# Stark VMS Flutter client

Operator client for the Stark Vehicle Management API: sign in, read the registry
totals and backend health, and manage vehicles.

## Run it

Start `vms-backend` first, then:

```
flutter pub get
flutter run -d chrome
```

The API base URL defaults to `http://localhost:8080`. Point the app somewhere
else at build time:

```
flutter run -d chrome --dart-define=VMS_API_BASE_URL=http://127.0.0.1:8080
```

On an Android emulator the host machine is `http://10.0.2.2:8080`.

The backend answers browser requests from `http://localhost:*` and
`http://127.0.0.1:*` out of the box; any other origin has to be added to
`APP_CORS_ALLOWED_ORIGIN_PATTERNS` in the backend `.env`.

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
