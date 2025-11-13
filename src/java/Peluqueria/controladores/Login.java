
package Peluqueria.controladores;

import Peluqueria.modelo.USUARIO;
import Peluqueria.Utilidades.Contraseñas; // <-- ¡Importamos nuestro gestor!
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.Query;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession; // <-- ¡Importante para la sesión!
import java.io.IOException;


/**
 *
 * @author ivan
 */

@WebServlet(name = "Login", urlPatterns = {"/Login"})
public class Login extends HttpServlet {

    @PersistenceContext(unitName = "PeluqueriaPaquiPU")
    private EntityManager em;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/PUBLICO/Login.jsp").forward(request, response);
        
        
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String passwordPlana = request.getParameter("password");
        String error = null;

        try {
            // 1. Buscar al usuario por email
            Query query = em.createQuery("SELECT u FROM USUARIO u WHERE u.email = :email", USUARIO.class);
            query.setParameter("email", email);
            USUARIO usuario = (USUARIO) query.getSingleResult();

            // 2. ¡Verificar la contraseña hasheada!
            if (Contraseñas.checkPassword(passwordPlana, usuario.getPassword())) {
                
                // ¡ÉXITO! Creamos la sesión
                HttpSession session = request.getSession(true);
                session.setAttribute("usuarioLogueado", usuario);
                
                // 3. Redirigir según el ROL
                if ("Administrador".equals(usuario.getRol())) {
                    response.sendRedirect(request.getContextPath() + "/Admin/Panel");
                } else {
                    // (Aquí iría tu futuro dashboard de cliente)
                    response.sendRedirect(request.getContextPath()); 
                }
                return; // ¡Importante! Salir del método tras redirigir

            } else {
                // La contraseña no coincide
                error = "Contraseña incorrecta.";
            }

        } catch (NoResultException e) {
            // El email no se encontró
            error = "El email '" + email + "' no está registrado.";
        } catch (Exception e) {
            error = "Error inesperado: " + e.getMessage();
        }

        // Si llegamos aquí, hubo un error
        request.setAttribute("loginError", error);
        request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/PUBLICO/Login.jsp").forward(request, response);
    }
        
        
     @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>
    
    }