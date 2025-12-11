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

// DEFINE LOS LÍMITES DE TAMAÑO (50MB PARA ARCHIVO INDIVIDUAL, 60MB PARA LA PETICIÓN TOTAL)
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

        // OBTENEMOS LA ACCIÓN DE LA URL (EJ: /LISTAR, /NUEVO)
        String path = request.getPathInfo();

        // SI NO HAY RUTA, POR DEFECTO VAMOS A LISTAR
        if (path == null) {
            path = "/listar";
        }

        // ENRUTADOR
        switch (path) {
            case "/listar":
                // LLAMA AL MÉTODO QUE CARGA LAS FOTOS DE LA BD
                listarGaleria(request, response);
                break;
            case "/nuevo":
                // MUESTRA EL FORMULARIO PARA SUBIR UNA FOTO NUEVA
                request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/ADMIN/formulario_galeria.jsp").forward(request, response);
                break;
            default:
                // CUALQUIER OTRA RUTA REDIRIGE AL LISTADO
                response.sendRedirect(request.getContextPath() + "/Admin/Galeria/listar");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getPathInfo();

        // SI NO HAY RUTA EN EL POST, ES UN ERROR DE PETICIÓN
        if (path == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        switch (path) {
            case "/crear":
                // PROCESA LA SUBIDA DEL ARCHIVO Y EL REGISTRO EN BD
                subirArchivo(request, response);
                break;
            case "/eliminar":
                // PROCESA EL BORRADO DEL ARCHIVO FÍSICO Y DE LA BD
                eliminarArchivo(request, response);
                break;
            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void listarGaleria(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // CONSULTA JPQL SELECCIONA TODAS LAS FOTOS ORDENADAS POR ID DESCENDENTE
            TypedQuery<GALERIA> q = em.createQuery("SELECT g FROM GALERIA g ORDER BY g.id DESC", GALERIA.class);
            List<GALERIA> galeria = q.getResultList();

            // GUARDAMOS LA LISTA EN EL REQUEST Y MANDAMOS AL JSP
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

            // RECUPERAMOS EL TÍTULO DEL INPUT DE TEXTO
            String titulo = request.getParameter("titulo");

            // RECUPERAMOS EL ARCHIVO BINARIO DEL INPUT TYPE="FILE"
            // PART --> CONTIENE DATOS DEL ARCHIVO COMO NOMBRE, TIPO ...
            Part filePart = request.getPart("archivo");

            // VALIDAMOS QUE SE HAYA SELECCIONADO UN ARCHIVO REALMENTE
            if (filePart == null || filePart.getSize() == 0) {
                request.setAttribute("error", "Debe seleccionar un archivo");
                request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/ADMIN/formulario_galeria.jsp").forward(request, response);
                return;
            }

            // PREPARAR EL NOMBRE DEL ARCHIVO
            // OBTENEMOS EL NOMBRE ORIGINAL (EJ: "foto.jpg")
            // filePart.getSubmittedFileName() --> RECUPERA EL NOMBRE DEL ARCHIVO TAL Y COMO LO ENVIO EL NAVEGADOR
            // Paths.get --> NOMBRE DEL ARCHIVO DEVUELTO CONTIENE UNA RUTA COMPLETA O PARCIAL
            // getFileName() --> OBTENEMOS EL ULTIMO ELEMENTO DE ESA RUTA QUE ES EL NOMBRE DEL ARCHIVO REAL
            String originalFileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();

            // EXTRAEMOS LA EXTENSIÓN .JPEG , .PNG ...
            String fileExtension = "";

            //ENCONTRAMOS LA ULTIMA APARICION DE UN PUNTO "."
            //DEVUELVE LA POSICION DEL PUNTO SI LO ENCUENTRA 
            int lastDotIndex = originalFileName.lastIndexOf(".");

            if (lastDotIndex > 0) {

                // SE CREA UNA CADENA NUEVA QUE COMIENZA EN EL PUNTO "." HASTA EL FINAL DE LA CADENA ORGINAL
                fileExtension = originalFileName.substring(lastDotIndex);
            }

            //UUID.randomUUID() --> ASIGNA UN IDENTIFICADOR AL ARCHIVO SUBIDO GARANTIZANDO QUE NO HAYA DUPLICADOS
            // POR ESO EN LA CARPETA IMG VEMOS NUMEROS AL AZAR
            String uniqueFileName = UUID.randomUUID().toString() + fileExtension;

            //CONVERTIMOS EL NOMBRE ORIGINAL A MINUSCULAS
            //COMPROBAMOS SI LA CADENA TERMINA EN .mp4 Y ASIGNAMOS EL TIPO DEPENDIENDO DE ESO
            String tipo = originalFileName.toLowerCase().endsWith(".mp4") ? "VIDEO" : "IMAGEN";

            //DEFINIR DÓNDE GUARDAR
            // OBTENEMOS LA RUTA REAL DONDE SE ESTÁ EJECUTANDO LA APLICACIÓN
            String buildPath = request.getServletContext().getRealPath("");

            //System.out.println("RUTA --> " + buildPath); ---> /home/usuario/proyecto/PeluqueriaPaqui/build/web
            // REEMPLAZO BUILD/WEB POR WEB
            // ESTO ES PARA QUE LA FOTO NO DESAPAREZCA CUANDO SE HAGA UN BUILD AND CLEAN DEL PROYECTO
            String sourcePath = buildPath.replace("/build/web", "/web");

            // YO LO ESTOY HACIENDO EN LINUX PERO ES NECESARIO LA
            // CORRECCIÓN PARA WINDOWS (QUE USA BARRAS INVERTIDAS)
            if (File.separator.equals("\\")) {
                sourcePath = buildPath.replace("\\build\\web", "\\web");
            }

            // CREAMOS EL OBJETO FILE APUNTANDO A LA CARPETA DE DESTINO FINAL
            //DONDE EL PADRE ES --> /home/usuario/proyecto/PeluqueriaPaqui/web
            // Y EL HIJO(SUBDIRECTORIO) ES /img
            File uploadDir = new File(sourcePath, "img");

            // CREAR DIRECTORIO SI NO EXISTE
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            System.out.println(">>> GUARDANDO EN CARPETA FUENTE (ORIGINAL): " + uploadDir.getAbsolutePath());

            // CREAMOS EL ARCHIVO VACÍO EN EL DESTINO
            // \Proyectos\MiApp\web\img\f47ac10b-58cc-4372-a567-0e02b2c3d479.jpg
            File file = new File(uploadDir, uniqueFileName);

            // GUARDAR ARCHIVO FISICO
            // INPUTSTREAM ES UN FLUJO DE DATOS QUE CONTIENE EL CONTENIDO REAL DEL ARCHIVO
            try (InputStream input = filePart.getInputStream()) {
                //COPIA TODOS LOS DATOS DEL ORIGEN AL DESTINO 
                Files.copy(input, file.toPath(), StandardCopyOption.REPLACE_EXISTING);
            }

            // GUARDAMOS TAMBIÉN EN LA CARPETA BUILD PARA QUE EL SERVIDOR PUEDA SERVIR LA FOTO
            // SIN NECESIDAD DE REINICIAR O SINCRONIZAR NETBEANS
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

            // GUARDAR EN BD
            // INICIAMOS TRANSACCIÓN
            ut.begin();

            GALERIA item = new GALERIA();

            // GUARDAMOS LA RUTA RELATIVA ("img/foto.jpg") QUE ES LA QUE HTML ENTIENDE
            item.setTitulo(titulo);
            item.setRutaArchivo("img/" + uniqueFileName);
            item.setTipo(tipo);
            em.persist(item); // GUARDAMOS EN BD
            ut.commit();      // CONFIRMAMOS CAMBIOS

            // REDIRIGIMOS AL LISTADO
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
            
            // OBTENEMOS EL ID A BORRAR
            String idStr = request.getParameter("id");
            if (idStr == null) {
                return;
            }

            Long id = Long.parseLong(idStr);

            // INICIAMOS TRANSACCIÓN
            ut.begin();
            
            // BUSCAMOS EL OBJETO EN LA BD
            GALERIA item = em.find(GALERIA.class, id);

            if (item != null) {
                
                // OBTENEMOS LA RUTA COMPLETA EN EL SERVIDOR
                String appPath = request.getServletContext().getRealPath("");
                
                // UNIMOS LA RUTA BASE CON LA RUTA GUARDADA (EJ: /.../Peluqueria/ + img/foto.jpg)
                File archivo = new File(appPath + File.separator + item.getRutaArchivo());

                if (archivo.exists()) {
                    archivo.delete();
                }

                // BORRAR DE LA BASE DE DATOS
                em.remove(item);
            }
            
            // CONFIRMAMOS EL BORRADO EN LA BD
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
