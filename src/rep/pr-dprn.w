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

Печать переоценки

Автор: Гюнтнер Виктор Арнольдович
Дата создания: 09/09/05
Author: Victor Guntner
Creation date: 09/09/05


в uib  не лезет !!!
*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as  recid           no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Печать переоценки".
{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/library.i      }
{ cmp/r-pril.i new   }
{ gbl/color.i        }
{ rep/menu-doc.i def }
{ gbl/getcntxt.i def }
{ cmp/showinf.i      }
{ gbl/getsect.i  def }
define variable ii as int no-undo .
define variable Nesoot_Flag  as logical  no-undo .
define variable stat                 as logical  no-undo .
define variable in-docprvalue as character no-undo.
define variable in-docprtype  as character no-undo.
define variable v-list_  as character no-undo.
define variable sys-key as char no-undo.                  /* для чтения параметра конфигурации */
define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
define variable v-user-action as character no-undo .
define variable v-printed as logical   no-undo .
define variable DisabledOptions as integer   no-undo .


DEFINE NEW SHARED BUFFER clients FOR ub.clients.
&scop new new

define buffer buf_usr-flt for ubflt.usr-flt .

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
&Scoped-Define ENABLED-OBJECTS RECT-1 b-exit b-mark b-erase b-print b-help ~
BROWSE-2 tg-print-zero rs-price-selection tg-sort-by-group v-printer-name
&Scoped-Define DISPLAYED-OBJECTS tg-print-zero rs-price-selection ~
tg-sort-by-group v-printer-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-erase
     LABEL "&Снять все *":L
     size 13.13 by 1.1 TOOLTIP "Снять все отметки"
     BGCOLOR 8 .

DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "&Выход ":L
     size 10 by 1.1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "&Помощь":L
     size 10 by 1
     BGCOLOR 8 .

DEFINE BUTTON b-mark
     LABEL "&*":L
     size 3.63 by 1.1
     BGCOLOR 8 .

DEFINE BUTTON b-print-doc
     LABEL ".   Пе&чать":L
     size 13.50 by 1.1
     BGCOLOR 8 .

DEFINE BUTTON i-print
     IMAGE-UP FILE "cmp/b-print.bmp":U
     IMAGE-DOWN FILE "cmp/b-print.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/b-print.bmp":U
     LABEL ""
     SIZE 4 BY .90.

DEFINE VARIABLE v-printer-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Текущий принтер"
      VIEW-AS TEXT
     SIZE 47 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE rs-price-selection AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Старая и новая цена; процент разницы", 1,
"Учетная и новая цена; процент наценки", 2
     SIZE 41.25 BY 1.67 NO-UNDO.

DEFINE RECTANGLE RECT-1
     edge-chars 0.25 GRAPHIC-EDGE  NO-FILL
     SIZE 64.25 BY 2.13.

DEFINE VARIABLE tg-print-zero AS LOGICAL INITIAL no
     LABEL "С нулевыми"
     VIEW-AS TOGGLE-BOX
     SIZE 16.63 BY .83 NO-UNDO.

DEFINE VARIABLE tg-sort-by-group AS LOGICAL INITIAL no
     LABEL "По группам"
     VIEW-AS TOGGLE-BOX
     SIZE 17.38 BY .83 NO-UNDO.

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
    WITH NO-BOX NO-ROW-MARKERS SEPARATORS SIZE 64 BY 15.46.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit at row 1.08 col 2.13
     b-mark at row 1.08 col 12.13
     b-erase at row 1.08 col 15.88
     b-print-doc at row 1.08 col 29.50
     i-print AT ROW 1.13 COL 30.13 NO-TAB-STOP
     b-help at row 1.08 col 55.63
     BROWSE-2 AT ROW 2.25 COL 1.75
     tg-print-zero AT ROW 18.92 COL 44.88
     rs-price-selection AT ROW 19 COL 2.63 NO-LABEL
     tg-sort-by-group AT ROW 19.83 COL 44.88
     v-printer-name AT ROW 17.96 COL 16.88 COLON-ALIGNED
     RECT-1 AT ROW 18.75 COL 1.63
     SPACE(0.74) SKIP(0.24)
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

ON CHOOSE OF i-print IN FRAME Dialog-Frame
DO:
  APPLY "choose" TO b-print-doc.
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
    if tmp#list.last-use = true
    then do:
        assign
            tmp#list.last-use = false
        .
        display
            "" @ tmp#list.last-use
        with browse {&browse-name}.
    end.
    else do:
        assign
            tmp#list.last-use = true
        .
        display
            "*" @ tmp#list.last-use
        with browse {&browse-name}.
    end.
    apply "VALUE-CHANGED" to {&browse-name} in frame {&frame-name}.
    assign
        g#log = {&browse-name}:select-next-row ()
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print-doc Dialog-Frame
ON CHOOSE OF b-print-doc IN FRAME Dialog-Frame /* Печать */
DO:

    define variable lok as logical no-undo .

    /*rash*/
    define variable         PrintDoc              as      logical no-undo .
    define variable         PrintSet              as      logical no-undo .
    define variable         Print-Round           AS      LOGICAL INITIAL yes no-undo .

    define variable l-recid as recid no-undo .
    /* Ничего не отметили */
    Assign
        v-list_ = ''
        ii      = 0
        l-recid = recid(Tmp#List)
    .
    For each Tmp#List share-lock
    :
        if Tmp#List.last-use <> false
        then Assign
            ii      = ii + 1
            v-list_ = v-list_ + ',' + string(tmp#list.id)
        .
    End.
    if ii = 0 then DO :

        Message "Отметьте формы документа для печати!" view-as alert-box INFORMATION title "Внимание !".
        find first Tmp#List where l-recid = recid(Tmp#List) no-lock  .
        return no-apply.

        End.
{ gbl/getsect.i run v-cntxt-obj-type v-cntxt-obj-code {&attr-prt-obj} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'in-docpr' then in-docprvalue =  thbjattr_thbj-attr.property-value-character .
end.

/* Запомнить параметры */
    find first buf_usr-flt exclusive-lock
         where buf_usr-flt.user-name   = v-cntxt-userid
           and buf_usr-flt.call-point  = substitute( "&1,&2"
                                                , {&h-ov}
                                                , ub.price-doc.status_   )
    no-error .
    if available buf_usr-flt
    then do:
        assign
            buf_usr-flt.type-price  = ( if rs-price-selection = 1 then yes else no )
            buf_usr-flt.type-val    = tg-print-zero
            buf_usr-flt.sort-gr     = tg-sort-by-group
        .
        assign
            buf_usr-flt.list_ = "":U
        .
        for each tmp#list
           where tmp#list.last-use = yes
        :
            assign
                buf_usr-flt.list_  = substitute(  "&1&2&3":U
                                        , buf_usr-flt.list_
                                        , ( if buf_usr-flt.list_ = "":U then "":U else ",":U )
                                        , tmp#list.id
                                    )
            .
        end.
    end.
    else do:
        create  buf_usr-flt .
        assign
            buf_usr-flt.user-name  = v-cntxt-userid
            buf_usr-flt.call-point = substitute( "&1,&2":U
                                            , {&h-ov}
                                            , ub.price-doc.status_   )
            rs-price-selection    = 1
            tg-print-zero         = no
            tg-sort-by-group      = no
        .
        assign
            buf_usr-flt.list_ = "":U
        .
        for each tmp#list
            where tmp#list.last-use = yes
        :
            assign
                buf_usr-flt.list_  = substitute(  "&1&2&3":U
                                        , buf_usr-flt.list_
                                        , ( if buf_usr-flt.list_ = "":U then "":U else ",":U )
                                        , tmp#list.id
                                    )
            .
        end.
    end.
    if g#quest-print = true
    then do:
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
                    , input rs-price-selection
                    , input tg-print-zero
                    , input tg-sort-by-group
                ).
            end.
            when 1
            then do:
                run value (tmp#list.proc-name)  (
                      input p-mainmenu-handle
                    , input rec_id
                    , input tmp#list.proc-param
                    , input rs-price-selection
                    , input tg-print-zero
                    , input tg-sort-by-group
                ).
            end.
            when 2
            then do:
                run value (tmp#list.proc-name)  (
                      input p-mainmenu-handle
                    , input rec_id
                    , input entry(1,tmp#list.proc-param)
                    , input entry(2,tmp#list.proc-param)
                    , input rs-price-selection
                    , input tg-print-zero
                    , input tg-sort-by-group
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

  if  g#quest-print = true  Then do:
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
              case Tmp#list.orient :
                  when 'A4port' then do:
                        DisabledOptions = 4 .
                  end.
                  when 'A4lans' or when "" then do:
                      DisabledOptions = 8 .
                  end.
              End case.
              if Tmp#list.orient <> "HTML":U then 
              run gbl/prnfilen.w
                (input  ""
                ,input  DisabledOptions
                ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
                ,input 7
                ,output v-user-action
                ,output v-printed
                ) .

             End.
      End.
   Else  Message 'Задание распечатано'.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tg-print-zero
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tg-print-zero Dialog-Frame
ON VALUE-CHANGED OF rs-price-selection IN FRAME Dialog-Frame
OR VALUE-CHANGED OF tg-print-zero IN FRAME Dialog-Frame
OR VALUE-CHANGED OF tg-sort-by-group IN FRAME Dialog-Frame
DO:
    assign
        rs-price-selection
        tg-print-zero
        tg-sort-by-group
    .

END.
/* фильтрация временной таблицы  ---------------------------------------------------------------------------------------*/
  For each tmp#list share-lock:
      if lookup(string(tmp#list.id), list_) > 0
      then tmp#list.last-use = true .

      tmp#list.view_ = 1 .
      /* отсекаем по ценам */
/*      if     type-price then assign tmp#list.view_ = tmp#list.view_ * lookup("sale",tmp#list.filtr) .*/
/*      if NOT type-price then assign tmp#list.view_ = tmp#list.view_ * lookup("cost",tmp#list.filtr) .*/
      /* отсекаем по валютам */
/*      if     type-val then assign tmp#list.view_ = tmp#list.view_ * lookup("rubl",tmp#list.filtr) .*/
/*      if NOT type-val then assign tmp#list.view_ = tmp#list.view_ * lookup("base",tmp#list.filtr) .*/

      /* отсекаем по other свойствам документа */
/*      if Tmp#list.blank-name = 'Акт автоматической переоценки'  and   trn-doc.ov = false*/
/*                     then  assign Tmp#list.view_ =  0 .*/
      /* отсекаем по sys-key */
      if sys-key <> {&SuperSysKey} then DO:
          if sys-key <> tmp#list.sys-key  and tmp#list.sys-key <> ''
                     THEN  Assign tmp#list.view_ = 0   tmp#list.last-use = false.
      End.

/*      if     tmp#list.view_ = 0  then     tmp#list.last-use = false  .*/
      if     tmp#list.proc-name = '' Then  Assign tmp#list.view_ = 0   tmp#list.last-use = false.

  End.

  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
  apply "VALUE-CHANGED" TO {&BROWSE-name} IN FRAME {&frame-name}.
  apply "entry" TO {&BROWSE-name} IN FRAME {&frame-name}.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-2
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
{ gbl/app_help.i }
    { gbl/getcntxt.i get " " p-mainmenu-handle }
find first ub.price-doc where recid(ub.price-doc) = rec_id no-lock.

IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
  v-printer-name = session:printer-name.
run load-menu (ub.price-doc.doc-num,  '*', ub.price-doc.status_, '*', '*').
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    run get-report-num in p-mainmenu-handle (
        output g#report-num
    ).
    run get-quest-print in p-mainmenu-handle (
        output g#quest-print
    ).
  RUN enable_UI.
  Tmp#List.last-use      :read-only in browse {&BROWSE-NAME} =  true .
    ASSIGN frame {&frame-name}:TITLE =  "Печать переоценки  "
  + " Статус: " + ub.price-doc.status_
  + "  № "  + ub.price-doc.doc-num.

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
  DISPLAY tg-print-zero rs-price-selection tg-sort-by-group v-printer-name
      WITH FRAME Dialog-Frame.
  ENABLE RECT-1 b-exit b-mark b-erase b-print-doc b-help BROWSE-2 tg-print-zero i-print
         rs-price-selection tg-sort-by-group v-printer-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Load-menu Dialog-Frame
PROCEDURE Load-menu :
/* Создание меню - Список форм по документу документов */
define input parameter p-doc-num as character        no-undo.
define input parameter xtype     as character        no-undo.
define input parameter xstatus   as character        no-undo.
define input parameter xInternal as character        no-undo.
define input parameter xflag     as character        no-undo.

  { gbl/currsysk.i
    v-menu-doc-sys-key
    no-error
  }

    assign
        v-menu-doc-doc-code = p-doc-num
        v-menu-doc-doc-type = xtype
        v-menu-doc-status_  = xstatus
        v-menu-doc-internal = xInternal
        v-menu-doc-flag     = xflag
        sys-key             = v-menu-doc-sys-key
    .
    { rep/pr-dprn.i }
/*                                                            message*/
/*                                                            Tmp#list.id*/
/*                                                      skip  Tmp#list.cli-code*/
/*                                                      skip  Tmp#list.blank-name*/
/*                                                      skip  Tmp#list.filtr*/
/*                                                      skip  Tmp#list.proc-name*/
/*                                                      skip  Tmp#list.proc-param*/
/*                                                      skip  Tmp#list.sys-key*/
/*                                                      skip  Tmp#list.orient*/
/*                                                            view-as alert-box.*/
/* загрузить значения из buf_usr-flt       */
    find first buf_usr-flt exclusive-lock
         where buf_usr-flt.user-name   = v-cntxt-userid
           and buf_usr-flt.call-point  = substitute( "&1,&2":U
                                                , {&h-ov}
                                                , ub.price-doc.status_   )
    no-error .
    if available buf_usr-flt
    then do:
        assign
            v-list_               = buf_usr-flt.list_
            rs-price-selection    = (if buf_usr-flt.type-price =  yes then 1 else 2)
            tg-print-zero         = buf_usr-flt.type-val
            tg-sort-by-group      = buf_usr-flt.sort-gr
        .
    end.
    else do:
        create  buf_usr-flt .
        assign
            buf_usr-flt.user-name  = v-cntxt-userid
            buf_usr-flt.call-point = substitute( "&1,&2":U
                                            , {&h-ov}
                                            , ub.price-doc.status_   )
            rs-price-selection    = 1
            tg-print-zero         = no
            tg-sort-by-group      = no
        .
        assign
            buf_usr-flt.list_ = "":U
        .
        for each tmp#list
            where tmp#list.last-use = yes
        :
            assign
                buf_usr-flt.list_  = substitute(  "&1&2&3":U
                                        , buf_usr-flt.list_
                                        , ( if buf_usr-flt.list_ = "":U then "":U else ",":U )
                                        , tmp#list.id
                                    )
            .
        end.
    end.
/* фильтрация временной таблицы  ---------------------------------------------------------------------------------------*/
  For each tmp#list share-lock
  :
      if lookup( string( tmp#list.id ), v-list_ ) > 0
      then tmp#list.last-use = true .

      tmp#list.view_ = 1 .

      /* отсекаем по sys-key */
      if sys-key <> {&SuperSysKey} then DO:
          if sys-key <> tmp#list.sys-key  and tmp#list.sys-key <> ''
                     THEN  Assign tmp#list.view_ = 0   tmp#list.last-use = false.
      End.

      if     tmp#list.proc-name = '' Then  Assign tmp#list.view_ = 0   tmp#list.last-use = false.

  End.



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME