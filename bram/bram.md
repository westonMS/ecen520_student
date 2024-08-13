<!--

Need to be more clear on Putty settings. 
- Parity? (enforce it!)
- Default baud rate?
They use glbl.v file for simulation. Need to include in their repository.
Don't hard code any paths in makefile! (perhaps have an environment variable that is set so I can reuse their makefiles)
- Have them simulate the full fight song

Futgure: if they hit enter, make sure both CR/LF are sent back
- buffer empties when right pressed.
- start fight song with new line (make it more clear how to setup putty and what to send at the end of the line)
- Have the fight song spit out the text as fast as possible (no delays).
-->
# BRAM

In this assignment you will practice instancing BRAMs and interface them to your UART. 
You will use your BRAM to buffer data received from the UART receiver and to send over the transmitter. 
Two different BRAMs will be used in this assignment. 
You will need to interface these two BRAMs to your UART as described below.

<!--
You can create this design in a single HDL file if you like.
-->

**Make a module** Make one module that does the fight song and a different module that does the replay buffer.

## Fight Song BRAM

Instance a single BRAM as a device primitive in your HDL (do not 'infer' the BRAM with your RTL). 
This BRAM should be organized as 8bit x 4096 (i.e., 4096 8-bit ASCII characters). 
Initialize the contents of the BRAM to include the text of the BYU fight song (see below). 
Note that the fight song will not fill the entire BRAM so you should only send the characters associated with the fight song and no more.
Make sure you send new line characters(\r\n) at the end of each line.

You should design your circuit so that when the **left** button is pressed, the _entire_ fight song is sent over the transmitter UART. 
You will need to implement flow control so that you don't send another character until the previous character has been sent. 
Also, you will need to put some sort of null or stop character at the end of the fight song so that you konw when to stop.

```
Rise all loyal Cougars and hurl your challenge to the foe.
You will fight, day or night, rain or snow.
Loyal, strong, and true
Wear the white and blue.
While we sing, get set to spring.
Come on Cougars it's up to you. Oh!

Chorus:
Rise and shout, the Cougars are out
along the trail to fame and glory.
Rise and shout, our cheers will ring out
As you unfold your victr'y story.

On you go to vanquish the foe for Alma Mater's sons and daughters.
As we join in song, in praise of you, our faith is strong.
We'll raise our colors high in the blue
And cheer our Cougars of BYU.
```

If the left button is pressed again during transmission you should ignore it (i.e., send the entire text before sending another one)

## UART Buffer BRAM

Implement a UART "buffer" with a second BRAM that saves the data received from the UART receiver one character after another.
Infer a second BRAM from HDL (no instancing of primitive) that is organized the same as the previous BRAM (i.e., 8x4096). 
This BRAM should store each character received from the UART in one address after the next. 
Create a counter that indicates the location where to store the next UART received character (you will need to display this counter in hex on the seven segment display).
When the **right** button is pressed, your circuit should send each character received in the BRAM over the UART back to the host.
Once the data has been sent, reset your counters so that you only send the new data received after the button has been pressed (you don't want to send the data received more than once).

Your BRAM will act like a FIFO: characters received from the UART are placed in the BRAM FIFO and when the button is pressed, the BRAM fifo is read and sent over the transmitter until the FIFO has emptied.

## Top-Level Testbench

Create a top-level testbench that instantiates your design and simulates the behavior of both button presses.
Create a makefile rule `sim_top` that performs this simulation from the commandline.
Create a makefile rule `gen_bit` that generates a bitstream for your top-level design.


## Submission


1. Prepare your repository
  * Make sure all of the _essential_ files needed to complete your project are committed into your repository
  * Make sure you have a  `.gitignore` file for your assignment directory and that all intermediate files are ignored.
  * Make sure you have a `makefile` with all the necessary make rules
    * `sim_top`: performs command line simulation of the top testbench
    * `gen_bit`: Generates a bitstream for your top-level design
2. Commit and tag your repository
  * Make sure all of your files are committed and properly tagged (using the proper tag)
3. Create your assignment [Readme.md](../resources/assignment_mechanics.md#assignment-submission) file
  * There are no assignment specific requriements for the readme

