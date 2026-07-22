block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: correxta.p $
$Archive: utl/correxta.p $

Корректировка статусов внешних артикулов

Автор: Хныкин Павел Андреевич
Дата создания: 11/10/08
Author: Pavel Khnykin
Creation date: 11/10/08

Алгоритм :
По всем внешним артикулам в некорректном статусе. Статус некорректный если он не {&current-status} или {&deleted-status}.
Если такой внешний артикул в статусе текущие для постащика существует уже по другому товару, то переводим найденые в статус удаленные,
в противном случае в статус текущие.

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: correxta.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/correxta.p $":U .
define variable vss-description as character no-undo init "Корректировка статусов внешних артикулов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }



&scop log-file  "correct-ext-artic.log":U
&scop dump-file "correct-ext-artic.bak":U

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
        where buf_ext-artic.status_ <> {&current-status}
          and buf_ext-artic.status_ <> {&deleted-status}
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
  end. /* if v-log = yes  */

  assign
    v-str = "Корректировка внешних артикулов..."
    v-i   = 0
  .

  for each buf_ext-artic no-lock
    where buf_ext-artic.status_ <> {&current-status}
      and buf_ext-artic.status_ <> {&deleted-status} ,
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

    /* ищем корректный внешний артикул по другому товару с таким же внешним артикулом */
    find first sch_ext-artic no-lock
      where sch_ext-artic.cli-type  = buf_ext-artic.cli-type
        and sch_ext-artic.cli-code  = buf_ext-artic.cli-code
        and sch_ext-artic.gds-code <> buf_ext-artic.gds-code
        and sch_ext-artic.ext-artic = buf_ext-artic.ext-artic
        and sch_ext-artic.status_   = {&current-status}
    use-index ea-stts /* НЕ ТРОГАТЬ!!! индекс по артикулу вероятнее быстрее чем по поставщику */
    no-error .
    if available(sch_ext-artic)
    then do:
      run write-log in this-procedure (input substitute( "Перевод вн. артикула &1 поставщик &2 &3 товара артик. &4 в статус '&5'"
                                                       , buf_ext-artic.ext-artic
                                                       , buf_ext-artic.cli-type
                                                       , buf_ext-artic.cli-code
                                                       , buf_goods.artic
                                                       , {&deleted-status}
                                                       )
                                      ).
      /* если есть внешний артикул по этому поставщику то все остальные проставляем в статус {&deleted-status} */
      run ref/extartd.p ( buf_ext-artic.cli-type
                        , buf_ext-artic.cli-code
                        , buf_ext-artic.gds-code
                        , {&deleted-status}
                        ) no-error .
      if error-status :error
      then do:
        run write-log in this-procedure ( input substitute( "Ошибка при установке статуса &1 для записи &2 &3 &4 : &5 &6"
                                                          , {&deleted-status}
                                                          , buf_ext-artic.cli-type
                                                          , buf_ext-artic.cli-code
                                                          , buf_goods.artic
                                                          , trim(return-value)
                                                          , trim(error-status :get-message(1))
                                                          )
                                        ) .
      end.
    end. /* if available(sch_ext-artic) */
    else do:
      run write-log in this-procedure (input substitute( "Перевод вн. артикула &1 поставщик &2 &3 товара артик. &4 в статус '&5'"
                                                       , buf_ext-artic.ext-artic
                                                       , buf_ext-artic.cli-type
                                                       , buf_ext-artic.cli-code
                                                       , buf_goods.artic
                                                       , {&current-status}
                                                       )
                                      ).
      /* в противном случае выставляем артикулу статус {&current-status}  */
      run ref/extartd.p ( buf_ext-artic.cli-type
                        , buf_ext-artic.cli-code
                        , buf_ext-artic.gds-code
                        , {&current-status}
                        ) no-error .
      if error-status :error
      then do:
        run write-log in this-procedure ( input substitute( "Ошибка при установке статуса &1 для записи &2 &3 &4 : &5 &6"
                                                          , {&current-status}
                                                          , buf_ext-artic.cli-type
                                                          , buf_ext-artic.cli-code
                                                          , buf_ext-artic.gds-code
                                                          , trim(return-value)
                                                          , trim(error-status :get-message(1))
                                                          )
                                        ) .
      end.

    end.
  end. /* for each buf_ext-artic no-lock  */
  hide frame log-frame.
  run write-log in this-procedure ( input "Проверка статусов внешних артикулов") .
  run calc-uncorrect-recs in this-procedure ( output v-total-uncorret-rec ) .
  run write-log in this-procedure ( input substitute("Найдено некорректных записей: &1 " , v-total-uncorret-rec )) .
  run write-log in this-procedure ( input "Корректировка статусов внешних артикулов завершена") .

  message
    "Корректировка заершена." skip
    "Лог файл: " string( file-info :full-pathname + '\' +  {&log-file})
  view-as alert-box information.

end.

/* ==================================================================== */
procedure calc-uncorrect-recs :
  define output parameter p-tot-recs as integer   no-undo .
do
on error undo, return error return-value
:
  define variable v-tot-recs as integer   no-undo .

  for each buf_ext-artic no-lock
    where buf_ext-artic.status_ <> {&current-status}
      and buf_ext-artic.status_ <> {&deleted-status}

  :
    assign
      v-tot-recs = v-tot-recs + 1
    .
  end.

  assign
    p-tot-recs = v-tot-recs
  .
end.

end procedure. /* calc-uncorrect-recs */

/* ==================================================================== */
procedure write-log :
  define input parameter p-log-message as character no-undo.
do
on error undo, return error return-value
:
  output stream slog to value({&log-file}) append.

  put stream slog unformatted
    today {&tabulation}
    string(time, "hh:mm:ss") {&tabulation}
    p-log-message
    {&new-line}
  .

  output stream slog close.

end.

end procedure. /* write-log */