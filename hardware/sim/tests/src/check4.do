set MODULE Check4Test
start $MODULE
add wave $MODULE/*
add wave $MODULE/dut/*
run 9000us
