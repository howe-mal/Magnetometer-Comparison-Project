function printResults(result, metrics, tRuntime)

    fprintf('\n--- Summary: %s Calibration ---\n', result.method);

    switch result.method
        case 'MinMax'
            fprintf('Hard iron offsets (uT): [%.2f, %.2f, %.2f]\n', result.hardIron);
            fprintf('Soft iron scale — X: %.4f  Y: %.4f  Z: %.4f\n', ...
                result.sX, result.sY, result.sZ);

        case 'Magcal'
            fprintf('Hard iron offsets (uT): [%.2f, %.2f, %.2f]\n', result.hardIron);
            fprintf('Soft iron matrix:\n');
            fprintf('  [%.2f, %.2f, %.2f]\n', result.softIron(1,:));
            fprintf('  [%.2f, %.2f, %.2f]\n', result.softIron(2,:));
            fprintf('  [%.2f, %.2f, %.2f]\n', result.softIron(3,:));

        case 'Kalman'
            fprintf('Kalman init bias (uT):   [%.2f, %.2f, %.2f]\n', result.b_init);
            fprintf('Final bias estimate (uT): [%.2f, %.2f, %.2f]\n', result.hardIron);
            fprintf('Bias shift from init (uT): [%.2f, %.2f, %.2f]\n', ...
                result.hardIron(1)-result.b_init(1), ...
                result.hardIron(2)-result.b_init(2), ...
                result.hardIron(3)-result.b_init(3));
            
        case 'LM'
            fprintf('Hard iron offsets (uT): [%.2f, %.2f, %.2f]\n', result.hardIron);
            fprintf('Soft iron matrix:\n');
            fprintf('  [%.2f, %.2f, %.2f]\n', result.softIron(1,:));
            fprintf('  [%.2f, %.2f, %.2f]\n', result.softIron(2,:));
            fprintf('  [%.2f, %.2f, %.2f]\n', result.softIron(3,:));
            fprintf('LM fitted radius (uT): %.2f\n', result.r_fit);
            fprintf('LM cost: %.6f\n', result.lm_cost);
    end

    fprintf('Mean calibrated field magnitude: %.2f uT\n', metrics.meanMag);
    fprintf('Std of field magnitude: %.2f uT\n', metrics.stdMag);
    fprintf('Expected field magnitude (Boston): 52.00 uT\n');
    fprintf('Magnitude error: %.2f uT (%.1f%%)\n', metrics.errorMag, metrics.errorPct);
    fprintf('Runtime: %.4f seconds\n', tRuntime);
end