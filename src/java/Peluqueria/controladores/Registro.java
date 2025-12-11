package Peluqueria.controladores;

import jakarta.annotation.Resource;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.transaction.UserTransaction;
import Peluqueria.Utilidades.Contraseñas;
import Peluqueria.modelo.USUARIO;
import jakarta.persistence.Query;
import java.time.LocalDate;

@WebServlet(name = "Registro", urlPatterns = {"/Registro"})
public class Registro extends HttpServlet {

    @PersistenceContext(unitName = "PeluqueriaPaquiPU")
    private EntityManager em;
    @Resource
    private UserTransaction transaccion;

    // MÉTODO QUE MANEJA LAS PETICIONES GET (CUANDO EL USUARIO ENTRA A LA PÁGINA DE REGISTRO POR PRIMERA VEZ)
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // REDIRIGE AL USUARIO A LA VISTA JSP DONDE ESTÁ EL FORMULARIO DE REGISTRO
        request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/PUBLICO/Registro.jsp").forward(request, response);

    }

    // MÉTODO QUE MANEJA LAS PETICIONES POST (CUANDO EL USUARIO ENVÍA EL FORMULARIO RELLENO)
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String error = null;
        String email = request.getParameter("Email");
        String nombre = null;
        Long telefono = null;
        String contraseña = null;

        try {
            // 1. COMPROBAR SI EL EMAIL YA EXISTE EN LA BASE DE DATOS
            // CREA UNA CONSULTA JPQL PARA BUSCAR UN USUARIO QUE TENGA ESE EMAIL
            Query consulta = em.createQuery("SELECT u FROM USUARIO u WHERE u.email = :email", USUARIO.class);
            consulta.setParameter("email", email);

            // SI LA LISTA DE RESULTADOS NO ESTÁ VACÍA, SIGNIFICA QUE EL EMAIL YA ESTÁ EN USO
            if (!consulta.getResultList().isEmpty()) {
                // LANZA UNA EXCEPCIÓN PERSONALIZADA PARA INTERRUMPIR EL PROCESO
                throw new Exception("El email '" + email + "' ya está registrado.");
            }

            // 2. RECOGER DATOS DEL FORMULARIO
            nombre = request.getParameter("NombreCompleto");

            // CONVIERTE EL TELÉFONO DE STRING A LONG (PUEDE LANZAR ERROR SI NO ES UN NÚMERO)
            telefono = Long.parseLong(request.getParameter("Telefono"));
            contraseña = request.getParameter("password");

            // 3. ¡HASHEAR LA CONTRASEÑA!
            // UTILIZA LA CLASE DE UTILIDAD 'CONSTRASEÑAS' PARA ENCRIPTAR LA CLAVE ANTES DE GUARDARLA
            String contraseñaHash = Contraseñas.hashPassword(contraseña);

            // 4. CREAR EL NUEVO USUARIO
            // INICIA LA TRANSACCIÓN MANUALMENTE PORQUE ESTAMOS MODIFICANDO LA BASE DE DATOS
            transaccion.begin();

            // INSTANCIA UN NUEVO OBJETO 'USUARIO' CON LOS DATOS RECOGIDOS
            USUARIO nuevoUsuario = new USUARIO(
                    nombre,
                    email,
                    telefono,
                    LocalDate.now(), // ESTABLECE LA FECHA DE ALTA COMO LA FECHA ACTUAL
                    "Cliente", //  ASIGNA EL ROL "CLIENTE" POR DEFECTO
                    contraseñaHash // GUARDA LA CONTRASEÑA YA ENCRIPTADA
            );

            // INDICA AL ENTITY MANAGER QUE GUARDE ESTE NUEVO OBJETO EN LA BASE DE DATOS
            em.persist(nuevoUsuario);

            // CONFIRMA LA TRANSACCIÓN PARA HACER LOS CAMBIOS PERMANENTES
            transaccion.commit();

        } catch (Exception e) {
            error = e.getMessage();
            try {
                if (transaccion.getStatus() == jakarta.transaction.Status.STATUS_ACTIVE) {
                    transaccion.rollback();
                }
            } catch (Exception e2) {
            }
        }

        //LÓGICA DE RESPUESTA AL USUARIO
        if (error != null) {
            // SI HUBO ALGÚN ERROR, SE VUELVE AL FORMULARIO
            request.setAttribute("registroError", error); // ENVÍA EL MENSAJE DE ERROR A LA VISTA

            // SE REENVÍAN LOS DATOS INGRESADOS PARA QUE EL USUARIO NO TENGA QUE VOLVER A ESCRIBIRLOS TODOS
            request.setAttribute("Email", email);
            request.setAttribute("NombreCompleto", nombre);
            request.setAttribute("Telefono", telefono);
            request.setAttribute("password", contraseña);

            // REDIRIGE DE VUELTA A LA PÁGINA DE LOGIN/REGISTRO
            request.getRequestDispatcher("/WEB-INF/Peluqueria.Vista/PUBLICO/Registro.jsp").forward(request, response);
        } else {
            // ¡ÉXITO! SI NO HUBO ERRORES
            // REDIRIGE AL USUARIO AL SERVLET DE LOGIN PARA QUE INICIE SESIÓN
            response.sendRedirect(request.getContextPath() + "/Login");
        }
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }

}
