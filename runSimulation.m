% script for sensitivity analysis
% clearvars;

percentages = [0.20, 0.15, 0.10, 0.05, 0, -0.05, -0.10, -0.15, -0.20];
percentages_t = array2table(string(percentages(:) * 100) + "%", 'VariableNames', {'Percentage'});

simulation_settings = getSimulationSettings();
general_settings = getGeneralSettings();


simulation_settings.ppw = 6;
simulation_settings.dx = 0.5e-3;
simulation_settings.medium_smooth = true;

output1 = table('Size', [0 9], 'VariableTypes', [repmat("double", 1, 9)], ...
    'VariableNames', {'source_strength', 'p_max', 'Isppa_focus', ...
    'Isppa_brain_peak', 'Q_avg', 'T_target', 'T_brain', 'T_skin', 'T_skull'});

% first parameter: SOURCE STRENGTH
target_Isppa = simulation_settings.target_Isppa;

for i = 1:numel(percentages)
    simulation_settings.target_Isppa = target_Isppa * (1 + percentages(i));
    Isppa_results = kWaveTUSModel(general_settings, simulation_settings);
    fields = fieldnames(Isppa_results);
    values = cellfun(@(f) double(Isppa_results.(f)), fields);
    T = array2table(values', 'VariableNames', output1.Properties.VariableNames);
    output1(end+1,:) = T;
end

output1 = [percentages_t, output1];

%%
% second parameter: FREQUENCY
output2 = table('Size', [0 9], 'VariableTypes', [repmat("double", 1, 9)], ...
    'VariableNames', {'frequency', 'p_max', 'Isppa_focus', ...
    'Isppa_brain_peak', 'Q_avg', 'T_target', 'T_brain', 'T_skin', 'T_skull'});

simulation_settings.target_Isppa = target_Isppa;
simulation_settings.return_values = {"frequency"};
frequency_0 = simulation_settings.f0;

for i = 1:numel(percentages)
    simulation_settings.f0 = frequency_0 * (1 + percentages(i));
    simulation_settings.dx = 0.5e-3;
    frequency_results = kWaveTUSModel(general_settings, simulation_settings);
    fields = fieldnames(frequency_results);
    values = cellfun(@(f) double(frequency_results.(f)), fields, 'UniformOutput', false);
    T = array2table(values', 'VariableNames', output2.Properties.VariableNames);
    output2(end+1,:) = T;
end

output2 = [percentages_t, output2];

writetable(output1, 'sensitivity_analysis.xlsx', 'Sheet', 'Source Strength');
writetable(output2, 'sensitivity_analysis.xlsx', 'Sheet', 'Frequency');