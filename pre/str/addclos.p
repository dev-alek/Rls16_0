block-level on error undo, throw.
define input  parameter parparentproc as handle no-undo .
define input  parameter p-recid as recid no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: addclos.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/addclos.p $":U .
define variable vss-description as character no-undo init "Процедура закрытия документа допрасхода".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table gds-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define buffer buf_add-doc for ub.add-doc  .
define buffer buf_trn-doc for ub.trn-doc  .
define variable v-t as integer   no-undo .
define variable v-i as integer   no-undo .
define variable g-log as logical   no-undo .
define variable o-db-num as integer   no-undo .
find first buf_add-doc  no-lock where recid(buf_add-doc) = p-recid no-error .
if not available buf_add-doc then return.
if buf_add-doc.status_ = 'факт':U then do:
  message 'Документ ДопРасходов уже закрыт на факт' view-as alert-box information .
  return .
end.
case buf_add-doc.status_ :
  when  'новый':U then do:
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
          buf_add-doc.status_         = 'закрыт':U
            buf_add-doc.incfo-date      = 01/01/1990
            buf_add-doc.cr-incfo        = no
            buf_add-doc.need-incfo      = 0
            buf_add-doc.factur-date     = 01/01/1990
            buf_add-doc.cr-factur       = no
            buf_add-doc.need-factur     = 0
      .
      end.
  end.
  when 'закрыт':U
  then do:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  buf_add-doc.obj-type
  ,input  buf_add-doc.obj-code
  ,output o-db-num
  )  .
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
            buf_add-doc.status_         = 'факт':U
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
           run str/trn-stat.p (
                input  parparentproc ,
                input  this-procedure  ,
                input  (if buf_trn-doc.flag_  then  '<закрытие документа>':U else  '<закрытие документа на факт>':U) ,
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
