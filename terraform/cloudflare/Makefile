

apply:
	sops -i -d .env ; \
	export $$(xargs <.env) ; \
	terraform apply ; \
	sops -i -e .env

plan:
	sops -i -d .env ; \
	export $$(xargs <.env) ; \
	terraform plan ; \
	sops -i -e .env
