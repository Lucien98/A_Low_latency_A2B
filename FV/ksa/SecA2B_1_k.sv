// File: ./lib/SecA2B_1_k.sv
module SecA2B_1_k #(parameter integer k = 8) (
    input  [k-1:0] ina,   // single arithmetic share
    output [k-1:0] out    // single Boolean share
);
    assign out = ina;
endmodule