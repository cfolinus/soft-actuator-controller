#ifndef TRAJECTORY_H
#define TRAJECTORY_H

#include <Arduino.h>

// Define a fixed max trajectory size to avoid dynamic allocation
#define MAX_TRAJECTORY_SIZE 30  // Adjust this size as needed

class Trajectory {
public:
    // Constructor
    Trajectory(int size);

    // Destructor not needed since we're avoiding dynamic memory allocation
    //~Trajectory();  // Remove destructor, not needed anymore

    // Reset the trajectory
    void reset();

    // Check if trajectory is finished
    bool isFinished(unsigned long deltaT) const;

    // Set new trajectory points and precompute differences
    bool setTrajectoryPoints(const float* newTimes, const double* newPressures, int size);

    // Linear interpolation based on deltaT
    float interp(unsigned long deltaT);

    // Check if system is failing to follow trajectory
    bool failingToFollow(double actualPressure, float deltaT, double threshold);

private:
    // Helper to update the timeout duration based on the longest time interval
    void updateTimeoutDuration();

    // Max size of the trajectory
    const int maxSize;

    // Arrays to store times, pressures, and precomputed differences (fixed-size arrays)
    float times[MAX_TRAJECTORY_SIZE];
    double pressures[MAX_TRAJECTORY_SIZE];
    float timeDifferences[MAX_TRAJECTORY_SIZE - 1];     // Precomputed time differences
    double pressureDifferences[MAX_TRAJECTORY_SIZE - 1]; // Precomputed pressure differences

    // Variables to keep track of trajectory progress
    int currentSetPoint;
    unsigned long lastWithinThresholdTime;
    unsigned long timeoutDuration;
};

// Initialize the trajectory object
bool InitializeTrajectory(Trajectory* traj, const float* times, const double* pressures, int size);

#endif  // TRAJECTORY_H
