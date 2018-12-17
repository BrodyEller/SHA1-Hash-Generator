transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+/home/viper/Documents/Quartus\ Workspace/SHA1Hasher_v2 {/home/viper/Documents/Quartus Workspace/SHA1Hasher_v2/SHA1Hasher_v2.sv}

