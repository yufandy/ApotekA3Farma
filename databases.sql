CREATE TABLE MasterSatuan (
    SatuanID INT IDENTITY(1,1) PRIMARY KEY,
    NamaSataun VARCHAR(100)
);

INSERT INTO Obat (KodeSKU,
    TipeProduk,
    NamaObat,
    Produsen,
    Barcode,
    Batch,
    JenisObat,
    BentukObat,
    SatuanUtama,
    SatuanLain,
    SatuanPengalih,
    HargaBeli,
    HargaJual,
    Stok,
    ZatAktif,
    KomisiPenjualan,
    NilaiKomisi,
    WajibdenganResep,
    TampilkanDiKatalog,
    Kandungan,
    Deskripsi)
VALUES
  ('Paracetamol', 'Analgesik', 'Tablet', 'Strip', 5000, 7000, 100, 'Penurun panas'),
  ('Amoxicillin', 'Antibiotik', 'Kapsul', 'Botol', 15000, 20000, 50, 'Antibakteri'),
  ('Vitamin C', 'Vitamin', 'Tablet', 'Strip', 3000, 5000, 200, 'Antioksidan');

CREATE TABLE Kategory (
    KategoryID INT IDENTITY(1,1) PRIMARY KEY,
    NamaKategory VARCHAR(100)
);

CREATE TABLE MasterRak (
    RakID INT IDENTITY(1,1) PRIMARY KEY,
    NamaRak VARCHAR(100)
);

CREATE TABLE Supplier (
    SupplierID INT IDENTITY(1,1) PRIMARY KEY,
    NamaSupplier VARCHAR(100),
    Alamat VARCHAR(200),
    Telepon VARCHAR(20)
);

CREATE TABLE Obat (
    ObatID INT IDENTITY(1,1) PRIMARY KEY,
    KodeSKU VARCHAR(100),
    TipeProduk VARCHAR(100),
    NamaObat VARCHAR(100),
    Produsen VARCHAR(100),
    Barcode VARCHAR(100),
    Batch VARCHAR(100),
    JenisObat VARCHAR(50),
    BentukObat VARCHAR(50),
    SatuanUtama VARCHAR(20),
    SatuanLain VARCHAR(20),
    SatuanPengalih VARCHAR(20),
    HargaBeli DECIMAL(10,2),
    HargaJual DECIMAL(10,2),
    Stok INT,
    ZatAktif VARCHAR(20),
    KomisiPenjualan	VARCHAR(50),
    NilaiKomisi DECIMAL(10,2),
    WajibdenganResep VARCHAR(20),
    TampilkanDiKatalog VARCHAR(20),
    Kandungan TEXT,
    Deskripsi TEXT
);

CREATE TABLE Transaksi (
    TransaksiID INT IDENTITY(1,1) PRIMARY KEY,
    TanggalTransaksi DATETIME,
    JenisTransaksi VARCHAR(20),
    TotalHarga DECIMAL(10,2),
    CustomerID INT
);

CREATE TABLE DetailTransaksi (
    DetailTransaksiID INT IDENTITY(1,1) PRIMARY KEY,
    TransaksiID INT,
    ObatID INT,
    Jumlah INT,
    HargaSatuan DECIMAL(10,2),
    CONSTRAINT FK_DetailTransaksi_Transaksi FOREIGN KEY (TransaksiID) REFERENCES Transaksi(TransaksiID),
    CONSTRAINT FK_DetailTransaksi_Obat FOREIGN KEY (ObatID) REFERENCES Obat(ObatID)
);

CREATE TABLE Customer (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    NamaCustomer VARCHAR(100),
    Alamat VARCHAR(200),
    Telepon VARCHAR(20)
);
