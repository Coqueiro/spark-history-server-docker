HUB_PUBLISHER?=datacrate

build:
	@docker build -t ${HUB_PUBLISHER}/spark-history:3.0.0-hadoop3.2 -f Dockerfile .

push:
	@docker push ${HUB_PUBLISHER}/spark-history:3.0.0-hadoop3.2

login:
	@docker login --username ${HUB_PUBLISHER} --password ${HUB_PASSWORD}