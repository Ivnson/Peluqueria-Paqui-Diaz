<%-- /WEB-INF/Peluqueria.Vista/PUBLICO/Registro.jsp --%>

<%-- DEFINICIÓN DE LA PÁGINA: ESTABLECEMOS EL TIPO DE CONTENIDO Y LA CODIFICACIÓN DE CARACTERES PARA EVITAR PROBLEMAS CON Ñ Y TILDES --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <%-- 1. IMPORTACIÓN DE CSS: REUTILIZAMOS EL MISMO ARCHIVO 'LOGIN.CSS' PARA QUE EL REGISTRO TENGA EL MISMO ESTILO QUE EL LOGIN --%>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/Login.css">

        <title>Registro - Peluquería Paqui Diaz</title>
        <style>
            /* ESTILOS ESPECÍFICOS PARA EL LOGO EN ESTA PÁGINA */
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

            <%-- 2. PANEL IZQUIERDO  --%>
            <div class="left-pane">
                <div class="logo">
                    <%-- ENLACE QUE REDIRIGE A LA PÁGINA DE INICIO --%>
                    <a href="${pageContext.request.contextPath}/">
                        <img src="${pageContext.request.contextPath}/img/logopeluqueria.png" alt="LOGO"/>
                    </a>
                </div>
            </div>

            <%-- 3. PANEL DERECHO  --%>
            <div class="right-pane">

                <div class="login-form-area">

                    <h1>Regístrate</h1>

                    <%-- 4. MANEJADOR DE ERRORES  --%>
                    <%
                        // RECUPERAMOS EL ATRIBUTO 'registroError' QUE EL SERVLET PUDO HABER ENVIADO SI FALLÓ EL REGISTRO
                        String regError = (String) request.getAttribute("registroError");
                        
                        // SOLO SI EXISTE UN ERROR Y NO ESTÁ VACÍO, MOSTRAMOS EL DIV DE ALERTA
                        if (regError != null && !regError.isEmpty()) {
                    %>
                    <div class="error-msg">
                        <%-- IMPRIMIMOS EL MENSAJE DE ERROR EN LA PANTALLA --%>
                        <%= regError%>
                    </div>
                    <% } // CERRAMOS EL IF DE JAVA %>

                    <%-- 5. FORMULARIO DE REGISTRO --%>
                    <%-- ACTION: INDICA QUE AL PULSAR EL BOTÓN, LOS DATOS SE ENVIARÁN AL SERVLET '/REGISTRO' --%>
                    <%-- METHOD: 'POST' PORQUE ESTAMOS ENVIANDO DATOS --%>
                    <form action="${pageContext.request.contextPath}/Registro" method="POST">

                        <div class="form-group">
                            <%-- NAME="NOMBRECOMPLETO": ESTE ES EL NOMBRE QUE USARÁ EL SERVLET CON request.getParameter("NombreCompleto") --%>
                            <input type="text" id="reg_nombre" name="NombreCompleto" placeholder="Nombre Completo" required>
                        </div>

                        <div class="form-group">
                            <input type="email" id="reg_email" name="Email" placeholder="Email" required>
                        </div>

                        <div class="form-group">
                            <input type="number" id="reg_tel" name="Telefono" placeholder="Teléfono" required>
                        </div>

                        <div class="form-group">
                            <input type="password" id="reg_pass" name="password" placeholder="Crear Contraseña" required>
                        </div>

                        <button type="submit" class="btn-submit">Crear Cuenta</button>
                    </form>

                    <%-- 6. ENLACE PARA VOLVER AL LOGIN SI YA TIENES CUENTA --%>
                    <div class="register-link">
                        <a href="${pageContext.request.contextPath}/Login">¡Ya tienes cuenta? Inicia sesión</a>
                    </div>

                </div>

            </div>

        </div>

    </body>
</html>