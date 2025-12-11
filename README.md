# 💇‍♀️ Sistema de Gestión - Peluquería Paqui Díaz

   

Una aplicación web completa desarrollada en **Java EE (Jakarta)** para la gestión integral de una peluquería. El sistema permite a los clientes reservar citas online mediante un calendario interactivo y a los administradores gestionar el negocio, usuarios y contenido multimedia.

## 🚀 Características Principales

### 🔒 Módulo de Seguridad y Usuarios

  * **Login y Registro:** Sistema seguro con encriptación de contraseñas (Hashing).
  * **Roles de Usuario:** Diferenciación entre **Administrador** y **Cliente**.
  * **Filtros de Seguridad:** Protección de rutas (`/Admin/*`, `/Perfil/*`) para evitar accesos no autorizados.
  * **Gestión de Sesiones:** Control de inicio y cierre de sesión seguro.

### 👤 Panel del Cliente

  * **Reserva de Citas Interactiva:** Selección de fecha y hora dinámica.
      * 📅 **Calendario Inteligente:** Desarrollado con JavaScript, permite navegar entre meses.
      * ⏱ **Disponibilidad en Tiempo Real:** Carga de huecos libres vía **AJAX/Fetch** sin recargar la página.
      * 💅 **Selección Múltiple:** Posibilidad de elegir varios servicios para una misma cita.
        
  * **Dashboard Personal:** Vista rápida de la próxima cita y estadísticas.
  * **Historial:** Consulta de citas pasadas y servicios realizados.
  * **Gestión de Perfil:** Edición de datos personales.

### 🛠 Panel de Administración

  * **CRUD Completo:** Crear, Leer, Actualizar y Eliminar registros de:
      * 👥 **Usuarios:** Gestión de clientes y administradores.
      * ✂️ **Servicios:** Configuración de nombre, precio y duración.
      * 📅 **Citas:** Gestión de la agenda global.
  * **Galería Multimedia:**
      * Subida de archivos **Imágenes y Vídeos (MP4)** al servidor.
      * Visualización previa en tabla y Modal (Lightbox).
      * Eliminación de archivos del servidor y base de datos.

## 🛠️ Tecnologías Utilizadas

### Backend

  * **Java (Jakarta EE):** Lógica de negocio.
  * **Servlets:** Controladores (Patrón MVC).
  * **JPA (Java Persistence API):** Mapeo Objeto-Relacional para la base de datos.
  * **UserTransaction:** Gestión manual de transacciones para asegurar la integridad de datos complejos (ej: citas con múltiples servicios).

### Frontend

  * **JSP (JavaServer Pages):** Vistas dinámicas con JSTL y Scriptlets.
  * **CSS3:** Diseño responsivo (adaptable a móviles y escritorio) y moderno.
  * **JavaScript (Vanilla):** Lógica del lado del cliente, validaciones, modal de galería y peticiones asíncronas (AJAX) para el calendario.

### Base de Datos

  * **Modelo Relacional:** Tablas para Usuarios, Citas, Servicios, Historial y Galería.
  * **Relaciones JPA:** `@ManyToMany` (Citas-Servicios), `@OneToMany`, etc.

## 📂 Estructura del Proyecto

El proyecto sigue el patrón de arquitectura **MVC (Modelo - Vista - Controlador)**:

```bash
PeluqueriaPaqui/
├── src/java/Peluqueria/
│   ├── controladores/   # Servlets (Lógica de negocio y navegación)
│   ├── modelo/          # Entidades JPA (Usuario, Cita, Servicio, Galeria)
│   ├── Utilidades/      # Clases auxiliares (Hashing de contraseñas)
│
├── web/
│   ├── css/             # Hojas de estilo
│   ├── img/             # Imágenes estáticas y subidas dinámicas
│   ├── js/              # Scripts (si los hubiera externos)
│   ├── WEB-INF/
│   │   ├── Peluqueria.Vista/
│   │   │   ├── ADMIN/   # JSPs privados del administrador
│   │   │   ├── CLIENTE/ # JSPs privados del cliente
│   │   │   ├── PUBLICO/ # Login y Registro
```

## ⚙️ Instalación y Despliegue

1.  **Clonar el repositorio:**
    ```bash
    git clone https://github.com/TU_USUARIO/PeluqueriaPaqui.git
    ```
2.  **Configurar Base de Datos:**
      * Asegúrate de tener un servidor MySQL/MariaDB corriendo.
      * Crea la base de datos (el nombre debe coincidir con tu `persistence.xml`).
3.  **Configurar el Servidor:**
      * Se requiere un servidor de aplicaciones compatible con Jakarta EE (ej: **GlassFish**, **Payara**, o **TomEE**).
      * Configurar el `DataSource` (Pool de conexiones) en el servidor apuntando a tu BD.
4.  **Desplegar:**
      * Abrir el proyecto en **NetBeans** (recomendado) o Eclipse.
      * Construir (Build) y Ejecutar (Run).

## ✒️ Autores

  * **Iván** - *Desarrollo Full Stack* - [GitHub](https://www.google.com/search?q=https://github.com/tu-usuario)

-----

