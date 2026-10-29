-- TUGAS MANDIRI PRAKTIKUM BASIS DATA
-- Implementasi Function dan Trigger
-- DBMS: MySQL 8.0 | Editor: DBeaver | Pengelola layanan: DBngin
-- Jalankan bagian per bagian sesuai komentar. Uji yang diharapkan menghasilkan error
-- (contoh harga = 0) dijalankan TERPISAH agar tidak menghentikan skrip pengujian lain.

CREATE DATABASE IF NOT EXISTS praktikum_function_trigger;
USE praktikum_function_trigger;

-- =========================================================
-- 1. MEMBUAT TABEL (sesuai modul praktikum)
-- =========================================================
CREATE TABLE IF NOT EXISTS produk (
    id_produk INT AUTO_INCREMENT PRIMARY KEY,
    nama_produk VARCHAR(100) NOT NULL,
    harga DECIMAL(12,2) NOT NULL,
    stok INT NOT NULL DEFAULT 0,
    CHECK (harga > 0),
    CHECK (stok >= 0)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS penjualan (
    id_penjualan INT AUTO_INCREMENT PRIMARY KEY,
    id_produk INT NOT NULL,
    jumlah INT NOT NULL,
    harga_satuan DECIMAL(12,2) NOT NULL,
    total DECIMAL(14,2) NOT NULL DEFAULT 0,
    tanggal_transaksi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_penjualan_produk
        FOREIGN KEY (id_produk) REFERENCES produk(id_produk),
    CHECK (jumlah > 0),
    CHECK (harga_satuan > 0),
    CHECK (total >= 0)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS log_stok (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_produk INT NOT NULL,
    stok_awal INT NOT NULL,
    stok_akhir INT NOT NULL,
    keterangan VARCHAR(100) NOT NULL,
    waktu_log TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB;

-- Data awal hanya dimasukkan jika produk dengan nama tersebut belum ada.
INSERT INTO produk (nama_produk, harga, stok)
SELECT 'Laptop', 7500000, 10
WHERE NOT EXISTS (SELECT 1 FROM produk WHERE nama_produk = 'Laptop');

INSERT INTO produk (nama_produk, harga, stok)
SELECT 'Mouse', 150000, 25
WHERE NOT EXISTS (SELECT 1 FROM produk WHERE nama_produk = 'Mouse');

INSERT INTO produk (nama_produk, harga, stok)
SELECT 'Keyboard', 350000, 15
WHERE NOT EXISTS (SELECT 1 FROM produk WHERE nama_produk = 'Keyboard');

INSERT INTO produk (nama_produk, harga, stok)
SELECT 'Monitor', 1800000, 8
WHERE NOT EXISTS (SELECT 1 FROM produk WHERE nama_produk = 'Monitor');

SELECT * FROM produk;

-- =========================================================
-- 2. FUNCTION hitung_pajak (pajak 11%)
-- =========================================================
DROP FUNCTION IF EXISTS hitung_pajak;
DELIMITER //
CREATE FUNCTION hitung_pajak(p_total DECIMAL(14,2))
RETURNS DECIMAL(14,2)
DETERMINISTIC
NO SQL
BEGIN
    RETURN p_total * 0.11;
END //
DELIMITER ;

-- Pengujian: hasil Rp220.000 dan Rp550.000
SELECT 2000000 AS total_transaksi, hitung_pajak(2000000) AS pajak;
SELECT 5000000 AS total_transaksi, hitung_pajak(5000000) AS pajak;

-- =========================================================
-- 3. FUNCTION hitung_total_akhir (diskon dalam persen)
-- =========================================================
DROP FUNCTION IF EXISTS hitung_total_akhir;
DELIMITER //
CREATE FUNCTION hitung_total_akhir(
    p_total DECIMAL(14,2),
    p_diskon DECIMAL(5,2)
)
RETURNS DECIMAL(14,2)
DETERMINISTIC
NO SQL
BEGIN
    RETURN p_total * (1 - p_diskon / 100);
END //
DELIMITER ;

-- Pengujian: diskon Rp450.000, total akhir Rp2.550.000
SELECT
    3000000 AS total_transaksi,
    15 AS diskon_persen,
    3000000 * 15 / 100 AS nominal_diskon,
    hitung_total_akhir(3000000, 15) AS total_akhir;

-- =========================================================
-- 4. TRIGGER catat_perubahan_stok (AFTER UPDATE produk)
-- =========================================================
DROP TRIGGER IF EXISTS catat_perubahan_stok;
DELIMITER //
CREATE TRIGGER catat_perubahan_stok
AFTER UPDATE ON produk
FOR EACH ROW
BEGIN
    IF OLD.stok <> NEW.stok THEN
        INSERT INTO log_stok (
            id_produk, stok_awal, stok_akhir, keterangan
        )
        VALUES (
            NEW.id_produk, OLD.stok, NEW.stok,
            'Perubahan stok produk'
        );
    END IF;
END //
DELIMITER ;

-- Pengujian stok Mouse dari 25 menjadi 30.
-- Pastikan ID Mouse dari SELECT produk adalah 2; jika berbeda, sesuaikan ID.
-- Reset stok dan bersihkan log pengujian Mouse:
UPDATE produk SET stok = 25 WHERE id_produk = 2;
DELETE FROM log_stok WHERE id_produk = 2;

-- Perubahan yang diuji:
UPDATE produk SET stok = 30 WHERE id_produk = 2;

SELECT id_produk, nama_produk, stok
FROM produk WHERE id_produk = 2;

SELECT * FROM log_stok WHERE id_produk = 2;

-- Hasil yang diharapkan: stok 30, log stok_awal 25 dan stok_akhir 30.
-- Catatan: UPDATE reset ke 25 di atas dapat membuat log sementara; log tersebut
-- dibersihkan sebelum pengujian utama.

-- =========================================================
-- 5. TRIGGER validasi_harga_produk (BEFORE UPDATE produk)
-- =========================================================
DROP TRIGGER IF EXISTS validasi_harga_produk;
DELIMITER //
CREATE TRIGGER validasi_harga_produk
BEFORE UPDATE ON produk
FOR EACH ROW
BEGIN
    IF NEW.harga <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Harga produk harus lebih dari nol';
    END IF;
END //
DELIMITER ;

-- UJI VALID: perubahan harga Mouse menjadi Rp200.000 harus berhasil.
UPDATE produk SET harga = 200000 WHERE id_produk = 2;
SELECT nama_produk, harga FROM produk WHERE id_produk = 2;

-- UJI TIDAK VALID - JALANKAN TERPISAH:
-- Perintah berikut harus ditolak oleh trigger. Jangan hilangkan tanda komentar
-- jika sedang menjalankan seluruh skrip sekaligus.
-- UPDATE produk SET harga = 0 WHERE id_produk = 2;
-- Setelah mencoba perintah di atas secara terpisah, verifikasi:
SELECT nama_produk, harga FROM produk WHERE id_produk = 2;
-- Harga seharusnya tetap Rp200.000.

-- =========================================================
-- 6. PEMERIKSAAN OBJEK
-- =========================================================
SHOW FUNCTION STATUS
WHERE Db = 'praktikum_function_trigger';

SHOW TRIGGERS FROM praktikum_function_trigger;

-- =========================================================
-- RINGKASAN HASIL YANG DIHARAPKAN
-- =========================================================
-- hitung_pajak(2000000) = 220000.00
-- hitung_pajak(5000000) = 550000.00
-- hitung_total_akhir(3000000, 15) = 2550000.00
-- stok Mouse setelah pengujian = 30
-- log perubahan Mouse = stok awal 25, stok akhir 30
-- UPDATE harga Mouse ke 200000 = diterima
-- UPDATE harga Mouse ke 0 = ditolak oleh trigger
