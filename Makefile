all:
	ooc main.ooc -shout ${OOC_FLAGS} -noclean +-I/usr/include/freetype2 -lftgl +font/font.lib
