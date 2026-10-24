# SafariChap Admin

Flutter Web dashboard for running SafariChap. Staff use it to manage:
- customers and KYC
- savings goals, payments, refunds and bookings
- the trip catalogue
- FX rates, business rules and notifications
- staff, roles and the audit log

It talks to the Django API (`../safarichap_api`) under `/api/admin/`. The architecture mirrors the mobile app (`../safarichap`): GetX, get_it, Chopper, `Result<T>` and json_serializable.

## Run it

1. Start the API (`docker compose -f docker-compose.dev.yaml up` in `safarichap_api`).
2. Give yourself access:
   ```bash
   docker compose -f docker-compose.dev.yaml exec app python manage.py create_super_admin --email you@safarichap.co.tz --name "You"
   ```
   This creates the Firebase user if needed and prints a link to set your password.
3. Register a **Web app** in the `safarichap` Firebase project and turn on the **Email/Password** sign-in provider in Firebase Console → Authentication. Then either:
   - run `flutterfire configure --project=safarichap --platforms=web`, which rewrites `lib/firebase_options.dart`, or
   - pass the Web app's keys at run time (below).
4. Run:
   ```bash
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   flutter run -d chrome \
     --dart-define=API_URL=http://localhost:8000 \
     --dart-define=FIREBASE_WEB_API_KEY=... \
     --dart-define=FIREBASE_WEB_APP_ID=...
   ```

In DEBUG the API accepts any `http://localhost:<port>` origin. In production, add the dashboard's origin to the API's `CORS_ALLOWED_ORIGINS`.

## Checks

```bash
flutter analyze && flutter test
```

- `test/api_contract_test.dart` parses real API responses recorded in `test/fixtures/`.
- `test/screens_smoke_test.dart` renders every section and detail page against those fixtures.
- When the admin API changes, re-record the fixtures with `tool/api_fixtures_test.py` (instructions are at the top of the file).

## Deploy

```bash
docker build -t safarichap-admin \
  --build-arg API_URL=https://api.safarichap.co.tz \
  --build-arg FIREBASE_WEB_API_KEY=... --build-arg FIREBASE_WEB_APP_ID=... .
docker run -p 8081:80 safarichap-admin
```

nginx serves the build with SPA fallback, no-cache on the app shell, and `noindex` / frame-deny headers (`docker/`). Keep the Flutter image tag in the `Dockerfile` on the same version you develop with.

## Roles

Permissions are enforced by the API; the dashboard only hides what you can't use.

| Role | Can |
|---|---|
| Super Admin | Everything, including staff and roles. Can't be edited. |
| Operations | Catalogue, goals, bookings; view customers and payments |
| Finance | Payments (incl. raw webhooks, reconcile), refunds, FX; view goals and settings |
| Support | Customers, KYC review, goals, broadcasts; view payments, refunds and bookings |
| Content | Catalogue only |
| Viewer | Read-only, except staff, roles and the audit log |

Custom roles can be made from any combination of permission codes (Roles → +).
