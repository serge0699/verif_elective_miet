module bin_to_onehot(
    input   logic [5:0]bin,
    output  logic [63:0]onehot
);
always_comb begin
    onehot = 64'b0; 
    onehot[bin] = 1'b1; 
end
endmodule