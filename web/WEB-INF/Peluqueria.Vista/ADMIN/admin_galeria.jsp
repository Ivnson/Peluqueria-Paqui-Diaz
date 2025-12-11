<%-- 1. IMPORTS NECESARIOS: TRAEMOS LA LISTA Y EL MODELO DE GALERÍA --%>
<%@ page import="java.util.List" %>
<%@ page import="Peluqueria.modelo.GALERIA" %>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Gestión de Galería - Administración</title>

        <%-- 2. CSS GLOBAL DEL ADMIN: REUTILIZAMOS EL ESTILO DE LA TABLA DE USUARIOS --%>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin_usuarios.css">

        <%-- 3. ESTILOS ESPECÍFICOS PARA GALERÍA Y MODAL --%>
        <style>
            /* --- ESTILOS DE LAS MINIATURAS (THUMBNAILS) --- */
            .thumb-img {
                width: 100px;
                height: 70px;
                object-fit: cover; /* RECORTA LA IMAGEN PARA QUE LLENE EL RECTÁNGULO SIN DEFORMARSE */
                border-radius: 6px;
                border: 1px solid #ddd;
                cursor: pointer;   /* CAMBIA EL CURSOR A UNA MANO AL PASAR POR ENCIMA */
                transition: transform 0.2s, opacity 0.2s;
            }
            .thumb-img:hover {
                transform: scale(1.05); /* EFECTO ZOOM AL PASAR EL RATÓN */
                opacity: 0.9;
            }

            /* --- ESTILO PARA MINIATURAS DE VÍDEO (CUADRADO NEGRO) --- */
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

            /* --- BADGES (ETIQUETAS DE COLOR) PARA DIFERENCIAR TIPO --- */
            .tipo-badge {
                padding: 4px 8px;
                border-radius: 4px;
                font-size: 0.8rem;
                font-weight: bold;
                display: inline-block;
            }
            .tipo-imagen {
                background-color: #e3f2fd; /* AZUL CLARO PARA FOTOS */
                color: #1565c0;
                border: 1px solid #bbdefb;
            }
            .tipo-video {
                background-color: #fce4ec; /* ROSA CLARO PARA VÍDEOS */
                color: #c2185b;
                border: 1px solid #f8bbd0;
            }

            /* --- ESTILOS DEL MODAL (VENTANA EMERGENTE O LIGHTBOX) --- */
            .modal {
                display: none; /* OCULTO POR DEFECTO HASTA QUE SE HAGA CLICK */
                position: fixed;
                z-index: 2000; /* Z-INDEX ALTO PARA QUE FLOTE SOBRE TODO LO DEMÁS */
                left: 0;
                top: 0;
                width: 100%;
                height: 100%;
                background-color: rgba(0,0,0,0.9); /* FONDO NEGRO SEMITRANSPARENTE */
                justify-content: center; /* CENTRADO HORIZONTAL FLEXBOX */
                align-items: center;     /* CENTRADO VERTICAL FLEXBOX */
                flex-direction: column;
                backdrop-filter: blur(5px); /* EFECTO BORROSO MODERNO EN EL FONDO */
            }

            .modal-content {
                max-width: 90%;
                max-height: 80vh; /* OCUPA MÁXIMO EL 80% DE LA ALTURA DE LA PANTALLA */
                border-radius: 5px;
                box-shadow: 0 0 20px rgba(255,255,255,0.1);
                object-fit: contain; /* ASEGURA QUE LA FOTO ENTERA SE VEA DENTRO DEL MODAL */
            }

            /* BOTÓN CERRAR (X) */
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

            /* PEQUEÑO AJUSTE PARA EL BOTÓN DE ELIMINAR */
            .acciones-form {
                margin: 0;
            }

            /* REPETICIÓN DE ESTILOS DE BOTONES (POR SI EL CSS EXTERNO FALLA) */
            .btn-panel {
                padding: 10px 18px;
                background-color: #95a5a6; 
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
                background-color: #7f8c8d; 
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

            /* --- RESPONSIVE (MEDIA QUERIES) --- */
            @media (max-width: 1024px) {
                .container { width: 95%; margin: 20px auto; padding: 20px; }
                header { flex-direction: column; align-items: flex-start; gap: 15px; }
                .header-buttons { width: 100%; justify-content: flex-start; flex-wrap: wrap; gap: 10px; }
            }

            @media (max-width: 768px) {
                .container { width: 98%; margin: 15px auto; padding: 15px; }
                header h1 { font-size: 1.5rem; }
                .table-wrapper { overflow-x: auto; border: 1px solid var(--gris-bordes); }
                table { min-width: 600px; }
                th, td { padding: 10px 12px; font-size: 0.9rem; }
                thead th { font-size: 0.8rem; }
                .btn-crear { width: 100%; text-align: center; }
                .btn-editar, .btn-eliminar { padding: 5px 8px; font-size: 12px; display: block; margin-bottom: 5px; text-align: center; }
            }

            @media (max-width: 480px) {
                body { padding: 10px 5px; }
                .container { padding: 12px; margin: 10px auto; border-radius: 8px; }
                header h1 { font-size: 1.3rem; }
                table { min-width: 650px; }
                th, td { padding: 6px 8px; font-size: 0.85rem; }
                .no-servicios td { padding: 30px 20px; font-size: 0.9rem; }
            }

            @media (max-width: 768px) {
                .btn-crear, .btn-panel { min-height: 40px; }
                .btn-editar, .btn-eliminar { min-height: 32px; }
            }

            /* CORRECCIÓN DE ANCHO DE COLUMNA PARA LA DESCRIPCIÓN */
            td:nth-child(3) {
                max-width: 250px;
                word-wrap: break-word;
            }
            @media (max-width: 768px) {
                td:nth-child(3) {
                    max-width: 150px;
                    overflow: hidden;
                    text-overflow: ellipsis;
                    white-space: nowrap;
                }
            }
        </style>
    </head>
    <body>

        <div class="container">
            <header>
                <h1>Gestión de Galería</h1>
                <div class="header-buttons">

                    <%-- BOTÓN VOLVER AL PANEL --%>
                    <a href="${pageContext.request.contextPath}/Admin/Panel" class="btn-panel">
                        Volver al Panel
                    </a>
                    
                    <%-- BOTÓN PARA IR AL FORMULARIO DE SUBIDA (ControladorGaleria /nuevo) --%>
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
                            // 4. LÓGICA JAVA: RECUPERAR DATOS DEL SERVLET
                            // 'listaGaleria' VIENE DEL CONTROLADOR CON TODOS LOS OBJETOS GALERIA DE LA BD
                            List<GALERIA> galeria = (List<GALERIA>) request.getAttribute("listaGaleria");

                            // SI HAY DATOS, LOS MOSTRAMOS
                            if (galeria != null && !galeria.isEmpty()) {
                                for (GALERIA item : galeria) {
                                    
                                    // CONSTRUIMOS LA RUTA RELATIVA PARA QUE EL HTML ENCUENTRE EL ARCHIVO
                                    // EJEMPLO: /PeluqueriaPaqui/img/foto123.jpg
                                    String rutaWeb = request.getContextPath() + "/" + item.getRutaArchivo();
                        %>
                        
                        <%-- INICIO DE FILA --%>
                        <tr>
                            <td><%= item.getId()%></td>

                            <%-- COLUMNA VISTA PREVIA (INTERACTIVA) --%>
                            <td>
                                <%-- SI ES IMAGEN, MOSTRAMOS UNA MINIATURA REAL --%>
                                <% if ("IMAGEN".equals(item.getTipo())) {%>
                                <img src="<%= rutaWeb%>" 
                                     alt="Ver Imagen" 
                                     class="thumb-img"
                                     <%-- AL HACER CLICK, LLAMAMOS A LA FUNCIÓN JS 'abrirModal' --%>
                                     onclick="abrirModal('<%= rutaWeb%>', 'IMAGEN')"
                                     title="Clic para ampliar">
                                
                                <%-- SI ES VÍDEO, MOSTRAMOS UN RECTÁNGULO NEGRO GENÉRICO --%>
                                <% } else {%>
                                <div class="thumb-video"
                                     onclick="abrirModal('<%= rutaWeb%>', 'VIDEO')"
                                     title="Clic para reproducir">
                                    ▶ VIDEO MP4
                                </div>
                                <% }%>
                            </td>

                            <td><%= item.getTitulo()%></td>

                            <%-- COLUMNA TIPO CON BADGE DE COLOR --%>
                            <td>
                                <span class="tipo-badge <%= "IMAGEN".equals(item.getTipo()) ? "tipo-imagen" : "tipo-video"%>">
                                    <%= item.getTipo()%>
                                </span>
                            </td>

                            <%-- COLUMNA ACCIONES --%>
                            <td>
                                <%-- FORMULARIO DE BORRADO --%>
                                <form action="${pageContext.request.contextPath}/Admin/Galeria/eliminar" method="POST" class="acciones-form"
                                      onsubmit="return confirm('ATENCIÓN:\n¿Estás seguro de que quieres eliminar este archivo permanentemente?');">

                                    <%-- ENVIAMOS EL ID PARA SABER QUÉ REGISTRO BORRAR DE LA BD --%>
                                    <input type="hidden" name="id" value="<%= item.getId()%>" />
                                    
                                    <%-- ENVIAMOS LA RUTA PARA QUE EL SERVLET BORRE TAMBIÉN EL ARCHIVO FÍSICO DEL DISCO --%>
                                    <input type="hidden" name="nombreArchivo" value="<%= item.getRutaArchivo()%>" />

                                    <button type="submit" class="btn-eliminar">Eliminar</button>
                                </form>
                            </td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <%-- BLOQUE SI NO HAY DATOS --%>
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

        <%-- 5. ESTRUCTURA DEL MODAL (VENTANA OCULTA) --%>
        <%-- ESTE DIV ESTÁ OCULTO (display:none) HASTA QUE SE HACE CLICK EN UNA MINIATURA --%>
        <div id="previewModal" class="modal" onclick="cerrarModal()">
            <span class="close-btn" onclick="cerrarModal()">&times;</span>

            <%-- ELEMENTO PARA MOSTRAR FOTOS EN GRANDE --%>
            <img class="modal-content" id="imgModal" style="display:none;">

            <%-- ELEMENTO PARA REPRODUCIR VÍDEOS --%>
            <video class="modal-content" id="videoModal" controls style="display:none;">
                <source id="videoSource" src="" type="video/mp4">
                Tu navegador no soporta la reproducción de videos.
            </video>
        </div>

        <%-- 6. JAVASCRIPT PARA MANEJAR EL MODAL --%>
        <script>
            // FUNCIÓN PARA ABRIR EL VISOR
            function abrirModal(ruta, tipo) {
                var modal = document.getElementById("previewModal");
                var img = document.getElementById("imgModal");
                var video = document.getElementById("videoModal");
                var videoSrc = document.getElementById("videoSource");

                // HACEMOS VISIBLE EL FONDO OSCURO
                modal.style.display = "flex";

                if (tipo === 'IMAGEN') {
                    // CONFIGURACIÓN PARA MODO IMAGEN
                    img.src = ruta;          // ASIGNAMOS LA RUTA DE LA FOTO
                    img.style.display = "block"; // MOSTRAMOS LA ETIQUETA IMG
                    video.style.display = "none"; // OCULTAMOS LA ETIQUETA VIDEO
                    video.pause();           // POR SEGURIDAD, PAUSAMOS CUALQUIER VÍDEO ANTERIOR
                } else {
                    // CONFIGURACIÓN PARA MODO VÍDEO
                    videoSrc.src = ruta;     // ASIGNAMOS LA RUTA DEL MP4
                    video.load();            // OBLIGAMOS AL NAVEGADOR A CARGAR EL NUEVO VÍDEO
                    video.style.display = "block";
                    img.style.display = "none";
                    // video.play(); // OPCIONAL: AUTOPLAY AL ABRIR
                }
            }

            // FUNCIÓN PARA CERRAR EL VISOR
            function cerrarModal() {
                var modal = document.getElementById("previewModal");
                var video = document.getElementById("videoModal");

                modal.style.display = "none"; // OCULTAR EL FONDO OSCURO

                // ¡IMPORTANTE! DETENER EL VÍDEO AL CERRAR
                // SI NO HACEMOS ESTO, EL AUDIO SEGUIRÍA SONANDO DE FONDO AUNQUE EL MODAL NO SE VEA
                video.pause();
                video.currentTime = 0;
            }

            // EVITAR QUE EL MODAL SE CIERRE SI HACEMOS CLIC EN LA PROPIA FOTO/VÍDEO
            // (SOLO QUEREMOS CERRAR SI CLICAMOS EN EL FONDO NEGRO O LA 'X')
            document.getElementById("imgModal").onclick = function (e) {
                e.stopPropagation();
            }
            document.getElementById("videoModal").onclick = function (e) {
                e.stopPropagation();
            }

            // ACCESIBILIDAD: CERRAR CON LA TECLA ESCAPE
            document.addEventListener('keydown', function (event) {
                if (event.key === "Escape") {
                    cerrarModal();
                }
            });
        </script>

    </body>
</html>