block-level on error undo, throw.
define input  parameter p-server-name as character no-undo .
define input  parameter p-event       as character no-undo .
define input  parameter p-parameters  as character no-undo .
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: logevent.p $":U .
def var vss-archive     as character no-undo init "$Archive: gbl/logevent.p $":U .
def var vss-description as character no-undo init "Модуль регистрации сообщений".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
do
on error undo, return error return-value
:
  def var v-command-name as character no-undo .
  def var v-logger-name as character no-undo .
  if p-event = ? then do:
    assign
      p-event = ""
    .
  end.
  if p-parameters = ? then do:
    assign
      p-parameters = '?'
    .
  end.
  assign
    v-logger-name = search("logevent.exe":u)
  .
  if v-logger-name <> ? then do:
    assign
      v-command-name  = v-logger-name
                      + (if p-server-name <> "" then " -m " + p-server-name + " " else "")
                      + (if p-event <> "" then " -r " + p-event + " " else "")
                      + " " + chr(34) + trim(p-parameters) + chr(34)
    .
    os-command silent  value (
      v-command-name
      ).
  end.
end.
