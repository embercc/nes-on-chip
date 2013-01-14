module ps2_scanner(
    input           i_clk           ,
    input           i_rstn          ,
    input           i_ps2_clk       ,
    input           i_ps2_data      ,
    output          o_ps2_txclk     ,
    output          o_ps2_txclk_e   ,
    output          o_ps2_txdata    ,
    output          o_ps2_txdata_e  ,
    output  [9:0]   o_jp_vector     ,
    output          o_initdone      
);





reg r_up;
reg r_down;
reg r_left;
reg r_right;
reg r_select;
reg r_start;
reg r_b;
reg r_a;
reg r_tb;
reg r_ta;
reg r_release;

wire        c_scan_ok;
wire[7:0]   c_scancode;
wire        c_ready;

reg r_done;
reg         [4:0]   r_ism;
reg         [4:0]   c_next_ism;
parameter   [4:0]   ISM_WAIT_AA     =5'h00;
parameter   [4:0]   ISM_WAIT_RDY1   =5'h01;
parameter   [4:0]   ISM_SEND_ED     =5'h02;
parameter   [4:0]   ISM_WAIT_RDY2   =5'h03;
parameter   [4:0]   ISM_WAIT_EDFA   =5'h04;
parameter   [4:0]   ISM_WAIT_RDY3   =5'h05;
parameter   [4:0]   ISM_SEND_00     =5'h06;
parameter   [4:0]   ISM_WAIT_RDY4   =5'h07;
parameter   [4:0]   ISM_WAIT_00FA   =5'h08;
parameter   [4:0]   ISM_WAIT_RDY5   =5'h09;
parameter   [4:0]   ISM_DONE        =5'h0A;

parameter   [4:0]   ISM_WAIT_AA0    =5'h10;
parameter   [4:0]   ISM_WAIT_RDY0   =5'h11;
parameter   [4:0]   ISM_SEND_FF     =5'h12;
parameter   [4:0]   ISM_WAIT_RDY6   =5'h13;
parameter   [4:0]   ISM_WAIT_FFFA   =5'h14;
parameter   [4:0]   ISM_WAIT_RDY7   =5'h15;


wire        c_cmd_val   ;
wire[7:0]   c_cmd       ;

//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

/*
keyboard initialize
*/
always @ ( * ) begin
    case (r_ism)
        ISM_WAIT_AA0:
            if(c_scan_ok && c_scancode==8'hAA)
                c_next_ism = ISM_WAIT_RDY0;
            else
                c_next_ism = ISM_WAIT_AA0;

        ISM_WAIT_RDY0:
            if(c_ready)
                c_next_ism = ISM_SEND_FF;
            else
                c_next_ism = ISM_WAIT_RDY0;
        
        ISM_SEND_FF:
            c_next_ism = ISM_WAIT_RDY6;
            
        ISM_WAIT_RDY6:
            if(c_ready)
                c_next_ism = ISM_WAIT_FFFA;
            else
                c_next_ism = ISM_WAIT_RDY6;
    
        ISM_WAIT_FFFA:
            if(c_scan_ok && c_scancode==8'hFA)
                c_next_ism = ISM_WAIT_RDY7;
            else
                c_next_ism = ISM_WAIT_FFFA;
                
        ISM_WAIT_RDY7:
            if(c_ready)
                c_next_ism = ISM_WAIT_AA;
            else
                c_next_ism = ISM_WAIT_RDY7;
        
        ISM_WAIT_AA : 
            if(c_scan_ok && c_scancode==8'hAA)
                c_next_ism = ISM_WAIT_RDY1;
            else
                c_next_ism = ISM_WAIT_AA;
        ISM_WAIT_RDY1:
            if(c_ready)
                c_next_ism = ISM_SEND_ED;
            else
                c_next_ism = ISM_WAIT_RDY1;
        ISM_SEND_ED:
            c_next_ism = ISM_WAIT_RDY2;
        ISM_WAIT_RDY2:
            if(c_ready)
                c_next_ism = ISM_WAIT_EDFA;
            else
                c_next_ism = ISM_WAIT_RDY2;
        ISM_WAIT_EDFA:
            if(c_scan_ok && c_scancode==8'hFA)
                c_next_ism = ISM_WAIT_RDY3;
            else
                c_next_ism = ISM_WAIT_EDFA;
        ISM_WAIT_RDY3:
            if(c_ready)
                c_next_ism = ISM_SEND_00;
            else
                c_next_ism = ISM_WAIT_RDY3;
        ISM_SEND_00:
            c_next_ism = ISM_WAIT_RDY4;
        ISM_WAIT_RDY4:
            if(c_ready)
                c_next_ism = ISM_WAIT_00FA;
            else
                c_next_ism = ISM_WAIT_RDY4;
        ISM_WAIT_00FA:
            if(c_scan_ok && c_scancode==8'hFA)
                c_next_ism = ISM_WAIT_RDY5;
            else
                c_next_ism = ISM_WAIT_00FA;
        ISM_WAIT_RDY5:
            if(c_ready)
                c_next_ism = ISM_DONE;
            else
                c_next_ism = ISM_WAIT_RDY5;
        ISM_DONE:
            if(c_scan_ok && c_scancode==8'hAA)
                c_next_ism = ISM_WAIT_RDY1;
            else
                c_next_ism = ISM_DONE;
        default:
            c_next_ism = ISM_SEND_FF;
    endcase
end

always @ ( posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_ism <= ISM_SEND_FF;
    end
    else begin
        r_ism <= c_next_ism;
    end
end


assign c_cmd_val = r_ism== ISM_SEND_FF || r_ism==ISM_SEND_ED || r_ism==ISM_SEND_00;
assign c_cmd =  (r_ism==ISM_SEND_FF) ? 8'hFF :
                (r_ism==ISM_SEND_ED) ? 8'hED :
                (r_ism==ISM_SEND_00) ? 8'h00 :
                8'hFF;

always @ ( posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_done <= 1'b0;
    end
    else begin
        if(r_ism==ISM_DONE) begin
            r_done <= 1'b1;
        end
    end
end

assign o_initdone = r_done;

/*
Primary
  +--------------------------------------------+
  |      A                                     |
  |      |                            TB    TA |
  |  <--   -->                                 |
  |      |                                     |
  |      v                            B     A  |
  |               SELECT  START                |
  +--------------------------------------------+
Secondary
  +--------------------------------------------+
  |      A                                     |
  |      |                            TB    TA |
  |  <--   -->                                 |
  |      |                                     |
  |      v                            B     A  |
  |                                            |
  +--------------------------------------------+

this module treated the inputs as Primary.
this can be used as secondary joypad by unconnect o_select and o_start.
*/

/*
we dont care about other keys.
used key map:
  +--------------------------------------------+
  |      W                                     |
  |      |                            U     I  |
  | A<--   -->D                                |
  |      |                                     |
  |      v                            J     K  |
  |      S           V        B                |
  +--------------------------------------------+
*/
/*
scan code:
up      W:1D
down    S:1B
left    A:1C
right   D:23
select  V:2A
start   B:32
b       J:3B
a       K:42
tb      U:3C
ta      I:43
    press D: 23
    release D: F0 23
*/
always @( posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_release <= 1'b0;
    end
    else begin
        if(c_scan_ok) begin
            if(c_scancode==8'hF0) begin
                r_release <= 1'b1;
            end
            else begin
                r_release <= 1'b0;
            end
        end

    end
end

always @( posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_up        <= 1'b0;
        r_down      <= 1'b0;
        r_left      <= 1'b0;
        r_right     <= 1'b0;
        r_select    <= 1'b0;
        r_start     <= 1'b0;
        r_b         <= 1'b0;
        r_a         <= 1'b0;
        r_tb        <= 1'b0;
        r_ta        <= 1'b0;
    end
    else begin
        if(c_scan_ok && c_scancode==8'h1D) begin
            if(r_release)   r_up <= 1'b0;
            else            r_up <= 1'b1;
        end

        if(c_scan_ok && c_scancode==8'h1B) begin
            if(r_release)   r_down <= 1'b0;
            else            r_down <= 1'b1;
        end

        if(c_scan_ok && c_scancode==8'h1C) begin
            if(r_release)   r_left <= 1'b0;
            else            r_left <= 1'b1;
        end

        if(c_scan_ok && c_scancode==8'h23) begin
            if(r_release)   r_right <= 1'b0;
            else            r_right <= 1'b1;
        end

        if(c_scan_ok && c_scancode==8'h2A) begin
            if(r_release)   r_select <= 1'b0;
            else            r_select <= 1'b1;
        end

        if(c_scan_ok && c_scancode==8'h32) begin
            if(r_release)   r_start <= 1'b0;
            else            r_start <= 1'b1;
        end

        if(c_scan_ok && c_scancode==8'h3B) begin
            if(r_release)   r_b <= 1'b0;
            else            r_b <= 1'b1;
        end

        if(c_scan_ok && c_scancode==8'h42) begin
            if(r_release)   r_a <= 1'b0;
            else            r_a <= 1'b1;
        end

        if(c_scan_ok && c_scancode==8'h3C) begin
            if(r_release)   r_tb <= 1'b0;
            else            r_tb <= 1'b1;
        end

        if(c_scan_ok && c_scancode==8'h43) begin
            if(r_release)   r_ta <= 1'b0;
            else            r_ta <= 1'b1;
        end
    end
end

/*
output
*/
assign o_jp_vector = {  r_up        , 
                        r_down      ,
                        r_left      ,
                        r_right     ,
                        r_b         ,
                        r_a         ,
                        r_tb        ,
                        r_ta        ,
                        r_select    ,
                        r_start     };




ps2_tranceiver(
    .i_clk           (i_clk),//input           
    .i_rstn          (i_rstn),//input           
    .i_ps2_clk       (i_ps2_clk),//input           
    .i_ps2_data      (i_ps2_data),//input           
    .o_ps2_txclk     (o_ps2_txclk),//output          
    .o_ps2_txclk_e   (o_ps2_txclk_e),//output          
    .o_ps2_txdata    (o_ps2_txdata),//output          
    .o_ps2_txdata_e  (o_ps2_txdata_e),//output          
    .i_cmd_val       (c_cmd_val),//input           
    .i_cmd           (c_cmd),//input   [7:0]   
    .o_scan_val      (c_scan_ok),//output          
    .o_scancode      (c_scancode),//output  [7:0]   
    .o_ready         (c_ready) //output          
);

endmodule
