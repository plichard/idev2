use glew,sdl
import glew
import Widget
import sdl/[Sdl,Event]
import Vector

include ./font/font
renderFont: extern func(...)
getFont: extern func(...)  -> Pointer
ftglGetFontBBox: extern func(...)

InputLine: class extends Widget {
    
    caretStart = 0, caretEnd = 0 : Int
    
    fakeBuffer := "88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888"
	buffer := ""
    
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
		glTranslated(0, 5, 0)
		renderFont(1, 12, 0.2, 1, buffer)
        
        // draw caret
        if(caretStart > 0) {
            bbox : Float[6]
            ftglGetFontBBox (getFont(), fakeBuffer, caretStart, bbox)
            textWidth : Float = (bbox[3] / 5)
            glTranslated(textWidth - 2, 0, 0)
        }
        renderFont(1, 12, 0.2, 1, "|")
        
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
                ch := e key keysym sym as Char
                // haha c'est tout moche.
				if((ch >= SDLK_SPACE && ch <= SDLK_z && e key keysym sym != SDLK_LSHIFT && e key keysym sym != SDLK_RSHIFT) && !((state & KMOD_LCTRL) || (state & KMOD_RCTRL))) {
                    if(state & KMOD_SHIFT) {
                        ch -= (97 - 65)
                    }
                    if(caretStart == buffer length()) {
                        buffer = buffer + ch
                    } else {
                        buffer = buffer substring(0, caretStart) + ch + buffer substring(caretStart, buffer length())
                    }
                    caretStart += 1
                    dirty = true
				} else if(ch == SDLK_BACKSPACE && caretStart > 0) {
                    buffer = buffer substring(0, caretStart - 1) + buffer substring(caretStart, buffer length())
                    caretStart -= 1
                    dirty = true
                } else if(ch == SDLK_DELETE && caretStart < buffer length()) {
                    buffer = buffer substring(0, caretStart) + buffer substring(caretStart + 1, buffer length())
                    dirty = true
                } else if(e key keysym sym == SDLK_RIGHT && caretStart < buffer length() ) {
                    caretStart += 1
                    dirty = true
                } else if(e key keysym sym == SDLK_LEFT && caretStart > 0) {
                    caretStart -= 1
                    dirty = true
                } else if(e key keysym sym == SDLK_HOME) {
                    caretStart = 0
                    dirty = true
                } else if(e key keysym sym == SDLK_END) {
                    caretStart = buffer length()
                    dirty = true
                }
			}
		}
	}
}
