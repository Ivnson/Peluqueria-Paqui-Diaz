/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package Peluqueria.controladores;

import Peluqueria.modelo.SERVICIO;
import jakarta.annotation.Resource;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.Query;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.transaction.Transaction;
import jakarta.transaction.UserTransaction;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author ivan
 */
@WebServlet(name = "ControladorServicios", urlPatterns = {"/Admin/Servicios/*"})
public class ControladorServicios extends HttpServlet {

    @PersistenceContext(unitName = "PeluqueriaPaquiPU")
    private EntityManager em;//GESTOR DE ENTIDADES

    @Resource
    private UserTransaction transaccion; //GESTIONAR TRANSACCIONES

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
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

                ListarServicios(request, response);
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
                response.sendError(404,"PAGINA NO ENCONTRADA");
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

                CrearServicio(request, response);
            }
            break;

            case "/Actualizar": {
                ActualizarServicio(request, response);
            }
            break;

            case "/Eliminar": {
                EliminarServicio(request, response);
            }
            break;
            default:
                response.sendError(404,"PAGINA NO ENCONTRADA");
                //throw new AssertionError();
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

    private void ListarServicios(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        List<SERVICIO> servicios = new ArrayList();
        Query consulta = em.createNativeQuery(
                "SELECT * FROM SERVICIO", SERVICIO.class);

        servicios = consulta.getResultList();

        if (servicios != null) {
            System.out.println(" LOG --> MOSTRANDO LOS SERVICIOS");
            request.setAttribute("ListaServicios", servicios);

            //BUSCAR QUE ES ESTO 
            request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/ADMIN/admin_servicios.jsp").forward(request, response);
        }
    }

    private void MostrarFormularioVacio(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("  LOG --> MOSTRANDO EL FORMULARIO PARA CREAR SERVICIO");
        request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/ADMIN/formulario_servicio.jsp").forward(request, response);
    }

    private void MostrarFormularioEditar(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        //HAY QUE HACER ESTO YA QUE SI UNA PERSONA PONE DIRECTAMENTE LA URL
        //NO POSEE UN ID Y EL REQUEST.GETPARAMETER DARA ERROR 
        String StringId = request.getParameter("id");
        Long id = null;
        //String error = null ; 

        if (StringId != null && StringId.isEmpty() == false) {
            try {
                id = Long.parseLong(StringId);
            } catch (Exception e) {
                System.out.println("NO SE HA PODIDO CONVERTIR EL ID");
                response.sendRedirect(request.getContextPath() + "/Admin/Servicios/Listar");
            }
        } else {
            System.out.println("NO SE ESPECIFICÓ NINGUN ID");
            response.sendRedirect(request.getContextPath() + "/Admin/Servicios/Listar");
        }

        SERVICIO ServicioEncontrado = em.find(SERVICIO.class, id);

        if (ServicioEncontrado != null) {
            request.setAttribute("servicio", ServicioEncontrado);

            request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/ADMIN/formulario_servicio.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/Admin/Servicios/Listar");
        }

    }

    private void CrearServicio(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

        String error = null;

        try {

            transaccion.begin();

            String NombreServicio = request.getParameter("NombreServicio");
            String Descripcion = request.getParameter("Descripcion");
            int Duracion = Integer.parseInt(request.getParameter("Duracion"));
            float Precio = Float.parseFloat(request.getParameter("Precio"));

            Query consulta = em.createNativeQuery(
                    "SELECT * FROM SERVICIO WHERE NOMBRESERVICIO = ?", SERVICIO.class);

            consulta.setParameter(1, NombreServicio);

            List<SERVICIO> servicio_encontrado = consulta.getResultList();

            if (servicio_encontrado.isEmpty() == true) {

                SERVICIO servicio_a_crear = new SERVICIO(NombreServicio, Descripcion, Duracion, Precio);

                em.persist(servicio_a_crear);

                transaccion.commit();

                System.out.println(" LOG --> CREANDO UN NUEVO SERVICIO");
            } else {
                System.out.println("SERVICIO YA CREADO");
                error = "SERVICIO YA CREADO";
                transaccion.rollback();
            }
        } catch (Exception e) {
            error = "ERROR AL CREAR EL SERVICIO";

            try {
                transaccion.rollback();
            } catch (Exception e2) {
                error = "ERROR EN LA TRANSACCION";
            }
        }

        if (error != null) {
            request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/ADMIN/formulario_servicio.jsp").forward(request, response);
            //response.sendRedirect("/formulario_servicios.jsp");
        } else {
            response.sendRedirect(request.getContextPath() + "/Admin/Servicios/Listar");
        }

    }

    private void ActualizarServicio(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

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

            String NombreServicio = request.getParameter("NombreServicio");
            String Descripcion = request.getParameter("Descripcion");
            int Duracion = Integer.parseInt(request.getParameter("Duracion"));
            float Precio = Float.parseFloat(request.getParameter("Precio"));

            SERVICIO servicio = em.find(SERVICIO.class, id);

            if (servicio != null) {
                servicio.setNombreServicio(NombreServicio);
                servicio.setDescripcion(Descripcion);
                servicio.setDuracion(Duracion);
                servicio.setPrecio(Precio);

                transaccion.commit();
            } else {
                transaccion.rollback();
                error = "SERVICIO NO ENCONTRADO";
            }

        } catch (Exception e) {
            error = "ERROR AL ACTUALIZAR EL SERVICIO";

            try {
                transaccion.rollback();
            } catch (Exception e2) {
                error = "ERROR EN LA TRANSACCION";
            }
        }

        if (error != null) {

            if (id != null) {
                SERVICIO ServicioOriginal = em.find(SERVICIO.class, id);
                request.setAttribute("servicio", ServicioOriginal);
            }

            request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/ADMIN/formulario_servicio.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/Admin/Servicios/Listar");
        }
    }

    private void EliminarServicio(HttpServletRequest request, HttpServletResponse response) throws IOException {

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

            SERVICIO ServicioEliminar = em.find(SERVICIO.class, id);

            if (ServicioEliminar != null) {
                em.remove(ServicioEliminar);

                transaccion.commit();
            } else {
                transaccion.rollback();
                error = "SERVICIO NO ENCONTRADO";
            }

        } catch (Exception e) {
            error = "ERROR AL ELIMINAR EL SERVICIO";

            try {
                transaccion.rollback();
            } catch (Exception e2) {
                error = "ERROR EN LA TRANSACCION";
            }
        }

        if (error != null) {
            System.out.println(" ERROR. VOLVIENDO A LISTAR SERVICIOS");
            response.sendRedirect(request.getContextPath() + "/Admin/Servicios/Listar");
        } else {
            response.sendRedirect(request.getContextPath() + "/Admin/Servicios/Listar");
        }
    }
}
