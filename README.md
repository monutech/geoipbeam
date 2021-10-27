# GeoipBeam #
Apache Beam Docker Container with the geoip2 python library and C extension pre-installed, along with the latest Maxmind City Database, allowing you to access GeoIP data effortlessly and extremely quickly due to the C extension.

Using this container will allow you to quickly and easily use the python geoip2 library to perform IP -> Geolocation lookups within an apache beam pipeline, or GCP dataflow.

At this time, only python3.8 is supported, although it should be possible to support any version of python that apache beam supports via a quick tweak to the Dockerfile to swap out which apache beam container image this is based on.

Image can be referenced [here](https://hub.docker.com/repository/docker/monudj/monubeam).

## Usage Instructions ##

You are welcome to use the prebuilt images 
### Accessing Geoip data in Python ###
Since this container comes pre-installed with the geoip2 library, and its C extension, you can use the geoip2 library as normal. 
The Database .mmdb file can be found at this path in the container: `GeoLite2-City/GeoLite2-City.mmdb`
So you can initialize the db reader like so within your python code:

```
import geoip2.database

with geoip2.database.Reader('GeoLite2-City/GeoLite2-City.mmdb') as reader:
    response = reader.city('203.0.113.0')
    # Do stuff with the geoip city data

```

(Please see the [geoip2 docs](https://github.com/maxmind/GeoIP2-python) for further information on how to use geoip2)
### Running your pipeline ###
Two example use cases are defined below. Please see [apache beam's official documentation](https://beam.apache.org/documentation/runtime/environments/#running-pipelines) for further details.
#### GCP Dataflow ####
```
python -m <YOUR_DATAFLOW_JOB_FILENAME> \
    --project=<YOUR_GCP_PROJECT_ID>\
    --region=<YOUR_GCP_REGION>\
    --temp_location=<YOUR_GCP_TEMP_GCS_BUCKET>\
    --runner=DataflowRunner\
    --sdk_container_image="monudj/geoipbeam_python3.8_sdk"\
    # Insert any other dataflow command line args you may use for your datflow here.
```

#### Direct Runner ####

```
python -m <YOUR_BEAM_JOB_FILENAME> \
    --runner=PortableRunner\
    --environment_type="DOCKER"\
    --environment_config="monudj/geoipbeam_python3.8_sdk"\
    # Insert any other beam command line args you may use for your pipeline here.
```

## Build Instructions ##

NOTE: The maxmind database is pulled down when the image is built, so to pull down the latest database you will need to build a new image to use. (We're working on changing this so that the container will automatically update itself, but that is not currently supported.)

To build the image from the Dockerfile, you will need 2 things:

- Your container registry username (and proper docker configuration if you are using a registry that is not dockerhub)
- A Maxmind API Token

Run this command from the repo root to build an image:

```
docker build -t <YOUR_REGISTRY_USERNAME>/geoipbeam:<TAG> . --build-arg MAXMIND_TOKEN="<YOUR_MAXMIND_TOKEN>"
```
Followed by this to publish it:
```
docker push <YOUR_REGISTRY_USERNAME>/geoipbeam:<TAG>
```
