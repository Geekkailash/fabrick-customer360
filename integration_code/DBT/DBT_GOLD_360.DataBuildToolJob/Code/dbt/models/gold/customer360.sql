{{ config(
    materialized = 'table',
    schema = 'gold'
) }}

with customers as (
    select *
    from {{ source('silver', 'customer') }}
),

orders as (
    select *
    from {{ source('silver', 'orders') }}
),

payments as (
    select *
    from {{ source('silver', 'payments') }}
),

support as (
    select *
    from {{ source('silver', 'support') }}
),

web as (
    select *
    from {{ source('silver', 'web') }}
)

select
    c.customer_id,
    c.name,
    c.gender,
    c.email,
    c.dob,
    c.location,
    o.order_id,
    o.order_date,
    o.amount,
    o.status,
    p.payment_id,
    p.payment_date,
    p.payment_method,
    p.payment_status,
    s.ticket_id,
    s.issue_type,
    s.ticket_date,
    s.resolution_status,
    w.session_id,
    w.page_viewed,
    w.session_time,
    w.device_type
from customers c
left join orders o
    on c.customer_id = o.customer_id
left join payments p
    on c.customer_id = p.customer_id
left join support s
    on c.customer_id = s.customer_id
left join web w
    on c.customer_id = w.customer_id