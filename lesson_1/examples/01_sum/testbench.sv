module testbench;

    logic [7:0] A;
    logic [7:0] B;
    logic [7:0] C;

    sum DUT(
        .a ( A ),
        .b ( B ),
        .c ( C )
    );

    initial begin

        A = 2;
        B = 3;

        #20ns;
        if(C !== 3) $error("BAD");
        $stop();

    end

endmodule
