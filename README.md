# Microsoft 365 Identity & Access Security

## Start Here

If you are new to this repository, these are the key places to begin:

- **Conditional Access Strategy**  
  `identity/conditional-access-strategy.md`  
  A practical view of how Microsoft 365 access should be secured using MFA, device trust, and risk-based controls.

- **Admin Roles Model**  
  `identity/admin-roles-model.md`  
  How administrative access should be structured using least privilege and role separation.

- **Conditional Access Export Script**  
  `powershell/export-conditional-access-policies.ps1`  
  A PowerShell script to review Conditional Access policies in a tenant.

- **Admin Role Assignment Export Script**  
  `powershell/export-admin-role-assignments.ps1`  
  A PowerShell script to audit who has privileged access in Entra ID.

These together show how identity is **designed, governed, and operated** in a secure Modern Workplace.



This repository contains practical work focused on **Microsoft 365 identity, access control, and security** using Entra ID (Azure AD) and Conditional Access.

It reflects how identity is designed, governed, and operated in real enterprise Modern Workplace environments.

---

## What this repository covers

- Entra ID identity management
- Conditional Access design and enforcement
- MFA and authentication methods
- Identity governance and admin role control
- Secure access to Microsoft 365
- PowerShell automation for identity operations

---

## Why identity matters

Identity is the primary security boundary in Microsoft 365.

Strong identity and access design:
- Protects users and data
- Enables secure remote work
- Supports Zero Trust security
- Reduces operational and security risk

---

## Folder structure

/powershell
Scripts for identity reporting and security operations


---

## What you will find here

This repository focuses on:
- Understanding who has access
- How access is protected
- How risk is reduced through identity controls
- How security and usability are balanced

It is designed for Modern Workplace and Microsoft 365 administrators who are responsible for running identity securely at scale.

---

## Safe publishing

This repository contains scripts and examples only.  
Do not commit tenant exports or real user data.

---
