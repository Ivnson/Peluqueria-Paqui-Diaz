/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Peluqueria.modelo;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.HashSet;
import java.util.Set;

/**
 *
 * @author ivan
 */
@Entity
@Table(name = "historial_citas")
public class HISTORIAL_CITA implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "Fecha", nullable = false)
    private LocalDate fecha;

    @Column(name = "HoraInicio", nullable = false)
    private LocalTime horaInicio;

    // Muchas citas archivadas pueden pertenecer a UN usuario
    @ManyToOne
    @JoinColumn(name = "usuario_id", nullable = false)
    private USUARIO usuario;

    @ManyToMany
    @JoinTable(
            name = "historial_cita_servicio",
            joinColumns = @JoinColumn(name = "historial_cita_id"),
            inverseJoinColumns = @JoinColumn(name = "servicio_id")
    )
    private Set<SERVICIO> serviciosSet = new HashSet<>();

    public HISTORIAL_CITA() {
    }

    public HISTORIAL_CITA(LocalDate fecha, LocalTime horaInicio, USUARIO usuario, Set<SERVICIO> serviciosSet) {
        this.fecha = fecha;
        this.horaInicio = horaInicio;
        this.usuario = usuario;
        this.serviciosSet = serviciosSet;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public LocalDate getFecha() {
        return fecha;
    }

    public void setFecha(LocalDate fecha) {
        this.fecha = fecha;
    }

    public LocalTime getHoraInicio() {
        return horaInicio;
    }

    public void setHoraInicio(LocalTime horaInicio) {
        this.horaInicio = horaInicio;
    }

    public USUARIO getUsuario() {
        return usuario;
    }

    public void setUsuario(USUARIO usuario) {
        this.usuario = usuario;
    }

    public Set<SERVICIO> getServiciosSet() {
        return serviciosSet;
    }

    public void setServiciosSet(Set<SERVICIO> serviciosSet) {
        this.serviciosSet = serviciosSet;
    }

    
    
    
    
    
    
    
    @Override
    public int hashCode() {
        int hash = 0;
        hash += (id != null ? id.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof HISTORIAL_CITA)) {
            return false;
        }
        HISTORIAL_CITA other = (HISTORIAL_CITA) object;
        if ((this.id == null && other.id != null) || (this.id != null && !this.id.equals(other.id))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "Peluqueria.modelo.HISTORIAL_CITA[ id=" + id + " ]";
    }

}
