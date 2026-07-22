&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список печатных форм план-меню

Автор: Демин Алексей Сергеевич
Дата создания: 09/09/05
Author: Alexey Demin
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
define variable vss-description as character no-undo init "Список печатных форм план-меню".
{ cmp/vssrevis.i        }
{ cmp/str-glbl.i        }
{ cmp/library.i         }
{ cmp/r-pril.i new      }
{ cmp/r-page1.i new     }
{ gbl/color.i           }
{ rep/menu-doc.i def    }
{ gbl/getcntxt.i def mai   }
{ cmp/showinf.i         }
{ gbl/getsect.i def    }
define variable ii as int no-undo .
define variable Nesoot_Flag  as logical  no-undo .
define variable stat                 as logical  no-undo .
define variable in-docprvalue as character no-undo.
define variable in-docprtype  as character no-undo.
define variable List_  as character no-undo.
define variable sys-key as char no-undo.                  /* для чтения параметра конфигурации */

define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.

define buffer buf_init_fbr-pln       for ub.fbr-pln.

&scop new new

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-2

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES Tmp#List

/* Definitions for BROWSE BROWSE-2                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2 Tmp#List.last-use Tmp#List.blank-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2 Tmp#List.last-use
&Scoped-define FIELD-PAIRS-IN-QUERY-BROWSE-2~
 ~{&FP1}last-use ~{&FP2}last-use ~{&FP3}
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-2 Tmp#List
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-2 Tmp#List
&Scoped-define SELF-NAME BROWSE-2
&Scoped-define OPEN-QUERY-BROWSE-2 OPEN QUERY {&SELF-NAME} FOR EACH Tmp#List NO-LOCK where     Tmp#List.view_ <> 0     BY Tmp#List.cli-code.
&Scoped-define TABLES-IN-QUERY-BROWSE-2 Tmp#List
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2 Tmp#List


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-2}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-mark b-erase b-print b-help ~
BROWSE-2 v-printer-name
&Scoped-Define DISPLAYED-OBJECTS v-printer-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-erase
     LABEL "&Снять все *":L
     size 13.13 by 1 TOOLTIP "Снять все отметки"
     BGCOLOR 8 .

DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "&Выход ":L
     size 10 by 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "&Помощь":L
     size 10 by 1
     BGCOLOR 8 .

DEFINE BUTTON b-mark
     LABEL "&*":L
     size 3.63 by 1
     BGCOLOR 8 .

DEFINE BUTTON b-print
     LABEL "Пе&чать":L
     size 10 by 1
     BGCOLOR 8 .

DEFINE VARIABLE v-printer-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Текущий принтер"
      VIEW-AS TEXT
     SIZE 46.13 BY .67
     FGCOLOR 4  NO-UNDO.

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
  ENABLE
      Tmp#List.last-use
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-BOX NO-ROW-MARKERS SEPARATORS SIZE 63.88 BY 19.21.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit at row 1.04 col 2.13
     b-mark at row 1.04 col 12.13
     b-erase at row 1.04 col 15.88
     b-print at row 1.04 col 44.88
     b-help at row 1.04 col 55
     BROWSE-2 AT ROW 2.25 COL 1.38
     v-printer-name AT ROW 22 COL 17 COLON-ALIGNED
     SPACE(1.11) SKIP(0.32)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: Tmp#List T "?" NO-UNDO ub ord-blank
      ADDITIONAL-FIELDS:
          field id as int
          field proc-name as char
          field proc-param as char
          field orient    as char
          field filtr as char
          field view_ as int init 1
          field sys-key as char
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BROWSE-2 b-help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       BROWSE-2:MAX-DATA-GUESS IN FRAME Dialog-Frame     = 200.

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

ON ROW-DISPLAY OF {&BROWSE-name} IN FRAME {&frame-name}
DO:
if Tmp#List.orient = 'A4port' OR
   Tmp#List.orient = 'A3port'
     then DO:
      Tmp#List.last-use          :fgcolor in browse {&browse-name} = blue_color.
      Tmp#List.blank-name        :fgcolor in browse {&browse-name} = blue_color.
  End.
  Else DO:
      if Tmp#List.orient = 'EXCEL' OR
        Tmp#List.orient = 'self'
          then DO:
              Tmp#List.last-use   :fgcolor in browse {&browse-name} = CYAN_COLOR.
              Tmp#List.blank-name :fgcolor in browse {&browse-name} = CYAN_COLOR.
          end.
          Else DO:
              Tmp#List.last-use   :fgcolor in browse {&browse-name} = black_color.
              Tmp#List.blank-name :fgcolor in browse {&browse-name} = black_color.
          End.
  End.
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
 find first ubflt.usr-flt exclusive-lock
      where ubflt.usr-flt.user-name = v-cntxt-userid
        and ubflt.usr-flt.call-point  = String( buf_init_fbr-pln.doc-type)
                                  + ",no,"
                                  /*+ String(  trn-doc.internal)*/
                                  + String(  buf_init_fbr-pln.status_ ) + ",no"
                                  /*+ String(  trn-doc.flag )*/
 no-error .
if g#quest-print = true  THEN DO:
   output  to value( string( session:temp-directory + "$" + string( g#report-num ) ) ) .
   OUTPUT CLOSE.
End.

    for each Tmp#List no-lock
        where Tmp#List.last-use = true
    :
        case num-entries(tmp#list.proc-param)
        :
            when 0
            then do:
                run value (tmp#list.proc-name)  (
                      input p-mainmenu-handle
                    , input rec_id
                ).
            end.
            when 1
            then do:
                run value (tmp#list.proc-name)  (
                      input p-mainmenu-handle
                    , input rec_id
                    , input tmp#list.proc-param
                ).
            end.
            when 2
            then do:
                run value (tmp#list.proc-name)  (
                      input p-mainmenu-handle
                    , input rec_id
                    , input entry(1,tmp#list.proc-param)
                    , input entry(2,tmp#list.proc-param)
                ).
            end.
            when 3
            then do:
                run value (tmp#list.proc-name)  (
                      input p-mainmenu-handle
                    , input rec_id
                    , input entry(1,tmp#list.proc-param)
                    , input entry(2,tmp#list.proc-param)
                    , input entry(3,tmp#list.proc-param)
                ).
            end.
            when 4
            then do:
                message
                    "Для документа производства число параметров не может быть больше 3"
                view-as alert-box.
                undo, return no-apply .
            end.
        end case.
    end.
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
             THEN do:
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
                            , 7
                            , output v-user-action
                            , output v-printed
                        ) .
                  end.
                  when 'A4lans' or when "" then do:
                        run gbl/prnfilen.w (
                              input "":U
                            , input 8
                            , input string( session :temp-directory ) + {&DF_Name} + string( g#report-num )
                            , 7
                            , output v-user-action
                            , output v-printed
                        ) .
                  end.
              End case.
             End.
    end.
    Else do:
        message
            "Задание распечатано"
        view-as alert-box information.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-2
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
{ gbl/app_help.i }

    { gbl/getcntxt.i get " " p-mainmenu-handle }
    run get-report-num in p-mainmenu-handle (
        output g#report-num
    ).
    run get-quest-print in p-mainmenu-handle (
        output g#quest-print
    ).
    find first buf_init_fbr-pln no-lock
        where recid(buf_init_fbr-pln) = rec_id
    .
    if valid-handle(active-window)
    and frame {&frame-name}:parent eq ?
    then do:
        assign
            FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW
        .
    end.
    assign
        v-printer-name = session:printer-name
    .
    run load-menu in this-procedure (
          input buf_init_fbr-pln.doc-code
        , input buf_init_fbr-pln.doc-type
        , input buf_init_fbr-pln.status_
        , input "'*'"
        , input "'*'"
    ).
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    RUN enable_UI.
    Tmp#List.last-use      :read-only in browse {&BROWSE-NAME} =  true .
        ASSIGN frame {&frame-name}:TITLE =  "Печать документа  "
    + " Тип: " + buf_init_fbr-pln.doc-type
    + " Статус: " + buf_init_fbr-pln.status_
    + "  № "  + buf_init_fbr-pln.doc-code.

    WAIT-FOR GO OF FRAME {&FRAME-NAME} focus {&browse-name}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

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
  DISPLAY v-printer-name
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-mark b-erase b-print b-help BROWSE-2 v-printer-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

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


    define buffer buf_usr-flt for ubflt.usr-flt .
do
for buf_usr-flt
on error undo, return error
:
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
    { rep/fplndprn.i }
    /* загрузить значения из buf_usr-flt       */
    find first buf_usr-flt no-lock
         where buf_usr-flt.user-name  = v-cntxt-userid
           and buf_usr-flt.call-point = string(buf_init_fbr-pln.doc-type) + ",no,"
                                    + string(buf_init_fbr-pln.status_ ) + ",no"
    no-error.
    if available buf_usr-flt
    then do:
        assign
            list_        = buf_usr-flt.list_
        .
    end.
    else do:
        create buf_usr-flt.
        assign
            buf_usr-flt.user-name    = v-cntxt-userid
            buf_usr-flt.call-point   = string( buf_init_fbr-pln.doc-type) + ",no," +
                                string(  buf_init_fbr-pln.status_ ) + ",no"
        .
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME