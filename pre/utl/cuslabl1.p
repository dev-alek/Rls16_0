block-level on error undo, throw.
define input parameter        p-mode as character no-undo .
define input parameter        p-silent as logical no-undo .
define input-output parameter p-rec  as recid     no-undo .
define input parameter p-tbl-name as character no-undo .
define input parameter p-fld-name as character no-undo .
define input parameter p-call-type as character no-undo .
define input parameter p-call-point as character no-undo .
define input parameter p-language as character no-undo .
define input parameter p-fld-data-type as character no-undo .
define input parameter p-custom-label as character no-undo .
define input parameter p-custom-view-func as character no-undo .
define input parameter p-reference-proc as character no-undo .
define input parameter p-custom-format as character no-undo .
define input parameter p-custom-tooltip as character no-undo .
define input parameter p-init-value-character as character no-undo .
define input parameter p-init-value-date as date no-undo .
define input parameter p-init-value-decimal as decimal no-undo .
define input parameter p-init-value-integer as integer no-undo .
define input parameter p-init-value-logical as logical no-undo .
define input parameter p-widget-type as character no-undo .
define input parameter p-widget-width as decimal no-undo .
define input parameter p-widget-list-items as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cuslabl1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/cuslabl1.p $":U .
define variable vss-description as character no-undo init "Сохранение настраиваемых полей".
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
define buffer buf_custom-labels for ub.custom-labels.
if p-mode <> 'ДОБАВЛЕНИЕ':U
AND p-mode <> 'ИЗМЕНЕНИЕ':U then do:
  message vss-workfile vss-revision vss-description skip
          "Неверный параметр p-mode - " p-mode
  view-as alert-box error .
  return error '':u.
end.
if g#db-num <> 0 then do:
  message vss-workfile vss-revision vss-description skip
          "Запрещено вызывать процедуру в УБД"
  view-as alert-box error .
  return error '':u.
end.
_main:
do for buf_custom-labels
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
   if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    find first buf_custom-labels no-lock where
              buf_custom-labels.tbl-name  = p-tbl-name
          and buf_custom-labels.fld-name  = p-fld-name
          and buf_custom-labels.call-type  = p-call-type
          and buf_custom-labels.call-point  = p-call-point
          and buf_custom-labels.language  = p-language no-error.
    if available buf_custom-labels then do:
      assign
      v-mess = substitute("Уже есть такое настраемваемое поле").
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    create buf_custom-labels.
    assign
    buf_custom-labels.tbl-name = p-tbl-name
    buf_custom-labels.fld-name = p-fld-name
    buf_custom-labels.call-type = p-call-type
    buf_custom-labels.call-point = p-call-point
    buf_custom-labels.language = p-language
    .
  end.
  if p-mode = 'ИЗМЕНЕНИЕ':U then do:
    find first buf_custom-labels exclusive-lock where
            recid(buf_custom-labels) = p-rec no-error.
    if not available buf_custom-labels then do:
      assign
      v-mess = substitute("Нет такого настраиваемого поля").
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    if p-tbl-name <> buf_custom-labels.tbl-name
    or p-fld-name <> buf_custom-labels.fld-name
    or p-call-type <> buf_custom-labels.call-type
    or p-call-point <> buf_custom-labels.call-point
    or p-language <> buf_custom-labels.language then do:
      assign
      v-mess = substitute("Для уже существующего настраиваемого поля невозможно изменение названия таблицы,&1" +
                              "названия поля, типа вызова, точки вызова и языка"
                              , chr(10)
                              )
      .
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
  end.
  assign
  buf_custom-labels.custom-format = p-custom-format
  buf_custom-labels.custom-label = p-custom-label
  buf_custom-labels.custom-view-func = p-custom-view-func
  buf_custom-labels.reference-proc = p-reference-proc
  buf_custom-labels.custom-tooltip = p-custom-tooltip
  buf_custom-labels.fld-data-type = p-fld-data-type
  buf_custom-labels.init-value-character = p-init-value-character
  buf_custom-labels.init-value-date = p-init-value-date
  buf_custom-labels.init-value-decimal = p-init-value-decimal
  buf_custom-labels.init-value-integer = p-init-value-integer
  buf_custom-labels.init-value-logical = p-init-value-logical
  buf_custom-labels.widget-type = p-widget-type
  buf_custom-labels.widget-width = p-widget-width
  buf_custom-labels.widget-list-items = p-widget-list-items
  p-rec = recid(buf_custom-labels)
  .
end.
PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("custom-label&1tbl-name=&2&1" +
                          "fld-name=&3&1" +
                          "call-type=&4&1" +
                          "call-point=&5&1" +
                          "language=&6&1&7"
                         , chr(10)
                         , p-tbl-name
                         , p-fld-name
                         , p-call-type
                         , p-call-point
                         , p-language
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
