use glew,sdl
import glew,sdl/[Sdl,Event]
import Vector
import structs/LinkedList
import Widget
import InputLine

OpenFileDialog: class extends Widget {
	textField : InputLine
	init: func ~openFileDialog {
		super()
		pos = Vector2i new(200,200)
		size = Vector2i new(400,40)
		cpos = Vector2i new(5,5)
		csize = Vector2i new(size x - 10, size y - 10)
		textField = InputLine new(this)
		hideType = NE_HIDE
		textField show()
	}
	
	handleEvent: func(e: Event) {
		state := SDL getModState()
		match( e type ) {
			case SDL_KEYDOWN => {
				match(e key keysym sym) {
					case SDLK_o => {
						if(state & KMOD_LCTRL || state & KMOD_RCTRL) {
							show()
							dirty = true
						}
					}
					case SDLK_RETURN => {
						hide()
						dirty = true
					}
				}
			}
		}
		textField handleEvent(e)
	}
	
	_render: func {
		bgDraw()
		textField render()
	}
	
	bgDraw: func {
		glColor3ub(128,128,128)
		drawRounded(0,0,size x,size y,5)
	}
}
