#!/usr/bin/env bash
#
# Builds the Flutter web client on Netlify.
#
# Netlify ships no Flutter SDK, so this fetches one, writes the app_config.env the app
# reads at start-up from the site's environment variables, and builds.
#
# Required environment variable:
#   API_BASE_URL     base URL of the Stark VMS API, no trailing slash
# Optional:
#   FLUTTER_VERSION  SDK version to fetch (set in netlify.toml)

set -euo pipefail

: "${API_BASE_URL:?Set API_BASE_URL in Netlify > Site configuration > Environment variables}"
FLUTTER_VERSION="${FLUTTER_VERSION:-3.44.9}"

FLUTTER_DIR="${HOME}/flutter-${FLUTTER_VERSION}"

if [ ! -x "${FLUTTER_DIR}/bin/flutter" ]; then
  echo "Fetching Flutter ${FLUTTER_VERSION}"
  git clone --depth 1 --branch "${FLUTTER_VERSION}" \
    https://github.com/flutter/flutter.git "${FLUTTER_DIR}"
fi

export PATH="${FLUTTER_DIR}/bin:${PATH}"
git config --global --add safe.directory "${FLUTTER_DIR}"

flutter --version
flutter config --no-analytics --no-cli-animations >/dev/null

# The app reads this file at start-up; it is gitignored, so the deploy writes
# it from the site's own configuration. No URL is baked into the source.
printf 'API_BASE_URL=%s\n' "${API_BASE_URL}" > app_config.env
echo "Building against ${API_BASE_URL}"

flutter pub get
flutter build web --release

echo "Built build/web"
