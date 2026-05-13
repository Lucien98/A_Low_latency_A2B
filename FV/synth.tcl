set IN_FILES       [regexp -all -inline {\S+} $::env(IN_FILES)]
set TOP_MODULE     $::env(TOP_MODULE)
set OUT_BASE       $::env(OUT_BASE)
set LIBERTY        $::env(LIBERTY)

set VLOG_PRE_MAP   $OUT_BASE/pre.v
set VLOG_POST_MAP  $OUT_BASE/post.v
set JSON_PRE_MAP   $OUT_BASE/pre.json
set JSON_POST_MAP  $OUT_BASE/post.json
set STATS_FILE     $OUT_BASE/stats.txt

foreach file $IN_FILES {
    yosys read_verilog -sv -defer $file
}

set k_val 8
if {[info exists ::env(K)] && [string length $::env(K)] > 0} {
    set k_val $::env(K)
}

# Only set parameter k (all modules have this parameter)
yosys hierarchy -top $TOP_MODULE -chparam k $k_val

# If the top module is SecA2B_n_k, also set parameter n
if {[string match "SecA2B_n_k" $TOP_MODULE] && [info exists ::env(N)]} {
    set n_val $::env(N)
    # Note: chparam syntax is -set <param_name> <value> <module>
    yosys chparam -set n $n_val $TOP_MODULE
}

yosys proc
yosys flatten
yosys synth -top $TOP_MODULE -flatten
yosys simplemap
yosys opt_expr
yosys opt_clean
yosys tee -o $STATS_FILE stat
yosys clean
yosys stat

yosys write_verilog $VLOG_PRE_MAP
yosys write_json    $JSON_PRE_MAP

yosys dfflibmap -liberty $LIBERTY
yosys abc -liberty $LIBERTY
yosys clean -purge

yosys write_verilog $VLOG_POST_MAP
yosys write_json    $JSON_POST_MAP
yosys tee -o $STATS_FILE stat -liberty $LIBERTY