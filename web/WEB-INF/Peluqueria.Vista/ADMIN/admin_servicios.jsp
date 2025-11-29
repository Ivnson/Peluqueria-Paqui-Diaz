<%-- 
    Document   : admin_servicios
    Created on : 2 nov 2025, 13:33:15
    Author     : ivan
--%>

<%@page import="java.util.ArrayList"%>
<%@page import="Peluqueria.modelo.SERVICIO"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/vista_admin_servicios.css">
        <title>Peluqueria Paqui Diaz</title>

        <style>
            .btn-panel {
                padding: 10px 18px;
                background-color: #95a5a6; /* Color gris profesional */
                color: var(--blanco);
                text-decoration: none;
                border-radius: 8px;
                font-weight: 600;
                transition: all 0.2s ease-out;
                display: flex;
                align-items: center;
                gap: 5px;
            }

            .btn-panel:hover {
                background-color: #7f8c8d; /* Gris más oscuro al hover */
                transform: translateY(-2px);
                box-shadow: 0 4px 10px rgba(0,0,0,0.1);
                color: var(--blanco);
                text-decoration: none;
            }

            .header-buttons {
                display: flex;
                gap: 12px;
                align-items: center;
            }

            /* =========================== */
            /* MEDIA QUERIES - RESPONSIVE  */
            /* =========================== */

            @media (max-width: 1024px) {
                .container {
                    width: 95%;
                    margin: 20px auto;
                    padding: 20px;
                }

                header {
                    flex-direction: column;
                    align-items: flex-start;
                    gap: 15px;
                }

                .header-buttons {
                    width: 100%;
                    justify-content: flex-start;
                    flex-wrap: wrap;
                    gap: 10px;
                }
            }

            @media (max-width: 768px) {
                .container {
                    width: 98%;
                    margin: 15px auto;
                    padding: 15px;
                }

                header h1 {
                    font-size: 1.5rem;
                }

                /* Hacer la tabla responsive */
                .table-wrapper {
                    overflow-x: auto;
                    border: 1px solid var(--gris-bordes);
                    -webkit-overflow-scrolling: touch;
                }

                table {
                    min-width: 700px; /* Ancho mínimo para scroll horizontal */
                }

                th, td {
                    padding: 10px 12px;
                    font-size: 0.9rem;
                }

                thead th {
                    font-size: 0.8rem;
                    padding: 12px 10px;
                }

                /* Botones del header */
                .btn-crear, .btn-panel {
                    padding: 8px 14px;
                    font-size: 0.9rem;
                    min-height: 44px;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                }

                /* Botones de acción en tabla */
                .btn-editar, .btn-eliminar {
                    padding: 8px 10px;
                    font-size: 12px;
                    display: block;
                    margin-bottom: 5px;
                    text-align: center;
                    min-width: 60px;
                    min-height: 32px;
                }

                .acciones-form {
                    display: block;
                    margin-bottom: 5px;
                }

                /* Limitar longitud de descripción */
                td:nth-child(3) {
                    max-width: 200px;
                    overflow: hidden;
                    text-overflow: ellipsis;
                    white-space: nowrap;
                }
            }


            @media (max-width: 480px) {
                .container {
                    padding: 10px;
                    margin: 5px auto;
                }

                header h1 {
                    font-size: 1.2rem;
                }

                /* Tabla más compacta para móviles */
                table {
                    min-width: 650px;
                }

                th, td {
                    padding: 6px 8px;
                    font-size: 0.8rem;
                }

                thead th {
                    font-size: 0.75rem;
                    padding: 10px 8px;
                }

                
            }

            

            @media (max-width: 768px) {
                .btn-crear, .btn-panel {
                    min-height: 40px;
                }

                .btn-editar, .btn-eliminar {
                    min-height: 32px;
                }
            }

            /* Mejorar la legibilidad de la descripción en dispositivos pequeños */
            td:nth-child(3) {
                max-width: 250px;
                word-wrap: break-word;
            }

            @media (max-width: 768px) {
                td:nth-child(3) {
                    max-width: 150px;
                    overflow: hidden;
                    text-overflow: ellipsis;
                    white-space: nowrap;
                }
            }


        </style>

    </head>
    <body>

        <div class="container">


            <header>
                <h1>Gestión de Servicios</h1>
                <div class="header-buttons">
                    <a href="${pageContext.request.contextPath}/Admin/Panel" class="btn-panel">
                        Volver al Panel
                    </a>
                    <a href="${pageContext.request.contextPath}/Admin/Servicios/Nuevo" class="btn-crear">
                        Crear Nuevo Servicio
                    </a>
                </div>
            </header>






            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Nombre</th>
                            <th>Descripción</th>
                            <th>Duración (min)</th>
                            <th>Precio (€)</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>

                    <tbody>

                        <%
                            List<SERVICIO> servicios = (List<SERVICIO>) request.getAttribute("ListaServicios");

                            if (servicios != null && !servicios.isEmpty()) {
                                for (SERVICIO servicio : servicios) {
                        %>
                        <tr>
                            <td><%= servicio.getId()%></td>
                            <td><%= servicio.getNombreServicio()%></td>
                            <td><%= servicio.getDescripcion()%></td>
                            <td><%= servicio.getDuracion()%></td>
                            <td><%= servicio.getPrecio()%></td>
                            <td>
                                <a href="${pageContext.request.contextPath}/Admin/Servicios/Editar?id=<%= servicio.getId()%>" class="btn-editar">Editar</a>

                                <form action="${pageContext.request.contextPath}/Admin/Servicios/Eliminar" method="POST" class="acciones-form">
                                    <input type="hidden" name="id" value="<%= servicio.getId()%>" />
                                    <button type="submit" class="btn-eliminar">Eliminar</button>
                                </form>
                            </td>
                        </tr>
                        <%
                            }
                        } else {
                        %>
                        <tr class="no-servicios">
                            <td colspan="6">No hay servicios registrados.</td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div> 

        </div>

    </body>

</html>
