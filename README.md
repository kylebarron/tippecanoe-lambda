# tippecanoe-lambda

Tippecanoe Lambda layer

## Layers

I've currently uploaded layers to four regions in the U.S. These layers include
binaries for `tippecanoe` and `tile-join`. If you want other binaries, uncomment
the `cp` lines at the end of the Dockerfile.

| Region       | ARN                                                             |
|--------------|-----------------------------------------------------------------|
| us-east-1    | arn:aws:lambda:us-east-1:961053664803:layer:tippecanoe-lambda:1 |
| us-east-2    | arn:aws:lambda:us-east-2:961053664803:layer:tippecanoe-lambda:1 |
| us-west-1    | arn:aws:lambda:us-west-1:961053664803:layer:tippecanoe-lambda:1 |
| us-west-2    | arn:aws:lambda:us-west-2:961053664803:layer:tippecanoe-lambda:1 |

To use them, just include the layer ARN of the same region as your function. The
binaries are then located in `/opt`. So to call Tippecanoe from Python, you can
do

```py
from subprocess import run
cmd = ['/opt/tippecanoe', '--version']
r = run(cmd, capture_output=True)
print(r.stderr)
# tippecanoe v1.35.0
```

These layers were generated from the Tippecanoe master branch on 2020-03-03,
from [commit ddb7993][ddb7993].

[ddb7993]: https://github.com/mapbox/tippecanoe/commit/ddb79937d932f753edd5fba994b23281ff45f19c


## Developing

To build the Docker image:
```bash
git clone https://github.com/kylebarron/tippecanoe-lambda
cd tippecanoe-lambda
export VERSION="0.1.0"
# You can change this tag if you'd like
# Just make sure you provide the same tag below
docker build . -t "kylebarron/tippecanoe-lambda:$VERSION"
```

Then use `img2lambda` to extract the lambda layer. (Note, really all this does
is extract the binaries from the docker image. It's probably easier to just
export the binary artifacts from the Docker step above, but I didn't take time
to figure out how to do that. PRs welcome.) You can download binaries from its
[Github releases
page](https://github.com/awslabs/aws-lambda-container-image-converter/releases).


```bash
# Export zip files to output/layer*.zip
img2lambda \
    --image "kylebarron/tippecanoe-lambda:$VERSION" \
    --image-type docker \
    --dry-run
```

`img2lambda` extracts each binary into a separate zip file, but I'd prefer to
have them combined them into one. The following just unzips the binaries in each
zip file and merges them.

```bash
cd output
# Extracts `tile-join`
unzip '*.zip'
# Creates tippecanoe-lambda.zip
zip tippecanoe-lambda tile-join tippecanoe
```

Now use the AWS CLI to upload a new lambda layer. Choose the desired region.
```bash
# Still in output/
export REGION="us-east-1"
aws lambda publish-layer-version \
        --region "$REGION" \
        --layer-name tippecanoe-lambda \
        --description "Tippecanoe lambda layer" \
        --zip-file fileb://tippecanoe-lambda.zip \
        --license-info "BSD-2-Clause"
# Make public
# From https://github.com/developmentseed/geolambda#create-a-new-version
aws lambda add-layer-version-permission \
    --region "$REGION" \
    --layer-name tippecanoe-lambda \
	--statement-id public \
    --version-number 1 \
    --principal '*' \
	--action lambda:GetLayerVersion
```