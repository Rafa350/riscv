"c:\program files\MIPS-gcc\bin\mips-mti-elf-as.exe" demo.S -a
"c:\program files\MIPS-gcc\bin\mips-mti-elf-objcopy.exe" --output-target=verilog --only-section=.text a.out a.txt
pause