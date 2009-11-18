use sdl,glew
import glew
import sdl/[Sdl,Event]
import Widget
import Vector

ScrollBar: class extends Widget {
	
	minValue := 0
	maxValue := 0
	currentvalue := 0

	init: func ~scrollBar (=parent){
		super()
	}
	
	setMin: func(=minValue) {dirty = true}
	setMax: func(=maxValue) {dirty = true}
	setMinMax: func(=minValue,=maxValue) {dirty = true}
	setVal: func(=currentvalue) {dirty = true}
	
	_render: func {
		glColor4ub(128,128,128,128)
		printf("Drawing scrollbar at: %d,%d\n",pos x,pos y)
		drawRounded(0, 0, size x, size y,size x / 2)
	}
	
	handleEvent: func(e: Event) {
	}
}
