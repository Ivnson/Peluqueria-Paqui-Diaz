/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package Peluqueria.controladores;

import Peluqueria.modelo.USUARIO;
import com.sun.istack.logging.Logger;
import jakarta.annotation.Resource;
import jakarta.jms.Session;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.Query;
import jakarta.servlet.RequestDispatcher;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.transaction.SystemException;
import jakarta.transaction.UserTransaction;
import java.time.LocalDate;
import java.util.AbstractList;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.logging.Level;

/**
 *
 * @author ivan
 */
@WebServlet(name = "ControladorUsuarios", urlPatterns = {"/Usuario", "/Usuario/*"})
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

        String VISTA = null;
        String accion = null;

        if (request.getServletPath().equals("/Usuario") == true) {
            if (request.getPathInfo() != null) {
                accion = request.getPathInfo();
            } else {
                accion = "error";
            }
        }

        try {
            switch (accion) {
                case "/listar": {
                    transaccion.begin();

                    List<USUARIO> lista_usuarios = new ArrayList<USUARIO>();
                    Query consulta = em.createNativeQuery("SELECT * FROM USUARIOS", USUARIO.class);
                    lista_usuarios = consulta.getResultList();
                    request.setAttribute("usuarios", lista_usuarios);
                    VISTA = "/WEB-INF/Peluqueria.Vista/usuarios.jsp";
                    transaccion.commit();
                }
                break;

                case "/new": {
                    VISTA = "/WEB-INF/Peluqueria.Vista/formulario_usuarios.jsp";
                }
                break;

                default:
                    VISTA = "/WEB-INF/Peluqueria.Vista/error.jsp";
            }
        } catch (Exception e1) {
            try {
                if (transaccion != null) {
                    transaccion.rollback();
                }
            } catch (Exception e2) {
                System.out.println("ERROR EN ROLLBACK" + e2.getMessage());
            }

            System.out.println("ERROR --> " + e1.getMessage());
            VISTA = "error";
        }

        RequestDispatcher rd = request.getRequestDispatcher(VISTA);
        rd.forward(request, response);
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

        String accion = request.getPathInfo();

        System.out.println("=== PARÁMETROS RECIBIDOS ===");
        System.out.println("nombreCompleto: " + request.getParameter("nombreCompleto"));
        System.out.println("email: " + request.getParameter("email"));
        System.out.println("telefono: " + request.getParameter("telefono"));
        System.out.println("============================");

        if ("/crear".equals(accion)) {
            try {
                transaccion.begin();

                USUARIO nuevo_usuario = new USUARIO();
                nuevo_usuario.setNombreCompleto(request.getParameter("nombreCompleto"));

                nuevo_usuario.setEmail(request.getParameter("email"));

                nuevo_usuario.setTelefono(Long.parseLong(request.getParameter("telefono")));

                LocalDate fecha_actual = LocalDate.now() ;
                nuevo_usuario.setFechaRegistro(fecha_actual);

                nuevo_usuario.setRol("Cliente");

                em.persist(nuevo_usuario);

                transaccion.commit();

                //REDIRIGIR A LA LISTA DE USUARIOS
                response.sendRedirect(request.getContextPath() + "/Usuario/listar");

            } catch (Exception e1) {

                try {
                    if (transaccion != null) {
                        transaccion.rollback();
                    }
                } catch (Exception e2) {
                    System.out.println("ERROR EN ROLLBACK" + e2.getMessage());
                }

                System.out.println("ERROR --> " + e1.getMessage());

                // Mostrar el error en el formulario en lugar de ir a error.jsp
                request.setAttribute("error", "Error al crear usuario: " + e1.getMessage());
                RequestDispatcher rd = request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/formulario_usuarios.jsp");
                rd.forward(request, response);
            }
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

}
