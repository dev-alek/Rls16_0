block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись индикаторов товара на объекте

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

При смене ИЖТ на  ass-izd-del запоминается дата последней смены ижт.
В новостях проставляется дата приема измененого статуса ИЖТ

Теперь аттрибут gopattr-CorrIztDel имеет смысл - дата последнего измениения ИЖТ
Проставляется при любой смене ИЖТ

*/

TRIGGER PROCEDURE FOR WRITE OF ub.gds-obj-prop OLD old_gds-obj-prop.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись индикаторов товара на объекте".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ trg/factord.i  }
{ nws/lib-nws.i }
{ ref/assgrpmt.i }

define buffer buf_c-gds-obj-prop for c-gds-obj-prop.
define buffer buf_c-gds-hist     for ub.c-gds-hist.
define buffer buf_assortment-matrix for ub.assortment-matrix  .
define buffer buf_assortment-matrix-goods for ub.assortment-matrix-goods  .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-host-code as integer no-undo .


main-block :
do transaction
on error undo main-block, return error
:
    run cur-time in this-procedure(output v-date, output v-time).

if g#news = false then do:
    assign
      ub.gds-obj-prop.grop-date-update     = v-date
      ub.gds-obj-prop.grop-time-update     = v-time
      ub.gds-obj-prop.grop-db-num-update   = g#db-num
      ub.gds-obj-prop.grop-who-update      = g#userid
    .
   if ub.gds-obj-prop.gdop-igt = "" or ub.gds-obj-prop.gdop-igt = ? then do:
      assign
        ub.gds-obj-prop.gdop-igt = {&ass-izd-empty}
        .
   end.
    /* Проверка изменения АссМин */
    if old_gds-obj-prop.gdop-assort-min <> ub.gds-obj-prop.gdop-assort-min and old_gds-obj-prop.gdop-assort-min = false then do:
      /* а есть ли Ассортим политика */
      find first buf_assortment-matrix no-lock where
                  buf_assortment-matrix.asmt-status = 0 and
                  buf_assortment-matrix.obj-code = ub.gds-obj-prop.obj-code and
                  buf_assortment-matrix.obj-type = ub.gds-obj-prop.obj-type no-error .
      if available buf_assortment-matrix then do: /* есть */
          find first buf_assortment-matrix-goods no-lock where
                      buf_assortment-matrix-goods.asmg-status = 0 and
                      buf_assortment-matrix-goods.gds-code = ub.gds-obj-prop.gds-code and
                      buf_assortment-matrix-goods.asmt-id  = buf_assortment-matrix.asmt-id and
                      buf_assortment-matrix-goods.db-num   = buf_assortment-matrix.db-num no-error .
           if not available buf_assortment-matrix-goods  then do:
              message  substitute("Товар &1 не включен в ассортиментную матрицу &2 " ,
              ub.gds-obj-prop.gds-code ,
              buf_assortment-matrix.asmt-name
              ) view-as alert-box error .
               return error "Добавлять этот товар в Amin нельзя !".
           end.
    end.
   end.
end.

/* ИСТОРИЯ */
  if g#news then do:
    define variable v-send as integer no-undo .
    v-send = integer({&hn-is-on}).
    { gbl/get-hn.i
    g#db-num
    ~{&table_gds-obj-prop~}
    0
    '':U
    0
    '':U
    '':U
    '':U
    0
    0
    0
    ~{&nws-to-hist~}
    v-send
    no-error
    }
  end.
  if not g#news
  or v-send >= 0 then do:
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-gds-obj-prop.
    buffer-copy old_gds-obj-prop to buf_c-gds-obj-prop
    assign
    buf_c-gds-obj-prop.gds-code         = ub.gds-obj-prop.gds-code
    buf_c-gds-obj-prop.obj-type         = ub.gds-obj-prop.obj-type
    buf_c-gds-obj-prop.obj-code         = ub.gds-obj-prop.obj-code
    buf_c-gds-obj-prop.chip-num         = next-value (s-gds-chip , {&db-name_schema})
    buf_c-gds-obj-prop.gdop-date-his    = v-date
    buf_c-gds-obj-prop.gdop-time-his    = v-time
    buf_c-gds-obj-prop.corr-user-db-num = g#db-num
    buf_c-gds-obj-prop.corr-user-name     = (if g#news
                                      then {&nts-user}
                                      else (if g#esys
                                            then {&esys-user}
                                            else g#userid)
                                      )
    .
    if ub.gds-obj-prop.obj-type <> {&cmp} then do:
       { gbl/hostcode.i ub.gds-obj-prop.obj-type ub.gds-obj-prop.obj-code v-host-code }
    end.
    else do:
        v-host-code = ub.gds-obj-prop.obj-code .
    end.

    create buf_c-gds-hist.
    buffer-copy buf_c-gds-obj-prop to buf_c-gds-hist
    assign
    buf_c-gds-hist.action = (if new ub.gds-obj-prop then integer({&hn-create}) else integer({&hn-update}))
    buf_c-gds-hist.subject = {&table_gds-obj-prop}
    buf_c-gds-hist.is-news = g#news
    buf_c-gds-hist.source-type = (if g#news
                                  then {&hn-source-db}
                                  else (if g#esys
                                        then {&hn-source-esys}
                                        else "":U)
                                  )
    buf_c-gds-hist.source-ref = (if g#news
                                  then string(g#news-source-db)
                                  else (if g#esys
                                        then string(g#esys-source-esys)
                                        else "":U)
                                  )
    buf_c-gds-hist.corr-date         = buf_c-gds-obj-prop.gdop-date-his
    buf_c-gds-hist.corr-time         = buf_c-gds-obj-prop.gdop-time-his
    buf_c-gds-hist.corr-user-db-num  = buf_c-gds-obj-prop.corr-user-db-num
    buf_c-gds-hist.corr-user-name    = buf_c-gds-obj-prop.corr-user-name
    buf_c-gds-hist.host-code         = v-host-code
    .
  end.
/* Отправка по новостям */

if /* g#db-num = 0 or ( g#db-num <> 0 and g#news = false )  SV  */ true then do:

  run str/callnews.p
    (input {&table_gds-obj-prop}
    ,input (buffer ub.gds-obj-prop:handle)
    ) no-error .
  if error-status:error then do:
     message
      vss-workfile vss-revision vss-description skip
      "Ошибка при передаче в новости" skip
      return-value skip
      view-as alert-box error .
      return error.
  end.
end.

define buffer buf_goods for ub.goods  .
define buffer del_assortment-matrix-goods for ub.assortment-matrix-goods  .
find first buf_goods no-lock where buf_goods.gds-code = ub.gds-obj-prop.gds-code no-error .

find first buf_assortment-matrix no-lock where
           buf_assortment-matrix.obj-type    = ub.gds-obj-prop.obj-type and
           buf_assortment-matrix.obj-code    = ub.gds-obj-prop.obj-code and
           buf_assortment-matrix.asmt-status = 0 and
           buf_assortment-matrix.asmt-type   = {&type-assmatr-obj}
           no-error .
find first buf_assortment-matrix-goods no-lock where
           buf_assortment-matrix-goods.asmg-status = 0 and
           buf_assortment-matrix-goods.gds-code    = ub.gds-obj-prop.gds-code and
           buf_assortment-matrix-goods.asmt-id     = buf_assortment-matrix.asmt-id and
           buf_assortment-matrix-goods.db-num      = buf_assortment-matrix.db-num
           no-error .

find first del_assortment-matrix-goods no-lock where
           del_assortment-matrix-goods.asmg-status = 1 and
           del_assortment-matrix-goods.gds-code    = ub.gds-obj-prop.gds-code and
           del_assortment-matrix-goods.asmt-id     = buf_assortment-matrix.asmt-id and
           del_assortment-matrix-goods.db-num      = buf_assortment-matrix.db-num
           no-error .


/* Изменения ИЖТ и в новостях и без !!! */
/*
if old_gds-obj-prop.gdop-igt <> ub.gds-obj-prop.gdop-igt and ub.gds-obj-prop.gdop-igt = {&ass-izd-del} then do:
*/
/* При любой смене ИЖТ - проставляем аттрибут !!!  */
if (new(ub.gds-obj-prop) AND ub.gds-obj-prop.gdop-igt = {&ass-izd-new}) OR
   (old_gds-obj-prop.gdop-igt <> ub.gds-obj-prop.gdop-igt)
   THEN DO:
   /*  */
   run make-attr-iztdel(ub.gds-obj-prop.gds-code , ub.gds-obj-prop.obj-type, ub.gds-obj-prop.obj-code) .
   if available buf_assortment-matrix-goods then do:
      run recalc-gds-assgrp
        (
          input  '--'  ,
          input  buf_goods.gds-code  ,
          input  buf_goods.grp-code  ,
          input  buf_assortment-matrix.asmt-id ,
          input  buf_assortment-matrix.db-num  )
          no-error .
    end.
end.

/*
Удаление атрибута нам теперь не нужно !!!
if old_gds-obj-prop.gdop-igt <> ub.gds-obj-prop.gdop-igt and old_gds-obj-prop.gdop-igt = {&ass-izd-del} then do:
   run del-attr-iztdel(ub.gds-obj-prop.gds-code , ub.gds-obj-prop.obj-type, ub.gds-obj-prop.obj-code) .
   if available buf_assortment-matrix-goods or available del_assortment-matrix-goods then do:
      run recalc-gds-assgrp
        (
          input  '+'  ,
          input  buf_goods.gds-code  ,
          input  buf_goods.grp-code  ,
          input  buf_assortment-matrix.asmt-id ,
          input  buf_assortment-matrix.db-num  )
          no-error .
    end.

end.
*/

  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_gds-obj-prop}
        , input ( buffer ub.gds-obj-prop:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
  end.
end.


procedure make-h :

  do
  on error undo, return error return-value
  :
      if error-status :error then
         message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          "Ошибка создания истории товара"
          view-as alert-box error .

  end.

end procedure. /* make-h */


procedure make-attr-iztdel :
define input  parameter p-gds-code as integer   no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define buffer x-gds-obj-prop-attr for ub.gds-obj-prop-attr  .


  do
  on error undo, return error return-value
  :
   find first x-gds-obj-prop-attr no-lock WHERE
              x-gds-obj-prop-attr.gds-code = p-gds-code AND
              x-gds-obj-prop-attr.obj-code = p-obj-code AND
              x-gds-obj-prop-attr.obj-type = p-obj-type and
              x-gds-obj-prop-attr.attr-code = {&gopattr-CorrIztDel} no-error .
   if not available x-gds-obj-prop-attr then do:
      create  x-gds-obj-prop-attr .
      assign
        x-gds-obj-prop-attr.gds-code = p-gds-code
        x-gds-obj-prop-attr.obj-code = p-obj-code
        x-gds-obj-prop-attr.obj-type = p-obj-type
        x-gds-obj-prop-attr.attr-code = {&gopattr-CorrIztDel}
        x-gds-obj-prop-attr.attr-value = string(today, "99/99/9999" )
      .
   end.
   else do:
      find first x-gds-obj-prop-attr exclusive-lock WHERE
                  x-gds-obj-prop-attr.gds-code = p-gds-code AND
                  x-gds-obj-prop-attr.obj-code = p-obj-code AND
                  x-gds-obj-prop-attr.obj-type = p-obj-type and
                  x-gds-obj-prop-attr.attr-code = {&gopattr-CorrIztDel} no-error .
      assign
        x-gds-obj-prop-attr.attr-value = string(today, "99/99/9999" )
      .
   end.
  end.

end procedure. /* make-attr */

/*
Эта процедура уже не нужна !!!
procedure del-attr-iztdel :
define input  parameter p-gds-code as integer   no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .

define buffer x-gds-obj-prop-attr for ub.gds-obj-prop-attr  .

  do
  on error undo, return error return-value
  :
   find first x-gds-obj-prop-attr exclusive-lock WHERE
              x-gds-obj-prop-attr.gds-code = p-gds-code AND
              x-gds-obj-prop-attr.obj-code = p-obj-code AND
              x-gds-obj-prop-attr.obj-type = p-obj-type and
              x-gds-obj-prop-attr.attr-code = {&gopattr-CorrIztDel} no-error .
   if available x-gds-obj-prop-attr then do:
       delete x-gds-obj-prop-attr.
   end.
  end.

end procedure. /* del-attr-iztdel */
*/

