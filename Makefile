BASE_TAG = base-open5gs
OPEN5GS_TAG = open5gs
DEPLOYMENT_TAG = kubernetes

PREFIX = registry.gitlab.bsc.es/ppc/software/open5gs/

all: open5gs

baseopen: 
	docker build -f base/Dockerfile -t $(PREFIX)$(BASE_TAG)-$(DEPLOYMENT_TAG) .
	docker push $(PREFIX)$(BASE_TAG)-$(DEPLOYMENT_TAG)
open5gs: baseopen
	docker build -f open5gs/Dockerfile -t $(PREFIX)$(OPEN5GS_TAG)-$(DEPLOYMENT_TAG) .
	docker push $(PREFIX)$(OPEN5GS_TAG)-$(DEPLOYMENT_TAG)