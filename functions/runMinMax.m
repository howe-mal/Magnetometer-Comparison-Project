function result = runMinMax(magX, magY, magZ)

    xMin = min(magX); xMax = max(magX);
    yMin = min(magY); yMax = max(magY);
    zMin = min(magZ); zMax = max(magZ);

    hardIron = [(xMin+xMax)/2, (yMin+yMax)/2, (zMin+zMax)/2];

    xRange   = (xMax-xMin)/2;
    yRange   = (yMax-yMin)/2;
    zRange   = (zMax-zMin)/2;
    avgRange = (xRange+yRange+zRange)/3;

    sX = avgRange/xRange;
    sY = avgRange/yRange;
    sZ = avgRange/zRange;

    result.calX      = (magX - hardIron(1)) * sX;
    result.calY      = (magY - hardIron(2)) * sY;
    result.calZ      = (magZ - hardIron(3)) * sZ;
    result.hardIron  = hardIron;
    result.softIron  = diag([sX, sY, sZ]);
    result.sX        = sX;
    result.sY        = sY;
    result.sZ        = sZ;
    result.method    = 'MinMax';
end