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
            USUARIO clienteLogueado = (USUARIO) session.getAttribute("usuarioLogueado");
            List<SERVICIO> servicios = (List<SERVICIO>) request.getAttribute("servicios");

            // Configuración del Calendario
            LocalDate today = LocalDate.now();
            YearMonth currentMonth = YearMonth.from(today);
            int daysInMonth = currentMonth.lengthOfMonth();
            LocalDate firstOfMonth = currentMonth.atDay(1);
            int firstDayValue = firstOfMonth.getDayOfWeek().getValue(); // 1=Lunes...

            String monthName = currentMonth.getMonth().getDisplayName(TextStyle.FULL, new Locale("es", "ES"));
            String capitalizedMonth = monthName.substring(0, 1).toUpperCase() + monthName.substring(1);
        %>

        <div class="form-container-horizontal">
            <div class="form-header">
                <h1>Solicitar Nueva Cita</h1>
            </div>

            <div id="caja-error">
                <% String error = (String) request.getAttribute("error");
                    if (error != null) {%>
                <div class="error-msg"><%= error%></div>
                <% }%>
            </div>

            <form id="formCita" action="${pageContext.request.contextPath}/Perfil/Citas/Crear" method="POST">
                <input type="hidden" name="clienteId" value="<%= clienteLogueado.getId()%>">

                <div class="form-content">
                    <div class="left-column">
                        <div class="form-section">
                            <h2>Servicios</h2>
                            <div class="servicios-grid">
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

                    <div class="right-column">
                        <div class="form-section">
                            <h2>Fecha de la Cita</h2>
                            <div class="calendar-container">
                                <!-- <CHANGE> Añadido botones de navegación entre meses -->
                                <div class="calendar-header">
                                    <button type="button" class="calendar-nav" onclick="changeMonth(-1)">&#8249;</button>
                                    <span class="calendar-month-year" id="monthYearDisplay"><%= capitalizedMonth%> <%= currentMonth.getYear()%></span>
                                    <button type="button" class="calendar-nav" onclick="changeMonth(1)">&#8250;</button>
                                </div>

                                <div class="calendar-weekdays">
                                    <span class="weekday">Lu</span>
                                    <span class="weekday">Ma</span>
                                    <span class="weekday">Mi</span>
                                    <span class="weekday">Ju</span>
                                    <span class="weekday">Vi</span>
                                    <span class="weekday">Sa</span>
                                    <span class="weekday">Do</span>
                                </div>

                                <!-- <CHANGE> Grid del calendario ahora se llena con JavaScript -->
                                <div class="calendar-grid" id="calendarGrid">
                                    <%
                                        for (int i = 0; i < firstDayValue - 1; i++) { %>
                                    <div class="day empty"></div>
                                    <% }
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
                            <input type="hidden" name="fecha" id="selectedDate" required>
                            <div class="selected-date-display">
                                Fecha: <span id="selectedDateText">Ninguna</span>
                            </div>
                        </div>

                        <div class="form-section">
                            <h2>Hora de Inicio</h2>
                            <input type="hidden" id="horaInicioHidden" name="horaInicio" required>

                            <div id="contenedorHoras" class="time-slots">
                                <div style="grid-column: 1/-1; text-align: center; color: #888; padding: 20px;">
                                    Selecciona una fecha primero.
                                </div>
                            </div>

                            <div class="selected-time-display">
                                Hora: <span id="selectedTimeText">Ninguna</span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="form-actions">
                    <a href="${pageContext.request.contextPath}/Perfil/Panel" class="btn btn-cancel">Cancelar</a>
                    <button type="submit" class="btn btn-submit">Solicitar Cita</button>
                </div>
            </form>
        </div>

        <script>
            const selectedDateInput = document.getElementById('selectedDate');
            const selectedDateText = document.getElementById('selectedDateText');
            const horaInicioHidden = document.getElementById('horaInicioHidden');
            const selectedTimeText = document.getElementById('selectedTimeText');
            const contenedorHoras = document.getElementById('contenedorHoras');
            const cajaError = document.getElementById('caja-error');
            // Variables para control del calendario
            let currentDisplayMonth = <%= currentMonth.getMonthValue() - 1%>; // JS usa 0-11
            let currentDisplayYear = <%= currentMonth.getYear()%>;
            // Nombres de meses
            const monthNames = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
                'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];




            // Cambiar mes
            function changeMonth(direction) {
                currentDisplayMonth += direction;

                if (currentDisplayMonth > 11) {
                    currentDisplayMonth = 0;
                    currentDisplayYear++;
                } else if (currentDisplayMonth < 0) {
                    currentDisplayMonth = 11;
                    currentDisplayYear--;
                }

                renderCalendar();
            }



            // Renderizar calendario
            function renderCalendar() {
                const firstDay = new Date(currentDisplayYear, currentDisplayMonth, 1).getDay();
                const daysInMonth = new Date(currentDisplayYear, currentDisplayMonth + 1, 0).getDate();
                const today = new Date();
                today.setHours(0, 0, 0, 0);

                // Ajustar para que lunes sea el primer día (0=domingo en JS)
                const startDay = firstDay === 0 ? 6 : firstDay - 1;

                // Actualizar título
                document.getElementById('monthYearDisplay').textContent =
                        monthNames[currentDisplayMonth] + ' ' + currentDisplayYear;

                // Limpiar grid
                const grid = document.getElementById('calendarGrid');
                grid.innerHTML = '';

                // Días vacíos al inicio
                for (let i = 0; i < startDay; i++) {
                    const emptyDiv = document.createElement('div');
                    emptyDiv.className = 'day empty';
                    grid.appendChild(emptyDiv);
                }

                // Días del mes
                for (let day = 1; day <= daysInMonth; day++) {
                    const dayDiv = document.createElement('div');
                    const dateObj = new Date(currentDisplayYear, currentDisplayMonth, day);

                    dayDiv.className = 'day';
                    dayDiv.textContent = day;

                    // Marcar día actual
                    if (dateObj.getTime() === today.getTime()) {
                        dayDiv.classList.add('today');
                    }

                    // Deshabilitar días pasados
                    if (dateObj < today) {
                        dayDiv.classList.add('past');
                    } else {
                        dayDiv.onclick = function () {
                            selectDate(this, dateObj);
                        };
                    }

                    // Guardar fecha en formato para enviar al servidor
                    const dateStr = currentDisplayYear + '-' +
                            String(currentDisplayMonth + 1).padStart(2, '0') + '-' +
                            String(day).padStart(2, '0');
                    dayDiv.setAttribute('data-date', dateStr);

                    grid.appendChild(dayDiv);
                }
            }



            // Seleccionar fecha
            function selectDate(element, dateObj) {
                // Remover selección previa
                document.querySelectorAll('.day.selected').forEach(d => d.classList.remove('selected'));

                // Añadir selección
                element.classList.add('selected');

                // Guardar fecha
                const selectedDate = element.getAttribute('data-date');
                document.getElementById('selectedDate').value = selectedDate;

                // Mostrar fecha seleccionada
                const dateDisplay = new Date(selectedDate);
                const options = {year: 'numeric', month: 'long', day: 'numeric'};
                document.getElementById('selectedDateText').textContent =
                        dateDisplay.toLocaleDateString('es-ES', options);

                // Cargar horarios disponibles para esta fecha
                cargarHorarios(selectedDate);
            }


            // Manejar clicks en días generados por JSP (al cargar)
            document.addEventListener('DOMContentLoaded', function () {
                document.querySelectorAll('.day:not(.past):not(.empty)').forEach(function (dayEl) {
                    dayEl.addEventListener('click', function () {
                        const dateStr = this.getAttribute('data-date');
                        const dateObj = new Date(dateStr);
                        selectDate(this, dateObj);
                    });
                });
            });





            // 1. CARGAR HORARIOS
            function cargarHorarios(fecha) {
                contenedorHoras.innerHTML = '<div style="grid-column: 1/-1; text-align: center;">Cargando...</div>';

                // Tu consola mostró que los datos llegan bien a esta URL
                fetch('${pageContext.request.contextPath}/Perfil/HorasOcupadas?fecha=' + fecha)
                        .then(res => res.json())
                        .then(data => {
                            console.log("Datos JS:", data); // Confirmación en consola
                            pintarHorarios(data);
                        })
                        .catch(err => {
                            console.error(err);
                            contenedorHoras.innerHTML = '<div style="color:red; grid-column:1/-1; text-align:center;">Error de conexión</div>';
                        });
            }

            // 2. PINTAR BOTONES
            function pintarHorarios(horarios) {
                contenedorHoras.innerHTML = '';

                if (!horarios || horarios.length === 0) {
                    contenedorHoras.innerHTML = '<div style="grid-column: 1/-1; text-align: center; color: #e74c3c; font-weight: bold;">Cerrado o completo.</div>';
                    return;
                }

                horarios.forEach(slot => {
                    // Usamos slot.hora (según tu consola)
                    const hora = slot.hora;
                    const ocupada = (slot.estado === 'ocupada');

                    // Creamos el elemento visual
                    const btn = document.createElement('div');
                    btn.className = `time-slot ${ocupada ? 'ocupada' : ''}`;
                    btn.textContent = hora;
                    if (ocupada) {
                        btn.innerHTML = hora + ' <small style="color:red">(Ocupado)</small>';
                    }

                    // Evento Click
                    if (!ocupada) {
                        btn.onclick = function () {
                            // Quitar selección previa
                            document.querySelectorAll('.time-slot').forEach(el => el.classList.remove('selected'));
                            // Seleccionar este
                            btn.classList.add('selected');
                            // Actualizar inputs
                            horaInicioHidden.value = hora;
                            selectedTimeText.textContent = hora;
                            // Limpiar error
                            if (cajaError)
                                cajaError.innerHTML = '';
                        };
                    }
                    contenedorHoras.appendChild(btn);
                });
            }

            // 3. EVENTOS CALENDARIO
            document.querySelectorAll('.day:not(.empty):not(.past)').forEach(day => {
                day.addEventListener('click', function () {
                    document.querySelectorAll('.day.selected').forEach(d => d.classList.remove('selected'));
                    this.classList.add('selected');

                    const fecha = this.getAttribute('data-date');
                    selectedDateInput.value = fecha;
                    selectedDateText.textContent = fecha;

                    // Resetear hora
                    horaInicioHidden.value = '';
                    selectedTimeText.textContent = 'Ninguna';

                    cargarHorarios(fecha);
                });
            });

            // 4. VALIDACIÓN FORMULARIO
            document.getElementById('formCita').addEventListener('submit', function (e) {
                let msg = '';
                if (!selectedDateInput.value)
                    msg = 'Selecciona una fecha';
                else if (!horaInicioHidden.value)
                    msg = 'Selecciona una hora';
                else if (document.querySelectorAll('input[name="serviciosIds"]:checked').length === 0)
                    msg = 'Elige un servicio';

                if (msg) {
                    e.preventDefault();
                    cajaError.innerHTML = `<div class="error-msg">${msg}</div>`;
                }
            });
        </script>
    </body>
</html>