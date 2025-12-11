<%-- 
    Document   : admin
    Created on : 2 nov 2025, 15:52:10
    Author     : ivan
--%>

<%-- DEFINIMOS EL TIPO DE CONTENIDO Y LA CODIFICACIÓN UTF-8 PARA CARACTERES ESPECIALES --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <%-- CONFIGURACIÓN DE VIEWPORT PARA QUE SE VEA BIEN EN MÓVILES --%>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
    <%-- VINCULAMOS LA HOJA DE ESTILOS CSS PRINCIPAL DEL PANEL --%>
    <%-- USAMOS '${pageContext...}' PARA OBTENER LA RUTA RAÍZ DE LA APP AUTOMÁTICAMENTE --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin_general.css"/>

    <title>Panel de Administración</title>

    <style>
        /* --- ESTILOS CSS ESPECÍFICOS PARA EL LOGOTIPO CIRCULAR --- */
        
        .logo a {
            display: inline-block;
        }

        /* CONTENEDOR DEL LOGO (EL MARCO REDONDO) */
        .logo {
            width: 120px;        /* TAMAÑO FIJO DEL CÍRCULO */
            height: 120px;
            border-radius: 60%;  /* EL 50% O MÁS CONVIERTE UN CUADRADO EN UN CÍRCULO PERFECTO */
            overflow: hidden;    /* RECORTA CUALQUIER PARTE DE LA IMAGEN QUE SE SALGA DEL CÍRCULO */
            padding: 0;          /* ¡IMPORTANTE! SIN RELLENO PARA QUE LA IMAGEN TOQUE LOS BORDES */

            /* CENTRADO Y DECORACIÓN (SOMBRA) */
            display: flex;
            justify-content: center;
            align-items: center;
            background-color: white;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            transition: all 0.3s ease;
        }

        /* LA IMAGEN DENTRO DEL LOGO */
        .logo img {
            width: 100%;
            height: 100%;
            /* OBJECT-FIT: COVER ES EL TRUCO. HACE ZOOM PARA LLENAR EL HUECO SIN DEFORMAR LA IMAGEN */
            object-fit: cover;      
            object-position: center; /* CENTRA LA IMAGEN PARA QUE SE VEA LA PARTE IMPORTANTE */
            display: block;          /* QUITA ESPACIOS EXTRAÑOS QUE A VECES APARECEN DEBAJO DE LAS IMÁGENES */
        }
    </style>
</head>
<body>

    <div class="dashboard-container">

        <%-- LOGO CENTRAL: AL PULSARLO LLEVA A LA PÁGINA DE INICIO PÚBLICA --%>
        <div class="logo">
            <a href="${pageContext.request.contextPath}/">
                <img src="${pageContext.request.contextPath}/img/logopeluqueria.png" alt="LOGO"/>
            </a>
        </div>

        <%-- MENÚ DE NAVEGACIÓN PRINCIPAL --%>
        <nav class="dashboard-nav">
            <ul>
                
                <%-- BOTÓN 1: GESTIÓN DE SERVICIOS --%>
                <%-- APUNTA AL SERVLET 'ControladorServicios' (MÉTODO GET /LISTAR) --%>
                <li>
                    <a href="${pageContext.request.contextPath}/Admin/Servicios/Listar" class="btn-nav">
                        Gestionar Servicios
                    </a>
                </li>
                
                <%-- BOTÓN 2: GESTIÓN DE USUARIOS --%>
                <%-- APUNTA AL SERVLET 'ControladorUsuarios' (MÉTODO GET /LISTAR) --%>
                <li>
                    <a href="${pageContext.request.contextPath}/Admin/Usuarios/Listar" class="btn-nav">
                        Gestionar Usuarios
                    </a>
                </li>
                
                <%-- BOTÓN 3: GESTIÓN DE CITAS --%>
                <%-- APUNTA AL SERVLET 'ControladorCitas' (MÉTODO GET /LISTAR) --%>
                <li>
                    <a href="${pageContext.request.contextPath}/Admin/Citas/Listar" class="btn-nav">
                        Gestionar Citas
                    </a>
                </li>
                
                <%-- BOTÓN 4: GESTIÓN DE GALERÍA --%>
                <%-- APUNTA AL SERVLET 'ControladorGaleria' (MÉTODO GET /LISTAR) --%>
                <li>
                    <a href="${pageContext.request.contextPath}/Admin/Galeria/listar" class="btn-nav">
                        Gestionar Galería
                    </a>
                </li>

            </ul>
        </nav>

    </div>

</body>
</html>