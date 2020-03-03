FROM lambci/lambda:build-provided

LABEL maintainer="Kyle Barron <kylebarron2@gmail.com>"

# Install system dependencies
RUN yum install -y make sqlite-devel zlib-devel bash git gcc-c++

# Create a directory and copy in all files
RUN mkdir -p /opt
RUN git clone https://github.com/mapbox/tippecanoe.git /opt/tippecanoe --depth 1
WORKDIR /opt/tippecanoe

# Build tippecanoe
RUN make \
  && make install

# Run the tests
CMD make test
