&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS B-table-Win
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список колонок и определение ширины страницы

Автор: Чернова Светлана Александровна
Дата создания: 08/23/01
Author: Svetlana Chernova
Creation date: 08/23/01

no_app_help.i
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
define variable vss-description as character no-undo init "Список колонок и определение ширины страницы".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/r-page1.i  }
{ cmp/showinf.i  }
DEFINE TEMP-TABLE List-field NO-UNDO
       field id as int
       field naim as char
       field use as log
       field make-correct as log
       field w-col as int
       .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME F-Main
&Scoped-define BROWSE-NAME br_table

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES List-field

/* Define KEY-PHRASE in case it is used by any query. */
&Scoped-define KEY-PHRASE TRUE

/* Definitions for BROWSE br_table                                      */
&Scoped-define FIELDS-IN-QUERY-br_table List-field.use List-field.Naim List-field.w-col /*
&Scoped-define ENABLED-FIELDS-IN-QUERY-br_table List-field.Naim List-field.w-col */
&Scoped-define ENABLED-TABLES-IN-QUERY-br_table List-field
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br_table List-field
&Scoped-define SELF-NAME br_table
&Scoped-define QUERY-STRING-br_table FOR EACH List-field WHERE ~{&KEY-PHRASE} NO-LOCK     ~{&SORTBY-PHRASE}
&Scoped-define OPEN-QUERY-br_table OPEN QUERY {&SELF-NAME} FOR EACH List-field WHERE ~{&KEY-PHRASE} NO-LOCK     ~{&SORTBY-PHRASE}.
&Scoped-define TABLES-IN-QUERY-br_table List-field
&Scoped-define FIRST-TABLE-IN-QUERY-br_table List-field


/* Definitions for FRAME F-Main                                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-F-Main ~
    ~{&OPEN-QUERY-br_table}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS br_table B-mark RECT-1 B-demark b-mark-2 ~
w-all w-all-1
&Scoped-Define DISPLAYED-OBJECTS w-all w-all-1

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Foreign Keys" B-table-Win _INLINE
/* Actions: ? adm/support/keyedit.w ? ? ? */
/* STRUCTURED-DATA
<KEY-OBJECT>
&BROWSE-NAME
</KEY-OBJECT>
<FOREIGN-KEYS>
</FOREIGN-KEYS>
<EXECUTING-CODE>
**************************
* Set attributes related to FOREIGN KEYS
*/
RUN set-attribute-list (
    'Keys-Accepted = "",
     Keys-Supplied = ""':U).
/**************************
</EXECUTING-CODE> */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Advanced Query Options" B-table-Win _INLINE
/* Actions: ? adm/support/advqedit.w ? ? ? */
/* STRUCTURED-DATA
<KEY-OBJECT>
&BROWSE-NAME
</KEY-OBJECT>
<SORTBY-OPTIONS>
</SORTBY-OPTIONS>
<SORTBY-RUN-CODE>
************************
* Set attributes related to SORTBY-OPTIONS */
RUN set-attribute-list (
    'SortBy-Options = ""':U).
/************************
</SORTBY-RUN-CODE>
<FILTER-ATTRIBUTES>
</FILTER-ATTRIBUTES> */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-demark
     LABEL "-"
     SIZE 3 BY 1 TOOLTIP "Снять все отметки".

DEFINE BUTTON B-mark
     LABEL "+"
     SIZE 3 BY 1 TOOLTIP "Отметить все колонки для печати".

DEFINE BUTTON b-mark-2
     LABEL "+-":L
     SIZE 3 BY 1 TOOLTIP "Отметить текущее поле для печати"
     BGCOLOR 8 .

DEFINE VARIABLE w-all AS INTEGER FORMAT ">>>":R3 INITIAL 0
     LABEL "Итого ширина отчета"
      VIEW-AS TEXT
     SIZE 4.38 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE w-all-1 AS INTEGER FORMAT ">>>":R3 INITIAL 0
      VIEW-AS TEXT
     SIZE 4.25 BY .67 TOOLTIP "Ширина отчета со всеми колонками"
     FGCOLOR 1  NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 1 GRAPHIC-EDGE
     SIZE 30.13 BY .08
     BGCOLOR 0 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br_table FOR
      List-field SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br_table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br_table B-table-Win _FREEFORM
  QUERY br_table NO-LOCK DISPLAY
      List-field.use COLUMN-LABEL "П" FORMAT "+/" LABEL-FGCOLOR 4
      List-field.Naim COLUMN-LABEL "Наименование":C43 FORMAT "X(43)" LABEL-FGCOLOR 4
      List-field.w-col COLUMN-LABEL "Ширина" FORMAT ">>>" LABEL-FGCOLOR 4
/*          Enable  List-field.Naim List-field.w-col */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ASSIGN SEPARATORS SIZE 56 BY 15.83
         BGCOLOR 15 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     br_table AT ROW 1 COL 1
     B-mark AT ROW 1.08 COL 57.38
     B-demark AT ROW 2.08 COL 57.38
     b-mark-2 AT ROW 3.08 COL 57.38
     w-all AT ROW 17.5 COL 55.01 RIGHT-ALIGNED
     w-all-1 AT ROW 17.5 COL 59.38 RIGHT-ALIGNED NO-LABEL
     RECT-1 AT ROW 17 COL 30
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1 SCROLLABLE
         BGCOLOR 8 FGCOLOR 0 .


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   Allow: Basic,Browse
   Frames: 1
   Add Fields to: External-Tables
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB)
  CREATE WINDOW B-table-Win ASSIGN
         HEIGHT             = 17.29
         WIDTH              = 59.38.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB B-table-Win
/* ************************* Included-Libraries *********************** */

{src/adm/method/browser.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW B-table-Win
  NOT-VISIBLE,,RUN-PERSISTENT                                           */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE Size-to-Fit                                              */
/* BROWSE-TAB br_table 1 F-Main */
ASSIGN
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

ASSIGN
       B-demark:HIDDEN IN FRAME F-Main           = TRUE.

ASSIGN
       B-mark:HIDDEN IN FRAME F-Main           = TRUE.

ASSIGN
       b-mark-2:HIDDEN IN FRAME F-Main           = TRUE.

ASSIGN
       br_table:HIDDEN  IN FRAME F-Main                = TRUE.

ASSIGN
       RECT-1:HIDDEN IN FRAME F-Main           = TRUE.

/* SETTINGS FOR FILL-IN w-all IN FRAME F-Main
   ALIGN-R                                                              */
ASSIGN
       w-all:HIDDEN IN FRAME F-Main           = TRUE.

/* SETTINGS FOR FILL-IN w-all-1 IN FRAME F-Main
   ALIGN-R                                                              */
ASSIGN
       w-all-1:HIDDEN IN FRAME F-Main           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br_table
/* Query rebuild information for BROWSE br_table
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH List-field WHERE ~{&KEY-PHRASE} NO-LOCK
    ~{&SORTBY-PHRASE}.
     _END_FREEFORM
     _Options          = "NO-LOCK KEY-PHRASE SORTBY-PHRASE"
     _Query            is OPENED
*/  /* BROWSE br_table */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME B-demark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-demark B-table-Win
ON CHOOSE OF B-demark IN FRAME F-Main /* - */
DO:
  For each List-field :
      If List-field.make-correct = true then List-field.use = false.
  End.
  apply "VALUE-CHANGED" to {&browse-name} in frame {&frame-name}.
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
     {&OPEN-BROWSERS-IN-QUERY-F-Main}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark B-table-Win
ON CHOOSE OF B-mark IN FRAME F-Main /* + */
DO:
  For each List-field  :
    If List-field.make-correct = true then  List-field.use = true.
  End.
  apply "VALUE-CHANGED" to {&browse-name} in frame {&frame-name}.
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
     {&OPEN-BROWSERS-IN-QUERY-F-Main}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark-2 B-table-Win
ON CHOOSE OF b-mark-2 IN FRAME F-Main /* +- */
OR MOUSE-SELECT-DBLCLICK OF {&BROWSE-name} IN FRAME {&frame-name}
DO:

define variable v-log as logical   no-undo .

find current List-field no-error.
  if not available List-field then do:
     message "Неправильный выбор строки.".
     return no-apply.
  end.
  If List-field.make-correct = true then DO:
    IF    List-field.use = true THEN DO:
          List-field.use = false.
          disp "" @ List-field.use with browse {&browse-name} no-error .
      End.
      Else DO:
           List-field.use = true.
           disp "+" @ List-field.use with browse {&browse-name} no-error .
      End.
   End.
     apply "VALUE-CHANGED" to {&browse-name} in frame {&frame-name}.
     v-log = {&browse-name}:select-next-row () no-error .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br_table
&Scoped-define SELF-NAME br_table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br_table B-table-Win
ON ROW-DISPLAY OF br_table IN FRAME F-Main
DO:
  if not list-field.make-correct  then
       assign
         list-field.naim  :bgcolor in browse {&browse-name} = 8
         list-field.use   :bgcolor in browse {&browse-name} = 8
         list-field.w-col :bgcolor in browse {&browse-name} = 8
         .
        Else
       assign
         list-field.naim  :bgcolor in browse {&browse-name} = ?
         list-field.use   :bgcolor in browse {&browse-name} = ?
         list-field.w-col :bgcolor in browse {&browse-name} = ?
         .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br_table B-table-Win
ON ROW-ENTRY OF br_table IN FRAME F-Main
DO:
  /* This code displays initial values for newly added or copied rows. */
  {src/adm/template/brsentry.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br_table B-table-Win
ON ROW-LEAVE OF br_table IN FRAME F-Main
DO:
    /* Do not disable this code or no updates will take place except
     by pressing the Save button on an Update SmartPanel. */
   {src/adm/template/brsleave.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br_table B-table-Win
ON VALUE-CHANGED OF br_table IN FRAME F-Main
DO:
  {src/adm/template/brschnge.i}

  w-all = 0.
  for each List-field no-lock :
      if List-field.use then
       assign
         w-all = w-all + List-field.w-col
         w-all = w-all + 1.  /* палочка */
  End.

  if w-all > 0 Then DO:
      display w-all  with frame {&frame-name}.

      RUN get-attribute IN THIS-PROCEDURE ('UIB-MODE').
      IF  RETURN-VALUE NE "DESIGN" THEN DO:
          define variable source-str as character.
          define variable state-source as handle .
          run get-link-handle IN adm-broker-hdl ( THIS-PROCEDURE, 'State':U , OUTPUT source-str ) no-error.
          State-source = WIDGET-HANDLE ( source-str ).
          IF VALID-HANDLE ( State-source ) THEN do :
             run view-how-name in State-source (input w-all) no-error.
             End.
      END.
  End.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK B-table-Win


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }

&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF


  run load-table in this-procedure   .
  Assign w-all-1 = 0 w-all = 0.
  for each List-field no-lock :
      w-all-1 = w-all-1 + List-field.w-col.
      if List-field.use then
         assign
           w-all   = w-all + List-field.w-col
           w-all-1 = w-all-1 + 1
           w-all   = w-all + 1.  /* палочка */
  End.
  display w-all  w-all-1 with frame {&frame-name} .

  if can-find (first  List-field no-lock) then DO :
     display br_table B-demark B-mark b-mark-2 rect-1 w-all w-all-1
             with frame {&frame-name}.
     End.
     {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
     {&OPEN-BROWSERS-IN-QUERY-F-Main}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available B-table-Win  _ADM-ROW-AVAILABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI B-table-Win  _DEFAULT-DISABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-apply-layout B-table-Win
PROCEDURE local-apply-layout :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'apply-layout':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
  /* run load-table .*/


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-create-record B-table-Win
PROCEDURE local-create-record :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'create-record':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize B-table-Win
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .


END PROCEDURE.


procedure load-table :

define variable ki as integer no-undo .
define variable kj as integer no-undo .
define variable qnty-col as integer no-undo .
define variable qnty-row as integer no-undo .
define variable l-name-field as character no-undo .

for each list-field  :
   delete  list-field no-error .
end.


qnty-col = MINIMUM(num-entries(entry (1,Sheetf.Excel-Column-Lable,CHR(10))),num-entries(Sheetf.sizes)).
qnty-row = num-entries(Sheetf.Excel-Column-Lable,CHR(10)).
repeat ki = 1 to qnty-col :
    l-name-field = '' .
    Repeat kj = 1 to  qnty-row :
      l-name-field = l-name-field  +
        if entry(ki, (entry(kJ,Sheetf.Excel-Column-Lable,CHR(10)))) = ""
          Then  fill(" ",10) + (if (kj <> qnty-row)  then  "/"   else " ")
          Else entry(ki, (entry(kJ,Sheetf.Excel-Column-Lable,CHR(10)))) +
            if (kj <> qnty-row)  then  "/"   else " ".
    End.
    if NOT(trim(l-name-field) = "" OR trim(l-name-field) = "/") THEN DO: /*не пустое название*/
        create List-field.
          Repeat kj = 1 to  qnty-row :
            List-field.naim = List-field.naim +
              if entry(ki, (entry(kJ,Sheetf.Excel-Column-Lable,CHR(10)))) = ""
                Then  fill(" ",10) + (if (kj <> qnty-row)  then  "/"   else " ")
                Else entry(ki, (entry(kJ,Sheetf.Excel-Column-Lable,CHR(10)))) +
                  if (kj <> qnty-row)  then  "/"   else " ".

           End.
     if num-entries(Sheetf.make-correct) = qnty-col then DO:
       List-field.make-correct = if entry(ki ,Sheetf.make-correct) = "false":U  or  entry(ki,Sheetf.make-correct) = ""
                                    then false  else true .
       end.
       else do:
             List-field.make-correct = false  .
             end.

       List-field.w-col = integer(entry(ki ,Sheetf.sizes)) no-error  .
       List-field.use = use-column[ki] .
       if List-field.make-correct = false then  List-field.use = true  .
    End.
    /*проверка на права */

    if num-entries(Sheetf.Rights-column) = qnty-col then DO :
       if trim(entry(ki ,Sheetf.Rights-column)) = "false":U  then
       assign
           List-field.make-correct = false
           List-field.use = false .
    End.
end.

 if not can-find ( first   List-field where           List-field.make-correct = true  ) then do:
    /* Если не найдено ни одно поле для корректировки то таблицу показывать не будем */
    for each list-field  :
      delete  list-field no-error .
    end.
 end.

end  procedure.

procedure read-table :
define variable s-i as integer no-undo .
define variable s-t as character no-undo .
define buffer buf_usr-flt for ubflt.usr-flt  .
For each  List-field no-lock :
    s-i = s-i + 1.
    Use-Column[s-i]  = List-field.use.
    s-t =  s-t + string(list-field.use , "true/false")  + ";".
End.

 find first buf_usr-flt exclusive-lock where
            buf_usr-flt.user-name = g#userid and
            buf_usr-flt.call-point   = ReportProc  no-error .
     if not available  buf_usr-flt then  create buf_usr-flt.
       Assign
         buf_usr-flt.user-name = g#userid
         buf_usr-flt.call-point   = ReportProc
         buf_usr-flt.list_ = buf_usr-flt.list_ + "," + string( "Use-column=" + s-t ) + ","
         .

end  procedure.


PROCEDURE op-br :
   run read-table in this-procedure .
   run load-table in this-procedure .
     {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
     {&OPEN-BROWSERS-IN-QUERY-F-Main}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records B-table-Win  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.               */
  {src/adm/template/snd-head.i}

  /* For each requested table, put it's ROWID in the output list.      */
  {src/adm/template/snd-list.i "List-field"}

  /* Deal with any unexpected table requests before closing.           */
  {src/adm/template/snd-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed B-table-Win
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.

  CASE p-state:
      /* Object instance CASEs can go here to replace standard behavior
         or add new cases. */
      {src/adm/template/bstates.i}
  END CASE.
  Apply "VALUE-CHANGED" to {&browse-name} in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME