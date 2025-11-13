/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package Peluqueria.controladores;

import Peluqueria.modelo.CITA;
import Peluqueria.modelo.SERVICIO;
import Peluqueria.modelo.USUARIO;
import jakarta.annotation.Resource;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.Query;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.transaction.UserTransaction;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 *
 * @author ivan
 */
@WebServlet(name = "ControladorCitas", urlPatterns = {"/Admin/Citas/*"})
public class ControladorCitas extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @PersistenceContext(unitName = "PeluqueriaPaquiPU")
    private EntityManager em;//GESTOR DE ENTIDADES

    @Resource
    private UserTransaction transaccion; //GESTIONAR TRANSACCIONES

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();

        if (pathInfo == null || pathInfo.equals("/")) {
            pathInfo = "/Listar";
        }

        switch (pathInfo) {
            case "/Listar": {

                ListarCitas(request, response);
            }
            break;

            case "/Nuevo": {
                MostrarFormularioVacio(request, response);
            }
            break;

            case "/Editar": {
                MostrarFormularioEditar(request, response);
            }
            break;
            default:
                response.sendError(404, "PAGINA NO ENCONTRADA");
        }
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();

        switch (pathInfo) {
            case "/Crear": {

                CrearCita(request, response);
            }
            break;

            case "/Actualizar": {
                ActualizarCita(request, response);
            }
            break;

            case "/Eliminar": {
                EliminarCita(request, response);
            }
            break;
            default:
                response.sendError(404, "PAGINA NO ENCONTRADA");

        }

    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

    private void ListarCitas(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        List<CITA> citas = new ArrayList();

        // "SELECT c FROM CITA c" -> Selecciona todas las entidades CITA.
        // "LEFT JOIN FETCH c.usuario" -> En la misma consulta, trae el objeto USUARIO.
        // "LEFT JOIN FETCH c.serviciosSet" -> En la misma consulta, trae el Set de SERVICIOS.
        Query consulta = em.createQuery(
                "SELECT DISTINCT c FROM CITA c LEFT JOIN FETCH c.usuario LEFT JOIN FETCH c.serviciosSet", CITA.class);

        citas = consulta.getResultList();

        if (citas != null) {
            System.out.println(" LOG --> MOSTRANDO LAS CITAS");
            request.setAttribute("listaCitas", citas);

            request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/ADMIN/admin_citas.jsp").forward(request, response);
        }
    }

    private void MostrarFormularioVacio(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        //CONSULTA PARA OBTENER LOS SERVICIOS 
        Query consulta1 = em.createNativeQuery(
                "SELECT * FROM SERVICIO", SERVICIO.class);

        List<SERVICIO> servicios = consulta1.getResultList();

        //CONSULTA PARA TRAER A TODOS LOS CLIENTES CON ROL Cliente
        Query consulta2 = em.createNativeQuery(
                "SELECT * FROM USUARIOS", USUARIO.class);
        //consulta2.setParameter(1, "Cliente");

        List<USUARIO> usuarios = consulta2.getResultList();

        request.setAttribute("servicios", servicios);
        request.setAttribute("usuarios", usuarios);

        System.out.println("  LOG --> MOSTRANDO EL FORMULARIO PARA CREAR UNA CITA");
        request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/ADMIN/formulario_cita.jsp").forward(request, response);
    }

    private void MostrarFormularioEditar(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        Long id = null;
        String idString = request.getParameter("id");

        if (idString != null && idString.isEmpty() == false) {
            try {
                id = Long.parseLong(idString);
            } catch (Exception e) {
                response.sendRedirect(request.getContextPath() + "/Admin/Citas/Listar");
            }
        } else {
            System.out.println("NO SE ESPECIFICÓ NINGUN ID");
            response.sendRedirect(request.getContextPath() + "/Admin/Citas/Listar");
        }

        CITA CitaEncontrada = em.find(CITA.class, id);

        if (CitaEncontrada != null) {
            //CONSULTA PARA OBTENER LOS SERVICIOS 
            Query consulta1 = em.createNativeQuery(
                    "SELECT * FROM SERVICIO", SERVICIO.class);

            List<SERVICIO> servicios = consulta1.getResultList();

            //CONSULTA PARA TRAER A TODOS LOS CLIENTES CON ROL Cliente
            Query consulta2 = em.createNativeQuery(
                    "SELECT * FROM USUARIOS", USUARIO.class);
            //consulta2.setParameter("rol", "Cliente");

            List<USUARIO> usuarios = consulta2.getResultList();

            request.setAttribute("servicios", servicios);
            request.setAttribute("usuarios", usuarios);
            request.setAttribute("cita", CitaEncontrada);
            request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/ADMIN/formulario_cita.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/Admin/Cita/Listar");
        }

    }

    private void CrearCita(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String error = null;

        try {
            Long UsuarioID = Long.parseLong(request.getParameter("usuarioID"));
            LocalDate Fecha = LocalDate.parse(request.getParameter("fecha"));
            LocalTime HoraInicio = LocalTime.parse(request.getParameter("horaInicio"));

            //RECOGER LA ELECCION DE VARIOS SERVICIOS QUE SALEN EN EL DESPLEGABLE 
            String[] Ids_de_servicios = request.getParameterValues("serviciosIds");

            if (Ids_de_servicios == null || Ids_de_servicios.length == 0) {
                //CON JAVASCRIPT LANZARIA UN FALLO 
                response.sendRedirect(request.getContextPath() + "/Admin/Cita/Listar");
            }

            if (UsuarioID == null) {
                response.sendRedirect(request.getContextPath() + "/Admin/Citas/Listar");
            }

            transaccion.begin();

            USUARIO usuario = em.find(USUARIO.class, UsuarioID);

            if (usuario == null) {
                //SI NO LO HA ENCONTRADO ES QUE ESE USUARIO NO ESTA REGISTRADO 
                //CON JAVASCRIPT LANZARIA UN FALLO 
                transaccion.rollback();
                response.sendRedirect(request.getContextPath() + "/Admin/Citas/Listar");
            }

            //CREAMOS UN SET DE SERVICIOS PARA AÑADIRLO DESPUES AL SET DE LA CITA 
            Set<SERVICIO> ServiciosParaCita = new HashSet<>();

            for (String IdServicio : Ids_de_servicios) {
                SERVICIO servicio = em.find(SERVICIO.class, Long.parseLong(IdServicio));

                if (servicio != null) {
                    ServiciosParaCita.add(servicio);
                }
            }

            if (ServiciosParaCita.isEmpty() == true) {
                transaccion.rollback();
                response.sendRedirect(request.getContextPath() + "/Admin/Citas/Listar");
            }

            //CREAMOS LA CITA Y LA GUARDAMOS 
            CITA NuevaCita = new CITA(Fecha, HoraInicio, usuario);
            NuevaCita.setServiciosSet(ServiciosParaCita);

            em.persist(NuevaCita);
            transaccion.commit();

        } catch (Exception e) {
            error = "ERROR AL CREAR EL SERVICIO";

            e.printStackTrace();

            try {
                transaccion.rollback();
            } catch (Exception e2) {
                error = "EL USUARIO YA TIENE UNA CITA";
            }

        }

        if (error != null) {

            // Cargar todos los clientes (Usuarios con rol "Cliente")
            
            Query consultaClientes = em.createNativeQuery(
                    "SELECT * FROM USUARIOS WHERE ROL = ?", USUARIO.class);
            consultaClientes.setParameter(1, "Cliente") ; 
            request.setAttribute("usuarios", consultaClientes.getResultList());

            // Cargar todos los servicios disponibles
            Query consultaServicios = em.createNativeQuery(
                    "SELECT * FROM SERVICIO", SERVICIO.class);
            request.setAttribute("servicios", consultaServicios.getResultList());

            request.setAttribute("error", error);
            request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/ADMIN/formulario_cita.jsp").forward(request, response);
            //response.sendRedirect(request.getContextPath() + "/Admin/Citas/Listar");

        } else {
            response.sendRedirect(request.getContextPath() + "/Admin/Citas/Listar");
        }
    }

    private void ActualizarCita(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        //HAY QUE HACER ESTO YA QUE SI UNA PERSONA PONE DIRECTAMENTE LA URL
        //NO POSEE UN ID Y EL REQUEST.GETPARAMETER DARA ERROR 
        String StringId = request.getParameter("id");
        Long id = null;
        String error = null;

        if (StringId != null && StringId.isEmpty() == false) {
            try {
                id = Long.parseLong(StringId);
            } catch (Exception e) {
                error = "NO SE HA PODIDO CONVERTIR EL ID";
            }
        } else {
            error = "NO SE ESPECIFICÓ NINGUN ID";
        }

        try {

            Long UsuarioID = Long.parseLong(request.getParameter("usuarioID"));
            LocalDate Fecha = LocalDate.parse(request.getParameter("fecha"));
            LocalTime HoraInicio = LocalTime.parse(request.getParameter("HoraInicio"));

            //RECOGER LA ELECCION DE VARIOS SERVICIOS QUE SALEN EN EL DESPLEGABLE 
            String[] Ids_de_servicios = request.getParameterValues("serviciosIds");

            if (Ids_de_servicios == null || Ids_de_servicios.length == 0) {
                response.sendRedirect(request.getContextPath() + "/Admin/Citas/Listar");
            }

            transaccion.begin();

            CITA CitaEditar = em.find(CITA.class, id);

            if (CitaEditar == null) {
                //LANZAR ERROR
                response.sendRedirect(request.getContextPath() + "/Admin/Citas/Listar");
            }

            USUARIO Usuario = em.find(USUARIO.class, UsuarioID);

            if (Usuario == null) {
                //LANZAR ERROR
                response.sendRedirect(request.getContextPath() + "/Admin/Citas/Listar");
            }

            //ACTUALIZAR LA CITA 
            CitaEditar.setUsuario(Usuario);
            CitaEditar.setHoraInicio(HoraInicio);
            CitaEditar.setFecha(Fecha);

            //BORRAMOS LOS SERVICIOS ANTIGUOS PARA PONER LOS NUEVOS 
            CitaEditar.getServiciosSet().clear();

            for (String idServicios : Ids_de_servicios) {
                SERVICIO servicio = em.find(SERVICIO.class, Long.parseLong(idServicios));

                if (servicio != null) {
                    CitaEditar.getServiciosSet().add(servicio);
                }
            }

            transaccion.commit();

        } catch (Exception e) {
            error = "ERROR AL ACTUALIZAR LA CITA";

            try {
                transaccion.rollback();
            } catch (Exception e2) {
                error = "ERROR EN LA TRANSACCION";
            }
        }

        if (error != null) {

            //CONSULTA PARA OBTENER LOS SERVICIOS 
            Query consulta1 = em.createNativeQuery(
                    "SELECT * FROM SERVICIO", SERVICIO.class);

            List<SERVICIO> servicios = consulta1.getResultList();

            //CONSULTA PARA TRAER A TODOS LOS CLIENTES CON ROL Cliente
            Query consulta2 = em.createNativeQuery(
                    "SELECT * FROM USUARIOS", USUARIO.class);
            //consulta2.setParameter(1, "Cliente");

            List<USUARIO> usuarios = consulta2.getResultList();

            request.setAttribute("servicios", servicios);
            request.setAttribute("usuarios", usuarios);

            if (id != null) {
                CITA CitaOriginal = em.find(CITA.class, id);
                request.setAttribute("cita", CitaOriginal);
            }

            request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/ADMIN/formulario_cita.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/Admin/Citas/Listar");
        }
    }

    private void EliminarCita(HttpServletRequest request, HttpServletResponse response) throws IOException {

        //HAY QUE HACER ESTO YA QUE SI UNA PERSONA PONE DIRECTAMENTE LA URL
        //NO POSEE UN ID Y EL REQUEST.GETPARAMETER DARA ERROR 
        String StringId = request.getParameter("id");
        Long id = null;
        String error = null;

        if (StringId != null && StringId.isEmpty() == false) {
            try {
                id = Long.parseLong(StringId);
            } catch (Exception e) {
                error = "NO SE HA PODIDO CONVERTIR EL ID";
            }
        } else {
            error = "NO SE ESPECIFICÓ NINGUN ID";
        }

        try {
            transaccion.begin();

            CITA CitaEliminar = em.find(CITA.class, id);

            if (CitaEliminar != null) {
                em.remove(CitaEliminar);

                transaccion.commit();
            } else {
                transaccion.rollback();
                error = "CITA NO ENCONTRADO";
            }

        } catch (Exception e) {
            error = "ERROR AL ELIMINAR EL CITA";

            try {
                transaccion.rollback();
            } catch (Exception e2) {
                error = "ERROR EN LA TRANSACCION";
            }
        }

        if (error != null) {
            System.out.println(" ERROR. VOLVIENDO A LISTAR CITAS");
            response.sendRedirect(request.getContextPath() + "/Admin/Citas/Listar");
        } else {
            response.sendRedirect(request.getContextPath() + "/Admin/Citas/Listar");
        }
    }

    /*

    private List<CITA> ObtenerCitaConDatos() {
        //OBTENER TODAS LAS CITAS 
        List<CITA> citas = em.createNativeQuery("SELECT * FROM CITA", CITA.class).getResultList();

        //OBETENER LOS USUARIOS
        for (int i = 0; i < citas.size(); i++) {

            if (citas.get(i).getUsuario() != null) {
                citas.get(i).getUsuario();
            }
        }

        //OBTENER LOS SERVICIOS
        for (int i = 0; i < citas.size(); i++) {

            if (citas.get(i).getServiciosSet() != null) {
                citas.get(i).getServiciosSet();
            }
        }

        return citas;

    }

     */
}
