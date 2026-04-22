function [magX, magY, magZ, fs] = loadSensorData(filepath, sensor)

    data = readtable(filepath);

    switch lower(sensor)
        case 'iphone'
            magX = data.x;
            magY = data.y;
            magZ = data.z;
            % iPhone has true elapsed seconds in seconds_elapsed column
            dt = mean(diff(data.seconds_elapsed));

        case 'vn100'
            magX = data.mag_x * 1e6;
            magY = data.mag_y * 1e6;
            magZ = data.mag_z * 1e6;
            % VN-100 has decimal Unix seconds in timestamp column
            dt = mean(diff(double(data.timestamp)));

        otherwise
            error('Unknown sensor type: %s. Use iphone or vn100.', sensor);
    end

    fs = 1/dt;

    fprintf('Loaded: %s | Sensor: %s | Samples: %d | Rate: %.1f Hz\n', ...
        filepath, sensor, length(magX), fs);
end