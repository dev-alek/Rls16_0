block-level on error undo, throw.
define input parameter p-obj-type       as character        no-undo.
define input parameter p-obj-code       as integer          no-undo.
define input parameter p-verify-arh     as logical          no-undo.
define input parameter p-verify-ahsp    as logical          no-undo.
define input parameter p-verify-aht     as logical          no-undo.
define input parameter p-date-from      as date             no-undo.
define input parameter p-date-to        as date             no-undo.
define output parameter p-archive-ok    as logical          no-undo.
define output parameter p-comment       as character        no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bge-ahzs.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/bge-ahzs.p $":U .
define variable vss-description as character no-undo init "Проверка архивов для диапазона дат для выгрузки".
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
    define variable v-date-from    as date         no-undo.
    define variable v-date-to      as date         no-undo.
    define variable v-can-print    as logical      no-undo.
do
on error undo, return error
:
    assign
        v-date-from = p-date-from
        v-date-to   = p-date-to
    .
    run rep/chk-ahz.p (
          input        p-obj-type
        , input        p-obj-code
        , input        yes
        , input        p-verify-arh
        , input        p-verify-ahsp
        , input        p-verify-aht
        , input        no
        , input        0
        , input        "":U
        , input-output v-date-from
        , input-output v-date-to
        , output       p-archive-ok
        , output       p-comment
        , output       v-can-print
    ) no-error .
    if error-status :error
    then do:
        undo, return error substitute( "Ошибка при вызове программы chk-ahz.p. &1. &2. &3"
            , return-value
            , trim(error-status :get-message(1))
            , trim(error-status :get-message(2))
        ) .
    end.
    if v-date-from <> p-date-from
    or v-date-to   <> p-date-to
    then do:
        assign
            p-archive-ok = no
            p-comment    = substitute( "Выгрузка не может быть произведена. &1", p-comment )
        .
    end.
end.
