# Data model — `client` and `asset`

Provider-agnostic by design (CLAUDE.md): a Linode VM, a domain, and a bucket are
all **assets** of different `type`. A new provider or resource type is a new
adapter + `type` value — never a schema reshape.

Stored as WebDNA tab-delimited `.db` files. Schema stubs (header row only) are
tracked as `db/*.db.example`; live `db/*.db` are gitignored. See
[db/README.md](../db/README.md) for setup.

## `client` — who we host for
Stub: [db/clients.db.example](../db/clients.db.example)

| field         | notes                                                        |
|---------------|--------------------------------------------------------------|
| `id`          | numeric primary key                                          |
| `name`        | primary contact name                                         |
| `company`     | business name (may be blank for individuals)                 |
| `email`       | primary contact email                                        |
| `phone`       | contact phone                                                |
| `status`      | `active` \| `suspended` \| `closed`                          |
| `billing_ref` | external billing id — reserved / optional                    |
| `notes`       | freeform                                                     |
| `created`     | ISO-8601 timestamp                                           |
| `modified`    | ISO-8601 timestamp                                           |

## `asset` — a billable thing we manage for a client
Stub: [db/assets.db.example](../db/assets.db.example)

| field         | notes                                                                 |
|---------------|-----------------------------------------------------------------------|
| `id`          | numeric primary key (our internal id)                                 |
| `client_id`   | FK → `client.id`                                                       |
| `type`        | `linode` \| `domain` \| `bucket` \| `firewall` \| `backup`            |
| `provider`    | `linode` (provider-agnostic field; new providers add values)          |
| `provider_id` | the provider's own id — Linode instance id, domain id, bucket name    |
| `label`       | human label (Linode label, domain name, bucket name)                  |
| `region`      | provider region, e.g. `ap-southeast` (Sydney), `au-mel` (Melbourne)   |
| `status`      | provider status, normalised — e.g. `running`/`offline`/`active`       |
| `cost`        | recurring cost, decimal                                               |
| `currency`    | `AUD`                                                                  |
| `renewal`     | next renewal / expiry date (ISO-8601)                                 |
| `created`     | ISO-8601 timestamp                                                    |
| `modified`    | ISO-8601 timestamp                                                    |
| `metadata`    | JSON blob for type-specific extras (specs, records, etc.)             |

### Why `provider_id` + `metadata`
The console is the system of record; the provider holds the live truth. `id` is
ours and stable; `provider_id` joins back to Linode. Type-specific fields (e.g. a
Linode's plan/specs, a domain's record count) live in `metadata` as JSON so the
flat schema stays generic.
