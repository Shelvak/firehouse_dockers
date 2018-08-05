# Firehouse Docker Compose

## Instalación y configuración

### Permisos para entrypoints
Primero es necesario establecer permiso de ejecución para los scripts que corren en los contenedores

```bash
$ chmod +x docker-logio/start.sh
$ chmod +x docker-broadcast/start.sh
$ chmod +x docker-firehouse/start.sh
```

## Iniciar compose
```
$ sudo docker-compose build
$ sudo docker-compose run -d
```
