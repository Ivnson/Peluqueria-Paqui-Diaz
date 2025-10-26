/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Inicializador;

/**
 *
 * @author ivan
 */
import jakarta.annotation.PostConstruct;
import jakarta.ejb.Singleton;
import jakarta.ejb.Startup;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

/**
 * Clase que se inicializa al arrancar la aplicación
 * y fuerza la carga de la Unidad de Persistencia (PU).
 */
@Singleton
@Startup // <-- Esto asegura que se inicie al desplegar la aplicación
public class InicializadorBD {

    // Inyectamos la Unidad de Persistencia (PU)
    // El servidor la inicializará al arrancar el EJB
    @PersistenceContext(unitName = "PeluqueriaPaquiPU") // <-- ¡IMPORTANTE! Usa el nombre de tu persistence-unit
    private EntityManager em;

    @PostConstruct
    public void init() {
        // Al inyectar el EntityManager, se fuerza la creación de las tablas.
        // Si quieres, puedes añadir un log aquí para confirmar:
        System.out.println("EJB Inicializador cargado. Se intentará la creación de tablas.");
    }
}