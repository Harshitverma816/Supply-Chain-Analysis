-- Supply Chain Data Analysis SQL Queries

-- 1. Total Revenue by Product type
select  product_type , sum(revenue_generated) as total_revenue 
from supply_chain_data
group by product_type 
order by total_revenue desc;

-- 2. Inventory Health (Stock − Order Quantity)
select  sku,
		    product_type , 
        stock_levels,
        order_quantities,
        (stock_levels - order_quantities) as inventory_health 
from supply_chain_data 
order by inventory_health desc;

-- 3. Shipping Time by Transportation Mode
select  transportation_modes, 
        avg(shipping_times) as avg_shipping_time  
from supply_chain_data 
group by transportation_modes
order by avg_shipping_time;

-- 4. Defect Rate Analysis
select product_type, 
		    avg(defect_rates) as avg_defect_rate 
from supply_chain_data 
group by product_type
order by avg_defect_rate;

-- 5. Route Cost Comparison
select routes, 
		    avg(costs) as avg_cost 
from supply_chain_data 
group by routes
order by avg_cost desc;

-- 6. Manufacturing Lead Time Summary
select product_type, 
		    avg(manufacturing_lead_time) as avg_mfg_lead_time 
from supply_chain_data 
group by product_type;

-- 7. Top Selling Products
select sku,
		    product_type, 
        number_of_products_sold 
from supply_chain_data 
order by number_of_products_sold desc 
limit 10;

-- 8. Defect Rate vs Manufacturing Cost
select sku,
		    defect_rates,
		    manufacturing_costs, 
        revenue_generated 
from supply_chain_data 
order by defect_rates desc;

-- 9. TOP 10 most profitable products
select sku,
		    product_type, 
        revenue_generated - (manufacturing_costs * number_of_products_sold) as profit 
from supply_chain_data 
order by profit desc 
limit 10;

-- 10. shipping performance score
select transportation_modes,
		avg(shipping_times) as avg_shipping_time,
        rank() over (order by avg(shipping_times)) as speed_rank  
from supply_chain_data 
group by transportation_modes
order by avg_shipping_time;

-- 11. route cost efficiency index
select routes,
		avg(costs) as avg_cost,
		avg(shipping_times) as avg_time,
        (avg(costs) / avg(shipping_times)) as cost_efficiency_score   
from supply_chain_data 
group by routes
order by cost_efficiency_score asc;

-- 12. Manufacturing cost vs selling price gap
select sku,
		price,
        manufacturing_costs,
        (price - manufacturing_costs) as margin, 
		case
        	when (price - manufacturing_costs) < 0 then "Loss"
            when (price - manufacturing_costs) < (0.10 * price) then "Low Margin"
            else "Healthy Margin"
        end as margin_category 
from supply_chain_data
order by margin asc;

-- 13. Transportation mode performance score
select transportation_modes,
		    avg(costs) as avg_cost,
        avg(shipping_times) as avg_time,
        (avg(costs) * 0.6 + avg(shipping_times) * 0.4) as performance_score 
from supply_chain_data 
group by transportation_modes 
order by performance_score asc; 

-- 14. Rank products by Revenue + show % contribution
select sku,
		product_type,
    	revenue_generated,
    	rank() OVER (order by revenue_generated desc) as revenue_rank,
    	round(100 * revenue_generated / sum(revenue_generated) over (), 2) as revenue_percentage
from supply_chain_data
order by revenue_generated desc;

-- 15. Top Leas Time analysis using CTE
with lead as (
    select 
        sku,
        product_type,
        lead_times + manufacturing_lead_time as total_lead_time
    from supply_chain_data
)
select 
    product_type,
    avg(total_lead_time) as avg_total_lead_time,
    min(total_lead_time) as min_lead_time,
    max(total_lead_time) as max_lead_time
from lead
group by product_type
order by avg_total_lead_time desc;


-- 16. Inventory Risk Classification (High priority items)
select
    sku,
    product_type,
    stock_levels,
    order_quantities,
    case 
        when stock_levels < order_quantities then 'STOCKOUT RISK'
        when stock_levels = order_quantities then 'CRITICAL – REORDER NOW'
        when stock_levels > order_quantities * 2 then 'Excess Stock'
        else 'Healthy Stock'
    end as inventory_status
from supply_chain_data
order by stock_levels - order_quantities asc;

-- 17. Full Supply Chain Score
select 
    sku,
    product_type,
    stock_levels,
    defect_rates,
    shipping_times,
    (stock_levels * 0.4) +
    ((10 - defect_rates) * 0.3) +
    ((20 - shipping_times) * 0.3) as supply_chain_score
from supply_chain_data
order by supply_chain_score desc;
