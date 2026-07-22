define {1} shared temp-table tt-zakaz like ub.order-line 
    field gds-name          as character
    field minZapas          as decimal
    field volMinZapas       as integer
    field ostatokDay        as decimal
    field qntyDaySale       as integer
    field qntyDayGoods      as integer
    field ostatokGoods      as decimal
    field qntyDay           as integer
    field contract-prn-code as character
    field contract-code     as integer
    index pi    gds-code          contract-code
    index artic artic             prod-type         prod-code 
    index contr contract-prn-code.

define {1} shared temp-table temp-gds-qnty no-undo
    field day      as date
    field ost      as decimal
    field gds-code as integer
    index pi is unique primary day gds-code
    index by-ost               ost .
  