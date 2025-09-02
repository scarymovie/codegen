GEN_IMAGE := example-codegen
GEN_TAG := latest
API_DIR := api
CONFIG_DIR := oapi-config
OUT_DIR := external

build_codegen:
	@echo ">>> Building codegen image..."
	docker build -t $(GEN_IMAGE):$(GEN_TAG) -f codegen/Dockerfile .

# --- OpenAPI: Server ---
generate-server: build_codegen
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
			$(GEN_IMAGE):$(GEN_TAG) \
			"oapi-codegen -config $(CONFIG_DIR)/server.yaml -package $$name -o $$out_dir/$$name.gen.go $$spec"; \
	done

# --- OpenAPI: Client ---
generate-client: build_codegen
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
			$(GEN_IMAGE):$(GEN_TAG) \
			"oapi-codegen -config $(CONFIG_DIR)/client.yaml -package $$name -o $$out_dir/$$name.gen.go $$spec"; \
	done

# --- AsyncAPI ---
generate-asyncapi: build_codegen
	@set -e; \
	SPECS="$(wildcard $(API_DIR)/*.asyncapi.yml $(API_DIR)/*.asyncapi.yaml)"; \
	if [ -z "$$SPECS" ]; then \
		echo "No AsyncAPI specs matched (*.asyncapi.yml|*.asyncapi.yaml) in $(API_DIR)"; \
		exit 0; \
	fi; \
	for spec in $$SPECS; do \
		name=$$(basename $$spec | sed -E 's/\.asyncapi\.ya?ml$$//'); \
		out_dir=$(OUT_DIR)/asyncapi/$$name; \
		echo ">>> Generating asyncapi code for $$name into $$out_dir..."; \
		mkdir -p $$out_dir; \
		docker run --rm \
			-v $(PWD):/app \
			-w /app \
			$(GEN_IMAGE):$(GEN_TAG) \
			"asyncapi generate fromTemplate $$spec @asyncapi/go-watermill-template -o $$out_dir --force-write"; \
	done


# --- Orchestration ---
generate: generate-server generate-client generate-asyncapi

clean:
	@echo ">>> Cleaning external..."
	rm -rf $(OUT_DIR)/*

regen: clean generate
