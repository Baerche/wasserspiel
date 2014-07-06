CMD=(~/freeminer-4.9.3-git/bin/freeminer --config ../tools/my-minetest.conf; xrandr --size 1280x1024)&
CMD=(~/minetest-4.10-git/bin/minetest --config ../tools/my-minetest.conf; xrandr --size 1280x1024)&

run:
	cat makefile
	pkill minetest || true
	pkill freeminer || true
	mkdir -p screenshots
	cd screenshots && $(CMD)
	
	
menu:
	pkill minetest || true
	minetest


