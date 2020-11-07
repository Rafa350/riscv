#include "sim.h"
#include "testbench.h"
#include "memory.h"
    
#include <verilated_fst_c.h>
    
    
// Els temps son en ticks de simulacio (simTime). Per que sigui totalment
// asincron, els temps d'activacio o desactivacio no poden ser multiples 
// de 10, ja que el temp del sistems (clock) es cada 10 ticks del temps 
// de simulacio (simTime)
//
#define CLOCK_MAX             500  // Nombre de ticks a simular
#define CLOCK_START             0  // Tick per iniciar clk
#define CLOCK_TICKS            10  // Tics per cicle clk

#define CLOCK_RST_SET           0  // Tic per iniciar el reset
#define CLOCK_RST_CLR           7  // Tic per acabar el reset

    
using namespace Simulation;


class CPUTestbench: public Testbench<Vtop, VerilatedFstC> {
       
    private:
        ROM *rom;
        RAM *ram;
        
    public:
        CPUTestbench(ROM *rom, RAM *ram);
        void run();
};


/// ----------------------------------------------------------------------
/// \bried    Contructor de l'objecte
/// \param    rom: Memoria rom
/// \param    ram: Memoria ram
///
CPUTestbench::CPUTestbench(
    ROM *rom, 
    RAM *ram):
    
    rom(rom),
    ram(ram)     {
   
}


/// ----------------------------------------------------------------------
/// \brief    Executa la simulacio.
///
void CPUTestbench::run() {
    
    std::string traceFileName("waves_sc/trace.fst");
	
    Vtop *top = getTop();
    top->i_clk = 0;
    top->i_rst = 0;

    writeConsole("*** CPU\n");
    writeConsole("*** Starting simulation...\n");

    openTrace(traceFileName);
    writeConsole("*** Enabling waves...\n");
    writeConsole(std::string("    --Wave file name: " + traceFileName + "\n"));

    writeConsole("*** Start simulation loop.\n");
        
    unsigned tick;
    do {        
        tick = getTickCount();
        
        // Genera la senyal 'clk'
        //
        if (tick >= CLOCK_START) {
            if ((tick % 10) == 0)
                top->i_clk = 0;
            else if ((tick % 10) == 5) 
                top->i_clk = 1;
        }

        // Genera la senyal de 'rst'
        //
        if (tick == CLOCK_RST_CLR)
            top->i_rst = 0;
        else if (tick == CLOCK_RST_SET)
            top->i_rst = 1;
		
		// Acces al programa 
		//
		top->i_rom_rdata = rom->read32(top->o_rom_addr);
        
        // Acces a la RAM
        //
        top->i_ram_rdata = ram->read32(top->o_ram_addr);
        if (top->o_ram_we) 
            ram->write32(top->o_ram_addr, top->o_ram_wdata);
        
        // Desensambla l'instruccio actual
        //        
        if (((tick % 10) == 0) && (top->i_clk == 0) && (top->i_rst == 0))
            disassembly(top->o_rom_addr >> 2, top->i_rom_rdata);

    } while (nextTick() && (tick < CLOCK_MAX));
    
    closeTrace();
    
    writeConsole("*** End simulation loop.\n");
    writeConsole("    --Total simulation time: " + std::to_string(getTickCount()) + " ticks.\n");

    writeConsole("*** ROM dump start.\n");
    rom->dump(0, 16);
    writeConsole("*** ROM dump end.\n");
    
    writeConsole("*** RAM dump start.\n");
    ram->dump(0, 16);
    writeConsole("*** RAM dump end.\n");
	
    writeConsole("*** Simulation end.\n");
    writeConsole("*** Exit.\n");
}


/// ----------------------------------------------------------------------
/// \brief    Entrada a l'aplicacio.
/// \param    argc: Nombre d'arguments.
/// \param    argv: Llista d'arguments.
/// \param    env: Variables del sistema.
/// \return   0 si tot es correcte.
///
int main(
    int argc, 
    char **argv, 
    char **env) {
        
	ROM *rom = new ROM();
    RAM *ram = new RAM();

    CPUTestbench *tb = new CPUTestbench(rom, ram);
    tb->run();   
    delete tb;
    
    delete rom;
    delete ram;
    
    return 0;
}
