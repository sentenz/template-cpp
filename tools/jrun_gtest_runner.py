#!/usr/bin/env python3
"""Run a Google Test filter on real hardware using SEGGER J-Run and RTT.

Success requires BOTH a zero J-Run process exit code and a non-empty GTest
summary emitted by the firmware. This prevents a flashed-but-not-run false pass.
"""
from __future__ import annotations

import argparse
from pathlib import Path
import re
import subprocess
import sys

SUMMARY = re.compile(r"^GTEST_SUMMARY selected=(\d+) failed=(\d+) skipped=(\d+)\s*$", re.M)


def build_command(args: argparse.Namespace) -> list[str]:
    command = [
        args.jrun, "--nogui", "--quit", "--rtt", "--nosemihost",
        "--device", args.device, "--if", args.interface,
        "--speed", str(args.speed),
    ]
    if args.usb:
        command.extend(["--usb", args.usb])
    command.extend(["--args", args.filter, args.elf])
    return command


def run_jrun(args: argparse.Namespace) -> int:
    log_dir = Path(args.log_dir)
    log_dir.mkdir(parents=True, exist_ok=True)
    slug = re.sub(r"[^A-Za-z0-9_.-]+", "_", args.filter).strip("._") or "all"
    log_path = log_dir / f"{slug}.log"
    command = build_command(args)
    print(f"[jrun] filter={args.filter!r}, ELF={args.elf}", flush=True)

    try:
        result = subprocess.run(
            command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
            text=True, errors="replace", timeout=args.timeout, check=False,
        )
    except subprocess.TimeoutExpired as exc:
        raw = exc.stdout or b""
        output = raw.decode("utf-8", errors="replace") if isinstance(raw, bytes) else raw
        log_path.write_text(output + "\n[jrun] TIMEOUT\n", encoding="utf-8")
        sys.stdout.write(output)
        print(f"[jrun] FAIL: timeout ({args.timeout}s), log={log_path}")
        return 124
    except OSError as exc:
        log_path.write_text(f"[jrun] cannot start J-Run: {exc}\n", encoding="utf-8")
        print(f"[jrun] FAIL: cannot start J-Run: {exc}")
        return 125

    output = result.stdout or ""
    log_path.write_text(output, encoding="utf-8")
    sys.stdout.write(output)
    sys.stdout.flush()
    match = SUMMARY.search(output)
    if result.returncode != 0:
        print(f"[jrun] FAIL: J-Run/firmware exit={result.returncode}, log={log_path}")
        return 1
    if match is None:
        print(f"[jrun] FAIL: missing GTEST_SUMMARY, log={log_path}")
        return 1
    selected, failed, skipped = map(int, match.groups())
    if selected == 0 or failed:
        print(f"[jrun] FAIL: selected={selected}, failed={failed}, skipped={skipped}, log={log_path}")
        return 1
    print(f"[jrun] PASS: selected={selected}, skipped={skipped}, log={log_path}")
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--jrun", required=True)
    parser.add_argument("--device", required=True)
    parser.add_argument("--interface", choices=("SWD", "JTAG"), default="SWD")
    parser.add_argument("--speed", type=int, default=4000)
    parser.add_argument("--usb")
    parser.add_argument("--timeout", type=int, default=60)
    parser.add_argument("--log-dir", required=True)
    parser.add_argument("--filter", required=True)
    parser.add_argument("--elf", required=True)
    args = parser.parse_args(argv)
    if args.timeout <= 0 or args.speed <= 0:
        parser.error("--timeout and --speed must be positive")
    return run_jrun(args)


if __name__ == "__main__":
    raise SystemExit(main())
