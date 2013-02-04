module sram_bhv (
    //input                       i_clk   ,
    input   [19 : 0]    i_addr  ,
    input               i_ce_n  ,
    inout   [15 : 0]    io_dq   ,
    input               i_lb_n  ,
    input               i_oe_n  ,
    input               i_ub_n  ,
    input               i_we_n
    
);

    reg [15:0] mem_array [0 : 20'hfffff];

//write port
    always @ (posedge i_we_n) begin
        if(~i_ce_n) begin
            if(~i_lb_n) begin
                mem_array[i_addr][7:0] <= io_dq[7:0];
            end
            
            if(~i_ub_n) begin
                mem_array[i_addr][15:8] <= io_dq[15:8];
            end
        end
    end
    
    assign  io_dq = ~i_oe_n & ~i_ce_n & i_we_n ? mem_array[i_addr] : 16'hz;
    
    integer k;
    initial begin
        for (k=0; k<=20'hfffff; k++) begin
            mem_array[k] = {16{1'b0}};
        end
    end
endmodule
