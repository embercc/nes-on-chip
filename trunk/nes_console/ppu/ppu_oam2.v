module ppu_oam2(
    input             i_clk   ,
    input   [2:0]     i_addr  ,
    input   [31:0]    i_data  ,
    input             i_we    ,
    output  [31:0]    o_q
);

reg [31:0] mem_array[0:7];
reg [31:0] r_q;

//write
always @( posedge i_clk ) begin
    if(i_we) begin
        mem_array[i_addr] <= i_data;
    end
end


//read, registered output
always @(posedge i_clk) begin
    r_q <= mem_array[i_addr];
end
assign o_q = r_q;

endmodule
