"""Unit tests for J-Run result parsing without any connected hardware."""
import importlib.util
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

PATH = Path(__file__).resolve().parents[2] / "tools/jrun_gtest_runner.py"
SPEC = importlib.util.spec_from_file_location("jrun_gtest_runner", PATH)
runner = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
SPEC.loader.exec_module(runner)


class RunnerContractTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        from argparse import Namespace
        self.args = Namespace(
            jrun="JRun", device="STM32F407VG", interface="SWD",
            speed=4000, usb=None, timeout=60, log_dir=self.temp.name,
            filter="Arithmetic.*", elf="firmware.elf",
        )

    def simulate(self, output, returncode=0):
        completed = subprocess.CompletedProcess(["JRun"], returncode, stdout=output)
        with patch.object(runner.subprocess, "run", return_value=completed) as run:
            code = runner.run_jrun(self.args)
        self.assertIn("--args", run.call_args.args[0])
        self.assertTrue(list(Path(self.temp.name).glob("*.log")))
        return code

    def test_success_requires_summary_and_zero_exit(self):
        self.assertEqual(self.simulate("GTEST_SUMMARY selected=5 failed=0 skipped=1\n"), 0)

    def test_missing_summary(self):
        self.assertNotEqual(self.simulate("flash OK\n"), 0)

    def test_no_selected_tests(self):
        self.assertNotEqual(self.simulate("GTEST_SUMMARY selected=0 failed=0 skipped=0\n"), 0)

    def test_failed_assertion(self):
        self.assertNotEqual(self.simulate("GTEST_SUMMARY selected=5 failed=1 skipped=0\n"), 0)

    def test_firmware_failure(self):
        self.assertNotEqual(self.simulate("GTEST_SUMMARY selected=5 failed=0 skipped=0\n", 11), 0)

    def test_timeout(self):
        exc = subprocess.TimeoutExpired(["JRun"], 60, output=b"running")
        with patch.object(runner.subprocess, "run", side_effect=exc):
            self.assertEqual(runner.run_jrun(self.args), 124)

    def test_missing_executable(self):
        with patch.object(runner.subprocess, "run", side_effect=FileNotFoundError("JRun")):
            self.assertEqual(runner.run_jrun(self.args), 125)


if __name__ == "__main__":
    unittest.main()
