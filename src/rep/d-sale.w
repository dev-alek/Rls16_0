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

Список печатных форм  для продажи

Автор: Демин Алексей Сергеевич
Дата создания: 09/14/06
Author: Alexey Demin
Creation date: 09/14/06

Input:

Output:

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc       as widget-handle no-undo .
DEFINE INPUT PARAMETER rec_id              as  RECID .
define input parameter p-quest-print       as logical no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список печатных форм  для продажи".
{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/library.i      }
{ cmp/showinf.i      }
{ cmp/r-pril.i new   }
{ gbl/color.i        }
{ rep/menu-doc.i def }
{ gbl/cur-time.i     }
{ gbl/prn-lib.i      }
{ gbl/waitfram.i     }
{ gbl/getcntxt.i def }


define variable ii as int no-undo .
define variable Nesoot_Flag  as logical  no-undo .
define variable stat                 as logical  no-undo .
define variable in-docprvalue as character no-undo.
define variable in-docprtype  as character no-undo.
define variable List_  as character no-undo.
def new shared  var CostPrice as logical no-undo .
def new shared  var PrintScale as logical no-undo .
define variable sys-key as char no-undo.                  /* для чтения параметра конфигурации */
define variable p-doc-tp as character no-undo .

define buffer buf_inkas for ub.inkas.
define buffer buf_usr-flt for ubflt.usr-flt .
/*DEFINE NEW SHARED BUFFER clients FOR clients.*/
&scop new new

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-2

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES Tmp#List

/* Definitions for BROWSE BROWSE-2                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2 Tmp#List.last-use Tmp#List.blank-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2 Tmp#List.last-use
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-2 Tmp#List
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-2 Tmp#List
&Scoped-define SELF-NAME BROWSE-2
&Scoped-define QUERY-STRING-BROWSE-2 FOR EACH Tmp#List NO-LOCK where     Tmp#List.view_ <> 0     BY Tmp#List.id
&Scoped-define OPEN-QUERY-BROWSE-2 OPEN QUERY {&SELF-NAME} FOR EACH Tmp#List NO-LOCK where     Tmp#List.view_ <> 0     BY Tmp#List.id.
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
     SIZE 12 BY 1 TOOLTIP "Снять все отметки"
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
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-print
     LABEL "Выполнить/Пе&чать":L
     SIZE 20 BY 1
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
    WITH NO-BOX NO-ROW-MARKERS SEPARATORS SIZE 63.88 BY 14.58.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 11
     b-erase AT ROW 1 COL 14
     b-print AT ROW 1 COL 34
     b-help AT ROW 1 COL 54
     BROWSE-2 AT ROW 2.25 COL 1.38
     v-printer-name AT ROW 17.13 COL 17 COLON-ALIGNED
     SPACE(1.11) SKIP(0.27)
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
          field sys-key as character
          field sys-key-black  as character
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BROWSE-2 b-help Dialog-Frame */
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
    BY Tmp#List.id.
     _END_FREEFORM
     _OrdList          = "Temp-Tables.Tmp#List.id|yes"
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
  if Tmp#List.orient = 'A4port'
  or Tmp#List.orient = 'A3port'
  then do:
      Tmp#List.last-use          :fgcolor in browse {&browse-name} = blue_color.
      Tmp#List.blank-name        :fgcolor in browse {&browse-name} = blue_color.
  end.
  else do:
    if Tmp#List.orient = 'EXCEL'
    or Tmp#List.orient = 'self'
    then do:
        Tmp#List.last-use   :fgcolor in browse {&browse-name} = CYAN_COLOR.
        Tmp#List.blank-name :fgcolor in browse {&browse-name} = CYAN_COLOR.
    end.
    else do:
        Tmp#List.last-use   :fgcolor in browse {&browse-name} = black_color.
        Tmp#List.blank-name :fgcolor in browse {&browse-name} = black_color.
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-erase
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-erase Dialog-Frame
ON CHOOSE OF b-erase IN FRAME Dialog-Frame /* Снять все * */
DO:
  for each tmp#list
  :
    assign
      Tmp#List.last-use = false
    .
  end.

  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
OR MOUSE-SELECT-DBLCLICK OF {&BROWSE-name} IN FRAME {&frame-name}
DO:
define variable glog as logical no-undo .
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
        glog = {&browse-name}:select-next-row ()
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Выполнить/Печать */
DO:


  define variable lok as logical no-undo .
  define variable v-frame-width as integer no-undo .
  define variable g#quest-print as logical no-undo .
  define variable g#report-num as integer no-undo .
  /* Поиск кода 'возврат поставщику' */
  Find first ub.Sysconf where buf_inkas.host-code = ub.Sysconf.host-code
      no-lock no-error.


  /*rash*/
  define variable         PrintDoc              as      logical no-undo .
  define variable         PrintSet              as      logical no-undo .
  define variable         Print-Round           AS      LOGICAL INITIAL yes no-undo .


    define variable l-recid as recid no-undo .
/* Ничего не отметили */
    Assign List_ = '' ii = 0.
    l-recid = recid(Tmp#List) .
    For each Tmp#List
    :
        if Tmp#List.last-use <> false
        then Assign
            ii = ii + 1
            List_ = List_ + ',' + string(tmp#list.id)
        .
    End.
    if ii = 0 then DO :

      Message
      "Отметьте формы документа для печати!"
      view-as alert-box INFORMATION title "Внимание !".
      find first Tmp#List where l-recid = recid(Tmp#List) no-lock  .
      return no-apply.
    End.
    /* Запомнить параметры */
    find first buf_usr-flt exclusive-lock
         where buf_usr-flt.user-name = v-cntxt-userid
           and buf_usr-flt.call-point  = String( p-doc-tp) + ","
                                  + String(  buf_inkas.status_ )

 no-error .
 if avail buf_usr-flt
 then Assign
 buf_usr-flt.list_       = list_
 .

    run get-quest-print  in parparentproc(output g#quest-print).

    if g#quest-print = true or p-quest-print
    then do:
        run get-report-num in parparentproc ( output g#report-num).
        output  to value( string( session:temp-directory + "$" + string( g#report-num ) ) ) .
        output close.
    End.
    /*
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) .
    output close.
    output to value( string( session:temp-directory + {&DF_Name} + string( g#report-num ) ) + ".txl" ) .
    output close.
    */
    for each Tmp#List no-lock
       where Tmp#List.last-use = true
    :
        case num-entries(tmp#list.proc-param)
        :
            when 0
            then do:
                run value (tmp#list.proc-name)  (input parparentproc
                                                ,input buf_inkas.inkas-code
                                                ,output v-frame-width
                                                ).
            end.
            when 1
            then do:
                run value (tmp#list.proc-name)  (     input parparentproc
                                                    , input buf_inkas.inkas-code
                                                    , input tmp#list.proc-param
                                                    , output v-frame-width
                                                ).
            end.
            when 2
            then do:
                run value (tmp#list.proc-name)  (     input parparentproc
                                                    , input buf_inkas.inkas-code
                                                    , input Entry(1,tmp#list.proc-param)
                                                    , input Entry(2,tmp#list.proc-param)
                                                    , output v-frame-width
                                                ).
            end.
            when 3
            then do:
                run value (tmp#list.proc-name)  (     input parparentproc
                                                    , input buf_inkas.inkas-code
                                                    , input Entry(1,tmp#list.proc-param)
                                                    , input Entry(2,tmp#list.proc-param)
                                                    , input Entry(3,tmp#list.proc-param)
                                                    , output v-frame-width
                                                ).
            end.
            when 4
            then do:
                run value (tmp#list.proc-name)  (     input parparentproc
                                                    , input buf_inkas.inkas-code
                                                    , input Entry(1,tmp#list.proc-param)
                                                    , input Entry(2,tmp#list.proc-param)
                                                    , input Entry(3,tmp#list.proc-param)
                                                    , input Entry(4,tmp#list.proc-param)
                                                    , output v-frame-width
                                                ).
            end.
            when 5
            then do:
                run value (tmp#list.proc-name)  (     input parparentproc
                                                    , input buf_inkas.inkas-code
                                                    , input Entry(1,tmp#list.proc-param)
                                                    , input Entry(2,tmp#list.proc-param)
                                                    , input Entry(3,tmp#list.proc-param)
                                                    , input Entry(4,tmp#list.proc-param)
                                                    , input Entry(5,tmp#list.proc-param)
                                                    , output v-frame-width
                                                ).
            end.
            when 6
            then do:
                run value (tmp#list.proc-name)  (     input parparentproc
                                                    , input buf_inkas.inkas-code
                                                    , input Entry(1,tmp#list.proc-param)
                                                    , input Entry(2,tmp#list.proc-param)
                                                    , input Entry(3,tmp#list.proc-param)
                                                    , input Entry(4,tmp#list.proc-param)
                                                    , input Entry(5,tmp#list.proc-param)
                                                    , input Entry(6,tmp#list.proc-param)
                                                    , output v-frame-width
                                                ).
            end.
        End case.
    End.
    run waitfram-hide in this-procedure .

    if g#quest-print = true or p-quest-print
    Then do:
        os-delete
            value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) )
        .
        os-rename
            value(  string( session:temp-directory ) + "$" + string( g#report-num ) )
            value(  string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) )
        .
        os-delete
            value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
        .
        os-rename
            value(  string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
            value(  string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
        .
        find first tmp#list
              where Tmp#List.last-use = true
        no-error .
        case Tmp#list.orient
        :
            when 'A4port'
            then do:
              run prn-lib-prn-file in this-procedure (
                                                        input parParentProc
                                                        ,input 0
                                                        ).
            end.
            when 'A4lans'
            or when ""
            then do:
              run prn-lib-prn-file in this-procedure (
                                                        input parParentProc
                                                        ,input 8
                                                        ).
            end.
            when 'output':U then do:
              if v-frame-width <= 198 then do:
                if v-frame-width < 136 then do:
                  run prn-lib-prn-file in this-procedure (
                                                            input parParentProc
                                                            ,input 0
                                                            ).

                end.
                if v-frame-width <= 198 and v-frame-width >= 136 then do:
                  run prn-lib-prn-file in this-procedure (
                                                            input parParentProc
                                                            ,input 8
                                                            ).
                 end.
              end.
              else do:
                if v-frame-width <= 255 then
                run prn-lib-prn-file in this-procedure (
                                                          input parParentProc
                                                          ,input 1
                                                          ).
                else
                run prn-lib-prn-file in this-procedure (
                                                          input parParentProc
                                                          ,input 20
                                                          ).
              end.
            end.
        end case.
    end.
    else do:
        Message 'Задание распечатано'.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-2
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
{ gbl/app_help.i }
find first buf_inkas where recid(buf_inkas) = rec_id no-lock.

IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
  v-printer-name = session:printer-name.

Assign
p-doc-tp = "inkas":U .

{ gbl/getcntxt.i get }
run load-menu in this-procedure (
    input buf_inkas.inkas-code
  , input p-doc-tp
  , input buf_inkas.status_).
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  Tmp#List.last-use      :read-only in browse {&BROWSE-NAME} =  true .
  Tmp#List.blank-name:width in browse browse-2 = 59.
  Tmp#List.blank-name:resizable in browse browse-2 = yes.
    ASSIGN frame {&frame-name}:TITLE =  "Работа с отчетом о продаже (печать и не только)"
    + " Статус: " + buf_inkas.status_
    + "  № "  + buf_inkas.inkas-code.
    if sys-key = {&SuperSysKey}
    then do:
        run init-syskey-names in this-procedure.
    end.
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
  DISPLAY v-printer-name
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-mark b-erase b-print b-help BROWSE-2 v-printer-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-syskey-names Dialog-Frame
PROCEDURE init-syskey-names :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    define variable v-next-line as logical       no-undo.
    lines-of-browse:
    for each tmp#list
    :
        if v-next-line = yes
        then do:
            assign
                v-next-line = no
            .
            next lines-of-browse.
        end.
        if tmp#list.sys-key <> ""
        then do:
            assign
                tmp#list.blank-name = substring( tmp#list.blank-name + " '" + tmp#list.sys-key + "'" , 1, 120 )
                v-next-line = yes
            .
        end.
        if Tmp#List.sys-key-black <> ""
        then do:
            assign
                Tmp#List.blank-name = substring( Tmp#List.blank-name + " no-'" + Tmp#List.sys-key-black + "'", 1, 120 )
                v-next-line = yes
            .
        end.
    end.
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
end.
END PROCEDURE. /* init-syskey-names */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Load-menu Dialog-Frame
PROCEDURE Load-menu :
/* Создание меню - Список форм по отчету о продаже */
define input parameter p-inkas-code as character        no-undo.
define input parameter xtype        as character        no-undo.
define input parameter xstatus      as character        no-undo.

/*это просто болванки для совместимости*/
define variable xInternal as char no-undo init no.
define variable xflag     as char no-undo init yes.


    { gbl/currsysk.i
      v-menu-doc-sys-key
      no-error
    }

    assign
        v-menu-doc-doc-code = p-inkas-code
        v-menu-doc-doc-type = xtype
        v-menu-doc-status_  = xstatus
        v-menu-doc-internal = xInternal
        v-menu-doc-flag     = xflag
        sys-key             = v-menu-doc-sys-key
    .

{ rep/load-sal.i }
/* загрузить значения из buf_usr-flt       */
find first buf_usr-flt no-lock
     where buf_usr-flt.user-name  = v-cntxt-userid
       and buf_usr-flt.call-point = string(p-doc-tp) + ","
                                + string(buf_inkas.status_ )

no-error.
if available buf_usr-flt
then do:
  Assign
      list_        = buf_usr-flt.list_
  .
end.
else do:
    create  buf_usr-flt .
    Assign
    buf_usr-flt.user-name = v-cntxt-userid
    buf_usr-flt.call-point   = String( p-doc-tp) + "," +
                          String(  buf_inkas.status_ )
    .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME