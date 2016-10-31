module uart_test(input CLOCK_50, inout [33:0] GPIO_0, input [1:0] KEY);

reg rst_n;
reg [9:0] por;

// Baud Generator
reg baud_gen_en;
wire baud_tick;

baud_generator baud_gen(.clk(CLOCK_50), .baud_gen_en(baud_gen_en), .rst_n(rst_n), .baud_tick(baud_tick));

// TX
reg [7:0] tx_data;
reg tx_start;
wire tx_busy;
wire tx_wire;

uart_tx tx(.clk(CLOCK_50), .baud_tick(baud_tick), .tx_wire(tx_wire), .rst_n(rst_n), .tx_data(tx_data), .tx_busy(tx_busy), .tx_start(tx_start));

// Reset Control
always @(posedge CLOCK_50 or negedge KEY[0])
begin
  if(~KEY[0])
  begin
    rst_n <= 1;
    baud_gen_enable <= 0;
  end
  else if(por)
    por <= por - 1;
  else
  begin
    baud_gen_enable <= 1;
    rst_n <= 0;
  end
end

initial
begin
  rst_n <= 1;
  enable <= 0;
  tx_start <= 0;
  por <= 10'b1111111111;
  recv_data <= 8'b01010101;

  recv_state <= RX_WRITE;
end

assign rx_wire <= GPIO[0];
assign GPIO[1] <= tx_wire;

endmodule
