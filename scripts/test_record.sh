#!/bin/bash

DRIVER_PATH="test_driver/integration_test_driver.dart"
OUTPUT_VIDEO=test_videos/recording.mp4
RECORD_TIMEOUT=179
START_RECORD_AFTER=0
export MSYS_NO_PATHCONV=1 #disable path conversion

if [ ! -f "pubspec.yaml" ]; then
    echo "This script must be run from the root of the Flutter project."
    exit 1
fi




RUN_START_DATE=$(date +"%Y_%m_%d_%H_%M_%S")

ON_DEVICE_NAME="${RUN_START_DATE}_scenario_1.mp4" #ensure no collision
ON_DEVICE_OUTPUT_FILE="/sdcard/$ON_DEVICE_NAME"
echo "ON_DEVICE_OUTPUT_FILE: $ON_DEVICE_OUTPUT_FILE"

before_test=$(date +"%T")
flutter drive --driver=test_driver/integration_test_driver.dart --target=test/integration_tests/scenario_1_test.dart&
TEST_PID=$!

sleep $START_RECORD_AFTER
adb shell "screenrecord --size 720x1280 --time-limit $RECORD_TIMEOUT $ON_DEVICE_OUTPUT_FILE" &
RECORDING_PID=$!
echo "started record"

wait $TEST_PID
exit_status=$?
if [ $exit_status -ne 0 ]; then
    echo "Test failed"
    STATUS=FAILED
else
    echo "Test passed"
    STATUS=PASSED
fi
wait $RECORDING_PID
echo "$RECORDING_PID"
adb pull $ON_DEVICE_OUTPUT_FILE $OUTPUT_VIDEO

adb shell rm $ON_DEVICE_OUTPUT_FILE