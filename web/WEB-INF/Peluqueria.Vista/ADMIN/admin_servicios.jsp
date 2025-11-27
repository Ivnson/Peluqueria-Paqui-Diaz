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
