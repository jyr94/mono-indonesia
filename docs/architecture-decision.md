# Architecture Decision: Backend Approach

## Decision: Node.js WebSocket Server (Authoritative)

### Rationale

| Criteria | Node.js WebSocket | Firebase Only |
|----------|-------------------|---------------|
| Authoritative server | ✅ Full control | ❌ Limited |
| Anti-cheat | ✅ Server-side validation | ⚠️ Cloud Functions (cold start) |
| Real-time latency | ✅ Persistent connection | ✅ Good |
| Cost (MVP) | $5/mo DigitalOcean | Free tier → pay-as-you-go |
| Complexity | Medium | Low |
| Scalability | Manual | Auto |

### Chosen Approach: **Node.js + ws (Primary) + Firebase (Supplement)**

- **Node.js WebSocket server** for authoritative game logic (dice, money, turns)
- **Firebase Auth** for user authentication (guest + Google)
- **Firestore** for user profile persistence only (not game state)
- **Firebase Analytics + Crashlytics** for monitoring

### Server Stack
- Runtime: Node.js 20+
- WebSocket: `ws` library (lightweight, no overhead)
- Hosting: DigitalOcean droplet ($5/mo) or Railway/Render free tier for dev
- No database needed on server (game state is in-memory, rooms are ephemeral)

### Why Not Firebase-Only?
1. Dice rolls must be server-authoritative to prevent cheating
2. Cloud Functions have cold start latency (~1-3s) bad for real-time games
3. Firestore listeners can't enforce strict turn ordering reliably
4. Full control over game state machine

### Tradeoffs Accepted
- Need to manage a server (monitoring, restarts)
- Slightly more infrastructure setup than pure Firebase
- Server costs ~$5/mo (vs free Firebase tier for low usage)

### Alternative Considered
Firebase Realtime Database + Cloud Functions could work for faster MVP but sacrifices authoritativeness. Can be revisited if server maintenance becomes burden.
