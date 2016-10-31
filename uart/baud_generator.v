`define BITS_TO_FIT(N) (\
     N < (1 << 1) ? 1 : \
    (N < (1 << 2) ? 2 : \
    (N < (1 << 3) ? 3 : \
    (N < (1 << 4) ? 4 : \
    (N < (1 << 5) ? 5 : \
    (N < (1 << 6) ? 6 : \
    (N < (1 << 7) ? 7 : \
    (N < (1 << 8) ? 8 : \
    (N < (1 << 9) ? 9 : \
    (N < (1 << 10) ? 10 : \
    (N < (1 << 11) ? 11 : \
    (N < (1 << 12) ? 12 : \
    (N < (1 << 13) ? 13 : \
    (N < (1 << 14) ? 14 : \
    (N < (1 << 15) ? 15 : \
    (N < (1 << 16) ? 16 : \
    (N < (1 << 17) ? 17 : \
    (N < (1 << 18) ? 18 : \
    (N < (1 << 19) ? 19 : \
    (N < (1 << 20) ? 20 : \
    (N < (1 << 21) ? 21 : \
    (N < (1 << 22) ? 22 : \
    (N < (1 << 23) ? 23 : \
    (N < (1 << 24) ? 24 : \
    (N < (1 << 25) ? 25 : \
    (N < (1 << 26) ? 26 : \
    (N < (1 << 27) ? 27 : \
    (N < (1 << 28) ? 28 : \
    (N < (1 << 29) ? 29 : \
    (N < (1 << 30) ? 30 : \
    (N < (1 << 31) ? 31 : \
     32)))))))))))))))))))))))))))))))

module baud_generator(input clk, input baud_gen_en, input rst_n, output baud_tick);

parameter CLK_RATE = 50_000_000; // 50 MHz
parameter BAUD_RATE = 115_200;

localparam TICK_RATE = BAUD_RATE << 3;
localparam TICK_ACC_BITS = (`BITS_TO_FIT(CLK_RATE));

reg [TICK_ACC_BITS:0] v;

wire [TICK_ACC_BITS:0] inc = v[TICK_ACC_BITS] ? (TICK_RATE) : (TICK_RATE - CLK_RATE);
wire [TICK_ACC_BITS:0] next = v + inc;
wire [TICK_ACC_BITS:0] half = (TICK_RATE - CLK_RATE) >> 1;

always @(posedge clk or negedge baud_gen_en or negedge rst_n)
begin
  if(~rst_n)
    v = 0;
  else if(baud_gen_en)
    v = next;
end

assign baud_tick = (rst_n && baud_gen_en && ~v[TICK_ACC_BITS]);

endmodule
