<%-- 
    Document   : formulario_cita
    Created on : 6 nov 2025, 19:25:00
    Author     : ivan
--%>

<%@page import="java.util.Set"%>
<%@page import="java.util.HashSet"%>
<%@page import="Peluqueria.modelo.SERVICIO"%>
<%@page import="Peluqueria.modelo.USUARIO"%>
<%@page import="java.util.List"%>
<%@page import="Peluqueria.modelo.CITA"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    
    <%-- ¡Reutilizamos el mismo CSS del formulario de servicios! --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/formulario_usuario.css">
    
    <title>Formulario de Cita</title>
</head>
<body>

    <%
        // --- 3. LÓGICA DE JAVA (SCRIPTLET) ---

        // Obtenemos los 3 atributos que envía el ControladorCitas
        CITA cita = (CITA) request.getAttribute("cita");
        List<USUARIO> listaClientes = (List<USUARIO>) request.getAttribute("usuarios");
        List<SERVICIO> listaServicios = (List<SERVICIO>) request.getAttribute("servicios");
        String error = (String) request.getAttribute("error");

        // Definimos el modo (Crear vs Editar)
        String modo = (cita != null) ? "editar" : "crear";
        String urlAccion = (modo.equals("editar"))
                ? request.getContextPath() + "/Admin/Citas/Actualizar" // (Usamos minúsculas, como en el controlador)
                : request.getContextPath() + "/Admin/Citas/Crear";

        // --- Lógica de RE-POBLADO (para errores y modo editar) ---
        // Esto es clave para que el formulario no se borre si hay un error
        
        // 1. Cliente (Usuario)
        String idClienteSeleccionado = request.getParameter("usuarioId"); // Dato de error
        if (idClienteSeleccionado == null && modo.equals("editar")) {
             idClienteSeleccionado = String.valueOf(cita.getUsuario().getId()); // Dato de edición
        }

        // 2. Servicios
        String[] idsServiciosSeleccionados = request.getParameterValues("serviciosIds"); // Datos de error
        Set<String> setServiciosIds = new HashSet<>();
        if (idsServiciosSeleccionados != null) {
            for(String s : idsServiciosSeleccionados) setServiciosIds.add(s);
        } else if (modo.equals("editar") && cita.getServiciosSet() != null) {
            for (SERVICIO s : cita.getServiciosSet()) {
                setServiciosIds.add(String.valueOf(s.getId())); // Datos de edición
            }
        }
        
        // 3. Fecha
        String fechaMostrada = request.getParameter("fecha"); // Dato de error
        if (fechaMostrada == null && modo.equals("editar")) {
            fechaMostrada = cita.getFecha().toString(); // Dato de edición
        } else if (fechaMostrada == null) {
            fechaMostrada = ""; // Dato de creación
        }

        // 4. Hora
        String horaMostrada = request.getParameter("horaInicio"); // Dato de error
        if (horaMostrada == null && modo.equals("editar")) {
            horaMostrada = cita.getHoraInicio().toString(); // Dato de edición
        } else if (horaMostrada == null) {
            horaMostrada = ""; // Dato de creación
        }
    %>

    <div class="form-container">

        <h1>
            <% if (modo.equals("editar")) { %>
                Editar Cita
            <% } else { %>
                Crear Nueva Cita
            <% } %>
        </h1>

        <%-- Mostrar errores, si los hay --%>
        <% if (error != null && !error.isEmpty()) {%>
        <div class="error-msg">
            <strong>Error:</strong> <%= error%>
        </div>
        <% }%>


        <form action="<%= urlAccion%>" method="POST">

            <% if (modo.equals("editar")) {%>
                <input type="hidden" name="id" value="<%= cita.getId()%>" />
            <% }%>

            <%-- CAMPO 1: CLIENTE (Menú desplegable) --%>
            <div class="form-group">
                <label for="usuarioID">Cliente:</label>
                <select name="usuarioID" id="usuarioID" required>
                    <option value="">-- Seleccione un cliente --</option>
                    <%
                        if (listaClientes != null) {
                            for (USUARIO cliente : listaClientes) {
                                // Lógica para marcar como "selected" si es el cliente de la cita
                                String seleccionado = (idClienteSeleccionado != null && idClienteSeleccionado.equals(String.valueOf(cliente.getId())))
                                        ? "selected" : "";
                    %>
                                <option value="<%= cliente.getId() %>" <%= seleccionado %>>
                                    <%= cliente.getNombreCompleto() %> (<%= cliente.getEmail() %>)
                                </option>
                    <%
                            } // Cierre del for
                        } // Cierre del if
                    %>
                </select>
            </div>

            <%-- CAMPO 2: SERVICIOS (Menú desplegable MÚLTIPLE) --%>
            <div class="form-group">
                <label for="serviciosIds">Servicios:</label>
                <select name="serviciosIds" id="serviciosIds" multiple required size="5">
                    <%
                        String seleccionado = null ;
                        if (listaServicios != null) {
                            for (SERVICIO servicio : listaServicios) {
                                // Lógica para marcar como "selected"
                                if(setServiciosIds.contains(String.valueOf(servicio.getId())))
                                {
                                    seleccionado = "selected" ; 
                                }
                                else
                                {
                                    seleccionado = "" ; 
                                }
                    %>
                                <option value="<%= servicio.getId() %>" <%= seleccionado %>>
                                    <%= servicio.getNombreServicio() %> (<%= servicio.getPrecio() %> €)
                                </option>
                    <%
                            } 
                        } 
                    %>
                </select>
                <small style="color: #f0f0f0; opacity: 0.8;">Mantén Ctrl (o Cmd) para seleccionar varios.</small>
            </div>

            <%-- FECHA --%>
            <div class="form-group">
                <label for="fecha">Fecha de la Cita:</label>
                <input type="date" id="fecha" name="fecha" value="<%= fechaMostrada %>" required>
            </div>

            <%--  HORA --%>
            <div class="form-group">
                <label for="HoraInicio">Hora de Inicio:</label>
                <input type="time" id="HoraInicio" name="HoraInicio" value="<%= horaMostrada %>" required>
            </div>


            <%-- BOTONES --%>
            <div class="button-group">
                <% if (modo.equals("editar")) { %>
                <button type="submit" class="btn btn-submit">Guardar Cambios</button>
                <% } else { %>
                <button type="submit" class="btn btn-submit">Crear Cita</button>
                <% }%>

                <a href="${pageContext.request.contextPath}/Admin/Citas/Listar" class="btn btn-cancel">
                    Cancelar
                </a>
            </div>

        </form>
    </div>

</body>
</html>
