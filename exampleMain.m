
% Before running simulations: get m2m folder and get trajectory/focal pos 
% from 3D Slicer

% first, get general and simulation settings
general_settings = getGeneralSettings();
simulation_settings = getSimulationSettings();

% second, customize settings
% (these three are the most important)
simulation_settings.ppw = 3;
simulation_settings.mask_path = 'C:\Users\Lunar\m2m_subject01';
simulation_settings.focal_pos = [81, 66, 128];

% third, call the model and get outputs
out = kWaveTUSModel(general_settings, simulation_settings);