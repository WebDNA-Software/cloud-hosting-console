# WebDNA notes

Working knowledge accumulated while building this console against **WebDNA 8.6.5**
on an Apache + mod_webdna server — practical gotchas that aren't obvious from the
docs.

---

## Outbound HTTP — use `[shell]` + curl

Make outbound HTTP/API calls with `[shell]` running `curl`. Do **not** use
`[tcpconnect]`/`[tcpsend]`, and `[geturl]` does not exist in this build.

- **Why:** curl handles TLS, headers and redirects and returns just the response
  body (no HTTP headers to strip); `[shell]` is enabled on the server.
- **How:** see `lib/linode_adapter.inc` — `[linode_get path=...&authed=1]` wraps
  curl, adds `Authorization: Bearer [LINODE_API_TOKEN]`, and appends a
  bracket-free `__CONSOLE_HTTP__<code>` marker so callers split status from body.
- **Caveat:** curl `-H` puts the token on argv (visible to local `ps`); before
  prod, move the header into a `curl -K` config file (mode 600).

## Parsing JSON — `[JSONstore2]` only (RAM `table=`)

Use **`[JSONstore2]`**, never `[JSONstore]`. `[jsonstore2]` flattens arrays and
stores each node by full path name; `[JSONstore]` stores an array as a single
`name:array` field (no per-element rows).

- Parse into a **RAM `table=`** (in-memory, discarded on the next HTTP request) —
  not a `.db`, which persists on disk and needs cleanup. `table=` for *parsing
  provider JSON*; `db=` for *our own system-of-record data* (see DB writes below).
- **Array-payload model** (confirmed, `GET /linode/instances` = `{"data":[…]}`):
  `[JSONstore2 table=instances][body][/JSONstore2]` stores the WHOLE document as
  ONE record (carries `page=1`), fields named by JSON path — `data:0:label`,
  `data:1:status`. There is **no** table-name prefix (`[instances:…]` stays literal).

  ```
  [search table=instances&eqpagedata=1][founditems]
    [results]   <- length of the data[] array
    [loop start=0&end=[math][results]-1[/math]]
      [interpret][data:[index]:label][/interpret]
    [/loop]
  [/founditems][/search]
  ```

  `[interpret]` is required because the field name contains the loop's `[index]`.
- **Nested objects/arrays** flatten by colon path: `data:N:specs:vcpus`,
  `data:N:rules:inbound:M:action`, `data:N:backups:schedule:day`, `data:N:ipv4:0`.
  A field that doesn't exist (empty array, or JSON `null`) resolves to its LITERAL
  `[data:N:...]` (and JSON `null` prints the string `null`).
- **Counting a nested array** (it has no `[results]`): iterate a BOUNDED loop and
  only count/render entries whose known field matches via `[switch]` — absent
  entries match nothing and are skipped (firewall rule counts use this).
- **Multiple `table=` tables COEXIST** — a table is destroyed on the next HTTP
  request, NOT on the next `[JSONstore2]` call. You can hold several parsed
  responses at once, or parse per-row inside a loop.
- Do **not** field-slice live JSON with `[middle]` (see below).

## `[if]` / `[switch]` traps

- **`[if]` reads a bare `T`/`F` as a boolean keyword.** A string flag "T" prints
  "T" but `[if [flag]=T]` is FALSE. Use digit sentinels (`1`/`0`) for boolean-ish
  flags/params (`authed=1` + `[if [authed]=1]`).
- **`[if [x]=word]` with a bare lowercase-word RHS is BROKEN.** WebDNA reads an
  unquoted alphabetic RHS as a *variable name* (resolves to empty), so it never
  matches a string literal: `[if running=running]` is NOMATCH. Numeric/hyphenated
  RHS work (`[if [code]=200]`). Fix word comparisons with `[switch]`.
- Comparison operators: `[if]`/`[showif]`/`[hideif]` use `!` for not-equal (NOT
  `!=`); `[switch]` uses `=` only. Numeric `>` / `<` DO work in `[if]`
  (`[if [id] > [maxid]]`). Avoid empty-operand comparisons — unreliable.
- **`[switch]` has no usable default and no fall-through.** A no-value `[case]`
  does not fire as a fallback, `[else]` inside `[switch]` errors ("IfNotFound"),
  and stacked cases don't share a body. Pattern: default the var BEFORE the
  switch, then let a `[case]` flip it; give each value its own full `[case]` body.

## Comments

Comments are **`[!]...[/!]` ONLY**. The `[!-- ... --]` form is INVALID WebDNA and
doesn't always error loudly — don't rely on render output to catch it.

## URL / form params

An ABSENT param renders as the **literal `[name]`**, not empty — so you can't test
presence with an empty-compare. For a numeric id, detect a real value via "first
char is a digit": `[switch value=[getchars start=1&end=1][zone][/getchars]]
[case value=1]…[case value=9]…` (the literal `[zone]` starts with `[`). Form
action dispatch: post `[do]=add|update|delete` and `[switch value=[do]]` runs the
matching case; on a plain load `[do]` is literal and matches nothing (safe no-op).

## Loops

Nested `[loop]`: `[index]` is always the INNERMOST loop. To use an outer loop's
index inside an inner loop, capture it first: `[text]fwi=[index][/text]`, then
`[data:[fwi]:rules:inbound:[index]:action]`.

## `[middle]` on live JSON is unreliable

Field-slicing curl-returned JSON with `[middle startafter=... endbefore=...]`
fails (it re-parses the `[ ]` array brackets); the same `[middle]` on a hardcoded
literal works. `endbefore="` (a lone double-quote) is ignored — `endbefore=",`
works. Use `[JSONstore2]` for real parsing; `[getchars]` + a marker split is fine
for status codes.

## Persistent `.db` writes (system-of-record data → `db=`)

Validated on the server:

- `[append db=db/x.db]f=v&f2=v2[/append]` REQUIRES the db file to already exist
  (it does NOT auto-create) — set up via `cp db/x.db.example db/x.db` and make it
  group-writable by www-data (`chmod 664`; `db/` is setgid www-data).
- `[url]`-encode text values in append/replace bodies (`name=[url][name][/url]`)
  so a literal `&`/`=` in user input doesn't corrupt the record.
- Auto-increment id: scan max then +1 — `[if [id] > [maxid]]`.
- `[replace db=x&eqIDdata=[cid]]…[/replace]` and `[delete db=x&eqIDdata=[id]]`
  use the same `eqFIELDdata=` constraint syntax as `[search]`.
- ISO timestamp in one tag: `[date format=%Y-%m-%dT%H:%M:%S]` (the format honours
  time codes too). Default `[date]` is `dd/mm/yyyy`.
- `[numfound]` renders LITERAL outside its `[search]`; count via a loop counter.

## Includes

`[include file=config/secrets.inc]` (path relative to the template) works; the
`^config/...` form errors with "template not found".

## Environment / server

- **Apache + mod_webdna.** The handler processes `.tpl .tmpl .dna .html .zarc`,
  so `index.html` is WebDNA-evaluated. `DirectoryIndex index.html`.
- Pretty URLs: `.htaccess` internally rewrites `/foo` → `/foo.html` (keeps WebDNA
  processing; POST body + query string preserved).
- `[shell]` must be enabled for the outbound-curl pattern; ensure `curl` is present.
- **WebDNA error log:** `/var/log/apache2/error.log` (`sudo -n tail -f`).
- Template changes deploy fine (no stale-cache problem).
- **Deploy:** `bin/deploy.sh` rsyncs content-only (the web root is typically
  www-data-owned); `--apply` to push, `--clean` to remove stale dev-only files.
