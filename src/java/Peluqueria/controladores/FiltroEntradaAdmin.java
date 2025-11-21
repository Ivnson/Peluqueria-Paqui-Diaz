package Peluqueria.controladores; 

import Peluqueria.modelo.USUARIO;
import java.io.IOException;
import jakarta.servlet.Filter; 
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter; 
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

// NO USO NAME , ME DA ERROR 
@WebFilter(value = {"/Admin", "/Admin/*"})
public class FiltroEntradaAdmin implements Filter { 

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        System.out.println("LOG: FiltroEntradaAdmin INICIADO");
    }


    @Override
    public void doFilter(ServletRequest sr, ServletResponse sr1, FilterChain fc) throws IOException, ServletException {
        
        System.out.println("LOG: DOFILTER SE ESTÁ EJECUTANDO..."); // <-- Añade esto para depurar
        
        HttpServletRequest request = (HttpServletRequest) sr;
        HttpServletResponse response = (HttpServletResponse) sr1;
        HttpSession sesion = request.getSession(false);
        boolean admin = false;

        //EXISTE UNA SESION Y HAY UN USUARIO LOGUEADO ?
        if (sesion != null && sesion.getAttribute("usuarioLogueado") != null) { 

            //OBTENGO EL USUARIO
            USUARIO usuario = (USUARIO) sesion.getAttribute("usuarioLogueado");

            if ("Administrador".equals(usuario.getRol())) {
                admin = true;
            }
        }

        if (admin == true) {
            // PERMISO CONCEDIDO
            System.out.println("LOG: Acceso CONCEDIDO a Admin.");
            fc.doFilter(request, response);
        } else {
            // PERMISO DENEGADO
            System.out.println("LOG --> ACCESO DENEGADO A ADMIN");
            response.sendRedirect(request.getContextPath() + "/"); 
        }
    }

    @Override
    public void destroy() {
        
    }

 
}