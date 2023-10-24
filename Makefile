OPEN5GS_TAG = open5gs
DEPLOYMENT_TAG = kubernetes

PREFIX = registry.gitlab.bsc.es/ppc/software/open5gs/

all: open5gs

open5gs:
	docker build -f open5gs/Dockerfile -t $(PREFIX)$(DEPLOYMENT_TAG)-$(OPEN5GS_TAG) .
	docker push $(PREFIX)$(DEPLOYMENT_TAG)-$(OPEN5GS_TAG)