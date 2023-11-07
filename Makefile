OPEN5GS_TAG = open5gs
UERANSIM_TAG = ueransim
WEBUI_TAG = webui
DEPLOYMENT_TAG = kubernetes

PREFIX = registry.gitlab.bsc.es/ppc/software/open5gs/

NO_CACHE = 

all: webui open5gs

open5gs:
	docker build $(NO_CACHE) -f open5gs/Dockerfile -t $(PREFIX)$(DEPLOYMENT_TAG)-$(OPEN5GS_TAG) open5gs/
	docker push $(PREFIX)$(DEPLOYMENT_TAG)-$(OPEN5GS_TAG)

webui:
	docker build $(NO_CACHE) -f webui/Dockerfile -t $(PREFIX)$(DEPLOYMENT_TAG)-$(WEBUI_TAG) webui/
	docker push $(PREFIX)$(DEPLOYMENT_TAG)-$(WEBUI_TAG)

# ueransim: webui
# 	docker build $(NO_CACHE) -f ueransim/Dockerfile -t $(PREFIX)$(DEPLOYMENT_TAG)-$(UERANSIM_TAG) ueransim/
# 	docker push $(PREFIX)$(DEPLOYMENT_TAG)-$(UERANSIM_TAG)

.PHONY: all open5gs webui no-cache

no-cache:
	$(MAKE) NO_CACHE=--no-cache all