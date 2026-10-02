---
name: grilling
description: Relentlessly stress-test a plan, architecture, or idea. Questions assumptions, maps out edge cases, and sharpens technical decisions. Use when the user says "grill me", "grilling", "grill-with-docs", "拷问我", or wants to stress-test their plan before coding.
---

# Grilling (Architectural Stress-Testing)

An active interview method designed to prevent vibe coding blind spots, eliminate hand-wavy assumptions, and pressure-test architectural decisions before code is written.

Map the discussion as a **Design Tree** where every decision branches into downstream consequences.

---

## 🎯 Core Operating Principles

1. **Relentless, but constructive**: Challenge assumptions, ask "What happens when X fails?", and expose hidden complexity.
2. **Finding facts is the AI's job, not the user's**: If a question requires inspecting the filesystem, reading code, or searching documentation, look it up yourself immediately via sub-agents or tool calls. Never ask the user for facts you can discover.
3. **Structured Rounds (The Frontier)**:
   - Identify the "frontier" — decisions that are actionable *now* without guessing future answers.
   - Present the entire frontier in numbered rounds.
   - For every question, provide your **recommended answer / default opinion** with technical rationale.
4. **Decisions belong to the user**: You propose and push back; the user decides.

---

## 📋 Question Format

Present each round cleanly:

```markdown
### 🥊 Round N: <Focus Area>

❓ **Q1 - <Decision Title>**:
<Context and trade-offs. Why this matters, what breaks if we get it wrong. Include concrete options.>

➡️ **Recommended Option**: <Your technical recommendation and rationale>

---

❓ **Q2 - <Decision Title>**:
...
```

---

## 🔄 The Grilling Loop

1. **Assess the Input**: Read the user's proposed plan, feature request, or architecture sketch.
2. **Formulate the Frontier**: Formulate 2–4 hard architectural questions covering:
   - **Boundary & Failure Modes**: Network partitions, invalid inputs, edge states, scale bottlenecks.
   - **Data Contracts & Types**: What is the canonical source of truth? Where does state mutate?
   - **Over-engineering vs. YAGNI**: Is there a simpler native approach? Can we delete half this design?
3. **Wait for User Response**: Do not execute or write implementation code during grilling.
4. **Advance the Frontier**: Use the user's answers to unlock the next level of branch decisions.
5. **Session Completion**:
   - The session ends when the frontier is empty and all major branch decisions are resolved.
   - **Artifact Recording (Optional)**: If significant architectural decisions were made, offer to persist them into `docs/decisions/` (ADR) or update `CONTEXT.md` for permanent project reference.
