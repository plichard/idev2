all:
	ooc main.ooc -shout ${OOC_FLAGS} -driver=sequence -noclean +-I/usr/include/freetype2 -lftgl +font/font.lib
