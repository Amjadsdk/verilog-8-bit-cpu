module register_file(
    input   [1:0] readA,
    input   [1:0] readB,
    input   [1:0] regW,
    input   [7:0] dataW,
    input writeEnable,
    input clk,
    output  [7:0] dataA,
    output  [7:0] dataB
); 

    wire [7:0] q0;
    wire [7:0] q1;
    wire [7:0] q2;
    wire [7:0] q3;

    wire en0;
    wire en1;
    wire en2;
    wire en3;

    // register enables
    assign en0 = writeEnable & (regW == 2'b00);
    assign en1 = writeEnable & (regW == 2'b01);
    assign en2 = writeEnable & (regW == 2'b10);
    assign en3 = writeEnable & (regW == 2'b11);

    register_8bit R0 (
        .D(dataW),
        .Q(q0),
        .enable(en0),
        .clk(clk)
    );

    register_8bit R1 (
        .D(dataW),
        .Q(q1),
        .enable(en1),
        .clk(clk)
    );

    register_8bit R2 (
        .D(dataW),
        .Q(q2),
        .enable(en2),
        .clk(clk)
    );

    register_8bit R3 (
        .D(dataW),
        .Q(q3),
        .enable(en3),
        .clk(clk)
    );

    reg     [7:0] resA;

    always @(*)
    begin
        case (readA)
            2'b00: resA = q0;
            2'b01: resA = q1;
            2'b10: resA = q2;
            2'b11: resA = q3;
            default: resA = 8'b00000000;
        endcase
    end

    assign dataA = resA;

    reg     [7:0] resB;

    always @(*)
    begin
        case (readB)
            2'b00: resB = q0;
            2'b01: resB = q1;
            2'b10: resB = q2;
            2'b11: resB = q3;
            default: resB = 8'b00000000;
        endcase
    end

    assign dataB = resB;

endmodule