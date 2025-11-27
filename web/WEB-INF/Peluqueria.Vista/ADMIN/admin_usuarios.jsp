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
                <h1>Gestión de Usuarios</h1>
                <div class="header-buttons">
                    <a href="${pageContext.request.contextPath}/Admin/Panel" class="btn-panel">
                        Volver al Panel
                    </a>
                    <a href="${pageContext.request.contextPath}/Admin/Usuarios/Nuevo" class="btn-crear">
                        Crear Nuevo Usuario
                    </a>
                </div>
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
