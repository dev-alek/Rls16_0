block-level on error undo, throw.
define input  parameter parparentproc       as widget-handle no-undo .
define input  parameter p-curr-host-code    like ub.sysconf.host-code no-undo .
define input  parameter p-curr-obj-type     like ub.clients.obj-type no-undo .
define input  parameter p-curr-obj-code     like ub.clients.obj-code no-undo .
define input  parameter p-doc-code-list     as character no-undo .
define input  parameter p-doc-type-list     as character no-undo .
define output parameter p-new-doc-code-list as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: doclsted.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/doclsted.p $":U .
define variable vss-description as character no-undo init "Редактировать список документов в символьной переменной".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table doc-list no-undo
field doc-date   like ub.trn-doc.doc-date
field doc-code   like ub.trn-doc.doc-code
field obj-type   like ub.trn-doc.obj-type
field obj-code   like ub.trn-doc.obj-code
field fact-num   like ub.trn-doc.fact-num
field fact-date  like ub.trn-doc.fact-date
field shift-date like ub.trn-doc.shift-date
field shift-num  like ub.trn-doc.shift-num
field shift-name like ub.trn-doc.shift-name
field fact-order as decimal
field is-trn-doc as logical
field is-del as logical
field doc-type   like ub.trn-doc.doc-type
field ext-doc-type   like ub.trn-doc.ext-doc-type
field sel-order  as integer
field znak       as integer
field to-del     as logical
field is-archive-exist as logical
index xpk is primary unique doc-code doc-type
index xfact fact-num
index xfact-date fact-date
index sel-order sel-order
index znak-order znak sel-order
index isdel is-del
.
define buffer inkas_trn-doc for ub.trn-doc .
define buffer c-inkas_trn-doc for ub.c-trn-doc .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define   new shared   temp-table doc-list-hist no-undo
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
define variable lns-cnt  as integer   no-undo .
define variable line-rec as recid     no-undo .
define buffer buf_trn-doc  for ub.trn-doc .
define buffer buf_doc-list for doc-list .
define variable v-ind                  as integer   no-undo .
define variable v-doc-list-num-entries as integer   no-undo .
do
on error undo, return error return-value
:
  assign
    v-doc-list-num-entries = num-entries(p-doc-code-list, chr(44))
  .
  do v-ind = 1 to v-doc-list-num-entries
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = entry(v-ind, p-doc-code-list, chr(44))
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Код документа" entry(v-ind, p-doc-code-list, chr(44)) skip
        "Номер элемента" v-ind skip
        view-as alert-box error .
    end.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find doc-list
  where doc-list.doc-code = buf_trn-doc.doc-code
    and doc-list.doc-type = buf_trn-doc.doc-type
  no-error .
if available doc-list then do:
  assign
    doc-list.to-del = no
  .
end.
else do:
  create doc-list .
  assign
  doc-list.doc-code   = buf_trn-doc.doc-code
  doc-list.obj-type   = buf_trn-doc.obj-type
  doc-list.obj-code   = buf_trn-doc.obj-code
  doc-list.fact-num   = buf_trn-doc.fact-num
  doc-list.doc-date   = buf_trn-doc.doc-date
  doc-list.fact-date  = buf_trn-doc.fact-date
  doc-list.shift-date = buf_trn-doc.shift-date
  doc-list.shift-num  = buf_trn-doc.shift-num
  doc-list.fact-order = buf_trn-doc.fact-order
  doc-list.is-trn-doc = yes
  doc-list.is-del     = no
  doc-list.doc-type   = buf_trn-doc.doc-type
  doc-list.ext-doc-type   = buf_trn-doc.ext-doc-type
  doc-list.sel-order  = v-ind
  doc-list.znak       = if can-do ('рас,спи':U, doc-list.doc-type) then -1 else 1
  doc-list.to-del = no
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (doc-list)
  .
end.
  end.
  run str/doc-liso.w
    (input  parparentproc
    ,input  p-curr-host-code
    ,input  p-curr-obj-type
    ,input  p-curr-obj-code
    ) .
  define variable v-doc-list as character no-undo .
  assign
    v-doc-list = ''
  .
  define variable v-show-err-message as logical   no-undo .
  assign
    v-show-err-message = true
  .
  check_doc:
  for each buf_doc-list
  by buf_doc-list.sel-order
  :
    if lookup(buf_doc-list.doc-type, p-doc-type-list) = 0
    then do:
      if v-show-err-message = true
      then do:
        message
          "Нельзя указывать для ограничения резервирования документы типа" skip
          "" buf_doc-list.doc-type skip
          "Документ с номером" buf_doc-list.doc-code skip
          "не будет включен в список документов" skip
          "Продолжать информировать об исключенных документах?"
          view-as alert-box question buttons yes-no update v-show-err-message .
      end.
      next check_doc .
    end.
    assign
      v-doc-list = v-doc-list
                 + (if v-doc-list <> '' then chr(44) else '')
                 + buf_doc-list.doc-code
    .
    if length(v-doc-list) > 10000
    then do:
      message
        "Строковый список документов может содержать только ограниченное число документов" skip
        "Всего будет учтено документов" num-entries(v-doc-list, chr(44)) skip
        "Оставшиеся документы будут проигнорированы" skip
        "Работа программы будет продолжена" skip
        view-as alert-box information .
      leave .
    end.
  end.
  assign
    p-new-doc-code-list = v-doc-list
  .
end.
