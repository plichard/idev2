use glew,sdl
import glew,sdl/[Sdl,Event]
import Vector
import Widget
import structs/LinkedList
import OpenFileDialog
import TextContent

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
	dialog := OpenFileDialog new(this)
	tabsHovered := false
	
	init: func ~tabbed (x,y: Int){
		super()
		size = Vector2i new(Widget windowWidth,Widget windowHeight)
		csize = Vector2i new(size x,size y - tabHeight)
		//printf("Tabbed[%p] has a csize of: %d,%d \n",this,csize x, csize y)
		dialog _show = false
	}
	
	setHeight: func(=tabHeight) {}
	
	_render: func {
		size = Vector2i new(Widget windowWidth,Widget windowHeight)
		csize = Vector2i new(size x,size y - tabHeight)
		glPushMatrix()
		ntab := 0
		for(tab in tabs) {
			bbox : Float[6]
			ftglGetFontBBox (getFont(), tab name, tab name length(), bbox)
            // bbox[3] = font width
            // / 5 because we scale 5x after
            // 30px right margin for the icon to come.
			tabWidth = bbox[3]/5 + 30
			if(ntab == focus) {
				glColor4ub(onTabC x,onTabC y,onTabC z,255)
			} else {
				glColor4ub(offTabC x,offTabC y,offTabC z,255)
			}
			
			glBegin(GL_QUADS)
			glVertex2i(0,0)
			glVertex2i(tabWidth, 0)
			glVertex2i(tabWidth, tabHeight)
			glVertex2i(0, tabHeight)
			glEnd()
			glColor4ub(0, 0, 0, 255)
			renderFont(0, 17, 0.2, 1, tab name)
			
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
	
	newTextTab: func {
		tab := TextContent new(true,this)
		tab show()
		tabs add(tab)
		focus = tabs lastIndex()
	}
    
    removeAt: func (index: Int) {
		if(index >= 0 && index <= tabs lastIndex()) {
			tabs removeAt(index)
			if(focus >= tabs size()) {
				focus -= 1
			}
		}
    }
    
    handleKeyboardEvent: func(e: Event) {}
	handleMouseEvent: func(e: Event) {}
	
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
                        case SDLK_w => {
                            if(state & KMOD_LCTRL || state & KMOD_RCTRL) {
                                removeAt(focus)
                                dirty = true
                            }
                        }
                        case SDLK_t => {
                            if(state & KMOD_LCTRL || state & KMOD_RCTRL) {
                                newTextTab()
                                dirty = true
                            }
                        }
                        case SDLK_o => {
                            if(state & KMOD_LCTRL || state & KMOD_RCTRL) {
                                dialog show()
                                dirty = true
                            }
                        }
					}
				}
				case SDL_MOUSEMOTION => {
					hoverTab(e motion x, e motion y)
				}
				case SDL_MOUSEBUTTONUP => {
					if (e button button == SDL_BUTTON_WHEELUP && tabsHovered) {
						focus -= 1; focus < 0? focus = tabs lastIndex(): 0 
						dirty = true
					}
					else if (e button button == SDL_BUTTON_WHEELDOWN && tabsHovered) {
						focus += 1; focus > tabs lastIndex()? focus = 0:0
						dirty = true
					}
				}
			}
			if(focus >= 0) {
				tabs get(focus) handleEvent(e)
			}
		}
		dialog handleEvent(e)
		//printf("dialog show: %d\n",dialog _show)
	}
	
	hoverTab: func(x,y: Int) {
		absPos := getAbsPos()
		if(y > absPos y && y < absPos y + tabHeight) {
			tabsHovered = true
			dirty = true
			for(tab in tabs) {
				bbox : Float[6]
				ftglGetFontBBox (getFont(), tab name, tab name length(), bbox)
				// bbox[3] = font width
				// / 5 because we scale 5x after
				// 30px right margin for the icon to come.
				tabWidth = bbox[3]/5 + 30
			}
		} else {
			tabsHovered = false
		}
	}
	
}
