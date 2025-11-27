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

@WebServlet(name = "ControladorIndex", urlPatterns = {""})
public class ControladorIndex extends HttpServlet {

    @PersistenceContext(unitName = "PeluqueriaPaquiPU")
    private EntityManager em;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Obtener las últimas 6 imágenes de la galería para el carrusel
            TypedQuery<GALERIA> q = em.createQuery(
                    "SELECT g FROM GALERIA g ORDER BY g.id DESC", GALERIA.class);
            //q.setMaxResults(6);
            List<GALERIA> imagenesGaleria = q.getResultList();

            request.setAttribute("imagenesGaleria", imagenesGaleria);
            request.getRequestDispatcher("/index.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            // Si hay error, igual cargar el index sin imágenes
            request.getRequestDispatcher("/index.jsp").forward(request, response);
        }
    }
}
