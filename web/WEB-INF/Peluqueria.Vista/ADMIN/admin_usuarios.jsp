<%-- 
    Document   : admin_usuarios
    Created on : 5 nov 2025, 22:43:43
    Author     : ivan
--%>

<%-- IMPORTACIONES NECESARIAS PARA MANEJAR LISTAS Y EL MODELO DE USUARIO --%>
<%@page import="java.util.List"%>
<%@page import="Peluqueria.modelo.USUARIO"%>
<%-- CONFIGURACIÓN DE CODIFICACIÓN PARA CARACTERES ESPECIALES (TILDES, ETC.) --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <%-- ENLACE AL CSS EXTERNO. USAMOS '${pageContext...}' PARA OBTENER LA RUTA RAÍZ DEL PROYECTO DINÁMICAMENTE --%>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin_usuarios.css">
        <title>Peluqueria Paqui Diaz</title>

        <style>
            /* ESTILOS CSS INTERNOS PARA BOTONES Y RESPONSIVIDAD */
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


            /* REGLAS PARA TABLETS Y PANTALLAS MEDIANAS */
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

            /* REGLAS PARA MÓVILES */
            @media (max-width: 768px) {
                .container {
                    width: 98%;
                    margin: 15px auto;
                    padding: 15px;
                }

                header h1 {
                    font-size: 1.5rem;
                }

                /* HACER LA TABLA RESPONSIVE CON SCROLL HORIZONTAL */
                .table-wrapper {
                    overflow-x: auto;
                    border: 1px solid var(--gris-bordes);

                }

                table {
                    min-width: 800px; /* Ancho mínimo para forzar el scroll */
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
                    min-height: 44px; /* Tamaño táctil */
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
            }


            /* REGLAS PARA MÓVILES MUY PEQUEÑOS */
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
                    min-width: 750px;
                }

                th, td {
                    padding: 6px 8px;
                    font-size: 0.8rem;
                }

                thead th {
                    font-size: 0.75rem;
                    padding: 10px 8px;
                }

                /* OCULTAR COLUMNAS MENOS IMPORTANTES EN MÓVILES PEQUEÑOS */
                @media (max-width: 400px) {
                    table {
                        min-width: 700px;
                    }

                    /* Ocultar ID y Fecha de Registro */
                    th:nth-child(1), td:nth-child(1), /* ID */
                        th:nth-child(5), td:nth-child(5) { /* Fecha de Registro */
                        display: none;
                    }
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
        </style>


    </head>
    <body>

        <div class="container">
            <header>
                <h1>Gestión de Usuarios</h1>
                <div class="header-buttons">
                    <%-- BOTÓN PARA VOLVER AL PANEL GENERAL --%>
                    <a href="${pageContext.request.contextPath}/Admin/Panel" class="btn-panel">
                        Volver al Panel
                    </a>
                    <%-- BOTÓN PARA IR AL FORMULARIO DE CREAR USUARIO --%>
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
                            // --- INICIO LÓGICA JAVA ---

                            // 1. RECUPERAMOS LA LISTA DE USUARIOS QUE EL SERVLET (ControladorUsuarios) NOS ENVIÓ EN EL REQUEST.
                            // HACEMOS UN CASTING (List<USUARIO>) PORQUE EL REQUEST DEVUELVE UN OBJECT GENÉRICO.
                            List<USUARIO> usuarios = (List<USUARIO>) request.getAttribute("ListaUsuarios");

                            // 2. COMPROBAMOS SI LA LISTA EXISTE Y NO ESTÁ VACÍA
                            if (usuarios != null && !usuarios.isEmpty()) {

                                // 3. BUCLE FOR-EACH: RECORREMOS CADA USUARIO DE LA LISTA
                                for (USUARIO usuario : usuarios) {

                        %>
                        <%-- --- INICIO FILA DE LA TABLA (SE REPITE POR CADA USUARIO) --- --%>
                        <tr>
                            <%-- IMPRIMIMOS LOS DATOS DEL USUARIO USANDO EXPRESIONES <%= ... %> --%>
                            <td><%= usuario.getId()%></td>
                            <td><%= usuario.getNombreCompleto()%></td>
                            <td><%= usuario.getEmail()%></td>
                            <td><%= usuario.getTelefono()%></td>
                            <td><%= usuario.getFechaRegistro()%></td>
                            <td><%= usuario.getRol()%></td>

                            <%-- COLUMNA DE ACCIONES (EDITAR / BORRAR) --%>
                            <td>
                                <%-- ENLACE EDITAR: PASAMOS EL ID POR URL (GET) PARA QUE EL SERVLET SEPA A QUIÉN EDITAR --%>
                                <a href="${pageContext.request.contextPath}/Admin/Usuarios/Editar?id=<%= usuario.getId()%>" class="btn-editar">Editar</a>

                                <%-- FORMULARIO ELIMINAR: USAMOS UN FORMULARIO (POST) PARA UNA ACCIÓN DESTRUCTIVA --%>
                                <form action="${pageContext.request.contextPath}/Admin/Usuarios/Eliminar" method="POST" class="acciones-form">
                                    <%-- INPUT OCULTO CON EL ID DEL USUARIO A ELIMINAR --%>
                                    <input type="hidden" name="id" value="<%= usuario.getId()%>" />
                                    <button type="submit" class="btn-eliminar">Eliminar</button>
                                </form>
                            </td>
                        </tr>
                        <%-- --- FIN FILA DE LA TABLA --- --%>
                        <%
                            } // FIN DEL BUCLE FOR
                        } else {
                        %>
                        <%-- --- BLOQUE SI NO HAY DATOS --- --%>
                        <tr class="no-servicios">
                            <td colspan="6">No hay servicios registrados.</td>
                        </tr>
                        <%
                            } // FIN DEL IF/ELSE
%>
                    </tbody>
                </table>
            </div> 

        </div>

    </body>

</html>