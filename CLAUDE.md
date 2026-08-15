# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# Le Quint Mobile

## START HERE

Before doing anything:

1. Read docs/project/PROJECT_STATUS.md
2. Read docs/ai/claude-development-guide.md
3. Read docs/project/decisions.md
4. Read docs/architecture/architecture.md
5. Read the SPEC associated with the current TASK
6. Read docs/ux/
7. Inspect the existing web application when business behavior is involved.

The repository documentation is persistent context.
Do not depend on previous conversations.

Before modifying any code, confirm that you have read and understood
the relevant project documentation, SPEC, TASK, architecture, and UX requirements.

If a critical contradiction or missing decision is found, stop and ask
before implementing.

## CURRENT OBJECTIVE

Implement only the TASK explicitly selected by the user.

Use PROJECT_STATUS.md to determine the implementation order
and dependencies.

Do not implement future TASKs automatically.

## IMPORTANT

There is an existing functional hotel management web application.

The mobile app is a complementary product.

Do not reinvent existing business rules.

Use the existing web application as the reference for
existing business behavior, domain models, permissions,
and Firebase data structures.

Do not modify the web application or its backend behavior
without explicit approval.

## UI/UX

Read:

docs/ux/design-system.md
docs/ux/design-tokens.md
docs/ux/visual-direction.md
docs/ux/components.md
docs/ux/interaction.md
docs/ux/references.md

Visual references are located at:

docs/design-references/

Use them as visual direction, not as literal screenshots to copy.

You may improve UI/UX decisions within the Design System.