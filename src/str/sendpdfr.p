block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: sendpdfr.p $
$Archive: str/sendpdfr.p $

Пересылка ДНЦ на кассу

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/22/09
Author: Bakhtadze Natalya
Creation date: 03/22/09

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sendpdfr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/sendpdfr.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ ref/xobjgrp.i }
{ str/pdf-list.i pdf-list def }

/*
  run str/diallog.w
              ( input parparentproc
              , input this-procedure
              , input 'str/sendpdfr.p':U
              , input ("U":U + {&delim-par} +
                      string(buf_price-doc-forming.plt-id) + {&delim-par}  +
                      string(buf_price-doc-forming.plt-db-num) + {&delim-par} +
                      string(buf_price-doc-forming.pdf-id) + {&delim-par}  +
                      string(buf_price-doc-forming.pdf-db-num)
                      )
              , input yes /*p-auto-go*/
              , input '':U
              , input '') no-error .

или

  run str/diallog.w
              ( input parparentproc
              , input this-procedure
              , input 'str/sendpdfr.p':U
              , input "N":U
              , input yes /*p-auto-go*/
              , input '':U
              , input '') no-error .

 из внешних систем и новостей
 */

define variable pdf-action as character no-undo.
define variable p-pdf-id like ub.price-doc-forming.pdf-id no-undo .
define variable p-pdf-db like ub.price-doc-forming.pdf-db no-undo .
define variable p-plt-id like ub.price-doc-forming.plt-id no-undo .
define variable p-plt-db-num like ub.price-doc-forming.plt-db-num no-undo .

define variable v-pdf-id like ub.price-doc-forming.pdf-id no-undo .
define variable v-pdf-db like ub.price-doc-forming.pdf-db no-undo .
define variable v-plt-id like ub.price-doc-forming.plt-id no-undo .
define variable v-plt-db-num like ub.price-doc-forming.plt-db-num no-undo .
define variable v-ii as integer no-undo .
define variable v-del as logical no-undo .


define buffer buf_price-doc-forming for ub.price-doc-forming.
define buffer buf_cash-desk for ub.cash-desk.
assign
pdf-action = entry(1, p-parameter, {&delim-par})
.
case pdf-action :
  when "N" then do:
    do while p-pdf-id <> 0
    or v-ii = 0:
      v-pdf-id = 0.
      run sendnall_get-pdf in p-parent-handle (  input-output v-ii
                                       ,output v-plt-id
                                       ,output v-plt-db-num
                                       ,output v-pdf-id
                                       ,output v-pdf-db
                                       ,output v-del
                                       ) no-error.
      if not error-status:error then do:
        run fill-pdf in this-procedure (
                                   input v-plt-id
                                  ,input v-plt-db-num
                                  ,input v-pdf-id
                                  ,input v-pdf-db
                                  ,input (pdf-action = "D")
                                  ).
      end.
      else leave.
    end.
  end.
  when "U"
  or when "D"
  then do:
    assign
    p-plt-id = integer(entry(2, p-parameter, {&delim-par}))
    p-plt-db-num = integer(entry(3, p-parameter, {&delim-par}))
    p-pdf-id = integer(entry(4, p-parameter, {&delim-par}))
    p-pdf-db = integer(entry(5, p-parameter, {&delim-par}))
    no-error
    .
    if  error-status:error then return error substitute("Неверные значения параметров").
    find first buf_price-doc-forming no-lock where
            buf_price-doc-forming.plt-id = p-plt-id
        and buf_price-doc-forming.plt-db-num = p-plt-db-num
        and buf_price-doc-forming.pdf-id = p-pdf-id
        and buf_price-doc-forming.pdf-db = p-pdf-db
            no-error .
    if not available buf_price-doc-forming then return error substitute("Не найден ДНЦ &1 по БД &2 (ТПЛ &3 от БД &4)"
                                                        ,p-pdf-id
                                                        ,p-pdf-db
                                                        ,p-plt-id
                                                        ,p-plt-db-num).
    run fill-pdf in this-procedure (
                               input p-plt-id
                              ,input p-plt-db-num
                              ,input p-pdf-id
                              ,input p-pdf-db
                              ,input (pdf-action = "D")
                              ).

  end.
  otherwise do:
    return error substitute("Неизвестное значение параметра pdf-action=&1", pdf-action).
  end.
end.

for each pdf-list :
  empty temp-table X_obj-group.
  run metod-obj-pdf in this-procedure ( input g#db-num
                                      ,input pdf-list.pdf-id
                                      ,input pdf-list.pdf-db
                                      ,input pdf-list.plt-id
                                      ,input pdf-list.plt-db-num
                                      ) no-error.

  for each X_obj-group no-lock where
          X_obj-group.obj-type = {&shop}
      and X_obj-group.db-num = g#db-num,
        first buf_cash-desk no-lock where
            buf_cash-desk.db-num = g#db-num
        AND buf_cash-desk.obj-code = X_obj-group.obj-code
        AND buf_cash-desk.cash-on = yes:

      run set-title in p-log-handle ( input substitute('Отсылка ДНЦ &1 на кассу', pdf-list.pdf-id)).
      run str/send-pdf.p (
                    input parparentproc
                    ,input p-parent-handle
                    ,input p-log-handle
                    ,input ("U":U + {&delim-par} +
                          string(pdf-list.plt-id) + {&delim-par}  +
                          string(pdf-list.plt-db-num) + {&delim-par} +
                          string(pdf-list.pdf-id) + {&delim-par}  +
                          string(pdf-list.pdf-db) + {&delim-par} +
                          string(X_obj-group.obj-code))
                      ) no-error .
      if error-status:error then
      return error substitute( "ошибка при отправке ДНЦ на кассу по магазину &1&2&3&2&4"
                              , X_obj-group.obj-code
                              , {&new-line}
                              , error-status:get-message(1)
                              , return-value
                              ).
  end.
end.

procedure fill-pdf :
define input parameter p-plt-id as integer no-undo .
define input parameter p-plt-db-num as integer no-undo .
define input parameter p-pdf-id as integer no-undo .
define input parameter p-pdf-db-num as integer no-undo .
define input parameter p-del as logical no-undo .
define buffer buf_pdf-list for pdf-list.

do
on error undo, return error
:
  find first pdf-list where
           pdf-list.plt-id = p-plt-id
       and pdf-list.plt-db-num = p-plt-db-num
       and pdf-list.pdf-id = p-pdf-id
       and pdf-list.pdf-db = p-pdf-db-num no-error.
  if not available pdf-list then do:
    find last buf_pdf-list use-index oi no-error.
    create pdf-list.
    assign
    pdf-list.plt-id = p-plt-id
    pdf-list.plt-db-num = p-plt-db-num
    pdf-list.pdf-id = p-pdf-id
    pdf-list.pdf-db = p-pdf-db-num
    pdf-list.to-del = p-del
    pdf-list.order-num = (if available buf_pdf-list then buf_pdf-list.order-num + 1 else 1)
    .
    release pdf-list.
  end.
end.

end procedure. /* fill-pdf */
