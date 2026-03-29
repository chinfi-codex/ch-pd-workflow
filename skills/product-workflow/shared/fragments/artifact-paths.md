## Artifact 路径约定

统一根目录：

```text
./prd/
  project-memos/
    project-memo-YYYY-MM-DD.md
  features/
    <feature-slug>/
      feature-brief-YYYY-MM-DD.md
      prd-YYYY-MM-DD.md
      pd-review-report-YYYY-MM-DD.md
```

路径使用规则：

- `./prd/` 是相对当前项目根目录的 artifact 归档路径
- `project memo` 是项目级唯一逻辑对象，写入 `./prd/project-memos/project-memo-YYYY-MM-DD.md`
- 需求级文档统一按 `feature-slug` 归档到 `./prd/features/<feature-slug>/`
- `feature brief` 写入 `./prd/features/<feature-slug>/feature-brief-YYYY-MM-DD.md`
- `PRD` 写入 `./prd/features/<feature-slug>/prd-YYYY-MM-DD.md`
- `pd-review-report` 写入 `./prd/features/<feature-slug>/pd-review-report-YYYY-MM-DD.md`
- `feature-slug` 是需求级稳定标识，一经建立不因中文标题调整而改变
- 同一需求的所有正式文档必须沿用同一个 `feature-slug`
- 文档更新使用“新文件 + 日期后缀”策略，不覆盖旧文件
- 默认读取同目录下最新日期的同类文档作为当前版本
- 文件命名保持稳定、可搜索、可比较，避免使用含糊名称如 `final-v2-latest`
