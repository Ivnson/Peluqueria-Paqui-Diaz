<%-- 1. IMPORTAR TODAS LAS CLASES NECESARIAS --%>
<%@ page import="Peluqueria.modelo.USUARIO" %>
<%@ page import="Peluqueria.modelo.CITA" %>
<%@ page import="Peluqueria.modelo.HISTORIAL_CITA" %>
<%@ page import="Peluqueria.modelo.SERVICIO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%-- 2. CONFIGURAR LA PÁGINA (para tildes y €) --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Mi Historial - Peluquería Paqui Diaz</title>

        <%-- 3. ¡REUTILIZAMOS EL CSS DEL DASHBOARD! --%>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/Panel_Cliente.css">

        <%-- 4. Estilos extra solo para esta página --%>
        <style>
            /* Estilos para la lista de servicios dentro de CADA caja del historial */
            .historial-servicios-lista {
                list-style: none;
                padding-left: 15px;
                margin-top: 10px;
                font-size: 0.95rem;
                color: #555;
            }
            .historial-servicios-lista li::before {
                content: '•';
                color: var(--verde-agua);
                font-weight: bold;
                display: inline-block;
                width: 1em;
                margin-left: -1em;
            }

            @media (max-width: 768px) {
                header {
                    flex-direction: column;
                    gap: 1rem;
                    padding: 1rem;
                    text-align: center;
                }

                .header-actions {
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

                .header-actions {
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
            // --- 5. LÓGICA DE JAVA (SCRIPTLET) ---

            // Obtenemos el historial que el Controlador nos envió
            List<HISTORIAL_CITA> historialCitas = (List<HISTORIAL_CITA>) request.getAttribute("historialCitas");

            // Formateadores para fechas y horas (igual que en el dashboard)
            DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
            DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HH:mm");
        %>

        <div class="container">

            <header class="dashboard-header">
                <h1>Mi Historial de Citas</h1>
                <div class="header-actions">
                    <%-- Botón para volver al panel principal --%>
                    <a href="${pageContext.request.contextPath}/Perfil/Panel" class="btn-logout">Volver al Panel</a>
                </div>
            </header>


            <div class="historial-grid">

                <%
                    // --- 7. LÓGICA DE VISTA (IF/ELSE) ---
                    if (historialCitas != null && !historialCitas.isEmpty()) {
                %>

                <%-- Esta es la tarjeta principal que envuelve todas las cajas --%>
                <div class="content-card" style="grid-column: 1 / -1;">
                    <h2>Tus Citas Pasadas</h2>

                    <%
                        // --- 8. BUCLE PARA CADA "CAJA" ---
                        for (HISTORIAL_CITA hCita : historialCitas) {

                            // Calculamos el precio total para esta caja de historial
                            double historialTotalPrecio = 0;
                            if (hCita.getServiciosSet() != null) {
                                for (SERVICIO s : hCita.getServiciosSet()) {
                                    historialTotalPrecio += s.getPrecio();
                                }
                            }
                    %>

                    <%-- 
                      Esta es la "caja" individual (el .historial-item)
                      (Definida en Panel_Cliente.css)
                    --%>
                    <div class="historial-item">
                        <div class="historial-icon">📅</div>
                        <div class="historial-details">
                            <div class="main-info">
                                Cita del <%= hCita.getFecha().format(dateFormatter)%> a las <%= hCita.getHoraInicio().format(timeFormatter)%>
                            </div>
                            <div class="secondary-info">
                                <span><%= hCita.getServiciosSet().size()%> servicios</span>
                                <span>Total: <%= String.format("%.2f", historialTotalPrecio)%> €</span>
                            </div>

                            <%-- Lista de los servicios de esa cita --%>
                            <ul class="historial-servicios-lista">
                                <%
                                    for (SERVICIO s : hCita.getServiciosSet()) {
                                %>
                                <li><%= s.getNombreServicio()%></li>
                                    <%
                                        }
                                    %>
                            </ul>
                        </div>
                    </div>

                    <%
                        } // Fin del for historialCitas
                    } else {
                    %>

                    <div class="content-card no-cita-card" style="grid-column: 1 / -1;">
                        <h2 class="h2Cita">Aún no tienes un historial</h2>
                        <p>Las citas que completes aparecerán aquí.</p>
                    </div>
                    <%
                    } // Fin del if/else
%>
                </div>
            </div> 

        </div> 

    </body>
</html>