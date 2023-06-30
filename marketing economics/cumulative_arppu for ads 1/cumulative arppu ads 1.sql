with company_1 as (
    select user_id, order_id, time::date as date, action
    from user_actions
    where user_id in (8631, 8632, 8638, 8643, 8657, 8673, 8706, 8707, 8715, 8723, 8732, 8739, 8741, 
                        8750, 8751, 8752, 8770, 8774, 8788, 8791, 8804, 8810, 8815, 8828, 8830, 8845, 
                        8853, 8859, 8867, 8869, 8876, 8879, 8883, 8896, 8909, 8911, 8933, 8940, 8972, 
                        8976, 8988, 8990, 9002, 9004, 9009, 9019, 9020, 9035, 9036, 9061, 9069, 9071, 
                        9075, 9081, 9085, 9089, 9108, 9113, 9144, 9145, 9146, 9162, 9165, 9167, 9175, 
                        9180, 9182, 9197, 9198, 9210, 9223, 9251, 9257, 9278, 9287, 9291, 9313, 9317, 
                        9321, 9334, 9351, 9391, 9398, 9414, 9420, 9422, 9431, 9450, 9451, 9454, 9472, 
                        9476, 9478, 9491, 9494, 9505, 9512, 9518, 9524, 9526, 9528, 9531, 9535, 9550, 
                        9559, 9561, 9562, 9599, 9603, 9605, 9611, 9612, 9615, 9625, 9633, 9652, 9654, 
                        9655, 9660, 9662, 9667, 9677, 9679, 9689, 9695, 9720, 9726, 9739, 9740, 9762, 
                        9778, 9786, 9794, 9804, 9810, 9813, 9818, 9828, 9831, 9836, 9838, 9845, 9871, 
                        9887, 9891, 9896, 9897, 9916, 9945, 9960, 9963, 9965, 9968, 9971, 9993, 9998, 
                        9999, 10001, 10013, 10016, 10023, 10030, 10051, 10057, 10064, 10082, 10103, 
                        10105, 10122, 10134, 10135)
            and order_id not in (select order_id from user_actions where action='cancel_order')
)

select 'Кампания № 1' as ads_campaign,
    concat('Day ',(date_part('day',date)-1)::text) as day,
    round(sum(arppu) over(order by date),2) as cumulative_arppu,
    round(250000.0/(select count(distinct user_id) from company_1),2) as cac
from (
    select date, sum(price) / (select count(distinct user_id) from company_1)::decimal as arppu
    from (
        select min(user_id) as user_id, order_id, sum(price) as price, min(date) as date
        from (
            select user_id, company_1.order_id, unnest(product_ids) as product_id, date
            from company_1 left join orders using(order_id)
        ) as t1 left join products using(product_id)
        group by order_id
    ) as t2 
    group by date
) as t3

order by 1,2

