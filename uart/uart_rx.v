module uart_rx(input clk, input baud_tick, input rx_wire, input rst_n, output wire [7:0] rx_data, output rx_data_ready, output rx_error);

localparam IDLE  = 4'b0000;
localparam START = 4'b0001;
localparam STOP  = 4'b0010;
localparam BIT_0 = 4'b1000;
localparam BIT_1 = 4'b1001;
localparam BIT_2 = 4'b1010;
localparam BIT_3 = 4'b1011;
localparam BIT_4 = 4'b1100;
localparam BIT_5 = 4'b1101;
localparam BIT_6 = 4'b1110;
localparam BIT_7 = 4'b1111;

reg [3:0] state;
reg [2:0] tick_cntr;
reg rx_bit;
reg [7:0] data;
reg data_ready;
reg error;

wire read_bit;

always @(posedge baud_tick)
  if(rst_n)
    tick_cntr <= tick_cntr + 1;

always @(posedge clk or negedge rst_n)
begin
  if(~rst_n)
  begin
    state <= IDLE;
    rx_bit <= 1;
    data <= 8'bz;
    tick_cntr <= 3'b0;
    data_ready <= 0;
    error <= 0;
  end
end

always @(posedge baud_tick)
begin
  rx_bit = rx_wire;
  begin
    case(state)
      IDLE:
      if(~rx_bit)
      begin
        state <= START;
        tick_cntr <= 0;
        data_ready <= 0;
        error <= 0;
        data <= 8'bz;
      end
      START: 
        if(read_bit) 
          state <= BIT_0;
      BIT_0:
        if(read_bit) 
          state <= BIT_1;
      BIT_1:
        if(read_bit) 
          state <= BIT_2;
      BIT_2:
        if(read_bit) 
          state <= BIT_3;
      BIT_3:
        if(read_bit) 
          state <= BIT_4;
      BIT_4:
        if(read_bit) 
          state <= BIT_5;
      BIT_5:
        if(read_bit) 
          state <= BIT_6;
      BIT_6:
        if(read_bit) 
          state <= BIT_7;
      BIT_7:
        if(read_bit) 
          state <= STOP;
      STOP:
      if(read_bit)
        begin
          data_ready <= 1; 
          state <= IDLE;
          error <= rx_bit != 1;
        end
      default:
        state <= IDLE;
    endcase
  end

  // all the states in which to read from the RX wire have bit 3 asserted
  if(read_bit && state[3])
    data <= { rx_bit, data[7:1] };
end

assign read_bit = tick_cntr == 3'b100; // sample in the 'middle'

assign rx_data = data;
assign rx_data_ready = data_ready;
assign rx_error = error;

endmodule
