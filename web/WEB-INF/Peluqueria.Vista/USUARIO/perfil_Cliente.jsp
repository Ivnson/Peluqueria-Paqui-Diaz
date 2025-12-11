<%-- /WEB-INF/Peluqueria.Vista/CLIENTE/perfil_cliente.jsp --%>
<%-- IMPORTAMOS LA CLASE USUARIO PARA PODER MANIPULAR EL OBJETO QUE NOS ENVÍA EL SERVLET --%>
<%@page import="Peluqueria.modelo.USUARIO"%>
<%-- DEFINIMOS QUE ESTE ARCHIVO ES HTML Y LA CODIFICACIÓN DE CARACTERES --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="Peluqueria.modelo.USUARIO"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <%-- REUTILIZAMOS EL CSS DEL FORMULARIO DE ADMIN
             USAMOS ${pageContext...} PARA OBTENER LA RUTA RAÍZ DEL PROYECTO  --%>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/formulario_usuario.css"> 
        <title>Mi Perfil</title>
    </head>
    <body>

        <%
            // OBTENEMOS EL USUARIO QUE EL SERVLET NOS ENVIA 
            USUARIO usuario = (USUARIO) request.getAttribute("usuario");

            // RECUPERAMOS SI HAY ALGÚN MENSAJE DE ERROR ENVIADO DESDE EL SERVLET
            String error = (String) request.getAttribute("error");

            // CONSTRUIMOS LA URL A LA QUE SE ENVIARÁN LOS DATOS DEL FORMULARIO
            String urlAccion = request.getContextPath() + "/Perfil/Actualizar";

            // PREPARAMOS LAS VARIABLES PARA RELLENAR LOS CAMPOS DEL FORMULARIO
            // ES MUY IMPORTANTE VERIFICAR SI EL USUARIO ES NULL PARA EVITAR ERRORES 
            String nombre;
            if (usuario != null) {
                // SI HAY USUARIO, USAMOS SU NOMBRE REAL
                nombre = usuario.getNombreCompleto();
            } else {
                // SI NO, DEJAMOS EL CAMPO VACÍO
                nombre = "";
            }

            String email;
            if (usuario != null) {
                email = usuario.getEmail();
            } else {
                email = "";
            }

            String telefono;

            // AQUÍ TAMBIÉN VERIFICAMOS QUE EL TELÉFONO DENTRO DEL USUARIO NO SEA NULL
            if (usuario != null && usuario.getTelefono() != null) {

                // CONVERTIMOS EL LONG A STRING
                telefono = String.valueOf(usuario.getTelefono());
            } else {
                telefono = "";
            }
        %>

        <div class="form-container">
            <h1>Modificar mi Perfil</h1>

            <%-- BLOQUE JAVA PARA MOSTRAR ERROR SOLAMENTE SI EXISTE --%>
            <% if (error != null && !error.isEmpty()) {%>
            <div class="error-msg">
                <strong>Error:</strong> <%= error%>
            </div>
            <% }%>

            <%-- EL FORMULARIO ENVIARÁ LOS DATOS POR POST A LA URL QUE DEFINIMOS ARRIBA --%>
            <form action="<%= urlAccion%>" method="POST">

                <%-- NO NECESITAMOS UN INPUT HIDDEN PARA EL ID, PORQUE EL SERVLET YA SABE QUIÉN ERES POR LA SESIÓN --%>

                <div class="form-group">
                    <label for="NombreCompleto">Nombre Completo:</label>
                    <input type="text" id="NombreCompleto" name="NombreCompleto" value="<%= nombre%>" required>
                </div>

                <div class="form-group">
                    <label for="Email">Email:</label>
                    <input type="text" id="Email" name="Email" value="<%= email%>" required>
                </div>

                <%-- ELIMINAMOS EL CAMPO DE ROL PORQUE UN CLIENTE NO DEBE PODER CAMBIAR SU PROPIO ROL --%>

                <div class="form-group">
                    <label for="Telefono">Telefono :</label>
                    <input type="number" id="Telefono" name="Telefono" value="<%= telefono%>" required>
                </div>

                <div class="form-group">
                    <label for="password">Nueva Contraseña (dejar en blanco para no cambiar)</label>
                    <input type="password" id="password" name="password">
                </div>

                <div class="button-group">
                    <button type="submit" class="btn btn-submit">Guardar Cambios</button>
                    <a href="${pageContext.request.contextPath}/Perfil/Panel" class="btn btn-cancel">
                        Cancelar
                    </a>
                </div>
            </form>
        </div>

        <%-- ESTO ES JAVASCRIPT (SE EJECUTA EN EL NAVEGADOR DEL CLIENTE, NO EN EL SERVIDOR) --%>
        <script>
            function validarFormulario() {
                const email = document.getElementById('Email').value;
                const telefono = document.getElementById('Telefono').value;

                // VALIDACIÓN SIMPLE DE EMAIL
                if (!email.includes('@')) {
                    alert('El email debe contener el símbolo "@"');
                    return false;
                }

                // VALIDACIÓN DE TELÉFONO, LONGITUD Y QUE SEAN SOLO NÚMEROS
                const telefonoStr = telefono.toString().trim();
                if (telefonoStr.length !== 9 || !/^\d+$/.test(telefonoStr)) {
                    alert('El teléfono debe tener exactamente 9 números');
                    return false;
                }

                return true;
            }

            // ASIGNAMOS LA FUNCIÓN AL EVENTO ONSUBMIT DEL FORMULARIO
            // CUANDO HACES CLICK EN GUARDAR CAMBIOS SE EJECUTA ESTA FUNCION 
            document.querySelector('form').onsubmit = validarFormulario;
        </script>



    </body>



</html>