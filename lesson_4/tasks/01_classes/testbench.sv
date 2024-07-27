module testbench;


    // TODO:
    //
    // Создайте поля:
    //   - bit [7:0] a
    //   - bit [7:0] b
    //
    // Опишите ограничения такие, что:
    //   1) 'b' больше 0
    //   2) 'a' делится на 'b' без остатка
    //   3) 'a' больше 'b'
    //   4) сумма 'a' и 'b' больше 100

    class my_class_1;
        rand bit [7:0] a;
        rand bit [7:0] b;

        constraint constr {
            b > 0;
            a % b == 0;
            a > b;
            a + b > 100;
        }
    endclass


    // TODO:
    //
    // Создайте поля:
    //   - bit [7:0] a
    //   - bit [7:0] b
    //
    // Опишите ограничения такие, что:
    //   1) если 'a' равно нулю, то 'b' равно 100
    //   2) 'a' меньше 100
    //   3) 'b' больше 50


    class my_class_2;
        rand bit [7:0] a;
        rand bit [7:0] b;

        constraint constr {
            a == 0 -> b == 100;
            a < 100;
            b > 50;
        }
    endclass


    // TODO:
    //
    // Создайте поля:
    //   - int data []
    //
    // Опишите ограничения такие, что:
    //   1) размер массива четный
    //   2) размер массива меньше 10
    //   3) каждый элемент массива меньше 200
    //   4) если индекс элемента четный - элемент тоже четный

    class my_class_3;
        rand int data[];
        constraint constr {
            data.size() % 2 == 0;
            data.size() < 10;
            foreach (data[i]) {
                data[i] < 200;
                if(i % 2 == 0) {
                    data[i] % 2 == 0;
                }
            }
        }
    endclass


    // TODO:
    //
    // Создайте поля:
    //   - bit [1:0] size;
    //   - bit [7:0] data [];
    //
    // Опишите ограничения такие, что:
    //   1) размер 'data' равен 'size'
    //   2) если 'size' равен 3, то все элементы 'data' равны 0,
    //      иначе каждый элемент 'data' уникален

    class my_class_4;
        rand bit [1:0] size;
        rand bit [7:0] data [];

        constraint constr {
            data.size() == size;
            if(size == 3) {
                foreach (data[i]) {
                    data[i] == 0;
                }
            } else {
                unique {data};
            }

        }
    endclass


    // TODO:
    //
    // Создайте поля:
    //   - bit [7:0] data;
    //   - bit [7:0] addr;
    //   - bit req;
    //   - bit we;
    //
    // Опишите ограничения такие, что:
    //   1) адрес выровнен по границе 4 байт (последние 2 бита равны 0)
    //   2) если 'req' равен 1, то 'data' в интервале от 100 до 200
    //   3) если 'req' и 'we' равны 1, то 'addr' меньше 128

    class my_class_5;
    rand bit [7:0] data;
    rand bit [7:0] addr;
    rand bit req;
    rand bit we;

    constraint constr {
        addr[1:0] == 2'b00;
        req -> data inside {[100:200]};
        (req && we) -> addr < 128;
    }

    endclass


    // TODO:
    //
    // Создайте поля:
    //   - bit [31:0] tdata  [];
    //   - bit        tid;
    //   - bit        tlast [];
    //
    // Опишите ограничения такие, что:
    //   1) размер 'tdata' равен размеру 'tlast'
    //   2) размеры 'tdata' и 'tlast' меньше 33
    //   3) размеры 'tdata' и 'tlast' кратны 8
    //   4) 'tlast', равный 1, появляется в массиве не
    //      чаще, чем раз в 4 значения

    class my_class_6;
        rand bit [31:0] tdata  [];
        rand bit        tid;
        rand bit        tlast [];

        constraint tlast_c {
            tdata.size() == tlast.size();
            tdata.size() < 33;
            tdata.size() % 8 == 0;

            // // Lazy implementation v1.0
            // foreach(tlast[i]) {
            //     if(tlast[i] == 1 && ~(i inside {tlast.size()-1, tlast.size()-2, tlast.size()-3})) {
            //         tlast[i+1] == 0;
            //         tlast[i+2] == 0;
            //         tlast[i+3] == 0;
            //     }
            //     else if(tlast[i] == 1 && i == tlast.size()-3 && {tlast[i-3], tlast[i-2], tlast[i-1]} == 3'b0) {
            //         tlast[i+1] == 0;
            //         tlast[i+2] == 0;
            //     }
            //     else if(tlast[i] == 1 && i == tlast.size()-2 && {tlast[i-3], tlast[i-2], tlast[i-1]} == 3'b0) {
            //         tlast[i+1] == 0;
            //     }
            // }

            // "Elegant" implementation v1.1
            foreach(tlast[i]) {
                if(tlast[i]) {
                    if      (tlast.size() - i > 3 ) {tlast[i+1], tlast[i+2], tlast[i+3]} == '0;
                    else if (tlast.size() - i == 3) {tlast[i+1], tlast[i+2]}             == '0;
                    else if (tlast.size() - i == 2) {tlast[i+1]}                         == '0;
                }
            }
        }
    endclass

    `include "checker.svh"

endmodule
