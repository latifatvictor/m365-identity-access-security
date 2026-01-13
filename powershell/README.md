# PowerShell Scripts

These scripts support Microsoft 365 identity governance and access security.

## Scripts

- `export-conditional-access-policies.ps1`  
  Exports Conditional Access policies (sanitised) and creates a CSV summary.

  Permissions: `Policy.Read.All`

- `export-admin-role-assignments.ps1`  
  Exports Entra ID admin role assignments to CSV for access reviews.

  Permissions: `RoleManagement.Read.Directory`, `Directory.Read.All`

## Safety note
Do not commit CSV/JSON exports from production tenants. Keep all outputs private.
