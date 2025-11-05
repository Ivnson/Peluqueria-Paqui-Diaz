/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package Peluqueria.controladores;

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
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author ivan
 */
@WebServlet(name = "ControladorUsuarios", urlPatterns = {"/Admin/Usuarios/*"})
public class ControladorUsuarios extends HttpServlet {

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

    /*
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            //TODO output your page here. You may use following sample code. 
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet ControladorUsuarios</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ControladorUsuarios at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }*/
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

                ListarUsuarios(request, response);
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

                CrearUsuario(request, response);
            }
            break;

            case "/Actualizar": {
                ActualizarUsuario(request, response);
            }
            break;

            case "/Eliminar": {
                EliminarUsuario(request, response);
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

    private void ListarUsuarios(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        List<USUARIO> usuarios = new ArrayList();
        Query consulta = em.createNativeQuery(
                "SELECT * FROM USUARIOS", USUARIO.class);

        usuarios = consulta.getResultList();

        if (usuarios != null) {
            System.out.println(" LOG --> MOSTRANDO LOS USUARIOS");
            request.setAttribute("ListaUsuarios", usuarios);

            request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/ADMIN/admin_usuarios.jsp").forward(request, response);
        }
    }

    private void MostrarFormularioVacio(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("  LOG --> MOSTRANDO EL FORMULARIO PARA CREAR UN USUARIO");
        request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/ADMIN/formulario_usuario.jsp").forward(request, response);
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
                response.sendRedirect(request.getContextPath() + "/Admin/Usuarios/Listar");
            }
        } else {
            System.out.println("NO SE ESPECIFICÓ NINGUN ID");
            response.sendRedirect(request.getContextPath() + "/Admin/Usuarios/Listar");
        }

        USUARIO UsuarioEncontrado = em.find(USUARIO.class, id);

        if (UsuarioEncontrado != null) {
            request.setAttribute("usuario", UsuarioEncontrado);

            request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/ADMIN/formulario_usuario.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/Admin/Usuarios/Listar");
        }

    }

    private void CrearUsuario(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

        String error = null;

        try {

            transaccion.begin();

            String NombreCompleto = request.getParameter("NombreCompleto");
            LocalDate fechaRegistro = LocalDate.now();
            String Email = request.getParameter("Email");
            Long Telefono = Long.parseLong(request.getParameter("Telefono"));
            String Rol = request.getParameter("Rol");

            Query consulta = em.createNativeQuery(
                    "SELECT * FROM USUARIOS WHERE NOMBRECOMPLETO = ?", USUARIO.class);

            consulta.setParameter(1, NombreCompleto);

            List<USUARIO> usuario_encontrado = consulta.getResultList();

            if (usuario_encontrado.isEmpty() == true) {

                USUARIO usuario_a_crear = new USUARIO(NombreCompleto, Email, Telefono, fechaRegistro, Rol);

                em.persist(usuario_a_crear);

                transaccion.commit();

                System.out.println(" LOG --> CREANDO UN NUEVO USUARIO");
            } else {
                System.out.println("USUARIO YA CREADO");
                error = "USUARIO YA CREADO";
                transaccion.rollback();
            }
        } catch (Exception e) {
            error = "ERROR AL CREAR EL USUARIO";

            try {
                transaccion.rollback();
            } catch (Exception e2) {
                error = "ERROR EN LA TRANSACCION";
            }
        }

        if (error != null) {
            request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/ADMIN/formulario_usuario.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/Admin/Usuarios/Listar");
        }

    }

    private void ActualizarUsuario(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

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

            String NombreCompleto = request.getParameter("NombreCompleto");
            LocalDate fechaRegistro = LocalDate.now();
            String Email = request.getParameter("Email");
            Long Telefono = Long.parseLong(request.getParameter("Telefono"));
            String Rol = request.getParameter("Rol");

            USUARIO usuario = em.find(USUARIO.class, id);

            if (usuario != null) {

                usuario.setNombreCompleto(NombreCompleto);
                usuario.setFechaRegistro(fechaRegistro);
                usuario.setEmail(Email);
                usuario.setTelefono(Telefono);
                usuario.setRol(Rol);

                transaccion.commit();
            } else {
                transaccion.rollback();
                error = "USUARIO NO ENCONTRADO";
            }

        } catch (Exception e) {
            error = "ERROR AL ACTUALIZAR EL USUARIO";

            try {
                transaccion.rollback();
            } catch (Exception e2) {
                error = "ERROR EN LA TRANSACCION";
            }
        }

        if (error != null) {

            if (id != null) {
                USUARIO UsuarioOriginal = em.find(USUARIO.class, id);
                request.setAttribute("usuario", UsuarioOriginal);
            }

            request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/ADMIN/formulario_usuario.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/Admin/Usuarios/Listar");
        }
    }
    
    
    
    
    
    
    private void EliminarUsuario(HttpServletRequest request, HttpServletResponse response) throws IOException {

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

            USUARIO UsuarioEliminar = em.find(USUARIO.class, id);

            if (UsuarioEliminar != null) {
                em.remove(UsuarioEliminar);

                transaccion.commit();
            } else {
                transaccion.rollback();
                error = "USUARIO NO ENCONTRADO";
            }

        } catch (Exception e) {
            error = "ERROR AL ELIMINAR EL USUARIO";

            try {
                transaccion.rollback();
            } catch (Exception e2) {
                error = "ERROR EN LA TRANSACCION";
            }
        }

        if (error != null) {
            System.out.println(" ERROR. VOLVIENDO A LISTAR LOS USUARIOS");
            response.sendRedirect(request.getContextPath() + "/Admin/Usuarios/Listar");
        } else {
            response.sendRedirect(request.getContextPath() + "/Admin/Usuarios/Listar");
        }
    }

}
