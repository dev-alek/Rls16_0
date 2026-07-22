block-level on error undo, throw.
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define input  parameter p-shift-date as date      no-undo .
define input  parameter p-shift-num  as integer   no-undo .
define output parameter p-fact-date  as date      no-undo .
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: getshtdt.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: gbl/getshtdt.p $":U .
define variable vss-description as character no-undo initial "Определение даты конца смены".
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define buffer buf_shift-obj for ub.shift-obj .
do
on error undo, return error return-value
:
  find first buf_shift-obj no-lock
    where buf_shift-obj.obj-type   = p-obj-type
      and buf_shift-obj.obj-code   = p-obj-code
      and buf_shift-obj.shift-date = p-shift-date
      and buf_shift-obj.shift-num  = p-shift-num
    no-error .
  if not available buf_shift-obj
  then do:
    undo, return error substitute("Не найдена смена. Объект &1 &2. Смена &3 &4."
                                 ,p-obj-type
                                 ,p-obj-code
                                 ,p-shift-date
                                 ,p-shift-num
                                 ) .
  end.
  if buf_shift-obj.status_ = 'зкр':U
  then do:
    assign
      p-fact-date = buf_shift-obj.close-date
    .
  end.
  else do:
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output p-fact-date
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении даты на объекте" skip
        "Объект" p-obj-type p-obj-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end.
