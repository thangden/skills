---
name: aos
description: >-
  Dùng skill này bất cứ khi nào user muốn setup workspace AI cho team — kể cả
  các cách nói như: setup cho team mình, setup workspace để Claude giúp team,
  cấu hình CLAUDE.md + agents + memory + hooks, onboarding workspace mới cho
  team, bootstrap AI layer, setup hệ điều hành AI, init .claude/ từ đầu, setup
  5 layers cho team, demo AOS setup, repo chưa có gì setup giùm mình, hoặc bất
  kỳ ý định nào muốn Claude hoạt động như thành viên thật sự của team. Tạo đầy
  đủ 5 layers (CLAUDE.md, .claude/memory/, .claude/rules/, .claude/hooks/,
  .claude/agents/) cho mọi team: BD, MKT, OPS, Tech FE/BE, Product — qua
  interview thông minh tự scan context.
---

# Skill: AOS — Agentic OS Setup

Skill này tự động khởi tạo kiến trúc 5-Layers Agentic OS (Kernel → Memory → Rules → Hooks → Agents/Skills) cho bất kỳ team hoặc role nào. Output là workspace hoàn chỉnh kèm `demo-prompts.md` để test ngay sau khi setup.

---

## PHASE 0A: CONTEXT SCAN

**Chạy trước mọi thứ — không hỏi gì cho đến khi scan xong.**

Đọc workspace theo thứ tự ưu tiên (dừng khi đủ context, tối đa 5 files):

1. `README.md` — project description, team info, tech stack
2. `package.json` hoặc `pyproject.toml` / `pom.xml` / `Cargo.toml` — language & framework
3. `CLAUDE.md` (nếu có) — existing rules, personas, constraints
4. Top-level folder structure (`ls -la`) — workflow hints từ tên folder
5. `.env.example` hoặc `docker-compose.yml` — environment / service hints

**Giới hạn scan:** tối đa 5 files, bỏ qua file > 50KB, **không bao giờ đọc `.env` thật**.

Sau khi scan, hiển thị summary dạng này để user confirm:

```
🔍 Mình đã scan workspace và infer được:
- Team type: [Tech FE / Tech BE / Non-tech / Unknown]
- Tech stack: [Next.js 15 + TypeScript / Python FastAPI / N/A]
- Primary workflow hint: [từ tên folder: proposals/, content/, reports/...]
- Existing AOS config: [Có CLAUDE.md / Chưa có gì]

Mình sẽ bỏ qua câu hỏi về những thông tin đã rõ.
Có gì cần đính chính không? (yes = tiếp tục / hoặc nói điều cần sửa)
```

**Mapping inference → câu hỏi bị skip trong Phase 1:**

| Infer được từ scan | Bỏ qua câu hỏi |
|---|---|
| README có mô tả team/role rõ | [1] Team & Role |
| `package.json` / lockfile có framework | Phần tech stack của câu [6] |
| Folder `proposals/`, `content/`, `reports/`... tồn tại | Câu [3] Folder Structure |
| `CLAUDE.md` có red lines / safety constraints | Câu [4] và [5] |

Nếu user xác nhận đúng → skip câu hỏi tương ứng trong Phase 1.
Nếu user đính chính → ghi nhận, hỏi lại đúng câu đó.
Nếu không infer được gì (repo trống không có README) → bỏ qua, vào Phase 1 bình thường.

---

## PHASE 0B: DETECTION GATE

**Sau khi scan xong, kiểm tra workspace:**

1. Kiểm tra xem `.claude/` có tồn tại không
2. Nếu **CÓ** → list ra những gì đang có:

```
⚠️  Mình thấy workspace đã có:
- .claude/agents/: [danh sách file]
- .claude/skills/: [danh sách file]
- CLAUDE.md: [có / không]

Bạn muốn:
(A) Setup mới hoàn toàn — ghi đè những gì có sẵn
(B) Chỉ tạo những phần còn thiếu — giữ nguyên file cũ
```

3. Nếu user chọn **(B)** → hiển thị **Dry-run Preview** trước khi tạo bất kỳ file nào:

```
📋 Dry-run Preview — những file sẽ được tạo hoặc bỏ qua:
✅ Tạo mới: CLAUDE.md (chưa có)
✅ Tạo mới: .claude/memory/ (chưa có)
⏭  Bỏ qua: .claude/agents/bd-senior.md (đã tồn tại — giữ nguyên)
✅ Tạo mới: .claude/skills/[anchor-workflow].md

Xác nhận tiếp tục? (yes / no)
```

4. Nếu user chọn **(A)** hoặc `.claude/` không tồn tại → tiếp tục Phase 1 bình thường.

**STOP-LOSS nếu workspace ambiguous:** Nếu detect thấy nhiều CLAUDE.md từ nhiều project khác nhau → hỏi user xác nhận đây là workspace đúng trước khi tiếp tục.

---

## PHASE 1: DYNAMIC INTERVIEW

**Quy tắc:**

- Hỏi **từng câu một**, chờ trả lời mới hỏi tiếp
- Không đánh số tiến độ kiểu "Câu 1/6" — hỏi tự nhiên như đồng nghiệp
- Nếu user trả lời một câu chứa nhiều thông tin → gộp, bỏ qua câu liên quan
- **Bỏ qua câu đã có đáp án từ Phase 0A scan** — không hỏi lại

**STOP-LOSS:** Nếu sau 3-4 câu user vẫn trả lời mơ hồ ("không biết", "tuỳ bạn", "làm gì cũng được") → DỪNG ngay. Không sinh file. Trả về: *"AOS cần thông tin cụ thể về workflow và output structure để setup đúng. Vui lòng chuẩn bị rõ hơn rồi gõ lại `/aos`."*

**6 câu cần thu thập (có thể kết hợp, có thể skip nếu đã infer):**

**[1] Team & Role**
> "Bạn đang setup workspace cho team/role nào? Team đó làm công việc gì chính?"

**[2] Anchor Use Case** *(quan trọng nhất — không được bỏ qua)*
> "Mô tả workflow quan trọng nhất của team: từ **input gì** → qua **những bước nào** → ra **output gì**?
> Ví dụ: Meeting note → Research công ty → Draft proposal → Proposal hoàn chỉnh"

**[3] Folder Structure**
> "Output đó thường lưu vào folder nào? Ngoài ra bạn còn có folder nào thường làm việc không?"
> *(Dùng để đặt tên path-based rules. Ví dụ: `proposals/`, `outreach/`, `content/`, `campaigns/`)*

**[4] Red Lines**
> "Kể 2-3 điều AI tuyệt đối KHÔNG được làm hoặc cam kết trong workspace này."

**[5] Safety Constraints**
> "Thông tin gì không được phép share hoặc cam kết khi chưa có approval?"
> *(Ví dụ: pricing matrix, contract terms, client data, internal roadmap)*

**[6] Tone & Domain Knowledge**
> "Giọng văn của team: professional, casual, data-driven, creative...?
> Và agent cần biết gì đặc thù về domain của team?" *(ICP, pricing tiers, objection handling, kỹ thuật...)*

---

## PHASE 2: GENERATION

Sau khi thu thập đủ thông tin — **không hỏi thêm** — tạo files theo thứ tự từ Layer 1 đến Layer 5.

---

### Layer 1 — Kernel

**`CLAUDE.md`** — Hiến pháp, bắt buộc dưới 200 dòng:

- Team description + primary mission
- ICP / đối tượng phục vụ của team
- 2-3 golden rules (từ red lines Phase 1)
- Default output format (markdown với headers rõ ràng)
- Giọng văn chuẩn

**`SOUL.md`** — Runtime policies:

- Điều agent được phép làm
- Safety constraints: thông tin không được share/cam kết (từ Phase 1 câu [5])
- Tone guide chi tiết
- Red lines dưới dạng bullet list

---

### Layer 2 — Memory

Tạo folder **`.claude/memory/`** với 3 thành phần cốt lõi:

**`.claude/memory/system-knowledge.md`** — Long-term architectures & decisions index:

- Seed với 3-5 entries từ thông tin Phase 1
- Format mỗi entry: `- [Quyết định/fact quan trọng ~150 chars] → [link file chi tiết nếu có]`

**`.claude/memory/active-context.md`** — Active state & Sprint tracking:

```markdown
# Active Context & Trajectory
Nguồn Jira Ticket / Backlog chính hiện tại. Chỉnh sửa theo list này:

## In Progress
- [ ] Customize agent persona với domain knowledge thật của team

## To Do
- [ ] Test anchor use case end-to-end lần đầu
- [ ] Tham chiếu kiến thức thực tế và ghi vào system-knowledge.md

## Done
- [x] Setup AI OS 5 layers
```

**`.claude/memory/episodic/`** — Tạo folder rỗng + file ngày hôm nay `YYYY-MM-DD.md`:

- Ghi lại log ngắn gọn: team setup, anchor use case đã chọn, các quyết định kiến trúc chính

---

### Layer 3 — Rules

Tạo **3 files** trong `.claude/rules/`, tên dynamic theo input:

**File 1: `brand-voice.md`** — Không có `paths` (load globally mọi lúc):
```yaml
---
description: [Team] brand voice và communication standards — load globally
---
```
Nội dung: tone guide, từ ngữ không dùng, cách viết chuẩn của team.

**File 2: `[primary-folder]-rules.md`** — Tên = primary output folder (ví dụ: `proposal-rules.md`):
```yaml
---
description: Rules cho [primary task] — chỉ load khi làm việc với [primary-folder]/
paths: ["[primary-folder]/**"]
---
```
Nội dung: cấu trúc bắt buộc của output chính, checklist trước khi finalize.

**File 3: `[secondary-folder]-rules.md`** — Tên = secondary folder (ví dụ: `outreach-rules.md`):
```yaml
---
description: Rules cho [secondary task] — chỉ load khi làm việc với [secondary-folder]/
paths: ["[secondary-folder]/**"]
---
```
Nội dung: rules đặc thù cho task phụ.

---

### Layer 4 — Hooks

**`.claude/settings.json`**:
```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/quality-gate.sh"
          }
        ]
      }
    ]
  }
}
```

**`.claude/hooks/quality-gate.sh`** — Quality Gate + Memory Guard.

Có hai variant tùy theo team type được infer ở Phase 0A:

**Variant A — Non-tech teams (BD, MKT, OPS):** file-based checks, không dùng git commands:
```bash
#!/bin/bash
# Stop hook — Quality Gate & Memory Guard

OUTPUT_DIR="[primary-folder-từ-phase1]"
MIN_LINES=5
ERRORS=0

# -- 1. Output Check --
if [ ! -d "$OUTPUT_DIR" ]; then
  echo "⚠ Chưa thấy output trong $OUTPUT_DIR — nếu task cần tạo file, hãy kiểm tra lại." >&2
else
  LATEST=$(find "$OUTPUT_DIR" -maxdepth 2 -name "*.md" -newer "$OUTPUT_DIR" 2>/dev/null | head -1)
  if [ -n "$LATEST" ]; then
    LINE_COUNT=$(wc -l < "$LATEST")
    if [ "$LINE_COUNT" -lt "$MIN_LINES" ]; then
      echo "BLOCKED: File $LATEST chỉ có $LINE_COUNT dòng — có vẻ chưa hoàn chỉnh." >&2
      ERRORS=1
    else
      echo "✓ Output check passed — $LATEST ($LINE_COUNT dòng)" >&2
    fi
  fi
fi

# -- 2. Memory Guard --
MEMORY_DIR=".claude/memory"
if [ -d "$MEMORY_DIR" ]; then
  RECENT_MEM=$(find "$MEMORY_DIR" -type f -mmin -30 2>/dev/null)
  if [ -n "$RECENT_MEM" ]; then
    echo "✓ Memory updated" >&2
  else
    echo "BLOCKED: Kỷ Luật Thép - Chưa cập nhật bộ nhớ!" >&2
    echo "Rule: Đánh dấu [x] vào active-context.md hoặc ghi log vào episodic/!" >&2
    ERRORS=1
  fi
fi

[ "$ERRORS" -eq 1 ] && { echo "Quality gate FAILED." >&2; exit 2; }
echo "All checks PASSED ✓" >&2
exit 0
```

**Variant B — Tech teams (FE, BE, Full-stack):** thêm git-aware checks, dùng `find` thay glob để portable:
```bash
#!/bin/bash
# Stop hook — Quality Gate & Memory Guard (Tech variant)

ERRORS=0

# -- 1. Secret Detection (git-aware) --
if git rev-parse --git-dir > /dev/null 2>&1; then
  if git diff --cached 2>/dev/null | grep '^\+' | grep -v '^\+\+\+' \
     | grep -iE "(password|secret|api_key|token)\s*=\s*['\"][^'\"]{8,}" > /dev/null 2>&1; then
    echo "BLOCKED: Hardcoded secret detected in staged changes!" >&2; ERRORS=1
  else
    echo "✓ Secret scan passed" >&2
  fi
  # .env guard
  if git diff --cached --name-only 2>/dev/null | grep -E '^\.env$' > /dev/null 2>&1; then
    echo "BLOCKED: .env staged — do not commit credentials!" >&2; ERRORS=1
  fi
fi

# -- 2. Output Check (dùng find, không dùng glob /**/) --
SRC_DIR="[primary-source-dir-từ-phase1]"   # vd: apps/web/src/components
if [ -d "$SRC_DIR" ]; then
  LATEST=$(find "$SRC_DIR" -type f \( -name "*.ts" -o -name "*.tsx" \) -newer "$SRC_DIR" 2>/dev/null | head -1)
  if [ -n "$LATEST" ]; then
    LINE_COUNT=$(wc -l < "$LATEST")
    [ "$LINE_COUNT" -lt 5 ] && { echo "BLOCKED: $LATEST too short ($LINE_COUNT lines)" >&2; ERRORS=1; } \
                             || echo "✓ Code check passed — $LATEST" >&2
  fi
fi

# -- 3. Memory Guard --
MEMORY_DIR=".claude/memory"
if [ -d "$MEMORY_DIR" ]; then
  RECENT_MEM=$(find "$MEMORY_DIR" -type f -mmin -30 2>/dev/null)
  [ -n "$RECENT_MEM" ] && echo "✓ Memory updated" >&2 \
    || { echo "BLOCKED: Memory not updated — check active-context.md!" >&2; ERRORS=1; }
fi

[ "$ERRORS" -eq 1 ] && { echo "Quality gate FAILED." >&2; exit 2; }
echo "All checks PASSED ✓" >&2
exit 0
```

> **Lưu ý khi generate:**
>
> - Chọn Variant A cho Non-tech (BD, MKT, OPS), Variant B cho Tech (FE, BE, Full-stack)
> - Thay `[primary-folder]` / `[primary-source-dir]` bằng folder thật từ câu [3] / Phase 0A scan
> - Không dùng bash glob `**/*.ext` — dùng `find` để portable trên macOS (bash 3.x)
> - Script dùng `>&2` để Claude nhận feedback từ hook

---

### Layer 5 — Agents + Skill

**Agent 1: `.claude/agents/[team]-senior.md`** — Tên dynamic theo team:
```yaml
---
name: [team]-senior
description: [Mô tả persona — kinh nghiệm, domain knowledge, communication style, từ Phase 1 câu [6]]
model: sonnet
tools: []
---

# [Team] Senior Agent

## Persona
[Chi tiết: background, kinh nghiệm, cách suy nghĩ]

## Domain Knowledge
[Kiến thức đặc thù từ Phase 1: ICP, pricing, objection handling, technical knowledge...]

## Red Lines
[Những điều agent này không được làm — từ Phase 1 câu [4] và [5]]
```

**Agent 2: `.claude/agents/research-analyst.md`** — Cố định, không thay đổi:
```yaml
---
name: research-analyst
description: Read-only research specialist. Thorough, factual, always flags uncertainty. Never writes or edits files.
model: haiku
tools: [Read, Grep, Glob]
---

# Research Analyst Agent

## Persona
Systematic researcher. Biết cách đào thông tin, luôn cite source, không hallucinate.
Khi không chắc → ghi rõ "Chưa verify được" thay vì đoán.

## Approach
- Đọc nhiều nguồn trước khi kết luận
- Trả về structured summary với confidence level
- Flag mọi thông tin cần verify thêm
```

**Skill: `.claude/skills/[anchor-workflow-name].md`** — Tên = tên workflow từ anchor use case:
```yaml
---
description: [Mô tả workflow — input gì → output gì]
---
```
Nội dung:

- **Khi nào dùng:** trigger conditions
- **Input cần chuẩn bị:** loại input từ anchor use case (ví dụ: meeting note, report thô, brief)
- **Các bước thực thi:**
  1. `@research-analyst` — research/phân tích input
  2. `@[team]-senior` — process và draft output
  3. Review và finalize
- **Output:** loại output từ anchor use case
- **Trigger:** `/[anchor-workflow-name]`

---

## PHASE 3: DOCUMENTATION

**`AIOS-README.md`** tại root:

Bố cục bắt buộc:

1. **Chúc mừng** — "AI OS của team [X] đã sẵn sàng"
2. **Giải phẫu 5 Layers** bằng ngôn ngữ đại chúng (không dùng thuật ngữ code):
   - Kernel = Hiến pháp, load mọi lúc
   - Memory = Bộ nhớ dài hạn, không bao giờ quên (`system-knowledge`, `active-context`)
   - Rules = Luật tự động load đúng lúc, tiết kiệm context
   - Hooks = Kỷ luật thép (Memory Guard), AI không thể bỏ qua
   - Agents = Đội ngũ chuyên biệt, mỗi người một việc
3. **Quick Start** — chạy anchor use case ngay bằng `demo-prompts.md`
4. **5 Tips quan trọng:**
   - CLAUDE.md < 200 dòng, restart sau khi sửa
   - 1 session = 1 mục tiêu, dùng `/compact` khi session dài
   - Hooks exit code 2 sẽ block việc kết thúc task
   - Giữ Memory luôn được Agent tự cập nhật cuối giờ.
   - `@agent-name` để invoke trực tiếp, nhanh hơn để orchestrator tự chọn

**`demo-prompts.md`** tại root — copy-paste ready, nội dung thật từ anchor use case:

```markdown
# Demo Prompts — [Team] Workspace

## Full Pipeline — [Anchor Use Case Name]
[Prompt 1 — invoke research-analyst với input thật từ anchor use case]

[Prompt 2 — invoke [team]-senior với output từ bước trên]

/[skill-name]

## Test từng agent riêng
@research-analyst [sample research task phù hợp với team]

@[team]-senior [sample execution task phù hợp với team]

## Cập nhật memory sau task
LƯU Ý: Vui lòng check off task trong `.claude/memory/active-context.md` và ghi nhận một log nhỏ tại `.claude/memory/episodic/[hôm-nay].md` để thỏa mãn Memory Guard Hook trước khi báo xong task!
```

---

Kết thúc Phase 3: thông báo cho user —
> "✓ AI OS đã setup xong. Mở `demo-prompts.md` và chạy lệnh đầu tiên để test."
