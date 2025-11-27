<%@page import="java.util.List"%>
<%@page import="Peluqueria.modelo.GALERIA"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.0.0/dist/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css"/>

        <script src="https://code.jquery.com/jquery-3.2.1.slim.min.js" integrity="sha384-KJ3o2DKtIkvYIK3UENzmM7KCkRr/rE9/Qpg6aAZGJwFDMVNA/GpGFF93hXpG5KkN" crossorigin="anonymous"></script>
        <script src="https://cdn.jsdelivr.net/npm/popper.js@1.12.9/dist/umd/popper.min.js" integrity="sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q" crossorigin="anonymous"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.0.0/dist/js/bootstrap.min.js" integrity="sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl" crossorigin="anonymous"></script>

        <title>Peluquería Paqui Diaz - Especialistas en Método Curly</title>

        <style>
            .carousel-item {
                height: 500px; /* Ajusta esta altura a tu gusto */
                background-color: #f5f5f5;
            }
            .carousel-item img {
                height: 100%;
                width: 100%;
                object-fit: cover; /* Recorta la imagen para llenar el espacio sin deformarse */
                object-position: center;
            }
        </style>
    </head>

    <body>

        <header>
            <h1>Peluquería Paqui Diaz</h1>
            <nav>
                <ul>
                    <li><a href="${pageContext.request.contextPath}/index">Inicio</a></li>
                    <li><a href="#metodo">Método Curly</a></li>
                    <li><a href="#servicios">Servicios</a></li>
                    <li><a href="#sobre-mi">Sobre Mí</a></li>
                    <li><a href="#galeria">Galería</a></li>
                    <li><a href="#contacto">Contacto</a></li>
                </ul>
            </nav>
        </header>

        <main>

            <section id="inicio">
                <h2>Descubre el poder de tus rizos</h2>
                <p>Bienvenida a tu espacio en Pilas, especializado en la recuperación y cuidado del cabello rizado y ondulado con el Método Curly.</p>
                <a href="#contacto">Pide tu cita ahora</a>
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
                <h3>Transformaciones (Antes y Después)</h3>
                <p>Una imagen vale más que mil palabras. Mira los resultados de nuestras clientas.</p>

                <div id="carouselExample" class="carousel slide" data-ride="carousel">

                    <ol class="carousel-indicators">
                        <%
                            List<GALERIA> listaIndicadores = (List<GALERIA>) request.getAttribute("imagenesGaleria");
                            if (listaIndicadores != null && !listaIndicadores.isEmpty()) {
                                for (int i = 0; i < listaIndicadores.size(); i++) {
                        %>
                        <li data-target="#carouselExample" data-slide-to="<%= i%>" class="<%= (i == 0) ? "active" : ""%>"></li>
                            <%
                                    }
                                }
                            %>
                    </ol>
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

                            <%-- LOGICA PARA DIFERENCIAR VIDEO / IMAGEN --%>
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

                            <div class="carousel-caption d-none d-md-block">
                                <h5><%= item.getTitulo()%></h5>
                                <% if ("VIDEO".equals(item.getTipo())) { %>
                                <p><small>(Video)</small></p>
                                <% } %>
                            </div>
                        </div>
                        <%
                            }
                        } else {
                        %>
                        <% }%>
                    </div>

                    <a class="carousel-control-prev" href="#carouselExample" role="button" data-slide="prev">
                        <span class="carousel-control-prev-icon" aria-hidden="true"></span>
                        <span class="sr-only">Anterior</span>
                    </a>
                    <a class="carousel-control-next" href="#carouselExample" role="button" data-slide="next">
                        <span class="carousel-control-next-icon" aria-hidden="true"></span>
                        <span class="sr-only">Siguiente</span>
                    </a>
                </div>

                <br>
                <a href="https://www.instagram.com/paquidiaz76_curly/" target="_blank">Ver más en Instagram</a>
            </section>

            <hr>

            <section id="contacto">
                <h3>Pide tu Cita</h3>
                <p>¿Lista para empezar tu viaje hacia un cabello espectacular? ¡Contacta conmigo!</p>
                <div class="info-item">
                    <strong>Horario</strong>
                    <div class="horario-detallado">
                        <div class="dia-horario"><span class="dia">Lunes:</span> <span class="horas cerrado">Cerrado</span></div>
                        <div class="dia-horario"><span class="dia">Martes:</span> <span class="horas">10:00 - 20:00</span></div>
                        <div class="dia-horario"><span class="dia">Miércoles:</span> <span class="horas">10:00 - 15:00</span></div>
                        <div class="dia-horario"><span class="dia">Jueves:</span> <span class="horas">10:00 - 20:00</span></div>
                        <div class="dia-horario"><span class="dia">Viernes:</span> <span class="horas">10:00 - 20:00</span></div>
                        <div class="dia-horario"><span class="dia">Sábado:</span> <span class="horas">09:00 - 14:00</span></div>
                        <div class="dia-horario"><span class="dia">Domingo:</span> <span class="horas cerrado">Cerrado</span></div>
                    </div>
                </div>
                <ul>
                    <li>Teléfono / WhatsApp: FALTA PONER EL NUMERO </li>
                </ul>
                <div class="mapa-contenedor">
                    <div class="mapa-real">
                        <iframe 
                            src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3173.586894087597!2d-6.303835923492651!3d37.29183783902621!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0xd120d6d7d5b0e8d%3A0x4f0c0b6d0c0b6d0c!2sC.%20Paseo%20Hoyo%20del%20Huerto%2C%2014%2C%2041840%20Pilas%2C%20Sevilla!5e0!3m2!1ses!2ses!4v1680000000000!5m2!1ses!2ses" 
                            width="100%" 
                            height="400" 
                            style="border:0;" 
                            allowfullscreen="" 
                            loading="lazy" 
                            referrerpolicy="no-referrer-when-downgrade">
                        </iframe>
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

    </body>
</html>