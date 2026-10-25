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

-- Tabla relacional para usuarios y grupos
CREATE TABLE grupos_usuarios(
	id INT IDENTITY PRIMARY KEY,
	grupo_id INT NOT NULL,
	usuario_id INT NOT NULL,
	fecha_ingreso DATETIME NOT NULL DEFAULT(CURRENT_TIMESTAMP), -- Se guarda la fecha de ingreso del participante para asociarle solo los gastos posteriores a su ingreso
	FOREIGN KEY (grupo_id) REFERENCES grupos(id),
	FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
	CONSTRAINT grupo_usuario_constraint UNIQUE(grupo_id,usuario_id) -- Cada usuario solo puede agregarse una vez a cada grupo
);

CREATE TABLE categorias(
	id INT IDENTITY PRIMARY KEY,
	nombre VARCHAR(100) NOT NULL,
);

-- Tabla que registra todos los gastos del sistema
CREATE TABLE gastos(
	id INT IDENTITY PRIMARY KEY,
	nombre VARCHAR(100) NOT NULL,
	usuario_id INT NOT NULL, -- Usuario que realizó el pago del gasto
	fecha DATETIME NOT NULL DEFAULT(CURRENT_TIMESTAMP),
	monto DECIMAL(10,2) NOT NULL,
	FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
	CONSTRAINT gastos_monto_check CHECK(monto > 0),
);

-- Trigger para crear tablas de cuotas al cargar un gasto (también para la eliminación)
-- Cuotas correspondientes a un gasto, todos los gastos tienen al menos una cuota (se crea por trigger)
CREATE TABLE cuotas(
	id INT IDENTITY PRIMARY KEY,
	gasto_id INT NOT NULL,
	numero INT NOT NULL,
	vencimiento DATE NOT NULL, -- Verificar que las cuotas sean + grandes que la fecha de registro de gasto
	monto DECIMAL(10,2) NOT NULL,
	FOREIGN KEY (gasto_id) REFERENCES gastos(id),
	CONSTRAINT cuotas_monto_check CHECK(monto > 0)
);

-- Relaciona un gasto a un usuario perteneciente a un grupo específico
CREATE TABLE gastos_grupos_usuarios(
	id INT IDENTITY PRIMARY KEY,
	grupo_usuario_id INT NOT NULL,
	gasto_id INT NOT NULL,
	FOREIGN KEY (grupo_usuario_id) REFERENCES grupos_usuarios(id),
	FOREIGN KEY (gasto_id) REFERENCES gastos(id),
	CONSTRAINT gastos_usuarios_unique UNIQUE(gasto_id,grupo_usuario_id), -- No permite duplicados en gastos con grupos_usuarios
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

-- Tabla para registrar pagos de usuarios
CREATE TABLE pagos_usuarios(
	id INT IDENTITY PRIMARY KEY,
	usuario_id INT NOT NULL,
	cuota_id INT NOT NULL,
	importe DECIMAL(10,2) NOT NULL,
	fecha DATETIME NOT NULL DEFAULT(CURRENT_TIMESTAMP),
	FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
	FOREIGN KEY (cuota_id) REFERENCES cuotas(id),
	CONSTRAINT check_pagos_usuarios_importe CHECK(importe > 0),
);