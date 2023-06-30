select date_trunc('month', time) as date,
    count(distinct user_id) as MAU
from user_actions
group by date
order by 1