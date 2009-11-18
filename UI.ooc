use glew,sdl
import glew
import sdl/[Sdl,Video,Event]
import structs/LinkedList
import Widget
import Vector

UI: class {
	
	widgets := LinkedList<Widget> new()
	id := 100
	mouse := Vector2i new(0,0)
	needsRefresh := true
	
	init: func {
	}
	
	render: func {
		Widget keepDirty = false
		if(Widget dirty) {
			glClear( GL_COLOR_BUFFER_BIT)
		
			glDisable(GL_DEPTH_TEST)
			glMatrixMode( GL_MODELVIEW )
			glLoadIdentity( )
		
			glPushMatrix()
			for(widget in widgets) {
				widget render()
			}
			if(!Widget keepDirty)
				Widget dirty = false
				
			glPopMatrix()
			glFlush()
			SDLVideo glSwapBuffers()
		} 	
	}
	
	refresh: func(w,h: Int) {
		Widget windowWidth = w
		Widget windowHeight = h
		Widget dirty = true
	}
	
	handleEvent: func(e: Event) {
		for(widget in widgets) {
			widget handleEvent(e)
		}
		
		match( e type ) {
			case SDL_MOUSEMOTION => {
				mouse x = e motion x
				mouse y = e motion y
			}
		}
	}
	
	add: func(w: Widget) {
		widgets add(w)
		w id = id
		id += 1
	}

}
