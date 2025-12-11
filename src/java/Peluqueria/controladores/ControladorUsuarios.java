/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package Peluqueria.controladores;

import Peluqueria.modelo.USUARIO;
import jakarta.annotation.Resource;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.Query;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.transaction.UserTransaction;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import Peluqueria.Utilidades.Contraseñas;

/**
 *
 * @author ivan
 */
@WebServlet(name = "ControladorUsuarios", urlPatterns = {"/Admin/Usuarios/*"})
public class ControladorUsuarios extends HttpServlet {

    @PersistenceContext(unitName = "PeluqueriaPaquiPU")
    private EntityManager em;//GESTOR DE ENTIDADES

    @Resource
    private UserTransaction transaccion; //GESTIONAR TRANSACCIONES

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // OBTENEMOS LA PARTE FINAL DE LA URL  "/LISTAR", "/NUEVO" ...
        String pathInfo = request.getPathInfo();

        // SI NO HAY RUTA ESPECÍFICA, POR DEFECTO VAMOS A LISTAR
        if (pathInfo == null || pathInfo.equals("/")) {
            pathInfo = "/Listar";
        }

        // DEPENDIENDO DE LA RUTA, LLAMAMOS A UN MÉTODO DIFERENTE
        switch (pathInfo) {
            case "/Listar": {
                // MUESTRA LA TABLA CON TODOS LOS USUARIOS
                ListarUsuarios(request, response);
            }
            break;

            case "/Nuevo": {
                // MUESTRA EL FORMULARIO VACÍO PARA CREAR UNO NUEVO
                MostrarFormularioVacio(request, response);
            }
            break;

            case "/Editar": {
                // MUESTRA EL FORMULARIO RELLENO CON LOS DATOS DEL USUARIO A EDITAR
                MostrarFormularioEditar(request, response);
            }
            break;
            default:
                // SI LA RUTA NO EXISTE, ERROR 404
                response.sendError(404, "PAGINA NO ENCONTRADA");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // OBTENEMOS LA ACCIÓN A REALIZAR DESDE LA URL DEL FORMULARIO
        String pathInfo = request.getPathInfo();

        switch (pathInfo) {
            case "/Crear": {
                // PROCESA EL FORMULARIO DE REGISTRO
                CrearUsuario(request, response);
            }
            break;

            case "/Actualizar": {
                // PROCESA EL FORMULARIO DE EDICIÓN
                ActualizarUsuario(request, response);
            }
            break;

            case "/Eliminar": {
                // PROCESA LA PETICIÓN DE BORRADO
                EliminarUsuario(request, response);
            }
            break;
            default:
                response.sendError(404, "PAGINA NO ENCONTRADA");

        }
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }

    private void ListarUsuarios(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // CREAMOS UNA CONSULTA SQL NATIVA PARA OBTENER TODOS LOS DATOS DE LA TABLA USUARIOS
        List<USUARIO> usuarios = new ArrayList();
        Query consulta = em.createNativeQuery(
                "SELECT * FROM USUARIOS", USUARIO.class);

        // GUARDAMOS EL RESULTADO EN LA LISTA
        usuarios = consulta.getResultList();

        if (usuarios != null) {
            System.out.println(" LOG --> MOSTRANDO LOS USUARIOS");

            // GUARDAMOS LA LISTA EN EL REQUEST PARA PODER USARLA EN EL JSP
            request.setAttribute("ListaUsuarios", usuarios);

            // ENVIAMOS AL ADMIN A LA VISTA JSP DONDE ESTÁ LA TABLA
            request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/ADMIN/admin_usuarios.jsp").forward(request, response);
        }
    }

    private void MostrarFormularioVacio(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("  LOG --> MOSTRANDO EL FORMULARIO PARA CREAR UN USUARIO");

        // SIMPLEMENTE REDIRIGE AL JSP DEL FORMULARIO
        request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/ADMIN/formulario_usuario.jsp").forward(request, response);
    }

    private void MostrarFormularioEditar(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        //HAY QUE HACER ESTO YA QUE SI UNA PERSONA PONE DIRECTAMENTE LA URL
        //NO POSEE UN ID Y EL REQUEST.GETPARAMETER DARA ERROR 
        String StringId = request.getParameter("id");
        Long id = null;

        // VALIDAMOS QUE EL ID NO SEA NULO NI ESTÉ VACÍO
        if (StringId != null && StringId.isEmpty() == false) {
            try {

                // CONVERTIMOS EL TEXTO A NÚMERO 
                id = Long.parseLong(StringId);

            } catch (Exception e) {

                // SI FALLA LA CONVERSIÓN, VOLVEMOS AL LISTADO
                System.out.println("NO SE HA PODIDO CONVERTIR EL ID");
                response.sendRedirect(request.getContextPath() + "/Admin/Usuarios/Listar");
            }
        } else {

            // SI NO HAY ID, VOLVEMOS AL LISTADO
            System.out.println("NO SE ESPECIFICÓ NINGUN ID");
            response.sendRedirect(request.getContextPath() + "/Admin/Usuarios/Listar");
        }

        // BUSCAMOS EN LA BASE DE DATOS EL USUARIO CON ESE ID
        USUARIO UsuarioEncontrado = em.find(USUARIO.class, id);

        if (UsuarioEncontrado != null) {
            // SI LO ENCONTRAMOS, LO METEMOS EN EL REQUEST, EL JSP LO USARÁ PARA RELLENAR LAS CAJAS DE TEXTO
            request.setAttribute("usuario", UsuarioEncontrado);

            // MOSTRAMOS EL MISMO JSP QUE PARA CREAR, PERO AHORA ESTARÁ RELLENO
            request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/ADMIN/formulario_usuario.jsp").forward(request, response);
        } else {
            // SI NO EXISTE EN LA BD, VOLVEMOS AL LISTADO
            response.sendRedirect(request.getContextPath() + "/Admin/Usuarios/Listar");
        }

    }

    private void CrearUsuario(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

        String error = null;

        try {

            // INICIAMOS LA TRANSACCIÓN PARA PODER GUARDAR EN LA BD
            transaccion.begin();

            // RECOGEMOS TODOS LOS DATOS QUE VIENEN DEL FORMULARIO
            String NombreCompleto = request.getParameter("NombreCompleto");
            LocalDate fechaRegistro = LocalDate.now();
            String Email = request.getParameter("Email");
            Long Telefono = Long.parseLong(request.getParameter("Telefono"));
            String Rol = request.getParameter("Rol");

            // VALIDAMOS LA CONTRASEÑA
            String passwordPlana = request.getParameter("password");
            if (passwordPlana == null || passwordPlana.isEmpty()) {
                throw new Exception("La contraseña no puede estar vacía.");
            }

            // ENCRIPTAMOS LA CONTRASEÑA ANTES DE GUARDARLA
            String contraseñaHash = Contraseñas.hashPassword(passwordPlana);

            // COMPROBAMOS SI EL EMAIL YA EXISTE (PARA NO TENER DUPLICADOS)
            Query consulta = em.createNativeQuery(
                    "SELECT * FROM USUARIOS WHERE EMAIL = ?", USUARIO.class);

            consulta.setParameter(1, Email);

            List<USUARIO> usuario_encontrado = consulta.getResultList();

            if (usuario_encontrado.isEmpty() == true) {

                // SI LA LISTA ESTÁ VACÍA, EL EMAIL ESTÁ LIBRE Y CREAMOS EL OBJETO
                USUARIO usuario_a_crear = new USUARIO(NombreCompleto, Email, Telefono, fechaRegistro, Rol, contraseñaHash);

                // GUARDAMOS EL USUARIO
                em.persist(usuario_a_crear);

                // CONFIRMAMOS LOS CAMBIOS EN LA BASE DE DATOS
                transaccion.commit();

                System.out.println(" LOG --> CREANDO UN NUEVO USUARIO");
            } else {

                // SI EL EMAIL YA EXISTE, DAMOS ERROR Y DESHACEMOS LA TRANSACCIÓN
                System.out.println("USUARIO YA CREADO");
                error = "USUARIO YA CREADO";
                transaccion.rollback();
            }
        } catch (Exception e) {
            // SI OCURRE CUALQUIER ERROR
            error = "ERROR AL CREAR EL USUARIO";

            try {
                // INTENTAMOS DESHACER LA TRANSACCIÓN
                transaccion.rollback();
            } catch (Exception e2) {
                error = "ERROR EN LA TRANSACCION";
            }
        }

        if (error != null) {
            // SI HUBO ERROR, VOLVEMOS AL FORMULARIO 
            request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/ADMIN/formulario_usuario.jsp").forward(request, response);
        } else {
            // SI TODO FUE BIEN, VOLVEMOS A LA LISTA DE USUARIOS
            response.sendRedirect(request.getContextPath() + "/Admin/Usuarios/Listar");
        }

    }

    // REEMPLAZA ESTO EN TU ControladorUsuarios.java
// (Asegúrate de tener: import Peluqueria.util.PasswordUtils;)
    private void ActualizarUsuario(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // RECOGEMOS EL ID DEL USUARIO A MODIFICAR
        String StringId = request.getParameter("id");
        Long id = null;
        String error = null;

        // VALIDAMOS EL ID
        if (StringId != null && !StringId.isEmpty()) {
            try {
                id = Long.parseLong(StringId);
            } catch (Exception e) {
                error = "NO SE HA PODIDO CONVERTIR EL ID";
            }
        } else {
            error = "NO SE ESPECIFICÓ NINGUN ID";
        }

        // SI EL ID ES INVÁLIDO, MOSTRAMOS ERROR
        if (id == null) {
            request.setAttribute("error", error);
            request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/ADMIN/formulario_usuario.jsp").forward(request, response);
            return; // DETENER EJECUCIONN
        }

        try {
            //1. RECOGER DATOS
            String NombreCompleto = request.getParameter("NombreCompleto");
            String Email = request.getParameter("Email");
            Long Telefono = Long.parseLong(request.getParameter("Telefono"));
            String Rol = request.getParameter("Rol");

            // LA CONTRASEÑA ES OPCIONAL AL EDITAR
            String passwordPlana = request.getParameter("password");

            //2. INICIAR TRANSACCIÓN 
            transaccion.begin();

            // BUSCAMOS EL USUARIO ORIGINAL EN LA BD
            USUARIO usuario = em.find(USUARIO.class, id);

            if (usuario != null) {

                // ACTUALIZAMOS LOS DATOS BÁSICOS CON LOS SETTERS
                usuario.setNombreCompleto(NombreCompleto);
                usuario.setEmail(Email);
                usuario.setTelefono(Telefono);
                usuario.setRol(Rol);

                // ACTUALIZAR LA CONTRASEÑA (SOLO SI SE PROPORCIONÓ UNA NUEVA)
                if (passwordPlana != null && !passwordPlana.isEmpty()) {
                    System.out.println("LOG: Actualizando contraseña para el usuario " + id);
                    String contraseñaHash = Contraseñas.hashPassword(passwordPlana);
                    usuario.setPassword(contraseñaHash);
                }

                // CONFIRMAMOS LOS CAMBIOS
                transaccion.commit();
            } else {

                // SI EL USUARIO NO EXISTE, DESHACEMOS
                transaccion.rollback();
                error = "USUARIO NO ENCONTRADO";
            }

        } catch (NumberFormatException e) {
            error = "Error de formato: El teléfono debe ser un número.";
            // No hay rollback aquí
        } catch (Exception e) {
            error = "ERROR AL ACTUALIZAR EL USUARIO: " + e.getMessage();
            try {

                // SI LA TRANSACCIÓN SIGUE ACTIVA TRAS EL ERROR, HACEMOS ROLLBACK
                if (transaccion.getStatus() == jakarta.transaction.Status.STATUS_ACTIVE) {
                    transaccion.rollback();
                }
            } catch (Exception e2) {
                error = "ERROR EN LA TRANSACCION";
            }
        }

        if (error != null) {
            
            // SI HAY ERROR, VOLVEMOS AL FORMULARIO Y RECARGAMOS LOS DATOS ORIGINALES DEL USUARIO PARA NO PERDERLOS
            request.setAttribute("error", error);
            if (id != null) {
                USUARIO UsuarioOriginal = em.find(USUARIO.class, id);
                request.setAttribute("usuario", UsuarioOriginal);
            }
            request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/ADMIN/formulario_usuario.jsp").forward(request, response);
        } else {
            
            // SI ÉXITO, VOLVEMOS A LA LISTA
            response.sendRedirect(request.getContextPath() + "/Admin/Usuarios/Listar");
        }
    }

    private void EliminarUsuario(HttpServletRequest request, HttpServletResponse response) throws IOException {

        //HAY QUE HACER ESTO YA QUE SI UNA PERSONA PONE DIRECTAMENTE LA URL
        //NO POSEE UN ID Y EL REQUEST.GETPARAMETER DARA ERROR 
        String StringId = request.getParameter("id");
        Long id = null;
        String error = null;

        // VALIDACIÓN DEL ID
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

            // BUSCAMOS EL USUARIO A BORRAR
            USUARIO UsuarioEliminar = em.find(USUARIO.class, id);

            if (UsuarioEliminar != null) {
                
                // SI EXISTE, LO MARCAMOS PARA BORRAR
                em.remove(UsuarioEliminar);

                // CONFIRMAMOS EL BORRADO EN LA BD
                transaccion.commit();
            } else {
                transaccion.rollback();
                error = "USUARIO NO ENCONTRADO";
            }

        } catch (Exception e) {
            error = "ERROR AL ELIMINAR EL USUARIO";

            try {
                transaccion.rollback();
            } catch (Exception e2) {
                error = "ERROR EN LA TRANSACCION";
            }
        }

        // REDIRIGIMOS A LA LISTA ---> CODIGO REDUNDANTE ;)DESPUES LO CAMBIO
        if (error != null) {
            System.out.println(" ERROR. VOLVIENDO A LISTAR LOS USUARIOS");
            response.sendRedirect(request.getContextPath() + "/Admin/Usuarios/Listar");
        } else {
            response.sendRedirect(request.getContextPath() + "/Admin/Usuarios/Listar");
        }
    }

}
