HUB_PUBLISHER?=datacrate

build:
<<<<<<< HEAD
	@docker build -t ${HUB_PUBLISHER}/spark-history:3.0.0-hadoop3.2 -f Dockerfile . --no-cache
=======
	@docker build -t ${HUB_PUBLISHER}/spark-history:3.0.0-hadoop3.2 -f Dockerfile .
>>>>>>> a0009e8657c4cde15e0a272b31f51a3bc5376e6f

push:
	@docker push ${HUB_PUBLISHER}/spark-history:3.0.0-hadoop3.2

login:
	@docker login --username ${HUB_PUBLISHER} --password ${HUB_PASSWORD}