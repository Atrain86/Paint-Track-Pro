# 🧠 AI Triad Collaboration Protocol

## Overview
The AI Triad system operates as a three-part intelligence pipeline:

- **A-Frame (Pipeline Czar):** Creative executive authority, approves all merges and decisions.
- **ChatGPT (Strategic Systems Intelligence):** Designs and prepares execution plans.
- **Cline (Execution Engineer):** Executes commands within VS Code and reports progress.

---

## 🧩 Folder Roles

| Folder | Purpose | Access |
|---------|----------|--------|
| `triad_whiteboard/` | Active collaboration, shared notes | GPT + Cline |
| `triad_plans/` | Strategic prompts, blueprints | GPT + Cline |
| `triad_reports/` | Cline status updates, logs | GPT + Cline |
| `triad_logs/` | Automatic commit logs | GPT + Cline |
| `triad_private/` | Executive-only (ignored via .gitignore) | A-Frame + GPT |

---

## ⚙️ Operational Flow

1. **PLAN Mode:**  
   - GPT drafts and refines complete execution strategies.  
   - A-Frame reviews and approves.

2. **TOGGLE (Ready for Act):**  
   - A-Frame gives the go-ahead (`⌘⇧A`).  
   - Cline activates execution phase.

3. **ACT Mode:**  
   - Cline performs all code-level actions, commits reports into `/triad_reports/`.

4. **DEBRIEF:**  
   - GPT reviews Cline’s reports, summarizes key results into `/triad_whiteboard/`.

---

## 🧱 Safety Rules

- A-Frame never edits partial code.
- GPT provides full files only.
- Cline executes within pre-approved contexts.
- All actions logged in `/triad_logs/`.

---

## 🔐 Security Notes

- `triad_private/` excluded via `.gitignore`
- Local credentials stored securely via macOS Keychain
- All pushes via HTTPS and authenticated tokens

---

## 🚀 Goal

To maintain a **self-sustaining, intelligent collaboration environment** where GPT, Cline, and A-Frame coordinate seamlessly through GitHub—eliminating manual copy-paste and maximizing focus on executive decision-making.

