block-level on error undo, throw.
define input-output parameter par-rid as recid no-undo .
define input parameter par-mode as character no-undo .
define input parameter p-db-num like ub.fbr-prn.db-num no-undo .
define input parameter p-prn-num like ub.fbr-prn.prn-num no-undo .
define input parameter p-obj-type like ub.fbr-prn-grp.obj-type no-undo .
define input parameter p-obj-code like ub.fbr-prn-grp.obj-code no-undo .
define input parameter p-node-code like ub.fbr-prn-grp.node-code no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fprngrp1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/fprngrp1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений связки принтер кухни-группа товаров".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable var-entry as character no-undo .
define variable v-db-num like ub.db.db-num no-undo .
define buffer buf_fbr-prn-grp for ub.fbr-prn-grp .
define buffer buf_clients for ub.clients.
if par-mode <> 'ДОБАВЛЕНИЕ':U AND par-mode <> 'ИЗМЕНЕНИЕ':U then do:
  message vss-workfile vss-revision vss-description skip
          "Неверный параметр par-mode - " par-mode
  view-as alert-box error .
  return error '':u.
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
if p-db-num <> v-db-num then do:
  assign
  var-entry = "db-num":U
  .
  message
  vss-workfile vss-revision vss-description skip
  "Нельзя вводить группы для принтера в чужой БД"
  view-as alert-box error .
  return error var-entry.
end.
if p-node-code = 0 then do:
  assign
  var-entry = "node-code":U
  .
  message
  "Укажите группу товара"
  view-as alert-box error .
  return error var-entry.
end.
if p-prn-num = 0 then do:
  assign
  var-entry = "prn-num":U
  .
  message
  "Укажите номер принтера"
  view-as alert-box error .
  return error var-entry.
end.
find first buf_clients no-lock where
          buf_clients.obj-type = p-obj-type
     AND  buf_clients.obj-code = p-obj-code no-error .
if p-obj-type = "":u
or p-obj-code = 0
or not available buf_clients
then do:
  assign
  var-entry = "obj-code":U
  .
  message
  "Укажите объект"
  view-as alert-box error .
  return error var-entry.
end.
if buf_clients.db-num <> v-db-num then do:
  assign
  var-entry = "obj-code":U
  .
  message
  "Укажите объект текущей БД"
  view-as alert-box error .
  return error var-entry.
end.
if LOOKUP(p-obj-type, ('маг':U + chr(44) + 'скл':U)) = 0 then do:
  assign
  var-entry = "obj-type":U
  .
  message
  "Объект может быть только " 'маг':U "или" 'скл':U
  view-as alert-box error .
  return error var-entry.
end.
_main:
do
on error undo _main, return error
:
  CASE par-mode:
    when 'ДОБАВЛЕНИЕ':U then do:
      find first buf_fbr-prn-grp no-lock where
                 buf_fbr-prn-grp.node-code = p-node-code
             AND buf_fbr-prn-grp.obj-type = p-obj-type
             AND buf_fbr-prn-grp.obj-code = p-obj-code no-error .
      if available buf_fbr-prn-grp then do:
        assign
        var-entry = "p-node-code"
        .
        message
        "Для группы товаров" p-node-code skip
        "уже определен принтер на объекте" p-obj-type p-obj-code
        view-as alert-box error .
        return error var-entry.
      end.
      create ub.fbr-prn-grp.
    end.
    when 'ИЗМЕНЕНИЕ':U then do:
      find first ub.fbr-prn-grp exclusive-lock where
                recid(ub.fbr-prn-grp) = par-rid no-error .
      if not available ub.fbr-prn-grp
      then do:
        assign
        var-entry = "node-code":U
        .
        message
        "Не определен кухни для группы" p-node-code skip
        "на объекте" p-obj-type p-obj-code
        view-as alert-box error .
        return error var-entry.
      end.
      IF ub.fbr-prn-grp.obj-type <> p-obj-type
      OR ub.fbr-prn-grp.obj-code <> p-obj-code
      OR ub.fbr-prn-grp.node-code <> p-node-code
      OR ub.fbr-prn-grp.db-num <> p-db-num
      OR ub.fbr-prn-grp.prn-num <> p-prn-num
      then do:
        assign
        var-entry = "":U
        .
        message
        "Для записи группы товара на принтере кухни нельзя изменять поля первичного ключа"  skip
        view-as alert-box error .
        return error var-entry.
      end.
    end.
  END CASE.
  assign
  ub.fbr-prn-grp.node-code = p-node-code
  ub.fbr-prn-grp.prn-num = p-prn-num
  ub.fbr-prn-grp.db-num = p-db-num
  ub.fbr-prn-grp.obj-type = p-obj-type
  ub.fbr-prn-grp.obj-code = p-obj-code
  par-rid = recid(ub.fbr-prn-grp)
  .
end.
