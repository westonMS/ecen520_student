
<!--
Notes:
- Warnings:
  - Teach them how to set the tools to ignore warnings and how to get rid of warnings
  - Tell them that they should not have *any* warnings during synthesis
-- Any _new_ coding standards to add? It would be nice to add something for this assignment

- Future:
  - Make sure that the data displayed on the LEDs doesn't change/flicker (i.e., latch the data)
  - Note that many studens struggled debugging their receiver and the transmitter model at the same time. It wasn't clear which one has the problem.
     - Suggestion: create a top-level testbench that just hooks up my receiver model to their transmitter model and is used to validate their transmitter model. This way, they can have a known good transmitter model to test their receiver.
-->

# UART Receiver

The purpose of this assignment is to create a top-level UART receiver/transmitter in SystemVerilog and a testbench to validate your receiver.
You will also create a seven segment display controller for displaying data from your UART on the seven segment display.

## Assignment Instructions

Create a new directory in your repository as described above and put all the files for this assignment within this directory.

### Seven Segment Display Controller

### Seven Segment Controller and Testbench

Create a new "seven segment controller" module in VHDL that will drive the seven segment display of the Nexys DDR board. 
This module can be based on the [segment sevent display](http://ecen220wiki.groups.et.byu.net/labs/lab-05/) module developed in ECEN 220.
Note that there are eight digits on the seven segment display for this board so you will need to support all eight digits with your module. 
Make this module parametrizable with the following two parameters:

  * CLOCK_FREQUENCY (in Hz). Set the default to the clock rate of the nexys board.
  * MIN_DIGIT_DISPLAY_TIME_MS (in ms). Set the default to 20 ms. Use this parameter to determine how long to display each digit
 
Create a simple testbench for validating that your seven-segment display controller.
This testbench should check to make sure the seven segment display asserts the appropriate segment signals.
You will need to lower the MIN_DIGIT_DISPLAY_TIME_MS so that you can simulate this in a reasonable amount of time.
Create a makefile rule `make sim_ssd` for this simulation.

<!--
I am going to hold off on creating a testbench for this. I think it will be too much work for this assignment.

**Create a testbench for the seven segment controller**

`sim_7seg`
-->

### Create top-level design

Create a top-level design that uses the following top-level ports:

| Port Name | Direction | Width | Function |
| ---- | ---- | ---- | ----  |
| CLK100MHZ | Input | 1 | Clock |
| CPU_RESETN | Input | 1 | Reset (low asserted) |
| SW | Input | 8 | Switches (8 data bits to send) |
| BTNC | Input | 1 | Control signal to start a transmit operation |
| LED | Output | 16 | Board LEDs (used for data and busy) |
| UART_RXD_OUT | Output | 1 | Transmitter output signal |
| UART_TXD_IN | Input | 1 | Receiver input signal |
| LED16_B | Output | 1 | Used for TX busy signal |
| LED17_R | Output | 1 | Used for RX busy signal |
| LED17_G | Output | 1 | Used for RX error signal |
| Parameter Name | Default Value | Purpose |
| ---- | ---- | ---- |
| CLK_FREQUECY | 100_000_000 | Specify the clock frequency |
| BAUD_RATE  | 19_200 | Specify the receiver baud rate |
| PARITY | 1 | Specify the parity bit (0 = even, 1 = odd) |


Design your top-level circuit as follows:
* Instance your transmitter
  * Hook the TX output signal to the top-level `UART_RXD_OUT` pin of the board (i.e., to the host)
  * Attach the lower 8 switches on the board to the input to the UART transmitter (i.e., the value of the switches is the value to transmit over the UART).
  * Attach the lower 8 switches on the board to the lower 8 LEDs. This way the user can more easily see the value of the switches with the LEDs
  * Attach the tx busy signal to the LED16_B signal to provide a blue LED indicator when the transmitter is busy
* Instance your receiver
  * Hook the RX signal to the top-level `UART_TXD_IN` pin of the board (i.e., to the host)
  * Hook up the upper 8 LEDs to the data recevied by your receiver. These LEDs should display the last value received by the receiver. You should only update these LEDs when the 'data_strobe' indicates a new character has been received
  * Attach the rx busy signal to the LED17_R signal to provide a red LED indicator when the receiver is busy
  * Attach the rx error signal to the LED17_G signal to provide a green LED indicator when the receiver has an error
* Hook up the center button (BTNC) to your circuit so that when the button is pressed one character will be transmitted. You will need a debouncer and one-shot circuit to accomplish this. You will need to implement a simple state machine or handshaking protocol to make sure that only one character is sent for each button press.
* Attach the `CPU_RESETN` signal so that when pressed, the system will be reset (note that the input reset polarity is negative asserted)
* Add a two flip-flop synchronizer between the RX input signal and your receiver. This is necessary to avoid metastibilty and properly synchronize the asynchronous input.

### Top-level testbench

Create another testbench for your top-level design.
This testbench should be designed as follows:
* Make the top-level design parameterizable in baud rate, clock frequency, and parity. The default should be a baud rate of 19200, a clock frequency of 100 MHz, and odd parity.
* Create a free-running clock
* Instance your top-level design
* Attach the `UART_RXD_OUT` output of your top-level design (i.e., transmitter output) to the  `UART_TXD_IN` input of your top-level design (i.e., receiver input). This way when you transmit a character from your transmit module, it will be received by your receiver module.
* Perform the following sequence of events for your testbench:
  * Execute the simulation for a few clock cycles without setting any of the inputs
  * Set default values for the inputs (reset, buttons, and switchces)
  * Wait for a few clock cycle, Assert the reset for a few clock cycles, Deassert the reset (don't forget that the reset signal for the board is low asserted)
  * Perform at least 3 character transfers as follows:
    * Choose a random value for the character you want to send
    * Set the switch values to this value
    * Press btnc long enough to make it through your debouncer
    * Wait until the tx_busy and rx_busy LED values are both zero
    * Check to make sure the upper LEDs match the value you sent
    * Check to make sure there is no error

Make sure your top-level design successfully passes this testbench.
Add a makefile rule named `sim_top` that will perform this simulation from the command line.

When simulating, you can [change the top-level parameters](../resources/vivado_command_line.md#setting-parameters-for-simulation) of your testbench or module to simulate different conditions of your system.
Create another makefile rule named `sim_top_115200_even` that will simulate your top-level design with a baud rate of 115200 and even parity.
You will need to add the command line option to change the baud rate of your top-level design as descrbed [here](../resources/vivado_command_line.md#setting-parameters-for-simulation).

### Implementation and Download

At this point you are ready to implement your design, generate a bitfile and download it to your board.
Create a new makefile rule named `gen_bit` that will generate a bitfile named `uart_19200.bit` for your top-level design with the default top-level parameters.
Download your design to your board and use 'putty' to make sure the UART receiver is working correctly using Putty or some other terminal emulator.

After demonstrating that your uart works properly, create a new makefile rule named `gen_bit_115200_even` that will generate a bitfile operating with a baud rate of 115200 and even parity and named `uart_115200.bit`.
To generate such a bitfile you will need to change the top-level BAUD_RATE parameter to 115200 during the logic synthesis.
Instructions for setting top-level parameters during synthesis can be found [here](../resources/vivado_command_line.md#setting-parameters-for-synthesis).
Download this different bitfile with a different baud rate and make sure it is operating correctly in Putty.

The synthesis step is a very important part of the implementation process and you should always check the logs for warnings that are generated during this step.
It is a good practice to address _all_ warnings generated from the synthesis process. 
In many cases you will need to change your orginal HDL code to address the warnings.
Review your synthesis logs and try to address all of the warnings that you can.
In some cases you can ignore the warning.
If you are certain that you can ignore the warning, you will want to change the synthesis settings such that the particular warning is changed to an "INFO" or less severe message in the logs.
Review the instructions on [adjusting the message severity level](../resources/vivado_command_line.md#adjusting-message-severity-levels) to see how to do this.
These instructions list messages that can be downgraded and those that should be upgraded. 
You will need to make sure that you don't have *any* synthesis warnings in your implementation.

Note that you should add the following to your .xdc file to get rid of the "Missing CFGBVS and CONFIG_VOLTAGE Design Properties" warning:

```
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
```

## Submission and Grading

Once you have completed the assignment and verified that everything is working correctly, follow these steps to formally submit your assignment.

1. Prepare your repository
  * Make sure all of the _essential_ files needed to complete your project are committed into your repository
  * Make sure you have a  `.gitignore` file for your assignment directory and that all intermediate files are ignored.
  * Make sure you have a `makefile` with all the necessary make rules
    * `sim_ssd`:
    * `sim_top`: performs command line simulation of the top testbench
    * `sim_top_115200_even`: performs command line simulation of the top testbench
    * `gen_bit`: Generates a bitstream for your top-level design
    * `gen_bit_115200_even`: Generates a bitstream for your top-level design
2. Commit and tag your repository
  * Make sure all of your files are committed and properly tagged (using the proper tag)
3. Create your assignment [Readme.md](../resources/assignment_mechanics.md#assignment-submission) file
  * Create the template file based on the instructions linked above
  * Add the following items for the assignment-specific section of the readme:
    1. **Resoures**: Provide a summary of the number of resources your design uses (see the output from the utilization report). Specifically, indicate the number of `Slice LUTs`, `Slice Registers`, and `Bonded IOB` resources your design uses.
    2. **Warnings**: You should not have _any_ warnings in your project as described in the assignment instructions above. Make sure you don't have any warnings and state this in your readme.
    3. **Timing**: Determine the "Worst Negative Slack" (or WNS). This is found in the timing report and indicates how much timing you slack you have with the current clocking.



### Grading

I will follow these steps to grade this assignment:

1. Fetch and get tag
2. Check date of submission
3. Simulate and build your design (run all five make rules)
6. Download  both designs  and make sure they work properly
7. Check to see if there are any files that are generated during the build process but not ignored.
8. run `make clean` and see if there are any files that are not deleted that should be deleted.
10. Review your Readme.md to see if it has all the requirements
11. Review your code for compliance to the coding standards
  * Make sure your uart receiver is using only Verilog 95 constructs

