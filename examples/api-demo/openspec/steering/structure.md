# Structure: api-demo

## Directory layout
```
src/
  index.js          # HTTP server entry point
  routes/           # Route handlers (one file per domain)
```

## Layers & responsibilities

| Layer | Directory | Responsibility |
|-------|-----------|----------------|
| HTTP  | `src/`    | Request handling, routing, response formatting |

## Standard flow
```
Request → index.js → route handler → JSON response
```
