%% Load Data %%
sensorData  = readtable('SLA7HSMagnetometerUncalibrated.csv');

%% Min-Max Calibration %%
tic;
magX = sensorData.x;
magY = sensorData.y;
magZ = sensorData.z;

xMin = min(magX); xMax = max(magX);
yMin = min(magY); yMax = max(magY);
zMin = min(magZ); zMax = max(magZ);

% Hard iron offsets
hardDist = [(xMin+xMax)/2, (yMin+yMax)/2, (zMin+zMax)/2];

% Soft iron scale factors
xRange   = (xMax - xMin) / 2;
yRange   = (yMax - yMin) / 2;
zRange   = (zMax - zMin) / 2;
avgRange = (xRange + yRange + zRange) / 3;
sX = avgRange / xRange;
sY = avgRange / yRange;
sZ = avgRange / zRange;

% Apply calibration to data
minMaxX = (magX - hardDist(1)) * sX;
minMaxY = (magY - hardDist(2)) * sY;
minMaxZ = (magZ - hardDist(3)) * sZ;

% Graph 1: Magnetometer XYZ before and after calibration
figure;
subplot(3,2,1);
plot(magX, magY, 'r.');
axis equal; grid on;
xlabel('X (uT)'); ylabel('Y (uT)');
title('Raw Magnetometer XY');

subplot(3,2,2);
plot(minMaxX, minMaxY, 'b.');
axis equal; grid on;
xlabel('X (uT)'); ylabel('Y (uT)');
title('Calibrated Magnetometer XY');

subplot(3,2,3);
plot(magX, magZ, 'r.');
axis equal; grid on;
xlabel('X (uT)'); ylabel('Z (uT)');
title('Raw Magnetometer XZ');

subplot(3,2,4);
plot(minMaxX, minMaxZ, 'b.');
axis equal; grid on;
xlabel('X (uT)'); ylabel('Z (uT)');
title('Calibrated Magnetometer XZ');

subplot(3,2,5);
plot(magY, magZ, 'r.');
axis equal; grid on;
xlabel('Y (uT)'); ylabel('Z (uT)');
title('Raw Magnetometer YZ');

subplot(3,2,6);
plot(minMaxY, minMaxZ, 'b.');
axis equal; grid on;
xlabel('Y (uT)'); ylabel('Z (uT)');
title('Calibrated Magnetometer YZ');

% Graph 2: Time series before and after calibration
t = (1:length(magX))';

figure;
subplot(3,2,1); plot(t, magX); ylabel('X (uT)'); title('Raw Magnetometer'); grid on;
subplot(3,2,3); plot(t, magY); ylabel('Y (uT)'); grid on;
subplot(3,2,5); plot(t, magZ); ylabel('Z (uT)'); xlabel('Sample'); grid on;

subplot(3,2,2); plot(t, minMaxX); ylabel('X (uT)'); title('Calibrated Magnetometer'); grid on;
subplot(3,2,4); plot(t, minMaxY); ylabel('Y (uT)'); grid on;
subplot(3,2,6); plot(t, minMaxZ); ylabel('Z (uT)'); xlabel('Sample'); grid on;

fprintf('\n--- Summary: MinMax Calibration ---\n');
fprintf('Hard iron offsets (uT): [%.2f, %.2f, %.2f]\n', hardDist);
fprintf('Soft iron scale — X: %.4f  Y: %.4f  Z: %.4f\n', sX, sY, sZ);

fprintf('\n--- Summary: MinMax Magnitude Error ---\n');
magMag = sqrt(minMaxX.^2 + minMaxY.^2 + minMaxZ.^2);
fprintf('Mean calibrated field magnitude: %.2f uT\n', mean(magMag));
fprintf('Std of field magnitude: %.2f uT\n', std(magMag));
expectedField = 52.0; % approximate Earth field magnitude in Boston (uT)
magnitudeError = abs(mean(magMag) - expectedField);
magnitudeErrorPct = (magnitudeError / expectedField) * 100;
fprintf('Expected field magnitude (Boston): %.2f uT\n', expectedField);
fprintf('Magnitude error: %.2f uT (%.1f%%)\n', magnitudeError, magnitudeErrorPct);

tMinmax = toc;

%% Magcal Calibration %%
tic;
magXYZ = [magX, magY, magZ];
[A,b,expMFS]  = magcal(magXYZ);
XYZMagcal = (magXYZ-b)*A;

% Extract individual calibrated axes
magcalX = XYZMagcal(:,1);
magcalY = XYZMagcal(:,2);
magcalZ = XYZMagcal(:,3);

% Graph 1: Magnetometer XYZ before and after calibration
figure;
subplot(3,2,1);
plot(magX, magY, 'r.');
axis equal; grid on;
xlabel('X (uT)'); ylabel('Y (uT)');
title('Raw Magnetometer XY');

subplot(3,2,2);
plot(magcalX, magcalY, 'b.');
axis equal; grid on;
xlabel('X (uT)'); ylabel('Y (uT)');
title('Calibrated Magnetometer XY');

subplot(3,2,3);
plot(magX, magZ, 'r.');
axis equal; grid on;
xlabel('X (uT)'); ylabel('Z (uT)');
title('Raw Magnetometer XZ');

subplot(3,2,4);
plot(magcalX, magcalZ, 'b.');
axis equal; grid on;
xlabel('X (uT)'); ylabel('Z (uT)');
title('Calibrated Magnetometer XZ');

subplot(3,2,5);
plot(magY, magZ, 'r.');
axis equal; grid on;
xlabel('Y (uT)'); ylabel('Z (uT)');
title('Raw Magnetometer YZ');

subplot(3,2,6);
plot(magcalY, magcalZ, 'b.');
axis equal; grid on;
xlabel('Y (uT)'); ylabel('Z (uT)');
title('Calibrated Magnetometer YZ');

% Graph 2: Time series before and after calibration
t = (1:length(magX))';

figure;
subplot(3,2,1); plot(t, magX); ylabel('X (uT)'); title('Raw Magnetometer'); grid on;
subplot(3,2,3); plot(t, magY); ylabel('Y (uT)'); grid on;
subplot(3,2,5); plot(t, magZ); ylabel('Z (uT)'); xlabel('Sample'); grid on;

subplot(3,2,2); plot(t, magcalX); ylabel('X (uT)'); title('Calibrated Magnetometer'); grid on;
subplot(3,2,4); plot(t, magcalY); ylabel('Y (uT)'); grid on;
subplot(3,2,6); plot(t, magcalZ); ylabel('Z (uT)'); xlabel('Sample'); grid on;

fprintf('\n--- Summary: Magcal Calibration ---\n');
fprintf('Hard iron offsets (uT): [%.2f, %.2f, %.2f]\n', b);
fprintf('Soft iron scale — [%.2f, %.2f, %.2f]\n', A);

fprintf('\n--- Summary: Magcal Magnitude Error ---\n');
magMag = sqrt(magcalX.^2 + magcalY.^2 + magcalZ.^2);
fprintf('Mean calibrated field magnitude: %.2f uT\n', mean(magMag));
fprintf('Std of field magnitude: %.2f uT\n', std(magMag));
expectedField = 52.0; % approximate Earth field magnitude in Boston (uT)
magnitudeError = abs(mean(magMag) - expectedField);
magnitudeErrorPct = (magnitudeError / expectedField) * 100;
fprintf('Expected field magnitude (Boston): %.2f uT\n', expectedField);
fprintf('Magnitude error: %.2f uT (%.1f%%)\n', magnitudeError, magnitudeErrorPct);

tMagcal = toc;

%% Kalman Filter Calibration — Scalar EKF With Numerical Fixes %%
tic;
N = size(magXYZ, 1);

% --- Sphere fit initialization ---
A_ls   = [2*magXYZ, ones(N,1)];
b_ls   = sum(magXYZ.^2, 2);
params = A_ls \ b_ls;
b_init = params(1:3);
r_init = sqrt(abs(params(4) + sum(b_init.^2)));

fprintf('\n--- Kalman Filter Initialization ---\n');
fprintf('Estimated bias (uT):   [%.2f, %.2f, %.2f]\n', b_init);
fprintf('Estimated radius (uT): %.2f\n', r_init);
expMFS_uT = r_init;

% --- R: use fixed literature value ---
% Quietest window approach unreliable for moving data
% Literature value for MEMS magnetometer: 1-2 uT std -> R = 1-4
R = 1.5;
fprintf('Using R: %.4f\n', R);

% --- Filter parameters ---
% Q very small — bias is static (powered off Apple Watch)
Q    = 1e-6 * eye(3);   % extremely small process noise
b_kf = b_init;
P_kf = 0.01 * eye(3);   % tight — good initialization

magKF       = zeros(N, 3);
biasHistory = zeros(N, 3);

for k = 1:N
    z_k = magXYZ(k,:)';

    % Predict
    b_pred = b_kf;
    P_pred = P_kf + Q;

    % Corrected measurement
    m_corrected = z_k - b_pred;
    mag_norm    = norm(m_corrected);

    % Skip if degenerate
    if mag_norm < 1.0 || mag_norm > 500.0
        magKF(k,:)       = m_corrected';
        biasHistory(k,:) = b_kf';
        continue;
    end

    % Jacobian H (1x3)
    H = -(m_corrected / mag_norm)';

    % Scalar innovation
    innovation = mag_norm - expMFS_uT;

    % Only update if innovation is meaningful
    % Skip if within noise floor — prevents unnecessary drift
    if abs(innovation) < 0.1
        magKF(k,:)       = m_corrected';
        biasHistory(k,:) = b_kf';
        continue;
    end

    % Clamp innovation
    innovation = max(min(innovation, 2.0), -2.0);

    % Innovation covariance (scalar)
    S = H * P_pred * H' + R;

    % Kalman gain (3x1)
    K = (P_pred * H') / S;

    % Update
    b_new = b_pred + K * innovation;

    % Reject update if bias moves too far from initialization
    % Prevents runaway drift
    maxBiasShift = 10.0;  % maximum allowed shift from init in uT
    if any(abs(b_new - b_init) > maxBiasShift)
        % Still update covariance but reject bias update
        P_kf = (eye(3) - K * H) * P_pred;
        P_kf = (P_kf + P_kf') / 2;
        magKF(k,:)       = m_corrected';
        biasHistory(k,:) = b_kf';
        continue;
    end

    b_kf = b_new;
    P_kf = (eye(3) - K * H) * P_pred;
    P_kf = (P_kf + P_kf') / 2;

    magKF(k,:)       = (z_k - b_kf)';
    biasHistory(k,:) = b_kf';
end

% --- Results ---
magKF_X   = magKF(:,1);
magKF_Y   = magKF(:,2);
magKF_Z   = magKF(:,3);

magMag_KF         = sqrt(magKF_X.^2 + magKF_Y.^2 + magKF_Z.^2);
expectedField     = 52.0;
magnitudeError_KF = abs(mean(magMag_KF) - expectedField);

fprintf('\n--- Summary: Kalman Filter Calibration ---\n');
fprintf('Final bias estimate (uT): [%.2f, %.2f, %.2f]\n', b_kf);
fprintf('Bias shift from init (uT): [%.2f, %.2f, %.2f]\n', ...
    b_kf(1)-b_init(1), b_kf(2)-b_init(2), b_kf(3)-b_init(3));
fprintf('Mean calibrated field magnitude: %.2f uT\n', mean(magMag_KF));
fprintf('Std of field magnitude: %.2f uT\n', std(magMag_KF));
fprintf('Expected field magnitude (Boston): %.2f uT\n', expectedField);
fprintf('Magnitude error: %.2f uT (%.1f%%)\n', ...
    magnitudeError_KF, (magnitudeError_KF/expectedField)*100);

% --- Convergence plot ---
figure;
subplot(3,1,1);
plot(biasHistory(:,1), 'r'); hold on;
yline(b_init(1), 'r--', 'Init'); grid on;
ylabel('Bias X (uT)');
title('Kalman Filter Bias Convergence');
ylim([b_init(1)-15, b_init(1)+15]);

subplot(3,1,2);
plot(biasHistory(:,2), 'g'); hold on;
yline(b_init(2), 'g--', 'Init'); grid on;
ylabel('Bias Y (uT)');
ylim([b_init(2)-15, b_init(2)+15]);

subplot(3,1,3);
plot(biasHistory(:,3), 'b'); hold on;
yline(b_init(3), 'b--', 'Init'); grid on;
ylabel('Bias Z (uT)'); xlabel('Sample');
ylim([b_init(3)-15, b_init(3)+15]);

tKalman = toc;

fprintf('\n--- Computational Cost Comparison ---\n');
fprintf('MinMax runtime:        %.4f seconds\n', tMinmax);
fprintf('Magcal runtime:        %.4f seconds\n', tMagcal);
fprintf('Kalman filter runtime: %.4f seconds\n', tKalman);