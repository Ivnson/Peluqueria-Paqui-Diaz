/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Peluqueria.Utilidades;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;

/**
 *
 * @author ivan
 */
public class Contraseñas {

    // Convierte la contraseña en un hash SHA-256
    public static String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes());
            return Base64.getEncoder().encodeToString(hash);
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Error al hashear la contraseña", e);
        }
    }

    // Compara una contraseña del formulario con una ya hasheada de la BD
    public static boolean checkPassword(String passwordPlana, String passwordHasheada) {
        String hashDeIntento = hashPassword(passwordPlana);
        return hashDeIntento.equals(passwordHasheada);
    }

}
