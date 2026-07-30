SET NOCOUNT ON;
SET XACT_ABORT ON;

IF (SELECT COUNT(*) FROM dbo.Package) <> 8
    THROW 51000, 'Expected eight packages.', 1;

IF (SELECT COUNT(*) FROM dbo.DomesticShipment) <> 4
    THROW 51001, 'Expected four domestic shipments.', 1;

IF (SELECT COUNT(*) FROM dbo.InternationalShipment) <> 4
    THROW 51002, 'Expected four international shipments.', 1;

IF (SELECT COUNT(*) FROM dbo.vw_DomesticShipmentSummary) <> 4
    THROW 51005, 'Expected four rows in the domestic shipment view.', 1;

IF EXISTS (
    SELECT package.PackageId
    FROM dbo.Package AS package
    LEFT JOIN dbo.DomesticShipment AS domestic
        ON domestic.PackageId = package.PackageId
    LEFT JOIN dbo.InternationalShipment AS international
        ON international.PackageId = package.PackageId
    WHERE
        (CASE WHEN domestic.PackageId IS NULL THEN 0 ELSE 1 END) +
        (CASE WHEN international.PackageId IS NULL THEN 0 ELSE 1 END) <> 1
)
    THROW 51003, 'Every package must have exactly one shipment classification.', 1;

BEGIN TRY
    INSERT dbo.Package
        (PackageId, DestinationAddress, RecipientName, WeightKg)
    VALUES
        (999, N'Test', N'Test', -1);
    THROW 51004, 'Negative package weight was accepted.', 1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 51004
        THROW;
END CATCH;

UPDATE dbo.Package
SET Status = 'InTransit'
WHERE PackageId IN (101, 102);

IF (
    SELECT COUNT(*)
    FROM dbo.PackageStatusHistory
    WHERE PreviousStatus = 'Created' AND NewStatus = 'InTransit'
) <> 2
    THROW 51006, 'The status trigger did not audit a multi-row update.', 1;

BEGIN TRY
    EXEC dbo.usp_DriverWorkload @MinimumPackages = -1;
    THROW 51007, 'The stored procedure accepted an invalid minimum.', 1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 51007
        THROW;
END CATCH;

PRINT 'All database assertions passed.';
