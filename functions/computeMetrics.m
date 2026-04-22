function metrics = computeMetrics(result, expectedField)

    if nargin < 2
        expectedField = 52.0;
    end

    magMag           = sqrt(result.calX.^2 + result.calY.^2 + result.calZ.^2);
    metrics.meanMag  = mean(magMag);
    metrics.stdMag   = std(magMag);
    metrics.errorMag = abs(metrics.meanMag - expectedField);
    metrics.errorPct = (metrics.errorMag / expectedField) * 100;
    metrics.magMag   = magMag;

    if isfield(result, 'hardIron')
        metrics.hardIronMag = norm(result.hardIron);
    else
        metrics.hardIronMag = NaN;
    end
end