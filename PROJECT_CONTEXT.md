# Project Context

Proyecto: proyecto1
Ubicacion: /Users/julioruiz/Desarrollo_Flutter/proyecto1
API Laravel: apisiga (/Users/julioruiz/desarrollo_laravel/apisiga)
Estado: En implementacion de sync offline (Drift + incremental)
Fecha inicio: 2026-02-08
Objetivo actual: App Flutter con patron MVVM + Provider, login conectado a API Laravel (apisiga) usando seguridad por token y permisos/roles por modulo (como en Laravel web), catalogo de productos paginado con filtros y detalle con zoom de imagen y stock por sucursal.

Estado actual:
- Proyecto Flutter creado y dependencias configuradas (provider, http, google_fonts, shared_preferences, flutter_secure_storage, device_info_plus, uuid).
- Estructura MVVM: lib/models, lib/views, lib/viewmodels.
- Login con API real: POST /api/{empresa}/login usando token de empresa (Bearer) y device_name. Autenticacion por token (Sanctum), no por sesiones.
- Seguridad en ventanas/UI basada en permisos Laravel (slugs tipo productos.view, productos.update, etc.) por rol.
- Configuracion persistente: ruta API, codigo empresa (minusculas), token empresa (seguro).
- Token de usuario guardado en storage seguro y reutilizado para peticiones logeadas.
- Pantalla de catalogo de productos con scroll infinito, filtros por categoria, busqueda y solo activos (activo=1).
- Catalogo con vista grid/lista, sin botones de agregar, muestra precio y stock.
- Imagen del listado usa miniatura; si falta muestra placeholder "Sin imagen".
- Detalle de producto con imagen optimizada web y zoom (InteractiveViewer).
- Precio en la foto (esquina inferior derecha), sin fondo, en celeste/azul.
- Stock por sucursal mostrado en tres columnas (Stock / Sucursal / Valor).
- Subida de imagen en ficha (galeria o camara) para usuarios con permiso productos.update.
- Listado de productos filtrado fijo por tipo=1.
- Se normaliza la orientacion de fotos tomadas en vertical antes de subir (EXIF).
- Al subir foto se conservan marca y stock por sucursal (merge de datos).
- Base local con Drift para catalogo (productos, categorias, marcas, sucursales, bodegas, existencias) y stock por sucursal.
- Botones en catalogo: descargar catalogo completo, sincronizar incremental y descargar fotos.
- Modo offline: si no hay internet, carga catalogo desde base local.
- Login offline: si ya hubo sesion previa, permite entrar sin internet (usa datos locales).
- Indicador offline: icono de nube en AppBar del catalogo y ficha, cambia en tiempo real.
- Cache de imagenes: fotos descargadas se muestran offline desde cache local.
- Auto-sync al entrar con internet: sincroniza incremental y descarga fotos una vez por sesion.
- Limpieza de filtros al iniciar/cerrar sesion (busqueda, familia, marca, activo).
- Navegacion login -> catalogo -> detalle -> regresar sin recargar lista.
- Boton salir hace logout y regresa a login.
- Se normalizan URLs de imagen (localhost/127.0.0.1 -> host real del API).
- APK release generado (actual): build/app/outputs/flutter-apk/app-release.apk.

Pantallas:
- Login: tonos celestes, recuerda ultimo usuario/clave, valida contra API, navega a catalogo.
- Configuracion: ruta API, token empresa, codigo empresa.
- Catalogo: listado con miniaturas, filtros, paginacion, detalle con foto original y zoom.
- Detalle: muestra marca en lugar de categoria.

Pendiente:
- (Opcional) agregar filtro por marca y toggle de activo en UI.
- (Opcional) centralizar cliente API para todas las consultas.
- Completar UI de estados/progreso de sincronizacion (por ahora SnackBars).
- Definir estrategia de sync incremental por pantalla (otras entidades del ERP).

Notas:
- Ruta API debe incluir /api (ej. http://localhost:8000/api).

## Historial de decisiones y solicitudes

### 2026-02-12 (sesion coordinada Flutter + APISIGA)
- Se confirma que este proyecto Flutter y APISIGA se gestionan en paralelo y ambos `PROJECT_CONTEXT.md` deben mantenerse sincronizados para evitar conflictos entre desarrolladores.
- Cambio de alcance funcional: el dominio principal sera **Socios** (no solo clientes), manteniendo una sola entidad de datos con banderas `es_cliente` y `es_proveedor`.
- Requerimiento UX solicitado: manejar ventanas separadas para Cliente y Proveedor, pero permitiendo marcar desde cada pantalla si tambien aplica al otro tipo.
- Requerimiento operativo principal de la app movil: levantamiento de pedidos en ruta por vendedores y alta/captura de nuevos clientes desde la app.
- Seguridad obligatoria en frontend: respetar permisos Laravel por modulo/accion (slugs) para mostrar/ocultar acciones y proteger flujos.
- Requerimiento offline obligatorio: mantener operacion sin internet para consulta y procesos clave del flujo movil.
- Nuevo flujo de navegacion solicitado:
  - Login -> pantalla de bienvenida (nombre usuario, rol, info de sesion).
  - Navegacion principal con `NavigationDrawer`.
  - Posteriormente, reemplazar bienvenida por dashboard operativo.
- Vision de dashboard (pendiente de implementacion):
  - Recuento de clientes.
  - Pedidos del dia.
  - Venta del dia.
  - Cantidad de pedidos.
  - Selector/rastreo de ruta.
  - Modo mapa para pedidos: punteo de clientes por ruta.
  - Modo mapa para entrega: punteo de clientes con pedidos del dia.
- Alcance de siguiente fase tecnica:
  - Crear modulo nuevo de Socios en Flutter.
  - CRUD completo.
  - Integracion con seguridad por permisos.
  - Integracion con sync/offline.

### 2026-02-12 (estado tras implementacion backend APISIGA)
- Decision de ejecucion: primero APISIGA y pruebas; **no iniciar cambios Flutter** hasta validar backend.
- APISIGA ya implemento y probo para fase socios/pedidos:
  - `socios`: soporte de `pasaporte`, `giro_id` (actividad economica) y `municipio_id` (distrito DTE).
  - `ventas`: nuevo `tipo_registro` (`PED`/`VTA`).
  - `users`: nuevo campo JSON `perfil` (vendedor_id, sucursal_id, punto_venta_id).
  - nuevas entidades sincronizables: `rutas` y `socio_sucursales`.
  - nuevos endpoints de apoyo:
    - `/api/{empresa}/clientes`
    - `/api/{empresa}/proveedores`
    - `/api/{empresa}/catalogos-dte/actividades-economicas`
    - `/api/{empresa}/catalogos-dte/distritos`
    - CRUD/masivo de `rutas`
    - CRUD/masivo de `socios-sucursales` + listado por socio.
- Seguridad y sincronizacion:
  - Se mantiene seguridad por permisos Laravel.
  - Se conserva enfoque de sync incremental/offline (`updated_since` + `include_deleted`) para no repetir fallas ya superadas en productos.
- Pruebas backend reportadas:
  - Migraciones tenant OK (`apisiga_c001`).
  - `php artisan test` en verde (8 tests, 36 assertions).
- Aclaracion de arquitectura DB:
  - BD central `apisiga`: tablas centrales (ej. `empresas`, `migrations`).
  - Datos ERP operativos (socios, ventas, productos, etc.): en BD tenant `apisiga_{codigo}`.
- Pendiente siguiente fase (Flutter):
  - Integrar NavigationDrawer + pantalla bienvenida post-login.
  - Consumir modulo socios/clientes/proveedores/rutas/sucursales de socios.
  - Implementar cola offline para altas/ediciones de socios y sucursales.

### 2026-02-12 (avance Flutter - inicio fase UI operativa)
- Flujo post-login actualizado:
  - Login ya no entra directo a catalogo; ahora navega a `HomeView` (bienvenida).
- Nueva pantalla principal con `NavigationDrawer`:
  - Inicio (bienvenida)
  - Clientes (placeholder inicial)
  - Proveedores (placeholder inicial)
  - Pedidos (placeholder inicial)
  - Productos (lanzador al modulo actual)
  - Configuracion
  - Cerrar sesion
- Bienvenida muestra informacion de sesion:
  - nombre/email de usuario
  - rol
  - estado de sesion
  - conectividad online/offline
  - fecha/hora de ultimo login
- `AuthViewModel` ampliado para persistir metadatos de sesion:
  - `userId`, `userName`, `userEmail`, `loginAt`.
- `LoginViewModel` ahora guarda datos del usuario devueltos por API al iniciar sesion.
- Correccion tecnica de conectividad:
  - `checkConnectivity()` ahora se procesa como lista de resultados (evita falsos online y protege flujo offline/sync).
- Validacion de cambios Flutter:
  - `flutter test` en verde.
  - `flutter analyze` mantiene avisos/info preexistentes del proyecto (no bloqueantes para esta fase).

### 2026-02-12 (ajuste UX menu-productos)
- Requisito aplicado: desde `NavigationDrawer`, opcion **Productos** abre directamente el modulo de productos (sin pantalla/accion intermedia de "abrir productos").
- Se crea componente compartido `MainNavigationDrawer` para centralizar menu principal y evitar duplicidad.
- `ProductsView` se integra con el mismo drawer cuando es abierta desde Home, permitiendo navegar entre secciones desde la pantalla de productos sin romper su comportamiento operativo actual.
- Se conserva flujo funcional existente en productos:
  - sincronizacion catalogo/fotos,
  - busqueda y filtros,
  - estado online/offline,
  - logout y acceso a configuracion.

### 2026-02-12 (unificacion de tema visual)
- Se centraliza la paleta y estilos base en `lib/theme/app_theme.dart` (`ThemeExtension<AppPalette>` + `AppTheme.light()`), para evitar colores hardcodeados por ventana.
- `main.dart` pasa a usar `AppTheme.light()` como tema global unico.
- Vistas conectadas al tema compartido:
  - `login_view.dart`
  - `settings_view.dart`
  - `products_view.dart`
  - `product_detail_view.dart`
- Resultado esperado:
  - consistencia visual entre ventanas (misma paleta, cards, app bars, botones e indicadores),
  - menor riesgo de desviaciones de color al agregar nuevas pantallas.

### 2026-02-12 (ajuste fino de homogeneidad visual)
- Solicitud explicita aplicada: mantener mismos colores, tipografia, tamanos base de texto, color/tamano de botones y fondo de pantalla.
- Refinamientos implementados:
  - login sin fondo gradiente especial (usa fondo global de `scaffoldBackgroundColor` igual que el resto),
  - estandarizacion de escala tipografica en tema (`headline/title/body/label`),
  - botones elevados con color primario y alto base comun (`minimumSize` global),
  - boton de accion en productos (`Ir al pago`) alineado al mismo esquema de boton principal.

### 2026-02-12 (ajuste menor productos)
- Se elimina el boton de cerrar sesion del `AppBar` en `ProductsView`.
- El cierre de sesion se mantiene disponible desde `NavigationDrawer` (menu lateral), evitando duplicidad de accion en esa pantalla.

### 2026-02-12 (temas predefinidos + fondo decorativo global)
- Se implementa seleccion de tema en la app con presets predefinidos:
  - `Sistema`
  - `Claro`
  - `Oscuro`
  - `Celeste`
- Persistencia local del tema en `SharedPreferences` desde `SettingsViewModel` (`theme_preference`) y aplicacion inmediata al UI.
- `MaterialApp` ahora resuelve dinamicamente `theme`, `darkTheme` y `themeMode` segun la preferencia guardada.
- Se amplian paletas en `AppTheme`:
  - `lightPalette`
  - `skyPalette`
  - `darkPalette`
- Se agrega fondo decorativo reutilizable (`AppThemedBackground`) con gradiente y formas tipo orb, adaptado por paleta.
- El fondo decorativo se aplica en las pantallas principales actuales:
  - Login
  - Home
  - Productos
  - Detalle de producto
  - Configuracion
- Configuracion ahora incluye seccion **Apariencia** para seleccionar tema sin depender del guardado de API.

### 2026-02-12 (ajuste de identidad de temas)
- Se ajustan presets para evitar similitud visual entre `Claro`, `Sistema` y `Celeste`.
- Resultado final solicitado:
  - `Claro`: paleta de grises suaves.
  - `Sistema`: paleta azul/cian con acento morado inspirada en referencia visual compartida.
  - `Celeste`: conserva la paleta celeste previa.
- Cambio de comportamiento:
  - `Sistema` ahora funciona como preset visual fijo (no ligado al brillo del dispositivo).
  - `Oscuro` mantiene `ThemeMode.dark`.
- Tema por defecto en instalacion nueva:
  - `Celeste` (`theme_preference` inicia/fallback en `sky`).
