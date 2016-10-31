module uart_test_tb;

reg clk;
reg [1:0] KEY;
reg [33:0] GPIO;

always
begin
  #5 clk = !clk;
end

endmodule;

