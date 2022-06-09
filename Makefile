.PHONY: build

build:
	docker build \
        --progress plain \
        -f ./.docker/Dockerfile \
        -t stevenlafl/ad2openldap ./

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
	  --entrypoint /bin/bash \
	  stevenlafl/ad2openldap
