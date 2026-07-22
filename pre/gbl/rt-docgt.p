block-level on error undo, throw.
define input  parameter p-unique-doc-code as character no-undo .
define input  parameter p-user-id         as character no-undo .
define output parameter p-other           as character no-undo .
define output parameter p-error-message   as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rt-docgt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/rt-docgt.p $":U .
define variable vss-description as character no-undo init "Радиотерминал. Получить атрибуты документа зарегистрированного с терминала .".
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
define buffer buf_batchprocess for ub.batchprocess .
do
on error undo, return error return-value
:
  find first buf_batchprocess exclusive-lock
    where buf_batchprocess.bp_type     = 'rt-doc':U
      and buf_batchprocess.bp_status   = 'N':U
      and buf_batchprocess.charkey_one = p-unique-doc-code
    no-error .
  if available buf_batchprocess
  then do:
    if buf_batchprocess.user_id <> p-user-id
    then do:
      assign
        p-error-message = substitute('Документ &1 редактируется пользователем &2 с &3 в режием &4'
                                    ,p-unique-doc-code
                                    ,buf_batchprocess.user_id
                                    ,string(buf_batchprocess.bp_sysdate, '99/99/9999':u)
                                    ,(if buf_batchprocess.bp_execsystime = '1' then 'факт.количеств' else 'док.количеств')
                                    )
      .
      return.
    end.
    else do:
      assign
        p-other = buf_batchprocess.charkey_two
      .
      return .
    end.
  end.
end.
