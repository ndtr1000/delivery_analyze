select date_trunc('week', time) as date,
    count(distinct user_id) as WAU
from user_actions
group by date
order by 1