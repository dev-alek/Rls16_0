block-level on error undo, throw.
{ cmp/str-glbl.i }
{ gbl/thbjattr.i }
{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ nws/lib-nws.i }
define variable v-value-character   as character no-undo .
define variable v-value-decimal     as decimal   no-undo .
define variable v-value-integer     as integer   no-undo .
define variable v-value-logical     as logical   no-undo .
define variable v-value-type        as character no-undo .
define variable v-value-date        as date      no-undo .
define variable v-ext-sys           as integer   no-undo .

define variable v-recid as recid no-undo .
define variable v-recid-list as longchar no-undo .
define variable v-prod  as character no-undo .


define stream str-ext .
define temp-table tt-ext-classif like ub.ext-classif .

run adm/shattri.p (
       input "get":U
      ,input '':U
      ,input 0
      ,input {&attr-egais-host}
      ,input {&attr-egais-host_egais-exsys}
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
assign v-ext-sys = v-value-integer .

output stream str-ext to value ("ext-classif_egais_backup_.d") append .
put stream str-ext unformatted "Начало выгрузки - " string(today) + "   " + string(time, "hh:mm:ss") skip .
for each  ext-classif exclusive-lock
    where ext-classif.classif-subject = 'goods'
      and ext-classif.classif-name = 'exp-esys-gds-code'
      and ext-classif.db-num = 0
      and ext-classif.key#_two = v-ext-sys
      and ext-classif.charkey_two <> ""
      and ext-classif.charkey_three <> "" :
    export stream str-ext delimiter ';' ext-classif .
    find first ext-classif-attr no-lock where ext-classif-attr.classif-subject = ext-classif.classif-subject
      and ext-classif-attr.classif-name = ext-classif.classif-name
      and ext-classif-attr.db-num = ext-classif.db-num
      and ext-classif-attr.Key#_One = ext-classif.key#_one
      and ext-classif-attr.Key#_two = ext-classif.key#_two
      and ext-classif-attr.Key#_three = ext-classif.key#_three
      and ext-classif-attr.CharKey_One = ext-classif.charkey_one
      and ext-classif-attr.CharKey_two = ext-classif.charkey_two
      and ext-classif-attr.CharKey_three = ext-classif.charkey_three
      and ext-classif-attr.nonunique = ext-classif.nonunique
      and ext-classif-attr.attr-code = 'egais-info'
      no-error .
    if available  ext-classif-attr then do :
        export stream str-ext delimiter ';' ext-classif-attr .
        assign 
            ext-classif.charkey_two = ""
            ext-classif.charkey_three = ""
        no-error .
    end.
    else put stream str-ext unformatted skip .
end.
put stream str-ext unformatted "Конец выгрузки - " string(today) + "   " + string(time, "hh:mm:ss") skip skip .
output stream str-ext close .

/* бэкап в файл и перенос во временную таблицу */
output stream str-ext to value ("ext-classif_egais_backup.d") append .
put stream str-ext unformatted "Начало выгрузки - " string(today) + "   " + string(time, "hh:mm:ss") skip .
for each  ext-classif no-lock
    where ext-classif.classif-subject = 'goods'
      and ext-classif.classif-name = 'exp-esys-gds-code'
      and ext-classif.db-num = 0
      and ext-classif.key#_two = v-ext-sys :
    export stream str-ext delimiter ';' ext-classif .
    find first ext-classif-attr no-lock where ext-classif-attr.classif-subject = ext-classif.classif-subject
      and ext-classif-attr.classif-name = ext-classif.classif-name
      and ext-classif-attr.db-num = ext-classif.db-num
      and ext-classif-attr.Key#_One = ext-classif.key#_one
      and ext-classif-attr.Key#_two = ext-classif.key#_two
      and ext-classif-attr.Key#_three = ext-classif.key#_three
      and ext-classif-attr.CharKey_One = ext-classif.charkey_one
      and ext-classif-attr.CharKey_two = ext-classif.charkey_two
      and ext-classif-attr.CharKey_three = ext-classif.charkey_three
      and ext-classif-attr.nonunique = ext-classif.nonunique
      and ext-classif-attr.attr-code = 'egais-info'
      no-error .
    if available  ext-classif-attr then next .
    create tt-ext-classif .
    buffer-copy ext-classif to tt-ext-classif 
    assign tt-ext-classif.charkey_three = "" no-error .
end.
put stream str-ext unformatted "Конец выгрузки - " string(today) + "   " + string(time, "hh:mm:ss") skip skip .
output stream str-ext close .
/* удаление и отсылка в новости правильных записей */.
for each  ext-classif exclusive-lock
    where ext-classif.classif-subject = 'goods'
      and ext-classif.classif-name = 'exp-esys-gds-code'
      and ext-classif.db-num = 0
      and ext-classif.key#_two = v-ext-sys :
    find first ext-classif-attr exclusive-lock where ext-classif-attr.classif-subject = ext-classif.classif-subject
      and ext-classif-attr.classif-name = ext-classif.classif-name
      and ext-classif-attr.db-num = ext-classif.db-num
      and ext-classif-attr.Key#_One = ext-classif.key#_one
      and ext-classif-attr.Key#_two = ext-classif.key#_two
      and ext-classif-attr.Key#_three = ext-classif.key#_three
      and ext-classif-attr.CharKey_One = ext-classif.charkey_one
      and ext-classif-attr.CharKey_two = ext-classif.charkey_two
      and ext-classif-attr.CharKey_three = ext-classif.charkey_three
      and ext-classif-attr.nonunique = ext-classif.nonunique
      and ext-classif-attr.attr-code = 'egais-info'
      no-error .
    if available  ext-classif-attr then do :
        run str/callnews.p
          ( input {&table_ext-classif}
            ,input (buffer ext-classif:handle )
          ) .
        run str/callnews.p
          ( input {&table_ext-classif-attr}
            ,input (buffer ext-classif-attr:handle )
          ) .
        next .  
    end.      
    delete ext-classif .
end.
/* выделение записей, которые нужно оставить */
for each tt-ext-classif no-lock
        break by tt-ext-classif.key#_one by tt-ext-classif.charkey_one :
    if num-entries(tt-ext-classif.charkey_two, chr(4)) = 3
    and num-entries(entry(1,tt-ext-classif.charkey_two, chr(4)), chr(5)) = 6
    and num-entries(entry(2,tt-ext-classif.charkey_two, chr(4)), chr(5)) = 6
    then do :
        v-recid = recid(tt-ext-classif) .
    end.
    
    if not (num-entries(tt-ext-classif.charkey_two, chr(4)) = 3
    and num-entries(entry(1,tt-ext-classif.charkey_two, chr(4)), chr(5)) = 6
    and num-entries(entry(2,tt-ext-classif.charkey_two, chr(4)), chr(5)) = 6)
    and v-recid = ?
    then do :
        v-recid = recid(tt-ext-classif) .
    end.
    
    if last-of (tt-ext-classif.charkey_one) then do :
        v-recid-list = v-recid-list + chr(5) + string (v-recid).
        v-recid = ?.
    end.
end.
/* создание новых ext-classif и ext-classif-attr */
for each tt-ext-classif no-lock
        break by tt-ext-classif.key#_one by tt-ext-classif.charkey_one :
    if lookup (string(recid(tt-ext-classif)), v-recid-list, chr(5)) > 0 then do :
        create ext-classif.
        buffer-copy tt-ext-classif to ext-classif
        assign ext-classif.charkey_two = "" no-error .
        if error-status:error then next .
        create ext-classif-attr.
        buffer-copy ext-classif to ext-classif-attr
        assign ext-classif-attr.attr-code = 'egais-info' .
        
        if tt-ext-classif.charkey_two = ""
        then
        assign
            ext-classif-attr.attr-value = chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + 
                                          chr(4) +
                                          chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + 
                                          chr(4) 
        .
        
        else if num-entries(tt-ext-classif.charkey_two, chr(4)) = 3
        and num-entries(entry(1,tt-ext-classif.charkey_two, chr(4)), chr(5)) = 6
        and num-entries(entry(2,tt-ext-classif.charkey_two, chr(4)), chr(5)) = 6
        then 
        assign ext-classif-attr.attr-value = tt-ext-classif.charkey_two .
        
        else do :
            assign
                ext-classif-attr.attr-value = chr(4) + chr(4) 
            .
            /* Производитель */
            v-prod = chr(5) + chr(5) + chr(5) + chr(5) + chr(5) .
            assign /* regID */
               entry(1, v-prod, chr(5)) = entry(1, (entry(1, tt-ext-classif.charkey_two, chr(4))), chr(5))
            no-error.
            assign /* fullName */
               entry(4, v-prod, chr(5)) = entry(2, (entry(1, tt-ext-classif.charkey_two, chr(4))), chr(5))
            no-error.
            assign /* country */
               entry(5, v-prod, chr(5)) = entry(3, (entry(1, tt-ext-classif.charkey_two, chr(4))), chr(5))
            no-error.
            assign /* description */
               entry(6, v-prod, chr(5)) = entry(4, (entry(1, tt-ext-classif.charkey_two, chr(4))), chr(5))
            no-error. 
            assign
                entry(1, ext-classif-attr.attr-value, chr(4)) = v-prod 
            no-error.
            /* Импортер */ 
            assign
                entry(2, ext-classif-attr.attr-value, chr(4)) = entry(2, tt-ext-classif.charkey_two, chr(4)) 
            no-error. 
            /* наименование товара ЕГАИС */
            assign
                entry(3, ext-classif-attr.attr-value, chr(4)) = entry(3, tt-ext-classif.charkey_two, chr(4)) 
            no-error. 
        end.
    end.
end.

message "Готово" view-as alert-box .
