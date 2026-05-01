SKILLS_DIR  := skills
GLOBAL_DIR  := $(HOME)/.agents/skills
SKILL_DIRS  := $(wildcard $(SKILLS_DIR)/devo*)
SKILL_NAMES := $(notdir $(SKILL_DIRS))

# Override install destination: make install DEST=/custom/path
DEST ?= $(GLOBAL_DIR)

.DEFAULT_GOAL := help
.PHONY: help install install-project uninstall uninstall-project validate list

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "  install            Install all skills to $(GLOBAL_DIR)"
	@echo "  install-project    Install all skills to .agents/skills/ in the current directory"
	@echo "  install DEST=X     Install all skills to a custom path"
	@echo "  uninstall          Remove skills from $(GLOBAL_DIR)"
	@echo "  uninstall DEST=X   Remove skills from a custom path"
	@echo "  uninstall-project  Remove skills from .agents/skills/"
	@echo "  validate           Validate SKILL.md files (requires skills-ref)"
	@echo "  list               List skills in this repo"

install:
	@mkdir -p $(DEST)
	@$(foreach d,$(SKILL_DIRS),rm -rf $(DEST)/$(notdir $(d)) && cp -r $(d) $(DEST)/ && echo "  installed: $(notdir $(d)) -> $(DEST)";)
	@echo ""
	@echo "Installed $(words $(SKILL_DIRS)) skill(s) to $(DEST)"

install-project:
	@mkdir -p .agents/skills
	@$(foreach d,$(SKILL_DIRS),rm -rf .agents/skills/$(notdir $(d)) && cp -r $(d) .agents/skills/ && echo "  installed: $(notdir $(d)) -> .agents/skills";)
	@echo ""
	@echo "Installed $(words $(SKILL_DIRS)) skill(s) to .agents/skills"

uninstall:
	@$(foreach n,$(SKILL_NAMES), \
		test -d $(DEST)/$(n) && rm -rf $(DEST)/$(n) && echo "  removed: $(n)" || true;)
	@echo "Uninstalled $(words $(SKILL_NAMES)) skill(s) from $(DEST)"

uninstall-project:
	@$(foreach n,$(SKILL_NAMES), \
		test -d .agents/skills/$(n) && rm -rf .agents/skills/$(n) && echo "  removed: $(n)" || true;)
	@echo "Uninstalled $(words $(SKILL_NAMES)) skill(s) from .agents/skills"

validate:
	@if command -v skills-ref >/dev/null 2>&1; then \
		$(foreach d,$(SKILL_DIRS),skills-ref validate $(d);) \
	else \
		echo "skills-ref not found — see https://github.com/agentskills/agentskills"; \
		echo "Basic check:"; \
		$(foreach d,$(SKILL_DIRS), \
			test -f $(d)/SKILL.md \
				&& echo "  ok: $(d)/SKILL.md" \
				|| echo "  MISSING: $(d)/SKILL.md";) \
	fi

list:
	@echo "Skills in this repo:"
	@$(foreach n,$(SKILL_NAMES),echo "  $(n)";)
