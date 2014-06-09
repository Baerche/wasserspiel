run:
	cat makefile
	pkill minetest || true
	
	#minetest --go
	minetest --gameid minetest --worldname "1" --go
	#cat ~/.minetest/minetest.conf
	
menu:
	pkill minetest || true
	minetest


