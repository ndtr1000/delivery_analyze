with q1 as (
    select name, revenue,
        round(revenue*100/sum(revenue) over()::decimal,2) as share_in_revenue
    from (
        select name, sum(price) as revenue
        from (
            select order_id, unnest(product_ids) as product_id
            from orders
            where order_id not in (select order_id from user_actions where action='cancel_order')
        ) as t1 left join products using(product_id)
        group by name
    ) as t2
)

select product_name, sum(revenue) as revenue, sum(share_in_revenue) as share_in_revenue
from (
    select 
        case when share_in_revenue<0.5 then 'ДРУГОЕ' 
            else name 
        end as product_name,
        revenue, share_in_revenue
    from q1
) as t3
group by product_name
order by revenue desc
