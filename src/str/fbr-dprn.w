using Ibs.Th.Gbl.*.

&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
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

Список печатных форм документа производства

Автор: Белоусов Илья Александрович
Дата создания: 09/09/05
Author: Ilia Belousov
Creation date: 09/09/05

Input:

Output:

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список печатных форм документа производства".
{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/library.i      }
{ cmp/r-pril.i new   }
{ gbl/color.i        }
{ rep/menu-doc.i def }
{ gbl/getcntxt.i def }
{ gbl/getsect.i def  }
{ cmp/showinf.i      }

define new shared variable CostPrice    as logical                          no-undo.

define variable ii              as integer          no-undo.
define variable Nesoot_Flag     as logical          no-undo.
define variable stat            as logical          no-undo.
define variable in-docprvalue   as character        no-undo.
define variable in-docprtype    as character        no-undo.
define variable List_           as character        no-undo.
define variable sys-key         as character        no-undo.   /* для чтения параметра конфигурации */

define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.

/* для генерации отчетов excel */
def new shared var v-rep-util as class ReportXsltUtil no-undo.

DEFINE NEW SHARED BUFFER clients FOR ub.clients.
&scop new new

define buffer buf_usr-flt for ubflt.usr-flt .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-2

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES Tmp#List

/* Definitions for BROWSE BROWSE-2                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2 Tmp#List.last-use Tmp#List.blank-name Tmp#List.type-price
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2 Tmp#List.last-use
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-2 Tmp#List
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-2 Tmp#List
&Scoped-define SELF-NAME BROWSE-2
&Scoped-define QUERY-STRING-BROWSE-2 FOR EACH Tmp#List NO-LOCK where     Tmp#List.view_ <> 0     BY Tmp#List.cli-code
&Scoped-define OPEN-QUERY-BROWSE-2 OPEN QUERY {&SELF-NAME} FOR EACH Tmp#List NO-LOCK where     Tmp#List.view_ <> 0     BY Tmp#List.cli-code.
&Scoped-define TABLES-IN-QUERY-BROWSE-2 Tmp#List
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2 Tmp#List


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-2}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-chg b-print b-help b-exit b-mark b-erase ~
BROWSE-2 tg-rubl tg-fat tg-detail v-printer-name
&Scoped-Define DISPLAYED-OBJECTS tg-rubl tg-fat tg-detail v-printer-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON b-erase
     LABEL "&Снять все *":L
     SIZE 13.13 BY 1 TOOLTIP "Снять все отметки"
     BGCOLOR 8 .

DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "&Выход ":L
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "&Помощь":L
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-mark
     LABEL "&*":L
     SIZE 3.63 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-print
     LABEL "Пе&чать":L
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE v-printer-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Текущий принтер"
      VIEW-AS TEXT
     SIZE 53 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE tg-detail AS LOGICAL INITIAL no
     LABEL "Детализация"
     VIEW-AS TOGGLE-BOX
     SIZE 19.75 BY .83 NO-UNDO.

DEFINE VARIABLE tg-fat AS LOGICAL INITIAL no
     LABEL "Калорийность"
     VIEW-AS TOGGLE-BOX
     SIZE 15.5 BY .83 NO-UNDO.

DEFINE VARIABLE tg-rubl AS LOGICAL INITIAL no
     LABEL "Печать в "
     VIEW-AS TOGGLE-BOX
     SIZE 19.75 BY .83 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-2 FOR
      Tmp#List SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2 Dialog-Frame _FREEFORM
  QUERY BROWSE-2 DISPLAY
      Tmp#List.last-use COLUMN-LABEL "*" FORMAT "*/"
      Tmp#List.blank-name COLUMN-LABEL "Название документа":C59 FORMAT "X(59)"
      Tmp#List.type-price column-label "уч.ц."    format "X(5)"
  ENABLE
      Tmp#List.last-use
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-BOX NO-ROW-MARKERS SEPARATORS SIZE 70.13 BY 17.54.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-chg AT ROW 1 COL 36 WIDGET-ID 2
     b-print AT ROW 1 COL 51
     b-help AT ROW 1 COL 61
     b-exit AT ROW 1.04 COL 2.13
     b-mark AT ROW 1.04 COL 12.13
     b-erase AT ROW 1.04 COL 15.88
     BROWSE-2 AT ROW 2.25 COL 1.38
     tg-rubl AT ROW 20.04 COL 2.5
     tg-fat AT ROW 20.04 COL 45.38 WIDGET-ID 4
     tg-detail AT ROW 20.96 COL 2.5
     v-printer-name AT ROW 22 COL 17 COLON-ALIGNED
     SPACE(0.62) SKIP(0.32)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "".


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
/* BROWSE-TAB BROWSE-2 b-erase Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       BROWSE-2:MAX-DATA-GUESS IN FRAME Dialog-Frame         = 200.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-2
/* Query rebuild information for BROWSE BROWSE-2
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH Tmp#List NO-LOCK where
    Tmp#List.view_ <> 0
    BY Tmp#List.cli-code.
     _END_FREEFORM
     _OrdList          = "Temp-Tables.Tmp#List.cli-code|yes"
     _Query            is OPENED
*/  /* BROWSE BROWSE-2 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-2 Dialog-Frame
ON 1 OF BROWSE-2 IN FRAME Dialog-Frame
DO:
    if available tmp#list
    then do:
        if tmp#list.type-price = "  +":U
        or tmp#list.type-price = "  -":U
        then do:
            assign
                tmp#list.type-price = ( if tmp#list.type-price = "  +":U then "  -":U else "  +":U )
            .
        end.
        BROWSE-2 :refresh().
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
    if available tmp#list
    then do:
        define variable v-options-string            as character    no-undo.
        define variable v-options-string-new        as character    no-undo.
        define variable v-options-enabled-string    as character    no-undo.
        run menu-doc-create-options-string in this-procedure (
              input tmp#list.id
            , output v-options-string
        ).
        run menu-doc-create-options-enabled-string in this-procedure (
              input tmp#list.id
            , output v-options-enabled-string
        ).
        run str/fbrdprnd.w (
              input tmp#list.blank-name
            , input v-options-string
            , input v-options-enabled-string
            , output v-options-string-new
        ) no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip(1)
                skip "Ошибка изменения параметров печати."
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return no-apply .
        end.
        if v-options-string-new <> v-options-string
        then do:
            run menu-doc-set-options-string in this-procedure (
                    input tmp#list.id
                  , input v-options-string-new
            ).
            browse {&browse-name} :refresh().
            apply "entry" to {&browse-name} in frame {&frame-name}.
        end.
    end.        /* available tmp#list */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-erase
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-erase Dialog-Frame
ON CHOOSE OF b-erase IN FRAME Dialog-Frame /* Снять все * */
DO:
  For each Tmp#List share-lock :
      Tmp#List.last-use=false.
  End.
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
OR MOUSE-SELECT-DBLCLICK OF {&BROWSE-name} IN FRAME {&frame-name}
DO:
    if not available tmp#list
    then do:
        message "Неправильный выбор строки.".
        return no-apply.
    end.
    {&browse-name} :refresh ().
    if Tmp#List.last-use = true
    then do:
        assign
            Tmp#List.last-use = false
        .
        display
            "" @ Tmp#List.last-use
        with browse {&browse-name}.
    end.
    else do:
        assign
            Tmp#List.last-use = true
        .
        display
            "*" @ Tmp#List.last-use
        with browse {&browse-name}.
    end.
    apply "VALUE-CHANGED" to {&browse-name} in frame {&frame-name}.
    assign
        g#log = {&browse-name}:select-next-row ()
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
DO:
  define variable lok as logical no-undo .
  
/*rash*/
define variable         PrintDoc              as      logical no-undo .
define variable         PrintSet              as      logical no-undo .
define variable         Print-Round           AS      LOGICAL INITIAL yes no-undo .

    define variable l-recid as recid no-undo .
/* Ничего не отметили */
    Assign
        List_ = ''
        ii = 0
        l-recid = recid(Tmp#List)
    .
    
    For each Tmp#List
    :
        if Tmp#List.last-use <> false
        then Assign
            ii = ii + 1
            List_ = List_ + ',' + string(tmp#list.id)
        .
    End.
    if ii = 0
    then do:
        Message
            "Отметьте формы документа для печати!"
        view-as alert-box information
        title "Внимание !".
        find first Tmp#List no-lock
             where l-recid = recid(Tmp#List)
        .
        return no-apply.
    end.
{ gbl/getsect.i run v-cntxt-obj-type v-cntxt-obj-code {&attr-prt-obj} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'in-docpr' then in-docprvalue =  thbjattr_thbj-attr.property-value-character .
end.

/* Запомнить параметры */
    run save-form-parameters in this-procedure.

    if g#quest-print = true  THEN DO:
    output  to value( string( session:temp-directory + "$" + string( g#report-num ) ) ) .
    OUTPUT CLOSE.
    End.
    v-rep-util = new ReportXsltUtil(string( session :temp-directory ) + {&DF_Name} + string( g#report-num )).
    
    for each tmp#list no-lock
        where tmp#list.last-use = yes
    :
        assign
            CostPrice   = ( trim( tmp#list.type-price ) = "+":U )
        .
        
        v-rep-util:begin-report().
        
        case num-entries(tmp#list.proc-param)
        :
            when 0
            then do:
                run value (tmp#list.proc-name)  (
                      input p-mainmenu-handle
                    , input rec_id
                    , input tg-rubl
                    , input tg-detail
                    , INPUT tg-fat
                ).
            end.
            when 1
            then do:
                run value (tmp#list.proc-name)  (
                      input p-mainmenu-handle
                    , input rec_id
                    , input tg-rubl
                    , input tg-detail
                    , input tmp#list.proc-param
                ).
            end.
            when 2
            then do:  
                run value (tmp#list.proc-name)  (
                      input p-mainmenu-handle
                    , input rec_id
                    , input tg-rubl
                    , input tg-detail
                    , INPUT tg-fat
                    , input entry(1,tmp#list.proc-param)
                    , input entry(2,tmp#list.proc-param)
                ).
            end.
            when 3
            then do:
                message "Для документа производства число параметров не может быть равно 3"
                    view-as alert-box.
            end.
            when 4
            then do:
                run value (tmp#list.proc-name) (
                      input p-mainmenu-handle
                    , input rec_id
                    , input tg-rubl
                    , input tg-detail
                    , input entry(1,tmp#list.proc-param)
                    , input entry(2,tmp#list.proc-param)
                    , input entry(3,tmp#list.proc-param)
                    , input entry(4,tmp#list.proc-param)
                ).
            end.
            
            when 5
            then do:
                message
                    "Для документа производства число параметров не может быть больше 4"
                view-as alert-box.
                undo, return no-apply .
            end.
        end case.
        
        v-rep-util:end-report().
    end.
    
    v-rep-util:write-config().
    delete object v-rep-util.
    
    { gbl/stopwork.i }
    
    if g#quest-print = true
    then do:
        OS-DELETE
           value( string( session:temp-directory) + {&DF_Name} + string( g#report-num )  )    .

        OS-RENAME
           value(  string( session:temp-directory) + "$" + string( g#report-num )     )
           value(  string( session:temp-directory) + {&DF_Name} + string( g#report-num )) .
         /* Если протокол цен Excel Или tick-doc  у них своя печать */
        IF ii = 1 and
            ((can-find (first tmp#list where CAPS(Tmp#list.proc-name) = "rep/xl-prtcl.p":U and Tmp#List.last-use = true) = true  ) OR
             (can-find (first tmp#list where CAPS(Tmp#list.proc-name) = "rep/tick-doc.p":U and Tmp#List.last-use = true) = true  ))
             then do:
                   { gbl/stopwork.i }
             end.
             ELSE DO :
              find first tmp#list where  Tmp#List.last-use = true no-lock no-error .
                define variable v-user-action           as character            no-undo.
                define variable v-printed               as logical              no-undo.
              case Tmp#list.orient :
                  when 'A4port' then do:
                        run gbl/prnfilen.w (
                              input "":U
                            , input 4
                            , input string( session :temp-directory ) + {&DF_Name} + string( g#report-num )
                            , input 7
                            , output v-user-action
                            , output v-printed
                        ) .
                  end.
                  when 'A4lans' or when "" then do:
                        run gbl/prnfilen.w (
                              input "":U
                            , input 8
                            , input string( session :temp-directory ) + {&DF_Name} + string( g#report-num )
                            , input 7
                            , output v-user-action
                            , output v-printed
                        ) .
                  end.
              End case.
             End.
      end.
   Else  Message 'Задание распечатано'.   
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-2
&Scoped-define SELF-NAME BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-2 Dialog-Frame
ON ROW-DISPLAY OF BROWSE-2 IN FRAME Dialog-Frame
DO:
  if Tmp#List.orient = 'A4port' OR
     Tmp#List.orient = 'A3port'
  then DO:
      Tmp#List.last-use          :fgcolor in browse {&browse-name} = blue_color.
      Tmp#List.blank-name        :fgcolor in browse {&browse-name} = blue_color.
  End.
  else do:
      if Tmp#List.orient = 'EXCEL' OR
         Tmp#List.orient = 'self'
      then DO:
              Tmp#List.last-use   :fgcolor in browse {&browse-name} = CYAN_COLOR.
              Tmp#List.blank-name :fgcolor in browse {&browse-name} = CYAN_COLOR.
      end.
      else do:
          Tmp#List.last-use   :fgcolor in browse {&browse-name} = black_color.
          Tmp#List.blank-name :fgcolor in browse {&browse-name} = black_color.
      end.
  end.
  if tmp#list.type-price-enabled = no
  then do:
      assign
          Tmp#List.type-price :bgcolor in browse {&browse-name} = GREY_COLOR
      .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
{ gbl/app_help.i }
find first ub.fbr-doc where recid(ub.fbr-doc) = rec_id no-lock.

IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
  v-printer-name = session:printer-name.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   { gbl/getcntxt.i get " " p-mainmenu-handle }
   run get-report-num in p-mainmenu-handle (
       output g#report-num
   ).
   run get-quest-print in p-mainmenu-handle (
       output g#quest-print
   ).
  assign tg-rubl:label = "Печать в {&abbr_rublyah}" .

    run load-menu in this-procedure (
          ub.fbr-doc.doc-code
        , ub.fbr-doc.doc-type
        , ub.fbr-doc.status_
        , '*'
        , '*'
    ).
  RUN enable_UI.
  Tmp#List.last-use      :read-only in browse {&BROWSE-NAME} =  true .
    ASSIGN frame {&frame-name}:TITLE =  "Печать документа  "
  + " Тип: " + ub.fbr-doc.doc-type
  + " Статус: " + ub.fbr-doc.status_
  + "  № "  + ub.fbr-doc.doc-code.

  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus {&browse-name}.
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
  DISPLAY tg-rubl tg-fat tg-detail v-printer-name
      WITH FRAME Dialog-Frame.
  ENABLE b-chg b-print b-help b-exit b-mark b-erase BROWSE-2 tg-rubl tg-fat
         tg-detail v-printer-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-call-point Dialog-Frame
PROCEDURE get-call-point :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-tmp#list-id as integer          no-undo.
define input parameter p-doc-type as character        no-undo.
define input parameter p-status_  as character        no-undo.
define input parameter p-internal as character        no-undo.
define input parameter p-flag     as character        no-undo.
define output parameter p-call-point as character        no-undo.

do
on error undo, return error
:
    assign
        p-call-point = substitute( "&1,&2,&3,&4", p-doc-type, p-status_, p-internal, p-flag )
    .
end.
END PROCEDURE. /* get-call-point */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-saved-logical Dialog-Frame
PROCEDURE get-saved-logical :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-list       as character        no-undo.
define input parameter p-name       as character        no-undo.
define output parameter p-logical   as character        no-undo.

    define variable v-position    as integer      no-undo.
do
on error undo, return error
:
    assign
        v-position = lookup( p-name, p-list )
    .
    if v-position = 0
    then do:
        assign
            p-logical = "  -":U
        .
    end.
    else do:
        if num-entries( p-list ) > v-position
        then do:
            assign
                p-logical = "  ":U + entry( v-position + 1, p-list )
            .
            if trim( p-logical ) = "":U
            then do:
                assign
                    p-logical = "  -":U
                .
            end.
        end.
        else do:
            assign
                p-logical = "  -":U
            .
        end.
    end.
end.
END PROCEDURE. /* get-saved-logical */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Load-menu Dialog-Frame
PROCEDURE Load-menu :
/* Создание меню - Список форм по документу документов */
define input parameter p-doc-code   as character        no-undo.
define input parameter xtype        as character        no-undo.
define input parameter xstatus      as character        no-undo.
define input parameter xInternal    as character        no-undo.
define input parameter xflag        as character        no-undo.

    define variable varhave-dressing    as logical  init no no-undo.
    define variable v-call-point        as character    no-undo.
    define variable v-temp-char         as character    no-undo.

    define buffer bf_fbr-line   for ub.fbr-line.
    define buffer bf_recipe     for ub.recipe.
    define buffer buf_tmp#list  for tmp#list.
do
for bf_fbr-line
  , bf_recipe
  , buf_tmp#list
on error undo, return error
:
for each bf_fbr-line where bf_fbr-line.doc-code = fbr-doc.doc-code no-lock,
  first bf_recipe
   where bf_recipe.recipe-code = bf_fbr-line.recipe-code
     and bf_recipe.recipe-type = {&dressing}  no-lock on error undo, return error return-value :
  assign
    varhave-dressing = yes.
  leave.
end.
    { gbl/currsysk.i
      v-menu-doc-sys-key
      no-error
    }

    assign
        v-menu-doc-doc-code = p-doc-code
        v-menu-doc-doc-type = xtype
        v-menu-doc-status_  = xstatus
        v-menu-doc-internal = xInternal
        v-menu-doc-flag     = xflag
        sys-key             = v-menu-doc-sys-key
    .
    { str/fbr-dprn.i }
/* фильтрация временной таблицы  ---------------------------------------------------------------------------------------*/
    for each buf_tmp#list
    :
        run get-call-point in this-procedure (
              input buf_tmp#list.id
            , input v-menu-doc-doc-type
            , input v-menu-doc-status_
            , input v-menu-doc-internal
            , input v-menu-doc-flag
            , output v-call-point
        ).
        /* загрузить значения из ubflt.usr-flt       */
        find first buf_usr-flt no-lock
             where buf_usr-flt.user-name  = v-cntxt-userid
               and buf_usr-flt.call-point = substitute( "&1,&2,&3,&4"
                                            , buf_tmp#list.blank-name
                                            , buf_tmp#list.sys-key
                                            , buf_tmp#list.sys-key-black
                                            , v-call-point )
        no-error.
        if available buf_usr-flt
        then do:
            assign
                tg-detail    =  ( if lookup("detail", buf_usr-flt.list_) > 0 then yes else no )
                tg-rubl      =  ( if lookup("rubl",   buf_usr-flt.list_) > 0 then yes else no )
                tg-fat       =  ( if lookup("fat",    buf_usr-flt.list_) > 0 then yes else no )
            .
        end.
        else do:
            create buf_usr-flt .
            assign
                buf_usr-flt.user-name    = v-cntxt-userid
                buf_usr-flt.call-point   = substitute( "&1,&2,&3,&4"
                                            , buf_tmp#list.blank-name
                                            , buf_tmp#list.sys-key
                                            , buf_tmp#list.sys-key-black
                                            , v-call-point )
            .
        end.
        run get-saved-logical in this-procedure (
              input buf_usr-flt.list_
            , input "type-price":U
            , output buf_tmp#list.type-price
        ).
        assign
            v-temp-char = "":U
        .
        run get-saved-logical in this-procedure (
              input buf_usr-flt.list_
            , input "selection":U
            , output v-temp-char
        ).
        if v-temp-char = "  +":U
        then do:
            assign
                buf_tmp#list.last-use = yes
            .
        end.
        assign
            buf_tmp#list.view_ = 1
        .
        /* отсекаем по sys-key */
        if sys-key <> {&SuperSysKey}
        then do:
            if sys-key <> buf_tmp#list.sys-key
            and buf_tmp#list.sys-key <> ''
            then do:
                assign
                    buf_tmp#list.view_      = 0
                    buf_tmp#list.last-use   = no
                .
            end.
        end.
        if buf_tmp#list.proc-name = "":U
        then do:
            assign
                buf_tmp#list.view_      = 0
                buf_tmp#list.last-use   = no
            .
        end.
        if buf_tmp#list.type-price-enabled = no
        then do:
            assign
                buf_tmp#list.type-price   = " ":U
            .
        end.
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-form-parameters Dialog-Frame
PROCEDURE save-form-parameters :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define variable v-call-point    as character    no-undo.

    define buffer buf_tmp#list          for tmp#list.
    define buffer buf_usr-flt           for ubflt.usr-flt.
    define buffer buf_temp_form-list    for temp_form-list.
do
for buf_tmp#list
  , buf_usr-flt
  , buf_temp_form-list
with frame {&frame-name}
on error undo, return error
:
    for each buf_tmp#list
    :
        run get-call-point in this-procedure (
              input buf_tmp#list.id
            , input v-menu-doc-doc-type
            , input v-menu-doc-status_
            , input v-menu-doc-internal
            , input v-menu-doc-flag
            , output v-call-point
        ).
        find first buf_usr-flt exclusive-lock
             where buf_usr-flt.user-name  = v-cntxt-userid
               and buf_usr-flt.call-point = substitute( "&1,&2,&3,&4"
                                            , buf_tmp#list.blank-name
                                            , buf_tmp#list.sys-key
                                            , buf_tmp#list.sys-key-black
                                            , v-call-point )
        no-error.
        if not available buf_usr-flt
        then do:
            create buf_usr-flt.
            assign
                buf_usr-flt.user-name  = v-cntxt-userid
                buf_usr-flt.call-point = substitute( "&1,&2,&3,&4"
                                            , buf_tmp#list.blank-name
                                            , buf_tmp#list.sys-key
                                            , buf_tmp#list.sys-key-black
                                            , v-call-point )
            .
        end.
        assign
            buf_usr-flt.list_ = substitute( "selection,&1,type-price,&2,type-scale,&3,type-val,&4,sort-name,&5,sort-gr,&6,print-graft,&7":U
                                    , ( if buf_tmp#list.last-use = yes then "+":U else "-":U )
                                    , ( if index( buf_tmp#list.type-price , "+":U ) <> 0 then "+":U else "-":U )
                                    , ( if index( buf_tmp#list.type-scale , "+":U ) <> 0 then "+":U else "-":U )
                                    , ( if index( buf_tmp#list.type-val   , "+":U ) <> 0 then "+":U else "-":U )
                                    , ( if index( buf_tmp#list.sort-name  , "+":U ) <> 0 then "+":U else "-":U )
                                    , ( if index( buf_tmp#list.sort-gr    , "+":U ) <> 0 then "+":U else "-":U )
                                    , ( if index( buf_tmp#list.print-graft, "+":U ) <> 0 then "+":U else "-":U )
                                    )
        .
        assign
            tg-rubl
            tg-detail
            tg-fat
        .
        assign
            buf_usr-flt.list_       = buf_usr-flt.list_
                                    + ( if tg-rubl   = yes then ",rubl"   else "" )
                                    + ( if tg-detail = yes then ",detail" else "" )
                                    + ( if tg-fat    = yes then ",fat" else "" )
        .
    end.
end.
END PROCEDURE. /* save-form-parameters */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
