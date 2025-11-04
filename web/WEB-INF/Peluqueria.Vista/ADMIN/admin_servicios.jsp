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
    </head>





    <body>

        <div class="container">
            <header>
                <h1>Gestión de Servicios</h1>
                <a href="${pageContext.request.contextPath}/Admin/Servicios/Nuevo" class="btn-crear">
                    + Crear Nuevo Servicio
                </a>
            </header>

            <%-- 
              4. EL CONTENEDOR DE LA TABLA
              Este 'div' es el que aplica los bordes redondeados.
            --%>
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
                        <%-- 
                          5. SCRIPTLET DE JAVA (El Bucle)
                          (Usando el nombre de atributo "ListaServicios" de tu controlador)
                        --%>
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
                            } // Cerramos el 'for'
                        } else {
                        %>
                        <tr class="no-servicios">
                            <td colspan="6">No hay servicios registrados.</td>
                        </tr>
                        <%
                        } // Cerramos el 'else'
%>
                    </tbody>
                </table>
            </div> <%-- Fin de .table-wrapper --%>

        </div> <%-- Fin de .container --%>

    </body>


















</body>

</html>
