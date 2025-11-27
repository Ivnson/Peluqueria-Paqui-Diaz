<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/formulario_usuario.css">
    <title>Subir a Galería</title>
</head>
<body>
    <div class="form-container">
        <h1>Subir Nueva Foto/Video</h1>
        
        <%-- Agrega mensajes de error --%>
        <% String error = (String) request.getAttribute("error"); %>
        <% if (error != null && !error.isEmpty()) { %>
            <div class="error-msg">
                <strong>Error:</strong> <%= error %>
            </div>
        <% } %>
        
        <%-- Corrige la URL del action --%>
        <form action="${pageContext.request.contextPath}/Admin/Galeria/crear" method="POST" enctype="multipart/form-data">
            
            <div class="form-group">
                <label>Título / Descripción:</label>
                <input type="text" name="titulo" required>
            </div>

            <div class="form-group">
                <label>Archivo (Imagen o MP4):</label>
                <input type="file" name="archivo" accept="image/*,video/mp4" required>
            </div>

            <div class="button-group">
                <button type="submit" class="btn btn-submit">Subir</button>
                <a href="${pageContext.request.contextPath}/Admin/Galeria/listar" class="btn btn-cancel">Cancelar</a>
            </div>
        </form>
    </div>
</body>
</html>