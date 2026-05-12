// ============================================================================
// Unified testbench for SecA2B using SecRCA adder
// Parameters: d = 2,3,4; k = bit width (default 8)
// ============================================================================
module tb_SecA2B_rca;
    parameter int d = 2;
    parameter int k = 8;

    // ---------- local signals ----------
    reg clk;
    reg [4*k-1:0] ina;          // wide enough for d=4
    reg [8*(k-1)-1:0] rnd;      // wide enough for d=4
    wire [4*k-1:0] out;

    // ---------- DUT instantiation (explicit, no .*) ----------
    generate
        if (d == 2) begin
            SecA2B_2_k #(.k(k)) dut (
                .clk (clk),
                .ina (ina[2*k-1:0]),
                .rnd (rnd[(k-1)-1:0]),
                .out (out[2*k-1:0])
            );
            assign out[4*k-1:2*k] = 0;
        end else if (d == 3) begin
            SecA2B_3_k #(.k(k)) dut (
                .clk (clk),
                .ina (ina[3*k-1:0]),
                .rnd (rnd[4*(k-1)-1:0]),
                .out (out[3*k-1:0])
            );
            assign out[4*k-1:3*k] = 0;
        end else if (d == 4) begin
            SecA2B_4_k #(.k(k)) dut (
                .clk (clk),
                .ina (ina[4*k-1:0]),
                .rnd (rnd[8*(k-1)-1:0]),
                .out (out[4*k-1:0])
            );
        end else begin
            initial $error("Unsupported d=%0d", d);
        end
    endgenerate

    // ---------- Clock ----------
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // ---------- Boolean reconstruction (XOR of shares) ----------
    function [k-1:0] reconstruct;
        input [4*k-1:0] shares;
        integer b, s;
        reg [k-1:0] res;
        begin
            for (b = 0; b < k; b++) begin
                res[b] = 0;
                for (s = 0; s < d; s++) begin
                    res[b] = res[b] ^ shares[s*k + b];
                end
            end
            reconstruct = res;
        end
    endfunction

    // ---------- Test procedure ----------
    initial begin
        integer i, err_cnt = 0;
        reg [k-1:0] a0, a1, a2, a3;
        reg [k-1:0] sum_expected, sum_out;
        integer latency;

        if (d == 2) latency = 2*(k-1);
        else if (d == 3) latency = 4*(k-1);
        else if (d == 4) latency = 4*(k-1);
        else latency = 0;

        $display("Testing SecA2B_RCA (d=%0d, k=%0d, latency=%0d cycles)", d, k, latency);
        repeat (2) @(posedge clk);

        for (i = 0; i < 100; i++) begin
            a0 = $urandom();
            a1 = $urandom();
            a2 = $urandom();
            a3 = $urandom();

            // Pad assignments to match full 4*k width
            case (d)
                2: ina = {{(4*k - 2*k){1'b0}}, a1, a0};
                3: ina = {{(4*k - 3*k){1'b0}}, a2, a1, a0};
                4: ina = {a3, a2, a1, a0};
                default: ina = 0;
            endcase

            // randomness (64 bits, enough for max 56 bits)
            rnd = {$urandom(), $urandom()};

            repeat (latency) @(posedge clk);
            #1;

            // compute expected sum (mod 2^k)
            if (d == 2) sum_expected = a0 + a1;
            else if (d == 3) sum_expected = a0 + a1 + a2;
            else if (d == 4) sum_expected = a0 + a1 + a2 + a3;
            else sum_expected = 0;

            sum_out = reconstruct(out);
            if (sum_out !== sum_expected) begin
                $display("ERROR test %0d: expected 0x%0x, got 0x%0x", i, sum_expected, sum_out);
                err_cnt++;
            end else begin
                $display("OK test %0d", i);
            end

            // pipeline bubble
            repeat (2) @(posedge clk);
        end

        if (err_cnt) $display("%0d errors", err_cnt);
        else $display("All tests passed");
        $finish;
    end
endmodule