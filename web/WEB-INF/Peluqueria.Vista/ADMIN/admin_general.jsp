<%-- 
    Document   : admin
    Created on : 2 nov 2025, 15:52:10
    Author     : ivan
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin_general.css"/>
    
    <title>Panel de Administración</title>
</head>
<body>

    <div class="dashboard-container">
        
        <div class="logo">
            <a href="${pageContext.request.contextPath}/">PD</a>
        </div>
        
        <nav class="dashboard-nav">
            <ul>
                <li>
                    <a href="${pageContext.request.contextPath}/Admin/Servicios/Listar" class="btn-nav">
                        Gestionar Servicios
                    </a>
                </li>
                <li>
                    <a href="${pageContext.request.contextPath}/Admin/Usuarios/Listar" class="btn-nav">
                        Gestionar Usuarios
                    </a>
                </li>
                <li>
                    <a href="${pageContext.request.contextPath}/Admin/Citas/Listar" class="btn-nav">
                        Gestionar Citas
                    </a>
                </li>
            </ul>
        </nav>
        
    </div>

</body>
</html>


