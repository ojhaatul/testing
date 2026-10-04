# 04 – End-to-End Delivery Process

```
Requirement ─► Design ─► Build (Git) ─► CI ─► Import to DEV ─► Transport ─► QAS test ─► PRD
 docs/01        docs/02    src/*.abap    GH Actions  abapGit      SE09/STMS   docs/03     STMS
```

| # | Stage            | Where            | Output / gate                                              |
|---|------------------|------------------|------------------------------------------------------------|
| 1 | Requirement      | `docs/01-requirement.md` | Signed-off acceptance criteria                      |
| 2 | Technical design | `docs/02-technical-design.md` | Object list, approved by lead developer         |
| 3 | Build            | Feature branch, `src/` (abapGit format) | Code + ABAP Unit tests                    |
| 4 | CI               | GitHub Actions `.github/workflows/ci.yml` | abaplint clean, ABAP Unit green → PR mergeable |
| 5 | Code review      | Pull request     | Approval; PR template checklist                            |
| 6 | Import to DEV    | SAP DEV, transaction `ZABAPGIT` | Objects active in package `ZEMPLOYEE`         |
| 7 | DEV checks       | ATC, ABAP Unit   | No P1/P2 ATC findings, unit tests green                    |
| 8 | Transport        | SE09 / SE10      | Workbench request released                                 |
| 9 | QAS test         | SAP QAS          | `docs/03-test-plan.md` level 3 executed, UAT sign-off      |
| 10| Go-live          | STMS import to PRD | Report available; optionally assign T-code via SE93      |

## Stage 6 detail – pulling into SAP with abapGit
1. Install abapGit once in DEV (standalone report `ZABAPGIT_STANDALONE` from https://abapgit.org).
2. Create package `ZEMPLOYEE` (SE21), assign a transport layer.
3. `ZABAPGIT` → **New Online** → repo URL, package `ZEMPLOYEE` → **Clone**.
4. **Pull**; choose/create a workbench transport request when prompted.
5. Activate inactive objects if any (SE80 → package → Activate).

Changes made directly in SAP can be pushed back to Git from the same abapGit repo screen (**Stage** → **Commit**), keeping Git as the source of truth.

## Run locally
```bash
npm ci
npm test          # abaplint + ABAP Unit
```
