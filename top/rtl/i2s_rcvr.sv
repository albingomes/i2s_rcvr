//===================================================================================
// Project      : i2s_rcvr
// File name    : i2s_rcvr.sv 
// Designer     : Albin Gomes
// Device       : N/A
// Description  : Receiver module for i2s 
// Limitations  : N/A
// Version      : 0.1
//===================================================================================

module i2s_rcvr (
  input                 clk,        // local system clock: faster than bck
  input                 bck,        // bit clock to be used for receive data: 12MHz
  input                 reset_n,
  input                 lrck,       // channel select
  input                 data,       // serial digital audio receive data
  output logic [15:0]   data_out    // parallel digital data out synchronized to system clock
);

//-----------------------------------------------------------------------------------
// Nets, Regs and states
//-----------------------------------------------------------------------------------

logic         lrck_reg;
logic         channel;
logic [3:0]   bit_counter;
logic [15:0]  shift_reg;
logic [15:0]  storage_reg;  


//-----------------------------------------------------------------------------------
// Assignments
//-----------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------
// Processes
//-----------------------------------------------------------------------------------

// for lrck edge detection
always_ff @(posedge bck) begin 
  lrck_reg  <= (reset_n == 0) ? 0 : lrck;
end

// channel select
always_ff @(posedge bck) begin
  if (reset_n == 0) begin
    channel <= 0;
  end 
  begin
    if (lrck == 1 && lrck_reg == 0) begin      //rising edge detected
      channel <= 1; // right channel
    end
    else if (lrck == 0 && lrck_reg == 1) begin // falling edge detected
      channel <= 0; // left channel
    end
  end
end

// counter for bits
always_ff @(posedge bck) begin
  if (reset_n == 0) begin
    bit_counter <= 15;
  end 
  else begin
    if ((lrck == 1 && lrck_reg == 0) || (lrck == 0 && lrck_reg == 1)) begin
      bit_counter <= 15;
    end
    else begin
      bit_counter <= (bit_counter == 0)? 0:bit_counter - 1;
    end
  end
end

// shift reg
always_ff @(posedge bck) begin
  if (reset_n == 0) begin
    shift_reg <= 16'h0000;
  end
  else begin
    shift_reg <= {shift_reg[14:0],data};
  end
end 

// store data
always_ff @(posedge bck) begin
  if(reset_n == 0) begin
    storage_reg <= 16'h0000;
  end
  else begin
    if (bit_counter == 0) begin
        storage_reg <= shift_reg;
    end
  end 
end

// data out on system clk
always_ff @(posedge clk)begin
  if (reset_n == 0) begin
    data_out    <= 0;
  end
  else begin
    data_out    <= storage_reg;
  end
end

endmodule