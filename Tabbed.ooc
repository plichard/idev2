use glew,sdl
import glew,sdl/[Sdl,Event]
import Vector
import Widget
import structs/LinkedList
import OpenFileDialog

include ./font/font
renderFont: extern func(...)
getFont: extern func(...)  -> Pointer
ftglGetFontBBox: extern func(...)

Tabbed: class extends Widget {
	tabs := LinkedList<Widget> new()
	tabHeight := 20
	tabWidth := 100
	onTabC := Vector3b new(255,255,255)
	offTabC := Vector3b new(128,128,128)
	focus := -1
	dialog := OpenFileDialog new()
	
	init: func ~tabbed (x,y: Int){
		super()
		size = Vector2i new(x,y)
		csize = Vector2i new(x,y - tabHeight)
		dialog _show = false
	}
	
	setHeight: func(=tabHeight) {}
	
	_render: func {
		glPushMatrix()
		ntab := 0
		for(tab in tabs) {
			bbox : Float[6]
			ftglGetFontBBox (getFont(), tab name, tab name length(), bbox)
			tabWidth = bbox[3]/5 + 30
			if(ntab == focus) {
				glColor3ub(onTabC x,onTabC y,onTabC z)
			} else {
				glColor3ub(offTabC x,offTabC y,offTabC z)
			}
			
			glBegin(GL_QUADS)
			glVertex2i(0,0)
			glVertex2i(tabWidth,0)
			glVertex2i(tabWidth,tabHeight)
			glVertex2i(0,tabHeight)
			glEnd()
			glColor3ub(0,0,0)
			renderFont(0,16,0.2,1,tab name)
			
			glTranslated(tabWidth,0,0)
			ntab += 1
		}
		glPopMatrix()
		
		glTranslated(0,tabHeight,0)
		if(focus >= 0) {
			tabs[focus] render()
		}
		dialog render()
	}
	
	add: func(w: Widget) {
		tabs add(w)
		w parent = this
		focus = tabs lastIndex()
	}
	
	handleEvent: func(e: Event) {
		state := SDL getModState()
		if(!dialog _show) {
			match( e type ) {
				case SDL_KEYDOWN => {
					match(e key keysym sym) {
						//case SDLK_LEFT =>  {focus -= 1; focus < 0? focus = 0:0}
						//case SDLK_RIGHT => {focus += 1; focus > tabs lastIndex()? focus = tabs lastIndex():0}
						case SDLK_PAGEUP => {
							if(state & KMOD_LCTRL || state & KMOD_RCTRL) {
								focus -= 1; focus < 0? focus = tabs lastIndex(): 0 
								dirty = true
							}
						}
						case SDLK_PAGEDOWN => {
							if(state & KMOD_LCTRL || state & KMOD_RCTRL) {
								focus += 1; focus > tabs lastIndex()? focus = 0:0
								dirty = true
							}
						}
					}
				}
			}
			for(tab in tabs) {
				tab handleEvent(e)
			}
		}
		dialog handleEvent(e)
		//printf("dialog show: %d\n",dialog _show)
	}
}
