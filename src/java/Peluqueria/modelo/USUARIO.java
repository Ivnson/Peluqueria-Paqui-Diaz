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
import java.io.Serializable;
import java.time.LocalDate;

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
    private String nombreCompleto;

    @Column(name = "Email", nullable = false, unique = true)
    private String email;

    @Column(name = "Telefono", nullable = false, length = 9, unique = true)
    private Long telefono;

    @Column(name = "FechaRegistro", nullable = false)
    private LocalDate fechaRegistro;

    @Column(name = "Rol")
    private String rol;

    @OneToOne(mappedBy = "usuario", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    private CITA cita;

    @Column(name = "Password", nullable = false, length = 64) // length=64 para guardar el hash SHA-256
    private String password;

    public USUARIO() {
    }

    public USUARIO(String NombreCompleto, String Email, Long Telefono, LocalDate FechaRegistro, String Rol, String contraseñaHash) {
        this.nombreCompleto = NombreCompleto;
        this.email = Email;
        this.telefono = Telefono;
        this.fechaRegistro = FechaRegistro;
        this.rol = Rol;
        this.password = contraseñaHash;
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

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
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

    public CITA getCita() {
        return cita;
    }

    public void setCita(CITA cita) {
        this.cita = cita;
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
