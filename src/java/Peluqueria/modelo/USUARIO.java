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
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import jakarta.persistence.Temporal;
import jakarta.persistence.TemporalType;
import jakarta.validation.constraints.NotBlank;
import java.io.Serializable;
import java.time.LocalDate;
import java.util.Date;
import java.util.HashSet;
import java.util.Set;

/**
 *
 * @author ivan
 */
@Entity
@Table(name = "usuarios")
public class USUARIO implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "NombreCompleto", nullable = false)
    private String nombreCompleto;  // <-- Cambio a camelCase

    //le pongo el UNIQUE despues de hacer pruebas 
    @Column(name = "Email", nullable = false)
    private String email;  // <-- Cambio a camelCase

    //le pongo el UNIQUE despues de hacer pruebas 
    @Column(name = "Telefono", nullable = false, length = 12)
    private Long telefono;  // <-- Cambio a camelCase

    @Column(name = "FechaRegistro", nullable = false)
    private LocalDate fechaRegistro;  // <-- Cambio a camelCase

    @Column(name = "Rol")
    private String rol;  // <-- Cambio a camelCase

    // CORRECCIÓN: mappedBy debe coincidir con el nombre del campo en CITA
    @OneToOne(mappedBy = "usuario", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    private Set<CITA> citas = new HashSet<>();

    public USUARIO() {
    }

    public USUARIO(String NombreCompleto, String Email, Long Telefono, LocalDate FechaRegistro, String Rol) {
        this.nombreCompleto = NombreCompleto;
        this.email = Email;
        this.telefono = Telefono;
        this.fechaRegistro = FechaRegistro;
        this.rol = Rol;
    }

    public String getNombreCompleto() {
        return nombreCompleto;
    }

    public void setNombreCompleto(String NombreCompleto) {
        this.nombreCompleto = NombreCompleto;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String Email) {
        this.email = Email;
    }

    public Long getTelefono() {
        return telefono;
    }

    public void setTelefono(Long Telefono) {
        this.telefono = Telefono;
    }

    public LocalDate getFechaRegistro() {
        return fechaRegistro;
    }

    public void setFechaRegistro(LocalDate FechaRegistro) {
        this.fechaRegistro = FechaRegistro;
    }

    public String getRol() {
        return rol;
    }

    public void setRol(String Rol) {
        this.rol = Rol;
    }

    public Set<CITA> getCitas() {
        return citas;
    }

    public void setCitas(Set<CITA> citas) {
        this.citas = citas;
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
        if (!(object instanceof USUARIO)) {
            return false;
        }
        USUARIO other = (USUARIO) object;
        if ((this.id == null && other.id != null) || (this.id != null && !this.id.equals(other.id))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "Peluqueria.modelo.USUARIO[ id=" + id + " ]";
    }

}
