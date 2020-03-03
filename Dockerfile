FROM lambci/lambda:build-provided

LABEL maintainer="Kyle Barron <kylebarron2@gmail.com>"

# Install system dependencies
RUN yum install -y make sqlite-devel zlib-devel bash git gcc-c++

# Create a build directory; clone tippecanoe; and copy in all files
RUN mkdir -p /build
RUN git clone https://github.com/mapbox/tippecanoe.git /build/tippecanoe --depth 1
WORKDIR /build/tippecanoe

# Build tippecanoe
RUN make \
  && make install

# Run the tests
CMD make test

# Copy binaries to `/opt`
RUN cp ./tippecanoe /opt/tippecanoe
RUN cp ./tippecanoe-decode /opt/tippecanoe-decode
RUN cp ./tippecanoe-enumerate /opt/tippecanoe-enumerate
RUN cp ./tippecanoe-json-tool /opt/tippecanoe-json-tool
RUN cp ./tile-join /opt/tile-join
