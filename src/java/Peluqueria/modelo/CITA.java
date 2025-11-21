/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Peluqueria.modelo;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.ManyToOne;
//import jakarta.persistence.OneToMany;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import jakarta.persistence.Temporal;
import jakarta.persistence.TemporalType;
import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalTime;
//import java.sql.Time;
//import java.util.ArrayList;
import java.util.Date;
import java.util.HashSet;
//import java.util.List;
import java.util.Set;

/**
 *
 * @author ivan
 */
@Entity
@Table(name = "Cita")
public class CITA implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "Fecha", nullable = false)
    private LocalDate fecha;  // <-- Cambio a camelCase

    @Column(name = "HoraInicio", nullable = false)
    private LocalTime horaInicio;  // <-- Cambio a camelCase

    //RELACION 1---1 (UNA CITA PERTENECE SOLO A UN USUARIO Y UN USUARIO SOLO TIENE UNA CITA
    // CORRECCIÓN: Nombre del campo en minúscula para seguir convención Java
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "usuario_id", nullable = false, unique = true)
    private USUARIO usuario;  // <-- Cambio a camelCase

    @ManyToMany(fetch = FetchType.LAZY, cascade = {CascadeType.PERSIST, CascadeType.MERGE})
    @JoinTable(
            name = "Cita_Servicio",
            joinColumns = @JoinColumn(name = "idCita", referencedColumnName = "id"),
            inverseJoinColumns = @JoinColumn(name = "idServicio", referencedColumnName = "id")
    )
    private Set<SERVICIO> serviciosSet = new HashSet<>();

    public CITA() {
    }

    public CITA(LocalDate Fecha, LocalTime HoraInicio, USUARIO Usuario) {
        this.fecha = Fecha;
        this.horaInicio = HoraInicio;
        this.usuario = Usuario;
    }

    public LocalDate getFecha() {
        return fecha;
    }

    public USUARIO getUsuario() {
        return usuario;
    }

    public void setUsuario(USUARIO Usuario) {
        this.usuario = Usuario;
    }

    public void setFecha(LocalDate Fecha) {
        this.fecha = Fecha;
    }

    public LocalTime getHoraInicio() {
        return horaInicio;
    }

    public void setHoraInicio(LocalTime HoraInicio) {
        this.horaInicio = HoraInicio;
    }

    public Set<SERVICIO> getServiciosSet() {
        return serviciosSet;
    }

    public void setServiciosSet(Set<SERVICIO> serviciosSet) {
        this.serviciosSet = serviciosSet;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
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
        if (!(object instanceof CITA)) {
            return false;
        }
        CITA other = (CITA) object;
        if ((this.id == null && other.id != null) || (this.id != null && !this.id.equals(other.id))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "Peluqueria.modelo.CITA[ id=" + id + " ]";
    }

}
