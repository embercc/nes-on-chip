`timescale 10ns/1ns

/*
Auther:
    ember_cc
Discribe:   
    6502's uop entry, combination logic. 
    i use the opcode as the location of the first uop, 
    this tricky thing will shorten the decode logic.
*/
/*
Patch Note:
Create.
*/

module cpu_6502_uop_entry(
    input [7:0]      i_opcode      ,
    output [10:0]    o_uop_entry
    
);
    assign o_uop_entry = {3'b0, i_opcode};
endmodule
