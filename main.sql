-- Do people who spend more time on social media also spend more on e-commerce?

SELECT 
    CASE
        WHEN SocialMediaHrs < 1 THEN 'less than 1 hour'
        WHEN SocialMediaHrs BETWEEN 1 AND 3 THEN 'between 1 and 3 hours'
        WHEN SocialMediaHrs BETWEEN 3 AND 5 THEN 'between 3 and 5 hours'
        ELSE 'more than 5 hours'
    END AS SocialMediaHrsRange,
    AVG(EcomSpendINR) AS AvgEcomSpend
FROM
    phone_usage
GROUP BY CASE
    WHEN SocialMediaHrs < 1 THEN 'less than 1 hour'
    WHEN SocialMediaHrs BETWEEN 1 AND 3 THEN 'between 1 and 3 hours'
    WHEN SocialMediaHrs BETWEEN 3 AND 5 THEN 'between 3 and 5 hours'
    ELSE 'more than 5 hours'
END
ORDER BY AvgEcomSpend DESC;


-- Are there any anomalies, like extremely high screen time or unusual recharge patterns?

SELECT 
    UserID, ScreenTimeHrs, DataUsageGB, RechargeCostINR
FROM
    phone_usage
WHERE
    ScreenTimeHrs > 24
        OR (DataUsageGB <= 1
        AND RechargeCostINR > 500)
ORDER BY RechargeCostINR ASC;


-- What are the most cost-effective recharge plans for heavy users?

SELECT 
    UserID, DataUsageGB, CallsDurationMins, RechargeCostINR
FROM
    phone_usage
WHERE
    DataUsageGB > 45
        AND CallsDurationMins > 100
ORDER BY RechargeCostINR ASC
LIMIT 1;


-- Which locations have the highest average data usage?

SELECT 
    Location, AVG(DataUsageGB) AS AvgDataUsage
FROM
    phone_usage
GROUP BY Location
ORDER BY AvgDataUsage DESC;


-- What is the most popular phone brand in each city based on user count?

SELECT 
    Location, 
    PhoneBrand AS MostFamousBrand, 
    UserCount AS NumberOfUsers
FROM (
    SELECT 
        Location, 
        PhoneBrand, 
        COUNT(UserID) AS UserCount,
        RANK() OVER (PARTITION BY Location ORDER BY COUNT(UserID) DESC) AS `Rank`
    FROM 
        phone_usage
    GROUP BY 
        Location, 
        PhoneBrand
) AS RankedBrands
WHERE 
    `Rank` = 1
ORDER BY 
    Location ASC;
