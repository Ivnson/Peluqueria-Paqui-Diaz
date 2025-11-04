<%-- 
    Document   : formUsers
    Created on : 24 oct 2025, 10:20:20
    Author     : ivan
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Peluqueria Paqui Diaz</title>
        <link rel="stylesheet" href="/web/css/main.css" type="text/css"/>
    </head>
    <body>
        <h1>FORMULARIO</h1>

        <form action="/Peluqueria/Usuario/crear" method="POST">

            <div>
                <label for="nombreCompleto">Nombre Completo:</label>
                <input id="nombreCompleto" type="text" name="nombreCompleto"><br />

                <label for="email">Correo:</label>
                <input id="email" type="text" name="email"><br />

                <label for="telefono">Teléfono: </label>
                <input id="telefono" type="text" name="telefono"><br />

                <input type="submit" value="Guardar" />
            </div>


        </form>

    </body>
</html>
