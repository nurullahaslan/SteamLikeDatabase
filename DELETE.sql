--ANAHTAR_ID ile OYUN_ID'si e�it olan ANAHTAR sat�rlar�n� sil.
DELETE FROM ANAHTAR WHERE ANAHTAR_ID = OYUN_ID
--FIYAT'� 50 ile 100 aras�ndaki ANAHTAR sat�rlar�n� sil.
DELETE FROM ANAHTAR WHERE FIYAT BETWEEN 50 AND 100

--OYUN_ID de�eri girilen tarihlerin fark�n�n g�n cinsinden de�erine e�it olan YORUMYAPAR sat�rlar�n� sil.
DELETE FROM YORUMYAPAR WHERE OYUN_ID = DATEDIFF(DD,'2017-8-6','2018-3-13');

--OYUN_ID de�eri mevcut tarihin ay cinsinden de�erine e�it olan ODULLER sat�rlar�n� sil.
DELETE FROM ODULLER WHERE OYUN_ID = DATEPART(MM,GETDATE());

--BASARIM_ID si 1 ve 12 olarak kay�tl� KAZANIR sat�rlar�n� sil.
DELETE FROM  KAZANIR WHERE BASARIM_ID = 1 AND BASARIM_ID = 12
