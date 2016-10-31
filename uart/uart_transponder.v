module uart_transponder(input clk, input rst_n, input baud_tick, input rx_wire);
    
// FIFO
wire [7:0] data_in;
wire data_in_wait;
wire data_in_write;

wire [7:0] data_out;
wire data_out_wait;
wire data_out_read;

wire [31:0] csr_in_readdata;
wire csr_in_read;

wire [31:0] csr_out_readdata;
wire csr_out_read;

uart_sys uart_fifo (
  .clk_clk                   (clk),
  .reset_reset_n             (rst_n),

  .uart_data_in_writedata    (data_in),
  .uart_data_in_write        (data_in_write),
  .uart_data_in_waitrequest  (data_in_wait),
  
  .uart_data_out_readdata    (data_out),
  .uart_data_out_read        (data_out_read),
  .uart_data_out_waitrequest (data_out_wait),
  
  .uart_csr_out_address      (0),
  .uart_csr_out_read         (csr_out_read),
  .uart_csr_out_writedata    (0),
  .uart_csr_out_write        (0),
  .uart_csr_out_readdata     (csr_out_readdata),
  
  .uart_csr_in_address       (0),
  .uart_csr_in_read          (csr_in_read),
  .uart_csr_in_writedata     (0),
  .uart_csr_in_write         (0),
  .uart_csr_in_readdata      (csr_in_readdata)
);

uart_recv recv(.clk(clk), .baud_tick(baud_tick), .rx_wire(rx_wire), .rst_n(rst_n),
    .data_in(data_in), .data_in_wait(data_in_wait), .data_in_write(data_in_write));

endmodule

