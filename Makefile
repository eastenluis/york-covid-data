GIT_COMMIT := $(shell git rev-parse HEAD)

.PHONY: run-local
run-local:
	docker build -t yorkcovidnotifier:latest . && \
		docker run --env-file .env -p 9099:8080 yorkcovidnotifier:latest

.PHONY: plan-local
plan:
	terraform -chdir=./terraform plan -var-file build.tfvars -var "git_commit=${GIT_COMMIT}"

.PHONY: apply-local
apply:
	terraform -chdir=./terraform apply -var-file build.tfvars -var "git_commit=${GIT_COMMIT}"
