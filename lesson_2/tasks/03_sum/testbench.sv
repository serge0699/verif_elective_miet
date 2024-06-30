module testbench;

    // Тактовый сигнал и сигнал сброса
    logic clk;
    logic aresetn;

    // Остальные сигналы
    logic [7:0] A;
    logic [7:0] B;
    logic [7:0] C;

    sum DUT (
        .clk     ( clk     ),
        .aresetn ( aresetn ),
        .a       ( A       ),
        .b       ( B       ),
        .c       ( C       )
    );

    // TODO:
    // Определите период тактового сигнала
    parameter CLK_PERIOD = 10; // ?;

    // TODO:
    // Cгенерируйте тактовый сигнал
    initial begin
        clk <= 0;
        forever begin
            // Пишите тут.
            #(CLK_PERIOD) clk = ~clk;
        end
    end
    
    // Генерация сигнала сброса
    initial begin
        aresetn <= 0;
        #(CLK_PERIOD);
        aresetn <= 1;
    end

    // TODO:
    // Cгенерируйте входные воздействия и проверки
    // в соответствии с диаграммой.

    //                |10ns-|
    //           __   |__   |__    __    __    __    __
    // clk     _|  |__|  |__|  |__|  |__|  |__|  |__|  |__|
    //              __|_____|_____|_____|_____|_____|_____|
    // aresetn ____|  |     |     |     |     |     |     |
    //                |     |     |     |     |     |     |
    // A       <XXXXX>|<2-->|<20--+---->|<4-->|<40->|<2---|
    // B       <XXXXX>|<3-->|<30--+---->|<5-->|<50->|<1---|
    // C       <0---->|<XXX>|<5-->|<50--+---->|<9-->|<90--|
    //                |     |     |     |
    //               15ns  25ns  35ns  45ns ...

    initial begin
        // Входные воздействия опишите здесь.
        // Не забудьте про ожидание сигнала сброса!
        wait(aresetn);
        @(posedge clk);
        A <= 2;
        B <= 3;
        @(posedge clk);
        A <= 20;
        B <= 30;
        @(posedge clk);
        @(posedge clk);
        A <= 4;
        B <= 5;
        @(posedge clk);
        A <= 40;
        B <= 50;
        @(posedge clk);
        A <= 2;
        B <= 1;
        @(posedge clk);
        @(posedge clk);
        $stop();
    end

    initial begin
        // Проверки опишите здесь.
        // Не забудьте про ожидание сигнала сброса!
        wait(aresetn);
        @(posedge clk);
        // A <= 2;
        // B <= 3;
        @(posedge clk);
        @(posedge clk);
        if(C !== 5)     $display("(%0t) ERR: A = %0d, B = %0d, C = %0d, (C !== 5)", $time(), A, B, C);
        else            $display("(%0t) OK", $time());
        // A <= 20;
        // B <= 30;
        @(posedge clk);
        if(C !== 50)    $display("(%0t) ERR: A = %0d, B = %0d, C = %0d, (C !== 50)", $time(), A, B, C);
        else            $display("(%0t) OK", $time());
        @(posedge clk);
        if(C !== 50)    $display("(%0t) ERR: A = %0d, B = %0d, C = %0d, (C !== 50)", $time(), A, B, C);
        else            $display("(%0t) OK", $time());
        // A <= 4;
        // B <= 5;
        @(posedge clk);
        if(C !== 9)     $display("(%0t) ERR: A = %0d, B = %0d, C = %0d, (C !== 9)", $time(), A, B, C);
        else            $display("(%0t) OK", $time());
        // A <= 40;
        // B <= 50;
        @(posedge clk);
        if(C !== 90)    $display("(%0t) ERR: A = %0d, B = %0d, C = %0d, (C !== 90)", $time(), A, B, C);
        else            $display("(%0t) OK", $time());
        // A <= 2;
        // B <= 1;
        @(posedge clk);
        if(C !== 3) $display("(%0t) ERR: A = %0d, B = %0d, C = %0d, (C !== 3)", $time(), A, B, C);
        else        $display("(%0t) OK", $time());
    end

endmodule
