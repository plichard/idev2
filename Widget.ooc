use glew,sdl,glu
import glew,sdl/[Sdl,Event],glu/Glu
import Vector

include ./font/font
initFont: extern func(...)

NORMAL_HIDE := 0
NE_HIDE := 1

Widget: abstract class {
	foundFocus : static Bool = true
	dirty : static Bool = false
	keepDirty : static Bool = false
	pos := Vector2i new(0,0)
	size := Vector2i new(0,0)
	
	cpos := Vector2i new(0,0)  //position of a child widget, if available
	csize := Vector2i new(200,200) //space avalaible to a child widget, if any
	
	scale := Vector2d new(1,1)
	_show := false
	parent: Widget = null
	fill := false
	name := "<unknown>"
	focused := false
	hovered := false
	modal := false
	id : Int
	
	step := 0.0
	nstep := 10.0
	
	hideType := NORMAL_HIDE
	
	
	init: func ~widget() {
		
	}
	
	setName: func(=name) {}
	
	setSize: func(=size) { dirty = true}
	
	setPos: func(=pos) {dirty = true}
	
	_render: abstract func()
	
	render: func {
		if(_show ) {
			glPushMatrix()
			if(modal) {
				printf("step: %1.0f\n",step)
				if(step > 0) {
					glColor4d(0,0,0,(nstep - step)/nstep / 2.0 )
				} else if(step < 0) {
					glColor4d(0,0,0,-step/nstep /2.0)
				} else {
					glColor4d(0,0,0,0.5)
				}
				drawQuad(0,0,1280,800)
			}
			if(hideType != NORMAL_HIDE) {
				animHide()
			} else {
				glTranslated(pos x, pos y, 0)
			}
			_render()
			glPopMatrix()
		}
	}
	
	handleEvent: abstract func(e: Event)
	
	show: func {
		if(hideType == NORMAL_HIDE) {
			_show = true
		} else if(_show == false){
			step = nstep
			_show = true
			keepDirty = true
		}
	}
	
	hide: func {
		if(hideType == NORMAL_HIDE) {
			_show = false
		} else if(_show == true){
			step = -nstep
			_show = true
			keepDirty = true
		}
	}
	
	animHide: func {
		if(step > 0) {
			step -= 1
			s : Double = (nstep - step) / nstep
			glScaled(s,s,s)
			glTranslated(pos x * s,pos y * s,0)
			keepDirty = true
		} else if (step < 0) {
			step += 1
			s : Double = -step / nstep
			glScaled(s,s,s)
			glTranslated(pos x * s,pos y * s,0)
			keepDirty = true
			step == 0? _show = false : 0
		} else {
			glTranslated(pos x, pos y, 0)
		}
	}	
	
	scroll: func (pixels: Int) {
		printf("Warning: %s does not implement scroll\n",class name)
	}
	
}


drawQuad: func(x,y,w,h: Int) {
	glBegin(GL_QUADS)
	glVertex2i(x,y)
	glVertex2i(x+w,y)
	glVertex2i(x+w,y+h)
	glVertex2i(x,y+h)
	glEnd()
}

drawRounded: func(x,y,w,h,r: Int) {  //position, size, rounding radius
	glPushMatrix()
	drawQuad(0,r,w,h-r-r)
	drawQuad(r,0,w-r-r,h)
	radius := r as Double
	nstep := 10.0
	i := 0.0
	//degree * 0.0174532925 = radian
	//draw upper left round
	glBegin(GL_TRIANGLE_FAN)
	glVertex2d(r,r)
	for(i = 90.0 ; i <= 180.0; i += 90.0/nstep) {
		glVertex2d(cos(i*0.0174532925)*radius + radius, -sin(i*0.0174532925)*radius + radius)
	}
	glEnd()
	//draw lower left round
	glBegin(GL_TRIANGLE_FAN)
	glVertex2d(r,h-r)
	for(i = 90.0 ; i <= 180.0; i += 90.0/nstep) {
		glVertex2d(cos(i*0.0174532925)*radius + radius, sin(i*0.0174532925)*radius + h - radius)
	}
	glEnd()
	//draw upper right round
	glBegin(GL_TRIANGLE_FAN)
	glVertex2d(w-r,r)
	for(i = 0.0 ; i <= 90.0; i += 90.0/nstep) {
		glVertex2d(cos(i*0.0174532925)*radius + w - radius, -sin(i*0.0174532925)*radius + radius)
	}
	glEnd()
	
	glBegin(GL_TRIANGLE_FAN)
	glVertex2d(w-r,h-r)
	for(i = 0.0 ; i <= 90.0; i += 90.0/nstep) {
		glVertex2d(cos(i*0.0174532925)*radius + w - radius, sin(i*0.0174532925)*radius + h - radius)
	}
	glEnd()
	glPopMatrix()
}

