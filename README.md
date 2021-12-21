
# Dart OpenWhisk function templates

<p align="center">
  <img src="preview/logo.png" />
</p>

This repository contains [OpenWhisk](https://openwhisk.apache.org/) function templates for writing serverless functions in the [Dart](https://dart.dev/) programming language.


## Usage

1. Make sure OpenWhisk has been deployed to your Kubernetes cluster and the OpenWhisk CLI tool has been installed. See [here](https://github.com/NicklasXYZ/selfhosted-serverless) and [here](https://github.com/NicklasXYZ/selfhosted-serverless/blob/main/OpenWhisk.md) for a brief introduction on how to do this.

2. Download the Dart function templates from this repo and enter into the main directory:

```bash
git clone https://github.com/nicklasxyz/dart_openwhisk && \
cd dart_openwhisk
```

3. Add new functionality to the function that is going to be deployed and managed by OpenWhisk:

``` bash
code template/function/lib/src/function_base.dart
# ... Inside this file extend or add whatever you want to below the 'handleRequest' function  
```

Note: The files and directories in the `dart_openwhisk/template` directory are a part of a usual Dart project, but structured specifically for use with OpenWhisk. All new functionality should primarily be implemented as a part of the `function` package residing in the `dart_openwhisk/template/function/` directory. Extra dependencies should be added to the respective `pubspec.yaml` files in the root of the `template` or in the `template/function` directory. The project can be compiled and tested locally as usual. See the forllowing [README.md](template/README.md) for more information.

4. Build and push the function:

```bash
# Define your docker image name and function name below
export FUNC_NAME=  # For example: test-function
export IMAGE_NAME= # For example: username/test-function:latest

# Then build and push the docker image to Docker Hub:
docker build template --tag $IMAGE_NAME && docker push $IMAGE_NAME
```

5. Create a package and deploy the serverless function:

```bash
wsk -i package create demo && \
wsk -i action create /guest/demo/$FUNC_NAME --docker $IMAGE_NAME --web true

# To remove function deployments run:
wsk -i action delete /guest/demo/$FUNC_NAME
```

6. Wait a few seconds, then we can invoke the function by sending a request through curl:

```bash
### Retrieve function invocation URL
export FUNC_URL=$(wsk -i action get /guest/demo/$FUNC_NAME --url | tail -1)

### Example GET request
curl -k \
  -X GET $FUNC_URL; \
  echo

# If nothing was changed in the 'dart_openwhisk/template/function' 
# directory before deployment then we should just see the default response:
>> Hello from OpenWhisk & Dart!

### Example POST request:
curl -k \
  -d "{\"name\": \"Peter\", \"age\": \"42\", \"height\": \"180.5\"}" \
  -H "Content-Type: application/json" \
  -X POST $FUNC_URL; \
  echo

# If nothing was changed in the 'dart_openwhisk/template/function'
# directory before deployment then we should just see the default response:
>> [{"string_field":"Peter"}, {"int_field":42}, {"double_field":180.5}]
```

For more information on how other request methods work see the [OpenWhisk API gateway docs](https://github.com/apache/openwhisk/blob/master/docs/apigateway.md)