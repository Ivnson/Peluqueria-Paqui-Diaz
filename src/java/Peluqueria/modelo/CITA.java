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
import jakarta.persistence.OneToMany;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import jakarta.persistence.Temporal;
import jakarta.persistence.TemporalType;
import java.io.Serializable;
//import java.sql.Time;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

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

    @Temporal(TemporalType.DATE)
    @Column(name = "Fecha", nullable = false)
    public Date Fecha;

    @Temporal(TemporalType.TIME)
    @Column(name = "HoraInicio", nullable = false)
    private Date HoraInicio;

    //RELACION 1---1 (UNA CITA PERTENECE SOLO A UN USUARIO Y UN USUARIO SOLO TIENE UNA CITA
    @OneToOne
    @JoinColumn(name = "Usuario", unique = true, nullable = false)
    private USUARIO Usuario;

    @OneToMany(mappedBy = "idCita", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    private List<CITA_SERVICIO> cita_servicios = new ArrayList<>();

    public CITA() {
    }

    public CITA(Date Fecha, Date HoraInicio, USUARIO Usuario) {
        this.Fecha = Fecha;
        this.HoraInicio = HoraInicio;
        this.Usuario = Usuario;
    }

    public Date getFecha() {
        return Fecha;
    }

    public USUARIO getUsuario() {
        return Usuario;
    }

    public void setUsuario(USUARIO Usuario) {
        this.Usuario = Usuario;
    }

    public void setFecha(Date Fecha) {
        this.Fecha = Fecha;
    }

    public Date getHoraInicio() {
        return HoraInicio;
    }

    public void setHoraInicio(Date HoraInicio) {
        this.HoraInicio = HoraInicio;
    }

    public List<CITA_SERVICIO> getCita_servicios() {
        return cita_servicios;
    }

    public void setCita_servicios(List<CITA_SERVICIO> cita_servicios) {
        this.cita_servicios = cita_servicios;
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
