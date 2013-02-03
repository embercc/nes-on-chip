`timescale 10ns/1ns

module breath_led(
    input       i_clk,
    input       i_rstn,
    output  reg o_led
);
    reg [7:0]  r_cnt;
    reg [20:0]  r_duty;
    reg         r_sig;
    
    always @(posedge i_clk or negedge i_rstn) begin
        if(~i_rstn) begin
            r_duty <= 21'h0;
            r_sig <= 1'b0;
        end
        else begin
            r_duty <= r_duty + (r_sig ? 21'h1 : {21{1'b1}});
            
            if(r_duty=={{20{1'b1}}, 1'b0}) begin
                r_sig <= 1'b0;
            end
            else if (r_duty==21'h1) begin
                r_sig <= 1'b1;
            end
        end
    end
    
    
    always @(posedge i_clk or negedge i_rstn) begin
        if(~i_rstn) begin
            r_cnt <= 8'h0;
        end
        else begin
            r_cnt <= r_cnt + 8'h1;
        end
    end
    
    always @(posedge i_clk or negedge i_rstn) begin
        if(~i_rstn) begin
            o_led <= 1'b0;
        end
        else begin
            o_led <= r_cnt < r_duty[20:13] ? 1'b0 : 1'b1;
        end
    end
endmodule
