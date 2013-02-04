module joypad_ctrl(
    input           i_clk           ,
    input           i_rstn          ,
    input [9:0]     i_jpd_1p        ,
    input [9:0]     i_jpd_2p        ,
    
    //slave port
    input   [15:0]  i_bus_addr      ,
    input           i_bus_wn        ,
    input   [7:0]   i_bus_wdata     ,
    output  [7:0]   o_jpd_rdata     
);


/*
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
*/

wire c_1p_up       ;
wire c_1p_down     ;
wire c_1p_left     ;
wire c_1p_right    ;
wire c_1p_b        ;
wire c_1p_a        ;
wire c_1p_tb       ;
wire c_1p_ta       ;
wire c_1p_select   ;
wire c_1p_start    ;


wire c_2p_up       ;
wire c_2p_down     ;
wire c_2p_left     ;
wire c_2p_right    ;
wire c_2p_b        ;
wire c_2p_a        ;
wire c_2p_tb        ;
wire c_2p_ta        ;
wire c_2p_select   ;
wire c_2p_start    ;

wire c_1p_rb       ;
wire c_1p_ra       ;
wire c_2p_rb       ;
wire c_2p_ra       ;

reg [15:0] r_turbo      ;
reg [7:0]  r_1p_keys    ;
reg [7:0]  r_2p_keys    ;
reg        r_keys_val   ;

always @ (posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
    end
    else begin
    end
end


assign c_1p_up      = i_jpd_1p[9] ;
assign c_1p_down    = i_jpd_1p[8] ;
assign c_1p_left    = i_jpd_1p[7] ;
assign c_1p_right   = i_jpd_1p[6] ;
assign c_1p_b       = i_jpd_1p[5] ;
assign c_1p_a       = i_jpd_1p[4] ;
assign c_1p_tb      = i_jpd_1p[3] ;
assign c_1p_ta      = i_jpd_1p[2] ;
assign c_1p_select  = i_jpd_1p[1] ;
assign c_1p_start   = i_jpd_1p[0] ;

assign c_2p_up      = i_jpd_2p[9] ;
assign c_2p_down    = i_jpd_2p[8] ;
assign c_2p_left    = i_jpd_2p[7] ;
assign c_2p_right   = i_jpd_2p[6] ;
assign c_2p_b       = i_jpd_2p[5] ;
assign c_2p_a       = i_jpd_2p[4] ;
assign c_2p_tb      = i_jpd_2p[3] ;
assign c_2p_ta      = i_jpd_2p[2] ;
assign c_2p_select  = i_jpd_2p[1] ;
assign c_2p_start   = i_jpd_2p[0] ;

//turbo mode
always @ (posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_turbo <= 16'h0;
    end
    else begin
        r_turbo <= r_turbo + 16'h1;
    end
end

assign c_1p_ra = c_1p_ta ? r_turbo[15] : c_1p_a;
assign c_1p_rb = c_1p_tb ? r_turbo[15] : c_1p_b;
assign c_2p_ra = c_2p_ta ? r_turbo[15] : c_2p_a;
assign c_2p_rb = c_2p_tb ? r_turbo[15] : c_2p_b;

//the output order: A, B, Select, Start, Up, Down, Left, Right

//strobe and shift out
always @ (posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_1p_keys <= 8'h0;
        r_2p_keys <= 8'h0;
        r_keys_val <= 1'b0;
    end
    else begin
        if((i_bus_addr==16'h4016) & ~i_bus_wn) begin
            if(i_bus_wdata[0]) begin
                r_1p_keys <= {c_1p_right, c_1p_left, c_1p_down, c_1p_up, c_1p_start, c_1p_select, c_1p_rb, c_1p_ra};
                r_2p_keys <= {c_2p_right, c_2p_left, c_2p_down, c_2p_up, c_2p_start, c_2p_select, c_2p_rb, c_2p_ra};
                r_keys_val <= 1'b0;
            end
            else begin
                r_keys_val <= 1'b1;
            end
        end
        else if((i_bus_addr==16'h4016) & i_bus_wn & r_keys_val) begin
            r_1p_keys <= {1'b1, r_1p_keys[7:1]};
        end
        else if((i_bus_addr==16'h4017) & i_bus_wn & r_keys_val) begin
            r_2p_keys <= {1'b1, r_2p_keys[7:1]};
        end
    end
end

//output 
assign o_jpd_rdata =    ~i_bus_wn ? 8'h0 :
                        i_bus_addr==16'h4016 ? {7'h0, r_1p_keys[0]} :
                        i_bus_addr==16'h4017 ? {7'h0, r_2p_keys[0]} :
                        8'h0;

endmodule