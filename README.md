# **map-service**

This repo provides a scaffold for defining a map service in a Kubernetes or Docker environment. It is not a complete project as it lacks security controls, scaling procedures and others.

<br>

## **Docker**
#
### Docker folder
  * **docker-compose.yaml** - defines the services
  * **.env** file - defines useful env variables
  * **files** folder - contains resources for the initialization of the project

#### Deploying:
    Docker$ docker-compose up
    
Upload geographical data to Postgres. You can find them at **[Europe Maps](https://download.geofabrik.de/europe.html)**:

    Docker$ osm2pgsql -c -U db-user -d db-data -W -P 30432 -H localhost romania-latest.osm 

Re-deploy so that **mapproxy** can generate a default configuration ( this is step is not needed if you provide the configuration by mounting it in the container):

    Docker$ docker-compose down && docker-compose up -d

You can now access the map( you can use QGIS Destkop ):
* http://localhost:9090/wms - through the cache
* http://localhost:32080/ows/?MAP=/data/romania.qgs direct rendering
<br>

## **K8s**
#

**!! You need to configure a NFS server. This is not covered !!**

Create a namespace:

    $ kubectl create namespace gis

Create a storage-class:

    k8s/storage $ kubectl apply -f qgis-static-storage.yaml 
    storageclass.storage.k8s.io/qgis-static-storage created

Create a pv:
    k8s/storage $ kubectl  apply -f postgres-qgis-data.yaml 
    persistentvolume/postgres-qgis-data created

Create a secret for the postgres and postgres connections:

    k8s/database$ kubectl -n gis apply -f secret-config.yaml 
    secret/postgres-secret created

Create postgres statefulset and service:

    k8s/database$ kubectl -n gis apply -f postgres.yaml 
    statefulset.apps/postgres-primary created
    service/postgres-primary created

Populate database:

    k8s/database$ osm2pgsql -c -U db-user -d db-data -W -P 31432 -H worker-01 romania-latest.osm

Deploy qgis:

    k8s/qgis$ kubectl -n gis apply -f qgis.yaml
    deployment.apps/qgis created
    service/qgis-service created

Deploy mapproxy:

    k8s/mapproxy$ kubectl -n gis apply -f mapproxy.yaml 
    deployment.apps/mapproxy created
    service/mapproxy-service created


You can now access the map( you can use QGIS Destkop ):
* http://worker-01:32080/ows/?MAP=/data/romania.qgs - direct rendering
* http://worker-01:30090/wms - through the cache