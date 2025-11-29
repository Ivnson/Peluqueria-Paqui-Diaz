<%-- 
    Document   : admin_citas
    Created on : 6 nov 2025, 19:28:28
    Author     : ivan
--%>

<%@page import="Peluqueria.modelo.SERVICIO"%>
<%@page import="java.util.Set"%>
<%@page import="Peluqueria.modelo.CITA"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Gestión de Citas</title>

        <%-- 3. ENLAZAR EL CSS DE LA TABLA (Reutilizamos el de servicios/usuarios) --%>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin_usuarios.css">

        <%-- 4. Estilos extra para los botones y la lista de servicios --%>
        <style>
            /* Estilos para la lista de servicios dentro de la celda */
            .servicios-list {
                margin: 0;
                padding-left: 20px;
            }
            .servicios-list li {
                margin-bottom: 5px;
            }

            /* Estilos para los botones de acción */
            .btn-editar {
                background-color: #f1c40f;
                color: #333;
            }
            .btn-eliminar {
                background-color: #e74c3c;
                color: white;
                border: none;
                cursor: pointer;
                font-family: inherit;
            }
            .acciones-form {
                display: inline;
            }

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
                    -webkit-overflow-scrolling: touch; /* Mejor scroll en iOS */
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
                }

                /* Botones de acción en tabla */
                .btn-editar, .btn-eliminar {
                    padding: 5px 8px;
                    font-size: 12px;
                    display: block;
                    margin-bottom: 5px;
                    text-align: center;
                    width: 60px;
                }

                /* Lista de servicios más compacta */
                .servicios-list {
                    padding-left: 15px;
                    font-size: 0.85rem;
                }

                .servicios-list li {
                    margin-bottom: 3px;
                }
            }

           
            

            @media (max-width: 480px) {
                .container {
                    padding: 10px;
                }

                header h1 {
                    font-size: 1.2rem;
                    text-align: center;
                    width: 100%;
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

                /* Ocultar columnas menos importantes en móviles muy pequeños */
                @media (max-width: 360px) {
                    table {
                        min-width: 600px;
                    }

                    /* Opcional: ocultar ID de cita en móviles muy pequeños */
                    th:nth-child(1),
                        td:nth-child(1) {
                        display: none;
                    }
                }
            }

            /* Mejoras específicas para la tabla de citas */
            .servicios-list {
                max-width: 200px;
                word-wrap: break-word;
            }

            /* Para el contenedor de botones en el header */
            .header-buttons {
                display: flex;
                gap: 12px;
                align-items: center;
            }

            /* Asegurar que los botones sean táctiles en móviles */
            .btn-crear, .btn-panel, .btn-editar, .btn-eliminar {
                min-height: 44px; /* Tamaño mínimo táctil recomendado */
                display: flex;
                align-items: center;
                justify-content: center;
            }

            @media (max-width: 768px) {
                .btn-crear, .btn-panel {
                    min-height: 40px;
                }

                .btn-editar, .btn-eliminar {
                    min-height: 32px;
                }
            }
        </style>
    </head>
    <body>

        <div class="container">
            <header>
                <h1>Gestión de Citas</h1>
                <div class="header-buttons">
                    <a href="${pageContext.request.contextPath}/Admin/Panel" class="btn-panel">
                        Volver al Panel
                    </a>
                    <a href="${pageContext.request.contextPath}/Admin/Citas/Nuevo" class="btn-crear">
                        Crear Nueva Cita
                    </a>
                </div>
            </header>


            <%-- 
              5. EL CONTENEDOR DE LA TABLA
              (Con el 'table-wrapper' para los bordes redondeados)
            --%>
            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>ID Cita</th>
                            <th>Cliente</th>
                            <th>Fecha</th>
                            <th>Hora</th>
                            <th>Servicios</th> <%-- ¡La columna clave! --%>
                            <th>Acciones</th>
                        </tr>
                    </thead>

                    <tbody>
                        <%-- 
                          6. SCRIPTLET DE JAVA (El Bucle)
                          (Obtenemos "listaCitas" de tu ControladorCitas.java)
                        --%>
                        <%
                            List<CITA> citas = (List<CITA>) request.getAttribute("listaCitas");

                            if (citas != null && !citas.isEmpty()) {
                                for (CITA cita : citas) {
                        %>
                        <tr>
                            <td><%= cita.getId()%></td>

                            <%-- 
                              Gracias a JPA, podemos navegar por los objetos:
                              cita -> getUsuario() -> getNombreCompleto()
                            --%>
                            <td><%= cita.getUsuario().getNombreCompleto()%></td>

                            <td><%= cita.getFecha()%></td>
                            <td><%= cita.getHoraInicio()%></td>

                            <%-- 
                              7. BUCLE ANIDADO PARA LOS SERVICIOS
                              Aquí recorremos el Set<SERVICIO> de cada cita.
                            --%>
                            <td>
                                <ul class="servicios-list">
                                    <%
                                        Set<SERVICIO> servicios = cita.getServiciosSet();
                                        if (servicios != null && !servicios.isEmpty()) {
                                            for (SERVICIO s : servicios) {
                                    %>
                                    <li><%= s.getNombreServicio()%></li>
                                        <%
                                            } // Cierre del 'for' de servicios
                                        } else {
                                        %>
                                    <li>(Sin servicios)</li>
                                        <%
                                            } // Cierre del 'else' de servicios
                                        %>
                                </ul>
                            </td>

                            <%-- 8. ACCIONES (Editar/Eliminar) --%>
                            <td>
                                <a href="${pageContext.request.contextPath}/Admin/Citas/Editar?id=<%= cita.getId()%>" class="btn-editar">Editar</a>

                                <form action="${pageContext.request.contextPath}/Admin/Citas/Eliminar" method="POST" class="acciones-form">
                                    <input type="hidden" name="id" value="<%= cita.getId()%>" />
                                    <button type="submit" class="btn-eliminar">Eliminar</button>
                                </form>
                            </td>
                        </tr>
                        <%
                            } // Cierre del 'for' de citas
                        } else {
                        %>
                        <tr class="no-servicios">
                            <%-- 'colspan="6"' para que ocupe las 6 columnas --%>
                            <td colspan="6">No hay citas registradas.</td>
                        </tr>
                        <%
                            } // Cierre del 'else' de citas
                        %>
                    </tbody>
                </table>
            </div> <%-- Fin de .table-wrapper --%>

        </div> <%-- Fin de .container --%>

    </body>
</html>