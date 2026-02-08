# Project Context

Proyecto: proyecto1
Ubicacion: /Users/julioruiz/Desarrollo_Flutter/proyecto1
API Laravel: apisiga (/Users/julioruiz/desarrollo_laravel/apisiga)
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
- Navegacion login -> catalogo -> detalle -> regresar sin recargar lista.
- Boton salir hace logout y regresa a login.
- Se normalizan URLs de imagen (localhost/127.0.0.1 -> host real del API).
- APK release generado: build/app/outputs/flutter-apk/app-release.apk.
- APK release generado (actual): build/app/outputs/flutter-apk/app-release.apk.

Pantallas:
- Login: tonos celestes, recuerda ultimo usuario/clave, valida contra API, navega a catalogo.
- Configuracion: ruta API, token empresa, codigo empresa.
- Catalogo: listado con miniaturas, filtros, paginacion, detalle con foto original y zoom.
- Detalle: muestra marca en lugar de categoria.

Pendiente:
- (Opcional) agregar filtro por marca y toggle de activo en UI.
- (Opcional) centralizar cliente API para todas las consultas.

Notas:
- Ruta API debe incluir /api (ej. http://localhost:8000/api).
