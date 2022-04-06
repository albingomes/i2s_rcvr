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
  input           clk,        // local system clock: faster than bck
  input           bck,        // bit clock to be used for receive data: 12MHz
  input           reset_n,
  input           lrck,       // channel select
  input           data,       // serial digital audio receive data
  output [23:0]   data_out    // parallel digital data out synchronized to system clock
);

//-----------------------------------------------------------------------------------
// Nets, Regs and states
//-----------------------------------------------------------------------------------

logic         lrck_reg;
logic         channel;
logic         channel_sync_flag;
logic [4:0]   bit_counter;
logic [23:0]  shift_reg;
logic [23:0]  ch0_reg;  // left channel
logic [23:0]  ch1_reg;  // right channel
logic [23:0]  sync_flop0;
logic [23:0]  sync_flop1;

//-----------------------------------------------------------------------------------
// Assignments
//-----------------------------------------------------------------------------------
assign data_out = sync_flop1; 

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
    if (lrck == 1 && lrck_reg == 0) begin //rising edge detected
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
    bit_counter <= 23;
  end 
  else begin
    if ((lrck == 1 && lrck_reg == 0) || (lrck == 0 && lrck_reg == 1) || (bit_counter == 0)) begin
      bit_counter <= 23;
    end
    else begin
      bit_counter <= bit_counter - 1;
    end
  end
end

// shift reg
always_ff @(posedge bck) begin
  if (reset_n == 0) begin
    shift_reg <= 24'h000000;
  end
  else begin
    shift_reg <= {shift_reg[23:1],data};
  end
end 

// store data
always_ff @(posedge bck) begin
  if(reset_n == 0) begin
    ch0_reg <= 24'h000000;
    ch1_reg <= 24'h000000;
  end
  else begin
    if (bit_counter == 0) begin
      if (channel == 0) begin     // left channel
        ch0_reg           <= shift_reg;
        channel_sync_flag <= 0;   // left channel ready for data sync
      end 
      else begin                  // right channel
        ch1_reg           <= shift_reg;
        channel_sync_flag <= 1;   // right channel ready for data sync
      end 
    end
  end 
end

// Syncronization to system clk
always_ff @(posedge clk)begin
  if (reset_n == 0) begin
    sync_flop0  <= 24'h000000;
    sync_flop1  <= 24'h000000;
  end
  else begin
    if(channel_sync_flag == 0) begin // left channel data ready for sync
      sync_flop0  <= ch0_reg;
      sync_flop1  <= sync_flop0;
    end
    else begin                       // right channel data ready for sync
      sync_flop0  <= ch1_reg;
      sync_flop1  <= sync_flop0;
    end
  end
end

endmodule