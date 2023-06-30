with order_info as (
    select date, sum(price) as revenue, sum(tax) as tax, count(distinct order_id) as accepted_orders
    from (
        select t1.order_id, name, price, 
            case when name in ('сахар', 'сухарики', 'сушки', 'семечки', 
                                'масло льняное', 'виноград', 'масло оливковое', 
                                'арбуз', 'батон', 'йогурт', 'сливки', 'гречка', 
                                'овсянка', 'макароны', 'баранина', 'апельсины', 
                                'бублики', 'хлеб', 'горох', 'сметана', 'рыба копченая', 
                                'мука', 'шпроты', 'сосиски', 'свинина', 'рис', 
                                'масло кунжутное', 'сгущенка', 'ананас', 'говядина', 
                                'соль', 'рыба вяленая', 'масло подсолнечное', 'яблоки', 
                                'груши', 'лепешка', 'молоко', 'курица', 'лаваш', 'вафли', 'мандарины')
                            then round(price*10/110,2)
                            else round(price*20/120,2)
            end as tax,
            date
        from (
            select order_id, unnest(product_ids) as product_id, creation_time::date as date
            from orders
            where order_id not in (select order_id from user_actions where action='cancel_order')
        ) as t1 left join products using(product_id)
    ) as t3
    group by date
),
courier_info as (
    select date, sum(delivered) as delivered_orders,
        count(courier_id) filter(where delivered >= 5) as yes_bonus
    from (
        select time::date as date, courier_id, count(distinct order_id) as delivered
        from courier_actions
        where order_id not in (select order_id from user_actions where action='cancel_order') and action='deliver_order'
        group by date, courier_id
    ) as t2
    group by date
)

select date, revenue, costs, tax,
    -(costs+tax)+revenue as gross_profit,
    sum(revenue) over(order by date) as total_revenue,
    sum(costs) over(order by date) as total_costs,
    sum(tax) over(order by date) as total_tax,
    sum(revenue-(costs+tax)) over(order by date) as total_gross_profit,
    round((revenue-(costs+tax))*100/revenue::decimal,2) as gross_profit_ratio,
    round(sum(revenue-(costs+tax)) over(order by date)*100/sum(revenue) over(order by date)::decimal,2) as total_gross_profit_ratio
from (
    select date, revenue,
        case 
            when date_part('month',date)=8 then 120000+(accepted_orders*140)+(delivered_orders*150)+(yes_bonus*400)
            else 150000+(accepted_orders*115)+(delivered_orders*150)+(yes_bonus*500)
        end as costs,
        tax
    from order_info inner join courier_info using(date)
    order by date
) as t5
order by date


