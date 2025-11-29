<%@page import="jakarta.jms.Session"%>
<%@page import="java.util.List"%>
<%@page import="Peluqueria.modelo.GALERIA"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-1BmE4kWBq78iYhFldvKuhfTAU6auU8tT94WrHftjDbrCEXSU1oBoqyl2QvZ6jIW3" crossorigin="anonymous">

        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css"/>

        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/img/logopeluqueria.png">

        <title>Peluquería Paqui Diaz - Especialistas en Método Curly</title>

        <style>
            /* ========== CARRUSEL PANORÁMICO PROFESIONAL ========== */

            /* Variables de color */
            :root {
                --carousel-primary: #3a9f8a;
                --carousel-secondary: #88D4C0;
                --carousel-dark: #2c7a68;
            }

            #galeria div{
                padding: 4px ;
                margin: 0px auto ;
                max-width: 1300px ;
            }

            /* Contenedor principal - Ultra panorámico */
            .carousel {
                width: 100%;
                max-width: 1600px;
                margin: 50px auto;
                border-radius: 20px;
                overflow: hidden;
                box-shadow:
                    0 30px 60px rgba(58, 159, 138, 0.2),
                    0 10px 20px rgba(0, 0, 0, 0.1);
                position: relative;
                background: #000;
            }

            /* Formato panorámico cinematográfico (21:9) */
            .carousel-item {
                height: 550px;
                position: relative;
                overflow: hidden;
            }

            /* Imágenes y videos con efecto Ken Burns sutil */
            .carousel-item img,
            .carousel-item video {
                width: 100%;
                height: 100%;
                object-fit: cover;
                object-position: center;

            }

            /* Efecto zoom muy sutil durante la transición automática */
            .carousel-item.active img,
            .carousel-item.active video {

            }

            /* Contenedor interno */
            .carousel-inner {
                border-radius: 20px;
                overflow: hidden;
            }

            /* Overlay gradiente elegante */
            .carousel-item::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;

                z-index: 2;
                pointer-events: none;
            }

            /* Controles de navegación - Estilo minimalista flotante */
            .carousel-control-prev,
            .carousel-control-next {
                width: 56px;
                height: 56px;
                background: rgba(255, 255, 255, 0.95);
                border-radius: 50%;
                top: 50%;
                transform: translateY(-50%);
                opacity: 1 !important;  /* Siempre visible */
                visibility: visible !important;
                display: flex !important;
                align-items: center;
                justify-content: center;
                transition: all 0.3s ease;
                border: none;
                box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
                z-index: 100;
            }

            .carousel-control-prev {
                left: 30px;
            }

            .carousel-control-next {
                right: 30px;
            }

            /* Mostrar controles en hover del carrusel */
            .carousel:hover .carousel-control-prev,
            .carousel:hover .carousel-control-next {
                opacity: 1;
            }

            .carousel-control-prev:hover,
            .carousel-control-next:hover {
                background: var(--carousel-primary);
                transform: translateY(-50%) scale(1.1);
                box-shadow: 0 8px 30px rgba(58, 159, 138, 0.4);
            }

            /* Iconos de los controles */
            .carousel-control-prev-icon,
            .carousel-control-next-icon {
                width: 20px;
                height: 20px;
                filter: invert(0%) brightness(30%);
                transition: filter 0.3s ease;
            }

            .carousel-control-prev:hover .carousel-control-prev-icon,
            .carousel-control-next:hover .carousel-control-next-icon {
                filter: invert(100%) brightness(100%);
            }

            /* Ocultar indicadores */
            .carousel-indicators {
                display: none !important;
            }

            /* Captions - Diseño moderno con glassmorphism */
            .carousel-caption {
                position: absolute;
                bottom: 40px;
                left: 50%;

                width: auto;
                max-width: 80%;
                padding: 20px 40px;
                background: rgba(255, 255, 255, 0.15);
                backdrop-filter: blur(20px);
                -webkit-backdrop-filter: blur(20px);
                border-radius: 16px;
                border: 1px solid rgba(255, 255, 255, 0.2);
                text-align: center;
                z-index: 5;
                opacity: 0;

            }

            .carousel-item.active .carousel-caption {
                opacity: 1;

            }

            .carousel-caption h5 {
                font-size: 1.6em;
                font-weight: 700;
                color: #fff;
                margin: 0 0 8px 0;
                text-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
                letter-spacing: 0.5px;
            }

            .carousel-caption p {
                font-size: 1em;
                color: rgba(255, 255, 255, 0.9);
                margin: 0;
                text-shadow: 0 1px 5px rgba(0, 0, 0, 0.2);
            }



          

            /* Badge para videos */
            .video-badge {
                position: absolute;
                top: 25px;
                left: 25px;
                background: rgba(255, 255, 255, 0.95);
                color: var(--carousel-dark);
                padding: 10px 18px;
                border-radius: 30px;
                font-size: 0.85em;
                font-weight: 600;
                z-index: 5;
                display: flex;
                align-items: center;
                gap: 8px;
                box-shadow: 0 4px 15px rgba(0, 0, 0, 0.15);
            }

            .video-badge::before {
                content: '';
                width: 0;
                height: 0;
                border-left: 8px solid var(--carousel-primary);
                border-top: 5px solid transparent;
                border-bottom: 5px solid transparent;
            }

            /* ========== Z-INDEX PARA TRANSICIONES SUAVES ========== */
            .carousel-item {
                backface-visibility: hidden;
                -webkit-backface-visibility: hidden;
            }

            .carousel-item.active {
                z-index: 2;
            }

            .carousel-item-next,
            .carousel-item-prev {
                z-index: 1;
            }

            /* ========== RESPONSIVE ========== */
            @media (max-width: 1400px) {
                .carousel {
                    max-width: 95%;
                    border-radius: 16px;
                }

                .carousel-item {
                    height: 480px;
                }
            }

            @media (max-width: 1024px) {
                .carousel-item {
                    height: 400px;
                }

                .carousel-control-prev,
                .carousel-control-next {
                    width: 48px;
                    height: 48px;
                    opacity: 1;
                }

                .carousel-control-prev {
                    left: 20px;
                }

                .carousel-control-next {
                    right: 20px;
                }

                .carousel-caption {
                    padding: 16px 30px;
                    max-width: 85%;
                }

                .carousel-caption h5 {
                    font-size: 1.3em;
                }
            }

            @media (max-width: 768px) {
                .carousel {
                    margin: 30px auto;
                    border-radius: 12px;
                    max-width: 100%;
                }

                .carousel-inner {
                    border-radius: 12px;
                }

                .carousel-item {
                    height: 320px;
                }

                .carousel-control-prev,
                .carousel-control-next {
                    width: 44px;
                    height: 44px;
                }

                .carousel-control-prev {
                    left: 15px;
                }

                .carousel-control-next {
                    right: 15px;
                }

                .carousel-caption {
                    bottom: 25px;
                    padding: 14px 24px;
                    max-width: 90%;
                    border-radius: 12px;
                }

                .carousel-caption h5 {
                    font-size: 1.15em;
                }

                .carousel-caption p {
                    font-size: 0.9em;
                }

                .video-badge {
                    top: 15px;
                    left: 15px;
                    padding: 8px 14px;
                    font-size: 0.8em;
                }
            }

            @media (max-width: 576px) {
                .carousel {
                    margin: 20px auto;
                    border-radius: 0;
                }

                .carousel-inner {
                    border-radius: 0;
                }

                .carousel-item {
                    height: 260px;
                }

                .carousel-control-prev,
                .carousel-control-next {
                    width: 40px;
                    height: 40px;
                }

                .carousel-control-prev {
                    left: 10px;
                }

                .carousel-control-next {
                    right: 10px;
                }

                .carousel-caption {
                    bottom: 15px;
                    padding: 12px 18px;
                    border-radius: 10px;
                }

                .carousel-caption h5 {
                    font-size: 1em;
                    margin-bottom: 4px;
                }

                .carousel-caption p {
                    font-size: 0.85em;
                }

                /* Ocultar barra de progreso en móvil */
                .carousel::after {
                    display: none;
                }
            }

            /* ========== FIX SUPERPOSICIÓN DE IMÁGENES ========== */

            /* Asegurar que el contenedor tenga overflow hidden */
            .carousel-inner {
                overflow: hidden !important;
                position: relative;
            }

            /* Cada item debe estar posicionado correctamente */
            .carousel-item {
                position: relative;
                display: none;
                float: left;
                width: 100%;
                margin-right: -100%;
                backface-visibility: hidden;
                -webkit-backface-visibility: hidden;


            }

            /* Solo el item activo es visible */
            .carousel-item.active {
                display: block;
                z-index: 2;
            }

            /* Items en transición */
            .carousel-item-next,
            .carousel-item-prev {
                display: block;
                position: absolute;
                top: 0;
                z-index: 1;
            }

            .carousel-item-next.carousel-item-start,
            .carousel-item-prev.carousel-item-end {
                z-index: 3;
            }

            /* Transición suave sin superposición */
            .carousel-fade .carousel-item {
                opacity: 0;

                transform: none;
            }

            .carousel-fade .carousel-item.active,
            .carousel-fade .carousel-item-next.carousel-item-start,
            .carousel-fade .carousel-item-prev.carousel-item-end {
                opacity: 1;
                z-index: 2;
            }

            .carousel-fade .carousel-item.active.carousel-item-start,
            .carousel-fade .carousel-item.active.carousel-item-end {
                opacity: 0;
                z-index: 1;
            }

            /* Imágenes y videos dentro del carrusel */
            .carousel-item img,
            .carousel-item video {
                position: relative;
                z-index: 1;
                display: block;
                width: 100%;
                height: 100%;
                object-fit: cover;
            }


            /* --- ESTILOS SECCIÓN CONTACTO --- */

            #contacto {
                padding: 60px 20px;
                background-color: var(--gris-fondo); /* O el color de fondo que prefieras */
            }

            #contacto h3 {
                text-align: center;
                margin-bottom: 10px;
            }

            .contacto-intro {
                text-align: center;
                margin-bottom: 40px;
                color: #666;
                font-size: 1.1rem;
            }

            /* Rejilla Principal (2 Columnas) */
            .contacto-grid {
                display: grid;
                grid-template-columns: 1fr 1fr; /* Dos columnas iguales */
                gap: 30px;
                max-width: 1200px;
                margin: 0 auto;
            }

            /* Tarjetas (Izquierda y Derecha) */
            .contacto-info-card,
            .mapa-card {
                background: white;
                border-radius: 15px;
                box-shadow: 0 8px 20px rgba(0,0,0,0.05);
                padding: 30px;
                height: 100%; /* Para que tengan la misma altura */
            }

            /* Mapa */
            .mapa-card {
                padding: 0; /* El mapa ocupa todo el borde */
                overflow: hidden; /* Recorta las esquinas del iframe */
                min-height: 400px;
            }
            .mapa-real, .mapa-real iframe {
                height: 100%;
                width: 100%;
                display: block;
            }

            /* Bloques de Información (Teléfono, Dirección) */
            .info-bloque {
                display: flex;
                align-items: center;
                margin-bottom: 25px;
                padding-bottom: 15px;
                border-bottom: 1px solid #eee;
            }

            .icono-contacto {
                font-size: 1.5rem;
                background-color: var(--verde-claro); /* O un gris muy claro */
                color: var(--verde-principal);
                width: 50px;
                height: 50px;
                border-radius: 50%;
                display: flex;
                justify-content: center;
                align-items: center;
                margin-right: 15px;
            }

            .texto-contacto strong {
                display: block;
                color: var(--texto-oscuro);
                font-size: 1.1rem;
                margin-bottom: 4px;
            }

            .texto-contacto p {
                margin: 0;
                color: #555;
            }

            /* Bloque de Horario */
            .horario-bloque h5 {
                color: var(--verde-principal);
                font-size: 1.2rem;
                margin-bottom: 15px;
                font-weight: 700;
            }

            .dia-row {
                display: flex;
                justify-content: space-between;
                padding: 8px 0;
                border-bottom: 1px dashed #eee;
                font-size: 0.95rem;
            }
            .dia-row:last-child {
                border-bottom: none;
            }

            .dia {
                font-weight: 600;
                color: #444;
            }

            .hora {
                color: #666;
            }

            .hora.cerrado {
                color: var(--rojo-error); /* #dc3545 */
                font-weight: bold;
                background-color: #fff5f5;
                padding: 2px 8px;
                border-radius: 4px;
                font-size: 0.85rem;
            }

            /* Responsive (Móvil) */
            @media (max-width: 768px) {
                .contacto-grid {
                    grid-template-columns: 1fr; /* Una columna */
                }
                .mapa-card {
                    height: 300px; /* Altura fija en móvil */
                }
            }
        </style>



    </head>

    <body>

        <header>
            <h1>Peluquería Paqui Diaz</h1>
            <nav>
                <%
                    if (session.getAttribute("usuarioLogueado") == null) {
                %>


                <a href="${pageContext.request.contextPath}/Login" class="btn-header">
                    Iniciar Sesión
                </a>


                <%
                } else {
                %>


                <a href="${pageContext.request.contextPath}/Perfil/Panel" class="btn-header">
                    Mi Perfil
                </a>


                <%
                    }
                %>
            </nav>
        </header>

        <main>

            <section id="inicio">
                <h2>Descubre el poder de tus rizos</h2>
                <p>Bienvenida a tu espacio en Pilas, especializado en la recuperación y cuidado del cabello rizado y ondulado con el Método Curly.</p>
                <a href="${pageContext.request.contextPath}/Perfil/Panel">Pide tu cita ahora</a>
            </section>

            <hr> 

            <section id="servicios">
                <h2>Nuestros Servicios</h2>
                <article>
                    <h4>Especialidad: Método Curly</h4>
                    <p>Diagnóstico capilar, corte en seco especializado, hidratación profunda y definición. Te enseñamos a cuidar tu cabello en casa.</p>
                </article>
                <article>
                    <h4>Corte y Peinado</h4>
                    <p>Realizamos todo tipo de cortes y peinados para mujer, adaptados a tu estilo y facciones, sea cual sea tu tipo de cabello.</p>
                </article>
                <article>
                    <h4>Coloración y Mechas</h4>
                    <p>Balayage, mechas y tratamientos de color que respetan la salud de tu fibra capilar, incluso en cabellos rizados.</p>
                </article>
            </section>

            <hr>

            <section id="sobre-mi">
                <h3>Conoce a Paqui Diaz</h3>
                <h4>Con más de 15 años de experiencia y una pasión por la salud capilar, mi misión es ayudarte a reconectar con tu cabello natural. Formada en las últimas técnicas del Método Curly, te acompaño en tu transición para que luzcas unos rizos sanos y definidos.</h4>
            </section>

            <hr>

            <section id="galeria">
                <h3>Una imagen vale más que mil palabras</h3>


                <!-- Añade la clase "carousel-fade" -->
                <div id="carouselGaleria" class="carousel slide carousel-fade" data-bs-ride="carousel">
                    <!-- Indicadores -->
                    <div class="carousel-indicators">
                        <%
                            List<GALERIA> listaIndicadores = (List<GALERIA>) request.getAttribute("imagenesGaleria");
                            if (listaIndicadores != null && !listaIndicadores.isEmpty()) {
                                for (int i = 0; i < listaIndicadores.size(); i++) {
                        %>
                        <button type="button" 
                                data-bs-target="#carouselExample" 
                                data-bs-slide-to="<%= i%>" 
                                class="<%= (i == 0) ? "active" : ""%>" 
                                aria-current="<%= (i == 0) ? "true" : "false"%>"
                                aria-label="Slide <%= i + 1%>"></button>
                        <%
                                }
                            }
                        %>
                    </div>

                    <!-- Contenido del carrusel -->
                    <div class="carousel-inner">
                        <%
                            List<GALERIA> fotos = (List<GALERIA>) request.getAttribute("imagenesGaleria");
                            if (fotos != null && !fotos.isEmpty()) {
                                boolean esPrimero = true;
                                for (GALERIA item : fotos) {
                                    String claseActive = esPrimero ? "active" : "";
                                    esPrimero = false;
                        %>
                        <div class="carousel-item <%= claseActive%>">
                            <%-- Lógica para diferenciar VIDEO / IMAGEN --%>
                            <% if ("VIDEO".equals(item.getTipo())) {%>
                            <video class="d-block w-100" controls>
                                <source src="${pageContext.request.contextPath}/<%= item.getRutaArchivo()%>" type="video/mp4">
                                Tu navegador no soporta videos.
                            </video>
                            <% } else {%>
                            <img src="${pageContext.request.contextPath}/<%= item.getRutaArchivo()%>" 
                                 class="d-block w-100" 
                                 alt="<%= item.getTitulo()%>">
                            <% }%>


                        </div>
                        <%
                            }
                        } else {
                        %>
                        <!-- Carrusel vacío - mostrar placeholder -->
                        <div class="carousel-item active">
                            <img src="${pageContext.request.contextPath}/images/placeholder.jpg" 
                                 class="d-block w-100" 
                                 alt="No hay imágenes disponibles">
                            <div class="carousel-caption">
                                <h5>No hay imágenes disponibles</h5>
                            </div>
                        </div>
                        <% }%>
                    </div>

                    <!-- Controles de navegación -->
                    <button class="carousel-control-prev" type="button" data-bs-target="#carouselGaleria" data-bs-slide="prev">
                        <span class="carousel-control-prev-icon" aria-hidden="true"></span>
                        <span class="visually-hidden">Anterior</span>
                    </button>
                    <button class="carousel-control-next" type="button" data-bs-target="#carouselGaleria" data-bs-slide="next">
                        <span class="carousel-control-next-icon" aria-hidden="true"></span>
                        <span class="visually-hidden">Siguiente</span>
                    </button>
                </div>

                <br>
                <a href="https://www.instagram.com/paquidiaz76_curly/" target="_blank">Ver más en Instagram</a>
            </section>




            <hr>

            <section id="contacto">
                <h3>¡Contacta conmigo!</h3>


                <div class="contacto-grid">

                    <div class="contacto-info-card">
                        <h4>Información</h4>

                        <div class="info-bloque">
                            <div class="icono-contacto">📞</div>
                            <div class="texto-contacto">
                                <strong>Teléfono / WhatsApp</strong>
                                <p>+34 649 689 064</p> </div>
                        </div>

                        <div class="info-bloque">
                            <div class="icono-contacto">📍</div>
                            <div class="texto-contacto">
                                <strong>Dirección</strong>
                                <p>Calle Paseo Hoyo del Huerto 14, 41840 Pilas, España</p>
                            </div>
                        </div>

                        <div class="horario-bloque">
                            <h5>Horario de Apertura</h5>
                            <div class="horario-lista">
                                <div class="dia-row"><span class="dia">Lunes</span> <span class="hora cerrado">Cerrado</span></div>
                                <div class="dia-row"><span class="dia">Martes</span> <span class="hora">10:00 - 20:00</span></div>
                                <div class="dia-row"><span class="dia">Miércoles</span> <span class="hora">10:00 - 15:00</span></div>
                                <div class="dia-row"><span class="dia">Jueves</span> <span class="hora">10:00 - 20:00</span></div>
                                <div class="dia-row"><span class="dia">Viernes</span> <span class="hora">10:00 - 20:00</span></div>
                                <div class="dia-row"><span class="dia">Sábado</span> <span class="hora">09:00 - 14:00</span></div>
                                <div class="dia-row"><span class="dia">Domingo</span> <span class="hora cerrado">Cerrado</span></div>
                            </div>
                        </div>
                    </div>

                    <div class="mapa-card">
                        <div class="mapa-real">
                            <iframe 
                                src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3170.749646670524!2d-6.301826624163922!3d37.37210997208971!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0xd120d6d7d5b0e8d%3A0x4f0c0b6d0c0b6d0c!2sC.%20Paseo%20Hoyo%20del%20Huerto%2C%2014%2C%2041840%20Pilas%2C%20Sevilla!5e0!3m2!1ses!2ses!4v1716458212345!5m2!1ses!2ses" 
                                width="100%" 
                                height="100%" 
                                style="border:0;" 
                                allowfullscreen="" 
                                loading="lazy" 
                                referrerpolicy="no-referrer-when-downgrade">
                            </iframe>
                        </div>
                    </div>

                </div>
            </section>

        </main>

        <footer>
            <p>Síguenos en nuestras redes:</p>
            <a href="https://www.instagram.com/paquidiaz76_curly/" target="_blank">Instagram</a>
            <p>© 2025 Peluquería Paqui Diaz. Todos los derechos reservados.</p>
            <a href="https://www.linkedin.com/in/iv%C3%A1n-gonz%C3%A1lez-d%C3%ADaz-638961254/" target="_blank"><p>Diseñado por Ivan Gonzalez Diaz</p></a>
        </footer>


        <script>
            document.addEventListener('DOMContentLoaded', function () {
                const carousel = document.getElementById('carouselGaleria');
                const items = carousel.querySelectorAll('.carousel-item');
                const prevBtn = carousel.querySelector('.carousel-control-prev');
                const nextBtn = carousel.querySelector('.carousel-control-next');
                let currentIndex = 0;

                // Función para mostrar un slide específico
                function showSlide(index) {
                    // Ocultar todos los items
                    items.forEach(function (item) {
                        item.classList.remove('active');
                    });

                    // Ajustar el índice si se sale de los límites
                    if (index >= items.length) {
                        currentIndex = 0;
                    } else if (index < 0) {
                        currentIndex = items.length - 1;
                    } else {
                        currentIndex = index;
                    }

                    // Mostrar el item actual
                    items[currentIndex].classList.add('active');

                    // Pausar todos los videos y reproducir el actual si es video
                    items.forEach(function (item) {
                        const video = item.querySelector('video');
                        if (video) {
                            video.pause();
                        }
                    });

                    const currentVideo = items[currentIndex].querySelector('video');
                    if (currentVideo) {
                        currentVideo.currentTime = 0;
                    }
                }

                // Botón siguiente
                nextBtn.addEventListener('click', function (e) {
                    e.preventDefault();
                    showSlide(currentIndex + 1);
                });

                // Botón anterior
                prevBtn.addEventListener('click', function (e) {
                    e.preventDefault();
                    showSlide(currentIndex - 1);
                });


            });
        </script>
    </body>
</html>







