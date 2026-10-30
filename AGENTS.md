# omitsis-devops/php

Base image `ghcr.io/omitsis-devops/php:<ver>-fpm-alpine` (also `omitsis/php` on Docker Hub). It is
the `FROM` of omitsis-stack-templates' `services/php-fpm/Dockerfile`, so every site's php-fpm
builds on it. GitHub Actions (`.github/workflows/docker-image.yml`) builds and publishes it for
PHP 7.4–8.5 on every push to `main`, weekly and on manual runs: a push to `main` ships to every
site. Don't push without the user's go-ahead.

## Rule: Dockerfile changes

Whenever the `Dockerfile` changes (installed packages, extensions, tools, config), remind the user
that omitsis-stack-templates must be updated to match:

- the reference copy of this Dockerfile under `services/php-fpm/` (formerly `Dockerfile.build`,
  renamed by the 2026-10-30 task);
- the "already in the base image" list in `services/php-fpm/README.md`.
