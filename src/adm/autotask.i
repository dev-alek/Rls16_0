/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Временная таблица автозаданий

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/18/05
Author: Bakhtadze Natalya
Creation date: 07/18/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


&if "{1}" = "define" &then

DEFINE TEMP-TABLE temp-autotask NO-UNDO
FIELD db-num like ub.db.db-num
FIELD task-type AS CHARACTER
FIELD task-name AS CHARACTER
FIELD task-date AS DATE
FIELD task-time AS INTEGER
FIELD date-time as character
FIELD overtime AS LOGICAL
FIELD corr as character
INDEX pi IS UNIQUE PRIMARY
db-num
task-type
.

&endif

&if "{1}" = "assign" &then
   find first buf_BatchProcess no-lock
      where buf_BatchProcess.BP_Status   = {&btpr-normal}
        and buf_BatchProcess.BP_Type     = {2}
        and buf_BatchProcess.CharKey_One = string( buf_db.db-num )
        and buf_BatchProcess.CharKey_Two = "auto":U
      no-error
    .
    FIND FIRST buf_temp-autotask WHERE
              buf_temp-autotask.db-num = buf_db.db-num
        AND buf_temp-autotask.task-type = {2} NO-ERROR.
    IF NOT AVAILABLE buf_temp-autotask THEN DO:
        CREATE buf_temp-autotask.
        ASSIGN
        buf_temp-autotask.db-num = buf_db.db-num
        buf_temp-autotask.task-type = {2}
        .
        case buf_temp-autotask.task-type:
          when {&btpr-type-autonws} then do:
            assign
            buf_temp-autotask.task-name = "Новости"
            .
          end.
          when {&btpr-type-autoarh} then do:
            assign
            buf_temp-autotask.task-name = "Архивы"
            .
          end.
          when {&btpr-type-autoexp} then do:
            assign
            buf_temp-autotask.task-name = "Экспорт"
            .
          end.
          when {&btpr-type-autooxml} then do:
            assign
            buf_temp-autotask.task-name = "OpenXML"
            .
          end.
          when {&btpr-type-autogetcd} then do:
            assign
            buf_temp-autotask.task-name = "Прием инф. с касс"
            .
          end.
          when {&btpr-type-autosale} then do:
            assign
            buf_temp-autotask.task-name = "Обработка продаж"
            .
          end.
          when {&btpr-type-autosuz} then do:
            assign
            buf_temp-autotask.task-name = "Отчеты"
            .
          end.
          when {&btpr-type-autocbnk} then do:
            assign
            buf_temp-autotask.task-name = "Эксп/имп в КЛИЕНТ-БАНК"
            .
          end.
          when {&btpr-type-autofree} then do:
            assign
            buf_temp-autotask.task-name = "Произвольные задания"
            .
          end.
          when {&btpr-type-sktsrv} then do:
            assign
            buf_temp-autotask.task-name = "Сокет-Сервер"
            .
          end.
          when {&btpr-type-mercury} then do:
            assign
            buf_temp-autotask.task-name = "Меркурий"
            .
          end.
          when {&btpr-type-hddtest} then do:
            assign
            buf_temp-autotask.task-name = "Мониторинг HDD"
            .
          end.
          when {&btpr-type-is_motp} then do:
            assign
            buf_temp-autotask.task-name = "ИС МОТП"
            .
          end.
          when {&btpr-type-is_diadoc} then do:
            assign
            buf_temp-autotask.task-name = "ИС Диадок"
            .
          end.
          when {&btpr-type-is_PM} then do:
            assign
            buf_temp-autotask.task-name = "ИС Президентский Мониторинг"
            .
          end.
        END CASE.
    END.

    if available buf_BatchProcess then do:
      assign
        buf_temp-autotask.task-date = buf_BatchProcess.BP_ExecSysDate
        buf_temp-autotask.task-time = buf_BatchProcess.BP_ExecSysTimeInt
      .
      if buf_temp-autotask.task-date < v-c-date
        or ( buf_temp-autotask.task-date = v-c-date
             and buf_BatchProcess.BP_ExecSysTimeInt < v-c-time
           )
      then do:
        assign
        buf_temp-autotask.overtime = YES
        .
      end.
      else do:
        if buf_temp-autotask.overtime = YES then do:
          assign
          buf_temp-autotask.overtime = NO
          .
        end.
      end.
    end.
    else do:
      assign
      buf_temp-autotask.overtime = YES
      buf_temp-autotask.task-date = ?
      buf_temp-autotask.task-time = ?
      .
    end.
    find first buf-c_BatchProcess no-lock
      where buf-c_BatchProcess.BP_Status   = {&btpr-normal}
        and buf-c_BatchProcess.BP_Type     = {2}
        and buf-c_BatchProcess.CharKey_One = string( buf_db.db-num )
        and buf-c_BatchProcess.CharKey_Two <> "auto":U
      no-error
    .
    if available buf-c_BatchProcess then do:
      assign
        buf_temp-autotask.corr = "!!!":U
      .
    end.
    else do:
      assign
      buf_temp-autotask.corr = "":U
      .
    end.
    assign
    buf_temp-autotask.date-time = string(buf_temp-autotask.task-date, "99/99/9999") + {&space-char} +
                                  string(buf_temp-autotask.task-time, "HH:MM")
   .

&endif


/* $Workfile$ e n d */