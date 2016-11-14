module uart_xmit(
    input clk,
    input baud_tick,
    output tx_wire,
    input rst_n,

    input empty,
    input [7:0] data,
    output read
    );

wire tx_busy;
reg tx_start;

uart_tx tx(.clk(clk), .baud_tick(baud_tick), .tx_wire(tx_wire), .rst_n(rst_n),
    .rx_data(data), .tx_busy(tx_busy), .tx_start(tx_start));

localparam TX_IDLE   = 2'b00;
localparam TX_READ   = 2'b01;
localparam TX_RDWAIT = 2'b10;
localparam TX_BUSYWAIT = 2'b11;

reg [1:0] xmit_state;
reg read_req;

always @(posedge clk or negedge rst_n)
begin
  if(~rst_n)
  begin
    xmit_state <= TX_IDLE;
    read_req <= 0;
  end
end

always @(posedge clk)
begin
  case(xmit_state)
    TX_IDLE:
      if(~tx_busy && ~empty)
        xmit_state = TX_READ;
    TX_READ:
      if(~empty)
      begin
        read_req <= 1;
        xmit_state <= TX_RDWAIT;
      end
    TX_RDWAIT:
      begin
        tx_start <= 1;
        read_req <= 0;
        xmit_state <= TX_BUSYWAIT;
      end
    TX_BUSYWAIT:
      if(tx_busy)
      begin
        tx_start <= 0;
        xmit_state <= TX_IDLE;
      end
  endcase
end

assign read = read_req;

endmodule