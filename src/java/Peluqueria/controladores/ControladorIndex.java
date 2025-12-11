package Peluqueria.controladores;

import Peluqueria.modelo.GALERIA;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

// INDICA QUE ESTE SERVLET SE EJECUTARÁ CUANDO EL USUARIO ENTRE A LA RAÍZ DE LA APLICACIÓN 
@WebServlet(name = "ControladorIndex", urlPatterns = {""})
public class ControladorIndex extends HttpServlet {

    @PersistenceContext(unitName = "PeluqueriaPaquiPU")
    private EntityManager em;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {

            // 1. PREPARAR LA CONSULTA A LA BASE DE DATOS
            // USAMOS TYPEDQUERY PARA OBTENER OBJETOS DE TIPO GALERIA
            // ORDENAMOS POR ID DESCENDENTE PARA QUE SALGAN PRIMERO LAS FOTOS MÁS NUEVAS
            TypedQuery<GALERIA> q = em.createQuery(
                    "SELECT g FROM GALERIA g ORDER BY g.id DESC", GALERIA.class);

            // 2. EJECUTAR LA CONSULTA Y GUARDAR EL RESULTADO EN UNA LISTA
            List<GALERIA> imagenesGaleria = q.getResultList();

            // 3. PASAR DATOS A LA VISTA (JSP)
            // GUARDAMOS LA LISTA EN EL OBJETO REQUEST CON EL NOMBRE imagenesGaleria
            request.setAttribute("imagenesGaleria", imagenesGaleria);

            request.getRequestDispatcher("/index.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            // AUNQUE FALLE LA CARGA DE IMÁGENES, INTENTAMOS MOSTRAR LA PÁGINA DE INICIO IGUALMENTE
            request.getRequestDispatcher("/index.jsp").forward(request, response);
        }
    }
}
