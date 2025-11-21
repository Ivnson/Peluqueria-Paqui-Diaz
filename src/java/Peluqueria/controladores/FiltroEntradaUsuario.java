/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
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

/**
 *
 * @author ivan
 */
@WebFilter(value = {"/Perfil", "/Perfil/*"})
public class FiltroEntradaUsuario implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        
    }

    @Override
    public void doFilter(ServletRequest sr, ServletResponse sr1, FilterChain fc) throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) sr;
        HttpServletResponse httpResponse = (HttpServletResponse) sr1;
        HttpSession session = httpRequest.getSession(false);

        boolean esCliente = false;

        // 1. ¿Hay un usuario logueado en la sesión?
        if (session != null && session.getAttribute("usuarioLogueado") != null) {
            USUARIO usuario = (USUARIO) session.getAttribute("usuarioLogueado");

            // 2. ¿Es un cliente o un admin (que también puede ver su dashboard de cliente)?
            if ("Cliente".equals(usuario.getRol()) || "Administrador".equals(usuario.getRol())) {
                esCliente = true;
            }
        }

        if (esCliente) {
            // El usuario es un cliente o admin. Dejarlo pasar.
            fc.doFilter(sr, sr1);
        } else {
            // No hay sesión, o no es el rol adecuado.
            System.out.println("LOG: Acceso DENEGADO a /cliente/* para un usuario no autorizado.");
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/Login"); // Redirige al login
        }

    }

    @Override
    public void destroy() {
        
    }

}
