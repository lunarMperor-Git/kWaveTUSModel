# kWaveTUSModel

**Written by Guanfa (Felix) Shen, last modified: 8/13/2026**

MATLAB/K-Wave-based computational model of Transcranial Ultrasound Stimulation

This model models acoustic and thermal transcranial ultrasound simulations by using K-Wave and MATLAB. User inputs a m2m file or a .mat file of a head MRI, then specify medium, source, sensor, and grid properties in `general_settings` and `simulation_settings`. Outputs include figures of both acoustic and thermal simulations and numerical results from the simulation. This model was created to compare the BabelBrain and k-wave models, specifically differences in their underlying acoustic mathematical methods (FDTD vs k-Space Pseudospectral Method).

---

## Model Package

| Function/File             | Description                                            |
| ------------------------- | ------------------------------------------------------ |
| `kWaveTUSModel()`         | Acoustic and Thermal model                             |
| `getGeneralSettings()`    | General medium settings                                |
| `getSimulationSettings()` | Various simulation settings (transducer, signal, etc.) |
| `m2m_to_mat()`            | Helper function to turn m2m folder into masks          |
| `resizeMask()`            | Helper function to resize and smooth masks             |
| `new_toneBurst()`         | Revised toneBurst function                             |
| `exampleMain`             | Example simulation                                     |

---

## Requirements

* MATLAB, preferably version R2025b (requires license)
* MATLAB Image Processing Toolbox (requires license)
* MATLAB Parallel Processing Toolbox (recommended, requires license)
* K-Wave Toolbox
* K-Wave C++/CUDA Implementation Binaries (highly recommended)
* 3D Slicer
* 3D Slicer SlicerIGT extension
* SimNIBS (charm)

---

## Limitations

* Unable to rotate transducer in z-direction.
* Limited mask pre-processing methods that require revisions, it is only accurate at 6 PPW.
* Smoothing of medium causes discrepancies at extremely high or low sound speeds and densities.
* Alpha power is set at 2. This may be causing some discrepancies.
* No implementation of GUI.
* Only able to read Cartesian coordinates for focal position.
* Thermal simulation sensors and plotting assume transducer is pointed at the back of the head, and needs revision if transducer needs to be placed elsewhere.

---

## Assumptions

* PRF has negligible effects on heating regime.
* The acoustic simulation is linear

---

## Setup/Installation

1. Install all softwares listed in requirements.
2. Acquire a T1 MRI scan.
3. Use SimNIBS’s charm model to segment tissue masks.

   * **Windows (CMD):**

     ```text
     charm subje
     ```

