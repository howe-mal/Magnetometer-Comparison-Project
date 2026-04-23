% Runs MinMax, Magcal, and Kalman calibration on all datasets
% Add new datasets by adding rows to the 'datasets' cell array
addpath('functions');

% Configuration
expectedField = 52.0;   % Boston Earth field magnitude (uT)
algorithms    = {'MinMax', 'Magcal', 'Kalman', 'LM'};

%% Dataset Definitions %%
% Format: {filepath, sensor_type, label}
% sensor_type: 'iphone' or 'vn100'
datasets = {
    'data/SLACleanMagnetometerUncalibrated.csv',    'iphone', 'iPhone Clean';
    'data/SLA7HSMagnetometerUncalibrated.csv',   'iphone', 'iPhone 7cm Hard/Soft';
    'data/SLA7HardMagnetometerUncalibrated.csv',  'iphone', 'iPhone 7cm Hard';
    'data/SLA7SoftMagnetometerUncalibrated.csv',  'iphone', 'iPhone 7cm Soft';
    'data/SLA30HSMagnetometerUncalibrated.csv','iphone', 'iPhone 30cm Hard/Soft';
    'data/SLA30HardMagnetometerUncalibrated.csv', 'iphone', 'iPhone 30cm Hard';
    'data/SLA30SoftMagnetometerUncalibrated.csv', 'iphone', 'iPhone 30cm Soft';
    'data/clearIMU.csv',     'vn100',  'VN-100 Clean';
    'data/vn7HS.csv',    'vn100',  'VN-100 7cm Hard/Soft';
    'data/vn7Hard.csv',   'vn100',  'VN-100 7cm Hard';
    'data/vn7Soft.csv',   'vn100',  'VN-100 7cm Soft';
    'data/vn30HS.csv', 'vn100',  'VN-100 30cm Hard/Soft';
    'data/vn30Hard.csv',  'vn100',  'VN-100 30cm Hard';
    'data/vn30Soft.csv',  'vn100',  'VN-100 30cm Soft';
};

nDatasets   = size(datasets, 1);
nAlgorithms = length(algorithms);

% Preallocate results
allMetrics = cell(nDatasets, nAlgorithms);

%% Runs All Algorithms On All Datasets %%
for i = 1:nDatasets

    filepath   = datasets{i,1};
    sensorType = datasets{i,2};
    label      = datasets{i,3};

    fprintf('\n========================================\n');
    fprintf('Dataset %d/%d: %s\n', i, nDatasets, label);
    fprintf('========================================\n');

    % Load data
    [magX, magY, magZ, fs] = loadSensorData(filepath, sensorType);

    % MinMax
    tMinMax     = timeit(@() runMinMax(magX, magY, magZ));
    mmResult    = runMinMax(magX, magY, magZ);
    mmMetrics   = computeMetrics(mmResult, expectedField);
    mmMetrics.runtime = tMinMax;
    allMetrics{i,1}   = mmMetrics;
    printResults(mmResult, mmMetrics, tMinMax);

    % Magcal
    tMagcal     = timeit(@() runMagcal(magX, magY, magZ));
    mcResult    = runMagcal(magX, magY, magZ);
    mcMetrics   = computeMetrics(mcResult, expectedField);
    mcMetrics.runtime = tMagcal;
    allMetrics{i,2}   = mcMetrics;
    printResults(mcResult, mcMetrics, tMagcal);

    % Kalman Filter
    fprintf('\n--- Kalman Filter Initialization ---\n');
    tKalman     = timeit(@() runKalmanFilter(magX, magY, magZ));
    kfResult    = runKalmanFilter(magX, magY, magZ);
    kfMetrics   = computeMetrics(kfResult, expectedField);
    kfMetrics.runtime = tKalman;
    allMetrics{i,3}   = kfMetrics;
    printResults(kfResult, kfMetrics, tKalman);

    % Levenberg-Marquardt
    tLM         = timeit(@() runLevenbergMarquardt(magX, magY, magZ));
    lmResult    = runLevenbergMarquardt(magX, magY, magZ);
    lmMetrics   = computeMetrics(lmResult, expectedField);
    lmMetrics.runtime = tLM;
    allMetrics{i,4}   = lmMetrics;
    printResults(lmResult, lmMetrics, tLM);

    % --- Per-dataset cost summary ---
    fprintf('\n--- Computational Cost: %s ---\n', label);
    fprintf('MinMax: %.4f s | Magcal: %.4f s | Kalman: %.4f s | LM: %.4f s\n', ...
        tMinMax, tMagcal, tKalman, tLM);
end

%% Summary Figures %%
allLabels = datasets(:,3);
plotSummary(allMetrics, allLabels, algorithms);

fprintf('\n========================================\n');
fprintf('Analysis complete.\n');
fprintf('Datasets: %d | Algorithms: %d | Total results: %d\n', ...
    nDatasets, nAlgorithms, nDatasets*nAlgorithms);
fprintf('========================================\n');

%% Final Summary — Best Algorithm by Sensor and Metric
fprintf('\n========================================\n');
fprintf('Final Summary: Best Algorithm by Sensor\n');
fprintf('========================================\n');

% Sensor groupings — dataset indices
iphone_idx = 1:7;
vn100_idx  = 8:14;

sensors     = {'iPhone 11', 'VN-100'};
sensorIdxs  = {iphone_idx, vn100_idx};

for s = 1:2
    idx = sensorIdxs{s};
    fprintf('\n--- %s ---\n', sensors{s});

    % Preallocate
    std_mean     = zeros(1, nAlgorithms);
    err_mean     = zeros(1, nAlgorithms);
    runtime_mean = zeros(1, nAlgorithms);

    for j = 1:nAlgorithms
        stds     = arrayfun(@(i) allMetrics{i,j}.stdMag,   idx);
        errs     = arrayfun(@(i) allMetrics{i,j}.errorPct, idx);
        runtimes = arrayfun(@(i) allMetrics{i,j}.runtime,  idx);

        std_mean(j)     = mean(stds);
        err_mean(j)     = mean(errs);
        runtime_mean(j) = mean(runtimes);
    end

    % Print means
    fprintf('%-22s  MinMax     Magcal     Kalman     LM\n', 'Metric');
    fprintf('%-22s  %-10.2f %-10.2f %-10.2f %-10.2f\n', ...
        'Consistency Std (uT)', std_mean(1), std_mean(2), std_mean(3), std_mean(4));
    fprintf('%-22s  %-10.1f %-10.1f %-10.1f %-10.1f\n', ...
        'Magnitude Error (%)', err_mean(1), err_mean(2), err_mean(3), err_mean(4));
    fprintf('%-22s  %-10.4f %-10.4f %-10.4f %-10.4f\n', ...
        'Runtime (s)', runtime_mean(1), runtime_mean(2), runtime_mean(3), runtime_mean(4));

    % Print winners
    [~, w1] = min(std_mean);
    [~, w2] = min(err_mean);
    [~, w3] = min(runtime_mean);
    algNames = {'MinMax', 'Magcal', 'Kalman', 'LM'};
    fprintf('Best Consistency:       %s\n', algNames{w1});
    fprintf('Best Magnitude Accuracy:%s\n', algNames{w2});
    fprintf('Fastest Runtime:        %s\n', algNames{w3});
end
fprintf('\n========================================\n');

%% Average Runtime Summary Plot %%
runtimes_all = zeros(nDatasets, nAlgorithms);
for i = 1:nDatasets
    for j = 1:nAlgorithms
        runtimes_all(i,j) = allMetrics{i,j}.runtime;
    end
end
avg_runtimes = mean(runtimes_all, 1);
std_runtimes = std(runtimes_all, 0, 1);

figure;
b = bar(avg_runtimes);
hold on;
errorbar(1:nAlgorithms, avg_runtimes, std_runtimes, 'k', 'LineStyle', 'none');
set(gca, 'XTickLabel', algorithms);
xlabel('Algorithm');
ylabel('Average Runtime (s)');
title('Average Computational Cost by Algorithm');
grid on;

%% Degradation Analysis: iPhone Only — 30cm vs 7cm %%
conditions = {'Hard/Soft', 'Hard Only', 'Soft Only'};
iphone_7cm   = [2, 3, 4];
iphone_30cm  = [5, 6, 7];
iphone_clean = 1;

algNames = {'MinMax', 'Magcal', 'Kalman', 'LM'};
nAlg = length(algNames);

% Compute baseline
baseline_err = zeros(1, nAlg);
baseline_std = zeros(1, nAlg);
for j = 1:nAlg
    baseline_err(j) = allMetrics{iphone_clean, j}.errorPct;
    baseline_std(j) = allMetrics{iphone_clean, j}.stdMag;
end

% Compute degradation
degradation_err = zeros(3, nAlg);
degradation_std = zeros(3, nAlg);
for c = 1:3
    for j = 1:nAlg
        err_7cm  = allMetrics{iphone_7cm(c),  j}.errorPct;
        err_30cm = allMetrics{iphone_30cm(c), j}.errorPct;
        std_7cm  = allMetrics{iphone_7cm(c),  j}.stdMag;
        std_30cm = allMetrics{iphone_30cm(c), j}.stdMag;
        degradation_err(c,j) = err_7cm - err_30cm;
        degradation_std(c,j) = std_7cm - std_30cm;
    end
end


% Print table
fprintf('\n--- iPhone 11 Degradation Table ---\n');
fprintf('%-18s  %-10s %-10s %-10s %-10s\n', 'Condition', algNames{:});
fprintf('%-18s  %-10.2f %-10.2f %-10.2f %-10.2f\n', 'Baseline (Clean)', baseline_err);
for c = 1:3
    abs_30cm = arrayfun(@(j) allMetrics{iphone_30cm(c),j}.errorPct, 1:nAlg);
    abs_7cm  = arrayfun(@(j) allMetrics{iphone_7cm(c),j}.errorPct,  1:nAlg);
    fprintf('%-18s  %-10.2f %-10.2f %-10.2f %-10.2f\n', ...
        sprintf('30cm %s', conditions{c}), abs_30cm);
    fprintf('%-18s  %-10.2f %-10.2f %-10.2f %-10.2f\n', ...
        sprintf('7cm %s',  conditions{c}), abs_7cm);
    fprintf('%-18s  %-10.2f %-10.2f %-10.2f %-10.2f\n', ...
        sprintf('Deg. %s', conditions{c}), degradation_err(c,:));
    fprintf('\n');
end

%% Degradation Analysis: VN-100 Only — 30cm vs 7cm %%
conditions = {'Hard/Soft', 'Hard Only', 'Soft Only'};
vn100_7cm   = [9, 10, 11];
vn100_30cm  = [12, 13, 14];
vn100_clean = 8;

algNames = {'MinMax', 'Magcal', 'Kalman', 'LM'};
nAlg = length(algNames);

% Compute baseline
baseline_err = zeros(1, nAlg);
baseline_std = zeros(1, nAlg);
for j = 1:nAlg
    baseline_err(j) = allMetrics{vn100_clean, j}.errorPct;
    baseline_std(j) = allMetrics{vn100_clean, j}.stdMag;
end

% Compute degradation
degradation_err = zeros(3, nAlg);
degradation_std = zeros(3, nAlg);
for c = 1:3
    for j = 1:nAlg
        err_7cm  = allMetrics{vn100_7cm(c),  j}.errorPct;
        err_30cm = allMetrics{vn100_30cm(c), j}.errorPct;
        std_7cm  = allMetrics{vn100_7cm(c),  j}.stdMag;
        std_30cm = allMetrics{vn100_30cm(c), j}.stdMag;
        degradation_err(c,j) = err_7cm - err_30cm;
        degradation_std(c,j) = std_7cm - std_30cm;
    end
end

% Print table
fprintf('\n--- VN-100 Degradation Table ---\n');
fprintf('%-18s  %-10s %-10s %-10s %-10s\n', 'Condition', algNames{:});
fprintf('%-18s  %-10.2f %-10.2f %-10.2f %-10.2f\n', 'Baseline (Clean)', baseline_err);
for c = 1:3
    abs_30cm = arrayfun(@(j) allMetrics{vn100_30cm(c),j}.errorPct, 1:nAlg);
    abs_7cm  = arrayfun(@(j) allMetrics{vn100_7cm(c),j}.errorPct,  1:nAlg);
    fprintf('%-18s  %-10.2f %-10.2f %-10.2f %-10.2f\n', ...
        sprintf('30cm %s', conditions{c}), abs_30cm);
    fprintf('%-18s  %-10.2f %-10.2f %-10.2f %-10.2f\n', ...
        sprintf('7cm %s',  conditions{c}), abs_7cm);
    fprintf('%-18s  %-10.2f %-10.2f %-10.2f %-10.2f\n', ...
        sprintf('Deg. %s', conditions{c}), degradation_err(c,:));
    fprintf('\n');
end

%% Location Comparison: VN-100 Location A vs Location B %%

% Location B: VN-100 Clean (8) and VN-100 7cm Soft (11)
% Location A: All other VN-100 datasets (9, 10, 12, 13, 14)
locB_idx = [8, 11];
locA_idx = [9, 10, 12, 13, 14];

algNames = {'MinMax', 'Magcal', 'Kalman', 'LM'};
nAlg = length(algNames);

% Compute mean error and std for each location
locA_err = zeros(1, nAlg);
locB_err = zeros(1, nAlg);
locA_std = zeros(1, nAlg);
locB_std = zeros(1, nAlg);

for j = 1:nAlg
    locA_err(j) = mean(arrayfun(@(i) allMetrics{i,j}.errorPct, locA_idx));
    locB_err(j) = mean(arrayfun(@(i) allMetrics{i,j}.errorPct, locB_idx));
    locA_std(j) = mean(arrayfun(@(i) allMetrics{i,j}.stdMag,   locA_idx));
    locB_std(j) = mean(arrayfun(@(i) allMetrics{i,j}.stdMag,   locB_idx));
end

figure('Position', [100, 100, 900, 400]);

% Magnitude Error comparison
subplot(1, 2, 1);
bar([locA_err; locB_err]');
set(gca, 'XTickLabel', algNames);
ylabel('Mean Magnitude Error (%)');
title('VN-100 Magnitude Error: Location A vs Location B');
legend({'Location A', 'Location B'}, 'Location', 'best');
grid on;

% Std comparison
subplot(1, 2, 2);
bar([locA_std; locB_std]');
set(gca, 'XTickLabel', algNames);
ylabel('Mean Std (\muT)');
title('VN-100 Consistency: Location A vs Location B');
legend({'Location A', 'Location B'}, 'Location', 'best');
grid on;

% Print table
fprintf('\n--- VN-100 Location Comparison ---\n');
fprintf('%-12s  %-10s %-10s %-10s %-10s\n', 'Metric', algNames{:});
fprintf('%-12s  %-10.2f %-10.2f %-10.2f %-10.2f\n', 'Loc A Error', locA_err);
fprintf('%-12s  %-10.2f %-10.2f %-10.2f %-10.2f\n', 'Loc B Error', locB_err);
fprintf('%-12s  %-10.2f %-10.2f %-10.2f %-10.2f\n', 'Loc A Std',   locA_std);
fprintf('%-12s  %-10.2f %-10.2f %-10.2f %-10.2f\n', 'Loc B Std',   locB_std);

%% 3D Sphere Plots: Datasets 3, 4, 5 %%
datasetIdxs = [3, 4, 2];
nDatasets   = length(datasetIdxs);

figure('Position', [100, 100, 1400, 900]);

plotCol = 1;
for d = 1:nDatasets
    idx = datasetIdxs(d);
    [magX, magY, magZ, ~] = loadSensorData(datasets{idx,1}, datasets{idx,2});
    label = datasets{idx, 3};

    % Run all algorithms
    results = {
        runMinMax(magX, magY, magZ),
        runMagcal(magX, magY, magZ),
        runKalmanFilter(magX, magY, magZ),
        runLevenbergMarquardt(magX, magY, magZ)
    };

    % Raw data
    subplot(nDatasets, 5, plotCol);
    c = sqrt(results{j}.calX.^2 + results{j}.calY.^2 + results{j}.calZ.^2);
    scatter3(results{j}.calX, results{j}.calY, results{j}.calZ, 5, c, 'filled');
    colormap cool;
    xlabel('X'); ylabel('Y'); zlabel('Z');
    title(sprintf('Raw\n%s', label));
    axis equal; grid on;

    % Calibrated — one subplot per algorithm
    for j = 1:4
        subplot(nDatasets, 5, plotCol + j);
        c = sqrt(results{j}.calX.^2 + results{j}.calY.^2 + results{j}.calZ.^2);
        scatter3(results{j}.calX, results{j}.calY, results{j}.calZ, 5, c, 'filled');
        colormap cool;
        xlabel('X'); ylabel('Y'); zlabel('Z');
        title(sprintf('%s\n%s', algNames{j}, label));
        axis equal; grid on;
    end

    plotCol = plotCol + 5;
end

sgtitle('Raw vs Calibrated: Datasets 3, 4, 5');