block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gdsprtpr.p $
$Archive: ref/gdsprtpr.p $

Печать шкалы

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/11/06

*/


define input parameter parparentproc as widget-handle no-undo .
define input parameter p-node-code like ub.gds-prt.node-code no-undo .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: gdsprtpr.p $":U .
def var vss-archive     as character no-undo init "$Archive: ref/gdsprtpr.p $":U .
def var vss-description as character no-undo init "Печать шкалы".
{ cmp/vssrevis.i }

DEFINE VARIABLE line as character no-undo .
DEFINE VARIABLE date_string as character no-undo .
DEFINE VARIABLE v-found as logical no-undo .
define variable v-node-code like ub.gds-prt.node-code no-undo.
define variable v-lvl-num like ub.gds-prt.lvl-num no-undo.
define buffer buf_gds-prt for ub.gds-prt .
define buffer upper_gds-prt for ub.gds-prt .

{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }

find first buf_gds-prt no-lock where
           buf_gds-prt.node-code = p-node-code no-error.
if not available buf_gds-prt then do:
  message
  vss-workfile vss-revision vss-description skip
  "Не найден узел шкалы" skip
  "node-code" p-node-code
  view-as alert-box error .
  return error.
end.

if can-find(first upper_gds-prt no-lock where
                  upper_gds-prt.node-code = buf_gds-prt.upper-code) then do:
  message
  vss-workfile vss-revision vss-description skip
  "Узел шкалы не корневой"
  "node-code" p-node-code "upper-code" buf_gds-prt.upper-code
  view-as alert-box error .
  return error.
end.
do
on error undo, return error
:


  run prn-lib-open-stream  in this-procedure (
                                              input parParentProc
                                              ,input {&CS_PS}
                                              ,input yes /*p-is-stream*/
                                              ,input no /*p-append*/
                                              ).

  Line = fill("-", 128).
  date_string = cur-time-print() .
  PUT STREAM PrnLibStream UNFORMATTED
  line skip(0)
  date_string skip(0)
  "Шкала:" {&space-char} buf_gds-prt.node-name
  skip(1).
  assign
  v-node-code = buf_gds-prt.node-code
  v-lvl-num = 1
  v-found = yes
  .
  do while v-found = yes:
    assign
    v-found = yes
    .
    run print-level in this-procedure (
                                         input-output v-node-code
                                        ,input buf_gds-prt.upper-code
                                        ,input-output v-lvl-num
                                        ,output v-found
                                                        ) no-error.
    if error-status:error then  LEAVE.
  END.

  output  STREAM PrnLibStream CLOSE.
  run prn-lib-prn-file in this-procedure (
                                            input parParentProc
                                            ,input 0
                                            ).
end. /*doe*/

procedure print-level :
/*печать одного уровня шкалы*/
define input-output parameter p-node-code like ub.gds-prt.node-code no-undo.
define input parameter p-upper-code like ub.gds-prt.upper-code no-undo .
define input-output  parameter p-lvl-num like ub.gds-prt.lvl-num no-undo.
DEFINE output parameter p-found as logical no-undo.
define variable v-current-pos as integer no-undo.
define buffer bf_gds-prt for ub.gds-prt.
define buffer bf_lvl-name for ub.lvl-name.

  do
  on error undo, return error
  :

  if can-find(first bf_gds-prt no-lock where
                      bf_gds-prt.upper-code = p-node-code) then do:
      find first bf_lvl-name no-lock where
                 bf_lvl-name.level = p-lvl-num - 1 and
                 bf_lvl-name.upper-code = p-upper-code no-error .
      put stream PrnLibStream unformatted
      fill({&space-char}, p-lvl-num * 2)
      "Уровень" {&space-char} p-lvl-num {&colon-char} {&space-char}
      (if available bf_lvl-name then bf_lvl-name.lvl-name else "":U) skip
      fill({&space-char}, p-lvl-num * 2)
      .
      assign
      v-current-pos = p-lvl-num * 2
      .
      for each bf_gds-prt no-lock where
                  bf_gds-prt.upper-code = p-node-code:
        if v-current-pos + 14 >  {&A4_CW0} then do:
          assign
          v-current-pos = p-lvl-num * 2
          .
          put stream PrnLibStream unformatted
          skip
          fill({&space-char}, p-lvl-num * 2)
          .
        end.
        put stream PrnLibStream unformatted
        string(chr(124) + substr(bf_gds-prt.node-name, 1, 10), "X(11)") {&space-char} {&space-char} {&space-char}
        .
        assign
        v-current-pos = v-current-pos + 14
        .
      end.
      put stream PrnLibStream unformatted
      skip(1).
      assign
      p-lvl-num = p-lvl-num + 1
      .
      find first bf_gds-prt no-lock where
                  bf_gds-prt.upper-code = p-node-code.
        assign
        p-node-code = bf_gds-prt.node-code
        p-found = yes
        .
  end.
  else do:
      assign
      p-found = no
      .
  end.
    end.
end procedure. /* print-level */