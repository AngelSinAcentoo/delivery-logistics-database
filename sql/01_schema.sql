SET NOCOUNT ON;
SET XACT_ABORT ON;

CREATE TABLE dbo.Package (
    PackageId int NOT NULL,
    DestinationAddress nvarchar(120) NOT NULL,
    RecipientName nvarchar(100) NOT NULL,
    WeightKg decimal(8, 2) NULL,
    Status varchar(20) NOT NULL
        CONSTRAINT DF_Package_Status DEFAULT 'Created',
    CreatedAt datetime2(0) NOT NULL
        CONSTRAINT DF_Package_CreatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Package PRIMARY KEY (PackageId),
    CONSTRAINT CK_Package_Weight CHECK (WeightKg IS NULL OR WeightKg > 0),
    CONSTRAINT CK_Package_Status
        CHECK (Status IN ('Created', 'InTransit', 'Delivered', 'Cancelled'))
);

CREATE TABLE dbo.LocalCenter (
    CenterId int NOT NULL,
    CenterName nvarchar(100) NOT NULL,
    City nvarchar(80) NOT NULL,
    CONSTRAINT PK_LocalCenter PRIMARY KEY (CenterId),
    CONSTRAINT UQ_LocalCenter_Name UNIQUE (CenterName)
);

CREATE TABLE dbo.Truck (
    Plate varchar(10) NOT NULL,
    MaximumLoadKg decimal(10, 2) NOT NULL,
    HomeCity nvarchar(80) NOT NULL,
    CONSTRAINT PK_Truck PRIMARY KEY (Plate),
    CONSTRAINT CK_Truck_Load CHECK (MaximumLoadKg > 0)
);

CREATE TABLE dbo.Driver (
    DriverId int IDENTITY(1, 1) NOT NULL,
    DisplayName nvarchar(100) NOT NULL,
    HomeCity nvarchar(80) NULL,
    CONSTRAINT PK_Driver PRIMARY KEY (DriverId)
);

CREATE TABLE dbo.DriverTruckAssignment (
    DriverId int NOT NULL,
    TruckPlate varchar(10) NOT NULL,
    AssignmentDate date NOT NULL,
    CONSTRAINT PK_DriverTruckAssignment
        PRIMARY KEY (DriverId, TruckPlate, AssignmentDate),
    CONSTRAINT FK_DriverTruckAssignment_Driver
        FOREIGN KEY (DriverId) REFERENCES dbo.Driver(DriverId),
    CONSTRAINT FK_DriverTruckAssignment_Truck
        FOREIGN KEY (TruckPlate) REFERENCES dbo.Truck(Plate)
);

CREATE TABLE dbo.Route (
    RouteId int NOT NULL,
    OriginCity nvarchar(80) NOT NULL,
    DestinationCity nvarchar(80) NOT NULL,
    DepartureDate date NOT NULL,
    CONSTRAINT PK_Route PRIMARY KEY (RouteId),
    CONSTRAINT CK_Route_Cities CHECK (OriginCity <> DestinationCity)
);

CREATE TABLE dbo.RouteDriver (
    RouteId int NOT NULL,
    DriverId int NOT NULL,
    CONSTRAINT PK_RouteDriver PRIMARY KEY (RouteId, DriverId),
    CONSTRAINT FK_RouteDriver_Route
        FOREIGN KEY (RouteId) REFERENCES dbo.Route(RouteId) ON DELETE CASCADE,
    CONSTRAINT FK_RouteDriver_Driver
        FOREIGN KEY (DriverId) REFERENCES dbo.Driver(DriverId)
);

CREATE TABLE dbo.DomesticShipment (
    PackageId int NOT NULL,
    RouteId int NOT NULL,
    DestinationState nvarchar(80) NOT NULL,
    CONSTRAINT PK_DomesticShipment PRIMARY KEY (PackageId),
    CONSTRAINT FK_DomesticShipment_Package
        FOREIGN KEY (PackageId) REFERENCES dbo.Package(PackageId) ON DELETE CASCADE,
    CONSTRAINT FK_DomesticShipment_Route
        FOREIGN KEY (RouteId) REFERENCES dbo.Route(RouteId)
);

CREATE TABLE dbo.InternationalShipment (
    PackageId int NOT NULL,
    CenterId int NOT NULL,
    Airline nvarchar(80) NOT NULL,
    ExpectedDeliveryDate date NULL,
    CONSTRAINT PK_InternationalShipment PRIMARY KEY (PackageId),
    CONSTRAINT FK_InternationalShipment_Package
        FOREIGN KEY (PackageId) REFERENCES dbo.Package(PackageId) ON DELETE CASCADE,
    CONSTRAINT FK_InternationalShipment_Center
        FOREIGN KEY (CenterId) REFERENCES dbo.LocalCenter(CenterId)
);

CREATE INDEX IX_Route_DepartureDate
    ON dbo.Route(DepartureDate);

CREATE INDEX IX_InternationalShipment_CenterId
    ON dbo.InternationalShipment(CenterId);
