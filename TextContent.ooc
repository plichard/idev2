use glew,sdl
import glew,sdl/[Sdl,Event]
import structs/LinkedList
import Vector
import Widget
import io/FileReader
include ./font/font

initFont: extern func(...)
getFont: extern func(...) -> Pointer
renderFont: extern func(...)
ftglGetFontBBox: extern func(...) -> Pointer

TextContent: class extends Widget {
	
	lines := LinkedList<String> new()	//contains all lines
	cachedLines := LinkedList<String> new()
	nline := 0				//variable use for loading and so...
	topLine := 0 			//index of the first visible line
	bottomLine := 0
	visibleLines := 0
	currentLine := 0		//index of the line containing the cursor, so we can highlight it
	numbersWidth := 0
	lineSpacing := 17
	fontWidth := 0.0
	file := "Tabbed.ooc"	
	
	
	bgColor := Vector3b new(254,254,254)		//background color
	
	init: func ~textContent (=fill) {
		super()
		bbox : Float[6]
		ftglGetFontBBox (getFont(), "8", 1, bbox)
		fontWidth = bbox[3]/5
	}
	
	init: func ~textParent (=fill,=parent) {
		super()
		bbox : Float[6]
		ftglGetFontBBox (getFont(), "8", 1, bbox)
		fontWidth = bbox[3]/5
	}
	
	
	_render: func {
		if(fill) {
			if(parent) {
			size = parent csize
			}
		}
		
		
		numbersWidth = log10(lines size()) as Int + 1
		bgDraw()
		drawText()
		drawLineNumbers()
	}
	
	drawText: func {
		glPushMatrix()
		glTranslated(numbersWidth * 10,0,0)
		visibleLines = (size y / lineSpacing) as Int + 1
		bottomLine = topLine + visibleLines
		if(bottomLine > lines lastIndex())
			bottomLine = lines lastIndex()
		iter := lines iterator()
		i := 0
		//printf("we got %d visible lines\n",bottomLine - topLine)
		//printf("topline: %d\n",topLine)
		//printf("bottomline: %d\n",bottomLine)
		//printf("fontwidth: %d\n",fontWidth)
		//printf("")
		character : Char[2]
		character[1] = '\0'
		for(i in 0..topLine) { iter next() }
		i = topLine
		nline = topLine
		while (iter hasNext() && i < bottomLine) {
			line := iter next()
			//printf("drawing line: %s\n",line)
			if(nline == currentLine) {
				highDraw()
			}
			glColor3ub(0,0,0)
			glPushMatrix()
			for(i2 in 0..line length()) {
				if(line[i2] == '\t') {
					renderFont(4,12,0.2,1,"    ")
					glTranslated(fontWidth*4,0,0)
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
		glColor3ub(200,200,200)
		glBegin(GL_QUADS)
		glVertex2i(0,0)
		glVertex2i(numbersWidth*10,0)
		glVertex2i(numbersWidth * 10,lines size() * lineSpacing + 10)
		glVertex2i(0,lines size() * lineSpacing + 10)
		glEnd()
		glColor3ub(0,0,64)
		for(i in topLine..bottomLine) {
			number: Char[4]
			sprintf(number,"%d",i)
			renderFont(1,12,0.2,1,number)
			glTranslated(0,lineSpacing,0)
		}
		glPopMatrix()
	}
	
	cacheLines: func() {
		cachedLines clear()
		for(line in lines) {
			lineSize := 0
			for(n := 0;n<line length();n += 1) {
				if(line[n] == '\t') {
					lineSize += 4
				} else {
					lineSize += 1
				}
			}
			rline := String new(lineSize)
			ri := 0
			for(i in 0..lineSize) {
				if(line[i] == '\t') {
					for(n in 0..4) {
						rline[ri+n] = ' '
					}
					ri += 4
				} else {
					rline[ri] = line[i]
					ri += 1
				}
			}
			rline[lineSize - 1] = '\0'
			cachedLines add(rline)	
		}
	}
	
	//functions that draws the line highlighting
	highDraw: func {
		glPushMatrix()
		glColor3ub(200,200,250)
		glBegin(GL_QUADS)
		glVertex2i(0,0)
		glVertex2i(size x,0)
		glVertex2i(size x,16)
		glVertex2i(0,16)
		glEnd()
		glPopMatrix()
	}
	
	bgDraw: func {
		glColor3ub(bgColor x, bgColor y, bgColor z)
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
        printf("Finished loading %s (%d lines total)\n", file, lines size())
	}
	
	handleEvent: func(e: Event) {
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
						//printf("currentLine: %d\n",currentLine)
						dirty = true
					}
				}
			}
			case SDL_MOUSEBUTTONUP => {
				if (e button button == SDL_BUTTON_WHEELUP && topLine > 3) {
					topLine -= 4
					dirty = true
				}
				else if (e button button == SDL_BUTTON_WHEELDOWN && topLine < lines lastIndex() - 3) {
					topLine += 4
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
		c : Char = filereader read()
		while(c != '\n' && filereader hasNext()) {
			nChars += 1
			c = filereader read()
		}
		
		line : Char[nChars + 2]
		filereader rewind(nChars + 1)
		c = filereader read()
		i = 0
		while(i < nChars ) {
			line[i] = c
			i += 1
			c = filereader read()
		}
		line[i] = '\0'
        //printf("Got line %s\n", line)
		return line as String clone()
	}
	
}
