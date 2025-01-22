
{{ config(
    materialized='incremental',
    unique_key='CLIENT_ID',
    incremental_strategy='delete+insert'
    ) 
}}

WITH SOURCE_DATA AS (
    SELECT B.CLIENT_ID, B.VALUE AS BREAD_VALUE, V.VALUE AS VEGETABLE_VALUE, M.VALUE AS MEAT_VALUE
    FROM {{ source('burger_input', 'bread') }} AS B
    INNER JOIN {{ source('burger_input', 'vegetable') }} AS V ON V.CLIENT_ID = B.CLIENT_ID
    INNER JOIN {{ source('burger_input', 'meat') }} AS M ON M.CLIENT_ID = B.CLIENT_ID
),
BURGER_DATA AS (
    SELECT CLIENT_ID, '🍔' AS VALUE
    FROM SOURCE_DATA
    WHERE BREAD_VALUE = '🍞' 
    AND VEGETABLE_VALUE = '🍅' 
    AND (MEAT_VALUE = '🥩' OR MEAT_VALUE = '🍗' OR MEAT_VALUE = '🐟')
),
OTHER_DATA AS (
    SELECT CLIENT_ID, BREAD_VALUE || ' + ' || VEGETABLE_VALUE || ' + ' || MEAT_VALUE AS VALUE
    FROM SOURCE_DATA
    WHERE NOT EXISTS (SELECT 1 FROM BURGER_DATA WHERE BURGER_DATA.CLIENT_ID = SOURCE_DATA.CLIENT_ID)
)

SELECT * FROM BURGER_DATA
UNION
SELECT * FROM OTHER_DATA
