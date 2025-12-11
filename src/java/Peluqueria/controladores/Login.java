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

    // MÉTODO DOGET: SE EJECUTA CUANDO ALGUIEN ESCRIBE LA URL O HACE CLIC EN UN ENLACE "LOGIN"
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // SIMPLEMENTE MUESTRA EL FORMULARIO JSP AL USUARIO
        request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/PUBLICO/Login.jsp").forward(request, response);

    }

    // MÉTODO DOPOST: SE EJECUTA CUANDO EL USUARIO PULSA EL BOTÓN "ENTRAR" DEL FORMULARIO
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // RECUPERA LOS DATOS QUE EL USUARIO ESCRIBIÓ EN LAS CAJAS DE TEXTO
        String email = request.getParameter("email");
        String passwordPlana = request.getParameter("password");
        String error = null;

        try {
            // 1. BUSCAR AL USUARIO POR EMAIL EN LA BASE DE DATOS
            // PREPARA UNA CONSULTA JPQL PARA ENCONTRAR UN USUARIO QUE COINCIDA CON EL EMAIL
            Query query = em.createQuery("SELECT u FROM USUARIO u WHERE u.email = :email", USUARIO.class);
            query.setParameter("email", email);

            // EJECUTA LA CONSULTA. SI NO ENCUENTRA NADA, LANZARÁ 'NoResultException'
            USUARIO usuario = (USUARIO) query.getSingleResult();

            // 2. ¡VERIFICAR LA CONTRASEÑA HASHEADA   
            // USA TU CLASE DE UTILIDAD PARA COMPARAR LA CONTRASEÑA ESCRITA CON EL HASH GUARDADO EN LA BD
            if (Contraseñas.checkPassword(passwordPlana, usuario.getPassword())) {

                // ¡ÉXITO! LAS CREDENCIALES SON CORRECTAS.
                // CREAMOS LA SESIÓN HTTP (O RECUPERAMOS LA EXISTENTE)
                HttpSession session = request.getSession(true);

                // GUARDAMOS TODO EL OBJETO USUARIO EN LA SESIÓN. 
                // ESTO ES COMO DARLE UNA PULSERA VIP AL USUARIO PARA QUE NO TENGA QUE LOGUEARSE EN CADA PÁGINA
                session.setAttribute("usuarioLogueado", usuario);

                // 3. REDIRIGIR SEGÚN EL ROL
                // SI EL USUARIO ES ADMINISTRADOR, LO MANDAMOS AL PANEL DE GESTIÓN
                if ("Administrador".equals(usuario.getRol())) {
                    response.sendRedirect(request.getContextPath() + "/Admin/Panel");
                } else {
                    // SI ES UN CLIENTE NORMAL, LO MANDAMOS A SU PERFIL PERSONAL
                    response.sendRedirect(request.getContextPath() + "/Perfil/Panel");
                }
                return; //CORTAMOS LA EJECUCIÓN AQUÍ PORQUE YA HEMOS REDIRIGIDO AL USUARIO

            } else {
                // SI EL EMAIL EXISTE PERO LA CONTRASEÑA NO COINCIDE
                error = "Contraseña incorrecta.";
            }

        } catch (NoResultException e) {
            // LA CONSULTA DEL PASO 1 NO DEVUELVE NADA
            error = "El email '" + email + "' no está registrado.";
        } catch (Exception e) {
            // ERROR CUALQUIERA
            error = "Error inesperado: " + e.getMessage();
        }

        // SI LLEGAMOS AQUÍ ES PORQUE HUBO UN ERROR (CONTRASEÑA MAL O EMAIL NO EXISTE)
        // GUARDAMOS EL MENSAJE DE ERROR PARA MOSTRARLO EN EL JSP
        request.setAttribute("loginError", error);
        request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/PUBLICO/Login.jsp").forward(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }

}
