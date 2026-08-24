# Firebase Budget Monitoring Setup

## Overview

Monitor Firebase costs to avoid unexpected charges. The free Spark plan has limits;
set up alerts before hitting them.

## Setup Steps

### 1. Google Cloud Budget Alert

1. Go to [Google Cloud Console](https://console.cloud.google.com/billing/budgets)
2. Select your billing account
3. Click **Create Budget**
4. Set budget name: `monopoli-indonesia-monthly`
5. Set amount: `$25/month` (or your preferred limit)
6. Alert thresholds: `50%, 80%, 100%`
7. Notification channels: Email + (optional) Slack/PagerDuty

### 2. Firebase Usage Monitoring

1. Go to [Firebase Console](https://console.firebase.google.com) → Usage tab
2. Monitor these metrics:
   - **Realtime Database**: Connections, storage, bandwidth
   - **Authentication**: Verifications/month
   - **Firestore**: Reads, writes, deletes, storage
   - **Hosting**: Storage, transfer
   - **Analytics**: Events logged

### 3. Free Tier Limits (Spark Plan)

| Service | Free Limit |
|---------|-----------|
| Realtime Database | 100 concurrent connections, 1 GB storage |
| Firestore | 50K reads/day, 20K writes/day, 1 GB storage |
| Authentication | 10K verifications/month |
| Hosting | 10 GB storage, 360 MB/day transfer |
| Analytics | Unlimited |
| Crashlytics | Unlimited |

### 4. Alerts Configuration

```json
{
  "budget": {
    "amount": 25,
    "currency": "USD",
    "period": "monthly"
  },
  "alerts": [
    {"threshold": 0.5, "channel": "email"},
    {"threshold": 0.8, "channel": "email"},
    {"threshold": 1.0, "channel": "email"}
  ]
}
```

### 5. Cost Optimization Tips

- Enable RTDB persistence offline to reduce reads
- Use `limitToLast()` for chat messages (already implemented: 50)
- Clean up old rooms periodically (add TTL or scheduled function)
- Use Firebase Emulator for local development
- Monitor `database.rules.json` to prevent unauthorized writes

### 6. Emergency Killswitch

If costs spike unexpectedly:

```bash
# Disable RTDB
firebase database:instances:disable

# Disable specific Firebase services
# Go to Firebase Console → Project Settings → Usage
```
