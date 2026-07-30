param(
    [string]$Server = ".\SQLEXPRESS"
)

$ErrorActionPreference = "Stop"
$database = "PortfolioLogisticsTest_" + [Guid]::NewGuid().ToString("N")

if ($database -notmatch '^PortfolioLogisticsTest_[a-f0-9]{32}$') {
    throw "Unexpected temporary database name."
}

function Invoke-Sql {
    param(
        [string]$Database,
        [string]$File
    )

    sqlcmd -S $Server -E -b -r 1 -d $Database -i $File
    if ($LASTEXITCODE -ne 0) {
        throw "sqlcmd failed for $File"
    }
}

try {
    sqlcmd -S $Server -E -b -r 1 -Q "CREATE DATABASE [$database];"
    if ($LASTEXITCODE -ne 0) {
        throw "Could not create the temporary database."
    }

    Invoke-Sql -Database $database -File (Join-Path $PSScriptRoot "sql\01_schema.sql")
    Invoke-Sql -Database $database -File (Join-Path $PSScriptRoot "sql\02_seed.sql")
    Invoke-Sql -Database $database -File (Join-Path $PSScriptRoot "sql\04_programmability.sql")
    Invoke-Sql -Database $database -File (Join-Path $PSScriptRoot "sql\03_queries.sql")
    Invoke-Sql -Database $database -File (Join-Path $PSScriptRoot "tests\assertions.sql")

    Write-Host "Database integration tests passed."
}
finally {
    sqlcmd -S $Server -E -b -r 1 -Q "
        IF DB_ID(N'$database') IS NOT NULL
        BEGIN
            ALTER DATABASE [$database] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
            DROP DATABASE [$database];
        END
    "
}
