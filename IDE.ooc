import RenderWindow	
use sdl,glew,glu
import glu/Glu
import glew
import sdl/Event,sdl/Sdl
import UI
import TextContent
import Tabbed
import Widget

include ./font/font

initFont: extern func(...)
usleep: extern func(...)

IDE: class {
	
	window := RenderWindow new(1280, 800, 32, false)
	ui := UI new()
	running := false
	
	init: func {
        SDL enableUnicode(1)
		initFont(80,72)
		
		tabbed := Tabbed new(window width,window height)
		tabbed show()
		ui add(tabbed as Widget)
		mainLoop()
	}
	
	quit: func {
		window quit(0)
		printf( "Exited cleanly =)\n")
	}
		
	mainLoop: func {
		running = true
		lastTime := SDL getTicks()
		currentTime := SDL getTicks()
		while(running){
			currentTime = SDL getTicks()
			if (currentTime - lastTime > 15)
			{
				handleEvent()
				ui render()		
				lastTime = currentTime
			}
			else 
			{
				SDL delay(15 - (currentTime - lastTime))
			}

			
		}
		quit()
	}
		
		
	handleEvent: func {
		event: Event
		while ( SDLEvent poll( event& ) ) {
			match( event type ) {
				case SDL_KEYDOWN => {
					match(event key keysym sym) {
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
