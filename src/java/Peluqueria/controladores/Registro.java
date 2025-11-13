/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package Peluqueria.controladores;

import jakarta.annotation.Resource;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.transaction.UserTransaction;
import Peluqueria.Utilidades.Contraseñas;
import Peluqueria.modelo.USUARIO;
import jakarta.persistence.Query;
import java.time.LocalDate;

/**
 *
 * @author ivan
 */
@WebServlet(name = "Registro", urlPatterns = {"/Registro"})
public class Registro extends HttpServlet {

    @PersistenceContext(unitName = "PeluqueriaPaquiPU")
    private EntityManager em;
    @Resource
    private UserTransaction transaccion;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/PUBLICO/Registro.jsp").forward(request, response);

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

        String error = null;
        String email = request.getParameter("Email");
        String nombre = null;
        Long telefono = null;
        String contraseña = null;

        try {
            // 1. Comprobar si el email ya existe
            Query consulta = em.createQuery("SELECT u FROM USUARIO u WHERE u.email = :email", USUARIO.class);
            consulta.setParameter("email", email);
            if (!consulta.getResultList().isEmpty()) {
                throw new Exception("El email '" + email + "' ya está registrado.");
            }

            // 2. Recoger datos
            nombre = request.getParameter("NombreCompleto");
            telefono = Long.parseLong(request.getParameter("Telefono"));
            contraseña = request.getParameter("password");

            // 3. ¡Hashear la contraseña!
            String contraseñaHash = Contraseñas.hashPassword(contraseña);

            // 4. Crear el nuevo usuario
            transaccion.begin();
            USUARIO nuevoUsuario = new USUARIO(
                    nombre,
                    email,
                    telefono,
                    LocalDate.now(),
                    "Cliente", // <-- ¡Rol fijado a "Cliente"!
                    contraseñaHash// <-- Guardamos el hash
            );

            em.persist(nuevoUsuario);
            transaccion.commit();

        } catch (Exception e) {
            error = e.getMessage();
            try {
                if (transaccion.getStatus() == jakarta.transaction.Status.STATUS_ACTIVE) {
                    transaccion.rollback();
                }
            } catch (Exception e2) {
            }
        }

        if (error != null) {
            // Si hay un error, volvemos al formulario con el mensaje
            request.setAttribute("registroError", error);
            request.setAttribute("Email", email);
            request.setAttribute("NombreCompleto", nombre);
            request.setAttribute("Telefono", telefono);
            request.setAttribute("password", contraseña);
            request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/PUBLICO/Login_Registro.jsp").forward(request, response);
        } else {
            // ¡Éxito! Redirigimos al login (o a donde quieras)
            response.sendRedirect(request.getContextPath() + "/Login");
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
