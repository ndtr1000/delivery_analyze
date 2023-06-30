select hour::int, successful_orders, canceled_orders,
    round(canceled_orders/(successful_orders+canceled_orders)::decimal,3) as cancel_rate
from (
    select date_part('hour', creation_time) as hour, count(order_id) as canceled_orders
    from orders
    where order_id in (select order_id from user_actions where action='cancel_order')
    group by hour
) as t1 inner join (
    select date_part('hour', creation_time) as hour, count(order_id) as successful_orders
    from orders
    where order_id not in (select order_id from user_actions where action='cancel_order')
    group by hour
) as t2 using(hour)
order by hour



