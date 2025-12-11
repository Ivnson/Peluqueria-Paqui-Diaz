<%-- /WEB-INF/Peluqueria.Vista/PUBLICO/Login.jsp --%>

<%-- DEFINIMOS EL TIPO DE CONTENIDO Y LA CODIFICACIÓN (UTF-8) PARA CARACTERES ESPECIALES --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <%-- 1. IMPORTACIÓN DE CSS: ENLAZAMOS LA HOJA DE ESTILOS EXTERNA --%>
        <%-- USAMOS ${pageContext.request.contextPath} PARA OBTENER LA RUTA RAÍZ DEL PROYECTO  --%>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/Login.css">

        <title>Iniciar Sesión - Peluquería Paqui Diaz</title>

        <style>
            /* ESTILOS CSS INTERNOS ESPECÍFICOS PARA EL LOGO EN ESTA PÁGINA */
            .logo {
                text-align: center;
                margin-bottom: 30px;
                padding: 20px 0;
                
            }

            .logo img {
                max-width: 200px;
                height: auto;
                border-radius: 220px ; 
            }
        </style>
    </head>
    <body>

        <div class="split-screen-container">

            <%-- 2. PANEL IZQUIERDO : MUESTRA EL LOGOTIPO DE LA EMPRESA --%>
            <div class="left-pane">
                <div class="logo">
                    <%-- ENLACE QUE REDIRIGE A LA PÁGINA PRINCIPAL --%>
                    <a href="${pageContext.request.contextPath}/">
                        <img src="${pageContext.request.contextPath}/img/logopeluqueria.png" alt="LOGO"/>
                    </a>
                </div>
            </div>

            <%-- 3. PANEL DERECHO: ZONA DE INTERACCIÓN DEL USUARIO --%>
            <div class="right-pane">

                <div class="login-form-area">
                    <h1>Iniciar Sesión</h1>

                    <%-- 4. MANEJADOR DE ERRORES : COMPRUEBA SI EL LOGIN FALLÓ ANTERIORMENTE --%>
                    <%
                        // RECUPERAMOS EL MENSAJE DE ERROR QUE EL SERVLET PUDO HABER GUARDADO EN EL REQUEST
                        // EJEMPLO: "Contraseña incorrecta"
                        String loginError = (String) request.getAttribute("loginError");
                        
                        // SI EXISTE UN ERROR (NO ES NULL) Y TIENE TEXTO, MOSTRAMOS EL BLOQUE DE ALERTA
                        if (loginError != null && !loginError.isEmpty()) {
                    %>
                    <div class="error-msg">
                        <%-- IMPRIMIMOS EL TEXTO DEL ERROR EN EL HTML VISIBLE --%>
                        <%= loginError%>
                    </div>
                    <% } // CERRAMOS LA LLAVE DEL IF DE JAVA %>

                    <%-- 5. FORMULARIO DE LOGIN --%>
                    <%-- ACTION: INDICA QUE LOS DATOS SE ENVIARÁN AL SERVLET '/Login' --%>
                    <%-- METHOD: 'POST' PARA ENVIAR LA CONTRASEÑA DE FORMA PRIVADA (NO EN LA URL) --%>
                    <form action="${pageContext.request.contextPath}/Login" method="POST">

                        <div class="form-group">
                            <%-- INPUT EMAIL: 'NAME="email"' ES LA CLAVE QUE USARÁ EL SERVLET PARA LEER EL DATO --%>
                            <input type="email" id="login_email" name="email" placeholder="Email" required>
                        </div>

                        <div class="form-group">
                            <%-- INPUT PASSWORD: TIPO 'PASSWORD' PARA OCULTAR LOS CARACTERES --%>
                            <input type="password" id="login_pass" name="password" placeholder="Contraseña" required>
                        </div>

                        <button type="submit" class="btn-submit">Entrar</button>
                    </form>

                    <%-- 6. ENLACE DE REGISTRO: REDIRIGE AL USUARIO SI AÚN NO TIENE CUENTA --%>
                    <div class="register-link">
                        <a href="${pageContext.request.contextPath}/Registro">¡Regístrate aquí!</a>
                    </div>

                </div>

            </div>

        </div>

    </body>
</html>