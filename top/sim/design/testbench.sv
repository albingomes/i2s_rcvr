//===================================================================================
// Project      : i2s_rcvr
// File name    : testbench.sv 
// Designer     : Albin Gomes
// Device       : N/A
// Description  : testbench for i2s_rcvr.sv 
// Limitations  : N/A
// Version      : 0.1
//===================================================================================

`timescale 1ns / 1ps

module testbench();

//-----------------------------------------------------------------------------------
// Nets, Regs and parameter
//-----------------------------------------------------------------------------------
logic         test_clk;
parameter     test_clk_period = 41.67; // 24MHz
logic         test_bck;
parameter     test_bck_period = 83.33; // 12MHz
logic         test_reset_n;
logic         test_lrck;
logic         test_data;
logic [23:0]  test_data_out;
parameter     transaction = 100;
parameter     num_of_bits = 24;

//-----------------------------------------------------------------------------------
// DUT
//-----------------------------------------------------------------------------------
    
i2s_rcvr i2s_rcvr_0 (
    .clk          (test_clk),
    .bck          (test_bck),
    .reset_n      (test_reset_n),
    .lrck         (test_lrck),
    .data         (test_data),
    .data_out     (test_data_out)
);   

//-----------------------------------------------------------------------------------
// Initialize
//----------------------------------------------------------------------------------- 

initial begin
  test_clk        <= 1'b0;
  test_bck        <= 1'b0;
  test_reset_n    <= 1'b0;
  test_lrck       <= 1'b0;
  test_data       <= 1'b0;
end

//-----------------------------------------------------------------------------------
// Clocks 
//-----------------------------------------------------------------------------------

always #(test_bck_period/2) test_bck = !test_bck; //12 MHz clk
always #(test_clk_period/2) test_clk = !test_clk; //24 MHz clk

//-----------------------------------------------------------------------------------
// Stimulus
//-----------------------------------------------------------------------------------
    
initial begin
  #5;
  @(posedge test_bck);
  test_reset_n    = 1'b1;
  for (int i = 0; i < transaction; i++) begin
    @(negedge test_bck);
    test_lrck     = !test_lrck;
    for(int j=0; j < num_of_bits; j++) begin
      @(negedge test_bck);
      test_data = $urandom();
    end
  end
end
       
endmodule