with q1 as(
    select order_id, user_id, time, product_id, price
    from ( -- join not canceled orders with products
        select t.order_id, t.user_id, t.time, unnest(product_ids) as product_id
        from ( -- select not canceled orders
            select order_id, user_id, time
            from user_actions
            where order_id not in (select order_id from user_actions where action='cancel_order')
        ) as t left join orders using(order_id)
    ) as t1 left join products using(product_id)
),
final_table as (
    select date, paying_user, count_orders, DAU, revenue
    from (
        select date, count(distinct user_id) as paying_user, count(order_id) as count_orders, sum(price) as revenue
        from (
            select order_id, min(user_id) as user_id, min(time::date) as date, sum(price) as price
            from q1
            group by order_id
        ) as t2
        group by date
    ) as t3 inner join (
        select time::date as date, count(distinct user_id) as dau
        from user_actions
        group by date
    ) as t4 using(date)
) 

select date, 
    round(revenue/dau::decimal,2) as ARPU,
    round(revenue/paying_user::decimal,2) as ARPPU,
    round(revenue/count_orders::decimal,2) as AOV
from final_table
order by 1


