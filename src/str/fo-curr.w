&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Форма ввода и корректировки курсов ФО

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06


Creation date: 05/11/04 1:12
*/
/*------------------------------------------------------------------------

  File:

  Description:

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author:

  Created:
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parParentProc   AS WIDGET-HANDLE NO-UNDO.
define input parameter par-host-code   as integer no-undo .
define input-output parameter   p-sum-rubl      as decimal no-undo .
define input-output parameter   p-sum-base      as decimal no-undo .
define input-output parameter   p-sum-contr     as decimal no-undo .
define  input         parameter p-basecode      as integer no-undo .
define  input-output  parameter p-base-rate     as decimal no-undo .
define  input-output  parameter p-base-scale    as integer no-undo .
define  input         parameter p-contract-curr as integer no-undo .
define  input-output  parameter p-contract-rate as decimal no-undo .
define  input-output  parameter p-contract-scale as integer no-undo .
define input parameter          p-val-pay as integer no-undo .
define input parameter p-hide-rubl  as logical no-undo .
define input parameter p-hide-base  as logical no-undo .
define input parameter p-hide-contr as logical no-undo .
define output parameter p-res as logical no-undo .

/* Local Variable Definitions ---                                       */

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Форма ввода и корректировки курсов ФО".
{ cmp/vssrevis.i  }
{ cmp/trg-def.i   }
{ cmp/showinf.i   }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit B-quit B-Help loc_sum-contract-2 ~
B-r-1 B-r-2 loc_sum-contract B-r-4 r-curr-base B-r-3 r-curr-contr B-r-5 ~
FILL-IN-8 loc_abbr-rubl-5 loc_abbr-rubl-6 loc_abbr-rubl-7 loc_abbr-base-2 ~
loc_abbr-rubl-8 loc_abbr-contr-2 loc_abbr-rubl-2 loc_abbr-rubl ~
loc_abbr-base loc_abbr-contr RECT-6 RECT-7
&Scoped-Define DISPLAYED-OBJECTS loc_sum-rubl-2 loc_base-rate-2 ~
loc_base-scale-2 loc_sum-base-2 loc_contract-rate-2 loc_contract-scale-2 ~
loc_sum-contract-2 loc_sum-rubl loc_sum-base loc_sum-contract loc_base-rate ~
loc_base-scale loc_contract-rate loc_contract-scale FILL-IN-8 ~
loc_abbr-rubl-5 loc_abbr-rubl-6 loc_abbr-rubl-7 loc_abbr-base-2 ~
loc_abbr-rubl-8 loc_abbr-contr-2 loc_abbr-rubl-2 loc_abbr-rubl ~
loc_abbr-base loc_abbr-contr

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-1 loc_contract-rate-2 loc_contract-scale-2 ~
loc_sum-contract-2 loc_sum-contract loc_contract-rate loc_contract-scale
&Scoped-define List-2 loc_base-rate-2 loc_base-scale-2 loc_contract-rate-2 ~
loc_contract-scale-2 loc_base-rate loc_base-scale loc_contract-rate ~
loc_contract-scale
&Scoped-define List-5 loc_sum-rubl-2 loc_sum-rubl loc_abbr-rubl-5 ~
loc_abbr-rubl-6 loc_abbr-rubl-7 loc_abbr-rubl-8 loc_abbr-rubl-2 ~
loc_abbr-rubl
&Scoped-define List-6 loc_base-rate-2 loc_base-scale-2 loc_sum-base-2 ~
loc_sum-base loc_base-rate loc_base-scale loc_abbr-base-2 loc_abbr-contr-2 ~
loc_abbr-base loc_abbr-contr

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD sel-abbr Dialog-Frame
FUNCTION sel-abbr RETURNS CHARACTER
( p-curr-code as int )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU POPUP-MENU-B-r-1
       MENU-ITEM m_rubl-base    LABEL "Пересчитать {&abbr_rub_allshift} по курсу и сумме в &баз.вал."
       MENU-ITEM m_rubl-contr   LABEL "Пересчитать {&abbr_rub_allshift} по курсу и сумме в вал.&договора".


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-r-1
     LABEL "Расчет"
     SIZE 10 BY 1 TOOLTIP "Пересчитать национальную валюту"
     BGCOLOR 8 .

DEFINE BUTTON B-r-2
     LABEL "Расчет"
     SIZE 10 BY 1 TOOLTIP "Пересчитать сумму в Б.В. по курсу Б.В. и сумме в {&abbr_rublyah}"
     BGCOLOR 8 .

DEFINE BUTTON B-r-3
     LABEL "Расчет"
     SIZE 10 BY 1 TOOLTIP "Пересчитать курс Б.В. по сумме Б.В. и сумме в {&abbr_rublyah}"
     BGCOLOR 8 .

DEFINE BUTTON B-r-4
     LABEL "Расчет"
     SIZE 10 BY 1 TOOLTIP "Пересчитать сумму в вал.договора по курсу вал.договора и сумме в {&abbr_rublyah}"
     BGCOLOR 8 .

DEFINE BUTTON B-r-5
     LABEL "Расчет"
     SIZE 10 BY 1 TOOLTIP "Пересчитать курс вал.договора по сумме в вал.договора и сумме в {&abbr_rublyah}"
     BGCOLOR 8 .

DEFINE BUTTON r-curr-base
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88 TOOLTIP "Выбор из справочника валют".

DEFINE BUTTON r-curr-contr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88 TOOLTIP "Выбор из справочника валют".

DEFINE VARIABLE FILL-IN-8 AS CHARACTER FORMAT "X(256)":U INITIAL "Старые значения"
      VIEW-AS TEXT
     SIZE 16 BY .67
     FGCOLOR 3  NO-UNDO.

DEFINE VARIABLE loc_abbr-base AS CHARACTER FORMAT "X(12)":U
     LABEL "Баз.вал."
      VIEW-AS TEXT
     SIZE 5.38 BY .67 TOOLTIP "Базовая валюта"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE loc_abbr-base-2 AS CHARACTER FORMAT "X(12)":U
      VIEW-AS TEXT
     SIZE 5.38 BY 1 TOOLTIP "Базовая валюта"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE loc_abbr-contr AS CHARACTER FORMAT "X(12)":U
     LABEL "Валюта договора"
      VIEW-AS TEXT
     SIZE 5.13 BY .67 TOOLTIP "Валюта договора"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE loc_abbr-contr-2 AS CHARACTER FORMAT "X(12)":U
      VIEW-AS TEXT
     SIZE 5.13 BY 1 TOOLTIP "Валюта договора"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE loc_abbr-rubl AS CHARACTER FORMAT "X(12)":U INITIAL "{&abbr_rub_allshift}"
      VIEW-AS TEXT
     SIZE 4.5 BY 1 TOOLTIP "Национальная валюта"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE loc_abbr-rubl-2 AS CHARACTER FORMAT "X(20)":U INITIAL "Национальная валюта:"
      VIEW-AS TEXT
     SIZE 21.5 BY 1 TOOLTIP "Национальная валюта" NO-UNDO.

DEFINE VARIABLE loc_abbr-rubl-5 AS CHARACTER FORMAT "X(20)":U INITIAL "Национальная валюта:"
      VIEW-AS TEXT
     SIZE 21.5 BY 1 TOOLTIP "Национальная валюта" NO-UNDO.

DEFINE VARIABLE loc_abbr-rubl-6 AS CHARACTER FORMAT "X(12)":U INITIAL "{&abbr_rub_allshift}"
      VIEW-AS TEXT
     SIZE 4.5 BY 1 TOOLTIP "Национальная валюта"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE loc_abbr-rubl-7 AS CHARACTER FORMAT "X(12)":U INITIAL "Баз.вал.:"
      VIEW-AS TEXT
     SIZE 9.5 BY 1 NO-UNDO.

DEFINE VARIABLE loc_abbr-rubl-8 AS CHARACTER FORMAT "X(12)":U INITIAL "Договор :"
      VIEW-AS TEXT
     SIZE 9.5 BY 1 NO-UNDO.

DEFINE VARIABLE loc_base-rate AS DECIMAL FORMAT ">>,>>9.9999" INITIAL 0
     LABEL "Курс"
     VIEW-AS FILL-IN NATIVE
     SIZE 12 BY 1.

DEFINE VARIABLE loc_base-rate-2 AS DECIMAL FORMAT ">>,>>9.9999" INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 12 BY 1.

DEFINE VARIABLE loc_base-scale AS INTEGER FORMAT ">,>>>,>>9" INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 5 BY 1.

DEFINE VARIABLE loc_base-scale-2 AS INTEGER FORMAT ">,>>>,>>9" INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 5 BY 1.

DEFINE VARIABLE loc_contract-rate AS DECIMAL FORMAT ">>,>>9.9999" INITIAL 0
     LABEL "Курс"
     VIEW-AS FILL-IN NATIVE
     SIZE 12 BY 1.

DEFINE VARIABLE loc_contract-rate-2 AS DECIMAL FORMAT ">>,>>9.9999" INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 12 BY 1.

DEFINE VARIABLE loc_contract-scale AS INTEGER FORMAT ">,>>>,>>9" INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 5 BY 1.

DEFINE VARIABLE loc_contract-scale-2 AS INTEGER FORMAT ">,>>>,>>9" INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 5 BY 1.

DEFINE VARIABLE loc_sum-base LIKE fin-ob.sum-base
     LABEL "Сумма"
     VIEW-AS FILL-IN NATIVE
     SIZE 22 BY 1 NO-UNDO.

DEFINE VARIABLE loc_sum-base-2 LIKE fin-ob.sum-base
     VIEW-AS FILL-IN NATIVE
     SIZE 22 BY 1 TOOLTIP "<<F5>> - пересчет курса баз.вал." NO-UNDO.

DEFINE VARIABLE loc_sum-contract LIKE fin-ob.sum-contract
     LABEL "Сумма"
     VIEW-AS FILL-IN NATIVE
     SIZE 22 BY 1 NO-UNDO.

DEFINE VARIABLE loc_sum-contract-2 LIKE fin-ob.sum-contract
     VIEW-AS FILL-IN NATIVE
     SIZE 22 BY 1 TOOLTIP "<<F5>> - пересчет курса валюты договора" NO-UNDO.

DEFINE VARIABLE loc_sum-rubl LIKE fin-ob.sum-rubl
     VIEW-AS FILL-IN NATIVE
     SIZE 22 BY 1 NO-UNDO.

DEFINE VARIABLE loc_sum-rubl-2 LIKE fin-ob.sum-rubl
     VIEW-AS FILL-IN NATIVE
     SIZE 22 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 98.5 BY 9.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 98.5 BY 9.25.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 89.5
     loc_sum-rubl-2 AT ROW 4 COL 40.5 COLON-ALIGNED NO-LABEL FORMAT "->,>>>,>>>,>>>,>>9.99"
     loc_base-rate-2 AT ROW 6 COL 22 COLON-ALIGNED NO-LABEL
     loc_base-scale-2 AT ROW 6 COL 34.5 COLON-ALIGNED NO-LABEL
     loc_sum-base-2 AT ROW 6 COL 40.5 COLON-ALIGNED NO-LABEL FORMAT "->,>>>,>>>,>>>,>>9.99"
     loc_contract-rate-2 AT ROW 8 COL 22 COLON-ALIGNED NO-LABEL
     loc_contract-scale-2 AT ROW 8 COL 34.5 COLON-ALIGNED NO-LABEL
     loc_sum-contract-2 AT ROW 8 COL 40.5 COLON-ALIGNED NO-LABEL FORMAT "->,>>>,>>>,>>>,>>9.99"
     loc_sum-rubl AT ROW 12.5 COL 38.5 COLON-ALIGNED NO-LABEL FORMAT "->,>>>,>>>,>>>,>>9.99"
     B-r-1 AT ROW 12.5 COL 63
     loc_sum-base AT ROW 17.25 COL 10 COLON-ALIGNED
          LABEL "Сумма" FORMAT "->,>>>,>>>,>>>,>>9.99"
     B-r-2 AT ROW 17.25 COL 34.5
     loc_sum-contract AT ROW 17.25 COL 64 COLON-ALIGNED
          LABEL "Сумма" FORMAT "->,>>>,>>>,>>>,>>9.99"
     B-r-4 AT ROW 17.25 COL 88.5
     loc_base-rate AT ROW 18.25 COL 10 COLON-ALIGNED
     loc_base-scale AT ROW 18.25 COL 22.5 COLON-ALIGNED NO-LABEL
     r-curr-base AT ROW 18.25 COL 30.5
     B-r-3 AT ROW 18.25 COL 34.5
     loc_contract-rate AT ROW 18.25 COL 64 COLON-ALIGNED
     loc_contract-scale AT ROW 18.25 COL 76.5 COLON-ALIGNED NO-LABEL
     r-curr-contr AT ROW 18.25 COL 84.5
     B-r-5 AT ROW 18.25 COL 88.5
     FILL-IN-8 AT ROW 1.25 COL 36 COLON-ALIGNED NO-LABEL
     loc_abbr-rubl-5 AT ROW 4 COL 15.5 NO-LABEL
     loc_abbr-rubl-6 AT ROW 4 COL 37.5 NO-LABEL
     loc_abbr-rubl-7 AT ROW 6 COL 4 NO-LABEL
     loc_abbr-base-2 AT ROW 6 COL 17.5 NO-LABEL AUTO-RETURN
     loc_abbr-rubl-8 AT ROW 8 COL 4 NO-LABEL
     loc_abbr-contr-2 AT ROW 8.13 COL 17.5 NO-LABEL AUTO-RETURN
     loc_abbr-rubl-2 AT ROW 12.5 COL 13.5 NO-LABEL
     loc_abbr-rubl AT ROW 12.5 COL 35.5 NO-LABEL
     loc_abbr-base AT ROW 16.5 COL 2 AUTO-RETURN
     loc_abbr-contr AT ROW 16.5 COL 49 AUTO-RETURN
     RECT-6 AT ROW 2.25 COL 1
     RECT-7 AT ROW 11.25 COL 1
     SPACE(0.00) SKIP(0.16)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Расчет сумм и курсов ФО"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-r-1:POPUP-MENU IN FRAME Dialog-Frame       = MENU POPUP-MENU-B-r-1:HANDLE.

/* SETTINGS FOR FILL-IN loc_abbr-base IN FRAME Dialog-Frame
   ALIGN-L 6                                                            */
/* SETTINGS FOR FILL-IN loc_abbr-base-2 IN FRAME Dialog-Frame
   ALIGN-L 6                                                            */
/* SETTINGS FOR FILL-IN loc_abbr-contr IN FRAME Dialog-Frame
   ALIGN-L 6                                                            */
/* SETTINGS FOR FILL-IN loc_abbr-contr-2 IN FRAME Dialog-Frame
   ALIGN-L 6                                                            */
/* SETTINGS FOR FILL-IN loc_abbr-rubl IN FRAME Dialog-Frame
   ALIGN-L 5                                                            */
/* SETTINGS FOR FILL-IN loc_abbr-rubl-2 IN FRAME Dialog-Frame
   ALIGN-L 5                                                            */
/* SETTINGS FOR FILL-IN loc_abbr-rubl-5 IN FRAME Dialog-Frame
   ALIGN-L 5                                                            */
/* SETTINGS FOR FILL-IN loc_abbr-rubl-6 IN FRAME Dialog-Frame
   ALIGN-L 5                                                            */
/* SETTINGS FOR FILL-IN loc_abbr-rubl-7 IN FRAME Dialog-Frame
   ALIGN-L 5                                                            */
/* SETTINGS FOR FILL-IN loc_abbr-rubl-8 IN FRAME Dialog-Frame
   ALIGN-L 5                                                            */
/* SETTINGS FOR FILL-IN loc_base-rate IN FRAME Dialog-Frame
   NO-ENABLE 2 6                                                        */
/* SETTINGS FOR FILL-IN loc_base-rate-2 IN FRAME Dialog-Frame
   NO-ENABLE 2 6                                                        */
/* SETTINGS FOR FILL-IN loc_base-scale IN FRAME Dialog-Frame
   NO-ENABLE 2 6                                                        */
/* SETTINGS FOR FILL-IN loc_base-scale-2 IN FRAME Dialog-Frame
   NO-ENABLE 2 6                                                        */
/* SETTINGS FOR FILL-IN loc_contract-rate IN FRAME Dialog-Frame
   NO-ENABLE 1 2                                                        */
/* SETTINGS FOR FILL-IN loc_contract-rate-2 IN FRAME Dialog-Frame
   NO-ENABLE 1 2                                                        */
/* SETTINGS FOR FILL-IN loc_contract-scale IN FRAME Dialog-Frame
   NO-ENABLE 1 2                                                        */
/* SETTINGS FOR FILL-IN loc_contract-scale-2 IN FRAME Dialog-Frame
   NO-ENABLE 1 2                                                        */
/* SETTINGS FOR FILL-IN loc_sum-base IN FRAME Dialog-Frame
   NO-ENABLE 6 LIKE = ub.fin-ob.sum-base EXP-LABEL EXP-FORMAT EXP-SIZE  */
/* SETTINGS FOR FILL-IN loc_sum-base-2 IN FRAME Dialog-Frame
   NO-ENABLE 6 LIKE = ub.fin-ob.sum-base EXP-FORMAT EXP-SIZE            */
/* SETTINGS FOR FILL-IN loc_sum-contract IN FRAME Dialog-Frame
   1 LIKE = ub.fin-ob.sum-contract EXP-LABEL EXP-FORMAT                 */
/* SETTINGS FOR FILL-IN loc_sum-contract-2 IN FRAME Dialog-Frame
   1 LIKE = ub.fin-ob.sum-contract EXP-FORMAT EXP-SIZE                  */
/* SETTINGS FOR FILL-IN loc_sum-rubl IN FRAME Dialog-Frame
   NO-ENABLE 5 LIKE = ub.fin-ob.sum-rubl EXP-FORMAT EXP-SIZE            */
/* SETTINGS FOR FILL-IN loc_sum-rubl-2 IN FRAME Dialog-Frame
   NO-ENABLE 5 LIKE = ub.fin-ob.sum-rubl EXP-FORMAT EXP-SIZE            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Расчет сумм и курсов ФО */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
DEFINE VARIABLE v-rate-correct AS CHARACTER NO-UNDO.
p-res = YES.
run ver-summ in this-procedure (output v-rate-correct) no-error.
if error-status:error then do:
  message "Ошибка при вызове процедуры rate-correct." skip
          return-value
          error-status:get-message(1)
          error-status:get-message(2)
  view-as alert-box error.
  return no-apply.
end.
CASE v-rate-correct:
    WHEN "base-rate":U THEN DO:
           message
          "Курс базовой валюты не согласован с суммой в базовой валюте и суммой в национальной валюте" skip
          "Сумма в базовой валюте: " loc_sum-base skip
          "Сумма в {&abbr_rublyah}: " loc_sum-rubl skip
          "Курс базовой валюты: " loc_base-rate skip
          "Шкала базовой валюты: " loc_base-scale
  view-as alert-box information.
    /*
      if b-base-rate:sensitive then do:
        apply "entry" to b-base-rate.
      end.
      else do:
        apply "entry" to sum-doc-1.
      end.
      */
        RETURN NO-apply.
    END.
    WHEN "contract-rate":U THEN DO:
        message
          "Курс валюты договора не согласован c суммой договора и суммой в национальной валюте" skip
          "Сумма в валюте договора: " loc_sum-contract skip
          "Сумма в {&abbr_rublyah}: " loc_sum-rubl skip
          "Курс валюты договора: " loc_contract-rate skip
          "Шкала валюты договора: " loc_contract-scale
view-as alert-box information.
        /*
      if b-contract-rate:sensitive then do:
        apply "entry" to b-contract-rate.
      end.
      else do:
        apply "entry" to sum-contr-1.
      end.*/

        return NO-apply.
  END.
END CASE.

if loc_sum-rubl = 0 or loc_sum-rubl = ? or
    loc_sum-base       = 0 or   loc_sum-base      = ? or
    loc_sum-contract   = 0 or   loc_sum-contract   = ? or

    loc_base-rate      = 0 or   loc_base-rate      = ? or
    loc_base-scale     = 0 or   loc_base-scale     = ? or

    loc_contract-rate  = 0 or   loc_contract-rate   = ? or
    loc_contract-scale = 0 or   loc_contract-scale  = ?
 then do:
    message "Ошибка при вводе сумм или курсов! "
    "Значение не должно равнятся 0 или ?"  view-as alert-box error .
            return NO-apply.
end.

if
    loc_base-rate      < 0   or
    loc_base-scale     < 0   or
    loc_contract-rate  < 0   or
    loc_contract-scale < 0
 then do:
    message "Ошибка при вводе курсов! "
    "Значение не должно быть меньше 0 "
    view-as alert-box error .
            return NO-apply.
end.



assign
   p-sum-rubl        =  loc_sum-rubl
   p-sum-base        =  loc_sum-base
   p-sum-contr       =  loc_sum-contract

   p-base-rate       =  loc_base-rate
   p-base-scale      =  loc_base-scale

   p-contract-rate   =  loc_contract-rate
   p-contract-scale  =  loc_contract-scale

.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-quit Dialog-Frame
ON CHOOSE OF B-quit IN FRAME Dialog-Frame /* Отказ */
DO:
  p-res = NO.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-r-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-r-1 Dialog-Frame
ON CHOOSE OF B-r-1 IN FRAME Dialog-Frame /* Расчет */
DO:
    run gbl/pop-up.p (self:handle, no) no-error.
    IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-r-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-r-2 Dialog-Frame
ON CHOOSE OF B-r-2 IN FRAME Dialog-Frame /* Расчет */
DO:
    assign loc_sum-rubl
           loc_base-rate
           loc_base-scale
           .

   loc_sum-base  = (  loc_base-scale   / loc_base-rate) * loc_sum-rubl  .

   display
      loc_sum-base         when loc_sum-base         :visible
      with frame {&frame-name}  .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-r-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-r-3 Dialog-Frame
ON CHOOSE OF B-r-3 IN FRAME Dialog-Frame /* Расчет */
DO:
   ASSIGN loc_sum-rubl
          loc_base-scale
          loc_sum-base
        .


    loc_base-rate = loc_sum-rubl / (loc_base-scale * loc_sum-base) .

    DISPLAY loc_base-rate  WITH FRAME {&FRAME-NAME}  .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-r-4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-r-4 Dialog-Frame
ON CHOOSE OF B-r-4 IN FRAME Dialog-Frame /* Расчет */
DO:
    assign loc_sum-rubl
         loc_contract-rate
         loc_contract-scale
  .
 loc_sum-contract   = (  loc_contract-scale   / loc_contract-rate) * loc_sum-rubl .

   display
    loc_sum-contract         when loc_sum-contract         :visible
    with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-r-5
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-r-5 Dialog-Frame
ON CHOOSE OF B-r-5 IN FRAME Dialog-Frame /* Расчет */
DO:
  ASSIGN
      loc_sum-rubl
      loc_contract-scale
      loc_sum-contract
      .

  loc_contract-rate = loc_sum-rubl / (loc_contract-scale * loc_sum-contract) .
  DISPLAY loc_contract-rate  WITH FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc_base-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_base-rate Dialog-Frame
ON LEAVE OF loc_base-rate IN FRAME Dialog-Frame /* Курс */
DO:
  APPLY "LEAVE":U TO loc_sum-base .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_base-rate Dialog-Frame
ON return OF loc_base-rate IN FRAME Dialog-Frame /* Курс */
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc_base-rate-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_base-rate-2 Dialog-Frame
ON LEAVE OF loc_base-rate-2 IN FRAME Dialog-Frame
OR "LEAVE" Of loc_base-scale
OR "LEAVE" Of loc_contract-rate
OR "LEAVE" Of loc_contract-scale

DO:
  assign loc_base-rate loc_base-scale
  loc_contract-rate
  loc_contract-scale
  .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_base-rate-2 Dialog-Frame
ON return OF loc_base-rate-2 IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc_base-scale
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_base-scale Dialog-Frame
ON LEAVE OF loc_base-scale IN FRAME Dialog-Frame
DO:
  APPLY "LEAVE":U TO loc_sum-base .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_base-scale Dialog-Frame
ON return OF loc_base-scale IN FRAME Dialog-Frame
DO:
  run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc_base-scale-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_base-scale-2 Dialog-Frame
ON return OF loc_base-scale-2 IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc_contract-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_contract-rate Dialog-Frame
ON LEAVE OF loc_contract-rate IN FRAME Dialog-Frame /* Курс */
DO:
  APPLY "LEAVE":U TO loc_sum-contract .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_contract-rate Dialog-Frame
ON return OF loc_contract-rate IN FRAME Dialog-Frame /* Курс */
DO:

    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc_contract-rate-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_contract-rate-2 Dialog-Frame
ON return OF loc_contract-rate-2 IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc_contract-scale
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_contract-scale Dialog-Frame
ON LEAVE OF loc_contract-scale IN FRAME Dialog-Frame
DO:
  APPLY "LEAVE":U TO loc_sum-contract .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_contract-scale Dialog-Frame
ON return OF loc_contract-scale IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc_contract-scale-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_contract-scale-2 Dialog-Frame
ON return OF loc_contract-scale-2 IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc_sum-base
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_sum-base Dialog-Frame
ON LEAVE OF loc_sum-base IN FRAME Dialog-Frame /* Сумма */
DO:
    IF loc_sum-base:MODIFIED THEN ASSIGN loc_sum-base.
    IF loc_base-scale:MODIFIED THEN ASSIGN loc_base-scale.
    IF loc_base-rate:MODIFIED THEN ASSIGN loc_base-rate.



    IF p-contract-curr = p-basecode AND p-hide-contr = YES THEN DO:
  loc_sum-contract   = loc_sum-base.
  loc_contract-rate  = loc_base-rate.
  loc_contract-scale = loc_base-scale .
      DISPLAY
            loc_sum-contract
            loc_contract-rate
            loc_contract-scale
        with frame {&frame-name}.
    END.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_sum-base Dialog-Frame
ON return OF loc_sum-base IN FRAME Dialog-Frame /* Сумма */
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc_sum-base-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_sum-base-2 Dialog-Frame
ON LEAVE OF loc_sum-base-2 IN FRAME Dialog-Frame
DO:

assign loc_sum-base
 loc_base-rate loc_base-scale

 loc_contract-rate loc_contract-scale

 .
  loc_sum-rubl    = ( loc_base-rate  / loc_base-scale) * loc_sum-base .
  loc_sum-contract   = (  loc_contract-scale   / loc_contract-rate) * loc_sum-rubl .

   display
    loc_sum-base         when loc_sum-base         :visible
    loc_sum-rubl         when loc_sum-rubl         :visible
    loc_sum-contract     when loc_sum-contract     :visible
    with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_sum-base-2 Dialog-Frame
ON return OF loc_sum-base-2 IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc_sum-contract
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_sum-contract Dialog-Frame
ON LEAVE OF loc_sum-contract IN FRAME Dialog-Frame /* Сумма */
DO:
    IF loc_sum-contract:MODIFIED   THEN ASSIGN loc_sum-contract.
    IF loc_contract-rate:MODIFIED  THEN ASSIGN loc_contract-rate.
    IF loc_contract-scale:MODIFIED THEN ASSIGN loc_contract-scale.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_sum-contract Dialog-Frame
ON return OF loc_sum-contract IN FRAME Dialog-Frame /* Сумма */
DO:

    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc_sum-contract-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_sum-contract-2 Dialog-Frame
ON LEAVE OF loc_sum-contract-2 IN FRAME Dialog-Frame
DO:

 assign loc_sum-contract
 loc_base-rate loc_base-scale

 loc_contract-rate loc_contract-scale
 .
  loc_sum-rubl  =  ( loc_contract-rate  / loc_contract-scale) * loc_sum-contract .
  loc_sum-base   = (  loc_base-scale   / loc_base-rate) * loc_sum-rubl .


  display
  loc_sum-base           when loc_sum-base         :visible
  loc_sum-rubl           when loc_sum-rubl         :visible
  loc_sum-contract       when loc_sum-contract     :visible

  with frame {&frame-name}.
 END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_sum-contract-2 Dialog-Frame
ON return OF loc_sum-contract-2 IN FRAME Dialog-Frame
DO:
      run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc_sum-rubl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_sum-rubl Dialog-Frame
ON LEAVE OF loc_sum-rubl IN FRAME Dialog-Frame
DO:

IF loc_sum-rubl:MODIFIED THEN ASSIGN loc_sum-rubl.

IF p-basecode = 0 THEN DO:
loc_sum-base   = loc_sum-rubl.
loc_base-rate  = 1           .
loc_base-scale = 1           .
    DISPLAY
          loc_sum-base
          loc_base-rate
          loc_base-scale
      with frame {&frame-name}.
  END.
  IF p-contract-curr = 0 THEN DO:
  loc_sum-contract   = loc_sum-rubl.
  loc_contract-rate  = 1           .
  loc_contract-scale = 1           .
      DISPLAY
            loc_sum-contract
            loc_contract-rate
            loc_contract-scale
        with frame {&frame-name}.
    END.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_sum-rubl Dialog-Frame
ON return OF loc_sum-rubl IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc_sum-rubl-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_sum-rubl-2 Dialog-Frame
ON LEAVE OF loc_sum-rubl-2 IN FRAME Dialog-Frame
DO:

assign loc_sum-rubl
 loc_base-rate loc_base-scale

 loc_contract-rate loc_contract-scale
 .
  loc_sum-base    = ( loc_base-scale  / loc_base-rate) * loc_sum-rubl .

  loc_sum-contract      = (  loc_contract-scale    / loc_contract-rate) * loc_sum-rubl .
  display
  loc_sum-base            when loc_sum-base         :visible
  loc_sum-contract        when loc_sum-contract     :visible
  with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_sum-rubl-2 Dialog-Frame
ON return OF loc_sum-rubl-2 IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_rubl-base
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_rubl-base Dialog-Frame
ON CHOOSE OF MENU-ITEM m_rubl-base /* Пересчитать Р_УБ по курсу и сумме в баз.вал. */
DO:
    assign  FRAME {&FRAME-NAME}
           loc_sum-base
           loc_base-rate
           loc_base-scale
           .

  loc_sum-rubl    = ( loc_base-rate  / loc_base-scale) * loc_sum-base .


   display
    loc_sum-rubl         when loc_sum-rubl         :visible
   with frame {&frame-name}.
  APPLY "LEAVE":U TO loc_sum-rubl .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_rubl-contr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_rubl-contr Dialog-Frame
ON CHOOSE OF MENU-ITEM m_rubl-contr /* Пересчитать Р_УБ по курсу и сумме в вал.договора */
DO:
  assign FRAME {&FRAME-NAME}  loc_sum-contract
           loc_contract-rate
           loc_contract-scale
           .

  loc_sum-rubl    = ( loc_contract-rate  / loc_contract-scale) * loc_sum-contract .


   display
    loc_sum-rubl         when loc_sum-rubl         :visible
   with frame {&frame-name}.
   APPLY "LEAVE":U TO loc_sum-rubl .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-curr-base
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-curr-base Dialog-Frame
ON CHOOSE OF r-curr-base IN FRAME Dialog-Frame
DO:
{ gbl/stdbtn.i }
define variable v-base-abbr like ub.currency.curr-abbr no-undo .
  { gbl/exchrate.i  p-basecode today loc_base-rate loc_base-scale v-base-abbr }

   display
   loc_base-rate
   loc_base-scale
   with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-curr-contr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-curr-contr Dialog-Frame
ON CHOOSE OF r-curr-contr IN FRAME Dialog-Frame
DO:
  { gbl/stdbtn.i }
  define variable v-contract-abbr like ub.currency.curr-abbr no-undo .
    { gbl/exchrate.i  p-contract-curr today loc_contract-rate loc_contract-scale v-contract-abbr }

     display
     loc_contract-rate
     loc_contract-scale
     with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
{ gbl/app_help.i }
/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

ASSIGN B-r-1 :POPUP-MENU IN FRAME {&frame-name} = MENU POPUP-MENU-B-r-1 :HANDLE.
ASSIGN B-r-1 :MENU-MOUSE = 1.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run enable_my.
  wait-for go of frame {&frame-name} focus loc_sum-rubl .
END.
run disable_ui.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame  _DEFAULT-DISABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_my Dialog-Frame
PROCEDURE enable_my :
assign
  loc_sum-rubl       = p-sum-rubl
  loc_sum-base       = p-sum-base
  loc_sum-contract      = p-sum-contr
  loc_sum-rubl-2        = p-sum-rubl
  loc_sum-base-2        = p-sum-base
  loc_sum-contract-2    = p-sum-contr

  loc_base-rate      = p-base-rate
  loc_base-scale     = p-base-scale
  loc_contract-rate  = p-contract-rate
  loc_contract-scale = p-contract-scale
  loc_base-rate-2      = p-base-rate
  loc_base-scale-2     = p-base-scale
  loc_contract-rate-2  = p-contract-rate
  loc_contract-scale-2 = p-contract-scale
  loc_abbr-base         = sel-abbr(p-basecode)
  loc_abbr-base-2       = sel-abbr(p-basecode)
  loc_abbr-contr        = sel-abbr(p-contract-curr)
  loc_abbr-contr-2      = sel-abbr(p-contract-curr)

.
MENU-ITEM m_rubl-base:sensitive IN MENU POPUP-MENU-B-r-1  = NOT p-hide-base .
MENU-ITEM m_rubl-contr:sensitive IN MENU POPUP-MENU-B-r-1 = NOT p-hide-contr .

DISPLAY loc_sum-rubl-2 loc_base-rate-2 loc_base-scale-2 loc_sum-base-2
          loc_contract-rate-2 loc_contract-scale-2 loc_sum-contract-2
          loc_sum-rubl loc_sum-base loc_sum-contract loc_base-rate
          loc_base-scale loc_contract-rate loc_contract-scale FILL-IN-8
          loc_abbr-rubl-5 loc_abbr-rubl-6 loc_abbr-rubl-7 loc_abbr-base-2
          loc_abbr-rubl-8 loc_abbr-contr-2 loc_abbr-rubl-2 loc_abbr-rubl
          loc_abbr-base
          loc_abbr-contr
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-quit B-Help

          B-r-1         when p-hide-rubl = false
          loc_sum-rubl  when p-hide-rubl = false

          B-r-2          when p-hide-base = false
          B-r-3          when p-hide-base = false
          loc_sum-base   when p-hide-base = false
          loc_base-rate  when p-hide-base = false
          loc_base-scale when p-hide-base = false
          r-curr-base    when p-hide-base = false


          B-r-4              when p-hide-contr = false
          B-r-5              when p-hide-contr = false
          loc_sum-contract   when p-hide-contr = false
          loc_contract-rate  when p-hide-contr = false
          loc_contract-scale when p-hide-contr = false
          r-curr-contr       when p-hide-contr = false



      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame  _DEFAULT-ENABLE
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
  DISPLAY loc_sum-rubl-2 loc_base-rate-2 loc_base-scale-2 loc_sum-base-2
          loc_contract-rate-2 loc_contract-scale-2 loc_sum-contract-2
          loc_sum-rubl loc_sum-base loc_sum-contract loc_base-rate
          loc_base-scale loc_contract-rate loc_contract-scale FILL-IN-8
          loc_abbr-rubl-5 loc_abbr-rubl-6 loc_abbr-rubl-7 loc_abbr-base-2
          loc_abbr-rubl-8 loc_abbr-contr-2 loc_abbr-rubl-2 loc_abbr-rubl
          loc_abbr-base loc_abbr-contr
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-quit B-Help loc_sum-contract-2 B-r-1 B-r-2 loc_sum-contract
         B-r-4 r-curr-base B-r-3 r-curr-contr B-r-5 FILL-IN-8 loc_abbr-rubl-5
         loc_abbr-rubl-6 loc_abbr-rubl-7 loc_abbr-base-2 loc_abbr-rubl-8
         loc_abbr-contr-2 loc_abbr-rubl-2 loc_abbr-rubl loc_abbr-base
         loc_abbr-contr RECT-6 RECT-7
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE next-focus Dialog-Frame
PROCEDURE next-focus :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

  define input parameter p-widget-handle as handle no-undo .
  define variable l-apply-entry as logical no-undo .

  assign
    l-apply-entry = /* false */  true
  .

  do with frame {&frame-name} :

    if  loc_sum-rubl       :handle = p-widget-handle then do:
                                                         if loc_sum-base :sensitive then do:       apply "entry":u to loc_sum-base    .        return . end.
                                                         if loc_sum-contract :sensitive then do:       apply "entry":u to loc_sum-contract    .        return . end.
                                                         if B-exit     :sensitive then do:       apply "entry":u to B-exit     .        return . end.
                                                     end.

    if  loc_sum-base       :handle = p-widget-handle then do:
                                                            if loc_base-rate :sensitive then do:       apply "entry":u to loc_base-rate   .        return . end.
                                                            if loc_sum-contract :sensitive then do:       apply "entry":u to loc_sum-contract    .        return . end.
                                                            if B-exit     :sensitive then do:       apply "entry":u to B-exit     .        return . end.
                                                          end.
    if  loc_sum-contract   :handle = p-widget-handle then do:
                                                          if loc_contract-rate :sensitive then do:       apply "entry":u to loc_contract-rate   .        return . end.
                                                          if B-exit     :sensitive then do:       apply "entry":u to B-exit     .        return . end.

                                                          end.

    if  loc_base-rate    :handle = p-widget-handle then do:
        if loc_base-scale :sensitive then do:       apply "entry":u to loc_base-scale.  return . end.
    END.

    if loc_base-scale    :handle = p-widget-handle then do:
       if loc_sum-contract :sensitive then do:       apply "entry":u to loc_sum-contract.  return . end.
       if B-exit     :sensitive then do:       apply "entry":u to B-exit     .        return . end.
    END.


    if loc_contract-rate    :handle = p-widget-handle then do:
       if loc_contract-scale :sensitive then do:       apply "entry":u to loc_contract-scale.  return . end.
    END.

    if loc_contract-scale    :handle = p-widget-handle then do:
       if B-exit     :sensitive then do:       apply "entry":u to B-exit     .        return . end.
    END.


    end. /* do with frame */


  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ver-summ Dialog-Frame
PROCEDURE ver-summ :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE OUTPUT PARAMETER p-rate-correct AS CHARACTER NO-UNDO.
IF abs( (loc_sum-rubl / loc_sum-base)  - (loc_base-rate / loc_base-scale)) > 0.0001  THEN DO:
    p-rate-correct = "base-rate":U.
    RETURN.
END.
IF abs( (loc_sum-rubl / loc_sum-contract) - (loc_contract-rate / loc_contract-scale )) > 0.0001 THEN DO:
    p-rate-correct = "contract-rate":U.
    RETURN.
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION sel-abbr Dialog-Frame
FUNCTION sel-abbr RETURNS CHARACTER
( p-curr-code as int ) :
  define variable rr as character no-undo .
  find first currency no-lock where  currency.curr-code  = p-curr-code no-error.
  rr = currency.curr-abbr .
  RETURN rr.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME