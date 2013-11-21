set MODULE Check4Test
start $MODULE
add wave $MODULE/*
add wave $MODULE/dut/*
run 2000us
