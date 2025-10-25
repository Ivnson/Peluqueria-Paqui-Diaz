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
import java.io.Serializable;
import java.sql.Time;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 *
 * @author ivan
 */
@Entity
@Table(name = "Servicio")
public class SERVICIO implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id ; 
    
    @Column(name = "NombreServicio", nullable = false, length = 100, unique = true)
    private String NombreServicio;

    @Column(name = "Descripcion", length = 500)
    private String Descripcion;

    @Column(name = "Duracion", nullable = false)
    private int Duracion; // en minutos

    @Column(name = "Precio", nullable = false)
    private float Precio;

    @OneToMany(mappedBy = "idServicio", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    private List<CITA_SERVICIO> Cita_servicio = new ArrayList<>();

    public SERVICIO() {
    }

    public SERVICIO(String NombreServicio, String Descripcion, int Duracion, float Precio) {
        this.NombreServicio = NombreServicio;
        this.Descripcion = Descripcion;
        this.Duracion = Duracion;
        this.Precio = Precio;
    }

    public String getNombreServicio() {
        return NombreServicio;
    }

    public void setNombreServicio(String NombreServicio) {
        this.NombreServicio = NombreServicio;
    }

    public String getDescripcion() {
        return Descripcion;
    }

    public void setDescripcion(String Descripcion) {
        this.Descripcion = Descripcion;
    }

    public int getDuracion() {
        return Duracion;
    }

    public void setDuracion(int Duracion) {
        this.Duracion = Duracion;
    }

    public float getPrecio() {
        return Precio;
    }

    public void setPrecio(float Precio) {
        this.Precio = Precio;
    }

    public List<CITA_SERVICIO> getCita_servicio() {
        return Cita_servicio;
    }

    public void setCita_servicio(List<CITA_SERVICIO> Cita_servicio) {
        this.Cita_servicio = Cita_servicio;
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
        if (!(object instanceof SERVICIO)) {
            return false;
        }
        SERVICIO other = (SERVICIO) object;
        if ((this.id == null && other.id != null) || (this.id != null && !this.id.equals(other.id))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "Peluqueria.modelo.SERVICIO[ id=" + id + " ]";
    }

}
