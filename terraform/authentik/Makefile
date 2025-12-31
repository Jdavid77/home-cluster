

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

destroy:
	sops -i -d .env ; \
	export $$(xargs <.env) ; \
	terraform destroy ; \
	sops -i -e .env

refresh:
	sops -i -d .env ; \
	export $$(xargs <.env) ; \
	terraform refresh ; \
	sops -i -e .env	