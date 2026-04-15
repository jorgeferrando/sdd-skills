# SDD Skills — Roadmap

Ultima actualizacion: 2026-04-15

---

## Tier 1: Fundamentos (2026-04-16 → 2026-04-28)

Sin esto, el resto se construye sobre arena.

| # | Tarea | Entregable | Fecha objetivo |
|---|-------|-----------|----------------|
| 1 | ~~CI de validacion de skills~~ | `.github/workflows/validate.yml` | ~~2026-04-18~~ 2026-04-15 |
| 2 | ~~CHANGELOG + tag v1.0.0~~ | `CHANGELOG.md`, tag `v1.0.0` | ~~2026-04-21~~ 2026-04-15 |
| 3 | ~~Smoke test del workflow completo~~ | `examples/api-demo/` con openspec + WALKTHROUGH.md (7 friction points) | ~~2026-04-28~~ 2026-04-15 |

**Criterio de salida:** CI verde en cada push, version publicada, workflow validado end-to-end.

---

## Tier 2: Reducir friccion de entrada (2026-04-29 → 2026-05-19)

Adquisicion de primeros usuarios.

| # | Tarea | Entregable | Fecha objetivo |
|---|-------|-----------|----------------|
| 4 | Verificar compatibilidad con SkillKit | Instalacion probada, ajustes de frontmatter si necesario | 2026-05-02 |
| 5 | Mejoras al installer | Seleccion de skills, dry-run, colores ANSI | 2026-05-07 |
| 6 | `sdd-init` modo rapido (`--quick`) | `instructions.md` actualizado con deteccion de modo | 2026-05-14 |
| 7 | Evaluar si `install-skills.sh` pasa a secundario | Decision documentada + simplificacion si aplica | 2026-05-19 |

**Criterio de salida:** Un usuario nuevo puede instalar y ejecutar su primer ciclo SDD en menos de 5 minutos.

**Dependencia externa:** Tarea 4 depende de aceptacion en SkillKit (issue rohitg00/skillkit#112). Si no hay respuesta para 2026-05-02, se salta y se retoma cuando respondan.

---

## Tier 3: Diferenciacion (2026-05-20 → 2026-06-16)

Lo que separa SDD de "un prompt largo".

| # | Tarea | Entregable | Fecha objetivo |
|---|-------|-----------|----------------|
| 8 | Output contracts en frontmatter | `requires`/`produces` en los 16 skills | 2026-05-26 |
| 9 | Extension point en `sdd-continue` | Lectura de skills custom desde `openspec/skills/`, docs actualizados | 2026-06-02 |
| 10 | `sdd-recall` | `skills/sdd-recall/instructions.md`, docs, entry en plugin.json | 2026-06-09 |
| 11 | `sdd-steer --report` | Modo `--report` en sdd-steer, docs actualizados | 2026-06-16 |

**Criterio de salida:** Un equipo puede extender el workflow con skills propios, y las specs archivadas son recuperables.

---

## Tier 4: Escala y ecosistema (2026-06-17 → 2026-07-21)

Cuando haya usuarios reales que validen el diseno.

| # | Tarea | Entregable | Fecha objetivo |
|---|-------|-----------|----------------|
| 12 | `sdd-audit` como GitHub Action | `.github/actions/sdd-audit/action.yml` publicada | 2026-06-23 |
| 13 | Convention inheritance (monorepos) | Semantica de merge en steering, docs | 2026-06-30 |
| 14 | `sdd-steer --prune` | Deteccion de reglas redundantes/contradictorias | 2026-07-07 |
| 15 | Spec review workflow | `sdd-spec` genera PR draft para review humano | 2026-07-14 |
| 16 | Conflict detection en `sdd-new` | Deteccion de specs concurrentes sobre mismos archivos | 2026-07-21 |

**Criterio de salida:** SDD funciona como gate de calidad en CI y soporta equipos con multiples contributors concurrentes.

**Nota:** Tier 4 se replanifica al inicio de Tier 3 basandose en feedback real de usuarios. Las tareas 15 y 16 requieren validacion con equipos reales — si no hay usuarios en equipo para entonces, se difieren.

---

## Descartado

| Idea | Razon |
|------|-------|
| npm/pip package propio | SkillKit cubre ese canal |
| Telemetria | Requiere backend, desproporcionado para el tamano actual |
| VS Code extension | Plugin de Claude + SkillKit cubren el canal |
| Workflow.json programatico | Output contracts (tarea 8) cubren el 80% |
| VERSIONS.md por skill | CHANGELOG + git tags es suficiente para 16 skills / 1 autor |
| TUI completo con dependencia externa | Mejoras al installer (tarea 5) dan el 80% del valor sin deps |

---

## Hitos completados

- [x] 2026-04-15 — Reestructura repo: `sdd-*/` → `skills/sdd-*/` (SkillKit compatible)
- [x] 2026-04-15 — SkillKit como opcion de instalacion en README y docs
- [x] 2026-04-15 — Issue rohitg00/skillkit#112 para registro en marketplace
- [x] 2026-04-15 — CI de validacion (`validate-skills.sh` + GitHub Actions)
- [x] 2026-04-15 — CHANGELOG.md + tag v1.0.0
- [x] 2026-04-15 — Smoke test completo: `examples/api-demo/` con 7 friction points documentados
