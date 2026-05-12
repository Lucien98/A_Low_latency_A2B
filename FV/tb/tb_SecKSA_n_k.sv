module tb_SecKSA_n_k();

    parameter n = 3;
    parameter k = 8;
    localparam L = $clog2(k-1);
    localparam RND_PER_AND = k * n*(n-1)/2;
    localparam TOTAL_AND = 2*L;
    localparam RND_WIDTH = TOTAL_AND * RND_PER_AND;   // 48 bits for n=2,k=8
    localparam LATENCY = 2 * (L+1);                   // 8 cycles for k=8

    reg clk;
    reg [n*k-1:0] ina, inb;
    reg [RND_WIDTH-1:0] rnd;
    wire [n*k-1:0] out;

    SecKSA_n_k #(.n(n), .k(k)) dut (.*);

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    function [k-1:0] reconstruct;
        input [n*k-1:0] shares;
        integer b, s;
        reg [k-1:0] res;
        begin
            for (b = 0; b < k; b++) begin
                res[b] = 0;
                for (s = 0; s < n; s++)
                    res[b] = res[b] ^ shares[s*k + b];
            end
            reconstruct = res;
        end
    endfunction

    function [n*k-1:0] random_shares;
        input [k-1:0] plain;
        integer b, s;
        reg [n*k-1:0] shares;
        begin
            for (b = 0; b < k; b++) begin
                shares[0*k + b] = $urandom();
                for (s = 1; s < n-1; s++)
                    shares[s*k + b] = $urandom();
                shares[(n-1)*k + b] = plain[b];
                for (s = 0; s < n-1; s++)
                    shares[(n-1)*k + b] = shares[(n-1)*k + b] ^ shares[s*k + b];
            end
            random_shares = shares;
        end
    endfunction

    initial begin
        integer i, err_cnt = 0;
        reg [k-1:0] a, b, exp, got;
        $display("Testing SecKSA_n_k (n=%0d, k=%0d) latency=%0d cycles", n, k, LATENCY);
        repeat (2) @(posedge clk);

        for (i = 0; i < 100; i++) begin
            a = $urandom();
            b = $urandom();
            ina = random_shares(a);
            inb = random_shares(b);
            // Provide enough random bits (48 bits for n=2,k=8)
            rnd = 0;//{$urandom(), $urandom(), $urandom(), $urandom()};
            repeat (LATENCY) @(posedge clk);
            #1;
            got = reconstruct(out);
            exp = a + b;
            if (got !== exp) begin
                $display("ERROR test %0d: a=0x%0x b=0x%0x exp=0x%0x got=0x%0x", i, a, b, exp, got);
                err_cnt++;
            end else $display("OK test %0d", i);
            repeat (2) @(posedge clk);
        end
        if (err_cnt) $display("%0d errors", err_cnt);
        else $display("All tests passed");
        $finish;
    end

endmodule