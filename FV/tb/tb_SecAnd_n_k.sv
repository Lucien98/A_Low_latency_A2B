// ============================================================================
// Testbench for SecAnd_n_k
// ============================================================================
module tb_SecAnd_n_k();

    localparam d = 2;
    localparam k = 4;
    localparam HPC2_RND_BITS = d*(d-1)/2;   // = 1 for d=2
    localparam RND_WIDTH     = k * HPC2_RND_BITS;  // = 4

    reg         clk;
    reg  [k*d-1:0] ina, inb;
    reg  [RND_WIDTH-1:0] rnd;
    wire [k*d-1:0] out;

    // DUT instance
    SecAnd_n_k #(.d(d), .k(k)) dut (
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

    // Helper: reconstruct a k-bit value from its d shares (XOR)
    function [k-1:0] reconstruct;
        input [k*d-1:0] shares;
        integer s, b;
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

    // Test procedure
    initial begin
        integer tests = 100, i, err_cnt = 0;
        reg [k-1:0] a_plain, b_plain, expected, out_plain;
        reg [k*d-1:0] a_shares, b_shares;
        reg [RND_WIDTH-1:0] rnd_val;

        $display("Starting testbench for SecAnd_n_k (d=%0d, k=%0d)", d, k);

        // Initial values (reset)
        ina = 0; inb = 0; rnd = 0;
        repeat (2) @(posedge clk);  // wait for possible reset

        for (i = 0; i < tests; i = i + 1) begin
            // Generate random plain values and random shares
            a_plain = $urandom();
            b_plain = $urandom();
            // For d=2, create two shares that XOR to plain value
            a_shares = 0;
            b_shares = 0;
            for (int b = 0; b < k; b = b + 1) begin
                // share0 random, share1 = plain ^ share0
                bit share0 = $urandom();
                a_shares[0*k + b] = share0;
                a_shares[1*k + b] = a_plain[b] ^ share0;
                share0 = $urandom();
                b_shares[0*k + b] = share0;
                b_shares[1*k + b] = b_plain[b] ^ share0;
            end
            rnd_val = $urandom();   // randomness can be arbitrary

            // Apply inputs
            ina = a_shares;
            inb = b_shares;
            rnd = rnd_val;
            @(posedge clk);
            @(posedge clk);   // latency = 2 cycles
            #1;   // small delay for signal stability

            // Capture and verify output
            out_plain = reconstruct(out);
            expected = a_plain & b_plain;
            if (out_plain !== expected) begin
                $display("ERROR: test %0d: a=0x%0x, b=0x%0x, out=0x%0x, expected=0x%0x",
                         i, a_plain, b_plain, out_plain, expected);
                err_cnt = err_cnt + 1;
            end else begin
                $display("OK: test %0d: a=0x%0x, b=0x%0x -> out=0x%0x",
                         i, a_plain, b_plain, out_plain);
            end
            @(posedge clk);
        end

        if (err_cnt == 0)
            $display("All tests passed.");
        else
            $display("%0d errors occurred.", err_cnt);
        $finish;
    end

endmodule