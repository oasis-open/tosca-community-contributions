# org.postgresql:1.0

TOSCA profile for [PostgreSQL](https://www.postgresql.org), the
open-source relational database management system.

## Node types

- **Dbms** — installation of the PostgreSQL server (apt package
  `postgresql`).
- **User** — a PostgreSQL role/user account, managed by a `Dbms`,
  exposing a `Credential` capability.
- **Database** — a logical database managed by a `Dbms` and owned by
  a `User`.
