
--CREATE FUNCTION	toplamTutar(@kID INT)
--RETURNS INT AS
--BEGIN
--DECLARE @toplamTutar INT;
--SELECT @toplamTutar=SUM(FIYAT) 
--FROM ANAHTAR
--WHERE KULLANICI_ID=@kID;

--RETURN @toplamTutar;

--END



--ID si verilen yapýmcýnýn en son ödül alan oyununun adýný döndüren fonksiyon

CREATE FUNCTION	sonOdulAlanOyun(@yapimciID INT)
RETURNS VARCHAR(50) AS
BEGIN
DECLARE @oyunAdi VARCHAR(50);

SELECT @oyunAdi=
o.ADI FROM OYUN O INNER JOIN ODULLER D ON O.OYUN_ID=D.OYUN_ID
WHERE YAPIMCI_ID=@yapimciID AND TARIH=(SELECT
MAX(TARIH) FROM OYUN O INNER JOIN ODULLER D ON O.OYUN_ID=D.OYUN_ID
WHERE YAPIMCI_ID=@yapimciID)

RETURN @oyunAdi;
END

go

select dbo.sonOdulAlanOyun(1)

go


--Kullanýcýlarýn oyunlarda kazandýðý baþarýlarý gösteren view

CREATE VIEW kullaniciBasarilari AS

SELECT K.TARIH AS KAZANMA_TARIHI, U.ADI AS ISIM,B.ADI AS KAZANILAN_BASARI,O.ADI AS KAZANDIGI_OYUN
FROM KULLANICI U INNER JOIN KAZANIR K ON U.KULLANICI_ID=K.KULLANICI_ID
INNER JOIN BASARIMLAR B ON K.BASARIM_ID=B.BASARIM_ID
INNER JOIN OYUN O ON O.OYUN_ID=B.OYUN_ID
go

SELECT * FROM kullaniciBasarilari

go

--Yapýmcýlarýn toplam satýþ miktarýný gösteren view.

CREATE VIEW vw_toplam_kazanc AS
    SELECT Y.YAPIMCI_ID AS YapýmcýID,
          Y.ADI AS YapýmcýAdý,
          SUM(O.FIYAT) AS ToplamKazanc FROM YAPIMCI Y
          INNER JOIN OYUN O ON O.YAPIMCI_ID = Y.YAPIMCI_ID
          INNER JOIN ANAHTAR A ON A.OYUN_ID = O.OYUN_ID
          GROUP BY Y.YAPIMCI_ID,Y.ADI
GO


SELECT * FROM vw_toplam_kazanc
GO


--Kullanýcý ID'si, Oyun ID'si veya yorum türünün opsiyonel olarak verilmesi durumunda,
--Hangi Kullanýcý, Hangi Oyun, Tarih, Yorum Metni ve Yorum Türü þeklinde listeleyen prosedür.
IF OBJECT_ID ('sp_YorumGetir') IS NOT NULL
BEGIN
    DROP PROCEDURE sp_YorumGetir
END
GO

CREATE PROCEDURE sp_YorumGetir(@kullaniciID INT=NULL, @oyunID INT=NULL, @tur INT=NULL) AS
    SELECT K.ADI AS HangiKullanici,
           O.ADI AS HangiOyun,
           Y.TARIH AS HangiTarih,
           Y.METIN AS YorumMetni,
           CASE WHEN Y.TUR = 0 THEN 'Olumsuz' ELSE 'Olumlu' END YorumTürü FROM KULLANICI K 
            INNER JOIN YORUMYAPAR Y ON K.KULLANICI_ID = Y.KULLANICI_ID
            INNER JOIN OYUN O ON Y.OYUN_ID=O.OYUN_ID
            WHERE K.KULLANICI_ID = ISNULL(@kullaniciID, K.KULLANICI_ID) AND 
              O.OYUN_ID = ISNULL(@oyunID, O.OYUN_ID) AND 
              TUR = ISNULL(@tur, TUR)
GO

EXEC sp_YorumGetir 1, NULL,1
EXEC sp_YorumGetir
EXEC sp_YorumGetir NULL, 1,0
EXEC sp_YorumGetir NULL,2, NULL
GO

-- verilen oyunu id si ve verilen indirim miktarýna göre indirim yapan procedure

CREATE PROCEDURE spIndirimYap(@oyunID INT,@oran FLOAT) AS

UPDATE OYUN SET FIYAT= FIYAT*(1-@oran) WHERE OYUN_ID=@oyunID

GO

EXEC spIndirimYap 1, 0.25
go
--id si verilen kullanýcyý silen procedure
CREATE PROCEDURE spKullaniciSil(@kullaniciID int) AS

DECLARE @tranCounter int =@@TRANCOUNT;

IF @tranCounter>0
	SAVE TRANSACTION prosedurKayitNoktasi

	 BEGIN TRANSACTION

BEGIN TRY
	DELETE FROM KAZANIR WHERE KULLANICI_ID=@kullaniciID;
	DELETE FROM ANAHTAR WHERE KULLANICI_ID=@kullaniciID;
	DELETE FROM YORUMYAPAR WHERE KULLANICI_ID=@kullaniciID;
	DELETE FROM FATURA WHERE KULLANICI_ID=@kullaniciID;
	DELETE FROM KULLANICI WHERE KULLANICI_ID=@kullaniciID;

COMMIT

END TRY

BEGIN CATCH

	IF @tranCounter=0 AND XACT_STATE() = -1
		ROLLBACK TRANSACTION
	ELSE
		BEGIN
			ROLLBACK TRANSACTION prosedurKayitNoktasi
			COMMIT
		END
	DECLARE @ErrorMessage NVARCHAR(4000)
	SET @ErrorMessage= ERROR_MESSAGE()
	DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
	DECLARE @ErrorState INT = ERROR_STATE()

	RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)
	END CATCH
go

exec spKullaniciSil 1
go

--trigger

CREATE TRIGGER trgOyunGüncelle ON OYUN AFTER UPDATE AS
    IF UPDATE(OYUN_ID)
    BEGIN 
        RAISERROR('!!! OYUN_ID GÜNCELLENEMEZ!!! GÜNCELLEME ÝPTAL EDÝLDÝ!', 16, 1)
        ROLLBACK
    END
GO


SELECT * FROM KULLANICI WHERE ADI='KULLANICI 435984'
 SET STATISTICS IO ON
 SET STATISTICS TIME ON

 CREATE NONCLUSTERED INDEX idxKullanici on KULLANICI (ADI,EMAIL)



