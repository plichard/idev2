/* InputLine source file, generated with ooc */
#include "InputLine.h"
#include <out/glew.h>
#include <ooc-sdl/sdl/Sdl.h>
#include <ooc-sdl/sdl/Event.h>
#include <idev2/Vector.h>

void InputLine___defaults___impl(struct _InputLine *this){
	Widget___defaults___impl((Widget *) this);
	#line 14 "./InputLine.ooc"
	this->caretStart = 0;
	#line 14 "./InputLine.ooc"
	this->caretEnd = 0;
	#line 16 "./InputLine.ooc"
	this->fakeBuffer = "88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888";
	#line 17 "./InputLine.ooc"
	this->buffer = "";
}

void InputLine___destroy___impl(struct _InputLine *this){
}

void InputLine_init_inputLine_impl(struct _InputLine *this, struct _Widget *parent){
	#line 19 "./InputLine.ooc"
	((Widget*) this)->parent = parent;
	#line 20 "./InputLine.ooc"
	Widget_init_widget((struct _Widget *) this);
	#line 21 "./InputLine.ooc"
	((Widget*) this)->pos = parent->cpos;
	#line 22 "./InputLine.ooc"
	((Widget*) this)->size = parent->csize;
	#line 23 "./InputLine.ooc"
	printf("inputLine got this pos: %d,%d\n", ((Widget*) this)->pos->x, ((Widget*) this)->pos->y);
}

void InputLine__render_impl(struct _InputLine *this){
	#line 26 "./InputLine.ooc"
	InputLine_bgDraw(this);
	#line 27 "./InputLine.ooc"
	InputLine_bufferDraw(this);
}

void InputLine_bgDraw_impl(struct _InputLine *this){
	#line 31 "./InputLine.ooc"
	glColor3ub(((unsigned char) (255)), ((unsigned char) (255)), ((unsigned char) (255)));
	#line 32 "./InputLine.ooc"
	drawQuad(0, 0, ((Widget*) this)->size->x, ((Widget*) this)->size->y);
}

void InputLine_bufferDraw_impl(struct _InputLine *this){
	#line 36 "./InputLine.ooc"
	glPushMatrix();
	#line 37 "./InputLine.ooc"
	glColor3ub(((unsigned char) (0)), ((unsigned char) (0)), ((unsigned char) (0)));
	#line 38 "./InputLine.ooc"
	glTranslated(((double) (0)), ((double) (5)), ((double) (0)));
	#line 39 "./InputLine.ooc"
	renderFont(1, 12, 0.2, 1, this->buffer);
	#line 42 "./InputLine.ooc"
	if (this->caretStart > 0){
		#line 43 "./InputLine.ooc"
		float bbox[6];
		#line 44 "./InputLine.ooc"
		ftglGetFontBBox(getFont(), this->fakeBuffer, this->caretStart, bbox);
		#line 45 "./InputLine.ooc"
		float textWidth = (bbox[3] / 5);
		#line 46 "./InputLine.ooc"
		glTranslated(((double) (textWidth - 2)), ((double) (0)), ((double) (0)));
	}
	#line 48 "./InputLine.ooc"
	renderFont(1, 12, 0.2, 1, "|");
	#line 50 "./InputLine.ooc"
	glPopMatrix();
}

void InputLine_handleEvent_impl(struct _InputLine *this, SDL_Event e){
	#line 54 "./InputLine.ooc"
	int state = (int) SDL_getModState();
	#line 55 "./InputLine.ooc"
	if (((e.type)) == (SDL_KEYDOWN)){
		
		{
			#line 62 "./InputLine.ooc"
			int ch = e.key.keysym.sym;
			#line 64 "./InputLine.ooc"
			if ((ch >= SDLK_SPACE && ch <= SDLK_z && ch != SDLK_LSHIFT && e.key.keysym.sym != SDLK_RSHIFT) && !((state & KMOD_LCTRL) || (state & KMOD_RCTRL))){
				#line 65 "./InputLine.ooc"
				if (state & KMOD_SHIFT){
					#line 66 "./InputLine.ooc"
					ch -= (97 - 65);
				}
				#line 72 "./InputLine.ooc"
				if (this->caretStart == (size_t) String_length(this->buffer)){
					#line 73 "./InputLine.ooc"
					this->buffer = __OP_ADD_String_Char__String(this->buffer, ((char) (ch)));
				}
				#line 74 "./InputLine.ooc"
				else {
					#line 75 "./InputLine.ooc"
					this->buffer = __OP_ADD_String_String__String(String_substring(this->buffer, 0, this->caretStart), __OP_ADD_Char_String__String(((char) (ch)), String_substring(this->buffer, this->caretStart, (size_t) String_length(this->buffer))));
				}
				#line 77 "./InputLine.ooc"
				this->caretStart += 1;
				#line 78 "./InputLine.ooc"
				((WidgetClass*) Widget_class())->dirty = true;
			}
			#line 79 "./InputLine.ooc"
			else if (ch == SDLK_BACKSPACE && this->caretStart > 0){
				#line 80 "./InputLine.ooc"
				this->buffer = __OP_ADD_String_String__String(String_substring(this->buffer, 0, this->caretStart - 1), String_substring(this->buffer, this->caretStart, (size_t) String_length(this->buffer)));
				#line 81 "./InputLine.ooc"
				this->caretStart -= 1;
				#line 82 "./InputLine.ooc"
				((WidgetClass*) Widget_class())->dirty = true;
			}
			#line 83 "./InputLine.ooc"
			else if (ch == SDLK_DELETE && this->caretStart < (size_t) String_length(this->buffer)){
				#line 84 "./InputLine.ooc"
				this->buffer = __OP_ADD_String_String__String(String_substring(this->buffer, 0, this->caretStart), String_substring(this->buffer, this->caretStart + 1, (size_t) String_length(this->buffer)));
				#line 85 "./InputLine.ooc"
				((WidgetClass*) Widget_class())->dirty = true;
			}
			#line 86 "./InputLine.ooc"
			else if (e.key.keysym.sym == SDLK_RIGHT && this->caretStart < (size_t) String_length(this->buffer)){
				#line 87 "./InputLine.ooc"
				this->caretStart += 1;
				#line 88 "./InputLine.ooc"
				((WidgetClass*) Widget_class())->dirty = true;
			}
			#line 89 "./InputLine.ooc"
			else if (e.key.keysym.sym == SDLK_LEFT && this->caretStart > 0){
				#line 90 "./InputLine.ooc"
				this->caretStart -= 1;
				#line 91 "./InputLine.ooc"
				((WidgetClass*) Widget_class())->dirty = true;
			}
			#line 92 "./InputLine.ooc"
			else if (e.key.keysym.sym == SDLK_HOME){
				#line 93 "./InputLine.ooc"
				this->caretStart = 0;
				#line 94 "./InputLine.ooc"
				((WidgetClass*) Widget_class())->dirty = true;
			}
			#line 95 "./InputLine.ooc"
			else if (e.key.keysym.sym == SDLK_END){
				#line 96 "./InputLine.ooc"
				this->caretStart = (size_t) String_length(this->buffer);
				#line 97 "./InputLine.ooc"
				((WidgetClass*) Widget_class())->dirty = true;
			}
		};
	};
}

lang__Class *InputLine_class(){
	static bool __done__ = false;
	static InputLineClass class = {{{{
					.instanceSize = sizeof(InputLine),
					.size = sizeof(void*),
					.name = "InputLine",
				},
				.__load__ = (void (*)()) InputLine___load__,
				.__defaults__ = (void (*)(struct _lang__Object *)) InputLine___defaults___impl,
				.__destroy__ = (void (*)(struct _lang__Object *)) InputLine___destroy___impl,
			},
			.new_widget = (struct _Widget * (*)()) Widget_new_widget,
			.init_widget = Widget_init_widget_impl,
			.setName = (void (*)(struct _Widget *, char *)) Widget_setName_impl,
			.setSize = (void (*)(struct _Widget *, int, int)) Widget_setSize_impl,
			._render = (void (*)(struct _Widget *)) InputLine__render_impl,
			.render = (void (*)(struct _Widget *)) Widget_render_impl,
			.handleEvent = (void (*)(struct _Widget *, SDL_Event)) InputLine_handleEvent_impl,
			.show = (void (*)(struct _Widget *)) Widget_show_impl,
			.hide = (void (*)(struct _Widget *)) Widget_hide_impl,
			.animHide = (void (*)(struct _Widget *)) Widget_animHide_impl,
		},
		.new_inputLine = InputLine_new_inputLine,
		.init_inputLine = InputLine_init_inputLine_impl,
		.bgDraw = InputLine_bgDraw_impl,
		.bufferDraw = InputLine_bufferDraw_impl,
	};
	lang__Class *classPtr = (lang__Class *) &class;
	if(!__done__){
		__done__ = true;
		classPtr->super = Widget_class();
	}
	return classPtr;
}


void InputLine___defaults__(struct _InputLine *this){
	((lang__ObjectClass *)((lang__Object *)this)->class)->__defaults__((struct _lang__Object *) this);
}


void InputLine___destroy__(struct _InputLine *this){
	((lang__ObjectClass *)((lang__Object *)this)->class)->__destroy__((struct _lang__Object *) this);
}


void InputLine_init_inputLine(struct _InputLine *this, struct _Widget *parent){
	((InputLineClass *)((lang__Object *)this)->class)->init_inputLine((struct _InputLine *) this, parent);
}


void InputLine__render(struct _InputLine *this){
	((WidgetClass *)((lang__Object *)this)->class)->_render((struct _Widget *) this);
}


void InputLine_bgDraw(struct _InputLine *this){
	((InputLineClass *)((lang__Object *)this)->class)->bgDraw((struct _InputLine *) this);
}


void InputLine_bufferDraw(struct _InputLine *this){
	((InputLineClass *)((lang__Object *)this)->class)->bufferDraw((struct _InputLine *) this);
}


void InputLine_handleEvent(struct _InputLine *this, SDL_Event e){
	((WidgetClass *)((lang__Object *)this)->class)->handleEvent((struct _Widget *) this, e);
}


void InputLine___load__(){
}


struct _InputLine *InputLine_new_inputLine(struct _Widget *parent){
	#line 19 "./InputLine.ooc"
	struct _InputLine *this = ((struct _InputLine *) (Class_alloc(InputLine_class())));
	#line 19 "./InputLine.ooc"
	InputLine_init_inputLine(this, parent);
	#line 19 "./InputLine.ooc"
	return this;
}



void _InputLine_load(){
	static bool __done__ = false;
	if (!__done__){
		__done__ = true;
		InputLine___load__();
		_lang_BasicTypes_load();
		_lang_memory_load();
		_lang_ooclib_load();
		_lang_stdio_load();
		_glew_load();
		_Widget_load();
		_sdl_Sdl_load();
		_sdl_Event_load();
		_Vector_load();
	}
}

