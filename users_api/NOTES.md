# Practice 11 — NOTES

## Level 1: what the wire looks like (jsonplaceholder.typicode.com)

| Request | Status | Body |
|---|---|---|
| `GET /users` | 200, `application/json; charset=utf-8` | array of **10** users |
| `GET /users/1` | 200 | one object |
| `GET /users/999` | **404** | `{}` (empty object, no message) |
| `POST /users` + JSON | **201** | what I sent + `"id": 11` (the server adds only the id; nothing is really saved) |
| `GET /users?id=3` | 200 | a **list of one** `[ {...} ]`, not an object |

Status → exception: 404 → NotFoundException, 401 → UnauthorizedException,
>= 500 → ServerException(status), no response → NoConnectionException,
bad JSON / failed cast → BadResponseException.

### User (top level)

| field | JSON type | Dart type | nullable? |
|---|---|---|---|
| id | number (int) | int | no |
| name | string | String | no |
| username | string | String | no |
| email | string | String | no |
| address | object | Address | no |
| phone | string | String | no |
| website | string | String? | treated as optional |
| company | object | Company record | no |

### address (geo is nested twice: user → address → geo)

| field | JSON type | Dart type | nullable? |
|---|---|---|---|
| street | string | String | no |
| suite | string | String | no |
| city | string | String | no |
| zipcode | string | String | no |
| geo | object | Geo | no |

geo: `lat`, `lng` — **strings** in JSON (`"-37.3159"`) → `double` in Dart.

### company

| field | JSON type | Dart type | nullable? |
|---|---|---|---|
| name | string | String | no |
| catchPhrase | string | String | no |
| bs | string | (ignored) | — |

> Verify these against your own Postman/curl output before handing in.

## Level 5: timings (fill in after testing on a real phone)

- Airplane mode → Offline view after: **___ s** (expected < 1 s)
- Wi-Fi without internet → Offline view after: **___ s** (expected ≈ 10 s)
- Screenshots to add: `screenshot_timeout.png`, `screenshot_200.png`
