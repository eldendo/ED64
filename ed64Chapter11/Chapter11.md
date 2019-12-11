
# ED64 - HOW TO WRITE A COMMODORE 64 EMULATOR  
Copyright 2006 - 2019 by ir. Marc Dendooven

## Chapter 11: Conclusion

To my astonishment it's already 10 years ago since I wrote the last chapter, and more than 13 years since I started with this project. Since I recently started a completely new commodore 64 emulator project, I will write here a conclusion for the former one.

I started ed64 in a very naive way: I wrote an emulator, as I mentioned it in the first chapter, the way a machine code programmer 'sees' the machine. I never tended to emulate the computer exactly.  For most computer systems this would have been enough... but not for the commodore 64. Programmers were (and still are - there is still a c64 scene active) doing tricks with the hardware that were never intended by the designers. The simplified view I emulated would never be able to cope with that sort of programs. So I decided to stop the project and start all over again, but this time with an emulator that tries to mimic the original hardware as close as possible.

To continue the habit of publishing new code with each chapter, I hereby present the (probably) final (but not finished) version of ed64. 

I changed the graphics library from winGraph to ptcGraph. This has two advantages:

- ptcGraph is included in the freePascal distribution. So no need to look for and link with an external library
- ptcGraph works not only on windows but also on GNU/linux (and probably also on other systems). In 2006 I used m$ windows but like every sane person I switched permanently to a better environment.

Have fun with it !

I hope you will follow my new project (probably called Commander64). Thanks for the interest in my projects.

(you can find the code here)[./ed64Chapter11]
