# Data Privacy and Retention

> **Read this when:** Designing data handling, responding to a deletion request, or preparing for GDPR/privacy audit.
>
> **Time:** 15 min to read. Complete the data flow audit for your system.
>
> **After reading:** You will have a privacy architecture checklist and know what to implement.
>
> **Prerequisites:** None. See [Sovereignty](../04-compliance/sovereignty.md) for regulatory context.

---

**Policies and controls that ensure sensitive data is used, stored, and deleted correctly.**

Privacy is not just legal. It's architectural. You can't bolt it on later.

---

## Requirements to Design For

| Requirement | What It Means |
|-------------|--------------|
| Data minimization | Collect only what you need |
| Retention windows | Delete data after X days |
| Deletion guarantees | Actually delete, prove you deleted |
| Data residency | Keep data in specified regions |
| Access logging | Know who accessed what, when |
| Least privilege | Default to no access, grant explicitly |

---

## The Failure Mode

The system logs everything "just in case."

Then:
- A customer asks for deletion
- You can't find all copies
- A regulator asks for proof
- You can't provide it

Now you have a compliance incident.

---

## Implementation

**1. Data classification at ingestion**

When data enters the system, tag it:
```python
data.classification = "pii" | "sensitive" | "public"
data.retention_days = 90
data.residency = "eu"
```

**2. Retention enforcement**

Automated deletion based on policy:
```sql
DELETE FROM user_data
WHERE created_at < NOW() - INTERVAL retention_days
  AND classification = 'pii';
```

**3. Deletion verification**

Prove deletion happened:
- Log deletion events
- Verify data is unretrievable
- Provide audit trail on request

**4. Residency enforcement**

Route data based on classification and tenant:
```python
if tenant.region == "eu":
    store = eu_datastore
else:
    store = us_datastore
```

**5. Access logging**

Every access to sensitive data is logged:
```json
{
  "accessor": "user@company.com",
  "resource": "customer_data_123",
  "action": "read",
  "timestamp": "2026-02-02T10:15:00Z",
  "justification": "support_ticket_456"
}
```

---

## The Litmus Test

> Can you explain where sensitive data lives and how it expires?

If the answer requires investigation, privacy is not designed in.

---

> *"Privacy is not just legal. It's architectural. You can't bolt it on later."*
