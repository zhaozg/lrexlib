# Makefile for lrexlib

# See src/*/Makefile for user-definable settings

REGNAMES = gnu pcre posix oniguruma tre
PROJECT = lrexlib
VERSION = 2.6.0
PROJECT_VERSIONED = $(PROJECT)-$(VERSION)
DISTFILE = $(PROJECT_VERSIONED).zip

check:
	@for i in $(REGNAMES); do \
	  cd src/$$i && LUA_PATH="../../test/?.lua;$(LUA_PATH)" $(LUA) ../../test/runtest.lua -d. $$i && cd ../..; \
	done

doc:
	@make -C doc

dist: doc
	git2cl > ChangeLog
	cd .. && rm -f $(DISTFILE) && zip $(DISTFILE) -r $(PROJECT) -x "lrexlib/.git/*" "*.gitignore" "*.o" "*.a" "*.so" "*.so.*" "*.zip" "*SciTE.properties" "*scite.properties" && mv $(DISTFILE) $(PROJECT) && cd $(PROJECT) && unzip $(DISTFILE) && mv $(PROJECT) $(PROJECT_VERSIONED) && rm -f $(DISTFILE) && zip $(DISTFILE) -r $(PROJECT_VERSIONED) && rm -rf $(PROJECT_VERSIONED)

release:
	agrep -d 'Release' $(VERSION) NEWS | tail -n +3 | head -n -2 > release-notes && \
	git diff --exit-code && \
	git tag -a -m "Release tag" rel-`echo $(VERSION) | sed -e 's/\./-/g'` && \
	git push && git push --tags && \
	woger lua,github package=$(PROJECT) package_name=$(PROJECT) version=$(VERSION) description="Lua binding for regex libraries" notes=release-notes dist_type="zip" github_user=rrthomas
	@echo "Don't forget to upload release to github!"
	rm -f release-notes
