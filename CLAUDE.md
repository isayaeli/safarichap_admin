# SafariChap Admin

Flutter **Web** dashboard for SafariChap staff. It is the companion to the mobile app (`~/Desktop/safarichap`) and
the Django API (`~/Desktop/safarichap_api`). It only calls `/api/admin/*`, whose contract is in the API's
`docs/BACKEND_GUIDE.md` §14.

## Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # after editing models or Chopper services
cp dart_defines.example.json web/dart_defines.json          # once; gitignored, holds the Firebase web key
flutter run -d chrome                                      # dart-defines still work and take priority
flutter analyze && flutter test                            # keep both clean
flutter build web --release
```

## Architecture: same as the mobile app

Before adding something, find the equivalent file in `~/Desktop/safarichap` and follow it.

- **Layout:** `lib/src/{bindings, st, core/{components,resources,utils,money}, data/{models/<feature>, services/<feature>, repositories}, ui/<feature>}`.
- **DI:** get_it `sl` in `lib/src/st/st.dart`. `InitialBinding` puts the app-wide `SessionController` (staff profile and permission codes) and `ShellController` (section and content navigator).
- **Network:**
  - `AdminClient` (`data/admin_client.dart`) wraps one `ChopperClient` and exposes `xService()` getters.
  - The interceptor sends the Firebase ID token and retries once on **401**. A **403** means a missing permission and is not retried.
  - Services use DRF paths with trailing slashes and put `static create()` at the bottom.
- **Repositories:** return `Result<T>` through `response.toResult(...)` (`core/utils/extensions.dart`). Lists come back as `Paginated<T>`.
- **Controllers:** `GetxController` with `.obs` fields, `repo.x().execute((result) {...})`, and the snack helpers.
  - Every table screen extends `PagedController<T>` (page/search/filters/ordering → DRF query params) and renders `PagedTable<T>`.
  - The catalogue reuses `CatalogueController<T>` with the resource name as the Get tag.
- **Controller lifetime:**
  - Screens `Get.put` their controller in a State field and `Get.delete` it in `dispose`. The nested content navigator isn't watched by GetX's route-based cleanup, so screens must clean up themselves.
  - Detail pages tag the controller `'${uuid}#${identityHashCode(this)}'`, because the same record can be open twice.
- **Navigation:**
  - `ShellScreen` = side nav (collapsible; a drawer under 1000 px) + top bar + a nested `Navigator` (`Get.nestedKey(ShellController.navigatorId)`).
  - Open detail and form pages with `shell.open(Page())` so the side nav stays. Go back with `shell.back()`. Dialogs use `Get.dialog`.
  - `SectionRoot` maps `AdminSection` → list screen. There are no `GetPage` routes, and a browser refresh returns to the first section.
- **Permissions:**
  - Gate UI with `PermissionGate(code: 'x.manage', child: ...)` or `can('x.manage')`.
  - A section shows only if the user has its `AdminSection.permission` (a `.view` code).
  - The API is the authority. The codes live in `safarichap_api/apps/adminpanel/permissions.py`; add new ones there first.
- **Models:** `json_serializable`, with snake_case fields matching the API and `// ignore_for_file: non_constant_identifier_names`. Enums are in `data/models/enums.dart` (copied from the app plus `RefundStatus`, `KycDocumentType`, `BroadcastAudience`). Money stays integers.
- **Money:** `Money` + `Currency`, never `double`.
  - Display with `.formatted` or `.compact`.
  - Parse inputs with `MoneyFormatter.parse` and prefill them with `MoneyFormatter.toInput`.
  - Charts divide into major units only for plotting.
- **Languages:** English is the key (`"Save".tr`), and Kiswahili goes in `core/resources/translations/sw.dart`.
  - Use `.trParams` for `@placeholders`.
  - Components that take a label (`TableColumn`, `FilterDropdown`, `searchHint`, `emptyMessage`, `SimpleTable` headers) call `.tr` themselves, so pass the English string.
  - Strings sent to the API stay English.
- **Theme:** the app's colours and Poppins; light and dark. Use `colorScheme.onSurfaceVariant` for muted text.

## Gotchas

- In an extension on chopper's `Response`, write **`this.body`**. A bare `body` resolves to chopper's top-level `@body` annotation constant and every parse fails with "type 'Body' is not a subtype of …".
- **Never `Get.back()`.** In GetX 4 it closes a visible snackbar *instead of* the dialog/page, and saves show a success snack first, so the dialog stays open. Close dialogs with `closeDialog([result])` (`core/utils/navigation.dart`) and content pages with `shell.back()`.
- Buttons that send a request use `BusyButton(busy: controller.isX.value, ...)` (`core/components/busy_button.dart`): spinner in place of the icon, taps ignored while busy. Give each action its own flag when several buttons share a screen (e.g. `GoalDetailController.acting`).
- `package:web` / `dart:js_interop` only compile for the web. Browser-only code (CSV download) sits behind a conditional export (`core/utils/file_download.dart`) so `flutter test` still runs on the VM.
- Loading indicators and skeletons animate forever, so widget tests must pump fixed frames (see `_settle` in `test/screens_smoke_test.dart`), not `pumpAndSettle`.
- `IntrinsicHeight` around fl_chart (or anything with a `LayoutBuilder`) throws.
- **No keys in source.** `Env` (`core/utils/env.dart`) takes `API_URL`, `FIREBASE_WEB_API_KEY` and `FIREBASE_WEB_APP_ID` from dart-defines, or else fetches `dart_defines.json` at startup (`web/dart_defines.json`, gitignored). Don't re-run `flutterfire configure`: it writes the key back into `lib/firebase_options.dart`. Without a key the sign-in screen shows a notice and stays disabled.

## Tests

- `test/api_contract_test.dart` parses real API responses (`test/fixtures/*.json`). Re-record them with `tool/api_fixtures_test.py` whenever the admin API changes.
- `test/screens_smoke_test.dart` renders every section and detail page through a `MockClient` that answers from the fixtures, and fails on any exception or unanswered request.
- `test/session_test.dart` covers permission gating; `money_test` and `translations_test` are copied from the app.
