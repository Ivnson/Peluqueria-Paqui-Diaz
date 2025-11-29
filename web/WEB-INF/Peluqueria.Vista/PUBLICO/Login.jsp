<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <%-- 1. Enlazamos tu NUEVO archivo CSS --%>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/Login.css">

        <title>Iniciar Sesión - Peluquería Paqui Diaz</title>

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

            <%-- 2. PANEL IZQUIERDO (Branding) --%>
            <div class="left-pane">
                <div class="logo">
                    <a href="${pageContext.request.contextPath}/">
                        <img src="${pageContext.request.contextPath}/img/logopeluqueria.png" alt="LOGO"/>
                    </a>
                </div>
            </div>

            <%-- 3. PANEL DERECHO (Formulario) --%>
            <div class="right-pane">

                <div class="login-form-area">
                    <h1>Iniciar Sesión</h1>

                    <%-- 4. Manejador de Errores --%>
                    <%
                        String loginError = (String) request.getAttribute("loginError");
                        if (loginError != null && !loginError.isEmpty()) {
                    %>
                    <div class="error-msg">
                        <%= loginError%>
                    </div>
                    <% }%>

                    <%-- 5. Formulario de Login --%>
                    <form action="${pageContext.request.contextPath}/Login" method="POST">

                        <div class="form-group">
                            <%-- Usamos 'placeholder' como en la imagen --%>
                            <input type="email" id="login_email" name="email" placeholder="Email" required>
                        </div>

                        <div class="form-group">
                            <input type="password" id="login_pass" name="password" placeholder="Contraseña" required>
                        </div>

                        <button type="submit" class="btn-submit">Entrar</button>
                    </form>

                    <%-- 6. Enlace de Registro --%>
                    <div class="register-link">
                        <a href="${pageContext.request.contextPath}/Registro">¡Regístrate aquí!</a>
                    </div>

                </div>

            </div>

        </div>

    </body>
</html>