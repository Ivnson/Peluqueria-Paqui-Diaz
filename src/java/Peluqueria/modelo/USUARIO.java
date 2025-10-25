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
import java.util.Date;

/**
 *
 * @author ivan
 */
@Entity
@Table(name = "Usuario")
public class USUARIO implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    
    @Column(name = "NombreCompleto", nullable = false) //NULLABLE = FALSE PARA QUE EL VALOR SEA OBLIGATORIO
    private String NombreCompleto;


    //UNA PERSONA PARA REGISTRARSE NECESITA EL NOMBRE, EMAIL Y TELEFONO    
    //LE QUITO EL UNIQUE PARA HACER PRUEBAS
    @Column(name = "Email", nullable = false)//CON UNIQUE NO SE PERMITEN VALORES DUPLICADOS 
    private String Email;
    
    //UNA PERSONA SE INICIA SESION GRACIAS AL TELEFONO 
    //Y SE LE ENVIA UN SMS DE CONFIRMACION
    //LE QUITO EL UNIQUE PARA HACER PRUEBAS
    @Column(name = "Telefono", nullable = false, length = 12)
    private Long Telefono;

    @Temporal(TemporalType.DATE)
    @Column(name = "FechaRegistro", nullable = false)
    private Date FechaRegistro;

    @Column(name = "Rol")
    private String Rol;

    @OneToOne(mappedBy = "Usuario", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    private CITA cita;

    public USUARIO() {
    }

    public USUARIO(String NombreCompleto, String Email, Long Telefono, Date FechaRegistro, String Rol) {
        this.NombreCompleto = NombreCompleto;
        this.Email = Email;
        this.Telefono = Telefono;
        this.FechaRegistro = FechaRegistro;
        this.Rol = Rol;
    }

    public String getNombreCompleto() {
        return NombreCompleto;
    }

    public void setNombreCompleto(String NombreCompleto) {
        this.NombreCompleto = NombreCompleto;
    }

    public String getEmail() {
        return Email;
    }

    public void setEmail(String Email) {
        this.Email = Email;
    }

    public Long getTelefono() {
        return Telefono;
    }

    public void setTelefono(Long Telefono) {
        this.Telefono = Telefono;
    }

    public Date getFechaRegistro() {
        return FechaRegistro;
    }

    public void setFechaRegistro(Date FechaRegistro) {
        this.FechaRegistro = FechaRegistro;
    }

    public String getRol() {
        return Rol;
    }

    public void setRol(String Rol) {
        this.Rol = Rol;
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
