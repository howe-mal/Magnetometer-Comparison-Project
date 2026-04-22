function result = runLevenbergMarquardt(magX, magY, magZ)
% Levenberg-Marquardt nonlinear least squares magnetometer calibration
% Stage 1: LM sphere fit for hard iron (minimizes ||m - b|| - r)
% Stage 2: Ellipsoid fit on corrected data for soft iron

    data = [magX, magY, magZ];
    N    = size(data, 1);

    %% --- Stage 1: Linear least squares initialization (same as Kalman) ---
    A_ls   = [2*data, ones(N,1)];
    b_ls   = sum(data.^2, 2);
    params = A_ls \ b_ls;
    b_init = params(1:3);
    r_init = sqrt(abs(params(4) + dot(b_init, b_init)));

    %% --- Stage 2: Levenberg-Marquardt nonlinear refinement ---
    % Minimize: sum((||m_i - b|| - r)^2)
    % State vector: [bx, by, bz, r]
    x0 = [b_init; r_init];

    options = optimoptions('lsqnonlin', ...
        'Algorithm',       'levenberg-marquardt', ...
        'MaxFunctionEvaluations', 1000, ...
        'TolFun',           1e-8, ...
        'TolX',             1e-8, ...
        'Display',          'off');

    residualFn = @(p) sqrt(sum((data - p(1:3)').^2, 2)) - p(4);

    [x_opt, lm_cost, ~, ~, ~, ~, jacobian] = lsqnonlin( ...
        residualFn, x0, [], [], options);

    b_hi   = x_opt(1:3);
    r_fit  = x_opt(4);
    lm_nfev = numel(x0);   % approximation — lsqnonlin doesn't expose nfev directly

    %% --- Stage 3: Soft iron ellipsoid fit on hard-iron-corrected data ---
    data_c = data - b_hi';
    x = data_c(:,1);
    y = data_c(:,2);
    z = data_c(:,3);

    % General ellipsoid: ax^2 + by^2 + cz^2 + 2dxy + 2exz + 2fyz = 1
    A2     = [x.^2, y.^2, z.^2, 2*x.*y, 2*x.*z, 2*y.*z];
    coeffs = A2 \ ones(N,1);

    a = coeffs(1); b = coeffs(2); c = coeffs(3);
    d = coeffs(4); e = coeffs(5); f = coeffs(6);

    % Assemble symmetric matrix W
    W = [a, d, e;
         d, b, f;
         e, f, c];

    % Eigendecomposition
    [eigvecs, eigvals_diag] = eig(W);
    eigvals = max(diag(eigvals_diag), 1e-10);   % clamp negative eigenvalues

    % Scale to preserve field magnitude
    scale  = exp(mean(log(1.0 ./ sqrt(eigvals))));
    W_sqrt = eigvecs * diag(sqrt(eigvals)) * eigvecs';
    A_soft = scale * W_sqrt;

    % Apply soft iron correction
    data_cal = data_c * A_soft;

    result.calX     = data_cal(:,1);
    result.calY     = data_cal(:,2);
    result.calZ     = data_cal(:,3);
    result.hardIron = b_hi';
    result.softIron = A_soft;
    result.r_fit    = r_fit;
    result.lm_cost  = lm_cost;
    result.method   = 'LM';
end