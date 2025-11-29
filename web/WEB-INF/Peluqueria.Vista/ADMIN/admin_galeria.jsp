<%-- 1. IMPORTS NECESARIOS --%>
<%@ page import="java.util.List" %>
<%@ page import="Peluqueria.modelo.GALERIA" %>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Gestión de Galería - Administración</title>

        <%-- 2. CSS GLOBAL DEL ADMIN (Asegúrate de que esta ruta sea correcta para tu proyecto) --%>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin_usuarios.css">

        <%-- 3. ESTILOS ESPECÍFICOS PARA GALERÍA Y MODAL --%>
        <style>
            /* --- Estilos de la Tabla y Miniaturas --- */
            .thumb-img {
                width: 100px;
                height: 70px;
                object-fit: cover;
                border-radius: 6px;
                border: 1px solid #ddd;
                cursor: pointer;
                transition: transform 0.2s, opacity 0.2s;
            }
            .thumb-img:hover {
                transform: scale(1.05);
                opacity: 0.9;
            }

            .thumb-video {
                width: 100px;
                height: 70px;
                background-color: #222;
                display: flex;
                align-items: center;
                justify-content: center;
                border-radius: 6px;
                color: white;
                font-size: 0.8rem;
                cursor: pointer;
                border: 1px solid #444;
                transition: transform 0.2s;
            }
            .thumb-video:hover {
                transform: scale(1.05);
                background-color: #333;
            }

            /* --- Badges de Tipo (Etiquetas de color) --- */
            .tipo-badge {
                padding: 4px 8px;
                border-radius: 4px;
                font-size: 0.8rem;
                font-weight: bold;
                display: inline-block;
            }
            .tipo-imagen {
                background-color: #e3f2fd;
                color: #1565c0;
                border: 1px solid #bbdefb;
            }
            .tipo-video {
                background-color: #fce4ec;
                color: #c2185b;
                border: 1px solid #f8bbd0;
            }

            /* --- ESTILOS DEL MODAL (VENTANA EMERGENTE) --- */
            .modal {
                display: none; /* Oculto por defecto */
                position: fixed;
                z-index: 2000; /* Por encima de todo */
                left: 0;
                top: 0;
                width: 100%;
                height: 100%;
                background-color: rgba(0,0,0,0.9); /* Fondo negro casi opaco */
                justify-content: center;
                align-items: center;
                flex-direction: column;
                backdrop-filter: blur(5px); /* Efecto borroso de fondo */
            }

            .modal-content {
                max-width: 90%;
                max-height: 80vh;
                border-radius: 5px;
                box-shadow: 0 0 20px rgba(255,255,255,0.1);
                object-fit: contain;
            }

            /* Botón cerrar (X) */
            .close-btn {
                position: absolute;
                top: 20px;
                right: 35px;
                color: #f1f1f1;
                font-size: 40px;
                font-weight: bold;
                cursor: pointer;
                transition: 0.3s;
                z-index: 2001;
            }
            .close-btn:hover {
                color: #ff4444;
                transform: scale(1.1);
            }

            /* Ajuste para el botón de eliminar alineado */
            .acciones-form {
                margin: 0;
            }



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


            /* =========================== */
            /* MEDIA QUERIES - RESPONSIVE  */
            /* =========================== */

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

                header h1 {
                    font-size: 1.5rem;
                }
            }

            @media (max-width: 768px) {
                .container {
                    width: 98%;
                    margin: 15px auto;
                    padding: 15px;
                }

                /* Hacer la tabla responsive */
                .table-wrapper {
                    overflow-x: auto;
                    border: 1px solid var(--gris-bordes);
                }

                table {
                    min-width: 600px; /* Mantiene el ancho mínimo para scroll horizontal */
                }

                th, td {
                    padding: 10px 12px;
                    font-size: 0.9rem;
                }

                thead th {
                    font-size: 0.8rem;
                }

                .btn-crear {
                    width: 100%;
                    text-align: center;
                }

                /* Botones de acción más compactos */
                .btn-editar, .btn-eliminar {
                    padding: 5px 8px;
                    font-size: 12px;
                    display: block;
                    margin-bottom: 5px;
                    text-align: center;
                }
            }

            @media (max-width: 480px) {
                body {
                    padding: 10px 5px;
                }

                .container {
                    padding: 12px;
                    margin: 10px auto;
                    border-radius: 8px;
                }

                header h1 {
                    font-size: 1.3rem;
                }

                th, td {
                    padding: 8px 10px;
                    font-size: 0.85rem;
                }

                /* Mensaje de no hay datos */
                .no-servicios td,
                .no-usuarios td,
                .no-citas td {
                    padding: 30px 20px;
                    font-size: 0.9rem;
                }
            }
        </style>
    </head>
    <body>

        <div class="container">
            <header>
                <h1>Gestión de Galería</h1>
                <div class="header-buttons">


                    <a href="${pageContext.request.contextPath}/Admin/Panel" class="btn-panel">
                        Volver al Panel
                    </a>
                    <%-- Botón para ir al formulario de subir --%>
                    <a href="${pageContext.request.contextPath}/Admin/Galeria/nuevo" class="btn-crear">
                        Subir Nueva Foto/Video
                    </a>
                </div>

            </header>

            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Vista Previa (Click para ver)</th>
                            <th>Título / Descripción</th>
                            <th>Tipo</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>

                    <tbody>
                        <%
                            // 4. LÓGICA JAVA: RECUPERAR DATOS
                            List<GALERIA> galeria = (List<GALERIA>) request.getAttribute("listaGaleria");

                            if (galeria != null && !galeria.isEmpty()) {
                                for (GALERIA item : galeria) {
                                    // Construimos la ruta web completa: /Peluqueria/img/archivo.jpg
                                    String rutaWeb = request.getContextPath() + "/" + item.getRutaArchivo();
                        %>
                        <tr>
                            <td><%= item.getId()%></td>

                            <%-- COLUMNA VISTA PREVIA CON CLICK --%>
                            <td>
                                <% if ("IMAGEN".equals(item.getTipo())) {%>
                                <img src="<%= rutaWeb%>" 
                                     alt="Ver Imagen" 
                                     class="thumb-img"
                                     onclick="abrirModal('<%= rutaWeb%>', 'IMAGEN')"
                                     title="Clic para ampliar">
                                <% } else {%>
                                <div class="thumb-video"
                                     onclick="abrirModal('<%= rutaWeb%>', 'VIDEO')"
                                     title="Clic para reproducir">
                                    ▶ VIDEO MP4
                                </div>
                                <% }%>
                            </td>

                            <td><%= item.getTitulo()%></td>

                            <td>
                                <span class="tipo-badge <%= "IMAGEN".equals(item.getTipo()) ? "tipo-imagen" : "tipo-video"%>">
                                    <%= item.getTipo()%>
                                </span>
                            </td>

                            <td>
                                <form action="${pageContext.request.contextPath}/Admin/Galeria/eliminar" method="POST" class="acciones-form"
                                      onsubmit="return confirm('ATENCIÓN:\n¿Estás seguro de que quieres eliminar este archivo permanentemente?');">

                                    <input type="hidden" name="id" value="<%= item.getId()%>" />
                                    <%-- Enviamos la ruta para borrar el archivo físico --%>
                                    <input type="hidden" name="nombreArchivo" value="<%= item.getRutaArchivo()%>" />

                                    <button type="submit" class="btn-eliminar">Eliminar</button>
                                </form>
                            </td>
                        </tr>
                        <%
                            }
                        } else {
                        %>
                        <tr class="no-servicios">
                            <td colspan="5" style="text-align: center; padding: 20px;">
                                No hay fotos ni videos en la galería actualmente.
                            </td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>


        </div>

        <%-- 5. ESTRUCTURA DEL MODAL (OCULTO AL INICIO) --%>
        <div id="previewModal" class="modal" onclick="cerrarModal()">
            <span class="close-btn" onclick="cerrarModal()">&times;</span>

            <img class="modal-content" id="imgModal" style="display:none;">

            <video class="modal-content" id="videoModal" controls style="display:none;">
                <source id="videoSource" src="" type="video/mp4">
                Tu navegador no soporta la reproducción de videos.
            </video>
        </div>

        <%-- 6. JAVASCRIPT PARA EL MODAL --%>
        <script>
            function abrirModal(ruta, tipo) {
                var modal = document.getElementById("previewModal");
                var img = document.getElementById("imgModal");
                var video = document.getElementById("videoModal");
                var videoSrc = document.getElementById("videoSource");

                // Mostrar el fondo oscuro
                modal.style.display = "flex";

                if (tipo === 'IMAGEN') {
                    // Configurar modo Imagen
                    img.src = ruta;
                    img.style.display = "block";
                    video.style.display = "none";
                    video.pause(); // Asegurar silencio
                } else {
                    // Configurar modo Video
                    videoSrc.src = ruta;
                    video.load(); // Cargar nueva fuente
                    video.style.display = "block";
                    img.style.display = "none";
                    // video.play(); // Descomentar si quieres que arranque solo
                }
            }

            function cerrarModal() {
                var modal = document.getElementById("previewModal");
                var video = document.getElementById("videoModal");

                modal.style.display = "none";

                // IMPORTANTE: Pausar video al cerrar
                video.pause();
                video.currentTime = 0;
            }

            // Evitar que el modal se cierre si hacemos clic DENTRO del contenido
            document.getElementById("imgModal").onclick = function (e) {
                e.stopPropagation();
            }
            document.getElementById("videoModal").onclick = function (e) {
                e.stopPropagation();
            }

            // Cerrar con la tecla ESC
            document.addEventListener('keydown', function (event) {
                if (event.key === "Escape") {
                    cerrarModal();
                }
            });
        </script>

    </body>
</html>











