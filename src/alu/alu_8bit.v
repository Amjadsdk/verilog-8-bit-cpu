module alu_8bit (
    input   [7:0] A,
    input   [7:0] B,
    input   [2:0] op,
    output  [7:0] S,
    output reg Co
);

    wire    [7:0] add_result;
    wire    [7:0] sub_result;
    wire    [7:0] and_result;
    wire    [7:0] or_result;
    wire    [7:0] xor_result;
    wire    [7:0] sl_result;
    wire    [7:0] sr_result;
    wire    [7:0] eq_result;

    wire carry_add;
    ripple_adder ra0 (
        .A(A),
        .B(B),
        .Ci(1'b0),
        .S(add_result),
        .Co(carry_add)
    );

    wire carry_sub;
    ripple_adder ra1 (
        .A(A),
        .B(~B),
        .Ci(1'b1),
        .S(sub_result),
        .Co(carry_sub)
    );

    and_circuit and0 (
        .A(A),
        .B(B),
        .S(and_result)
    );

    or_circuit or0 (
        .A(A),
        .B(B),
        .S(or_result)
    );

    xor_circuit xor0 (
        .A(A),
        .B(B),
        .S(xor_result)
    );

    sl_circuit sl0 (
        .A(A),
        .S(sl_result)
    );

    sr_circuit sr0(
        .A(A),
        .S(sr_result)
    );

    eq_circuit eq0 (
        .A(A),
        .B(B),
        .S(eq_result)
    );

    reg    [7:0] res;
    always @(*) begin
        case (op)
            3'b000: begin res = add_result;
                    Co = carry_add; end
            3'b001: begin res = sub_result;
                    Co = carry_sub; end
            3'b010: begin res = and_result;
                    Co = 1'b0; end
            3'b011: begin res = or_result;
                    Co = 1'b0; end
            3'b100: begin res = xor_result;
                    Co = 1'b0; end
            3'b101: begin res = sl_result;
                    Co = 1'b0; end
            3'b110: begin res = sr_result;
                    Co = 1'b0; end
            3'b111: begin res = eq_result;
                    Co = 1'b0; end
            default: begin res = 8'b00000000;
                    Co = 1'b0; end
        endcase
    end

    assign S = res;
    
endmodule

module full_adder (
    input   A, 
    input   B, 
    input   Ci, 
    output  S, 
    output  Co
);

    assign S = A ^ B ^ Ci;
    assign Co = (A & B) | (Ci &(A ^ B));

endmodule

// ripple_adder will be used for adder and subtractor
module ripple_adder (
    input [7:0] A,
    input [7:0] B,
    input Ci,
    output Co,
    output [7:0] S
);

    wire [7:0] carry;

    // call full adder 8 times
    full_adder fa0 (
        .A(A[0]),
        .B(B[0]),
        .Ci(Ci),
        .S(S[0]),
        .Co(carry[0])
    );

    full_adder fa1 (
        .A(A[1]),
        .B(B[1]),
        .Ci(carry[0]),
        .S(S[1]),
        .Co(carry[1])
    );

    full_adder fa2 (
        .A(A[2]),
        .B(B[2]),
        .Ci(carry[1]),
        .S(S[2]),
        .Co(carry[2])
    );

    full_adder fa3 (
        .A(A[3]),
        .B(B[3]),
        .Ci(carry[2]),
        .S(S[3]),
        .Co(carry[3])
    );

    full_adder fa4 (
        .A(A[4]),
        .B(B[4]),
        .Ci(carry[3]),
        .S(S[4]),
        .Co(carry[4])
    );

    full_adder fa5 (
        .A(A[5]),
        .B(B[5]),
        .Ci(carry[4]),
        .S(S[5]),
        .Co(carry[5])
    );

    full_adder fa6 (
        .A(A[6]),
        .B(B[6]),
        .Ci(carry[5]),
        .S(S[6]),
        .Co(carry[6])
    );

    full_adder fa7 (
        .A(A[7]),
        .B(B[7]),
        .Ci(carry[6]),
        .S(S[7]),
        .Co(carry[7])
    );

    assign Co = carry[7];

endmodule

module and_circuit (
    input   [7:0] A,
    input   [7:0] B,
    output  [7:0] S
);

    assign S = A & B;
    
endmodule

module or_circuit (
    input   [7:0] A,
    input   [7:0] B,
    output  [7:0] S
);

    assign S = A | B;
    
endmodule

module xor_circuit (
    input   [7:0] A,
    input   [7:0] B,
    output  [7:0] S
);

    assign S = A ^ B;
    
endmodule

module sl_circuit (
    input   [7:0] A,
    output  [7:0] S
);

    assign S = A  << 1;
    
endmodule

module sr_circuit (
    input   [7:0] A,
    output  [7:0] S
);

    assign S = A  >> 1;
    
endmodule

module eq_circuit (
    input   [7:0] A,
    input   [7:0] B,
    output  [7:0] S
);

wire [7:0] result;
assign result[0] = A[0] ~^ B[0];
assign result[1] = A[1] ~^ B[1];
assign result[2] = A[2] ~^ B[2];
assign result[3] = A[3] ~^ B[3];
assign result[4] = A[4] ~^ B[4];
assign result[5] = A[5] ~^ B[5];
assign result[6] = A[6] ~^ B[6];
assign result[7] = A[7] ~^ B[7];

assign S[0] = result[0] & result[1] & result[2] & result[3] & result[4] & result[5] & result[6] & result[7];
assign S[7:1] = 7'b0000000;

endmodule