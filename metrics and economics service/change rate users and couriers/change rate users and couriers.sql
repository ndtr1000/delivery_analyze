with info as (
    select date, new_users, new_couriers,
        sum(new_users) over(order by date)::int as total_users,
        sum(new_couriers) over(order by date)::int as total_couriers
    from (   
        select date, count(user_id) as new_users
        from (
            select user_id, min(time::date) as date
            from user_actions
            group by user_id
        ) as t1
        group by date
    ) as q1 inner join (
        select date, count(courier_id) as new_couriers
        from (
            select courier_id, min(time::date) as date
            from courier_actions
            group by courier_id
        ) as t2
        group by date
    ) as q2 using(date)
)

select date, new_users, new_couriers, total_users, total_couriers,
    round((new_users - lag(new_users) over(order by date))::decimal/lag(new_users) over(order by date)*100,2) as new_users_change,
    round((new_couriers - lag(new_couriers) over(order by date))::decimal/lag(new_couriers) over(order by date)*100,2) as new_couriers_change,
    round((total_users - lag(total_users) over(order by date))::decimal/lag(total_users) over(order by date)*100,2) as total_users_growth,
    round((total_couriers - lag(total_couriers) over(order by date))::decimal/lag(total_couriers) over(order by date)*100,2) as total_couriers_growth
from info
order by date


