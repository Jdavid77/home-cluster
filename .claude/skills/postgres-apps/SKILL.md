---
name: postgres-apps
description: Scale every app that uses the NAS Postgres down to zero, or back up. Run with down, up or list.
disable-model-invocation: true
---

# Postgres apps

Scales the apps whose database is on the NAS Postgres (`192.168.1.84:5432`), for Postgres maintenance such as the [major upgrade runbook](../../../docs/runbooks/nas-postgres-major-upgrade.md). Everything else in the cluster keeps running.

The apps are the ones with `postgres` in `DEPENDS_ON`, in the `keda/dependencies` component (`k8s/components/keda/dependencies`). The component gives each workload in `KEDA_TARGETS` a ScaledObject that follows the `postgres` blackbox probe. The script finds them on the cluster by that probe in the trigger query, and scales them by pausing KEDA with the `autoscaling.keda.sh/paused-replicas` annotation.

```sh
.claude/skills/postgres-apps/scripts/postgres-apps.sh list|down|up
```

## Steps

1. Run `list` and show the user the ScaledObjects, their workloads and replica counts. Done when the user has confirmed the list. If an app they expect is missing, it needs the component with `postgres` in `DEPENDS_ON` (and its workloads in `KEDA_TARGETS`); stop and fix that in git before scaling anything.
2. Run the mode the user asked for:
   - `down` sets `paused-replicas: "0"` on each ScaledObject, so KEDA scales the workload to 0 and holds it there. It then waits for each workload's pods to go.
   - `up` removes the annotation. KEDA takes the workloads back to their counts, as long as the postgres probe is up.
3. Run `list` again. Done when every workload shows `replicas=0 paused=0` after `down`, or its normal count and `paused=-` after `up` (KEDA can take a minute). Report any that don't.

## Notes

- No HelmRelease is suspended and nothing is saved: KEDA owns the replica counts, so removing the pause is enough to restore them.
- The script writes the annotation with `--field-manager=postgres-apps`. Under kubectl's default field manager, Flux's server-side apply removes it on the next ResourceSet reconcile, which unpauses the app. Under its own manager it survives reconciles (tested 2026-11-27).
- Without the pause, KEDA also scales these apps to 0 by itself when the probe on 5432 fails for about 6 minutes (1m probe window plus the 300s cooldown), and back up when it recovers.
