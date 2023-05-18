with q1 as (
    select date, sum(price) as revenue
    from (
        select creation_time::date as date, order_id, unnest(product_ids) as product_id
        from orders
        where order_id not in (select order_id from user_actions where action='cancel_order')
    ) as t1 inner join products using(product_id)
    group by date
)
select date, revenue,
    sum(revenue) over(order by date) as total_revenue,
    round((revenue-lag(revenue) over(order by date))*100/lag(revenue) over(order by date)::decimal,2) as revenue_change
from q1