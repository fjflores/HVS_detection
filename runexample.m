%RUNEXAMPLE  Detect 3-10 Hz events in the bundled synthetic EEG.
% Run this script from any working directory. The results remain in the
% workspace as spindle_table, mt_spect, and figure_handle for inspection.

% The Editor may execute a temporary copy of a script. Locate the real
% repository by checking the active Editor file, current folder, and the
% script location, rather than trusting the script path alone.
candidate_dirs = {pwd};
try
    active_file = matlab.desktop.editor.getActiveFilename;
    if isfile(active_file)
        candidate_dirs = [{fileparts(active_file)}, candidate_dirs];
    end
catch
    % MATLAB may be running without the desktop (for example, -batch).
end
script_path = which('runexample');
if ~isempty(script_path)
    candidate_dirs{end+1} = fileparts(script_path);
end
stack = dbstack('-completenames');
if ~isempty(stack) && ~isempty(stack(1).file)
    candidate_dirs{end+1} = fileparts(stack(1).file);
end

repo_dir = '';
for candidate_idx = 1:numel(candidate_dirs)
    candidate = candidate_dirs{candidate_idx};
    while ~isempty(candidate)
        if isfile(fullfile(candidate, 'example_data', 'synthetic_low_frequency_eeg.mat')) && ...
                isfolder(fullfile(candidate, 'helper_function', 'TFsigma_peak_detector'))
            repo_dir = candidate;
            break;
        end
        parent = fileparts(candidate);
        if strcmp(parent, candidate)
            break;
        end
        candidate = parent;
    end
    if ~isempty(repo_dir)
        break;
    end
end
if isempty(repo_dir)
    error(['Cannot locate the repository. Open its runexample.m in the Editor ' ...
        'or make the repository your current MATLAB folder.']);
end
addpath(fullfile(repo_dir, 'helper_function', 'TFsigma_peak_detector'));
addpath(fullfile(repo_dir, 'helper_function', 'multitaper'));
addpath(fullfile(repo_dir, 'helper_function', 'multitaper', 'multitaper_spectrogram_mex'));
addpath(fullfile(repo_dir, 'helper_function', 'utils'));

sample = load(fullfile(repo_dir, 'example_data', 'synthetic_low_frequency_eeg.mat'));
EEG = sample.EEG;
Fs = sample.Fs;
sleep_stages = sample.sleep_stages;

% Use a 2-second window for finer resolution at low frequencies. Search
% 3-10 Hz peaks within a spectrogram that extends beyond both band edges.
% The toolbox calls the output spindle_table, but these are 3-10 Hz events.
[spindle_table, mt_spect] = TF_peak_detection(EEG, Fs, sleep_stages, ...
    'artifact_detect', false, ...
    'MT_freq_max', 15, ...
    'MT_window', [2 0.05], ...
    'MT_taper', [2 3], ...
    'peak_freq_range', [3 10], ...
    'findpeaks_freq_range', [1 12], ...
    'spindle_freq_range', [3 10], ...
    'verbose', false);

fprintf('Implanted 6 Hz bursts: %d\n', numel(sample.event_centers));
fprintf('Detected 3-10 Hz events: %d\n', height(spindle_table));
disp(spindle_table(1:min(10, height(spindle_table)), :));

% Show the raw EEG and its multitaper spectrogram on a shared time axis.
% Detected events are highlighted in red on the EEG and marked by their
% central time and frequency on the spectrogram.
eeg_times = (0:numel(EEG)-1) / Fs;
figure_handle = figure('Name', 'Synthetic EEG 3-10 Hz event detection', 'Color', 'w');
tiledlayout(figure_handle, 2, 1, 'TileSpacing', 'compact');

eeg_ax = nexttile;
plot(eeg_ax, eeg_times, EEG, 'Color', [0.25 0.25 0.25]);
hold(eeg_ax, 'on');
for event_idx = 1:height(spindle_table)
    in_event = eeg_times >= spindle_table.Start_Time(event_idx) & ...
        eeg_times <= spindle_table.End_Time(event_idx);
    plot(eeg_ax, eeg_times(in_event), EEG(in_event), 'r', 'LineWidth', 1.2);
end
ylabel(eeg_ax, 'EEG amplitude');
title(eeg_ax, 'Synthetic EEG (detected events in red)');
grid(eeg_ax, 'on');

spect_ax = nexttile;
imagesc(spect_ax, mt_spect.stimes, mt_spect.sfreqs, ...
    nanpow2db(mt_spect.spect'));
axis(spect_ax, 'xy');
hold(spect_ax, 'on');
scatter(spect_ax, spindle_table.Max_Prominence_Time, ...
    spindle_table.Freq_Central, 45, 'r', 'filled', ...
    'MarkerEdgeColor', 'w', 'LineWidth', 0.8);
ylim(spect_ax, [1 13]);
xlabel(spect_ax, 'Time (s)');
ylabel(spect_ax, 'Frequency (Hz)');
title(spect_ax, 'Multitaper spectrogram (event center time and frequency)');
colorbar(spect_ax);
linkaxes([eeg_ax spect_ax], 'x');
xlim(eeg_ax, [eeg_times(1) eeg_times(end)]);
