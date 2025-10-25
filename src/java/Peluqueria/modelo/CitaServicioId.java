/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Peluqueria.modelo;

/**
 *
 * @author ivan
 */

import jakarta.persistence.Embeddable;
import java.io.Serializable;
import java.util.Objects;
import jakarta.persistence.Column;


@Embeddable
public class CitaServicioId implements Serializable {

    private static final long serialVersionUID = 1L;

    @Column(name = "idCita")
    private Long idCita;

    @Column(name = "idServicio")
    private Long idServicio;

    // Constructor vacío (OBLIGATORIO para JPA)

    /**
     *
     * @param id
     * @param id1
     */
    public CitaServicioId() {
    }

    // Constructor con parámetros
    public CitaServicioId(Long idCita, Long idServicio) {
        this.idCita = idCita;
        this.idServicio = idServicio;
    }

    // Getters y Setters
    public Long getIdCita() {
        return idCita;
    }

    public void setIdCita(Long idCita) {
        this.idCita = idCita;
    }

    public Long getIdServicio() {
        return idServicio;
    }

    public void setIdServicio(Long idServicio) {
        this.idServicio = idServicio;
    }

    // equals() OBLIGATORIO para claves compuestas
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof CitaServicioId)) return false;
        CitaServicioId that = (CitaServicioId) o;
        return Objects.equals(idCita, that.idCita) && 
               Objects.equals(idServicio, that.idServicio);
    }

    // hashCode() OBLIGATORIO para claves compuestas
    @Override
    public int hashCode() {
        return Objects.hash(idCita, idServicio);
    }

    // toString opcional
    @Override
    public String toString() {
        return "CitaServicioId{" + "idCita=" + idCita + ", idServicio=" + idServicio + '}';
    }
}