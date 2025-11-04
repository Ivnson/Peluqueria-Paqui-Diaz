

<%@page import="java.util.List"%>
<%@page import="Peluqueria.modelo.USUARIO"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Peluqueria Paqui Diaz</title>
        <link rel="stylesheet" href="/web/css/main.css" type="text/css"/>
    </head>
    <body>
        <div class="header">
            <h1>🧑‍💼 LISTA DE USUARIOS</h1>
            <p>Gestión de clientes y empleados - Peluquería Paqui Díaz</p>
        </div>


        <%
            // Obtener la lista de usuarios del request
            List<USUARIO> usuarios = (List<USUARIO>) request.getAttribute("usuarios");

            if (usuarios != null && !usuarios.isEmpty()) {
        %>

        <div class="contador_usuarios">
            <strong>📊 Total de usuarios registrados: <%= usuarios.size()%></strong>
        </div>

        <table>

            <tr>
                <th>ID</th>
                <th>Nombre Completo</th>
                <th>Email</th>
                <th>Teléfono</th>
                <th>Fecha Registro</th>
                <th>Rol</th>
            </tr>


            <%
                for (int i = 0; i < usuarios.size(); i++) {
            %>
            <tr>
                <td><%=usuarios.get(i).getId()%></td>
                <td><%= usuarios.get(i).getNombreCompleto()%></td>
                <td><%= usuarios.get(i).getEmail()%></td>
                <td class="derecha"><%= usuarios.get(i).getTelefono()%></td>
                <td><%= usuarios.get(i).getFechaRegistro()%></td>
                <td><%= usuarios.get(i).getRol()%></td>
            </tr>
            <%
                }
            %>

        </table>

        <%
        } else {
        %>
        <div class="empty-message">
            <h3>📭 No hay usuarios registrados</h3>
            <p>No se encontraron usuarios en la base de datos.</p>
            <a href="new" class="enlace">👤 Registrar Primer Usuario</a>
        </div>
        <%
            }
        %>


        <div class="navigation">
            <a href="/Peluqueria/Usuario/new" class="enlace">➕ Registrar Nuevo Usuario</a>
            <a href="/Peluqueria" class="enlace enlace-secondary">🏠 Volver al Inicio</a>
        </div>


    </body>
</html>




