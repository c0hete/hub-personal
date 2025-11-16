# [CONTEXT:MONITOR] SESSION TRACKING

**Purpose:** Monitor context usage and warn before degradation  
**Target:** Maximize productivity within plan limits

---

## [LIMITS:PLAN] [L10]

**Your plan limits (adjust as needed):**
```
Messages per conversation: ~50-60 (estimate)
Optimal range: 1-40 messages
Warning zone: 41-50 messages
Critical zone: 51+ messages (start new session)
```

**Context window:**
```
Sonnet 4.5: 200K tokens input
Effective working range: 0-150K tokens
Warning zone: 150K-180K tokens
Critical: 180K+ tokens (quality drops)
```

---

## [TRACKING:METHOD] [L30]

**Claude self-monitors by:**

1. **Message count tracking**
   - Count messages in current conversation
   - Warn at message #40
   - Suggest new session at #50

2. **Context complexity**
   - Simple Q&A: Low impact
   - Code generation: Medium impact
   - Multiple file edits: High impact
   - Full doc updates: Critical impact

3. **Quality indicators**
   - Responses getting slower
   - More clarification questions
   - Less precise code
   - Forgetting recent context

---

## [BEHAVIOR:RULES] [L55]

**At message #40:**
```
⚠️ Context Warning

We're at ~40 messages. Context is getting heavy.

Options:
A. Continue (5-10 more messages safe)
B. Start new session now (optimal)
C. Wrap up current task, then new session

Recommendation: [based on current task complexity]
```

**At message #50:**
```
🔴 Context Critical

We're at ~50 messages. Quality may degrade.

STRONGLY RECOMMEND:
1. Save current work
2. Generate session summary
3. Start fresh conversation
4. Paste 04_SESSION_START.md
5. Continue with clean context

Continue anyway? (not recommended)
```

**At message #60+:**
```
❌ Context Saturated

We're past 60 messages. Responses will be:
- Slower
- Less accurate
- May forget recent context
- May hallucinate details

REQUIRED ACTION:
1. End this session
2. Generate UPDATES.md
3. New conversation mandatory
```

---

## [EFFICIENCY:MODES] [L105]

**To maximize your plan:**

### **Sprint Mode (high efficiency)**
```
Use when: Clear task, focused work
Pattern:
- Load context (1 msg)
- Task description (1 msg)
- Code generation (1 msg)
- Iteration if needed (2-3 msgs)
- Summary (1 msg)
Total: ~6-8 messages per task

Optimal for: Model creation, migrations, single features
```

### **Development Mode (balanced)**
```
Use when: Multiple related tasks
Pattern:
- Load context (1 msg)
- Multiple tasks (15-20 msgs)
- Iterations and fixes (10-15 msgs)
- Summary (1 msg)
Total: ~30-40 messages per session

Optimal for: Feature development, multiple files
```

### **Planning Mode (low efficiency, avoid)**
```
Use when: Discussions, architecture decisions
Pattern:
- Back and forth discussions
- "What if" scenarios
- Comparisons

⚠️ WARNING: Burns messages fast with low output
Better: Use docs for planning, Claude for coding
```

---

## [TRACKING:TEMPLATE] [L150]

**Claude provides status every 10 messages:**

```
[Message #10] ━━━━━━━━━━░░░░░░░░░░ 20% | Status: ✅ Fresh
[Message #20] ━━━━━━━━━━━━━━░░░░░░ 40% | Status: ✅ Good
[Message #30] ━━━━━━━━━━━━━━━━━░░░ 60% | Status: ✅ Stable
[Message #40] ━━━━━━━━━━━━━━━━━━━░ 80% | Status: ⚠️ Heavy
[Message #50] ━━━━━━━━━━━━━━━━━━━━ 100%| Status: 🔴 Critical
```

---

## [OPTIMIZATION:TIPS] [L165]

**Get more from each session:**

### ✅ DO:
- Paste 04_SESSION_START.md ONCE at start
- Ask for complete code (not step-by-step)
- Batch related questions together
- Request "generate all files for User feature"
- Use clear, specific prompts

### ❌ DON'T:
- Re-paste SESSION_START multiple times
- Ask "what do you think?" (discussion)
- Request explanations of generated code
- Ask about alternatives or comparisons
- Small incremental changes (batch them)

---

## [SESSION:TEMPLATES] [L190]

**Efficient session patterns:**

### **Pattern 1: Feature Complete (optimal)**
```
[1] Paste SESSION_START
[2] "Create User authentication feature:
     - Model with avatar, timezone
     - Migration with fields
     - Controller with CRUD
     - Policy for authorization
     - Test with 3 cases
     
     Generate all files complete, ready to copy."

[3-4] Copy files, test, fix if needed
[5] "Session summary"

Total: 5 messages = 1 complete feature ✅
```

### **Pattern 2: Multiple Models (good)**
```
[1] Paste SESSION_START
[2] "Create models: User, Note, Tag with migrations and tests"
[3-8] Iterations and fixes
[9] "Session summary"

Total: 9 messages = 3 models ✅
```

### **Pattern 3: Discussion (inefficient - avoid)**
```
[1] "Should I use Vue or Livewire?"
[2-15] Discussion, comparisons, pros/cons
[16] "Ok, I'll use Vue"

Total: 16 messages = 0 code ❌
Better: Docs already decided (Vue), skip discussion
```

---

## [QUALITY:INDICATORS] [L235]

**Signs you need new session:**

🔴 **Critical (stop immediately):**
- Claude forgets what you just said
- Contradicts earlier responses
- Generates code that doesn't match MASTER.md
- Asks about decisions already in docs
- Repeats same question multiple times

⚠️ **Warning (finish task, then restart):**
- Responses getting longer/verbose
- More cautious language ("I think", "maybe")
- Asks for clarification on clear prompts
- Code quality slightly lower
- Takes longer to respond

✅ **Healthy:**
- Direct, concise responses
- Code matches conventions exactly
- No clarification questions on clear prompts
- Fast response times
- Remembers session context

---

## [EMERGENCY:PROTOCOL] [L265]

**If context corrupted mid-session:**

```
1. Stop immediately
2. Don't try to fix in same session
3. Note what you were doing
4. Start new conversation
5. Paste SESSION_START
6. Add: "Previous session got corrupted at [task].
         Starting fresh. Continue from: [specific point]"
```

---

## [AUTOMATION:HELPERS] [L280]

**PowerShell helpers (create these):**

```powershell
# session_start.ps1
Get-Content .\docs\04_SESSION_START.md | Set-Clipboard
Write-Host "✅ SESSION_START copied to clipboard"

# message_counter.ps1
# Manual tracking (since Claude can't count perfectly)
$count = Read-Host "Current message number"
if ($count -gt 40) {
    Write-Host "⚠️ WARNING: Context getting heavy" -ForegroundColor Yellow
    Write-Host "Consider starting new session" -ForegroundColor Yellow
}
if ($count -gt 50) {
    Write-Host "🔴 CRITICAL: Start new session NOW" -ForegroundColor Red
}
```

---

## [PROMPTS:INTEGRATION] [L305]

**Add to 03_PROMPTS.md:**

```markdown
## [RULES:CONTEXT_TRACKING]

**Every 10 messages, display status bar:**
[Message #20] ━━━━━━━━━━━━━━░░░░░░ 40% | Status: ✅ Good

**At message #40:**
Display warning, offer to wrap up

**At message #50:**
Display critical warning, strongly suggest new session

**At message #60:**
Refuse to continue, require new session

**Always prioritize:**
- Complete code over explanations
- Batch operations over incremental
- Efficiency over discussion
```

---

## [COST:OPTIMIZATION] [L330]

**Maximize value per message:**

### **High value messages:**
```
✅ Complete feature generation (1 msg = full feature)
✅ Multiple file creation (1 msg = 5 files)
✅ Batch fixes (1 msg = fix 3 issues)
✅ Session summary (1 msg = full update guide)
```

### **Low value messages (minimize):**
```
❌ "Explain this code" (read docs instead)
❌ "What's the difference between X and Y?" (decide before asking)
❌ "Should I...?" (docs have decisions)
❌ Small incremental tweaks (batch them)
```

**Rule of thumb:**
Each message should produce ≥5 lines of usable code
Or advance project state significantly

---

## [TRACKING:MANUAL] [L360]

**You track manually:**

```
Session Log (keep in notepad):
---
Session #1 - 2025-11-15 09:00
Messages: 38
Output: User model, Note model, migrations
Quality: ✅ Excellent
New session needed: No

Session #2 - 2025-11-15 11:00  
Messages: 52
Output: Auth controllers, policies
Quality: ⚠️ Degraded at msg 48
New session needed: YES

Session #3 - 2025-11-15 14:00
Messages: 25
Output: Tag system complete
Quality: ✅ Excellent
New session needed: No
```

---

**[CONTEXT:MONITOR:END]** [L390]

This system helps you:
- Maximize output per session
- Avoid wasted messages
- Know when to restart
- Stay within plan limits
- Maintain code quality
