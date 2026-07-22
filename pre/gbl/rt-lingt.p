block-level on error undo, throw.
define input  parameter p-unique-doc-code as character no-undo .
define input  parameter p-b-code          as integer   no-undo .
define output parameter p-qnty            as decimal   no-undo .
define output parameter p-last-date       as date      no-undo .
define output parameter p-price-docf      as decimal   no-undo .
define output parameter p-status          as character no-undo .
define output parameter p-error-message   as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rt-lingt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/rt-lingt.p $":U .
define variable vss-description as character no-undo init "Радиотерминал. Зарегистрировать количество по строке документа".
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
  assign
    p-qnty          = 0
    p-last-date     = ?
    p-price-docf    = 0
    p-status        = '0'
    p-error-message = ''
  .
  find first buf_batchprocess exclusive-lock
    where buf_batchprocess.bp_type     = 'rt-line':U
      and buf_batchprocess.bp_status   = 'N':U
      and buf_batchprocess.charkey_one = p-unique-doc-code
      and buf_batchprocess.key#_one    = p-b-code
  no-error .
  if not available buf_batchprocess
  then do:
   return .
  end.
  assign
    p-qnty = decimal(buf_batchprocess.bp_execsystime)
  no-error .
  if error-status :error
  then do:
    assign
      p-status        = "1"
      p-error-message = substitute("gbl/rt-lingt.p: Ошибка преобразования кол-ва в строке документа &1 | &2. &3"
                                  , p-unique-doc-code
                                  , p-b-code
                                  , error-status :get-message(1)
                                  )
    .
    return .
  end.
  assign
    p-last-date = date(buf_batchprocess.charkey_two)
  no-error .
  if error-status :error = yes
  then do:
    assign
      p-status        = "1"
      p-error-message = substitute("gbl/rt-lingt.p: Ошибка преобразования срока годности в строке документа &1 | &2. &3"
                                  , p-unique-doc-code
                                  , p-b-code
                                  , error-status :get-message(1)
                                  )
    .
    return .
  end.
  assign
    p-price-docf = decimal(buf_batchprocess.charkey_three)
  no-error .
  if error-status :error = yes
  then do:
    assign
      p-status        = "1"
      p-error-message = substitute("gbl/rt-lingt.p: Ошибка преобразования цены в строке документа &1 | &2. &3"
                                  , p-unique-doc-code
                                  , p-b-code
                                  , error-status :get-message(1)
                                  )
    .
    return .
  end.
end.
