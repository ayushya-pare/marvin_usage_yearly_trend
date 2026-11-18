#!/usr/bin/env bash
# Run on Marvin from a checkout on a filesystem shared with compute nodes.
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
args=()
check=false
for arg in "$@"; do
  case "$arg" in
    --refresh|--split) args+=("$arg") ;;
    --check) check=true ;;
    -h|--help)
      echo 'Usage: ./generate_raw_reports.sh [--check] [--refresh] [--split]'
      echo 'Configure submit.slurm first. --check validates without submitting.'
      exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done
if grep -q '^#SBATCH.*REQUIRED_' submit.slurm; then
  echo 'Set the REQUIRED_* Slurm resource settings in submit.slurm using your Marvin allocation.' >&2
  exit 2
fi
bash -n submit.slurm
if "$check"; then
  echo 'Configuration syntax checked. Submission command:'
  printf 'sbatch --chdir=%q submit.slurm' "$PWD"
  if ((${#args[@]})); then printf ' %q' "${args[@]}"; fi
  printf '\n'
  exit 0
fi
mkdir -p logs
# All scheduling and logging directives live in submit.slurm.
if ((${#args[@]})); then
  exec sbatch --chdir="$PWD" submit.slurm "${args[@]}"
else
  exec sbatch --chdir="$PWD" submit.slurm
fi
