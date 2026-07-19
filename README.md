# FitByte Fitness Tracker

FitByte (a play on FitBit, of course :^]) is a small Go fitness-tracking application with a JSON API, PostgreSQL persistence, and a static web client. The app lets users log in, track sleep sessions, exercise sessions, and meditation sessions, then view their data through pages under `/web/`.

## Motivation

FitByte was built as a learning-focused backend project: a small but realistic application for practicing API design, authentication, database migrations, generated SQL access code, and a simple browser-based client. The goal is to keep the product scope approachable while still touching the parts of a real service that matter: users, credentials, persistence, validation, and authenticated data access.

The project is also a way to explore how health-tracking domains can be modeled in software. Sleep, exercise, and meditation are intentionally simple categories, but they create enough variety to practice designing endpoints, database tables, and frontend flows without letting the application become too large to reason about.

## Quick Start

1. Install the project dependencies:

```bash
go mod download
```

2. Create a PostgreSQL database for local development.

3. Apply the SQL schema files in `sql/schema/` in order:

```text
001_users.sql
002_sleep.sql
003_refresh_tokens.sql
004_exercise.sql
005_meditations.sql
```

4. Create a local `.env` file with the required configuration:

```env
DB_URL=postgres://username:password@localhost:5432/fitbyte?sslmode=disable
PORT=:8080
FILEPATH_ROOT=web
USER_CREATION_TOKEN=replace-me
ADMIN_KEY=replace-me
TOKEN_DURATION=3600
TOKEN_SECRET=replace-me
```

5. Start the server:

```bash
go run .
```

6. Open the web client:

```text
http://localhost:8080/web/
```

Use the port that matches your `PORT` value.

## Usage

FitByte can be used through the static web client or directly through the JSON API.

- Visit `/web/` to use the browser interface.
- Create a user with `POST /api/users` and the `USER_CREATION_TOKEN` bearer token.
- Log in with `POST /api/login` to receive an access token and refresh token.
- Use the access token to create and list sleep, exercise, and meditation sessions.
- Use the refresh token with `POST /api/refresh` when the access token expires.
- Use `POST /api/revoke` to revoke a refresh token.

Full endpoint details, request bodies, and authentication requirements are documented in `api_doc.md`.

## Project Structure

```text
.
├── main.go                 # HTTP server, route handlers, app configuration
├── internal/
│   ├── auth.go             # Password hashing, JWTs, bearer token helpers
│   └── database/           # sqlc-generated database access code
├── sql/
│   ├── schema/             # Goose-style migration files
│   └── queries/            # sqlc query definitions
├── tests/                  # Go tests
├── web/                    # Static frontend pages and shared JS/CSS
├── images/                 # Project screenshots/assets
├── sqlc.yaml               # sqlc configuration
└── api_doc.md              # API reference
```

## Features

- User creation guarded by a server-side creation token.
- Password hashing with Argon2id.
- Login with short-lived JWT access tokens and 60-day refresh tokens.
- Refresh token revocation.
- Authenticated creation and retrieval of:
  - Sleep sessions
  - Exercise sessions
  - Meditation sessions
- Admin-only reset endpoints for development/testing data cleanup.
- Static web client served by the Go server.

## Technology

- Go 1.26.2
- PostgreSQL
- `net/http` routing with method-aware patterns
- `sqlc` for generated database code
- Goose-style SQL migration files
- JWT authentication via `github.com/golang-jwt/jwt/v4`
- Argon2id password hashing via `github.com/alexedwards/argon2id`

## Configuration

The app reads configuration from environment variables. A local `.env` file is loaded during startup if present.

| Variable | Purpose |
| --- | --- |
| `DB_URL` | PostgreSQL connection string |
| `PORT` | HTTP server address, for example `:8080` |
| `FILEPATH_ROOT` | Directory served at `/web/`, typically `web` |
| `USER_CREATION_TOKEN` | Bearer token required by `POST /api/users` |
| `ADMIN_KEY` | Bearer token required by destructive reset endpoints |
| `TOKEN_DURATION` | Access-token lifetime in seconds |
| `TOKEN_SECRET` | Secret used to sign JWT access tokens |

## Development Notes

- The database access layer is generated from `sql/queries/*.sql` using `sqlc`.
- Authentication tests currently cover password hashing and hash comparison.
- The `.http` file contains local request examples for manual API testing.
- API details, including request bodies and auth requirements, live in `api_doc.md`.

## Contributing

Contributions should keep the project simple, readable, and useful as a learning resource.

1. Create a branch for your change.
2. Keep changes focused on one feature, fix, or documentation improvement at a time.
3. Update `api_doc.md` when changing API behavior.
4. Add or update tests when changing authentication, validation, database access, or route behavior.
5. Run the test suite before opening a pull request:

```bash
go test ./...
```

When making schema or query changes, update the SQL files first, regenerate the `sqlc` code, and review the generated files before committing.

## What I Learned

- SQLC and Goose are an incredible stack for managing databases and are going to become a regular part of my workflow.
- I really enjoyed the flexibility that came with using Go for the backend of this project and find myself preferring Go over something like FastAPI in Python.
- Keys as well as tokens allow for secure designs and are a must have in any backend.


## Use of AI in This Project
I think that AI is an incredibly useful tool and is fundamentally reshaping the world of software development. However, I think it is still very important that we as developers pride ourselves on really understanding programming (not just syntax, but a deep level of understanding of how things work) and AI, when used incorrectly, can be quite detrimental to this notion.

For this project, I used AI to help me create the frontend of this application. I have never really built any frontend projects before, so AI allowed me to ship something quickly while also explaining the design choices that it was making - helping my learning overall. It isn't perfect, but it was fun to put together and gives me a solid baseline so that with my next project I can code more of it by hand and deepen my understanding.

As for the backend, that was hand coded by yours truly. I have found a deep love and joy for programming projects such as this one.
