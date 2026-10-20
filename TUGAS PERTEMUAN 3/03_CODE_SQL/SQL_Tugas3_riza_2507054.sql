CREATE DATABASE IF NOT EXISTS praktikum_transaksi;

USE praktikum_transaksi;
CREATE TABLE IF NOT EXISTS rekening (
    id INT PRIMARY KEY,
    nama VARCHAR(50) NOT NULL,
    saldo DECIMAL(12,2) NOT NULL,
    CONSTRAINT chk_saldo_nonnegatif CHECK (saldo >= 0)
) ENGINE=InnoDB;

INSERT INTO rekening (id, nama, saldo)
VALUES
    (1, 'Budi', 500000.00),
    (2, 'Siti', 250000.00);

SELECT id, nama, saldo
FROM rekening
ORDER BY id;

START TRANSACTION;
UPDATE rekening
SET saldo = saldo - 75000
WHERE id = 1;

UPDATE rekening
SET saldo = saldo + 75000
WHERE id = 2;

SELECT id, nama, saldo
FROM rekening
ORDER BY id;

COMMIT;

SELECT id, nama, saldo
FROM rekening
ORDER BY id;

START TRANSACTION;
UPDATE rekening
SET saldo = saldo - 20000
WHERE id = 1;

SELECT id, nama, saldo
FROM rekening
ORDER BY id;

ROLLBACK;

SELECT id, nama, saldo
FROM rekening
ORDER BY id;

START TRANSACTION;

UPDATE rekening
SET saldo = saldo - 30000
WHERE id = 1;

UPDATE rekening
SET saldo = saldo + 30000
WHERE id = 2;

SAVEPOINT setelah_transfer;

UPDATE rekening
SET saldo = saldo - 5000
WHERE id = 1;

SELECT id, nama, saldo
FROM rekening
ORDER BY id;

ROLLBACK TO SAVEPOINT setelah_transfer;

COMMIT;

SELECT id, nama, saldo
FROM rekening
ORDER BY id;

START TRANSACTION;

UPDATE rekening
SET saldo = saldo - 10000
WHERE id = 1;

SAVEPOINT sp_pemeriksaan;

UPDATE rekening
SET saldo = saldo + 10000
WHERE id = 2;

RELEASE SAVEPOINT sp_pemeriksaan;

COMMIT;

SELECT id, nama, saldo
FROM rekening
ORDER BY id;
