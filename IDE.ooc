import RenderWindow	
use sdl,glew,glu
import glu/Glu
import glew
import sdl/Event,sdl/Sdl
usleep: extern func(...)
import UI
import TextContent
import Tabbed
import Widget

include ./font/font

initFont: extern func(...)

IDE: class {
	
	window := RenderWindow new(1680, 1050, 32, false)
	ui := UI new()
	running := false
	
	init: func {
        SDL enableUnicode(1)
		initFont(80,72)
		
		tabbed := Tabbed new(window width,window height)
		tabbed show()
		text1 := TextContent new(true)
		text1 reload("font/main.c")
		text1 show()
		
		text2 := TextContent new(true)
		text2 setName("Nom supeeeee")
		text2 reload("font/font.h")
		text2 show()
		
		tabbed add(text1 as Widget)
		tabbed add(text2 as Widget)
		ui add(tabbed as Widget)
		mainLoop()
	}
	
	quit: func {
		window quit(0)
		printf( "Exited cleanly =)\n")
	}
		
	mainLoop: func {
		running = true
		while(running){
			handleEvent()
			if(ui) {
				ui render()
			}
			usleep(15000)
		}
		quit()
	}
		
		
	handleEvent: func {
		event: Event
		while ( SDLEvent poll( event& ) ) {
			match( event type ) {
				case SDL_KEYDOWN => {
					match(event key keysym sym) {
						case SDLK_ESCAPE => running = false
						case SDLK_F5 => ui refresh()
					}
				}
				
				case SDL_QUIT => running = false
			}
			ui handleEvent(event)
			if(window handleEvent(event&)){
				ui refresh()
			}
		}
	}
}
