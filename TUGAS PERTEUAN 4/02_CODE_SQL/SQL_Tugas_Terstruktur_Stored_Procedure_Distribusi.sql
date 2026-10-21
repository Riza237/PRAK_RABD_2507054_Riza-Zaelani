/*
TUGAS TERSTRUKTUR PERTEMUAN 4 - STORED PROCEDURES
PT Mitra Distribusi Nusantara | MariaDB/MySQL melalui DBeaver

JALANKAN SEBAGAI SQL SCRIPT (umumnya Alt+X), karena menggunakan DELIMITER.
PERINGATAN: bagian reset menghapus tabel/procedure bernama sama pada database latihan.
*/

CREATE DATABASE IF NOT EXISTS db_distribusi;
USE db_distribusi;

-- RESET OBJEK LATIHAN
DROP PROCEDURE IF EXISTS sp_tampil_barang;
DROP PROCEDURE IF EXISTS sp_cari_kategori;
DROP PROCEDURE IF EXISTS sp_tambah_barang;
DROP PROCEDURE IF EXISTS sp_catat_penjualan;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS penjualan;
DROP TABLE IF EXISTS barang;
SET FOREIGN_KEY_CHECKS = 1;

-- TUGAS 1: MEMBUAT TABEL DAN MENGISI DATA
CREATE TABLE barang (
    kode_barang VARCHAR(5) NOT NULL,
    nama_barang VARCHAR(100) NOT NULL,
    kategori VARCHAR(30) NOT NULL,
    harga DECIMAL(12,2) NOT NULL,
    stok INT NOT NULL,
    PRIMARY KEY (kode_barang)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE penjualan (
    no_transaksi VARCHAR(5) NOT NULL,
    tanggal DATE NOT NULL,
    kode_barang VARCHAR(5) NOT NULL,
    jumlah INT NOT NULL,
    PRIMARY KEY (no_transaksi),
    CONSTRAINT fk_penjualan_barang
        FOREIGN KEY (kode_barang) REFERENCES barang(kode_barang)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO barang (kode_barang, nama_barang, kategori, harga, stok) VALUES
('BR001', 'Kertas A4', 'ATK', 65000, 120),
('BR002', 'Tinta Printer', 'Elektronik', 85000, 45),
('BR003', 'Pulpen', 'ATK', 2500, 500),
('BR004', 'Toner Printer', 'Elektronik', 450000, 20),
('BR005', 'Map Arsip', 'ATK', 5000, 200),
('BR006', 'Kalkulator', 'Elektronik', 125000, 35),
('BR007', 'Buku Agenda', 'ATK', 18000, 80),
('BR008', 'Label Pengiriman', 'Kemasan', 12000, 150);

INSERT INTO penjualan (no_transaksi, tanggal, kode_barang, jumlah) VALUES
('TR001', '2026-10-01', 'BR001', 10),
('TR002', '2026-10-02', 'BR002', 5),
('TR003', '2026-10-03', 'BR003', 50),
('TR004', '2026-10-04', 'BR005', 20),
('TR005', '2026-10-05', 'BR007', 15);

SELECT * FROM barang ORDER BY kode_barang;
SELECT * FROM penjualan ORDER BY no_transaksi;

-- TUGAS 2: MEMBUAT EMPAT STORED PROCEDURE
DELIMITER $$

CREATE PROCEDURE sp_tampil_barang()
BEGIN
    SELECT kode_barang, nama_barang, kategori, harga, stok
    FROM barang
    ORDER BY kode_barang;
END$$

CREATE PROCEDURE sp_cari_kategori(IN p_kategori VARCHAR(30))
BEGIN
    SELECT kode_barang, nama_barang, kategori, harga, stok
    FROM barang
    WHERE kategori = p_kategori
    ORDER BY kode_barang;
END$$

CREATE PROCEDURE sp_tambah_barang(
    IN p_kode_barang VARCHAR(5),
    IN p_nama_barang VARCHAR(100),
    IN p_kategori VARCHAR(30),
    IN p_harga DECIMAL(12,2),
    IN p_stok INT
)
BEGIN
    INSERT INTO barang (kode_barang, nama_barang, kategori, harga, stok)
    VALUES (p_kode_barang, p_nama_barang, p_kategori, p_harga, p_stok);

    SELECT * FROM barang ORDER BY kode_barang;
END$$

CREATE PROCEDURE sp_catat_penjualan(
    IN p_no_transaksi VARCHAR(5),
    IN p_tanggal DATE,
    IN p_kode_barang VARCHAR(5),
    IN p_jumlah INT
)
BEGIN
    INSERT INTO penjualan (no_transaksi, tanggal, kode_barang, jumlah)
    VALUES (p_no_transaksi, p_tanggal, p_kode_barang, p_jumlah);

    SELECT * FROM penjualan ORDER BY no_transaksi;
END$$

DELIMITER ;

-- TUGAS 3: MEMANGGIL DAN MENGUJI PROCEDURE
CALL sp_tampil_barang();
CALL sp_cari_kategori('Elektronik');
CALL sp_tambah_barang('BR009', 'Label Barcode', 'Kemasan', 25000, 75);
CALL sp_catat_penjualan('TR006', '2026-10-06', 'BR009', 10);

SELECT * FROM barang WHERE kode_barang = 'BR009';
SELECT * FROM penjualan WHERE no_transaksi = 'TR006';

-- TUGAS 4: DAFTAR STORED PROCEDURE
SHOW PROCEDURE STATUS WHERE Db = 'db_distribusi';

-- TUGAS 5: UBAH sp_tampil_barang MENJADI FILTER stok < 50
-- Definisi awal prosedur di atas merupakan definisi sebelumnya.
DROP PROCEDURE IF EXISTS sp_tampil_barang;

DELIMITER $$
CREATE PROCEDURE sp_tampil_barang()
BEGIN
    SELECT kode_barang, nama_barang, kategori, harga, stok
    FROM barang
    WHERE stok < 50
    ORDER BY kode_barang;
END$$
DELIMITER ;

CALL sp_tampil_barang();
-- Hasil yang benar: BR002 (45), BR004 (20), BR006 (35).
-- BR009 tidak muncul karena stoknya 75.

-- TUGAS 6: HAPUS DUA PROCEDURE
DROP PROCEDURE sp_catat_penjualan;
DROP PROCEDURE IF EXISTS sp_tambah_barang;

SHOW PROCEDURE STATUS WHERE Db = 'db_distribusi';

-- Untuk mengamati error setelah procedure dihapus, jalankan satu per satu
-- dengan menghilangkan tanda komentar:
-- CALL sp_catat_penjualan('TR007', '2026-10-07', 'BR009', 1);
-- CALL sp_tambah_barang('BR010', 'Contoh', 'Kemasan', 1000, 1);

-- Data tetap ada meskipun procedure dihapus
SELECT * FROM barang ORDER BY kode_barang;
SELECT * FROM penjualan ORDER BY no_transaksi;
