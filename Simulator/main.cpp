#include <iostream>
#include "RISCVSim.h"
#include "RISCVTracer.h"


using namespace std;


int main() {

    cout << "RISCV Behavorial simulator V1.0\n";

    RISCVTracer *tracer = new RISCVTracer();
    if (tracer) {

        RISCVSim *sim = new RISCVSim(tracer);
        if (sim) {

            delete sim;
        }

        delete tracer;
    }

    return 0;
}