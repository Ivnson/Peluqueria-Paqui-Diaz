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
import jakarta.persistence.TypedQuery;
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

    // MÉTODO DOGET: MANEJA LAS PETICIONES DE SOLO LECTURA (NAVEGACIÓN)
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // OBTENEMOS LA PARTE DE LA URL DESPUÉS DE "/PERFIL" PARA SABER QUÉ ACCIÓN REALIZAR
        String pathInfo = request.getPathInfo();

        // SI NO HAY RUTA ESPECÍFICA, REDIRIGIMOS AL PANEL PRINCIPAL POR DEFECTO
        if (pathInfo == null || pathInfo.equals("/")) {
            pathInfo = "/Panel";
        }

        USUARIO usuarioLogueado = (USUARIO) request.getSession().getAttribute("usuarioLogueado");

        // EVALUAMOS LA RUTA SOLICITADA 
        switch (pathInfo) {
            case "/Panel":
                // MUESTRA LA PÁGINA PRINCIPAL DEL CLIENTE CON SUS CITAS
                mostrarDashboard(request, response, usuarioLogueado);
                break;
            case "/Editar":
                // MUESTRA EL FORMULARIO PARA EDITAR DATOS PERSONALES
                mostrarFormularioEditar(request, response, usuarioLogueado);
                break;

            case "/Citas/Nueva":
                // MUESTRA EL FORMULARIO PARA CREAR UNA NUEVA CITA
                mostrarFormularioCitaCliente(request, response);
                break;

            case "/Citas/Historial":
                // MUESTRA EL LISTADO DE CITAS PASADAS
                mostrarHistorial(request, response, usuarioLogueado);
                break;

            case "/HorasOcupadas":
                // ESTA RUTA ES LLAMADA POR JAVASCRIPT (AJAX) PARA OBTENER HORAS OCUPADAS EN FORMATO JSON
                obtenerHorasOcupadas(request, response);
                break;

            default:
                // SI LA RUTA NO EXISTE, DEVUELVE UN ERROR 404
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                break;
        }
    }

    // MÉTODO PARA GENERAR UN JSON CON LAS HORAS DISPONIBLES Y OCUPADAS DE UN DÍA ESPECÍFICO
    private void obtenerHorasOcupadas(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // CONFIGURAMOS LA RESPUESTA COMO JSON
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            // RECIBIMOS LA FECHA SELECCIONADA POR EL CLIENTE
            String fechaParam = request.getParameter("fecha");

            if (fechaParam == null || fechaParam.isEmpty()) {
                // SI NO HAY FECHA, DEVUELVE ARRAY VACÍO
                response.getWriter().write("[]");
                return;
            }

            LocalDate fecha = LocalDate.parse(fechaParam);

            // 1. GENERAR TODOS LOS HUECOS POSIBLES SEGÚN EL HORARIO DE APERTURA DEL DÍA
            List<LocalTime> slotsPosibles = generarHorariosParaDia(fecha);

            // 2. CONSULTAR EN LA BASE DE DATOS QUÉ HORAS YA TIENEN CITA ESE DÍA
            List<String> horasOcupadasStr = new ArrayList<>();
            try {
                TypedQuery<LocalTime> query = em.createQuery(
                        "SELECT c.horaInicio FROM CITA c WHERE c.fecha = :fecha", LocalTime.class);
                query.setParameter("fecha", fecha);

                List<LocalTime> resultadosBD = query.getResultList();

                // FORMATEAMOS LAS HORAS DE LA BD A STRING (EJ: "10:30")
                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("HH:mm");
                for (LocalTime horaBD : resultadosBD) {
                    horasOcupadasStr.add(horaBD.format(formatter));
                }
            } catch (Exception e) {
                System.err.println("Error consultando BD: " + e.getMessage());
            }

            // 3. CONSTRUIR MANUALMENTE EL STRING JSON COMBINANDO SLOTS Y ESTADO
            StringBuilder json = new StringBuilder("[");
            DateTimeFormatter jsonFormatter = DateTimeFormatter.ofPattern("HH:mm");

            for (int i = 0; i < slotsPosibles.size(); i++) {
                LocalTime slot = slotsPosibles.get(i);
                String horaSlotStr = slot.format(jsonFormatter);

                // DETERMINAMOS SI EL SLOT ESTÁ EN LA LISTA DE HORAS OCUPADAS
                boolean estaOcupada = horasOcupadasStr.contains(horaSlotStr);
                String estado = estaOcupada ? "ocupada" : "libre";

                // AGREGAMOS EL OBJETO JSON AL ARRAY: {"hora": "10:00", "estado": "libre"}
                json.append(String.format("{\"hora\": \"%s\", \"estado\": \"%s\"}", horaSlotStr, estado));

                // AÑADIMOS COMA SI NO ES EL ÚLTIMO ELEMENTO
                if (i < slotsPosibles.size() - 1) {
                    json.append(",");
                }
            }
            json.append("]");

            // ENVIAMOS EL JSON AL NAVEGADOR
            response.getWriter().write(json.toString());

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("[]");
        }
    }

    // MÉTODO AUXILIAR QUE DEFINE LA LÓGICA DE NEGOCIO DE LOS HORARIOS DE APERTURA
    private List<LocalTime> generarHorariosParaDia(LocalDate fecha) {
        List<LocalTime> slots = new ArrayList<>();
        java.time.DayOfWeek diaSemana = fecha.getDayOfWeek();

        LocalTime inicio = null;
        LocalTime fin = null;

        // DEFINIMOS HORARIO DE APERTURA Y CIERRE SEGÚN EL DÍA DE LA SEMANA
        switch (diaSemana) {
            case MONDAY:
            case SUNDAY:
                return slots; // LUNES Y DOMINGO CERRADO (LISTA VACÍA)

            case TUESDAY:
            case THURSDAY:
            case FRIDAY:
                inicio = LocalTime.of(10, 0); // DE 10:00 A 20:00
                fin = LocalTime.of(20, 0);
                break;

            case WEDNESDAY: // MIÉRCOLES HASTA LAS 15:00
                inicio = LocalTime.of(10, 0);
                fin = LocalTime.of(15, 0);
                break;

            case SATURDAY:  // SÁBADOS DE 09:00 A 14:00
                inicio = LocalTime.of(9, 0);
                fin = LocalTime.of(14, 0);
                break;
        }

        // SI HAY HORARIO DEFINIDO, CREAMOS HUECOS CADA 30 MINUTOS
        if (inicio != null && fin != null) {
            LocalTime actual = inicio;
            while (actual.isBefore(fin)) {
                slots.add(actual);
                actual = actual.plusMinutes(30);// INCREMENTO DE 30 MINUTOS
            }
        }

        return slots;
    }

    // MÉTODO DOPOST: MANEJA EL ENVÍO DE FORMULARIOS Y ACCIONES QUE MODIFICAN DATOS
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            pathInfo = "/Panel";
        }

        USUARIO usuarioLogueado = (USUARIO) request.getSession().getAttribute("usuarioLogueado");

        // ROUTER PARA PETICIONES POST
        switch (pathInfo) {
            case "/Citas/Cancelar":
                // LÓGICA PARA CANCELAR UNA CITA EXISTENTE
                cancelarCita(request, response, usuarioLogueado);
                break;

            case "/Citas/Crear":
                // LÓGICA PARA REGISTRAR UNA NUEVA CITA
                crearCitaCliente(request, response, usuarioLogueado);
                break;

            case "/Actualizar":
                // LÓGICA PARA ACTUALIZAR DATOS DEL PERFIL
                actualizarPerfilCliente(request, response, usuarioLogueado);
                break;
            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                break;
        }
    }

    // MUESTRA EL DASHBOARD PRINCIPAL Y GESTIONA EL ARCHIVADO DE CITAS PASADAS
    private void mostrarDashboard(HttpServletRequest request, HttpServletResponse response, USUARIO usuario)
            throws ServletException, IOException {

        CITA citaActiva = null;
        List<HISTORIAL_CITA> historialCitas = null;

        try {
            // BUSCAMOS TODAS LAS CITAS ACTIVAS DEL USUARIO ORDENADAS POR FECHA
            TypedQuery<CITA> citaQuery = em.createQuery(
                    "SELECT c FROM CITA c LEFT JOIN FETCH c.serviciosSet WHERE c.usuario.id = :usuarioId ORDER BY c.fecha ASC, c.horaInicio ASC", CITA.class);
            citaQuery.setParameter("usuarioId", usuario.getId());
            List<CITA> citasUsuario = citaQuery.getResultList();

            // RECORREMOS LAS CITAS PARA VERIFICAR SI ALGUNA YA HA PASADO (EXPIRADO)
            for (CITA cita : citasUsuario) {
                LocalDateTime fechaHoraCita = LocalDateTime.of(cita.getFecha(), cita.getHoraInicio());

                // SI LA FECHA DE LA CITA ES ANTERIOR A "AHORA MISMO"
                if (fechaHoraCita.isBefore(LocalDateTime.now())) {

                    System.out.println("LOG: Cita ID " + cita.getId() + " expirada. Moviendo al historial...");

                    try {
                        // INICIAMOS TRANSACCIÓN PARA MOVER LA CITA A LA TABLA HISTORIAL
                        ut.begin();

                        // 1. CREAR OBJETO HISTORIAL_CITA CON LOS DATOS DE LA CITA
                        HISTORIAL_CITA archivo = new HISTORIAL_CITA(
                                cita.getFecha(),
                                cita.getHoraInicio(),
                                cita.getUsuario(),
                                new HashSet<>(cita.getServiciosSet()) // COPIAMOS LOS SERVICIOS
                        );
                        em.persist(archivo);// GUARDAMOS EN HISTORIAL

                        // 2. ELIMINAR DE LA TABLA DE CITAS ACTIVAS
                        em.remove(em.merge(cita));
                        ut.commit();// CONFIRMAMOS CAMBIOS

                    } catch (Exception e_archivar) {
                        // SI FALLA, HACEMOS ROLLBACK PARA NO DEJAR DATOS INCONSISTENTES
                        System.err.println("Error al archivar cita expirada: " + e_archivar.getMessage());
                        try {
                            ut.rollback();
                        } catch (Exception e_rb) {
                        }
                    }
                } else {
                    // SI LA CITA ES FUTURA, LA CONSIDERAMOS LA "CITA ACTIVA" (SOLO MOSTRAMOS LA PRÓXIMA)
                    if (citaActiva == null) {
                        citaActiva = cita;
                    }
                }
            }

        } catch (Exception e) {
            System.err.println("Error al buscar cita activa: " + e.getMessage());
        }

        // CARGAMOS EL HISTORIAL DE CITAS PASADAS PARA MOSTRARLO
        try {
            TypedQuery<HISTORIAL_CITA> historialQuery = em.createQuery(
                    "SELECT h FROM HISTORIAL_CITA h LEFT JOIN FETCH h.serviciosSet WHERE h.usuario.id = :usuarioId ORDER BY h.fecha DESC", HISTORIAL_CITA.class);
            historialQuery.setParameter("usuarioId", usuario.getId());
            historialCitas = historialQuery.getResultList();
        } catch (Exception e) {
            System.err.println("Error al buscar historial de citas: " + e.getMessage());
        }

        // ENVIAMOS LOS DATOS A LA VISTA JSP
        request.setAttribute("citaActiva", citaActiva);
        request.setAttribute("historialCitas", historialCitas);
        request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/USUARIO/Panel_Cliente.jsp").forward(request, response);
    }

    // PREPARA Y MUESTRA EL FORMULARIO DE EDICIÓN DE PERFIL
    private void mostrarFormularioEditar(HttpServletRequest request, HttpServletResponse response, USUARIO usuario)
            throws ServletException, IOException {

        request.setAttribute("usuario", usuario);
        request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/USUARIO/perfil_Cliente.jsp").forward(request, response);
    }

    // PREPARA Y MUESTRA EL FORMULARIO PARA PEDIR CITA (CARGA SERVICIOS Y HORAS)
    private void mostrarFormularioCitaCliente(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // CARGAMOS TODOS LOS SERVICIOS DISPONIBLES EN LA PELUQUERÍA
            TypedQuery<SERVICIO> consultaServicios = em.createQuery("SELECT s FROM SERVICIO s", SERVICIO.class);
            request.setAttribute("servicios", consultaServicios.getResultList());

            // POR DEFECTO, CARGAMOS LAS HORAS OCUPADAS DE "HOY" PARA LA VISTA INICIAL
            LocalDate hoy = LocalDate.now();
            List<String> horasOcupadas = obtenerHorasOcupadasParaFecha(hoy);
            request.setAttribute("horasOcupadas", horasOcupadas);

        } catch (Exception e) {
            request.setAttribute("error", "No se pudieron cargar los servicios o las horas.");
        }

        request.setAttribute("modo", "crearCliente");
        request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/USUARIO/formulario_cita_cliente.jsp").forward(request, response);
    }

    // MÉTODO AUXILIAR PARA OBTENER HORAS OCUPADAS EN FORMATO LISTA DE STRINGS
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

    // MUESTRA LA VISTA DEDICADA AL HISTORIAL COMPLETO
    private void mostrarHistorial(HttpServletRequest request, HttpServletResponse response, USUARIO usuario)
            throws ServletException, IOException {

        try {

            // CONSULTA JPQL PARA OBTENER EL HISTORIAL ORDENADO POR FECHA DESCENDENTE
            TypedQuery<HISTORIAL_CITA> historialQuery = em.createQuery(
                    "SELECT h FROM HISTORIAL_CITA h LEFT JOIN FETCH h.serviciosSet WHERE h.usuario.id = :usuarioId ORDER BY h.fecha DESC", HISTORIAL_CITA.class);
            historialQuery.setParameter("usuarioId", usuario.getId());
            request.setAttribute("historialCitas", historialQuery.getResultList());
        } catch (Exception e) {
            System.err.println("Error al buscar historial de citas: " + e.getMessage());
        }
        request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/USUARIO/Historial_citas.jsp").forward(request, response);
    }

    // ACCIÓN PARA CANCELAR UNA CITA
    private void cancelarCita(HttpServletRequest request, HttpServletResponse response, USUARIO usuario)
            throws ServletException, IOException {

        String idCitaStr = request.getParameter("idCita");
        Long idCita = Long.parseLong(idCitaStr);
        String error = null;
        String msg = null;

        try {
            // INICIAMOS TRANSACCIÓN PARA BORRAR
            ut.begin();
            // BUSCAMOS LA CITA POR ID
            CITA citaACancelar = em.find(CITA.class, idCita);

            USUARIO user = citaACancelar.getUsuario();

            // VERIFICAMOS QUE LA CITA EXISTA Y QUE PERTENEZCA AL USUARIO LOGUEADO 
            if (citaACancelar == null || !user.getId().equals(usuario.getId())) {
                error = "No se encontró la cita o no tienes permiso.";
            } else {
                // SI TODO ES CORRECTO, LA ELIMINAMOS
                em.remove(citaACancelar);
                ut.commit(); // CONFIRMAMOS EL BORRADO EN LA BD
                msg = "Tu cita ha sido cancelada con éxito.";
            }
        } catch (Exception e) {
            // SI FALLA, HACEMOS ROLLBACK Y CAPTURAMOS EL ERROR
            error = "Error al cancelar la cita: " + e.getMessage();
            try {
                ut.rollback();
            } catch (Exception e2) {
            }
        }

        // GUARDAMOS MENSAJES EN SESIÓN PARA MOSTRARLOS TRAS LA REDIRECCIÓN
        if (error != null) {
            request.getSession().setAttribute("errorMsg", error);
        }
        if (msg != null) {
            request.getSession().setAttribute("successMsg", msg);
        }

        // REDIRIGIMOS AL PANEL
        response.sendRedirect(request.getContextPath() + "/Perfil/Panel");
    }

    // ACCIÓN PARA ACTUALIZAR DATOS DEL PERFIL
    private void actualizarPerfilCliente(HttpServletRequest request, HttpServletResponse response, USUARIO usuarioLogueado)
            throws ServletException, IOException {

        String error = null;

        try {
            // RECOGEMOS DATOS DEL FORMULARIO
            String nombre = request.getParameter("NombreCompleto");
            String email = request.getParameter("Email");
            Long telefono = Long.parseLong(request.getParameter("Telefono"));
            String passwordPlana = request.getParameter("password");

            ut.begin();
            // BUSCAMOS AL USUARIO EN LA BD PARA ASEGURARNOS QUE ESTÁ
            USUARIO usuario = em.find(USUARIO.class, usuarioLogueado.getId());

            // ACTUALIZAMOS LOS CAMPOS
            usuario.setNombreCompleto(nombre);
            usuario.setEmail(email);
            usuario.setTelefono(telefono);

            // SOLO ACTUALIZAMOS LA CONTRASEÑA SI EL CAMPO NO ESTÁ VACÍO
            if (passwordPlana != null && !passwordPlana.isEmpty()) {
                // HASHEAMOS LA NUEVA CONTRASEÑA ANTES DE GUARDARLA
                String hash = Contraseñas.hashPassword(passwordPlana);
                usuario.setPassword(hash);
            }
            ut.commit();

            // ACTUALIZAMOS EL USUARIO EN LA SESIÓN PARA QUE LOS CAMBIOS SE REFLEJEN INMEDIATAMENTE
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

    // LÓGICA PRINCIPAL: CREACIÓN DE UNA CITA NUEVA
    private void crearCitaCliente(HttpServletRequest request, HttpServletResponse response, USUARIO usuarioLogueado)
            throws ServletException, IOException {

        String error = null;
        boolean transactionCommitted = false;

        try {
            System.out.println("=== INICIANDO CREACIÓN DE CITA CLIENTE ===");

            /*System.out.println("=== PARÁMETROS RECIBIDOS ===");
            java.util.Enumeration<String> paramNames = request.getParameterNames();
            while (paramNames.hasMoreElements()) {
                String paramName = paramNames.nextElement();
                String[] paramValues = request.getParameterValues(paramName);
                System.out.println(paramName + ": " + java.util.Arrays.toString(paramValues));
            }
            System.out.println("=== FIN PARÁMETROS ===");*/
            // 1. RECOGER Y VALIDAR PARÁMETROS BÁSICOS
            LocalDate Fecha = null;
            LocalTime HoraInicio = null;
            String[] Ids_de_servicios = null;

            try {
                // VALIDACIÓN DE LA FECHA
                String fechaParam = request.getParameter("fecha");
                System.out.println("Fecha recibida: '" + fechaParam + "'");

                if (fechaParam == null || fechaParam.trim().isEmpty()) {
                    error = "La fecha es obligatoria";
                    throw new Exception(error);
                }

                Fecha = LocalDate.parse(fechaParam);

                // VALIDAR QUE LA FECHA NO SEA PASADA
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
                // VALIDACIÓN DE LA HORA
                String horaParam = request.getParameter("horaInicio");
                System.out.println("Hora recibida: '" + horaParam + "'");

                if (horaParam == null || horaParam.trim().isEmpty()) {
                    error = "La hora es obligatoria";
                    throw new Exception(error);
                }

                HoraInicio = LocalTime.parse(horaParam);

                // VERIFICAR QUE LA HORA ESTÁ DENTRO DEL HORARIO DE APERTURA DE ESE DÍA
                List<LocalTime> horasDia = generarHorariosParaDia(Fecha);

                // VALIDAR QUE LA HORA ESTE DENTRO DEL HORARIO ESTABLECIDO
                if (!horasDia.contains(HoraInicio)) {
                    error = "La hora seleccionada no es válida para el horario del día.";
                    throw new Exception(error);
                }

            } catch (Exception e) {
                if (error == null) {
                    error = "Hora no válida. Formato esperado: HH:MM";
                }
                throw new Exception(error);
            }

            // RECOGER SERVICIOS SELECCIONADOS (CHECKBOXES)
            Ids_de_servicios = request.getParameterValues("serviciosIds");
            System.out.println("Servicios recibidos: " + (Ids_de_servicios != null ? java.util.Arrays.toString(Ids_de_servicios) : "NULL"));

            if (Ids_de_servicios == null || Ids_de_servicios.length == 0) {
                error = "Debe seleccionar al menos un servicio.";
                throw new Exception(error);
            }

            // --- NUEVA VALIDACIÓN DE DISPONIBILIDAD ---
            // CONSULTAMOS SI YA EXISTE ALGUIEN CON ESA FECHA Y HORA EXACTA
            TypedQuery<Long> checkQuery = em.createQuery(
                    "SELECT COUNT(c) FROM CITA c WHERE c.fecha = :fecha AND c.horaInicio = :hora", Long.class);
            checkQuery.setParameter("fecha", Fecha);
            checkQuery.setParameter("hora", HoraInicio);

            Long count = checkQuery.getSingleResult();

            if (count > 0) {
                // YA EXISTE --> LANZAMOS ERROR 
                throw new Exception("Lo sentimos, la hora " + HoraInicio + " del día " + Fecha + " ya está ocupada. Por favor, elige otra.");
            }
            // ------------------------------------------

            // 2. INICIAR TRANSACCIÓN (TODO LO QUE SIGUE SE HACE DE FORMA ATÓMICA)
            ut.begin();
            System.out.println("Transacción iniciada");

            // 3. REFRESCAR USUARIO DESDE BD
            USUARIO usuario = em.find(USUARIO.class, usuarioLogueado.getId());
            if (usuario == null) {
                error = "Usuario no encontrado en la base de datos";
                throw new Exception(error);
            }
            System.out.println("Usuario cargado: " + usuario.getNombreCompleto());

            // 4. VERIFICAR SI EL USUARIO YA TIENE UNA CITA ACTIVA (REGLA DE NEGOCIO: SOLO 1 CITA A LA VEZ)
            CITA cita_antigua = null;
            try {

                TypedQuery<CITA> query = em.createQuery(
                        "SELECT c FROM CITA c WHERE c.usuario.id = :usuarioId", CITA.class);
                query.setParameter("usuarioId", usuario.getId());
                cita_antigua = query.getSingleResult();
            } catch (NoResultException e) {
                cita_antigua = null;
            }

            System.out.println("Cita existente del usuario: " + (cita_antigua != null ? "SÍ (ID: " + cita_antigua.getId() + ")" : "NO"));

            // SI TIENE CITA, VEMOS SI ES VIEJA (EXPIRADA) O FUTURA
            if (cita_antigua != null) {

                LocalDateTime fechaHoraCitaAntigua = LocalDateTime.of(cita_antigua.getFecha(), cita_antigua.getHoraInicio());
                boolean estaExpirada = fechaHoraCitaAntigua.isBefore(LocalDateTime.now());

                System.out.println("Cita expirada: " + estaExpirada);

                if (estaExpirada) {
                    // SI ES VIEJA, LA MOVEMOS AL HISTORIAL AUTOMÁTICAMENTE PARA DEJAR SITIO A LA NUEVA
                    System.out.println("Archivando cita expirada...");
                    HISTORIAL_CITA archivo = new HISTORIAL_CITA(
                            cita_antigua.getFecha(),
                            cita_antigua.getHoraInicio(),
                            cita_antigua.getUsuario(),
                            new HashSet<>(cita_antigua.getServiciosSet())
                    );
                    em.persist(archivo);
                    em.remove(em.merge(cita_antigua));// BORRAMOS LA VIEJA
                    System.out.println("Cita antigua archivada y eliminada");
                } else {
                    // SI TIENE UNA CITA FUTURA, IMPEDIMOS CREAR OTRA
                    error = "Ya tienes una cita activa para el " + cita_antigua.getFecha() + " a las " + cita_antigua.getHoraInicio();
                    throw new Exception(error);
                }
            }

            // 5. RECUPERAR LOS OBJETOS SERVICIO DE LA BD BASADO EN LOS IDS SELECCIONADOS
            Set<SERVICIO> ServiciosParaCita = new HashSet<>();
            for (String idServicio : Ids_de_servicios) {
                try {
                    Long id = Long.parseLong(idServicio);
                    SERVICIO servicio = em.find(SERVICIO.class, id);
                    if (servicio != null) {

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

            // 6. CREAR Y GUARDAR LA NUEVA CITA
            System.out.println("Creando nueva cita...");
            CITA NuevaCita = new CITA(Fecha, HoraInicio, usuario);

            // ASIGNAMOS LOS SERVICIOS
            NuevaCita.setServiciosSet(ServiciosParaCita);

            em.persist(NuevaCita); // GUARDAMOS EN BD

            usuario.setCita(NuevaCita); // ACTUALIZAMOS LA RELACIÓN EN EL USUARIO

            // 7. CONFIRMAR TRANSACCIÓN
            ut.commit();
            transactionCommitted = true;
            System.out.println("=== CITA CLIENTE CREADA EXITOSAMENTE ===");
            System.out.println("Nueva cita ID: " + NuevaCita.getId());

            //VERIFICAR QUE LA CITA SE GUARDO
            CITA citaVerificada = em.find(CITA.class, NuevaCita.getId());
            if (citaVerificada != null) {
                System.out.println("Cita verificada en BD - ID: " + citaVerificada.getId());
            } else {
                System.out.println("ERROR: La cita no se encontró después de persistir");
            }

        } catch (Exception e) {
            // MANEJO DE ERRORES Y ROLLBACK
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

        // 8. REDIRECCIÓN O VUELTA AL FORMULARIO
        if (error != null || !transactionCommitted) {
            System.out.println("Mostrando formulario con error: " + error);
            try {
                //RECARGAR SERVICIOS Y MOSTRAR EL FORMULARIO CON UN ERROR
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

    
}
