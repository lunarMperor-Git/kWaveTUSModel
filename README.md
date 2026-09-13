# kWaveTUSModel

**Written by Guanfa (Felix) Shen, last modified: 8/13/2026**

MATLAB/K-Wave-based computational model of Transcranial Ultrasound Stimulation

This model models acoustic and thermal transcranial ultrasound simulations by using K-Wave and MATLAB. User inputs a m2m file or a .mat file of a head MRI, then specify medium, source, sensor, and grid properties in `general_settings` and `simulation_settings`. Outputs include figures of both acoustic and thermal simulations and numerical results from the simulation. This model was created to compare the BabelBrain and k-wave models, specifically differences in their underlying acoustic mathematical methods (FDTD vs k-Space Pseudospectral Method).

---

## Model Package

| Function/File | Description |
|---|---|
| `kWaveTUSModel()` | Acoustic and Thermal model |
| `getGeneralSettings()` | General medium settings |
| `getSimulationSettings()` | Various simulation settings (transducer, signal, etc.) |
| `m2m_to_mat()` | Helper function to turn m2m folder into masks |
| `resizeMask()` | Helper function to resize and smooth masks |
| `new_toneBurst()` | Revised toneBurst function |
| `exampleMain` | Example simulation |

---

## Requirements

- MATLAB, preferably version R2025b (requires license)
- MATLAB Image Processing Toolbox (requires license)
- MATLAB Parallel Processing Toolbox (recommended, requires license)
- K-Wave Toolbox
- K-Wave C++/CUDA Implementation Binaries (highly recommended)
- 3D Slicer
- 3D Slicer SlicerIGT extension
- SimNIBS (charm)

---

## Limitations

- Unable to rotate transducer in z-direction.
- Limited mask pre-processing methods that require revisions, it is only accurate at 6 PPW.
- Smoothing of medium causes discrepancies at extremely high or low sound speeds and densities.
- Alpha power is set at 2. This may be causing some discrepancies.
- No implementation of GUI.
- Only able to read Cartesian coordinates for focal position.
- Thermal simulation sensors and plotting assume transducer is pointed at the back of the head, and needs revision if transducer needs to be placed elsewhere.

---

## Assumptions

- PRF has negligible effects on heating regime.
- The acoustic simulation is linear

---

## Setup/Installation

1. Install all softwares listed in requirements.
2. Acquire a T1 MRI scan.
3. Use SimNIBS’s charm model to segment tissue masks.
   - **Windows (CMD):**
     ```text
     charm subject_id T1_file_path T2_file_path --forcerun
     ```
   - **macOS:**
     ```text
     charm subject_id T1_file_path T2_file_path
     ```
   - **NOTE:** subject_id = any name you want to assign, T2 file path is optional.
4. In 3D Slicer, plot out focal position. Following BabelBrain’s planning guide may help.
   - In the model, you must input the Cartesian coordinates `(x, y, z)`!
5. See below (or the `exampleMain` function packaged with the `kWaveTUSModel`) for writing a script to begin simulations.

---

## Example Simulation Script

See `exampleMain.m` for an example main file.

---

# Model Pipeline

## Before the model

- Have ready an MRI imaging folder (m2m)
- Segment through SimNIBS
- Plot out focal point in 3D Slicer

---

## STEP 0: Preprocess Masks

- Load segmented masks with helper function `m2m_to_mat()`
- For graphing, the masks are permuted and flipped in the x direction
- If the scale (calculated from dx) is not equal to 1, then the masks need to be rescaled with helper function `resizeMask()`
- Then, the skull undergoes a strong binary closing to smooth out the edges
- A `csf_mask` is created for the empty spaces inside the skull
- The skull is segmented into cortical and trabecular bones
  - **NOTE:** cortical/trabecular segmentation is artificial and does not follow SimNIBS segmentation, which aligns with BabelBrain

---

## STEP 1: Acoustic Simulation

### STEP 1.1: Create kgrid object

- The Nx, Ny, and Nz are taken from the dimensions of the masks
- A kWaveGrid object is created with them and dx, which is calculated before with frequency and PPW

### STEP 1.2: Define Medium Acoustic Properties

- Sound speed and density are defined for cortical and trabecular bone, brain, and skin
- **IMPORTANT:** the alpha power is set at 2. After literature review, 2 is the best power for simulations since if the power was a decimal, then there would be fractional derivatives which may mess up numerical dispersion of the simulation. Many papers/studies, including those by Dr. Bradley Treeby, use alpha power of 2. However, this requires more testing.
- Since Babelbrain uses alpha power of 1, the alpha coefficients are normalized to alpha power of 1
- The medium is smoothed to prevent numerical errors due to the large attenuation from the skull, it can be turned off in simulation settings.
- The model ensures that there are no NaN or negative values for medium properties
- Then, using the minimum sound speed, the model calculates the time needed for sound to travel diagonally across the grid, which is the duration of the simulation. A period of 5 is added so that k-wave can record these periods in steady state.
- Using k-wave’s `makeTime()`, dt is calculated with the user-dictated CFL number.

### STEP 1.3: Define Source

- The user has the option to choose either a `toneBurst()` or a CW input.
- The user inputs the focal position/target in an array: `[x y z]`
- The diameter, radius, focal position, and bowl position are calculated with scale and inputted into `kWaveArray`, which is the transducer object
- The bowl transducer is placed 64 mm behind the target
- Check if the source mask is overlapping with the tissue masks

A map of the tissue and transducer masks are outputted for the user.

### STEP 1.4: Define Sensor

- The sensor mask is set at every single grid point in the grid, and record `p_max` and `p_rms`
- The sensor is set to record only 5 periods of steady state
- Input arguments are made for the acoustic simulation, including PML size (which uses `getOptimalPMLSize()` to get the best size) and casting to `gpuArray-single` (which needs the Parallel Computing toolbox)

### STEP 1.5: Run Acoustic Simulation

- The simulation is either run on CPU or CUDA
- `p_max` and `p_rms` are created

Acoustic simulation results are graphed, including p_max and p_rms at focus, and the focal size as well

---

## STEP 2: Thermal Simulation

### STEP 2.1: Calculate Isppa and Q

- In case the medium is smoothed, the sound speed and density are restored for the thermal simulation
- Using p_rms, the Isppa is calculated. Then, it is scaled to the target Isppa in the brain, and p_rms is scaled to the same factor.
- Then, alpha coefficients in nepers are mapped
- Q is calculated using BabelBrain’s formula
- The Q of skin often receives lots of noise from reflections from the skull, and is smoothed for better heating results

### STEP 2.2: Define Medium Thermal Properties

- The specific heat, thermal conductivity, perfusion coefficient, blood ambient temp, blood density, blood specific heat, and blood perfusion rate are defined

### STEP 2.3: Define Sensor

- The model only sets sensors near the focal point

### STEP 2.4: Define Heating Loop, Run Simulation

- The duty cycle, duration of heating/cooling, and repetitions are defined
- The dt is set to 0.5 to save memory
- A time array is set for later graphing the heating curves
- `Q_on` is the Q during heating, which is Q * duty_cycle * absorption_fraction
- `Q_off` is Q during cooling, which is 0
- `kWaveDiffusion` is called
- The for loop represents the repetitions of pulses
- `kdiff.Q` is first set to `Q_on`, then heating is calculated for the `t_on` duration
- `kdiff.Q` is then set to `Q_off`, and heating is calculated again for `t_off` duration

Finally, plot the thermal simulation results (Q, Isppa, Temperature maps, and Temperature curves)

---

## Outputs

- Max Isppa in brain
- Isppa at target
- max Ispta in brain
- Ispta at target
- max temperature at target, brain, skin, and skull
- offset of focus from the target
- FWHM size
