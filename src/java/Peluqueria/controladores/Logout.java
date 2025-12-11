/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package Peluqueria.controladores;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 *
 * @author ivan
 */
@WebServlet(name = "Logout", urlPatterns = {"/Logout"})
public class Logout extends HttpServlet {

    // MÉTODO QUE MANEJA LAS PETICIONES GET. SE EJECUTA CUANDO ALGUIEN HACE CLIC 
    // EN UN ENLACE DE "CERRAR SESIÓN"
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // RECUPERA LA SESIÓN ACTUAL ASOCIADA A LA PETICIÓN DEL NAVEGADOR
        // SI NO EXISTE SESIÓN, PODRÍA DEVOLVER NULL O CREAR UNA NUEVA DEPENDIENDO 
        // DE LA CONFIGURACIÓN, PERO AQUÍ SOLO NOS INTERESA OBTENER EL OBJETO
        HttpSession sesion = request.getSession();

        if (sesion != null) {
            System.out.println("LOG--> CERRANDO LA SESION DEL USUARIO");

            // ESTA ES LA LÍNEA MÁS IMPORTANTE: INVALIDA LA SESIÓN.
            // ESTO BORRA TODOS LOS ATRIBUTOS GUARDADOS (COMO "usuarioLogueado") Y DESCONECTA AL USUARIO DEL SERVIDOR.
            sesion.invalidate();
        }

        response.sendRedirect(request.getContextPath());
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }

}
