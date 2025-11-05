<%-- 
    Document   : admin_usuarios
    Created on : 5 nov 2025, 22:43:43
    Author     : ivan
--%>

<%@page import="java.util.List"%>
<%@page import="Peluqueria.modelo.USUARIO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin_usuarios.css">
        <title>Peluqueria Paqui Diaz</title>
    </head>
    <body>

        <div class="container">
            <header>
                <h1>Gestión de Usuarios</h1>
                <a href="${pageContext.request.contextPath}/Admin/Usuarios/Nuevo" class="btn-crear">
                    + Crear Nuevo Usuario
                </a>
            </header>


            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Nombre Completo</th>
                            <th>Email</th>
                            <th>Telefono</th>
                            <th>Fecha de Registro</th>
                            <th>Rol</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>

                    <tbody>

                        <%
                            List<USUARIO> usuarios = (List<USUARIO>) request.getAttribute("ListaUsuarios");

                            if (usuarios != null && !usuarios.isEmpty()) {
                                for (USUARIO usuario : usuarios) {

                        %>
                        <tr>
                            <td><%= usuario.getId()%></td>
                            <td><%= usuario.getNombreCompleto()%></td>
                            <td><%= usuario.getEmail()%></td>
                            <td><%= usuario.getTelefono()%></td>
                            <td><%= usuario.getFechaRegistro()%></td>
                            <td><%= usuario.getRol()%></td>
                            <td>
                                <a href="${pageContext.request.contextPath}/Admin/Usuarios/Editar?id=<%= usuario.getId()%>" class="btn-editar">Editar</a>

                                <form action="${pageContext.request.contextPath}/Admin/Usuarios/Eliminar" method="POST" class="acciones-form">
                                    <input type="hidden" name="id" value="<%= usuario.getId()%>" />
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
