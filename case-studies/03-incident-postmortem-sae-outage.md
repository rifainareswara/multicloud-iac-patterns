# Incident Postmortem: Full-Fleet Serverless Outage (503)

**Theme:** SRE · Incident Response · Observability
**Stack:** Alibaba Cloud SAE, ActionTrail (audit log), GitHub Actions, CLI forensics

> A real postmortem, sanitized. It's here deliberately: the most useful thing it
> demonstrates is honest root-cause analysis — including discovering the cause
> was a self-inflicted automation, and saying so.

---

## Summary

Around 02:00 local time, **every serverless application across dev and UAT went
down**, serving 503s. Service was restored manually within the hour. Root cause
was traced to an in-house cost-saving automation, not the platform.

## Detection & impact

- **Symptom:** all SAE apps in both non-production environments stopped; public
  endpoints returned 503.
- **Blast radius:** dev + UAT (9 apps). Production unaffected.

## Investigation (read-only, evidence-first)

I deliberately investigated *before* changing anything, to avoid destroying
evidence:

1. **Ruled out the obvious suspect.** Checked for any SAE auto-scaling /
   scheduled-scaling rules on all 9 apps — there were none. So native scheduled
   scaling could not have caused it.
2. **Went to the audit log.** Queried ActionTrail for `StopApplication` events in
   the region. Found **9 sequential Stop events spanning ~12 seconds**, all from
   the same RAM user, same source IP, and a Go-SDK user agent.
3. **Read the signal in the pattern.** Nine stops in 12 seconds, in a fixed
   order, is not a human in a console — it's a script iterating an array. The Go
   SDK + a cloud-hosted source IP pointed at an automated runner.
4. **Found the culprit in our own repo.** A GitHub Actions workflow — a homegrown
   "power scheduler" meant to stop dev/UAT outside office hours to save money —
   had a `StopApplication` loop whose array order *exactly matched* the order of
   Stop events in the audit log. That sequence match was the smoking gun.
5. **Confirmed the timeline.** The scheduler had been silently failing for weeks
   on a CLI-install bug; a fix had landed hours earlier. The first *successful*
   run is what took the fleet down — most likely a manual post-fix test trigger
   rather than the scheduled cron.

## Recovery

Restarted all 9 applications manually via the same automation's `start` path
(confirmed in the audit log as coming from my own workstation). Full restoration
within the hour.

## Root cause

A **self-inflicted automation defect**: the cost-saving scheduler did exactly
what it was written to do — stop the apps — but the trigger fired unexpectedly
(a manual test after a long-broken workflow was repaired), and there was no guard
distinguishing "intended scheduled stop" from "someone is testing the fix."

## Lessons / follow-ups

- **Audit logs are the source of truth.** A subtle gotcha: filtering ActionTrail
  by service name returned nothing for SAE — I had to filter by event name
  directly. Knowing your observability tooling's quirks *is* the skill.
- **Cost automation that can stop production-shaped resources needs guardrails** —
  explicit environment scoping, a dry-run mode, and confirmation that a "test"
  run can't silently nuke a fleet.
- **Evidence-first response.** Investigating read-only before remediating is what
  made a clean root cause possible.

## What I'd highlight in an interview

- Methodical, evidence-driven root-causing using cloud-native audit logs.
- Reading intent from a *pattern* (12 seconds, fixed order) rather than guessing.
- Owning that the cause was our own automation — and turning it into concrete
  guardrail follow-ups.

## Skills demonstrated

`incident response` · `root-cause analysis` · `Alibaba SAE` ·
`ActionTrail / audit-log forensics` · `CI/CD safety` · `blameless postmortem`
