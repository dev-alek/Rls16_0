block-level on error undo, throw.
define input  parameter parParentProc as handle  no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: prclose.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/prclose.p $":U .
define variable vss-description as character no-undo init " Закрытие всех новых переоценок по всем неудаленным объектам.   ".
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
define new global shared variable g#lib-log as handle no-undo .
define variable p-log-handle as handle  no-undo .
if (valid-handle(g#lib-log) <> true) then do:   run gbl/lib-log.p persistent no-error .   if error-status :error or (valid-handle(g#lib-log) <> true) then do:     message       "Error starting gbl/lib-log.p" skip       g#lib-log skip       g#lib-log :type skip       g#lib-log :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-log_get-log-handle in g#lib-log
  (output  p-log-handle
  )  .
define buffer buf_db        for ub.db .
define buffer buf_clients   for ub.clients .
define buffer buf_sys-ctrl  for ub.sys-ctrl .
define buffer buf-price-doc for ub.price-doc.
define buffer buf-shift-obj for ub.shift-obj.
MESSAGE
  "Вы уверены, что хотите начать работу утилиты ?"
VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
        TITLE " Закрытие всех новых переоценок" UPDATE answer AS LOG.
IF answer <> YES THEN RETURN.
find first buf_sys-ctrl no-lock no-error .
  for each buf_db no-lock where buf_db.db-num = buf_sys-ctrl.db-num  ,
   each buf_clients no-lock  where buf_clients.db-num = buf_db.db-num
                               and buf_clients.stts = 0 ,
   each buf-price-doc no-lock where  buf-price-doc.obj-code = buf_clients.obj-code
                                 and buf-price-doc.obj-type = buf_clients.obj-type
                                 and buf-price-doc.status_ =  'новый':U
                                    on error undo, return error  :
        if can-find (first buf-shift-obj   where     buf-shift-obj.obj-code = buf_clients.obj-code
                                                and buf-shift-obj.obj-type = buf_clients.obj-type no-lock )
        Then message "На объекте " buf_clients.obj-type buf_clients.obj-code  " есть смены . Автоматически закрыть до состояния АКТ нельзя, закройте документ переоценки № "
                     buf-price-doc.doc-num  " в ручную!" .
        Else
          run str/pr-stat.p (  input parParentProc
                             , input p-log-handle
                             , input "close-act"
                             , input buf-price-doc.doc-num
                             , input ?
                             , input true
                             , input true ) no-error .
  end.
 Message "Процесс закрытия переоценок по базе данных № " buf_sys-ctrl.db-num " завершен !" view-as alert-box information .
