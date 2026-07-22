block-level on error undo, throw.
define input parameter p-min as integer.
define input parameter p-max as integer.
if p-min > p-max then
do:
    message "Не правильно введен диапазон" view-as alert-box.
    return.
end.
define variable prod_i as integer.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define temp-table tt-range like code-range.
find first code-range where code-range.range-type =  'sclc':U and code-range.first-code =  p-min  no-error.
if not available code-range then
do:
    message "Диапазона для данных параметров не существует" view-as alert-box.
    return.
end.
find first code-range where code-range.range-type =  'sclc':U and code-range.last-code =  p-max  no-error.
if not available code-range then
do:
    message "Диапазона для данных параметров не существует" view-as alert-box.
    return.
end.
do prod_i  = p-min to p-max :
    find first  prod-bc no-lock where prod-bc.b-str = string(prod_i,"99999") no-error.
    find  first tt-range where tt-range.range-type =  'sclc':U and tt-range.last-code = prod_i - 1 no-error.
    if (available tt-range and tt-range.stts = "u")  and  available prod-bc then tt-range.last-code = prod_i .
    else   if ((available tt-range and tt-range.stts = "u") or not available tt-range) and not available prod-bc then
        do:
            create tt-range.
            assign
                tt-range.stts       = "f"
                tt-range.first-code = prod_i
                tt-range.last-code  = prod_i
                tt-range.range-type = 'sclc':U.
        end.
        else  if  (available tt-range and tt-range.stts = "f")  and not available prod-bc then tt-range.last-code = prod_i.
            else if ((available tt-range and tt-range.stts = "f") or not available tt-range) and  available prod-bc then
                do:
                    create tt-range.
                    assign
                        tt-range.stts       = "u"
                        tt-range.first-code = prod_i
                        tt-range.last-code  = prod_i
                        tt-range.range-type = 'sclc':U.
                end.
end.
disable triggers for load of code-range.
output to c:/temp/code-range.txt.
for each code-range where code-range.first-code >= p-min and code-range.last-code <= p-max and code-range.range-type = 'sclc':U  and  code-range.db-num = g#db-num :
    export code-range.
    delete code-range.
end.
output close.
output to c:/temp/core-tt.txt.
for each tt-range :
    create code-range.
    assign
        code-range.first-code = tt-range.first-code
        code-range.last-code  = tt-range.last-code
        code-range.db-num     = g#db-num
        code-range.beg-date   = today
        code-range.stts       = tt-range.stts
        code-range.range-type = tt-range.range-type.
    export tt-range.
end.
output close.
