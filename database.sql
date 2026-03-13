CREATE TABLE IF NOT EXISTS density_settings (
    identifier VARCHAR(64) PRIMARY KEY,
    vehicle FLOAT DEFAULT 1.0,
    parked FLOAT DEFAULT 1.0,
    ped FLOAT DEFAULT 1.0,
    scene FLOAT DEFAULT 1.0,
    police FLOAT DEFAULT 1.0
);