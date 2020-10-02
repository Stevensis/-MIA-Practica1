CREATE DATABASE MIAP1;

USE MIAP1;

CREATE TABLE contacto(
	idContacto INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    nombre varchar(60) not null
)

CREATE TABLE compania(
	idCompania INT PRIMARY KEY NOT NULL  AUTO_INCREMENT,
    nombre VARCHAR(60) NOT NULL,
    correo varchar(60),
    telefono varchar(45),
    idContacto INT,
    FOREIGN KEY (idContacto) REFERENCES contacto(idContacto)
)

CREATE TABLE region (
	idRegion INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    nombre varchar(100)
)

CREATE TABLE ciudad (
	idCiudad INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    nombre varchar(100),
    idRegion INT,
    FOREIGN KEY (idRegion) REFERENCES region(idRegion)
)

CREATE TABLE tipoUsuario(
	idTIpoUsuario INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    nombre varchar(45),
    identificador CHAR
)

CREATE TABLE usuario(
	idUsuario INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(60),
    correo VARCHAR(60),
    telefono VARCHAR(50),
    fecha_registro DATE,
    direccion VARCHAR(100),
    codigo_postal VARCHAR(45),
    
    idTipoUsuario INT,
    idCiudad INT,
    
    FOREIGN KEY (idTipoUsuario) REFERENCES tipoUsuario(idTIpoUsuario),
    FOREIGN KEY (idCiudad) REFERENCES ciudad (idCiudad)
)

CREATE TABLE categoria_producto(
	idCategoria_Producto INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(60)
)

CREATE TABLE producto(
	idProducto INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(100),
    precio_unitario DECIMAL(10,2),
    idCategoria INT,
    
    FOREIGN KEY (idCategoria) REFERENCES categoria_producto (idCategoria_Producto)
)



CREATE TABLE orden(
	idOrden INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    cantidad INT,
    idProducto INT,
    
    FOREIGN KEY (idProducto) REFERENCES producto(idProducto)
    
)

CREATE TABLE detalle(
	 idDetalle INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
     idCompania INT,
	 idUsuario INT,
     idOrden INT,
     FOREIGN KEY (idCompania) REFERENCES compania(idCompania),
     FOREIGN KEY (idUsuario) REFERENCES usuario(idUsuario),
     FOREIGN KEY (idOrden) REFERENCES orden(idOrden)
)

INSERT INTO tipoUsuario (nombre,identificador) VALUES('Cliente','C')
INSERT INTO tipoUsuario (nombre,identificador) VALUES('Proveedor','P')

create table temporal(
	nombre_compania varchar(100) not null,
    contacto_compania varchar(100) not null,
    correo_compania varchar(100) not null,
    telefono_compania varchar(100) not null,
    tipo varchar(100) not null,
    nombre varchar(100) not null, 
    correo varchar(100) not null, 
    telefono varchar(100) not null,
    fecha_registro varchar(100) not null,
    direccion varchar(100) not null,
    ciudad varchar(100) not null, 
    codigo_postal varchar(100) not null,
    region varchar(100) not null, 
    producto varchar(100) not null,
    categoria_producto varchar(100) not null,
    cantidad varchar(100) not null,
    precio_unitario varchar(100) not null
);

-- Carga Temporal
LOAD DATA INFILE '/var/lib/mysql-files/DataCenterData.csv' 
INTO TABLE temporal
FIELDS TERMINATED BY ';' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select*from temporal

-- Carga Modelo contacto

INSERT INTO contacto (nombre) 
SELECT DISTINCT contacto_compania FROM temporal

-- Carga Modelo Compania
INSERT INTO compania (nombre,correo,telefono,idContacto) 
SELECT DISTINCT T.nombre_compania,T.correo_compania, T.telefono_compania, 
(SELECT idContacto FROM contacto AS C WHERE  C.nombre = T.contacto_compania) 
FROM temporal AS T

-- Carga Modelo Region
INSERT INTO region (nombre) 
SELECT DISTINCT T.region FROM temporal AS T

-- Carga Modelo Ciudad
INSERT INTO ciudad (nombre,idRegion)
SELECT DISTINCT T.ciudad,
(SELECT R.idRegion FROM region R WHERE R.nombre=T.region) 
FROM temporal AS T

--  Usuario
INSERT INTO usuario (nombre,correo,telefono,fecha_registro,direccion,codigo_postal,idTipoUsuario,idCiudad)
SELECT DISTINCT T.nombre, T.correo, T.telefono, str_to_date(T.fecha_registro,'%d/%m/%Y'), T.direccion, T.codigo_postal,
(SELECT idTIpoUsuario FROM tipoUsuario AS TU WHERE TU.identificador=T.tipo ),
(SELECT C.idCiudad FROM ciudad AS C WHERE C.nombre=T.ciudad)
 FROM temporal AS T
 
 -- Categoria del producto 
 INSERT INTO categoria_producto (nombre)
 SELECT DISTINCT T.categoria_producto FROM temporal AS T
 
 -- Carga Productos
 INSERT INTO producto (nombre,precio_unitario,idCategoria)
 SELECT DISTINCT T.producto, T.precio_unitario,
 (SELECT CA.idCategoria_Producto FROM categoria_producto AS CA WHERE CA.nombre=T.categoria_producto)
 FROM temporal AS T
 
 -- Carga Orden
 INSERT INTO orden (cantidad,idProducto)
 SELECT DISTINCT T.cantidad,
 (SELECT idProducto FROM producto AS P WHERE P.nombre=T.producto)
 FROM temporal AS T
 
 -- Carga Detalle
 INSERT INTO detalle (idOrden,idCompania,idUsuario)
 SELECT (SELECT o.idOrden FROM orden AS o INNER JOIN producto AS p ON o.idProducto = p.idProducto
  WHERE T.producto = p.nombre AND o.cantidad = T.cantidad),
 (SELECT idCompania FROM compania AS CO WHERE CO.nombre=T.nombre_compania),
 (SELECT idUsuario FROM usuario AS U WHERE U.nombre=T.nombre)
 FROM temporal AS T
 
 DELETE FROM producto WHERE idProducto>=0
 
 SELECT * FROM usuario where idTipoUsuario=1
 SELECT * FROM producto