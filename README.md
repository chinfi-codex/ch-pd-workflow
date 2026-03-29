# ch-pd-workflow

一套给 Codex 用的产品工作流 skills。

它不是“帮你多写几份文档”的工具包，而是把产品判断和文档交接拆成几个明确阶段，避免团队一开始就在错误的问题上堆功能。

## 这套 skills 在解决什么问题

很多团队写 PRD 的时候有两个常见问题：

- 还没想清楚“为什么做”，就开始写“怎么做”
- 关键边界没定清楚，却把决定推迟到开发阶段

`ch-pd-workflow` 的目标，是把这些容易混在一起的事情拆开处理。

它把产品工作流分成 4 个角色：

- `/ceo`: 先看项目方向值不值得做
- `/feature-br`: 再把需求问题、用户价值和范围收敛清楚
- `/prd`: 再把已经明确的方案写成正式 PRD
- `/pd-review`: 最后检查这份 PRD 是否真的能交给设计、研发、测试继续往下做

推荐使用顺序：

```text
/ceo -> /feature-br -> /prd -> /pd-review
```

## 这套方法背后的哲学

### 1. CEO 视角：先判断方向，再讨论功能

`/ceo` 对应的不是“老板拍脑袋”，而是一种更克制的项目判断方式。

它会优先看这些问题：

- 这件事到底在服务谁
- 用户有没有真实而高频的需求
- 我们准备提供的方案，是否真的匹配这个需求
- 这件事的资源代价、机会成本和阶段优先级是什么
- 相比现有替代方案，我们到底有什么独特价值

白话一点说：

先回答“这件事值不值得做”，再讨论“这个按钮放左边还是右边”。

### 2. 产品设计视角：先定义问题，再定义方案

`/feature-br` 和 `/prd` 的设计原则很明确：

- 先把问题讲清楚，再把功能写清楚
- 先把边界写清楚，再把细节补完整
- 先减少协作摩擦，再追求文档好看

所以这套 skills 会刻意避免几种常见写法：

- “体验更好”“更智能”这种没有判断标准的话
- “开发时再定”“后续再细化”这种把关键决策往后推的话
- 还没收敛范围，就先写一大堆功能列表

这套方法默认相信一件事：

真正拖慢团队的，通常不是文档写得不够长，而是关键判断不够清楚。

## 适合谁用

这套 skills 适合这些场景：

- 你用 Codex 辅助自己做产品、写 PRD
- 你是独立开发者，想给自己的需求流程加上更强的结构
- 你希望 AI 不是随便生成文档，而是按阶段做判断和收敛

如果你完全不熟悉 Codex，也没关系。下面会直接告诉你怎么安装、怎么用。

## 什么是 Codex skill

可以把 Codex skill 理解成“给 Codex 增加一种固定工作方式的说明书”。

它不是程序插件那种需要复杂安装的东西，本质上是一组有结构的 `SKILL.md` 文件。Codex 读取这些文件后，就会按你定义的方式来工作。

## 第一次安装

### 你需要准备什么

- 已安装 Codex
- Windows PowerShell 或 macOS/Linux 终端
- 如果你之后要修改模板并重新生成，机器上还需要安装 Node.js

### Windows 一键安装

直接执行：

```powershell
irm https://raw.githubusercontent.com/chinfi-codex/ch-pd-workflow/main/install.ps1 | iex
```

### macOS / Linux 一键安装

直接执行：

```bash
curl -fsSL https://raw.githubusercontent.com/chinfi-codex/ch-pd-workflow/main/install.sh | bash
```

### 安装后会发生什么

安装脚本会把仓库里的 `product-workflow` skill 包复制到你的 Codex skills 目录：

- 优先使用 `$CODEX_HOME/skills`
- 如果没有设置 `CODEX_HOME`，默认安装到 `~/.codex/skills`

最终目录通常会是：

```text
~/.codex/skills/product-workflow
```

## 安装后怎么用

安装完成后，你可以在 Codex 中直接按场景调用这些 skills。

### 什么时候用 `/ceo`

当你脑子里只有一个模糊方向，还没确定这事到底值不值得做时，用 `/ceo`。

示例：

```text
请用 /ceo 帮我判断：我想做一个给中小团队用的 AI 版销售复盘工具，这件事当前阶段值不值得做？
```

### 什么时候用 `/feature-br`

当方向已经大致确认，但需求还很散、范围还不清楚时，用 `/feature-br`。

示例：

```text
请用 /feature-br 帮我把“在 CRM 里加入 AI 跟进建议”这个想法收敛成一个可以进入 PRD 的 feature brief。
```

### 什么时候用 `/prd`

当 `feature brief` 已经确定，你要把它写成正式产品需求文档时，用 `/prd`。

示例：

```text
请基于当前项目里已经确认的 feature brief，用 /prd 产出正式 PRD。
```

### 什么时候用 `/pd-review`

当 PRD 已经写完，你想确认它是否能交给设计、研发、测试继续落地时，用 `/pd-review`。

示例：

```text
请用 /pd-review 审查当前 PRD，直接补齐不足的地方，并给出可交付结论。
```

## 给小白的最简单理解

如果你只记一句话，可以记这个：

- `/ceo` 负责判断要不要做
- `/feature-br` 负责判断该怎么收敛
- `/prd` 负责把已经明确的方案写清楚
- `/pd-review` 负责检查这份文档能不能真的交接

不要一上来就跳到 `/prd`。如果前面的判断没做清楚，PRD 只会把混乱写得更完整。

## 仓库结构

```text
.
├─ README.md
├─ install.ps1
├─ install.sh
├─ sync.ps1
├─ sync.sh
├─ package.json
└─ skills/
   └─ product-workflow/
      ├─ ceo/
      ├─ feature-br/
      ├─ prd/
      ├─ pd-review/
      ├─ shared/
      └─ scripts/
```

## 如果你想修改 skill 模板

这一段是给维护者和高级用户的。

### 先改哪里

你应该改这些源码文件：

- `skills/product-workflow/*/SKILL.md.tmpl`
- `skills/product-workflow/shared/fragments/*`

不要直接修改生成后的 `SKILL.md`，因为下次构建时会被覆盖。

### 改完后怎么让 Codex 里的版本也更新

你改完模板后，需要执行一次同步脚本。

Windows：

```powershell
powershell -ExecutionPolicy Bypass -File .\sync.ps1
```

macOS / Linux：

```bash
bash ./sync.sh
```

同步脚本会自动做两件事：

1. 重新生成各个 `SKILL.md`
2. 把最新内容复制到你的 Codex skills 目录

### 也可以只做构建

如果你暂时只想重新生成 `SKILL.md`，不想同步到 Codex：

```bash
npm run build
```

## 常见问题

### 1. 为什么我改了模板，Codex 里还是旧内容

因为你改的是源码模板，不是 Codex 已安装目录里的最终文件。

你需要运行：

- Windows: `sync.ps1`
- macOS / Linux: `sync.sh`

### 2. 安装目录在哪里

优先是：

```text
$CODEX_HOME/skills/product-workflow
```

如果没有设置 `CODEX_HOME`，通常是：

```text
~/.codex/skills/product-workflow
```

### 3. 没装 Node.js 可以用吗

如果你只是安装和使用，通常可以。

如果你要修改模板并重新生成 `SKILL.md`，就需要安装 Node.js，因为生成器依赖 Node 运行。

## 开发命令

```bash
npm run build
```

```bash
npm run sync
```

## 许可证

本项目默认使用 MIT License。
