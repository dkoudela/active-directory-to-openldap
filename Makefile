.PHONY: build

build:
	docker build \
        --progress plain \
        -f ./.docker/Dockerfile \
        -t stevenlafl/ad2openldap ./

build-phpldapadmin:
	docker build \
		--progress plain \
		-f ./.docker/Dockerfile.phpldapadmin \
		-t stevenlafl/phpldapadmin ./


debug:
	docker run \
	  --rm \
	  -it \
	  -v $(shell pwd)/ldif:/app/ldif \
	  -v $(shell pwd)/schema:/app/schema \
	  -w /app \
	  -e ROOTDN="dc=example,dc=com" \
	  -e ROOTPW="secrets" \
	  -e ADDADUSERPW=false \
	  -e DEFAULTADUSERPW="topsecret" \
	  -p 389:389 \
	  -p 636:636 \
	  --entrypoint /bin/bash \
	  stevenlafl/ad2openldap

run:
	docker run \
	  --rm \
	  -it \
	  -v $(shell pwd)/ldif:/app/ldif \
	  -v $(shell pwd)/schema:/app/schema \
	  -w /app \
	  -e ROOTDN="dc=example,dc=com" \
	  -e ROOTPW="secrets" \
	  -e ADDADUSERPW=false \
	  -e DEFAULTADUSERPW="topsecret" \
	  -p 389:389 \
	  -p 636:636 \
	  stevenlafl/ad2openldap

run-phpldapadmin:
	docker run \
	  --rm \
	  -it \
	  -p 80:80 \
	  -p 443:443 \
	  stevenlafl/phpldapadmin

debug-phpldapadmin:
	docker run \
	  --rm \
	  -it \
	  --entrypoint /bin/bash \
	  stevenlafl/phpldapadmin
