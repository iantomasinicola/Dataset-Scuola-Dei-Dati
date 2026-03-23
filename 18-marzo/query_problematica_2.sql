SELECT YEAR(DataFattura) AS Anno,
	COUNT(*)
FROM   dbo.Fatture
GROUP BY YEAR(DataFattura);
