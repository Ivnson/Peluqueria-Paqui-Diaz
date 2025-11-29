<%@ page import="Peluqueria.modelo.USUARIO" %>
<%@ page import="Peluqueria.modelo.CITA" %>
<%@ page import="Peluqueria.modelo.HISTORIAL_CITA" %> <%-- ¡Nueva importación! --%>
<%@ page import="Peluqueria.modelo.SERVICIO" %>
<%@ page import="java.util.List" %> <%-- Para el historial --%>
<%@ page import="java.util.Set" %>
<%@ page import="java.time.format.DateTimeFormatter" %> <%-- Para formatear fechas/horas --%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Mi Panel - Peluquería Paqui Diaz</title>

        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/Panel_Cliente.css">

        <style>
            /* Estilos base para el header */
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

            /* Media Queries para Responsive */
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
            // --- 1. LÓGICA DE JAVA (SCRIPTLET) ---

            // Obtenemos el usuario de la sesión
            USUARIO usuario = (USUARIO) session.getAttribute("usuarioLogueado");

            // Obtenemos la cita activa y el historial del request (¡Tu ControladorCliente debe enviar esto!)
            CITA citaActiva = (CITA) request.getAttribute("citaActiva");
            List<HISTORIAL_CITA> historialCitas = (List<HISTORIAL_CITA>) request.getAttribute("historialCitas");

            // Formateadores para fechas y horas
            DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
            DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HH:mm");

            String nombreCliente = "Cliente";
            if (usuario != null) {
                nombreCliente = usuario.getNombreCompleto().split(" ")[0]; // Solo el primer nombre
            }
        %>

        <div class="container">

            <header>
                <h1><span>Hola,</span> <%= nombreCliente%>!</h1>
                <div class="header-buttons">

                    <%
                        if (usuario.getRol().equals("Administrador")) {
                    %>

                    <a href="${pageContext.request.contextPath}/Admin/Panel" class="btn-logout">
                        Panel Admin
                    </a>

                    <a href="${pageContext.request.contextPath}/" class="btn-logout">
                        Ir al Inicio
                    </a>
                    <a href="${pageContext.request.contextPath}/Logout" class="btn-logout">Cerrar Sesión</a>

                    <%
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
                if (citaActiva != null) {

            %>

            <%-- Tarjetas de Estadísticas (Kudos) --%>
            <div class="kpi-grid">
                <div class="kpi-card">
                    <div class="label">Tu Próxima Cita</div>
                    <div class="value"><%= citaActiva.getFecha().format(dateFormatter)%></div>
                    <div class="detail">Hora: <%= citaActiva.getHoraInicio().format(timeFormatter)%></div>
                </div>
                <div class="kpi-card">
                    <div class="label">Servicios Reservados</div>
                    <div class="value"><%= citaActiva.getServiciosSet().size()%></div>
                    <%
                        double totalPrecio = 0;
                        for (SERVICIO s : citaActiva.getServiciosSet()) {
                            totalPrecio += s.getPrecio();
                        }
                    %>
                    <div class="detail">Precio total estimado: <%= String.format("%.2f", totalPrecio)%> €</div>
                </div>
                <div class="kpi-card">
                    <div class="label">Estado</div>
                    <div class="value">Confirmada</div>
                    <div class="detail">¡Te esperamos!</div>
                </div>
            </div>

            <div class="content-area">

                <%-- Tarjeta 1: Detalle de los Servicios de la Cita --%>
                <div class="content-card">
                    <h2>Detalles de mi Cita</h2>
                    <ul class="servicios-list">
                        <%
                            Set<SERVICIO> servicios = citaActiva.getServiciosSet();
                            for (SERVICIO s : servicios) {
                        %>
                        <li><%= s.getNombreServicio()%> - <%= String.format("%.2f", s.getPrecio())%> €</li>
                            <%
                                }
                            %>
                    </ul>
                </div>

                <%-- Tarjeta 2: Acciones y Perfil --%>
                <div class="content-card">
                    <h2>Acciones</h2>
                    <ul class="acciones-list">
                        <li>
                            <a href="${pageContext.request.contextPath}/Perfil/Editar">Modificar mis datos</a>
                        </li>
                        <li>
                            <%-- Formulario para Cancelar Cita --%>
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
            } else {

            %>

            <div class="content-area">

                <%-- Tarjeta 1: Pedir Cita --%>
                <div class="content-card no-cita-card">
                    <h2 class="h2Cita">No tienes ninguna cita activa</h2>
                    <p>¡Reserva ahora para empezar a cuidar tu look!</p>
                    <a href="${pageContext.request.contextPath}/Perfil/Citas/Nueva" class="btn-pedir-cita">
                        Pedir Cita Ahora
                    </a>
                </div>

                <%-- Tarjeta 2: Perfil y Historial (sin cita activa, más simple) --%>
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

            <%                } // Cierre del if/else citaActiva
            %>

            <%-- --- 3. SECCIÓN DEL HISTORIAL DE CITAS (Abajo) --- --%>
            <% if (historialCitas != null && !historialCitas.isEmpty()) { %>
            <div class="historial-grid" id="historial">
                <div class="content-card" style="grid-column: 1 / -1;"> <%-- Ocupa todo el ancho --%>
                    <h2>Historial de Citas Pasadas</h2>

                    <%
                        for (HISTORIAL_CITA hCita : historialCitas) {
                            // Sumar precios para el detalle
                            double historialTotalPrecio = 0;
                            if (hCita.getServiciosSet() != null) {
                                for (SERVICIO s : hCita.getServiciosSet()) {
                                    historialTotalPrecio += s.getPrecio();
                                }
                            }
                    %>
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
                        } // Fin del for historialCitas
                    %>
                </div>
            </div>
            <% }%>

        </div> <%-- Fin de .container --%>

    </body>
</html>