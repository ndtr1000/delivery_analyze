with orders_and_paying_users as (
    select date_part('isodow', time) as date, count(order_id) as orders, 
        count(distinct user_id) as paying_users
    from user_actions
    where time between '2022-08-26' and '2022-09-09' 
        and order_id not in (select order_id from user_actions where action='cancel_order')
    group by date
),
dau as (
    select date_part('isodow', time) as date, count(distinct user_id) as users
    from user_actions
    where time between '2022-08-26' and '2022-09-09' 
    group by date
),
table_revenue as (
    select date, sum(price) as revenue
    from (
        select date_part('isodow', creation_time) as date, unnest(product_ids) as product_id
        from orders
        where creation_time between '2022-08-26' and '2022-09-09' 
            and order_id not in (select order_id from user_actions where action='cancel_order')
    ) as t1 left join products using(product_id)
    group by date
),
name_of_day as (
    select to_char(time,'Day') as weekday,
        min(date_part('isodow', time)) as date
    from user_actions
    where time between '2022-08-26' and '2022-09-09'
    group by weekday
)

select 
    weekday,
    t2.date as weekday_number, 
    round(revenue/users::decimal,2) as arpu,
    round(revenue/paying_users::decimal,2) as arppu,
    round(revenue/orders::decimal,2) as aov
from (
    select date, orders, users, paying_users, revenue
    from orders_and_paying_users join dau using(date) join table_revenue using(date) 
) as t2 left join name_of_day using(date)
order by 2

