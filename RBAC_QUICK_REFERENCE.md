# Role-Based UI Control - Quick Reference

## Permission Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         USER LOGS IN                                 │
│                              ↓                                       │
│                    Check currentUser.role                            │
└─────────────────────────────────────────────────────────────────────┘
                                ↓
        ┌───────────────────────┼───────────────────────┐
        ↓                       ↓                       ↓
    ┌───────┐            ┌──────────┐           ┌──────────┐
    │ ADMIN │            │  SENIOR  │           │  JUNIOR  │
    └───────┘            └──────────┘           └──────────┘
        ↓                       ↓                       ↓
    Full Access          Partial Access          View Only
```

---

## Component Permission Matrix

### Sidebar Component

```
┌─────────────────────────────────────────────────────────────────────┐
│                          SIDEBAR.TSX                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  [⚙️ Settings Menu]                                                  │
│    ├─ 🌙 Dark Mode Toggle          → ALL USERS                      │
│    ├─ 📋 List of Suppliers         → canManageSuppliers             │
│    └─ 👥 Team Members              → ALL USERS                      │
│                                                                      │
│  [📦 Purchase Orders List]                                           │
│    ├─ View POs                     → ALL USERS                      │
│    ├─ + Add Channel (per PO)      → canCreateChannel                │
│    └─ Channel List                 → ALL USERS                      │
│                                                                      │
│  [➕ Create PO Button (Footer)]    → canCreatePO                     │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘

Permissions:
  canCreatePO         = ADMIN, SENIOR_MERCHANDISER
  canCreateChannel    = ADMIN, SENIOR_MERCHANDISER, SENIOR_MANAGER
  canManageSuppliers  = Manufacturers only (not vendors)
```

---

### ChatRoom Component

```
┌─────────────────────────────────────────────────────────────────────┐
│                         CHATROOM.TSX                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  [💬 Message Area]                                                   │
│    ├─ View Messages                → ALL USERS                      │
│    ├─ Send Messages                → ALL USERS                      │
│    ├─ Edit Own Message             → canEditMessage(msg)            │
│    └─ Delete Own Message           → canDeleteMessage(msg)          │
│                                                                      │
│  [ℹ️ Group Info Panel]                                               │
│    ├─ View Members                 → ALL USERS                      │
│    ├─ + Add Member Button          → canAddMembers (ADMIN only)     │
│    └─ Update Channel Status        → canEditChannel                 │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘

Permissions:
  canAddMembers       = ADMIN only
  canEditChannel      = ADMIN, SENIOR_MERCHANDISER, SENIOR_MANAGER
  canEditMessage      = message.user_id === currentUser.id
  canDeleteMessage    = message.user_id === currentUser.id
```

---

### SpecDrawer Component

```
┌─────────────────────────────────────────────────────────────────────┐
│                        SPECDRAWER.TSX                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  [📋 SPECS TAB]                                                      │
│    ├─ View Specs                   → ALL USERS                      │
│    ├─ Add Spec (textarea)          → canEditChannel                 │
│    └─ Delete Spec (hover button)   → canEditChannel                 │
│                                                                      │
│  [📎 FILES TAB]                                                      │
│    ├─ View Files                   → ALL USERS                      │
│    ├─ Upload File                  → canEditChannel                 │
│    └─ Delete File (hover button)   → canEditChannel                 │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘

Permissions:
  canEditChannel      = ADMIN, SENIOR_MERCHANDISER, SENIOR_MANAGER
```

---

## Role Capabilities Summary

### 👑 ADMIN
```
✅ Create PO
✅ Edit PO (when implemented)
✅ Delete PO (when implemented)
✅ Create Channel
✅ Edit Channel (when implemented)
✅ Delete Channel (when implemented)
✅ Add Members to Channel
✅ Remove Members from Channel
✅ Invite Team Members
✅ Change User Roles
✅ Add/Delete Specs
✅ Upload/Delete Files
✅ Edit/Delete Own Messages
✅ Manage Suppliers
```

### 📊 SENIOR_MERCHANDISER
```
✅ Create PO
✅ Edit PO (when implemented)
✅ Delete PO (when implemented)
✅ Create Channel
✅ Edit Channel (when implemented)
✅ Delete Channel (when implemented)
❌ Add Members to Channel
❌ Remove Members from Channel
❌ Invite Team Members
❌ Change User Roles
✅ Add/Delete Specs
✅ Upload/Delete Files
✅ Edit/Delete Own Messages
✅ Manage Suppliers (if manufacturer)
```

### 🏢 SENIOR_MANAGER
```
❌ Create PO
❌ Edit PO
❌ Delete PO
✅ Create Channel
✅ Edit Channel (when implemented)
✅ Delete Channel (when implemented)
❌ Add Members to Channel
❌ Remove Members from Channel
❌ Invite Team Members
❌ Change User Roles
✅ Add/Delete Specs
✅ Upload/Delete Files
✅ Edit/Delete Own Messages
✅ Manage Suppliers (if manufacturer)
```

### 📝 JUNIOR_MERCHANDISER
```
❌ Create PO
❌ Edit PO
❌ Delete PO
❌ Create Channel
❌ Edit Channel
❌ Delete Channel
❌ Add Members to Channel
❌ Remove Members from Channel
❌ Invite Team Members
❌ Change User Roles
❌ Add/Delete Specs
❌ Upload/Delete Files
✅ Edit/Delete Own Messages
✅ View All Assigned Content
✅ Send Messages
```

### 📋 JUNIOR_MANAGER
```
❌ Create PO
❌ Edit PO
❌ Delete PO
❌ Create Channel
❌ Edit Channel
❌ Delete Channel
❌ Add Members to Channel
❌ Remove Members from Channel
❌ Invite Team Members
❌ Change User Roles
❌ Add/Delete Specs
❌ Upload/Delete Files
✅ Edit/Delete Own Messages
✅ View All Assigned Content
✅ Send Messages
```

---

## Code Pattern Examples

### Pattern 1: Simple Role Check
```typescript
// In component
const canCreatePO = ['ADMIN', 'SENIOR_MERCHANDISER'].includes(currentUser.role);

// In JSX
{canCreatePO && (
  <button onClick={handleCreatePO}>
    Create PO
  </button>
)}
```

### Pattern 2: Ownership Check
```typescript
// In component
const canEditMessage = (message: Message) => message.user_id === currentUser.id;

// In JSX
{messages.map(msg => (
  <div>
    {msg.content}
    {canEditMessage(msg) && (
      <button onClick={() => handleEdit(msg)}>Edit</button>
    )}
  </div>
))}
```

### Pattern 3: Combined Check
```typescript
// In component
const canManageSuppliers = !isVendor; // Company type check

// In JSX
{canManageSuppliers && (
  <button onClick={openSuppliersModal}>
    List of Suppliers
  </button>
)}
```

---

## UI States by Role

### When ADMIN Opens App
```
Sidebar:
  ✅ Create PO button visible
  ✅ Add Channel buttons visible
  ✅ Settings → Suppliers visible
  ✅ Settings → Team Members visible

ChatRoom:
  ✅ Add Member button visible
  ✅ Edit/Delete own messages

SpecDrawer:
  ✅ Add Spec form visible
  ✅ Delete buttons on specs
  ✅ Upload File button visible
  ✅ Delete buttons on files
```

### When SENIOR_MERCHANDISER Opens App
```
Sidebar:
  ✅ Create PO button visible
  ✅ Add Channel buttons visible
  ✅ Settings → Suppliers visible
  ✅ Settings → Team Members visible (view only)

ChatRoom:
  ❌ Add Member button hidden
  ✅ Edit/Delete own messages

SpecDrawer:
  ✅ Add Spec form visible
  ✅ Delete buttons on specs
  ✅ Upload File button visible
  ✅ Delete buttons on files
```

### When JUNIOR_MERCHANDISER Opens App
```
Sidebar:
  ❌ Create PO button hidden
  ❌ Add Channel buttons hidden
  ✅ Settings → Suppliers visible
  ✅ Settings → Team Members visible (view only)

ChatRoom:
  ❌ Add Member button hidden
  ✅ Edit/Delete own messages

SpecDrawer:
  ❌ Add Spec form hidden
  ❌ Delete buttons on specs hidden
  ❌ Upload File button hidden
  ❌ Delete buttons on files hidden
  ℹ️ Shows: "Only Admins and Senior members can add specs."
```

---

## Testing Scenarios

### Test Case 1: ADMIN User
1. Login as ADMIN
2. Should see "+" button in footer
3. Click "+" → Create PO modal opens
4. Create PO successfully
5. Should see "Add Channel" button under PO
6. Click "Add Channel" → Modal opens
7. Open ChatRoom
8. Should see "Add Member" button in group info
9. Open SpecDrawer
10. Should see "Add Spec" form
11. Should see upload button in Files tab

### Test Case 2: JUNIOR_MERCHANDISER User
1. Login as JUNIOR_MERCHANDISER
2. Should NOT see "+" button in footer
3. Should NOT see "Add Channel" buttons
4. Open ChatRoom
5. Should NOT see "Add Member" button
6. Can send messages
7. Can see edit/delete on own messages
8. Open SpecDrawer
9. Should NOT see "Add Spec" form
10. Should see message: "Only Admins and Senior members can add specs."

### Test Case 3: Message Ownership
1. Login as any user
2. Send a message
3. Should see edit/delete buttons on that message
4. Should NOT see edit/delete on other users' messages

---

## Quick Troubleshooting

### Issue: User can't see Create PO button
**Check:**
- Is user role ADMIN or SENIOR_MERCHANDISER?
- Is `canCreatePO` variable correctly set?
- Is button wrapped in `{canCreatePO && ...}` conditional?

### Issue: User can't add members
**Check:**
- Is user role ADMIN?
- Is `canAddMembers` set to `currentUser.role === 'ADMIN'`?
- Was the permission updated from the old model?

### Issue: Specs not saving
**Check:**
- Is backend API implemented?
- Check console for errors
- Verify `handleAddSpec` is being called
- Check if TODO comment is still in place

---

**End of Quick Reference**
