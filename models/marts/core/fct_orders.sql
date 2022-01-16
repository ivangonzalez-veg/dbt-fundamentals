
with payments as (
    select * from {{ref('stg_payments')}}
),
orders as(
    select * from {{ref('stg_orders')}}
),
final as (
    select orders.order_id, orders.customer_id, payments.amount
    from orders inner join payments on orders.order_id = payments.orderid
)
select * from final