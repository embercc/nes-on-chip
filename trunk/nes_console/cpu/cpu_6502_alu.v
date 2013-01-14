/*
Auther:
    ember_cc
Discribe:   
    2A03's ALU, combination logic
*/
/*
Patch Note:
Create.
*/
module cpu_6502_alu(
    input   [3:0]       i_func  ,
    input   [7:0]       i_left  ,
    input   [7:0]       i_right ,
    input               i_c     ,
    output  reg [7:0]   o_q     ,
    output  reg         o_c     ,
    output              o_z     ,
    output  reg         o_v     ,
    output              o_n     
);
                   
    parameter   F_AND       = 4'h0;
    parameter   F_EOR       = 4'h1;
    parameter   F_ORA       = 4'h2;
    parameter   F_BIT       = 4'h3;
    parameter   F_ADC       = 4'h4;
    parameter   F_AD1       = 4'h5;
    parameter   F_SBC       = 4'h6;
    parameter   F_SB1       = 4'h7;
    parameter   F_ASL       = 4'h8;
    parameter   F_LSR       = 4'h9;
    parameter   F_ROL       = 4'hA;
    parameter   F_ROR       = 4'hB;
    parameter   F_BYPASS    = 4'hC;
    parameter   F_CMP       = 4'hD;
    parameter   F_Q_F       = 4'hE;
    parameter   F_NOP       = 4'hF;
       
    /*
        output
    */
    /*
    base:       begin
                    o_q = 8'h0;
                    o_c = 1'b0;
                    o_v = 1'b0;
                end
    */
    assign  o_n = o_q[7];
    assign  o_z = (o_q==8'h0);
    
    always @ (*) begin
        case(i_func)
            F_AND       :
                begin
                    o_q = i_left & i_right;
                    o_c = 1'b0;
                    o_v = 1'b0;
                end
            F_EOR       :   
                begin
                    o_q = i_left ^ i_right;
                    o_c = 1'b0;
                    o_v = 1'b0;
                end
            F_ORA       :   
                begin
                    o_q = i_left | i_right;
                    o_c = 1'b0;
                    o_v = 1'b0;
                end
            F_BIT       :   
                begin
                    o_q = i_left & i_right;
                    o_c = 1'b0;
                    o_v = o_q[6];
                end
            F_ADC       :   
                begin
                    {o_c, o_q} = {1'b0, i_left} + {1'b0, i_right} + {8'h0, i_c};
                    o_v = (~(i_left[7] ^ i_right[7])) & (i_left[7] ^ o_q[7]);
                end
            F_AD1       :   
                begin
                    o_q = i_left + 8'h1;
                    o_c = 1'b0;
                    o_v = 1'b0;
                end
            F_SBC       :   
                begin
                    {o_c, o_q} = {1'b0, i_left} - {1'b0, i_right} - {8'h0, ~i_c};
                    o_v = (i_left[7] ^ o_q[7]) & (i_left[7] ^ i_right[7]);
                end
            F_SB1       :   
                begin
                    o_q = i_left - 8'h1;
                    o_c = 1'b0;
                    o_v = 1'b0;
                end
            F_ASL       :   
                begin
                    o_q = {i_left[6:0], 1'b0};
                    o_c = i_left[7];
                    o_v = 1'b0;
                end
            F_LSR       :   
                begin
                    o_q = {1'b0, i_left[7:1]};
                    o_c = i_left[0];
                    o_v = 1'b0;
                end
            F_ROL       :   
                begin
                    o_q = {i_left[6:0], i_c};
                    o_c = i_left[7];
                    o_v = 1'b0;
                end
            F_ROR       :   
                begin
                    o_q = {i_c, i_left[7:1]};
                    o_c = i_left[0];
                    o_v = 1'b0;
                end
            F_BYPASS    :   
                begin
                    o_q = i_left;
                    o_c = 1'b0;
                    o_v = 1'b0;
                end
            F_CMP       :   
                begin
                    {o_c, o_q} = {1'b0, i_left} - {1'b0, i_right};
                    o_v = 1'b0;
                end
            F_Q_F       :   
                begin
                    o_q = 8'hFF;
                    o_c = 1'b0;
                    o_v = 1'b0;
                end
            F_NOP       :
                begin
                    o_q = 8'h0;
                    o_c = 1'b0;
                    o_v = 1'b0;
                end
        endcase
    end
endmodule
