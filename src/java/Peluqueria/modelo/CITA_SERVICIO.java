/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Peluqueria.modelo;

import jakarta.persistence.Column;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.MapsId;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import java.io.Serializable;

/**
 *
 * @author ivan
 */
@Entity
@Table(name = "Cita_Servicio")
public class CITA_SERVICIO implements Serializable {

    //JPA NO PERMITE CLAVES COMPUESTAS SIN UNA CLASE ESPECIFICA --> CitaServicioId
    //Y NO SE PUEDE PONER @ID A ID_CITA E ID_SERVICIO
    private static final long serialVersionUID = 1L;
    //@Id
    //@GeneratedValue(strategy = GenerationType.AUTO)
    @EmbeddedId
    private CitaServicioId id;

    @ManyToOne(fetch = FetchType.LAZY)
    //@Column(name = "Idcita", unique = true, nullable = false)
    @MapsId("idCita")
    @JoinColumn(name = "idCita", nullable = false)
    private CITA idCita;

    @ManyToOne(fetch = FetchType.LAZY)
    //@Column(name = "Idservicio", unique = true, nullable = false)
    @MapsId("idServicio")
    @JoinColumn(name = "idServicio", nullable = false)
    private SERVICIO idServicio;

    public CITA_SERVICIO() {
    }

    public CITA_SERVICIO(CITA idCita, SERVICIO idServicio) {
        this.idServicio = idServicio;
        this.idCita = idCita;
        this.id = new CitaServicioId(idCita.getId(), idServicio.getId());
    }

    public CitaServicioId getId() {
        return id;
    }

    public void setId(CitaServicioId id) {
        this.id = id;
    }

    public CITA getIdCita() {
        return idCita;
    }

    public void setIdCita(CITA idCita) {
        this.idCita = idCita;
    }

    public SERVICIO getIdServicio() {
        return idServicio;
    }

    public void setIdServicio(SERVICIO idServicio) {
        this.idServicio = idServicio;
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
        if (!(object instanceof CITA_SERVICIO)) {
            return false;
        }
        CITA_SERVICIO other = (CITA_SERVICIO) object;
        if ((this.id == null && other.id != null) || (this.id != null && !this.id.equals(other.id))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "Peluqueria.modelo.CITA_SERVICIO[ id=" + id + " ]";
    }

}
