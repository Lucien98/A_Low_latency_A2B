// ============================================================================
// Testbench for SecA2B using SecKSA adder (Kogge-Stone based)
// Parameter: d = number of shares (2, 3, or 4)
//           k = bit width (default 8)
// Usage (Verilator): -Gd=2 -Gk=8
// ============================================================================
module tb_SecA2B_ksa;
    parameter int d = 2;          // number of shares (2,3,4)
    parameter int k = 8;          // bit width

    // ------------------------------------------------------------------------
    // Local parameters derived from d and k
    // ------------------------------------------------------------------------
    localparam int L = $clog2(k-1);                 // number of KSA stages
    localparam int DEPTH = (d == 2) ? 1 : 2;        // recursion depth of the A2B tree
    localparam int LATENCY = DEPTH * 2 * (L+1);     // total clock cycles

    // ------------------------------------------------------------------------
    // Total randomness width – sum over all SecKSA instances in the tree
    // each SecKSA_n_k requires 2*L * k * n*(n-1)/2 bits
    // Compute as constant expression without a function
    // ------------------------------------------------------------------------
    localparam int RND_PER_AND_2 = 2 * L * k * 1;        // n=2 → n*(n-1)/2 = 1
    localparam int RND_PER_AND_3 = 2 * L * k * 3;        // n=3 → 3
    localparam int RND_PER_AND_4 = 2 * L * k * 6;        // n=4 → 6

    localparam int RND_TOTAL = 
        (d == 2) ? RND_PER_AND_2 :
        (d == 3) ? RND_PER_AND_2 + RND_PER_AND_3 :
        (d == 4) ? 2 * RND_PER_AND_2 + RND_PER_AND_4 :
        0;

    // ------------------------------------------------------------------------
    // Signals
    // ------------------------------------------------------------------------
    reg clk;
    reg [d*k-1:0] ina;                     // arithmetic shares (input)
    reg [RND_TOTAL-1:0] rnd;               // concatenated randomness
    wire [d*k-1:0] out;                    // boolean shares (output)

    // ------------------------------------------------------------------------
    // Instantiate DUT according to d
    // ------------------------------------------------------------------------
    generate
        if (d == 2) begin
            SecA2B_2_k #(.k(k)) dut (.*);
        end else if (d == 3) begin
            SecA2B_3_k #(.k(k)) dut (.*);
        end else if (d == 4) begin
            SecA2B_4_k #(.k(k)) dut (.*);
        end else begin
            initial $fatal("Unsupported number of shares d=%0d (must be 2,3,4)", d);
        end
    endgenerate

    // ------------------------------------------------------------------------
    // Clock generator
    // ------------------------------------------------------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // ------------------------------------------------------------------------
    // Arithmetic sharing generator: sum of all shares = plain (mod 2^k)
    // ------------------------------------------------------------------------
    function automatic [d*k-1:0] random_arith_shares;
        input [k-1:0] plain;
        reg [k-1:0] shares [0:d-1];
        int i;
        begin
            for (i = 0; i < d-1; i++) shares[i] = $urandom();
            shares[d-1] = plain;
            for (i = 0; i < d-1; i++) shares[d-1] = shares[d-1] - shares[i];
            // pack in share-major order: shares[0] in LSB part, shares[d-1] in MSB part
            for (i = 0; i < d; i++) begin
                random_arith_shares[i*k +: k] = shares[i];
            end
        end
    endfunction

    // ------------------------------------------------------------------------
    // Boolean reconstruction: XOR all shares
    // ------------------------------------------------------------------------
    function automatic [k-1:0] reconstruct_bool;
        input [d*k-1:0] shares;
        int b, i;
        reg [k-1:0] res;
        begin
            for (b = 0; b < k; b++) begin
                res[b] = 0;
                for (i = 0; i < d; i++) res[b] = res[b] ^ shares[i*k + b];
            end
            reconstruct_bool = res;
        end
    endfunction

    // ------------------------------------------------------------------------
    // Test procedure
    // ------------------------------------------------------------------------
    initial begin
        int i, err_cnt = 0;
        reg [k-1:0] secret, recovered;
        $display("Testing SecA2B (KSA) | d=%0d, k=%0d, latency=%0d cycles", d, k, LATENCY);
        repeat (2) @(posedge clk);

        for (i = 0; i < 100; i++) begin
            secret = $urandom();
            ina = random_arith_shares(secret);
            // generate enough random bits (use 4*32 = 128 bits, but for d=4,k=8 we need 384 bits)
            // Using 16*32 = 512 bits guarantees enough for all cases
            rnd = {$urandom(), $urandom(), $urandom(), $urandom(),
                   $urandom(), $urandom(), $urandom(), $urandom(),
                   $urandom(), $urandom(), $urandom(), $urandom(),
                   $urandom(), $urandom(), $urandom(), $urandom()}[RND_TOTAL-1:0];
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