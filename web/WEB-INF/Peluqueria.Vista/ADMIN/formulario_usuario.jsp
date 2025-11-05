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

            String nombre = "";
            String email = "" ;
            String rol = "" ; 
            Long telefono = null ; 

            if (modo.equals("editar")) {
                nombre = usuario.getNombreCompleto() ; 
                email = usuario.getEmail() ; 
                rol = usuario.getRol() ; 
                telefono = usuario.getTelefono() ; 
               
            }


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

                //SUSTITUIR ESTO POR UN DESPLEGABLE CON DOS OPCIONES ---> CLIENTE Y ADMIN 
                <div class="form-group">
                    <label for="Rol">Rol:</label>
                    <input type="text" id="Rol" name="Rol" value="<%= rol%>" required>
                </div>

                <div class="form-group">
                    <label for="Telefono">Telefono :</label>
                    <input type="number" id="Telefono" name="Telefono" value="<%= telefono%>" required>
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

    </body>
</html>
