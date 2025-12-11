<%-- 
    Document   : formulario_usuario
    Created on : 5 nov 2025, 22:45:17
    Author     : ivan
--%>

<%-- IMPORTAMOS LA CLASE USUARIO PARA PODER MANEJAR EL OBJETO QUE VIENE DEL SERVLET --%>
<%@page import="Peluqueria.modelo.USUARIO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <%-- ENLAZAMOS LA HOJA DE ESTILOS CSS --%>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/formulario_servicio.css">
        <title>Peluqueria Paqui Diaz</title>
    </head>
    <body>

        <%
            // --- INICIO DEL BLOQUE DE LÓGICA JAVA (SCRIPTLET) ---

            // 1. RECUPERAR DATOS DEL SERVLET
            // EL SERVLET 'ControladorUsuarios' NOS ENVÍA UN OBJETO 'USUARIO' (SI ES EDITAR) O NULL (SI ES CREAR).
            USUARIO usuario = (USUARIO) request.getAttribute("usuario");
            // RECUPERAMOS POSIBLES MENSAJES DE ERROR (EJ: "EMAIL REPETIDO").
            String error = (String) request.getAttribute("error");

            // 2. DETERMINAR EL MODO (CREAR VS EDITAR)
            // POR DEFECTO ASUMIMOS QUE ES "CREAR".
            String modo = "crear";
            // LA URL A LA QUE SE ENVIARÁ EL FORMULARIO POR DEFECTO.
            String urlAccion = request.getContextPath() + "/Admin/Usuarios/Crear";
            
            // SI EL OBJETO USUARIO NO ES NULL, SIGNIFICA QUE ESTAMOS EN MODO "EDITAR".
            if (usuario != null) {
                modo = "editar";
                // CAMBIAMOS LA URL DE ACCIÓN PARA QUE APUNTE A 'ACTUALIZAR'.
                urlAccion = request.getContextPath() + "/Admin/Usuarios/Actualizar";
            }

            // --- 3. LÓGICA DE RE-POBLADO DE CAMPOS (STICKY FORM) ---
            // ESTO ES COMPLEJO PERO ÚTIL:
            // PRIORITY 1: request.getParameter(...) -> SI EL USUARIO ENVIÓ EL FORMULARIO Y FALLÓ, QUEREMOS MANTENER LO QUE ESCRIBIÓ.
            // PRIORITY 2: usuario.get...() -> SI ESTAMOS EDITANDO, QUEREMOS MOSTRAR LOS DATOS DE LA BASE DE DATOS.
            // PRIORITY 3: "" -> SI ES NUEVO Y NO HAY ERRORES, CAMPO VACÍO.

            String nombre = (request.getParameter("NombreCompleto") != null) 
                            ? request.getParameter("NombreCompleto") // SI HAY DATO PREVIO DEL FORMULARIO, ÚSALO
                            : (modo.equals("editar") ? usuario.getNombreCompleto() : ""); // SI NO, MIRA SI ESTAMOS EDITANDO

            String email = (request.getParameter("Email") != null) 
                           ? request.getParameter("Email") 
                           : (modo.equals("editar") ? usuario.getEmail() : "");

            String rol = (request.getParameter("Rol") != null) 
                         ? request.getParameter("Rol") 
                         : (modo.equals("editar") ? usuario.getRol() : "Cliente"); // ROL POR DEFECTO 'CLIENTE'

            // PARA EL TELÉFONO HAY QUE TENER CUIDADO CON LOS NULOS AL CONVERTIR DE LONG A STRING
            String telefono = (request.getParameter("Telefono") != null) 
                              ? request.getParameter("Telefono") 
                              : (modo.equals("editar") && usuario.getTelefono() != null ? String.valueOf(usuario.getTelefono()) : "");
                              
            // --- FIN DEL BLOQUE JAVA ---
        %>

        <div class="form-container">
            <%-- TÍTULO DINÁMICO SEGÚN EL MODO --%>
            <h1>
                <% if (modo.equals("editar")) { %>
                Editar Usuario
                <% } else { %>
                Crear Nuevo Usuario
                <% } %>
            </h1>

            <%-- BLOQUE PARA MOSTRAR ERRORES SI EXISTEN --%>
            <% if (error != null && !error.isEmpty()) {%>
            <div class="error-msg">
                <strong>Error:</strong> <%= error%>
            </div>
            <% }%>

            <%-- EL FORMULARIO SE ENVIARÁ A LA URL CALCULADA AL PRINCIPIO (CREAR O ACTUALIZAR) --%>
            <form action="<%= urlAccion%>" method="POST">

                <%-- CAMPO OCULTO (HIDDEN) PARA EL ID --%>
                <%-- SOLO SE GENERA SI ESTAMOS EN MODO EDITAR, PORQUE AL CREAR NO TENEMOS ID AÚN --%>
                <% if (modo.equals("editar")) {%>
                <input type="hidden" name="id" value="<%= usuario.getId()%>" />
                <% }%>

                <div class="form-group">
                    <label for="NombreCompleto">Nombre del usuario:</label>
                    <%-- VALUE="<%= NOMBRE %>": INSERTA EL VALOR CALCULADO EN JAVA DENTRO DE LA CAJA DE TEXTO --%>
                    <input type="text" id="NombreCompleto" name="NombreCompleto" value="<%= nombre%>" required>
                </div>

                <div class="form-group">
                    <label for="Email">Email:</label>
                    <input type="text" id="Email" name="Email" value="<%= email%>" required>
                </div>

                <%-- CAMPO DE ROL (DESPLEGABLE) --%>
                <div class="form-group">
                    <label for="Rol">Rol:</label>
                    <select id="Rol" name="Rol">
                        <%-- LÓGICA TERNARIA EN EL HTML: SI LA VARIABLE 'rol' COINCIDE, AÑADIMOS EL ATRIBUTO 'SELECTED' --%>
                        <option value="Cliente" <%= "Cliente".equals(rol) ? "selected" : ""%>>Cliente</option>
                        <option value="Administrador" <%= "Administrador".equals(rol) ? "selected" : ""%>>Administrador</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="Telefono">Telefono :</label>
                    <input type="number" id="Telefono" name="Telefono" value="<%= telefono%>" required>
                </div>

                <%-- CAMPO DE CONTRASEÑA --%>
                <div class="form-group">
                    <label for="password">
                        <%-- TEXTO DE LA ETIQUETA DINÁMICO --%>
                        <% if (modo.equals("editar")) { %>
                        Nueva Contraseña (dejar en blanco para no cambiar)
                        <% } else { %>
                        Contraseña:
                        <% } %>
                    </label>
                    
                    <%-- INPUT DE CONTRASEÑA --%>
                    <%-- LÓGICA IMPORTANTE: SOLO PONEMOS EL ATRIBUTO 'REQUIRED' SI ESTAMOS EN MODO 'CREAR' --%>
                    <%-- AL EDITAR, PUEDE ESTAR VACÍO (MANTIENE LA ANTIGUA) --%>
                    <input type="password" id="password" name="password" 
                           <% if (modo.equals("crear")) {
                                   out.print("required");
                               } %>>

                    <%-- BOTÓN PARA VER/OCULTAR CONTRASEÑA CON JAVASCRIPT --%>
                    <button type="button" id="togglePassword">Ver</button>
                </div>


                <div class="button-group">
                    <%-- TEXTO DEL BOTÓN DE ENVÍO DINÁMICO --%>
                    <% if (modo.equals("editar")) { %>
                    <button type="submit" class="btn btn-submit">Guardar Cambios</button>
                    <% } else { %>
                    <button type="submit" class="btn btn-submit">Crear Usuario</button>
                    <% }%>
                    
                    <%-- BOTÓN CANCELAR: SIEMPRE VUELVE AL LISTADO --%>
                    <a href="${pageContext.request.contextPath}/Admin/Usuarios/Listar" class="btn btn-cancel">
                        Cancelar
                    </a>
                </div>
            </form>
        </div>

        <%-- SCRIPT DE JAVASCRIPT PARA MOSTRAR/OCULTAR CONTRASEÑA --%>
        <script>
            // 1. SELECCIONAMOS EL BOTÓN Y EL CAMPO DE CONTRASEÑA DEL DOM
            const toggleButton = document.getElementById('togglePassword');
            const passwordInput = document.getElementById('password');

            // 2. AÑADIMOS UN "ESCUCHADOR" DE CLICS AL BOTÓN
            toggleButton.addEventListener('click', function () {

                // 3. COMPROBAMOS EL TIPO DE INPUT ACTUAL (SI ES PASSWORD O TEXT)
                const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';

                // 4. CAMBIAMOS EL TIPO AL CONTRARIO (SI ERA OCULTO SE VE, SI SE VEÍA SE OCULTA)
                passwordInput.setAttribute('type', type);

                // 5. CAMBIAMOS EL TEXTO DEL BOTÓN PARA DAR FEEDBACK AL USUARIO
                this.textContent = (type === 'password') ? 'Ver' : 'Ocultar';
            });
        </script>

    </body>
</html>