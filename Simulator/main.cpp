#include <iostream>
#include "RISCVSim.h"
#include "RISCVTracer.h"


using namespace std;


int main() {

    cout << "RISCVSim V1.0\n";

    RISCVTracer *tracer = new RISCVTracer();
    RISCVSim *sim = new RISCVSim(tracer);

    delete sim;

    return 0;
}