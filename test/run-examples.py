#!/usr/bin/env python3
"""Run BASIC examples with deterministic interactive input and local data fixtures."""

from __future__ import annotations

import argparse
import os
import pty
import re
import select
import subprocess
import tempfile
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FIXTURES = {
    "fit.dat": "1 3\n2 5\n3 7\n4 9\n",
    "real.dat": "0 1\n1 0\n2 -1\n3 0\n",
    "imag.dat": "0 0\n1 0\n2 0\n3 0\n",
    "flow.dat": "0 0 1 0\n1 0 0 1\n0 1 -1 0\n1 1 0 -1\n",
    "data.dat": "0 1\n1 2\n2 3\n3 4\n",
    "input.dat": "0 1\n1 2\n2 3\n3 4\n",
    "femflow2d.dat": "0 0 1 0\n1 0 0 1\n0 1 -1 0\n1 1 0 -1\n",
}
PROMPT_END = re.compile(r"(?:->|=>|[?:=])\s*$")


def response(program: str, prompt: str) -> str:
    text = prompt.lower()
    if "file name to save" in text:
        return ""
    if any(word in text for word in ("imaginary", "imag part")):
        return "imag.dat"
    if "real part" in text:
        return "real.dat"
    if "flow" in text and any(word in text for word in ("file", "name", "input")):
        return "flow.dat"
    if "interactive looping" in text:
        return "2"
    if "stop iteration" in text:
        return "1"
    if "initial energy increment" in text:
        return "0.1"
    if "length scale" in text:
        return "1"
    if "energy scale" in text:
        return "0.01"
    if "dx" in text:
        return "0.11"
    if "plot at interval" in text:
        return "1"
    if "interval" in text and "time steps" in text:
        return "1"
    if any(word in text for word in ("file", "filename", "data file")):
        return "fit.dat" if "fit" in program.lower() else "data.dat"
    if "forward" in text or "transform" in text:
        return "1"
    if "real data" in text or "complex" in text:
        return "1"
    if any(word in text for word in ("save", "portion", "nyquist", "yes/no")):
        return "0"
    if "time step" in text or re.search(r"\bdt\b", text):
        return "0.01"
    if "time constant" in text:
        return "10"
    if "number of walks" in text:
        return "20"
    if any(word in text for word in ("cutoff", "fraction")):
        return "0.01"
    if "initial number" in text:
        return "100"
    if "start x" in text:
        return "0"
    if "end x" in text:
        return "1"
    if "max number of panels" in text:
        return "1"
    if "max number" in text:
        return "20"
    if any(word in text for word in (
        "number of points", "number points", "number of division",
        "number divide", "number of equations", "number of steps",
    )):
        return "4"
    if "map the max" in text:
        return "2"
    if "map the min" in text or "map the arrow" in text:
        return "0" if "max" not in text else "1"
    if "xmax" in text:
        return "1"
    return "1"


def make_fixtures(directory: Path) -> None:
    for name, contents in FIXTURES.items():
        (directory / name).write_text(contents, encoding="utf-8")


def run_one(program: Path, timeout: float) -> tuple[str, str]:
    with tempfile.TemporaryDirectory(prefix="truebasic-example-") as temporary:
        work = Path(temporary)
        make_fixtures(work)
        master, slave = pty.openpty()
        process = subprocess.Popen(
            ["rakupp", str(ROOT / "TrueBASIC.raku"), "--graphics=svg", str(program)],
            cwd=work,
            stdin=subprocess.PIPE,
            stdout=slave,
            stderr=slave,
            close_fds=True,
        )
        os.close(slave)
        output = bytearray()
        answered_through = 0
        start = time.monotonic()
        timed_out = False
        try:
            while process.poll() is None:
                remaining = timeout - (time.monotonic() - start)
                if remaining <= 0:
                    timed_out = True
                    process.kill()
                    break
                ready, _, _ = select.select([master], [], [], min(remaining, 0.2))
                if not ready:
                    continue
                try:
                    chunk = os.read(master, 4096)
                except OSError:
                    break
                if not chunk:
                    break
                output.extend(chunk)
                current = output.decode("utf-8", errors="replace")
                line_start = current.rfind("\n") + 1
                prompt_line = current[line_start:]
                markers = [
                    match for match in PROMPT_END.finditer(prompt_line)
                    if line_start + match.end() > answered_through
                ]
                if markers:
                    marker = markers[-1]
                    absolute_end = line_start + marker.end()
                    prompt_text = current[max(line_start, answered_through):line_start + marker.end()]
                    answer = response(program.name, prompt_text)
                    process.stdin.write((answer + "\n").encode())
                    process.stdin.flush()
                    answered_through = absolute_end
            try:
                process.wait(timeout=1)
            except subprocess.TimeoutExpired:
                process.kill()
                process.wait()
            while select.select([master], [], [], 0)[0]:
                try:
                    chunk = os.read(master, 4096)
                except OSError:
                    break
                if not chunk:
                    break
                output.extend(chunk)
        finally:
            os.close(master)
            if process.stdin:
                process.stdin.close()
        result = output.decode("utf-8", errors="replace").replace("\r\n", "\n")
        if timed_out:
            return "TIMEOUT", result
        if process.returncode or "Runtime error" in result or "Fatal error" in result:
            return "FAIL", result
        return "PASS", result


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--only", help="run one example by filename")
    parser.add_argument("--timeout", type=float, default=10, help="seconds per example (default: 10)")
    args = parser.parse_args()
    examples = sorted(
        path for path in (ROOT / "examples").iterdir()
        if path.is_file() and path.suffix.lower() in {".tru", ".bas"}
    )
    if args.only:
        examples = [path for path in examples if path.name.lower() == args.only.lower()]
        if not examples:
            parser.error(f"no example named {args.only!r}")
    totals = {"PASS": 0, "FAIL": 0, "TIMEOUT": 0}
    for program in examples:
        status, output = run_one(program, args.timeout)
        totals[status] += 1
        print(f"{status:7} {program.name}")
        if status != "PASS":
            lines = [line for line in output.splitlines() if line.strip()]
            for line in lines[-5:]:
                print(f"         {line}")
    print(
        f"\nSummary: {totals['PASS']} passed, {totals['FAIL']} failed, "
        f"{totals['TIMEOUT']} timed out ({len(examples)} total)"
    )
    return 1 if totals["FAIL"] or totals["TIMEOUT"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
