<%-- 
    Document   : formulario_usuario
    Created on : 5 nov 2025, 22:45:17
    Author     : ivan
--%>

<%@page import="Peluqueria.modelo.USUARIO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/formulario_servicio.css">
        <title>Peluqueria Paqui Diaz</title>
    </head>
    <body>

        <%
            USUARIO usuario = (USUARIO) request.getAttribute("usuario");
            String error = (String) request.getAttribute("error");

            String modo = "crear";
            String urlAccion = request.getContextPath() + "/Admin/Usuarios/Crear";
            if (usuario != null) {
                modo = "editar";
                urlAccion = request.getContextPath() + "/Admin/Usuarios/Actualizar";
            }

            // --- Lógica de re-poblado ---
            // (Mejorado para manejar errores y valores nulos)
            String nombre = (request.getParameter("NombreCompleto") != null) ? request.getParameter("NombreCompleto") : (modo.equals("editar") ? usuario.getNombreCompleto() : "");
            String email = (request.getParameter("Email") != null) ? request.getParameter("Email") : (modo.equals("editar") ? usuario.getEmail() : "");
            String rol = (request.getParameter("Rol") != null) ? request.getParameter("Rol") : (modo.equals("editar") ? usuario.getRol() : "Cliente");

            // Corregido para manejar el 'Long' y 'null' correctamente
            String telefono = (request.getParameter("Telefono") != null) ? request.getParameter("Telefono") : (modo.equals("editar") && usuario.getTelefono() != null ? String.valueOf(usuario.getTelefono()) : "");
        %>

        <div class="form-container">
            <h1>
                <% if (modo.equals("editar")) { %>
                Editar Usuario
                <% } else { %>
                Crear Nuevo Usuario
                <% } %>
            </h1>

            <% if (error != null && !error.isEmpty()) {%>
            <div class="error-msg">
                <strong>Error:</strong> <%= error%>
            </div>
            <% }%>

            <form action="<%= urlAccion%>" method="POST">

                <% if (modo.equals("editar")) {%>
                <input type="hidden" name="id" value="<%= usuario.getId()%>" />
                <% }%>

                <div class="form-group">
                    <label for="NombreCompleto">Nombre del usuario:</label>
                    <input type="text" id="NombreCompleto" name="NombreCompleto" value="<%= nombre%>" required>
                </div>

                <div class="form-group">
                    <label for="Email">Email:</label>
                    <input type="text" id="Email" name="Email" value="<%= email%>" required>
                </div>

                <%-- CAMPO DE ROL (Corregido con desplegable) --%>
                <div class="form-group">
                    <label for="Rol">Rol:</label>
                    <select id="Rol" name="Rol">
                        <option value="Cliente" <%= "Cliente".equals(rol) ? "selected" : ""%>>Cliente</option>
                        <option value="Administrador" <%= "Administrador".equals(rol) ? "selected" : ""%>>Administrador</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="Telefono">Telefono :</label>
                    <input type="number" id="Telefono" name="Telefono" value="<%= telefono%>" required>
                </div>

                <%-- 
                  ¡NUEVO CAMPO DE CONTRASEÑA!
                  - type="password" (para los *)
                  - id="password" (para el JavaScript)
                  - El 'required' solo se pone en modo "crear"
                --%>
                <div class="form-group">
                    <label for="password">
                        <% if (modo.equals("editar")) { %>
                        Nueva Contraseña (dejar en blanco para no cambiar)
                        <% } else { %>
                        Contraseña:
                        <% } %>
                    </label>
                    <input type="password" id="password" name="password" 
                           <% if (modo.equals("crear")) {
                                   out.print("required");
                               } %>>

                    <%-- El botón de "ver/ocultar" --%>
                    <button type="button" id="togglePassword">Ver</button>
                </div>


                <div class="button-group">
                    <% if (modo.equals("editar")) { %>
                    <button type="submit" class="btn btn-submit">Guardar Cambios</button>
                    <% } else { %>
                    <button type="submit" class="btn btn-submit">Crear Usuario</button>
                    <% }%>
                    <a href="${pageContext.request.contextPath}/Admin/Usuarios/Listar" class="btn btn-cancel">
                        Cancelar
                    </a>
                </div>
            </form>
        </div>

        <%-- 
          ¡NUEVO BLOQUE JAVASCRIPT!
          (Se pone al final del <body> para que cargue más rápido)
        --%>
        <script>
            // 1. Seleccionamos el botón y el campo de contraseña
            const toggleButton = document.getElementById('togglePassword');
            const passwordInput = document.getElementById('password');

            // 2. Añadimos un "escuchador" de clics al botón
            toggleButton.addEventListener('click', function () {

                // 3. Comprobamos el tipo de input
                const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';

                // 4. Cambiamos el tipo
                passwordInput.setAttribute('type', type);

                // 5. Cambiamos el texto del botón
                this.textContent = (type === 'password') ? 'Ver' : 'Ocultar';
            });
        </script>

    </body>
</html>
