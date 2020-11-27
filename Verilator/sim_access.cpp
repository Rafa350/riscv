#include "sim.h"
#include "Vverilator_top.h"
#include "Vverilator_top_top.h"
#include "Vverilator_top_ProcessorPP__Aa_Pa.h"



CPUAccess::CPUAccess(
    Vtop* top):
    top(top) {
        
    cpu = top->top->CPU;
}


uint32_t CPUAccess::getIFID_PC() const {
    
    return cpu->getIFID_PC();
}


uint32_t CPUAccess::getIFID_Inst() const {
    
    return cpu->getIFID_Inst();
}


uint32_t CPUAccess::getIDEX_OP() const {
    
    return cpu->getIDEX_InstOP();
}


uint32_t CPUAccess::getIDEX_RS1() const {
    
    return cpu->getIDEX_InstRS1();
}


uint32_t CPUAccess::getIDEX_RS2() const {
    
    return cpu->getIDEX_InstRS2();
}


uint32_t CPUAccess::getIDEX_IMM() const {
    
    return cpu->getIDEX_InstIMM();
}


uint32_t CPUAccess::getIDEX_DataA() const {
    
    return cpu->getIDEX_DataA();
}


uint32_t CPUAccess::getIDEX_DataB() const {
    
    return cpu->getIDEX_DataB();
}


uint32_t CPUAccess::getIDEX_RegWrAddr() const {
    
    return cpu->getIDEX_RegWrAddr();
}


uint32_t CPUAccess::getIDEX_RegWrEnable() const {
    
    return cpu->getIDEX_RegWrEnable();
}


uint32_t CPUAccess::getIDEX_RegWrDataSel() const {
    
    return cpu->getIDEX_RegWrDataSel();
}


uint32_t CPUAccess::getEXMEM_RegWrAddr() const {
    
    return cpu->getEXMEM_RegWrAddr();
}


uint32_t CPUAccess::getEXMEM_RegWrEnable() const {
    
    return cpu->getEXMEM_RegWrEnable();
}


uint32_t CPUAccess::getEXMEM_RegWrDataSel() const {
    
    return cpu->getEXMEM_RegWrDataSel();
}
