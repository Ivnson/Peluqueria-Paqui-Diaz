<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/calendario.css">
    <title>Calendario de Disponibilidad - Peluquería Paqui Diaz</title>
    <style>
        .loading {
            text-align: center;
            padding: 20px;
            color: #666;
        }
        
        .error-message {
            background-color: #ffebee;
            color: #c62828;
            padding: 15px;
            border-radius: 4px;
            margin: 10px 0;
            text-align: center;
        }
    </style>
</head>
<body>

    <div class="calendario-container">
        <div class="calendario-header">
            <div class="navegacion-calendario">
                <button id="btn-mes-anterior" class="btn-navegacion">← Mes Anterior</button>
            </div>
            
            <div class="calendario-mes" id="mes-actual">
                Cargando...
            </div>
            
            <div class="navegacion-calendario">
                <button id="btn-mes-siguiente" class="btn-navegacion">Mes Siguiente →</button>
            </div>
        </div>

        <div id="loading" class="loading">
            📅 Cargando disponibilidad...
        </div>

        <div id="error-container" class="error-message" style="display: none;"></div>

        <div class="calendario-grid" id="calendario" style="display: none;">
            <!-- Se generará dinámicamente con JavaScript -->
        </div>
    </div>

    <script>
        // Estado global
        let estado = {
            año: new Date().getFullYear(),
            mes: new Date().getMonth() + 1,
            disponibilidad: {}
        };

        // Nombres de meses en español
        const meses = [
            'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
            'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
        ];

        // Inicializar
        document.addEventListener('DOMContentLoaded', function() {
            cargarCalendario();
            configurarEventos();
        });

        function configurarEventos() {
            document.getElementById('btn-mes-anterior').addEventListener('click', function() {
                estado.mes--;
                if (estado.mes < 1) {
                    estado.mes = 12;
                    estado.año--;
                }
                cargarCalendario();
            });

            document.getElementById('btn-mes-siguiente').addEventListener('click', function() {
                estado.mes++;
                if (estado.mes > 12) {
                    estado.mes = 1;
                    estado.año++;
                }
                cargarCalendario();
            });
        }

        function cargarCalendario() {
            mostrarLoading();
            ocultarError();

            const url = `${pageContext.request.contextPath}/Perfil/Citas/Disponibilidad?año=${estado.año}&mes=${estado.mes}`;
            
            fetch(url)
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Error en la respuesta del servidor');
                    }
                    return response.json();
                })
                .then(data => {
                    if (data.estado === 'error') {
                        throw new Error(data.mensaje);
                    }
                    
                    estado.disponibilidad = data.disponibilidad || {};
                    actualizarVista(data);
                    ocultarLoading();
                })
                .catch(error => {
                    console.error('Error:', error);
                    mostrarError('Error al cargar la disponibilidad: ' + error.message);
                    ocultarLoading();
                });
        }

        function actualizarVista(data) {
            // Actualizar título
            document.getElementById('mes-actual').textContent = 
                `${meses[estado.mes - 1]} ${estado.año}`;

            // Generar calendario
            generarCalendario();
            
            // Mostrar calendario
            document.getElementById('calendario').style.display = 'grid';
        }

        function generarCalendario() {
            const calendario = document.getElementById('calendario');
            calendario.innerHTML = '';

            // Añadir días de la semana
            const diasSemana = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
            diasSemana.forEach(dia => {
                const divDia = document.createElement('div');
                divDia.className = 'dia-semana';
                divDia.textContent = dia;
                calendario.appendChild(divDia);
            });

            // Generar días del mes
            const primerDia = new Date(estado.año, estado.mes - 1, 1);
            const ultimoDia = new Date(estado.año, estado.mes, 0);
            const diasEnMes = ultimoDia.getDate();
            
            // Ajustar inicio (lunes como primer día)
            let diaInicio = primerDia.getDay() - 1;
            if (diaInicio < 0) diaInicio = 6;

            // Generar días anteriores al mes
            const fechaInicio = new Date(primerDia);
            fechaInicio.setDate(fechaInicio.getDate() - diaInicio);

            for (let i = 0; i < 42; i++) { // 6 semanas
                const fecha = new Date(fechaInicio);
                fecha.setDate(fecha.getDate() + i);
                
                const divDia = crearDiaCalendario(fecha);
                calendario.appendChild(divDia);
            }
        }

        function crearDiaCalendario(fecha) {
            const divDia = document.createElement('div');
            const esMesActual = fecha.getMonth() === estado.mes - 1;
            const esPasado = fecha < new Date().setHours(0, 0, 0, 0);
            const esHoy = esMismoDia(fecha, new Date());

            divDia.className = 'dia-calendario';
            if (!esMesActual) divDia.classList.add('dia-otro-mes');
            if (esPasado) divDia.classList.add('dia-pasado');
            if (esHoy) divDia.classList.add('hoy');

            // Número del día
            const divNumero = document.createElement('div');
            divNumero.className = 'dia-numero';
            divNumero.textContent = fecha.getDate();
            divDia.appendChild(divNumero);

            // Horas disponibles/ocupadas
            if (esMesActual && !esPasado) {
                const divHoras = crearHorasDelDia(fecha);
                divDia.appendChild(divHoras);
            }

            return divDia;
        }

        function crearHorasDelDia(fecha) {
            const divHoras = document.createElement('div');
            divHoras.className = 'horas-ocupadas';

            const fechaStr = formatoFecha(fecha);
            const horasOcupadas = estado.disponibilidad[fechaStr] || [];
            
            // Horario de trabajo
            const horaInicio = 9; // 9:00
            const horaFin = 20;   // 20:00
            const duracionCita = 30; // minutos

            for (let hora = horaInicio; hora < horaFin; hora++) {
                for (let minuto = 0; minuto < 60; minuto += duracionCita) {
                    const horaStr = `${hora.toString().padStart(2, '0')}:${minuto.toString().padStart(2, '0')}`;
                    const estaOcupada = horasOcupadas.includes(horaStr);
                    
                    const spanHora = document.createElement('span');
                    spanHora.className = estaOcupada ? 'hora-ocupada' : 'hora-disponible';
                    spanHora.textContent = horaStr;
                    spanHora.title = estaOcupada ? 'Hora ocupada' : 'Hora disponible';

                    if (!estaOcupada) {
                        spanHora.style.cursor = 'pointer';
                        spanHora.addEventListener('click', () => seleccionarHora(fechaStr, horaStr));
                    }

                    divHoras.appendChild(spanHora);
                }
            }

            return divHoras;
        }

        function seleccionarHora(fecha, hora) {
            if (confirm(`¿Reservar cita para el ${fecha} a las ${hora}?`)) {
                // Redirigir al formulario con los parámetros
                window.location.href = 
                    `${pageContext.request.contextPath}/Perfil/Citas/Nueva?fecha=${fecha}&hora=${hora}`;
            }
        }

        // Utilidades
        function esMismoDia(fecha1, fecha2) {
            return fecha1.getDate() === fecha2.getDate() &&
                   fecha1.getMonth() === fecha2.getMonth() &&
                   fecha1.getFullYear() === fecha2.getFullYear();
        }

        function formatoFecha(fecha) {
            return `${fecha.getFullYear()}-${(fecha.getMonth() + 1).toString().padStart(2, '0')}-${fecha.getDate().toString().padStart(2, '0')}`;
        }

        function mostrarLoading() {
            document.getElementById('loading').style.display = 'block';
            document.getElementById('calendario').style.display = 'none';
        }

        function ocultarLoading() {
            document.getElementById('loading').style.display = 'none';
        }

        function mostrarError(mensaje) {
            const errorDiv = document.getElementById('error-container');
            errorDiv.textContent = mensaje;
            errorDiv.style.display = 'block';
        }

        function ocultarError() {
            document.getElementById('error-container').style.display = 'none';
        }

        // Actualizar automáticamente cada minuto
        setInterval(cargarCalendario, 30000);
    </script>

</body>
</html>