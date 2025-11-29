<%-- 
    Document   : admin
    Created on : 2 nov 2025, 15:52:10
    Author     : ivan
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin_general.css"/>

    <title>Panel de Administración</title>

    <style>
        .logo a {
            display: inline-block;
        }

        /* Contenedor del Logo (El botón circular) */
        .logo {
            width: 120px;       /* Tamaño del círculo */
            height: 120px;
            border-radius: 60%; /* Lo hace perfectamente redondo */
            overflow: hidden;   /* Recorta la imagen que se salga del círculo */
            padding: 0;         /* ¡IMPORTANTE! Quitamos el relleno para que llegue al borde */

            /* Centrado y decoración */
            display: flex;
            justify-content: center;
            align-items: center;
            background-color: white;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            overflow: hidden;
            transition: all 0.3s ease;
        }

        /* La Imagen dentro del Logo */
        .logo img {
            width: 100%;
            height: 100%;
            object-fit: cover;     /* <--- LA CLAVE: Hace zoom para llenar todo el hueco */
            object-position: center; /* Centra la imagen */
            display: block;        /* Quita espacios extraños debajo de la imagen */
        }
    </style>
</head>
<body>

    <div class="dashboard-container">

        <div class="logo">
            <a href="${pageContext.request.contextPath}/">
                <img src="${pageContext.request.contextPath}/img/logopeluqueria.png" alt="LOGO"/>
            </a>
        </div>

        <nav class="dashboard-nav">
            <ul>
                <li>
                    <a href="${pageContext.request.contextPath}/Admin/Servicios/Listar" class="btn-nav">
                        Gestionar Servicios
                    </a>
                </li>
                <li>
                    <a href="${pageContext.request.contextPath}/Admin/Usuarios/Listar" class="btn-nav">
                        Gestionar Usuarios
                    </a>
                </li>
                <li>
                    <a href="${pageContext.request.contextPath}/Admin/Citas/Listar" class="btn-nav">
                        Gestionar Citas
                    </a>
                </li>
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


