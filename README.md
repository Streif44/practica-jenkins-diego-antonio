# Proceso de despliegue de aplicación Python usando un pipeline de Jenkins

## Creación de la imagen de Jenkins

El primer paso para poner en funcionamiento la aplicación será crear la imagen personalizada de Jenkins que usará Docker para crear el contenedor de Jenkins. Se usará Docker Desktop, el cual en caso de no estar instalado en el sistema, se puede encontrar en la página https://www.docker.com/products/docker-desktop/.

Para ello, descargamos los contenidos de la carpeta `docs` del repositorio de GitHub https://github.com/Streif44/practica-jenkins-diego-antonio a una ubicación en nuestro sistema, ejecutamos Docker Desktop, abrimos un símbolo del sistema desplazándonos a la carpeta donde descargamos los archivos de antes usando el comando `cd` seguido de la ubicación, y ejecutamos el comando `docker build -t myjenkins-blueocean .` que creará una imagen de Docker con el nombre especificado siguiendo las instrucciones del archivo `Dockerfile` que se halla en la carpeta `docs`. Es importante usar el nombre `myjenkins-blueocean`, ya que es el que usará la configuración de Terraform en el siguiente paso.

## Despliegue de contenedores Docker usando Terraform

Ahora que tenemos la imagen personalizada de Jenkins para Docker, es el momento de desplegar el sistema usando Terraform, el cual se puede descargar desde https://developer.hashicorp.com/terraform/install.

Para ello, volvemos al símbolo del sistema de antes y ejecutamos el comando `terraform init`. Esto realizará varias tareas importantes, entre ellas identificar y descargar los proveedores de recursos específicos que utilizará nuestro sistema de contenedores e inicializar el estado de Terraform, un archivo que contiene toda la información sobre la infraestructura que estamos construyendo y los cambios a realizar sobre ella.

Una vez hecho esto, ejecutamos el comando `terraform apply` (escribiendo `yes` cuando se pregunte), el cual creará los recursos necesarios para el sistema siguiendo la configuración del archivo `main.tf` e iniciará los contenedores de Docker, con sus volúmenes y todo lo necesario para su correcto funcionamiento.

En caso de que aparezca un error

## Configuración de Jenkins y despliegue de aplicación Python

Una vez configurado todo el sistema, podremos dirigirnos a http://localhost:8080/ y verificar que podemos conectarnos a la aplicación Jenkins. Se nos pedirá introducir una contraseña para continuar, la cual se puede encontrar en los logs del contenedor llamado `jenkins-blueocean`. También podremos ver esta contraseña abriendo un terminal de dicho contenedor y ejecutando el comando `cat /var/jenkins_home/secrets/initialAdminPassword` dentro del mismo.

Una vez introducida la contraseña obtenida, seleccionamos la opción de instalar los plugins recomendados, esperamos a que finalice la descarga, introducimos los datos de inicio de sesión que veamos convenientes (o lo dejamos como admin), insertamos una URL para acceder a Jenkins, hacemos click en reiniciar y esperamos a que se reinicie el servicio.

Una vez hecho todo esto, hacemos click en `Create a job`, en la parte central del panel de control. Introducimos un nombre apropiado y seleccionamos `Pipeline`. Tras continuar, dentro de Pipeline cambiamos la definición a `Pipeline script from SCM`, el SCM a `Git`, y la URL de repositorio a la del repositorio de GitHub del proyecto https://github.com/Streif44/practica-jenkins-diego-antonio. En branches to build especificamos la rama `*/main` y le damos a guardar.

Una vez hecho todo esto, seleccionamos `Construir ahora` en el menú de la izquierda y esperamos a que finalice su ejecución, la cual puede tardar unos minutos en su primera vez. Si en builds aparece un símbolo de check verde, el sistema fue desplegado exitosamente. Podemos ver el progreso de las etapas del Jenkinsfile haciendo click en la build y en `Console output`.