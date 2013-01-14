interface M_BUS(input bit CLK);
    logic [15:0]    ADDR;
    logic           R_WN;
    logic [7:0]     oDATA;
    logic [7:0]     iDATA;
    
    //clocking sync @ (posedge CLK);
    //    input ADDR;
    //    input R_WN;
    //    input oDATA;
    //    output iDATA;
    //endclocking
    
    //modport TB_PORT(clocking sync);
    modport DUT_PORT(output ADDR, output R_WN, output oDATA, input iDATA);
    modport RAM_PORT(input ADDR, input R_WN, input oDATA, output iDATA);
endinterface

interface M_INT(input bit CLK);
    logic RST_N;
    logic NMI_N;
    logic IRQ_N;
    
    clocking sync @(posedge CLK);
        output RST_N;
        output NMI_N;
        output IRQ_N;
    endclocking

    modport TB_PORT(clocking sync);
    modport DUT_PORT(input RST_N, input NMI_N, input IRQ_N);
endinterface
