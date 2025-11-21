/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package Peluqueria.controladores;

import Peluqueria.modelo.CITA;
import jakarta.annotation.Resource;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.Query;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.transaction.UserTransaction;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 *
 * @author ivan
 */
@WebServlet(name = "DisponibilidadCitas", urlPatterns = {"/Perfil/Citas/Disponibilidad"})
public class DisponibilidadCitas extends HttpServlet {

    @PersistenceContext(unitName = "PeluqueriaPaquiPU")
    private EntityManager em;

    @Resource
    private UserTransaction transaccion; //GESTIONAR TRANSACCIONES

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();

        try {
            int año = Integer.parseInt(request.getParameter("año"));
            int mes = Integer.parseInt(request.getParameter("mes"));

            LocalDate fechaInicio = LocalDate.of(año, mes, 1);
            LocalDate fechaFin = fechaInicio.withDayOfMonth(fechaInicio.lengthOfMonth());

            Query consultaCitas = em.createQuery(
                    "SELECT c FROM CITA c WHERE c.fecha BETWEEN :inicio AND :fin", CITA.class);
            consultaCitas.setParameter("inicio", fechaInicio);
            consultaCitas.setParameter("fin", fechaFin);

            List<CITA> citasDelMes = consultaCitas.getResultList();

            // JSON manual simple
            StringBuilder json = new StringBuilder();
            json.append("{\"año\":").append(año);
            json.append(",\"mes\":").append(mes);
            json.append(",\"estado\":\"exito\"");
            json.append(",\"disponibilidad\":{");

            Map<String, List<String>> disponibilidad = new HashMap<>();
            for (CITA cita : citasDelMes) {
                String fecha = cita.getFecha().toString();
                String hora = cita.getHoraInicio().toString();

                if (!disponibilidad.containsKey(fecha)) {
                    disponibilidad.put(fecha, new ArrayList<>());
                }
                disponibilidad.get(fecha).add(hora);
            }

            boolean firstDate = true;
            for (Map.Entry<String, List<String>> entry : disponibilidad.entrySet()) {
                if (!firstDate) {
                    json.append(",");
                }
                firstDate = false;

                json.append("\"").append(entry.getKey()).append("\":");
                json.append("[");

                boolean firstTime = true;
                for (String hora : entry.getValue()) {
                    if (!firstTime) {
                        json.append(",");
                    }
                    firstTime = false;
                    json.append("\"").append(hora).append("\"");
                }
                json.append("]");
            }

            json.append("}}");

            out.print(json.toString());

        } catch (Exception e) {
            out.print("{\"estado\":\"error\",\"mensaje\":\""
                    + e.getMessage().replace("\"", "\\\"") + "\"}");
        }
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
