/*

$Revision: $
$Author: $
$Date: $
$Workfile: $
$Archive: $

Инклюд обработки топливной транзации с чеком и добавление записи транзакции  в temp-table tt-rep

Автор: Ростовцев Александр
Дата создания: 24/05/23
Author: Rostovtsev Alexandr
Creation date: 24/05/23
Used by: r-tranfuel.p (r-tranfuel.i)

*/
for first chk-doc-attr where
          chk-doc-attr.attr-code  = "CheckId"
      and chk-doc-attr.attr-value = tran-fuel.uuid-cheq
no-lock,
    first chk-doc where
          chk-doc.doc-code = chk-doc-attr.doc-code
      and can-do(iChkTypeCodeList, string(chk-doc.chk-type))
no-lock
&if "{1}" <> "class" &then
,
    first obj-list where
          obj-list.obj-type = chk-doc.obj-type
      and obj-list.obj-code = chk-doc.obj-code
no-lock
&endif
:
  v-gds-code = tran-fuel.fuel-code.
  if v-gds-code < 100 then do: /* Если короткий код, то ищем полный код */
    find first prod-bc where
               prod-bc.b-str = string(v-gds-code)
    no-lock no-error.
    if avail prod-bc then do:
       find first chk-gds where
                  chk-gds.doc-code = chk-doc.doc-code
              and chk-gds.b-code   = prod-bc.b-code
       no-lock no-error.
       find first goods where
                  goods.gds-code = prod-bc.b-code
       no-lock no-error.
       if not avail chk-gds or not avail goods
       then
          next TRAN-FUEL.
       v-gds-code = goods.gds-code.
    end.
    else next TRAN-FUEL.
  end.
  else do:
     find first chk-gds where
                chk-gds.doc-code = chk-doc.doc-code
            and chk-gds.b-code   = v-gds-code
     no-lock no-error.
     find first goods where
                goods.gds-code = v-gds-code
     no-lock no-error.
     if not avail chk-gds or not avail goods
     then
        next TRAN-FUEL.
  end.
  if not can-do(iGdsCodeList, string(v-gds-code)) then next TRAN-FUEL.
  
  &if "{1}" = "class" &then
    CreateOneRec(buffer chk-doc,
                 buffer tran-fuel,
                 buffer chk-gds,
                 buffer goods
                 ).
  &else
    run CreateOneRec(buffer obj-list,
                     buffer chk-doc,
                     buffer tran-fuel,
                     buffer chk-gds,
                     buffer goods
                     ).
  &endif
end.  
