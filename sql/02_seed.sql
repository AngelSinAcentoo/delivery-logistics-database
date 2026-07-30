SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRANSACTION;

INSERT dbo.Package (PackageId, DestinationAddress, RecipientName, WeightKg)
VALUES
    (101, N'Avenida Central 100', N'Cliente Alfa', 3.50),
    (102, N'Calle Norte 220', N'Cliente Beta', 5.00),
    (103, N'Boulevard Sur 18', N'Cliente Gamma', NULL),
    (104, N'Calle Lago 77', N'Cliente Delta', 8.25),
    (201, N'Alexanderplatz 1', N'Cliente Europa', 10.00),
    (202, N'Avenida Libertad 55', N'Cliente América', 4.50),
    (203, N'Rua Central 90', N'Cliente Atlántico', 7.00),
    (204, N'Rue du Port 14', N'Cliente Mediterráneo', 11.00);

INSERT dbo.LocalCenter (CenterId, CenterName, City)
VALUES
    (10, N'Centro Europa', N'Berlín'),
    (20, N'Centro América', N'Caracas'),
    (30, N'Centro Atlántico', N'Lisboa'),
    (40, N'Centro Mediterráneo', N'Marsella');

INSERT dbo.Truck (Plate, MaximumLoadKg, HomeCity)
VALUES
    ('TRK-001', 700, N'Ciudad de México'),
    ('TRK-002', 800, N'Monterrey'),
    ('TRK-003', 1200, N'Guadalajara');

INSERT dbo.Driver (DisplayName, HomeCity)
VALUES
    (N'Conductor Uno', N'Ciudad de México'),
    (N'Conductor Dos', N'Monterrey'),
    (N'Conductor Tres', N'Guadalajara');

INSERT dbo.DriverTruckAssignment (DriverId, TruckPlate, AssignmentDate)
VALUES
    (1, 'TRK-001', '2026-03-20'),
    (2, 'TRK-002', '2026-03-20'),
    (3, 'TRK-003', '2026-03-21');

INSERT dbo.Route (RouteId, OriginCity, DestinationCity, DepartureDate)
VALUES
    (1, N'Ciudad de México', N'Guadalajara', '2026-03-21'),
    (2, N'Ciudad de México', N'Monterrey', '2026-03-22'),
    (3, N'Guadalajara', N'Puebla', '2026-03-23');

INSERT dbo.RouteDriver (RouteId, DriverId)
VALUES (1, 1), (2, 2), (3, 3);

INSERT dbo.DomesticShipment (PackageId, RouteId, DestinationState)
VALUES
    (101, 1, N'Jalisco'),
    (102, 2, N'Nuevo León'),
    (103, 3, N'Puebla'),
    (104, 1, N'Jalisco');

INSERT dbo.InternationalShipment
    (PackageId, CenterId, Airline, ExpectedDeliveryDate)
VALUES
    (201, 10, N'Aerolínea Uno', '2026-04-10'),
    (202, 20, N'Aerolínea Dos', NULL),
    (203, 30, N'Aerolínea Tres', '2026-04-12'),
    (204, 40, N'Aerolínea Cuatro', '2026-04-14');

COMMIT TRANSACTION;
