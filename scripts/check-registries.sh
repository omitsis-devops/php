#!/usr/bin/env bash
# Compare omitsis php images on ghcr.io and Docker Hub: digest + build date per tag.
# Same digest on both sides = same build reached both registries.
set -euo pipefail

VERSIONS="${*:-7.4 8.1 8.2 8.3 8.4 8.5}"
ACCEPT="application/vnd.oci.image.index.v1+json,application/vnd.docker.distribution.manifest.list.v2+json,application/vnd.oci.image.manifest.v1+json,application/vnd.docker.distribution.manifest.v2+json"
GHCR_TOKEN=$(curl -s "https://ghcr.io/token?scope=repository:omitsis-devops/php:pull" | jq -r .token)

ghcr() { curl -s -H "Authorization: Bearer $GHCR_TOKEN" -H "Accept: $ACCEPT" "https://ghcr.io/v2/omitsis-devops/php/$1"; }

for v in $VERSIONS; do
  tag="$v-fpm-alpine"

  g_digest=$(curl -s -I -H "Authorization: Bearer $GHCR_TOKEN" -H "Accept: $ACCEPT" \
    "https://ghcr.io/v2/omitsis-devops/php/manifests/$tag" | awk -F': ' 'tolower($1)=="docker-content-digest"{print $2}' | tr -d '\r')
  g_created="-"
  if [ -n "$g_digest" ]; then
    # index -> amd64 manifest -> config blob "created"
    amd64=$(ghcr "manifests/$tag" | jq -r '[.manifests[]? | select(.platform.architecture=="amd64")][0].digest // empty')
    cfg=$(ghcr "manifests/${amd64:-$tag}" | jq -r '.config.digest')
    g_created=$(curl -sL -H "Authorization: Bearer $GHCR_TOKEN" "https://ghcr.io/v2/omitsis-devops/php/blobs/$cfg" | jq -r '.created')
  fi

  hub=$(curl -s "https://hub.docker.com/v2/repositories/omitsis/php/tags/$tag")
  h_digest=$(jq -r '.digest // "-"' <<<"$hub")
  h_pushed=$(jq -r '.tag_last_pushed // "-"' <<<"$hub")
  h_arch=$(jq -r '[.images[]?.architecture] | join(",")' <<<"$hub")

  [ "$g_digest" = "$h_digest" ] && match=MATCH || match=DIFF

  jq -n --arg tag "$tag" --arg match "$match" \
    --arg gd "${g_digest:--}" --arg gc "$g_created" \
    --arg hd "$h_digest" --arg hp "$h_pushed" --arg ha "$h_arch" \
    '{tag:$tag, same_build:$match, ghcr:{digest:$gd, created:$gc}, dockerhub:{digest:$hd, pushed:$hp, arch:$ha}}'
done
