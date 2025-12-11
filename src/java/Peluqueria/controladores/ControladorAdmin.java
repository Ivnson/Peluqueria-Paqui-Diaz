
package Peluqueria.controladores;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;


@WebServlet(name = "ControladorAdmin", urlPatterns = {"/Admin/Panel"})
public class ControladorAdmin extends HttpServlet {

    
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
    }

   
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("LOG: Mostrando Dashboard de Admin...");

        // REDIRIGE LA PETICIÓN  AL ARCHIVO JSP QUE CONTIENE LA VISTA DEL PANEL GENERAL
        // AL ESTAR DENTRO DE /WEB-INF/, EL USUARIO NO PUEDE ENTRAR DIRECTAMENTE ESCRIBIENDO LA URL DEL JSP
        // TIENE QUE PASAR POR ESTE CONTROLADOR OBLIGATORIAMENTE
        request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/ADMIN/admin_general.jsp")
                .forward(request, response);

    }

   
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        doGet(request, response);

    }

    
    @Override
    public String getServletInfo() {
        return "Short description";
    }

}
