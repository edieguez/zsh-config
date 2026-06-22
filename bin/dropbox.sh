#! /usr/bin/env bash
: ${DROPBOX_DIR=$HOME/Dropbox}
: ${DROPBOX_REMOTE=Dropbox}

dry_run=
resync=
extra_args=()

for arg in "$@"; do
  case "$arg" in
    --dry-run) dry_run=true ;;
    --local)   resync=local ;;
    --remote)  resync=remote ;;
    *)         extra_args+=("$arg") ;;
  esac
done

base_flags=(--verbose --exclude ".DS_Store")
[[ -n "$dry_run" ]] && base_flags+=(--dry-run)

if [[ -n "$resync" ]]; then
  if [[ "$resync" == "remote" ]]; then
    src="$DROPBOX_REMOTE:"
    dst="$DROPBOX_DIR"
  else
    src="$DROPBOX_DIR"
    dst="$DROPBOX_REMOTE:"
  fi

  echo "🔄 Syncing — $resync is source of truth${dry_run:+ (dry run)}..."
  rclone sync "${base_flags[@]}" "$src" "$dst" "${extra_args[@]}" ||
    {
      echo "❌ Sync failed (exit code $?)." >&2
      exit $?
    }

  if [[ -n "$dry_run" ]]; then
    echo "✅ Dry run complete — no changes made."
    exit 0
  fi

  echo "↔️ Reinitializing bisync state..."
  rclone bisync "${base_flags[@]}" --resync "$DROPBOX_DIR" "$DROPBOX_REMOTE:" "${extra_args[@]}" ||
    {
      echo "❌ Bisync reinit failed (exit code $?)." >&2
      exit $?
    }
  echo "✅ Resync complete."
  exit 0
fi

echo "🔄 Starting Dropbox sync${dry_run:+ (dry run)}..."
rclone bisync "${base_flags[@]}" "$DROPBOX_DIR" "$DROPBOX_REMOTE:" "${extra_args[@]}"
exit_code=$?

case $exit_code in
0) echo "✅ Sync complete." ;;
2)
  echo "⚠️  Bisync aborted — sync state needs reset." >&2
  echo "    Run with --local to use local as source of truth." >&2
  echo "    Run with --remote to use remote as source of truth." >&2
  exit $exit_code
  ;;
*)
  echo "❌ Sync failed (exit code $exit_code)." >&2
  exit $exit_code
  ;;
esac
