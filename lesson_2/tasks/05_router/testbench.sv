module testbench;

    // Тактовый сигнал и сигнал сброса
    logic clk;
    logic aresetn;

    // Остальные сигналы
    logic  [3:0][1:0] sel;
    logic       [3:0] in;
    logic       [3:0] out;
    logic  [31:0] errors;

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
    parameter CLK_PERIOD =  10;

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
	aresetn = 0;
	errors = 0;
	#(CLK_PERIOD);
	aresetn = 1;
    end

    // TODO:
    // Сгенерируйте входные сигналы
    // Не забудьте про ожидание сигнала сброса!
    initial begin
	wait(aresetn);
        // Входные воздействия опишите здесь.
		repeat(20) begin
		@(posedge clk)
		sel = $urandom();
		in  = $urandom();
		end
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
		pkt.out = out;
		pkt.in = in;
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
			$display("////////////////////////");
			$display("prev_sel[0]=%d", pkt_prev.sel[0]);
			$display("prev_sel[1]=%d", pkt_prev.sel[1]);
			$display("prev_sel[2]=%d", pkt_prev.sel[2]);
			$display("prev_sel[3]=%d", pkt_prev.sel[3]);
			
			$display("prev_in[0]=%d", pkt_prev.in[0]);
			$display("prev_in[1]=%d", pkt_prev.in[1]);
			$display("prev_in[2]=%d", pkt_prev.in[2]);
			$display("prev_in[3]=%d", pkt_prev.in[3]);
			
			$display("cur_out[0]=%d", pkt_cur.out[0]);
			$display("cur_out[1]=%d", pkt_cur.out[1]);
			$display("cur_out[2]=%d", pkt_cur.out[2]);
			$display("cur_out[3]=%d", pkt_cur.out[3]);
			
			
            // Пишите здесь



        if      (pkt_prev.sel[0][1:0] == 2'b00 && pkt_cur.out[0] != pkt_prev.in[0]) begin
                    errors = errors +1'b1;
		    $error("sel=0-0 pkt_cur.out=%d, pkt_prev.in=%d", pkt_cur.out[0], pkt_prev.in[0]);
		end
		else if (pkt_prev.sel[0][1:0] != 2'b00 && pkt_prev.sel[1][1:0] == 2'b00 && pkt_cur.out[0] != pkt_prev.in[1]) begin
                    errors = errors +1'b1;
		    $error("sel=0-1 pkt_cur.out=%d, pkt_prev.in=%d", pkt_cur.out[0], pkt_prev.in[1]);
		end
		else if (pkt_prev.sel[0][1:0] != 2'b00 && pkt_prev.sel[1][1:0] != 2'b00 && pkt_prev.sel[2][1:0] == 2'b00 && pkt_cur.out[0] != pkt_prev.in[2]) begin
                    errors = errors +1'b1;
		    $error("sel=0-2 pkt_cur.out=%d, pkt_prev.in=%d", pkt_cur.out[0], pkt_prev.in[2]);
		end
		else if (pkt_prev.sel[0][1:0] != 2'b00 && pkt_prev.sel[1][1:0] != 2'b00 && pkt_prev.sel[2][1:0] != 2'b00 && pkt_prev.sel[3][1:0] == 2'b00 && pkt_cur.out[0] != pkt_prev.in[3]) begin
                    errors = errors +1'b1;
	    	    $error("sel=0-3 pkt_cur.out=%d, pkt_prev.in=%d", pkt_cur.out[0], pkt_prev.in[3]);
		end
		else if (
		   pkt_prev.sel[0][1:0] != 2'b00 
		&& pkt_prev.sel[1][1:0] != 2'b00 
		&& pkt_prev.sel[2][1:0] != 2'b00 
		&& pkt_prev.sel[3][1:0] != 2'b00 
		&& pkt_cur.out[0] != 1'b0) begin
			errors = errors +1'b1;
			$error("Out[0] no equal 0, pkt_cur.out[0]", pkt_cur.out[0]);
		end

      

        if      (pkt_prev.sel[0][1:0] == 2'b01 && pkt_cur.out[1] != pkt_prev.in[0]) begin
                    errors = errors +1'b1;
		    $error("sel=1-0 pkt_cur.out=%d, pkt_prev.in=%d", pkt_cur.out[1], pkt_prev.in[0]);
		end
		else if (pkt_prev.sel[0][1:0] != 2'b01 && pkt_prev.sel[1][1:0] == 2'b01 && pkt_cur.out[1] != pkt_prev.in[1]) begin
                    errors = errors +1'b1;
		    $error("sel=1-1 pkt_cur.out=%d, pkt_prev.in=%d", pkt_cur.out[1], pkt_prev.in[1]);
		end
		else if (pkt_prev.sel[0][1:0] != 2'b01 && pkt_prev.sel[1][1:0] != 2'b01 && pkt_prev.sel[2][1:0] == 2'b01 && pkt_cur.out[1] != pkt_prev.in[2]) begin
                    errors = errors +1'b1;
		    $error("sel=1-2 pkt_cur.out=%d, pkt_prev.in=%d", pkt_cur.out[1], pkt_prev.in[2]);
		end
		else if (pkt_prev.sel[0][1:0] != 2'b01 && pkt_prev.sel[1][1:0] != 2'b01 && pkt_prev.sel[2][1:0] != 2'b01 && pkt_prev.sel[3][1:0] == 2'b01 && pkt_cur.out[1] != pkt_prev.in[3]) begin
                    errors = errors +1'b1;
	    	    $error("sel=1-3 pkt_cur.out=%d, pkt_prev.in=%d", pkt_cur.out[1], pkt_prev.in[3]);
		end
		else if (
		   pkt_prev.sel[0][1:0] != 2'b01 
		&& pkt_prev.sel[1][1:0] != 2'b01 
		&& pkt_prev.sel[2][1:0] != 2'b01 
		&& pkt_prev.sel[3][1:0] != 2'b01 
		&& pkt_cur.out[1] != 1'b0) begin
			errors = errors +1'b1;
			$error("Out[1] no equal 0, pkt_cur.out[1]", pkt_cur.out[1]);
		end


        if      (pkt_prev.sel[0][1:0] == 2'b10 && pkt_cur.out[2] != pkt_prev.in[0]) begin
                    errors = errors +1'b1;
		    $error("sel=2-0 pkt_cur.out=%d, pkt_prev.in=%d", pkt_cur.out[2], pkt_prev.in[0]);
		end
		else if (pkt_prev.sel[0][1:0] != 2'b10 && pkt_prev.sel[1][1:0] == 2'b10 && pkt_cur.out[2] != pkt_prev.in[1]) begin
                    errors = errors +1'b1;
		    $error("sel=2-1 pkt_cur.out=%d, pkt_prev.in=%d", pkt_cur.out[2], pkt_prev.in[1]);
		end
		else if (pkt_prev.sel[0][1:0] != 2'b10 && pkt_prev.sel[1][1:0] != 2'b10 && pkt_prev.sel[2][1:0] == 2'b10 && pkt_cur.out[2] != pkt_prev.in[2]) begin
                    errors = errors +1'b1;
		    $error("sel=2-2 pkt_cur.out=%d, pkt_prev.in=%d", pkt_cur.out[2], pkt_prev.in[2]);
		end
		else if (pkt_prev.sel[0][1:0] != 2'b10 && pkt_prev.sel[1][1:0] != 2'b10 && pkt_prev.sel[2][1:0] != 2'b10 && pkt_prev.sel[3][1:0] == 2'b10 && pkt_cur.out[2] != pkt_prev.in[3]) begin
                    errors = errors +1'b1;
	    	    $error("sel=2-3 pkt_cur.out=%d, pkt_prev.in=%d", pkt_cur.out[2], pkt_prev.in[3]);
		end
		else if (
		   pkt_prev.sel[0][1:0] != 2'b10 
		&& pkt_prev.sel[1][1:0] != 2'b10 
		&& pkt_prev.sel[2][1:0] != 2'b10 
		&& pkt_prev.sel[3][1:0] != 2'b10 
		&& pkt_cur.out[2] != 1'b0) begin
			errors = errors +1'b1;
			$error("Out[2] no equal 0, pkt_cur.out[2]", pkt_cur.out[2]);
		end


        if      (pkt_prev.sel[0][1:0] == 2'b11 && pkt_cur.out[3] != pkt_prev.in[0]) begin
                    errors = errors +1'b1;
		    $error("sel=3-0 pkt_cur.out=%d, pkt_prev.in=%d", pkt_cur.out[3], pkt_prev.in[0]);
		end
		else if (pkt_prev.sel[0][1:0] != 2'b11 && pkt_prev.sel[1][1:0] == 2'b11 && pkt_cur.out[3] != pkt_prev.in[1]) begin
                    errors = errors +1'b1;
		    $error("sel=3-1 pkt_cur.out=%d, pkt_prev.in=%d", pkt_cur.out[3], pkt_prev.in[1]);
		end
		else if (pkt_prev.sel[0][1:0] != 2'b11 && pkt_prev.sel[1][1:0] != 2'b11 && pkt_prev.sel[2][1:0] == 2'b11 && pkt_cur.out[3] != pkt_prev.in[2]) begin
                    errors = errors +1'b1;
		    $error("sel=3-2 pkt_cur.out=%d, pkt_prev.in=%d", pkt_cur.out[3], pkt_prev.in[2]);
		end
		else if (pkt_prev.sel[0][1:0] != 2'b11 && pkt_prev.sel[1][1:0] != 2'b11 && pkt_prev.sel[2][1:0] != 2'b11 && pkt_prev.sel[3][1:0] == 2'b11 && pkt_cur.out[3] != pkt_prev.in[3]) begin
                    errors = errors +1'b1;
	    	    $error("sel=3-3 pkt_cur.out=%d, pkt_prev.in=%d", pkt_cur.out[3], pkt_prev.in[3]);
		end
		else if (
		   pkt_prev.sel[0][1:0] != 2'b11 
		&& pkt_prev.sel[1][1:0] != 2'b11 
		&& pkt_prev.sel[2][1:0] != 2'b11 
		&& pkt_prev.sel[3][1:0] != 2'b11 
		&& pkt_cur.out[3] != 1'b0) begin
			errors = errors +1'b1;
			$error("Out[3] no equal 0, pkt_cur.out[3] ", pkt_cur.out[3]);
		end

            pkt_prev = pkt_cur;

        end
    end
	
	initial begin
		#(21*CLK_PERIOD);
		$display("errors=%d", errors);
		$stop();
	end

endmodule