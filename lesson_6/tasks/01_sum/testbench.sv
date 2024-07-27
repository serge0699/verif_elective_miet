module testbench;

    // Тактовый сигнал и сигнал сброса
    logic clk;
    logic aresetn;

    // Остальные сигналы
    logic [7:0] a;
    logic [7:0] b;
    logic [7:0] c;

    sum DUT(
        .clk     ( clk     ),
        .aresetn ( aresetn ),
        .a       ( a       ),
        .b       ( b       ),
        .c       ( c       )
    );

    `include "generator.svh"

    // TODO:
    // В рамках симуляции значения 'a' и 'b'
    // генерируются согласно некоторым правилам.
    // Напишите модель покрытия, при помощи
    // которой определите, какие значения
    // принимают переменные 'a' и 'b'.

    covergroup sum_cg @(posedge clk);
        // Пишите здесь
        a_cg: coverpoint a {
            bins b1 [] = {[0:$]};
        }
        b_cg: coverpoint b {
            bins b1 [] = {[0:$]};
        }

        // coverpoint a;
        // coverpoint b;
        // options.cover
    endgroup

    sum_cg cg = new();

// a - 67-111
// b - 126-217

endmodule
