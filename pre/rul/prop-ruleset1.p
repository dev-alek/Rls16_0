block-level on error undo, throw.
define input parameter        p-mode as character no-undo .
define input parameter        p-silent as logical no-undo .
define input-output parameter p-rec  as recid     no-undo .
define input parameter        p-codex-id as integer no-undo .
define input parameter        p-ruleset-id as integer no-undo .
define input parameter        p-dtm-code as integer no-undo .
define input parameter        p-is-dynamic as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сохранение привязки prop-head к ruleset".
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
define variable v-mess as character no-undo .
define variable v-entry as character no-undo .
define buffer buf_ruleset for dictdb.ruleset.
define buffer buf_prop-ruleset for dictdb.prop-ruleset.
define buffer buf_prop-head for dictdb.prop-head.
if p-mode <> 'ДОБАВЛЕНИЕ':U
and p-mode <> 'ИЗМЕНЕНИЕ':U
then do:
  message vss-workfile vss-revision vss-description skip
          "Неверный параметр p-mode - " p-mode
  view-as alert-box error .
  return error '':u.
end.
_main:
do for buf_ruleset
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    find first buf_ruleset no-lock where
              buf_ruleset.codex_id = p-codex-id
          and buf_ruleset.ruleset_id = p-ruleset-id no-error.
    if not available buf_ruleset then do:
      assign
      v-mess = "Не найден ruleset c таким кодексом и набором правил".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    find first buf_prop-head no-lock where
              buf_prop-head.dtm-code = p-dtm-code no-error.
    if not available buf_prop-head then do:
      assign
      v-mess = "Не найден prop-head c таким dtm-code".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    create buf_prop-ruleset.
    assign
    buf_prop-ruleset.codex_id = p-codex-id
    buf_prop-ruleset.ruleset_id = p-ruleset-id
    buf_prop-ruleset.dtm-code = p-dtm-code
    buf_prop-ruleset.is_dynamic = p-is-dynamic
    .
  end.
  if p-mode = 'ИЗМЕНЕНИЕ':U then do:
    find first buf_prop-ruleset exclusive-lock where
              recid(buf_prop-ruleset) = p-rec .
    if buf_prop-ruleset.codex_id <> p-codex-id
    or buf_prop-ruleset.ruleset_id <> p-ruleset-id
    or buf_prop-ruleset.dtm-code <> p-dtm-code
    then do:
      assign
      v-mess = substitute("Для уже существующего prop-ruleset невозможно изменеие кодекса, набора правил и кода объекта &1" +
                              "старые значения кодекса и набора правил: &2, &3 и &4"
                              , chr(10)
                              , buf_prop-ruleset.codex_id
                              , buf_prop-ruleset.ruleset_id
                              , buf_prop-ruleset.dtm-code
                              )
      .
    end.
  end.
  assign
  buf_prop-ruleset.is_dynamic = p-is-dynamic
  .
end.
PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("prop-ruleset кодекс: &1 набор: &2 объект &3: &4"
                         , p-codex-id
                         , p-ruleset-id
                         , p-dtm-code
                         , p-mess)
      .
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.
