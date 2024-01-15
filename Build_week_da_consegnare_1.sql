SELECT * FROM build_week.transazioni;

 --  1.Analisi delle Vendite Mensili:
--  Domanda: Trova il totale delle vendite per ogni mese. 

SELECT
    MONTH(DataTransazione) AS Mese,
    ROUND(SUM(Prezzo_per_quantita_acquistata),2) AS VenditeTotali
FROM
    `build_week`.`transazioni`
GROUP BY
    Mese;
    
    
    
    --  2.Prodotti più Venduti:
    --  Domanda: Identifica i tre prodotti più venduti e la loro quantità venduta.
    
    SELECT
    P.NomeProdotto,  p.ProdottoID,
    SUM(T.QuantitaAcquistata) AS QuantitaVenduta
FROM
   `build_week`.`transazioni` T
JOIN
    `build_week`.`prodotti` P ON T.ProdottoID = P.ProdottoID
GROUP BY
    T.ProdottoID, P.NomeProdotto
ORDER BY
    QuantitaVenduta DESC
LIMIT 3;

--  3.Analisi Cliente:
--  Domanda: Trova il cliente che ha effettuato il maggior numero di acquisti.
SELECT
    C.NomeCliente, C.ClienteID,
    COUNT(T.TransazioneID) AS NumeroAcquisti,
     SUM(T.QuantitaAcquistata) AS QuantitaTotaleAcquistata
FROM
    `build_week`.`clienti` C
JOIN
    `build_week`.`transazioni` T ON C.ClienteID = T.ClienteID
GROUP BY
    C.ClienteID, C.NomeCliente
ORDER BY
    NumeroAcquisti DESC
LIMIT 2;  --   Limit 2 perchè sono in due che hanno fatto 3 acquisti.

--  4.Valore medio della transazione:
--  Domanda: Calcola il valore medio di ogni transazione.

SELECT
    p.Categoria,
    YEAR(t.DataTransazione) AS Anno,
    MONTH(t.DataTransazione) AS Mese,
    QUARTER(t.DataTransazione) AS Trimestre,
    ROUND(AVG(t.ImportoTransazione),2) AS ValoreMedioTransazionePerCategoria
FROM
    `build_week`.`transazioni` t
JOIN
    `build_week`.`prodotti` p ON t.ProdottoID = p.ProdottoID
GROUP BY
    p.Categoria, Anno, Mese, Trimestre
ORDER BY
    p.Categoria, Anno, Mese, Trimestre;

-- 5.Analisi Categoria Prodotto:
-- Domanda: Determina la categoria di prodotto con il maggior numero di vendite.

SELECT
    p.Categoria,
    SUM(t.QuantitaAcquistata) AS QuantitaTotaleVenduta
FROM
    `build_week`.`prodotti` p
JOIN
    `build_week`.`transazioni` t ON p.ProdottoID = t.ProdottoID
GROUP BY
    p.Categoria
ORDER BY
    QuantitaTotaleVenduta DESC
LIMIT 1;

--  6.Cliente Fedele:
--  Domanda: Identifica il cliente con il maggior valore totale di acquisti.

SELECT
    c.ClienteID,
    c.NomeCliente,
    c.Email,
    SUM(t.Prezzo_per_quantita_acquistata) AS ValoreTotaleAcquisti
FROM
    `build_week`.`clienti` c
JOIN
    `build_week`.`transazioni` t ON c.ClienteID = t.ClienteID
GROUP BY
    c.ClienteID, c.NomeCliente, c.Email
ORDER BY
    ValoreTotaleAcquisti DESC
LIMIT 1;

--  7.Spedizioni Riuscite:
--  Domanda: Calcola la percentuale di spedizioni con "Consegna Riuscita".

SELECT
    COUNT(*) AS NumeroTotaleSpedizioni,
    SUM(CASE WHEN s.StatusConsegna = 'Consegna Riuscita' THEN 1 ELSE 0 END) AS NumeroConsegneRiuscite,
    ROUND((SUM(CASE WHEN s.StatusConsegna = 'Consegna Riuscita' THEN 1 ELSE 0 END) / COUNT(*)) * 100,2) AS PercentualeConsegneRiuscite
FROM
    `build_week`.`spedizioni` s;
    
--  8.Prodotto con la Migliore Recensione:
--  Domanda: Trova il prodotto con la recensione media più alta.

SELECT
    p.ProdottoID,
    p.NomeProdotto,
    SUM(t.QuantitaAcquistata) AS QuantitaAcquistata,
    p.Categoria,
    AVG(r.Rating) AS MediaRecensioni
FROM
    `build_week`.`prodotti` p
JOIN
    `build_week`.`transazioni` t ON p.ProdottoID = t.ProdottoID
JOIN
    `build_week`.`ratings` r ON p.ProdottoID = r.ProdottoID
GROUP BY
    p.Categoria
ORDER BY
    MediaRecensioni DESC
    LIMIT 3;
    

    
--  9.Analisi Temporale:
--  Domanda: Calcola la variazione percentuale nelle vendite rispetto al mese precedente.

SELECT
    MONTH(DataTransazione) AS Mese,
    YEAR(DataTransazione) AS Anno,
    ROUND(SUM(Prezzo_per_quantita_acquistata),2) AS VenditeMensili,
    LAG(ROUND(SUM(Prezzo_per_quantita_acquistata),2)) OVER (ORDER BY YEAR(DataTransazione), MONTH(DataTransazione)) AS VenditeMensiliMesePrecedente,
    CASE
        WHEN LAG(SUM(Prezzo_per_quantita_acquistata)) OVER (ORDER BY YEAR(DataTransazione), MONTH(DataTransazione)) IS NOT NULL
        THEN ((SUM(Prezzo_per_quantita_acquistata) - LAG(SUM(Prezzo_per_quantita_acquistata)) OVER (ORDER BY YEAR(DataTransazione), MONTH(DataTransazione))) / LAG(SUM(ImportoTransazione)) OVER (ORDER BY YEAR(DataTransazione), MONTH(DataTransazione))) * 100
        ELSE NULL
    END AS VariazionePercentuale
FROM
    `build_week`.`transazioni`
GROUP BY
    YEAR(DataTransazione), MONTH(DataTransazione)
ORDER BY
    YEAR(DataTransazione), MONTH(DataTransazione);
  
    
    
--  10.Quantità di Prodotti Disponibili:
--  Domanda: Determina la quantità media disponibile per categoria di prodotto.

SELECT
    Categoria,
    ROUND(AVG(QuantitaDisponibile),2) AS QuantitaMediaDisponibile
FROM
     `build_week`.`prodotti`
GROUP BY
    Categoria;
    
--   11.Analisi Spedizioni:
--   Domanda: Trova il metodo di spedizione più utilizzato.

 SELECT
    MetodoSpedizione,
    COUNT(*) AS NumeroTransazioni
FROM
    `build_week`.`spedizioni`
GROUP BY
    MetodoSpedizione
ORDER BY
    NumeroTransazioni DESC
LIMIT 1;

--  12.Analisi dei Clienti:
--  Domanda: Calcola il numero medio di clienti registrati al mese.


SELECT
    ROUND(COUNT(*) / 24, 0) AS MediaClientiMensile
FROM
    `build_week`.clienti
WHERE
    YEAR(DataRegistrazione) IN (2022, 2023);
    
    
--  13.Prodotti Rari:
--  Domanda: Identifica i prodotti con una quantità disponibile inferiore alla media.
    
    SELECT
    NomeProdotto,
    Categoria,
    QuantitaDisponibile,
    ROUND(AVG(QuantitaDisponibile) OVER (PARTITION BY Categoria), 2) AS MediaQuantitaCategoria,
    CASE
        WHEN QuantitaDisponibile > AVG(QuantitaDisponibile) OVER (PARTITION BY Categoria) THEN '+'
        WHEN QuantitaDisponibile < AVG(QuantitaDisponibile) OVER (PARTITION BY Categoria) THEN '-'
        ELSE '='
    END AS ConfrontoConMedia
FROM
    `build_week`.`prodotti`
ORDER BY
    Categoria, NomeProdotto;  --  è stata presa la media per la categoria.
    
--   14.Analisi dei Prodotti per Cliente:
--  Domanda: Per ogni cliente, elenca i prodotti acquistati e il totale speso.


  SELECT a.ClienteID, a.ProdottoID, 
       ROUND(SUM(a.QuantitaAcquistata*b.Prezzo),2) AS Spesa_acquisti,
       a.QuantitaAcquistata
FROM `Build_week`.`transazioni` a
JOIN `Build_week`.`prodotti` b
ON a.ProdottoID = b.ProdottoID
GROUP BY a.ClienteID, a.ProdottoID
ORDER BY a.ClienteID ASC; 
    
--  15.Miglior Mese per le Vendite:
--  Domanda: Identifica il mese con il maggior importo totale delle vendite.

SELECT 
    YEAR(DataTransazione) AS Anno,
    MONTH(DataTransazione) AS Mese,
    ROUND(SUM(p.Prezzo * t.QuantitaAcquistata), 2) AS ImportoTotaleVendite
FROM  `build_week`.`transazioni` t
JOIN `build_week`.`prodotti` p ON t.ProdottoID = p.ProdottoID
GROUP BY Anno, Mese
ORDER BY ImportoTotaleVendite DESC
LIMIT 1;

--  16.Analisi dei Prodotti in Magazzino:
--  Domanda: Trova la quantità totale di prodotti disponibili in magazzino.

SELECT
    p.Categoria,
    YEAR(t.DataTransazione) AS Anno,
    MONTH(t.DataTransazione) AS Mese,
    SUM(p.QuantitaDisponibile) AS QuantitaTotaleDisponibile
FROM
    `build_week`.`prodotti` p
LEFT JOIN
    `build_week`.`transazioni` t ON p.ProdottoID = t.ProdottoID
GROUP BY
    p.Categoria, Anno, Mese
ORDER BY
    p.Categoria, Anno, Mese;
    
--   17.Clienti Senza Acquisti:
--  Domanda: Identifica i clienti che non hanno effettuato alcun acquisto.

    SELECT COUNT(*) AS NumeroClientiSenzaAcquisti
FROM `build_week`.`clienti` c
LEFT JOIN `build_week`.`transazioni` t ON c.ClienteID = t.ClienteID
WHERE t.ClienteID IS NULL;
        
--  18.Analisi Annuale delle Vendite:
--  Domanda: Calcola il totale delle vendite per ogni anno.

SELECT 
    YEAR(DataTransazione) AS Anno,
    Categoria,
    ROUND(SUM(Prezzo_per_quantita_acquistata), 2) AS TotaleVenditePerCategoria
FROM
    `build_week`.`transazioni` T
JOIN
    `build_week`.`prodotti` P ON T.ProdottoID = P.ProdottoID
GROUP BY 
    Anno, Categoria
ORDER BY 
    Anno, Categoria;  --  Contati per la categoria per l'analisi migliore
    

    
--  19.Spedizioni in Ritardo:
--  Domanda: Trova la percentuale di spedizioni con "In Consegna" rispetto al totale.


    SELECT
    COUNT(*) AS NumeroTotaleSpedizioni,
    SUM(CASE WHEN StatusConsegna = 'In Consegna' THEN 1 ELSE 0 END) AS NumeroInConsegna,
    ROUND((SUM(CASE WHEN StatusConsegna = 'In Consegna' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS PercentualeInConsegna
FROM
    `build_week`.`spedizioni`;