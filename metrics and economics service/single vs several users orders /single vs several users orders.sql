with q1 as (
    select time::date as date, user_id, count(order_id) as count
    from user_actions
    where order_id not in (select order_id from user_actions where action='cancel_order')
    group by date, user_id
    order by 1, 2
)

select date,
    round(single_users::decimal/(single_users+several_users)*100,2) as single_order_users_share,
    round(several_users::decimal/(single_users+several_users)*100,2) as several_orders_users_share
from (
    select date, 
        count(distinct user_id) filter(where count=1) as single_users,
        count(distinct user_id) filter(where count>1) as several_users
    from q1
    group by date
) as t1