SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

CREATE VIEW dbo.vw_DomesticShipmentSummary
AS
SELECT
    package.PackageId,
    package.RecipientName,
    package.Status,
    shipment.DestinationState,
    route.RouteId,
    route.OriginCity,
    route.DestinationCity,
    route.DepartureDate,
    driver.DriverId,
    driver.DisplayName AS DriverName
FROM dbo.Package AS package
JOIN dbo.DomesticShipment AS shipment
    ON shipment.PackageId = package.PackageId
JOIN dbo.Route AS route
    ON route.RouteId = shipment.RouteId
JOIN dbo.RouteDriver AS routeDriver
    ON routeDriver.RouteId = route.RouteId
JOIN dbo.Driver AS driver
    ON driver.DriverId = routeDriver.DriverId;
GO

CREATE PROCEDURE dbo.usp_DriverWorkload
    @MinimumPackages int = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF @MinimumPackages < 0
        THROW 52000, 'Minimum package count cannot be negative.', 1;

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
    HAVING COUNT(shipment.PackageId) >= @MinimumPackages
    ORDER BY PackageCount DESC, driver.DriverId;
END;
GO

CREATE TABLE dbo.PackageStatusHistory (
    HistoryId bigint IDENTITY(1, 1) NOT NULL,
    PackageId int NOT NULL,
    PreviousStatus varchar(20) NOT NULL,
    NewStatus varchar(20) NOT NULL,
    ChangedAt datetime2(0) NOT NULL
        CONSTRAINT DF_PackageStatusHistory_ChangedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_PackageStatusHistory PRIMARY KEY (HistoryId),
    CONSTRAINT FK_PackageStatusHistory_Package
        FOREIGN KEY (PackageId) REFERENCES dbo.Package(PackageId)
);
GO

CREATE TRIGGER dbo.trg_Package_StatusHistory
ON dbo.Package
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT dbo.PackageStatusHistory
        (PackageId, PreviousStatus, NewStatus)
    SELECT
        inserted.PackageId,
        deleted.Status,
        inserted.Status
    FROM inserted
    JOIN deleted
        ON deleted.PackageId = inserted.PackageId
    WHERE inserted.Status <> deleted.Status;
END;
GO
