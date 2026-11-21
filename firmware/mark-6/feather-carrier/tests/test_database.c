#include "album.h"
#include <assert.h>
#include <pthread.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
static album_t library;
static void *reader(void *arg){unsigned seed=(unsigned)(uintptr_t)arg;album_track_t t;for(unsigned i=0;i<2000;i++){unsigned id=(i*37+seed)%library.count;assert(album_read_track(&library,id,&t));assert(t.path[0]&&t.title[0]);}return NULL;}
int main(int argc,char **argv){
 assert(argc>=2);
 bool loaded=album_load(argv[1],&library);
 if(argc>2&&!strcmp(argv[2],"invalid")){assert(!loaded&&!library.count&&!library.database);puts("PASS invalid database rejected without fallback scan");return 0;}
 assert(loaded&&library.database&&library.count>512);
 album_track_t t;
 if(argc>2&&!strcmp(argv[2],"record")){assert(!album_read_track(&library,1,&t));album_close(&library);puts("PASS corrupted record rejected");return 0;}
 unsigned *ids=malloc(ALBUM_INDEX_MAX_TRACKS*sizeof(*ids));assert(ids);
 unsigned n=album_query(&library,ALBUM_QUERY_ALL,ALBUM_INDEX_MAX_TRACKS,ids,ALBUM_INDEX_MAX_TRACKS);assert(n==library.count);
 assert(!album_query(&library,ALBUM_QUERY_ALL,0,ids,1));
 char previous[128]={0};
 for(unsigned i=0;i<n;i++){assert(album_read_track(&library,ids[i],&t));assert(strcasecmp(previous,t.title)<=0);strcpy(previous,t.title);assert(album_find_path(&library,t.path)==(int)ids[i]);}
 unsigned artists=album_query(&library,ALBUM_QUERY_ARTISTS,0,ids,ALBUM_INDEX_MAX_TRACKS);assert(artists);
 unsigned *artist_ids=malloc(artists*sizeof(unsigned));memcpy(artist_ids,ids,artists*sizeof(unsigned));unsigned total=0;
 for(unsigned i=0;i<artists;i++){
  unsigned albums=album_query(&library,ALBUM_QUERY_ALBUMS,artist_ids[i],ids,ALBUM_INDEX_MAX_TRACKS);assert(albums);
  unsigned *reps=malloc(albums*sizeof(unsigned));memcpy(reps,ids,albums*sizeof(unsigned));
  for(unsigned j=0;j<albums;j++){unsigned songs=album_query(&library,ALBUM_QUERY_SONGS,reps[j],ids,ALBUM_INDEX_MAX_TRACKS);assert(songs);total+=songs;for(unsigned k=0;k<songs;k++)assert(ids[k]==reps[j]+k);}
  free(reps);
 }
 /* Labels must agree with real metadata for every track, including group boundaries. */
 for(unsigned i=0;i<library.count;i++){album_track_t label;assert(album_read_track(&library,i,&t));assert(album_read_labels(&library,i,&label));assert(!strcmp(label.artist,t.artist)&&!strcmp(label.album,t.album));}
 assert(total==library.count);assert(album_find_path(&library,"not-present.mp3")==-1);assert(!album_read_track(&library,library.count,&t));
 pthread_t threads[3];for(unsigned i=0;i<3;i++)assert(!pthread_create(&threads[i],NULL,reader,(void *)(uintptr_t)i));for(unsigned i=0;i<3;i++)pthread_join(threads[i],NULL);
 printf("PASS database: %u songs, %u artists, grouped navigation, title order, path restore, concurrent cache reads\n",library.count,artists);
 /* Removing access to the catalog must not break group browsing. */
 char source[1024],hidden[1024];snprintf(source,sizeof(source),"%s/library.hdb",argv[1]);snprintf(hidden,sizeof(hidden),"%s/library.hidden",argv[1]);assert(!rename(source,hidden));
 for(unsigned i=0;i<library.count;i++){assert(album_read_labels(&library,i,&t));assert(t.artist[0]&&t.album[0]);}
 for(unsigned i=0;i<artists;i++)assert(album_query(&library,ALBUM_QUERY_ALBUMS,artist_ids[i],ids,ALBUM_INDEX_MAX_TRACKS));
 assert(!rename(hidden,source));puts("PASS artist/album labels and group navigation with catalog unavailable");
 free(artist_ids);free(ids);album_close(&library);assert(!library.count&&!library.database);
}
