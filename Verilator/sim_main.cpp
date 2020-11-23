#include "sim.h"

    
#define PIPELINE


#ifdef PIPELINE
    #define TRACE_FILE_NAME "../waves_pp/trace.fst"
#else
    #define TRACE_FILE_NAME "../waves_sc/trace.fst"
#endif
    
    
// Els temps son en ticks de simulacio (simTime). Per que sigui totalment
// asincron, els temps d'activacio o desactivacio no poden ser multiples 
// de 10, ja que el temp del sistems (clock) es cada 10 ticks del temps 
// de simulacio (simTime)
//
#define CLOCK_MAX             400  // Nombre de ticks a simular
#define CLOCK_START             0  // Tick per iniciar clk
#define CLOCK_TICKS            10  // Tics per cicle clk

#define CLOCK_RST_SET           0  // Tic per iniciar el reset
#define CLOCK_RST_CLR           7  // Tic per acabar el reset


using namespace Simulation;


class CPUTestbench: public Testbench<Vtop, VerilatedFstC> {
       
    private:
        RAM *ram;
        
    public:
        CPUTestbench(RAM *ram);
        void run();
};


/// ----------------------------------------------------------------------
/// \bried    Contructor de l'objecte
/// \param    rom: Memoria rom
/// \param    ram: Memoria ram
///
CPUTestbench::CPUTestbench(
    RAM *ram):
    
    ram(ram) {
}


/// ----------------------------------------------------------------------
/// \brief    Executa la simulacio.
///
void CPUTestbench::run() {

    std::string traceFileName(TRACE_FILE_NAME);
	
    Vtop *top = getTop();
    top->i_Clock = 0;
    top->i_Reset = 0;

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
                top->i_Clock = 0;
            else if ((tick % 10) == 5) 
                top->i_Clock = 1;
        }

        // Genera la senyal de 'rst'
        //
        if (tick == CLOCK_RST_CLR)
            top->i_Reset = 0;
        else if (tick == CLOCK_RST_SET)
            top->i_Reset = 1;
		
        // Acces a la RAM
        //
        top->i_MemRdData = ram->read32(top->o_MemAddr);
        if (top->o_MemWrEnable) 
            ram->write32(top->o_MemAddr, top->o_MemWrData);
        
        // Desensambla l'instruccio actual
        //        
        if (((tick % 10) == 0) && (top->i_Clock == 0) && (top->i_Reset == 0)) 
            disassembly(top->o_DbgPgmAddr, top->o_DbgPgmInst);

    } while (nextTick() && (tick < CLOCK_MAX));
    
    closeTrace();
    
    writeConsole("*** End simulation loop.\n");
    writeConsole("    --Total simulation time: " + std::to_string(getTickCount()) + " ticks.\n");
   
    writeConsole("*** RAM dump start.\n");
    ram->dump(0, 32);
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
        
    RAM *ram = new RAM();

    CPUTestbench *tb = new CPUTestbench(ram);
    tb->run();   
    delete tb;
    
    delete ram;
    
    return 0;
}
