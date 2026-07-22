&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
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

Информация по секциям автоцистерн


Автор: Кривошеин Александр
Дата создания: 14/07/10
Author: Mikhail Pervakov
Creation date: 14/07/10

*/

/* ***************************  Definitions  ************************** */
/* Parameters Definitions ---                                           */
define input parameter parmode as character no-undo.
define input parameter parnum-tank as CHARACTER no-undo.
define input parameter partype-AC  as integer   no-undo .
define input parameter par-neck  as integer   no-undo .  
define input-output parameter parsec-num as CHARACTER no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Измерение по резервуару".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }

DEFINE BUFFER buf_auto-tank FOR auto-tank.
define buffer buf_auto-section for ub.auto-section .
define temp-table tt-section no-undo 
   field dif     as integer
   field volume1 as decimal
   field deltaV  as character
   index pi dif
   .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

define variable ii as integer no-undo .
&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-2

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-section

/* Definitions for BROWSE BROWSE-2                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2 tt-section.dif ~
tt-section.volume1 tt-section.deltaV 
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2 tt-section.volume1 ~
tt-section.deltaV 
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-2 tt-section
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-2 tt-section
&Scoped-define QUERY-STRING-BROWSE-2 FOR EACH tt-section exclusive-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-2 OPEN QUERY BROWSE-2 FOR EACH tt-section exclusive-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-2 tt-section
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2 tt-section


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-2}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-cancel b-help F-dop-volume BROWSE-2 
&Scoped-Define DISPLAYED-OBJECTS varsec-num varsec-qnty F-dop-volume 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cancel AUTO-END-KEY 
   LABEL "&Отмена" 
   SIZE 10 BY 1
   BGCOLOR 8 .

DEFINE BUTTON b-help 
   LABEL "Помо&щь" 
   SIZE 10 BY 1
   BGCOLOR 8 .

DEFINE BUTTON b-save AUTO-GO 
   LABEL "&Ввод" 
   SIZE 10 BY 1
   BGCOLOR 8 .

DEFINE VARIABLE ellipse-depth      AS CHARACTER FORMAT "x(8)" 
   LABEL "Толщина стенки горловины, мм" 
   VIEW-AS FILL-IN 
   SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE ellipse-max        AS CHARACTER FORMAT "x(8)" 
   LABEL "Диаметр горловины большой оси эллипса, мм" 
   VIEW-AS FILL-IN 
   SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE ellipse-min        AS CHARACTER FORMAT "x(8)" 
   LABEL "Диаметр горловины малой оси эллипса, мм" 
   VIEW-AS FILL-IN 
   SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE F-dop-volume       AS DECIMAL   FORMAT ">>,>>9.999":U INITIAL 0 
   LABEL "Доп.объем трубопровода нижнего налива, л" 
   VIEW-AS FILL-IN 
   SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE square-depth       AS CHARACTER FORMAT "x(8)" 
   LABEL "Толщина стенки горловины, мм" 
   VIEW-AS FILL-IN 
   SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE square-lenght      AS CHARACTER FORMAT "x(8)" 
   LABEL "Длина горловины, мм" 
   VIEW-AS FILL-IN 
   SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE square-width       AS CHARACTER FORMAT "x(8)" 
   LABEL "Ширина горловины, мм" 
   VIEW-AS FILL-IN 
   SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE varsec-diam-in     AS CHARACTER FORMAT "x(8)" 
   LABEL "Внутренний диаметр горловины, мм" 
   VIEW-AS FILL-IN 
   SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE varsec-diam-out    AS CHARACTER FORMAT "x(8)" 
   LABEL "Внешний диаметр горловины, мм" 
   VIEW-AS FILL-IN 
   SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE varsec-diam-depth  AS CHARACTER FORMAT "x(8)" 
   LABEL "Толщина стенки горловины, мм" 
   VIEW-AS FILL-IN 
   SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE varsec-diam-lenght AS CHARACTER FORMAT "x(8)" 
   LABEL "Длина внешней окружности горловины, мм" 
   VIEW-AS FILL-IN 
   SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE varsec-num         AS INTEGER   FORMAT "->,>>>,>>9" INITIAL 0 
   LABEL "Номер секции" 
   VIEW-AS FILL-IN 
   SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE varsec-qnty        AS DECIMAL   FORMAT "->>>,>>>,>>9.999" INITIAL 0 
   LABEL "Вместимость секции, л" 
   VIEW-AS FILL-IN 
   SIZE 15 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-2 FOR 
   tt-section SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2 Dialog-Frame _STRUCTURED
   QUERY BROWSE-2 DISPLAY
   tt-section.dif COLUMN-LABEL "Отклонение от!тарировочной!планки, см" FORMAT "->9.9":U WIDTH 15
   tt-section.volume1 COLUMN-LABEL "Объем!для указанного!отклонения от планки, л" FORMAT "->>,>>9.99":U
   if tt-section.deltaV > "" and decimal(tt-section.deltaV) > 0 then string(decimal(tt-section.deltaV), ">>>>>>>>>>9.9999") else "" COLUMN-LABEL "Коэффициент!вместимости!горловины,дм3/мм" FORMAT "X(16)"
  ENABLE
      tt-section.volume1 
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 58 BY 7.75 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
   b-save AT ROW 1 COL 1 WIDGET-ID 2
   b-cancel AT ROW 1 COL 11 WIDGET-ID 4
   b-help AT ROW 1 COL 21 WIDGET-ID 6
   varsec-num AT ROW 2.25 COL 42.5 COLON-ALIGNED WIDGET-ID 8
   varsec-qnty AT ROW 3.5 COL 42.5 COLON-ALIGNED WIDGET-ID 10
   F-dop-volume AT ROW 4.75 COL 42.5 COLON-ALIGNED WIDGET-ID 18
   BROWSE-2 AT ROW 6 COL 1.5 WIDGET-ID 100
   varsec-diam-in AT ROW 6 COL 42.5 COLON-ALIGNED WIDGET-ID 16
   varsec-diam-out AT ROW 7.25 COL 42.5 COLON-ALIGNED WIDGET-ID 38
   varsec-diam-depth AT ROW 8.5 COL 42.5 COLON-ALIGNED WIDGET-ID 40
   varsec-diam-lenght AT ROW 9.75 COL 42.5 COLON-ALIGNED WIDGET-ID 42
   square-lenght AT ROW 6 COL 42.5 COLON-ALIGNED WIDGET-ID 26
   ellipse-max AT ROW 6 COL 42.5 COLON-ALIGNED WIDGET-ID 32
   square-width AT ROW 7.25 COL 42.5 COLON-ALIGNED WIDGET-ID 28
   ellipse-min AT ROW 7.25 COL 42.5 COLON-ALIGNED WIDGET-ID 34
   square-depth AT ROW 8.5 COL 42.5 COLON-ALIGNED WIDGET-ID 30
   ellipse-depth AT ROW 8.5 COL 42.5 COLON-ALIGNED WIDGET-ID 36
   SPACE(1.12) SKIP(4.87)
   WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
   SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
   TITLE "Данные по секции"
   DEFAULT-BUTTON b-save CANCEL-BUTTON b-cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-2 F-dop-volume Dialog-Frame */
ASSIGN 
   FRAME Dialog-Frame:SCROLLABLE = FALSE
   FRAME Dialog-Frame:HIDDEN     = TRUE.

/* SETTINGS FOR BUTTON b-save IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN ellipse-depth IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN ellipse-max IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN ellipse-min IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN square-depth IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN square-lenght IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN square-width IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN varsec-diam IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN varsec-num IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varsec-qnty IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 

/* Setting information for Queries and Browse Widgets fields            */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Данные по секции */
   DO:
      APPLY "END-ERROR":U TO SELF.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-save Dialog-Frame
ON CHOOSE OF b-save IN FRAME Dialog-Frame /* Ввод */
DO:
  
  IF input frame {&frame-name} varsec-num <= 0 THEN DO:
    message "Номер секции указан неверно." view-as alert-box error.
    RETURN no-apply.
  END.

      if (par-neck = 0 and partype-AC = 1) OR
         (par-neck = 0 and partype-AC = 2) OR

         (par-neck = 1 and 
         input frame {&frame-name} square-depth <> '' and 
         input frame {&frame-name} square-lenght <> '' and 
         input frame {&frame-name} square-width <> '') OR

         (par-neck = 2 and 
         input frame {&frame-name} ellipse-min <> '' and 
         input frame {&frame-name} ellipse-max <> '' and 
         input frame {&frame-name} ellipse-depth <> '') OR

         (par-neck = 3 and input frame {&frame-name} varsec-diam-depth <> '' and
         input frame {&frame-name} varsec-diam-out <> '' and 
         (parmode = {&add-def} or parmode = {&update}) AND 
         input frame {&frame-name} varsec-num <> 0 AND 
         input frame {&frame-name} varsec-qnty <> 0) OR

         (par-neck = 3 and input frame {&frame-name} varsec-diam-depth <> '' and
         input frame {&frame-name} varsec-diam-lenght <> '' AND 
         (parmode = {&add-def} or parmode = {&update}) AND 
         input frame {&frame-name} varsec-num <> 0 AND 
         input frame {&frame-name} varsec-qnty <> 0) OR

         (par-neck = 3 and input frame {&frame-name} varsec-diam-in <> '' and
         varsec-diam-depth = "" and varsec-diam-lenght = "" and varsec-diam-out = "" and
         (parmode = {&add-def} or parmode = {&update}) AND 
         input frame {&frame-name} varsec-num <> 0 AND 
         input frame {&frame-name} varsec-qnty <> 0)
         then 
      do:
    end.
      else 
      do :
         if par-neck <> 3 then 
         do:
            message "Введите данные! Не все поля заполнены" view-as alert-box.
            return no-apply.
         end. 
         else 
         do:
            if varsec-diam-in = "" and varsec-diam-out = "" and varsec-diam-lenght = "" then 
            do: 
               message "Введите данные! Необходимо указать одно из значений:" skip
                  "внешний диаметр, внутренний диаметр или длину внешней окружности горловины." 
                  view-as alert-box.
               return no-apply.
            end.
            else 
            do:
               if varsec-diam-in = "" then do:
               if varsec-diam-out > "" or varsec-diam-lenght > "" then do:
               if varsec-diam-depth = "" then 
               do:
                  message "Введите данные! Необходимо указать толщину стенки горловины." view-as alert-box.
                  return no-apply.
               end.
               end.
               end.
         end.     
      end.   
   end.    
if par-neck = 3 and decimal(varsec-diam-in) > decimal(varsec-diam-out) and 
   varsec-diam-in <> "" and varsec-diam-out <> "" then 
do:
   message "Внутренний диаметр горловины должен быть меньше внешнего"
      view-as alert-box error.
   return no-apply.     
end.      
     IF AVAILABLE ub.auto-section THEN do:
     if integer(parsec-num) <> ub.auto-section.section-num then do:
        IF CAN-FIND(buf_auto-section WHERE buf_auto-section.auto-num = parnum-tank 
                                       and buf_auto-section.section-num = integer(parsec-num)) THEN DO:
            message "Секция с таким номером уже существует." view-as alert-box error.
            RETURN.
        END. ELSE.
     end.   
     END.
     ELSE
        IF CAN-FIND(buf_auto-section WHERE buf_auto-section.auto-num = parnum-tank 
                                         and buf_auto-section.section-num = integer(parsec-num)) THEN DO:
            message "Секция с таким номером уже существует." view-as alert-box error.
            RETURN.
        END.
 
     IF NOT AVAILABLE ub.auto-section THEN DO:
        create ub.auto-section.
                ub.auto-section.auto-num = parnum-tank
                .
        
     END.
     assign
        ub.auto-section.section-num = integer(varsec-num)
        ub.auto-section.brutto-qnty = varsec-qnty
        ub.auto-section.add-volume  = F-dop-volume
        .
     case par-neck:
        when 0 then 
           do:
              do ii = -10 to 10:
                 find first ub.auto-section-table exclusive-lock where ub.auto-section-table.auto-num = parnum-tank
                    and ub.auto-section-table.section-num = integer(varsec-num) 
                    and ub.auto-section-table.error = ii no-error .
                 if not available (ub.auto-section-table) then 
                 do:
                    create ub.auto-section-table .
                    assign
                       ub.auto-section-table.auto-num    = parnum-tank
                       ub.auto-section-table.section-num = integer(varsec-num)
                       ub.auto-section-table.error       = ii
                       .
                 end.
                 for first tt-section where tt-section.dif = ii:
                    assign
                       ub.auto-section-table.volume-error = tt-section.volume1
                       ub.auto-section-table.volume-between = decimal(tt-section.deltaV) * 100
                    .  
                 end.              
              end.                
           end.
        when 1 then 
           do:
              assign
                 ub.auto-section.length        = decimal(square-lenght)
                 ub.auto-section.width         = decimal(square-width)
                 ub.auto-section.section-depth = decimal(square-depth)
                 .              
           end.
        when 2 then 
           do:
              assign
                 ub.auto-section.diameter-max  = decimal(ellipse-max)
                 ub.auto-section.diameter-min  = decimal(ellipse-min)
                 ub.auto-section.section-depth = decimal(ellipse-depth)
                 .              
           end.
        when 3 then 
           do:
              assign
                 ub.auto-section.diameter-max  = decimal(varsec-diam-out)
                 ub.auto-section.diameter-min  = decimal(varsec-diam-in)
                 ub.auto-section.length        = decimal(varsec-diam-lenght)
                 ub.auto-section.section-depth = decimal(varsec-diam-depth)
                 .              
           end.   
     end case .   
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ellipse-depth
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ellipse-depth Dialog-Frame
ON LEAVE OF ellipse-depth IN FRAME Dialog-Frame /* Толщина стенки горловины, мм */
   DO:
      assign ellipse-depth .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ellipse-max
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ellipse-max Dialog-Frame
ON LEAVE OF ellipse-max IN FRAME Dialog-Frame /* Диаметр горловины большой оси эллипса, мм */
   DO:
      assign ellipse-max .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ellipse-min
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ellipse-min Dialog-Frame
ON LEAVE OF ellipse-min IN FRAME Dialog-Frame /* Диаметр горловины малой оси эллипса, мм */
   DO:
      assign ellipse-min .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME F-dop-volume
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL F-dop-volume Dialog-Frame
ON LEAVE OF F-dop-volume IN FRAME Dialog-Frame /* Доп.объем трубопровода нижнего налива,л */
   DO:
      assign f-dop-volume .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME square-depth
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL square-depth Dialog-Frame
ON LEAVE OF square-depth IN FRAME Dialog-Frame /* Толщина стенки горловины, мм */
   DO:
      assign square-depth .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME square-lenght
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL square-lenght Dialog-Frame
ON LEAVE OF square-lenght IN FRAME Dialog-Frame /* Длина горловины, мм */
   DO:
      assign square-lenght .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME square-width
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL square-width Dialog-Frame
ON LEAVE OF square-width IN FRAME Dialog-Frame /* Ширина горловины, мм */
   DO:
      assign square-width .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varsec-diam-in
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsec-diam-in Dialog-Frame
ON LEAVE OF varsec-diam-in IN FRAME Dialog-Frame /* Диаметр горловины, мм */
   DO:
      if string(varsec-diam-in) <> varsec-diam-in:screen-value then 
      do:
         assign varsec-diam-in .
      end.

   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME varsec-diam-out
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsec-diam-out Dialog-Frame
ON LEAVE OF varsec-diam-out IN FRAME Dialog-Frame /* Диаметр горловины, мм */
   DO:
      if string(varsec-diam-out) <> varsec-diam-out:screen-value then 
      do:
         assign varsec-diam-out .
      end.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME varsec-diam-depth
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsec-diam-depth Dialog-Frame
ON LEAVE OF varsec-diam-depth IN FRAME Dialog-Frame /* Диаметр горловины, мм */
   DO:
      assign varsec-diam-depth .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME varsec-diam-lenght
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsec-diam-lenght Dialog-Frame
ON LEAVE OF varsec-diam-lenght IN FRAME Dialog-Frame /* Диаметр горловины, мм */
   DO:
      assign varsec-diam-lenght .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varsec-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsec-num Dialog-Frame
ON LEAVE OF varsec-num IN FRAME Dialog-Frame /* Номер секции */
   DO:
      assign varsec-num .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varsec-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsec-qnty Dialog-Frame
ON LEAVE OF varsec-qnty IN FRAME Dialog-Frame /* Вместимость, л */
   DO:
      assign varsec-qnty .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
&Scoped-define BROWSE-NAME BROWSE-2
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
   THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    
  if parmode = {&lookup} then do:
    find first ub.auto-section where ub.auto-section.auto-num = parnum-tank and ub.auto-section.section-num = integer(parsec-num) NO-LOCK NO-ERROR.
  end.
  if parmode = {&update} then do:
    do transaction:
      find first ub.auto-section where ub.auto-section.auto-num = parnum-tank and ub.auto-section.section-num = integer(parsec-num) exclusive-lock NO-ERROR.
    end.
  end.
  if parmode = {&add-def} then do:
    varsec-num = 0.
  end.
  ELSE varsec-num = INTEGER(parsec-num).

  if AVAILABLE ub.auto-section AND
     (parmode = {&lookup} or
      parmode = {&update}) then do:

    assign
      varsec-qnty   = ub.auto-section.brutto-qnty
      F-dop-volume  = ub.auto-section.add-volume
      .
     case par-neck:
        when 0 then 
           do:
              output to vtvt.txt.
              for each ub.auto-section-table exclusive-lock where ub.auto-section-table.auto-num = ub.auto-section.auto-num
                 and ub.auto-section-table.section-num = ub.auto-section.section-num:
                 create tt-section .
                 assign
                    tt-section.dif     = ub.auto-section-table.error
                    tt-section.volume1 = ub.auto-section-table.volume-error
                    tt-section.deltaV  = string(ub.auto-section-table.volume-between / 100)
                 .
                 export tt-section .
              end. 
              output close.             
           end.
        when 1 then 
           do:
              assign
                 square-depth  = string(ub.auto-section.section-depth)
                 square-lenght = string(ub.auto-section.length)
                 square-width  = string(ub.auto-section.width)
                 .            
           end.
        when 2 then 
           do:
              assign
                 ellipse-depth = string(ub.auto-section.section-depth)
                 ellipse-max   = string(ub.auto-section.diameter-max)
                 ellipse-min   = string(ub.auto-section.diameter-min)
                 .
           end.
        when 3 then 
           do:
              assign
                 varsec-diam-in     = string(ub.auto-section.diameter-min)
                 varsec-diam-out    = string(ub.auto-section.diameter-max)
                 varsec-diam-depth  = string(ub.auto-section.section-depth)
                 varsec-diam-lenght = string(ub.auto-section.length)
                 .
           end.   
     end case .   

  END.
  ELSE DO:
      assign
         varsec-qnty    = 0
         varsec-diam-in = ''
         .
      if par-neck = 0 and partype-AC = 1 then 
      do:
         do ii = -10 to 10: 
            if ii = 0 then next .
            create tt-section .
            assign
               tt-section.dif = ii
               .
         end.
      end.   
   END.

   RUN local-enable_UI.
   WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

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
   DISPLAY varsec-num varsec-qnty F-dop-volume 
      WITH FRAME Dialog-Frame.
   ENABLE b-cancel b-help F-dop-volume BROWSE-2 
      WITH FRAME Dialog-Frame.
   VIEW FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-enable_UI Dialog-Frame 
PROCEDURE local-enable_UI :
   /*------------------------------------------------------------------------------
         Purpose:     Override standard ADM method
         Notes:
       ------------------------------------------------------------------------------*/

   /* Code placed here will execute PRIOR to standard behavior. */

   /* Dispatch standard ADM method.                             */
   RUN enable_ui.

  if parmode = {&add-def} or
     parmode = {&update} then do:
     case par-neck:
         when 2 then do: /*Элиптическая*/
            enable
            ellipse-depth
            ellipse-max
            ellipse-min
            with frame {&frame-name} .
            display
            ellipse-depth
            ellipse-max
            ellipse-min
            with frame {&frame-name} .
            hide
            square-depth
            square-lenght
            square-width
            varsec-diam-in
            varsec-diam-out
            varsec-diam-depth
            varsec-diam-lenght
            BROWSE-2
            in frame {&frame-name} .
         end.    
         when 1 then do: /*Квадратная*/
            enable
            square-depth
            square-lenght
            square-width
            with frame {&frame-name} .
            display
            square-depth
            square-lenght
            square-width
            with frame {&frame-name} .            
            hide
            ellipse-depth
            ellipse-max
            ellipse-min
            varsec-diam-in
            varsec-diam-out
            varsec-diam-depth
            varsec-diam-lenght
            BROWSE-2
            in frame {&frame-name} .         
         end.    
         when 3 then do: /*Круглая*/
            enable
            varsec-diam-in
            varsec-diam-out
            varsec-diam-depth
            varsec-diam-lenght
            with frame {&frame-name} .
            display
            varsec-diam-in
            varsec-diam-out
            varsec-diam-depth
            varsec-diam-lenght
            with frame {&frame-name} .            
            hide
            ellipse-depth
            ellipse-max
            ellipse-min
            square-depth
            square-lenght
            square-width
            BROWSE-2
            in frame {&frame-name} .           
         end.    
         when 0 then do: /*Без горловины*/
         if partype-AC = 1 then do:
            enable
            BROWSE-2
            with frame {&frame-name} .
            {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
         end.
         else do:
            hide
            BROWSE-2
            in frame {&frame-name} .            
         end.      
            hide
            ellipse-depth
            ellipse-max
            ellipse-min
            varsec-diam-in
            varsec-diam-out
            varsec-diam-depth
            varsec-diam-lenght
            square-depth
            square-lenght
            square-width
            in frame {&frame-name} .    
         end.             
     end case .
     enable varsec-num varsec-qnty b-save with frame {&frame-name}.
     if partype-AC = 2 then do:
         hide 
             F-dop-volume
             ellipse-depth
             ellipse-max
             ellipse-min
             varsec-diam-in
             varsec-diam-out
             varsec-diam-depth
             varsec-diam-lenght
             square-depth
             square-lenght
             square-width
             BROWSE-2
             in frame {&frame-name} .
end.       
     else enable F-dop-volume with frame {&frame-name} .
  end.
  else do:
     case par-neck:
         when 2 then do: /*Элиптическая*/
            disable
            ellipse-depth
            ellipse-max
            ellipse-min
            with frame {&frame-name} .
            display
            ellipse-depth
            ellipse-max
            ellipse-min
            with frame {&frame-name} .
            hide
            square-depth
            square-lenght
            square-width
            varsec-diam-in
            varsec-diam-out
            varsec-diam-depth
            varsec-diam-lenght
            BROWSE-2
            in frame {&frame-name} .
         end.    
         when 1 then do: /*Квадратная*/
            disable
            square-depth
            square-lenght
            square-width
            with frame {&frame-name} .
            display
            square-depth
            square-lenght
            square-width
            with frame {&frame-name} .
            hide
            ellipse-depth
            ellipse-max
            ellipse-min
            varsec-diam-in
            varsec-diam-out
            varsec-diam-depth
            varsec-diam-lenght
            BROWSE-2
            in frame {&frame-name} .         
         end.    
         when 3 then do: /*Круглая*/
            disable
            varsec-diam-in
            varsec-diam-out
            varsec-diam-depth
            varsec-diam-lenght
            with frame {&frame-name} .
            display
            varsec-diam-in
            varsec-diam-out
            varsec-diam-depth
            varsec-diam-lenght
            with frame {&frame-name} .            
            hide
            ellipse-depth
            ellipse-max
            ellipse-min
            square-depth
            square-lenght
            square-width
            BROWSE-2
            in frame {&frame-name} .           
         end.    
         when 0 then do: /*Без горловины*/
         if partype-AC = 1 then do:
            display
            BROWSE-2
            with frame {&frame-name} .
            {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}       
         end.
         else do:
            hide
            BROWSE-2
            in frame {&frame-name} .            
         end.      
            hide
            ellipse-depth
            ellipse-max
            ellipse-min
            varsec-diam-in
            varsec-diam-out
            varsec-diam-depth
            varsec-diam-lenght
            square-depth
            square-lenght
            square-width
            in frame {&frame-name} .    
         end.             
     end case .
     disable varsec-num varsec-qnty b-save with frame {&frame-name}.
     if partype-AC = 2 then 
     hide 
     BROWSE-2
     F-dop-volume 
     ellipse-depth
     ellipse-max
     ellipse-min
     varsec-diam-in
     varsec-diam-out
     varsec-diam-depth
     varsec-diam-lenght
     square-depth
     square-lenght
     square-width
     in frame {&frame-name} .
     else disable F-dop-volume with frame {&frame-name} .      
  end .      
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

