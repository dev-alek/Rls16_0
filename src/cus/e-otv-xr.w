/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Объединенная счет-фактура по ответственному хранению

Автор: Булгаков Андрей Николаевич
Дата создания: 06/28/02
Author: Andrew Bulgakoff
Creation date: 06/28/02

*/

DEFINE VARIABLE vss-revision    AS CHARACTER NO-UNDO INITIAL "$Revision$":U.
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INITIAL "$Author$":U.
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INITIAL "$Date$":U.
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INITIAL "$Workfile$":U.
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INITIAL "$Archive$":U.
DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INITIAL "Объединенная счет-фактура по ответственному хранению":U.

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ rep/rep-bt.i   }

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */
/* Local Variable Definitions ---                                       */
DEFINE VARIABLE State-source AS WIDGET-HANDLE.
DEFINE VARIABLE jj           AS INTEGER   NO-UNDO.

DEFINE BUFFER supplier FOR ub.clients.

/* ********************  Preprocessor Definitions  ******************** */
&SCOP FRAME-NAME        fr-D-otv-xr-0
&SCOP combo-box         COMBO-BOX INNER-LINES 4 LIST-ITEMS {&cmp}, {&prs}, {&stock}, {&shop}
&SCOP ENABLED-OBJECTS   v_title j_supp-code v_supp-type Btn_Supplier v_scf-code /* type-scale */ v_pay-title
&SCOP DISPLAYED-OBJECTS v_title j_supp-code v_supp-type v_supp-name  v_scf-code /* type-scale */ v_pay-title v_pay-code v_header

/* ***********************  Control Definitions  ********************** */
/* Definitions of the field level widgets                               */
DEFINE VARIABLE j_supp-code AS INTEGER   NO-UNDO VIEW-AS FILL-IN      SIZE-CHARS 11.50 BY 1.00 FORMAT "->>>>>>>>>":U.
DEFINE VARIABLE v_supp-type AS CHARACTER NO-UNDO VIEW-AS {&combo-box} SIZE-CHARS  6.50 BY 1.00 FORMAT "x(3)":U.
DEFINE VARIABLE v_supp-name AS CHARACTER NO-UNDO VIEW-AS FILL-IN      SIZE-CHARS 45.00 BY 1.00 FORMAT "x(50)":U FGCOLOR 4.
DEFINE VARIABLE type-scale  AS LOGICAL   NO-UNDO VIEW-AS TOGGLE-BOX   SIZE-CHARS 27.00 BY 1.00                  INITIAL NO.
DEFINE VARIABLE v_scf-code  AS CHARACTER NO-UNDO VIEW-AS FILL-IN      SIZE-CHARS 32.00 BY 1.00 FORMAT "x(32)":U.
DEFINE VARIABLE v_pay-code  AS CHARACTER NO-UNDO VIEW-AS FILL-IN      SIZE-CHARS 32.00 BY 1.00 FORMAT "x(32)":U.
DEFINE VARIABLE v_header    AS CHARACTER NO-UNDO VIEW-AS FILL-IN      SIZE-CHARS 20.00 BY 1.00 FORMAT "x(20)":U.
DEFINE VARIABLE v_title     AS CHARACTER NO-UNDO VIEW-AS RADIO-SET    VERTICAL
  RADIO-BUTTONS "&Отчет",                         "отчет",
                "С&чет-фактура",                  "счет-фактура",
                "Счет-фактура (с &компенсацией)", "компенсация"       SIZE-CHARS 75.00 BY 3.75 INITIAL "отчет".
DEFINE VARIABLE v_pay-title AS CHARACTER NO-UNDO VIEW-AS RADIO-SET    VERTICAL
  RADIO-BUTTONS "№ счет&а-фактуры", "счет",
                "Вручну&ю",         "вручную",
                "П&устографка",     "пусто"                           SIZE-CHARS 21.88 BY 3.00 INITIAL "счет".

DEFINE BUTTON Btn_Supplier IMAGE-UP          FILE 'btn-down-arrow'
                           IMAGE-DOWN        FILE 'btn-down-arrow'
                           IMAGE-INSENSITIVE FILE 'btn-down-arrow'
                           LABEL '':L        SIZE-CHARS 3.00 BY 1.00 DEFAULT.

/* ************************  Frame Definitions  *********************** */
DEFINE FRAME {&FRAME-NAME}
  v_header     AT ROW  1.25 COL  2.50 NO-LABEL                                    BGCOLOR  3 FGCOLOR 15
  v_title      AT ROW  2.25 COL  2.50 NO-LABEL
  Btn_Supplier AT ROW  6.50 COL  1.00
  j_supp-code  AT ROW  6.50 COL  4.00    LABEL "По&ставщик"                       BGCOLOR 15
  v_supp-type  AT ROW  6.50 COL 26.63 NO-LABEL                                    BGCOLOR 15
  v_supp-name  AT ROW  6.50 COL 33.50 NO-LABEL
  v_pay-title  AT ROW  7.67 COL 69.75 NO-LABEL
  v_scf-code   AT ROW  8.00 COL 13.50    LABEL "Номер счета-&фактуры"             BGCOLOR 15
  v_pay-code   AT ROW  9.50 COL  1.50    LABEL "К платежно-расчетному &документу" BGCOLOR  8 FGCOLOR  4
  type-scale   AT ROW 11.00 COL  1.50    LABEL "&Детализация по признакам"
WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY SIDE-LABELS NO-UNDERLINE THREE-D AT COL 1 ROW 1 SCROLLABLE BGCOLOR 8 FGCOLOR 0.

/* *********************** Procedure Settings ************************ */
/* This procedure should always be RUN PERSISTENT. Report the error, then cleanup and return. */
{ gbl/personly.i }

/* ************************* Included-Libraries *********************** */
{ src/adm/method/viewer.i }

/* ***************  Runtime Attributes and UIB Settings  ************** */
ASSIGN FRAME {&FRAME-NAME} :SCROLLABLE = NO
       FRAME {&FRAME-NAME} :HIDDEN     = YES.
ASSIGN j_supp-code  :TOOLTIP IN FRAME {&FRAME-NAME} = "Код поставщика"
       v_supp-type  :TOOLTIP IN FRAME {&FRAME-NAME} = "Тип поставщика"
       v_supp-name  :TOOLTIP IN FRAME {&FRAME-NAME} = "Наименование поставщика"
       Btn_Supplier :TOOLTIP IN FRAME {&FRAME-NAME} = "Вызов справочника клиентов"
       type-scale   :TOOLTIP IN FRAME {&FRAME-NAME} = "Печатать с детализацией по признакам".

/* ************************  Control Triggers  ************************ */
ON CHOOSE OF Btn_Supplier IN FRAME {&FRAME-NAME} DO:
  DEFINE VARIABLE v_rid-list AS CHARACTER NO-UNDO.

  run ref/cli-all.w (  INPUT my-handle,
                   INPUT "{&Btn_Select}",
                   INPUT {&pro},
                   INPUT {&all},
                   INPUT {&current},
                   INPUT ( IF AVAILABLE supplier THEN RECID( supplier ) ELSE ? ),
                   INPUT ",,,,,,NO,,",
                   INPUT ?,
                  OUTPUT v_rid-list                                               ).
  FIND supplier NO-LOCK WHERE RECID( supplier ) = INTEGER( v_rid-list ) NO-ERROR.
  IF AVAILABLE supplier THEN DO:
    ASSIGN j_supp-code = supplier.obj-code
           v_supp-type = supplier.obj-type
           v_supp-name = supplier.obj-name.
  END.                  ELSE DO:
    ASSIGN v_supp-name = "":U
           j_supp-code = 0
           v_supp-type = {&cmp}.
  END.
  DISPLAY  j_supp-code v_supp-type v_supp-name WITH FRAME {&FRAME-NAME}.
END.

ON LEAVE OF v_supp-type IN FRAME {&FRAME-NAME} DO:
  ASSIGN v_supp-type.
  FIND supplier NO-LOCK WHERE supplier.obj-type = v_supp-type AND supplier.obj-code = j_supp-code NO-ERROR.
  ASSIGN  v_supp-name = ( IF AVAILABLE supplier THEN supplier.obj-name ELSE "":U ).
  DISPLAY v_supp-name WITH FRAME {&FRAME-NAME}.
END.

ON VALUE-CHANGED OF v_supp-type IN FRAME {&FRAME-NAME} DO:
  ASSIGN v_supp-type.
  FIND supplier NO-LOCK WHERE supplier.obj-type = v_supp-type AND supplier.obj-code = j_supp-code NO-ERROR.
  ASSIGN  v_supp-name = ( IF AVAILABLE supplier THEN supplier.obj-name ELSE "":U ).
  DISPLAY v_supp-name WITH FRAME {&FRAME-NAME}.
END.

ON LEAVE OF j_supp-code IN FRAME {&FRAME-NAME} DO:
  ASSIGN j_supp-code.
  FIND supplier NO-LOCK WHERE supplier.obj-type = v_supp-type AND supplier.obj-code = j_supp-code NO-ERROR.
  ASSIGN  v_supp-name = ( IF AVAILABLE supplier THEN supplier.obj-name ELSE "":U ).
  DISPLAY v_supp-name WITH FRAME {&FRAME-NAME}.
END.

ON VALUE-CHANGED OF v_title IN FRAME {&FRAME-NAME} DO:
  ASSIGN v_title.
END.

ON LEAVE OF v_title IN FRAME {&FRAME-NAME} DO:
  ASSIGN v_title.
END.

ON LEAVE OF v_scf-code IN FRAME {&FRAME-NAME} DO:
  ASSIGN v_scf-code.
  IF INPUT FRAME {&FRAME-NAME} v_pay-title = "счет" THEN DO:
    ASSIGN  v_pay-code = v_scf-code.
    DISPLAY v_pay-code WITH FRAME {&FRAME-NAME}.
  END.
END.

ON VALUE-CHANGED OF v_pay-title IN FRAME {&FRAME-NAME} DO:
  ASSIGN v_pay-title.
  IF           v_pay-title = "счет"    THEN DO:
    ASSIGN  v_pay-code = ( INPUT FRAME {&FRAME-NAME} v_scf-code ).
    ASSIGN  v_pay-code :BGCOLOR IN FRAME {&FRAME-NAME} = 8
            v_pay-code :FGCOLOR IN FRAME {&FRAME-NAME} = 4.
    DISABLE v_pay-code WITH FRAME {&FRAME-NAME}.
    DISPLAY v_pay-code WITH FRAME {&FRAME-NAME}.
  END. ELSE IF v_pay-title = "вручную" THEN DO:
    IF v_pay-code :SENSITIVE IN FRAME {&FRAME-NAME} THEN DO: ASSIGN v_pay-code. END.
    ASSIGN  v_pay-code :BGCOLOR IN FRAME {&FRAME-NAME} = 15
            v_pay-code :FGCOLOR IN FRAME {&FRAME-NAME} = 0.
    ENABLE  v_pay-code WITH FRAME {&FRAME-NAME}.
    APPLY "ENTRY":U TO v_pay-code IN FRAME {&FRAME-NAME}.
  END. ELSE IF v_pay-title = "пусто"   THEN DO:
    ASSIGN  v_pay-code = "":U.
    ASSIGN  v_pay-code :BGCOLOR IN FRAME {&FRAME-NAME} = 8
            v_pay-code :FGCOLOR IN FRAME {&FRAME-NAME} = 4.
    DISABLE v_pay-code WITH FRAME {&FRAME-NAME}.
    DISPLAY v_pay-code WITH FRAME {&FRAME-NAME}.
  END.
END.

ON LEAVE OF v_pay-title IN FRAME {&FRAME-NAME} DO:
  ASSIGN v_pay-title.
END.

/* ON VALUE-CHANGED OF type-scale IN FRAME {&FRAME-NAME} DO: ASSIGN type-scale. END. */

/* ***************************  Main Block  *************************** */
/* If testing in the UIB, initialize the SmartObject. */
&IF DEFINED( UIB_IS_RUNNING ) <> 0 &THEN RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ). &ENDIF

ASSIGN  v_supp-type = {&cmp}
        v_header    = " З А Г О Л О В О К ".
ASSIGN  v_pay-code :BGCOLOR IN FRAME {&FRAME-NAME} = 8
        v_pay-code :FGCOLOR IN FRAME {&FRAME-NAME} = 4.
DISPLAY v_supp-type v_header WITH FRAME {&FRAME-NAME}.

/* **********************  Internal Procedures  *********************** */
PROCEDURE disable_UI :
  HIDE FRAME {&FRAME-NAME} NO-PAUSE.
  IF THIS-PROCEDURE :PERSISTENT THEN DO: DELETE PROCEDURE THIS-PROCEDURE. END.
END PROCEDURE. /* disable_UI */

PROCEDURE local-initialize :
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ).
  { cmp/cr-objls.i v-cntxt-obj-type v-cntxt-obj-code }

  ASSIGN  v_supp-type = {&cmp}.
  DISPLAY v_supp-type WITH FRAME {&FRAME-NAME}.
END PROCEDURE. /* local-initialize */

PROCEDURE my-report :
  ASSIGN FRAME {&FRAME-NAME} v_supp-type j_supp-code v_scf-code v_pay-code /* type-scale */ .
  ASSIGN PrintRubl  = ( x-SET_val_TYPE = 1 )
         v_pay-code = "№ " + v_pay-code.
  IF v_title = "компенсация" THEN DO:
    run cus/r-otvxr1.p ( INPUT my-handle,
                     INPUT v_supp-type,
                     INPUT j_supp-code,
                     INPUT x-date-start,
                     INPUT x-date-end,
                     INPUT v_scf-code,
                     INPUT v_pay-code,
                     INPUT ( v_pay-title = "счет" ) /* ,
                     INPUT type-scale */   ).
  END.                       ELSE DO:
    run cus/r-otv-xr.p ( INPUT my-handle,
                     INPUT v_supp-type,
                     INPUT j_supp-code,
                     INPUT x-date-start,
                     INPUT x-date-end,
                     INPUT v_scf-code,
                     INPUT v_pay-code,
                     INPUT v_title,
                     INPUT ( v_pay-title = "счет" ) /* ,
                     INPUT type-scale */   ).
  END.
END PROCEDURE. /* my-report */

PROCEDURE my-var :
  ASSIGN FRAME {&FRAME-NAME} v_supp-type j_supp-code type-scale.

  IF           v_title = "компенсация"  THEN DO:
    ASSIGN ReportName   = " С Ч Е Т - Ф А К Т У Р А   П О   О Т В Е Т С Т В Е Н Н О М У   Х Р А Н Е Н И Ю ".
  END. ELSE IF v_title = "отчет"        THEN DO:
    ASSIGN ReportName   = " О Т Ч Е Т   П О   О Т В Е Т С Т В Е Н Н О М У   Х Р А Н Е Н И Ю ".
  END. ELSE IF v_title = "счет-фактура" THEN DO:
    ASSIGN ReportName   = " С Ч Е Т - Ф А К Т У Р А   П О   О Т В Е Т С Т В Е Н Н О М У   Х Р А Н Е Н И Ю ".
  END.                                  ELSE DO:
    ASSIGN ReportName   = " С Ч Е Т - Ф А К Т У Р А   П О   О Т В Е Т С Т В Е Н Н О М У   Х Р А Н Е Н И Ю ".
  END.
  ASSIGN ReportHeader = "  от "       + STRING( x-date-end,   "99.99.9999":U ) + CHR( 10 ) +
                        "Поставщик: " +         v_supp-name.
  ASSIGN Sheetf.Excel-Column-Lable = "Наименование товара,Ед.,Количество,Цена за,Ст-ть товаров,в т.ч.,Ставка,Сумма," +
                                     "Ст-ть товаров,Страна,Номер ГТД," + {&new-line} +
                                     ",изм.,,ед. изм.,без налога,акциз,налога,налога,с налогом,происхождения,,,"
         Sheetf.Sizes              = "59,4,11,12,17,9,6,12,15,15,26,"
         Sheetf.Make-correct       = FILL( "FALSE,", 11 ).
END PROCEDURE. /* my-var */

PROCEDURE state-changed :
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.

  CASE p-state : /* Object instance CASEs can go here to replace standard behavior or add new cases. */
  END CASE. /* p-state */
END PROCEDURE. /* state-changed */
