## TRIAD_PROTOCOL_V1.md

### Purpose
To define the standard communication framework between GPT, Cline, and A-Frame.

---

### Folder Roles
- **triad_whiteboard/** — GPT-initiated tasks, concepts, and directives.  
- **triad_reports/** — Cline responses, confirmations, and diagnostic feedback.  
- **triad_plans/** — Joint strategic planning and versioned coordination documents.  
- **triad_logs/** — Automated outputs, summaries, or build results.  
- **triad_private/** — Confidential or local-only content (excluded via .gitignore).

---

### Workflow Sequence
1. **GPT → Cline** : Post directive in triad_whiteboard/  
2. **Cline → GPT** : Execute, then post report in triad_reports/  
3. **GPT → A-Frame** : Summarize key outcomes in triad_plans/  
4. **All Agents** : Record system or process updates in triad_logs/

---

### Commit Etiquette
- Prefix commits with actor name:  
  - GPT: “GPT → Cline …”  
  - Cline: “Cline → GPT …”  
  - A-Frame: “A-Frame Note …”  
- Keep one task per commit.  
- Reference related files in message body.

---

### Security
- No sensitive data in tracked files.  
- triad_private/ remains local-only.

---

### Goal
Enable autonomous, traceable collaboration between agents with minimal human mediation.
