use glew,sdl
import glew,sdl/[Sdl,Event]
import structs/LinkedList
import Vector
import Widget
import io/FileReader
include ./font/font

initFont: extern func(...)
renderFont: extern func(...)

TextContent: class extends Widget {
	
	lines := LinkedList<String> new()	//contains all lines
	cachedLines := LinkedList<GLuint> new()
	nline := 0				//variable use for loading and so...
	topLine := 0 			//index of the first visible line
	currentLine := 0		//index of the line containing the cursor, so we can highlight it
	numbersWidth := 0
	file := "Tabbed.ooc"	
	
	
	bgColor := Vector3b new(254,254,254)		//background color
	
	init: func ~textContent (=fill) {
		super()
	}
	
	init: func ~textParent (=fill,=parent) {
		super()
	}
	
	
	_render: func {
		if(fill) {
			if(parent) {
			size = parent csize
			}
		}
		
		nline = 0
		numbersWidth = log10(lines size()) as Int + 1
		bgDraw()
		drawText()
		drawLineNumbers()
	}
	
	drawText: func {
		glPushMatrix()
		glTranslated(numbersWidth * 10,0,0)
		
		for(line in lines) {
			if(nline == currentLine) {
				highDraw()
			}
			rline := ""
			for(i in 0..line length()) {
				if(line[i] == '\t') {
					rline = rline + "    "
				} else {
					rline = rline + line[i]
				}
			}
			glColor3ub(0,0,0)
			renderFont(4,12, 0.2,1,rline)
			glTranslated(0,17,0)
			nline += 1
		}
		glPopMatrix()
	}
	
	
	drawLineNumbers: func {
		
		glPushMatrix()
		glColor3ub(200,200,200)
		glBegin(GL_QUADS)
		glVertex2i(0,0)
		glVertex2i(numbersWidth*10,0)
		glVertex2i(numbersWidth * 10,lines size() * 17 + 10)
		glVertex2i(0,lines size() * 17 + 10)
		glEnd()
		glColor3ub(0,0,64)
		for(i in 0..lines size()) {
			number: Char[4]
			sprintf(number,"%d",i)
			renderFont(1,12,0.2,1,number)
			glTranslated(0,17,0)
		}
		glPopMatrix()
	}
	
	cacheLines: func() {
		i := 0
		for(line in lines) {
			rline := ""
			for(i in 0..line length()) {
				if(line[i] == '\t') {
					rline = rline + "    "
				} else {
					rline = rline + line[i]
				}
			}
			dlist := glGenLists(1)
			cachedLines add(dlist)
			glNewList(dlist, GL_COMPILE)
				renderFont(16,12,0.2,1,rline)
			glEndList()
			i += 1
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
            printf("Also got line %s\n", line)
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
						printf("currentLine: %d\n",currentLine)
						dirty = true
					}
					
					case SDLK_DOWN => {
						currentLine += 1
						if(currentLine > lines lastIndex())
							currentLine = lines lastIndex()
						printf("currentLine: %d\n",currentLine)
						dirty = true
					}
				}
			}
		}
	}
	
	addLine: func(line: String) {
		lines add(line)
	}
	
	readLine: func(filereader: FileReader) -> String{
		i := 0
		line : Char[128]
		c : Char = filereader read()
		while(c != '\n' && filereader hasNext()) {
			line[i] = c
			i += 1
			c = filereader read()
		}
		line[i] = '\0'
        printf("Got line %s\n", line)
		return line as String clone()
	}
	
}
