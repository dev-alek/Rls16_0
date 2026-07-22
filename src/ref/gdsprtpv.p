block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gdsprtpv.p $
$Archive: ref/gdsprtpv.p $

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
def var vss-workfile    as character no-undo init "$Workfile: gdsprtpv.p $":U .
def var vss-archive     as character no-undo init "$Archive: ref/gdsprtpv.p $":U .
def var vss-description as character no-undo init "Печать шкалы".
{ cmp/vssrevis.i }

DEFINE VARIABLE line as character no-undo .
DEFINE VARIABLE date_string as character no-undo .
DEFINE VARIABLE v-found as logical no-undo .
define variable v-node-code like ub.gds-prt.node-code no-undo.
define variable v-lvl-num like ub.gds-prt.lvl-num no-undo.
DEFINE VARIABLE lvl as character no-undo extent 10.
DEFINE VARIABLE lvl-name as character no-undo extent 10.
DEFINE VARIABLE v-current-page as integer no-undo .
DEFINE VARIABLE v-first-page as logical no-undo init yes.

define buffer buf_gds-prt for ub.gds-prt .
define buffer upper_gds-prt for ub.gds-prt .
{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }

define temp-table tt-level no-undo
FIELD level like ub.lvl-name.level
FIELD lvl-name like ub.lvl-name.lvl-name
index pi is primary unique
level
.

define temp-table tt-prt no-undo
FIELD node-code like ub.gds-prt.node-code
FIELD node-name like ub.gds-prt.node-name
FIELD level like ub.lvl-name.level
FIELD line-num as integer
index pi is PRIMARY UNIQUE
level
node-code
index line is unique
line-num level
.

DEFINE FRAME PRT-FRAME
lvl[1]  column-label "Уровень 1" FORMAT "x(18)"       space(1)
lvl[2]  column-label "Уровень 2" FORMAT "x(18)"       space(1)
lvl[3]  column-label "Уровень 3" FORMAT "x(18)"       space(1)
lvl[4]  column-label "Уровень 4" FORMAT "x(18)"       space(1)
lvl[5]  column-label "Уровень 5" FORMAT "x(18)"       space(1)
lvl[6]  column-label "Уровень 6" FORMAT "x(18)"       space(1)
lvl[7]  column-label "Уровень 7" FORMAT "x(18)"       space(1)
lvl[8]  column-label "Уровень 8" FORMAT "x(18)"       space(1)
lvl[9]  column-label "Уровень 9" FORMAT "x(18)"       space(1)
lvl[10]  column-label "Уровень 10" FORMAT "x(18)"       space(1)
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(198)" AT 1
with width {&DOS_CW_2} down stream-io use-text NO-BOX.



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
  for each tt-level:
    delete tt-level.
  end.
  for each tt-prt:
    delete tt-prt.
  END.
  assign
  v-node-code = buf_gds-prt.node-code
  v-lvl-num = 1
  v-found = yes
  .
  do while v-found = yes:
    assign
    v-found = yes
    .
    run create-level in this-procedure (
                                         input-output v-node-code
                                        ,input buf_gds-prt.upper-code
                                        ,input-output v-lvl-num
                                        ,output v-found
                                                        ) no-error.
    if error-status:error then  LEAVE.
  END.


  run prn-lib-open-stream  in this-procedure (
                                              input parParentProc
                                              ,input {&LS_PS_A4}
                                              ,input yes /*p-is-stream*/
                                              ,input no /*p-append*/
                                              ).
  Line = fill("-", 198).
  date_string = cur-time-print() .
  FOR EACH tt-level no-lock:
    assign
    lvl-name[tt-level.level + 1] = substr(tt-level.lvl-name, 1, 18)
    .
  END.
  FORM HEADER
  Line format "X(198)" AT 1 SKIP
  "Продолжение - на следующей странице" AT 30 SKIP
  with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW  STREAM PrnLibStream FRAME BottomFrame .
  FORM with FRAME PRT-FRAME.
  FOR EACH tt-prt No-LOCK
  BREAK
  by tt-prt.line-num
  by tt-prt.level:
    if first-of(tt-prt.line-num) then do:
      assign
      lvl[1] = "":U
      lvl[2] = "":U
      lvl[3] = "":U
      lvl[4] = "":U
      lvl[5] = "":U
      lvl[6] = "":U
      lvl[7] = "":U
      lvl[8] = "":U
      lvl[9] = "":U
      lvl[10] = "":U
      .
      DOWN stream PrnLibStream
      with FRAME PRT-FRAME.
    end.
    assign
    lvl[tt-prt.level + 1] = tt-prt.node-name
    .
    if LAST-of(tt-prt.line-num) then do:
      if v-first-page = yes then do:
        PUT STREAM PrnLibStream UNFORMATTED
        "Шкала:" {&space-char} buf_gds-prt.node-name
        skip.
        PUT stream PrnLibStream unformatted
        skip(2).
        DISPLAY STREAM PrnLibStream
        lvl-name[1] @   lvl[1]
        lvl-name[2] @   lvl[2]
        lvl-name[3] @   lvl[3]
        lvl-name[4] @   lvl[4]
        lvl-name[5] @   lvl[5]
        lvl-name[6] @   lvl[6]
        lvl-name[7] @   lvl[7]
        lvl-name[8] @   lvl[8]
        lvl-name[9]  @  lvl[9]
        lvl-name[10] @  lvl[10]
        with frame prt-frame.
        assign
        v-first-page = no
        v-current-page = page-number(PrnLibStream)
        .
        DOWN stream PrnLibStream
        with frame prt-frame.
        underline stream PrnLibStream
        lvl[1]
        lvl[2]
        lvl[3]
        lvl[4]
        lvl[5]
        lvl[6]
        lvl[7]
        lvl[8]
        lvl[9]
        lvl[10]
        with frame prt-frame.
        DOWN stream PrnLibStream
        with frame prt-frame.
      end.
      display stream PrnLibStream
      lvl[1]
      lvl[2]
      lvl[3]
      lvl[4]
      lvl[5]
      lvl[6]
      lvl[7]
      lvl[8]
      lvl[9]
      lvl[10]
      with frame prt-frame.
    END.
  END.
  HIDE  STREAM PrnLibStream FRAME BottomFrame .
  output  STREAM PrnLibStream CLOSE.
  run prn-lib-prn-file in this-procedure (
                                            input parParentProc
                                            ,input 8
                                            ).

end. /*doe*/

procedure create-level :
/*создание записей во временной таблице для одного уровня шкалы*/
define input-output parameter p-node-code like ub.gds-prt.node-code no-undo.
define input parameter p-upper-code like ub.gds-prt.upper-code no-undo .
define input-output  parameter p-lvl-num like ub.gds-prt.lvl-num no-undo.
DEFINE output parameter p-found as logical no-undo.
DEFINE VARIABLE v-line-num as integer no-undo .
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
      find first tt-level where
                 tt-level.level = p-lvl-num - 1  no-error .
      if not available tt-level then do:
        create tt-level.
        assign
        tt-level.level = p-lvl-num - 1
        tt-level.lvl-name = if available bf_lvl-name then bf_lvl-name.lvl-name else "":U
        .
      end.

      for each bf_gds-prt no-lock where
                  bf_gds-prt.upper-code = p-node-code:
        assign
        v-line-num = v-line-num + 1
        .
        find first tt-prt where
                   tt-prt.node-code = bf_gds-prt.node-code no-error .
        if not available tt-prt then do:
          create tt-prt.
          assign
          tt-prt.node-code = bf_gds-prt.node-code
          tt-prt.level = p-lvl-num - 1
          .
        end.
        assign
        tt-prt.node-name = substr(bf_gds-prt.node-name, 1, 10)
        tt-prt.line-num = v-line-num
        .
      end.
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
end procedure. /* create-level */