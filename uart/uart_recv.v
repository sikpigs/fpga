module uart_recv(
    input clk,
    input baud_tick,
    input rx_wire,
    input rst_n,

    input data_in_full,
    output [7:0] data_in,
    output data_in_write
    );

wire rx_data_ready;
wire rx_error;

uart_rx rx(.clk(clk), .baud_tick(baud_tick), .rx_wire(rx_wire), .rst_n(rst_n),
    .rx_data(data_in), .rx_data_ready(rx_data_ready), .rx_error(rx_error));

localparam RX_IDLE   = 2'b00;
localparam RX_WRITE  = 2'b01;
localparam RX_WRWAIT = 2'b10;

reg [1:0] recv_state;
reg write_req;

always @(posedge clk or negedge rst_n)
begin
  if(~rst_n)
  begin
    recv_state <= RX_IDLE;
    write_req <= 0;
  end
end

// wait for rx_data_ready
always @(posedge rx_data_ready)
begin
  // save received data
  recv_state = RX_WRITE;
end

always @(posedge clk)
begin
  case(recv_state)
    RX_WRITE:
      if(~data_in_full)
      begin
        write_req <= 1;
        recv_state <= RX_WRWAIT;
      end
    RX_WRWAIT:
      begin
        write_req <= 0;
        recv_state <= RX_IDLE;
      end
  endcase
end

assign data_in_write = write_req;

endmodule
