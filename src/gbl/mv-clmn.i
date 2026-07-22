/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Перемещение колонок в броузере

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

CREATE: Суслов Алексей Юрьевич

*/
/*---------------------------------------------------------------------------------------
!!!ДЛЯ ТОГО, ЧТОБЫ СРАБОТАЛ НАЧАЛЬНЫЙ ПОРЯДОК - ФАЙЛ ДОЛЖЕН БЫТЬ ВКЛЮЧЕН СТРОГО ПЕРЕД WAIT-FOR!!!
    Program:  mv-clmn.i
    Created:  Суслов Алексей Юрьевич   6 Aug 1999
Description:  Перемещение колонок в броузере
              &browser-name
              находящемся во фрейме
              &frame-name
              &ext-col - Кол-во колонок
              &start-column - 1-я колонка после не перемещаемых (locked)
              Если колонки при перемещении нельзя отделять друг от друга они должны
              быть объеденены в группы
              &num-group -кол-во групп(не более 5)
              &mem-gr_x - через запятую перечисленные члены группы х
              &prev-order-column_1..5 - начальный порядок незафиксированных колонок
              &prev-order-column-condition_1..5 - условие срабатования начального порядка колонок
!!!ДЛЯ ТОГО, ЧТОБЫ СРАБОТАЛ НАЧАЛЬНЫЙ ПОРЯДОК - ФАЙЛ ДОЛЖЕН БЫТЬ ВКЛЮЧЕН СТРОГО ПЕРЕД WAIT-FOR!!!
--------------------------------------------------------------------------------------------*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

DEF VAR cur-clmn-num{&browse-name} as INT EXTENT {&ext-col} no-undo.
DEF VAR varmvi{&browse-name}       as INT no-undo.
DEF VAR varmvj{&browse-name}       as INT no-undo.
DEF VAR varmvk{&browse-name}       as INT no-undo.
DEF VAR varmvl{&browse-name}       as INT no-undo.
DEF VAR move-element{&browse-name} as INT no-undo.
def var jj{&browse-name}           as int no-undo.
do varmvi{&browse-name} = 1 to EXTENT(cur-clmn-num{&browse-name}):
  ASSIGN cur-clmn-num{&browse-name}[varmvi{&browse-name}] = varmvi{&browse-name}.
END.
RUN start-mv-clmn{&browse-name}.
PROCEDURE start-mv-clmn{&browse-name}:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   &IF "{&prev-order-column-condition_1}" <> "" &THEN
       IF {&prev-order-column-condition_1} THEN DO:
   &ENDIF
   &IF "{&prev-order-column_1}" <> "" &THEN
   DO jj{&browse-name} = NUM-ENTRIES({&prev-order-column_1}) TO 1 BY -1:
     RUN re-move-clmn{&browse-name} ( cur-clmn-num{&browse-name}[INTEGER(ENTRY (jj{&browse-name}, {&prev-order-column_1}))] , {&start-column}).
   END.
   &ENDIF
   &IF "{&prev-order-column-condition_1}" <> "" &THEN
       END.
   &ENDIF

   &IF "{&prev-order-column-condition_2}" <> "" &THEN
       IF {&prev-order-column-condition_2} THEN DO:
   &ENDIF
   &IF "{&prev-order-column_2}" <> "" &THEN
   DO jj{&browse-name} = NUM-ENTRIES({&prev-order-column_2}) TO 1 BY -1:
     RUN re-move-clmn{&browse-name} ( cur-clmn-num{&browse-name}[INTEGER(ENTRY (jj{&browse-name}, {&prev-order-column_2}))] , {&start-column}).
   END.
   &ENDIF
   &IF "{&prev-order-column-condition_2}" <> "" &THEN
       END.
   &ENDIF

   &IF "{&prev-order-column-condition_3}" <> "" &THEN
       IF {&prev-order-column-condition_3} THEN DO:
   &ENDIF
   &IF "{&prev-order-column_3}" <> "" &THEN
   DO jj{&browse-name} = NUM-ENTRIES({&prev-order-column_3}) TO 1 BY -1:
     RUN re-move-clmn{&browse-name} ( cur-clmn-num{&browse-name}[INTEGER(ENTRY (jj{&browse-name}, {&prev-order-column_3}))] , {&start-column}).
   END.
   &ENDIF
   &IF "{&prev-order-column-condition_3}" <> "" &THEN
       END.
   &ENDIF

   &IF "{&prev-order-column-condition_4}" <> "" &THEN
       IF {&prev-order-column-condition_4} THEN DO:
   &ENDIF
   &IF "{&prev-order-column_4}" <> "" &THEN
   DO jj{&browse-name} = NUM-ENTRIES({&prev-order-column_4}) TO 1 BY -1:
     RUN re-move-clmn{&browse-name} ( cur-clmn-num{&browse-name}[INTEGER(ENTRY (jj{&browse-name}, {&prev-order-column_4}))] , {&start-column}).
   END.
   &ENDIF
   &IF "{&prev-order-column-condition_4}" <> "" &THEN
       END.
   &ENDIF

   &IF "{&prev-order-column-condition_5}" <> "" &THEN
       IF {&prev-order-column-condition_5} THEN DO:
   &ENDIF
   &IF "{&prev-order-column_5}" <> "" &THEN
   DO jj{&browse-name} = NUM-ENTRIES({&prev-order-column_5}) TO 1 BY -1:
     RUN re-move-clmn{&browse-name} ( cur-clmn-num{&browse-name}[INTEGER(ENTRY (jj{&browse-name}, {&prev-order-column_5}))] , {&start-column}).
   END.
   &ENDIF
   &IF "{&prev-order-column-condition_5}" <> "" &THEN
       END.
   &ENDIF

   &IF "{&prev-order-column-condition_6}" <> "" &THEN
       IF {&prev-order-column-condition_6} THEN DO:
   &ENDIF
   &IF "{&prev-order-column_6}" <> "" &THEN
   DO jj{&browse-name} = NUM-ENTRIES({&prev-order-column_6}) TO 1 BY -1:
     RUN re-move-clmn{&browse-name} ( cur-clmn-num{&browse-name}[INTEGER(ENTRY (jj{&browse-name}, {&prev-order-column_6}))] , {&start-column}).
   END.
   &ENDIF
   &IF "{&prev-order-column-condition_6}" <> "" &THEN
       END.
   &ENDIF
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.

ON ctrl-cursor-right OF BROWSE {&browse-name} do:
  RUN re-move-clmn{&browse-name} ( {&start-column}, {&ext-col}).
END.

ON ctrl-cursor-left OF BROWSE {&browse-name} do:
  RUN re-move-clmn{&browse-name} ({&ext-col}, {&start-column}).
END.

PROCEDURE re-move-clmn{&browse-name}:
  /*Перемещение колонки с места source-column на место target-column*/
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  /*
  Надо проверить
  if num-results("{&browse-name}") = 0
  or num-results("{&browse-name}") = ? then do:
    return .
  end.
  */
  DO varmvi{&browse-name} = 1 TO EXTENT(cur-clmn-num{&browse-name}):
    if cur-clmn-num{&browse-name}[varmvi{&browse-name}] = source-column THEN cur-clmn-num{&browse-name}[varmvi{&browse-name}] = -1.
  END.

  if {&browse-name}:MOVE-COLUMN(source-column, target-column) IN FRAME {&frame-name} then.

  if source-column > target-column THEN
  DO varmvj{&browse-name} = source-column - 1 to target-column BY -1:
    DO varmvi{&browse-name} = 1 TO EXTENT(cur-clmn-num{&browse-name}):
        if cur-clmn-num{&browse-name}[varmvi{&browse-name}] = varmvj{&browse-name} THEN DO:
          cur-clmn-num{&browse-name}[varmvi{&browse-name}] = cur-clmn-num{&browse-name}[varmvi{&browse-name}] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvj{&browse-name} = source-column + 1 to target-column:
    DO varmvi{&browse-name} = 1 TO EXTENT(cur-clmn-num{&browse-name}):
      if cur-clmn-num{&browse-name}[varmvi{&browse-name}] = varmvj{&browse-name} THEN DO:
        cur-clmn-num{&browse-name}[varmvi{&browse-name}] = cur-clmn-num{&browse-name}[varmvi{&browse-name}] - 1.
      END.
    END.
  END.
  DO varmvi{&browse-name} = 1 TO EXTENT(cur-clmn-num{&browse-name}):
    if cur-clmn-num{&browse-name}[varmvi{&browse-name}] = -1 THEN cur-clmn-num{&browse-name}[varmvi{&browse-name}] = target-column.
  END.
END PROCEDURE.

PROCEDURE ch-clmn{&browse-name}:
  /*Перемещение колонки вместе с его группой*/
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.

  if cur-clmn-loc <= {&start-column} then do:
    /* часть левых колонок не перемещаем */
    return .
  end.

  DO varmvi{&browse-name} = 1 TO EXTENT(cur-clmn-num{&browse-name}):
    if cur-clmn-num{&browse-name}[varmvi{&browse-name}] = cur-clmn-loc THEN move-element{&browse-name} = varmvi{&browse-name}.
  END.
  RUN re-move-clmn{&browse-name} (cur-clmn-loc, {&start-column}).
  /*Вместе с элементом перемещаем его группу*/
  &if defined(num-group) &then
    &IF {&num-group} > 0
    &THEN
        if CAN-DO("{&mem-gr_1}", STRING(move-element{&browse-name})) THEN DO:
          ASSIGN varmvk{&browse-name} = {&start-column}.
          DO varmvl{&browse-name} = 1 to NUM-ENTRIES("{&mem-gr_1}"):
              if move-element{&browse-name} = INTEGER(ENTRY (varmvl{&browse-name},"{&mem-gr_1}")) THEN NEXT.
              varmvk{&browse-name} = varmvk{&browse-name} + 1.
              RUN re-move-clmn{&browse-name} (cur-clmn-num{&browse-name}[INTEGER(ENTRY(varmvl{&browse-name},"{&mem-gr_1}"))], varmvk{&browse-name}).
          END.
        END.
    &ENDIF
    &IF {&num-group} > 1
    &THEN
        if CAN-DO("{&mem-gr_2}", STRING(move-element{&browse-name})) THEN DO:
          ASSIGN varmvk{&browse-name} = {&start-column}.
          DO varmvl{&browse-name} = 1 to NUM-ENTRIES("{&mem-gr_2}"):
              if move-element{&browse-name} = INTEGER(ENTRY (varmvl{&browse-name},"{&mem-gr_2}")) THEN NEXT.
              varmvk{&browse-name} = varmvk{&browse-name} + 1.
              RUN re-move-clmn{&browse-name} (cur-clmn-num{&browse-name}[INTEGER(ENTRY(varmvl{&browse-name},"{&mem-gr_2}"))], varmvk{&browse-name}).
          END.
        END.
    &ENDIF
    &IF {&num-group} > 2
    &THEN
        if CAN-DO("{&mem-gr_3}", STRING(move-element{&browse-name})) THEN DO:
          ASSIGN varmvk{&browse-name} = {&start-column}.
          DO varmvl{&browse-name} = 1 to NUM-ENTRIES("{&mem-gr_3}"):
              if move-element{&browse-name} = INTEGER(ENTRY (varmvl{&browse-name},"{&mem-gr_3}")) THEN NEXT.
              varmvk{&browse-name} = varmvk{&browse-name} + 1.
              RUN re-move-clmn{&browse-name} (cur-clmn-num{&browse-name}[INTEGER(ENTRY(varmvl{&browse-name},"{&mem-gr_3}"))], varmvk{&browse-name}).
          END.
        END.
    &ENDIF
    &IF {&num-group} > 3
    &THEN
        if CAN-DO("{&mem-gr_4}", STRING(move-element{&browse-name})) THEN DO:
          ASSIGN varmvk{&browse-name} = {&start-column}.
          DO varmvl{&browse-name} = 1 to NUM-ENTRIES("{&mem-gr_4}"):
              if move-element{&browse-name} = INTEGER(ENTRY (varmvl{&browse-name},"{&mem-gr_4}")) THEN NEXT.
              varmvk{&browse-name} = varmvk{&browse-name} + 1.
              RUN re-move-clmn{&browse-name} (cur-clmn-num{&browse-name}[INTEGER(ENTRY(varmvl{&browse-name},"{&mem-gr_4}"))], varmvk{&browse-name}).
          END.
        END.
    &ENDIF
    &IF {&num-group} > 4
    &THEN
        if CAN-DO("{&mem-gr_5}", STRING(move-element{&browse-name})) THEN DO:
          ASSIGN varmvk{&browse-name} = {&start-column}.
          DO varmvl{&browse-name} = 1 to NUM-ENTRIES("{&mem-gr_5}"):
              if move-element{&browse-name} = INTEGER(ENTRY (varmvl{&browse-name},"{&mem-gr_5}")) THEN NEXT.
              varmvk{&browse-name} = varmvk{&browse-name} + 1.
              RUN re-move-clmn{&browse-name} (cur-clmn-num{&browse-name}[INTEGER(ENTRY(varmvl{&browse-name},"{&mem-gr_5}"))], varmvk{&browse-name}).
          END.
        END.
    &ENDIF
  &endif
END PROCEDURE.

PROCEDURE mv-brw-default{&browse-name}:
def var old-session as logical no-undo.
  /*Установка столбцов в порядке определенном в browser*/
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvl{&browse-name} = {&start-column} to EXTENT(cur-clmn-num{&browse-name}):
    RUN re-move-clmn{&browse-name} (cur-clmn-num{&browse-name}[varmvl{&browse-name}], varmvl{&browse-name}).
  END.
  RUN start-mv-clmn{&browse-name}.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.

&if "{&mv-brw-real-default}" = "yes" &then
PROCEDURE mv-brw-real-default{&browse-name}:
def var old-session as logical no-undo.
  /*Установка столбцов в порядке определенном в browser*/
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvl{&browse-name} = {&start-column} to EXTENT(cur-clmn-num{&browse-name}):
    RUN re-move-clmn{&browse-name} (cur-clmn-num{&browse-name}[varmvl{&browse-name}], varmvl{&browse-name}).
  END.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
&endif.

/* $Workfile$ e n d */