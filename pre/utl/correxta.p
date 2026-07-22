block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: correxta.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/correxta.p $":U .
define variable vss-description as character no-undo init "Корректировка статусов внешних артикулов".
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
define stream slog.
define stream sout.
define buffer buf_goods     for ub.goods.
define buffer buf_ext-artic for ub.ext-artic.
define buffer sch_ext-artic for ub.ext-artic.
define variable v-total-uncorret-rec  as integer   no-undo .
define variable v-cur-stts-counter    as integer   no-undo .
define variable v-del-stts-counter    as integer   no-undo .
define variable v-log                 as logical   no-undo .
define variable v-filename            as character no-undo .
define variable v-full-filename       as character no-undo .
define variable v-str                 as character no-undo .
define variable v-i                   as integer   no-undo .
define variable v-cli-str             as character no-undo .
define variable v-cli-art             as character no-undo .
define frame log-frame
  v-str               format "X(40)"      no-label                  skip
  v-i                 format ">>>>>>>>9"  label "Прочитано записей" skip
  v-cli-str           format "X(13)"      label "Поставщик"         skip
  v-cli-art           format "X(14)"      label "Внешний артикул"
  with view-as dialog-box side-labels three-d
  title "Корректировка статусов внешних артикулов"
.
do
on error undo, return error return-value
:
  run write-log in this-procedure ( input "Корректировка статусов внешних артикулов") .
  run calc-uncorrect-recs in this-procedure ( output v-total-uncorret-rec ) .
  run write-log in this-procedure ( input substitute("Найдено некорректных записей: &1 " , v-total-uncorret-rec )) .
  assign
    file-info :file-name = ".":U
  .
  message
    "Сохранить внешние артикулы в файл перед корректировкой ?" skip
  view-as alert-box question buttons yes-no update v-log.
  pause 0 before-hide.
  view frame log-frame.
  if v-log = yes
  then do :
    SYSTEM-DIALOG GET-FILE v-filename
                  TITLE   "Файл"
                  FILTERS "Резервная копия (*.bak)"    "*.bak",
                          "Все файлы (*.*)"    "*.*"
                  USE-FILENAME
                  UPDATE v-log.
    if v-log then do:
      assign
        v-full-filename = search(v-filename)
      .
      if v-full-filename <> ?
      then do:
        message
          "Файл " v-full-filename " будет перезаписан."
        view-as alert-box warning.
      end.
      assign
        v-str = "Экспорт некорректных внешних артикулов..."
      .
      output stream sout to value(v-filename).
      for each buf_ext-artic no-lock
        where buf_ext-artic.status_ <> 'тек':U
          and buf_ext-artic.status_ <> 'удал':U
      :
        assign
          v-i = v-i + 1
          v-cli-str = string(buf_ext-artic.cli-code, "999999999")  +  " "  +  trim(buf_ext-artic.cli-type)
          v-cli-art = buf_ext-artic.ext-artic
        .
        display
          v-str
          v-i
          v-cli-str
          v-cli-art
        with frame log-frame.
        export stream sout delimiter ";" buf_ext-artic.
      end.
      output stream sout close.
    end.
  end.
  assign
    v-str = "Корректировка внешних артикулов..."
    v-i   = 0
  .
  for each buf_ext-artic no-lock
    where buf_ext-artic.status_ <> 'тек':U
      and buf_ext-artic.status_ <> 'удал':U ,
    first buf_goods no-lock
      where buf_goods.gds-code = buf_ext-artic.gds-code
  :
    assign
      v-i = v-i + 1
      v-cli-str = string(buf_ext-artic.cli-code, "999999999")  +  " "  +  trim(buf_ext-artic.cli-type)
      v-cli-art = buf_ext-artic.ext-artic
    .
    display
      v-str
      v-i
      v-cli-str
      v-cli-art
    with frame log-frame.
    find first sch_ext-artic no-lock
      where sch_ext-artic.cli-type  = buf_ext-artic.cli-type
        and sch_ext-artic.cli-code  = buf_ext-artic.cli-code
        and sch_ext-artic.gds-code <> buf_ext-artic.gds-code
        and sch_ext-artic.ext-artic = buf_ext-artic.ext-artic
        and sch_ext-artic.status_   = 'тек':U
    use-index ea-stts
    no-error .
    if available(sch_ext-artic)
    then do:
      run write-log in this-procedure (input substitute( "Перевод вн. артикула &1 поставщик &2 &3 товара артик. &4 в статус '&5'"
                                                       , buf_ext-artic.ext-artic
                                                       , buf_ext-artic.cli-type
                                                       , buf_ext-artic.cli-code
                                                       , buf_goods.artic
                                                       , 'удал':U
                                                       )
                                      ).
      run ref/extartd.p ( buf_ext-artic.cli-type
                        , buf_ext-artic.cli-code
                        , buf_ext-artic.gds-code
                        , 'удал':U
                        ) no-error .
      if error-status :error
      then do:
        run write-log in this-procedure ( input substitute( "Ошибка при установке статуса &1 для записи &2 &3 &4 : &5 &6"
                                                          , 'удал':U
                                                          , buf_ext-artic.cli-type
                                                          , buf_ext-artic.cli-code
                                                          , buf_goods.artic
                                                          , trim(return-value)
                                                          , trim(error-status :get-message(1))
                                                          )
                                        ) .
      end.
    end.
    else do:
      run write-log in this-procedure (input substitute( "Перевод вн. артикула &1 поставщик &2 &3 товара артик. &4 в статус '&5'"
                                                       , buf_ext-artic.ext-artic
                                                       , buf_ext-artic.cli-type
                                                       , buf_ext-artic.cli-code
                                                       , buf_goods.artic
                                                       , 'тек':U
                                                       )
                                      ).
      run ref/extartd.p ( buf_ext-artic.cli-type
                        , buf_ext-artic.cli-code
                        , buf_ext-artic.gds-code
                        , 'тек':U
                        ) no-error .
      if error-status :error
      then do:
        run write-log in this-procedure ( input substitute( "Ошибка при установке статуса &1 для записи &2 &3 &4 : &5 &6"
                                                          , 'тек':U
                                                          , buf_ext-artic.cli-type
                                                          , buf_ext-artic.cli-code
                                                          , buf_ext-artic.gds-code
                                                          , trim(return-value)
                                                          , trim(error-status :get-message(1))
                                                          )
                                        ) .
      end.
    end.
  end.
  hide frame log-frame.
  run write-log in this-procedure ( input "Проверка статусов внешних артикулов") .
  run calc-uncorrect-recs in this-procedure ( output v-total-uncorret-rec ) .
  run write-log in this-procedure ( input substitute("Найдено некорректных записей: &1 " , v-total-uncorret-rec )) .
  run write-log in this-procedure ( input "Корректировка статусов внешних артикулов завершена") .
  message
    "Корректировка заершена." skip
    "Лог файл: " string( file-info :full-pathname + '\' +  "correct-ext-artic.log":U)
  view-as alert-box information.
end.
procedure calc-uncorrect-recs :
  define output parameter p-tot-recs as integer   no-undo .
do
on error undo, return error return-value
:
  define variable v-tot-recs as integer   no-undo .
  for each buf_ext-artic no-lock
    where buf_ext-artic.status_ <> 'тек':U
      and buf_ext-artic.status_ <> 'удал':U
  :
    assign
      v-tot-recs = v-tot-recs + 1
    .
  end.
  assign
    p-tot-recs = v-tot-recs
  .
end.
end procedure.
procedure write-log :
  define input parameter p-log-message as character no-undo.
do
on error undo, return error return-value
:
  output stream slog to value("correct-ext-artic.log":U) append.
  put stream slog unformatted
    today chr(9)
    string(time, "hh:mm:ss") chr(9)
    p-log-message
    chr(10)
  .
  output stream slog close.
end.
end procedure.
