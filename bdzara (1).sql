-- ============================================================
--  Base de Datos: bdzara
--  E-commerce para Firestore (modelo relacional equivalente)
--  Generado: 2026-05-13
-- ============================================================

CREATE DATABASE IF NOT EXISTS bdzara
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE bdzara;

-- ------------------------------------------------------------
-- 1. PROVEEDORES
-- ------------------------------------------------------------
CREATE TABLE proveedores (
    id          CHAR(36)        NOT NULL,
    nombre      VARCHAR(150)    NOT NULL,
    contacto    VARCHAR(100),
    email       VARCHAR(150),
    telefono    VARCHAR(20),
    pais        VARCHAR(60),
    CONSTRAINT pk_proveedores PRIMARY KEY (id)
);

-- ------------------------------------------------------------
-- 2. USUARIOS
-- ------------------------------------------------------------
CREATE TABLE usuarios (
    id              CHAR(36)        NOT NULL,
    email           VARCHAR(150)    NOT NULL,
    nombre          VARCHAR(150)    NOT NULL,
    fecha_registro  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_usuarios PRIMARY KEY (id),
    CONSTRAINT uq_usuarios_email UNIQUE (email)
);

-- ------------------------------------------------------------
-- 3. DIRECCIONES  (desnormalización del array map de usuarios)
-- ------------------------------------------------------------
CREATE TABLE direcciones (
    id          CHAR(36)        NOT NULL,
    usuario_id  CHAR(36)        NOT NULL,
    calle       VARCHAR(200),
    ciudad      VARCHAR(100),
    estado      VARCHAR(100),
    codigo_postal VARCHAR(20),
    pais        VARCHAR(60),
    es_principal BOOLEAN        NOT NULL DEFAULT FALSE,
    CONSTRAINT pk_direcciones PRIMARY KEY (id),
    CONSTRAINT fk_dir_usuario  FOREIGN KEY (usuario_id)
        REFERENCES usuarios (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ------------------------------------------------------------
-- 4. PRODUCTOS
-- ------------------------------------------------------------
CREATE TABLE productos (
    id              CHAR(36)        NOT NULL,
    proveedor_id    CHAR(36)        NOT NULL,
    nombre          VARCHAR(255)    NOT NULL,
    descripcion     TEXT,
    precio_base     DECIMAL(12,2)   NOT NULL DEFAULT 0.00,
    fecha_registro  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_productos PRIMARY KEY (id),
    CONSTRAINT fk_prod_proveedor FOREIGN KEY (proveedor_id)
        REFERENCES proveedores (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- ------------------------------------------------------------
-- 5. IMAGENES DE PRODUCTO  (desnormalización del array imagenes)
-- ------------------------------------------------------------
CREATE TABLE imagenes_producto (
    id          CHAR(36)        NOT NULL,
    producto_id CHAR(36)        NOT NULL,
    url         VARCHAR(500)    NOT NULL,
    orden       TINYINT UNSIGNED NOT NULL DEFAULT 0,
    CONSTRAINT pk_imagenes_producto PRIMARY KEY (id),
    CONSTRAINT fk_img_producto FOREIGN KEY (producto_id)
        REFERENCES productos (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ------------------------------------------------------------
-- 6. VARIANTES  (talla / color por producto)
-- ------------------------------------------------------------
CREATE TABLE variantes (
    id          CHAR(36)        NOT NULL,
    producto_id CHAR(36)        NOT NULL,
    talla       VARCHAR(20),
    color       VARCHAR(50),
    nombre_pro  VARCHAR(255),           -- campo denormalizado
    CONSTRAINT pk_variantes PRIMARY KEY (id),
    CONSTRAINT fk_var_producto FOREIGN KEY (producto_id)
        REFERENCES productos (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ------------------------------------------------------------
-- 7. INVENTARIO  (stock por variante)
-- ------------------------------------------------------------
CREATE TABLE inventario (
    id                   CHAR(36)   NOT NULL,
    variante_id          CHAR(36)   NOT NULL,
    cantidad             INT        NOT NULL DEFAULT 0,
    stock_minimo         INT                 DEFAULT 0,
    ultima_actualizacion TIMESTAMP  NOT NULL DEFAULT CURRENT_TIMESTAMP
                                    ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT pk_inventario PRIMARY KEY (id),
    CONSTRAINT uq_inv_variante UNIQUE (variante_id),
    CONSTRAINT fk_inv_variante FOREIGN KEY (variante_id)
        REFERENCES variantes (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ------------------------------------------------------------
-- 8. PEDIDOS
-- ------------------------------------------------------------
CREATE TABLE pedidos (
    id                  CHAR(36)        NOT NULL,
    usuario_id          CHAR(36)        NOT NULL,
    fecha               TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total               DECIMAL(12,2)   NOT NULL DEFAULT 0.00,
    estado              VARCHAR(50)     NOT NULL DEFAULT 'pendiente',
    -- Dirección de entrega denormalizada (map en Firestore)
    entrega_calle       VARCHAR(200),
    entrega_ciudad      VARCHAR(100),
    entrega_estado      VARCHAR(100),
    entrega_cp          VARCHAR(20),
    entrega_pais        VARCHAR(60),
    CONSTRAINT pk_pedidos PRIMARY KEY (id),
    CONSTRAINT fk_ped_usuario FOREIGN KEY (usuario_id)
        REFERENCES usuarios (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- ------------------------------------------------------------
-- 9. DETALLES PEDIDO  (subcolección de Pedidos en Firestore)
-- ------------------------------------------------------------
CREATE TABLE detalles_pedido (
    id              CHAR(36)        NOT NULL,
    pedido_id       CHAR(36)        NOT NULL,
    producto_id     CHAR(36)        NOT NULL,
    -- Campos denormalizados para histórico
    nombre_producto VARCHAR(255),
    talla           VARCHAR(20),
    color           VARCHAR(50),
    cantidad        INT             NOT NULL DEFAULT 1,
    precio_unitario DECIMAL(12,2)   NOT NULL DEFAULT 0.00,
    CONSTRAINT pk_detalles_pedido PRIMARY KEY (id),
    CONSTRAINT fk_det_pedido   FOREIGN KEY (pedido_id)
        REFERENCES pedidos (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_det_producto FOREIGN KEY (producto_id)
        REFERENCES productos (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- ============================================================
--  ÍNDICES ADICIONALES
-- ============================================================
CREATE INDEX idx_dir_usuario     ON direcciones       (usuario_id);
CREATE INDEX idx_img_producto    ON imagenes_producto (producto_id);
CREATE INDEX idx_var_producto    ON variantes         (producto_id);
CREATE INDEX idx_ped_usuario     ON pedidos           (usuario_id);
CREATE INDEX idx_ped_estado      ON pedidos           (estado);
CREATE INDEX idx_det_pedido      ON detalles_pedido   (pedido_id);
CREATE INDEX idx_det_producto    ON detalles_pedido   (producto_id);
CREATE INDEX idx_prod_proveedor  ON productos         (proveedor_id);

-- ============================================================
--  FIN DEL SCRIPT  bdzara.sql
-- ============================================================
