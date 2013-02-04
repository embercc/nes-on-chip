module cpu_6502(
    input               i_CLK       ,   //1.79MHz
    input               i_PAUSE     ,   //cpu will pause and release the databus for DMA time. need more thinking. do nothing about it right now.
                                
    output  reg [15:0]  o_ADDR      ,
    input       [7:0]   i_DATA      ,
    output      [7:0]   o_DATA      ,
    output              o_R_WN      ,
                                 
    input               i_NMI_N     ,
    input               i_IRQ_N     ,
    input               i_RST_N     ,
    
    output      [15:0]  o_PC        ,
    output      [7:0]   o_SP        ,
    output      [7:0]   o_IR        ,
    output      [7:0]   o_P
);

    parameter [15:0] NMI_VECTOR_L = 16'hFFFA;
    parameter [15:0] NMI_VECTOR_H = 16'hFFFB;
    parameter [15:0] RST_VECTOR_L = 16'hFFFC;
    parameter [15:0] RST_VECTOR_H = 16'hFFFD;
    parameter [15:0] IRQ_VECTOR_L = 16'hFFFE;
    parameter [15:0] IRQ_VECTOR_H = 16'hFFFF;

    reg [7:0]   r_A;
    reg [7:0]   r_X;
    reg [7:0]   r_Y;
    reg         r_N;
    reg         r_V;
    wire        c_B;
    reg         r_D;
    reg         r_I;
    reg         r_Z;
    reg         r_C;

    reg [15:0]  r_PC;
    reg [7:0]   r_SP;
    
    reg [15:0]  r_ADDR;
    reg [7:0]   r_TMP;
    reg [7:0]   r_IR;
    reg [10:0]  r_UPTR;

//INT signals
    wire        c_nmi_neg;
    reg         r_nmi_last;
    reg         r_nmi_req;
    reg         r_nmi_overlap;
    reg         r_is_brk;
    wire        c_irq_req;
    wire [15:0] c_int_vector_l;
    wire [15:0] c_int_vector_h;

    wire[7:0]   c_P;
    
    wire[3:0]   c_func_addr;
    wire[4:0]   c_func_raddr;
    wire[5:0]   c_func_pc;
    wire[1:0]   c_func_sp;
    wire[3:0]   c_func_alu;
    wire[3:0]   c_func_alu_l;
    wire[1:0]   c_func_alu_r;
    wire[2:0]   c_func_alu_q;
    wire[6:0]   c_func_p_mask;  //N V B D I Z C
    wire[3:0]   c_func_p_src;   //N V Z C
    wire[6:0]   c_func_p_set;   //N V B D I Z C
    wire[10:0]  c_func_nextuop;
    wire        c_func_tmp_w;
    
    wire[7:0]   c_radder;
    wire[15:0]  c_data_sign_ext;
    wire[7:0]   c_alu_left;
    wire[7:0]   c_alu_right;
    wire[7:0]   c_alu_q;
    wire        c_alu_c;
    wire        c_alu_z;
    wire        c_alu_v;
    wire        c_alu_n;
    wire[10:0]  c_decoded_entry;
    reg [10:0]  c_nextuop;
    
    
/*------------------------------------------
    circuit begin
--------------------------------------------*/


/*
    NMI negedge detection
*/
    always @ (posedge i_CLK or negedge i_RST_N) begin
        if(~i_RST_N) begin
            r_nmi_last <= 1'b1;
        end
        else begin
            r_nmi_last <= i_NMI_N;
        end
    end
    
    assign c_nmi_neg = r_nmi_last & ~i_NMI_N;
/*
    NMI overlap detection
*/
    always @ (posedge i_CLK or negedge i_RST_N) begin
        if(~i_RST_N) begin
            r_nmi_overlap <= 1'b0;
        end
        else if (~i_PAUSE) begin
            if(c_nmi_neg && ((r_UPTR==11'h3ff && c_nextuop==11'h000)|| r_UPTR==11'h000 || r_UPTR==11'h100 || r_UPTR==11'h200 || r_UPTR==11'h300 || r_UPTR==11'h5ff || r_UPTR==11'h6ff)) begin  //overlapped
                r_nmi_overlap <= 1'b1;
            end
            else if (r_UPTR==11'h5ff && r_nmi_req==1'b1) begin  //no overlap. use overlap for "this interrupt sequence is served for NMI"
                r_nmi_overlap <= 1'b1;
            end
            else if (r_UPTR==11'h500) begin
                r_nmi_overlap <= 1'b0;
            end
        end
    end
    
/*
    NMI req generate
*/
    always @ (posedge i_CLK or negedge i_RST_N) begin
        if(~i_RST_N) begin
            r_nmi_req <= 1'b0;
        end
        else if (~i_PAUSE) begin
            if(c_nmi_neg) begin
                r_nmi_req <= 1'b1;
            end
            else if(r_UPTR==11'h500 && r_nmi_overlap) begin
                r_nmi_req <= 1'b0;
            end
        end
    end
    
    assign c_irq_req = i_IRQ_N & ~r_I;
    
/*
    BRK detection
*/
    always @ (posedge i_CLK or negedge i_RST_N) begin
        if(~i_RST_N) begin
            r_is_brk <= 1'b0;
        end
        else if (~i_PAUSE) begin
            if(r_UPTR==11'h000) begin
                r_is_brk <= 1'b1;
            end
            else if(r_UPTR==11'h500) begin
                r_is_brk <= 1'b0;
            end
        end
    end



/*
    A
*/
    always @ (posedge i_CLK or negedge i_RST_N) begin
        if(~i_RST_N) begin
            r_A <= 8'h0;
        end
        else if (~i_PAUSE) begin
            if(c_func_alu_q==3'h2) begin
                r_A <= c_alu_q;
            end
        end
    end

/*
    X
*/
    always @ (posedge i_CLK or negedge i_RST_N) begin
        if(~i_RST_N) begin
            r_X <= 8'h0;
        end
        else if (~i_PAUSE) begin
            if(c_func_alu_q==3'h3) begin
                r_X <= c_alu_q;
            end
        end
    end

/*
    Y
*/
    always @ (posedge i_CLK or negedge i_RST_N) begin
        if(~i_RST_N) begin
            r_Y <= 8'h0;
        end
        else if (~i_PAUSE) begin
            if(c_func_alu_q==3'h4) begin
                r_Y <= c_alu_q;
            end
        end
    end

/*
    P
*/
    always @ (posedge i_CLK or negedge i_RST_N) begin
        if(~i_RST_N) begin
            r_N <= 1'b0;
            r_V <= 1'b0;
            //r_B <= 1'b0;
            r_D <= 1'b0;
            r_I <= 1'b1;
            r_Z <= 1'b0;
            r_C <= 1'b0;
        end
        else if (~i_PAUSE) begin
            if (c_func_alu_q==3'h5) begin
                r_N <= c_alu_q[7];
            end
            else if(c_func_p_mask[6]) begin
                if(c_func_p_src[3]) begin
                    r_N <= c_func_p_set[6];
                end
                else begin
                    r_N <= c_alu_n;
                end
            end
            
            if (c_func_alu_q==3'h5) begin
                r_V <= c_alu_q[6];
            end
            else if(c_func_p_mask[5]) begin
                if(c_func_p_src[2]) begin
                    r_V <= c_func_p_set[5];
                end
                else begin
                    r_V <= c_alu_v;
                end
            end
            
            //if (c_func_alu_q==3'h5) begin
            //    r_B <= c_alu_q[4];
            //end
            //else if(c_func_p_mask[4]) begin
            //    r_B <= c_func_p_set[4];
            //end
            
            
            if (c_func_alu_q==3'h5) begin
                r_D <= c_alu_q[3];
            end
            else if(c_func_p_mask[3]) begin
                r_D <= c_func_p_set[3];
            end
            
            if (c_func_alu_q==3'h5) begin
                r_I <= c_alu_q[2];
            end
            else if(c_func_p_mask[2]) begin
                r_I <= c_func_p_set[2];
            end
            
            if (c_func_alu_q==3'h5) begin
                r_Z <= c_alu_q[1];
            end
            else if(c_func_p_mask[1]) begin
                if(c_func_p_src[1]) begin
                    r_Z <= c_func_p_set[1];
                end
                else begin
                    r_Z <= c_alu_z;
                end
            end
            
            if (c_func_alu_q==3'h5) begin
                r_C <= c_alu_q[0];
            end
            else if(c_func_p_mask[0]) begin
                if(c_func_p_src[0]) begin
                    r_C <= c_func_p_set[0];
                end
                else begin
                    r_C <= c_alu_c;
                end
            end
        end
    end
    
    //assign c_B = c_func_p_mask[4] & c_func_p_set[4];
    assign c_B = r_is_brk | (r_UPTR==11'h008); //BRK or PHP
    assign c_P = {r_N, r_V, 1'b1, c_B, r_D, r_I, r_Z, r_C};
    
/*
    r_PC
    PC is not effected by RST_N, when RST_N occurs, the 
    processer will start the RESET interrupt sequence.
*/
    always @ ( posedge i_CLK ) begin
        if (~i_PAUSE) begin
            if(c_func_pc[5:3]==3'b111) begin   //for branch
                if (
                       (c_func_pc[2:0]==3'b000 && ~r_C)    //BCC
                     ||(c_func_pc[2:0]==3'b001 &&  r_C)    //BCS
                     ||(c_func_pc[2:0]==3'b010 &&  r_Z)    //BEQ
                     ||(c_func_pc[2:0]==3'b011 && ~r_Z)    //BNE
                     ||(c_func_pc[2:0]==3'b100 &&  r_N)    //BMI
                     ||(c_func_pc[2:0]==3'b101 && ~r_N)    //BPL
                     ||(c_func_pc[2:0]==3'b110 && ~r_V)    //BVC
                     ||(c_func_pc[2:0]==3'b111 &&  r_V)    //BVS
                ) begin
                    r_PC <= r_PC + c_data_sign_ext;
                end
                else begin
                    r_PC <= r_PC;
                end
            end
            else if(c_func_pc[5:3]==3'b000) begin
                r_PC <= r_PC;
            end
            else if(c_func_pc[5:3]==3'b001) begin
                r_PC <= r_PC + 16'h0001;
            end
            else if(c_func_pc[5:3]==3'b010) begin
                r_PC <= {r_PC[15:8], i_DATA};
            end
            else if(c_func_pc[5:3]==3'b011) begin
                r_PC <= {i_DATA, r_PC[7:0]};
            end
            else if(c_func_pc[5:3]==3'b100) begin
                r_PC <= {r_PC[15:8], r_TMP};
            end
            else if(c_func_pc[5:3]==3'b101) begin
                r_PC <= {i_DATA, r_TMP};
            end
            else begin
                r_PC <= r_PC;
            end
        end
    end
    assign c_data_sign_ext = {{9{r_TMP[7]}}, r_TMP[6:0]};
    
    
/*
    r_SP
*/
    always @(posedge i_CLK or negedge i_RST_N) begin
        if(~i_RST_N) begin
            r_SP <= 8'hfd;
        end
        else if (~i_PAUSE) begin
            if     (c_func_sp==2'b00) begin
                r_SP <= r_SP;
            end
            else if(c_func_sp==2'b01) begin
                r_SP <= r_SP + 8'h1;
            end
            else if(c_func_sp==2'b10) begin
                r_SP <= r_SP - 8'h1;
            end
            else begin
                r_SP <= c_alu_q;
            end
        end
    end
    
/*
    r_ADDR
*/
    assign c_radder =   (c_func_raddr[1:0]==2'b00) ? 8'h00 :
                        (c_func_raddr[1:0]==2'b01) ? 8'h01 :
                        (c_func_raddr[1:0]==2'b10) ? r_X   :
                        r_Y;
    always @ ( posedge i_CLK or negedge i_RST_N) begin
        if(~i_RST_N) begin
            r_ADDR <= 1'b0;
        end
        else if (~i_PAUSE) begin
            if(c_func_raddr[3:2]==2'b00) begin
                r_ADDR <= {8'h0, i_DATA + c_radder};
            end
            else if (c_func_raddr[3:2]==2'b01) begin
                r_ADDR <= {i_DATA, r_ADDR[7:0]} + c_radder;
            end
            else if (c_func_raddr[3:2]==2'b10) begin
                r_ADDR <= {r_ADDR[15:8], r_ADDR[7:0] + c_radder};
            end
            else begin
                r_ADDR <= {i_DATA, r_TMP} + c_radder;
            end
        end
    end

/*
    r_TMP
*/
    always @ ( posedge i_CLK or negedge i_RST_N) begin
        if(~i_RST_N) begin
            r_TMP <= 8'h0;
        end
        else if (~i_PAUSE) begin
            if(c_func_tmp_w) begin
                r_TMP <= i_DATA;
            end
        end
    end

/*
    r_IR
*/
    always @ (posedge i_CLK or negedge i_RST_N) begin
        if(~i_RST_N) begin
            r_IR <= 8'hff;
        end
        else if (~i_PAUSE) begin
            if(r_UPTR == 11'h3ff) begin
                r_IR <= i_DATA;
            end
        end
    end

/*
    r_UPTR with INT support
*/
    //assign c_nextuop = c_func_nextuop == 11'h7ff ? c_decoded_entry : c_func_nextuop;
    always @ ( * ) begin
        if(c_func_nextuop==11'h7ff)
            c_nextuop = c_decoded_entry;
        else if (c_func_nextuop==11'h3ff) begin
            if(c_nmi_neg | (r_nmi_req & ~r_nmi_overlap))
                c_nextuop = 11'h5ff;
            else if(c_irq_req)
                c_nextuop = 11'h5ff;
            else
                c_nextuop = c_func_nextuop;
        end
        else begin
            c_nextuop = c_func_nextuop;
        end
    end
    always @ (posedge i_CLK or negedge i_RST_N) begin
        if(~i_RST_N) begin
            r_UPTR <= 11'h1FF;
        end
        else if (~i_PAUSE) begin
            r_UPTR <= c_nextuop;
        end
    end


/*
    o_ADDR with INT support
*/
    assign c_int_vector_l = (r_nmi_overlap & r_nmi_req) ? NMI_VECTOR_L : IRQ_VECTOR_L;
    assign c_int_vector_h = (r_nmi_overlap & r_nmi_req) ? NMI_VECTOR_H : IRQ_VECTOR_H;
    always @ ( * ) begin
        case(c_func_addr)
            4'b0000:    o_ADDR = r_PC;
            4'b0001:    o_ADDR = {8'h01, r_SP};
            4'b0010:    o_ADDR = r_ADDR;
            4'b0011:    o_ADDR = 16'h0;
            //4'b1010:    o_ADDR = NMI_VECTOR_L;
            //4'b1011:    o_ADDR = NMI_VECTOR_H;
            4'b1100:    o_ADDR = RST_VECTOR_L;
            4'b1101:    o_ADDR = RST_VECTOR_H;
            4'b1110:    o_ADDR = c_int_vector_l;
            4'b1111:    o_ADDR = c_int_vector_h;
            default:    o_ADDR = 16'h0;
        endcase
    end

/*
    o_DATA and o_R_WN
*/
    assign o_DATA = (c_func_alu_q==3'h1) ? c_alu_q : 8'h0;
    assign o_R_WN = i_PAUSE | ((c_func_alu_q==3'h1) ? 1'b0 : 1'b1);
    
/*
    alu inputs
*/
    assign c_alu_left = (c_func_alu_l == 4'h1) ? i_DATA         :
                        (c_func_alu_l == 4'h2) ? r_A            :
                        (c_func_alu_l == 4'h3) ? r_X            :
                        (c_func_alu_l == 4'h4) ? r_Y            :
                        (c_func_alu_l == 4'h5) ? r_SP           :
                        (c_func_alu_l == 4'h6) ? r_PC[7:0]      :
                        (c_func_alu_l == 4'h7) ? r_PC[15:8]     :
                        (c_func_alu_l == 4'h8) ? c_P            :
                        (c_func_alu_l == 4'h9) ? r_TMP          :
                        8'h0 ;
                        
    assign  c_alu_right =   (c_func_alu_r==2'b01) ? r_A:
                            (c_func_alu_r==2'b10) ? r_X:
                            (c_func_alu_r==2'b11) ? r_Y:
                            i_DATA;
            
/*
debug outputs
*/
    assign o_PC = r_PC;
    assign o_SP = r_SP;
    assign o_IR = r_IR;
    assign o_P  = c_P;

    cpu_6502_alu alu(
        .i_func   (c_func_alu),
        .i_left   (c_alu_left),
        .i_right  (c_alu_right),
        .i_c      (r_C),
        .o_q      (c_alu_q),
        .o_c      (c_alu_c),
        .o_z      (c_alu_z),
        .o_v      (c_alu_v),
        .o_n      (c_alu_n)
    );
    
    cpu_6502_uop_entry uop_entry(
        .i_opcode       (i_DATA         ),
        .o_uop_entry    (c_decoded_entry)         
    );
    
    cpu_6502_uop_table uop_table(
        .i_uop_index     (r_UPTR),     
        .o_func_nextuop  (c_func_nextuop),     
        .o_func_alu      (c_func_alu),     
        .o_func_alu_l    (c_func_alu_l),     
        .o_func_alu_r    (c_func_alu_r),     
        .o_func_alu_q    (c_func_alu_q),     
        .o_func_p_mask   (c_func_p_mask),     
        .o_func_p_src    (c_func_p_src),     
        .o_func_p_set    (c_func_p_set),     
        .o_func_tmp_w    (c_func_tmp_w),     
        .o_func_addr     (c_func_addr),     
        .o_func_raddr    (c_func_raddr),     
        .o_func_pc       (c_func_pc),     
        .o_func_sp       (c_func_sp) 
    );
endmodule
                             