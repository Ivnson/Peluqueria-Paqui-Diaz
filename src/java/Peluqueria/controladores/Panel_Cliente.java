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
import java.util.HashSet;
import java.util.List;
import java.util.Set;

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
            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                break;
        }
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
            request.setAttribute("servicios", consultaServicios.getResultList()); // (Tu JSP espera "servicios" [cite: 142])
        } catch (Exception e) {
            request.setAttribute("error", "No se pudieron cargar los servicios.");
        }

        request.setAttribute("modo", "crearCliente");
      
        request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/USUARIO/formulario_cita_cliente.jsp").forward(request, response);
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

        try {
            System.out.println("=== INICIANDO CREACIÓN DE CITA CLIENTE ===");

            // 1. Recoger y validar parámetros con debugging
            LocalDate Fecha = null;
            LocalTime HoraInicio = null;
            String[] Ids_de_servicios = null;

            try {
                String fechaParam = request.getParameter("fecha");
                System.out.println("Fecha recibida: '" + fechaParam + "'");
                Fecha = LocalDate.parse(fechaParam);
            } catch (Exception e) {
                error = "Fecha no válida. Formato esperado: YYYY-MM-DD";
                throw new Exception(error);
            }

            try {
                String horaParam = request.getParameter("HoraInicio");
                System.out.println("Hora recibida: '" + horaParam + "'");
                HoraInicio = LocalTime.parse(horaParam);
            } catch (Exception e) {
                error = "Hora no válida. Formato esperado: HH:MM";
                throw new Exception(error);
            }

            Ids_de_servicios = request.getParameterValues("serviciosIds");
            System.out.println("Servicios recibidos: " + (Ids_de_servicios != null ? java.util.Arrays.toString(Ids_de_servicios) : "NULL"));

            if (Ids_de_servicios == null || Ids_de_servicios.length == 0) {
                error = "Debe seleccionar al menos un servicio.";
                throw new Exception(error);
            }

            // 2. Iniciar transacción
            ut.begin();
            System.out.println("Transacción iniciada");

            // 3. Refrescar usuario desde BD
            USUARIO usuario = em.find(USUARIO.class, usuarioLogueado.getId());
            System.out.println("Usuario cargado: " + usuario.getNombreCompleto());

            // 4. Verificar cita existente
            CITA cita_antigua = usuario.getCita();
            System.out.println("Cita existente: " + (cita_antigua != null ? "SÍ (ID: " + cita_antigua.getId() + ")" : "NO"));

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

            // 5. Crear Set de servicios
            Set<SERVICIO> ServiciosParaCita = new HashSet<>();
            for (String idServicio : Ids_de_servicios) {
                try {
                    Long id = Long.parseLong(idServicio);
                    SERVICIO servicio = em.find(SERVICIO.class, id);
                    if (servicio != null) {
                        ServiciosParaCita.add(servicio);
                        System.out.println("Servicio añadido: " + servicio.getNombreServicio());
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
            NuevaCita.setServiciosSet(ServiciosParaCita);
            em.persist(NuevaCita);

            // 7. Commit
            ut.commit();
            System.out.println("=== CITA CLIENTE CREADA EXITOSAMENTE ===");

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
        if (error != null) {
            // Recargar servicios y mostrar formulario con error
            try {
                Query consultaServicios = em.createNativeQuery("SELECT * FROM SERVICIO", SERVICIO.class);
                request.setAttribute("servicios", consultaServicios.getResultList());
                request.setAttribute("error", error);
                request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/CLIENTE/formulario_cita_cliente.jsp").forward(request, response);
            } catch (Exception e) {
                System.err.println("Error al recargar servicios: " + e.getMessage());
                response.sendRedirect(request.getContextPath() + "/Perfil/Panel?error=" + java.net.URLEncoder.encode(error, "UTF-8"));
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/Perfil/Panel?msg=CitaCreada");
        }
    }

}
