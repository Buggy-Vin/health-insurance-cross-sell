-- เพิ่มคอลัมน์ age_band เพื่อจัดกลุ่มอายุ
ALTER TABLE data ADD COLUMN age_band VARCHAR(10);

UPDATE data
SET age_band = CASE
    WHEN age BETWEEN 20 AND 25 THEN '20-25'
    WHEN age BETWEEN 26 AND 35 THEN '26-35'
    WHEN age BETWEEN 36 AND 45 THEN '36-45'
    WHEN age BETWEEN 46 AND 55 THEN '46-55'
    WHEN age BETWEEN 56 AND 65 THEN '56-65'
    ELSE '66-85'
END;

-- เพิ่มคอลัมน์ vintage_band เพื่อจัดกลุ่มระยะเวลาที่เป็นลูกค้า
ALTER TABLE data ADD COLUMN vintage_band VARCHAR(20);

UPDATE data
SET vintage_band = CASE
    WHEN vintage BETWEEN 10 AND 90 THEN 'Q1'
    WHEN vintage BETWEEN 91 AND 180 THEN 'Q2'
    WHEN vintage BETWEEN 181 AND 270 THEN 'Q3'
    ELSE 'Q4'
END;

-- จำนวนลูกค้าตามกลุ่มอายุ
SELECT age_band,
       count(*) as customer_count
FROM data
group by age_band;

-- จำนวนลูกค้าตามเพศ
SELECT gender,
       count(*) as customer_count
FROM data
group by gender;

-- ภูมิภาคที่มีลูกค้ามากที่สุด 10 อันดับ
SELECT region_code,
       count(*) as customer_count
FROM data
group by region_code
order by customer_count desc
limit 10;

-- กลุ่มอายุที่มีอัตราตอบรับสูงที่สุด
SELECT age_band,
       count(*) as customer_count,
       sum(response) as interested_customers,
	     ROUND(SUM(response)::numeric / COUNT(*), 4) AS response_rate
FROM data
group by age_band
order by response_rate desc;


-- เปรียบเทียบอัตราตอบรับตามประวัติรถเสียหาย
SELECT vehicle_damage,
       count(*) as customer_count,
	     sum(response) as interested_customers,
	     ROUND(SUM(response)::numeric / COUNT(*), 4) AS response_rate
FROM data
group by vehicle_damage
order by customer_count desc;


-- เปรียบเทียบลูกค้าที่มีและไม่มีประกันรถยนต์อยู่แล้ว
SELECT previously_insured,
       count(*) as customer_count,
	     sum(response) as interested_customers,
	     ROUND(SUM(response)::numeric / COUNT(*), 4) AS response_rate
FROM data
group by previously_insured
order by response_rate desc;


-- เปรียบเทียบอัตราตอบรับตามอายุรถ
SELECT vehicle_age,
       count(*) as customer_count,
	     sum(response) as interested_customers,
	     ROUND(SUM(response)::numeric / COUNT(*), 4) AS response_rate
FROM data
group by vehicle_age
order by response_rate desc;


-- ช่องทางขายที่มีอัตราตอบรับสูง โดยพิจารณาเฉพาะช่องทางที่มีลูกค้าอย่างน้อย 500 คน
SELECT policy_sales_channel,
       count(*) as customer_count,
	     sum(response) as interested_customers,
	     ROUND(SUM(response)::numeric / COUNT(*), 4) AS response_rate
FROM data
group by policy_sales_channel
having count(*) >= 500
order by response_rate desc;

-- สัดส่วนผู้สนใจที่มาจาก 5 ช่องทางขายที่มีผู้สนใจมากที่สุด
WITH channel_response AS (
  SELECT policy_sales_channel,
         SUM(response) AS interested_customers
  FROM data
  GROUP BY policy_sales_channel
),
ranked AS (
  SELECT *,
         RANK() OVER (ORDER BY interested_customers DESC) AS channel_rank
  FROM channel_response
)

SELECT SUM(interested_customers) AS top5_responded,
       (SELECT SUM(response) FROM data) AS total_responded,
       ROUND(SUM(interested_customers) * 100.0 / (SELECT SUM(response) FROM data), 2) AS top5_share_pct
FROM ranked
WHERE channel_rank <= 5;

-- เบี้ยประกันสุขภาพเฉลี่ยของกลุ่มที่สนใจและไม่สนใจประกันรถยนต์
SELECT response,
       round(avg(annual_premium)::numeric, 2) as avg_annual_premium
FROM data
group by response;

-- เบี้ยประกันสุขภาพเฉลี่ยตามกลุ่มอายุ
SELECT age_band,
       count(*) as customer_count,
       round(avg(annual_premium)::numeric, 2) as avg_annual_premium
FROM data
group by age_band
order by avg_annual_premium desc;

-- เบี้ยประกันสุขภาพเฉลี่ยตามภูมิภาค
SELECT region_code,
       count(*) as customer_count,
       round(avg(annual_premium)::numeric, 2) as avg_annual_premium
FROM data
group by region_code
order by avg_annual_premium desc;

-- อัตราตอบรับตามระยะเวลาที่เป็นลูกค้า
SELECT vintage_band,
       count(*) as customer_count,
       sum(response) as interested_customers,
       ROUND(SUM(response)::numeric / COUNT(*), 4) AS response_rate
FROM data
group by vintage_band;


