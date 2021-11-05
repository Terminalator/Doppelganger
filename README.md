# Doppelganger
This is my attempt at reverse engineering the Doppelganger program that came with the Phantom from Trilogic. Also see Thomas Christophe's project The-Phantom for more information on this project.

I have not used 6502 assembly language in many years so I have had to not only refresh my knowledge of it but also learn the syntax of Kick Assembler - I haven't even done that yet! Many aspects of the C64 architecture I am unfamiliar with, especially peripheral communications. So you can see, I picked the wrong projected to start off with. 

When I initally disassembled the code, it was a bit of a mess. Data was interpeted as code and vice-versa. As a result the program crashed when SYS'ed. It took many hours going through the code to tidy it up and change all the raw data to .byte and .text lines. I now have it where the program runs fine and appears to work as intended.

This has been (and still is) a great learning project for me and I am continuing to work my way through it, slowly. I have reaquainted myself with many of my old C64 books which have sat on my bookshelf for many years, unused. 

All I have succeded in doing so far is to add a lot of comments to the disassembled code. My plan of attack has been to randomly pick a section of code and comment it as much as I can until I hit a wall, then I move to somewhere else in the code. The quality of my comments varies from, "INY // increase Y by 1" to things that might only make sense to me e.g. ".byte $ab // T 90 deg ccw". Many of my comments are incorrect and this is due to my lack of understanding of C64 / 1541 communications.

It's difficult trying to do this while at the same time, learning how to use the actual IDE / Assembler / Hex Editor etc. At the minute I am using Linux with IDE65xx, C64Debugger and Bless hex editor. I have wasted a lot of time searching for what might be best for my use case but eventually threw in the towel and just got on with doing something.

The audience that this project will appeal to is probably limited right now to about 2 people but if you can help in any way, please do so. BTW, this is my first venture with github so expect some (a lot of) mistakes

![20211102_230327_1 resized](https://user-images.githubusercontent.com/19365728/140433118-ce8fb3d7-a519-4e31-adf9-e7772ee03103.jpg)
