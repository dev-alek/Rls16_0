block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

триггер на изменение в ДЕН таблице

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.price-all OLD old_price-all .
define variable  vss-revision    as character no-undo init "$Revision$":U .
define variable  vss-author      as character no-undo init "$Author$":U .
define variable  vss-date        as character no-undo init "$Date$":U .
define variable  vss-workfile    as character no-undo init "$Workfile$":U .
define variable  vss-archive     as character no-undo init "$Archive$":U .
define variable  vss-description as character no-undo init "триггер на изменение в ДЕН таблице".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ trg/factord.i  }
{ gbl/cur-time.i }
define variable v-fact-date            as date    no-undo .
define variable v-fact-time            as integer no-undo .
define variable v-fact-order           as decimal no-undo .
define variable v-shift-end-fact-order as decimal no-undo .
define variable v-day-end-fact-order   as decimal no-undo .
define variable l-shift-on as logical no-undo .
define variable l-date as date      no-undo .
define variable l-time as integer   no-undo .
define variable s-date as date      no-undo . /* дата начала смены для документа */
define variable s-num  as integer   no-undo . /* порядок смены для документа */
define variable s-name as character no-undo . /* номер смены для документа */
define variable max-fact-order as decimal   no-undo .

define buffer buf_price-doc-forming for ub.price-doc-forming  .
define buffer buf_price-list-type   for ub.price-list-type  .
define buffer buf2_price-list-type   for ub.price-list-type  .
define buffer last_price-all for ub.price-all  .
define buffer buf_price-doc for ub.price-doc  .
define variable v-plt-id as integer   no-undo .
define variable v-plt-db-num as integer   no-undo .

main-block :
do transaction
on error undo main-block, return error
:

run cur-time in this-procedure ( output v-fact-date, output v-fact-time) .

if g#news = false then do:
/* Это проставляется в переоценке , проверка если не установилась */
  if ( ub.price-all.fact-order = 0 or ub.price-all.fact-order = ?)  and
       ub.price-all.status_ = {&act-overvalue}
  then do:
     /* По закрытой переоценке фактордер должен братся из нее */
     /* По остальным рассчитыватся  */
      find first buf_price-doc no-lock where
                 buf_price-doc.doc-num = ub.price-all.out-code and
                 buf_price-doc.status_  = {&act-overvalue} no-error .
      if available buf_price-doc then do:
         v-fact-order = buf_price-doc.fact-order.  /* fact-order создания строки */
      end.
      else do:
          run cur-time in this-procedure ( output v-fact-date, output v-fact-time) .
          { gbl/objat.i
            ub.price-all.obj-type
            ub.price-all.obj-code
            "'shift-on=request'"
            l-shift-on
            no-error
          }
          if error-status :error then do:
             message
               vss-workfile vss-revision vss-description skip
               error-status :get-message(1) skip
               return-value skip
               "objat"   skip
                ub.price-all.obj-type skip
                ub.price-all.obj-code skip
               view-as alert-box error
             .
             undo, return error return-value .
          end.
          run gbl/factdate.p
          ( input        ub.price-all.obj-type  ,
            input        ub.price-all.obj-code  ,
            input-output v-fact-date ,
            input-output v-fact-time ,
            input-output s-date  ,
            input-output s-num ,
            input-output s-name,
            input        false
            ) no-error .
          if error-status :error then do:
             undo, return error return-value .
          end.
          run factord in this-procedure
            (input  v-fact-date            /* p-fact-date            */
            ,input  v-fact-time            /* p-fact-time            */
            ,input  v-fact-time            /* p-fact-num             */
            ,input  s-date                 /* p-shift-date           */
            ,input  s-num                  /* p-shift-num            */
            ,input  l-shift-on             /* p-shift-on             */
            ,output v-fact-order           /* p-fact-order           */
            ,output v-shift-end-fact-order /* p-shift-end-fact-order */
            ,output v-day-end-fact-order   /* p-day-end-fact-order   */
            ) no-error .
          if error-status :error
          or v-fact-order = ?
          or v-fact-order = 0 then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при определении фактического номера " skip
              "fact-date"               v-fact-date   skip
              "fact-time"               v-fact-time   skip
              "fact-num(pal-id)"        ub.price-all.pal-id    skip
              "shift-date"              s-date  skip
              "shift-num"               s-num   skip
              "v-fact-order"            v-fact-order           skip
              "v-shift-end-fact-order"  v-shift-end-fact-order skip
              "v-day-end-fact-order"    v-day-end-fact-order   skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error .
          end.
      end.

      ub.price-all.fact-order = v-fact-order.  /* fact-order создания строки */

      find first buf_price-list-type no-lock where
                 buf_price-list-type.plt-id      = ub.price-all.plt-id      and
                 buf_price-list-type.plt-db-num  = ub.price-all.plt-db-num  no-error .

      v-plt-id     = ub.price-all.plt-id  .
      v-plt-db-num = ub.price-all.plt-db-num  .

      /*  отметка на старых ценах */
      if buf_price-list-type.main = true then do:
          for each  last_price-all exclusive-lock where
            last_price-all.main-indication = ub.price-all.main-indication  and
            last_price-all.type-price      = ub.price-all.type-price       and
            last_price-all.b-code          = ub.price-all.b-code           and
            last_price-all.gds-code        = ub.price-all.gds-code         and
            last_price-all.obj-code        = ub.price-all.obj-code         and
            last_price-all.obj-type        = ub.price-all.obj-type         and
            last_price-all.plt-priority    = 0                              and
            last_price-all.last-pr        = true
            and
            not (
                  last_price-all.pdf-id          = ub.price-all.pdf-id             and
                  last_price-all.pdf-db          = ub.price-all.pdf-db        )
              :
            assign
              last_price-all.last-pr           = false
              last_price-all.end-date          = v-fact-date
              last_price-all.fact-order-sys-to = v-fact-order
             .
          end.
      end.
  end.

/* ограничения по времени */

  run factord-max-fact-order (output max-fact-order) .
  find first buf_price-doc-forming no-lock where
             buf_price-doc-forming.plt-id     = ub.price-all.plt-id and
             buf_price-doc-forming.plt-db-num = ub.price-all.plt-db-num and
             buf_price-doc-forming.pdf-id     = ub.price-all.pdf-id and
             buf_price-doc-forming.pdf-db     = ub.price-all.pdf-db
             no-error .
  if error-status :error then do:
      undo, return error SUBSTITUTE ("Ошибка поиска ДНЦ plt= &1/&2 pdf= &3/&4 ",  ub.price-all.plt-id , ub.price-all.plt-db-num ,
                                    ub.price-all.pdf-id ,  ub.price-all.pdf-db  ).
  end.
  if logical ( buf_price-doc-forming.have-start-period ) =  true then  do:
      if logical ( buf_price-doc-forming.have-end-period ) =  false then do:
        ub.price-all.fact-order-sys-to = max-fact-order .
      end.
  end.
  else do:
      if v-plt-id = 0 and  v-plt-db-num = 0 then do:
         v-plt-id     = ub.price-all.plt-id        .
         v-plt-db-num = ub.price-all.plt-db-num    .
      end.
      find first buf2_price-list-type no-lock where
                 buf2_price-list-type.plt-id       = v-plt-id        and
                 buf2_price-list-type.plt-db-num   = v-plt-db-num   no-error .
        if error-status :error then do:
           message substitute("&1 Нет ТПЛ &2 &3" ,error-status :get-message(1) , v-plt-id, v-plt-db-num    ) .
           return error substitute("&1 Нет ТПЛ &2 &3" ,error-status :get-message(1) , v-plt-id, v-plt-db-num    ) .
        end.


      if buf2_price-list-type.work-date = integer( {&mpl-date-sys} ) then do:
         ub.price-all.fact-order-sys-from =  ub.price-all.fact-order .
      end.
      else do:
          ub.price-all.fact-order-sys-from = TRUNCATE (  ub.price-all.fact-order , 2 )  . /* отсечена часть по времени */
      end.

      if logical ( buf_price-doc-forming.have-end-period ) =  false then do:
        ub.price-all.fact-order-sys-to = max-fact-order .
      end.
  end.

define variable v-cmp as character no-undo .
    buffer-compare old_price-all
    to ub.price-all case-sensitive
    save result in v-cmp
    .

    if v-cmp <> "":U  then do:
    /* закрытые пошлем по новостям  */
    if  ub.price-all.status_ = {&act-overvalue} and old_price-all.status_ <> {&act-overvalue}    then do:
      run str/callnews.p
        (input "price-all"
        ,input (buffer ub.price-all:handle)
        ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно маршрутизировать price-all для отправки в новости" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
    else do:
      find first buf_price-doc no-lock where buf_price-doc.doc-num = ub.price-all.out-code no-error .
      if available buf_price-doc and g#db-num = 0 then do: /* незакрытые переоценки тоже пошлем Только из ГБД */
          run str/callnews.p
            (input "price-all"
            ,input (buffer ub.price-all:handle)
            ) no-error .
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              "Невозможно маршрутизировать price-all для отправки в новости" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error .
          end.
      end.
    end.
    end.
end.

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_price-all}
        , input ( buffer ub.price-all:handle )
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