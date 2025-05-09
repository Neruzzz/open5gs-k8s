PREFIX = registry.gitlab.bsc.es/ppc/software/open5gs-k8s
OPEN5GS_TAG = open5gs
O5GSVERSION = 2.6.6
UERANSIM_TAG = ueransim
UERANVERSION = 3.2.6
WEBUI_TAG = webui
DEPLOYMENT_TAG = kubernetes

# Plataforma por defecto a amd64
PLATFORM = linux/amd64
NO_CACHE =

all: open5gs webui ueransim

open5gs:
	@echo "Building Open5GS version $(O5GSVERSION)..."
	docker buildx build --provenance=false $(NO_CACHE) --platform $(PLATFORM) -f open5gs/Dockerfile \
		--tag $(PREFIX)/$(DEPLOYMENT_TAG)-$(OPEN5GS_TAG)-$(PLATFORM):$(O5GSVERSION) \
		--push open5gs/
	@echo "Image pushed: $(PREFIX)/$(DEPLOYMENT_TAG)-$(OPEN5GS_TAG)-$(PLATFORM):$(O5GSVERSION)"

webui:
	@echo "Building WebUI..."
	docker buildx build --provenance=false $(NO_CACHE) --platform $(PLATFORM) -f webui/Dockerfile \
		--tag $(PREFIX)/$(DEPLOYMENT_TAG)-$(WEBUI_TAG)-$(PLATFORM):latest \
		--push webui/
	@echo "Image pushed: $(PREFIX)/$(DEPLOYMENT_TAG)-$(WEBUI_TAG)-$(PLATFORM):latest"

ueransim:
	@echo "Building UERANSIM..."
	docker buildx build --provenance=false $(NO_CACHE) --platform $(PLATFORM) -f ueransim/Dockerfile \
		--tag $(PREFIX)/$(DEPLOYMENT_TAG)-$(UERANSIM_TAG)-$(PLATFORM):$(UERANVERSION) \
		--push ueransim/
	@echo "Image pushed: $(PREFIX)/$(DEPLOYMENT_TAG)-$(UERANSIM_TAG)-$(PLATFORM):latest"

.PHONY: all open5gs webui ueransim no-cache

no-cache:
	$(MAKE) NO_CACHE=--no-cache all
