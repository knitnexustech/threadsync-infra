# Remember Me Feature - Implementation Documentation

## Overview
The "Remember Me" feature allows users to stay logged in across browser sessions, eliminating the need to log in every time they visit the application.

## How It Works

### User Experience
1. **Login Screen**: Users see a "Remember me on this device" checkbox (checked by default)
2. **Checkbox States**:
   - ✅ **Checked**: User stays logged in for **30 days** (uses `localStorage`)
   - ❌ **Unchecked**: Session ends when browser closes (uses `sessionStorage`)
3. **Auto-Login**: If a valid session exists, users are automatically logged in on page load

### Technical Implementation

#### Files Modified/Created:
1. **`sessionUtils.ts`** (NEW) - Session management utility
2. **`components/Login.tsx`** - Added "Remember Me" checkbox
3. **`App.tsx`** - Session restoration logic

#### Storage Strategy:
- **Remember Me = ON**: Uses `localStorage` (persists after browser close, 30-day expiry)
- **Remember Me = OFF**: Uses `sessionStorage` (clears when browser/tab closes)

#### Session Data Structure:
```typescript
{
  user: User,           // User object from database
  timestamp: number,    // When session was created
  rememberMe: boolean   // Whether it's a persistent session
}
```

## Security Considerations

### ✅ Implemented:
- **30-day expiration** for persistent sessions
- **Automatic session clearing** on logout
- **Storage isolation** (only one storage type used at a time)
- **Session validation** on app load

### ⚠️ Security Notes:
1. **XSS Vulnerability**: Tokens in `localStorage` are vulnerable to XSS attacks
   - **Mitigation**: Ensure all user inputs are sanitized
   - **Future**: Consider migrating to httpOnly cookies for production

2. **Shared Devices**: Users on shared computers should uncheck "Remember Me"
   - **Recommendation**: Add a warning for public/shared computers

3. **Token Theft**: If someone gains access to localStorage, they can impersonate the user
   - **Mitigation**: Implement IP/device fingerprinting (future enhancement)

## Usage

### For Users:
```
1. Go to login page
2. Enter phone number and passcode
3. Check/uncheck "Remember me on this device"
4. Click LOGIN
```

### For Developers:

#### Save Session:
```typescript
import { saveSession } from './sessionUtils';

// On successful login
saveSession(user, rememberMe);
```

#### Load Session:
```typescript
import { loadSession } from './sessionUtils';

// On app initialization
const savedUser = loadSession();
if (savedUser) {
  // Auto-login
}
```

#### Clear Session:
```typescript
import { clearSession } from './sessionUtils';

// On logout
clearSession();
```

## Testing Checklist

- [ ] Login with "Remember Me" checked → Close browser → Reopen → Should auto-login
- [ ] Login with "Remember Me" unchecked → Close browser → Reopen → Should require login
- [ ] Logout → Should clear session and require login
- [ ] Wait 30+ days → Session should expire and require login
- [ ] Multiple tabs → Session should sync across tabs

## Future Enhancements

1. **"Logout from all devices"** - Server-side token revocation
2. **Device management** - View and revoke sessions from other devices
3. **Suspicious activity detection** - Alert on login from new location/device
4. **Inactivity timeout** - Auto-logout after X minutes of inactivity
5. **httpOnly cookies** - More secure token storage (requires backend changes)
6. **Refresh tokens** - Short-lived access tokens with long-lived refresh tokens

## Troubleshooting

### Session not persisting:
- Check browser's localStorage/sessionStorage settings
- Ensure cookies/storage are not blocked
- Check browser console for errors

### Auto-login not working:
- Clear browser cache and storage
- Check if session expired (30 days)
- Verify `sessionUtils.ts` is imported correctly

### Session persisting when it shouldn't:
- Ensure "Remember Me" was unchecked
- Manually clear storage: `localStorage.clear()` and `sessionStorage.clear()`

## API Reference

### `saveSession(user, rememberMe)`
Saves user session to storage.
- **Parameters**:
  - `user`: User object
  - `rememberMe`: boolean (true = localStorage, false = sessionStorage)

### `loadSession()`
Loads user session from storage.
- **Returns**: User object or null
- **Side effects**: Clears expired sessions

### `clearSession()`
Clears user session from all storage.

### `hasValidSession()`
Checks if a valid session exists.
- **Returns**: boolean

---

**Last Updated**: 2026-02-03
**Version**: 1.0.0
