`timescale 1 ps / 1 ps
module uart_fifo_tb;

reg clk;
reg [7:0] data;
reg [7:0] rd;
reg rdreq;
reg wrreq;

wire rdempty;
wire wrfull;
wire [7:0] q;

localparam WRITE_0 = 0;
localparam WRITE_1 = 1;
localparam READ_0 = 2;
localparam READ_1 = 3;

reg [1:0] state;

uart_fifo fifo(
	.data(data),
	.rdclk(clk),
	.rdreq(rdreq),
	.wrclk(clk),
	.wrreq(wrreq),
	.q(q),
	.rdempty(rdempty),
	.wrfull(wrfull));

always @(posedge clk)
begin
  case(state)
    WRITE_0:
    begin
      data <= data + 1;
      wrreq <= 1;
      state <= WRITE_1;
    end
    WRITE_1:
    begin
      wrreq <= 0;
      if(wrfull)
        state <= READ_0;
      else
        state <= WRITE_0;
    end
    READ_0:
    begin
      rdreq <= 1;
      state <= READ_1;
    end
    READ_1:
    begin
      rd <= q;
      rdreq <= 0;
      if(rdempty)
        state <= WRITE_0;
      else
        state <= READ_0;
    end
  endcase
end

always
  #5 clk <= ~clk;

initial
begin
  clk <= 0;
  rdreq <= 0;
  wrreq <= 0;
  data <= 8'b00000000;
  state <= WRITE_0;
end

endmodule
