block-level on error undo, throw.
define input parameter        p-mode as character no-undo .
define input parameter        p-silent as logical no-undo .
define input-output parameter p-rec  as recid     no-undo .
define input parameter        p-mode-type as character no-undo .
define input parameter        p-mode-id as character no-undo .
define input parameter        p-prev-mode-id as character no-undo .
define input parameter        p-codex-id as integer no-undo .
define input parameter        p-ruleset-id as integer no-undo .
define input parameter        p-mode-name as character no-undo .
define input parameter        p-des as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wi-mode1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/wi-mode1.p $":U .
define variable vss-description as character no-undo init "Сохранение режима работы".
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
define variable v-codex-id as integer no-undo .
define buffer buf_wi-mode for ub.wi-mode.
define buffer buf_ruleset for ub.ruleset.
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
do for buf_wi-mode
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
  if p-prev-mode-id > '' then do:
    find first buf_wi-mode no-lock where
              buf_wi-mode.mode-type = p-mode-type
          and buf_wi-mode.mode-id = p-prev-mode-id no-error.
    if not available buf_wi-mode then do:
      assign
      v-mess = "Предыдущий режим - не существует режима c таким типом и id".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'prev-mode-id':U).
    end.
  end.
  if p-codex-id > 0 then do:
    find first buf_ruleset no-lock where
              buf_ruleset.codex_id = p-codex-id
          and buf_ruleset.ruleset_id = p-ruleset-id no-error.
    if not available buf_ruleset then do:
      assign
      v-mess = substitute("Не найден кодекс/набор правил &1/&2", p-codex-id, p-ruleset-id).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'codex-id':U).
    end.
    case p-mode-type:
      when 'cd-IBS-TH':U then do:
        ASSIGN
        v-codex-id = 19.
      END.
      OTHERWISE DO:
        MESSAGE
        substitute("Неивестен кодекс для режима работы с типом &1", p-mode-type)
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN NO-APPLY.
      end.
    end case.
    if v-codex-id <> p-codex-id then do:
      assign
      v-mess = substitute("Неверное значение p-codex-id=&1 для типа режима &2", p-codex-id, p-mode-type).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'codex-id':U).
    end.
  end.
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    find first buf_wi-mode no-lock where
              buf_wi-mode.mode-type = p-mode-type
          and buf_wi-mode.mode-id = p-mode-id no-error.
    if lookup(p-mode-type, 'cd-IBS-TH':U) = 0 then do:
      assign
      v-mess = substitute("Неверный тип режима &1", p-mode-type).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    if available buf_wi-mode then do:
      assign
      v-mess = "Уже существует режим c таким типом и ID".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    create buf_wi-mode.
    assign
    buf_wi-mode.mode-type = p-mode-type
    buf_wi-mode.mode-id = p-mode-id
    .
  end.
  if p-mode = 'ИЗМЕНЕНИЕ':U then do:
    find first buf_wi-mode exclusive-lock where
              recid(buf_wi-mode) = p-rec .
    if buf_wi-mode.mode-type <> p-mode-type
    or buf_wi-mode.mode-id <> p-mode-id
    then do:
      assign
      v-mess = substitute("Для уже существующего wi-mode невозможно изменить тип и ID&1" +
                              "старые значения типа и ID: &2 и &3"
                              , chr(10)
                              , buf_wi-mode.mode-type
                              , buf_wi-mode.mode-id)
      .
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
  end.
  assign
  buf_wi-mode.mode-name = p-mode-name
  buf_wi-mode.prev-mode-id = p-prev-mode-id
  buf_wi-mode.codex_id = p-codex-id
  buf_wi-mode.ruleset_id = p-ruleset-id
  buf_wi-mode.des = p-des
  p-rec = recid(buf_wi-mode)
  .
end.
PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Тип режима: &1 ID: &2: &3"
                         , p-mode-type
                         , p-mode-id
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
