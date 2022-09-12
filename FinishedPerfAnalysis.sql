--QUick query to make sure everything was imported correctly
SELECT *
FROM [Trading Analysis Mid-2021]..Performance$

--Going to start by checking the overall PNL for this strategy 
SELECT SUM(pnl) as Total_Profit
FROM [Trading Analysis Mid-2021]..Performance$
--From this query I can see that the strategy, without commission and fees, had a positive PNL of 95 dollars 
--Now going to start adding in the data that this table does not include which is a commision for every contract bought or sold and I will put that into a new table.
--I also want to clean up some of the extra data imported in from the brokerage that is not necessary for this.
CREATE TABLE Performance_Comsission_Added (
	symbol NVARCHAR(255),
	_priceFormat FLOAT,
	_tickSize FLOAT,
	buyFillId FLOAT,
	sellFillId FLOAT,
	buyPrice FLOAT,
	sellPrice FLOAT,
	pnl MONEY,
	boughtTimestamp DATETIME,
	soldTimestamp DATETIME,
	durationSeconds FLOAT,
	tradeComission FLOAT
	)
	
INSERT INTO Performance_Comsission_Added
	SELECT symbol, _priceFormat, _tickSize, buyFillId, sellFillId, buyPrice, sellPrice, pnl, boughtTimestamp, soldTimestamp, durationSeconds,
		(_priceFormat*-0.25) AS tradeComission
	FROM [Trading Analysis Mid-2021]..Performance$
--Now another quick query to check that the data was imported into the new table correctly.
SELECT * FROM [Trading Analysis Mid-2021]..Performance_Comsission_Added
--Now I will do a new profit calculation while including comission on the trades.
SELECT SUM(pnl) AS grossPnl, (SUM(pnl)-SUM(tradeComission)) AS netPnl
FROM [Trading Analysis Mid-2021]..Performance_Comsission_Added

--Now we can see that the true number is that this strategy, in these conditions, would have lost 357.5 dollars over this time period while factoring in trade comissions.
--I will take the data from the table I created and create visualizations in tableau to better display the shortcomings of this strategy.

CREATE VIEW Stats_on_Bulk AS
	SELECT SUM(pnl) AS grossPnl, (SUM(pnl)-SUM(tradeComission)) AS netPnl, AVG(durationSeconds) as averageDuration, (CAST(COUNT(CASE WHEN pnl < 0 THEN 1 END) AS DECIMAL)/COUNT(pnl))*100 AS PercentLosingTrades, 
		COUNT(CASE WHEN pnl < 0 THEN 1 END) AS countLosingtrades, (CAST(COUNT(CASE WHEN pnl > 0 THEN 1 END) AS DECIMAL)/COUNT(pnl))*100 AS PercentWinningTrades, COUNT(CASE WHEN pnl > 0 THEN 1 END) AS countWinningtrades, 
		(CAST(COUNT(CASE WHEN pnl = 0 THEN 1 END) AS DECIMAL)/COUNT(pnl))*100 AS PercentScratchTrades, COUNT(CASE WHEN pnl = 0 THEN 1 END) AS countScratchtrades
	FROM [Trading Analysis Mid-2021]..Performance_Comsission_Added;

CREATE VIEW Bulk_Perf_Export AS
	SELECT *
	FROM [Trading Analysis Mid-2021]..Performance_Comsission_Added;