USE TPO;

CREATE TABLE usuarios(
	id INT IDENTITY PRIMARY KEY,
	nombre VARCHAR(100) NOT NULL,
	apellido VARCHAR(100) NOT NULL,
	dni NUMERIC(10) NOT NULL
);

CREATE TABLE grupos(
	id INT IDENTITY PRIMARY KEY,
	nombre VARCHAR(100)
);

CREATE TABLE grupos_usuarios(
	id INT IDENTITY PRIMARY KEY,
	grupo_id INT NOT NULL,
	usuario_id INT NOT NULL,
	FOREIGN KEY (grupo_id) REFERENCES grupos(id),
	FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

CREATE TABLE categorias(
	id INT IDENTITY PRIMARY KEY,
	nombre VARCHAR(100) NOT NULL,
);

CREATE TABLE gastos(
	id INT IDENTITY PRIMARY KEY,
	usuario_id INT NOT NULL,
	fecha DATETIME NOT NULL DEFAULT(CURRENT_TIMESTAMP),
	monto DECIMAL(10,2) NOT NULL,
	cuotas INT NOT NULL,
	FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
	CONSTRAINT gastos_monto_check CHECK(monto > 0),
	CONSTRAINT gastos_cuotas_check CHECK(cuotas >= 1)
);

CREATE TABLE cuotas(
	id INT IDENTITY PRIMARY KEY,
	gasto_id INT NOT NULL,
	numero INT NOT NULL,
	vencimiento DATE NOT NULL, -- Verificar que las cuotas sean + grandes que la fecha de registro de gasto
	monto DECIMAL(10,2) NOT NULL,
	FOREIGN KEY (gasto_id) REFERENCES gastos(id),
	CONSTRAINT cuotas_monto_check CHECK(monto > 0)
);

CREATE TABLE gastos_grupos(
	id INT IDENTITY PRIMARY KEY,
	grupo_id INT NOT NULL,
	usuario_id INT NOT NULL,
	FOREIGN KEY (grupo_id) REFERENCES grupos(id),
	FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

CREATE TABLE categorias_grupos(
	id INT IDENTITY PRIMARY KEY,
	grupo_id INT NOT NULL,
	categoria_id INT NOT NULL,
	FOREIGN KEY (grupo_id) REFERENCES grupos(id),
	FOREIGN KEY (categoria_id) REFERENCES categorias(id)
);

CREATE TABLE categorias_usuarios(
	id INT IDENTITY PRIMARY KEY,
	usuario_id INT NOT NULL,
	categoria_id INT NOT NULL,
	FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
	FOREIGN KEY (categoria_id) REFERENCES categorias(id)
);

CREATE TABLE pagos_usuarios(
	id INT IDENTITY PRIMARY KEY,
	usuario_id INT NOT NULL,
	cuota_id INT NOT NULL,
	importe FLOAT NOT NULL,
	fecha DATETIME NOT NULL DEFAULT(CURRENT_TIMESTAMP),
	FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
	FOREIGN KEY (cuota_id) REFERENCES cuotas(id),
	CONSTRAINT check_pagos_usuarios_importe CHECK(importe > 0),
);