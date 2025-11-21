<%@page import="java.util.Set"%>
<%@page import="java.util.HashSet"%>
<%@page import="Peluqueria.modelo.SERVICIO"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/formulario_usuario.css">
        <title>Solicitar Cita - Peluquería Paqui Diaz</title>
    </head>
    <body>

        <%
            List<SERVICIO> listaServicios = (List<SERVICIO>) request.getAttribute("servicios");
            String error = (String) request.getAttribute("error");

            // Lógica de RE-POBLADO para errores
            String fechaMostrada = request.getParameter("fecha");
            if (fechaMostrada == null) {
                fechaMostrada = "";
            }

            String horaMostrada = request.getParameter("HoraInicio");
            if (horaMostrada == null) {
                horaMostrada = "";
            }

            String[] idsServiciosSeleccionados = request.getParameterValues("serviciosIds");
            Set<String> setServiciosIds = new HashSet<>();
            if (idsServiciosSeleccionados != null) {
                for (String s : idsServiciosSeleccionados) {
                    setServiciosIds.add(s);
                }
            }
        %>

        <div class="form-container">
            <h1>Solicitar Nueva Cita</h1>

            <%-- Mostrar errores --%>
            <% if (error != null && !error.isEmpty()) {%>
            <div class="error-msg">
                <strong>Error:</strong> <%= error%>
            </div>
            <% } %>

            <form action="${pageContext.request.contextPath}/Perfil/Citas/Crear" method="POST">

                <%-- SERVICIOS --%>
                <div class="form-group">
                    <label for="serviciosIds">Servicios:</label>
                    <select name="serviciosIds" id="serviciosIds" multiple required size="5">
                        <%
                            if (listaServicios != null) {
                                for (SERVICIO servicio : listaServicios) {
                                    String seleccionado = setServiciosIds.contains(String.valueOf(servicio.getId()))
                                            ? "selected" : "";
                        %>
                        <option value="<%= servicio.getId()%>" <%= seleccionado%>>
                            <%= servicio.getNombreServicio()%> (<%= String.format("%.2f", servicio.getPrecio())%> €)
                        </option>
                        <%
                                }
                            }
                        %>
                    </select>
                    <small style="color: #f0f0f0; opacity: 0.8;">Mantén Ctrl (o Cmd) para seleccionar varios servicios.</small>
                </div>

                <%-- FECHA --%>
                <div class="form-group">
                    <label for="fecha">Fecha de la Cita:</label>
                    <input type="date" id="fecha" name="fecha" value="<%= fechaMostrada%>" required 
                           min="<%= java.time.LocalDate.now().plusDays(1)%>">
                </div>

                <%-- HORA --%>
                <div class="form-group">
                    <label for="HoraInicio">Hora de Inicio:</label>
                    <input type="time" id="HoraInicio" name="HoraInicio" value="<%= horaMostrada%>" required
                           min="09:00" max="20:00">
                </div>

                <%-- BOTONES --%>
                <div class="button-group">
                    <button type="submit" class="btn btn-submit">Solicitar Cita</button>
                    <a href="${pageContext.request.contextPath}/Perfil/Panel" class="btn btn-cancel">
                        Cancelar
                    </a>
                </div>
            </form>
        </div>


        <script>
            document.addEventListener('DOMContentLoaded', function () {
                const urlParams = new URLSearchParams(window.location.search);
                const fecha = urlParams.get('fecha');
                const hora = urlParams.get('hora');

                if (fecha && hora) {
                    document.getElementById('fecha').value = fecha;
                    document.getElementById('HoraInicio').value = hora;
                }
            });
        </script>

    </body>
</html>