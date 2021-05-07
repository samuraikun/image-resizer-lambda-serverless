# image-resizer-lambda-serverless
AWS Lambda to resize image when upload image to specific S3 bucket.

## Runtime
- Ruby2.7

## Deploy & Resource Setting
- Serverless Framework

## Setup

#### required
- Docker
- AWS Account & AWS CLI

### Add AWS credential

```bash
$ touch docker.env
```

`docker.env`

```bash
AWS_ACCESS_KEY_ID=xxx
AWS_DEFAULT_REGION=ap-northeast-1
AWS_SECRET_ACCESS_KEY=xxx
```

### docker-compose

```bash
$ docker-compose build
$ docker-compose --rm run serverless sh

sh-4.2# bundle config set path 'vendor/bundle'
sh-4.2# bundle install
```

## Debug Lambda

### use `bundle exec ruby` in docker-compose
For example, you insert `binding.irb` in `handler.rb` for debug.

You command below

```bash
sh-4.2# bundle exec ruby handler.rb
```

### docker-lambda
- WIP

## Deploy

```bash
sh-4.2# sls deploy

# Remove Resources
sh-4.2# sls remove
```

## Lambda Layer
deploy [`libvips`](https://github.com/libvips/libvips) to lambda layer for native extendions.

use https://github.com/customink/ruby-vips-lambda

```
$ git clone https://github.com/customink/ruby-vips-lambda.git
$ cd ruby-vips-lambda
$ ./bin/deploy
```

#### If you deploy to layer other region(not us-east-1)
- change `AWS_DEFAULT_REGION` in `ruby-vips-lambda/bin/deploy`

```
#!/bin/bash

set -e

./bin/build

export VIPS_VERSION=$(cat share/VIPS_VERSION)
export LAYER_NAME="rubyvips${VIPS_VERSION//./}-27"

# change here
export AWS_REGION=${AWS_REGION:=ap-northeast-1}

aws lambda publish-layer-version \
  --region $AWS_REGION \
  --layer-name $LAYER_NAME \
  --description "Libvips for Ruby FFI." \
  --zip-file "fileb://share/libvips.zip"
```
