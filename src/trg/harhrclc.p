block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Перерасчет межфирменных архивов

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/11/06

*/


define input  parameter p-cat-code       like ub.hold-time.cat-code no-undo .
define input  parameter p-lock-code      as character no-undo .
define input  parameter p-btpr-type-code as character no-undo .
define input  parameter p-start-date     like ub.hold-time.start-date no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Перерасчет межфирменных архивов".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4':u,p-cat-code,p-lock-code,p-btpr-type-code,p-start-date)" }
{ cmp/trg-def.i  }
{ gbl/lastdate.i }
{ trg/harhcrht.i }
{ gbl/waitfram.i }

define buffer del_hold-time           for ub.hold-time .
define buffer del_hold-trn            for ub.hold-trn .
define buffer del_hold-goods          for ub.hold-goods .
define buffer del_hold-gds-grp        for ub.hold-gds-grp .
define buffer del_hold-purch          for ub.hold-purch .
define buffer del_hold-purch-grp      for ub.hold-purch-grp .
define buffer del_hold-purch-supp     for ub.hold-purch-supp .
define buffer del_hold-purch-supp-gds for ub.hold-purch-supp-gds .
define buffer del_hold-sale           for ub.hold-sale .
define buffer del_hold-sale-grp       for ub.hold-sale-grp .

define buffer buf_trn-doc for ub.trn-doc .
define buffer buf_db      for ub.db .
define buffer buf_clients for ub.clients .

do
on error undo, return error
:

  find first del_hold-time exclusive-lock
    where del_hold-time.cat-code   = p-cat-code
      and del_hold-time.time-type  = {&harh-type-month}
      and del_hold-time.start-date = p-start-date
    no-error .
  if not available del_hold-time
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись межфирменного архива" skip
      "cat-code" p-cat-code skip
      "time-type" {&harh-type-month} skip
      "start-date" p-start-date skip
      view-as alert-box error .
    undo, return error.
  end.

  assign
    del_hold-time.status_        = {&deleted}
    del_hold-time.grpupdate-date = today
    del_hold-time.update-date    = today
  .

  define variable v-ind as integer   no-undo .

  assign
    v-ind = 0
  .

  for each del_hold-trn
    where del_hold-trn.cat-code  = del_hold-time.cat-code
      and del_hold-trn.time-code = del_hold-time.time-code
  on error undo, return error
  :
    assign
      v-ind = v-ind + 1
    .
    if v-ind modulo 10 = 0
    then do:
      run waitfram-show in this-procedure
        (input substitute("Перерасчет межфирменных архивов. Удаление списка документов за период. Удалено &1."
                          ,v-ind
                          )
        ) .
    end.

    delete del_hold-trn .
  end.

  assign
    v-ind = 0
  .

  for each del_hold-goods
    where del_hold-goods.cat-code  = del_hold-time.cat-code
      and del_hold-goods.time-code = del_hold-time.time-code
  on error undo, return error
  :
    assign
      v-ind = v-ind + 1
    .
    if v-ind modulo 10 = 0
    then do:
      run waitfram-show in this-procedure
        (input substitute("Перерасчет межфирменных архивов. Удаление списка товаров за период. Удалено &1."
                          ,v-ind
                          )
        ) .
    end.

    delete del_hold-goods .
  end.

  assign
    v-ind = 0
  .

  for each del_hold-gds-grp
    where del_hold-gds-grp.cat-code  = del_hold-time.cat-code
      and del_hold-gds-grp.time-code = del_hold-time.time-code
  on error undo, return error
  :
    assign
      v-ind = v-ind + 1
    .
    if v-ind modulo 10 = 0
    then do:
      run waitfram-show in this-procedure
        (input substitute("Перерасчет межфирменных архивов. Удаление списка групп товаров за период. Удалено &1."
                          ,v-ind
                          )
        ) .
    end.

    delete del_hold-gds-grp .
  end.

  assign
    v-ind = 0
  .

  for each del_hold-purch
    where del_hold-purch.cat-code  = del_hold-time.cat-code
      and del_hold-purch.time-code = del_hold-time.time-code
  on error undo, return error
  :
    assign
      v-ind = v-ind + 1
    .
    if v-ind modulo 10 = 0
    then do:
      run waitfram-show in this-procedure
        (input substitute("Перерасчет межфирменных архивов. Удаление списка приходов за период. Удалено &1."
                          ,v-ind
                          )
        ) .
    end.

    delete del_hold-purch .
  end.

  assign
    v-ind = 0
  .

  for each del_hold-purch-grp
    where del_hold-purch-grp.cat-code  = del_hold-time.cat-code
      and del_hold-purch-grp.time-code = del_hold-time.time-code
  on error undo, return error
  :
    assign
      v-ind = v-ind + 1
    .
    if v-ind modulo 10 = 0
    then do:
      run waitfram-show in this-procedure
        (input substitute("Перерасчет межфирменных архивов. Удаление списка приходов по группам за период. Удалено &1."
                          ,v-ind
                          )
        ) .
    end.

    delete del_hold-purch-grp .
  end.

  assign
    v-ind = 0
  .

  for each del_hold-purch-supp
    where del_hold-purch-supp.cat-code  = del_hold-time.cat-code
      and del_hold-purch-supp.time-code = del_hold-time.time-code
  on error undo, return error
  :
    assign
      v-ind = v-ind + 1
    .
    if v-ind modulo 10 = 0
    then do:
      run waitfram-show in this-procedure
        (input substitute("Перерасчет межфирменных архивов. Удаление списка приходов по поставщикам за период. Удалено &1."
                          ,v-ind
                          )
        ) .
    end.

    delete del_hold-purch-supp .
  end.

  assign
    v-ind = 0
  .

  for each del_hold-purch-supp-gds
    where del_hold-purch-supp-gds.cat-code  = del_hold-time.cat-code
      and del_hold-purch-supp-gds.time-code = del_hold-time.time-code
  on error undo, return error
  :
    assign
      v-ind = v-ind + 1
    .
    if v-ind modulo 10 = 0
    then do:
      run waitfram-show in this-procedure
        (input substitute("Перерасчет межфирменных архивов. Удаление списка приходов по поставщикам по товарам за период. Удалено &1."
                          ,v-ind
                          )
        ) .
    end.

    delete del_hold-purch-supp-gds .
  end.

  assign
    v-ind = 0
  .

  for each del_hold-sale
    where del_hold-sale.cat-code  = del_hold-time.cat-code
      and del_hold-sale.time-code = del_hold-time.time-code
  on error undo, return error
  :
    assign
      v-ind = v-ind + 1
    .
    if v-ind modulo 10 = 0
    then do:
      run waitfram-show in this-procedure
        (input substitute("Перерасчет межфирменных архивов. Удаление списка продаж за период. Удалено &1."
                          ,v-ind
                          )
        ) .
    end.

    delete del_hold-sale .
  end.

  assign
    v-ind = 0
  .

  for each del_hold-sale-grp
    where del_hold-sale-grp.cat-code  = del_hold-time.cat-code
      AND del_hold-sale-grp.time-code = del_hold-time.time-code
  on error undo, return error
  :
    assign
      v-ind = v-ind + 1
    .
    if v-ind modulo 10 = 0
    then do:
      run waitfram-show in this-procedure
        (input substitute("Перерасчет межфирменных архивов. Удаление списка продаж по группам за период. Удалено &1."
                          ,v-ind
                          )
        ) .
    end.

    delete del_hold-sale-grp .
  end.

  for each buf_db no-lock
  ,each buf_clients no-lock
    where buf_clients.db-num = buf_db.db-num
  ,each buf_trn-doc no-lock
    where buf_trn-doc.obj-type = buf_clients.obj-type
      and buf_trn-doc.obj-code = buf_clients.obj-code
      and buf_trn-doc.status_ = {&fact}
      and buf_trn-doc.fact-date >= del_hold-time.start-date
      and buf_trn-doc.fact-date <= del_hold-time.end-date
  on error undo, return error
  :
    run waitfram-show in this-procedure
      (input substitute("Перерасчет межфирменных архивов. Документ &1. Дата &2"
                        ,buf_trn-doc.doc-code
                        ,buf_trn-doc.fact-date
                        )
      ) .

    define buffer buf_BatchProcess for ub.BatchProcess .
    find first buf_BatchProcess exclusive-lock
      where buf_BatchProcess.bp_type     = p-btpr-type-code
        and buf_BatchProcess.bp_status   = {&btpr-normal}
        and buf_batchprocess.charkey_one = buf_trn-doc.doc-code
      no-error .
    if available buf_BatchProcess
    then do:
      delete buf_BatchProcess .
    end.

    run trg/harhtclc.p
      (input p-cat-code           /* p-cat-code       */
      ,input p-lock-code          /* p-lock-type      */
      ,input p-btpr-type-code     /* p-btpr-type-code */
      ,input buf_trn-doc.doc-code /* p-doc-code       */
      ) no-error .
    if error-status :error
    then do:
      undo,
      return error ("Ошибка при расчете межфирменного архива:" + {&new-line} +
                    "cat-code:" + {&space-char} + string(p-cat-code) + {&new-line} +
                    "time-code:" + {&space-char} + string(del_hold-time.time-code) + {&new-line} +
                    "документ:" + {&space-char} + buf_trn-doc.doc-code + {&new-line}
                    ).
    end.
  end.

  assign
    del_hold-time.status_ = {&current}
  .

  run waitfram-hide in this-procedure .
end.