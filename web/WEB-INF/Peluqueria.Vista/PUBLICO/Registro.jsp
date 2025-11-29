<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <%-- 1. ¡Reutilizamos EXACTAMENTE el mismo CSS que el login! --%>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/Login.css">

        <title>Registro - Peluquería Paqui Diaz</title>
        <style>
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

            <%-- 2. PANEL IZQUIERDO (Branding) - Es idéntico --%>
            <div class="left-pane">
                <div class="logo">
                    <a href="${pageContext.request.contextPath}/">
                        <img src="${pageContext.request.contextPath}/img/logopeluqueria.png" alt="LOGO"/>
                    </a>
                </div>
            </div>

            <%-- 3. PANEL DERECHO (Formulario de Registro) --%>
            <div class="right-pane">

                <div class="login-form-area">

                    <%-- Título cambiado --%>
                    <h1>Regístrate</h1>

                    <%-- 4. Manejador de Errores (para el registro) --%>
                    <%
                        String regError = (String) request.getAttribute("registroError");
                        if (regError != null && !regError.isEmpty()) {
                    %>
                    <div class="error-msg">
                        <%= regError%>
                    </div>
                    <% }%>

                    <%-- 5. Formulario de Registro --%>
                    <%-- Apunta al servlet de /registro --%>
                    <form action="${pageContext.request.contextPath}/Registro" method="POST">

                        <div class="form-group">
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

                        <%-- Botón cambiado --%>
                        <button type="submit" class="btn-submit">Crear Cuenta</button>
                    </form>

                    <%-- 6. Enlace de Login (cambiado) --%>
                    <div class="register-link">
                        <a href="${pageContext.request.contextPath}/Login">¡Ya tienes cuenta? Inicia sesión</a>
                    </div>

                </div>

            </div>

        </div>

    </body>
</html>