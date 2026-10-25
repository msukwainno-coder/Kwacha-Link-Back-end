# Security checklist

- [ ] Use HTTPS in Render and Supabase; set `NODE_ENV=production`.
- [ ] Keep `.env` out of Git; use Render environment settings.
- [ ] Never use Supabase secret/service-role key in browser code. API currently uses publishable key and user-scoped access-token clients for ordinary requests.
- [ ] Inspect existing RLS policies before applying migration 009. Confirm RLS enabled on all seven tables and test policy behavior with anon, user A, user B.
- [ ] Review public profile exposure: `private_contact` is not selected by profile APIs; never add it to public offer results.
- [ ] Configure `ADMIN_USER_IDS` only with trusted Auth UUIDs; set `SUPABASE_SECRET_KEY` only in Render if manual activation is needed. Restrict dashboard access and audit activations.
- [ ] Keep subscription inserts pending; do not treat browser-supplied payment references as payment proof.
- [ ] Test owner-only offer edits, participant-only messages/deals, cross-account IDOR attempts, role/subscription manipulation, duplicate reviews, and deal confirmation from two separate accounts.
- [ ] Confirm only the second party confirmation deducts amount once, concurrent confirmations do not overdraw, and zero balance marks offer filled.
- [ ] Apply rate limits and CORS allowlist; CORS is not an authorization mechanism.
- [ ] Avoid logging tokens, passwords, message bodies, payment details, or private contact data.
- [ ] Enable Supabase Auth email confirmation and configure password-reset redirect URLs.
- [ ] Back up database and test migrations in a staging project before production.

## Two-account manual security test
Create test accounts A and B. A posts offer. B requests connection. A accepts. B and A exchange messages. Create deal and confirm from B; verify status remains pending. Confirm from A; verify completed and remaining amount reduced once. Attempt to repeat either confirmation and expect failure. Create account C and attempt to read the connection messages and deal; it must fail. Attempt to PATCH A's offer as B; it must not change. Request subscription as B and verify it is pending and contact access remains false until controlled activation. Never use real payment or sensitive production data during testing.
