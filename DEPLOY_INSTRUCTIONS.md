# Deploy Instructions — Hub Personal v1.1

**Versión:** 1.1.0 (POST endpoints enabled)
**Fecha:** 2025-12-13
**Estado:** Ready for production

---

## 🚀 Quick Deploy (Server)

```bash
# SSH to server
ssh root@184.174.33.249

# Navigate to Hub
cd /srv/apps/hub

# Pull latest changes
git pull origin main

# Install dependencies
composer install --no-dev --optimize-autoloader

# Run migrations (Sanctum + hub_events)
php artisan migrate --force

# Clear caches
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Reload PHP-FPM
sudo systemctl reload php8.3-fpm

# Verify
curl https://hub.alvaradomazzei.cl/api/v1/hub/heartbeat
```

---

## 🔑 Generate Production Tokens

### For EnergyApp

```bash
cd /srv/apps/hub
php generate-agent-token.php energyapp prod
```

**Copy token and add to EnergyApp `.env`:**
```env
HUB_API_TOKEN=<generated_token>
HUB_EVENTS_ENABLED=true
```

---

### For Portfolio

```bash
cd /srv/apps/hub
php generate-agent-token.php portfolio prod
```

**Copy token and add to Portfolio `.env`:**
```env
HUB_API_TOKEN=<generated_token>
HUB_EVENTS_ENABLED=true
```

---

### For Supervisor (future)

```bash
cd /srv/apps/hub
php generate-agent-token.php supervisor prod
```

**Note:** Supervisor needs `hub:read` scope only:
```php
$token = $user->createToken('supervisor-prod', ['hub:read']);
```

---

## ✅ Post-Deploy Checklist

- [ ] Migrations ran successfully
- [ ] API endpoints respond:
  - [ ] `GET /api/v1/hub/heartbeat` → 200 OK
  - [ ] `GET /api/v1/hub/info` → 200 OK
  - [ ] `GET /api/v1/hub/events` → 200 OK (empty array expected)
- [ ] Generated tokens for agents
- [ ] Configured agents' `.env` files
- [ ] Tested POST endpoint with curl

---

## 🧪 Test POST Endpoint (Production)

```bash
# Get token from generate-agent-token.php output

curl -X POST https://hub.alvaradomazzei.cl/api/v1/hub/events \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "AppRegistered",
    "source": "energyapp",
    "occurred_at": "2025-12-13T18:00:00Z",
    "payload": {
      "version": "2.1.0",
      "env": "production"
    }
  }'
```

**Expected response:**
```json
{
  "id": "01kcb1...",
  "type": "AppRegistered",
  "source": "energyapp",
  "occurred_at": "2025-12-13T18:00:00+00:00",
  "created_at": "2025-12-13T18:05:12+00:00"
}
```

---

## 🔍 Troubleshooting

### "401 Unauthorized"
- Verify token is correct
- Check token hasn't been revoked
- Confirm `Authorization: Bearer <token>` header

### "403 Forbidden (insufficient_permissions)"
- Token needs `hub:write` scope
- Regenerate token with correct scope

### "403 Forbidden (source_mismatch)"
- Token name must match source (e.g., `energyapp-prod` can only report source `energyapp`)
- Regenerate token with correct name

### "422 Validation Error"
- Check `type` is valid (`AppRegistered`, `AgentHeartbeat`, etc.)
- Verify `occurred_at` is valid ISO8601 and not future (+5 min tolerance)
- Ensure `source` is provided

---

## 📊 Monitor Events

```bash
# SSH to server
ssh root@184.174.33.249

# Connect to database
psql -U hub_user -d hub_personal

# View recent events
SELECT id, type, source, occurred_at, created_at
FROM hub_events
ORDER BY occurred_at DESC
LIMIT 10;

# Count events by type
SELECT type, COUNT(*) as total
FROM hub_events
GROUP BY type
ORDER BY total DESC;

# Events from specific source
SELECT *
FROM hub_events
WHERE source = 'energyapp'
ORDER BY occurred_at DESC
LIMIT 5;
```

---

## 🔄 Rollback (if needed)

```bash
cd /srv/apps/hub

# Revert to previous commit
git revert HEAD

# Or reset to specific commit
git reset --hard a2a0ddc  # Previous stable commit

# Re-deploy
composer install --no-dev
php artisan migrate --force
php artisan config:cache
sudo systemctl reload php8.3-fpm
```

---

## 📞 Support

**Issues:** https://github.com/c0hete/hub-personal/issues
**Docs:** `/srv/knowledge-base/`
**Contact:** José Alvarado

---

**Last updated:** 2025-12-13
