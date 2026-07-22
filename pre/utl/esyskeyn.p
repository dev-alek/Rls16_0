block-level on error undo, throw.
define input parameter p-profile-id-list as character no-undo .
define input parameter p-new-esys-type as integer no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: esyskeyn.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/esyskeyn.p $":U .
define variable vss-description as character no-undo init "Рыба утилиты переименования типа ВС в значениях машины правил".
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
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_ext-system for ub.ext-system.
main-block:
for each buf_rule-call-param no-lock
where lookup(string(buf_rule-call-param.profile_id), p-profile-id-list) > 0
on error  undo main-block, retry main-block
on stop   undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    message
    substitute("Ошибка при выполнении переименования типа ВС в значениях параметра вызова машины правил:&1&2&1" +
               "Список профайлов для переименования параметров - &3&1" +
               "Новое значение типа ВС - &4&1"
               , chr(10)
               , error-status:get-message(1)
               , p-profile-id-list
               , p-new-esys-type
               )
    view-as alert-box error .
    return error.
  end.
  if buf_rule-call-param.param-2-data-type begins 'ext-system':U
  and buf_rule-call-param.param-value-integer <> 0
  then do:
    find first buf_ext-system share-lock where
            buf_ext-system.esys-id = buf_rule-call-param.param-value-integer
        and buf_ext-system.db-num = 0 no-error.
    if available buf_ext-system
    and buf_ext-system.esys-type = integer('1':U) then do:
      assign
      buf_ext-system.esys-type = p-new-esys-type
      .
    end.
  end.
end.
