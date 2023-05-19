select date_trunc('month', first_action)::date as start_month,
    first_action as start_date,
    action - first_action as day_number,
    round(rt::decimal/max(rt) over(partition by first_action),2) as retention
from (
    select first_action, action, count(user_id) as rt
    from (
        select distinct user_id, 
            min(time::date) over(partition by user_id) as first_action,
            time::date as action
        from user_actions
    ) as t1
    group by first_action, action
    order by 1, 2
) as t2

