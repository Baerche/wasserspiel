run:
	cat makefile
	pkill minetest || true
	minetest --go
	#cat ~/.minetest/minetest.conf
	
