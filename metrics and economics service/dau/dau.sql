select time::date as date,
    count(distinct user_id) as DAU
from user_actions
group by date
order by 1