docker-asterisk-festival
========================

This is a work in progress

This container exposes the following volumes:
```
/etc/asterisk
```

## Building the image
```
$ sudo docker build -t="oggers/asterisk-festival" .
```

## Creating a container
```
$ sudo docker run --name asterisk -d oggers/asterisk-festival

# map config on the host
$ sudo docker run -v <config dir on host>:/etc/asterisk -d oggers/asterisk-festival

# test container
$ sudo docker run --rm -it oggers/asterisk-festival /bin/bash
```
