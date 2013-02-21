module flash_bhv #(
    parameter PRG_INITVEC = "prg_init.txt"
    //parameter CHR_INITVEC = "chr_init.txt"
)(
    input   [22:0]  i_addr  ,
    output  [7:0]  o_q
);

    reg [7:0] mem_array [0 : {23{1'b1}}];

    assign  o_q = mem_array[i_addr];
    
    initial begin
        $readmemh(PRG_INITVEC, mem_array);
        //$readmemh(CHR_INITVEC, mem_array, 23'h400000, 23'h4fffff);
    end
endmodule
