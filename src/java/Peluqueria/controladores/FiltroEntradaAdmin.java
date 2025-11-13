package Peluqueria.controladores; // (Tu paquete)

import Peluqueria.modelo.USUARIO; // (Importa tu entidad)
import java.io.IOException;
import jakarta.servlet.Filter; // <-- Importa Filter
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter; // <-- ¡ANOTACIÓN CORREGIDA!
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * ESTA ES LA CLASE DE FILTRO CORRECTA
 * - SOLO implementa Filter
 * - NO extiende HttpServlet
 * - USA @WebFilter
 */

// NO USO NAME , ME DA ERROR 
@WebFilter(value = {"/Admin", "/Admin/*"})
public class FiltroEntradaAdmin implements Filter { // <-- ¡YA NO "extends HttpServlet"!

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // (Puedes dejarlo vacío)
        System.out.println("LOG: FiltroEntradaAdmin INICIADO");
    }

    /**
     * ¡Este es el método que se ejecuta! Tu lógica aquí es PERFECTA.
     */
    @Override
    public void doFilter(ServletRequest sr, ServletResponse sr1, FilterChain fc) throws IOException, ServletException {
        
        System.out.println("LOG: DOFILTER SE ESTÁ EJECUTANDO..."); // <-- Añade esto para depurar
        
        HttpServletRequest request = (HttpServletRequest) sr;
        HttpServletResponse response = (HttpServletResponse) sr1;
        HttpSession sesion = request.getSession(false);
        boolean admin = false;

        //EXISTE UNA SESION Y HAY UN USUARIO LOGUEADO ?
        if (sesion != null && sesion.getAttribute("usuarioLogueado") != null) { // (Tuve que corregir el nombre del atributo que pusiste en LoginServlet)

            //OBTENGO EL USUARIO
            USUARIO usuario = (USUARIO) sesion.getAttribute("usuarioLogueado");

            if ("Administrador".equals(usuario.getRol())) {
                admin = true;
            }
        }

        if (admin == true) {
            // ¡Permiso concedido! Dejar pasar al Servlet.
            System.out.println("LOG: Acceso CONCEDIDO a Admin.");
            fc.doFilter(request, response);
        } else {
            // ¡Permiso denegado! Redirigir al inicio.
            System.out.println("LOG --> ACCESO DENEGADO A ADMIN");
            response.sendRedirect(request.getContextPath() + "/"); // (Redirigir a la raíz es más seguro)
        }
    }

    @Override
    public void destroy() {
        // (Puedes dejarlo vacío)
    }

    // ¡LOS MÉTODOS doGet, doPost y getServletInfo SE HAN ELIMINADO!
}