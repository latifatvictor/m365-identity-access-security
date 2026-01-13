# Conditional Access Strategy (Microsoft 365)

## Purpose
This document outlines a practical Conditional Access approach to secure Microsoft 365 access using risk-based controls, device trust, and least privilege.

The goal is security without unnecessary friction.

---

## Core principles
- Enforce MFA for all users, stronger controls for admins
- Use device compliance for access to sensitive apps and data
- Block legacy authentication
- Apply least privilege and protect privileged sessions
- Start with monitor mode, then enforce in phases

---

## Recommended baseline policies

### 1. Block legacy authentication
- Block access for legacy auth clients
- Exception handling should be minimal and time-bound

### 2. Require MFA for all users
- Require MFA for cloud apps (Microsoft 365)
- Consider trusted locations carefully (avoid broad exclusions)

### 3. Require compliant device for core Microsoft 365 apps
- Require Intune compliant device for Exchange, SharePoint, Teams
- Use separate policies for high-risk groups and apps

### 4. Protect privileged roles (admin accounts)
- Require MFA every time
- Require compliant device
- Restrict to trusted locations where appropriate
- Consider additional controls (authentication strength)

### 5. Guest and external access controls
- Apply stricter policies for guests
- Limit sessions and require MFA where possible
- Review and remove inactive guest accounts regularly

---

## Rollout approach
- Phase 1: Audit and understand sign-in patterns
- Phase 2: Enforce MFA and block legacy auth
- Phase 3: Enforce device compliance for key apps
- Phase 4: Tighten privileged access and guest policies
- Phase 5: Review, tune, and document exceptions

---

## Common mistakes to avoid
- Too many exclusions and bypasses
- Applying strict policies without a pilot group
- Not separating admin and user accounts
- Not aligning device compliance with access policies
- Not reviewing sign-in logs after policy changes

---

## Operational checks
- Review sign-in failures and user impact after changes
- Monitor Conditional Access insights and reporting
- Review policy exceptions monthly
- Validate admin roles and break glass accounts quarterly

---
