SET NOCOUNT ON;

DROP TRIGGER IF EXISTS dbo.trg_Package_StatusHistory;
DROP PROCEDURE IF EXISTS dbo.usp_DriverWorkload;
DROP VIEW IF EXISTS dbo.vw_DomesticShipmentSummary;
DROP TABLE IF EXISTS dbo.PackageStatusHistory;
DROP TABLE IF EXISTS dbo.InternationalShipment;
DROP TABLE IF EXISTS dbo.DomesticShipment;
DROP TABLE IF EXISTS dbo.RouteDriver;
DROP TABLE IF EXISTS dbo.Route;
DROP TABLE IF EXISTS dbo.DriverTruckAssignment;
DROP TABLE IF EXISTS dbo.Driver;
DROP TABLE IF EXISTS dbo.Truck;
DROP TABLE IF EXISTS dbo.LocalCenter;
DROP TABLE IF EXISTS dbo.Package;
