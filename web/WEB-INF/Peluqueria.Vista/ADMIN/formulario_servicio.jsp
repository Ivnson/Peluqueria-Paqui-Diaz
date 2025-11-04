<%-- 
    Document   : formulario_servicios
    Created on : 4 nov 2025, 18:49:14
    Author     : ivan
--%>

<%@page import="Peluqueria.modelo.SERVICIO"%>
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
            // --- 1. LÓGICA DE JAVA (SCRIPTLET) ---

            // Intentamos obtener el servicio que el Controlador nos envió (en modo "Editar")
            SERVICIO servicio = (SERVICIO) request.getAttribute("servicio");

            // Variable para guardar el mensaje de error (si existe)
            String error = (String) request.getAttribute("error");

            // Variables para decidir el modo y la URL del formulario
            String modo = "crear"; // Por defecto, es un formulario de "Crear"
            String urlAccion = request.getContextPath() + "/Admin/Servicios/Crear"; // URL por defecto

            // Si el objeto 'servicio' NO es nulo, estamos en modo "Editar"
            if (servicio != null) {
                modo = "editar";
                urlAccion = request.getContextPath() + "/Admin/Servicios/Actualizar";
            }

            // Variables para pre-rellenar los campos
            // Por defecto, están vacíos (para modo "Crear")
            String nombre = "";
            String descripcion = "";
            String duracion = "";
            String precio = "";

            // Si estamos en modo "Editar", rellenamos las variables con los datos del servicio
            if (modo.equals("editar")) {
                nombre = servicio.getNombreServicio();
                descripcion = servicio.getDescripcion();
                duracion = String.valueOf(servicio.getDuracion()); // Convertir int a String
                precio = String.valueOf(servicio.getPrecio());     // Convertir float a String
            }

            /*
         * NOTA IMPORTANTE SOBRE ERRORES:
         * Tu 'ControladorServicios' (en CrearServicio y ActualizarServicio)
         * debe enviar el mensaje de error así para que este JSP lo muestre:
         *
         * if (error != null) {
         * request.setAttribute("error", error); // <-- ¡ESTA LÍNEA ES VITAL!
         * request.getRequestDispatcher(...).forward(request, response);
         * }
             */
        %>




        <div class="form-container">

            <h1>
                <% if (modo.equals("editar")) { %>
                Editar Servicio
                <% } else { %>
                Crear Nuevo Servicio
                <% } %>
            </h1>

            <% if (error != null && !error.isEmpty()) {%>
            <div class="error-msg">
                <strong>Error:</strong> <%= error%>
            </div>
            <% }%>


            <form action="<%= urlAccion%>" method="POST">

                <% if (modo.equals("editar")) {%>
                <input type="hidden" name="id" value="<%= servicio.getId()%>" />
                <% }%>

                <div class="form-group">
                    <label for="NombreServicio">Nombre del Servicio:</label>
                    <input type="text" id="NombreServicio" name="NombreServicio" value="<%= nombre%>" required>
                </div>

                <div class="form-group">
                    <label for="Descripcion">Descripción:</label>
                    <textarea id="Descripcion" name="Descripcion" rows="4"><%= descripcion%></textarea>
                </div>

                <div class="form-group">
                    <label for="Duracion">Duración (en minutos):</label>
                    <input type="number" id="Duracion" name="Duracion" value="<%= duracion%>" required>
                </div>

                <div class="form-group">
                    <label for="Precio">Precio (€):</label>
                    <input type="number" id="Precio" name="Precio" step="0.01" value="<%= precio%>" required>
                </div>

                <div class="button-group">
                    <% if (modo.equals("editar")) { %>
                    <button type="submit" class="btn btn-submit">Guardar Cambios</button>
                    <% } else { %>
                    <button type="submit" class="btn btn-submit">Crear Servicio</button>
                    <% }%>

                    <a href="${pageContext.request.contextPath}/Admin/Servicios/Listar" class="btn btn-cancel">
                        Cancelar
                    </a>

                </div>

            </form>
        </div>

    </body>
</html>
