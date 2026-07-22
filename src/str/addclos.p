block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: addclos.p $
$Archive: str/addclos.p $

Процедура закрытия документа допрасхода

Автор: Чернова Светлана Александровна
Дата создания: 02/05/08
Author: Svetlana Chernova
Creation date: 02/05/08


*/

define input  parameter parparentproc as handle no-undo .
define input  parameter p-recid as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: addclos.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/addclos.p $":U .
define variable vss-description as character no-undo init "Процедура закрытия документа допрасхода".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ cmp/gds-list.i gds-list def "new shared"}

define buffer buf_add-doc for ub.add-doc  .
define buffer buf_trn-doc for ub.trn-doc  .
define variable v-t as integer   no-undo .
define variable v-i as integer   no-undo .
define variable g-log as logical   no-undo .
define variable o-db-num as integer   no-undo .

find first buf_add-doc  no-lock where recid(buf_add-doc) = p-recid no-error .
if not available buf_add-doc then return.


if buf_add-doc.status_ = {&fact} then do:
  message 'Документ ДопРасходов уже закрыт на факт' view-as alert-box information .
  return .
end.

case buf_add-doc.status_ :
  when  {&g___new} then do:
      v-i = 0.
      v-t = 0 .
      for each ub.add-trn no-lock where
              ub.add-trn.doc-code = buf_add-doc.doc-code :
          find first buf_trn-doc no-lock where
                    buf_trn-doc.doc-code = ub.add-trn.trn-doc-code no-error .
            if available buf_trn-doc then do:
                  if buf_add-doc.base-rate <>  buf_trn-doc.base-rate  then v-t = 2 .
                  if buf_add-doc.base-scale <> buf_trn-doc.base-scale then v-t = 2 .

          end.
          v-i = v-i + 1.
      end.
      if v-t <> 0 then do:
        message 'Курс базовой валюты не соответствует накладным !!!'
        view-as alert-box information .
        return .
      end.

      if v-i = 0 then do:
        message 'Нет ни одной связки с ПН'
        view-as alert-box information .
        return .
      end.

      v-i = 0.
      for each ub.add-line no-lock where
              ub.add-line.doc-code = buf_add-doc.doc-code :
          v-i = v-i + 1.
      end.

      if v-i = 0 then do:
        message 'Нет ни одной строки в документе !'
        view-as alert-box information .
        return .
      end.

      find current buf_add-doc exclusive-lock no-error .
      if available buf_add-doc then do:
      assign
          buf_add-doc.status_         = {&add-close}
            buf_add-doc.incfo-date      = 01/01/1990
            buf_add-doc.cr-incfo        = no
            buf_add-doc.need-incfo      = 0
            buf_add-doc.factur-date     = 01/01/1990
            buf_add-doc.cr-factur       = no
            buf_add-doc.need-factur     = 0

      .
      end.
  end.
  when {&add-close}
  then do:

      { gbl/objdbnum.i
        buf_add-doc.obj-type
        buf_add-doc.obj-code
        o-db-num
        }
        if o-db-num <> v-cntxt-db-num then do:
          message 'Закрыть на ФАКТ можно на активной стороне!' view-as alert-box information .
          return .
        end.



        run close-fact (buf_add-doc.doc-code) no-error .
        if error-status :error then do:
          message
            error-status :get-message(1) skip
            return-value skip
            "Ошибка при закрытии приходных накладных"
            view-as alert-box error
          .
          return.
        end.
      find current buf_add-doc exclusive-lock no-error .
      if available buf_add-doc then do:
        assign
            buf_add-doc.status_         = {&fact}
        .
        end.
  end.
end case.

PROCEDURE close-fact :
define input  parameter  p-doc-code as character no-undo .

define variable varcheck-return as logical no-undo .
define variable varchg-inv as logical no-undo .
define variable v-cntxt-cash-pay  as integer   no-undo .
define variable v-cntxt-in-ov     as logical   no-undo .
define variable v-cntxt-base-code as integer   no-undo .
define variable v-cntxt-rsrv-time as integer   no-undo .
define variable v-cntxt-load-time as integer   no-undo .
define variable v-cntxt-holidays  as character no-undo .
define variable g#log as logical  no-undo .

define buffer buf_sysconf for ub.sysconf  .
find first buf_sysconf where buf_sysconf.host-code = buf_add-doc.host-code no-lock.

assign
  v-cntxt-cash-pay   = buf_sysconf.cash-pay
  v-cntxt-base-code  = buf_sysconf.base-code
  v-cntxt-in-ov      = buf_sysconf.in-ov
  v-cntxt-rsrv-time  = buf_sysconf.rsrv-time
  v-cntxt-load-time  = buf_sysconf.load-time
  v-cntxt-holidays   = buf_sysconf.holidays
.


define buffer buf_trn-doc for ub.trn-doc  .
tr:
do transaction
   ON ERROR   UNDO tr, LEAVE
   ON END-KEY UNDO tr, LEAVE
   ON STOP    UNDO tr , LEAVE :

for each ub.add-trn no-lock where
         ub.add-trn.doc-code = p-doc-code :
     find first  buf_trn-doc no-lock where
                 buf_trn-doc.doc-code = ub.add-trn.trn-doc-code
                 no-error .
     if not available buf_trn-doc then do:
        message 'Не найдена ПН с №' ub.add-trn.trn-doc-code
        view-as alert-box information .
        undo, return error return-value .
     end.

     if buf_trn-doc.tot-other  <> 0 or
        buf_trn-doc.tot-transp <> 0 then do:
          run str/add-exp.p (input parparentproc,
                          input buf_trn-doc.doc-code ,
                          input buf_trn-doc.tot-other  * buf_trn-doc.exch-rate / buf_trn-doc.exch-scale,
                          input buf_trn-doc.tot-transp * buf_trn-doc.exch-rate / buf_trn-doc.exch-scale) no-error.
          if error-status :error
          then do:
            undo, return error substitute ( "Ошибка при установке дополнительных расходов &1 .", return-value ).
          end.
     end.
end.

run str/addsuper.p (parparentproc , p-doc-code ) no-error .
if error-status :error then do:
   message
     vss-workfile vss-revision vss-description skip
     error-status :get-message(1) skip
     return-value skip
     "Ошибка размазывания ДопРасходов в учетную цену  (addsuper.p)"
     view-as alert-box error
   .
   undo, return error return-value .
end.

for each ub.add-trn no-lock where
         ub.add-trn.doc-code = p-doc-code:
     find first  buf_trn-doc no-lock where
                 buf_trn-doc.doc-code = ub.add-trn.trn-doc-code no-error .
     if available buf_trn-doc then do:
        /* закроем сразу на ФАКТ */
           run str/trn-stat.p (
                input  parparentproc ,
                input  this-procedure  ,
                input  (if buf_trn-doc.flag_  then  {&close-doc} else  {&close-fact}) ,
                input  buf_trn-doc.doc-code,
                input  varcheck-return  ,
                input  v-cntxt-db-num   ,
                input  v-cntxt-in-ov    ,
                input  v-cntxt-rsrv-time,
                input  v-cntxt-load-time,
                input  v-cntxt-holidays ,
                input  yes ,
                output varchg-inv ,
                output table gds-list) no-error .
          if error-status:error then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при принудительном закрытии документа " buf_trn-doc.doc-code skip
              return-value skip
              error-status :get-message(1)
              view-as alert-box error.
            undo, return error return-value .
          end.
     end.
end.
end.
END PROCEDURE.


PROCEDURE many-add-docs :
define output parameter p-reply as logical   no-undo .
p-reply = true .
END PROCEDURE.