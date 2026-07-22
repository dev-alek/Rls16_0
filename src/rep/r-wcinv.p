block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-wcinv.p $
$Archive: rep/r-wcinv.p $

Печать удаленного документа инвентаризации материальных ценностей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/09/05
Author: Bakhtadze Natalya
Creation date: 09/09/05

Author:  Булгаков А.Н.
Created: 30/07/2001.

*/

/* ***************************  Definitions  ************************** */
/* Parameters Definitions */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-c-wth-doc-recid as recid.

/* VSS Variables Definitions */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision: aea5316774be, 0, rls $":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author: expertek $":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile: r-wcinv.p $":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive: rep/r-wcinv.p $":U.
define variable vss-description AS CHAR NO-UNDO INIT "печать удаленного документа инвентаризации материальных ценностей":U.

/* Shared Variables & Preprocessors Definitions */
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ gbl/cur-time.i }

/* Preprocessors Definitions */
&SCOP FRAME-NAME frm-print-w-inv-0

/* Local Variables Definitions */
define variable sym1 AS CHAR FORM "x(1)":U COLUMN-LABEL ":!:" INIT ":":U NO-UNDO.
define variable sym2 AS CHAR FORM "x(1)":U COLUMN-LABEL ":!:" INIT ":":U NO-UNDO.
define variable sym3 AS CHAR FORM "x(1)":U COLUMN-LABEL ":!:" INIT ":":U NO-UNDO.
define variable sym4 AS CHAR FORM "x(1)":U COLUMN-LABEL ":!:" INIT ":":U NO-UNDO.
define variable sym5 AS CHAR FORM "x(1)":U COLUMN-LABEL ":!:" INIT ":":U NO-UNDO.
define variable sym6 AS CHAR FORM "x(1)":U COLUMN-LABEL ":!:" INIT ":":U NO-UNDO.

define variable Line        AS CHAR NO-UNDO.
define variable v_wth-name  AS CHAR NO-UNDO FORM "x(40)":U.
define variable v_wth-place AS CHAR NO-UNDO FORM "x(20)":U.
define variable d_sum-diff  AS DEC  NO-UNDO FORM "->>>,>>>,>>9.99":U.

/* Buffers Definitions */
DEFine  BUFFER buf_c-wth-doc   FOR ub.c-wth-doc.
DEFine  BUFFER buf-cmp FOR ub.clients.
DEFine  BUFFER buf-obj FOR ub.clients.
DEFine  BUFFER buf-pn1 FOR ub.clients.
DEFine  BUFFER buf-pn2 FOR ub.clients.
DEFine  BUFFER buf-pn3 FOR ub.clients.
DEFine  BUFFER buf-pn4 FOR ub.clients.
DEFine  BUFFER buf-pn5 FOR ub.clients.

/* **********************  Frame Definitions  *********************** */
DEF FRAME {&FRAME-NAME}
sym1 No-LABEL
v_wth-name           NO-LABEL FORM "x(40)":U
sym2 No-LABEL
v_wth-place          NO-LABEL FORM "x(20)":U
sym3 No-LABEL
ub.c-wth-line.doc-sum  NO-LABEL FORM "->>,>>>,>>9.99":U
sym4 No-LABEL
ub.c-wth-line.fact-sum NO-LABEL FORM "->>,>>>,>>9.99":U
sym5 No-LABEL
d_sum-diff           NO-LABEL FORM "->>>,>>>,>>9.99":U
sym6 No-LABEL
HEADER
SPACE( 7 ) "Страница:" PAGE-NUMBER(PrnLibStream) FORM ">>9":U SKIP
"-----------------------------------------------------------------------------------------------------------------------" SKIP
":                                          :                      :      Сумма     :      Сумма     :   Расхождение   :" SKIP
":               Наименование               :    Место хранения    :      План      :      Факт      :   План - Факт   :" SKIP
"-----------------------------------------------------------------------------------------------------------------------"
WITH WIDTH {&A4_CW0} DOWN STREAM-IO  NO-BOX NO-Underline No-LABELS.

/* ***************************  Main Block  *************************** */
Main-Block:
DO ON ERROR   UNDO Main-Block, LEAVE Main-Block
   ON END-KEY UNDO Main-Block, LEAVE Main-Block
   ON STOP    UNDO Main-Block, LEAVE Main-Block :
  FIND FIRST buf_c-wth-doc where
            recid(buf_c-wth-doc) = p-c-wth-doc-recid No-ERROR.
  IF NOT AVAIL buf_c-wth-doc THEN DO:
    MESSAGE "Удаленный документ инвентаризации МЦ не найден!" VIEW-AS ALERT-BOX ERROR.
    UNDO Main-Block, LEAVE Main-Block.
  END.
  ELSE DO:
    ASSIGN Line = FILL( "-":U, {&A4_CW0} ).
  END.
  FIND buf-cmp NO-LOCK WHERE
      buf-cmp.obj-type = {&cmp}          AND
      buf-cmp.obj-code = buf_c-wth-doc.host-code NO-ERROR.
  FIND buf-obj NO-LOCK WHERE
      buf-obj.obj-type = buf_c-wth-doc.obj-type AND
      buf-obj.obj-code = buf_c-wth-doc.obj-code NO-ERROR.
  FIND FIRST buf-pn1 NO-LOCK WHERE
      buf-pn1.obj-type = {&prs}         AND
      buf-pn1.obj-code = buf_c-wth-doc.operator NO-ERROR.
  FIND buf-pn2 NO-LOCK WHERE
      buf-pn2.obj-type = {&prs}         AND
      buf-pn2.obj-code = buf_c-wth-doc.deliver  NO-ERROR.
  FIND buf-pn3 NO-LOCK WHERE
      buf-pn3.obj-type = {&prs}         AND
      buf-pn3.obj-code = buf_c-wth-doc.receiver NO-ERROR.
  FIND buf-pn4 NO-LOCK WHERE
      buf-pn4.obj-type = {&prs}         AND
      buf-pn4.obj-code = buf_c-wth-doc.inv-prs4 NO-ERROR.
  FIND buf-pn5 NO-LOCK WHERE
      buf-pn5.obj-type = {&prs}         AND
      buf-pn5.obj-code = buf_c-wth-doc.inv-prs5 NO-ERROR.
  run prn-lib-open-stream  in this-procedure (
                                              input parParentProc
                                              ,input {&CS_PS}
                                              ,input yes /*p-is-stream*/
                                              ,input no /*p-append*/
                                              ).


  PUT STREAM PrnLibStream UNFORMATTED
  buf-cmp.obj-name                           AT  6 SKIP
  buf-obj.obj-name                           AT  6 SKIP(1)
  "УДАЛЕННАЯ ИНВЕНТАРИЗАЦИОННАЯ ВЕДОМОСТЬ"   AT 30 SKIP
  "ДВИЖЕНИЕ МАТЕРИАЛЬНЫХ ЦЕННОСТЕЙ НА АЗК"   AT 20 SKIP
  "Смена:"                                   AT 43
  STRING( buf_c-wth-doc.shift-name, "X(2)":U ) " от "
  STRING( buf_c-wth-doc.shift-date, "99-99-9999":U ) SKIP(0)
  cur-time-print() at 57 format "X(35)" SKIP
  .
  FORM HEADER
  Line format "X(118)" AT 1 SKIP
  "Продолжение - на следующей странице" AT 30 SKIP
  with FRAME BottomFrame width {&A4_CW0} PAGE-BOTTOM NO-LABELS NO-BOX .

  VIEW  STREAM PrnLibStream FRAME BottomFrame .
  FORM with FRAME {&frame-name}  .

  FOR EACH ub.c-wth-line NO-LOCK WHERE
           ub.c-wth-line.doc-code = buf_c-wth-doc.doc-code
       AND ub.c-wth-line.corr-user-db-num = buf_c-wth-doc.chip-num
       AND ub.c-wth-line.chip-num = buf_c-wth-doc.chip-num
           :
    FIND ub.wealth     NO-LOCK WHERE
         ub.wealth.wth-code   = ub.c-wth-line.wth-code NO-ERROR.
    FIND ub.wth-place  NO-LOCK WHERE
      ub.wth-place.host-code = buf_c-wth-doc.host-code      AND
      ub.wth-place.obj-type  = buf_c-wth-doc.obj-type       AND
      ub.wth-place.obj-code  = buf_c-wth-doc.obj-code       AND
      ub.wth-place.w-p-code  = ub.c-wth-line.w-p-code NO-ERROR.
    ASSIGN
    v_wth-name  = ( IF AVAIL ub.wealth    THEN ub.wealth.wth-name    ELSE "":U )
    v_wth-place = ( IF AVAIL ub.wth-place THEN ub.wth-place.w-p-name ELSE "":U )
    d_sum-diff  = ( ub.c-wth-line.fact-sum - ub.c-wth-line.doc-sum )
    .
    ACCUMULATE
    ub.c-wth-line.doc-sum ( TOTAL )
    ub.c-wth-line.fact-sum ( TOTAL )
    d_sum-diff          ( TOTAL )
    .
    DISP  STREAM PrnLibStream
    sym1 v_wth-name
    sym2 v_wth-place
    sym3 ub.c-wth-line.doc-sum
    sym4 ub.c-wth-line.fact-sum
    sym5 d_sum-diff
    Sym6
    WITH FRAME {&FRAME-NAME}.
    DOWN  STREAM PrnLibStream
    WITH FRAME {&FRAME-NAME}.
  END.
  UNDERLINE STREAM PrnLibStream
  sym1 v_wth-name
  sym2 v_wth-place
  sym3 ub.c-wth-line.doc-sum
  sym4 ub.c-wth-line.fact-sum
  sym5 d_sum-diff
  Sym6
  WITH FRAME {&frame-name}.
  DOWN  STREAM PrnLibStream
  WITH FRAME {&FRAME-NAME}.
  DISP  STREAM PrnLibStream
  sym1
  sym2
  sym3 (ACCUM TOTAL ub.c-wth-line.doc-sum ) @ ub.c-wth-line.doc-sum
  sym4 (ACCUM TOTAL ub.c-wth-line.fact-sum ) @ ub.c-wth-line.fact-sum
  sym5 (ACCUM TOTAL d_sum-diff) @ d_sum-diff
  Sym6
  WITH FRAME {&FRAME-NAME}.
  DOWN  STREAM PrnLibStream
  WITH FRAME {&FRAME-NAME}.
  UNDERLINE STREAM PrnLibStream
  sym1 v_wth-name
  sym2 v_wth-place
  sym3 ub.c-wth-line.doc-sum
  sym4 ub.c-wth-line.fact-sum
  sym5 d_sum-diff
  Sym6
  WITH FRAME {&frame-name}.
  DOWN  STREAM PrnLibStream
  WITH FRAME {&FRAME-NAME}.

  PUT  STREAM PrnLibStream UNFORMATTED
  SKIP( 2 ) "Члены Инвентаризационной комиссии"
  SKIP( 1 )
  SUBSTR( (if avail buf-pn1 then buf-pn1.obj-name else '':U)  + FILL( "_", 60 ), 1, 60 ) + " подпись " + FILL( "_", 40 )
  SKIP( 1 )
  SUBSTR( (if avail buf-pn2 then buf-pn2.obj-name else '':U)  + FILL( "_", 60 ), 1, 60 ) + " подпись " + FILL( "_", 40 )
  SKIP( 1 )
  SUBSTR( (if avail buf-pn3 then buf-pn3.obj-name else '':U)  + FILL( "_", 60 ), 1, 60 ) + " подпись " + FILL( "_", 40 )
  SKIP( 1 )
  SUBSTR( (if avail buf-pn4 then buf-pn4.obj-name else '':U)  + FILL( "_", 60 ), 1, 60 ) + " подпись " + FILL( "_", 40 )
  SKIP( 1 )
  SUBSTR( (if avail buf-pn5 then buf-pn5.obj-name else '':U)  + FILL( "_", 60 ), 1, 60 ) + " подпись " + FILL( "_", 40 )
  SKIP
  .
  HIDE  STREAM PrnLibStream FRAME BottomFrame .
  HIDE  STREAM PrnLibStream FRAME {&frame-name}.
  OUTPUT  STREAM PrnLibStream CLOSE.

  run prn-lib-prn-file in this-procedure (
                                            input parParentProc
                                            ,input 0
                                            ).
END.