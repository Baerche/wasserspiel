CMD=(~/minetest-4.10-git/bin/minetest --config ../tools/my-minetest.conf; xrandr --size 1280x1024)&

CMD=(~/freeminer-4.9.3-git/bin/freeminer --config ../tools/my-minetest.conf --name debugger --password "" --worldname 'welt' --go)&
CMD=(~/freeminer-4.9.3-git/bin/freeminer --config ../tools/my-minetest.conf; xrandr --size 1280x1024)&

CMD=(minetest --config ../tools/my-minetest.conf; xrandr --size 1280x1024)&
CMD=(minetest --config ../tools/my-minetest.conf --name debugger --password "" --worldname '410welt' --go; xrandr --size 1280x1024)&
CMD=(minetest --config ../tools/my-minetest.conf --name debugger --password "" --worldname '410welt' --go)&
CMD=(minetest --config ../tools/my-minetest.conf)&

run:
	cat makefile
	pkill minetest || true
	pkill freeminer || true
	mkdir -p screenshots
	cd screenshots && $(CMD)
	
menu:
	minetest --config tools/my-minetest.conf


