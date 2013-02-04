module hex2sig(
    input       [3:0] i_hex,
    output reg  [6:0] o_sig
);
    /*
       ---0----    
       |	  |    
       5	  1    
       |	  |    
       ---6----    
       |	  |    
       4	  2    
       |	  |    
       ---3----    
      
    */
    always @ ( * ) begin
        case (i_hex)
            4'h0    :   o_sig = 7'b1000000 ;
            4'h1    :   o_sig = 7'b1111001 ;
            4'h2    :   o_sig = 7'b0100100 ;
            4'h3    :   o_sig = 7'b0110000 ;
            4'h4    :   o_sig = 7'b0011001 ;
            4'h5    :   o_sig = 7'b0010010 ;
            4'h6    :   o_sig = 7'b0000010 ;
            4'h7    :   o_sig = 7'b1111000 ;
            4'h8    :   o_sig = 7'b0000000 ;
            4'h9    :   o_sig = 7'b0011000 ;
            4'hA    :   o_sig = 7'b0001000 ;
            4'hB    :   o_sig = 7'b0000011 ;
            4'hC    :   o_sig = 7'b1000110 ;
            4'hD    :   o_sig = 7'b0100001 ;
            4'hE    :   o_sig = 7'b0000110 ;
            4'hF    :   o_sig = 7'b0001110 ;
        endcase                    
    end
endmodule

module hex2sig_rotate(
    input       [3:0] i_hex,
    output  reg [6:0] o_sig
);
    /*
       ---3----    
       |	  |    
       2	  4    
       |	  |    
       ---6----    
       |	  |    
       1	  5    
       |	  |    
       ---0----    
      
    */
    always @ ( * ) begin
        case (i_hex)             //6543210
            4'h0    :   o_sig = 7'b1000000  ;
            4'h1    :   o_sig = 7'b1001111  ;
            4'h2    :   o_sig = 7'b0100100  ;
            4'h3    :   o_sig = 7'b0000110  ;
            4'h4    :   o_sig = 7'b0001011  ;
            4'h5    :   o_sig = 7'b0010010  ;
            4'h6    :   o_sig = 7'b0010000  ;
            4'h7    :   o_sig = 7'b1000111  ;
            4'h8    :   o_sig = 7'b0000000  ;
            4'h9    :   o_sig = 7'b0000010  ;
            4'hA    :   o_sig = 7'b0000001  ;
            4'hB    :   o_sig = 7'b0011000  ;
            4'hC    :   o_sig = 7'b1110000  ;
            4'hD    :   o_sig = 7'b0001100  ;
            4'hE    :   o_sig = 7'b0110000  ;
            4'hF    :   o_sig = 7'b0110001  ;
        endcase
    end

endmodule


