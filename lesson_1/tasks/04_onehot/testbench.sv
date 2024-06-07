`timescale 1ns/1ps

module testbench;

    // 5-битный входной сигнал
    logic [5:0] bin;
    event ev;

    // TODO:
    // Определите разрядность выходного
    // one-hot сигнала
    logic [63:0] onehot;
    logic [63:0] onehot_tb;

    // Тестируемый модуль: one-hot кодировщик
    // Соответствие выхода входу:
    // bin =  0 | onehot = 0...001
    // bin =  1 | onehot = 0...010
    // bin =  2 | onehot = 0...100
    // ...
    // bin = 63 | onehot = 1...000
    bin_to_onehot DUT (
        .bin  ( bin  ),
        .onehot ( onehot )
    );

    `include "checker.svh"

    // TODO:
    // Сгенерируйте все возможные входные воздействия и проверки.
    // Как думаете, есть ли способ компактнее, чем copy-paste?
    initial begin
	bin = 6'b1;
	for ( int i = 0; i <= 64; i++ ) begin
                bin = bin + 1; #1ns;
                #1; ->> ev;
                //break;
        end
	$stop();
    end

    // В конце симуляции будет выведена статистика о том, какая
    // часть из требуемых значений была подана. Для оценки того,
    // значения из какого интервала не были поданы, воспользуйтесь
    // отчетом 04_onehot/stats/covsummary.html (отчет сформируется
    // после завершения симуляции).

    // Пишите внутри этого блока. Можно использовать подход из
    // нескольких initial, можно из одного. 
    //------------------------------------------------------------
    initial begin
        while(1) begin
            @ev;
	    onehot_tb = 64'b1 <<  bin;
            if(onehot_tb !== onehot)begin
		 $error("BAD");
		 $display("bin = %d",bin ," onehot: %h ", onehot," onehot_tb: %h ", onehot_tb);
            end
        end
    end
    //------------------------------------------------------------

endmodule
