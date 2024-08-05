
<!--
Notes:
-- Any _new_ coding standards to add? It would be nice to add something for this assignment


-->

# UART Receiver and Testbench

The purpose of this assignment is to create a UART receiver module and verify that it operates correctly with a custom testbench.
<!--
You will also be creating a UART transmitter simulation model as part of the assignment verification.
-->

## Assignment Instructions

<!--
Create a new directory in your repository as described above and put all the files for this assignment within this directory.

### Create a UART transmitter simulation model

Create a Verilog simulation model that simulates the operation of a transmitter.
Your transmitter should be parameterizable in terms of baud rate, parity, and clock frequency.
You should design your transmitter model such that: 
  * Print a message when starting a transmission (and indicate the value sent and parity mode)
  * Print a message when you are done with a transmission

| Parameter Name | Default Value | Purpose |
| ---- | ---- | ---- |
| CLK_FREQUECY | 100_000_000 | Specify the clock frequency |
| BAUD_RATE  | 19_200 | Specify the transmit baud rate |
| PARITY | 1 | Specify the parity bit (0 = even, 1 = odd) |

Design your transmitter model as a simple, non-synthesizable model using the testbench principles discussed in class (you may want to refer to the [rx_model.sv](../uart_transmitter/rx_model.sv) used in the previous assignment).

**TODO**: Add a reset?
-->

## Create a UART Receiver Module

The primary goal of this assignment is to design a UART receiver module that can receive data from a UART transmitter.
Create a UART receiver module that actively monitors the input data in signal receives a single byte of data and a parity bit.
<!-- 
Note that all other modules or testbenches you create for this assignment can use any Verilog or SystemVerilog constructs.
The intent of this requirement is to give you practice using old style `reg` and `wire` data types.
-->
There is a ECEN 220 lab description for the  [UART Receiver](http://ecen220wiki.groups.et.byu.net/labs/lab-11/) but the requirements for this receiver may be slightly different.

Create your receiver with the following ports and parameters

| Port Name | Direction | Width | Function |
| ---- | ---- | ---- | ----  |
| clk | Input | 1 | Clock |
| rst | Input | 1 | Reset |
| din | Input | 1 | RX input signal |
| dout | Output | 8 | Received data values |
| busy | Output | 1 | Indicates that the transmitter is in the middle of a transmit |
| data_strobe | Output | 1 | Indicates that a new data value has been received |
| rx_error | Output | 1 | Indicates that there was an error when receiving |
| Parameter Name | Default Value | Purpose |
| ---- | ---- | ---- |
| CLK_FREQUECY | 100_000_000 | Specify the clock frequency |
| BAUD_RATE  | 19_200 | Specify the receiver baud rate |
| PARITY | 1 | Specify the parity bit (0 = even, 1 = odd) |

Design your receiver such that:
* The 'busy' signal is asserted whenever you are in the middle of a transmission
* The 'rst' signal will initialize the internal state machine to idle
* Provide a single cycle 'data_strobe' signal when you have received a new data value. The `dout` signal should have the new data value when the `data_strobe` signal is asserted.
* When your state machine is reset, it should check to make sure the 'din' input is '1' before going to an IDLE state and accepting received data. The purpose of this is to avoid the case when the input line starts out low on reset.
* Set the `rx_error` signal low every time you start a new transaction. When a transaction is complete, set the `rx_error` signal to '1' if any of the three conditions occur:
  * A '0' is not sampled in the middle of the first start bit
  * The received parity is incorrect
  * A stop bit is not received (i.e., you do not receive a '1' in the middle of the stop bit)

<!--
    If you get a reset and the input din is a '0' then you should go to some sort of "Startup" type state that just sits there and waits until din goes high. Once din goes high you can go into an idle state to wait for din to go to 0 again. The reason for this is that you do not want to just immediately start receiveing a character upon reset. You want to start up in a known state.
-->

Note that you must follow the [Level 2](../resources/coding_standard#level_2) coding standards for your Verilog files.

## Receiver Testbench

Create a dedicated testbench for your receiver with the following requirements:
  * Instance your synthesizable transmitter from the first assignment
    * In your testbench print a message to the terminal whenever a new transmission begins. Print the data being sent and the parity mode. Save this value so you can check to see if the receiver received the correct value.
  * Instance your receiver module and hook up the transmitter to the receiver
    * In your testbench, print a message whenever the receiver has received a new data value. Print the data value received. Also, check to make sure that the value received is the same as the value sent by the transmitter.
  * Generate a free oscillating clock
  * Implement the following sequence of events for the testbench
    * Provide a few clocks to the receiver/transmitter with undefined inputs. This should put both modules in a bad state
    * Provide initial default values for the inputs to your modules (but do not start the receiver)
    * Provide a few more clocks to clock in these inputs
    * Issue a reset by waiting a few clock cycles, issuing the reset for a few clock cycles, and then deasserting the reset
  * Provide a testbench parameter `NUMBER_OF_CHARS` with a default value of 10 that indicates the number of characters to transmit    
  * Create a loop that issues one character over the transmitter at a time with the following specifications:
    * Provide a random number between 100 and 2000 clock cycles before starting a transmission
    * Transmit a random 8-bit value for the transaction
    * Check to make sure the character you sent is the character you received. Print a message that you correctly received the character you sent or print that an error occurred.
  * End your simulation with `$stop`

You may want to review the [testbench](../tx_sim/tx_tb.sv) that was created for you in the previous assignment as an example to get started.
You may refer to and model your testbench after the [ECEN 220 Transmitter testbench](http://ecen220wiki.groups.et.byu.net/resources/testbenches/tb_tx.sv) as well.
When your transmitter operates correctly with the testbench, create a makefile with the `sim_rx` rule that will simulate your transmitter with the testbench from the command line.
In addition, create a makefile rule `sim_rx_115200_even` that simulates the receiver with a baud rate of 115200 and even parity.

## Submission and Grading

Once you have completed the assignment and verified that everything is working correctly, follow these steps to formally submit your assignment.

1. Prepare your repository
  * Make sure all the _essential_ files needed to complete your project are committed into your repository, that no _non-essential_ files are committed to your repository, and that you have a `.gitignore` file for your assignment directory and that all intermediate files are ignored.
  * Make sure you have a `makefile` with all the necessary make rules
    * `sim_rx`: performs command line simulation of rx testbench
    * `sim_rx_115200_even`: performs command line simulation of rx testbench
2. Commit and tag your repository
  * Make sure all of your files are committed and properly tagged (using the proper tag)
3. Create your assignment [Readme.md](../resources/assignment_mechanics.md#assignment-submission) file
  * Create the template file based on the instructions linked above

### Grading

I will follow these steps to grade this assignment:

1. Fetch and get tag
2. Check date of submission
3. Simulate your design (run all make rules)
7. Check to see if there are any files that are generated during the build process but not ignored.
8. run `make clean` and see if there are any files that are not deleted that should be deleted.
8. Review all your commit logs
10. Review your Readme.md to see if it has all the requirements
11. Review your code for compliance to the coding standards
  * Make sure your uart receiver is using only Verilog 95 constructs

