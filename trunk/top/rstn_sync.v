`timescale 1ns/1ps

module rstn_sync(
    input   i_clk     ,
    input   i_rstn    ,
    output  o_srstn
);

reg r_dffr1;
reg r_dffr2;

always @ ( posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_dffr1<= 1'b0;
    end
    else begin
        r_dffr1 <= 1'b1;
    end
end

always @ ( posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_dffr2<= 1'b0;
    end
    else begin
        r_dffr2 <= r_dffr1;
    end
end

assign o_srstn = r_dffr2;

endmodule
