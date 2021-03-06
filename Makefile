# Minimal makefile for Sphinx documentation
#

# You can set these variables from the command line.
SPHINXOPTS    =
SPHINXBUILD   = sphinx-build
SPHINXPROJ    = sdp-reference-architectures
SOURCEDIR     = .
BUILDDIR      = docs/_build
ORG_NAME      = boozallen
REPO_NAME     = sdp-iac

.PHONY: help Makefile docs build live deploy 

# Put it first so that "make" without argument is like "make help".
help: ## Show target options
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

clean: ## removes compiled documentation and jpi 
	rm -rf $(DOCSDIR)/$(BUILDDIR) build bin 

docs-image: ## builds container image for building the documentation
	docker build . -f docs/Dockerfile -t $(REPO_NAME)-docs

docs: ## builds documentation in _build/html 
      ## run make docs live for hot reloading of edits during development
	make clean
	make docs-image 
	$(eval goal := $(filter-out $@,$(MAKECMDGOALS)))
	@if [ "$(goal)" = "live" ]; then\
		cd $(DOCSDIR);\
		docker run -p 8000:8000 -v $(shell pwd):/app $(REPO_NAME)-docs sphinx-autobuild -b html $(ALLSPHINXOPTS) . $(BUILDDIR)/html -H 0.0.0.0;\
		cd - ;\
	elif [ "$(goal)" = "deploy" ]; then\
                docker run -v $(shell pwd):/app $(REPO_NAME)-docs $(SPHINXBUILD) -M html "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O);\
		git add docs/*;\
		git commit -m "updating documentation";\
		git push;\
	else\
		docker run -v $(shell pwd):/app $(REPO_NAME)-docs $(SPHINXBUILD) -M html "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O) ;\
	fi

deploy: ; 
live: ;

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	echo "Make command $@ not found" 
