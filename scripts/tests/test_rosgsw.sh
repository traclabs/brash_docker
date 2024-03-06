#!/usr/bin/env bash
echo "Current path: $PWD"
source install/setup.bash
colcon test  --event-handlers console_cohesion+ --ctest-args " -VVV" --return-code-on-test-failure --packages-select cfe_plugin
