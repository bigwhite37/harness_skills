# Convergent Dev Flow Validation Execution Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Validate the current `convergent-dev-flow` candidate by installing it into a fresh FastAPI host repo, then using the installed skill to deliver and verify a moderate-complexity soft-delete feature.

**Architecture:** Use `~/code/python/convergent-dev-flow-validation` as the host repo, bootstrap the local candidate ref into both Codex and Claude skill locations, then run a full `reframe -> plan -> ticket -> build -> review -> verify -> retro` workflow against the host API. The install audit and the feature workflow audit are both first-class outputs, so baseline failures and publication gaps are reported separately instead of being hidden behind local success.

**Tech Stack:** Python 3.12, FastAPI, SQLAlchemy, SQLite, pytest, local git checkout of `harness_skills`

---

### Task 1: Establish Host Baseline And Install Audit Surface

**Files:**
- Modify: `/Users/shuzhenyi/code/python/convergent-dev-flow-validation/.gitignore`
- Create: `/Users/shuzhenyi/code/python/convergent-dev-flow-validation/AGENTS.md`
- Create: `/Users/shuzhenyi/code/python/convergent-dev-flow-validation/CLAUDE.md`
- Create: `/Users/shuzhenyi/code/python/convergent-dev-flow-validation/.agents/skills/convergent-dev-flow/`
- Create: `/Users/shuzhenyi/code/python/convergent-dev-flow-validation/.claude/skills/convergent-dev-flow/`
- Test: `/Users/shuzhenyi/code/python/convergent-dev-flow-validation/.venv/bin/pytest`

- [ ] **Step 1: Check whether the exact candidate ref is remotely installable**

```bash
curl -fsSL https://raw.githubusercontent.com/bigwhite37/harness_skills/1df30134ff54257b79f90efb18a596096a9e4324/INSTALL.md >/tmp/convergent-dev-flow-install.md
```

Expected: if this succeeds, the remote-install path can be validated directly; if it fails, record the publication gap and continue with an explicit local-candidate bootstrap instead of pretending the remote path worked.

- [ ] **Step 2: Create a local virtualenv for reproducible host validation**

```bash
cd /Users/shuzhenyi/code/python/convergent-dev-flow-validation
python3 -m venv .venv
.venv/bin/pip install --upgrade pip
.venv/bin/pip install -r requirements.txt
```

- [ ] **Step 3: Run the host baseline tests and capture the real starting point**

Run: `.venv/bin/pytest -q`
Expected: Either a clean pass, or a concrete baseline failure that can be attributed to missing dependencies / host code rather than the skill.

- [ ] **Step 4: Keep validation-only artifacts out of git**

```gitignore
.venv/
user.db
test_db.db
.pytest_cache/
```

- [ ] **Step 5: Bootstrap the host permanent-rule files from the local candidate source**

```bash
cd /Users/shuzhenyi/code/python/convergent-dev-flow-validation
cp /Users/shuzhenyi/code/python/invest_repos/harness_skills/host-templates/AGENTS.md AGENTS.md
cp /Users/shuzhenyi/code/python/invest_repos/harness_skills/host-templates/CLAUDE.md CLAUDE.md
```

Expected: `AGENTS.md` contains `convergent-dev-flow bootstrap-template: AGENTS`; `CLAUDE.md` contains `convergent-dev-flow bootstrap-template: CLAUDE`.

- [ ] **Step 6: Rebuild the host skill directories from the local candidate ref**

```bash
cd /Users/shuzhenyi/code/python/convergent-dev-flow-validation
rm -rf .agents/skills/convergent-dev-flow .claude/skills/convergent-dev-flow
mkdir -p .agents/skills/convergent-dev-flow .claude/skills/convergent-dev-flow
cp /Users/shuzhenyi/code/python/invest_repos/harness_skills/SKILL.md .agents/skills/convergent-dev-flow/SKILL.md
cp /Users/shuzhenyi/code/python/invest_repos/harness_skills/SKILL.md .claude/skills/convergent-dev-flow/SKILL.md
cp -R /Users/shuzhenyi/code/python/invest_repos/harness_skills/flows .agents/skills/convergent-dev-flow/
cp -R /Users/shuzhenyi/code/python/invest_repos/harness_skills/flows .claude/skills/convergent-dev-flow/
cp -R /Users/shuzhenyi/code/python/invest_repos/harness_skills/guards .agents/skills/convergent-dev-flow/
cp -R /Users/shuzhenyi/code/python/invest_repos/harness_skills/guards .claude/skills/convergent-dev-flow/
cp -R /Users/shuzhenyi/code/python/invest_repos/harness_skills/templates .agents/skills/convergent-dev-flow/
cp -R /Users/shuzhenyi/code/python/invest_repos/harness_skills/templates .claude/skills/convergent-dev-flow/
cp -R /Users/shuzhenyi/code/python/invest_repos/harness_skills/references .agents/skills/convergent-dev-flow/
cp -R /Users/shuzhenyi/code/python/invest_repos/harness_skills/references .claude/skills/convergent-dev-flow/
cp -R /Users/shuzhenyi/code/python/invest_repos/harness_skills/examples .agents/skills/convergent-dev-flow/
cp -R /Users/shuzhenyi/code/python/invest_repos/harness_skills/examples .claude/skills/convergent-dev-flow/
cp -R /Users/shuzhenyi/code/python/invest_repos/harness_skills/evals .agents/skills/convergent-dev-flow/
cp -R /Users/shuzhenyi/code/python/invest_repos/harness_skills/evals .claude/skills/convergent-dev-flow/
mkdir -p .agents/skills/convergent-dev-flow/docs .claude/skills/convergent-dev-flow/docs
cp /Users/shuzhenyi/code/python/invest_repos/harness_skills/docs/usage.md .agents/skills/convergent-dev-flow/docs/usage.md
cp /Users/shuzhenyi/code/python/invest_repos/harness_skills/docs/usage.md .claude/skills/convergent-dev-flow/docs/usage.md
cp /Users/shuzhenyi/code/python/invest_repos/harness_skills/docs/self-check.md .agents/skills/convergent-dev-flow/docs/self-check.md
cp /Users/shuzhenyi/code/python/invest_repos/harness_skills/docs/self-check.md .claude/skills/convergent-dev-flow/docs/self-check.md
cp /Users/shuzhenyi/code/python/invest_repos/harness_skills/docs/acceptance.md .agents/skills/convergent-dev-flow/docs/acceptance.md
cp /Users/shuzhenyi/code/python/invest_repos/harness_skills/docs/acceptance.md .claude/skills/convergent-dev-flow/docs/acceptance.md
```

- [ ] **Step 7: Patch the Claude copy to enforce no nested model invocation**

```python
---
name: convergent-dev-flow
description: 用于需要通过 reframe、plan、ticket、build、review 与 verify 固定阶段推进收敛式开发任务的场景。
disable-model-invocation: true
---
```

Expected: only `.claude/skills/convergent-dev-flow/SKILL.md` gets the extra field.

- [ ] **Step 8: Record the install evidence**

Run: `find .agents/skills/convergent-dev-flow .claude/skills/convergent-dev-flow -maxdepth 2 | sort`
Expected: both trees contain `SKILL.md`, `flows/`, `guards/`, `templates/`, `references/`, `examples/`, `evals/`, and the three `docs/*.md` files.

- [ ] **Step 9: Commit the host bootstrap state**

```bash
cd /Users/shuzhenyi/code/python/convergent-dev-flow-validation
git checkout -b validation/convergent-dev-flow
git add .gitignore AGENTS.md CLAUDE.md .agents .claude
git commit -m "chore: install convergent-dev-flow validation skill"
```

### Task 2: Add Failing Tests For The Soft-Delete Workflow

**Files:**
- Modify: `/Users/shuzhenyi/code/python/convergent-dev-flow-validation/tests/test_crud_api.py`
- Test: `/Users/shuzhenyi/code/python/convergent-dev-flow-validation/.venv/bin/pytest tests/test_crud_api.py -q`

- [ ] **Step 1: Replace the hard-delete expectation with a soft-delete lifecycle test**

```python
def test_create_soft_delete_user_hides_it_by_default(test_client, user_payload):
    create_response = test_client.post("/api/users/", json=user_payload)
    assert create_response.status_code == 201

    delete_response = test_client.delete(f"/api/users/{user_payload['id']}")
    assert delete_response.status_code == 202
    assert delete_response.json()["Message"] == "User deleted successfully"

    get_response = test_client.get(f"/api/users/{user_payload['id']}")
    assert get_response.status_code == 404

    list_response = test_client.get("/api/users/")
    assert list_response.status_code == 200
    assert list_response.json()["results"] == 0

    include_deleted_response = test_client.get("/api/users/?include_deleted=true")
    assert include_deleted_response.status_code == 200
    include_deleted_payload = include_deleted_response.json()
    assert include_deleted_payload["results"] == 1
    assert include_deleted_payload["users"][0]["id"] == user_payload["id"]
    assert include_deleted_payload["users"][0]["deletedAt"] is not None
```

- [ ] **Step 2: Add a restore test that proves the user becomes visible again**

```python
def test_restore_soft_deleted_user(test_client, user_payload):
    create_response = test_client.post("/api/users/", json=user_payload)
    assert create_response.status_code == 201

    delete_response = test_client.delete(f"/api/users/{user_payload['id']}")
    assert delete_response.status_code == 202

    restore_response = test_client.post(f"/api/users/{user_payload['id']}/restore")
    assert restore_response.status_code == 200
    restore_payload = restore_response.json()
    assert restore_payload["Status"] == "Success"
    assert restore_payload["User"]["id"] == user_payload["id"]
    assert restore_payload["User"]["deletedAt"] is None

    get_response = test_client.get(f"/api/users/{user_payload['id']}")
    assert get_response.status_code == 200

    list_response = test_client.get("/api/users/")
    assert list_response.status_code == 200
    assert list_response.json()["results"] == 1
```

- [ ] **Step 3: Add a restore guardrail for active users**

```python
def test_restore_active_user_conflicts(test_client, user_payload):
    create_response = test_client.post("/api/users/", json=user_payload)
    assert create_response.status_code == 201

    restore_response = test_client.post(f"/api/users/{user_payload['id']}/restore")
    assert restore_response.status_code == 409
    assert restore_response.json()["detail"] == "User is not deleted."
```

- [ ] **Step 4: Run the focused test file and confirm the new coverage fails first**

Run: `.venv/bin/pytest tests/test_crud_api.py -q`
Expected: the new restore and soft-delete assertions fail against the current hard-delete implementation.

- [ ] **Step 5: Commit the failing tests**

```bash
cd /Users/shuzhenyi/code/python/convergent-dev-flow-validation
git add tests/test_crud_api.py
git commit -m "test: cover soft delete workflow"
```

### Task 3: Implement Soft Delete, Filtering, And Restore

**Files:**
- Modify: `/Users/shuzhenyi/code/python/convergent-dev-flow-validation/app/models.py`
- Modify: `/Users/shuzhenyi/code/python/convergent-dev-flow-validation/app/schemas.py`
- Modify: `/Users/shuzhenyi/code/python/convergent-dev-flow-validation/app/user.py`
- Test: `/Users/shuzhenyi/code/python/convergent-dev-flow-validation/.venv/bin/pytest tests/test_crud_api.py -q`

- [ ] **Step 1: Extend the SQLAlchemy model with a nullable deletion timestamp**

```python
deletedAt = Column(TIMESTAMP(timezone=True), nullable=True, default=None)
```

Place it beside `createdAt` / `updatedAt` in `app/models.py`.

- [ ] **Step 2: Expose the deletion timestamp in the API schema**

```python
class UserBaseSchema(BaseModel):
    id: UUID | None = None
    first_name: str = Field(..., description="The first name of the user", example="John")
    last_name: str = Field(..., description="The last name of the user", example="Doe")
    address: str | None = None
    activated: bool = False
    createdAt: datetime | None = None
    updatedAt: datetime | None = None
    deletedAt: datetime | None = None
```

- [ ] **Step 3: Add shared query helpers in `app/user.py` to avoid mixing active and deleted records**

```python
from datetime import datetime, timezone


def active_user_query(db: Session):
    return db.query(models.User).filter(models.User.deletedAt.is_(None))


def any_user_query(db: Session):
    return db.query(models.User)
```

- [ ] **Step 4: Update get, patch, and list handlers to respect soft-delete semantics**

```python
def get_user(userId: str, db: Session = Depends(get_db)):
    user_query = active_user_query(db).filter(models.User.id == userId)
    db_user = user_query.first()
    ...


def update_user(userId: str, payload: schemas.UserBaseSchema, db: Session = Depends(get_db)):
    user_query = active_user_query(db).filter(models.User.id == userId)
    db_user = user_query.first()
    ...


def get_users(
    db: Session = Depends(get_db),
    limit: int = 10,
    page: int = 1,
    search: str = "",
    include_deleted: bool = False,
):
    skip = (page - 1) * limit
    query = any_user_query(db) if include_deleted else active_user_query(db)
    users = (
        query.filter(models.User.first_name.contains(search))
        .limit(limit)
        .offset(skip)
        .all()
    )
    return schemas.ListUserResponse(status=schemas.Status.Success, results=len(users), users=users)
```

- [ ] **Step 5: Replace hard delete with a timestamped soft delete and add restore**

```python
def delete_user(userId: str, db: Session = Depends(get_db)):
    user = active_user_query(db).filter(models.User.id == userId).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"No User with this id: `{userId}` found",
        )
    user.deletedAt = datetime.now(timezone.utc)
    db.commit()
    db.refresh(user)
    return schemas.DeleteUserResponse(
        Status=schemas.Status.Success,
        Message="User deleted successfully",
    )


@router.post(
    "/{userId}/restore",
    status_code=status.HTTP_200_OK,
    response_model=schemas.UserResponse,
)
def restore_user(userId: str, db: Session = Depends(get_db)):
    user = any_user_query(db).filter(models.User.id == userId).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"No User with this id: `{userId}` found",
        )
    if user.deletedAt is None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="User is not deleted.",
        )
    user.deletedAt = None
    db.commit()
    db.refresh(user)
    user_schema = schemas.UserBaseSchema.model_validate(user)
    return schemas.UserResponse(Status=schemas.Status.Success, User=user_schema)
```

- [ ] **Step 6: Run the focused tests until the new behavior passes**

Run: `.venv/bin/pytest tests/test_crud_api.py -q`
Expected: all CRUD tests, including the new soft-delete tests, pass.

- [ ] **Step 7: Commit the implementation**

```bash
cd /Users/shuzhenyi/code/python/convergent-dev-flow-validation
git add app/models.py app/schemas.py app/user.py tests/test_crud_api.py
git commit -m "feat: add soft delete workflow"
```

### Task 4: Collect Workflow, Review, And Verification Evidence

**Files:**
- Create: `/Users/shuzhenyi/code/python/convergent-dev-flow-validation/validation-artifacts/install-audit.md`
- Create: `/Users/shuzhenyi/code/python/convergent-dev-flow-validation/validation-artifacts/workflow-audit.md`
- Create: `/Users/shuzhenyi/code/python/convergent-dev-flow-validation/validation-artifacts/verify-evidence.txt`
- Test: `/Users/shuzhenyi/code/python/convergent-dev-flow-validation/.venv/bin/pytest -q`

- [ ] **Step 1: Write the install audit with the exact source repo and source ref**

```md
# Install Audit

- SOURCE_REPO: /Users/shuzhenyi/code/python/invest_repos/harness_skills
- SOURCE_REF: 1df30134ff54257b79f90efb18a596096a9e4324
- bootstrap_mode: local candidate bootstrap
- codex_skill_path: .agents/skills/convergent-dev-flow
- claude_skill_path: .claude/skills/convergent-dev-flow
- claude_disable_model_invocation: true
```

- [ ] **Step 2: Write the workflow audit with explicit phase outputs**

```md
# Workflow Audit

- reframe: completed
- plan: completed
- ticket: completed
- build: completed
- review: completed
- verify: completed
- retro: completed

## Notes
- review and verify were recorded separately
- feature scope remained within soft delete, include_deleted, and restore
- baseline dependency failure was resolved before feature verification
```

- [ ] **Step 3: Capture direct verification evidence**

Run: `.venv/bin/pytest -q | tee validation-artifacts/verify-evidence.txt`
Expected: all tests pass with the new soft-delete coverage.

- [ ] **Step 4: Record the remote publication gap explicitly if the pinned candidate is not on GitHub**

```md
## Publication Gap

- local candidate ref: 1df30134ff54257b79f90efb18a596096a9e4324
- remote install coverage: not validated against GitHub raw because the candidate ref was not published at execution time
- conclusion: current candidate behavior validated locally; public remote-install parity still requires a pushed ref check
```

- [ ] **Step 5: Commit the validation artifacts**

```bash
cd /Users/shuzhenyi/code/python/convergent-dev-flow-validation
git add validation-artifacts
git commit -m "docs: record convergent-dev-flow validation evidence"
```
