`timescale 10ns/1ns

/*
Auther:
    ember_cc
Discribe:   
    6502's uop table, combination logic.
*/
/*
Patch Note:
Create.
--argue:    it will be a very large array
            if the fpga logic not enough, it must be put in blockrams.
*/

`include "uop_macros.v"

module cpu_6502_uop_table(
    input   [10:0]  i_uop_index     ,
    output  [10:0]  o_func_nextuop  ,
    output  [3:0]   o_func_alu      ,
    output  [3:0]   o_func_alu_l    ,
    output  [1:0]   o_func_alu_r    ,
    output  [2:0]   o_func_alu_q    ,
    output  [6:0]   o_func_p_mask   ,
    output  [3:0]   o_func_p_src    ,
    output  [6:0]   o_func_p_set    ,
    output          o_func_tmp_w    ,
    output  [3:0]   o_func_addr     ,
    output  [4:0]   o_func_raddr    ,
    output  [5:0]   o_func_pc       ,
    output  [1:0]   o_func_sp
);
/*
    the fetch uop is located in 11'h3ff
    the reset process starts at 11'h1ff
    the nextuop 11'b11111111111 indicates that the nextuop is from uop_entry module.
*/
    reg [59:0] uop_vector;
    assign {o_func_nextuop, o_func_alu, o_func_alu_l, o_func_alu_r, o_func_alu_q, o_func_p_mask, o_func_p_src, o_func_p_set, o_func_tmp_w, o_func_addr, o_func_raddr, o_func_pc, o_func_sp} = uop_vector;
    
    
    
    //assign o_func_nextuop   = uop_vector[59:49];
    //assign o_func_alu       = uop_vector[48:45];
    //assign o_func_alu_l     = uop_vector[44:41];
    //assign o_func_alu_r     = uop_vector[40:39];
    //assign o_func_alu_q     = uop_vector[38:36];
    //assign o_func_p_mask    = uop_vector[35:29];
    //assign o_func_p_src     = uop_vector[28:25];
    //assign o_func_p_set     = uop_vector[24:18];
    //assign o_func_tmp_w     = uop_vector[17];
    //assign o_func_addr      = uop_vector[16:13];
    //assign o_func_raddr     = uop_vector[12:8];
    //assign o_func_pc        = uop_vector[7:2];
    //assign o_func_sp        = uop_vector[1:0];
    
    
    
    
    
    
    always @ ( * ) begin
        case (i_uop_index)
            //                               next  alu     l        r        q          p_mask      psrc     p_set       TW  ADDR      rADDR                PC                  SP
            //  xxx:                         xxx   A_???   AL_???   AR_???   AQ_???     bbbbbbb     bbbb     bbbbbbb     b   OA_????   RA1_??????   RA2_?   PC1_???   PC2_???   SP_???
            //                                                                          NVBDIZC     NVZC     NVBDIZC                                                                 
            11'h000:    uop_vector  =   {11'h100, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //BRK2, do nothing but PC++
            11'h100:    uop_vector  =   {11'h200, `A_BPS, `AL_PCH, `AR_NOP, `AQ_MEM, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_SPPP, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_DEC };  //BRK3, PUSH PCH, SP-- , from this , till BRK7, is reused as General Interrupt Sequence.
            11'h200:    uop_vector  =   {11'h300, `A_BPS, `AL_PCL, `AR_NOP, `AQ_MEM, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_SPPP, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_DEC };  //BRK4, PUSH PCL, SP--
            11'h300:    uop_vector  =   {11'h400, `A_BPS, `AL_PPP, `AR_NOP, `AQ_MEM, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_SPPP, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_DEC };  //BRK5, P->MEM, SP--, the B flag is different in BRK and IRQ, the function is provided in cpu_6502.v
            11'h400:    uop_vector  =   {11'h500, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000100, 4'b0000, 7'b0000100, 1'b0, `OA_IPCL, `RA1_NOPNOP, `RA2_0, `PC1_PLM, `PC2_NOP, `SP_NOP };  //BRK6, load PCL, vector is seleted by the INT owner. setI
            11'h500:    uop_vector  =   {11'h3FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_IPCH, `RA1_NOPNOP, `RA2_0, `PC1_PHM, `PC2_NOP, `SP_NOP };  //BRK7, load PCH, vector is seleted by the INT owner.
            11'h001:    uop_vector  =   {11'h101, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_X, `PC1_INC, `PC2_NOP, `SP_NOP };  //ORA2, (indir,X), ((PC)+X)->rADDR, PC++
            11'h101:    uop_vector  =   {11'h201, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_HRLR_A, `RA2_1, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ORA3, (indir,X), (rADDR)->TMP, rADDR++
            11'h201:    uop_vector  =   {11'h301, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_HMLT_B, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ORA4, (indir,X), ((rADDR),TMP)->rADDR
            11'h301:    uop_vector  =   {11'h3FF, `A_ORA, `AL_AAA, `AR_MEM, `AQ_AAA, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ORA5, (indir,X), calc, done
            11'h002:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h003:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h004:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h005:    uop_vector  =   {11'h105, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //ORA2, zero, PC++
            11'h105:    uop_vector  =   {11'h3ff, `A_ORA, `AL_AAA, `AR_MEM, `AQ_NOP, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ORA3, zero, done
            11'h006:    uop_vector  =   {11'h106, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //ASL2, zero, PC++
            11'h106:    uop_vector  =   {11'h206, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ASL3, zero, MEM->TMP
            11'h206:    uop_vector  =   {11'h3ff, `A_ASL, `AL_TMP, `AR_NOP, `AQ_MEM, 7'b1000011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ASL4, zero, ALU->MEM, done
            11'h007:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h008:    uop_vector  =   {11'h3ff, `A_BPS, `AL_PPP, `AR_NOP, `AQ_MEM, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_SPPP, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_DEC };  //PHP2 impl, P->MEM with B set, SP--, done
            11'h009:    uop_vector  =   {11'h3ff, `A_ORA, `AL_AAA, `AR_MEM, `AQ_AAA, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //ORA, imme, pc++, done
            11'h00A:    uop_vector  =   {11'h3ff, `A_ASL, `AL_AAA, `AR_NOP, `AQ_AAA, 7'b1000011, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ASL, accu, done
            11'h00B:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h00C:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h00D:    uop_vector  =   {11'h10D, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //ORA2, absl, PC->ADDRL, PC++
            11'h10D:    uop_vector  =   {11'h20D, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //ORA3, absl, PC->ADDRH, PC++
            11'h20D:    uop_vector  =   {11'h3FF, `A_ORA, `AL_AAA, `AR_MEM, `AQ_AAA, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ORA4, absl, calc, done     
            11'h00E:    uop_vector  =   {11'h10E, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //ASL2, absl, PC->ADDRL, PC++
            11'h10E:    uop_vector  =   {11'h20E, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //ASL3, absl, PC->ADDRH, PC++
            11'h20E:    uop_vector  =   {11'h30E, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ASL4, absl, MEM->TMP,
            11'h30E:    uop_vector  =   {11'h3FF, `A_ASL, `AL_TMP, `AR_NOP, `AQ_MEM, 7'b1000011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ASL5, absl, calc, done
            11'h00F:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h010:    uop_vector  =   {11'h110, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //BPL2, MEM->TMP, PC++
            11'h110:    uop_vector  =   {11'h3ff, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_BRC, `PC2_BPL, `SP_NOP };  //BPL3, PC+=TMP/0, done
            11'h011:    uop_vector  =   {11'h111, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //ORA2, (indir)Y, (PC)->rADDR, PC++
            11'h111:    uop_vector  =   {11'h211, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_HRLR_A, `RA2_1, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ORA3, (indir)Y, (rADDR)->TMP, rADDR++
            11'h211:    uop_vector  =   {11'h311, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_HMLT_B, `RA2_Y, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ORA4, (indir)Y, ((rADDR),TMP)+Y->rADDR
            11'h311:    uop_vector  =   {11'h3FF, `A_ORA, `AL_AAA, `AR_MEM, `AQ_AAA, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ORA5, (indir)Y, calc, done
            11'h012:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h013:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h014:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h015:    uop_vector  =   {11'h115, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_X, `PC1_INC, `PC2_NOP, `SP_NOP };  //ORA2, zeroX, (PC) + X -> rADDRL, PC++
            11'h115:    uop_vector  =   {11'h3FF, `A_ORA, `AL_AAA, `AR_MEM, `AQ_AAA, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ORA3, zeroX, calc, done
            11'h016:    uop_vector  =   {11'h116, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_X, `PC1_INC, `PC2_NOP, `SP_NOP };  //ASL2, zeroX, (PC) + X -> rADDRL, PC++
            11'h116:    uop_vector  =   {11'h216, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ASL3, zeroX, MEM->TMP
            11'h216:    uop_vector  =   {11'h3FF, `A_ASL, `AL_TMP, `AR_NOP, `AQ_MEM, 7'b1000011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ASL4, zeroX, ALU->MEM, done
            11'h017:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h018:    uop_vector  =   {11'h3ff, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000001, 4'b0001, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //CLC, done
            11'h019:    uop_vector  =   {11'h119, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //ORA2, abslY, (PC)->rADDRL, PC++
            11'h119:    uop_vector  =   {11'h219, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_Y, `PC1_INC, `PC2_NOP, `SP_NOP };  //ORA3, abslY, ((PC), rADDRL)+Y -> rADDR, PC++
            11'h219:    uop_vector  =   {11'h3FF, `A_ORA, `AL_AAA, `AR_MEM, `AQ_AAA, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ORA4, abslY, calc, done
            11'h01A:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h01B:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h01C:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h01D:    uop_vector  =   {11'h11D, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //ORA2, abslX, (PC)->rADDRL, PC++
            11'h11D:    uop_vector  =   {11'h21D, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_X, `PC1_INC, `PC2_NOP, `SP_NOP };  //ORA3, abslX, ((PC), rADDRL)+X -> rADDR, PC++
            11'h21D:    uop_vector  =   {11'h3FF, `A_ORA, `AL_AAA, `AR_MEM, `AQ_AAA, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ORA4, abslX, calc, done
            11'h01E:    uop_vector  =   {11'h11E, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //ASL2, abslX, (PC)->rADDRL, PC++
            11'h11E:    uop_vector  =   {11'h21E, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_X, `PC1_INC, `PC2_NOP, `SP_NOP };  //ASL3, abslX, ((PC), rADDRL)+X -> rADDR, PC++
            11'h21E:    uop_vector  =   {11'h31E, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ASL3, abslX, MEM->TMP
            11'h31E:    uop_vector  =   {11'h3FF, `A_ASL, `AL_TMP, `AR_NOP, `AQ_MEM, 7'b1000011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ASL4, abslX, ALU->MEM, done
            11'h01F:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h020:    uop_vector  =   {11'h120, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //JSR2, MEM->TMP, PC++
            11'h120:    uop_vector  =   {11'h220, `A_BPS, `AL_PCH, `AR_NOP, `AQ_MEM, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_SPPP, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_DEC };  //JSR3, PUSH PCH, SP--
            11'h220:    uop_vector  =   {11'h320, `A_BPS, `AL_PCL, `AR_NOP, `AQ_MEM, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_SPPP, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_DEC };  //JSR4, PUSH PCL, SP--
            11'h320:    uop_vector  =   {11'h3ff, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_PMT, `PC2_NOP, `SP_NOP };  //JSR5, (MEM, TMP) -> PC, done
            11'h021:    uop_vector  =   {11'h121, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_X, `PC1_INC, `PC2_NOP, `SP_NOP };  //AND2, (indir,X), ((PC)+X)->rADDR, PC++
            11'h121:    uop_vector  =   {11'h221, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_HRLR_A, `RA2_1, `PC1_NOP, `PC2_NOP, `SP_NOP };  //AND3, (indir,X), (rADDR)->TMP, rADDR++
            11'h221:    uop_vector  =   {11'h321, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_HMLT_B, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //AND4, (indir,X), ((rADDR),TMP)->rADDR
            11'h321:    uop_vector  =   {11'h3FF, `A_AND, `AL_AAA, `AR_MEM, `AQ_AAA, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //AND5, (indir,X), calc, done
            11'h022:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h023:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h024:    uop_vector  =   {11'h124, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //BIT2, zero, PC++
            11'h124:    uop_vector  =   {11'h3ff, `A_BIT, `AL_AAA, `AR_MEM, `AQ_NOP, 7'b1100010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //BIT3, zero, done
            11'h025:    uop_vector  =   {11'h125, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //AND2, zero, PC++
            11'h125:    uop_vector  =   {11'h3ff, `A_AND, `AL_AAA, `AR_MEM, `AQ_NOP, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //AND3, zero, done
            11'h026:    uop_vector  =   {11'h126, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //ROL2, zero, PC++
            11'h126:    uop_vector  =   {11'h226, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ROL3, zero, MEM->TMP
            11'h226:    uop_vector  =   {11'h3ff, `A_ROL, `AL_TMP, `AR_NOP, `AQ_MEM, 7'b1000011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ROL4, zero, ALU->MEM, done
            11'h027:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h028:    uop_vector  =   {11'h128, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_INC };  //PLA2, SP++
            11'h128:    uop_vector  =   {11'h3ff, `A_BPS, `AL_MEM, `AR_NOP, `AQ_PPP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_SPPP, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //PLP3, MEM->P, done
            11'h029:    uop_vector  =   {11'h3ff, `A_AND, `AL_AAA, `AR_MEM, `AQ_AAA, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //AND, imme, pc++, done
            11'h02A:    uop_vector  =   {11'h3ff, `A_ROL, `AL_AAA, `AR_NOP, `AQ_AAA, 7'b1000011, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ROL, accu. done
            11'h02B:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h02C:    uop_vector  =   {11'h12C, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //BIT2, absl, PC->ADDRL, PC++ 
            11'h12C:    uop_vector  =   {11'h22C, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //BIT3, absl, PC->ADDRH, PC++     
            11'h22C:    uop_vector  =   {11'h3FF, `A_BIT, `AL_AAA, `AR_MEM, `AQ_NOP, 7'b1100010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //BIT4, absl, calc, done
            11'h02D:    uop_vector  =   {11'h12D, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //AND2, absl, PC->ADDRL, PC++
            11'h12D:    uop_vector  =   {11'h22D, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //AND3, absl, PC->ADDRH, PC++
            11'h22D:    uop_vector  =   {11'h3FF, `A_AND, `AL_AAA, `AR_MEM, `AQ_AAA, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //AND4, absl, calc, done     
            11'h02E:    uop_vector  =   {11'h12E, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //ROL2, absl, PC->ADDRL, PC++
            11'h12E:    uop_vector  =   {11'h22E, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //ROL3, absl, PC->ADDRH, PC++
            11'h22E:    uop_vector  =   {11'h32E, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ROL4, absl, MEM->TMP,
            11'h32E:    uop_vector  =   {11'h3FF, `A_ROL, `AL_TMP, `AR_NOP, `AQ_MEM, 7'b1000011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ROL5, absl, calc, done
            11'h02F:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h030:    uop_vector  =   {11'h130, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //BMI2, MEM->TMP, PC++
            11'h130:    uop_vector  =   {11'h3ff, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_BRC, `PC2_BMI, `SP_NOP };  //BMI3, PC+=TMP/0, done
            11'h031:    uop_vector  =   {11'h131, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //AND2, (indir)Y, (PC)->rADDR, PC++
            11'h131:    uop_vector  =   {11'h231, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_HRLR_A, `RA2_1, `PC1_NOP, `PC2_NOP, `SP_NOP };  //AND3, (indir)Y, (rADDR)->TMP, rADDR++
            11'h231:    uop_vector  =   {11'h331, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_HMLT_B, `RA2_Y, `PC1_NOP, `PC2_NOP, `SP_NOP };  //AND4, (indir)Y, ((rADDR),TMP)+Y->rADDR
            11'h331:    uop_vector  =   {11'h3FF, `A_AND, `AL_AAA, `AR_MEM, `AQ_AAA, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //AND5, (indir)Y, calc, done
            11'h032:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h033:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h034:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h035:    uop_vector  =   {11'h135, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_X, `PC1_INC, `PC2_NOP, `SP_NOP };  //AND2, zeroX, (PC) + X -> rADDRL, PC++
            11'h135:    uop_vector  =   {11'h3FF, `A_AND, `AL_AAA, `AR_MEM, `AQ_AAA, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //AND3, zeroX, calc, done
            11'h036:    uop_vector  =   {11'h136, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_X, `PC1_INC, `PC2_NOP, `SP_NOP };  //ROL2, zeroX, (PC) + X -> rADDRL, PC++
            11'h136:    uop_vector  =   {11'h236, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ROL3, zeroX, MEM->TMP
            11'h236:    uop_vector  =   {11'h3FF, `A_ROL, `AL_TMP, `AR_NOP, `AQ_MEM, 7'b1000011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ROL4, zeroX, ALU->MEM, done
            11'h037:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h038:    uop_vector  =   {11'h3ff, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000001, 4'b0001, 7'b0000001, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //SEC, done
            11'h039:    uop_vector  =   {11'h139, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //AND2, abslY, (PC)->rADDRL, PC++
            11'h139:    uop_vector  =   {11'h239, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_Y, `PC1_INC, `PC2_NOP, `SP_NOP };  //AND3, abslY, ((PC), rADDRL)+Y -> rADDR, PC++
            11'h239:    uop_vector  =   {11'h3FF, `A_AND, `AL_AAA, `AR_MEM, `AQ_AAA, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //AND4, abslY, calc, done
            11'h03A:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h03B:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h03C:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h03D:    uop_vector  =   {11'h13D, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //AND2, abslX, (PC)->rADDRL, PC++
            11'h13D:    uop_vector  =   {11'h23D, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_X, `PC1_INC, `PC2_NOP, `SP_NOP };  //AND3, abslX, ((PC), rADDRL)+X -> rADDR, PC++
            11'h23D:    uop_vector  =   {11'h3FF, `A_AND, `AL_AAA, `AR_MEM, `AQ_AAA, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //AND4, abslX, calc, done
            11'h03E:    uop_vector  =   {11'h13E, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //ROL2, abslX, (PC)->rADDRL, PC++
            11'h13E:    uop_vector  =   {11'h23E, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_X, `PC1_INC, `PC2_NOP, `SP_NOP };  //ROL3, abslX, ((PC), rADDRL)+X -> rADDR, PC++
            11'h23E:    uop_vector  =   {11'h33E, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ROL3, abslX, MEM->TMP
            11'h33E:    uop_vector  =   {11'h3FF, `A_ROL, `AL_TMP, `AR_NOP, `AQ_MEM, 7'b1000011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ROL4, abslX, ALU->MEM, done
            11'h03F:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h040:    uop_vector  =   {11'h140, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_INC };  //RTI2, SP++
            11'h140:    uop_vector  =   {11'h240, `A_BPS, `AL_MEM, `AR_NOP, `AQ_PPP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_SPPP, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_INC };  //RTI3, MEM->P, SP++
            11'h240:    uop_vector  =   {11'h340, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_SPPP, `RA1_NOPNOP, `RA2_0, `PC1_PLM, `PC2_NOP, `SP_INC };  //RTI4, MEM->PCL, SP++
            11'h340:    uop_vector  =   {11'h3ff, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_SPPP, `RA1_NOPNOP, `RA2_0, `PC1_PHM, `PC2_NOP, `SP_NOP };  //RTI5, MEM->PCH, done
            11'h041:    uop_vector  =   {11'h141, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_X, `PC1_INC, `PC2_NOP, `SP_NOP };  //EOR2, (indir,X), ((PC)+X)->rADDR, PC++
            11'h141:    uop_vector  =   {11'h241, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_HRLR_A, `RA2_1, `PC1_NOP, `PC2_NOP, `SP_NOP };  //EOR3, (indir,X), (rADDR)->TMP, rADDR++
            11'h241:    uop_vector  =   {11'h341, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_HMLT_B, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //EOR4, (indir,X), ((rADDR),TMP)->rADDR
            11'h341:    uop_vector  =   {11'h3FF, `A_EOR, `AL_AAA, `AR_MEM, `AQ_AAA, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //EOR5, (indir,X), calc, done
            11'h042:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h043:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h044:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h045:    uop_vector  =   {11'h145, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //EOR2, zero, PC++
            11'h145:    uop_vector  =   {11'h3ff, `A_EOR, `AL_AAA, `AR_MEM, `AQ_NOP, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //EOR3, zero, done
            11'h046:    uop_vector  =   {11'h146, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //LSR2, zero, PC++
            11'h146:    uop_vector  =   {11'h246, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //LSR3, zero, MEM->TMP
            11'h246:    uop_vector  =   {11'h3ff, `A_LSR, `AL_TMP, `AR_NOP, `AQ_MEM, 7'b1000011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //LSR4, zero, ALU->MEM, done
            11'h047:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h048:    uop_vector  =   {11'h3ff, `A_BPS, `AL_AAA, `AR_NOP, `AQ_MEM, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_SPPP, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_DEC };  //PHA, impl, A->MEM, SP--, done
            11'h049:    uop_vector  =   {11'h3ff, `A_EOR, `AL_AAA, `AR_MEM, `AQ_AAA, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //EOR, imme, pc++, done
            11'h04A:    uop_vector  =   {11'h3ff, `A_LSR, `AL_AAA, `AR_NOP, `AQ_AAA, 7'b1000011, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //LSR, accu. done
            11'h04B:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h04C:    uop_vector  =   {11'h14C, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //JMP2, MEM->TMP, PC++
            11'h14C:    uop_vector  =   {11'h3FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_PMT, `PC2_NOP, `SP_NOP };  //JMP3,(MEM, TMP) -> PC, done
            11'h04D:    uop_vector  =   {11'h14D, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //EOR2, absl, PC->ADDRL, PC++
            11'h14D:    uop_vector  =   {11'h24D, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //EOR3, absl, PC->ADDRH, PC++
            11'h24D:    uop_vector  =   {11'h3FF, `A_EOR, `AL_AAA, `AR_MEM, `AQ_AAA, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //EOR4, absl, calc, done     
            11'h04E:    uop_vector  =   {11'h14E, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //LSR2, absl, PC->ADDRL, PC++
            11'h14E:    uop_vector  =   {11'h24E, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //LSR3, absl, PC->ADDRH, PC++
            11'h24E:    uop_vector  =   {11'h34E, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //LSR4, absl, MEM->TMP,
            11'h34E:    uop_vector  =   {11'h3FF, `A_LSR, `AL_TMP, `AR_NOP, `AQ_MEM, 7'b1000011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //LSR5, absl, calc, done
            11'h04F:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h050:    uop_vector  =   {11'h150, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //BVC2, MEM->TMP, PC++
            11'h150:    uop_vector  =   {11'h3ff, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_BRC, `PC2_BVC, `SP_NOP };  //BVC3, PC+=TMP/0, done
            11'h051:    uop_vector  =   {11'h151, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //EOR2, (indir)Y, (PC)->rADDR, PC++
            11'h151:    uop_vector  =   {11'h251, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_HRLR_A, `RA2_1, `PC1_NOP, `PC2_NOP, `SP_NOP };  //EOR3, (indir)Y, (rADDR)->TMP, rADDR++
            11'h251:    uop_vector  =   {11'h351, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_HMLT_B, `RA2_Y, `PC1_NOP, `PC2_NOP, `SP_NOP };  //EOR4, (indir)Y, ((rADDR),TMP)+Y->rADDR
            11'h351:    uop_vector  =   {11'h3FF, `A_EOR, `AL_AAA, `AR_MEM, `AQ_AAA, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //EOR5, (indir)Y, calc, done
            11'h052:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h053:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h054:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h055:    uop_vector  =   {11'h155, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_X, `PC1_INC, `PC2_NOP, `SP_NOP };  //EOR2, zeroX, (PC) + X -> rADDRL, PC++
            11'h155:    uop_vector  =   {11'h3FF, `A_EOR, `AL_AAA, `AR_MEM, `AQ_AAA, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //EOR3, zeroX, calc, done
            11'h056:    uop_vector  =   {11'h156, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_X, `PC1_INC, `PC2_NOP, `SP_NOP };  //LSR2, zeroX, (PC) + X -> rADDRL, PC++
            11'h156:    uop_vector  =   {11'h256, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //LSR3, zeroX, MEM->TMP
            11'h256:    uop_vector  =   {11'h3FF, `A_LSR, `AL_TMP, `AR_NOP, `AQ_MEM, 7'b1000011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //LSR4, zeroX, ALU->MEM, done
            11'h057:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h058:    uop_vector  =   {11'h3ff, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000100, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //CLI, done
            11'h059:    uop_vector  =   {11'h159, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //EOR2, abslY, (PC)->rADDRL, PC++
            11'h159:    uop_vector  =   {11'h259, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_Y, `PC1_INC, `PC2_NOP, `SP_NOP };  //EOR3, abslY, ((PC), rADDRL)+Y -> rADDR, PC++
            11'h259:    uop_vector  =   {11'h3FF, `A_EOR, `AL_AAA, `AR_MEM, `AQ_AAA, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //EOR4, abslY, calc, done
            11'h05A:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h05B:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h05C:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h05D:    uop_vector  =   {11'h15D, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //EOR2, abslX, (PC)->rADDRL, PC++
            11'h15D:    uop_vector  =   {11'h25D, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_X, `PC1_INC, `PC2_NOP, `SP_NOP };  //EOR3, abslX, ((PC), rADDRL)+X -> rADDR, PC++
            11'h25D:    uop_vector  =   {11'h3FF, `A_EOR, `AL_AAA, `AR_MEM, `AQ_AAA, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //EOR4, abslX, calc, done
            11'h05E:    uop_vector  =   {11'h15E, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //LSR2, abslX, (PC)->rADDRL, PC++
            11'h15E:    uop_vector  =   {11'h25E, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_X, `PC1_INC, `PC2_NOP, `SP_NOP };  //LSR3, abslX, ((PC), rADDRL)+X -> rADDR, PC++
            11'h25E:    uop_vector  =   {11'h35E, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //LSR3, abslX, MEM->TMP
            11'h35E:    uop_vector  =   {11'h3FF, `A_LSR, `AL_TMP, `AR_NOP, `AQ_MEM, 7'b1000011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //LSR4, abslX, ALU->MEM, done
            11'h05F:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h060:    uop_vector  =   {11'h160, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_INC };  //RTS2, SP++
            11'h160:    uop_vector  =   {11'h260, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_SPPP, `RA1_NOPNOP, `RA2_0, `PC1_PLM, `PC2_NOP, `SP_INC };  //RTS3, MEM->PCL, SP++
            11'h260:    uop_vector  =   {11'h360, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_SPPP, `RA1_NOPNOP, `RA2_0, `PC1_PHM, `PC2_NOP, `SP_NOP };  //RTS4, MEM->PCH
            11'h360:    uop_vector  =   {11'h3ff, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //RTS5, PC++, done
            11'h061:    uop_vector  =   {11'h161, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_X, `PC1_INC, `PC2_NOP, `SP_NOP };  //ADC2, (indir,X), ((PC)+X)->rADDR, PC++
            11'h161:    uop_vector  =   {11'h261, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_HRLR_A, `RA2_1, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ADC3, (indir,X), (rADDR)->TMP, rADDR++
            11'h261:    uop_vector  =   {11'h361, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_HMLT_B, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ADC4, (indir,X), ((rADDR),TMP)->rADDR
            11'h361:    uop_vector  =   {11'h3FF, `A_ADC, `AL_AAA, `AR_MEM, `AQ_AAA, 7'b1100011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ADC5, (indir,X), calc, done
            11'h062:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h063:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h064:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h065:    uop_vector  =   {11'h165, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //ADC2, zero, PC++
            11'h165:    uop_vector  =   {11'h3ff, `A_ADC, `AL_AAA, `AR_MEM, `AQ_NOP, 7'b1100011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ADC3, zero, done
            11'h066:    uop_vector  =   {11'h166, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //ROR2, zero, PC++
            11'h166:    uop_vector  =   {11'h266, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ROR3, zero, MEM->TMP
            11'h266:    uop_vector  =   {11'h3ff, `A_ROR, `AL_TMP, `AR_NOP, `AQ_MEM, 7'b1000011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ROR4, zero, ALU->MEM, done
            11'h067:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h068:    uop_vector  =   {11'h168, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_INC };  //PLA2, impl, SP++
            11'h168:    uop_vector  =   {11'h3ff, `A_BPS, `AL_MEM, `AR_NOP, `AQ_AAA, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_SPPP, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //PLA3, MEM->P, done
            11'h069:    uop_vector  =   {11'h3ff, `A_ADC, `AL_AAA, `AR_MEM, `AQ_AAA, 7'b1100011, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //ADC imme, PC++, done
            11'h06A:    uop_vector  =   {11'h3ff, `A_ROR, `AL_AAA, `AR_NOP, `AQ_AAA, 7'b1000011, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ROR, accu. done
            11'h06B:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h06C:    uop_vector  =   {11'h16C, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //JMP2, indir, (PC) -> rADDRL, PC++
            11'h16C:    uop_vector  =   {11'h26C, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //JMP3, indir, (PC) -> rADDRH, PC++
            11'h26C:    uop_vector  =   {11'h36C, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_HRLR_A, `RA2_1, `PC1_PLM, `PC2_NOP, `SP_NOP };  //JMP4, indir, (rADDR)->PCL, rADDRL++
            11'h36C:    uop_vector  =   {11'h3FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_PHM, `PC2_NOP, `SP_NOP };  //JMP5, indir, (rADDR)->PCH, done
            11'h06D:    uop_vector  =   {11'h16D, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //ADC2, absl, PC->ADDRL, PC++
            11'h16D:    uop_vector  =   {11'h26D, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //ADC3, absl, PC->ADDRH, PC++
            11'h26D:    uop_vector  =   {11'h3FF, `A_ADC, `AL_AAA, `AR_MEM, `AQ_AAA, 7'b1100011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ADC4, absl, calc, done     
            11'h06E:    uop_vector  =   {11'h16E, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //ROR2, absl, PC->ADDRL, PC++
            11'h16E:    uop_vector  =   {11'h26E, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //ROR3, absl, PC->ADDRH, PC++
            11'h26E:    uop_vector  =   {11'h36E, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ROR4, absl, MEM->TMP,
            11'h36E:    uop_vector  =   {11'h3FF, `A_ROR, `AL_TMP, `AR_NOP, `AQ_MEM, 7'b1000011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ROR5, absl, calc, done
            11'h06F:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h070:    uop_vector  =   {11'h170, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //BVS2, MEM->TMP, PC++
            11'h170:    uop_vector  =   {11'h3ff, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_BRC, `PC2_BVS, `SP_NOP };  //BVS3, PC+=TMP/0, done
            11'h071:    uop_vector  =   {11'h171, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //ADC2, (indir)Y, (PC)->rADDR, PC++
            11'h171:    uop_vector  =   {11'h271, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_HRLR_A, `RA2_1, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ADC3, (indir)Y, (rADDR)->TMP, rADDR++
            11'h271:    uop_vector  =   {11'h371, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_HMLT_B, `RA2_Y, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ADC4, (indir)Y, ((rADDR),TMP)+Y->rADDR
            11'h371:    uop_vector  =   {11'h3FF, `A_ADC, `AL_AAA, `AR_MEM, `AQ_AAA, 7'b1100011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ADC5, (indir)Y, calc, done
            11'h072:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h073:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h074:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h075:    uop_vector  =   {11'h175, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_X, `PC1_INC, `PC2_NOP, `SP_NOP };  //ADC2, zeroX, (PC) + X -> rADDRL, PC++
            11'h175:    uop_vector  =   {11'h3FF, `A_ADC, `AL_AAA, `AR_MEM, `AQ_AAA, 7'b1100011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ADC3, zeroX, calc, done
            11'h076:    uop_vector  =   {11'h176, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_X, `PC1_INC, `PC2_NOP, `SP_NOP };  //ROR2, zeroX, (PC) + X -> rADDRL, PC++
            11'h176:    uop_vector  =   {11'h276, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ROR3, zeroX, MEM->TMP
            11'h276:    uop_vector  =   {11'h3FF, `A_ROR, `AL_TMP, `AR_NOP, `AQ_MEM, 7'b1000011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ROR4, zeroX, ALU->MEM, done
            11'h077:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h078:    uop_vector  =   {11'h3ff, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000100, 4'b0000, 7'b0000100, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //SEI, done
            11'h079:    uop_vector  =   {11'h179, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //ADC2, abslY, (PC)->rADDRL, PC++
            11'h179:    uop_vector  =   {11'h279, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_Y, `PC1_INC, `PC2_NOP, `SP_NOP };  //ADC3, abslY, ((PC), rADDRL)+Y -> rADDR, PC++
            11'h279:    uop_vector  =   {11'h3FF, `A_ADC, `AL_AAA, `AR_MEM, `AQ_AAA, 7'b1100011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ADC4, abslY, calc, done
            11'h07A:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h07B:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h07C:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h07D:    uop_vector  =   {11'h17D, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //ADC2, abslX, (PC)->rADDRL, PC++
            11'h17D:    uop_vector  =   {11'h27D, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_X, `PC1_INC, `PC2_NOP, `SP_NOP };  //ADC3, abslX, ((PC), rADDRL)+X -> rADDR, PC++
            11'h27D:    uop_vector  =   {11'h3FF, `A_ADC, `AL_AAA, `AR_MEM, `AQ_AAA, 7'b1100011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ADC4, abslX, calc, done
            11'h07E:    uop_vector  =   {11'h17E, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //ROR2, abslX, (PC)->rADDRL, PC++
            11'h17E:    uop_vector  =   {11'h27E, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_X, `PC1_INC, `PC2_NOP, `SP_NOP };  //ROR3, abslX, ((PC), rADDRL)+X -> rADDR, PC++
            11'h27E:    uop_vector  =   {11'h37E, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ROR3, abslX, MEM->TMP
            11'h37E:    uop_vector  =   {11'h3FF, `A_ROR, `AL_TMP, `AR_NOP, `AQ_MEM, 7'b1000011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //ROR4, abslX, ALU->MEM, done
            11'h07F:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h080:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h081:    uop_vector  =   {11'h181, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_X, `PC1_INC, `PC2_NOP, `SP_NOP };  //STA2, (indir,X), ((PC)+X)->rADDR, PC++
            11'h181:    uop_vector  =   {11'h281, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_HRLR_A, `RA2_1, `PC1_NOP, `PC2_NOP, `SP_NOP };  //STA3, (indir,X), (rADDR)->TMP, rADDR++
            11'h281:    uop_vector  =   {11'h381, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_HMLT_B, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //STA4, (indir,X), ((rADDR),TMP)->rADDR
            11'h381:    uop_vector  =   {11'h3FF, `A_BPS, `AL_AAA, `AR_NOP, `AQ_MEM, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //STA5, (indir,X), AAA->MEM, done
            11'h082:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h083:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h084:    uop_vector  =   {11'h184, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //STY2, zero, pc++
            11'h184:    uop_vector  =   {11'h3ff, `A_BPS, `AL_YYY, `AR_NOP, `AQ_MEM, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //STY3, zero, done
            11'h085:    uop_vector  =   {11'h185, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //STA2, zero, pc++
            11'h185:    uop_vector  =   {11'h3ff, `A_BPS, `AL_AAA, `AR_NOP, `AQ_MEM, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //STA3, zero, done
            11'h086:    uop_vector  =   {11'h186, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //STX2, zero, pc++
            11'h186:    uop_vector  =   {11'h3ff, `A_BPS, `AL_XXX, `AR_NOP, `AQ_MEM, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //STX3, zero, done
            11'h087:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h088:    uop_vector  =   {11'h3ff, `A_SB1, `AL_YYY, `AR_NOP, `AQ_YYY, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //DEY, impl, done
            11'h089:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h08A:    uop_vector  =   {11'h3ff, `A_BPS, `AL_XXX, `AR_NOP, `AQ_AAA, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //TXA, impl, done
            11'h08B:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h08C:    uop_vector  =   {11'h18C, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //STY2, absl, PC->ADDRL, PC++
            11'h18C:    uop_vector  =   {11'h28C, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //STY3, absl, PC->ADDRH, PC++
            11'h28C:    uop_vector  =   {11'h3FF, `A_BPS, `AL_YYY, `AR_NOP, `AQ_MEM, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //STY4, absl, Y->MEM, done     
            11'h08D:    uop_vector  =   {11'h18D, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //STA2, absl, PC->ADDRL, PC++
            11'h18D:    uop_vector  =   {11'h28D, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //STA3, absl, PC->ADDRH, PC++
            11'h28D:    uop_vector  =   {11'h3FF, `A_BPS, `AL_AAA, `AR_NOP, `AQ_MEM, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //STA4, absl, Y->MEM, done     
            11'h08E:    uop_vector  =   {11'h18E, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //STX2, absl, PC->ADDRL, PC++
            11'h18E:    uop_vector  =   {11'h28E, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //STX3, absl, PC->ADDRH, PC++
            11'h28E:    uop_vector  =   {11'h3FF, `A_BPS, `AL_XXX, `AR_NOP, `AQ_MEM, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //STX4, absl, Y->MEM, done     
            11'h08F:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h090:    uop_vector  =   {11'h190, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //BCC2, MEM->TMP, PC++
            11'h190:    uop_vector  =   {11'h3ff, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_BRC, `PC2_BCC, `SP_NOP };  //BCC3, PC+=TMP/0, done
            11'h091:    uop_vector  =   {11'h191, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //STA2, (indir)Y, (PC)->rADDR, PC++
            11'h191:    uop_vector  =   {11'h291, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_HRLR_A, `RA2_1, `PC1_NOP, `PC2_NOP, `SP_NOP };  //STA3, (indir)Y, (rADDR)->TMP, rADDR++
            11'h291:    uop_vector  =   {11'h391, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_HMLT_B, `RA2_Y, `PC1_NOP, `PC2_NOP, `SP_NOP };  //STA4, (indir)Y, ((rADDR),TMP)+Y->rADDR
            11'h391:    uop_vector  =   {11'h3FF, `A_BPS, `AL_AAA, `AR_NOP, `AQ_MEM, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //STA5, (indir)Y, AAA->MEM, done
            11'h092:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h093:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h094:    uop_vector  =   {11'h194, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_X, `PC1_INC, `PC2_NOP, `SP_NOP };  //STY2, zeroX, (PC) + X -> rADDRL, PC++
            11'h194:    uop_vector  =   {11'h3FF, `A_BPS, `AL_YYY, `AR_NOP, `AQ_MEM, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //STY3, zeroX, YYY->MEM, done
            11'h095:    uop_vector  =   {11'h195, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_X, `PC1_INC, `PC2_NOP, `SP_NOP };  //STA2, zeroX, (PC) + X -> rADDRL, PC++
            11'h195:    uop_vector  =   {11'h3FF, `A_BPS, `AL_AAA, `AR_NOP, `AQ_MEM, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //STA3, zeroX, AAA->MEM, done
            11'h096:    uop_vector  =   {11'h196, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_Y, `PC1_INC, `PC2_NOP, `SP_NOP };  //STX2, zeroY, (PC) + Y -> rADDRL, PC++
            11'h196:    uop_vector  =   {11'h3FF, `A_BPS, `AL_XXX, `AR_NOP, `AQ_MEM, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //STX3, zeroY, XXX->MEM, done
            11'h097:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h098:    uop_vector  =   {11'h3ff, `A_BPS, `AL_YYY, `AR_NOP, `AQ_AAA, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //TYA, impl, done
            11'h099:    uop_vector  =   {11'h199, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //STA2, abslY, (PC)->rADDRL, PC++
            11'h199:    uop_vector  =   {11'h299, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_Y, `PC1_INC, `PC2_NOP, `SP_NOP };  //STA3, abslY, ((PC), rADDRL)+Y -> rADDR, PC++
            11'h299:    uop_vector  =   {11'h3FF, `A_BPS, `AL_AAA, `AR_NOP, `AQ_MEM, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //STA4, abslY, ???->MEM, done
            11'h09A:    uop_vector  =   {11'h3ff, `A_BPS, `AL_XXX, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_SET };  //TXS, impl, done
            11'h09B:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h09C:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h09D:    uop_vector  =   {11'h19D, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //STA2, abslX, (PC)->rADDRL, PC++
            11'h19D:    uop_vector  =   {11'h29D, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_X, `PC1_INC, `PC2_NOP, `SP_NOP };  //STA3, abslX, ((PC), rADDRL)+X -> rADDR, PC++
            11'h29D:    uop_vector  =   {11'h3FF, `A_BPS, `AL_AAA, `AR_NOP, `AQ_MEM, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //STA4, abslX, AAA->MEM, done
            11'h09E:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h09F:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h0A0:    uop_vector  =   {11'h3ff, `A_BPS, `AL_MEM, `AR_NOP, `AQ_YYY, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //LDY2, imme, , PC++, done
            11'h0A1:    uop_vector  =   {11'h1A1, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_X, `PC1_INC, `PC2_NOP, `SP_NOP };  //LDA2, (indir,X), ((PC)+X)->rADDR, PC++
            11'h1A1:    uop_vector  =   {11'h2A1, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_HRLR_A, `RA2_1, `PC1_NOP, `PC2_NOP, `SP_NOP };  //LDA3, (indir,X), (rADDR)->TMP, rADDR++
            11'h2A1:    uop_vector  =   {11'h3A1, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_HMLT_B, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //LDA4, (indir,X), ((rADDR),TMP)->rADDR
            11'h3A1:    uop_vector  =   {11'h3FF, `A_BPS, `AL_MEM, `AR_NOP, `AQ_AAA, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //LDA5, (indir,X), calc, done
            11'h0A2:    uop_vector  =   {11'h3ff, `A_BPS, `AL_MEM, `AR_NOP, `AQ_XXX, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //LDX2, imme, , PC++, done
            11'h0A3:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h0A4:    uop_vector  =   {11'h1A4, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //LDY2, zero, PC++
            11'h1A4:    uop_vector  =   {11'h3ff, `A_BPS, `AL_MEM, `AR_NOP, `AQ_YYY, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //LDY3, zero, done
            11'h0A5:    uop_vector  =   {11'h1A5, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //LDA2, zero, PC++
            11'h1A5:    uop_vector  =   {11'h3ff, `A_BPS, `AL_MEM, `AR_NOP, `AQ_AAA, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //LDA3, zero, done
            11'h0A6:    uop_vector  =   {11'h1A6, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //LDX2, zero, PC++
            11'h1A6:    uop_vector  =   {11'h3ff, `A_BPS, `AL_MEM, `AR_NOP, `AQ_XXX, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //LDX3, zero, done
            11'h0A7:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h0A8:    uop_vector  =   {11'h3ff, `A_BPS, `AL_AAA, `AR_NOP, `AQ_YYY, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //TAY, impl, done
            11'h0A9:    uop_vector  =   {11'h3ff, `A_BPS, `AL_MEM, `AR_NOP, `AQ_AAA, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //LDA, imme, pc++, done
            11'h0AA:    uop_vector  =   {11'h3ff, `A_BPS, `AL_AAA, `AR_NOP, `AQ_XXX, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //TAX, impl, done
            11'h0AB:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h0AC:    uop_vector  =   {11'h1AC, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //LDY2, absl, PC->ADDRL, PC++
            11'h1AC:    uop_vector  =   {11'h2AC, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //LDY3, absl, PC->ADDRH, PC++
            11'h2AC:    uop_vector  =   {11'h3FF, `A_BPS, `AL_MEM, `AR_NOP, `AQ_YYY, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //LDY4, absl, calc, done     
            11'h0AD:    uop_vector  =   {11'h1AD, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //LDA2, absl, PC->ADDRL, PC++
            11'h1AD:    uop_vector  =   {11'h2AD, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //LDA3, absl, PC->ADDRH, PC++
            11'h2AD:    uop_vector  =   {11'h3FF, `A_BPS, `AL_MEM, `AR_NOP, `AQ_AAA, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //LDA4, absl, calc, done     
            11'h0AE:    uop_vector  =   {11'h1AE, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //LDX2, absl, PC->ADDRL, PC++
            11'h1AE:    uop_vector  =   {11'h2AE, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //LDX3, absl, PC->ADDRH, PC++
            11'h2AE:    uop_vector  =   {11'h3FF, `A_BPS, `AL_MEM, `AR_NOP, `AQ_XXX, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //LDX4, absl, calc, done     
            11'h0AF:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h0B0:    uop_vector  =   {11'h1B0, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //BCS2, MEM->TMP, PC++
            11'h1B0:    uop_vector  =   {11'h3ff, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_BRC, `PC2_BCS, `SP_NOP };  //BCS3, PC+=TMP/0, done
            11'h0B1:    uop_vector  =   {11'h1B1, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //LDA2, (indir)Y, (PC)->rADDR, PC++
            11'h1B1:    uop_vector  =   {11'h2B1, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_HRLR_A, `RA2_1, `PC1_NOP, `PC2_NOP, `SP_NOP };  //LDA3, (indir)Y, (rADDR)->TMP, rADDR++
            11'h2B1:    uop_vector  =   {11'h3B1, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_HMLT_B, `RA2_Y, `PC1_NOP, `PC2_NOP, `SP_NOP };  //LDA4, (indir)Y, ((rADDR),TMP)+Y->rADDR
            11'h3B1:    uop_vector  =   {11'h3FF, `A_BPS, `AL_MEM, `AR_NOP, `AQ_AAA, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //LDA5, (indir)Y, calc, done
            11'h0B2:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h0B3:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h0B4:    uop_vector  =   {11'h1B4, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_X, `PC1_INC, `PC2_NOP, `SP_NOP };  //LDY2, zeroX, (PC) + X -> rADDRL, PC++
            11'h1B4:    uop_vector  =   {11'h3FF, `A_BPS, `AL_MEM, `AR_NOP, `AQ_YYY, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //LDY3, zeroX, calc, done
            11'h0B5:    uop_vector  =   {11'h1B5, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_X, `PC1_INC, `PC2_NOP, `SP_NOP };  //LDA2, zeroX, (PC) + X -> rADDRL, PC++
            11'h1B5:    uop_vector  =   {11'h3FF, `A_BPS, `AL_MEM, `AR_NOP, `AQ_AAA, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //LDA3, zeroX, calc, done
            11'h0B6:    uop_vector  =   {11'h1B6, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_Y, `PC1_INC, `PC2_NOP, `SP_NOP };  //LDX2, zeroY, (PC) + Y -> rADDRL, PC++
            11'h1B6:    uop_vector  =   {11'h3FF, `A_BPS, `AL_MEM, `AR_NOP, `AQ_XXX, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //LDX3, zeroY, calc, done
            11'h0B7:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h0B8:    uop_vector  =   {11'h3ff, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0100000, 4'b0100, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //CLV, done
            11'h0B9:    uop_vector  =   {11'h1B9, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //LDA2, abslY, (PC)->rADDRL, PC++
            11'h1B9:    uop_vector  =   {11'h2B9, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_Y, `PC1_INC, `PC2_NOP, `SP_NOP };  //LDA3, abslY, ((PC), rADDRL)+Y -> rADDR, PC++
            11'h2B9:    uop_vector  =   {11'h3FF, `A_BPS, `AL_MEM, `AR_NOP, `AQ_AAA, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //LDA4, abslY, calc, done
            11'h0BA:    uop_vector  =   {11'h3ff, `A_BPS, `AL_SPP, `AR_NOP, `AQ_XXX, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //TSX, impl, done
            11'h0BB:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h0BC:    uop_vector  =   {11'h1BC, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //LDY2, abslX, (PC)->rADDRL, PC++
            11'h1BC:    uop_vector  =   {11'h2BC, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_X, `PC1_INC, `PC2_NOP, `SP_NOP };  //LDY3, abslX, ((PC), rADDRL)+X -> rADDR, PC++
            11'h2BC:    uop_vector  =   {11'h3FF, `A_BPS, `AL_MEM, `AR_NOP, `AQ_YYY, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //LDY4, abslX, calc, done
            11'h0BD:    uop_vector  =   {11'h1BD, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //LDA2, abslX, (PC)->rADDRL, PC++
            11'h1BD:    uop_vector  =   {11'h2BD, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_X, `PC1_INC, `PC2_NOP, `SP_NOP };  //LDA3, abslX, ((PC), rADDRL)+X -> rADDR, PC++
            11'h2BD:    uop_vector  =   {11'h3FF, `A_BPS, `AL_MEM, `AR_NOP, `AQ_AAA, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //LDA4, abslX, calc, done
            11'h0BE:    uop_vector  =   {11'h1BE, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //LDX2, abslY, (PC)->rADDRL, PC++
            11'h1BE:    uop_vector  =   {11'h2BE, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_Y, `PC1_INC, `PC2_NOP, `SP_NOP };  //LDX3, abslY, ((PC), rADDRL)+Y -> rADDR, PC++
            11'h2BE:    uop_vector  =   {11'h3FF, `A_BPS, `AL_MEM, `AR_NOP, `AQ_XXX, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //LDX4, abslY, calc, done
            11'h0BF:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h0C0:    uop_vector  =   {11'h3ff, `A_CMP, `AL_YYY, `AR_MEM, `AQ_NOP, 7'b1000011, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };   //CPY2, imme, PC++ done
            11'h0C1:    uop_vector  =   {11'h1C1, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_X, `PC1_INC, `PC2_NOP, `SP_NOP };  //CMP2, (indir,X), ((PC)+X)->rADDR, PC++
            11'h1C1:    uop_vector  =   {11'h2C1, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_HRLR_A, `RA2_1, `PC1_NOP, `PC2_NOP, `SP_NOP };  //CMP3, (indir,X), (rADDR)->TMP, rADDR++
            11'h2C1:    uop_vector  =   {11'h3C1, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_HMLT_B, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //CMP4, (indir,X), ((rADDR),TMP)->rADDR
            11'h3C1:    uop_vector  =   {11'h3FF, `A_CMP, `AL_AAA, `AR_MEM, `AQ_NOP, 7'b1000011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //CMP5, (indir,X), calc, done
            11'h0C2:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h0C3:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h0C4:    uop_vector  =   {11'h1C4, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //CPY2, zero, PC++
            11'h1C4:    uop_vector  =   {11'h3ff, `A_CMP, `AL_YYY, `AR_MEM, `AQ_NOP, 7'b1000011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //CPY3, zero, done
            11'h0C5:    uop_vector  =   {11'h1C5, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //CMP2, zero, PC++
            11'h1C5:    uop_vector  =   {11'h3ff, `A_CMP, `AL_AAA, `AR_MEM, `AQ_NOP, 7'b1000011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //CMP3, zero, done
            11'h0C6:    uop_vector  =   {11'h1C6, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //DEC2, zero, PC++
            11'h1C6:    uop_vector  =   {11'h2C6, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //DEC3, zero, MEM->TMP
            11'h2C6:    uop_vector  =   {11'h3ff, `A_SB1, `AL_TMP, `AR_NOP, `AQ_MEM, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //DEC4, zero, ALU->MEM, done
            11'h0C7:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h0C8:    uop_vector  =   {11'h3ff, `A_AD1, `AL_YYY, `AR_NOP, `AQ_YYY, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //INY, impl, done
            11'h0C9:    uop_vector  =   {11'h3ff, `A_CMP, `AL_AAA, `AR_MEM, `AQ_NOP, 7'b1000011, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //CMP, imme, done
            11'h0CA:    uop_vector  =   {11'h3ff, `A_SB1, `AL_XXX, `AR_NOP, `AQ_XXX, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //DEX, impl, done
            11'h0CB:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h0CC:    uop_vector  =   {11'h1CC, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //CPY2, absl, PC->ADDRL, PC++
            11'h1CC:    uop_vector  =   {11'h2CC, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //CPY3, absl, PC->ADDRH, PC++
            11'h2CC:    uop_vector  =   {11'h3FF, `A_CMP, `AL_YYY, `AR_MEM, `AQ_NOP, 7'b1000011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //CPY4, absl, calc, done     
            11'h0CD:    uop_vector  =   {11'h1CD, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //CMP2, absl, PC->ADDRL, PC++
            11'h1CD:    uop_vector  =   {11'h2CD, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //CMP3, absl, PC->ADDRH, PC++
            11'h2CD:    uop_vector  =   {11'h3FF, `A_CMP, `AL_AAA, `AR_MEM, `AQ_NOP, 7'b1000011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //CMP4, absl, calc, done     
            11'h0CE:    uop_vector  =   {11'h1CE, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //DEC2, absl, PC->ADDRL, PC++
            11'h1CE:    uop_vector  =   {11'h2CE, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //DEC3, absl, PC->ADDRH, PC++
            11'h2CE:    uop_vector  =   {11'h3CE, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //DEC4, absl, MEM->TMP,
            11'h3CE:    uop_vector  =   {11'h3FF, `A_SB1, `AL_TMP, `AR_NOP, `AQ_MEM, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //DEC5, absl, calc, done
            11'h0CF:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h0D0:    uop_vector  =   {11'h1D0, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //BNE2, MEM->TMP, PC++
            11'h1D0:    uop_vector  =   {11'h3ff, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_BRC, `PC2_BNE, `SP_NOP };  //BNE3, PC+=TMP/0, done
            11'h0D1:    uop_vector  =   {11'h1D1, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //CMP2, (indir)Y, (PC)->rADDR, PC++
            11'h1D1:    uop_vector  =   {11'h2D1, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_HRLR_A, `RA2_1, `PC1_NOP, `PC2_NOP, `SP_NOP };  //CMP3, (indir)Y, (rADDR)->TMP, rADDR++
            11'h2D1:    uop_vector  =   {11'h3D1, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_HMLT_B, `RA2_Y, `PC1_NOP, `PC2_NOP, `SP_NOP };  //CMP4, (indir)Y, ((rADDR),TMP)+Y->rADDR
            11'h3D1:    uop_vector  =   {11'h3FF, `A_CMP, `AL_AAA, `AR_MEM, `AQ_NOP, 7'b1000011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //CMP5, (indir)Y, calc, done
            11'h0D2:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h0D3:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h0D4:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h0D5:    uop_vector  =   {11'h1D5, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_X, `PC1_INC, `PC2_NOP, `SP_NOP };  //CMP2, zeroX, (PC) + X -> rADDRL, PC++
            11'h1D5:    uop_vector  =   {11'h3FF, `A_CMP, `AL_AAA, `AR_MEM, `AQ_NOP, 7'b1000011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //CMP3, zeroX, calc, done
            11'h0D6:    uop_vector  =   {11'h1D6, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_X, `PC1_INC, `PC2_NOP, `SP_NOP };  //DEC2, zeroX, (PC) + X -> rADDRL, PC++
            11'h1D6:    uop_vector  =   {11'h2D6, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //DEC3, zeroX, MEM->TMP
            11'h2D6:    uop_vector  =   {11'h3FF, `A_SB1, `AL_TMP, `AR_NOP, `AQ_MEM, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //DEC4, zeroX, ALU->MEM, done
            11'h0D7:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h0D8:    uop_vector  =   {11'h3ff, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0001000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //CLD, done
            11'h0D9:    uop_vector  =   {11'h1D9, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //CMP2, abslY, (PC)->rADDRL, PC++
            11'h1D9:    uop_vector  =   {11'h2D9, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_Y, `PC1_INC, `PC2_NOP, `SP_NOP };  //CMP3, abslY, ((PC), rADDRL)+Y -> rADDR, PC++
            11'h2D9:    uop_vector  =   {11'h3FF, `A_CMP, `AL_AAA, `AR_MEM, `AQ_NOP, 7'b1000011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //CMP4, abslY, calc, done
            11'h0DA:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h0DB:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h0DC:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h0DD:    uop_vector  =   {11'h1DD, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //CMP2, abslX, (PC)->rADDRL, PC++
            11'h1DD:    uop_vector  =   {11'h2DD, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_X, `PC1_INC, `PC2_NOP, `SP_NOP };  //CMP3, abslX, ((PC), rADDRL)+X -> rADDR, PC++
            11'h2DD:    uop_vector  =   {11'h3FF, `A_CMP, `AL_AAA, `AR_MEM, `AQ_NOP, 7'b1000011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //CMP4, abslX, calc, done
            11'h0DE:    uop_vector  =   {11'h1DE, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //DEC2, abslX, (PC)->rADDRL, PC++
            11'h1DE:    uop_vector  =   {11'h2DE, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_X, `PC1_INC, `PC2_NOP, `SP_NOP };  //DEC3, abslX, ((PC), rADDRL)+X -> rADDR, PC++
            11'h2DE:    uop_vector  =   {11'h3DE, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //DEC3, abslX, MEM->TMP
            11'h3DE:    uop_vector  =   {11'h3FF, `A_SB1, `AL_TMP, `AR_NOP, `AQ_MEM, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //DEC4, abslX, ALU->MEM, done
            11'h0DF:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h0E0:    uop_vector  =   {11'h3ff, `A_CMP, `AL_XXX, `AR_MEM, `AQ_NOP, 7'b1000011, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //CPX2, imme, PC++ done.
            11'h0E1:    uop_vector  =   {11'h1E1, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_X, `PC1_INC, `PC2_NOP, `SP_NOP };  //SBC2, (indir,X), ((PC)+X)->rADDR, PC++
            11'h1E1:    uop_vector  =   {11'h2E1, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_HRLR_A, `RA2_1, `PC1_NOP, `PC2_NOP, `SP_NOP };  //SBC3, (indir,X), (rADDR)->TMP, rADDR++
            11'h2E1:    uop_vector  =   {11'h3E1, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_HMLT_B, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //SBC4, (indir,X), ((rADDR),TMP)->rADDR
            11'h3E1:    uop_vector  =   {11'h3FF, `A_SBC, `AL_AAA, `AR_MEM, `AQ_AAA, 7'b1100011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //SBC5, (indir,X), calc, done
            11'h0E2:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h0E3:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h0E4:    uop_vector  =   {11'h1E4, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //CPX2, zero, PC++
            11'h1E4:    uop_vector  =   {11'h3ff, `A_CMP, `AL_XXX, `AR_MEM, `AQ_NOP, 7'b1000011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //CPX3, zero, done
            11'h0E5:    uop_vector  =   {11'h1E5, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //SBC2, zero, PC++
            11'h1E5:    uop_vector  =   {11'h3ff, `A_SBC, `AL_AAA, `AR_MEM, `AQ_AAA, 7'b1100011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //SBC3, zero, done
            11'h0E6:    uop_vector  =   {11'h1E6, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //INC2, zero, PC++
            11'h1E6:    uop_vector  =   {11'h2E6, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //INC3, zero, MEM->TMP
            11'h2E6:    uop_vector  =   {11'h3ff, `A_AD1, `AL_TMP, `AR_NOP, `AQ_MEM, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //INC4, zero, ALU->MEM, done
            11'h0E7:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h0E8:    uop_vector  =   {11'h3ff, `A_AD1, `AL_XXX, `AR_NOP, `AQ_XXX, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //INX, implied, done
            11'h0E9:    uop_vector  =   {11'h3ff, `A_SBC, `AL_AAA, `AR_MEM, `AQ_AAA, 7'b1100011, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //SBC, imme, pc++. done
            11'h0EA:    uop_vector  =   {11'h3ff, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //NOP, implied, done
            11'h0EB:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h0EC:    uop_vector  =   {11'h1EC, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //CPX2, absl, PC->ADDRL, PC++
            11'h1EC:    uop_vector  =   {11'h2EC, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //CPX3, absl, PC->ADDRH, PC++
            11'h2EC:    uop_vector  =   {11'h3FF, `A_CMP, `AL_XXX, `AR_MEM, `AQ_NOP, 7'b1000011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //CPX4, absl, calc, done     
            11'h0ED:    uop_vector  =   {11'h1ED, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //SBC2, absl, PC->ADDRL, PC++
            11'h1ED:    uop_vector  =   {11'h2ED, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //SBC3, absl, PC->ADDRH, PC++
            11'h2ED:    uop_vector  =   {11'h3FF, `A_SBC, `AL_AAA, `AR_MEM, `AQ_AAA, 7'b1100011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //SBC4, absl, calc, done     
            11'h0EE:    uop_vector  =   {11'h1EE, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //INC2, absl, PC->ADDRL, PC++
            11'h1EE:    uop_vector  =   {11'h2EE, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //INC3, absl, PC->ADDRH, PC++
            11'h2EE:    uop_vector  =   {11'h3EE, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //INC4, absl, MEM->TMP,
            11'h3EE:    uop_vector  =   {11'h3FF, `A_AD1, `AL_TMP, `AR_NOP, `AQ_MEM, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //INC5, absl, calc, done
            11'h0EF:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h0F0:    uop_vector  =   {11'h1F0, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //BEQ2, MEM->TMP, PC++
            11'h1F0:    uop_vector  =   {11'h3ff, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_BRC, `PC2_BEQ, `SP_NOP };  //BEQ3, PC+=TMP/0, done
            11'h0F1:    uop_vector  =   {11'h1F1, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //SBC2, (indir)Y, (PC)->rADDR, PC++
            11'h1F1:    uop_vector  =   {11'h2F1, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_HRLR_A, `RA2_1, `PC1_NOP, `PC2_NOP, `SP_NOP };  //SBC3, (indir)Y, (rADDR)->TMP, rADDR++
            11'h2F1:    uop_vector  =   {11'h3F1, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_HMLT_B, `RA2_Y, `PC1_NOP, `PC2_NOP, `SP_NOP };  //SBC4, (indir)Y, ((rADDR),TMP)+Y->rADDR
            11'h3F1:    uop_vector  =   {11'h3FF, `A_SBC, `AL_AAA, `AR_MEM, `AQ_AAA, 7'b1100011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //SBC5, (indir)Y, calc, done
            11'h0F2:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h0F3:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h0F4:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h0F5:    uop_vector  =   {11'h1F5, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_X, `PC1_INC, `PC2_NOP, `SP_NOP };  //SBC2, zeroX, (PC) + X -> rADDRL, PC++
            11'h1F5:    uop_vector  =   {11'h3FF, `A_SBC, `AL_AAA, `AR_MEM, `AQ_AAA, 7'b1100011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //SBC3, zeroX, calc, done
            11'h0F6:    uop_vector  =   {11'h1F6, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_X, `PC1_INC, `PC2_NOP, `SP_NOP };  //INC2, zeroX, (PC) + X -> rADDRL, PC++
            11'h1F6:    uop_vector  =   {11'h2F6, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //INC3, zeroX, MEM->TMP
            11'h2F6:    uop_vector  =   {11'h3FF, `A_AD1, `AL_TMP, `AR_NOP, `AQ_MEM, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //INC4, zeroX, ALU->MEM, done
            11'h0F7:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h0F8:    uop_vector  =   {11'h3ff, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0001000, 4'b0000, 7'b0001000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //SED, done
            11'h0F9:    uop_vector  =   {11'h1F9, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //SBC2, abslY, (PC)->rADDRL, PC++
            11'h1F9:    uop_vector  =   {11'h2F9, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_Y, `PC1_INC, `PC2_NOP, `SP_NOP };  //SBC3, abslY, ((PC), rADDRL)+Y -> rADDR, PC++
            11'h2F9:    uop_vector  =   {11'h3FF, `A_SBC, `AL_AAA, `AR_MEM, `AQ_AAA, 7'b1100011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //SBC4, abslY, calc, done
            11'h0FA:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h0FB:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h0FC:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h0FD:    uop_vector  =   {11'h1FD, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //SBC2, abslX, (PC)->rADDRL, PC++
            11'h1FD:    uop_vector  =   {11'h2FD, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_X, `PC1_INC, `PC2_NOP, `SP_NOP };  //SBC3, abslX, ((PC), rADDRL)+X -> rADDR, PC++
            11'h2FD:    uop_vector  =   {11'h3FF, `A_SBC, `AL_AAA, `AR_MEM, `AQ_AAA, 7'b1100011, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //SBC4, abslX, calc, done
            11'h0FE:    uop_vector  =   {11'h1FE, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_H0LM_A, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //INC2, abslX, (PC)->rADDRL, PC++
            11'h1FE:    uop_vector  =   {11'h2FE, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_HMLR_B, `RA2_X, `PC1_INC, `PC2_NOP, `SP_NOP };  //INC3, abslX, ((PC), rADDRL)+X -> rADDR, PC++
            11'h2FE:    uop_vector  =   {11'h3FE, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b1, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //INC3, abslX, MEM->TMP
            11'h3FE:    uop_vector  =   {11'h3FF, `A_AD1, `AL_TMP, `AR_NOP, `AQ_MEM, 7'b1000010, 4'b0000, 7'b0000000, 1'b0, `OA_RADD, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //INC4, abslX, ALU->MEM, done
            11'h0FF:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h1FF:    uop_vector  =   {11'h2FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_RPCL, `RA1_NOPNOP, `RA2_0, `PC1_PLM, `PC2_NOP, `SP_NOP };  //RST1, load PCL
            11'h2FF:    uop_vector  =   {11'h3FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000100, 4'b0000, 7'b0000100, 1'b0, `OA_RPCH, `RA1_NOPNOP, `RA2_0, `PC1_PHM, `PC2_NOP, `SP_NOP };  //RST2, load PCH, setI
            11'h3FF:    uop_vector  =   {11'h7ff, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_INC, `PC2_NOP, `SP_NOP };  //Fetch OPCODE, PC++
            11'h4FF:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
            11'h5FF:    uop_vector  =   {11'h6FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //general interrupt entry1, empty cycle
            11'h6FF:    uop_vector  =   {11'h100, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //general interrupt entry2, empty cycle
            default:    uop_vector  =   {11'h4FF, `A_NOP, `AL_NOP, `AR_NOP, `AQ_NOP, 7'b0000000, 4'b0000, 7'b0000000, 1'b0, `OA_PCCC, `RA1_NOPNOP, `RA2_0, `PC1_NOP, `PC2_NOP, `SP_NOP };  //it's a trap
        endcase
    end
endmodule
