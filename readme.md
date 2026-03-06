# OpenShift Patroni

PostgreSQL 15 high-availability setup for OpenShift using [Patroni](https://github.com/patroni/patroni).

## Image

The image is built in two layers:

- **postgres-base** — PostgreSQL 15.17 on Debian Bullseye, adapted for OpenShift (random UID with group 0)
- **patroni-openshift** — Patroni 3.3.6 with Kubernetes DCS, plus backup and monitoring tooling

## Included components

| Component | Purpose |
|---|---|
| Patroni 3.3.6 | HA cluster management (Kubernetes DCS) |
| pgBackRest | Backup and restore |
| TimescaleDB 2 | Time-series extension |
| pgvector | Vector similarity search |
| pg_repack | Online table repacking (remove bloat without locks) |
| temporal_tables | Temporal table versioning |
| Prometheus node_exporter | Host metrics |
| Prometheus postgres_exporter | PostgreSQL metrics (via CrunchyData pgmonitor) |
| Prometheus blackbox_exporter | Endpoint probing |
| SSH (port 2222) | Optional sshd for pgBackRest transfers |

## Ports

| Port | Service |
|---|---|
| 5432 | PostgreSQL |
| 8008 | Patroni REST API |
| 2222 | SSH (optional, controlled by `START_SSHD`) |

## Environment variables

| Variable | Default | Description |
|---|---|---|
| `START_SSHD` | `false` | Start an sshd on port 2222 |
| `ENABLE_NODE_EXPORTER` | `false` | Start Prometheus node_exporter |
| `ENABLE_BLACKBOX_EXPORTER` | `false` | Start Prometheus blackbox_exporter |
| `ENABLE_PER_DB_EXPORTER` | `false` | Start per-database postgres_exporter |
| `ENABLE_ALL_DB_EXPORTER` | `false` | Start all-database postgres_exporter |

## Building

```bash
./tag_and_push.sh
```

This builds the base image (`tsdc/postgres`) and then the Patroni image (`tsdc/openshift-patroni`), and pushes both.