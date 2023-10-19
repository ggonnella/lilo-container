IMAGE_NAME="lilo"
CONTAINER_NAME="liloC"
VERSION=1.0

default:
	@echo "Create Docker image/container:"
	@echo "  make image            build Docker image from Dockerfile"
	@echo "  make image-no-cache   (same but disable cache)"
	@echo "  make container        create and run container from the image"
	@echo "  make clean            remove image and container"
	@echo ""
	@echo "Use Docker container:"
	@echo "  make shell            start shell in container"
	@echo "  make run              run default action in container"

.PHONY: image image-no-cache container clean shell version \
	      test_container_running

image:
	docker build -t $(IMAGE_NAME) .

image-no-cache:
	docker build --no-cache -t $(IMAGE_NAME) .

version:
	echo ${VERSION}

ensure_container_running:
	@if [ -z "$$(docker ps -a | grep {{CONTAINER_NAME})" ]; then \
     docker run --detach --name ${CONTAINER_NAME} ${IMAGE_NAME}; \
  else \
    docker start ${CONTAINER_NAME}; \
  fi

container:
	make ensure_container_running || \
		(make image && make ensure_container_running)

clean:
	docker container rm -f ${CONTAINER_NAME} || true
	docker image rm -f ${IMAGE_NAME} || true

shell:
	docker run --rm -ti lilo

run:
	docker exec -it ${CONTAINER_NAME} true || make container
	docker exec -it ${CONTAINER_NAME} run
