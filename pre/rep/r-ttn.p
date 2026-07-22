block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-ttn.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-ttn.p $":U .
define variable vss-description as character no-undo init "заказная программа - суммарное кол-во товаров по списку док-ов".
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
define input  parameter p-doc-list as character no-undo .
define variable v-list-index as integer   no-undo .
define variable v-qnty as decimal   no-undo .
define variable is-torg12 as logical   no-undo .
define variable is-torg13 as logical   no-undo .
define buffer buf_trn-doc for trn-doc.
define buffer buf_doc-line for trn-doc.
define  stream str-export12.
define  stream str-export13.
  if p-doc-list = "" then do:
    message "Нет выбранных документов!"  view-as alert-box.
    return.
  end.
  do v-list-index = 1 to num-entries( p-doc-list ):
    find first buf_trn-doc no-lock where recid(buf_trn-doc) = int(entry( v-list-index, p-doc-list)) no-error .
    if not available buf_trn-doc then next.
    if buf_trn-doc.status_ <> 'факт':U then do:
      message "Документ " buf_trn-doc.doc-code " не в статусе " 'факт':U " . Пропускаем."  view-as alert-box.
      next.
    end.
    if buf_trn-doc.internal = yes then do:
      if is-torg13 = no then do:
        OUTPUT STREAM str-export13 TO  VALUE("ТОРГ-13.txt").
        assign is-torg13 = yes .
      end.
    end.
    else do:
      if is-torg12 = no then do:
        OUTPUT STREAM str-export12 TO  VALUE("ТОРГ-12.txt").
        assign is-torg12 = yes .
      end.
    end.
    assign v-qnty = 0 .
    for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code :
      assign v-qnty = v-qnty + buf_doc-line.fact-qnty .
    end.
    if buf_trn-doc.internal = yes then EXPORT STREAM str-export13 buf_trn-doc.doc-code v-qnty  .
    else                               EXPORT STREAM str-export12 buf_trn-doc.doc-code v-qnty  .
  end.
  if is-torg13 = yes then OUTPUT STREAM str-export13 CLOSE.
  if is-torg12 = yes then OUTPUT STREAM str-export12 CLOSE.
  if is-torg12 = yes or is-torg13 = yes then do:
    if search ("TTH.exe") <> ? then do:
      os-command silent value(search ("TTH.exe")) .
    end.
    else do:
      if search ("ТТН.exe") <> ? then do:
        os-command silent value(search ("ТТН.exe")) .
      end.
      else message "Файл TTH.exe не найден!" view-as alert-box.
    end.
  end.
  message
        "Экспорт выбранных документов в файлы ТОРГ-12.txt и/или ТОРГ-13.txt закончен"
view-as alert-box.
