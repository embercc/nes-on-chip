module ram_bhv #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 16
)(
    input                       i_clk   ,
    input   [ADDR_WIDTH-1 : 0]  i_addr  ,
    input   [DATA_WIDTH-1 : 0]  i_data  ,
    input                       i_w_n   ,
    output  [DATA_WIDTH-1 : 0]  o_q
);

    reg [DATA_WIDTH-1:0] mem_array [0 : {ADDR_WIDTH{1'b1}}];

    always @ (posedge i_clk) begin
        if(~i_w_n) begin
            mem_array[i_addr] <= i_data;
        end
    end
    
    assign  o_q = mem_array[i_addr];
    
    initial begin
        $readmemh("ram_init_vector.txt", mem_array);
    end
endmodule
