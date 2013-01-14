class Driver;
    //virtual M_BUS.TB_PORT m_bus;
    virtual M_INT.TB_PORT m_int;
    
    function new(/*virtual M_BUS.TB_PORT mb, */virtual M_INT.TB_PORT mi);
        //m_bus = mb;
        m_int = mi;
    endfunction
    
    task init();
        @(m_int.sync);
        m_int.sync.RST_N <= 0;
        m_int.sync.IRQ_N <= 1;
        m_int.sync.NMI_N <= 1;
        repeat (5) @(m_int.sync);
        m_int.sync.RST_N <= 1;
    endtask
    
    task run();
        repeat (1000) @(m_int.sync);
        $stop;
    endtask
endclass
