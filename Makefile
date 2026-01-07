GEN_IMAGE_OAPI := example-codegen-oapi
GEN_IMAGE_ASYNCAPI := example-codegen-asyncapi
GEN_TAG := latest
API_DIR := api
CONFIG_DIR := oapi-config
OUT_DIR := external

build-openapi:
	@echo ">>> Building OpenAPI codegen image..."
	docker build -t $(GEN_IMAGE_OAPI):$(GEN_TAG) -f codegen/Dockerfile.openapi .

# --- OpenAPI: Server ---
generate-server: build-openapi
	@set -e; \
	SPECS="$(wildcard $(API_DIR)/*.openapi.yml $(API_DIR)/*.openapi.yaml)"; \
	if [ -z "$$SPECS" ]; then \
		echo "No OpenAPI specs matched (*.openapi.yml|*.openapi.yaml) in $(API_DIR)"; \
		exit 1; \
	fi; \
	for spec in $$SPECS; do \
		name=$$(basename $$spec | sed -E 's/\.openapi\.ya?ml$$//'); \
		out_dir=$(OUT_DIR)/server/$$name; \
		echo ">>> Generating server code for $$name into $$out_dir..."; \
		mkdir -p $$out_dir; \
		docker run --rm \
			-v $(PWD):/app \
			-w /app \
			$(GEN_IMAGE_OAPI):$(GEN_TAG) \
			"oapi-codegen -config $(CONFIG_DIR)/server.yaml -package $$name -o $$out_dir/$$name.gen.go $$spec"; \
	done

# --- OpenAPI: Client ---
generate-client: build-openapi
	@set -e; \
	SPECS="$(wildcard $(API_DIR)/*.openapi.yml $(API_DIR)/*.openapi.yaml)"; \
	if [ -z "$$SPECS" ]; then \
		echo "No OpenAPI specs matched (*.openapi.yml|*.openapi.yaml) in $(API_DIR)"; \
		exit 1; \
	fi; \
	for spec in $$SPECS; do \
		name=$$(basename $$spec | sed -E 's/\.openapi\.ya?ml$$//'); \
		out_dir=$(OUT_DIR)/client/$$name; \
		echo ">>> Generating client code for $$name into $$out_dir..."; \
		mkdir -p $$out_dir; \
		docker run --rm \
			-v $(PWD):/app \
			-w /app \
			$(GEN_IMAGE_OAPI):$(GEN_TAG) \
			"oapi-codegen -config $(CONFIG_DIR)/client.yaml -package $$name -o $$out_dir/$$name.gen.go $$spec"; \
	done

# --- Orchestration ---
generate: generate-server generate-client

clean:
	@echo ">>> Cleaning external..."
	rm -rf $(OUT_DIR)/*

regen: clean generate
