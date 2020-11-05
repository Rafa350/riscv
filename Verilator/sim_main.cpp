#include "sim.h"


int main(int argc, char **argv, char **env) {
    
    const char *romFileName = "";
    const char *traceFileName = "trace.vcd";
    
    Verilated::commandArgs(argc, argv);    
    Verilated::debug(0);

    Vtop *top = new Vtop();    
    if (top) {
        VL_PRINTF("*** Starting simulation...\n");
        
        VL_PRINTF("*** Loading ROM...\n");
        ROM *rom = new ROM();
        if (!rom)
            exit(1);
        VL_PRINTF("*** ROM Loaded.\n");
        VL_PRINTF("    --Load size: %d bytes.\n", rom->getSize());
        
        RAM *ram = new RAM();
        
#if VM_TRACE			
        Verilated::traceEverOn(true);	
        VerilatedVcdC* tfp = new VerilatedVcdC;
        top->trace (tfp, 99);	
        tfp->open (traceFileName);
        VL_PRINTF("*** Enabling waves...\n");
        VL_PRINTF("    --Wave file name: %s\n", traceFileName);
#endif
        top->i_clk = 0;
        top->i_rst = 0;

        VL_PRINTF("*** Start simulation loop.\n");
        const int maxTime = 1000;
        unsigned time;
        for (time = 0; (time < maxTime) && !Verilated::gotFinish() && top->o_rom_addr < rom->getSize(); time++) {
            
            if (time && ((time % 10) == 0))
                top->i_clk = !top->i_clk;

            top->i_rst = time < 15;
            top->i_rom_rdata = rom->read32(top->o_rom_addr);
            
            if (top->o_ram_we)
                ram->write32(top->o_ram_addr, top->o_ram_wdata);
            top->i_ram_rdata = ram->read32(top->o_ram_addr);
            
            if (((time % 10) == 0) && (top->i_clk == 0) && (top->i_rst == 0))
                disassembly(top->o_rom_addr >> 2, top->i_rom_rdata);
            
            top->eval();
#if VM_TRACE
            if (tfp) 
                tfp->dump(time);	
#endif
            
        }
        VL_PRINTF("*** End simulation loop.\n");
        VL_PRINTF("    --Total simulation time: %d ticks.\n", time);

        top->final();
        
#if VM_TRACE
        if (tfp) 
            tfp->close();
#endif
        
        delete top;
        VL_PRINTF("*** Simulation end.\n");

        VL_PRINTF("*** ROM dump start.\n");
        rom->dump(0, 16);
        VL_PRINTF("*** ROM dump end.\n");
        
        VL_PRINTF("*** RAM dump start.\n");
        ram->dump(0, 16);
        VL_PRINTF("*** RAM dump end.\n");
    }
    
    VL_PRINTF("*** End.\n");

    exit(0);    
    
    return 0;
}
