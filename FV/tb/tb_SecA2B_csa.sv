module tb_SecA2B_n_k;
    parameter int n = 2;
    parameter int k = 8;

    localparam L = $clog2(k-1);
    localparam RND_KSA_2 = 2*L * k * 1;
    localparam RND_KSA_3 = 2*L * k * 3;
    localparam RND_KSA_4 = 2*L * k * 6;
    localparam RND_CSA_3 = 3*k;
    localparam RND_CSA_4 = 9*k;

    localparam int RND_TOTAL = (n==2) ? RND_KSA_2 :
                               (n==3) ? RND_CSA_3 + RND_KSA_3 :
                               (n==4) ? RND_CSA_4 + RND_KSA_4 : 0;
    // Latency: SecA2B_CS (if n>2) has 2 cycles; SecKSA has 2*(L+1)
    localparam int LATENCY = (n==2) ? 2*(L+1) : (n==3)? 2 + 2*(L+1) : 16;

    reg clk;
    reg [n*k-1:0] ina;
    reg [1023:0] rnd;          // wide enough to hold any needed randomness
    wire [n*k-1:0] out;

    SecA2B_n_k #(.n(n), .k(k)) dut (.*);

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    function [n*k-1:0] random_arith_shares;
        input [k-1:0] plain;
        integer i;
        reg [k-1:0] shares [0:n-1];
        begin
            for (i = 0; i < n-1; i++) shares[i] = $urandom();
            shares[n-1] = plain;
            for (i = 0; i < n-1; i++) shares[n-1] = shares[n-1] - shares[i];
            for (i = 0; i < n; i++) random_arith_shares[i*k +: k] = shares[i];
        end
    endfunction

    function [k-1:0] reconstruct_bool;
        input [n*k-1:0] shares;
        integer b, s;
        reg [k-1:0] res;
        begin
            for (b = 0; b < k; b++) begin
                res[b] = 0;
                for (s = 0; s < n; s++) res[b] = res[b] ^ shares[s*k + b];
            end
            reconstruct_bool = res;
        end
    endfunction

    // Generate a random vector of exactly RND_TOTAL bits
    function [1023:0] gen_rnd;
        integer i;
        reg [1023:0] tmp;
        begin
            tmp = 0;
            for (i = 0; i < (RND_TOTAL+31)/32; i++) begin
                tmp[i*32 +: 32] = $urandom();
            end
            gen_rnd = tmp;
        end
    endfunction

    initial begin
        integer i, err_cnt = 0;
        reg [k-1:0] secret, recovered;
        $display("Testing SecA2B_n_k (n=%0d, k=%0d, latency=%0d cycles)", n, k, LATENCY);
        repeat (2) @(posedge clk);

        for (i = 0; i < 100; i++) begin
            secret = $urandom();
            ina = random_arith_shares(secret);
            rnd = gen_rnd();              // fills only needed low bits, high bits 0
            repeat (LATENCY) @(posedge clk);
            #1;
            recovered = reconstruct_bool(out);
            if (recovered !== secret) begin
                $display("ERROR test %0d: secret=0x%0x recovered=0x%0x", i, secret, recovered);
                err_cnt++;
            end else begin
                $display("OK test %0d", i);
            end
            repeat (2) @(posedge clk);
        end
        if (err_cnt) $display("%0d errors", err_cnt);
        else $display("All tests passed");
        $finish;
    end
endmodule