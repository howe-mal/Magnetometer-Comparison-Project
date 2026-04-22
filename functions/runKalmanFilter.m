function result = runKalmanFilter(magX, magY, magZ)

    magXYZ = [magX, magY, magZ];
    N      = size(magXYZ, 1);

    % Sphere fit initialization
    A_ls   = [2*magXYZ, ones(N,1)];
    b_ls   = sum(magXYZ.^2, 2);
    params = A_ls \ b_ls;
    b_init = params(1:3);
    r_init = sqrt(abs(params(4) + sum(b_init.^2)));

    expMFS_uT    = r_init;
    Q            = 1e-6 * eye(3);
    R            = 1.5;
    b_kf         = b_init;
    P_kf         = 0.01 * eye(3);
    magKF        = zeros(N, 3);
    biasHistory  = zeros(N, 3);

    for k = 1:N
        z_k         = magXYZ(k,:)';
        b_pred      = b_kf;
        P_pred      = P_kf + Q;
        m_corrected = z_k - b_pred;
        mag_norm    = norm(m_corrected);

        if mag_norm < 1.0 || mag_norm > 500.0
            magKF(k,:)       = m_corrected';
            biasHistory(k,:) = b_kf';
            continue;
        end

        H          = -(m_corrected / mag_norm)';
        innovation = mag_norm - expMFS_uT;

        if abs(innovation) < 0.1
            magKF(k,:)       = m_corrected';
            biasHistory(k,:) = b_kf';
            continue;
        end

        innovation = max(min(innovation, 2.0), -2.0);
        S          = H * P_pred * H' + R;
        K          = (P_pred * H') / S;
        b_new      = b_pred + K * innovation;

        if any(abs(b_new - b_init) > 10.0)
            P_kf             = (eye(3) - K*H) * P_pred;
            P_kf             = (P_kf + P_kf') / 2;
            magKF(k,:)       = m_corrected';
            biasHistory(k,:) = b_kf';
            continue;
        end

        b_kf             = b_new;
        P_kf             = (eye(3) - K*H) * P_pred;
        P_kf             = (P_kf + P_kf') / 2;
        magKF(k,:)       = (z_k - b_kf)';
        biasHistory(k,:) = b_kf';
    end

    result.calX         = magKF(:,1);
    result.calY         = magKF(:,2);
    result.calZ         = magKF(:,3);
    result.hardIron     = b_kf';
    result.softIron     = eye(3);
    result.biasHistory  = biasHistory;
    result.b_init       = b_init;
    result.expMFS_uT    = expMFS_uT;
    result.method       = 'Kalman';
end