#include "sim.h"


void disassembly(unsigned addr, unsigned data) {
    
    // Instruccio LIT
    //
    if ((data & 0x8000) == 0x8000)
        VL_PRINTF("%4.4X LIT    %4.4X d+\n", addr, data & 0x7FFF);
    
    // Instruccio JMP
    //
    else if ((data & 0xE000) == 0x0000)
        VL_PRINTF("%4.4X JMP    %4.4X\n", addr, data & 0x0FFF);
        
    // Instruccio BRZ
    //
    else if ((data & 0xE000) == 0x2000)
        VL_PRINTF("%4.4X BRZ    %4.4X\n", addr, data & 0x0FFF);
        
    // Instruccio JSR
    //
    else if ((data & 0xE000) == 0x4000)
        VL_PRINTF("%4.4X JSR    %4.4X       PC->R\n", addr, data & 0x0FFF);
   
    // Instruccio DO
    //    
    else if ((data & 0xE000) == 0x6000) { 
        VL_PRINTF("%4.4X DO     ", addr);
        switch (data & 0x0F00) {
            case 0x0000:
                VL_PRINTF("T   ");
                break;
                
            case 0x0100:
                VL_PRINTF("N   ");
                break;
                
            case 0x0200:
                VL_PRINTF("T+N ");
                break;
                
            case 0x0300:
                VL_PRINTF("T&N ");
                break;
                
            case 0x0400:
                VL_PRINTF("T|N ");
                break;
                
            case 0x0500:
                VL_PRINTF("T^N ");
                break;

            case 0x0600:
                VL_PRINTF("~T  ");
                break;
                
            case 0x0700:
                VL_PRINTF("T=N ");
                break;
                
            case 0x0800:
                VL_PRINTF("T>N ");
                break;
                
            case 0x0900:
                VL_PRINTF("N<<T");
                break;
                
            case 0x0A00:
                VL_PRINTF("A-1 ");
                break;
                
            case 0x0B00:
                VL_PRINTF("N>>T");
                break;
                
            case 0x0C00:
                VL_PRINTF("0   ");
                break;
                
            case 0x0D00:
                VL_PRINTF("0   ");
                break;
                
            case 0x0E00:
                VL_PRINTF("0   ");
                break;
                
            case 0x0F00:
                VL_PRINTF("0   ");
                break;
        }
        
        switch (data & 0x0003) {
                case 0x0000:
                    VL_PRINTF("   ");
                    break;
                    
                case 0x0001:
                    VL_PRINTF(" d+");
                    break;
                    
                case 0x0002:
                    VL_PRINTF("   ");
                    break;
                    
                case 0x0003:
                    VL_PRINTF(" d-");
                    break;
        }

        switch (data & 0x000C) {
                case 0x0004:
                    VL_PRINTF("   ");
                    break;
                    
                case 0x0006:
                    VL_PRINTF(" r+");
                    break;
                    
                case 0x0008:
                    VL_PRINTF("   ");
                    break;
                    
                case 0x000C:
                    VL_PRINTF(" r-");
                    break;
        }
        
        if (data & 0x1000)
            VL_PRINTF(" R->PC");
        else
            VL_PRINTF("      ");
        
        switch (data & 0x0070) {
            case 0x0010:
                VL_PRINTF(" T->N  ");
                break;

            case 0x0020:
                VL_PRINTF(" T->R  ");
                break;
            
            case 0x0030:
                VL_PRINTF(" R->[T]");
                break;
        }
        
        VL_PRINTF("\n");
    }
}