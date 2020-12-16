#include "sim.h"


static uint8_t data[1024];        // La regio de memoria en bytes


/// ----------------------------------------------------------------------
/// \brief    Constructor
///
RAM::RAM():
    Simulation::Memory(data, sizeof(data) / sizeof(data[0])) {

    memset(data, 0, getSize());
}