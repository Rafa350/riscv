#include "sim.h"


static uint8_t data[1024];        // La regio de memoria en bytes


/// ----------------------------------------------------------------------
/// \brief    Constructor
///
RAM::RAM():
    Simulation::Memory(data, sizeof(data) / sizeof(data[0])) {
    
    for (unsigned i = 0; i < getSize(); i++)
        data[i] = uint8_t(i);
}