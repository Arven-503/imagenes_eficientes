Optimización de Imágenes de Contenedores: Refactorización Multietapa y Mejora de Capas en Docker

Este proyecto desarrolla una arquitectura basada en contenedores para un entorno integrado por un Frontend con Next.js 16+, una API REST desarrollada en Laravel y una base de datos MySQL 8.0. La infraestructura incorpora compilaciones multietapa, optimización de capas y gestión centralizada mediante Docker Compose.

Arquitectura del Sistema

El sistema está compuesto por tres servicios conectados entre sí mediante una red interna de tipo bridge:

[ Cliente / Navegador ]
|
+---> Puerto 3000 ---> [ Frontend: Next.js 16 (Node.js 20 Alpine) ]
|
+---> Puerto 8000 ---> [ Backend: API Laravel (PHP 8.4 Alpine + Nginx + FPM) ]
|
+---> Puerto 3306 (Interno) ---> [ Base de datos: MySQL 8.0 ]

Servicios, Tecnologías y Puertos
Servicio	Tecnología	Imagen Base	Puerto Publicado	Puerto Interno
Frontend	Next.js 16 (App Router)	node:20-alpine	3000	3000
Backend	API Laravel (PHP-FPM + Nginx)	php:8.4-fpm-alpine	8000	8000
Base de datos	Servidor MySQL	mysql:8.0	No publicado	3306
Criterios Técnicos y Optimización de los Dockerfiles
1. Compilaciones Multietapa (Multi-stage Builds)
Frontend (Next.js): Se organizó en tres etapas (deps, builder y runner). Únicamente se trasladan los archivos generados en formato standalone y los directorios estáticos a la imagen definitiva. Este procedimiento disminuye considerablemente el tamaño de la imagen, ya que excluye las dependencias de desarrollo y el administrador de paquetes completo.
Backend (Laravel): Se emplea la imagen oficial de Composer (composer:2) durante una fase preliminar para instalar las dependencias necesarias en producción (--no-dev --optimize-autoloader). En la etapa definitiva, solamente se incorpora el directorio vendor/ con las dependencias instaladas y optimizadas.
2. Disminución del Tamaño y Uso de Imágenes Ligeras
Se eligieron imágenes basadas en Alpine Linux (node:20-alpine y php:8.4-fpm-alpine), lo que permite reducir el espacio ocupado por el sistema operativo base de aproximadamente 800 MB a menos de 50 MB por contenedor.
3. Optimización del Almacenamiento en Caché de Capas (Layer Caching)
En ambos archivos Dockerfile, los archivos que especifican las dependencias (package.json y composer.json) se copian antes de incorporar el resto del código fuente. Esta estrategia impide que la instalación de paquetes tenga que ejecutarse nuevamente cada vez que se modifica el código de la aplicación, siempre que las definiciones de las dependencias permanezcan sin cambios.
4. Protección y Reducción de la Superficie de Ataque
Ejecución con un usuario sin privilegios: En el servicio Frontend, el proceso de Node.js se ejecuta mediante una cuenta de sistema específica (nextjs:nodejs con UID/GID 1001), evitando utilizar privilegios innecesarios.
Aislamiento de la base de datos: El puerto 3306 de MySQL no se expone al equipo anfitrión, por lo que las comunicaciones con la base de datos quedan restringidas a la red privada de Docker (app-network).
Exclusión de archivos sensibles: Se establecieron archivos .dockerignore con reglas estrictas en ambos proyectos para impedir que las claves de API, los archivos .env locales y las cachés temporales se incorporen accidentalmente a las imágenes.
Procedimiento de Ejecución
Requisitos Previos
Docker Desktop con el motor WSL2 activado.
Interfaz de línea de comandos de Git (Git CLI) o GitHub Desktop.
Pasos para Iniciar el Sistema
Descargar el repositorio y acceder a su directorio:
git clone https://github.com/Arven-503/imagenes_eficientes.git
cd imagenes_eficientes

Generar el archivo de configuración del entorno a partir de la plantilla:
cp .env.example .env

Construir las imágenes e iniciar los contenedores en segundo plano:
docker compose up --build -d

Comprobar el estado de los servicios:
docker compose ps

Abrir las aplicaciones desde el navegador:
Frontend: http://localhost:3000
API del Backend: http://localhost:8000
Apagado y Eliminación de Recursos

Para detener los servicios y eliminar los contenedores sin borrar los volúmenes de datos persistentes, ejecutar:

docker compose down


Para detener los servicios, eliminar los contenedores y suprimir también los volúmenes persistentes de la base de datos, ejecutar:

docker compose down -v


Nota: El comando docker compose down -v elimina los volúmenes asociados al proyecto y, por tanto, puede borrar permanentemente los datos almacenados en la base de datos. Úsalo únicamente cuando desees eliminar esa información.