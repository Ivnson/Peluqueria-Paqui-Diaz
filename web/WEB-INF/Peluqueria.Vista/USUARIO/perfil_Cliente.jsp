<%-- /WEB-INF/Peluqueria.Vista/CLIENTE/perfil_cliente.jsp --%>
<%@page import="Peluqueria.modelo.USUARIO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <%-- ¡Reutilizamos el CSS del formulario de admin! --%>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/formulario_usuario.css"> 
        <title>Mi Perfil</title>
    </head>
    <body>

        <%
            // Obtenemos el usuario que el servlet nos envía
            USUARIO usuario = (USUARIO) request.getAttribute("usuario");
            String error = (String) request.getAttribute("error");

            // La URL siempre apunta a actualizar el perfil
            String urlAccion = request.getContextPath() + "/Perfil/Actualizar";

            // Rellenamos los campos
            String nombre;
            if (usuario != null) {
                nombre = usuario.getNombreCompleto();
            } else {
                nombre = "";
            }

            String email;
            if (usuario != null) {
                email = usuario.getEmail();
            } else {
                email = "";
            }

            String telefono;
            if (usuario != null && usuario.getTelefono() != null) {
                telefono = String.valueOf(usuario.getTelefono());
            } else {
                telefono = "";
            }
        %>

        <div class="form-container">
            <h1>Modificar mi Perfil</h1>

            <% if (error != null && !error.isEmpty()) {%>
            <div class="error-msg">
                <strong>Error:</strong> <%= error%>
            </div>
            <% }%>

            <form action="<%= urlAccion%>" method="POST">

                <%-- El ID no lo necesitamos, el servlet lo sabe por la sesión --%>

                <div class="form-group">
                    <label for="NombreCompleto">Nombre Completo:</label>
                    <input type="text" id="NombreCompleto" name="NombreCompleto" value="<%= nombre%>" required>
                </div>

                <div class="form-group">
                    <label for="Email">Email:</label>
                    <input type="text" id="Email" name="Email" value="<%= email%>" required>
                </div>

                <%-- ¡CAMPO ROL ELIMINADO! --%>

                <div class="form-group">
                    <label for="Telefono">Telefono :</label>
                    <input type="number" id="Telefono" name="Telefono" value="<%= telefono%>" required>
                </div>

                <div class="form-group">
                    <label for="password">Nueva Contraseña (dejar en blanco para no cambiar)</label>
                    <input type="password" id="password" name="password">
                </div>

                <div class="button-group">
                    <button type="submit" class="btn btn-submit">Guardar Cambios</button>
                    <a href="${pageContext.request.contextPath}/Perfil/Panel" class="btn btn-cancel">
                        Cancelar
                    </a>
                </div>
            </form>
        </div>
    </body>
</html>