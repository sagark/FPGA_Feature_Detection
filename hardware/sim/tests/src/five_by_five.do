set MODULE five_by_five_testbench
start $MODULE
add wave $MODULE/*
add wave $MODULE/dut/*
run 100000us
