#include "trajectory.h"
#include "adjustableSettings.h"

// Constructor to initialize the size of the arrays and the counter
Trajectory::Trajectory(int size) : maxSize(size), currentSetPoint(0) {
    timeoutDuration = 2000; // 2 seconds default
    lastWithinThresholdTime = millis();
}

// Function to reset the currentSetPoint counting variable
void Trajectory::reset() {
    currentSetPoint = 1;
    lastWithinThresholdTime = millis();
}

// Function to fill trajectory class instance with new data and precompute differences
bool Trajectory::setTrajectoryPoints(const float* newTimes, const double* newPressures, int size) {
    if (size > maxSize) {
        return false;
    }

    // Copy data into the class arrays and precompute differences
    for (int i = 0; i < size; ++i) {
        times[i] = newTimes[i];
        pressures[i] = newPressures[i];
        if (i > 0) {
            timeDifferences[i - 1] = times[i] - times[i - 1];  // Precompute time differences
            pressureDifferences[i - 1] = pressures[i] - pressures[i - 1]; // Precompute pressure differences
        }
    }
    updateTimeoutDuration();
    return true;
}

// Function to linearly interpolate between two points in the trajectory based on deltaT
float Trajectory::interp(unsigned long deltaT) {
    if (maxSize < 2) {
        // Not enough points to interpolate
        return pressures[0];
    }

    // Binary search to find the correct interval for interpolation
    int low = currentSetPoint;
    int high = maxSize - 1;
    while (low < high) {
        int mid = (low + high) / 2;
        if (deltaT < times[mid]) {
            high = mid;
        } else {
            low = mid + 1;
        }
    }
    currentSetPoint = high;

    // Use precomputed differences for linear interpolation
    float t1 = times[currentSetPoint - 1];
    float factor = (deltaT - t1) / timeDifferences[currentSetPoint - 1];
    return pressures[currentSetPoint - 1] + factor * pressureDifferences[currentSetPoint - 1];
}

// Function to check if the system is failing to follow the trajectory
bool Trajectory::failingToFollow(double currentPressure, float deltaT, double threshold) {
    unsigned long currentTime = millis();  // Cache millis() for efficiency

    double expectedPressure = pressures[currentSetPoint];
    if (abs(expectedPressure - currentPressure) > threshold && expectedPressure != 0.0) {
        if ((currentTime - lastWithinThresholdTime) > timeoutDuration) {
            return true;  // Declare failure to follow trajectory
        }
    } else {
        lastWithinThresholdTime = currentTime;  // Update within-threshold time
    }

    return false;  // Not failing
}

// Function to check if the trajectory is finished
bool Trajectory::isFinished(unsigned long deltaT) const {
    return deltaT > times[maxSize - 1];
}

// Function to update the timeout duration based on the longest interval between points
void Trajectory::updateTimeoutDuration() {
    timeoutDuration = 2000;  // Default timeout
    for (int i = 1; i < maxSize; ++i) {
        float interval = timeDifferences[i - 1];  // Use precomputed time differences
        if (interval > timeoutDuration) {
            timeoutDuration = interval + 500;  // Add extra time as a buffer
        }
    }
}

// Initialize the trajectory object
bool InitializeTrajectory(Trajectory* traj, const float* times, const double* pressures, int size) {
    // Ensure the size of the arrays is less than the maxSize of the trajectory object
    return traj->setTrajectoryPoints(times, pressures, size);
}
