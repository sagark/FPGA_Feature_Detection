set MODULE octaveTestbench2
start $MODULE
add wave $MODULE/*
add wave $MODULE/dut/*
run 100000us
