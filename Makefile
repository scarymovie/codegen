GEN_IMAGE := lock-stock-codegen
GEN_TAG := latest
API_DIR := api
CONFIG_DIR := oapi-config
OUT_DIR := external

build_codegen:
	@echo ">>> Building codegen image..."
	docker build -t $(GEN_IMAGE):$(GEN_TAG) -f codegen/Dockerfile .

generate-server: build_codegen
	@for spec in $(API_DIR)/*.yaml; do \
		name=$$(basename $$spec .yaml); \
		out_dir=$(OUT_DIR)/server/$$name; \
		echo ">>> Generating server code for $$name into $$out_dir..."; \
		mkdir -p $$out_dir; \
		docker run --rm \
			-v $(PWD):/app \
			-w /app \
			$(GEN_IMAGE):$(GEN_TAG) \
			-config $(CONFIG_DIR)/server.yaml \
			-o $$out_dir/$$name.gen.go \
			$$spec; \
	done

generate-client: build_codegen
	@for spec in $(API_DIR)/*.yaml; do \
		name=$$(basename $$spec .yaml); \
		out_dir=$(OUT_DIR)/client/$$name; \
		echo ">>> Generating client code for $$name into $$out_dir..."; \
		mkdir -p $$out_dir; \
		docker run --rm \
			-v $(PWD):/app \
			-w /app \
			$(GEN_IMAGE):$(GEN_TAG) \
			-config $(CONFIG_DIR)/client.yaml \
			-o $$out_dir/$$name.gen.go \
			$$spec; \
	done

generate: generate-server generate-client

clean:
	@echo ">>> Cleaning external..."
	rm -rf $(OUT_DIR)/*

regen: clean generate
