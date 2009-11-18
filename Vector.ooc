

Vector2: class<T> {
	x,y: T
	
	init: func(=x,=y) {
		
	}
}

Vector2d: class {
	x,y: Double
	init: func(=x,=y) {}
}

Vector3d: class {
	x,y,z: Double
	init: func(=x,=y,=z){}
}

Vector3b: class {
	x,y,z: Octet
	init: func(=x,=y,=z){}
}

Vector2i: class {
	x,y: Int
	init: func(=x,=y) {}
	init: func ~vec(v: Vector2i) {
		x = v x
		y = v y
	}
}


operator += (a,b: Vector2i) {
	a x += b x
	a y += b y
}
