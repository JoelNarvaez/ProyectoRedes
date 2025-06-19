# Proyecto: Simulación de Subredes y Servicios con Docker

## 🧾 Introducción

Este proyecto implementa una red virtualizada con Docker y Docker Compose, que simula un entorno de red dividido en subredes para **clientes** y **servidores**, permitiendo probar:

- Reglas de firewall con `iptables`
- Resolución de nombres con BIND9 (DNS)
- Filtrado de navegación web mediante Squid (proxy)
- Configuración de servidores web virtuales (Apache)
- Acceso remoto mediante SSH y FTP

### 🧱 Subredes

- `red_clientes`: `192.168.100.0/25` (clientes)
- `red_servidores`: `192.168.100.128/25` (servidores)

Estas redes están conectadas por un **firewall** que funciona también como router y aplica políticas de filtrado y NAT.

---
## ▶️ Cómo levantar el entorno con Docker

Este proyecto está configurado para ejecutarse mediante **Docker Compose**, lo que permite levantar todos los servicios (clientes, firewall, DNS, web, proxy, etc.) en una sola línea de comando.

### 🔧 Requisitos previos

Asegúrate de tener instalado en tu sistema:

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/)

Puedes verificar con los siguientes comandos:

```bash
docker -v
docker compose version
```

### 1. Abre una terminal y navega a la carpeta del proyecto

Ubícate en el directorio donde está el archivo `docker-compose.yml`. Por ejemplo:

```bash
cd proyecto-2subredes
```

### 2. Levanta todos los contenedores (y constrúyelos si es la primera vez)

Ejecuta el siguiente comando para construir las imágenes necesarias y levantar todos los contenedores:

```bash
docker-compose up --build
```
Esto construirá los contenedores definidos en docker-compose.yml y los conectará a sus respectivas redes virtuales.

### 3. ✅ Verificar que los contenedores están activos
Para comprobar que los servicios se están ejecutando correctamente, puedes usar el siguiente comando:
```bash
docker ps
```
En el apartado de `Status` todos deben decir <b>UP</b>

### 3. 🛑 Detener todos los contenedores
Cuando quieras finalizar el entorno, puedes detener todos los servicios con:

```bash
docker-compose down
```

---
## 🧊 Squid Proxy – Filtrado de Contenido Web

El contenedor `squid` actúa como un **proxy HTTP** que filtra el tráfico web saliente desde los clientes hacia los servidores externos. Su propósito principal es restringir el acceso a ciertos sitios web y controlar qué contenido puede ser visitado desde la red interna.

Este proxy se configura para:

- Bloquear URLs que contengan ciertas **palabras clave**
- Bloquear **dominios específicos**
- Permitir el resto del tráfico web no restringido

### 📁 Archivos importantes

| Archivo | Descripción |
|--------|-------------|
| `squid.conf` | Archivo principal de configuración del proxy |
| `blacklist.txt` | Contiene palabras que si aparecen en una URL, esa URL será bloqueada |
| `blocked_sites.acl` | Lista de dominios que están completamente bloqueados |

### 🧪 ¿Cómo funciona?

En el archivo `squid.conf`, se definen dos listas de control de acceso (ACL):

```conf
http_port 3128  # Puerto del proxy

# ACL por palabras clave en URLs
acl palabras_bloqueadas url_regex "/etc/squid/blacklist.txt"
http_access deny palabras_bloqueadas

# ACL por dominios bloqueados
acl sitios_bloqueados dstdomain "/etc/squid/blocked_sites.acl"
http_access deny sitios_bloqueados

# Permitir todo lo demás
http_access allow all

# Registrar accesos
access_log /var/log/squid/access.log

``` 

### 🔎 ¿Cómo funciona Squid?

- Si una URL contiene una palabra del archivo `blacklist.txt`, **se bloquea**.
- Si el dominio de destino aparece en `blocked_sites.acl`, **se bloquea toda la conexión**.

---

### 🧪 Prueba del Proxy

El contenedor `firefox` (basado en una imagen con GUI accesible por navegador) está **preconfigurado para usar Squid como proxy**:

```env
FIREFOX_PROXY_HOST=192.168.100.131
FIREFOX_PROXY_PORT=3128
FIREFOX_PROXY_TYPE=http
```
###  Cómo probar Squid con Firefox

Puedes verificar el funcionamiento del proxy Squid accediendo al navegador gráfico contenido en el contenedor `firefox`.

#### 🔧 Pasos:

1. Abre tu navegador web (fuera de Docker) y entra a la siguiente dirección: `
   - `http://localhost:5800`
  
Esto abrirá la interfaz gráfica del navegador Firefox que corre dentro del contenedor Docker.

2. Una vez dentro del entorno de Firefox:

   - Haz clic en el **menú** (☰).
   - Entra a **Settings** o **Preferencias**.
   - Desplázate hasta la sección **Network Settings** y haz clic en **Settings...**.
   - Selecciona **Manual proxy configuration**.
   - En el campo **HTTP Proxy**, escribe:

     ```
     192.168.100.131
     ```

   - Puerto:

     ```
     3128
     ```

   - Marca la opción:  
     ✅ *Use this proxy server for all protocols*

   - Guarda los cambios (clic en **OK**).

3. Ahora intenta navegar a distintos sitios:

   - Ir a `www.tiktok.com` debería estar **bloqueado**.
   - Ir a cualquier URL que contenga palabras como `porno` o `violencia` también será **denegado**.
   - Otros sitios como `duckduckgo.com` o `wikipedia.org` deberían cargarse normalmente.

--

### 🧪 Cómo probar Squid con cliente1

El contenedor `cliente1` se maneja desde la línea de comandos. En esta sección, se utilizará su terminal para comprobar el funcionamiento del proxy Squid sin necesidad de interfaz gráfica.

1. Ejecuta este comando en la terminal: `
   ```bash
    docker exec -it cliente1 bash
    ```
   Esto abrira la terminal de clinete1
2. Realiza pruebas utilizando el proxy Squid
   -Usa la opción -x de curl para indicar el proxy manualmente. La sintaxis es:
    ```bash
    curl -x http://<IP_DEL_PROXY>:<PUERTO> <URL>
    ```
   En este proyecto:
   `IP del proxy: 192.168.100.131`
   `Puerto: 3128`
3. Ejemplos de pruebas:
    ```bash
     # Sitio permitido (debería funcionar)
    curl -x http://192.168.100.131:3128 http://wikipedia.org
  
    # Sitio bloqueado por dominio
    curl -x http://192.168.100.131:3128 http://www.tiktok.com
    ```
4.  Interpretar los resultados
   - ✅ Si la página está permitida, curl mostrará el contenido HTML en la terminal.
   - ❌ Si la página está bloqueada, curl mostrará un mensaje de "Access Denied" o similar generado por Squid.

---

✅ Si los sitios bloqueados no se cargan y los permitidos sí, entonces el proxy Squid está funcionando correctamente.

### ✅ Ventajas del uso de Squid

- 🔐 **Control del ancho de banda**  
  Permite limitar o priorizar el acceso a ciertos recursos web para optimizar el uso de la red.

- 🚫 **Filtrado de contenido no deseado**  
  Bloquea accesos a sitios web según listas de dominios o palabras clave.

- 📊 **Registro de navegación**  
  Guarda un historial de los sitios visitados por cada cliente, útil para auditoría y monitoreo.

- 🧱 **Base para implementar autenticación o caché**  
  Squid puede integrarse con sistemas de autenticación de usuarios y almacenar en caché contenidos estáticos para mejorar el rendimiento.
---

## 🌐 Servidor Web Apache – Hosts Virtuales

El contenedor `apache` implementa un **servidor web** utilizando Apache2. Está configurado para responder en la red de servidores y puede ser utilizado para alojar **múltiples sitios virtuales (Virtual Hosts)**.

---

### 📍 ¿Qué es un Host Virtual?

Un **host virtual** permite que un mismo servidor web escuche en el mismo puerto (por ejemplo, el 80), pero responda con contenido diferente según el **nombre del dominio solicitado**.

Por ejemplo:

- `site1.local` → contenido del sitio 1
- `site2.local` → contenido del sitio 2
- `site3.local` → contenido del sitio 3

---

### 🧾 Ubicación de la configuración

El archivo principal que gestiona esto es:
Este archivo se monta en el contenedor y contiene bloques `<VirtualHost>` como el siguiente:
```apache
<VirtualHost *:80>
    ServerName sitio1.local
    DocumentRoot /var/www/sitio1
</VirtualHost>

<VirtualHost *:80>
    ServerName sitio2.local
    DocumentRoot /var/www/sitio2
</VirtualHost>

<VirtualHost *:80>
    ServerName sitio3.local
    DocumentRoot /var/www/sitio3
</VirtualHost>
```
---
###  🧪 Prueba de los Host Virtuales
1. Ejecuta este comando en la terminal: `
   ```bash
    docker exec -it cliente1 bash
    ```
   Esto abrira la terminal de clinete1
   
3. Accede a los host virtuales
   Apache está configurado con múltiples virtual hosts (como sitio1.local, sitio2.local, etc.). Para que Apache responda con el contenido correcto, debes enviar el encabezado Host apropiado.
    ```bash
    curl -H "Host:Nombre_sitio" http://<IP_DEL_APACHE>
    ```
   En este proyecto:
   `IP del APACHE: 192.168.100.160`
3. Ejemplo de pruebas:
    ```bash
      curl -H "Host: site1.local" http://192.168.100.160
    ```
    - Si el nombre de host (Host) coincide con un VirtualHost definido en Apache, recibirás el contenido correcto (como el index.html del sitio).
    - Si el Host no existe o no coincide con la configuración de Apache, obtendrás una respuesta por defecto o un error 404.
---
## 🧠 Servidor DNS – BIND9

El contenedor `bind` implementa un servidor DNS interno utilizando **BIND9**. Su objetivo es permitir la resolución de nombres dentro de la red simulada, como por ejemplo:

- `site1.local`
- `site2.local`
- `site3.local`

Esto es esencial para que los clientes puedan acceder a servicios por nombre en lugar de por IP.

---

### 🧾 ¿Qué hace el servidor DNS?

- Resuelve nombres internos definidos en zonas como `db.site1.local`, `db.site2.local`, etc.
- Reenvía las consultas externas a servidores DNS públicos (Google, Cloudflare).
- Permite recursión para que los clientes puedan resolver tanto dominios locales como externos.

---

### 🧩 Archivos importantes

| Archivo | Descripción |
|---------|-------------|
| `named.conf` | Archivo base de configuración de BIND |
| `named.conf.options` | Configura la recursión y los reenviadores DNS |
| `named.conf.local` | Define las zonas locales (dominios `.local`) |
| `db.siteX.local` | Archivos de zona con los registros DNS de cada sitio |

---

### ⚙️ Ejemplo de configuración (`named.conf.options`)

```conf
options {
    directory "/var/cache/bind";

    allow-query { any; };     // Permitir consultas desde cualquier IP
    recursion yes;            // Permitir resolución recursiva

    forwarders {
        8.8.8.8;              // Google DNS
        1.1.1.1;              // Cloudflare DNS
    };

    dnssec-validation auto;
};

```
### ⚙️ Ejemplo de configuración (`db.siteX.local`)
Estos archivos definen los registros de los sitios locales. 
```conf
$TTL 604800
@   IN  SOA site1.local. root.site1.local. (
            2     ; Serial
            604800 ; Refresh
            86400  ; Retry
            2419200; Expire
            604800 ); Negative Cache TTL

@       IN  NS  site1.local.
@       IN  A   192.168.100.160
site1   IN  A   192.168.100.160
```
Esto permite que site1.local y www.site1.local se resuelvan a la IP del contenedor Apache.

### ⚙️ Ejemplo de configuración (`named.conf.local`)
Este archivo vincula cada zona definida a su respectivo archivo de base de datos DNS:
```conf
zone "site1.local" {
    type master;
    file "/etc/bind/db.site1.local";
};

zone "site2.local" {
    type master;
    file "/etc/bind/db.site2.local";
};

zone "site3.local" {
    type master;
    file "/etc/bind/db.site3.local";
};

```
Cada bloque zone define un dominio que el servidor puede resolver, y el archivo correspondiente indica los registros que contiene.

---
### 🧪 Prueba del DNS
##  Cómo probar DNS con Firefox

Puedes verificar el funcionamiento del DNS accediendo al navegador gráfico contenido en el contenedor `firefox`.

#### 🔧 Pasos:
Es lo mismo que en el squid, esto pasa porque primero pasa por el squid y luego resuelve los dominios
1. Abre tu navegador web (fuera de Docker) y entra a la siguiente dirección: `
   - `http://localhost:5800`
  
Esto abrirá la interfaz gráfica del navegador Firefox que corre dentro del contenedor Docker.

2. Una vez dentro del entorno de Firefox:

   - Haz clic en el **menú** (☰).
   - Entra a **Settings** o **Preferencias**.
   - Desplázate hasta la sección **Network Settings** y haz clic en **Settings...**.
   - Selecciona **Manual proxy configuration**.
   - En el campo **HTTP Proxy**, escribe:

     ```
     192.168.100.131
     ```

   - Puerto:

     ```
     3128
     ```

   - Marca la opción:  
     ✅ *Use this proxy server for all protocols*

   - Guarda los cambios (clic en **OK**).

3. Ahora intenta navegar en los distintos sitios:

   - Ir a `www.site1.local` debería aparecer la pagina Web es decir **index.html**.
   - Ir a `www.site2.local` debería aparecer la pagina Web es decir **index.html**.
  
### 🧪 Cómo probar DNS con cliente1

El contenedor `cliente1` se maneja desde la línea de comandos. En esta sección, se utilizará su terminal para comprobar el funcionamiento del DNS sin necesidad de interfaz gráfica.

1. Ejecuta este comando en la terminal: `
   ```bash
    docker exec -it cliente1 bash
    ```
   Esto abrira la terminal de clinete1
2. Realiza pruebas de resolución DNS con curl
   -Usa la opción -x de curl para indicar el proxy manualmente. La sintaxis es:
    ```bash
    curl http://<nombre_sitio>
    ```
  
3. Ejemplos de pruebas:
    ```bash
    curl http://site1.local
    curl http://site2.local
    ```
4.  Interpretar los resultados
  - ✅ Si el DNS está funcionando correctamente, recibirás el contenido HTML del sitio correspondiente (por ejemplo, el index.html de site1.local).
  - ❌ Si no está funcionando: Puede que curl indique un "Could not resolve host" si no encuentra el dominio.

### 🧠 Importancia del DNS en este proyecto
-Permite que los sitios virtuales de Apache funcionen por nombre.
-Facilita el filtrado en Squid si se usan dominios en lugar de IPs.
-Imita el comportamiento de una red real con su propio servidor DNS interno.

---

# 🔥 Firewall – Reglas con iptables

El contenedor `firewall` actúa como un **router y firewall** entre las dos subredes del proyecto:

- `red_clientes`: `192.168.100.0/25`
- `red_servidores`: `192.168.100.128/25`

Este contenedor tiene permisos elevados (`privileged: true`) y está configurado para aplicar reglas de control de tráfico mediante `iptables`.

---

### 📁 Script de configuración

Las reglas están definidas en: `contenedor-firewall/reglasFirewall.sh`

Este script se ejecuta automáticamente al iniciar el contenedor y aplica políticas como:

---

### ⚙️ Funciones del firewall

- 🔁 Activar el reenvío de paquetes (`ip_forward`)
- 🌐 Aplicar NAT (salida a internet desde clientes)
- 🔐 Bloquear puertos por IP o MAC
- 📶 Filtrar tráfico ICMP (`ping`)
- 📨 Limitar conexiones simultáneas
- 📬 Permitir o negar servicios como FTP, HTTP, SSH, etc.

---

### 🧪 Ejemplos de reglas aplicadas

```bash
# Activar reenvío IP
echo 1 > /proc/sys/net/ipv4/ip_forward

# NAT para salida a Internet
iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE

# Bloquear acceso HTTP desde cliente2
iptables -A FORWARD -s 192.168.100.14 -p tcp --dport 80 -j REJECT

# Bloquear FTP desde cliente3
iptables -A FORWARD -s 192.168.100.3 -p tcp --dport 21 -j REJECT

# Bloquear tráfico HTTPS desde cliente3
iptables -A FORWARD -s 192.168.100.3 -p tcp --dport 443 -j REJECT

# Permitir solo SSH desde cliente2
iptables -A FORWARD -s 192.168.100.14 -p tcp --dport 22 -j ACCEPT
iptables -A FORWARD -p tcp --dport 22 -j REJECT

# Limitar conexiones simultáneas por IP (máx. 20)
iptables -A FORWARD -p tcp --syn -m connlimit --connlimit-above 20 --connlimit-mask 32 -j REJECT
```
--
## 🧪 Pruebas de reglas del firewall (`iptables`)

Las siguientes pruebas permiten verificar el funcionamiento correcto de las reglas de `iptables` aplicadas en el contenedor `firewall`. Se recomienda realizarlas desde los contenedores `cliente2` y `cliente3` según lo especificado.

---

### 🔐 Regla 1 – Bloquear HTTP (puerto 80) para cliente2

```bash
curl http://192.168.100.160
```
- En cliente2: ❌ Bloqueado
- En cliente3: ✅ Permitido

### 🔐 egla 2 – Bloquear FTP (puerto 21) para cliente3

```bash
curl -v ftp://user:pass123@192.168.100.200/
```
- En cliente2: ✅ Permitido
- En cliente3: ❌ Bloqueado

### 🔐 Regla 3 y 4 – Bloquear respuestas ICMP tipo echo-reply (ping)
```bash
ping 192.168.100.X
```
- En todos los clientes: ❌ No deberían recibir respuesta (por echo-reply bloqueado)

### 🔐 Regla 5 – Bloquear SMTP (puerto 25) por MAC (cliente2)
```bash
telnet 192.168.100.150 25
telnet smtp.gmail.com 25
```
- En cliente2: ❌ Bloqueado
- En cliente3: ✅ Permitido

### 🔐 Regla 6 – Limitar conexiones simultáneas a 20
Prueba en cliente3 usando Apache Benchmark (ab):
```bash
ab -n 100 -c 20 http://192.168.100.160/  # Permitido
ab -n 100 -c 21 http://192.168.100.160/  # ❌ Debería fallar por límite
```
- Más de 20 conexiones concurrentes generan Failed requests.
- 
### 🔐 Regla 7 – Bloquear HTTPS (puerto 443) para cliente3
```bash
curl https://google.com:443
```
- En cliente2: ✅ Permitido
- En cliente3: ❌ Bloqueado

### 🔐  Regla 8 – Permitir acceso SSH solo desde cliente2
```bash
ssh user@192.168.100.150
```
- En cliente2: ✅ Permitido
Contraseña: 123
- En cliente3, cliente1, etc.: ❌ Bloqueado

## 🔍 Cómo verificar que las reglas `iptables` están activas

Puedes comprobar si las reglas del firewall están funcionando desde el propio contenedor `firewall`.

---

### 1️⃣ Acceder al contenedor `firewall`

Desde tu terminal (host):

```bash
docker exec -it firewall bash
```

### 2️⃣ Ver reglas activas

```bash
iptables -L FORWARD -v --line-numbers
```
Buscar la regla y los paquetes que detuvó.

## 🧠 ¿Por qué es importante?
Estas reglas simulan un entorno real donde:

- Cada cliente tiene permisos distintos
- Se filtran servicios peligrosos o innecesarios
- Se controla el tráfico entre redes internas

El firewall representa la capa de seguridad perimetral de una red real, y permite poner a prueba cómo diferentes clientes pueden o no acceder a ciertos servicios.

---

## 🙌 Créditos

Este proyecto fue desarrollado como parte de una práctica de simulación de redes y servicios utilizando Docker.

### 👥 Autores

- **[Joel Narvaez Martinez](https://github.com/JoelNarvaez)** – Configuración de contenedores, proxy, Host Virtuales documentación  
- **Ana Lorena Rosales** – iptables
- **Mariel Villalpando** – DNS

### 🏫 Institución

- Proyecto académico realizado en **Universidad Autonoma de Aguascalientes**
- Materia: **Redes de computadoras**
- Profesor: **Sergio Galvan**
- Semestre: **Enero-Julio 2025**

### 🛠️ Herramientas utilizadas

- Docker / Docker Compose
- Ubuntu Server
- Apache2
- BIND9
- Squid Proxy
- iptables
- curl, ping, dig, ab, telnet, ssh, etc.

---

💡 Este documento fue creado con fines educativos y de aprendizaje.  
Todos los archivos, configuraciones y pruebas pueden modificarse libremente para adaptarse a otros entornos de red.







   
