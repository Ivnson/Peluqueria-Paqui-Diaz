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
// DEFINIMOS QUE ESTE FILTRO SE ACTIVARÁ CUANDO SE INTENTE ENTRAR A "/ADMIN" O CUALQUIER COSA DENTRO DE ELLA "/ADMIN/*"
@WebFilter(value = {"/Admin", "/Admin/*"})
public class FiltroEntradaAdmin implements Filter { 

    //SE EJECUTA UNA VEZ AL ARRANCAR EL SERVIDOR
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        System.out.println("LOG: FiltroEntradaAdmin INICIADO");
    }

    //SE EJECUTA EN CADA PETICIÓN (REQUEST) HACIA LA ZONA DE ADMIN
    @Override
    public void doFilter(ServletRequest sr, ServletResponse sr1, FilterChain fc) throws IOException, ServletException {
        
        System.out.println("LOG: DOFILTER SE ESTÁ EJECUTANDO..."); // <-- Añade esto para depurar
        
        // CASTING
        // CONVERTIMOS A HTTPSERVLETREQUEST PARA PODER MANEJAR LA SESIÓN Y LAS REDIRECCIONES HTTP
        HttpServletRequest request = (HttpServletRequest) sr;
        HttpServletResponse response = (HttpServletResponse) sr1;
        
        // INTENTAMOS RECUPERAR LA SESIÓN ACTUAL
        HttpSession sesion = request.getSession(false);
        boolean admin = false;

        //EXISTE UNA SESION Y HAY UN USUARIO LOGUEADO ?
        if (sesion != null && sesion.getAttribute("usuarioLogueado") != null) { 

            //OBTENGO EL USUARIO
            USUARIO usuario = (USUARIO) sesion.getAttribute("usuarioLogueado");

            // COMPROBAMOS SI EL ROL DEL USUARIO ES "ADMINISTRADOR"
            // SI ES UN "CLIENTE", ESTA CONDICIÓN SERÁ FALSA.
            if ("Administrador".equals(usuario.getRol())) {
                admin = true;
            }
        }

        if (admin == true) {
            // EL USUARIO ES ADMIN,USAMOS fc.doFilter PARA DEJARLE PASAR HACIA EL SERVLET O JSP QUE SOLICITÓ
            System.out.println("LOG: Acceso CONCEDIDO a Admin.");
            fc.doFilter(request, response);
        } else {
            // O NO ESTÁ LOGUEADO, O ES UN CLIENTE INTENTANDO ENTRAR A LA ZONA DE ADMIN
            System.out.println("LOG --> ACCESO DENEGADO A ADMIN");
            
            // LO EXPULSAMOS A LA PÁGINA DE INICIO
            response.sendRedirect(request.getContextPath() + "/"); 
        }
    }

    @Override
    public void destroy() {
        
    }

 
}