SELECT *
FROM Fatture 
WHERE DataFattura = '2020-08-12'
 OR DataFattura = (SELECT MAX(DataArrivoEffettiva) FROM Fatture)