use glew,sdl
import glew,sdl/[Sdl,Event]
import io/File
import Vector
import structs/LinkedList
import Widget
import InputLine
import Tabbed
import TextContent

OpenFileDialog: class extends Widget {
    
    tabbed : Tabbed
	textField : InputLine
	init: func ~openFileDialog (=tabbed) {
		super()
		pos = Vector2i new(200, 200)
		size = Vector2i new(400, 35)
		cpos = Vector2i new(5, 5)
		csize = Vector2i new(size x - 10, size y - 10)
		textField = InputLine new(this)
		hideType = NE_HIDE
		modal = true
		textField show()
	}
	
	handleKeyboardEvent: func(e: Event) {}
	handleMouseEvent: func(e: Event) {}
	
	handleEvent: func(e: Event) {
		if(!_show) return

        //state := SDL getModState()
		match( e type ) {
			case SDL_KEYDOWN => {
				match(e key keysym sym) {
					case SDLK_RETURN => {
                        hide()
                        f := File new(textField buffer)
                        if(f exists() && f isFile()) {
                            text := TextContent new(true)
                            text reload(textField buffer)
                            text show()
                            tabbed add(text)
                        } else {
                            printf("%s doesn't exist or is not a file! Abandon..\n", textField buffer)
                        }
						dirty = true
					}
					case SDLK_ESCAPE => {
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
		glColor4ub(200,200,250,128)
		drawRounded(0,0,size x,size y,5)
	}
}
