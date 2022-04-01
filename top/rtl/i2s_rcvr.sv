//===================================================================================
// Project      : i2s_rcvr
// File name    : i2s_rcvr.sv 
// Designer     : Albin Gomes
// Device       : 
// Description  :
// Limitations  :
// Version      :
//===================================================================================

module i2s_rcvr (
  input     clk,        // local system clock
  input     bck,        // bit clock
  input     reset_n,
  input     enable,
  input     lrck,       // channel select
  input     data
);

//-----------------------------------------------------------------------------------
// Nets, Regs and states
//-----------------------------------------------------------------------------------

logic         lrck_reg;
logic [4:0]   bit_counter;
logic [23:0]  shift_reg;

//-----------------------------------------------------------------------------------
// Processes
//-----------------------------------------------------------------------------------

// for lrck edge detection
always_ff(posedge bck) begin 
  lrck_reg  <= (reset_n == 0) ? 0 : lrck;
end

// counter for bits
always_ff(posedge bck) begin
  if (reset_n == 0) begin
    bit_counter <= 24;
  end 
  else begin
    if ((lrck == 1 && lrck_reg == 0) || (lrck == 0 && lrck_reg == 1)) begin
      bit_counter <= 24;
    end
    else begin
      bit_counter <= bit_counter - 1;
    end
  end
end

// shift reg
always_ff(posedge bck) begin
  if (reset_n == 0) begin
    shift_reg <= 0;
  end
  else begin
    shift_reg <= {shift_reg[23:1],data};
  end
end 


endmodule