ARG BEAM_PYTHON

FROM apache/${BEAM_PYTHON:?Build argument needs to be set and not null. Use this form: --build-arg BEAM_PYTHON='<PYTHON-BEAM-VERSION>:VERSION'}

# Pass maxmind token as arg so we can commit this to version control
ARG MAXMIND_TOKEN
# Friendly message to help people not forget the arg.
RUN ["/bin/bash", "-c", ": ${MAXMIND_TOKEN:?Build argument needs to be set and not null. Use this form: --build-arg MAXMIND_TOKEN='<TOKEN>'}"]

# Install geoip python library
RUN pip install --no-cache-dir geoip2==4.4.0

# Download and unpack latest maxmind database
RUN wget -qO- https://download.maxmind.com/app/geoip_download\?edition_id\=GeoLite2-City\&license_key\=${MAXMIND_TOKEN}\&suffix\=tar.gz | tar xvz
RUN mv GeoLite2-City_* GeoLite2-City

# Download and install maxmind C library
RUN wget -qO- https://github.com/maxmind/libmaxminddb/releases/download/1.6.0/libmaxminddb-1.6.0.tar.gz | tar xvz
RUN mv libmaxminddb-* libmaxminddb
WORKDIR "/libmaxminddb"
RUN ./configure
RUN make
RUN make install
RUN ldconfig
WORKDIR "/"