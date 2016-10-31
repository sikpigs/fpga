module baud_generator_tb;

reg clock;
reg en;
reg rst_n;
wire baud_tick;
reg [31:0] tick_counter;
reg [31:0] clk_counter;

initial
begin
  clock = 0;
  en = 0;
  rst_n = 0;
  clk_counter = 0;
  tick_counter = 0;
  #10 rst_n = 1;
  #15 en = 1;
end

baud_generator baud_gen(.clk(clock), .baud_gen_en(en), .rst_n(rst_n), .baud_tick(baud_tick));

always
begin
  #5 clock = !clock;
  if(clock && rst_n && en)
    clk_counter = clk_counter + 1;
end

always @(posedge baud_tick)
begin
  tick_counter <= tick_counter + 1;
end

initial
begin
  #5000025 en = 0;
  if (clk_counter != 500000)
  begin
    $display("Incorrect number of clock ticks %d", clk_counter);
  end
  if (tick_counter != 4608)
  begin
    $display("Incorrect number of baud ticks %d", tick_counter);
  end

  $stop;
end

endmodule

