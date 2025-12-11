<%-- 
    Document   : formulario_cita
    Created on : 6 nov 2025, 19:25:00
    Author     : ivan
--%>

<%-- IMPORTAMOS LAS COLECCIONES (LIST, SET, HASHSET) Y LOS MODELOS NECESARIOS --%>
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
    
    <%-- REUTILIZAMOS EL CSS DE OTRO FORMULARIO PARA MANTENER LA COHERENCIA VISUAL --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/formulario_usuario.css">
    
    <title>Formulario de Cita</title>
</head>
<body>

    <%
        // --- INICIO DEL BLOQUE JAVA (SCRIPTLET) ---

        // 1. RECUPERAR DATOS DEL CONTROLADOR (ControladorCitas)
        // 'cita': OBJETO CITA SI ESTAMOS EDITANDO, O NULL SI ES NUEVA.
        // 'listaClientes': TODOS LOS USUARIOS PARA LLENAR EL DESPLEGABLE DE CLIENTES.
        // 'listaServicios': TODOS LOS SERVICIOS PARA LLENAR EL DESPLEGABLE MÚLTIPLE.
        CITA cita = (CITA) request.getAttribute("cita");
        List<USUARIO> listaClientes = (List<USUARIO>) request.getAttribute("usuarios");
        List<SERVICIO> listaServicios = (List<SERVICIO>) request.getAttribute("servicios");
        String error = (String) request.getAttribute("error");

        // 2. DETERMINAR EL MODO (CREAR VS EDITAR)
        String modo = (cita != null) ? "editar" : "crear";
        
        // 3. CONFIGURAR LA URL DE DESTINO SEGÚN EL MODO
        String urlAccion = (modo.equals("editar"))
                ? request.getContextPath() + "/Admin/Citas/Actualizar" 
                : request.getContextPath() + "/Admin/Citas/Crear";

        // --- 4. LÓGICA DE RE-POBLADO DE CAMPOS (STICKY FORM) ---
        // ESTA PARTE ES CRUCIAL: DECIDE QUÉ VALOR PONER EN CADA CAMPO.
        // PRIORIDAD 1: LO QUE ESCRIBIÓ EL USUARIO (SI HUBO UN ERROR AL ENVIAR).
        // PRIORIDAD 2: EL DATO DE LA BASE DE DATOS (SI ESTAMOS EDITANDO).
        // PRIORIDAD 3: VACÍO (SI ES NUEVO).
        
        // A) CLIENTE (USUARIO)
        String idClienteSeleccionado = request.getParameter("usuarioID"); // INTENTAMOS RECUPERAR DEL ENVÍO FALLIDO
        if (idClienteSeleccionado == null && modo.equals("editar")) {
             // SI NO HAY ENVÍO PREVIO PERO ESTAMOS EDITANDO, COGEMOS EL ID DEL CLIENTE DE LA CITA
             idClienteSeleccionado = String.valueOf(cita.getUsuario().getId()); 
        }

        // B) SERVICIOS (LÓGICA COMPLEJA PARA SELECCIÓN MÚLTIPLE)
        // RECUPERAMOS EL ARRAY DE IDs SI HUBO UN ENVÍO FALLIDO
        String[] idsServiciosSeleccionados = request.getParameterValues("serviciosIds"); 
        
        // USAMOS UN 'SET' (CONJUNTO) PARA PODER PREGUNTAR RÁPIDO SI UN SERVICIO ESTÁ SELECCIONADO (.contains)
        Set<String> setServiciosIds = new HashSet<>();
        
        if (idsServiciosSeleccionados != null) {
            // CASO 1: VENIMOS DE UN ERROR, LLENAMOS EL SET CON LO QUE EL USUARIO HABÍA MARCADO
            for(String s : idsServiciosSeleccionados) setServiciosIds.add(s);
        } else if (modo.equals("editar") && cita.getServiciosSet() != null) {
            // CASO 2: ESTAMOS EDITANDO, LLENAMOS EL SET CON LOS SERVICIOS QUE YA TIENE LA CITA EN BD
            for (SERVICIO s : cita.getServiciosSet()) {
                setServiciosIds.add(String.valueOf(s.getId())); 
            }
        }
        
        // C) FECHA
        String fechaMostrada = request.getParameter("fecha"); 
        if (fechaMostrada == null && modo.equals("editar")) {
            fechaMostrada = cita.getFecha().toString(); // FORMATO YYYY-MM-DD AUTOMÁTICO DE LOCALDATE
        } else if (fechaMostrada == null) {
            fechaMostrada = ""; 
        }

        // D) HORA
        String horaMostrada = request.getParameter("horaInicio"); 
        if (horaMostrada == null && modo.equals("editar")) {
            horaMostrada = cita.getHoraInicio().toString(); // FORMATO HH:MM
        } else if (horaMostrada == null) {
            horaMostrada = ""; 
        }
        
        // --- FIN DEL BLOQUE JAVA ---
    %>

    <div class="form-container">

        <%-- TÍTULO DINÁMICO --%>
        <h1>
            <% if (modo.equals("editar")) { %>
                Editar Cita
            <% } else { %>
                Crear Nueva Cita
            <% } %>
        </h1>

        <%-- CAJA DE ERRORES (SI EL SERVLET ENVIÓ ALGUNO) --%>
        <% if (error != null && !error.isEmpty()) {%>
        <div class="error-msg">
            <strong>Error:</strong> <%= error%>
        </div>
        <% }%>

        <%-- FORMULARIO --%>
        <form action="<%= urlAccion%>" method="POST">

            <%-- INPUT OCULTO CON EL ID DE LA CITA (SOLO AL EDITAR) --%>
            <% if (modo.equals("editar")) {%>
                <input type="hidden" name="id" value="<%= cita.getId()%>" />
            <% }%>

            <%-- CAMPO 1: CLIENTE (SELECT SIMPLE) --%>
            <div class="form-group">
                <label for="usuarioID">Cliente:</label>
                <select name="usuarioID" id="usuarioID" required>
                    <option value="">-- Seleccione un cliente --</option>
                    <%
                        // ITERAMOS LA LISTA DE TODOS LOS CLIENTES
                        if (listaClientes != null) {
                            for (USUARIO cliente : listaClientes) {
                                // COMPROBAMOS SI ESTE CLIENTE ES EL QUE DEBE ESTAR SELECCIONADO
                                String seleccionado = (idClienteSeleccionado != null && idClienteSeleccionado.equals(String.valueOf(cliente.getId())))
                                        ? "selected" : "";
                    %>
                                <%-- GENERAMOS LA OPCIÓN HTML --%>
                                <option value="<%= cliente.getId() %>" <%= seleccionado %>>
                                    <%= cliente.getNombreCompleto() %> (<%= cliente.getEmail() %>)
                                </option>
                    <%
                            } 
                        } 
                    %>
                </select>
            </div>

            <%-- CAMPO 2: SERVICIOS (SELECT MÚLTIPLE) --%>
            <div class="form-group">
                <label for="serviciosIds">Servicios:</label>
                <%-- MULTIPLE: PERMITE ELEGIR VARIOS CON CTRL. SIZE="5": MUESTRA 5 OPCIONES DE GOLPE --%>
                <select name="serviciosIds" id="serviciosIds" multiple required size="5">
                    <%
                        String seleccionado = null ;
                        if (listaServicios != null) {
                            for (SERVICIO servicio : listaServicios) {
                                // COMPROBAMOS SI EL ID DE ESTE SERVICIO ESTÁ EN NUESTRO 'SET' DE SELECCIONADOS
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

            <%-- CAMPO 3: FECHA --%>
            <div class="form-group">
                <label for="fecha">Fecha de la Cita:</label>
                <%-- TYPE="DATE": EL NAVEGADOR MUESTRA UN CALENDARIO --%>
                <input type="date" id="fecha" name="fecha" value="<%= fechaMostrada %>" required>
            </div>

            <%-- CAMPO 4: HORA --%>
            <div class="form-group">
                <label for="HoraInicio">Hora de Inicio:</label>
                <%-- TYPE="TIME": EL NAVEGADOR MUESTRA UN RELOJ O SELECTOR DE HORAS --%>
                <input type="time" id="HoraInicio" name="HoraInicio" value="<%= horaMostrada %>" required>
            </div>

            <%-- BOTONES DE ACCIÓN --%>
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