<%-- 
    Document   : formulario_servicios
    Created on : 4 nov 2025, 18:49:14
    Author     : ivan
--%>

<%-- IMPORTAMOS EL MODELO DE SERVICIO PARA PODER MANEJAR EL OBJETO --%>
<%@page import="Peluqueria.modelo.SERVICIO"%>
<%-- CONFIGURACIÓN DE CODIFICACIÓN PARA CARACTERES ESPECIALES --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <%-- ENLACE AL CSS PARA DAR ESTILO AL FORMULARIO --%>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/formulario_servicio.css">
        <title>Peluqueria Paqui Diaz</title>
    </head>
    <body>

        <%
            // --- INICIO DEL BLOQUE JAVA (LÓGICA DEL SERVIDOR) ---

            // 1. RECUPERAR DATOS
            // INTENTAMOS OBTENER UN OBJETO 'SERVICIO' QUE EL SERVLET (ControladorServicios) PUDO HABER ENVIADO.
            SERVICIO servicio = (SERVICIO) request.getAttribute("servicio");

            // RECUPERAMOS SI HAY ALGÚN MENSAJE DE ERROR (EJ: "PRECIO INVÁLIDO").
            String error = (String) request.getAttribute("error");

            // 2. CONFIGURACIÓN POR DEFECTO (MODO CREAR)
            String modo = "crear";
            // LA URL A LA QUE SE ENVIARÁ EL FORMULARIO POR DEFECTO
            String urlAccion = request.getContextPath() + "/Admin/Servicios/Crear";

            // 3. DETECCIÓN DE MODO EDITAR
            // SI EL OBJETO SERVICIO NO ES NULL, SIGNIFICA QUE VENIMOS DE PULSAR EL BOTÓN "EDITAR" EN LA LISTA.
            if (servicio != null) {
                modo = "editar";
                // CAMBIAMOS LA URL PARA QUE APUNTE A LA ACCIÓN DE ACTUALIZAR
                urlAccion = request.getContextPath() + "/Admin/Servicios/Actualizar";
            }

            // 4. PREPARACIÓN DE VARIABLES PARA LOS INPUTS
            // INICIALIZAMOS LAS VARIABLES VACÍAS PARA EL MODO "CREAR".
            String nombre = "";
            String descripcion = "";
            String duracion = "";
            String precio = "";

            // SI ESTAMOS EN MODO EDITAR, RELLENAMOS LAS VARIABLES CON LOS DATOS DE LA BASE DE DATOS.
            // ESTO HARÁ QUE LAS CAJAS DE TEXTO APAREZCAN YA RELLENAS.
            if (modo.equals("editar")) {
                nombre = servicio.getNombreServicio();
                descripcion = servicio.getDescripcion();
                // CONVERTIMOS LOS NÚMEROS A STRING PARA PODER PONERLOS EN EL HTML
                duracion = String.valueOf(servicio.getDuracion());
                precio = String.valueOf(servicio.getPrecio());
            }
            
            // --- FIN DEL BLOQUE JAVA ---
        %>

        <div class="form-container">

            <%-- TÍTULO DINÁMICO: CAMBIA SEGÚN SI CREAMOS O EDITAMOS --%>
            <h1>
                <% if (modo.equals("editar")) { %>
                Editar Servicio
                <% } else { %>
                Crear Nuevo Servicio
                <% } %>
            </h1>

            <%-- MOSTRAR MENSAJE DE ERROR SOLO SI EXISTE --%>
            <% if (error != null && !error.isEmpty()) {%>
            <div class="error-msg">
                <strong>Error:</strong> <%= error%>
            </div>
            <% }%>

            <%-- EL FORMULARIO SE ENVIARÁ A LA RUTA CALCULADA ARRIBA (urlAccion) --%>
            <form action="<%= urlAccion%>" method="POST">

                <%-- INPUT HIDDEN (OCULTO) PARA EL ID --%>
                <%-- ES CRUCIAL: AL EDITAR, NECESITAMOS ENVIAR EL ID AL SERVLET PARA QUE SEPA QUÉ REGISTRO ACTUALIZAR. --%>
                <%-- AL CREAR NO LO PONEMOS PORQUE LA BASE DE DATOS GENERA EL ID AUTOMÁTICAMENTE. --%>
                <% if (modo.equals("editar")) {%>
                <input type="hidden" name="id" value="<%= servicio.getId()%>" />
                <% }%>

                <div class="form-group">
                    <label for="NombreServicio">Nombre del Servicio:</label>
                    <%-- VALUE="<%= NOMBRE %>": RELLENA EL CAMPO CON LA VARIABLE JAVA --%>
                    <input type="text" id="NombreServicio" name="NombreServicio" value="<%= nombre%>" required>
                </div>

                <div class="form-group">
                    <label for="Descripcion">Descripción:</label>
                    <%-- EL TEXTAREA NO TIENE ATRIBUTO VALUE, EL TEXTO VA ENTRE LAS ETIQUETAS DE APERTURA Y CIERRE --%>
                    <textarea id="Descripcion" name="Descripcion" rows="4"><%= descripcion%></textarea>
                </div>

                <div class="form-group">
                    <label for="Duracion">Duración (en minutos):</label>
                    <%-- MIN="1": VALIDACIÓN HTML PARA QUE NO PONGAN 0 O NEGATIVOS --%>
                    <input type="number" id="Duracion" name="Duracion" value="<%= duracion%>" min="1" required>
                </div>

                <div class="form-group">
                    <label for="Precio">Precio (€):</label>
                    <%-- STEP="0.01": PERMITE ESCRIBIR DECIMALES (CÉNTIMOS). SI NO LO PONES, SOLO ACEPTA ENTEROS. --%>
                    <input type="number" id="Precio" name="Precio" step="0.01" value="<%= precio%>" min="0.01" required>
                </div>

                <div class="button-group">
                    <%-- TEXTO DEL BOTÓN DINÁMICO --%>
                    <% if (modo.equals("editar")) { %>
                    <button type="submit" class="btn btn-submit">Guardar Cambios</button>
                    <% } else { %>
                    <button type="submit" class="btn btn-submit">Crear Servicio</button>
                    <% }%>

                    <%-- BOTÓN CANCELAR: SIEMPRE REDIRIGE A LA LISTA DE SERVICIOS --%>
                    <a href="${pageContext.request.contextPath}/Admin/Servicios/Listar" class="btn btn-cancel">
                        Cancelar
                    </a>

                </div>

            </form>
        </div>

    </body>
</html>