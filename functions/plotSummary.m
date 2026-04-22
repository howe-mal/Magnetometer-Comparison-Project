function plotSummary(allMetrics, allLabels, algorithms)
% Generates summary comparison figures across all datasets

    nDatasets   = length(allLabels);
    nAlgorithms = length(algorithms);

    % Build matrices
    stdMatrix     = zeros(nDatasets, nAlgorithms);
    errorMatrix   = zeros(nDatasets, nAlgorithms);
    runtimeMatrix = zeros(nDatasets, nAlgorithms);
    hiMatrix      = zeros(nDatasets, nAlgorithms);

    for i = 1:nDatasets
        for j = 1:nAlgorithms
            stdMatrix(i,j)     = allMetrics{i,j}.stdMag;
            errorMatrix(i,j)   = allMetrics{i,j}.errorPct;
            runtimeMatrix(i,j) = allMetrics{i,j}.runtime;
            hiMatrix(i,j)      = allMetrics{i,j}.hardIronMag;
        end
    end

    % Heatmap: Std
    figure('Name', 'Summary — Magnitude Std Heatmap');
    imagesc(stdMatrix);
    colormap(flipud(summer));
    colorbar;
    xticks(1:nAlgorithms); xticklabels(algorithms);
    yticks(1:nDatasets);   yticklabels(allLabels);
    title('Magnitude Std (uT) — All Conditions');
    for r = 1:nDatasets
        for c = 1:nAlgorithms
            text(c, r, sprintf('%.2f', stdMatrix(r,c)), ...
                'HorizontalAlignment','center','FontSize',8,'FontWeight','bold');
        end
    end

    % Heatmap: Error Percent
    figure('Name', 'Summary — Magnitude Error Heatmap');
    imagesc(errorMatrix);
    colormap(flipud(summer));
    colorbar;
    xticks(1:nAlgorithms); xticklabels(algorithms);
    yticks(1:nDatasets);   yticklabels(allLabels);
    title('Magnitude Error (%) — All Conditions');
    for r = 1:nDatasets
        for c = 1:nAlgorithms
            text(c, r, sprintf('%.1f%%', errorMatrix(r,c)), ...
                'HorizontalAlignment','center','FontSize',8,'FontWeight','bold');
        end
    end

    % Bar: Runtime
    figure('Name', 'Summary — Computational Cost');
    bar(runtimeMatrix);
    xticklabels(allLabels); xtickangle(30);
    ylabel('Runtime (s)');
    title('Computational Cost by Algorithm and Condition');
    legend(algorithms); grid on;

    % Bar: Hard iron magnitude
    figure('Name', 'Summary — Hard Iron Magnitude');
    bar(hiMatrix);
    xticklabels(allLabels); xtickangle(30);
    ylabel('Hard Iron Magnitude (uT)');
    title('Hard Iron Bias Estimate — All Conditions');
    legend(algorithms); grid on;

    % Grouped bar: Std comparison
    figure('Name', 'Summary — Std Comparison');
    bar(stdMatrix);
    xticklabels(allLabels); xtickangle(30);
    ylabel('Magnitude Std (uT)');
    title('Post-Calibration Consistency — All Conditions');
    legend(algorithms); grid on;
    yline(0, 'k--');
end