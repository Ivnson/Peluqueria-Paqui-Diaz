<%-- 
    Document   : admin_citas
    Created on : 6 nov 2025, 19:28:28
    Author     : ivan
--%>

<%-- 1. IMPORTACIONES: NECESARIAS PARA PODER USAR LAS CLASES DEL MODELO EN EL HTML --%>
<%@page import="Peluqueria.modelo.SERVICIO"%>
<%@page import="java.util.Set"%>
<%@page import="Peluqueria.modelo.CITA"%>
<%@page import="java.util.List"%>
<%-- CONFIGURACIÓN DE CODIFICACIÓN PARA CARACTERES ESPECIALES --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Gestión de Citas</title>

        <%-- 3. ENLAZAR EL CSS: REUTILIZAMOS EL DE USUARIOS PARA MANTENER LA CONSISTENCIA VISUAL --%>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin_usuarios.css">

        <%-- 4. ESTILOS EXTRA ESPECÍFICOS PARA ESTA VISTA --%>
        <style>
            /* ESTILOS PARA LA LISTA DE SERVICIOS DENTRO DE UNA CELDA DE LA TABLA */
            .servicios-list {
                margin: 0;
                padding-left: 20px;
            }
            .servicios-list li {
                margin-bottom: 5px;
            }

            /* COLORES PARA LOS BOTONES DE ACCIÓN */
            .btn-editar {
                background-color: #f1c40f; /* AMARILLO */
                color: #333;
            }
            .btn-eliminar {
                background-color: #e74c3c; /* ROJO */
                color: white;
                border: none;
                cursor: pointer;
                font-family: inherit;
            }
            .acciones-form {
                display: inline;
            }

            /* BOTONES DEL PANEL DE CABECERA */
            .btn-panel {
                padding: 10px 18px;
                background-color: #95a5a6; 
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
                background-color: #7f8c8d; 
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

            /* ADAPTACIÓN PARA TABLETS Y MÓVILES */

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

                /* HABILITAR SCROLL HORIZONTAL EN LA TABLA SI NO CABE */
                .table-wrapper {
                    overflow-x: auto;
                    border: 1px solid var(--gris-bordes);
                    -webkit-overflow-scrolling: touch;
                }

                table {
                    min-width: 700px; 
                }

                th, td {
                    padding: 10px 12px;
                    font-size: 0.9rem;
                }

                thead th {
                    font-size: 0.8rem;
                    padding: 12px 10px;
                }

                .btn-crear {
                    width: 100%;
                    text-align: center;
                }

                /* BOTONES MÁS PEQUEÑOS EN MÓVIL */
                .btn-editar, .btn-eliminar {
                    padding: 5px 8px;
                    font-size: 12px;
                    display: block;
                    margin-bottom: 5px;
                    text-align: center;
                    width: 60px;
                }

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
                    margin: 5px auto;
                }

                header h1 {
                    font-size: 1.2rem;
                    text-align: center;
                    width: 100%;
                }

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

                /* OCULTAR ID EN PANTALLAS MUY PEQUEÑAS PARA AHORRAR ESPACIO */
                @media (max-width: 360px) {
                    table {
                        min-width: 600px;
                    }
                    th:nth-child(1),
                        td:nth-child(1) {
                        display: none;
                    }
                }
            }

            /* LIMITAR ANCHO DE LA LISTA DE SERVICIOS */
            .servicios-list {
                max-width: 200px;
                word-wrap: break-word;
            }

            .header-buttons {
                display: flex;
                gap: 12px;
                align-items: center;
            }

            .btn-crear, .btn-panel, .btn-editar, .btn-eliminar {
                min-height: 44px; 
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
                    <%-- BOTÓN PARA VOLVER AL DASHBOARD PRINCIPAL --%>
                    <a href="${pageContext.request.contextPath}/Admin/Panel" class="btn-panel">
                        Volver al Panel
                    </a>
                    <%-- BOTÓN PARA IR AL FORMULARIO DE NUEVA CITA --%>
                    <a href="${pageContext.request.contextPath}/Admin/Citas/Nuevo" class="btn-crear">
                        Crear Nueva Cita
                    </a>
                </div>
            </header>


            <%-- 5. CONTENEDOR DE LA TABLA CON SCROLL RESPONSIVE --%>
            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>ID Cita</th>
                            <th>Cliente</th>
                            <th>Fecha</th>
                            <th>Hora</th>
                            <th>Servicios</th> <%-- ESTA COLUMNA CONTIENE UNA LISTA ANIDADA --%>
                            <th>Acciones</th>
                        </tr>
                    </thead>

                    <tbody>
                        <%-- 
                          6. LÓGICA JAVA: RECUPERAR DATOS DEL SERVLET
                          EL 'ControladorCitas' NOS ENVÍA UNA LISTA DE OBJETOS 'CITA'.
                        --%>
                        <%
                            List<CITA> citas = (List<CITA>) request.getAttribute("listaCitas");

                            // SI HAY CITAS, LAS MOSTRAMOS
                            if (citas != null && !citas.isEmpty()) {
                                // BUCLE PRINCIPAL: RECORRE CADA CITA
                                for (CITA cita : citas) {
                        %>
                        <%-- INICIO DE FILA DE CITA --%>
                        <tr>
                            <td><%= cita.getId()%></td>

                            <%-- 
                              NAVEGACIÓN DE OBJETOS JPA:
                              ACCEDEMOS AL OBJETO 'USUARIO' DENTRO DE LA 'CITA' Y LUEGO A SU NOMBRE.
                            --%>
                            <td><%= cita.getUsuario().getNombreCompleto()%></td>

                            <td><%= cita.getFecha()%></td>
                            <td><%= cita.getHoraInicio()%></td>

                            <%-- 
                              7. COLUMNA DE SERVICIOS (LÓGICA ANIDADA)
                              DENTRO DE LA CELDA, CREAMOS UNA LISTA HTML (<ul>)
                            --%>
                            <td>
                                <ul class="servicios-list">
                                    <%
                                        // OBTENEMOS EL CONJUNTO DE SERVICIOS ASOCIADOS A ESTA CITA ESPECÍFICA
                                        Set<SERVICIO> servicios = cita.getServiciosSet();
                                        
                                        // SI TIENE SERVICIOS, LOS RECORREMOS EN UN SUB-BUCLE
                                        if (servicios != null && !servicios.isEmpty()) {
                                            for (SERVICIO s : servicios) {
                                    %>
                                    <%-- IMPRIMIMOS CADA SERVICIO COMO UN ÍTEM DE LISTA --%>
                                    <li><%= s.getNombreServicio()%></li>
                                    <%
                                            } // CIERRE DEL FOR DE SERVICIOS
                                        } else {
                                    %>
                                    <%-- SI LA LISTA ESTÁ VACÍA (RARO PERO POSIBLE) --%>
                                    <li>(Sin servicios)</li>
                                    <%
                                        } // CIERRE DEL ELSE
                                    %>
                                </ul>
                            </td>

                            <%-- 8. COLUMNA DE ACCIONES --%>
                            <td>
                                <%-- ENLACE EDITAR: ENVÍA EL ID DE LA CITA POR URL (GET) --%>
                                <a href="${pageContext.request.contextPath}/Admin/Citas/Editar?id=<%= cita.getId()%>" class="btn-editar">Editar</a>

                                <%-- FORMULARIO ELIMINAR: ENVÍA EL ID POR POST (MÁS SEGURO) --%>
                                <form action="${pageContext.request.contextPath}/Admin/Citas/Eliminar" method="POST" class="acciones-form">
                                    <input type="hidden" name="id" value="<%= cita.getId()%>" />
                                    <button type="submit" class="btn-eliminar">Eliminar</button>
                                </form>
                            </td>
                        </tr>
                        <%-- FIN DE FILA DE CITA --%>
                        <%
                                } // CIERRE DEL FOR DE CITAS
                            } else {
                        %>
                        <%-- SI NO HAY CITAS REGISTRADAS --%>
                        <tr class="no-servicios">
                            <td colspan="6">No hay citas registradas.</td>
                        </tr>
                        <%
                            } // CIERRE DEL ELSE PRINCIPAL
                        %>
                    </tbody>
                </table>
            </div> <%-- Fin de .table-wrapper --%>

        </div> <%-- Fin de .container --%>

    </body>
</html>