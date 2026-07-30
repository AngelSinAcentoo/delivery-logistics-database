SET NOCOUNT ON;

-- Domestic packages with route and assigned driver.
SELECT
    package.PackageId,
    package.RecipientName,
    route.OriginCity,
    route.DestinationCity,
    driver.DisplayName AS DriverName
FROM dbo.Package AS package
JOIN dbo.DomesticShipment AS shipment
    ON shipment.PackageId = package.PackageId
JOIN dbo.Route AS route
    ON route.RouteId = shipment.RouteId
JOIN dbo.RouteDriver AS routeDriver
    ON routeDriver.RouteId = route.RouteId
JOIN dbo.Driver AS driver
    ON driver.DriverId = routeDriver.DriverId
ORDER BY package.PackageId;

-- Workload by driver.
SELECT
    driver.DriverId,
    driver.DisplayName,
    COUNT(DISTINCT routeDriver.RouteId) AS RouteCount,
    COUNT(shipment.PackageId) AS PackageCount
FROM dbo.Driver AS driver
LEFT JOIN dbo.RouteDriver AS routeDriver
    ON routeDriver.DriverId = driver.DriverId
LEFT JOIN dbo.DomesticShipment AS shipment
    ON shipment.RouteId = routeDriver.RouteId
GROUP BY driver.DriverId, driver.DisplayName
ORDER BY driver.DriverId;

-- International deliveries that do not have an expected date.
SELECT
    shipment.PackageId,
    center.CenterName,
    shipment.Airline
FROM dbo.InternationalShipment AS shipment
JOIN dbo.LocalCenter AS center
    ON center.CenterId = shipment.CenterId
WHERE shipment.ExpectedDeliveryDate IS NULL;

-- Reusable view and stored-procedure examples.
SELECT *
FROM dbo.vw_DomesticShipmentSummary
ORDER BY PackageId;

EXEC dbo.usp_DriverWorkload @MinimumPackages = 1;
