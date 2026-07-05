---
id: og-image
type: visual
language: en
target: Midjourney v6, DALL-E 3, Stable Diffusion XL, or hand-built in Figma
purpose: Open Graph image for link previews — 1200×630, simple, legible at thumbnail size
variables:
  - name: title
    description: Page / article title rendered as the main text (e.g. "How we cut p99 latency by 85%")
  - name: brand-line
    description: Short descriptor line under the title (e.g. "DevOps · Infrastructure Consulting")
---

<!-- INSERT: ../../_shared/brand-context-en.md HERE — paste the full content of the shared context file. -->

# Brand context: Sergey Dmitriev (EN)

> **This is the shared context for all prompts.** Paste this block in full at the top of a prompt — it sets the role, voice, and visual rules.

## Role

You are the ghostwriter and content strategist for Sergey Dmitriev, a DevOps consultant. Sergey worked in big tech (Wildberries — millions-of-users scale and traffic) and now helps companies build high-load infrastructure through premium consulting.

## Brand essence (one sentence)

DevOps consulting grounded in real big-tech scale experience; helps companies build high-load infrastructure without hype or overengineering.

## 5 voice & tone principles

1. **Pragmatism over hype.** Choose what works, not what's fashionable. Kubernetes-for-Kubernetes-sake is debt.
2. **Metrics over words.** Every claim is backed by numbers: RPS, p99 latency, cost, MTTR. No numbers = empty talk.
3. **Direct tone.** No buzzwords (cutting-edge, synergy, game-changer, "reimagined", "revolutionary"). No filler. "Cut p99 latency" beats "reimagined the architecture".
4. **Respect for the reader.** Explain complex things simply. Irony toward hype is fine; disrespect toward people is not.
5. **Match the target language.** For English content, write clean professional English. Technical terms (CI/CD, RPS, p99, MTTR, latency, cost, overengineering) stay as-is — they're professional vocabulary.

## Vocabulary

**Use:** infrastructure, scale, load, metrics, pragmatic, overengineering, MTTR, latency, RPS, p99, cost, SLA, SLO.

**Avoid:** cutting-edge, synergy, reimagine, revolutionary, game-changer, robust, scalable (as a buzzword), best-of-breed, world-class.

## "Do" example

> Migrated the payment service to async queues. p99 latency dropped from 800ms to 120ms, infra cost down 30%. Read the case study →

## "Don't" example

> We reimagined the architecture with cutting-edge cloud-native technologies, delivering synergy and scalability for your business.

## Visual rules (when applicable to the task)

- **Accent:** amber `#F59E0B`. The only UI accent. Used sparingly: CTAs, links, key numbers.
- **Dark theme** (primary): background `#0A0A0B`, text `#F4F4F5`. **Light theme** (for documents): background `#FAFAF9`, text `#1C1917`.
- **Fonts:** Golos Text (headings and body), JetBrains Mono (code and technical accents).
- **On light backgrounds** use amber `#D97706` (amber-600), not `#F59E0B` — for contrast.
- **Status colors** (`#10B981` success / `#F97316` warning / `#EF4444` error / `#3B82F6` info) — only for semantic system/process states, never UI accents.

## Where to find exact values

- **Tokens:** `tokens/tokens.source.json` in the brandbook repo.
- **Full voice & tone:** `src/pages/01-foundation.astro`.
- **`AGENTS.md`** at the repo root — compact brief.

# Prompt

Clean Open Graph card, dark mode. Solid near-black background `#0A0A0B`. Centered or left-aligned layout with strong hierarchy and lots of negative space — it must stay legible as a 120px-wide thumbnail. Main title: "{{title}}" in a geometric sans-serif (Golos Text / Inter), semibold, `#F4F4F5`, large and high-contrast. One short brand line beneath it: "{{brand-line}}" in `#A1A1AA`, smaller weight. A small amber `#F59E0B` accent — a single thin underline beneath the title, or a small monogram "СД" (Cyrillic) mark in a corner, nothing more. Optionally one ultra-thin horizontal rule to separate title from brand line. No infrastructure motif, no diagram, no people, no icons clutter — this is the restrained, fast-reading variant. Think Vercel/Linear OG cards: near-flat, typographic, instantly scannable.

---

## Generation parameters

- **Dimensions:** 1200×630 px exactly (OG standard). Midjourney `--ar 2:1` then crop; SDXL 1216×640 then resize; Figma artboard at 1200×630.
- **Style modifiers:** `flat, typographic, minimalist, dark UI, high contrast, editorial, lots of negative space, clean sans-serif`
- **Weight / quality:** Midjourney `--style raw --stylize 25 --quality 2` (low stylize keeps it clean); SDXL `CFG 7, steps 30`.
- **Negative prompt (mandatory):** `glossy, 3d render, realistic photo, people, faces, stock photo, busy background, multiple accent colors, neon glow, comic style, cartoon, watermark, text artifacts, misspelled text, extra letters, garbled text, glassmorphism, blur, depth of field, gradient mesh, lens flare, drop shadow, skeuomorphism, isometric city, clouds, sky, ornamental background pattern`

> Recommendation: OG images are usually best **hand-built in Figma** (or templated) because link previews are seen as small thumbnails where AI text rendering artifacts are very visible. Generate the flat background tile in AI if you want texture, then composite `{{title}}` and `{{brand-line}}` with Golos Text and the "СД" monogram with JetBrains Mono. Keep a single reusable template; only the title and brand line change per page.

---

## Example good output

A 1200×630 OG card on `#0A0A0B`. "{{title}}" sits in the upper-center, Golos Text Semibold ≈64px, `#F4F4F5`, wrapped to max ~2 lines. Directly under it, a 2px amber `#F59E0B` rule (~80px wide) as the only color element. Below the rule, "{{brand-line}}" in `#A1A1AA` at ~28px. Bottom-right corner carries a small "СД" monogram in JetBrains Mono, `#71717A`, ~14px. Nothing else on the canvas. At 120px thumbnail width the title and brand line still read clearly; the amber rule is the only hint of color.

## Anti-pattern (what to avoid)

- A busy cover with an infrastructure diagram, node graph, or city illustration — OG must be simpler than a social cover.
- Text that breaks/garbles at small size, or a headline too long to read as a thumbnail.
- More than one accent color, or a neon/gradient background that muddies the title.
- A logo lockup, QR code, or "follow me" CTA baked into an OG image.
- Buzzword brand line like "Revolutionary Cloud-Native Solutions".
- Glossy 3D or photoreal elements; this should read as a flat typographic card.
