# i2s_rcvr
Inter-IC Sound (i2s) receiver

Hardware (FPGA) implementation of I2S receiver 

IO:

1. clk        : system clock 
2. bck        : bit clock - 12MHz 
3. reset_n    : global reset active low
4. lrck       : indicates channel
5. data       : audio serial data input
6. data_out   : 24 bit parallel audio data out synced to system clock (clk)

Architecture: 

1. Incoming data stream passes through shift register
2. Storage array used for left/right channel data
3. Edge detection of channel select signal
4. Parallel data pushed out at system clk
   
Tools:

1. Xilinx Vivado 2021.2
2. Device targeted: TBD
   
References:

1. Advanced FPGA Design Architecture, Implementation, and Optimization by Steve Kilts
2. Wikipedia
3. SystemVerilog for Design by Sutherland et al.
