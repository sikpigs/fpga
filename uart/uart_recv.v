module uart_recv(
    input clk,
    input baud_tick,
    input rx_wire,
    input rst_n,

    output [7:0] data_in,
    input data_in_wait,
    output data_in_write
    );

wire [7:0] rx_data;
wire rx_data_ready;
wire rx_error;

uart_rx rx(.clk(clk), .baud_tick(baud_tick), .rx_wire(rx_wire), .rst_n(rst_n),
    .rx_data(rx_data), .rx_data_ready(rx_data_ready), .rx_error(rx_error));

localparam RX_IDLE   = 2'b00;
localparam RX_WRITE  = 2'b01;
localparam RX_WRWAIT = 2'b10;

reg [7:0] recv_data;
reg recv_state;
reg write_req;

// wait for rx_data_ready
always @(posedge rx_data_ready)
begin
  // save received data
  recv_data = rx_data;
  recv_state = RX_WRITE;
end

assign data_in = recv_data;
assign data_in_write = write_req;

always @(posedge CLOCK_50)
begin
  case(recv_state)
    RX_IDLE:
    RX_WRITE:
      if(data_in_wait == 1'b0)
      begin
        write_req  <= 1;
        recv_state <= RX_WRWAIT;
      end
    RX_WRWAIT:
      if(data_in_wait == 1'b0)
      begin
        write_req <= 0;
        recv_state <= RX_IDLE;
      end
  endcase
end

endmodule
