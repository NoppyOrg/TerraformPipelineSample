# <使い方>
# 1. コードの整形を行う: make fmt
# 2. planを確認する:    make plan 
# 4. デプロイ:         make apply

TERRAFORM := terraform
.DEFAULT_GOAL := fmt

.PHONY: apply
apply: plan validate init fmt-check
	$(TERRAFORM) apply -auto-approve

.PHONY: plan
plan: validate init fmt-check 
	$(TERRAFORM) plan

.PHONY: validatete
validate: init fmt-check
	$(TERRAFORM) validate

.PHONY: init
init: fmt-check
	$(TERRAFORM) init

.PHONY: fmt-check
fmt-check:
	$(TERRAFORM) fmt -recursive -check -diff

.PHONY: fmt
fmt:
	$(TERRAFORM) fmt -recursive -diff
