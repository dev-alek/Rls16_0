&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет о продажах

Автор: Суслов Алексей Юрьевич
Дата создания: 04/12/06
Author: Alexey Suslov
Creation date: 04/12/06


*/

/************************ Global definitions ****************************/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Отчет о продажах".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ str/in-vatp.i  def }
{ str/out-vatp.i def }
{ cmp/r-pril.i   new }
{ gbl/prn-lib.i }
{ gbl/waitfram.i }
{ cmp/showinf.i }


&scop format-price format ">>>>9.99"
&scop format-summa format ">>>>>>>9.99"
/* ***************************  Definitions  ************************** */


/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.

{ rep/sale-clc-rom.i def}
DEFINE FRAME gds-grp
      sym1                          column-label ":!:" format "X(1)" space(0)
      tt-doc-line.gds-type          COLUMN-LABEL "т"   format "x(1)" space(0)
      sym2                          column-label ":!:" format "X(1)" space(0)
      tt-doc-line.artic             COLUMN-LABEL "Артикул"           space(0)
      sym3                          column-label ":!:" format "X(1)" space(0)
      tt-doc-line.gds-name          COLUMN-label "Название"          space(0)
      sym4                          column-label ":!:" format "X(1)" space(0)
      tt-doc-line.vat-acc           COLUMN-LABEL "НДС"  format ">9.99" space(0)
      sym5                          column-label ":!:" format "X(1)"         space(0)
      tt-doc-line.road-tax          COLUMN-LABEL "Дор.нал." {&format-price} space(0)
      sym6                          column-label ":!:" format "X(1)"          space(0)
      tt-doc-line.qnty              COLUMN-LABEL "Количество"                 space(0)
      sym7                          column-label ":!:" format "X(1)"          space(0)
      tt-doc-line.price-acc-out-vat COLUMN-LABEL "Уч. цена! без НДС" {&format-price} space(0)
      sym8                          column-label ":!:" format "X(1)" space(0)
      tt-doc-line.sum-vat-acc       COLUMN-LABEL "Сумма!НДС" {&format-summa} space(0)
      sym9                          column-label ":!:" format "X(1)"         space(0)
      tt-doc-line.price-acc         COLUMN-LABEL "Уч. цена! с НДС" {&format-price} space(0)
      sym10                         column-label ":!:" format "X(1)" space(0)
      tt-doc-line.increase          COLUMN-LABEL "Наценка" format "->>>>>9.99" space(0)
      sym11                         column-label ":!:" format "X(1)" space(0)
      tt-doc-line.vat-sale          COLUMN-LABEL "НДС" format ">9.99" space(0)
      sym12                         column-label ":!:" format "X(1)"  space(0)
      tt-doc-line.sum-vat-sale      COLUMN-LABEL "Сумма!НДС" {&format-summa} space(0)
      sym13                         column-label ":!:" format "X(1)" space(0)
      tt-doc-line.price-sale        COLUMN-LABEL "Розн.цена! с НДС" {&format-price} space(0)
      sym14                         column-label ":!:" format "X(1)" space(0)
      tt-doc-line.sum-acc-out-vat   COLUMN-LABEL "Сумма по уч!цене без НДС" {&format-summa} space(0)
      sym15                         column-label ":!:" format "X(1)" space(0)
      tt-doc-line.sum-sale-out-vat  column-label "Сумма прод.! без НДС" {&format-summa} space(0)
      sym16                         column-label ":!:" format "X(1)" space(0)
      tt-doc-line.sum-sale          column-label "Сумма прод.! c НДС" {&format-summa} space(0)
      sym17                         column-label ":!:" format "X(1)" space(0)
    HEADER
        cur-time-print() AT 5 format "X(35)"
        string( "Отчет о продажах: ") AT 45 format "X(40)"
        string( "Страница " + string( PAGE-NUMBER( PrnLibStream ), ">>9" ) ) AT 150 format "X(13)" SKIP
        Line format "X(195)" AT 1
    with width {&DOS_CW_2} down stream-io.
if session:set-wait-state("COMPILER") then.
assign Line = fill("-", 195).

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-help start-date end-date b-date ~
rb-gds-grp b-print
&Scoped-Define DISPLAYED-OBJECTS start-date end-date rb-gds-grp vargrp-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-date
     LABEL "Сбор данных"
     SIZE 15.38 BY 1.08.

DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "Выход"
     SIZE 9.5 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10.25 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON b-print
     LABEL "Печать"
     SIZE 15.13 BY 1.08.

DEFINE BUTTON r-gds-grp
     IMAGE-UP FILE "btn-down-arrow"
     IMAGE-DOWN FILE "btn-down-arrow"
     IMAGE-INSENSITIVE FILE "btn-down-arrow"
     SIZE 3.13 BY .96.

DEFINE VARIABLE vargrp-name AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 55.38 BY 2.75 NO-UNDO.

DEFINE VARIABLE end-date AS DATE FORMAT "99/99/99":U
     LABEL "По"
     VIEW-AS FILL-IN
     SIZE 14.13 BY 1.08 NO-UNDO.

DEFINE VARIABLE start-date AS DATE FORMAT "99/99/99":U
     LABEL "С"
     VIEW-AS FILL-IN
     SIZE 14.13 BY 1.08 NO-UNDO.

DEFINE VARIABLE rb-gds-grp AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
     "По всему классификатору", 1,
     "Выборочно", 2
     SIZE 54.88 BY .96 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1.17 COL 1.75
     b-help AT ROW 1.17 COL 13.38
     start-date AT ROW 2.67 COL 2.25
     end-date AT ROW 2.67 COL 22.13
     b-date AT ROW 2.67 COL 42.13
     rb-gds-grp AT ROW 4 COL 2.38 NO-LABEL
     b-print AT ROW 5.25 COL 42.25
     r-gds-grp AT ROW 5.38 COL 37.13
     vargrp-name AT ROW 6.58 COL 1.63 NO-LABEL
     "   Уровень классификатора" VIEW-AS TEXT
          SIZE 28.13 BY 1.08 AT ROW 5.29 COL 1.88
     SPACE(27.98) SKIP(3.29)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Отчет о продажах"
         DEFAULT-BUTTON b-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN end-date IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR BUTTON r-gds-grp IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN start-date IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR EDITOR vargrp-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Отчет о продажах */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-date Dialog-Frame
ON CHOOSE OF b-date IN FRAME Dialog-Frame /* Сбор данных */
DO:
  for each tt-doc-line:
      delete tt-doc-line.
  end.
  RUN calc-sale
  (INPUT p-curr-obj-type,
   INPUT p-curr-obj-code,
   INPUT input frame {&frame-name} start-date,
   INPUT input frame {&frame-name} end-date)
  .
  message "Сбор данных завершен" view-as alert-box.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


{ gbl/app_help.i }
&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
DO:
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

FORM with FRAME gds-grp.
FORM HEADER
    Line format "X(195)" AT 1 SKIP
    "Продолжение - на следующей странице" AT 60 SKIP
    with FRAME BottomFrame width {&DOS_CW_2}
    PAGE-BOTTOM no-labels no-box.
VIEW STREAM PrnLibStream FRAME BottomFrame .
PUT STREAM PrnLibStream
    string( "Отчет за период с: " + string(input frame {&frame-name} start-date,"99/99/9999") + " по: " + string(input frame {&frame-name} end-date,"99/99/9999"))
    AT 37 format "X(195)" SKIP(1).
  assign varroot = vargds-grp.
  RUN calc-gds-grp (input  1,
                    input  vargds-grp,
                    input  " ",
                    output varsum-vat-acc,
                    output varsum-vat-sale,
                    output varsum-acc-out-vat,
                    output varsum-sale-out-vat,
                    output varsum-sale,
                    output varsum-road-tax,
                    output varsum-qnty).
HIDE STREAM PrnLibStream FRAME BottomFrame .
OUTPUT STREAM PrnLibStream CLOSE.

if session:set-wait-state("") then.
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-gds-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-gds-grp Dialog-Frame
ON CHOOSE OF r-gds-grp IN FRAME Dialog-Frame
DO:
  define variable ref-list as character no-undo.
  run ref/gds-grp.w (
                  input parparentproc
                 ,input "b-sel"
                 ,input p-curr-obj-type
                 ,input p-curr-obj-code
                 ,input-output ref-list).
  IF REF-LIST <>  "":U then do:
    find first gds-grp where RECID(gds-grp) = integer(ref-list) no-lock.
    ASSIGN vargrp-name:SCREEN-VALUE in frame {&frame-name} = gds-grp.node-name
          vargds-grp = gds-grp.node-code.
  end.
  else do:
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rb-gds-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rb-gds-grp Dialog-Frame
ON VALUE-CHANGED OF rb-gds-grp IN FRAME Dialog-Frame
DO:
  if input frame {&frame-name} rb-gds-grp = 1 then do:
    find first gds-grp where gds-grp.upper-code = 0 no-lock.
    vargds-grp = gds-grp.node-code.
     ASSIGN vargrp-name:SCREEN-VALUE in frame {&frame-name} = " "
            r-gds-grp:SENSITIVE      = no.
  end.
  else do:
       assign r-gds-grp:SENSITIVE      = yes.
       apply "choose" to r-gds-grp in frame {&frame-name}.
       return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/ed_date.i start-date }
{ gbl/ed_date.i end-date }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/curobjdt.i p-curr-obj-type p-curr-obj-code v-today }
  assign
      start-date = v-today
      end-date   = v-today
  .
  find first gds-grp where gds-grp.upper-code = 0 no-lock.
  vargds-grp = gds-grp.node-code.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-gds-grp Dialog-Frame
{ rep/sale-clc-rom.i calc-grp}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-sale Dialog-Frame
{ rep/sale-clc-rom.i calc}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  HIDE FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame _DEFAULT-ENABLE
PROCEDURE enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  DISPLAY start-date end-date rb-gds-grp vargrp-name
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-help start-date end-date b-date rb-gds-grp b-print
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disp-tt-doc-line Dialog-Frame
PROCEDURE disp-tt-doc-line:
    display stream PrnLibStream
           sym1
           tt-doc-line.gds-type
           sym2
           tt-doc-line.artic
           sym3
           tt-doc-line.gds-name
           sym4
           tt-doc-line.vat-acc
           sym5
           tt-doc-line.road-tax
           sym6
           tt-doc-line.qnty
           sym7
           tt-doc-line.price-acc-out-vat
           sym8
           tt-doc-line.sum-vat-acc
           sym9
           tt-doc-line.price-acc
           sym10
           tt-doc-line.increase
           sym11
           tt-doc-line.vat-sale
           sym12
           tt-doc-line.sum-vat-sale
           sym13
           tt-doc-line.price-sale
           sym14
           tt-doc-line.sum-acc-out-vat
           sym15
           tt-doc-line.sum-sale-out-vat
           sym16
           tt-doc-line.sum-sale
           sym17
           with frame gds-grp.
DOWN STREAM PrnLibStream 1 with FRAME gds-grp.
           PUT STREAM PrnLibStream Line format "X(195)" SKIP.
END PROCEDURE.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disp-total Dialog-Frame
PROCEDURE disp-total:
define input parameter pardispgrp-name         as   character           no-undo.
define input parameter pardispsum-vat-acc      like doc-line.price-rubl no-undo.
define input parameter pardispsum-vat-sale     like doc-line.price-rubl no-undo.
define input parameter pardispsum-acc-out-vat  like doc-line.price-rubl no-undo.
define input parameter pardispsum-sale-out-vat like doc-line.price-rubl no-undo.
define input parameter pardispsum-sale         like doc-line.price-rubl no-undo.
define input parameter pardispsum-road-tax     like doc-line.price-rubl no-undo.
define input parameter pardispsum-qnty         like doc-line.fact-qnty  no-undo.

display stream PrnLibStream
sym1
">" @ tt-doc-line.gds-type
sym2
"Итого " @ tt-doc-line.artic
sym3
pardispgrp-name @ tt-doc-line.gds-name
sym4
sym5
sym6
sym7
sym8
pardispsum-vat-acc        @ tt-doc-line.sum-vat-acc
sym9
sym10
sym11
sym12
pardispsum-vat-sale       @ tt-doc-line.sum-vat-sale
sym13
sym14
pardispsum-acc-out-vat    @ tt-doc-line.sum-acc-out-vat
sym15
pardispsum-sale-out-vat   @ tt-doc-line.sum-sale-out-vat
sym16
pardispsum-sale           @ tt-doc-line.sum-sale
sym17
with frame gds-grp.
DOWN STREAM PrnLibStream 1 with FRAME gds-grp.
           PUT STREAM PrnLibStream Line format "X(195)" SKIP.
END PROCEDURE.
&ANALYZE-RESUME
procedure disp-grp-name:
define input parameter pargrp-name like goods.grp-name no-undo.
end procedure.