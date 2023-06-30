with about_users as (
    select first_action_u as date, count(user_id) as new_users,
        (sum(count(user_id)) over(order by first_action_u))::int as total_users
    from (
        select user_id, min(time::date) as first_action_u
        from user_actions
        group by user_id
    ) as t1
    group by first_action_u
),
about_couriers as (
    select first_action_c as date, count(courier_id) as new_couriers,
        (sum(count(courier_id)) over(order by first_action_c))::int as total_couriers
    from (
        select courier_id, min(time::date) as first_action_c
        from courier_actions
        group by courier_id
    ) as t2
    group by first_action_c
)

select date, new_users, new_couriers, total_users, total_couriers
from about_users inner join about_couriers using(date)
order by 1
