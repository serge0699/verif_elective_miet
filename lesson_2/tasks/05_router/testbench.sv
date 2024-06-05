module testbench;

    // Тактовый сигнал и сигнал сброса
    logic clk;
    logic aresetn;

    // Остальные сигналы
    logic  [3:0][1:0] sel;
    logic       [3:0] in;
    logic       [3:0] out;
    bit         [3:0] out_ref;
    router DUT(
        .clk     ( clk     ),
        .aresetn ( aresetn ),
        .sel     ( sel     ),
        .in      ( in      ),
        .out     ( out     )
    );

    // TODO:
    // Найдите все ошибки в модуле ~router~

    // TODO:
    // Определите период тактового сигнала
    parameter CLK_PERIOD = 10;

    // TODO:
    // Cгенерируйте тактовый сигнал
    initial begin
        clk <= 0;
        forever begin
           #(CLK_PERIOD) clk = ~clk; 
        end
    end
    
    // TODO:
    // Cгенерируйте сигнал сброса
    initial begin
        aresetn = 0; #10;
        aresetn = 1; 
    end

    // TODO:
    // Сгенерируйте входные сигналы
    // Не забудьте про ожидание сигнала сброса!
    task generate_input(int check, int flag);
        // Входные воздействия опишите здесь.
        wait(aresetn);
        repeat (check) begin
            @(posedge clk);
            in[3:0]     = $urandom_range(0,15);
            sel[0][1:0] = $urandom_range(0,3);
            sel[1][1:0] = $urandom_range(0,3);
            sel[2][1:0] = $urandom_range(0,3);
            sel[3][1:0] = $urandom_range(0,3);#(CLK_PERIOD);
            check = check - 1;
            if(check == 0) flag = 1;
            if(flag) $stop();
        end
    endtask

    // Пользуйтесь этой структурой
    typedef struct {
        logic  [3:0][1:0] sel;
        logic       [3:0] in;
        logic       [3:0] out;
    } packet;

    mailbox#(packet) mon2chk = new();

    task put_pkt();
        packet pkt;
            wait(aresetn);
            forever begin
                @(posedge clk);
                pkt.in  = in;
                pkt.sel = sel;
                pkt.out = out;
                mon2chk.put(pkt);
            end
    endtask

    // TODO:
    // Выполните проверку выходных сигналов
    task check();
        packet pkt_cur;
        wait(aresetn);
        forever begin
            mon2chk.get(pkt_cur);
            // Пишите здесь
            out_ref = 0;
            // $display("%t check  = ",$time);
            // $display(" in  = %d ",pkt_cur.in[3:0]);
            for(int i = 0; i <= 3; i++ ) begin
                out_ref[pkt_cur.sel[i] ] = pkt_cur.in[i];
            // $display(" out_ref  = %d", out_ref[pkt_cur.sel[i]], " out__sel = %d ", pkt_cur.sel[i], " pkt_in = %d " , pkt_cur.in[i]);
            end
            // $display(" out_ref  = %d", out_ref);
            if(pkt_cur.sel[0][1:0] == pkt_cur.sel[1][1:0] || pkt_cur.sel[0][1:0] == pkt_cur.sel[2][1:0] || pkt_cur.sel[0][1:0] == pkt_cur.sel[3][1:0]) begin
                out_ref[pkt_cur.sel[0][1:0]] = pkt_cur.in[0];
            end else if(pkt_cur.sel[1][1:0] == pkt_cur.sel[2][1:0] || pkt_cur.sel[1][1:0] == pkt_cur.sel[3][1:0])begin 
                out_ref[pkt_cur.sel[1][1:0]] = pkt_cur.in[1];
            end else if(pkt_cur.sel[2][1:0] == pkt_cur.sel[3][1:0]) begin
                out_ref[pkt_cur.sel[2][1:0]] = pkt_cur.in[2];
            end
            if(out_ref !== out) $error("Router ERROR: ", " out:" , out , " out_ref:" , out_ref , " in:" , pkt_cur.in);
        end
    endtask

    // TODO:
    // Сохраняйте сигналы каждый положительный
    // фронт тактового сигнала

    initial begin 
        fork
            generate_input(100,0);
            put_pkt();
            check();
        join
    end


endmodule
