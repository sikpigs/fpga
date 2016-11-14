`timescale 1 ps / 1 ps
module uart_recv_tb;

reg clk;
reg baud_gen_en;
reg rst_n;
wire baud_tick;

reg [2:0] tick_counter;
reg [15:0] test_data;
reg [19:0] test_input;
reg [1:0] byte_cntr;
wire rx_wire;

reg rdreq;
wire [7:0] data;
wire wrreq;
wire rdempty;
wire wrfull;
wire [7:0] q;

initial
begin
  clk = 0;
  baud_gen_en = 0;
  rst_n = 0;
  test_data[15:8] = 8'b01010101;
  test_data[7:0] = 8'b10101010;
  test_input = { 2'b10, test_data[15:8], 2'b10, test_data[7:0] };
  tick_counter = 0;
  rdreq = 0;
  byte_cntr = 0;

  #5 rst_n = 1;
  #5 baud_gen_en = 1;

  #90000 rdreq <= 1;
  #10 rdreq <= 0;
  #11 if(q != test_data[7:0])
    $display("Invalid byte1");
  #20 rdreq <= 1;
  #30 rdreq <= 0;
  #31 if(q != test_data[15:8])
    $display("Invalid byte2");
  $stop;
end

uart_fifo fifo(
	.data(data),
	.rdclk(clk),
	.rdreq(rdreq),
	.wrclk(clk),
	.wrreq(wrreq),
	.q(q),
	.rdempty(rdempty),
	.wrfull(wrfull));

baud_generator baud_gen(.clk(clk), .baud_gen_en(baud_gen_en), .rst_n(rst_n), .baud_tick(baud_tick));
uart_recv rx(.clk(clk), .baud_tick(baud_tick), .rx_wire(rx_wire), .rst_n(rst_n), .data_in_full(wrfull), .data_in(data), .data_in_write(wrreq));

always @(posedge wrreq)
begin
  byte_cntr <= byte_cntr + 1;
end

always
begin
  #5 clk = !clk;
end

always @(posedge baud_tick)
begin
  tick_counter = tick_counter + 1;
  if(tick_counter == 3'b000)
  begin
    test_input = { test_input[18:0], 1'b1 };
  end
end

assign rx_wire = test_input[19];

endmodule


