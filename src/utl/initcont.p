block-level on error undo, throw.
/*

$Revision: 01d4914e5615, 377, rls $
$Author: EShklyar $
$Date: Mon Dec 28 19:14:54 2015 +0300 $
$Workfile: initcont.p $
$Archive: utl/initcont.p $

утилита  инициализации arh-trn-doc-contract

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/27/06
Author: Michael Kochetkov
Creation date: 03/27/06

*/
/*define input parameter parparentproc as widget-handle no-undo*/ .

/* ***************************  Definitions  ************************** */
define variable vss-revision    as character no-undo init "$Revision: 01d4914e5615, 377, rls $":u .
define variable vss-author      as character no-undo init "$Author: EShklyar $":u .
define variable vss-date        as character no-undo init "$Date: Mon Dec 28 19:14:54 2015 +0300 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: initcont.p $":u .
define variable vss-archive     as character no-undo init "$Archive: utl/initcont.p $":u .
define variable vss-description as character no-undo init "утилита инициализации arh-trn-doc-contract " .
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
/*{ cmp/library.i }*/
{ str/libtfarh.i }
{ gbl/clntattr.i }
{ trg/factord.i }
{ cmp/r-page1.i   }
/*{ trg/partslib.i }*/
/*{ str/in-vatp.i def }*/
{ gbl/userobjs.i }
/*{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }*/

on write of ub.arh-trn-doc-contract override do:  end.
on delete of ub.arh-trn-doc-contract override do:  end.

define variable v-str          as CHAR    no-undo .
define variable par-type       as CHAR    no-undo .
define variable p-status       as integer no-undo .
define variable p-cut-date     as date    no-undo .
define variable p-cut-fin-date as date    no-undo.
define variable Counter1       as integer   no-undo .
define variable g-log          as logical   no-undo .
define variable v-fact-order     as decimal   no-undo .
define variable v-cut-fact-order as decimal   no-undo .

define buffer buf_arh-trn-doc-contract for ub.arh-trn-doc-contract.

  run day-begin-fact-order in this-procedure ( input x-date-alone, output v-fact-order ).
    /*Проверим на корректность запрашиваемой даты*/
  for each obj-list on error undo, return error :
    { gbl/cutd-obj.i obj-list.obj-type obj-list.obj-code p-status p-cut-date p-cut-fin-date }
    if p-status = 2 or
       p-status = 4 then do:  /* пересчет после обрезания */
      run factord-end-day in this-procedure ( input p-cut-date - 1, output v-cut-fact-order ).
      if v-fact-order <= v-cut-fact-order then do:
        message "Пересчет архивов должен начинаться с даты большей или равной дате обрезания." skip
                "Объект: " obj-list.obj-code " " obj-list.obj-type skip
                "Дата обрезания:" p-cut-date skip
                "Запрошенная дата пересчета архивов: " x-date-alone skip
                view-as alert-box error.
        return error.
      end.
    end.
  end.

  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 5 } /* Показать окно информации о текущем процессе */

  for each obj-list :
    run calc-archive in this-procedure ( input obj-list.obj-type, input obj-list.obj-code ).
  end.

  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */

  message  "Работа утилиты завершена"   view-as alert-box.


procedure calc-archive :
  do on error undo, return error return-value :
    define input  parameter p-obj-type like ub.clients.obj-type .
    define input  parameter p-obj-code like ub.clients.obj-code .

    for each ub.arh-trn-doc-contract exclusive-lock
      where ub.arh-trn-doc-contract.obj-type = p-obj-type
        and ub.arh-trn-doc-contract.obj-code = p-obj-code
      on error undo, return error return-value :
      if ub.arh-trn-doc-contract.fact-order >= v-fact-order then  delete ub.arh-trn-doc-contract .
    end.

/*    do transaction on error undo, return error return-value :*/
/*      find first db exclusive-lock where db.db-num = clients.db-num .*/
      for each trn-doc no-lock
        where trn-doc.obj-type = obj-list.obj-type
          and trn-doc.obj-code = obj-list.obj-code
          and trn-doc.status_  = {&fact}
          and trn-doc.fact-order >= v-fact-order
        :
        assign Counter1 = Counter1 + 1.
        { rep/repfrm.i disp Counter1 }

        { str/latrncnt.i ub.trn-doc.doc-code no-error }
        if error-status :error then message return-value error-status:get-message(1) view-as alert-box.
        { str/catrncnt.i ub.trn-doc.doc-code no-error }
        if error-status :error then message return-value error-status:get-message(1) view-as alert-box.
      end.
      run clntattr-delete in this-procedure ( input obj-list.obj-type,input obj-list.obj-code, input {&attr-arh-trn-doc-contract}, output v-str) .
/*    end.*/
  end.
end procedure. /* calc-archive */