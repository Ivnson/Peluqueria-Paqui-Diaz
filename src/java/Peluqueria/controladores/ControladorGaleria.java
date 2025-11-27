package Peluqueria.controladores;

import Peluqueria.modelo.GALERIA;
import jakarta.annotation.Resource;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import java.io.IOException;
import java.io.File;
import java.nio.file.Paths;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import jakarta.transaction.UserTransaction;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.UUID;

@WebServlet(name = "ControladorGaleria", urlPatterns = {"/Admin/Galeria/*"})
@MultipartConfig(
        maxFileSize = 50 * 1024 * 1024, // Aumentado a 50MB por si suben videos
        maxRequestSize = 60 * 1024 * 1024
)
public class ControladorGaleria extends HttpServlet {

    @PersistenceContext(unitName = "PeluqueriaPaquiPU")
    private EntityManager em;

    @Resource
    private UserTransaction ut;

    // CAMBIO 1: Nombre de la carpeta en la raíz
    private static final String UPLOAD_DIR = "img";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getPathInfo();
        if (path == null) {
            path = "/listar";
        }

        switch (path) {
            case "/listar":
                listarGaleria(request, response);
                break;
            case "/nuevo":
                request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/ADMIN/formulario_galeria.jsp").forward(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/Admin/Galeria/listar");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getPathInfo();
        if (path == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        switch (path) {
            case "/crear":
                subirArchivo(request, response);
                break;
            case "/eliminar":
                eliminarArchivo(request, response);
                break;
            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void listarGaleria(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            TypedQuery<GALERIA> q = em.createQuery("SELECT g FROM GALERIA g ORDER BY g.id DESC", GALERIA.class);
            List<GALERIA> galeria = q.getResultList();
            request.setAttribute("listaGaleria", galeria);
            request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/ADMIN/admin_galeria.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error al cargar la galería");
        }
    }

    private void subirArchivo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String titulo = request.getParameter("titulo");
            Part filePart = request.getPart("archivo");

            if (filePart == null || filePart.getSize() == 0) {
                request.setAttribute("error", "Debe seleccionar un archivo");
                request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/ADMIN/formulario_galeria.jsp").forward(request, response);
                return;
            }

            // 1. Preparar nombres
            String originalFileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            String fileExtension = "";
            int lastDotIndex = originalFileName.lastIndexOf(".");
            if (lastDotIndex > 0) {
                fileExtension = originalFileName.substring(lastDotIndex);
            }
            String uniqueFileName = UUID.randomUUID().toString() + fileExtension;
            String tipo = originalFileName.toLowerCase().endsWith(".mp4") ? "VIDEO" : "IMAGEN";

            // 2. Obtener la ruta ACTUAL del servidor (la carpeta build)
            String buildPath = request.getServletContext().getRealPath("");
            // buildPath es: /home/ivan/.../PeluqueriaPaqui/build/web

            // --- TRUCO PARA NETBEANS: CAMBIAR RUTA A LA CARPETA FUENTE ---
            // Reemplazamos "/build/web" por "/web" para apuntar a tu código fuente original
            String sourcePath = buildPath.replace("/build/web", "/web");

            // Si por alguna razón el sistema operativo usa barras invertidas (Windows), prevenimos:
            if (File.separator.equals("\\")) {
                sourcePath = buildPath.replace("\\build\\web", "\\web");
            }

            // Definimos la carpeta de destino final
            File uploadDir = new File(sourcePath, "img");
            // -------------------------------------------------------------

            // 3. Crear directorio si no existe
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            System.out.println(">>> GUARDANDO EN CARPETA FUENTE (ORIGINAL): " + uploadDir.getAbsolutePath());

            File file = new File(uploadDir, uniqueFileName);

            // 4. Guardar archivo físico
            try (InputStream input = filePart.getInputStream()) {
                Files.copy(input, file.toPath(), StandardCopyOption.REPLACE_EXISTING);
            }

            // *** OPCIONAL PERO RECOMENDADO ***
            // Para que la imagen se vea INMEDIATAMENTE sin reiniciar, 
            // también deberíamos guardarla en la carpeta 'build' actual.
            // Si no hacemos esto, la foto está segura, pero quizá no la veas hasta que NetBeans sincronice.
            try {
                File buildDir = new File(buildPath, "img");
                if (!buildDir.exists()) {
                    buildDir.mkdirs();
                }
                File buildFile = new File(buildDir, uniqueFileName);
                Files.copy(file.toPath(), buildFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
            } catch (Exception ex) {
                System.out.println("Nota: No se pudo copiar a la carpeta build temporal (no es crítico).");
            }
            // *********************************

            // 5. Guardar en Base de Datos
            ut.begin();
            GALERIA item = new GALERIA();
            item.setTitulo(titulo);
            item.setRutaArchivo("img/" + uniqueFileName);
            item.setTipo(tipo);
            em.persist(item);
            ut.commit();

            response.sendRedirect(request.getContextPath() + "/Admin/Galeria/listar");

        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (ut != null) {
                    ut.rollback();
                }
            } catch (Exception ex) {
            }
            request.setAttribute("error", "Error: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/ADMIN/formulario_galeria.jsp").forward(request, response);
        }
    }

    private void eliminarArchivo(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        try {
            String idStr = request.getParameter("id");
            if (idStr == null) {
                return;
            }

            Long id = Long.parseLong(idStr);

            ut.begin();
            GALERIA item = em.find(GALERIA.class, id);

            if (item != null) {
                // Borrar archivo físico primero
                String appPath = request.getServletContext().getRealPath("");
                // item.getRutaArchivo() ya trae "img/archivo.jpg", así que lo unimos directo
                File archivo = new File(appPath + File.separator + item.getRutaArchivo());

                if (archivo.exists()) {
                    archivo.delete();
                }

                // Borrar de BD
                em.remove(item);
            }
            ut.commit();

            response.sendRedirect(request.getContextPath() + "/Admin/Galeria/listar");

        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (ut != null) {
                    ut.rollback();
                }
            } catch (Exception ex) {
            }
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error al eliminar");
        }
    }
}
