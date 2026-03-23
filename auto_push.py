from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from typing import Iterable


REPO_ROOT = Path(__file__).resolve().parent
WINDOWS_GIT_CANDIDATES = (
    Path(r"C:\Program Files\Git\cmd\git.exe"),
    Path(r"C:\Program Files\Git\bin\git.exe"),
    Path(r"C:\Program Files (x86)\Git\cmd\git.exe"),
)


def find_git() -> str:
    git_from_path = shutil.which("git")
    if git_from_path:
        return git_from_path

    for candidate in WINDOWS_GIT_CANDIDATES:
        if candidate.exists():
            return str(candidate)

    raise FileNotFoundError(
        "git executable was not found. Install Git or update WINDOWS_GIT_CANDIDATES."
    )


def run_git(git: str, args: Iterable[str], check: bool = True) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [git, *args],
        cwd=REPO_ROOT,
        text=True,
        capture_output=True,
        check=check,
    )


def get_current_branch(git: str) -> str:
    result = run_git(git, ["branch", "--show-current"])
    return result.stdout.strip() or "main"


def get_status_lines(git: str) -> list[str]:
    result = run_git(git, ["status", "--short"])
    return [line.rstrip() for line in result.stdout.splitlines() if line.strip()]


def build_commit_message(status_lines: list[str]) -> str:
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    if not status_lines:
        return f"Auto commit {timestamp}"

    changed_files = [line[3:] for line in status_lines if len(line) >= 4]
    if len(changed_files) == 1:
        return f"Update {changed_files[0]}"

    return f"Auto update {len(changed_files)} files ({timestamp})"


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Stage all changes, create an automatic commit, and push to GitHub."
    )
    parser.add_argument(
        "-m",
        "--message",
        help="Custom commit message. If omitted, one is generated automatically.",
    )
    parser.add_argument(
        "--remote",
        default="origin",
        help="Git remote to push to. Default: origin",
    )
    parser.add_argument(
        "--branch",
        help="Git branch to push to. Default: current branch",
    )
    parser.add_argument(
        "--no-push",
        action="store_true",
        help="Commit changes without pushing.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be committed and pushed without changing anything.",
    )
    args = parser.parse_args()

    git = find_git()
    status_lines = get_status_lines(git)

    if not status_lines:
        print("No changes to commit.")
        return 0

    branch = args.branch or get_current_branch(git)
    message = args.message or build_commit_message(status_lines)

    print("Repository:", REPO_ROOT)
    print("Git:", git)
    print("Branch:", branch)
    print("Commit message:", message)
    print("Changed files:")
    for line in status_lines:
        print(" ", line)

    if args.dry_run:
        print("Dry run complete. No changes were staged, committed, or pushed.")
        return 0

    run_git(git, ["add", "-A"])

    commit_result = run_git(git, ["commit", "-m", message], check=False)
    combined_output = (commit_result.stdout + commit_result.stderr).strip()

    if commit_result.returncode != 0:
        if "nothing to commit" in combined_output.lower():
            print("Nothing to commit after staging.")
            return 0

        sys.stderr.write(combined_output + "\n")
        return commit_result.returncode

    if commit_result.stdout.strip():
        print(commit_result.stdout.strip())

    if args.no_push:
        print("Commit created. Push skipped because --no-push was used.")
        return 0

    push_result = run_git(git, ["push", args.remote, branch], check=False)
    push_output = (push_result.stdout + push_result.stderr).strip()

    if push_output:
        print(push_output)

    return push_result.returncode


if __name__ == "__main__":
    raise SystemExit(main())
