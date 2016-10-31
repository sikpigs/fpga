module uart_tx(input clk, input baud_tick, input tx_wire, input rst_n, input [7:0] tx_data, output tx_busy,
    input tx_start);

localparam IDLE  = 2'b00;
localparam START = 2'b01;
localparam STOP  = 2'b10;
localparam BIT   = 2'b11;

reg [1:0] state;
reg [2:0] tick_cntr;
reg [2:0] tx_cntr;
reg tx_bit;
reg [7:0] data;
reg busy;
reg error;

wire write_bit;

always @(posedge baud_tick)
  if(rst_n)
    tick_cntr <= tick_cntr + 1;

always @(posedge clk or negedge rst_n)
begin
  if(~rst_n)
  begin
    state <= IDLE;
    tx_bit <= 1;
    data <= 7'b1;
    tick_cntr <= 3'b0;
    busy <= 0;
    error <= 0;
    tx_cntr <= 3'b0;
  end
  else if(tx_start && ~busy)
  begin
    data[0] <= tx_data[0];
    data[1] <= tx_data[1];
    data[2] <= tx_data[2];
    data[3] <= tx_data[3];
    data[4] <= tx_data[4];
    data[5] <= tx_data[5];
    data[6] <= tx_data[6];
    data[7] <= tx_data[7];
    state <= START;
    tick_cntr <= 3'b0;
    busy <= 1;
  end
end

always @(posedge baud_tick)
begin
  if(write_bit)
    case(state)
      IDLE:
          busy = 0;
      START:
        begin
          tx_bit = 0;
          state = BIT;
        end
      BIT:
        begin
          tx_bit = data[tx_cntr];
          tx_cntr = tx_cntr + 1;
          if(tx_cntr == 3'b000)
            state = STOP;
        end
      STOP:
        begin
          tx_bit = 1;
          state = IDLE;
        end
    endcase
end

assign write_bit = tick_cntr == 3'b000;

assign tx_wire = tx_bit;
assign tx_error = error;
assign tx_busy = busy;

endmodule
