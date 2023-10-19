ARG BEAM_PYTHON=apache/beam_python3.8_sdk

FROM $BEAM_PYTHON

# Pass maxmind token as arg so we can commit this to version control
ARG MAXMIND_TOKEN

# Friendly message to help people not forget the arg.
RUN ["/bin/bash", "-c", ": ${MAXMIND_TOKEN:?Build argument needs to be set and not null. Use this form: --build-arg MAXMIND_TOKEN='<TOKEN>'}"]

# Install geoip python library
RUN pip install --no-cache-dir geoip2==4.4.0

# Install polars since it's not preinstalled in apache beam
RUN pip install --no-cache-dir polars

# Manually install version 7 of pyarrow. (Not technically supported by apache-beam yet, but it works ok and is needed for the dataflow job.)
RUN pip install --no-cache-dir pyarrow==7.0.0

# Download and unpack latest maxmind City, ASN, and Country databases
RUN for i in City ASN Country; do wget -qO- https://download.maxmind.com/app/geoip_download\?edition_id\=GeoLite2-${i}\&license_key\=${MAXMIND_TOKEN}\&suffix\=tar.gz | tar xvz; done
# Remove version names from extracted directories for easy access by using defined names.
RUN for i in City ASN Country; do mv GeoLite2-${i}_* GeoLite2-${i}; done

# Download and install latest maxmind C library
# Use the github API to get the latest release,
# and then use grep to find the needed key, cut to get the value from the 
# json key, and tr to remove the quotes around the key.
# lastly pass the result to wget to download and extract in place.
RUN curl -s https://api.github.com/repos/maxmind/libmaxminddb/releases/latest \
    | grep "browser_download_url.*tar.gz" \
    | cut -d : -f 2,3 \
    | tr -d \" \
    | xargs wget -qO- -\
    | tar xvz
# Remove version name from folder, and install the C libraries using make
RUN mv libmaxminddb-* libmaxminddb
WORKDIR "/libmaxminddb"
RUN ./configure
RUN make
RUN make install
RUN ldconfig
WORKDIR "/"
