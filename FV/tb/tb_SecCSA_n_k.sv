// ============================================================================
// Testbench for SecCSA_n_k (n=2, k=8)
// ============================================================================
module tb_SecCSA_n_k;
    parameter n = 3;
    parameter k = 8;
    localparam RND_BITS = k * n*(n-1)/2;   // 8 bits for n=2,k=8
    localparam LATENCY = 2;                // SecAnd latency

    reg clk;
    reg [n*k-1:0] ina, inb, incin;
    reg [RND_BITS-1:0] rnd;
    wire [n*k-1:0] outs, outc;

    SecCSA_n_k #(.n(n), .k(k)) dut (
        .clk(clk),
        .ina(ina),
        .inb(inb),
        .incin(incin),
        .rnd(rnd),
        .outs(outs),
        .outc(outc)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Convert Boolean shares (XOR) to plain value
    function [k-1:0] reconstruct;
        input [n*k-1:0] shares;
        integer b, s;
        reg [k-1:0] res;
        begin
            for (b = 0; b < k; b++) begin
                res[b] = 0;
                for (s = 0; s < n; s++) res[b] = res[b] ^ shares[s*k + b];
            end
            reconstruct = res;
        end
    endfunction

    // Generate Boolean shares from plain value (XOR)
    function [n*k-1:0] bool_shares;
        input [k-1:0] plain;
        integer b;
        reg [n*k-1:0] shares;
        begin
            for (b = 0; b < k; b++) begin
                shares[0*k + b] = $urandom();
                shares[1*k + b] = plain[b] ^ shares[0*k + b];
            end
            bool_shares = shares;
        end
    endfunction

    initial begin
        integer i, err_cnt = 0;
        reg [k-1:0] x_plain, y_plain, cin_plain;
        reg [k-1:0] s_plain, c_plain, sum_plain, sum_expected;
        reg [n*k-1:0] x_shares, y_shares, cin_shares;

        $display("Testing SecCSA_n_k (n=%0d, k=%0d, latency=%0d)", n, k, LATENCY);
        repeat (2) @(posedge clk);

        for (i = 0; i < 100; i++) begin
            x_plain = $urandom();
            y_plain = $urandom();
            cin_plain = $urandom();

            // Convert to Boolean shares
            x_shares = bool_shares(x_plain);
            y_shares = bool_shares(y_plain);
            cin_shares = bool_shares(cin_plain);

            ina = x_shares;
            inb = y_shares;
            incin = cin_shares;
            rnd = $urandom();   // 32 bits, truncated to 8 bits (RND_BITS=8)

            repeat (LATENCY) @(posedge clk);
            #1;

            s_plain = reconstruct(outs);
            c_plain = reconstruct(outc);

            // Verify s + c == x + y + cin (mod 2^k)
            sum_plain = s_plain + c_plain;
            sum_expected = x_plain + y_plain + cin_plain;

            if (sum_plain !== sum_expected) begin
                $display("ERROR test %0d: sum=0x%0x, expected=0x%0x", i, sum_plain, sum_expected);
                $display("  x=0x%0x y=0x%0x cin=0x%0x s=0x%0x c=0x%0x",
                         x_plain, y_plain, cin_plain, s_plain, c_plain);
                err_cnt++;
            end else begin
                $display("OK test %0d", i);
            end

            repeat (2) @(posedge clk);   // pipeline bubble
        end

        if (err_cnt) $display("%0d errors", err_cnt);
        else $display("All tests passed");
        $finish;
    end
endmodule