<%-- /WEB-INF/Peluqueria.Vista/CLIENTE/Panel_Cliente.jsp --%>


<%@ page import="Peluqueria.modelo.USUARIO" %>
<%@ page import="Peluqueria.modelo.CITA" %>
<%@ page import="Peluqueria.modelo.HISTORIAL_CITA" %> 
<%@ page import="Peluqueria.modelo.SERVICIO" %>
<%@ page import="java.util.List" %> 
<%@ page import="java.util.Set" %>
<%@ page import="java.time.format.DateTimeFormatter" %> <%-- CLASE PARA PONER LAS FECHAS BONITAS (EJ: 12/10/2023) --%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Mi Panel - Peluquería Paqui Diaz</title>

        <%-- VINCULAMOS LA HOJA DE ESTILOS CSS --%>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/Panel_Cliente.css">

        <style>
            /* ESTILOS INTERNOS PARA LA CABECERA Y BOTONES */
            header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 1rem 2rem;
                background-color: var(--gris-fondo);
                border-bottom: 1px solid var(--gris-bordes);
            }

            .header-buttons {
                display: flex;
                gap: 1rem;
            }

            .btn-logout {
                padding: 0.5rem 1rem;
                background-color: #dee2e6;
                color: var(--texto-oscuro);
                text-decoration: none;
                border-radius: 5px;
                font-weight: 600;
                transition: all 0.2s ease-out;
                white-space: nowrap;
            }

            .btn-logout:hover {
                background-color: #7f8c8d;
            }

            /* MEDIA QUERIES PARA QUE SE VEA BIEN EN MÓVILES */
            @media (max-width: 768px) {
                header {
                    flex-direction: column;
                    gap: 1rem;
                    padding: 1rem;
                    text-align: center;
                }

                .header-buttons {
                    flex-wrap: wrap;
                    justify-content: center;
                    gap: 0.75rem;
                }

                .btn-logout {
                    padding: 0.5rem 0.8rem;
                    font-size: 0.9rem;
                }
            }

            @media (max-width: 480px) {
                header h1 {
                    font-size: 1.5rem;
                }

                .header-buttons {
                    flex-direction: column;
                    width: 100%;
                    gap: 0.5rem;
                }

                .btn-logout {
                    width: 100%;
                    padding: 0.75rem;
                    text-align: center;
                }
            }
        </style>

    </head>
    <body>

        <%
            // --- 1. BLOQUE JAVA DE INICIALIZACIÓN ---

            // RECUPERAMOS AL USUARIO DE LA SESIÓN 
            USUARIO usuario = (USUARIO) session.getAttribute("usuarioLogueado");

            // RECUPERAMOS LOS DATOS QUE EL SERVLET  NOS HA ENVIADO EN EL REQUEST
            // 'citaActiva': PUEDE SER NULL SI EL CLIENTE NO TIENE CITA PENDIENTE
            // 'historialCitas': LISTA DE CITAS PASADAS
            CITA citaActiva = (CITA) request.getAttribute("citaActiva");
            List<HISTORIAL_CITA> historialCitas = (List<HISTORIAL_CITA>) request.getAttribute("historialCitas");

            // DEFINIMOS EL FORMATO EN EL QUE QUEREMOS MOSTRAR LAS FECHAS Y HORAS
            DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
            DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HH:mm");

            // LÓGICA PARA OBTENER SOLO EL PRIMER NOMBRE DEL CLIENTE (ESTÉTICA)
            String nombreCliente = "Cliente";
            if (usuario != null) {
                // SPLIT SEPARA EL NOMBRE COMPLETO POR ESPACIOS Y COGEMOS EL PRIMERO
                nombreCliente = usuario.getNombreCompleto().split(" ")[0];
            }
        %>

        <div class="container">

            <header>
                <%-- IMPRIMIMOS EL NOMBRE DEL CLIENTE --%>
                <h1><span>Hola,</span> <%= nombreCliente%>!</h1>
                <div class="header-buttons">

                    <%
                        // SI EL USUARIO ES ADMIN, LE MOSTRAMOS UN BOTÓN EXTRA
                        if (usuario.getRol().equals("Administrador")) {
                    %>

                    <%-- BOTÓN EXCLUSIVO PARA ADMINISTRADORES --%>
                    <a href="${pageContext.request.contextPath}/Admin/Panel" class="btn-logout">
                        Panel Admin
                    </a>

                    <a href="${pageContext.request.contextPath}/" class="btn-logout">
                        Ir al Inicio
                    </a>
                    <a href="${pageContext.request.contextPath}/Logout" class="btn-logout">Cerrar Sesión</a>

                    <%
                        // SI ES UN CLIENTE NORMAL
                    } else {
                    %>

                    <a href="${pageContext.request.contextPath}/" class="btn-logout">
                        Ir al Inicio
                    </a>
                    <a href="${pageContext.request.contextPath}/Logout" class="btn-logout">Cerrar Sesión</a>


                    <%
                        }
                    %>
                </div>
            </header>

            <%
                // --- 2. LÓGICA PRINCIPAL DE VISUALIZACIÓN ---
                // SI 'citaActiva' NO ES NULL, SIGNIFICA QUE HAY UNA CITA PENDIENTE
                // MOSTRAMOS EL DASHBOARD COMPLETO CON DETALLES
                if (citaActiva != null) {

            %>

            <%-- BLOQUE A: SE MUESTRA SOLO SI HAY CITA ACTIVA --%>
            <div class="kpi-grid">
                <%-- TARJETA 1: FECHA Y HORA --%>
                <div class="kpi-card">
                    <div class="label">Tu Próxima Cita</div>
                    <div class="value"><%= citaActiva.getFecha().format(dateFormatter)%></div>
                    <div class="detail">Hora: <%= citaActiva.getHoraInicio().format(timeFormatter)%></div>
                </div>

                <%-- TARJETA 2: TOTAL DE SERVICIOS Y PRECIO CALCULADO --%>
                <div class="kpi-card">
                    <div class="label">Servicios Reservados</div>
                    <div class="value"><%= citaActiva.getServiciosSet().size()%></div>
                    <%
                        // BUCLE JAVA PARA SUMAR EL PRECIO DE TODOS LOS SERVICIOS DE LA CITA
                        double totalPrecio = 0;
                        for (SERVICIO s : citaActiva.getServiciosSet()) {
                            totalPrecio += s.getPrecio();
                        }
                    %>
                    <div class="detail">Precio total estimado: <%= String.format("%.2f", totalPrecio)%> €</div>
                </div>

                <%-- TARJETA 3: ESTADO --%>
                <div class="kpi-card">
                    <div class="label">Estado</div>
                    <div class="value">Confirmada</div>
                    <div class="detail">¡Te esperamos!</div>
                </div>
            </div>

            <div class="content-area">

                <%-- TARJETA DE DETALLES: LISTA DESGLOSADA DE SERVICIOS --%>
                <div class="content-card">
                    <h2>Detalles de mi Cita</h2>
                    <ul class="servicios-list">
                        <%
                            // BUCLE PARA IMPRIMIR CADA SERVICIO EN UNA LISTA 
                            Set<SERVICIO> servicios = citaActiva.getServiciosSet();
                            for (SERVICIO s : servicios) {
                        %>
                        <li><%= s.getNombreServicio()%> - <%= String.format("%.2f", s.getPrecio())%> €</li>
                            <%
                                }
                            %>
                    </ul>
                </div>

                <%-- TARJETA DE ACCIONES (CANCELAR, EDITAR PERFIL) --%>
                <div class="content-card">
                    <h2>Acciones</h2>
                    <ul class="acciones-list">
                        <li>
                            <a href="${pageContext.request.contextPath}/Perfil/Editar">Modificar mis datos</a>
                        </li>
                        <li>
                            <%-- FORMULARIO PARA CANCELAR LA CITA. 
                                 SE USA UN FORM Y NO UN ENLACE 'A' PORQUE ES UNA ACCIÓN DESTRUCTIVA (POST) --%>
                            <form action="${pageContext.request.contextPath}/Perfil/Citas/Cancelar" method="POST" onsubmit="return confirm('¿Estás seguro de que quieres cancelar tu cita?');">
                                <input type="hidden" name="idCita" value="<%= citaActiva.getId()%>" />
                                <button type="submit" class="btn-cancelar">Cancelar mi cita</button>
                            </form>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/Perfil/Citas/Historial">Ver Historial de Citas</a>
                        </li>
                    </ul>
                </div>

            </div>

            <%
                // --- BLOQUE B: SE MUESTRA SI NO HAY CITA ACTIVA ---
            } else {
            %>

            <div class="content-area">

                <%-- TARJETA DE PEDIR CITA --%>
                <div class="content-card no-cita-card">
                    <h2 class="h2Cita">No tienes ninguna cita activa</h2>
                    <p>¡Reserva ahora para empezar a cuidar tu look!</p>
                    <%-- BOTÓN QUE LLEVA AL FORMULARIO DE NUEVA CITA --%>
                    <a href="${pageContext.request.contextPath}/Perfil/Citas/Nueva" class="btn-pedir-cita">
                        Pedir Cita Ahora
                    </a>
                </div>

                <%-- TARJETA DE ACCIONES  --%>
                <div class="content-card">
                    <h2>Mi Perfil y Acciones</h2>
                    <ul class="acciones-list">
                        <li>
                            <a href="${pageContext.request.contextPath}/Perfil/Editar">Modificar mis datos</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/Perfil/Citas/Historial">Ver Historial de Citas</a>
                        </li>
                    </ul>
                </div>

            </div>

            <%
                } // FIN DEL IF/ELSE PRINCIPAL
            %>

            <%-- --- 3. SECCIÓN DEL HISTORIAL DE CITAS (SIEMPRE VISIBLE SI HAY DATOS) --- --%>
            <%
                // SOLO MOSTRAMOS ESTE BLOQUE SI LA LISTA EXISTE Y TIENE AL MENOS UNA CITA PASADA
                if (historialCitas != null && !historialCitas.isEmpty()) {
            %>
            <div class="historial-grid" id="historial">
                <div class="content-card" style="grid-column: 1 / -1;"> 
                    <h2>Historial de Citas Pasadas</h2>

                    <%
                        // BUCLE PARA RECORRER EL HISTORIAL
                        for (HISTORIAL_CITA hCita : historialCitas) {
                            // CALCULAMOS EL PRECIO TOTAL DE CADA CITA DEL HISTORIAL 
                            double historialTotalPrecio = 0;
                            if (hCita.getServiciosSet() != null) {
                                for (SERVICIO s : hCita.getServiciosSet()) {
                                    historialTotalPrecio += s.getPrecio();
                                }
                            }
                    %>
                    <%-- DIBUJAMOS CADA ÍTEM DEL HISTORIAL --%>
                    <div class="historial-item">
                        <div class="historial-icon">📅</div>
                        <div class="historial-details">
                            <div class="main-info">Cita del <%= hCita.getFecha().format(dateFormatter)%> a las <%= hCita.getHoraInicio().format(timeFormatter)%></div>
                            <div class="secondary-info">
                                <span><%= hCita.getServiciosSet().size()%> servicios</span>
                                <span>Total: <%= String.format("%.2f", historialTotalPrecio)%> €</span>
                            </div>
                        </div>
                    </div>
                    <%
                        } // FIN DEL BUCLE FOR
                    %>
                </div>
            </div>
            <% } // FIN DEL IF HISTORIAL %>

        </div> 

    </body>
</html>