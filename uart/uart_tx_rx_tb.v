module uart_tx_rx_tb;

reg clk;
reg baud_gen_en;
reg rst_n;
wire baud_tick;

reg tx_start;
reg [7:0] tx_data;
reg [7:0] recv_data;

wire [7:0] rx_data;
wire rx_data_ready;
wire rx_error;

wire tx_busy;
wire tx_wire;

initial
begin
  clk = 0;
  baud_gen_en = 0;
  rst_n = 0;
  tx_data = 8'b01010101;
  recv_data = 8'b0;

  tx_start = 0;

  #10 rst_n = 1;
  #15 baud_gen_en = 1;
  #20 tx_start = 1;
  #30 tx_start = 0;
end

baud_generator baud_gen(.clk(clk), .baud_gen_en(baud_gen_en), .rst_n(rst_n), .baud_tick(baud_tick));
uart_tx tx(.clk(clk), .baud_tick(baud_tick), .tx_wire(tx_wire), .rst_n(rst_n), .tx_data(tx_data), .tx_busy(tx_busy), .tx_start(tx_start));
uart_rx rx(.clk(clk), .baud_tick(baud_tick), .rx_wire(tx_wire), .rst_n(rst_n), .rx_data(rx_data), .rx_data_ready(rx_data_ready), .rx_error(rx_error));

always
begin
  #5 clk = !clk;
end

always @(posedge rx_data_ready)
  recv_data = rx_data;

endmodule


