use glew,sdl
import glew
import Widget
import sdl/[Sdl,Event]
import Vector

include font/font
renderFont: extern func(...)

InputLine: class extends Widget {
	buffer:= ""
	init: func ~inputLine(=parent) {
		super()
		pos = parent cpos
		size = parent csize
		printf("inputLine got this pos: %d,%d\n",pos x, pos y)
	}
	_render: func {
		bgDraw()
		bufferDraw()
	}
	
	bgDraw: func {
		glColor3ub(255,255,255)
		drawQuad(0,0, size x, size y)
	}
	
	bufferDraw: func {
		glPushMatrix()
		glColor3ub(0,0,0)
		glTranslated(0,5,0)
		renderFont(1,12,0.2,1,buffer)
		glPopMatrix()
	}
	
	handleEvent: func(e: Event) {
		state := SDL getModState()
		match( e type ) {
			case SDL_KEYDOWN => {
				/*match(e key keysym sym) {
					case SDLK_o => {
						
					}
				}*/
				if(e key keysym sym >= SDLK_LEFTBRACKET && e key keysym sym <= SDLK_z && !(state & KMOD_LCTRL || state & KMOD_RCTRL)) {
					buffer = buffer + e key keysym sym as Char 
				}
			}
		}
	}
}
