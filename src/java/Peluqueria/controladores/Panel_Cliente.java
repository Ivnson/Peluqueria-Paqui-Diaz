package Peluqueria.controladores;

import Peluqueria.Utilidades.Contraseñas;
import Peluqueria.modelo.CITA;
import Peluqueria.modelo.HISTORIAL_CITA;
import Peluqueria.modelo.SERVICIO;
import Peluqueria.modelo.USUARIO;
import jakarta.annotation.Resource;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.Query;
import jakarta.persistence.TypedQuery; // <-- ¡Usamos TypedQuery!
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.transaction.UserTransaction;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@WebServlet(name = "Panel_Cliente", urlPatterns = {"/Perfil", "/Perfil/*"})
public class Panel_Cliente extends HttpServlet {

    @PersistenceContext(unitName = "PeluqueriaPaquiPU")
    private EntityManager em;

    @Resource
    private UserTransaction ut;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            pathInfo = "/Panel"; // Ruta por defecto
        }

        USUARIO usuarioLogueado = (USUARIO) request.getSession().getAttribute("usuarioLogueado");

        switch (pathInfo) {
            case "/Panel":
                mostrarDashboard(request, response, usuarioLogueado);
                break;
            case "/Editar":
                mostrarFormularioEditar(request, response, usuarioLogueado); // <-- Corregido de "Editar"
                break;

            case "/Citas/Nueva":
                // Esto es un GET, debe MOSTRAR el formulario
                mostrarFormularioCitaCliente(request, response); // <-- Corregido de "CrearCita"
                break;

            case "/Citas/Historial":
                mostrarHistorial(request, response, usuarioLogueado);
                break;

            case "/HorasOcupadas":
                obtenerHorasOcupadas(request, response);
                break;

            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                break;
        }
    }

    private void obtenerHorasOcupadas(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            String fechaParam = request.getParameter("fecha");
            if (fechaParam == null || fechaParam.isEmpty()) {
                response.getWriter().write("[]");
                return;
            }

            LocalDate fecha = LocalDate.parse(fechaParam);

            // 1. Generar los huecos posibles
            List<LocalTime> slotsPosibles = generarHorariosParaDia(fecha);

            // 2. Consultar qué horas están ocupadas en la BD
            List<String> horasOcupadasStr = new ArrayList<>();
            try {
                TypedQuery<LocalTime> query = em.createQuery(
                        "SELECT c.horaInicio FROM CITA c WHERE c.fecha = :fecha", LocalTime.class);
                query.setParameter("fecha", fecha);

                List<LocalTime> resultadosBD = query.getResultList();

                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("HH:mm");
                for (LocalTime horaBD : resultadosBD) {
                    horasOcupadasStr.add(horaBD.format(formatter));
                }
            } catch (Exception e) {
                System.err.println("Error consultando BD: " + e.getMessage());
            }

            // 3. Construir el JSON (Usamos "hora" en singular)
            StringBuilder json = new StringBuilder("[");
            DateTimeFormatter jsonFormatter = DateTimeFormatter.ofPattern("HH:mm");

            for (int i = 0; i < slotsPosibles.size(); i++) {
                LocalTime slot = slotsPosibles.get(i);
                String horaSlotStr = slot.format(jsonFormatter);

                boolean estaOcupada = horasOcupadasStr.contains(horaSlotStr);
                String estado = estaOcupada ? "ocupada" : "libre";

                // CLAVE: Usamos "hora" aquí
                json.append(String.format("{\"hora\": \"%s\", \"estado\": \"%s\"}", horaSlotStr, estado));

                if (i < slotsPosibles.size() - 1) {
                    json.append(",");
                }
            }
            json.append("]");

            response.getWriter().write(json.toString());

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("[]");
        }
    }

    // --- MÉTODO NUEVO CON TUS REGLAS DE NEGOCIO ---
    // --- MÉTODO AUXILIAR: Define los horarios de apertura ---
    private List<LocalTime> generarHorariosParaDia(LocalDate fecha) {
        List<LocalTime> slots = new ArrayList<>();
        java.time.DayOfWeek diaSemana = fecha.getDayOfWeek();

        LocalTime inicio = null;
        LocalTime fin = null;

        switch (diaSemana) {
            case MONDAY: // ¡Lunes Cerrado!
            case SUNDAY: // ¡Domingo Cerrado!
                return slots; // Devolvemos lista vacía = No hay huecos

            case TUESDAY:   // Martes: 10:00 - 20:00
            case THURSDAY:  // Jueves: 10:00 - 20:00
            case FRIDAY:    // Viernes: 10:00 - 20:00
                inicio = LocalTime.of(10, 0);
                fin = LocalTime.of(20, 0);
                break;

            case WEDNESDAY: // Miércoles: 10:00 - 15:00
                inicio = LocalTime.of(10, 0);
                fin = LocalTime.of(15, 0);
                break;

            case SATURDAY:  // Sábado: 09:00 - 14:00
                inicio = LocalTime.of(9, 0);
                fin = LocalTime.of(14, 0);
                break;
        }

        // Generamos los huecos cada 30 minutos
        if (inicio != null && fin != null) {
            LocalTime actual = inicio;
            while (actual.isBefore(fin)) {
                slots.add(actual);
                actual = actual.plusMinutes(30);
            }
        }

        return slots;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            pathInfo = "/Panel";
        }

        USUARIO usuarioLogueado = (USUARIO) request.getSession().getAttribute("usuarioLogueado");

        switch (pathInfo) {
            case "/Citas/Cancelar":
                cancelarCita(request, response, usuarioLogueado);
                break;

            case "/Citas/Crear":
                crearCitaCliente(request, response, usuarioLogueado);
                break;

            case "/Actualizar":
                actualizarPerfilCliente(request, response, usuarioLogueado);
                break;
            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                break;
        }
    }

    private void mostrarDashboard(HttpServletRequest request, HttpServletResponse response, USUARIO usuario)
            throws ServletException, IOException {

        CITA citaActiva = null;
        List<HISTORIAL_CITA> historialCitas = null;

        try {
            TypedQuery<CITA> citaQuery = em.createQuery(
                    "SELECT c FROM CITA c LEFT JOIN FETCH c.serviciosSet WHERE c.usuario.id = :usuarioId", CITA.class);
            citaQuery.setParameter("usuarioId", usuario.getId());
            citaActiva = citaQuery.getSingleResult();

            // --- ¡LÓGICA CORREGIDA! ---
            // Combinamos la fecha y la hora de la cita
            LocalDateTime fechaHoraCita = LocalDateTime.of(citaActiva.getFecha(), citaActiva.getHoraInicio());

            // Comparamos con la fecha Y hora actuales
            if (fechaHoraCita.isBefore(LocalDateTime.now())) {
                // La cita ya pasó (ej. son las 11:27, la cita era a las 11:26)
                System.out.println("LOG: Cita activa encontrada, pero ya expiró. Moviendo al historial...");

                try {
                    ut.begin();
                    // 1. "Guardar": Copiar a HISTORIAL_CITA
                    HISTORIAL_CITA archivo = new HISTORIAL_CITA(
                            citaActiva.getFecha(),
                            citaActiva.getHoraInicio(),
                            citaActiva.getUsuario(),
                            new HashSet<>(citaActiva.getServiciosSet())
                    );
                    em.persist(archivo);

                    // 2. "Borrar": Eliminar de CITA
                    em.remove(em.merge(citaActiva)); // Usamos merge() por seguridad
                    ut.commit();

                    // 3. Ponerla a null para que el JSP muestre "Pedir Cita"
                    citaActiva = null;

                } catch (Exception e_archivar) {
                    System.err.println("Error al archivar cita expirada: " + e_archivar.getMessage());
                    try {
                        ut.rollback();
                    } catch (Exception e_rb) {
                    }
                }
            }

        } catch (NoResultException e) {
            citaActiva = null; // No tiene cita, es normal
        } catch (Exception e) {
            System.err.println("Error al buscar cita activa: " + e.getMessage());
        }

        try {

            TypedQuery<HISTORIAL_CITA> historialQuery = em.createQuery(
                    "SELECT h FROM HISTORIAL_CITA h LEFT JOIN FETCH h.serviciosSet WHERE h.usuario.id = :usuarioId ORDER BY h.fecha DESC", HISTORIAL_CITA.class);
            historialQuery.setParameter("usuarioId", usuario.getId());
            historialCitas = historialQuery.getResultList();
        } catch (Exception e) {
            System.err.println("Error al buscar historial de citas: " + e.getMessage());
        }

        request.setAttribute("citaActiva", citaActiva);
        request.setAttribute("historialCitas", historialCitas);
        request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/USUARIO/Panel_Cliente.jsp").forward(request, response);
    }

    private void mostrarFormularioEditar(HttpServletRequest request, HttpServletResponse response, USUARIO usuario)
            throws ServletException, IOException {

        request.setAttribute("usuario", usuario);
        request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/USUARIO/perfil_Cliente.jsp").forward(request, response);
    }

    private void mostrarFormularioCitaCliente(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            TypedQuery<SERVICIO> consultaServicios = em.createQuery("SELECT s FROM SERVICIO s", SERVICIO.class);
            request.setAttribute("servicios", consultaServicios.getResultList());

            // CORREGIDO: Usar el nuevo nombre del método
            LocalDate hoy = LocalDate.now();
            List<String> horasOcupadas = obtenerHorasOcupadasParaFecha(hoy);
            request.setAttribute("horasOcupadas", horasOcupadas);

        } catch (Exception e) {
            request.setAttribute("error", "No se pudieron cargar los servicios o las horas.");
        }

        request.setAttribute("modo", "crearCliente");
        request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/USUARIO/formulario_cita_cliente.jsp").forward(request, response);
    }

    // En Panel_Cliente.java - REEMPLAZA el método obtenerHorasOcupadas(LocalDate) por este:
    private List<String> obtenerHorasOcupadasParaFecha(LocalDate fecha) {
        try {
            TypedQuery<LocalTime> query = em.createQuery(
                    "SELECT c.horaInicio FROM CITA c WHERE c.fecha = :fecha", LocalTime.class);
            query.setParameter("fecha", fecha);

            List<LocalTime> horas = query.getResultList();
            List<String> horasStr = new ArrayList<>();

            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("HH:mm");
            for (LocalTime h : horas) {
                horasStr.add(h.format(formatter));
            }
            return horasStr;
        } catch (Exception e) {
            System.err.println("Error al obtener horas ocupadas para fecha: " + e.getMessage());
            return new ArrayList<>();
        }
    }

    private void mostrarHistorial(HttpServletRequest request, HttpServletResponse response, USUARIO usuario)
            throws ServletException, IOException {

        try {
            TypedQuery<HISTORIAL_CITA> historialQuery = em.createQuery(
                    "SELECT h FROM HISTORIAL_CITA h LEFT JOIN FETCH h.serviciosSet WHERE h.usuario.id = :usuarioId ORDER BY h.fecha DESC", HISTORIAL_CITA.class);
            historialQuery.setParameter("usuarioId", usuario.getId());
            request.setAttribute("historialCitas", historialQuery.getResultList());
        } catch (Exception e) {
            System.err.println("Error al buscar historial de citas: " + e.getMessage());
        }
        request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/USUARIO/Historial_citas.jsp").forward(request, response);
    }

    // --- MÉTODOS POST ---
    private void cancelarCita(HttpServletRequest request, HttpServletResponse response, USUARIO usuario)
            throws ServletException, IOException {

        String idCitaStr = request.getParameter("idCita");
        Long idCita = Long.parseLong(idCitaStr);
        String error = null;
        String msg = null;

        try {
            ut.begin();
            CITA citaACancelar = em.find(CITA.class, idCita);

            if (citaACancelar == null || !citaACancelar.getUsuario().getId().equals(usuario.getId())) {
                error = "No se encontró la cita o no tienes permiso.";
            } else {
                em.remove(citaACancelar);
                ut.commit();
                msg = "Tu cita ha sido cancelada con éxito.";
            }
        } catch (Exception e) {
            error = "Error al cancelar la cita: " + e.getMessage();
            try {
                ut.rollback();
            } catch (Exception e2) {
            }
        }

        if (error != null) {
            request.getSession().setAttribute("errorMsg", error);
        }
        if (msg != null) {
            request.getSession().setAttribute("successMsg", msg);
        }

        response.sendRedirect(request.getContextPath() + "/Perfil/Panel");
    }

    private void actualizarPerfilCliente(HttpServletRequest request, HttpServletResponse response, USUARIO usuarioLogueado)
            throws ServletException, IOException {

        String error = null;

        try {
            String nombre = request.getParameter("NombreCompleto");
            String email = request.getParameter("Email");
            Long telefono = Long.parseLong(request.getParameter("Telefono"));
            String passwordPlana = request.getParameter("password");

            ut.begin();
            USUARIO usuario = em.find(USUARIO.class, usuarioLogueado.getId());
            usuario.setNombreCompleto(nombre);
            usuario.setEmail(email);
            usuario.setTelefono(telefono);

            if (passwordPlana != null && !passwordPlana.isEmpty()) {
                String hash = Contraseñas.hashPassword(passwordPlana);
                usuario.setPassword(hash);
            }
            ut.commit();
            request.getSession().setAttribute("usuarioLogueado", usuario); // ¡Importante!
        } catch (Exception e) {
            error = "Error al actualizar el perfil: " + e.getMessage();
            try {
                ut.rollback();
            } catch (Exception e2) {
            }
        }

        if (error != null) {
            request.setAttribute("error", error);
            request.setAttribute("usuario", usuarioLogueado);
            request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/USUARIO/perfil_Cliente.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/Perfil/Panel?msg=perfilActualizado");
        }
    }

    private void crearCitaCliente(HttpServletRequest request, HttpServletResponse response, USUARIO usuarioLogueado)
            throws ServletException, IOException {

        String error = null;
        boolean transactionCommitted = false;

        try {
            System.out.println("=== INICIANDO CREACIÓN DE CITA CLIENTE ===");

            // DEBUG: Mostrar todos los parámetros recibidos
            System.out.println("=== PARÁMETROS RECIBIDOS ===");
            java.util.Enumeration<String> paramNames = request.getParameterNames();
            while (paramNames.hasMoreElements()) {
                String paramName = paramNames.nextElement();
                String[] paramValues = request.getParameterValues(paramName);
                System.out.println(paramName + ": " + java.util.Arrays.toString(paramValues));
            }
            System.out.println("=== FIN PARÁMETROS ===");

            // 1. Recoger y validar parámetros
            LocalDate Fecha = null;
            LocalTime HoraInicio = null;
            String[] Ids_de_servicios = null;

            try {
                String fechaParam = request.getParameter("fecha");
                System.out.println("Fecha recibida: '" + fechaParam + "'");

                if (fechaParam == null || fechaParam.trim().isEmpty()) {
                    error = "La fecha es obligatoria";
                    throw new Exception(error);
                }

                Fecha = LocalDate.parse(fechaParam);

                // Validar que la fecha no sea pasada
                if (Fecha.isBefore(LocalDate.now())) {
                    error = "No se pueden agendar citas en fechas pasadas";
                    throw new Exception(error);
                }

            } catch (Exception e) {
                if (error == null) {
                    error = "Fecha no válida. Formato esperado: YYYY-MM-DD";
                }
                throw new Exception(error);
            }

            try {
                String horaParam = request.getParameter("horaInicio");
                System.out.println("Hora recibida: '" + horaParam + "'");

                if (horaParam == null || horaParam.trim().isEmpty()) {
                    error = "La hora es obligatoria";
                    throw new Exception(error);
                }

                HoraInicio = LocalTime.parse(horaParam);

                // Obtener horas laborales del día seleccionado
                List<LocalTime> horasDia = generarHorariosParaDia(Fecha);

                // Validar que la hora esté dentro del horario generado
                if (!horasDia.contains(HoraInicio)) {
                    error = "La hora seleccionada no es válida para el horario del día.";
                    throw new Exception(error);
                }

                // Validar horario laboral (9:00 - 13:00)
                /*if (HoraInicio.isBefore(LocalTime.of(10, 0))
                        || HoraInicio.isAfter(LocalTime.of(13, 0))) {
                    error = "El horario debe estar entre 09:00 y 13:00";
                    throw new Exception(error);
                }*/
            } catch (Exception e) {
                if (error == null) {
                    error = "Hora no válida. Formato esperado: HH:MM";
                }
                throw new Exception(error);
            }

            Ids_de_servicios = request.getParameterValues("serviciosIds");
            System.out.println("Servicios recibidos: " + (Ids_de_servicios != null ? java.util.Arrays.toString(Ids_de_servicios) : "NULL"));

            if (Ids_de_servicios == null || Ids_de_servicios.length == 0) {
                error = "Debe seleccionar al menos un servicio.";
                throw new Exception(error);
            }

            // --- NUEVA VALIDACIÓN DE DISPONIBILIDAD ---
            // 1. Consultar si ya existe una cita en esa fecha y hora
            TypedQuery<Long> checkQuery = em.createQuery(
                    "SELECT COUNT(c) FROM CITA c WHERE c.fecha = :fecha AND c.horaInicio = :hora", Long.class);
            checkQuery.setParameter("fecha", Fecha);
            checkQuery.setParameter("hora", HoraInicio);

            Long count = checkQuery.getSingleResult();

            if (count > 0) {
                // ¡Ya existe! Lanzamos nuestro propio error controlado
                throw new Exception("Lo sentimos, la hora " + HoraInicio + " del día " + Fecha + " ya está ocupada. Por favor, elige otra.");
            }
            // ------------------------------------------

            // 2. Iniciar transacción
            ut.begin();
            System.out.println("Transacción iniciada");

            // 3. Refrescar usuario desde BD (IMPORTANTE: dentro de la transacción)
            USUARIO usuario = em.find(USUARIO.class, usuarioLogueado.getId());
            if (usuario == null) {
                error = "Usuario no encontrado en la base de datos";
                throw new Exception(error);
            }
            System.out.println("Usuario cargado: " + usuario.getNombreCompleto());

            // 4. Verificar cita existente del usuario (para evitar múltiples citas)
            CITA cita_antigua = null;
            try {
                // Consulta más específica para evitar problemas de caché
                TypedQuery<CITA> query = em.createQuery(
                        "SELECT c FROM CITA c WHERE c.usuario.id = :usuarioId", CITA.class);
                query.setParameter("usuarioId", usuario.getId());
                cita_antigua = query.getSingleResult();
            } catch (NoResultException e) {
                cita_antigua = null;
            }

            System.out.println("Cita existente del usuario: " + (cita_antigua != null ? "SÍ (ID: " + cita_antigua.getId() + ")" : "NO"));

            if (cita_antigua != null) {
                LocalDateTime fechaHoraCitaAntigua = LocalDateTime.of(cita_antigua.getFecha(), cita_antigua.getHoraInicio());
                boolean estaExpirada = fechaHoraCitaAntigua.isBefore(LocalDateTime.now());

                System.out.println("Cita expirada: " + estaExpirada);

                if (estaExpirada) {
                    // Cita expirada, archivarla
                    System.out.println("Archivando cita expirada...");
                    HISTORIAL_CITA archivo = new HISTORIAL_CITA(
                            cita_antigua.getFecha(),
                            cita_antigua.getHoraInicio(),
                            cita_antigua.getUsuario(),
                            new HashSet<>(cita_antigua.getServiciosSet())
                    );
                    em.persist(archivo);
                    em.remove(em.merge(cita_antigua));
                    System.out.println("Cita antigua archivada y eliminada");
                } else {
                    // Cita activa, lanzar error
                    error = "Ya tienes una cita activa para el " + cita_antigua.getFecha() + " a las " + cita_antigua.getHoraInicio();
                    throw new Exception(error);
                }
            }

            // 5. Crear Set de servicios (asegurarse de que están managed)
            Set<SERVICIO> ServiciosParaCita = new HashSet<>();
            for (String idServicio : Ids_de_servicios) {
                try {
                    Long id = Long.parseLong(idServicio);
                    SERVICIO servicio = em.find(SERVICIO.class, id);
                    if (servicio != null) {
                        // Asegurarse de que el servicio esté managed
                        SERVICIO managedServicio = em.merge(servicio);
                        ServiciosParaCita.add(managedServicio);
                        System.out.println("Servicio añadido: " + managedServicio.getNombreServicio());
                    } else {
                        System.out.println("Servicio no encontrado ID: " + id);
                    }
                } catch (NumberFormatException e) {
                    System.err.println("ID de servicio no válido: " + idServicio);
                }
            }

            if (ServiciosParaCita.isEmpty()) {
                error = "No se pudieron encontrar los servicios seleccionados.";
                throw new Exception(error);
            }

            // 6. Crear nueva cita
            System.out.println("Creando nueva cita...");
            CITA NuevaCita = new CITA(Fecha, HoraInicio, usuario);

            // Establecer la relación bidireccional
            NuevaCita.setServiciosSet(ServiciosParaCita);

            // Persistir la cita
            em.persist(NuevaCita);

            // Actualizar la relación en el usuario
            usuario.setCita(NuevaCita);

            // 7. Commit - ¡IMPORTANTE!
            ut.commit();
            transactionCommitted = true;
            System.out.println("=== CITA CLIENTE CREADA EXITOSAMENTE ===");
            System.out.println("Nueva cita ID: " + NuevaCita.getId());

            // Verificar que la cita se guardó
            CITA citaVerificada = em.find(CITA.class, NuevaCita.getId());
            if (citaVerificada != null) {
                System.out.println("Cita verificada en BD - ID: " + citaVerificada.getId());
            } else {
                System.out.println("ERROR: La cita no se encontró después de persistir");
            }

        } catch (Exception e) {
            System.err.println("=== ERROR EN CREAR CITA CLIENTE ===");
            System.err.println("Mensaje: " + e.getMessage());
            System.err.println("Causa: " + e.getCause());
            e.printStackTrace();

            if (error == null) {
                error = "Error al crear la cita: " + e.getMessage();
            }

            try {
                if (ut.getStatus() == jakarta.transaction.Status.STATUS_ACTIVE) {
                    System.err.println("Haciendo rollback...");
                    ut.rollback();
                }
            } catch (Exception e2) {
                System.err.println("Error en rollback: " + e2.getMessage());
            }
        }

        // 8. Manejar resultado
        if (error != null || !transactionCommitted) {
            System.out.println("Mostrando formulario con error: " + error);
            try {
                // Recargar servicios y mostrar formulario con error
                TypedQuery<SERVICIO> consultaServicios = em.createQuery("SELECT s FROM SERVICIO s", SERVICIO.class);
                request.setAttribute("servicios", consultaServicios.getResultList());
                request.setAttribute("error", error != null ? error : "Error desconocido al crear la cita");

                request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/USUARIO/formulario_cita_cliente.jsp").forward(request, response);
            } catch (Exception e) {
                System.err.println("Error al recargar servicios: " + e.getMessage());
                response.sendRedirect(request.getContextPath() + "/Perfil/Panel?error=" + java.net.URLEncoder.encode(error != null ? error : "Error desconocido", "UTF-8"));
            }
        } else {
            System.out.println("Cita creada exitosamente - Redirigiendo al panel");
            response.sendRedirect(request.getContextPath() + "/Perfil/Panel?msg=CitaCreada");
        }
    }

    // Método temporal para verificar citas en la base de datos
    private void verificarCitasEnBD() {
        try {
            TypedQuery<CITA> query = em.createQuery("SELECT c FROM CITA c", CITA.class);
            List<CITA> todasLasCitas = query.getResultList();
            System.out.println("=== CITAS EN LA BASE DE DATOS ===");
            for (CITA cita : todasLasCitas) {
                System.out.println("Cita ID: " + cita.getId()
                        + ", Fecha: " + cita.getFecha()
                        + ", Hora: " + cita.getHoraInicio()
                        + ", Usuario: " + cita.getUsuario().getNombreCompleto());
            }
            System.out.println("Total citas: " + todasLasCitas.size());
        } catch (Exception e) {
            System.err.println("Error al verificar citas: " + e.getMessage());
        }
    }

}
