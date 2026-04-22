function result = runMagcal(magX, magY, magZ)

    magXYZ         = [magX, magY, magZ];
    [A, b, expMFS] = magcal(magXYZ);
    magXYZCal      = (magXYZ - b) * A;

    result.calX     = magXYZCal(:,1);
    result.calY     = magXYZCal(:,2);
    result.calZ     = magXYZCal(:,3);
    result.hardIron = b;
    result.softIron = A;
    result.expMFS   = expMFS;
    result.method   = 'Magcal';
end