/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обмен значениями между полями line-num таблицы

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

CREATE: Суслов Алексей Юрьевич

{&table-name} линий броузера {&browse-name}
{&open-query} - описание переоткрытия запроса после изменени

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable result as LOGICAL NO-UNDO.
ON ctrl-cursor-up OF browse {&browse-name} do:
   RUN change-line-num("up", output result).
   IF result THEN DO:
      {&open-query}
      reposition {&browse-name} to recid line-rec no-error.
   END.
END.
ON ctrl-cursor-down OF browse {&browse-name} do:
   RUN change-line-num("down", output result).
   IF result THEN DO:
      {&open-query}
      reposition {&browse-name} to recid line-rec no-error.
   END.
END.
PROCEDURE change-line-num:
define input parameter par-up-down as char no-undo.
define output parameter parresult as log initial no no-undo.
define variable source-{&table-name}-num as integer   no-undo .
define buffer   source-{&table-name}     for ub.{&table-name}.
define variable varlog as logical no-undo.
IF AVAILABLE {&table-name} THEN DO:
   ASSIGN line-rec = RECID({&table-name}).
   if sort-default = NO THEN DO:
        ASSIGN varlog = NO.
   	MESSAGE "Отсортировано не по порядку ввода в накладную."
                "Отмените сортировку!"
        VIEW-AS ALERT-BOX ERROR TITLE "Ошибка при изменении порядка ввода в накладную".
   END.
   ASSIGN source-{&table-name}-num = {&table-name}.line-num.
   FIND FIRST source-{&table-name} WHERE RECID(source-{&table-name}) = RECID({&table-name})
   EXCLUSIVE-LOCK.
   if par-up-down = "up" then GET PREV {&browse-name} EXCLUSIVE-LOCK.
                         else GET NEXT {&browse-name} EXCLUSIVE-LOCK.
   IF AVAILABLE {&table-name} THEN DO:
      ASSIGN source-{&table-name}.line-num = {&table-name}.line-num
             {&table-name}.line-num        = source-{&table-name}-num.
      ASSIGN parresult = YES.
   END.
END.
ELSE MESSAGE "Линия выбрана неправильно."
     VIEW-AS ALERT-BOX INFO BUTTONS OK.
END PROCEDURE.
/* $Workfile$ e n d */