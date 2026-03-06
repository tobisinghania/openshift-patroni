Copied from https://github.com/docker-library/postgres/tree/a23c0e97980edae5be2cd4eb68ff1f0762d031cd/15/bullseye

PostgreSQL version: **15.17** on Debian Bullseye.

Changes from upstream:
* Use primary group `0` (root) for OpenShift compatibility, no hardcoded UID/GID
* Set `g=u` permissions on writable directories
* Include `postgresql-server-dev-15` for building extensions in downstream images
* Use `hkps://keys.openpgp.org` for gosu GPG verification