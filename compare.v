// Aws Hammad - 1221697	- sec 2	

///////////////////////////////////////////////////////6-BIT-COMPARATOR//////////////////////////////////////////////////////////////////////
module comparator6bits_struct (clk,A,B,S,Equal,Greater,Smaller);
	input wire clk,S;// the clock and the selecter between signed/unsigned
  	input wire [5:0] A,B;// 6-bits inputs A,B
    output reg Equal,Greater,Smaller;// registers to have the outputs
    reg [5:0] A_reg,B_reg;// registers to have inputs
    reg S_reg;												   
    wire Equal_signed, Greater_signed, Smaller_signed;// for the last signed result
    wire Equal_unsigned, Greater_unsigned, Smaller_unsigned;
    // put the inputs in registers to make the circuit synchronous
    always @(posedge clk) begin
        A_reg <= A;
        B_reg <= B;
        S_reg <= S;
    end
    wire gt_2, eq_2, lt_2; // for bits [1:0]
    wire gt_4, eq_4, lt_4; // for bits [3:2]
    wire gt_6, eq_6, lt_6; // for bits [5:4]
    // compare bits [1:0]
  	comparator2bits c0(A_reg[1:0],B_reg[1:0],1'b0,1'b1,1'b0,gt_2,eq_2,lt_2);
    // compare bits [3:2]
  	comparator2bits c1(A_reg[3:2],B_reg[3:2],gt_2,eq_2,lt_2,gt_4,eq_4,lt_4);
    // compare bits [5:4]
    comparator2bits c2(A_reg[5:4],B_reg[5:4],gt_4,eq_4,lt_4,gt_6,eq_6,lt_6);
    wire msb_diff; // to see if the MSB of A and B are different
    xor #9 (msb_diff,A_reg[5],B_reg[5]);
	mux2x1 Equal_mux(.d0(eq_6), .d1(1'b0), .sel(msb_diff), .y(Equal_signed));// if MSBs are different select 1'b0 otherwise eq_6
	mux2x1 Greater_msb_mux(.d0(gt_6), .d1(~A_reg[5]), .sel(msb_diff), .y(Greater_signed));// if MSBs different select ~A_reg[5] otherwise gt_6
	mux2x1 Smaller_msb_mux(.d0(lt_6), .d1(A_reg[5]), .sel(msb_diff), .y(Smaller_signed));// if MSBs different select A_reg[5] otherwise lt_6
    // unsigned compare
    assign Equal_unsigned = eq_6;
    assign Greater_unsigned = gt_6;
    assign Smaller_unsigned = lt_6;
    // to select between signed and unsigned results according to S
    wire Equal_result, Greater_result, Smaller_result;
    mux2x1 Equality_mux(Equal_unsigned, Equal_signed, S_reg, Equal_result);
    mux2x1 Greater_mux(Greater_unsigned, Greater_signed, S_reg, Greater_result);
    mux2x1 Smaller_mux(Smaller_unsigned, Smaller_signed, S_reg, Smaller_result);
    // put the outputs in registers to make the circuit synchronous
    always @(posedge clk) begin
        Equal <= Equal_result;
        Greater <= Greater_result;
        Smaller <= Smaller_result;
    end
endmodule

///////////////////////////////////////////////////////////////2x1 Multiplexer///////////////////////////////////////////////////////////////////////////////////
module mux2x1(input wire d0, input wire d1, input wire sel, output wire y);
    wire not_sel;
    wire and0, and1;
    not #2 (not_sel, sel);
    and #6 (and0, d0, not_sel);
    and #6 (and1, d1, sel);
    or #6 (y, and0, and1); 
endmodule						 

///////////////////////////////////////////////////////////////2-BIT-COMPARATOR/////////////////////////////////////////////////////////////////////////////

module comparator2bits(a, b, Gt_I, Eq_I, Lt_I, Gt_O, Eq_O, Lt_O);
    input [1:0] a, b; // 2-bit inputs to compare
    input Gt_I, Eq_I, Lt_I; // inputs to compare multi-bit numbers
    output Gt_O, Eq_O, Lt_O; // outputs of the comparison 
    wire not_a1, not_b1, not_a0, not_b0; // to have ~(inputs)
    wire a1_and_not_b1, not_a1_and_b1; // to compare the MSB
    wire a0_and_not_b0, not_a0_and_b0; // to compare the LSB
    wire a1_eq_b1, a0_eq_b0; // if MSB or LSB are eqaul	for a,b
    wire a_gt_b, a_lt_b, a_eq_b; // comparison results
    wire a1_eq_b1_and_a0_gt_b0, a1_eq_b1_and_a0_lt_b0; // logic to help us in the comparison
    wire a_eq_b_and_gt_i, a_eq_b_and_lt_i; // logic for multi-bit numbers
    // to have the inverse of the inputs
    not #2 (not_a1, a[1]);
    not #2 (not_b1, b[1]);
    not #2 (not_a0, a[0]);
    not #2 (not_b0, b[0]);
    // for greater and less comparisons (using AND gates with 6 delay)
    and #6 (a1_and_not_b1, a[1], not_b1); // a[1] > b[1]
    and #6 (not_a1_and_b1, not_a1, b[1]); // a[1] < b[1]
    and #6 (a0_and_not_b0, a[0], not_b0); // a[0] > b[0]
    and #6 (not_a0_and_b0, not_a0, b[0]); // a[0] < b[0]
    // for equality comparisons	(using XNOR gates with 8 delay)
    xnor #8 (a1_eq_b1, a[1], b[1]); // a[1] == b[1]
    xnor #8 (a0_eq_b0, a[0], b[0]); // a[0] == b[0]
    // greater logic (using OR gates with 6 delay)
    and #6 (a1_eq_b1_and_a0_gt_b0, a1_eq_b1, a0_and_not_b0); // a[1:0] > b[1:0]
    or #6 (a_gt_b, a1_and_not_b1, a1_eq_b1_and_a0_gt_b0); // a > b
    // less logic
    and #6 (a1_eq_b1_and_a0_lt_b0, a1_eq_b1, not_a0_and_b0); // a[1:0] < b[1:0]
    or #6 (a_lt_b, not_a1_and_b1, a1_eq_b1_and_a0_lt_b0); // a < b
    // equality logic
    and #6 (a_eq_b, a1_eq_b1, a0_eq_b0); // a[1:0] == b[1:0]
    // for multi-bits inputs
    and #6 (a_eq_b_and_gt_i, a_eq_b, Gt_I); // equality and greater
    and #6 (a_eq_b_and_lt_i, a_eq_b, Lt_I); // equality and less
    // final results
    or #6 (Gt_O, a_gt_b, a_eq_b_and_gt_i); // final greater output
    or #6 (Lt_O, a_lt_b, a_eq_b_and_lt_i); // final less output
    and #6 (Eq_O, a_eq_b, Eq_I); // final equality output
endmodule


///////////////////////////////////////////////////////BEHAVIOURAL//////////////////////////////////////////////////////////////////////////////

module comparator6bits_behav (clk, A, B, S, Equal, Greater, Smaller, result_uns, result_sig);
    input wire clk, S;// the clock and the selecter between signed/unsigned
    input wire [5:0] A, B;// 6-bits inputs A,B
    output reg Equal, Greater, Smaller;// registers to have the outputs
    output reg [5:0] result_uns;// the result of the unsigned subtraction
    output reg signed [5:0] result_sig;// the result of the signed subtraction 
    // registers to have inputs
    reg [5:0] A_reg;                        
    reg [5:0] B_reg;                        
    reg S_reg;                              
    wire [6:0] uns_sub;// for the unsigned result subtraction and the 7th bit is for the borrow
    wire signed [5:0] sig_result;// for the signed result subtraction
    wire signed [5:0] sig_A;// signed A
    wire signed [5:0] sig_B;// signed B
    // put the inputs in the registers to make the circuit synchronous
    always @(posedge clk) begin
        A_reg <= A;
        B_reg <= B; 
        S_reg <= S; 
    end
    // compute the unsigned and signed subtraction
    assign uns_sub = {1'b0, A_reg} - {1'b0, B_reg};// the unsigned subtraction with borrow
    assign sig_A = $signed(A_reg);// convert A to signed for signed subtraction
    assign sig_B = $signed(B_reg);// convert B to signed for signed subtraction
    assign sig_result = sig_A - sig_B;// signed subtraction
    always @(posedge clk) begin
        // put subtraction results in registers	for signed and unsigned
        result_uns <= uns_sub[5:0];
        result_sig <= sig_result;
        // compare by the selection
        if (S_reg) begin // if s==1 then do signed comparison
            Equal <= (sig_A == sig_B);// A == B
            Greater <= (sig_A > sig_B);// A > B 
            Smaller <= (sig_A < sig_B);// A < B 
        end else begin
            // if s==0 then do unsigned comparison
            Equal <= (uns_sub[5:0] == 0);// A == B 
            Greater <= (!uns_sub[6]) && (uns_sub[5:0] != 0);// A > B
            Smaller <= uns_sub[6];// A < B
        end
    end
endmodule
				   

///////////////////////////////////////////////////////TESTBENCH/////////////////////////////////////////////////////////////////////////////

module TB;
    // inputs for the testbench
    reg clk; // clock 
    reg [5:0] A; // 6-bit input A
    reg [5:0] B; // 6-bit input B
    reg S; // selector to select signed or unsigned
    // outputs
    wire behav_eq;// equality for behavioral 
    wire behav_gr;// greater for behavioral 
    wire behav_sm;// smaller for behavioral 
    wire [5:0] behav_uns;// unsigned subtraction result for behavioral 
    wire signed [5:0] behav_si;// signed subtraction result for behavioral 
    wire str_eq;// equality for structural 
    wire str_gr;// greater for structural 
    wire str_sm;// smaller for structural 
    // instance of the behavioral module
    comparator6bits_behav c1 (clk, A, B, S, behav_eq, behav_gr, behav_sm, behav_uns, behav_si); 
    // instance the structural module
    comparator6bits_struct c2 (clk, A, B, S, str_eq, str_gr, str_sm); 
    initial begin
        clk = 0;// make the clock = 0
        forever #16 clk = ~clk;// invert clock every 16 time units
    end
    // task to test the modules
    task testing;
        input [5:0] A;// input A for testing
        input [5:0] B;// input B for testing
        input S;// for signed or unsigned mode
        begin
            $display("Testing A=%b, B=%b, S=%b", A, B, S);// display inputs
            $display("Behavioral -> Equal=%b, Greater=%b, Smaller=%b, Unsigned Result=%b, Signed Result=%d", 
                     behav_eq, behav_gr, behav_sm, behav_uns, behav_si);// display behavioral results
            $display("Structural -> Equal=%b, Greater=%b, Smaller=%b", str_eq, str_gr, str_sm);// display structural results
            if (behav_eq !== str_eq || behav_gr !== str_gr || behav_sm !== str_sm) begin
                $display("FAIL : Mismatch detected!");// display FAIL if outputs does not equal
            end else begin
                $display("PASS : Behavioral and Structural outputs are identical.");// display PASS if outputs are equal
            end
            $display("------------------------");
        end
    endtask

    // testing
    integer i, j;// for the loop
    initial begin
        #32; // wait for first reset
        // loop through ALL possible values for A and B
        for (i = 0; i < 64; i = i + 1) begin // 2^6 = 64 possible value for each A and B
            for (j = 0; j < 64; j = j + 1) begin
                A = i[5:0]; // give a 6-bit value to A
                B = j[5:0]; // give a 6-bit value to B
                // test for unsigned 
                S = 0; // set to unsigned 
                #128 testing(A, B, S); // call the testing task
                // test for signed 
                S = 1; // set to signed 
                #128 testing(A, B, S); // call the testing task
            end
        end
        $stop; // stop simulation
    end
endmodule
