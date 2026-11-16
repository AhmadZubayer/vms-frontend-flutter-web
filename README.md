# Stark VMS Flutter client

Operator client for the Stark Vehicle Management API: sign in, read the registry
totals and backend health, and manage vehicles.

## Configure it

Copy `.env.example` to `.env` and set the API it should talk to. No URL is
written into the Dart code.

```
API_BASE_URL=http://localhost:8080
```

| Where it runs | Value |
| --- | --- |
| Web or desktop against a local API | `http://localhost:8080` |
| Android emulator against a local API | `http://10.0.2.2:8080` |
| Deployed | `https://api.example.com` |

The file is bundled as an asset and read at start-up, so a built web app can be
re-pointed by editing `build/web/assets/.env` without rebuilding. A
`--dart-define=API_BASE_URL=...` passed at build time wins over the file, which
suits CI. If neither is set the app stops with a message naming the variable.

Whatever origin serves this app has to appear in the backend
`APP_CORS_ALLOWED_ORIGIN_PATTERNS`, or the browser blocks the calls.

## Run it

Start `vms-backend` first, then:

```
flutter pub get
flutter run -d chrome
```

## Deploy to Netlify

Netlify has no Flutter runtime, so [`netlify.toml`](netlify.toml) runs
[`scripts/netlify_build.sh`](scripts/netlify_build.sh), which fetches the SDK,
writes `.env` from the site's own environment variables, and builds.

1. Push this repository to GitHub.
2. In Netlify, **Add new site > Import an existing project**, pick the
   repository. The build command and publish directory come from
   `netlify.toml`; leave them as Netlify fills them in.
3. Under **Site configuration > Environment variables** add `API_BASE_URL`,
   the deployed API with no trailing slash, e.g.
   `https://stark-vms-api.onrender.com`. The build fails with a clear message
   if it is missing, rather than shipping a broken app. `FLUTTER_VERSION` is
   optional and defaults to the version pinned in `netlify.toml`.
4. Deploy, then add the Netlify origin, e.g. `https://stark-vms.netlify.app`,
   to the backend `APP_CORS_ALLOWED_ORIGIN_PATTERNS` and redeploy the API.
   Without that the browser blocks every call.

`netlify.toml` also rewrites every unmatched path to `index.html`, which the
app needs because it routes on real paths: without it, reloading
`/dashboard/vehicles` would 404.

To change the API later without a rebuild, edit `assets/.env` in the published
deploy; to change it permanently, update `API_BASE_URL` and redeploy.

## Routes

| Path | Page |
| --- | --- |
| `/login` | Sign-in form |
| `/dashboard` | Registry totals and server status |
| `/dashboard/vehicles` | Vehicle list with search, status filter, and paging |
| `/unauthorized` | Shown when the API rejects the session |
| `/404` | Shown for any unknown path |

`/` redirects to `/dashboard`. A signed-out visitor is sent to `/login`, and a
session the API ends mid-use lands on `/unauthorized`. On the web the paths are
served without a `#`, so a reload of `/dashboard/vehicles` needs the server to
fall back to `index.html` (`flutter run` already does).

## Layout

Feature-first, with one shared core:

```
lib/
  main.dart                     entry point
  app/                          MaterialApp, router, routes, theme
  core/
    config/                     base URL and layout breakpoints
    network/                    Dio client, API failures, session events
    platform/                   web-only path URL strategy
    storage/                    access token storage
    widgets/                    toast, confirm dialog, side sheet, state views
  features/
    auth/        data | domain | presentation
    dashboard/   data | domain | presentation
    vehicles/    data | domain | presentation
    errors/      presentation
```

Inside a feature, `domain` holds plain models, `data` holds the repository that
talks to the API, and `presentation` holds the pages, controllers, and widgets.
A feature may use `core`; it never reaches into another feature's `data`.

## State

Riverpod holds everything:

| Provider | Role |
| --- | --- |
| `authControllerProvider` | The session: restore on launch, sign in, sign out |
| `vehicleQueryProvider` | Page, page size, search term, status filter |
| `vehiclesPageProvider` | The page of vehicles matching that query |
| `vehicleStatsProvider` | Registry totals for the dashboard |
| `serverHealthProvider` | `GET /api/health` |
| `vehicleMutationsProvider` | Create, update, delete, then refresh both reads |

`ApiClient` attaches the bearer token to every request except the login call. A
`401` on any other call is reported through `SessionEvents`, which makes
`AuthController` drop the token and the router show `/unauthorized`.

## Notes

- Searching waits 350 ms after the last keystroke, then asks the API; the status
  dropdown and the pager are server-side too, so the table never filters a page
  it already has.
- Every create, update, and delete reports itself in a toast at the top middle
  of the screen. Deleting asks for confirmation first.
- The side menu is permanent at 1000 px and wider, and sits behind a drawer
  below that; the add and update form slides in from the right on a wide window
  and up from the bottom on a narrow one.
