function plotCalibration(magX, magY, magZ, result, label)
% Plots scatter and time series for raw vs calibrated data

    calX = result.calX;
    calY = result.calY;
    calZ = result.calZ;
    t    = (1:length(magX))';

    % --- Scatter plot ---
    figure('Name', sprintf('%s — %s Scatter', label, result.method));
    subplot(3,2,1);
    plot(magX, magY, 'r.', 'MarkerSize', 2);
    axis equal; grid on;
    xlabel('X (uT)'); ylabel('Y (uT)');
    title('Raw XY');

    subplot(3,2,2);
    plot(calX, calY, 'b.', 'MarkerSize', 2);
    axis equal; grid on;
    xlabel('X (uT)'); ylabel('Y (uT)');
    title(sprintf('Calibrated XY — %s', result.method));

    subplot(3,2,3);
    plot(magX, magZ, 'r.', 'MarkerSize', 2);
    axis equal; grid on;
    xlabel('X (uT)'); ylabel('Z (uT)');
    title('Raw XZ');

    subplot(3,2,4);
    plot(calX, calZ, 'b.', 'MarkerSize', 2);
    axis equal; grid on;
    xlabel('X (uT)'); ylabel('Z (uT)');
    title(sprintf('Calibrated XZ — %s', result.method));

    subplot(3,2,5);
    plot(magY, magZ, 'r.', 'MarkerSize', 2);
    axis equal; grid on;
    xlabel('Y (uT)'); ylabel('Z (uT)');
    title('Raw YZ');

    subplot(3,2,6);
    plot(calY, calZ, 'b.', 'MarkerSize', 2);
    axis equal; grid on;
    xlabel('Y (uT)'); ylabel('Z (uT)');
    title(sprintf('Calibrated YZ — %s', result.method));

    sgtitle(sprintf('%s — %s', label, result.method));

    % --- Time series plot ---
    figure('Name', sprintf('%s — %s Time Series', label, result.method));
    subplot(3,2,1); plot(t, magX); ylabel('X (uT)'); title('Raw'); grid on;
    subplot(3,2,3); plot(t, magY); ylabel('Y (uT)'); grid on;
    subplot(3,2,5); plot(t, magZ); ylabel('Z (uT)'); xlabel('Sample'); grid on;

    subplot(3,2,2); plot(t, calX); ylabel('X (uT)'); title(sprintf('Calibrated — %s', result.method)); grid on;
    subplot(3,2,4); plot(t, calY); ylabel('Y (uT)'); grid on;
    subplot(3,2,6); plot(t, calZ); ylabel('Z (uT)'); xlabel('Sample'); grid on;

    sgtitle(sprintf('%s — %s Time Series', label, result.method));

    % --- Kalman convergence plot (only for Kalman) ---
    if strcmp(result.method, 'Kalman')
        figure('Name', sprintf('%s — Kalman Convergence', label));
        subplot(3,1,1);
        plot(result.biasHistory(:,1), 'r'); hold on;
        yline(result.b_init(1), 'r--', 'Init');
        ylabel('Bias X (uT)');
        title(sprintf('Kalman Bias Convergence — %s', label));
        ylim([result.b_init(1)-15, result.b_init(1)+15]);
        grid on;

        subplot(3,1,2);
        plot(result.biasHistory(:,2), 'g'); hold on;
        yline(result.b_init(2), 'g--', 'Init');
        ylabel('Bias Y (uT)');
        ylim([result.b_init(2)-15, result.b_init(2)+15]);
        grid on;

        subplot(3,1,3);
        plot(result.biasHistory(:,3), 'b'); hold on;
        yline(result.b_init(3), 'b--', 'Init');
        ylabel('Bias Z (uT)'); xlabel('Sample');
        ylim([result.b_init(3)-15, result.b_init(3)+15]);
        grid on;
    end
end