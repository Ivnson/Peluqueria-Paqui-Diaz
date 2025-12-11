<%-- DEFINIMOS LA CODIFICACIÓN PARA EVITAR PROBLEMAS CON TILDES O Ñ --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <%-- REUTILIZAMOS EL CSS DE OTRO FORMULARIO PARA MANTENER LA COHERENCIA VISUAL --%>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/formulario_usuario.css">
        <title>Subir a Galería</title>
    </head>
    <body>
        <div class="form-container">
            <h1>Subir Nueva Foto/Video</h1>

            <%-- --- BLOQUE JAVA: GESTIÓN DE ERRORES --- --%>
            <%
                // RECUPERAMOS EL MENSAJE DE ERROR QUE EL SERVLET (ControladorGaleria) PUDO HABER ENVIADO
                // EJ: "DEBE SELECCIONAR UN ARCHIVO"
                String error = (String) request.getAttribute("error");
            %>

            <%-- SI HAY ERROR, MOSTRAMOS LA CAJITA ROJA --%>
            <% if (error != null && !error.isEmpty()) {%>
            <div class="error-msg">
                <%-- IMPRIMIMOS EL ERROR EN PANTALLA --%>
                <strong>Error:</strong> <%= error%>
            </div>
            <% }%>

            <%-- --- FORMULARIO DE SUBIDA --- --%>
            <%-- 1. ACTION: APUNTA AL MÉTODO POST DEL SERVLET DE GALERÍA --%>
            <%-- 2. ENCTYPE="MULTIPART/FORM-DATA": OBLIGATORIO PARA PODER ENVIAR ARCHIVOS BINARIOS (FOTOS/VÍDEOS) --%>
            <%-- SI OLVIDAS EL ENCTYPE, EL SERVIDOR SOLO RECIBIRÁ EL NOMBRE DEL ARCHIVO, PERO NO LA FOTO REAL --%>
            <form action="${pageContext.request.contextPath}/Admin/Galeria/crear" method="POST" enctype="multipart/form-data">

                <div class="form-group">
                    <label>Título / Descripción:</label>
                    <%-- INPUT DE TEXTO NORMAL PARA EL NOMBRE DE LA FOTO --%>
                    <input type="text" name="titulo" required>
                </div>

                <div class="form-group">
                    <label>Archivo (Imagen o MP4):</label>
                    <%-- INPUT TIPO FILE: ABRE EL EXPLORADOR DE ARCHIVOS DEL ORDENADOR --%>
                    <%-- ACCEPT: FILTRA PARA QUE SOLO SE PUEDAN ELEGIR IMÁGENES O VÍDEOS MP4 --%>
                    <input type="file" name="archivo" accept="image/*,video/mp4" required>
                </div>

                <div class="button-group">
                    <button type="submit" class="btn btn-submit">Subir</button>
                    <%-- BOTÓN CANCELAR: VUELVE AL LISTADO DE LA GALERÍA --%>
                    <a href="${pageContext.request.contextPath}/Admin/Galeria/listar" class="btn btn-cancel">Cancelar</a>
                </div>
            </form>
        </div>
    </body>
</html>