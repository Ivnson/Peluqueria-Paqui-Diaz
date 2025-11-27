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
import jakarta.persistence.Table;
import java.io.Serializable;

@Entity
@Table(name = "galeria")
public class GALERIA implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "Titulo", nullable = false)
    private String titulo;

    @Column(name = "RutaArchivo", nullable = false) // La URL de la imagen/video
    private String rutaArchivo;
    
    @Column(name = "Tipo", nullable = false) // "IMAGEN" o "VIDEO"
    private String tipo;

    // Constructores, Getters y Setters
    public GALERIA() {}

    public GALERIA(String titulo, String rutaArchivo, String tipo) {
        this.titulo = titulo;
        this.rutaArchivo = rutaArchivo;
        this.tipo = tipo;
    }
    
    // (Genera los Getters y Setters aquí con tu IDE)
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }
    public String getRutaArchivo() { return rutaArchivo; }
    public void setRutaArchivo(String rutaArchivo) { this.rutaArchivo = rutaArchivo; }
    public String getTipo() { return tipo; }
    public void setTipo(String tipo) { this.tipo = tipo; }
}