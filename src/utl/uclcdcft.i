/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Заполнение временной таблицы алгоритмов перед расчетом

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/25/06
Author: Bakhtadze Natalya
Creation date: 12/25/06

*/

                                                                                                                        &scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE fill-table :
define input parameter p-dc-type-list-mode as character no-undo .
define input parameter p-dc-type-list as character no-undo .
define input parameter p-calc-only as logical no-undo .
DEFINE BUFFER buf_dis-card-type FOR ub.dis-card-type.
DEFINE BUFFER buf_rule-by-call FOR ub.rule-by-call.
DEFINE BUFFER buf_tt0-rule-by-call FOR tt0-rule-by-call.
_buf_dis-card-type:
FOR EACH buf_dis-card-type:
  IF p-dc-type-list-mode = "*":U THEN.
  ELSE DO:
      IF not lookup(buf_dis-card-type.type, p-dc-type-list) > 0 then next _buf_dis-card-type.
  END.
  for each buf_rule-by-call no-lock where
          buf_rule-by-call.call_id = buf_dis-card-type.uniq-key-rec
      AND buf_rule-by-call.codex_id = 2
      AND buf_rule-by-call.ruleset_id = 5:
    if p-calc-only and buf_rule-by-call.can-calc = no then NEXT.
    find first buf_tt0-rule-by-call no-lock where
              buf_tt0-rule-by-call.call_id = buf_rule-by-call.call_id
          and buf_tt0-rule-by-call.ruleset_id = buf_rule-by-call.ruleset_id
          and buf_tt0-rule-by-call.order_id = buf_rule-by-call.order_id no-error.
    if not available buf_tt0-rule-by-call then do:
      create buf_tt0-rule-by-call.
      buffer-copy buf_rule-by-call to buf_tt0-rule-by-call.
    end.
  end.
END. /*for each t\buf_tt-dis-card-type*/

END PROCEDURE.

/* $Workfile$ e n d */