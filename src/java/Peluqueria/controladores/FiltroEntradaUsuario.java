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

    // MÉTODO DE INICIALIZACIÓN (SE EJECUTA UNA VEZ CUANDO ARRANCA EL SERVIDOR)
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {

    }

    // ESTE ES EL MÉTODO PRINCIPAL. CADA VEZ QUE LLEGA UNA PETICIÓN A LAS URLS PROTEGIDAS SE EJECUTA ESTE CÓDIGO
    @Override
    public void doFilter(ServletRequest sr, ServletResponse sr1, FilterChain fc) throws IOException, ServletException {

        // 1. CASTING
        // LOS OBJETOS ORIGINALES SON GENÉRICOS (ServletRequest), LOS CONVERTIMOS A HTTP (HttpServletRequest)
        // PARA PODER ACCEDER A LA SESIÓN Y A LOS MÉTODOS DE REDIRECCIÓN
        HttpServletRequest httpRequest = (HttpServletRequest) sr;
        HttpServletResponse httpResponse = (HttpServletResponse) sr1;

        // 2. OBTENER LA SESIÓN
        // USAMOS FALSE PORQUE SOLO QUEREMOS RECUPERAR UNA SESIÓN SI YA EXISTE
        // SI NO EXISTE YA QUE EL USUARIO NO SE HA LOGUEADO AÚN, NO QUEREMOS CREAR UNA VACÍA, QUEREMOS QUE DEVUELVA NULL
        HttpSession session = httpRequest.getSession(false);

        boolean esCliente = false;

        // 3. VERIFICACIÓN DE SEGURIDAD
        // PRIMERO COMPROBAMOS SI LA SESIÓN ES DIFERENTE DE NULL (EXISTE)
        // LUEGO COMPROBAMOS SI DENTRO HAY UN ATRIBUTO "usuarioLogueado" (QUE CREAMOS EN EL LOGIN)
        if (session != null && session.getAttribute("usuarioLogueado") != null) {
            USUARIO usuario = (USUARIO) session.getAttribute("usuarioLogueado");

            // 4. VERIFICACIÓN DE ROLES
            // COMPROBAMOS SI EL ROL DEL USUARIO ES "CLIENTE" O "ADMINISTRADOR"
            // PERMITIMOS AL ADMINISTRADOR ENTRAR TAMBIÉN, YA QUE A VECES NECESITA VER EL PERFIL DE USUARIO
            if ("Cliente".equals(usuario.getRol()) || "Administrador".equals(usuario.getRol())) {
                esCliente = true;
            }
        }

        if (esCliente) {
            // EL USUARIO ESTÁ AUTORIZADO
            // LLAMAMOS A fc.doFilter QUE PERMITE QUE LA PETICIÓN CONTINÚE HACIA SU DESTINO ORIGINAL (EL SERVLET O JSP)
            fc.doFilter(sr, sr1);
        } else {
            // ROL NO ADECUADO O NO HAY UNA SESION ABIERTTA
            System.out.println("LOG: Acceso DENEGADO a /cliente/* para un usuario no autorizado.");
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/Login"); // Redirige al login
        }

    }

    @Override
    public void destroy() {

    }

}
