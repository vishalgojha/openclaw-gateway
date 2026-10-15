# Heartbeat Rules

On every check:
1. Look at MEMORY.md and memory/YYYY-MM-DD.md for bills and reminders.
2. Find any bills that are UNPAID and due_date == today (YYYY-MM-DD). 
   If any exist, send ONE concise nudge listing them. Do NOT repeat if you already nudged today.
3. Find any reminders with done=false and due_at is today (or overdue but not done). 
   Nudge once if due today or within the past 24 hours and not acknowledged.
4. If nothing needs attention, respond with exactly: HEARTBEAT_OK

Rules:
- Never send more than 2 proactive messages per day total.
- Active hours: 07:00–23:00 IST only.
- Be concise (1–3 lines max). No paragraphs.
- Do NOT infer or invent amounts/dates. Only act on what is recorded.
- Never message anyone except the allowed sender.
