block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ahinfprn.p $
$Archive: utl/ahinfprn.p $

Печать информации о текущем состоянии архива

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 09/06/04

*/
define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-ah-infov-handle as handle    no-undo .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: ahinfprn.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/ahinfprn.p $":U .
define variable vss-description as character no-undo initial "Печать информации по архивам по товарам, по поставщикам, по типам приобретени".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/r-pril.i   }
{ gbl/prn-lib.i }
{ gbl/arhisatr.i }


do
on error undo, return error return-value
:

  define variable v-available                as logical   no-undo .
  define variable v-db-num                   as integer   no-undo .
  define variable v-obj-type                 as character no-undo .
  define variable v-obj-code                 as integer   no-undo .
  define variable v-archive-type             as character no-undo .
  define variable v-deleted                  as logical   no-undo .
  define variable v-archive-calc             as logical   no-undo .
  define variable v-archive-del              as logical   no-undo .
  define variable v-archive-disable          as logical   no-undo .
  define variable v-archive-rest             as logical   no-undo .
  define variable v-archive-bpexist          as logical   no-undo .
  define variable v-archive-detail-date      as date      no-undo .
  define variable v-archive-start-date       as date      no-undo .
  define variable v-archive-date-recalc      as date      no-undo .
  define variable v-archive-lock-prc         as logical   no-undo .
  define variable v-archive-execuser         as character no-undo .
  define variable v-archive-execsysdate      as date      no-undo .
  define variable v-archive-execsystime      as character no-undo .
  define variable v-archive-rest-lock-prc    as logical   no-undo .
  define variable v-archive-rest-execuser    as character no-undo .
  define variable v-archive-rest-execsysdate as date      no-undo .
  define variable v-archive-rest-execsystime as character no-undo .

  define variable v-archive-type-name     as character no-undo .
  define variable v-description           as character no-undo .

  if valid-handle(p-ah-infov-handle) <> true
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Неправильный указатель на процедуру p-ah-infov-handle" skip
      "p-ah-infov-handle" p-ah-infov-handle skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  run ah-infov_get-current in p-ah-infov-handle
    (output v-available                /* p-available             */
    ,output v-db-num                   /* p-db-num                */
    ,output v-obj-type                 /* p-obj-type              */
    ,output v-obj-code                 /* p-obj-code              */
    ,output v-archive-type             /* p-archive-type          */
    ,output v-deleted                  /* p-obj-deleted           */
    ,output v-archive-calc             /* p-archive-calc          */
    ,output v-archive-del              /* p-archive-del           */
    ,output v-archive-disable          /* p-archive-disable       */
    ,output v-archive-rest             /* p-archive-rest          */
    ,output v-archive-bpexist          /* p-archive-bpexist       */
    ,output v-archive-detail-date      /* p-archive-detail-date   */
    ,output v-archive-start-date       /* p-archive-start-date    */
    ,output v-archive-date-recalc      /* p-archive-recalc-date   */
    ,output v-archive-lock-prc         /* p-archive-lock-prc      */
    ,output v-archive-execuser         /* p-archive-execuser      */
    ,output v-archive-execsysdate      /* p-archive-execsysdate   */
    ,output v-archive-execsystime      /* p-archive-execsystime   */
    ,output v-archive-rest-lock-prc    /* p-archive-rest-lock-prc    */
    ,output v-archive-rest-execuser    /* p-archive-rest-execuser    */
    ,output v-archive-rest-execsysdate /* p-archive-rest-execsysdate */
    ,output v-archive-rest-execsystime /* p-archive-rest-execsystime */
    ) .

  if v-available <> true
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Недоступна запись информации об архиве" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    return .
  end.

  run ah-infov_archive-type-name-proc in p-ah-infov-handle
    (input  v-archive-type
    ,output v-archive-type-name
    ) .

  run ah-infov_get-description in p-ah-infov-handle
    (output v-description
    ) .

  run prn-lib-open-stream  in this-procedure (
                                              input parParentProc
                                              ,input {&LS_PS_A4}
                                              ,input yes /*p-is-stream*/
                                              ,input no /*p-append*/
                                              ).

  put stream PrnLibStream unformatted
    "Складской архив " + v-archive-type-name + ". " + v-description
    skip
    .
  put stream PrnLibStream unformatted
    " "
    skip
    .


  define buffer buf_sys-ctrl for ub.sys-ctrl .
  define buffer buf_db for ub.db .

  find buf_sys-ctrl .
  find first buf_db no-lock
    where buf_db.db-num = buf_sys-ctrl.db-num
    .
  put stream PrnLibStream unformatted
    "Текущая база данных:     " + string(buf_db.db-num) + " " + buf_db.db-name
    skip
    .

  define buffer buf_clients for ub.clients .
  find first buf_clients no-lock
    where buf_clients.obj-type = v-obj-type
      and buf_clients.obj-code = v-obj-code
    .
  put stream PrnLibStream unformatted
    "Объект:                  " + v-obj-type + " " + string(v-obj-code) + "  " + buf_clients.obj-name
    skip
    .

  find first buf_db no-lock
    where buf_db.db-num = v-db-num
    .
  put stream PrnLibStream unformatted
    "База данных объекта:     " + string(v-db-num) + " " + buf_db.db-name
    skip
    .

  if v-deleted = true
  then do:
    put stream PrnLibStream unformatted
      "                         " + "Объект удалён"
      skip
      .
  end.

  put stream PrnLibStream unformatted
    " "
    skip
    .

  if v-archive-del = true
  then do:
    if v-archive-disable = true
    then do:
      put stream PrnLibStream unformatted
        "                         " + "РАСЧЕТ АРХИВА ВЫКЛЮЧЕН"
        skip
        .
    end.
    else do:
      put stream PrnLibStream unformatted
        "                         " + "НЕ РАССЧИТАН НАЧАЛЬНЫЙ ОСТАТОК"
        skip
        .
    end.
  end.

  if v-archive-calc = true
  then do:
    put stream PrnLibStream unformatted
      "                         " + "НЕ РАССЧИТАН ОБОРОТ"
      skip
      .
  end.

  if v-archive-rest = true
  then do:
    put stream PrnLibStream unformatted
      "                         " + "СБОЙ УДАЛЕНИЯ/ВОССТАНОВЛЕНИЯ"
      skip
      .
  end.

  put stream PrnLibStream unformatted
    "Начало подробного:       " + substitute('&1', string(v-archive-detail-date, '99/99/9999':u))
    skip
    .

  put stream PrnLibStream unformatted
    "Начало сжатого:          " + substitute('&1', string(v-archive-start-date, '99/99/9999':u))
    skip
    .

  put stream PrnLibStream unformatted
    "Дата перерасчёта:        " + substitute('&1', string(v-archive-date-recalc, '99/99/9999':u))
    skip
    .


  if v-archive-lock-prc = true
  then do:
    put stream PrnLibStream unformatted
      " "
      skip
      .
    put stream PrnLibStream unformatted
      "                         " + "РАСЧЁТ АРХИВА"
      skip
      .
    put stream PrnLibStream unformatted
      "Пользователь:            " + substitute('&1', string(v-archive-execuser, '99/99/9999':u))
      skip
      .
    put stream PrnLibStream unformatted
      "Дата и время:            " + substitute('&1', string(v-archive-execsysdate, '99/99/9999':u))
                                  + substitute('&1', string(v-archive-execsystime, 'HH:MM:SS':u))
      skip
      .
  end.

  if v-archive-bpexist = true
  then do:
    put stream PrnLibStream unformatted
      " "
      skip
      .
    put stream PrnLibStream unformatted
      "Имеются задания на расчет архива"
      skip
      .
  end.

  put stream PrnLibStream unformatted
    " "
    skip
    .

  define buffer buf_archive-history for archive-history .
  define query q-hist for buf_archive-history scrolling .

  open query q-hist for each buf_archive-history no-lock
    where buf_archive-history.archive-type  = v-archive-type
      and buf_archive-history.obj-type      = v-obj-type
      and buf_archive-history.obj-code      = v-obj-code
    use-index ishow
    by buf_archive-history.chip-num descending
    .

  get first q-hist .

  put stream PrnLibStream unformatted
    " "
    skip
    .
  put stream PrnLibStream unformatted
    "История операций"
    skip
    .

  define variable v-print-header as logical   no-undo .

  assign
    v-print-header = true
  .

  define variable v-delimiter as character no-undo .

  assign
    v-delimiter = fill('-':u, 197)
  .

  do while available buf_archive-history
  :
    if line-counter(PrnLibStream) > page-size(PrnLibStream) - 2
    then do:
      put stream PrnLibStream unformatted
        v-delimiter skip
        fill(" ", 54) + "Продолжение на следующей странице" skip
        .
      page stream PrnLibStream .
      assign
        v-print-header = true
      .
      put stream PrnLibStream unformatted
        "Складской архив " + v-archive-type-name + ". "
        + substitute("Объект &1 &2. ", v-obj-type, v-obj-code)
        + v-description + ". "
        + substitute("Страница &1", page-number(PrnLibStream))
        skip
        .
    end.

    if v-print-header
    then do:
      put stream PrnLibStream unformatted
        v-delimiter skip
        "Дата       : Время    : Действие             : БД : Польз.   : Подробный  : Сжатый     : Перерасчёт :НеО:НеН:Вык:СбУ:Файл                  :Пра:Контрольная сумма MD5             : Номер   : Причина"
        skip
        v-delimiter skip
        .
      assign
        v-print-header = false
      .
    end.

    define variable v-history-description as character no-undo .
    run ah-infov_history-description in p-ah-infov-handle
      (input  buf_archive-history.action-type
      ,output v-history-description
      ) .

    define variable v-attr-calc    as logical   no-undo .
    define variable v-attr-del     as logical   no-undo .
    define variable v-attr-disable as logical   no-undo .
    define variable v-attr-rest    as logical   no-undo .

    run arhisatr_decode-attr in this-procedure
      (input  buf_archive-history.archive-calc /* p-attr-encode-calc */
      ,input  buf_archive-history.archive-del  /* p-attr-encode-del  */
      ,input  buf_archive-history.ps           /* p-attr-encode-ps   */
      ,output v-attr-calc                      /* p-attr-calc        */
      ,output v-attr-del                       /* p-attr-del         */
      ,output v-attr-disable                   /* p-attr-disable     */
      ,output v-attr-rest                      /* p-attr-rest        */
      ) .

    put stream PrnLibStream unformatted
        (if buf_archive-history.corr-date <> ?
         then string(buf_archive-history.corr-date, '99/99/9999':u)
         else fill(' ':u, 10)
        )
      + " : "
      + (if buf_archive-history.corr-time-str <> ?
         then string(buf_archive-history.corr-time-str, 'x(8)':u)
         else fill(' ':u, 8)
        )
      + " : "
      + (if v-history-description <> ?
         then string(v-history-description, 'x(20)':u)
         else fill(' ':u, 20)
        )
      + " : "
      + (if buf_archive-history.corr-user-db-num <> ?
         then string(buf_archive-history.corr-user-db-num, '>9':u)
         else fill(' ':u, 2)
        )
      + " : "
      + (if buf_archive-history.corr-user-name <> ?
         then string(buf_archive-history.corr-user-name, 'x(8)':u)
         else fill(' ':u, 8)
        )
      + " : "
      + (if buf_archive-history.archive-detail-date <> ?
         then string(buf_archive-history.archive-detail-date, '99/99/9999':u)
         else fill(' ':u, 10)
        )
      + " : "
      + (if buf_archive-history.archive-start-date <> ?
         then string(buf_archive-history.archive-start-date, '99/99/9999':u)
         else fill(' ':u, 10)
        )
      + " : "
      + (if buf_archive-history.archive-recalc-date <> ?
         then string(buf_archive-history.archive-recalc-date, '99/99/9999':u)
         else fill(' ':u, 10)
        )
      + " : "
      + (if v-attr-calc <> ?
         then string(v-attr-calc, '+/-':u)
         else fill(' ':u, 1)
        )
      + " : "
      + (if v-attr-del <> ?
         then string(v-attr-del, '+/-':u)
         else fill(' ':u, 1)
        )
      + " : "
      + (if v-attr-disable <> ?
         then string(v-attr-disable, '+/-':u)
         else fill(' ':u, 1)
        )
      + " : "
      + (if v-attr-rest <> ?
         then string(v-attr-rest, '+/-':u)
         else fill(' ':u, 1)
        )
      + " : "
      + (if buf_archive-history.file-name <> ?
         then string(buf_archive-history.file-name, 'x(20)':u)
         else fill(' ':u, 20)
        )
      + " : "
      + (if buf_archive-history.file-valid <> ?
         then string(buf_archive-history.file-valid, '+/-':u)
         else fill(' ':u, 1)
        )
      + " : "
      + (if buf_archive-history.file-md5 <> ?
         then string(buf_archive-history.file-md5, 'x(32)':u)
         else fill(' ':u, 32)
        )
      + " : "
      + (if buf_archive-history.chip-num <> ?
         then string(buf_archive-history.chip-num, '>>>>>>9':u)
         else fill(' ':u, 6)
        )
      + " : "
      + (if buf_archive-history.file-invalid-chip-num <> ?
         then string(buf_archive-history.file-invalid-chip-num, '>>>>>>9':u)
         else fill(' ':u, 6)
        )
      skip
      .

    get next q-hist .
  end.

  put stream PrnLibStream unformatted
    v-delimiter skip
    .

  output stream PrnLibStream close .

  run prn-lib-prn-file in this-procedure (
                                            input parParentProc
                                            ,input 8
                                            ).
end.