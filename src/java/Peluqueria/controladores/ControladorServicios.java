/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package Peluqueria.controladores;

import Peluqueria.modelo.SERVICIO;
import jakarta.annotation.Resource;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.Query;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.transaction.Transaction;
import jakarta.transaction.UserTransaction;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author ivan
 */
@WebServlet(name = "ControladorServicios", urlPatterns = {"/Admin/Servicios/*"})
public class ControladorServicios extends HttpServlet {

    @PersistenceContext(unitName = "PeluqueriaPaquiPU")
    private EntityManager em;//GESTOR DE ENTIDADES

    @Resource
    private UserTransaction transaccion; //GESTIONAR TRANSACCIONES

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // OBTENEMOS LA PARTE FINAL DE LA URL PARA SABER QUÉ QUIERE HACER EL ADMIN
        String pathInfo = request.getPathInfo();

        // SI NO HAY RUTA ESPECÍFICA, POR DEFECTO MOSTRAMOS LA LISTA
        if (pathInfo == null || pathInfo.equals("/")) {
            pathInfo = "/Listar";
        }

        switch (pathInfo) {
            case "/Listar": {
                // LLAMA AL MÉTODO QUE CONSULTA LA BD Y MUESTRA LA TABLA DE SERVICIOS
                ListarServicios(request, response);
            }
            break;

            case "/Nuevo": {
                // MUESTRA EL FORMULARIO VACÍO PARA DAR DE ALTA UN SERVICIO
                MostrarFormularioVacio(request, response);
            }
            break;

            case "/Editar": {
                // RECUPERA UN SERVICIO Y MUESTRA EL FORMULARIO CON SUS DATOS PARA MODIFICARLO
                MostrarFormularioEditar(request, response);
            }
            break;
            default:
                // SI LA RUTA NO EXISTE, DEVUELVE ERROR 404
                response.sendError(404, "PAGINA NO ENCONTRADA");
        }

    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();

        switch (pathInfo) {
            case "/Crear": {
                // RECIBE DATOS DEL FORMULARIO Y CREA UN NUEVO SERVICIO EN LA BD
                CrearServicio(request, response);
            }
            break;

            case "/Actualizar": {
                // RECIBE DATOS DEL FORMULARIO Y MODIFICA UN SERVICIO EXISTENTE
                ActualizarServicio(request, response);
            }
            break;

            case "/Eliminar": {
                // ELIMINA UN SERVICIO DE LA BD
                EliminarServicio(request, response);
            }
            break;
            default:
                response.sendError(404, "PAGINA NO ENCONTRADA");
        }

    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

    private void ListarServicios(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        List<SERVICIO> servicios = new ArrayList();

        // CREAMOS UNA CONSULTA SQL NATIVA PARA TRAER TODOS LOS SERVICIOS
        Query consulta = em.createNativeQuery(
                "SELECT * FROM SERVICIO", SERVICIO.class);

        servicios = consulta.getResultList();

        if (servicios != null) {
            System.out.println(" LOG --> MOSTRANDO LOS SERVICIOS");

            // GUARDAMOS LA LISTA EN EL REQUEST PARA QUE EL JSP PUEDA LEERLA
            request.setAttribute("ListaServicios", servicios);

            // REDIRIGIMOS A LA VISTA JSP QUE DIBUJA LA TABLA
            request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/ADMIN/admin_servicios.jsp").forward(request, response);
        }
    }

    private void MostrarFormularioVacio(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("  LOG --> MOSTRANDO EL FORMULARIO PARA CREAR SERVICIO");

        // SIMPLEMENTE CARGA EL JSP DEL FORMULARIO SIN DATOS PREVIOS
        request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/ADMIN/formulario_servicio.jsp").forward(request, response);
    }

    private void MostrarFormularioEditar(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        //HAY QUE HACER ESTO YA QUE SI UNA PERSONA PONE DIRECTAMENTE LA URL
        //NO POSEE UN ID Y EL REQUEST.GETPARAMETER DARA ERROR 
        String StringId = request.getParameter("id");
        Long id = null;

        // VALIDAMOS QUE EL ID NO ESTÉ VACIO
        if (StringId != null && StringId.isEmpty() == false) {
            try {
                // CONVERTIMOS EL TEXTO A NUMERO
                id = Long.parseLong(StringId);
            } catch (Exception e) {

                // SI EL ID NO ES UN NUMERO VALIDO, VOLVEMOS AL LISTADO
                System.out.println("NO SE HA PODIDO CONVERTIR EL ID");
                response.sendRedirect(request.getContextPath() + "/Admin/Servicios/Listar");
            }
        } else {
            System.out.println("NO SE ESPECIFICÓ NINGUN ID");
            response.sendRedirect(request.getContextPath() + "/Admin/Servicios/Listar");
        }

        // BUSCAMOS EL SERVICIO EN LA BASE DE DATOS
        SERVICIO ServicioEncontrado = em.find(SERVICIO.class, id);

        if (ServicioEncontrado != null) {
            // SI EXISTE, LO GUARDAMOS EN EL REQUEST. EL JSP USARÁ ESTOS DATOS PARA RELLENAR LOS CAMPOS.
            request.setAttribute("servicio", ServicioEncontrado);

            // MOSTRAMOS EL JSP DEL FORMULARIO (AHORA RELLENO)
            request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/ADMIN/formulario_servicio.jsp").forward(request, response);
        } else {
            // SI NO SE ENCUENTRA EN LA BD, VOLVEMOS AL LISTADO
            response.sendRedirect(request.getContextPath() + "/Admin/Servicios/Listar");
        }

    }

    private void CrearServicio(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

        String error = null;

        try {

            // INICIAMOS LA TRANSACCIÓN
            transaccion.begin();

            // RECOGEMOS LOS DATOS DEL FORMULARIO Y HACEMOS LAS CONVERSIONES NECESARIAS
            String NombreServicio = request.getParameter("NombreServicio");
            String Descripcion = request.getParameter("Descripcion");
            int Duracion = Integer.parseInt(request.getParameter("Duracion"));
            float Precio = Float.parseFloat(request.getParameter("Precio"));

            // VERIFICAMOS SI YA EXISTE UN SERVICIO CON ESE NOMBRE PARA EVITAR DUPLICADOS
            Query consulta = em.createNativeQuery(
                    "SELECT * FROM SERVICIO WHERE NOMBRESERVICIO = ?", SERVICIO.class);

            consulta.setParameter(1, NombreServicio);

            List<SERVICIO> servicio_encontrado = consulta.getResultList();

            if (servicio_encontrado.isEmpty() == true) {

                // SI NO EXISTE, CREAMOS EL OBJETO SERVICIO
                SERVICIO servicio_a_crear = new SERVICIO(NombreServicio, Descripcion, Duracion, Precio);

                // GUARDAMOS EL OBJETO
                em.persist(servicio_a_crear);

                // CONFIRMAMOS LA TRANSACCION
                transaccion.commit();

                System.out.println(" LOG --> CREANDO UN NUEVO SERVICIO");
            } else {

                // SI YA EXISTE, CANCELAMOS LA TRANSACCIÓN
                System.out.println("SERVICIO YA CREADO");
                error = "SERVICIO YA CREADO";
                transaccion.rollback();
            }
        } catch (Exception e) {
            error = "ERROR AL CREAR EL SERVICIO";

            try {
                transaccion.rollback();
            } catch (Exception e2) {
                error = "ERROR EN LA TRANSACCION";
            }
        }

        // SI HUBO ERROR, VOLVEMOS AL FORMULARIO
        if (error != null) {
            request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/ADMIN/formulario_servicio.jsp").forward(request, response);
            //response.sendRedirect("/formulario_servicios.jsp");
        } else {

            // SI TODO SALIO BIEN, VOLVEMOS A LA LISTA
            response.sendRedirect(request.getContextPath() + "/Admin/Servicios/Listar");
        }

    }

    private void ActualizarServicio(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        //HAY QUE HACER ESTO YA QUE SI UNA PERSONA PONE DIRECTAMENTE LA URL
        //NO POSEE UN ID Y EL REQUEST.GETPARAMETER DARA ERROR 
        String StringId = request.getParameter("id");
        Long id = null;
        String error = null;

        // VALIDAMOS EL ID
        if (StringId != null && StringId.isEmpty() == false) {
            try {
                id = Long.parseLong(StringId);
            } catch (Exception e) {
                error = "NO SE HA PODIDO CONVERTIR EL ID";
            }
        } else {
            error = "NO SE ESPECIFICÓ NINGUN ID";
        }

        try {
            // INICIAMOS TRANSACCIÓN
            transaccion.begin();

            // RECOGEMOS LOS NUEVOS DATOS DEL FORMULARIO
            String NombreServicio = request.getParameter("NombreServicio");
            String Descripcion = request.getParameter("Descripcion");
            int Duracion = Integer.parseInt(request.getParameter("Duracion"));
            float Precio = Float.parseFloat(request.getParameter("Precio"));

            // BUSCAMOS EL SERVICIO ORIGINAL EN LA BD
            SERVICIO servicio = em.find(SERVICIO.class, id);

            if (servicio != null) {

                // ACTUALIZAMOS SUS PROPIEDADES CON LOS SETTERS
                servicio.setNombreServicio(NombreServicio);
                servicio.setDescripcion(Descripcion);
                servicio.setDuracion(Duracion);
                servicio.setPrecio(Precio);

                // CONFIRMAMOS LOS CAMBIOS
                transaccion.commit();
            } else {

                // SI NO EXISTE EL SERVICIO, CANCELAMOS
                transaccion.rollback();
                error = "SERVICIO NO ENCONTRADO";
            }

        } catch (Exception e) {
            error = "ERROR AL ACTUALIZAR EL SERVICIO";

            try {
                transaccion.rollback();
            } catch (Exception e2) {
                error = "ERROR EN LA TRANSACCION";
            }
        }

        // VOLVER AL FORMULARIO CON ERROR O IR A LA LISTA
        if (error != null) {

            if (id != null) {

                // SI FALLÓ, INTENTAMOS CARGAR EL SERVICIO ORIGINAL DE NUEVO PARA NO MOSTRAR EL FORMULARIO VAC
                SERVICIO ServicioOriginal = em.find(SERVICIO.class, id);
                request.setAttribute("servicio", ServicioOriginal);
            }

            request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/ADMIN/formulario_servicio.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/Admin/Servicios/Listar");
        }
    }

    private void EliminarServicio(HttpServletRequest request, HttpServletResponse response) throws IOException {

        //HAY QUE HACER ESTO YA QUE SI UNA PERSONA PONE DIRECTAMENTE LA URL
        //NO POSEE UN ID Y EL REQUEST.GETPARAMETER DARA ERROR 
        String StringId = request.getParameter("id");
        Long id = null;
        String error = null;

        if (StringId != null && StringId.isEmpty() == false) {
            try {
                id = Long.parseLong(StringId);
            } catch (Exception e) {
                error = "NO SE HA PODIDO CONVERTIR EL ID";
            }
        } else {
            error = "NO SE ESPECIFICÓ NINGUN ID";
        }

        try {

            // INICIAMOS TRANSACCIÓN
            transaccion.begin();

            // BUSCAMOS EL SERVICIO A BORRAR
            SERVICIO ServicioEliminar = em.find(SERVICIO.class, id);

            if (ServicioEliminar != null) {
                // SI EXISTE, LO BORRAMOS
                em.remove(ServicioEliminar);
                // CONFIRMAMOS EL BORRADO
                transaccion.commit();
            } else {
                transaccion.rollback();
                error = "SERVICIO NO ENCONTRADO";
            }

        } catch (Exception e) {
            error = "ERROR AL ELIMINAR EL SERVICIO";

            try {
                transaccion.rollback();
            } catch (Exception e2) {
                error = "ERROR EN LA TRANSACCION";
            }
        }

        // REDIRIGIMOS A LA LISTA EN CUALQUIER CASO
        if (error != null) {
            System.out.println(" ERROR. VOLVIENDO A LISTAR SERVICIOS");
            response.sendRedirect(request.getContextPath() + "/Admin/Servicios/Listar");
        } else {
            response.sendRedirect(request.getContextPath() + "/Admin/Servicios/Listar");
        }
    }
}
