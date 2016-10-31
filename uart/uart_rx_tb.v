module uart_rx_tb;

reg clk;
reg baud_gen_en;
reg rst_n;
wire baud_tick;

reg [2:0] tick_counter;
reg [20:0] test_data;
reg [7:0] recv_data;
wire [7:0] rx_data;
wire rx_data_ready;
wire rx_wire;
wire rx_error;

initial
begin
  clk = 0;
  baud_gen_en = 0;
  rst_n = 0;
  test_data = 21'b100101010110101010101;
  tick_counter = 0;

  #10 rst_n = 1;
  #15 baud_gen_en = 1;
end

baud_generator baud_gen(.clk(clk), .baud_gen_en(baud_gen_en), .rst_n(rst_n), .baud_tick(baud_tick));
uart_rx rx(.clk(clk), .baud_tick(baud_tick), .rx_wire(rx_wire), .rst_n(rst_n), .rx_data(rx_data), .rx_data_ready(rx_data_ready), .rx_error(rx_error));

always
begin
  #5 clk = !clk;
end

always @(posedge baud_tick)
begin
  tick_counter = tick_counter + 1;
  if(tick_counter == 3'b000)
  begin
    test_data = { test_data[19:0], 1'b1 };
  end
end

always @(posedge rx_data_ready)
  recv_data = rx_data;

assign rx_wire = test_data[20];

endmodule

