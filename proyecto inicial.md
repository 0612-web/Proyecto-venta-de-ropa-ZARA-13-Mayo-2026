<img width="653" height="764" alt="image" src="https://github.com/user-attachments/assets/8eb0dbac-d9a1-47b1-9042-5b323b11a87d" />
Perfecto. Basado en tu diagrama anterior (más completo que mi primera versión) y actuando como **desarrollador de software**, voy a **generar imágenes con formato tabla ASCII** y **diagramas de relaciones** similares a los que me compartiste, pero añadiendo **tipos de datos específicos de Firestore**, **claves foráneas explícitas** y **notas de implementación**.

---

## Imagen 1: Modelo Entidad-Relación (MER) - Estilo profesional

```
┌─────────────────┐         ┌─────────────────┐         ┌─────────────────┐
│    CLIENTE      │         │     PEDIDO      │         │    DEVOLUCION   │
├─────────────────┤         ├─────────────────┤         ├─────────────────┤
│ PK │ uuid (id)  │◄────┐   │ PK │ uuid (id)  │         │ PK │ uuid (id)  │
│    │ nombre     │     │   │ FK │ cliente_id │         │ FK │ pedido_id  │
│    │ email      │     └───│    │ fecha      │         │    │ motivo     │
│    │ telefono   │         │    │ estado     │         │    │ estado     │
│    │ dirección  │         │    │ total      │         │    │ fecha      │
│    │ fecha_reg  │         │    │ metodo_pago│         └────────┬────────┘
└─────────────────┘         └───────┬─────────┘                  │
                                    │                              │
                                    │ 1:N                          │ 1:1
                                    │                              │
                            ┌───────▼─────────┐                    │
                            │ DETALLE_PEDIDO  │                    │
                            ├─────────────────┤                    │
                            │ PK │ uuid (id)  │                    │
                            │ FK │ pedido_id  │                    │
                            │ FK │ variante_id│                    │
                            │    │ cantidad   │                    │
                            │    │ precio_uni │                    │
                            └───────┬─────────┘                    │
                                    │                              │
                                    │ N:1                          │
                                    │                              │
┌─────────────────┐         ┌───────▼─────────┐         ┌─────────────────┐
│   CATEGORIA     │         │    VARIANTE     │         │   INVENTARIO    │
├─────────────────┤         ├─────────────────┤         ├─────────────────┤
│ PK │ uuid (id)  │         │ PK │ uuid (id)  │         │ PK │ uuid (id)  │
│ FK │ cat_padre  │         │ FK │ producto_id│         │ FK │ variante_id│
│    │ nombre     │         │    │ talla      │         │    │ cantidad   │
└────────┬────────┘         │    │ color      │         │    │ ult_actual │
         │                  │    │ stock      │         └────────┬────────┘
         │ 1:N               │    │ sku        │                  │
         │ (autorreferencia) └───────┬─────────┘                  │
         │                          │                             │
         │                     N:1  │                             │
         │                          │                             │
┌────────▼────────┐         ┌───────▼─────────┐         ┌────────▼────────┐
│    PRODUCTO     │         │   PROVEEDOR     │         │                 │
├─────────────────┤         ├─────────────────┤         │  (Inventario    │
│ PK │ uuid (id)  │         │ PK │ uuid (id)  │         │   es 1:1 con    │
│ FK │ categoria_id│        │    │ nombre     │         │   variante)     │
│ FK │ proveedor_id│        │    │ contacto   │         │                 │
│    │ nombre     │         │    │ país       │         └─────────────────┘
│    │ descripcion│         └─────────────────┘
│    │ precio_base│
└─────────────────┘
```

---

## Imagen 2: Tablas en formato Firestore (NoSQL adaptado)

Aquí convierto tu modelo relacional a **colecciones de Firestore** (equivalente a tablas):

```dart
// 📁 Colección: clientes
{
  "uuid": "cli_abc123",           // documento ID = uid de Firebase Auth
  "nombre": "Ana García",
  "email": "ana@email.com",
  "telefono": "+34123456789",
  "direccion": "C/ Mayor 123, Madrid",
  "fecha_registro": Timestamp(2024, 5, 20)
}

// 📁 Colección: categorias
{
  "uuid": "cat_001",
  "nombre": "Hombre",
  "categoria_padre_id": null      // null = raíz
},
{
  "uuid": "cat_002",
  "nombre": "Camisas",
  "categoria_padre_id": "cat_001" // subcategoría
}

// 📁 Colección: proveedores
{
  "uuid": "prov_01",
  "nombre": "Textiles S.A.",
  "contacto": "Juan Pérez",
  "pais": "España"
}

// 📁 Colección: productos
{
  "uuid": "prod_101",
  "nombre": "Camisa Oxford",
  "descripcion": "Algodón 100%, corte slim",
  "precio_base": 39.99,
  "categoria_id": "cat_002",       // referencia a categorias
  "proveedor_id": "prov_01",       // referencia a proveedores
  "activo": true,
  "imagenes": ["url1.jpg", "url2.jpg"]
}

// 📁 Colección: variantes (subcolección de productos)
// Ruta: productos/prod_101/variantes/
{
  "uuid": "var_001",
  "talla": "M",
  "color": "Azul marino",
  "stock": 45,
  "sku": "CAM-OXF-M-AZ"
},
{
  "uuid": "var_002",
  "talla": "L",
  "color": "Blanco",
  "stock": 12,
  "sku": "CAM-OXF-L-BL"
}

// 📁 Colección: pedidos
{
  "uuid": "ped_999",
  "cliente_id": "cli_abc123",
  "fecha": Timestamp(2025, 3, 10),
  "estado": "pendiente",            // pendiente, pagado, enviado, entregado, cancelado
  "total": 89.98,
  "metodo_pago": "tarjeta",
  "direccion_entrega": {            // objeto anidado
    "calle": "C/ Mayor 123",
    "ciudad": "Madrid",
    "cp": "28001"
  }
}

// 📁 Colección: detalles_pedido (subcolección de pedidos)
// Ruta: pedidos/ped_999/detalles/
{
  "uuid": "det_001",
  "variante_id": "var_001",
  "cantidad": 2,
  "precio_unitario": 39.99,        // precio congelado al momento de compra
  "nombre_producto": "Camisa Oxford", // denormalizado
  "talla": "M",
  "color": "Azul marino"
}

// 📁 Colección: devoluciones
{
  "uuid": "dev_555",
  "pedido_id": "ped_999",
  "motivo": "Talla incorrecta",
  "estado": "solicitada",           // solicitada, aprobada, rechazada, completada
  "fecha": Timestamp(2025, 3, 15)
}
```

---

## Imagen 3: Implementación técnica en Flutter + Firebase

### Modelo de datos en Dart (ejemplo completo)

```dart
// lib/data/models/producto_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductoModel {
  final String uuid;
  final String nombre;
  final String descripcion;
  final double precioBase;
  final String categoriaId;
  final String proveedorId;
  final bool activo;
  final List<String> imagenes;
  final DateTime? createdAt;

  ProductoModel({
    required this.uuid,
    required this.nombre,
    required this.descripcion,
    required this.precioBase,
    required this.categoriaId,
    required this.proveedorId,
    this.activo = true,
    this.imagenes = const [],
    this.createdAt,
  });

  // Desde Firestore
  factory ProductoModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? options,
  ) {
    final data = doc.data()!;
    return ProductoModel(
      uuid: doc.id,
      nombre: data['nombre'],
      descripcion: data['descripcion'],
      precioBase: data['precio_base'].toDouble(),
      categoriaId: data['categoria_id'],
      proveedorId: data['proveedor_id'],
      activo: data['activo'] ?? true,
      imagenes: List<String>.from(data['imagenes'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // Hacia Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'precio_base': precioBase,
      'categoria_id': categoriaId,
      'proveedor_id': proveedorId,
      'activo': activo,
      'imagenes': imagenes,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
```

### Repositorio con transacciones (para evitar sobreventa)

```dart
// lib/data/repositories/pedido_repository.dart
class PedidoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> crearPedido({
    required String clienteId,
    required List<ItemCarrito> items,
    required String metodoPago,
    required Map<String, dynamic> direccion,
  }) async {
    // 🔥 Usamos batch para múltiples operaciones atómicas
    final batch = _firestore.batch();
    final pedidoRef = _firestore.collection('pedidos').doc();
    final total = items.fold(0.0, (sum, item) => sum + (item.precioUnitario * item.cantidad));

    // 1. Crear pedido
    batch.set(pedidoRef, {
      'uuid': pedidoRef.id,
      'cliente_id': clienteId,
      'fecha': FieldValue.serverTimestamp(),
      'estado': 'pendiente',
      'total': total,
      'metodo_pago': metodoPago,
      'direccion_entrega': direccion,
    });

    // 2. Por cada item, descontar stock de la variante y crear detalle
    for (final item in items) {
      final varianteRef = _firestore.collection('variantes').doc(item.varianteId);
      final detalleRef = pedidoRef.collection('detalles').doc();

      // Descuento de stock
      batch.update(varianteRef, {
        'stock': FieldValue.increment(-item.cantidad),
      });

      // Crear detalle del pedido
      batch.set(detalleRef, {
        'uuid': detalleRef.id,
        'variante_id': item.varianteId,
        'cantidad': item.cantidad,
        'precio_unitario': item.precioUnitario,
        'nombre_producto': item.nombreProducto,
        'talla': item.talla,
        'color': item.color,
      });
    }

    await batch.commit();
  }
}
```

### Reglas de seguridad de Firestore (completas)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Clientes: solo lectura/escritura del propio usuario
    match /clientes/{clienteId} {
      allow read, write: if request.auth != null && request.auth.uid == clienteId;
    }
    
    // Productos: lectura pública, escritura solo admin
    match /productos/{productoId} {
      allow read: if true;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/clientes/$(request.auth.uid)).data.rol == 'admin';
    }
    
    // Variantes (subcolección de productos)
    match /productos/{productoId}/variantes/{varianteId} {
      allow read: if true;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/clientes/$(request.auth.uid)).data.rol == 'admin';
    }
    
    // Pedidos: el cliente puede leer sus propios pedidos, crear nuevos
    match /pedidos/{pedidoId} {
      allow read: if request.auth != null && 
        resource.data.cliente_id == request.auth.uid;
      allow create: if request.auth != null && 
        request.resource.data.cliente_id == request.auth.uid;
    }
    
    // Detalles: solo lectura dentro de pedidos propios
    match /pedidos/{pedidoId}/detalles/{detalleId} {
      allow read: if request.auth != null && 
        get(/databases/$(database)/documents/pedidos/$(pedidoId)).data.cliente_id == request.auth.uid;
    }
    
    // Categorías: lectura pública, escritura admin
    match /categorias/{categoriaId} {
      allow read: if true;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/clientes/$(request.auth.uid)).data.rol == 'admin';
    }
    
    // Proveedores: solo admin
    match /proveedores/{proveedorId} {
      allow read, write: if request.auth != null && 
        get(/databases/$(database)/documents/clientes/$(request.auth.uid)).data.rol == 'admin';
    }
  }
}
```

---

## Imagen 4: Arquitectura de la app (carpetas)

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       ├── formatters.dart
│       └── validators.dart
│
├── data/
│   ├── models/
│   │   ├── cliente_model.dart
│   │   ├── producto_model.dart
│   │   ├── variante_model.dart
│   │   ├── pedido_model.dart
│   │   ├── detalle_pedido_model.dart
│   │   ├── categoria_model.dart
│   │   ├── proveedor_model.dart
│   │   └── devolucion_model.dart
│   │
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── producto_repository.dart
│   │   ├── pedido_repository.dart
│   │   ├── carrito_repository.dart
│   │   └── inventario_repository.dart
│   │
│   └── datasources/
│       ├── firebase_remote_datasource.dart
│       └── local_datasource.dart (shared_preferences)
│
├── domain/
│   ├── entities/
│   │   └── (copias livianas de modelos)
│   └── usecases/
│       ├── get_productos_usecase.dart
│       ├── add_to_cart_usecase.dart
│       ├── crear_pedido_usecase.dart
│       └── consultar_stock_usecase.dart
│
├── presentation/
│   ├── cubits/
│   │   ├── auth_cubit/
│   │   ├── cart_cubit/
│   │   ├── products_cubit/
│   │   └── orders_cubit/
│   │
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── product_detail_screen.dart
│   │   ├── cart/
│   │   │   ├── cart_screen.dart
│   │   │   └── checkout_screen.dart
│   │   ├── orders/
│   │   │   ├── orders_history_screen.dart
│   │   │   └── order_detail_screen.dart
│   │   └── profile/
│   │       └── profile_screen.dart
│   │
│   └── widgets/
│       ├── product_card.dart
│       ├── size_selector.dart
│       ├── color_selector.dart
│       ├── quantity_selector.dart
│       └── custom_app_bar.dart
│
└── main.dart
```

---

## Imagen 5: Flujo completo de una compra (secuencia)

```
[USUARIO]                [APP]                    [FIRESTORE]
   │                       │                           │
   │ 1. Selecciona producto│                           │
   │──────────────────────>│                           │
   │                       │ 2. Consulta variantes     │
   │                       │──────────────────────────>│
   │                       │                           │
   │                       │ 3. Devuelve stock/talla   │
   │                       │<──────────────────────────│
   │ 4. Elige talla/color  │                           │
   │──────────────────────>│                           │
   │                       │ 5. Añade a carrito local  │
   │                       │ (shared_prefs)            │
   │                       │                           │
   │ 6. Procede a pagar    │                           │
   │──────────────────────>│                           │
   │                       │ 7. Inicia transacción     │
   │                       │──────────────────────────>│
   │                       │ 8. Descuenta stock        │
   │                       │──────────────────────────>│
   │                       │ 9. Crea pedido y detalles │
   │                       │──────────────────────────>│
   │                       │ 10. Confirma transacción  │
   │                       │<──────────────────────────│
   │ 11. Muestra éxito     │                           │
   │<──────────────────────│                           │
```

---

## Resumen final para el desarrollador

| Componente | Tecnología / Decisión |
|------------|----------------------|
| **Backend** | Firebase (Auth + Firestore + Storage + Functions) |
| **Frontend** | Flutter 3.x (Material 3) |
| **Estado** | BLoC + Cubit (para carrito, productos, pedidos) |
| **Offline** | Firestore offline persistence + SharedPreferences para carrito |
| **Transacciones** | Batch de Firestore (máx 500 ops) + Cloud Functions para validación extra |
| **Índices** | Firestore requiere índice para `productos.categoria_id` + `precio_base` (ordenación) |
| **Seguridad** | Reglas estrictas + validación en Cloud Functions para evitar sobreventa |

¿Necesitas que profundice en alguna parte específica? Por ejemplo:  
- Código completo del carrito con BLoC  
- Cloud Function para cancelar pedidos no pagados  
- Implementación de búsqueda con Algolia + Firestore


<img width="739" height="575" alt="image" src="https://github.com/user-attachments/assets/546f948f-69c2-492c-8a08-bd8e7216ac45" />
<img width="740" height="595" alt="image" src="https://github.com/user-attachments/assets/fc24f2f7-1561-461b-b1a1-433575627c9f" />
<img width="762" height="606" alt="image" src="https://github.com/user-attachments/assets/4aaa7235-9c75-43fb-85c4-6155b9522452" />

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

