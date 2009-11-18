use glew,sdl
import glew,sdl/[Sdl,Event]
import structs/LinkedList
import Vector
import Widget
import io/FileReader
import ScrollBar
include ./font/font

initFont: extern func(...)
getFont: extern func(...) -> Pointer
renderFont: extern func(...)
ftglGetFontBBox: extern func(...) -> Pointer

TextContent: class extends Widget {
	
	lines := LinkedList<String> new()	//contains all lines
	cachedLines := LinkedList<GLuint> new()
	nline := 0				//variable use for loading and so...
	topLine := 0 			//index of the first visible line
	bottomLine := 0
	visibleLines := 0
	currentLine := 0		//index of the line containing the cursor, so we can highlight it
	numbersWidth := 0
	lineSpacing := 17
	scrollWidth := 20
	fontWidth := 0.0
	file := "Tabbed.ooc"
	scrollBar := ScrollBar new(this)	
	
	
	bgColor := Vector3b new(254,254,254)		//background color
	
	init: func ~textContent (=fill) {
		super()
		bbox : Float[6]
		ftglGetFontBBox (getFont(), "8", 1, bbox)
		fontWidth = bbox[3]/5
		scrollBar setPos(Vector2i new(size x,0))
		scrollBar setSize(Vector2i new(scrollWidth,size y))
		scrollBar show()
	}
	
	init: func ~textParent (=fill,=parent) {
		super()
		bbox : Float[6]
		ftglGetFontBBox (getFont(), "8", 1, bbox)
		fontWidth = bbox[3]/5
		scrollBar setPos(Vector2i new(size x,0))
		scrollBar setSize(Vector2i new(scrollWidth,size y))
		scrollBar show()
	}
	
	
	_render: func {
		if(fill) {
			if(parent) {
			size = Vector2i new(parent csize)
			}
		}
		
		scrollBar setPos(Vector2i new(size x - scrollWidth,0))
		scrollBar setSize(Vector2i new(scrollWidth,size y))
		
		numbersWidth = log10(lines size()) as Int + 1
		bgDraw()
		//drawText()
		drawCachedText()
		drawLineNumbers()
		scrollBar render()
	}
	
	drawCachedText: func {
		glPushMatrix()
		glTranslated(numbersWidth * 10,0,0)
		visibleLines = (size y / lineSpacing) as Int + 1
		bottomLine = topLine + visibleLines
		if(bottomLine > lines lastIndex()) {
			bottomLine = lines lastIndex()
		}
		iter := cachedLines iterator()
		i := 0
		for(i in 0..topLine) { iter next() }
		i = topLine
		nline = topLine
		while (iter hasNext() && i < bottomLine + 1) {
			line := iter next()
			//printf("drawing line: %s\n",line)
			if(nline == currentLine) {
				highDraw()
			}
			glColor4ub(0,0,0,255)
			glCallList(line)
			glTranslated(0,lineSpacing,0)
			nline += 1
			i+=1
		}
		glPopMatrix()
	}
	
	drawText: func {
		glPushMatrix()
		glTranslated(numbersWidth * 10,0,0)
		visibleLines = (size y / lineSpacing) as Int + 1
		bottomLine = topLine + visibleLines
		if(bottomLine > lines lastIndex()) {
			bottomLine = lines lastIndex()
		}
		iter := lines iterator()
		i := 0
		character : Char[2]
		character[1] = '\0'
		for(i in 0..topLine) { iter next() }
		i = topLine
		nline = topLine
		while (iter hasNext() && i < bottomLine) {
			line := iter next()
			if(nline == currentLine) {
				highDraw()
			}
			glColor4ub(0,0,0,255)
			glPushMatrix()
			for(i2 in 0..line length()) {
				if(line[i2] == '\t') {
					glTranslated((fontWidth + 1)*4,0,0)
				} else if(line[i2] == ' ') {
					glTranslated(fontWidth + 1,0,0)
				} else {
					character[0] = line[i2]
					renderFont(4,12,0.2,1,character)
					glTranslated(fontWidth,0,0)
				}
			}
			glPopMatrix()
			glTranslated(0,lineSpacing,0)
			nline += 1
			i+=1
		}
		glPopMatrix()
	}
	
	
	drawLineNumbers: func {
		glPushMatrix()
		glColor4ub(200,200,200,255)
		glBegin(GL_QUADS)
		glVertex2i(0,0)
		glVertex2i(numbersWidth*10,0)
		glVertex2i(numbersWidth * 10, size y)
		glVertex2i(0,size y)
		glEnd()
		glColor4ub(0,0,64,255)
		for(i in topLine..bottomLine + 1) {
			printf("drawing line numbers: [%d..%d]\n",topLine, bottomLine + 1)
			number: Char[4]
			sprintf(number,"%d",i)
			renderFont(1,12,0.2,1,number)
			glTranslated(0,lineSpacing,0)
		}
		glPopMatrix()
	}
	
	cacheLines: func() {
		cachedLines clear()
		character: Char[2]
		character[1] = '\0'
		for(line in lines) {
			lineSize := 0
			for(i in 0..line length()) {
				if(line[i] == '\t') {
					lineSize += 4
				} else {
					lineSize += 1
				}
			}
			
			rline := String new(lineSize)
			i2 := 0
			for(i in 0..line length()) {
				if(line[i] == '\t') {
					for(n in 0..4) {
						rline[i2] = ' '
						i2 += 1
					}
				} else {
					rline[i2] = line[i]
					i2 += 1
				}
			}
			
			dlist : GLuint = glGenLists(1)
			glNewList(dlist, GL_COMPILE)
			/*glPushMatrix()
			for(i2 in 0..line length()) {
				if(line[i2] == '\t') {
					glTranslated((fontWidth + 1)*4,0,0)
				} else if(line[i2] == ' '){
					glTranslated(fontWidth + 1,0,0)
				}else {
					character[0] = line[i2]
					renderFont(4,12,0.2,1,character )
					glTranslated(fontWidth + 1,0,0)
				}
			}
			glPopMatrix()*/
			renderFont(4,12,0.2,1,rline)
			glEndList()
		
			cachedLines add(dlist)
		}
	}
	
	//functions that draws the line highlighting
	highDraw: func {
		glPushMatrix()
		glColor4ub(200,200,250,255)
		glBegin(GL_QUADS)
		glVertex2i(0,0)
		glVertex2i(size x,0)
		glVertex2i(size x,16)
		glVertex2i(0,16)
		glEnd()
		glPopMatrix()
	}
	
	bgDraw: func {
		glColor4ub(bgColor x, bgColor y, bgColor z,255)
		glBegin(GL_QUADS)
		glVertex2i(0,0)
		glVertex2i(0,size y)
		glVertex2i(size x,size y)
		glVertex2i(size x,0)
		glEnd()
	}
	
	reload: func(=file) {
		printf("Loading %s...\n", file)
		fr := FileReader new(file)
		name = file
		lines clear()
		nline = 0
		while(fr hasNext()) {
			c := fr read()
			if(c == '\n') {
				nline += 1
			}
		}
		fr reset(0)
        
		for(i in 0..nline) {
			line := readLine(fr)
            //printf("Also got line %s\n", line)
			lines add(line)
		}
		fr close()
		cacheLines()
        printf("Finished loading %s (%d lines total)\n", file, lines size())
	}
	handleKeyboardEvent: func (e: Event){}
	handleMouseEvent: func (e: Event){}
	
	handleEvent: func(e: Event) {
		state := SDL getModState()
		match( e type ) {
			case SDL_KEYDOWN => {
				match(e key keysym sym) {
					case SDLK_UP => {
						currentLine -= 1
						if(currentLine < 0)
							currentLine = 0
						//printf("currentLine: %d\n",currentLine)
						dirty = true
					}
					
					case SDLK_DOWN => {
						currentLine += 1
						if(currentLine > lines lastIndex())
							currentLine = lines lastIndex()
						printf("currentLine: %d\n",currentLine)
						dirty = true
					}
					case SDLK_PAGEUP => {
						if(!(state & KMOD_LCTRL || state & KMOD_RCTRL)) {
							topLine -= visibleLines
							if(topLine < 0)
								topLine = 0
							dirty = true
						}
					}
					case SDLK_PAGEDOWN => {
						if(!(state & KMOD_LCTRL || state & KMOD_RCTRL)) {
							topLine += visibleLines
							if(topLine > lines lastIndex())
								topLine = lines lastIndex()
							dirty = true
						}
					}
				}
			}
			case SDL_MOUSEBUTTONUP => {
				if (e button button == SDL_BUTTON_WHEELUP && lines size() > 0) {
					topLine -= 4
					if(topLine < 0) {
						topLine = 0
					}
					dirty = true
				}
				else if (e button button == SDL_BUTTON_WHEELDOWN && lines size() > 0) {
					topLine += 4
					if(topLine > lines lastIndex()) {
						topLine = lines lastIndex()
					}
					dirty = true
				}
			}
		}
	}
	
	addLine: func(line: String) {
		lines add(line)
	}
	
	readLine: func(filereader: FileReader) -> String{
		i := 0
		nChars := 0
		//line : Char[256]
		while(filereader hasNext() && filereader read() != '\n' ) {
			nChars += 1
		}
		
		line : Char[nChars + 1]
		filereader rewind(nChars + 1)
		i = 0
		while(i < nChars) {
			line[i] = filereader read()
			i += 1
		}
		line[i] = '\0'
        
        // skip the '\n'
        filereader read()
        
        //printf("Got line %s\n", line)
		return line as String clone()
	}
	
}

