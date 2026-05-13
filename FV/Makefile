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


# ============================================================================
# Formal Verification Flow for SecA2B (RCA/KSA/CSA) with Yosys + SILVER
# ============================================================================

YOSYS      ?= yosys
LIBERTY    ?= /home/lucien/git/ProverNG/yosys/LIB/custom_cells.lib
SILVER_ENC ?= python ./make_silver_new.py

SPEC_DIR   := spec
SYN_DIR    := syn

TYPES := csa ksa rca
N_VALS := 2 3 4
K_VALS := 4 8 16
# Define source file set at the beginning of the file
DESIGN_DIRS := csa ksa rca lib
# Collect all .sv files (excluding testbenches)
SRC_FILES := $(shell find $(DESIGN_DIRS) -maxdepth 1 -type f -name "*.sv" ! -name "tb_*.sv")
# Collect .v files from lib (e.g., MSKand_hpc2.v)
SRC_FILES += $(wildcard lib/*.v)
# Remove duplicates and convert to space-separated format
SRC_FILES := $(sort $(SRC_FILES))
# ------------------------------------------------------------------------
# Generate spec files (k=4,8,16)
# ------------------------------------------------------------------------
$(SPEC_DIR)/k%_spec.json:
	mkdir -p $(SPEC_DIR)
	@echo '{' > $@
	@echo '    "ina" : {"type": "S", "len": $*},' >> $@
	@echo '    "out" : {"type": "O", "len": $*},' >> $@
	@echo '    "rnd" : {"type": "M", "len": "?"},' >> $@
	@echo '    "clk": {"type": 1, "len": 1}' >> $@
	@echo '}' >> $@

# ------------------------------------------------------------------------
# Define rule for building a single configuration (no eval pollution)
# ------------------------------------------------------------------------
define build_one
syn/$(1)/n$(2)/k$(3)/.done: $(SPEC_DIR)/k$(3)_spec.json
	mkdir -p $$(dir $$@)
	@echo "=== Synthesizing $(1) n=$(2) k=$(3) ==="
	$(eval TOP := $(if $(filter csa,$(1)),SecA2B_n_k,SecA2B_$(2)_k))
	# Collect all .sv files under the current type directory (including recursive dependencies like SecA2B_1_k.sv)
	$(eval DESIGN_FILES := $(shell find $(1) -maxdepth 1 -type f -name "*.sv" 2>/dev/null | sort))
	$(eval LIB_FILES := $(wildcard lib/*.sv lib/*.v))
	$(eval SRC_FILES := $(DESIGN_FILES) $(LIB_FILES))
	@echo "Source files: $(SRC_FILES)"
	export IN_FILES="$(SRC_FILES)"; \
	export TOP_MODULE="$(TOP)"; \
	export OUT_BASE="syn/$(1)/n$(2)/k$(3)/"; \
	export LIBERTY="$(LIBERTY)"; \
	export N="$(2)"; \
	export K="$(3)"; \
	$(YOSYS) -c synth.tcl -l "syn/$(1)/n$(2)/k$(3)/log.txt"
	$(SILVER_ENC) --spec $(SPEC_DIR)/k$(3)_spec.json --circ syn/$(1)/n$(2)/k$(3)/post.json > syn/$(1)/n$(2)/k$(3)/circuit.nl
	touch $$@
endef

# Expand all combinations
$(foreach t,$(TYPES),\
  $(foreach n,$(N_VALS),\
    $(foreach k,$(K_VALS),\
      $(eval $(call build_one,$(t),$(n),$(k)))\
    )\
  )\
)

.PHONY: all clean specs syn-all

all: syn-all

specs: $(foreach k,$(K_VALS),$(SPEC_DIR)/k$(k)_spec.json)

syn-all: $(foreach t,$(TYPES),$(foreach n,$(N_VALS),$(foreach k,$(K_VALS),syn/$(t)/n$(n)/k$(k)/.done)))

clean:
	rm -rf $(SYN_DIR) $(SPEC_DIR)