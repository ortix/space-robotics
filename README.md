# Space Robotics
This project simulates a KUKA R10 Agilus robot arm by means of analytical inverse kinematics. It uses SimScape to visualize the robot arm.

## Get Started

* Open 2 MATLAB instances
* In instance 1 open and run `openGui.m`
* In instance 2 open and run `visualizerInterface.m`. Wait for the SimScape model to load and clock to tick.
* In the GUI of instance 1 select `fixed_8.mat` from the `Tasks` dropdown and press `Load`.
* Press execute the trajectory generation and inverse kinematics.
* In instance 2 the robot arm should start moving. The joint angles will also be printed in the terminal of instance 2.

## Files of interest
* `visualizerInterface.m` details the UDP connection and updating of the joint angles.
* `getDH.m` Returns the DH parameters in a struct.
* `forwardKinematics.m` Runs the forward kinematics.
* `inverseKinematics.m` Runs the inverse kinematics. 
* `getTransformToFrame.m` Returns the tranformation matrix from a specified frame to another.
* `pointsInSphere.m` Returns the xyz coordinates of randomly placed points inside a shell within `r1<r<r2`.
* `positionTrajectory2.m` Quintic joint space interpolation. Returns the interpolated joint angles, positions and tool orientations. Uses the `smoothstep.m` function to abstract the matrix calculations.
* `positionTrajectory.m` Task space interpolation with a Sigmoidal Member function.
