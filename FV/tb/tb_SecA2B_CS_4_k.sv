module tb_SecA2B_CS_4_k;
    parameter k = 8;
    localparam RND_BITS = 9*k;
    localparam LATENCY = 4;

    reg clk;
    reg [4*k-1:0] ina;
    reg [RND_BITS-1:0] rnd;
    wire [4*k-1:0] outs, outc;

    SecA2B_CS_4_k #(.k(k)) dut (
        .clk(clk),
        .ina(ina),
        .rnd(rnd),
        .outs(outs),
        .outc(outc)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    function [k-1:0] reconstruct;
        input [4*k-1:0] shares;
        integer b, s;
        reg [k-1:0] res;
        begin
            for (b = 0; b < k; b++) begin
                res[b] = 0;
                for (s = 0; s < 4; s++) res[b] = res[b] ^ shares[s*k + b];
            end
            reconstruct = res;
        end
    endfunction

    initial begin
        integer i, err = 0;
        reg [k-1:0] a0, a1, a2, a3, x_plain, s_plain, c_plain, sum;
        $display("Testing SecA2B_CS_4_k (k=%0d)", k);
        repeat (2) @(posedge clk);

        for (i = 0; i < 100; i++) begin
            a0 = $urandom();
            a1 = $urandom();
            a2 = $urandom();
            a3 = $urandom();
            x_plain = a0 + a1 + a2 + a3;
            ina = {a3, a2, a1, a0};
            rnd = {$urandom(), $urandom(), $urandom()}; // 96 bits > 72
            repeat (LATENCY) @(posedge clk);
            #1;
            s_plain = reconstruct(outs);
            c_plain = reconstruct(outc);
            sum = s_plain + c_plain;
            if (sum !== x_plain) begin
                $display("ERROR test %0d: sum=0x%0x expected=0x%0x", i, sum, x_plain);
                err++;
            end else $display("OK test %0d", i);
            repeat (2) @(posedge clk);
        end
        if (err) $display("%0d errors", err);
        else $display("All tests passed");
        $finish;
    end
endmodule