{\rtf1\ansi\ansicpg1251\cocoartf2636
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\pardirnatural\partightenfactor0

\f0\fs24 \cf0 select date_trunc('month', first_action)::date as start_month,\
    first_action as start_date,\
    action - first_action as day_number,\
    round(rt::decimal/max(rt) over(partition by first_action),2) as retention\
from (\
    select first_action, action, count(user_id) as rt\
    from (\
        select distinct user_id, \
            min(time::date) over(partition by user_id) as first_action,\
            time::date as action\
        from user_actions\
    ) as t1\
    group by first_action, action\
    order by 1, 2\
) as t2}