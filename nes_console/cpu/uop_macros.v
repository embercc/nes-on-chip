//func_alu
`define A_AND       4'b0000
`define A_EOR       4'b0001
`define A_ORA       4'b0010
`define A_BIT       4'b0011
`define A_ADC       4'b0100
`define A_AD1       4'b0101
`define A_SBC       4'b0110
`define A_SB1       4'b0111
`define A_ASL       4'b1000
`define A_LSR       4'b1001
`define A_ROL       4'b1010
`define A_ROR       4'b1011
`define A_BPS       4'b1100
`define A_CMP       4'b1101
`define A_Q_F       4'b1110
`define A_NOP       4'b1111

//func_alu_l
`define AL_NOP      4'b0000
`define AL_MEM      4'b0001
`define AL_AAA      4'b0010
`define AL_XXX      4'b0011
`define AL_YYY      4'b0100
`define AL_SPP      4'b0101
`define AL_PCL      4'b0110
`define AL_PCH      4'b0111
`define AL_PPP      4'b1000
`define AL_TMP      4'b1001

//func_alu_r
`define AR_NOP      2'b00
`define AR_MEM      2'b00
`define AR_AAA      2'b01
`define AR_XXX      2'b10
`define AR_YYY      2'b11

//func_alu_q.
`define AQ_NOP      3'b000
`define AQ_MEM      3'b001
`define AQ_AAA      3'b010
`define AQ_XXX      3'b011
`define AQ_YYY      3'b100
`define AQ_PPP      3'b101

//func_addr
`define OA_PCCC     4'b0000
`define OA_SPPP     4'b0001
`define OA_RADD     4'b0010
`define OA_0000     4'b0011
`define OA_NPCL     4'b1010
`define OA_NPCH     4'b1011
`define OA_RPCL     4'b1100
`define OA_RPCH     4'b1101
`define OA_IPCL     4'b1110
`define OA_IPCH     4'b1111


//func_raddr[3:2]
`define RA1_NOPNOP  3'b000
`define RA1_H0LM_A  3'b100
`define RA1_HMLR_B  3'b101
`define RA1_HRLR_A  3'b110
`define RA1_HMLT_B  3'b111
//func_raddr[1:0]
`define RA2_0       2'b00
`define RA2_1       2'b01
`define RA2_X       2'b10
`define RA2_Y       2'b11


//func_pc[5:3]
`define PC1_NOP     3'b000
`define PC1_INC     3'b001
`define PC1_PLM     3'b010
`define PC1_PHM     3'b011
`define PC1_PLT     3'b100
`define PC1_PMT     3'b101
`define PC1_BRC     3'b111
//func_pc[2:0]
`define PC2_NOP     3'b000
`define PC2_BCC     3'b000
`define PC2_BCS     3'b001
`define PC2_BEQ     3'b010
`define PC2_BNE     3'b011
`define PC2_BMI     3'b100
`define PC2_BPL     3'b101
`define PC2_BVC     3'b110
`define PC2_BVS     3'b111

//func_sp
`define SP_NOP      2'b00
`define SP_INC      2'b01
`define SP_DEC      2'b10
`define SP_SET      2'b11
