# ============================================================================
# Generic Yosys synthesis script for SecA2B projects
# ============================================================================

# --------------------------------------------------------------------
# Environment variables
# --------------------------------------------------------------------

set IN_FILES       [regexp -all -inline {\S+} $::env(IN_FILES)]
set TOP_MODULE     $::env(TOP_MODULE)
set OUT_BASE       $::env(OUT_BASE)
set LIBERTY        $::env(LIBERTY)

# Optional parameters
if {[info exists ::env(N)]} {
    set N_VAL $::env(N)
} else {
    set N_VAL 2
}

if {[info exists ::env(K)]} {
    set K_VAL $::env(K)
} else {
    set K_VAL 8
}

# --------------------------------------------------------------------
# Output files
# --------------------------------------------------------------------

set VLOG_PRE_MAP   $OUT_BASE/pre.v
set VLOG_POST_MAP  $OUT_BASE/post.v

set JSON_PRE_MAP   $OUT_BASE/pre.json
set JSON_POST_MAP  $OUT_BASE/post.json

set STATS_PRE      $OUT_BASE/stats_pre.txt
set STATS_POST     $OUT_BASE/stats_post.txt

# --------------------------------------------------------------------
# Read RTL
# --------------------------------------------------------------------

foreach file $IN_FILES {
    yosys read_verilog -sv -defer $file
}

# --------------------------------------------------------------------
# Elaborate hierarchy with parameters
# --------------------------------------------------------------------

if {$TOP_MODULE == "SecA2B_n_k"} {

    yosys hierarchy \
        -top $TOP_MODULE \
        -chparam n $N_VAL \
        -chparam k $K_VAL

} else {

    yosys hierarchy \
        -top $TOP_MODULE \
        -chparam k $K_VAL
}

# --------------------------------------------------------------------
# Frontend lowering
# --------------------------------------------------------------------

yosys proc
yosys flatten

# --------------------------------------------------------------------
# Generic synthesis
# --------------------------------------------------------------------

yosys synth -top $TOP_MODULE

yosys opt_expr
yosys opt_clean
yosys clean

# --------------------------------------------------------------------
# Pre-map netlist
# --------------------------------------------------------------------

yosys tee -o $STATS_PRE stat

yosys write_verilog $VLOG_PRE_MAP
yosys write_json    $JSON_PRE_MAP

# --------------------------------------------------------------------
# Technology mapping
# --------------------------------------------------------------------

yosys dfflibmap -liberty $LIBERTY
yosys abc       -liberty $LIBERTY

yosys clean -purge

# --------------------------------------------------------------------
# Post-map netlist
# --------------------------------------------------------------------

yosys tee -o $STATS_POST stat -liberty $LIBERTY

yosys write_verilog $VLOG_POST_MAP
yosys write_json    $JSON_POST_MAP