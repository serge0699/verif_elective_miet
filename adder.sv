module adder (
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [32:0] c
);

    assign c = a + b;

endmodule
