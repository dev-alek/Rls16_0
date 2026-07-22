block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Посылка всей информации на все магазины БД из новостей
написан для того, чтобы  не закрывтаь окно diallog.w при  вызове send-gds.p по каждому объекту

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/16/04
Author: Bakhtadze Natalya
Creation date: 02/16/04

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

/*
p-parameter включает
define input parameter p-db-num like ub.db.db-num no-undo .
*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Посылка всей информации на все магазины БД из новостей".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
define variable p-db-num like ub.db.db-num no-undo .

{ str/imp2cd_def.i}
{ str/defc-cli.i "new shared" }
{ ref/extclass.i }     
{ str/cdsnddef.i }  

define buffer buf_clients for ub.clients.
define buffer buf_shop for ub.shop.
define buffer buf_cash-desk for ub.cash-desk.

assign
p-db-num = integer(entry(1, p-parameter, {&delim-par}))
no-error
.
if error-status:error then return error.

define variable vrec-cur      as character no-undo.
define variable vrec-del      as character no-undo.
/*define variable log-file-name as character no-undo init "send-cd.txt":U .*/
/*define variable v-view-log    as logical   no-undo.*/

for each cash-pay-list no-lock:
   find first cash-pay where cash-pay.cdpay-code eq cash-pay-list.cdpay-code
                         and cash-pay.curr-code  eq cash-pay-list.curr-code
   no-lock no-error.
   if available cash-pay
   then do:
      if      cash-pay.status_ eq {&current-status}
      then
         vrec-cur = vrec-cur + "," + string(recid(cash-pay)).
      else if cash-pay.status_ eq {&deleted-status}
      then
         vrec-del = vrec-del + "," + string(recid(cash-pay)).
   end.
end.

vrec-cur = trim(vrec-cur,",").
vrec-del = trim(vrec-del,",").

for each buf_clients no-lock
      where buf_clients.obj-type = {&shop}
        and buf_clients.db-num   = g#db-num,
      first buf_cash-desk no-lock where
           buf_cash-desk.db-num = p-db-num
       AND buf_cash-desk.obj-code = buf_clients.obj-code
       AND buf_cash-desk.cash-on = yes
  on error undo, return error
  :
   if  vrec-cur ne ""
   then
      run str/send-pay.p (
                       input parparentproc
                      ,input p-parent-handle
                      ,input p-log-handle
                      ,input buf_clients.obj-code
                      ,input "U"
                      ,input 1
                     , input vrec-cur
                     , input log-file-name
                     , input-output v-view-log
                     ) no-error .
   if  vrec-del ne ""
   then
      run str/send-pay.p (
                       input parparentproc
                      ,input p-parent-handle
                      ,input p-log-handle
                      ,input buf_clients.obj-code
                      ,input "U"
                      ,input 1
                     , input vrec-del
                     , input log-file-name
                     , input-output v-view-log
                     ) no-error .
end.


define variable v-promo-actions-upd as class ibs.th.ref.promo.promoactionsubs no-undo .
define variable v-promo-actions-del as class ibs.th.ref.promo.promoactionsubs no-undo .

define variable v-promo-stor as class ibs.th.gbl.storage.promoactionstorage no-undo .
v-promo-stor = new ibs.th.gbl.storage.promoactionstorage().

for each PromoAction-list no-lock:
   find first ub.PromoAction where ub.PromoAction.id = PromoAction-list.id
                         and ub.PromoAction.db-num = PromoAction-list.db-num
   no-lock no-error.
   if available ub.PromoAction
   then do:
     if ub.PromoAction.Status_ = 2 or ub.PromoAction.changeDate < today then
      v-promo-stor:getpromoactionsubs(input-output v-promo-actions-del,PromoAction-list.db-num,PromoAction-list.id).
     else  v-promo-stor:getpromoactionsubs(input-output v-promo-actions-upd,PromoAction-list.db-num,PromoAction-list.id).
   end.
end.

delete object v-promo-stor.
if valid-Object(v-promo-actions-upd)
then do:
   for each buf_clients no-lock
         where buf_clients.obj-type = {&shop}
           and buf_clients.db-num   = g#db-num,
         first buf_cash-desk no-lock where
              buf_cash-desk.db-num = p-db-num
          AND buf_cash-desk.obj-code = buf_clients.obj-code
          AND buf_cash-desk.cash-on = yes
     on error undo, return error
     :
      run str/send-promo.p (
                       input parparentproc
                      ,input p-parent-handle
                      ,input p-log-handle
                      ,input buf_cash-desk.obj-code
                      ,input "U"
                      ,input (if not valid-object (v-promo-actions-upd)
                              then 0  /* all  */
                              else 1) /* list */
                     , input v-promo-actions-upd /* list */
                     , input log-file-name
                     , input-output v-view-log
                     ) no-error .
      
   end.
end.
if valid-Object(v-promo-actions-del)
then do:
   for each buf_clients no-lock
         where buf_clients.obj-type = {&shop}
           and buf_clients.db-num   = g#db-num,
         first buf_cash-desk no-lock where
              buf_cash-desk.db-num = p-db-num
          AND buf_cash-desk.obj-code = buf_clients.obj-code
          AND buf_cash-desk.cash-on = yes
     on error undo, return error
     :
      run str/send-promo.p (
                       input parparentproc
                      ,input p-parent-handle
                      ,input p-log-handle
                      ,input buf_cash-desk.obj-code
                      ,input "D"
                      ,input (if not valid-object (v-promo-actions-del)
                              then 0  /* all  */
                              else 1) /* list */
                     , input v-promo-actions-del /* list */
                     , input log-file-name
                     , input-output v-view-log
                     ) no-error .
      
   end.
end.

assign
   vrec-cur = ""
   vrec-del = ""
   .

for each buf_clients no-lock
      where buf_clients.obj-type = {&shop}
        and buf_clients.db-num   = g#db-num,
      first buf_cash-desk no-lock where
           buf_cash-desk.db-num = p-db-num
       AND buf_cash-desk.obj-code = buf_clients.obj-code
       AND buf_cash-desk.cash-on = yes
  on error undo, return error
  :


for each c-ext-classif-list no-lock:

   find first c-ext-classif where c-ext-classif.db-num = c-ext-classif-list.db-num and
                                c-ext-classif.Key#_One = c-ext-classif-list.Key#One and
                                c-ext-classif.Key#_Two = c-ext-classif-list.Key#Two and
                                c-ext-classif.CharKey_One = c-ext-classif-list.CharKey_One and
                                c-ext-classif.chip-num = c-ext-classif-list.chip-num and
                                c-ext-classif.classif-subject = {&table_goods} and 
                                c-ext-classif.classif-name = {&extclass_goods_esys}
   no-lock no-error.
   if available c-ext-classif
   then do:
      find first ext-classif where ext-classif.db-num = c-ext-classif-list.db-num and
                                ext-classif.Key#_One = c-ext-classif-list.Key#One and
                                ext-classif.Key#_Two = c-ext-classif-list.Key#Two and
                                ext-classif.CharKey_One = c-ext-classif-list.CharKey_One and
                                ext-classif.classif-subject = {&table_goods} and 
                                ext-classif.classif-name = {&extclass_goods_esys} no-error .
		if not available ext-classif then							
   vrec-del = vrec-del + "," + string(recid(c-ext-classif)).
   end.
end.
   if  vrec-del ne ""
   then
       run str/send-petrol.p (
                    input parparentproc
                   ,input p-parent-handle
                   ,input p-log-handle
                   ,input buf_clients.obj-code
                   ,input buf_clients.obj-type
                   ,input "D"
                   ,input 0
                  , input vrec-del
                  , input log-file-name
                  , input-output v-view-log
                  ) no-error .

for each ext-classif-list no-lock:

   find first ext-classif where ext-classif.db-num = ext-classif-list.db-num and
                                ext-classif.Key#_One = ext-classif-list.Key#One and
                                ext-classif.Key#_Two = ext-classif-list.Key#Two and
                                ext-classif.CharKey_One = ext-classif-list.CharKey_One and
                                ext-classif.classif-subject = {&table_goods} and 
                                ext-classif.classif-name = {&extclass_goods_esys}
   no-lock no-error.
   if available ext-classif
   then vrec-cur = vrec-cur + "," + string(recid(ext-classif)).
end.

vrec-cur = trim(vrec-cur,",").

   if  vrec-cur ne ""
   then
    run str/send-petrol.p (
                    input parparentproc
                   ,input p-parent-handle
                   ,input p-log-handle
                   ,input buf_clients.obj-code
                   ,input buf_clients.obj-type
                   ,input "U"
                   ,input 0
                  , input vrec-cur
                  , input log-file-name
                  , input-output v-view-log
                  ) no-error .
                
end.
if can-find(first gds-list no-lock)
or can-find(first gdsolist no-lock) then do:
  for each buf_clients no-lock
      where buf_clients.obj-type = {&shop}
        and buf_clients.db-num   = p-db-num,
      first buf_cash-desk no-lock where
           buf_cash-desk.db-num = p-db-num
       AND buf_cash-desk.obj-code = buf_clients.obj-code
       AND buf_cash-desk.cash-on = yes
  on error undo, return error
  :
    for each gdsolist no-lock where
            gdsolist.obj-type = buf_clients.obj-type
        and gdsolist.obj-code = buf_clients.obj-code:
        find first gds-list where
                  gds-list.gds-code = gdsolist.gds-code no-error .
        if avail gds-list then NEXT.
        if not avail gds-list then do:
          find first goods no-lock where
                    goods.gds-code = gdsolist.gds-code no-error .
          create gds-list.
          buffer-copy goods to gds-list.
        end.
        if avail gds-list then
        assign
        /*сигнал для send-gds.p чтобы стер эту запись*/
        gds-list.qnty = -1
        .
    END.
    run set-title in p-log-handle (
          input "Отправка товаров на кассу"
                                   ).
     run str/send-gds.p (
        input parparentproc
        ,input p-parent-handle
        ,input p-log-handle
        ,input (string(buf_clients.obj-code) + {&delim-par} + "no":U)
        ) no-error .
    if error-status:error then
    return error substitute( "ошибка при отправке товаров на кассу по магазину &1&2&3&2&4"
                            , buf_clients.obj-code
                            , {&new-line}
                            , error-status:get-message(1)
                            , return-value
                            ).
  end.
end.

if can-find(first bc-list no-lock) then do:
  for each buf_clients no-lock
      where buf_clients.obj-type = {&shop}
        and buf_clients.db-num   = g#db-num,
      first buf_cash-desk no-lock where
           buf_cash-desk.db-num = p-db-num
       AND buf_cash-desk.obj-code = buf_clients.obj-code
       AND buf_cash-desk.cash-on = yes
  on error undo, return error
  :
    run set-title in p-log-handle (
         input 'Удаление бар-кодов с кассы'
                                   ).
    run str/send-bcn.p (
                    input parparentproc
                   ,input p-parent-handle
                  ,input p-log-handle
                  ,input (string(buf_clients.obj-code) + {&delim-par} + "D":U)
                    ) no-error .
    if error-status:error then do:
      return error substitute( "ошибка при удалении бар-кодов с кассы магазина &1&2&3&2&4"
                            , buf_clients.obj-code
                            , {&new-line}
                            , error-status:get-message(1)
                            , return-value

      ).
    end.
    run set-title in p-log-handle (
         input 'Отправка бар-кодов на кассу'
                                   ).
    run str/send-bcn.p (
                    input parparentproc
                  ,input p-parent-handle
                  ,input p-log-handle
                  ,input (string(buf_clients.obj-code) + {&delim-par} + "U":U)
                    ) no-error .
    if error-status:error then do:
      return error substitute( "ошибка при отправке бар-кодов на кассы магазина &1&2&3&2&4"
                            , buf_clients.obj-code
                            , {&new-line}
                            , error-status:get-message(1)
                            , return-value

        ).
    end.
  end.
end.
if can-find(first pbc-list no-lock) then do:
    for each buf_clients no-lock
      where buf_clients.obj-type = {&shop}
        and buf_clients.db-num   = p-db-num,
      first buf_cash-desk no-lock where
           buf_cash-desk.db-num = p-db-num
       AND buf_cash-desk.obj-code = buf_clients.obj-code
       AND buf_cash-desk.cash-on = yes
  on error undo, return error
  :
    run set-title in p-log-handle (
          input 'Удаление ДопБК с кассы'
                                    ).
    run str/s-prdbcn.p (
                    input parparentproc
                  ,input p-parent-handle
                  ,input p-log-handle
                  ,input (string(buf_clients.obj-code) + {&delim-par} + "D":U)
                    ) no-error .
    if error-status:error then do:
      return error substitute( "ошибка при удалении ДопБК с кассы магазина &1&2&3&2&4"
                            , buf_clients.obj-code
                            , {&new-line}
                            , error-status:get-message(1)
                            , return-value
         ).
    end.
    run str/s-prdbcn.p (
                    input parparentproc
                  ,input p-parent-handle
                  ,input p-log-handle
                  ,input (string(buf_clients.obj-code) + {&delim-par} + "U":U)
                    ) no-error .
    if error-status:error then do:
      return error substitute( "ошибка при отправке ДопБК на кассы магазина &1&2&3&2&4"
                            , buf_clients.obj-code
                            , {&new-line}
                            , error-status:get-message(1)
                            , return-value
         ).
    end.
  end.
end.
if can-find(first cash-txn no-lock)
  or can-find(first cash-txr no-lock)
then do:
    run set-title in p-log-handle (
          input 'Отправка налогов на кассу'
                                    ).
  for each buf_clients no-lock
      where buf_clients.obj-type = {&shop}
        and buf_clients.db-num   = p-db-num,
      first buf_cash-desk no-lock where
           buf_cash-desk.db-num = p-db-num
       AND buf_cash-desk.obj-code = buf_clients.obj-code
       AND buf_cash-desk.cash-on = yes
  on error undo, return error
  :
    run str/sendtaxn.p (
                    input parparentproc
                  ,input p-parent-handle
                  ,input p-log-handle
                  ,input (string(buf_clients.obj-code) + {&delim-par} + "U":U)
                  ) no-error.
    if error-status:error then do:
      return error substitute( "ошибка при отправке налогов на кассы магазина &1&2&3&2&4"
                            , buf_clients.obj-code
                            , {&new-line}
                            , error-status:get-message(1)
                            , return-value

         ).
    end.
  end.
end.
if    can-find(first dc-list no-lock) 
   or can-find(first dc-dis-card-mask no-lock) 
   then do:
    run set-title in p-log-handle (
          input 'Отправка информации по клиентским картам на кассу'
                                    ).
    for each buf_clients no-lock
      where buf_clients.obj-type = {&shop}
        and buf_clients.db-num = p-db-num
  ,each buf_shop no-lock
      where buf_shop.obj-code = buf_clients.obj-code
    break by buf_shop.host-code
  on error undo, return error
  :
    if first-of(buf_shop.host-code) then do:
      run str/send-cli-news.p (
                    input parparentproc
                   ,input p-parent-handle
                   ,input p-log-handle
                   ,input (string(buf_clients.obj-code) + {&delim-par} + "U":U +
                           {&delim-par} + "no":U + {&delim-par} + "no":U )
                     ) no-error .
      if error-status:error then do:
        return error substitute( "ошибка при отправке информации по клиентским картам на кассы магазина &1&2&3&2&4"
                            , buf_clients.obj-code
                            , {&new-line}
                            , error-status:get-message(1)
                            , return-value
           ).
      end.
    end.
  end.
end.
if can-find(first stpl-list no-lock where stpl-list.classif-type = {&table_dis-card}) then do:
  for each stpl-list no-lock where
          stpl-list.classif-type = {&table_dis-card}:
    run str/snd-stpl.p (
                      input parparentproc
                      ,input p-parent-handle
                      ,input p-log-handle
                      ,input stpl-list.stop-list-code
                      ) no-error .
    if error-status:error then do:
      return error substitute( "ошибка при отправке информации по стоплистам на кассы &1&2&1&3"
                          , {&new-line}
                          , error-status:get-message(1)
                          , return-value
          ).
    end.
  end.
end.
if can-find (first  pdf-list ) then do:
  run str/sendpdfr.p (
                       input parparentproc
                      ,input this-procedure:handle
                      ,input p-log-handle
                      ,input "N"
                      ) no-error.
end.
if sendEMRC or sendMarkType or sendGisMt then do:
for each buf_clients no-lock
      where buf_clients.obj-type = {&shop}
        and buf_clients.db-num   = p-db-num,
      first buf_cash-desk no-lock where
           buf_cash-desk.db-num = p-db-num
       AND buf_cash-desk.obj-code = buf_clients.obj-code
       AND buf_cash-desk.cash-on = yes
  on error undo, return error
  :
   if sendEMRC then
   do:
       run str/send-all.p (
                           input parparentproc
                          ,input this-procedure:handle
                          ,input p-log-handle
                          ,input buf_clients.obj-type + {&delim-par} + string(buf_clients.obj-code) + {&delim-par} + 'D':U + {&delim-par} + 'emrc':U + {&delim-par} + 'Передача справочника ЕМЦ':U
                          ) no-error.
       run str/send-all.p (
                           input parparentproc
                          ,input this-procedure:handle
                          ,input p-log-handle
                          ,input buf_clients.obj-type + {&delim-par} + string(buf_clients.obj-code) + {&delim-par} + 'U':U + {&delim-par} + 'emrc':U + {&delim-par} + 'Передача справочника ЕМЦ':U
                          ) no-error.
   end.
   if sendMarkType then
   do:
       run str/send-all.p (
                           input parparentproc
                          ,input this-procedure:handle
                          ,input p-log-handle
                          ,input buf_clients.obj-type + {&delim-par} + string(buf_clients.obj-code) + {&delim-par} + 'U':U + {&delim-par} + 'MarkType':U + {&delim-par} + 'Передача типов маркировки':U
                          ) no-error.
   end.
   if sendGisMt then
   do:
       run str/send-all.p (
                           input parparentproc
                          ,input this-procedure:handle
                          ,input p-log-handle
                          ,input buf_clients.obj-type + {&delim-par} + string(buf_clients.obj-code) + {&delim-par} + 'U':U + {&delim-par} + 'gismt':U + {&delim-par} + 'Передача параметров работы с ТСПИоТ':U
                          ) no-error.
   end.
end.
end.
if settingUpd then do:
   { gbl/objserref.i }
end.
procedure sendnall_get-pdf : /*callback*/
define input-output parameter p-ii as integer no-undo .
define output parameter p-plt-id as integer no-undo .
define output parameter p-plt-db-num as integer no-undo .
define output parameter p-pdf-id as integer no-undo .
define output parameter p-pdf-db-num as integer no-undo .
define output parameter p-del as logical no-undo .

find first pdf-list where
          pdf-list.order-num > p-ii no-error.
if available pdf-list then do:
   assign
   p-plt-id = pdf-list.plt-id
   p-plt-db-num = pdf-list.plt-db-num
   p-pdf-id = pdf-list.pdf-id
   p-pdf-db-num = pdf-list.pdf-db
   p-ii = pdf-list.order-num
   p-del = pdf-list.to-del
   .
end.
end procedure. /* get-pdf */