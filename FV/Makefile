sim_secand_n2k4:
	verilator --binary -j 0 \
		-Wno-WIDTHTRUNC \
		--trace \
		./tb/tb_SecAnd_n_k.sv \
		--top-module tb_SecAnd_n_k \
		-Ilib -Itb
	./obj_dir/Vtb_SecAnd_n_k

sim_secrca_n2k8:
	verilator --binary -j 0 \
		-Wno-WIDTHTRUNC \
		--trace \
		./tb/tb_SecRCA_n_k.sv \
		--top-module tb_SecRCA_n_k \
		-Ilib -Itb
	./obj_dir/Vtb_SecRCA_n_k


# ============================================================================
# SecA2B using Kogge‑Stone adder (KSA) test targets
# Usage:
#   make sim_a2b_ksa_n2   - test with 2 shares (d=2, k=8)
#   make sim_a2b_ksa_n3   - test with 3 shares (d=3, k=8)
#   make sim_a2b_ksa_n4   - test with 4 shares (d=4, k=8)
# ============================================================================

sim_a2b_ksa_n2:
	verilator --binary -j 0 -Wno-WIDTHTRUNC --trace \
		./tb/tb_SecA2B_ksa.sv --top-module tb_SecA2B_ksa \
		-Gd=2 -Ilib -Iksa -Itb && ./obj_dir/Vtb_SecA2B_ksa

sim_a2b_ksa_n3:
	verilator --binary -j 0 -Wno-WIDTHTRUNC --trace \
		./tb/tb_SecA2B_ksa.sv --top-module tb_SecA2B_ksa \
		-Gd=3 -Ilib -Iksa -Itb && ./obj_dir/Vtb_SecA2B_ksa

sim_a2b_ksa_n4:
	verilator --binary -j 0 -Wno-WIDTHTRUNC --trace \
		./tb/tb_SecA2B_ksa.sv --top-module tb_SecA2B_ksa \
		-Gd=4 -Ilib -Iksa -Itb && ./obj_dir/Vtb_SecA2B_ksa

# ============================================================================
# SecA2B using RCA (ripple‑carry) adder test targets
# Usage:
#   make sim_a2b_rca_n2   - test with 2 shares (d=2, k=8)
#   make sim_a2b_rca_n3   - test with 3 shares (d=3, k=8)
#   make sim_a2b_rca_n4   - test with 4 shares (d=4, k=8)
# ============================================================================

sim_a2b_rca_n2:
	verilator --binary -j 0 -Wno-WIDTHTRUNC --trace \
		./tb/tb_SecA2B_rca.sv --top-module tb_SecA2B_rca \
		-Gd=2 -Ilib -Irca -Itb && ./obj_dir/Vtb_SecA2B_rca

sim_a2b_rca_n3:
	verilator --binary -j 0 -Wno-WIDTHTRUNC --trace \
		./tb/tb_SecA2B_rca.sv --top-module tb_SecA2B_rca \
		-Gd=3 -Ilib -Irca -Itb && ./obj_dir/Vtb_SecA2B_rca

sim_a2b_rca_n4:
	verilator --binary -j 0 -Wno-WIDTHTRUNC --trace \
		./tb/tb_SecA2B_rca.sv --top-module tb_SecA2B_rca \
		-Gd=4 -Ilib -Irca -Itb && ./obj_dir/Vtb_SecA2B_rca


# ============================================================================
# SecCSA (carry‑save adder) test target
# Usage:
#   make sim_csa_n2k8   - test with 2 shares, 8‑bit width
# ============================================================================

sim_csa_n2k8:
	verilator --binary -Wno-WIDTHTRUNC --trace \
		./tb/tb_SecCSA_n_k.sv --top-module tb_SecCSA_n_k \
		-Ilib -Itb
	cd obj_dir && ./Vtb_SecCSA_n_k

# ============================================================================
# SecA2B_CS (C-S representation) test targets
# Usage:
#   make sim_a2b_cs_n3k8   - test n=3, k=8
#   make sim_a2b_cs_n4k8   - test n=4, k=8
# ============================================================================

sim_a2b_cs_n3k8:
	verilator --binary -Wno-WIDTHTRUNC --trace \
		./tb/tb_SecA2B_CS_3_k.sv --top-module tb_SecA2B_CS_3_k \
		-Ilib -Itb
	cd obj_dir && ./Vtb_SecA2B_CS_3_k

sim_a2b_cs_n4k8:
	verilator --binary -Wno-WIDTHTRUNC --trace \
		./tb/tb_SecA2B_CS_4_k.sv --top-module tb_SecA2B_CS_4_k \
		-Ilib -Itb
	cd obj_dir && ./Vtb_SecA2B_CS_4_k


# ============================================================================
# SecA2B (CSA-based) test targets for n=2,3,4
# Usage:
#   make sim_a2b_csa_n2   - test n=2, k=8
#   make sim_a2b_csa_n3   - test n=3, k=8
#   make sim_a2b_csa_n4   - test n=4, k=8
# ============================================================================

sim_a2b_csa_n2:
	verilator --binary -Wno-WIDTHTRUNC --trace \
		./tb/tb_SecA2B_csa.sv --top-module tb_SecA2B_n_k \
		-Gn=2 -Ilib -Icsa -Itb
	cd obj_dir && ./Vtb_SecA2B_n_k

sim_a2b_csa_n3:
	verilator --binary -Wno-WIDTHTRUNC --trace \
		./tb/tb_SecA2B_csa.sv --top-module tb_SecA2B_n_k \
		-Gn=3 -Ilib -Icsa -Itb
	cd obj_dir && ./Vtb_SecA2B_n_k

sim_a2b_csa_n4:
	verilator --binary -Wno-WIDTHTRUNC --trace \
		./tb/tb_SecA2B_csa.sv --top-module tb_SecA2B_n_k \
		-Gn=4 -Ilib -Icsa -Itb
	cd obj_dir && ./Vtb_SecA2B_n_k



