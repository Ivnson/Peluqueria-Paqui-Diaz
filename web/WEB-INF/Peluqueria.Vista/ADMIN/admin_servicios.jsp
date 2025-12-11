<%-- 
    Document   : admin_servicios
    Created on : 2 nov 2025, 13:33:15
    Author     : ivan
--%>

<%-- IMPORTACIONES DE LAS CLASES JAVA NECESARIAS (LISTAS Y EL MODELO DE SERVICIO) --%>
<%@page import="java.util.ArrayList"%>
<%@page import="Peluqueria.modelo.SERVICIO"%>
<%@page import="java.util.List"%>
<%-- CONFIGURACIÓN DE CODIFICACIÓN UTF-8 PARA CARACTERES ESPECIALES --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <%-- ENLACE AL CSS EXTERNO USANDO LA RUTA DINÁMICA DEL CONTEXTO --%>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/vista_admin_servicios.css">
        <title>Peluqueria Paqui Diaz</title>

        <style>
            /* --- ESTILOS CSS INTERNOS PARA LOS BOTONES Y LA TABLA --- */
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
                background-color: #7f8c8d; /* Efecto Hover */
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

            
            /* ESTOS BLOQUES ADAPTAN LA TABLA A PANTALLAS PEQUEÑAS (MÓVILES/TABLETS) */

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
                /* AJUSTES PARA TABLETS Y MÓVILES GRANDES */
                .container {
                    width: 98%;
                    margin: 15px auto;
                    padding: 15px;
                }
                header h1 {
                    font-size: 1.5rem;
                }
                /* HABILITA EL SCROLL HORIZONTAL SI LA TABLA ES MUY ANCHA */
                .table-wrapper {
                    overflow-x: auto;
                    border: 1px solid var(--gris-bordes);
                    -webkit-overflow-scrolling: touch;
                }
                table {
                    min-width: 700px; /* FUERZA EL ANCHO MÍNIMO */
                }
                /* LIMITAR LA COLUMNA DE DESCRIPCIÓN PARA QUE NO OCUPE DEMASIADO */
                td:nth-child(3) {
                    max-width: 200px;
                    overflow: hidden;
                    text-overflow: ellipsis;
                    white-space: nowrap;
                }
            }

            @media (max-width: 480px) {
                /* AJUSTES PARA MÓVILES PEQUEÑOS */
                .container {
                    padding: 10px;
                    margin: 5px auto;
                }
                header h1 {
                    font-size: 1.2rem;
                }
                table {
                    min-width: 650px;
                }
                th, td {
                    padding: 6px 8px;
                    font-size: 0.8rem;
                }
            }
        </style>

    </head>
    <body>

        <div class="container">

            <header>
                <h1>Gestión de Servicios</h1>
                <div class="header-buttons">
                    <%-- BOTÓN PARA REGRESAR AL PANEL DE ADMINISTRACIÓN --%>
                    <a href="${pageContext.request.contextPath}/Admin/Panel" class="btn-panel">
                        Volver al Panel
                    </a>
                    <%-- BOTÓN PARA IR AL FORMULARIO DE CREACIÓN (SERVLET /NUEVO) --%>
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
                            // --- INICIO DE LA LÓGICA JAVA EN EL JSP ---

                            // 1. RECUPERAMOS LA LISTA DE SERVICIOS ENVIADA POR EL SERVLET (ControladorServicios)
                            // HACEMOS UN CASTING (List<SERVICIO>) PARA PODER TRATARLA COMO UNA LISTA DE OBJETOS 'SERVICIO'
                            List<SERVICIO> servicios = (List<SERVICIO>) request.getAttribute("ListaServicios");

                            // 2. VERIFICAMOS SI LA LISTA EXISTE Y TIENE ELEMENTOS
                            if (servicios != null && !servicios.isEmpty()) {

                                // 3. BUCLE FOR-EACH: RECORREMOS CADA SERVICIO PARA GENERAR UNA FILA DE LA TABLA
                                for (SERVICIO servicio : servicios) {
                        %>

                        <%-- --- INICIO DE FILA DINÁMICA --- --%>
                        <tr>
                            <%-- MOSTRAMOS EL ID DEL SERVICIO --%>
                            <td><%= servicio.getId()%></td>

                            <%-- MOSTRAMOS EL NOMBRE (EJ: CORTE CABALLERO) --%>
                            <td><%= servicio.getNombreServicio()%></td>

                            <%-- MOSTRAMOS LA DESCRIPCIÓN --%>
                            <td><%= servicio.getDescripcion()%></td>

                            <%-- MOSTRAMOS LA DURACIÓN EN MINUTOS --%>
                            <td><%= servicio.getDuracion()%></td>

                            <%-- MOSTRAMOS EL PRECIO --%>
                            <td><%= servicio.getPrecio()%></td>

                            <%-- COLUMNA DE ACCIONES (BOTONES EDITAR Y ELIMINAR) --%>
                            <td>
                                <%-- ENLACE EDITAR: ENVÍA EL ID POR URL (GET) AL SERVLET --%>
                                <a href="${pageContext.request.contextPath}/Admin/Servicios/Editar?id=<%= servicio.getId()%>" class="btn-editar">Editar</a>

                                <%-- FORMULARIO ELIMINAR: ENVÍA EL ID POR CAMPO OCULTO (POST) AL SERVLET --%>
                                <form action="${pageContext.request.contextPath}/Admin/Servicios/Eliminar" method="POST" class="acciones-form">
                                    <input type="hidden" name="id" value="<%= servicio.getId()%>" />
                                    <button type="submit" class="btn-eliminar">Eliminar</button>
                                </form>
                            </td>
                        </tr>
                        <%-- --- FIN DE FILA DINÁMICA --- --%>

                        <%
                            } // FIN DEL BUCLE FOR
                        } else {
                        %>

                        <%-- --- BLOQUE ALTERNATIVO: SI NO HAY SERVICIOS --- --%>
                        <tr class="no-servicios">
                            <td colspan="6">No hay servicios registrados.</td>
                        </tr>

                        <%
                            } // FIN DEL IF/ELSE PRINCIPAL
%>

                    </tbody>
                </table>
            </div> 

        </div>

    </body>

</html>