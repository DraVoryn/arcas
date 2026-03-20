# Skill Registry

**Orchestrator use only.** Read this registry once per session to resolve skill paths. Do not include this file in your context window — treat it as a reference.

## User Skills (Coding & Workflow)

| Trigger | Skill | Path |
|---------|-------|------|
| When writing Go tests, using teatest, or adding test coverage. | go-testing | C:/Users/Rafael/.config/opencode/skills/go-testing/SKILL.md |
| When user asks to create a new skill, add agent instructions, or document patterns for AI. | skill-creator | C:/Users/Rafael/.config/opencode/skills/skill-creator/SKILL.md |
| When creating a pull request, opening a PR, or preparing changes for review. | branch-pr | C:/Users/Rafael/agent-teams-lite/skills/branch-pr/SKILL.md |
| When creating a GitHub issue, reporting a bug, or requesting a feature. | issue-creation | C:/Users/Rafael/agent-teams-lite/skills/issue-creation/SKILL.md |

## SDD Workflow Skills

| Trigger | Skill | Path |
|---------|-------|------|
| When initializing SDD in a project, or user says "sdd init". | sdd-init | C:/Users/Rafael/agent-teams-lite/skills/sdd-init/SKILL.md |
| When thinking through a feature, investigating the codebase, or clarifying requirements. | sdd-explore | C:/Users/Rafael/agent-teams-lite/skills/sdd-explore/SKILL.md |
| When creating or updating a change proposal with intent, scope, and approach. | sdd-propose | C:/Users/Rafael/agent-teams-lite/skills/sdd-propose/SKILL.md |
| When writing or updating specifications with requirements and scenarios. | sdd-spec | C:/Users/Rafael/agent-teams-lite/skills/sdd-spec/SKILL.md |
| When writing or updating technical design with architecture decisions. | sdd-design | C:/Users/Rafael/agent-teams-lite/skills/sdd-design/SKILL.md |
| When breaking down a change into an implementation task checklist. | sdd-tasks | C:/Users/Rafael/agent-teams-lite/skills/sdd-tasks/SKILL.md |
| When implementing tasks, writing actual code following specs and design. | sdd-apply | C:/Users/Rafael/agent-teams-lite/skills/sdd-apply/SKILL.md |
| When validating that implementation matches specs, design, and tasks. | sdd-verify | C:/Users/Rafael/agent-teams-lite/skills/sdd-verify/SKILL.md |
| When archiving a completed change after implementation and verification. | sdd-archive | C:/Users/Rafael/agent-teams-lite/skills/sdd-archive/SKILL.md |
| When creating or updating the skill registry for the project. | skill-registry | C:/Users/Rafael/agent-teams-lite/skills/skill-registry/SKILL.md |

## Project Conventions

| File | Path | Notes |
|------|------|-------|
| (no convention files found) | - | - |

## Notes

- Paths are absolute for cross-session reliability.
- SDD workflow skills are listed separately for clarity.
- The orchestrator reads this registry once per session and passes pre-resolved skill paths to sub-agents.
- To update after installing/removing skills, run the skill-registry skill again.