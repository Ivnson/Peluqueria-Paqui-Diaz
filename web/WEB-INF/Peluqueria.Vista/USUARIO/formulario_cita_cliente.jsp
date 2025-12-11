<%@page import="Peluqueria.modelo.USUARIO"%>
<%@page import="Peluqueria.modelo.SERVICIO"%>
<%@page import="java.util.List"%>
<%@page import="java.time.LocalDate"%>
<%@page import="java.time.YearMonth"%>
<%@page import="java.time.DayOfWeek"%>
<%@page import="java.time.format.TextStyle"%>
<%@page import="java.util.Locale"%>
<%@page import="java.util.ArrayList"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Solicitar Nueva Cita</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/formulario_cita_cliente.css">
    </head>
    <body>

        <%

            // 1. RECUPERAMOS EL CLIENTE LOGUEADO DESDE LA SESIÓN
            USUARIO clienteLogueado = (USUARIO) session.getAttribute("usuarioLogueado");

            // 2. RECUPERAMOS LA LISTA DE SERVICIOS QUE EL SERVLET NOS MANDÓ
            List<SERVICIO> servicios = (List<SERVICIO>) request.getAttribute("servicios");

            // 3. CONFIGURACIÓN INICIAL DEL CALENDARIO 
            // OBTENEMOS LA FECHA DE HOY PARA SABER DÓNDE EMPEZAR A DIBUJAR EL CALENDARIO
            LocalDate today = LocalDate.now();
            // MES EN EL QUE ESTAMOS
            YearMonth currentMonth = YearMonth.from(today);
            // CUÁNTOS DÍAS TIENE ESTE MES
            int daysInMonth = currentMonth.lengthOfMonth();
            // EL DÍA 1 DEL MES
            LocalDate firstOfMonth = currentMonth.atDay(1);
            int firstDayValue = firstOfMonth.getDayOfWeek().getValue(); // 1=Lunes...

            // OBTENEMOS EL NOMBRE DEL MES EN ESPAÑOL PARA EL TÍTULO
            String monthName = currentMonth.getMonth().getDisplayName(TextStyle.FULL, new Locale("es", "ES"));
            // CONVERTIMOS LA PRIMERA LETRA EN MAYUSCULAS
            String capitalizedMonth = monthName.substring(0, 1).toUpperCase() + monthName.substring(1);
        %>

        <div class="form-container-horizontal">
            <div class="form-header">
                <h1>Solicitar Nueva Cita</h1>
            </div>

            <%-- ZONA DE MENSAJES DE ERROR (SI EL SERVLET NOS DEVUELVE ALGUNO) --%>
            <div id="caja-error">
                <% String error = (String) request.getAttribute("error");
                    if (error != null) {%>
                <div class="error-msg"><%= error%></div>
                <% }%>
            </div>

            <%-- SE ENVÍA POR POST A LA RUTA '/PERFIL/CITAS/CREAR' --%>
            <form id="formCita" action="${pageContext.request.contextPath}/Perfil/Citas/Crear" method="POST">
                <input type="hidden" name="clienteId" value="<%= clienteLogueado.getId()%>">

                <div class="form-content">
                    <%-- COLUMNA IZQUIERDA: SELECCIÓN DE SERVICIOS --%>
                    <div class="left-column">
                        <div class="form-section">
                            <h2>Servicios</h2>
                            <div class="servicios-grid">
                                <%-- ITERAMOS SOBRE LA LISTA DE SERVICIOS PARA CREAR UN CHECKBOX POR CADA UNO --%>
                                <% if (servicios != null) {
                                        for (SERVICIO s : servicios) {%>
                                <label class="servicio-checkbox">
                                    <input type="checkbox" name="serviciosIds" value="<%= s.getId()%>">
                                    <span class="checkmark"></span>
                                    <span class="servicio-info">
                                        <span class="servicio-nombre"><%= s.getNombreServicio()%></span>
                                        <span class="servicio-precio"><%= String.format("%.2f", s.getPrecio())%> €</span>
                                    </span>
                                </label>
                                <%  }
                                    }%>
                            </div>
                        </div>
                    </div>

                    <%-- COLUMNA DERECHA: CALENDARIO Y HORAS --%>
                    <div class="right-column">
                        <div class="form-section">
                            <h2>Fecha de la Cita</h2>
                            <div class="calendar-container">
                                <%-- CABECERA DEL CALENDARIO CON BOTONES DE NAVEGACIÓN (MES ANTERIOR / SIGUIENTE) --%>
                                <div class="calendar-header">
                                    <button type="button" class="calendar-nav" onclick="changeMonth(-1)">&#8249;</button>
                                    <span class="calendar-month-year" id="monthYearDisplay"><%= capitalizedMonth%> <%= currentMonth.getYear()%></span>
                                    <button type="button" class="calendar-nav" onclick="changeMonth(1)">&#8250;</button>
                                </div>

                                <%-- DÍAS DE LA SEMANA --%>
                                <div class="calendar-weekdays">
                                    <span class="weekday">Lu</span>
                                    <span class="weekday">Ma</span>
                                    <span class="weekday">Mi</span>
                                    <span class="weekday">Ju</span>
                                    <span class="weekday">Vi</span>
                                    <span class="weekday">Sa</span>
                                    <span class="weekday">Do</span>
                                </div>

                                <%-- CUERPO DEL CALENDARIO (GRID DE DÍAS) --%>
                                <%-- ID 'calendarGrid' PARA QUE JAVASCRIPT DIBUJE LOS DÍAS AQUÍ --%>
                                <div class="calendar-grid" id="calendarGrid">
                                    <%
                                        // RENDERIZADO INICIAL DEL CALENDARIO
                                        // ESTO DIBUJA EL CALENDARIO DEL MES ACTUAL AL CARGAR LA PÁGINA
                                        for (int i = 0; i < firstDayValue - 1; i++) { %>
                                    <div class="day empty"></div>
                                    <% }
                                        // DIBUJAMOS LOS DÍAS REALES DEL 1 AL 30/31
                                        for (int day = 1; day <= daysInMonth; day++) {
                                            LocalDate date = currentMonth.atDay(day);
                                            boolean isToday = date.equals(today);
                                            boolean isPast = date.isBefore(today);
                                    %>
                                    <div class="day <%= isToday ? "today" : ""%> <%= isPast ? "past" : ""%>" 
                                         data-date="<%= date%>" onclick="selectDate(this)"><%= day%></div>
                                    <% }%>
                                </div>
                            </div>
                            <%-- INPUT OCULTO DONDE SE GUARDARÁ LA FECHA ELEGIDA (YYYY-MM-DD) --%>
                            <input type="hidden" name="fecha" id="selectedDate" required>
                            <div class="selected-date-display">
                                Fecha: <span id="selectedDateText">Ninguna</span>
                            </div>
                        </div>

                        <div class="form-section">
                            <h2>Hora de Inicio</h2>
                            <%-- INPUT OCULTO DONDE SE GUARDARÁ LA HORA ELEGIDA (HH:MM) --%>
                            <input type="hidden" id="horaInicioHidden" name="horaInicio" required>

                            <%-- AQUÍ SE PINTARÁN LOS BOTONES DE HORA VÍA JAVASCRIPT --%>
                            <div id="contenedorHoras" class="time-slots">
                                <div style="grid-column: 1/-1; text-align: center; color: #888; padding: 20px;">
                                    Selecciona una fecha primero.
                                </div>
                            </div>

                            <div class="selected-time-display">
                                Hora: <span id="selectedTimeText">Ninguna</span>
                            </div></div>
                    </div>
                </div>

                <div class="form-actions">
                    <a href="${pageContext.request.contextPath}/Perfil/Panel" class="btn btn-cancel">Cancelar</a>
                    <button type="submit" class="btn btn-submit">Solicitar Cita</button>
                </div>
            </form>
        </div>

        <script>

            // 1. REFERENCIAS A ELEMENTOS DEL DOM
            const selectedDateInput = document.getElementById('selectedDate');
            const selectedDateText = document.getElementById('selectedDateText');
            const horaInicioHidden = document.getElementById('horaInicioHidden');
            const selectedTimeText = document.getElementById('selectedTimeText');
            const contenedorHoras = document.getElementById('contenedorHoras');
            const cajaError = document.getElementById('caja-error');

            // 2. VARIABLES DE ESTADO DEL CALENDARIO
            // INICIALIZAMOS CON EL MES QUE CALCULÓ JAVA AL PRINCIPIO
            let currentDisplayMonth = <%= currentMonth.getMonthValue() - 1%>; // JS usa 0-11
            let currentDisplayYear = <%= currentMonth.getYear()%>;


            const monthNames = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
                'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];




            // 3. FUNCIÓN PARA CAMBIAR DE MES (ADELANTE/ATRÁS)
            function changeMonth(direction) {
                currentDisplayMonth += direction;

                if (currentDisplayMonth > 11) {
                    currentDisplayMonth = 0;
                    currentDisplayYear++;
                } else if (currentDisplayMonth < 0) {
                    currentDisplayMonth = 11;
                    currentDisplayYear--;
                }

                // REDIBUJAMOS EL CALENDARIO CON EL NUEVO MES
                renderCalendar();
            }



            // 4. FUNCIÓN QUE DIBUJA EL CALENDARIO
            function renderCalendar() {

                // CALCULAMOS CUÁNDO EMPIEZA EL MES Y CUÁNTOS DÍAS TIENE
                const firstDay = new Date(currentDisplayYear, currentDisplayMonth, 1).getDay();
                const daysInMonth = new Date(currentDisplayYear, currentDisplayMonth + 1, 0).getDate();
                const today = new Date();

                // RESETEAMOS HORAS PARA COMPARAR SOLO FECHAS
                today.setHours(0, 0, 0, 0);

                // AJUSTE PARA QUE LUNES SEA EL PRIMER DÍA
                const startDay = (firstDay + 6) % 7;


                // ACTUALIZAMOS EL TÍTULO DEL MES
                document.getElementById('monthYearDisplay').textContent =
                        monthNames[currentDisplayMonth] + ' ' + currentDisplayYear;

                // LIMPIAMOS EL GRID ANTES DE DIBUJAR
                const grid = document.getElementById('calendarGrid');
                grid.innerHTML = '';

                // DIBUJAR HUECOS VACÍOS
                for (let i = 0; i < startDay; i++) {
                    const emptyDiv = document.createElement('div');
                    emptyDiv.className = 'day empty';

                    // INSERTA EL DIV VACIO COMO UN ELEMENTO HIJO DENTRO DEL GRID (CONTENEDOR PRINCIPAL DEL CALENDARIO)
                    grid.appendChild(emptyDiv);
                }

                // DIBUJAR LOS DÍAS
                for (let day = 1; day <= daysInMonth; day++) {
                    const dayDiv = document.createElement('div');
                    const dateObj = new Date(currentDisplayYear, currentDisplayMonth, day);

                    dayDiv.className = 'day';
                    dayDiv.textContent = day;

                    // MARCAR SI ES HOY
                    if (dateObj.getTime() === today.getTime()) {
                        dayDiv.classList.add('today');
                    }

                    // MARCAR Y DESHABILITAR SI ES PASADO
                    if (dateObj < today) {
                        dayDiv.classList.add('past');
                    } else {

                        // SI ES FUTURO U HOY, AÑADIMOS EL CLICK
                        dayDiv.onclick = function () {
                            selectDate(this, dateObj);
                        };
                    }

                    // GUARDAMOS LA FECHA EN FORMATO YYYY-MM-DD EN UN ATRIBUTO DE DATOS
                    const dateStr = currentDisplayYear + '-' +
                            String(currentDisplayMonth + 1).padStart(2, '0') + '-' +
                            String(day).padStart(2, '0');
                    dayDiv.setAttribute('data-date', dateStr);

                    grid.appendChild(dayDiv);
                }
            }



            // 5. FUNCIÓN AL HACER CLIC EN UN DÍA
            function selectDate(element, dateObj) {
                // REMOVER SELECCIÓN VISUAL ANTERIOR

                const selectedDays = document.querySelectorAll('.day.selected');


                for (const dayDiv of selectedDays) {
                    dayDiv.classList.remove('selected');
                }


                // MARCAR EL NUEVO DÍA
                element.classList.add('selected');

                // GUARDAR EL VALOR EN EL INPUT OCULTO
                const selectedDate = element.getAttribute('data-date');
                document.getElementById('selectedDate').value = selectedDate;

                // MOSTRAR FECHA AL USUARIO
                const dateDisplay = new Date(selectedDate);
                const options = {year: 'numeric', month: 'long', day: 'numeric'};
                document.getElementById('selectedDateText').textContent =
                        dateDisplay.toLocaleDateString('es-ES', options);

                // PEDIR LAS HORAS DE ESE DÍA
                cargarHorarios(selectedDate);
            }


            // 6. EVENT LISTENER PARA LOS DÍAS GENERADOS POR JAVA 
            // ESTO LE DICE AL NAVEGADOR: NO HAGAS NADA HASTA QUE TODO EL HTML ESTÉ CARGADO Y DIBUJADO
            document.addEventListener('DOMContentLoaded', function () {

                // BUSCA TODOS LOS ELEMENTOS QUE CUMPLAN ESTAS 3 CONDICIONES A LA VEZ
                // A TIENEN LA CLASE .day
                // B NO TIENEN LA CLASE .past
                // C NO TIENEN LA CLASE .empty
                
                document.querySelectorAll('.day:not(.past):not(.empty)').forEach(function (dayEl) {
                    
                    // POR CADA DÍA ENCONTRADO, LE PONEMOS PARA QUE ESCUCHE CLICK
                    dayEl.addEventListener('click', function () {
                        
                        // RECUPERAMOS LA FECHA QUE GUARDAMOS EN EL JSP CON data-date
                        const dateStr = this.getAttribute('data-date');
                        
                        // CONVERTIMOS ESE TEXTO EN UN OBJETO DE FECHA REAL
                        const dateObj = new Date(dateStr);
                        
                        selectDate(this, dateObj);
                    });
                });
            });





            // 7. CARGAR HORARIOS DESDE EL SERVIDOR
            function cargarHorarios(fecha) {
                
                // ANTES DE HACER NADA, BORRAMOS LOS BOTONES VIEJOS Y PONEMOS UN TEXTO ---> CARGANDO...
                // ESTO ES VITAL PARA QUE EL USUARIO SEPA QUE LA PÁGINA ESTÁ PENSANDO Y NO SE HA QUEDADO COLGADA
                contenedorHoras.innerHTML = '<div style="grid-column: 1/-1; text-align: center;">Cargando...</div>';

                // HACEMOS UN FETCH (PETICIÓN GET) AL SERVLET QUE DEVUELVE JSON
                fetch('${pageContext.request.contextPath}/Perfil/HorasOcupadas?fecha=' + fecha)
                        .then(res => res.json()) // CONVERTIMOS LA RESPUESTA JSON A UN ARRAY DE JS
                
                        // AQUÍ data YA ES EL ARRAY DE HORAS
                        .then(data => {
                            console.log("Datos JS:", data);
                            pintarHorarios(data); // LLAMAMOS A LA FUNCIÓN QUE DIBUJA LOS BOTONES
                        })
                        .catch(err => {
                            console.error(err);
                            contenedorHoras.innerHTML = '<div style="color:red; grid-column:1/-1; text-align:center;">Error de conexión</div>';
                        });
            }

            // 8. DIBUJAR BOTONES DE HORAS (RECIBE EL JSON)
            function pintarHorarios(horarios) {
                
                // ANTES DE DIBUJAR NADA, BORRAMOS LO QUE HUBIERA ANTES
                contenedorHoras.innerHTML = '';

                // SI EL ARRAY ES NULL O ESTÁ VACÍO, SIGNIFICA QUE NO HAY HUECOS (DÍA CERRADO)
                if (!horarios || horarios.length === 0) {
                    contenedorHoras.innerHTML = '<div style="grid-column: 1/-1; text-align: center; color: #e74c3c; font-weight: bold;">Cerrado o completo.</div>';
                    return;
                }

                // ITERAMOS SOBRE CADA HORA DEL JSON
                // SLOT REPRESENTA UN OBJETO INDIVIDUAL
                horarios.forEach(slot => {

                    // EXTRAEMOS LOS DATOS
                    const hora = slot.hora;
                    // VERIFICAMOS SI EL ESTADO ES ocupada ,ESTO DEVUELVE TRUE O FALSE
                    const ocupada = (slot.estado === 'ocupada');

                    // CREAMOS EL DIV DEL BOTÓN
                    const btn = document.createElement('div');
                    
                    // LE ASIGNAMOS CLASES CSS DINÁMICAS
                    // SIEMPRE TENDRÁ time-slot, SI ESTÁ OCUPADA, TAMBIÉN TENDRÁ LA CLASE ocupada
                    btn.className = `time-slot ${ocupada ? 'ocupada' : ''}`;
                    
                    // PONEMOS LA HORA COMO TEXTO DEL BOTÓN
                    btn.textContent = hora;
                    if (ocupada) {
                        btn.innerHTML = hora + ' <small style="color:red">(Ocupado)</small>';
                    }

                    // SOLO SI ESTÁ LIBRE LE PONEMOS EL CLICK
                    if (!ocupada) {
                        btn.onclick = function () {
                            // QUITAR SELECCIÓN DE OTRAS HORAS
                            document.querySelectorAll('.time-slot').forEach(el => el.classList.remove('selected'));
                            // MARCAR ESTA
                            btn.classList.add('selected');
                            // GUARDAR VALOR EN INPUT OCULTO
                            horaInicioHidden.value = hora;
                            selectedTimeText.textContent = hora;
                            // LIMPIAR MENSAJES DE ERROR
                            if (cajaError)
                                cajaError.innerHTML = '';
                        };
                    }
                    
                    // AGREGAMOS EL BOTÓN QUE ACABAMOS DE CONFIGURAR DENTRO DEL CONTENEDOR VISIBLE
                    contenedorHoras.appendChild(btn);
                });
            }

            // 9. RE-VINCULACIÓN DE EVENTOS 
            document.querySelectorAll('.day:not(.empty):not(.past)').forEach(day => {
                day.addEventListener('click', function () {
                    
                    // BUSCAMOS CUALQUIER DÍA QUE ESTUVIERA MARCADO PREVIAMENTE COMO SELECTED Y SE LO QUITAMOS
                    document.querySelectorAll('.day.selected').forEach(d => d.classList.remove('selected'));
                    
                    // ES EL DÍA QUE ACABAS DE CLICAR. LE AÑADIMOS LA CLASE
                    this.classList.add('selected');

                    // LEEMOS LA FECHA  QUE ESTÁ OCULTA EN EL ATRIBUTO DATA-DATE
                    const fecha = this.getAttribute('data-date');
                    
                    // METEMOS ESA FECHA EN EL INPUT OCULTO QUE SE ENVIARÁ AL SERVIDOR
                    selectedDateInput.value = fecha;
                    
                    // ACTUALIZAMOS EL TEXTO VISIBLE PARA QUE EL USUARIO VEA QUÉ DÍA ELIGIÓ
                    selectedDateText.textContent = fecha;

                    // SI CAMBIA EL DÍA, RESETEAMOS LA HORA ELEGIDA
                    horaInicioHidden.value = '';
                    selectedTimeText.textContent = 'Ninguna';

                    // LLAMAMOS A LA FUNCIÓN QUE PIDE AL SERVIDOR LOS HUECOS LIBRES PARA ESTA NUEVA FECHA
                    cargarHorarios(fecha);
                });
            });

            // 10. VALIDACIÓN FINAL ANTES DE ENVIAR EL FORMULARIO
            document.getElementById('formCita').addEventListener('submit', function (e) {
                let msg = '';

                // VERIFICAR QUE HAYA FECHA, HORA Y AL MENOS UN SERVICIO
                if (!selectedDateInput.value)
                    msg = 'Selecciona una fecha';
                else if (!horaInicioHidden.value)
                    msg = 'Selecciona una hora';
                else if (document.querySelectorAll('input[name="serviciosIds"]:checked').length === 0)
                    msg = 'Elige un servicio';

                if (msg) {
                    // DETENER EL ENVÍO
                    e.preventDefault();
                    cajaError.innerHTML = `<div class="error-msg">${msg}</div>`;
                }
            });
        </script>
    </body>
</html>