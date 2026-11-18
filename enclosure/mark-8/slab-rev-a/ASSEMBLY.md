# Harmony Mark-8 slab rev A: assembly

Build time is about 30 minutes once the parts are printed. The only soldering is the optional motor. Flash and test with the back open before you close the case.

![Exploded view](renders/exploded-isometric.png)

## Parts

| No. | Part | Source | Qty |
| --- | --- | --- | --- |
| 1 | Front shell | Printed, case colour (`print/front-shell.3mf`) | 1 |
| 2 | Wheel disc | Printed, black (`print/wheel-disc.3mf`) | 1 |
| 3 | Side button cap | Printed, case colour (`print/button-cap.3mf`) | 1 |
| 4 | Heat-set insert, M2 x 3 long, about 3.2 OD | Bought | 4 |
| 5 | Screen DLC-T2.7DDS#1 | DigiKey | 1 |
| 6 | Screen FPC (part of the screen; shown folded) | With 5 | - |
| 7 | Main board, assembled | JLCPCB | 1 |
| 8 | LiPo pack 404050 (or 403450), 1S, protected, JST PH 2.0 plug | Bought | 1 |
| 9 | Vibration motor LCM1027A2445F (optional) | LCSC C2759984 | 1 |
| 10 | Back plate | Printed, case colour (`print/back-plate.3mf`) | 1 |
| 11 | Screw M2 x 4, button head (ISO 7380, head 3.5 x 1.1) | Bought | 4 |

Also: 1 mm double-sided foam tape (a 35 x 45 piece for the battery), a strip of masking or Kapton tape, and CA glue or foam tape for the motor.

Tools: soldering iron with an M2 heat-set tip (a clean conical tip also works), fine tweezers, a plastic spudger or a fingernail, a ruler and a fine marker, a multimeter, a screwdriver for the M2 screws.

## Directions on the bench

Lay the front shell face down on a soft cloth with the USB-C opening toward you. From now on:

- "Up" means away from the bench, toward the back of the device.
- The side button wall is on your **left**. The card slot is to the **right** of the USB-C opening.
- The screen end is away from you.

## Steps

1. **Heat-set inserts (4) into the front shell (1).** Set the iron to 210 to 220 C for PLA (240 to 250 C for PETG). Put an insert on each of the four corner bosses. The 0.3 lead-in centres it. Press straight down with light force and let the heat do the work. Stop when the top of the insert is flush with the boss face, or at most 0.1 below it. Hold still for 2 s, then lift the iron. The insert is 3.0 long and the hole is 3.6 deep, so the melted plastic has room under it. Check that each insert is square to the face.

2. **Wheel disc (2) into the front shell (1).** Put the disc in from the inside, labels down. Turn it until its small key tab drops into the notch in the recess. The notch is on the side-button side of the opening, toward the screen end. The disc now sits flush with the front face. Turn the shell over and check that HOME is at the top.

3. **Side button cap (3) into the front shell (1).** From the inside, push the cap head first through the slot in the left wall. The two ears stay inside and rest against the wall. The open slot in the cap faces into the case. Put a strip of tape over the cap on the outside so it cannot fall in before the board holds it.

4. **Screen (5) into its pocket.** Peel the protective film off the front of the screen. Wipe the screen and the window. Lower the screen face down into the pocket with the FPC end toward the wheel. It sits between the two side walls, the top wall and two short lips at its lower corners. Press lightly at the four corners. It must lie flat on the skin.

5. **Lift the FPC (6) out of the way.** Bend the FPC up at the screen edge, inside the first 3 mm of the FPC (the thin "single area" next to the glass). Let it stand up out of the case. Do not crease it. The board goes in next and needs the space where the FPC was lying.

6. **Board (7) onto the locating pins.** Hold the board with the components up and the copper wheel rings down. Tilt it so the USB-C end is low. Slide the USB-C receptacle into its opening in the near wall, then lower the far end. The two pins in the shell go through the two small bare holes: one near the far edge, right of centre, and one near the left edge, about 10 mm from the near end. The side button's small plunger on the left board edge slides into the slot of the cap. Press the board flat. It lies on the skin and on the disc.

   Why the board goes in before the FPC tail: the FPC must be lifted first, because flat it covers the board area. The board then has to go in tilted to get the USB-C receptacle into the wall. The screen connector J2 is on the side of the board that now faces up, and the strip in front of its slot is free of tall parts, so the tail slides in flat after the board is in place. If you plug the FPC in first, the tilt-in bends the FPC at the connector.

7. **Fold the FPC tail (6).** Measure 25.2 mm from the contact end of the tail and mark the line across the tail with a fine marker. Fold the end down and under the tail along that line, 180 degrees. Make a soft fold, not a hard crease. After the fold the gold contacts face up, toward you. Pin 1 (the edge of the tail nearer the USB-C end) stays nearer the USB-C end.

8. **Open the J2 latch.** J2 is the small black connector just above the USB-C receptacle, a little right of centre. Its slot faces left. The latch is on its right side. Lift the latch with a fingernail or spudger. It swings up and over to the right, about 90 degrees.

9. **Insert the FPC and close the latch.** Lay the FPC down: the wide part slants down over the far edge of the board, the narrow leg runs toward you on the right of centre, past the square black buzzer, and the folded tail runs across to the left. Slide the folded end flat into the J2 slot from the left, contacts up, pin 1 toward you. Push it straight in until it stops (about 1.3 mm). Close the latch. Pull very gently: the tail must not move.

10. **Settle the extra FPC length.** The FPC is about 7 mm longer than its path. Let the extra length make one soft loop in the narrow leg, between the buzzer and the card socket. Nothing may press on the loop, and it must stay off the four round bare press pads on the board. See `renders/closeup-fpc-fold.png`.

11. **Check the battery polarity.** J4 pin 2 is plus (the + mark on the board). Packs with JST PH plugs come wired both ways. With a meter, check that the plug pin that will go into the + side of J4 is the red, positive wire. If it is reversed, do not plug it in: swap the two pins in the plug housing (lift each latch tab with a needle) or use another pack. The board blocks a reversed pack, but nothing charges until it is right.

12. **Battery (8).** Stick 1 mm foam tape on the back of the screen. Lay the pack on it, cable end toward you, centred left to right. Plug the cable into J4 (the large white connector at the right, near the screen edge). The plug goes in toward you. Lay the wires in the gap between the pack and the screen edge. Keep them off the FPC.

13. **Optional motor (9).** Glue the motor into its round seat on the inside of the back plate (10). Solder the red lead to M+ and the other lead to M- (the two labelled pads on the right part of the board, beside the card socket). Leave about 5 mm of slack so the back plate can open.

14. **Test before you close it.** With the back still open, plug in USB-C. Flash the board and run the bring-up test (see `firmware/mark-8/`). Check the screen colour bars, the wheel (all eight sectors and the centre), the side button, the buzzer, the card, the charge LED, the battery reading and the motor if fitted. Unplug USB-C. Fix anything now: it is much easier with the back open.

15. **Close the back plate (10) with the screws (11).** Lower the back plate with its posts down. The four posts land on the four round bare pads of the board. The lip goes inside the walls. Check all round the edge that no wire or FPC is caught. Put in the four M2 x 4 screws. Tighten in a cross pattern until each head sits in its counterbore, then stop. That is about 0.1 Nm: light finger force on a small driver. Do not use M2 x 5 or longer screws: they bottom out in the two bosses under the screen.

## Views

Exploded section through press post PP2, the buzzer, J2 and the USB-C receptacle:

![Exploded section](renders/exploded-section.png)

Assembled, front and back:

![Front](renders/assembled-front.png)

![Back](renders/assembled-back.png)

FPC route with the back plate and battery removed:

![FPC fold](renders/closeup-fpc-fold.png)

USB-C opening, card slot and side button:

![USB-C and microSD](renders/closeup-usb-microsd.png)

![Side button](renders/closeup-side-button.png)
