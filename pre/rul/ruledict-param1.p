block-level on error undo, throw.
define input parameter        p-mode as character no-undo .
define input parameter        p-silent as logical no-undo .
define input-output parameter p-rec  as recid     no-undo .
define input parameter        p-entry-id as integer no-undo .
define input parameter        p-language as character no-undo .
define input parameter        p-param-num as integer no-undo .
define input parameter        p-param-name as character no-undo .
define input parameter        p-param-label as character no-undo .
define input parameter        p-param-data-type as character no-undo .
define input parameter        p-param-2-data-type as character no-undo .
define input parameter        p-param-3-data-type as character no-undo .
define input parameter        p-param-mode as character no-undo .
define input parameter        p-documentation as character no-undo .
define input parameter        p-init-value-character as character no-undo .
define input parameter        p-init-value-date as date no-undo .
define input parameter        p-init-value-decimal as decimal no-undo .
define input parameter        p-init-value-integer as integer no-undo .
define input parameter        p-init-value-logical as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сохранение изменений ruledict-param".
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
define variable v-ii as integer no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-clob-db-num as integer   no-undo init ?.
define variable v-int64-id as integer   no-undo init 0.
define variable v-part-num as integer   no-undo .
define buffer buf_ruledict-param for ub.ruledict-param.
define buffer buf_ruledict for ub.ruledict.
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
do for buf_ruledict-param
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
  if p-param-name = '':u then do:
    assign
    v-mess = "Имя параметра не может быть пустым".
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'param-name':U).
  end.
  if p-param-label = '':u then do:
    assign
    v-mess = "Лейбл параметра не может быть пустым".
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'param-lable':U).
  end.
  if p-param-num = 0 then do:
    assign
    v-mess = "№ параметра не может = 0".
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'param-num':U).
  end.
  if lookup(p-param-data-type, 'character,date,datetime,datetime-tz,decimal,integer,void,logical,memptr,raw,recid,rowid,widget-handle':U + chr(44) + 'longchar':U) = 0
  then do:
    assign
    v-mess = substitute("Неверное значение типа параметра: &1", p-param-data-type).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'param-data-type':U).
  end.
  if lookup(p-param-mode, 'input,output,input-output,buffer,input table,output table,input-output table':u) = 0
  then do:
    assign
    v-mess = substitute("Неверное значение моды параметра: &1", p-param-mode).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'param-mode':U).
  end.
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    find first buf_ruledict-param exclusive-lock where
              buf_ruledict-param.entry-id = p-entry-id
          and buf_ruledict-param.language = p-language
          and buf_ruledict-param.param-num = p-param-num no-error.
    if available buf_ruledict-param then do:
      assign
      v-mess = "Уже существует ruledict-param c таким ID термина, языком и № пар-ра".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    find first buf_ruledict no-lock where
              buf_Ruledict.entry-id = p-entry-id no-error.
    if not available buf_ruledict then do:
      assign
      v-mess = "Не найден термин".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    create buf_ruledict-param.
    assign
    buf_ruledict-param.entry-id = p-entry-id
    buf_ruledict-param.language = p-language
    buf_ruledict-param.param-num = p-param-num
    .
  end.
  if p-mode = 'ИЗМЕНЕНИЕ':U then do:
    find first buf_ruledict-param exclusive-lock where
              recid(buf_ruledict-param) = p-rec .
    if buf_ruledict-param.entry-id <> p-entry-id
    or buf_ruledict-param.language <> p-language
    or buf_ruledict-param.param-num <> p-param-num
    then do:
      assign
      v-mess = substitute("Для уже существующего ruledict-param невозможно изменение ID термина, языка и № пар-ра1" +
                              "старые значения ID термина, языка и № пар-ра: &2, &3 и &4"
                              , chr(10)
                              , buf_ruledict-param.entry-id
                              , buf_ruledict-param.language
                              , buf_Ruledict-param.param-num)
      .
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
  end.
  do v-ii = 1 to num-entries(p-param-3-data-type):
    if not (entry(v-ii, p-param-3-data-type) = "LIST"
            or
            entry(v-ii, p-param-3-data-type) = "READ-ONLY"
            or
            entry(v-ii, p-param-3-data-type) = "SORTED-LIST"
            ) then do:
      assign
      v-mess = substitute("Неизвестный тип данных3 = &1"
                              , chr(10)
                              , p-param-3-data-type )
      .
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
  end.
  assign
  buf_ruledict-param.param-name          = p-param-name
  buf_ruledict-param.param-label         = p-param-label
  buf_ruledict-param.param-data-type     = p-param-data-type
  buf_ruledict-param.param-2-data-type   = p-param-2-data-type
  buf_ruledict-param.param-3-data-type   = p-param-3-data-type
  buf_ruledict-param.param-mode          = p-param-mode
  buf_ruledict-param.documentation       = p-documentation
  buf_ruledict-param.init-value-character = (if p-param-data-type = 'character':U
                                             then p-init-value-character
                                             else '':U)
  buf_ruledict-param.init-value-date      = (if p-param-data-type = 'date':U
                                             then p-init-value-date
                                             else ?)
  buf_ruledict-param.init-value-decimal   = (if p-param-data-type = 'decimal':U
                                             then p-init-value-decimal
                                             else 0.0)
  buf_ruledict-param.init-value-integer   = (if p-param-data-type = 'integer':U
                                             then p-init-value-integer
                                             else 0)
  buf_ruledict-param.init-value-logical   = (if p-param-data-type = 'logical':U
                                             then p-init-value-logical
                                             else no)
  .
  if buf_ruledict-param.param-data-type = 'character':U
  and buf_ruledict-param.param-2-data-type = "xsd"
  then do:
    run rul/rdp-clob.p ( buffer buf_ruledict-param
                        ,input p-mode) no-error.
    if error-status:error then  do:
      v-mess = substitute("Не удалось сохранить CLOB &1:&2&3&2&4"
                          ,buf_ruledict-param.init-value-character
                          ,chr(10)
                          , error-status:get-message(1)
                          , return-value ).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
  end.
end.
PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("ruledict-param ID термина: &1 язык: &2: № пар-ра &3:&4&5"
                         , p-entry-id
                         , p-language
                         , p-param-num
                         , chr(10)
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
