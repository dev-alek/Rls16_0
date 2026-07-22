&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS F-Frame-Win 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет по сегментации клиентов

Автор: Кабоев Валерий Асланович
Дата создания: 19/09/12
Author: Kaboev Valeriy
Creation date: 19/09/12

*/

/* Create an unnamed pool to store all the widgets created
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отчет сегментации клиентов" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }
{ gbl/cur-time.i }
{ cmp/dc-list.i dc-list def "new shared" }

define variable     cli-str             as char         no-undo.
define variable     obj_recids          as char         no-undo.
define variable     FixGroup            as char         no-undo.
define variable     FixDCard            as char         no-undo.
define variable     DcardMode           as char         no-undo     init "ALL". /* переменная выбора по ДК */
define variable     Filter-name         as char         no-undo.
define variable     ii                  as integer      no-undo.
define buffer       cli-dcard           for             clients.
define variable     lin                 as char         no-undo.
define variable     TotalSum            like dis-obj.gds-tot-rubl no-undo.
define variable     clients_found       as logical      no-undo.                             /*Флаг: наличие в базе клиентов с покупками и ДК */
define variable     xx                  as integer      no-undo.
define variable     ctmp                as char         no-undo.
define variable     buff                as handle       no-undo.
define variable     dcard-mode          as integer      no-undo init 0.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER FRAME

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rect-3 rect-5 rect-6 SelectDC chk-obj chk-dk ~
chk-sex chk-age 
&Scoped-Define DISPLAYED-OBJECTS SelectDC chk-obj chk-dk chk-sex chk-age ~
fill-start-date fill-end-date period-list 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON btn-add-period 
     LABEL "+" 
     SIZE 5 BY 1.

DEFINE BUTTON btn-del-period 
     LABEL "-" 
     SIZE 5 BY 1.

DEFINE VARIABLE fill-end-date AS INTEGER FORMAT ">>9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE fill-start-date AS INTEGER FORMAT ">>9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE SelectDC AS CHARACTER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Все", "all":U,
"Выборочно по картам", "card":U
     SIZE 30.6 BY 1.67 NO-UNDO.

DEFINE RECTANGLE rect-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 46 BY 3.38.

DEFINE RECTANGLE rect-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 46 BY 5.

DEFINE RECTANGLE rect-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 46 BY 8.29.

DEFINE VARIABLE period-list AS CHARACTER 
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL 
     SIZE 42.2 BY 5.33 NO-UNDO.

DEFINE VARIABLE chk-age AS LOGICAL INITIAL no 
     LABEL "Сегментация по возрасту" 
     VIEW-AS TOGGLE-BOX
     SIZE 33.2 BY 1 NO-UNDO.

DEFINE VARIABLE chk-dk AS LOGICAL INITIAL no 
     LABEL "Детализация по ДК" 
     VIEW-AS TOGGLE-BOX
     SIZE 27.2 BY 1 NO-UNDO.

DEFINE VARIABLE chk-obj AS LOGICAL INITIAL no 
     LABEL "Детализация по объектам" 
     VIEW-AS TOGGLE-BOX
     SIZE 33.2 BY .81 NO-UNDO.

DEFINE VARIABLE chk-sex AS LOGICAL INITIAL no 
     LABEL "Сегментация по полу" 
     VIEW-AS TOGGLE-BOX
     SIZE 28.2 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     SelectDC AT ROW 2.52 COL 3.8 NO-LABEL
     chk-obj AT ROW 6 COL 3.8 WIDGET-ID 2
     chk-dk AT ROW 6.76 COL 3.8
     chk-sex AT ROW 7.62 COL 3.8
     chk-age AT ROW 8.48 COL 3.8
     btn-add-period AT ROW 11.29 COL 35.8 WIDGET-ID 26
     btn-del-period AT ROW 11.29 COL 41.4 WIDGET-ID 18
     fill-start-date AT ROW 11.33 COL 4 NO-LABEL WIDGET-ID 20
     fill-end-date AT ROW 11.33 COL 21 NO-LABEL WIDGET-ID 14
     period-list AT ROW 12.81 COL 4 NO-LABEL WIDGET-ID 24
     "Задание возрастных групп" VIEW-AS TEXT
          SIZE 29.2 BY .95 AT ROW 10.33 COL 3.6 WIDGET-ID 22
          FGCOLOR 4 
     "_" VIEW-AS TEXT
          SIZE 2 BY .62 AT ROW 11.24 COL 19 WIDGET-ID 16
     "Выбор по ДК" VIEW-AS TEXT
          SIZE 31.2 BY .81 AT ROW 1.43 COL 3.6
          FGCOLOR 4 
     "Представление" VIEW-AS TEXT
          SIZE 26.8 BY .95 AT ROW 4.95 COL 3.6
          FGCOLOR 4 
     rect-3 AT ROW 1.19 COL 2.2
     rect-5 AT ROW 4.81 COL 2.2
     rect-6 AT ROW 10.1 COL 2.2 WIDGET-ID 12
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 49.4 BY 17.57.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   Allow: Basic,Browse,DB-Fields,Smart,Query
   Container Links: 
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW F-Frame-Win ASSIGN
         HEIGHT             = 17.57
         WIDTH              = 49.4.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB F-Frame-Win 
/* ************************* Included-Libraries *********************** */
{src/adm/method/containr.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW F-Frame-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE FRAME-NAME                                               */
/* SETTINGS FOR BUTTON btn-add-period IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON btn-del-period IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fill-end-date IN FRAME F-Main
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fill-start-date IN FRAME F-Main
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR SELECTION-LIST period-list IN FRAME F-Main
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = ""
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME btn-add-period
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-add-period F-Frame-Win
ON choose OF btn-add-period IN FRAME F-Main /* + */
do:
    define variable kursor as integer init 0 no-undo.
    define variable flag-ok as logical init yes no-undo.
    define variable end-age as integer no-undo.
    assign fill-start-date.
    assign fill-end-date.
    end-age = fill-end-date.
    if end-age = 0 then end-age = 9999.
    do while kursor < period-list:num-items:
        kursor = kursor + 1.
        if fill-start-date >= integer(entry(1,period-list:entry(kursor),"-")) 
        and fill-start-date <= integer(replace(entry(2,period-list:entry(kursor),"-"),"...","0"))
            then flag-ok = no.
        else if end-age >= integer(entry(1,period-list:entry(kursor),"-")) 
        and end-age <= integer(replace(entry(2,period-list:entry(kursor),"-"),"...","0"))
            then flag-ok = no.
    end.
    if flag-ok then do:
        if int(fill-end-date) = 0 or fill-start-date <= fill-end-date then 
        do:
            if int(fill-start-date) > 0 or int(fill-end-date) > 0 then
            do: 
                if int(fill-end-date) > 0 then
                ctmp = string(fill-start-date) + "-":u + string(fill-end-date).
                else if int(fill-end-date) = 0 then
                ctmp = string(fill-start-date) + "-...":u.
                period-list:add-last (ctmp).
                fill-start-date:screen-value = "0":u.
                fill-end-date:screen-value = "0":u.
            end.
            else message "Не заполнено ни одного поля.":u view-as alert-box.
        end.
        else message "Максимальный возраст периода не может быть меньше минимального. ":u + string(fill-start-date:screen-value) + "-" + string(fill-end-date:screen-value) view-as alert-box.
    end.
    else message "Данный возрастной период пересекается с указанным в списке.".
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn-del-period
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-del-period F-Frame-Win
ON CHOOSE OF btn-del-period IN FRAME F-Main /* - */
DO:
  period-list:delete(period-list:screen-value).
  assign period-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&Scoped-define SELF-NAME chk-age
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL chk-age F-Frame-Win
ON VALUE-CHANGED OF chk-age IN FRAME F-Main /* Сегментация по возрасту */
DO:
  assign chk-age.
  fill-start-date:sensitive = chk-age.
  fill-end-date:sensitive = chk-age.
  btn-add-period:sensitive = chk-age.
  btn-del-period:sensitive = chk-age.
  period-list:sensitive = chk-age.
  rect-6:sensitive = chk-age.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME SelectDC
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL SelectDC F-Frame-Win
ON VALUE-CHANGED OF SelectDC IN FRAME F-Main
DO:
 assign SelectDC.
 case SelectDC:
     when "card":u then do:
         run str/dc-list.w (my-handle, v-cntxt-host-code-obj, v-cntxt-obj-type, v-cntxt-obj-code).
         dcard-mode = 1.
         find first dc-list no-lock no-error .
          if not available dc-list then do:
            message
            "В списке карт нет ни одной карты"
            view-as alert-box WARNING.
            dcard-mode = 0.
            end.
     end.
     when "all":u then do:
         assign
         dcard-mode = 0
         SelectDC = "all":U
         .
     end.
 end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK F-Frame-Win 


&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
   /* Now enable the interface  if in test mode - otherwise this happens when
      the object is explicitly initialized from its container. */
   run dispatch in this-procedure ('initialize':u).
&ENDIF

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects F-Frame-Win  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available F-Frame-Win  _ADM-ROW-AVAILABLE
PROCEDURE adm-row-available :
/*------------------------------------------------------------------------------
  Purpose:     Dispatched to this procedure when the Record-
               Source has a new row available.  This procedure
               tries to get the new row (or foriegn keys) from
               the Record-Source and process it.
  Parameters:  <none>
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.             */
  {src/adm/template/row-head.i}

  /* Process the newly available records (i.e. display fields,
     open queries, and/or pass records on to any RECORD-TARGETS).    */
  {src/adm/template/row-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI F-Frame-Win  _DEFAULT-DISABLE
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
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI F-Frame-Win  _DEFAULT-ENABLE
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
  DISPLAY SelectDC chk-obj chk-dk chk-sex chk-age fill-start-date fill-end-date 
          period-list 
      WITH FRAME F-Main.
  ENABLE rect-3 rect-5 rect-6 SelectDC chk-obj chk-dk chk-sex chk-age 
      WITH FRAME F-Main.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize F-Frame-Win 
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/
  /* Code placed here will execute PRIOR to standard behavior. */
  /* Dispatch standard ADM method.                             */
  run dispatch in this-procedure ( input 'initialize':u ) .
  /* Code placed here will execute AFTER standard behavior.    */
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-report F-Frame-Win 
PROCEDURE My-report :
/*--DEFINITIONS--*/
        /*--VARIABLE DEFINITIONS--*/
            define variable     i-quantmp           as integer      no-undo.
            define variable     d-sumtmp            as decimal      no-undo.
            define variable     d-disctmp           as decimal      no-undo.
            define variable     list-counter        as integer      no-undo.
        /*END VARIABLE DEFINITIONS*/
    /*END DEFINITIONS*/ 
if chk-age:checked in frame f-main and period-list:num-items in frame f-main = 0  then
message "В списке нет ни одного периода" view-as alert-box.
else
do:
        
RUN My-var.
/*my-handle*/
assign chk-obj.
assign chk-dk.
assign chk-sex.
assign chk-age.
if not chk-age and not chk-sex then message "Не выбрана сегментация по какому-либо признаку." view-as alert-box.
else do:
    if chk-age and period-list:list-items = "" then message "Не задано ни одного возрастного периода.".
    else
    run rep/r-segm.p (
                        input my-handle,
                        input chk-obj, 
                        input chk-dk,
                        input chk-sex, 
                        input chk-age, 
                        input period-list:list-items,
                        input x-date-start,
                        input x-date-end,
                        input dcard-mode
                        ).
    end.
end.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var F-Frame-Win 
PROCEDURE my-var :
Reportname = "ИТОГИ ПО ДИСКОНТНЫМ КАРТАМ".
ReportHeader = "Покупатели: "
.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed F-Frame-Win 
PROCEDURE state-changed :
define input parameter p-issuer-hdl as handle no-undo.
  define input parameter p-state as character no-undo.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

