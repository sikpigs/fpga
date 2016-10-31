module uart_tx_tb;

reg clk;
reg baud_gen_en;
reg rst_n;
wire baud_tick;

reg [2:0] tick_counter;
reg [7:0] rx_data;
reg tx_start;
reg [7:0] tx_data;

wire tx_busy;
wire tx_wire;
wire tx_error;
wire rx_bit;

initial
begin
  clk = 0;
  baud_gen_en = 0;
  rst_n = 0;
  tx_data = 8'b01010101;
  rx_data = 8'b0;
  tick_counter = 3'b0;
  tx_start = 0;

  #10 rst_n = 1;
  #15 baud_gen_en = 1;
  #20 tx_start = 1;
  #30 tx_start = 0;
end

baud_generator baud_gen(.clk(clk), .baud_gen_en(baud_gen_en), .rst_n(rst_n), .baud_tick(baud_tick));
uart_tx tx(.clk(clk), .baud_tick(baud_tick), .tx_wire(tx_wire), .rst_n(rst_n), .tx_data(tx_data), .tx_busy(tx_busy), .tx_start(tx_start));

always
begin
  #5 clk = !clk;
end

always @(posedge baud_tick)
begin
  if(tick_counter == 3'b000)
  begin
    rx_data = { rx_bit, rx_data[7:1] };
  end

  tick_counter = tick_counter + 1;
end

assign rx_bit = tx_wire;

endmodule

