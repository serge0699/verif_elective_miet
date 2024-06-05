module testbench;

    // Тактовый сигнал и сигнал сброса
    logic clk;
    logic aresetn;

    // Остальные сигналы
    logic [31:0] instr;
    logic [31:0] i_imm;
    logic [31:0] i_imm_ef;
    logic [31:0] i_imm_ef_ee;
    logic [31:0] s_imm;
    logic [31:0] s_imm_ef;
    logic [31:0] s_imm_ef_ee;
    logic [31:0] b_imm;
    logic [31:0] b_imm_ef;
    logic [31:0] b_imm_ef_ee;
    logic [31:0] u_imm;
    logic [31:0] u_imm_ef;
    logic [31:0] u_imm_ef_ee;
    logic [31:0] j_imm;
    logic [31:0] j_imm_ef;
    logic [31:0] j_imm_ef_ee;

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
    // Сгенерируйте входные сигналы
    // Не забудьте про ожидание сигнала сброса!
    initial begin
        wait (aresetn);
        @(posedge clk);
        instr = 32'b11111100000000000000000111111111; 
        @(posedge clk);
        instr = 32'b11111111111111111111111111111111; 
        @(posedge clk);
        instr = 32'b10101010101010101010101010101010; 
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
        forever begin
            mon2chk.get(pkt_prev);
            i_imm_ef = {{21{pkt_prev.instr[31]}}, pkt_prev.instr[30:20]}; 
            s_imm_ef = {{21{pkt_prev.instr[31]}}, pkt_prev.instr[30:25], pkt_prev.instr[11:8],pkt_prev.instr[7]}; 
            b_imm_ef = {{19{pkt_prev.instr[31]}}, pkt_prev.instr[7], pkt_prev.instr[30:25], pkt_prev.instr[11:8], 0}; 
            u_imm_ef = {{1{pkt_prev.instr[31]}}, pkt_prev.instr[30:12], {11{1'b0}}};
            j_imm_ef = {{11{pkt_prev.instr[31]}}, pkt_prev.instr[19:12],pkt_prev.instr[20],pkt_prev.instr[30:25],pkt_prev.instr[24:21],0};
            // Пишите здесь.
            if ((i_imm !== i_imm_ef )|| (s_imm !== s_imm_ef) || (b_imm !== b_imm_ef) || (u_imm !== u_imm_ef) || (j_imm !== j_imm_ef)) begin 
                i_imm_ef_ee = i_imm ^ i_imm_ef;
                s_imm_ef_ee = s_imm ^ s_imm_ef;
                b_imm_ef_ee = b_imm ^ b_imm_ef;
                u_imm_ef_ee = u_imm ^ u_imm_ef;
                j_imm_ef_ee = j_imm ^ j_imm_ef;
                $display("disign_i    :%b", i_imm);
                $display("ef_i        :%b", i_imm_ef);
                $display("Bits error_i:%b", i_imm_ef_ee);
                $display("disign_s    :%b", s_imm);
                $display("ef_s        :%b", s_imm_ef);
                $display("Bits error_s:%b", s_imm_ef_ee);
                $display("disign_b    :%b", b_imm);
                $display("ef_b        :%b", b_imm_ef);
                $display("Bits error_b:%b", b_imm_ef_ee);
                $display("disign_u    :%b", u_imm);
                $display("ef_u        :%b", u_imm_ef);
                $display("Bits error_u:%b", u_imm_ef_ee);
                $display("disign_j    :%b", j_imm);
                $display("ef_j        :%b", j_imm_ef);
                $display("Bits error_j:%b", j_imm_ef_ee);
            end
            pkt_prev = pkt_cur;
        end

    end

endmodule
