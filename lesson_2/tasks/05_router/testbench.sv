module testbench;


    // Тактовый сигнал и сигнал сброса
    logic clk;
    logic aresetn;

    // Остальные сигналы
    logic  [3:0][1:0] sel;
    logic       [3:0] in;
    logic       [3:0] out;

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
    parameter CLK_PERIOD = 10; //xz

    // TODO:
    // Cгенерируйте тактовый сигнал
    initial begin
        clk <= 0;
        forever begin
	 #(CLK_PERIOD/2) clk <= ~clk;
        end
    end
    
    // TODO:
    // Cгенерируйте сигнал сброса
    initial begin
	aresetn <= 0;
        #(CLK_PERIOD);
        aresetn <= 1;
    end

    // TODO:
    // Сгенерируйте входные сигналы
    // Не забудьте про ожидание сигнала сброса!
    initial begin
        // Входные воздействия опишите здесь.
	wait(aresetn);
        repeat(20) begin
	    @(posedge clk);
            in <= $urandom_range(0, 15);
		foreach(sel[i]) begin
		    begin
		    	sel[i] = $urandom_range(0, 3);        // От 0 до 3
		    end   
		end
        end
        @(posedge clk);
        $stop();
    end

    // Пользуйтесь этой структурой
    typedef struct {
        logic  [3:0][1:0] sel;
        logic       [3:0] in;
        logic       [3:0] out;
    } packet;

    mailbox#(packet) mon2chk = new();

    // TODO:
    // Сохраняйте сигналы каждый положительный
    // фронт тактового сигнала
    initial begin
        packet pkt;
        wait(aresetn);
        forever begin
            @(posedge clk);
            // Пишите здесь.
	        pkt.sel = sel;
            pkt.in = in;
            pkt.out = out;
            mon2chk.put(pkt);
        end
    end

    // TODO:
    // Выполните проверку выходных сигналов
    initial begin
        packet pkt_prev, pkt_cur;
        wait(aresetn);
        mon2chk.get(pkt_prev);
        forever begin
            mon2chk.get(pkt_cur);

            // Пишите здесь
        for(int i = 0; i<4; i++) begin
            if(pkt_prev.sel[0] == i) begin 
                if( pkt_cur.out[i] !=  pkt_prev.in [0]) begin
                    $error("BAD_OUT%1d",i);
                    $display("pkt_prev.sel[0] = %d",pkt_prev.sel[0] ," pkt_prev.in [0]: %d ", pkt_prev.in [0]," pkt_cur.out[%1d]: %d ",i, pkt_cur.out[i]);
                end 
            end
            else if(pkt_prev.sel[1] == i) begin 
                if( pkt_cur.out[i] !=  pkt_prev.in [1]) begin
                    $error("BAD_OUT%1d",i);
                    $display("pkt_prev.sel[1] = %d",pkt_prev.sel[1] ," pkt_prev.in [1]: %d ", pkt_prev.in [1]," pkt_cur.out[%1d]: %d ",i, pkt_cur.out[i]);
                end
            end
            else if(pkt_prev.sel[2] == i) begin 
                if( pkt_cur.out[i] !=  pkt_prev.in [2]) begin
                    $error("BAD_OUT%1d",i);
                    $display("pkt_prev.sel[2] = %d",pkt_prev.sel[2] ," pkt_prev.in [2]: %d ", pkt_prev.in [2]," pkt_cur.out[%1d]: %d ",i, pkt_cur.out[i]);
                end
            end
            else if(pkt_prev.sel[3] == i) begin 
                if( pkt_cur.out[i] !=  pkt_prev.in [3]) begin
                    $error("BAD_OUT%1d",i);
                    $display("pkt_prev.sel[3] = %d",pkt_prev.sel[3] ," pkt_prev.in [3]: %d ", pkt_prev.in [3]," pkt_cur.out[%1d]: %d ",i, pkt_cur.out[i]);
                end
            end
            else if( pkt_cur.out[i] !=  0) begin
                    $error("BAD_OUT%1d",i);
                    $display("pkt_prev.sel = %d %d %d %d", pkt_prev.sel[3], pkt_prev.sel[2], pkt_prev.sel[1], pkt_prev.sel[0] ," pkt_cur.out[%1d]: %d ",i, pkt_cur.out[i]);
            end
        end                   		
            pkt_prev = pkt_cur;
    end
end
endmodule
