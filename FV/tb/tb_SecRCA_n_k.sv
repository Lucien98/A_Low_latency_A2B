// ============================================================================
// Testbench for SecRCA_n_k (unrolled version)
// ============================================================================
module tb_SecRCA_n_k();

    parameter d = 2;
    parameter k = 8;
    localparam RND_PER_BIT = d*(d-1)/2;
    localparam RND_TOTAL   = (k-1) * RND_PER_BIT;
    localparam LATENCY     = 2*(k-1);   // clock cycles until output valid

    reg         clk;
    reg  [k*d-1:0] ina, inb;
    reg  [RND_TOTAL-1:0] rnd;
    wire [k*d-1:0] out;

    // DUT instance
    SecRCA_n_k #(.d(d), .k(k)) dut (
        .clk(clk),
        .ina(ina),
        .inb(inb),
        .rnd(rnd),
        .out(out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Helper: reconstruct plain value from shares (XOR)
    function [k-1:0] reconstruct;
        input [k*d-1:0] shares;
        integer b, s;
        reg [k-1:0] res;
        begin
            res = 0;
            for (b = 0; b < k; b = b + 1) begin
                res[b] = 0;
                for (s = 0; s < d; s = s + 1)
                    res[b] = res[b] ^ shares[s*k + b];
            end
            reconstruct = res;
        end
    endfunction

    // Helper: generate random Boolean shares for a plain value
    function automatic [k*d-1:0] random_shares(input [k-1:0] plain);
        integer b, s;
        reg [k*d-1:0] shares;
        begin
            for (b = 0; b < k; b = b + 1) begin
                // share0 random, remaining shares random except last adjusted
                shares[0*k + b] = $urandom();
                for (s = 1; s < d-1; s = s + 1)
                    shares[s*k + b] = $urandom();
                // last share computed to make XOR = plain[b]
                if (d == 2) begin
                    shares[(d-1)*k + b] = plain[b] ^ shares[0*k + b];
                end else begin
                    shares[(d-1)*k + b] = plain[b];
                    for (s = 0; s < d-1; s = s + 1)
                        shares[(d-1)*k + b] = shares[(d-1)*k + b] ^ shares[s*k + b];
                end
            end
        end
        random_shares = shares;
    endfunction

    // Test procedure
    initial begin
        integer tests = 100, i, err_cnt = 0;
        reg [k-1:0] a_plain, b_plain, sum_expected, sum_out;
        reg [k*d-1:0] a_shares, b_shares;
        reg [RND_TOTAL-1:0] rnd_val;

        $display("Starting testbench for SecRCA_n_k (d=%0d, k=%0d)", d, k);
        $display("Latency = %0d cycles", LATENCY);

        // Initial values
        ina = 0; inb = 0; rnd = 0;
        repeat (2) @(posedge clk);

        for (i = 0; i < tests; i = i + 1) begin
            // Generate random plain values and random shares
            a_plain = $urandom();
            b_plain = $urandom();
            a_shares = random_shares(a_plain);
            b_shares = random_shares(b_plain);
            rnd_val = $urandom();

            // Apply inputs
            ina = a_shares;
            inb = b_shares;
            rnd = rnd_val;

            // Wait for the pipeline to fill (latency cycles)
            repeat (LATENCY) @(posedge clk);
            // Capture output after latency
            #1;  // small delay to avoid race
            sum_out = reconstruct(out);
            sum_expected = a_plain + b_plain;   // modulo 2^k is automatic

            if (sum_out !== sum_expected) begin
                $display("ERROR: test %0d: a=0x%0x, b=0x%0x, out=0x%0x, expected=0x%0x",
                         i, a_plain, b_plain, sum_out, sum_expected);
                err_cnt = err_cnt + 1;
            end else begin
                $display("OK: test %0d: a=0x%0x + b=0x%0x = 0x%0x",
                         i, a_plain, b_plain, sum_out);
            end

            // Small gap before next test
            repeat (2) @(posedge clk);
        end

        if (err_cnt == 0)
            $display("All tests passed.");
        else
            $display("%0d errors occurred.", err_cnt);
        $finish;
    end

endmodule