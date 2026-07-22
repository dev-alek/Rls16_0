block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sp-count.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/sp-count.p $":U .
define variable vss-description as character no-undo init "утилита для зачистки спецификаций от удаленных товаров (только проверка!!!)".
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
define buffer buf_goods for goods.
define buffer buf_contract-specif for contract-specif .
define variable v-user-action                as   character                   no-undo.
define variable v-printed                    as   logical                     no-undo.
define stream str-err.
define variable is-err as logical   no-undo .
assign is-err = no .
output stream str-err to value( "spec-del.err" ) .
for each buf_contract-specif no-lock :
  find first buf_goods no-lock where buf_goods.gds-code = buf_contract-specif.gds-code no-error .
  if not available buf_goods then do:
    put    stream str-err unformatted string( "Договор (вн.№) = " + string(buf_contract-specif.contract-num) + " Товар (вн.№) = " + string( buf_contract-specif.gds-code))  skip.
    assign is-err = yes .
  end.
end.
    output stream str-err close.
  if is-err then message  "Удаленные товары в спецификациях к договору можно посмотреть в файле spec-del.err" view-as alert-box.
  else           message  "Удаленных товаров в спецификациях к договору нет!" view-as alert-box.
