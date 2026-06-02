module tb_Adder();

    localparam WIDTH = 32

    // Linies de control del modul
    //
    logic [WIDTH-1:0] i_operandA;
    logic [WIDTH-1:0] i_operandB;
    logic i_carry;
    logic [WIDTH-1:0] o_result;
    logic o_carry;
    logic o_overflow;

    // Valors especials per verificar
    //
    logic [WIDTH-1:0] values[] = '{
        '0,   // 0000...0000
        'd1,  // 0000...0001
        '1    // 1111...1111
    };

    // Modul a verificar
    //
    Adder #(
        .WIDTH (WIDTH)
    )
    adder (
        .i_operandA (i_operandA),
        .i_operandB (i_operandB),
        .i_carry    (i_carry),
        .o_result   (o_result),
        .o_carry    (o_carry),
        .o_overflow (o_overflow)
    );
    
    // Fa una suma amb el modul i verifica
    //
    task test_add(
        input logic [WIDTH-1:0] operandA, 
        input logic [WIDTH-1:0] operandB, 
        input logic carry);
        
        logic [WIDTH:0] expected;
        
        begin
        
            expected = operandA + operandB + carry;
        
            i_operandA = operandA;
            i_operandB = operandB;
            i_carry = carry;

            #1;

            assert(o_result == expected[WIDTH-1:0])
                else $fatal(
                    "Result error: A=%h B=%h Cin=%b Expected=%h Got=%h",
                    operandA,
                    operandB,
                    carry,
                    expected[WIDTH-1:0],
                    o_result);            
                    
            assert(o_carry  == expected[WIDTH])             
                else $fatal(
                    "Carry error: A=%h B=%h Cin=%b Expected=%h Got=%h",
                    operandA,
                    operandB,
                    carry,
                    expected[WIDTH],
                    o_result);            
            
        end
        
    endtask
    
    // Testbench
    //
    initial begin
        repeat (1000)
            test_add(
                values[$urandom_range(0, values.size()-1)],
                $urandom(),
                $urandom_range(0, 1));                
        $display("Passed");
        $finish;
    end

endmodule