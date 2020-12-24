#include "sim.h"
#include "RISCV.h"
#include "RISCVMemory.h"


#define PIPELINE


#ifdef PIPELINE
    #define TRACE_FILE_NAME "waves_pp/trace.fst"
#else
    #define TRACE_FILE_NAME "waves_sc/trace.fst"
#endif


// Els temps son en ticks de simulacio (simTime). Per que sigui totalment
// asincron, els temps d'activacio o desactivacio no poden ser multiples
// de 10, ja que el temp del sistems (clock) es cada 10 ticks del temps
// de simulacio (simTime)
//
#define CLOCK_MAX            1000  // Nombre de ticks a simular
#define CLOCK_START             0  // Tick per iniciar clk
#define CLOCK_TICKS            10  // Tics per cicle clk

#define CLOCK_RST_SET           0  // Tic per iniciar el reset
#define CLOCK_RST_CLR           7  // Tic per acabar el reset


using namespace Simulation;


class CPUTestbench: public Testbench<Vtop, VerilatedFstC> {

    private:
        RISCV::Memory *dataMem;

    public:
        CPUTestbench(RISCV::Memory *dataMem);
        void run();
};


/// ----------------------------------------------------------------------
/// \bried    Contructor de l'objecte
/// \param    rom: Memoria rom
/// \param    ram: Memoria ram
///
CPUTestbench::CPUTestbench(
    RISCV::Memory *dataMem):

    dataMem(dataMem) {
}


/// ----------------------------------------------------------------------
/// \brief    Executa la simulacio.
///
void CPUTestbench::run() {

    std::string traceFileName(TRACE_FILE_NAME);

    Vtop *top = getTop();

    bool clockPosEdge = false;
    top->i_clock = 0;
    top->i_reset = 0;

    openTrace(traceFileName);

    unsigned tick;
    do {
        tick = getTickCount();

        // Genera la senyal 'clock'
        //
        if (tick >= CLOCK_START) {
            if ((tick % 10) == 0)
                top->i_clock = 0;
            else if ((tick % 10) == 5) {
                top->i_clock = 1;
                clockPosEdge = true;
            }
        }

        // Genera la senyal de 'reset'
        //
        if (tick == CLOCK_RST_CLR)
            top->i_reset = 0;
        else if (tick == CLOCK_RST_SET)
            top->i_reset = 1;

        // Acces a la memoria de dades
        //
        top->i_memRdData = dataMem->read32(top->o_memAddr);
        if (clockPosEdge && (top->o_memWrEnable == 1)) {
            if (top->o_memAddr >= 0x00200000) {

                // Periferics
                //
                switch (top->o_memAddr) {
                    case 0x00200000:
                        printf("TTY: %c\n", (char)top->o_memWrData);
                        break;
                }
            }
            else {

                // Memoria ram
                //
                switch (top->o_memAccess) {
                    case 0b000:
                        dataMem->write8(top->o_memAddr, top->o_memWrData);
                        break;

                    case 0b001:
                        dataMem->write16(top->o_memAddr, top->o_memWrData);
                        break;

                    case 0b010:
                        dataMem->write32(top->o_memAddr, top->o_memWrData);
                        break;
                }
            }
        }

        clockPosEdge = false;

    } while (nextTick() && (tick < CLOCK_MAX));

    closeTrace();
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

    printf("RISCV RTL simulator V1.0\n\n");

    RISCV::Memory *dataMem = new RISCV::Memory(nullptr, RISCV_DMEM_BASE, RISCV_DMEM_SIZE);
    if (dataMem) {

        CPUTestbench *tb = new CPUTestbench(dataMem);
        if (tb) {
            tb->run();
            delete tb;
        }

        printf("Data memory dump\n");
        dataMem->dump(RISCV_DMEM_BASE, 128);
        printf("\n");

        delete dataMem;
    }

    return 0;
}
