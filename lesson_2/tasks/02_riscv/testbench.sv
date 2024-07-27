module testbench;

    // Тактовый сигнал и сигнал сброса
    logic clk;
    logic aresetn;

    // Остальные сигналы
    logic [31:0] instr;
    logic [31:0] i_imm;
    logic [31:0] s_imm;
    logic [31:0] b_imm;
    logic [31:0] u_imm;
    logic [31:0] j_imm;

    logic [31:0] ref_i_imm;
    logic [31:0] ref_s_imm;
    logic [31:0] ref_b_imm;
    logic [31:0] ref_u_imm;
    logic [31:0] ref_j_imm;

    riscv_imm_gen DUT (
        .clk     ( clk     ),
        .aresetn ( aresetn ),
        .instr   ( instr   ),
        .i_imm   ( i_imm   ),
        .s_imm   ( s_imm   ),
        .b_imm   ( b_imm   ),
        .u_imm   ( u_imm   ),
        .j_imm   ( j_imm   )
    );

    // TODO:
    // Определите период тактового сигнала
    parameter CLK_PERIOD = 10;// ?;

    // TODO:
    // Cгенерируйте тактовый сигнал
    initial begin
        clk = 0;
        forever begin
            #(CLK_PERIOD/2) clk = ~clk;
        end
    end
    
    // Генерация сигнала сброса
    initial begin
        aresetn <= 0;
        #(CLK_PERIOD);
        aresetn <= 1;
    end

    // TODO:
    // Сгенерируйте входные сигналы
    // Не забудьте про ожидание сигнала сброса!
    initial begin
        wait(aresetn);
        repeat(10) begin
            @(posedge clk);
            instr <= $urandom();
        end

        $display("End of sim.");
        $stop();
    end

    // Пользуйтесь этой структурой
    typedef struct {
        logic [31:0] instr;
        logic [31:0] i_imm;
        logic [31:0] s_imm;
        logic [31:0] b_imm;
        logic [31:0] u_imm;
        logic [31:0] j_imm;
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
            pkt.instr = instr;
            pkt.i_imm = i_imm;
            pkt.s_imm = s_imm;
            pkt.b_imm = b_imm;
            pkt.u_imm = u_imm;
            pkt.j_imm = j_imm;
            mon2chk.put(pkt);
        end
    end

    // TODO:
    // Выполните проверку выходных сигналов.
    initial begin
        packet pkt_prev, pkt_cur;
        wait(aresetn);
        mon2chk.get(pkt_prev);
        forever begin
            mon2chk.get(pkt_cur);

            // Пишите здесь.
            $display("\n=================================================");
            // I_IMM

            ref_i_imm = { {21{pkt_prev.instr[31]}}, pkt_prev.instr[30:25], pkt_prev.instr[24:21], pkt_prev.instr[20] };
            ref_s_imm = { {21{pkt_prev.instr[31]}}, pkt_prev.instr[30:25], pkt_prev.instr[11: 8], pkt_prev.instr[ 7] };
            ref_b_imm = { {20{pkt_prev.instr[31]}}, pkt_prev.instr[7], pkt_prev.instr[30:25], pkt_prev.instr[11:8], 1'b0 };
            ref_u_imm = { pkt_prev.instr[31], pkt_prev.instr[30:20], pkt_prev.instr[19:12], 12'b0 };
            ref_j_imm = { {12{pkt_prev.instr[31]}}, pkt_prev.instr[19:12], pkt_prev.instr[20],  pkt_prev.instr[30:25],  pkt_prev.instr[24:21], 1'b0 };

            if(pkt_cur.i_imm !== ref_i_imm)
                $display("---------\n(%0t) i_imm bad!\ncur: %b\nexp: %b", $time(), pkt_cur.i_imm, ref_i_imm);

            // S_IMM
            if(pkt_cur.s_imm !== ref_s_imm)
                $display("---------\n(%0t) s_imm bad!\ncur: %b\nexp: %b", $time(), pkt_cur.s_imm, ref_s_imm);

            // B_IMM
            if(pkt_cur.b_imm !== ref_b_imm)
                $display("---------\n(%0t) b_imm bad!\ncur: %b\nexp: %b", $time(), pkt_cur.b_imm, ref_b_imm);

            // U_IMM
            if(pkt_cur.u_imm !== ref_u_imm)
                $display("---------\n(%0t) u_imm bad!\ncur: %b\nexp: %b", $time(), pkt_cur.u_imm, ref_u_imm);

            // J_IMM
            if(pkt_cur.j_imm !== ref_j_imm)
                $display("---------\n(%0t) j_imm bad!\ncur: %b\nexp: %b", $time(), pkt_cur.j_imm, ref_j_imm);

            pkt_prev = pkt_cur;
        end
    end

endmodule
