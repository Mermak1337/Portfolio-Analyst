CREATE SCHEMA IF NOT EXISTS analytics;

DROP VIEW IF EXISTS analytics.monthly_sales_summary;
DROP TABLE IF EXISTS analytics.orders;
DROP TABLE IF EXISTS analytics.customers;
DROP TABLE IF EXISTS analytics.products;
DROP TABLE IF EXISTS analytics.sales_targets;

CREATE TABLE analytics.customers (
    customer_id BIGSERIAL PRIMARY KEY,
    customer_name VARCHAR(200) NOT NULL,
    customer_segment VARCHAR(30) NOT NULL CHECK (customer_segment IN ('Малый бизнес', 'Крупный бизнес', 'Госсектор')),
    industry VARCHAR(100) NOT NULL,
    region VARCHAR(100) NOT NULL,
    registration_date DATE NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE analytics.products (
    product_id BIGSERIAL PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    product_category VARCHAR(100) NOT NULL,
    license_type VARCHAR(30) NOT NULL CHECK (license_type IN ('Подписка', 'Бессрочная лицензия')),
    standard_price NUMERIC(14, 2) NOT NULL CHECK (standard_price >= 0),
    cogs_rate NUMERIC(5, 4) NOT NULL CHECK (cogs_rate BETWEEN 0 AND 1)
);

CREATE TABLE analytics.orders (
    order_id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL REFERENCES analytics.customers(customer_id),
    product_id BIGINT NOT NULL REFERENCES analytics.products(product_id),
    order_date DATE NOT NULL,
    sales_channel VARCHAR(50) NOT NULL CHECK (sales_channel IN ('Прямые продажи', 'Партнёрский канал', 'Тендер', 'Онлайн-продажи')),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    discount_rate NUMERIC(5, 4) NOT NULL CHECK (discount_rate BETWEEN 0 AND 1),
    status VARCHAR(30) NOT NULL CHECK (status IN ('Завершена', 'В работе', 'Отменена', 'Возвращена')),
    payment_status VARCHAR(30) NOT NULL CHECK (payment_status IN ('Оплачен', 'Ожидает оплаты', 'Просрочен'))
);

CREATE TABLE analytics.sales_targets (
    target_month DATE PRIMARY KEY,
    target_revenue NUMERIC(16, 2) NOT NULL CHECK (target_revenue >= 0),
    target_orders INTEGER NOT NULL CHECK (target_orders >= 0)
);

INSERT INTO analytics.customers
(customer_name, customer_segment, industry, region, registration_date)
VALUES
('Северный банк', 'Крупный бизнес', 'Финансы', 'Москва', '2024-02-15'),
('Вектор-Телеком', 'Крупный бизнес', 'ИТ и телеком', 'Санкт-Петербург', '2024-04-10'),
('Ритейл-Сервис', 'Малый бизнес', 'Ритейл', 'Москва', '2024-05-21'),
('Городская клиника', 'Госсектор', 'Здравоохранение', 'Казань', '2024-06-05'),
('УралПром', 'Крупный бизнес', 'Промышленность', 'Екатеринбург', '2024-08-17'),
('Образование плюс', 'Госсектор', 'Образование', 'Новосибирск', '2024-09-12');

INSERT INTO analytics.products
(product_name, product_category, license_type, standard_price, cogs_rate)
VALUES
('Защита рабочих станций Стандарт', 'Защита рабочих станций', 'Подписка', 8500.00, 0.2400),
('Защита рабочих станций Расширенный', 'Защита рабочих станций', 'Подписка', 12500.00, 0.2700),
('Промышленная кибербезопасность', 'Промышленная безопасность', 'Подписка', 26500.00, 0.3500),
('Облачный центр безопасности', 'Облачная безопасность', 'Подписка', 6200.00, 0.1900),
('Защита от мошенничества', 'Защита от мошенничества', 'Подписка', 31000.00, 0.3100);

INSERT INTO analytics.sales_targets
(target_month, target_revenue, target_orders)
VALUES
('2026-01-01', 18000000.00, 24),
('2026-02-01', 19500000.00, 26),
('2026-03-01', 21000000.00, 28),
('2026-04-01', 22000000.00, 30),
('2026-05-01', 23500000.00, 31),
('2026-06-01', 25000000.00, 33);

INSERT INTO analytics.orders
(customer_id, product_id, order_date, sales_channel, quantity, discount_rate, status, payment_status)
VALUES
(1, 2, '2026-01-12', 'Прямые продажи', 420, 0.08, 'Завершена', 'Оплачен'),
(2, 4, '2026-01-18', 'Партнёрский канал', 600, 0.05, 'Завершена', 'Оплачен'),
(3, 1, '2026-02-03', 'Онлайн-продажи', 85, 0.03, 'Завершена', 'Оплачен'),
(4, 5, '2026-02-19', 'Тендер', 120, 0.10, 'Завершена', 'Ожидает оплаты'),
(5, 3, '2026-03-07', 'Прямые продажи', 300, 0.12, 'Завершена', 'Оплачен'),
(6, 4, '2026-03-22', 'Тендер', 250, 0.05, 'В работе', 'Ожидает оплаты'),
(1, 5, '2026-04-11', 'Прямые продажи', 75, 0.07, 'Завершена', 'Оплачен'),
(2, 2, '2026-04-26', 'Партнёрский канал', 190, 0.06, 'Завершена', 'Просрочен'),
(3, 1, '2026-05-09', 'Онлайн-продажи', 140, 0.02, 'Завершена', 'Оплачен'),
(4, 4, '2026-05-15', 'Тендер', 450, 0.09, 'Завершена', 'Оплачен'),
(5, 3, '2026-06-02', 'Прямые продажи', 380, 0.11, 'Завершена', 'Ожидает оплаты'),
(6, 1, '2026-06-21', 'Партнёрский канал', 110, 0.04, 'Отменена', 'Ожидает оплаты');

CREATE OR REPLACE VIEW analytics.order_economics AS
SELECT
    o.order_id,
    o.order_date,
    DATE_TRUNC('month', o.order_date)::DATE AS order_month,
    c.customer_id,
    c.customer_name,
    c.customer_segment,
    c.industry,
    c.region,
    p.product_id,
    p.product_name,
    p.product_category,
    o.sales_channel,
    o.quantity,
    o.discount_rate,
    o.status,
    o.payment_status,
    ROUND(p.standard_price * o.quantity, 2) AS gross_revenue,
    ROUND(p.standard_price * o.quantity * (1 - o.discount_rate), 2) AS net_revenue,
    ROUND(p.standard_price * o.quantity * (1 - o.discount_rate) * p.cogs_rate, 2) AS cogs,
    ROUND(p.standard_price * o.quantity * (1 - o.discount_rate) * (1 - p.cogs_rate), 2) AS gross_profit,
    ROUND(1 - p.cogs_rate, 4) AS gross_margin
FROM analytics.orders o
JOIN analytics.customers c ON c.customer_id = o.customer_id
JOIN analytics.products p ON p.product_id = o.product_id;

SELECT
    order_month,
    SUM(net_revenue) FILTER (WHERE status = 'Завершена') AS net_revenue,
    SUM(gross_profit) FILTER (WHERE status = 'Завершена') AS gross_profit,
    ROUND(SUM(gross_profit) FILTER (WHERE status = 'Завершена') / NULLIF(SUM(net_revenue) FILTER (WHERE status = 'Завершена'), 0), 4) AS gross_margin,
    COUNT(*) FILTER (WHERE status = 'Завершена') AS completed_orders
FROM analytics.order_economics
GROUP BY order_month
ORDER BY order_month;

SELECT
    region,
    customer_segment,
    COUNT(DISTINCT customer_id) AS customers,
    COUNT(*) FILTER (WHERE status = 'Завершена') AS completed_orders,
    SUM(net_revenue) FILTER (WHERE status = 'Завершена') AS net_revenue,
    ROUND(AVG(net_revenue) FILTER (WHERE status = 'Завершена'), 2) AS average_order_value
FROM analytics.order_economics
GROUP BY region, customer_segment
ORDER BY net_revenue DESC;

SELECT
    sales_channel,
    SUM(net_revenue) FILTER (WHERE status = 'Завершена') AS net_revenue,
    SUM(gross_profit) FILTER (WHERE status = 'Завершена') AS gross_profit,
    ROUND(SUM(gross_profit) FILTER (WHERE status = 'Завершена') / NULLIF(SUM(net_revenue) FILTER (WHERE status = 'Завершена'), 0), 4) AS gross_margin,
    COUNT(*) AS total_orders,
    COUNT(*) FILTER (WHERE status = 'Завершена') AS completed_orders
FROM analytics.order_economics
GROUP BY sales_channel
ORDER BY net_revenue DESC;

WITH monthly_revenue AS (
    SELECT
        order_month,
        SUM(net_revenue) FILTER (WHERE status = 'Завершена') AS revenue
    FROM analytics.order_economics
    GROUP BY order_month
)
SELECT
    order_month,
    revenue,
    LAG(revenue) OVER (ORDER BY order_month) AS previous_month_revenue,
    revenue - LAG(revenue) OVER (ORDER BY order_month) AS revenue_change,
    ROUND((revenue / NULLIF(LAG(revenue) OVER (ORDER BY order_month), 0) - 1)::NUMERIC, 4) AS revenue_growth_rate
FROM monthly_revenue
ORDER BY order_month;

WITH actuals AS (
    SELECT
        order_month,
        SUM(net_revenue) FILTER (WHERE status = 'Завершена') AS actual_revenue,
        COUNT(*) FILTER (WHERE status = 'Завершена') AS actual_orders
    FROM analytics.order_economics
    GROUP BY order_month
)
SELECT
    t.target_month,
    COALESCE(a.actual_revenue, 0) AS actual_revenue,
    t.target_revenue,
    COALESCE(a.actual_revenue, 0) - t.target_revenue AS revenue_variance,
    ROUND(COALESCE(a.actual_revenue, 0) / NULLIF(t.target_revenue, 0), 4) AS target_achievement_rate,
    COALESCE(a.actual_orders, 0) AS actual_orders,
    t.target_orders
FROM analytics.sales_targets t
LEFT JOIN actuals a ON a.order_month = t.target_month
ORDER BY t.target_month;

SELECT
    product_name,
    product_category,
    SUM(net_revenue) FILTER (WHERE status = 'Завершена') AS net_revenue,
    SUM(gross_profit) FILTER (WHERE status = 'Завершена') AS gross_profit,
    ROUND(SUM(gross_profit) FILTER (WHERE status = 'Завершена') / NULLIF(SUM(net_revenue) FILTER (WHERE status = 'Завершена'), 0), 4) AS gross_margin,
    RANK() OVER (ORDER BY SUM(net_revenue) FILTER (WHERE status = 'Завершена') DESC) AS revenue_rank
FROM analytics.order_economics
GROUP BY product_name, product_category
ORDER BY revenue_rank;

SELECT
    customer_id,
    customer_name,
    customer_segment,
    region,
    COUNT(*) FILTER (WHERE status = 'Завершена') AS completed_orders,
    SUM(net_revenue) FILTER (WHERE status = 'Завершена') AS lifetime_value,
    MAX(order_date) FILTER (WHERE status = 'Завершена') AS last_order_date,
    CURRENT_DATE - MAX(order_date) FILTER (WHERE status = 'Завершена') AS days_since_last_order,
    CASE
        WHEN MAX(order_date) FILTER (WHERE status = 'Завершена') IS NULL THEN 'Нет завершённых заказов'
        WHEN CURRENT_DATE - MAX(order_date) FILTER (WHERE status = 'Завершена') <= 90 THEN 'Активный'
        WHEN CURRENT_DATE - MAX(order_date) FILTER (WHERE status = 'Завершена') <= 180 THEN 'Под риском оттока'
        ELSE 'Ушедший клиент'
    END AS customer_status
FROM analytics.order_economics
GROUP BY customer_id, customer_name, customer_segment, region
ORDER BY lifetime_value DESC NULLS LAST;

SELECT
    payment_status,
    COUNT(*) AS order_count,
    SUM(net_revenue) AS net_revenue,
    ROUND(SUM(net_revenue) / NULLIF(SUM(SUM(net_revenue)) OVER (), 0), 4) AS revenue_share
FROM analytics.order_economics
WHERE status <> 'Отменена'
GROUP BY payment_status
ORDER BY net_revenue DESC;

SELECT
    order_id,
    customer_name,
    order_date,
    sales_channel,
    net_revenue,
    status,
    payment_status
FROM analytics.order_economics
WHERE status IN ('В работе', 'Возвращена')
   OR payment_status = 'Просрочен'
ORDER BY order_date;

SELECT
    customer_segment,
    product_category,
    SUM(net_revenue) FILTER (WHERE status = 'Завершена') AS net_revenue,
    ROUND(AVG(discount_rate), 4) AS average_discount_rate,
    ROUND(AVG(gross_margin), 4) AS average_gross_margin
FROM analytics.order_economics
GROUP BY GROUPING SETS ((customer_segment, product_category), (customer_segment), (product_category), ())
ORDER BY customer_segment NULLS LAST, product_category NULLS LAST;

SELECT
    order_month,
    sales_channel,
    SUM(net_revenue) FILTER (WHERE status = 'Завершена') AS net_revenue,
    SUM(SUM(net_revenue) FILTER (WHERE status = 'Завершена')) OVER (PARTITION BY order_month) AS monthly_revenue,
    ROUND(SUM(net_revenue) FILTER (WHERE status = 'Завершена') / NULLIF(SUM(SUM(net_revenue) FILTER (WHERE status = 'Завершена')) OVER (PARTITION BY order_month), 0), 4) AS channel_share
FROM analytics.order_economics
GROUP BY order_month, sales_channel
ORDER BY order_month, net_revenue DESC;

SELECT
    COUNT(*) AS total_orders,
    COUNT(*) FILTER (WHERE order_id IS NULL) AS missing_order_id,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS missing_customer_id,
    COUNT(*) FILTER (WHERE product_id IS NULL) AS missing_product_id,
    COUNT(*) FILTER (WHERE net_revenue < 0) AS negative_revenue,
    COUNT(*) FILTER (WHERE discount_rate NOT BETWEEN 0 AND 1) AS invalid_discount_rate,
    COUNT(DISTINCT order_id) AS unique_orders
FROM analytics.order_economics;

SELECT
    order_month,
    sales_channel,
    SUM(net_revenue) FILTER (WHERE status = 'Завершена') AS net_revenue,
    NTILE(4) OVER (PARTITION BY order_month ORDER BY SUM(net_revenue) FILTER (WHERE status = 'Завершена') DESC) AS channel_revenue_quartile
FROM analytics.order_economics
GROUP BY order_month, sales_channel
ORDER BY order_month, channel_revenue_quartile;
