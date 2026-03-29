# `product-workflow` Skill Pack

这是仓库里的技能源码目录，面向维护者。

如果你只是想安装并使用这些 skills，请先看仓库根目录的 `README.md`。那里会用更直白的方式解释项目定位、安装方法和使用示例。

## 包含内容

- `ceo/`: 项目级产品判断 skill
- `feature-br/`: 需求澄清与 Feature Brief skill
- `prd/`: 正式 PRD 编写 skill
- `pd-review/`: PRD 交接审查与补齐 skill
- `shared/fragments/`: 多个 skill 共享的提示词片段
- `scripts/`: 生成 `SKILL.md` 的构建脚本

## 维护规则

先理解一个原则：

- `SKILL.md.tmpl` 是源码
- `SKILL.md` 是生成产物

这意味着：

1. 你应该修改各目录下的 `SKILL.md.tmpl`
2. 如果是多个 skill 共用的规则，修改 `shared/fragments/*`
3. 不要直接编辑生成后的 `SKILL.md`
4. 改完后必须重新生成，并同步到 Codex 已安装目录

## 构建

在仓库根目录执行任一方式：

```bash
node --experimental-strip-types skills/product-workflow/scripts/gen-skill-docs.ts
```

```bash
bash skills/product-workflow/scripts/build-all.sh
```

```powershell
powershell -ExecutionPolicy Bypass -File skills/product-workflow/scripts/build-all.ps1
```

## 同步到 Codex

如果你已经把这个仓库安装到了 Codex，修改模板后还需要同步一次，否则 Codex 里的版本不会自动更新。

在仓库根目录执行：

```bash
bash ./sync.sh
```

或：

```powershell
powershell -ExecutionPolicy Bypass -File .\sync.ps1
```

同步脚本会自动做两件事：

1. 重新生成各个 `SKILL.md`
2. 把最新的 `skills/product-workflow` 复制到你的 Codex skills 目录

## 产物约定

这些 skills 默认把正式产物写入当前项目根目录下的 `./prd/`：

- `project memo` -> `./prd/project-memos/project-memo-YYYY-MM-DD.md`
- `feature brief` -> `./prd/features/<feature-slug>/feature-brief-YYYY-MM-DD.md`
- `PRD` -> `./prd/features/<feature-slug>/prd-YYYY-MM-DD.md`
- `pd-review-report` -> `./prd/features/<feature-slug>/pd-review-report-YYYY-MM-DD.md`

同一需求的后续文档必须沿用同一个 `feature-slug`。
