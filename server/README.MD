## Tools

### Email Sending

QFQQ uses Brevo to send transactional emails. The free plan allows up to 300 emails per day.

https://app.brevo.com/profile/information

### Flask CLI Commands

Run these commands from the `server` directory. List registered commands with:

```text
flask --app flaskr --help
```

Available application commands:

- `create-db` — create/reset the database schema. **This drops existing tables and their data.**
- `migrate-db` — apply database migrations.
- `mock-db` — populate the database with sample users and organization data.
- `set-org-paying <org_id> true|false` — set an organization's paying status.

For example, to mark organization `123` as paying:

```shell
flask --app flaskr set-org-paying 123 true
```
