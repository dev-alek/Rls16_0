
&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME DIALOG-1

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_Filter FOR ubflt.filter.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS DIALOG-1
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Выбор фильтра

Автор: Хныкин Павел Андреевич
Дата создания: 04/13/06
Author: Pavel Khnykin
Creation date: 04/13/06

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc  as widget-handle no-undo.
define input parameter c-point        as character no-undo .
/*может быть составным параметром - список с разделителями {&delim-par} */
/*
entry 1 - собственно  c-point
entry 2 - если есть  имя которое будет появляться в title окна вместо c-point
entry 3  - если есть - разрешена или нет сортировка для фильтров данного c-point
*/
define input parameter tbl            as character no-undo .
define input parameter buf            as character no-undo .
define input parameter fld            as character no-undo .
define input parameter lab            as character no-undo .
define input parameter spr            as character no-undo .
define input parameter dim            as character no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Выбор фильтра".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7|&8':u,parparentproc,c-point,tbl,buf,fld,lab,spr,dim)" }
{ cmp/str-glbl.i        }
{ cmp/showinf.i         }
{ cmp/library.i         }
{ gbl/flt-shar.i        }
{ gbl/flt-def.i no-vars }
/* { gbl/getcntxt.i def    } ЗДЕСЬ НЕЛЬЗЯ ВЫЗЫВАТЬ ПРОЦЕДУРУ getcntxt Т.К. ФИЛЬТРЫ ДОЛЖНЫ РАБОТАТЬ И БЕЗ ТЕКУЩЕГО ОБЪЕКТА */


DEFINE VARIABLE kl AS INTEGER INITIAL 0.
define variable MethodReturn AS LOGICAL.

define variable ID AS RECID.
define variable IDENT AS RECID.

define variable ii as integer no-undo.
define variable jj as integer no-undo.
define variable rec as recid no-undo.
define variable p-enable-sorting as logical no-undo init yes.
define variable p-c-point-name   as character no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-cntxt-userid as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME DIALOG-1
&Scoped-define BROWSE-NAME br-filter

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_Filter

/* Definitions for BROWSE br-filter                                     */
&Scoped-define FIELDS-IN-QUERY-br-filter X_Filter.Naim
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-filter
&Scoped-define QUERY-STRING-br-filter FOR EACH X_Filter ~
      WHERE X_Filter.call-point = c-point NO-LOCK
&Scoped-define OPEN-QUERY-br-filter OPEN QUERY br-filter FOR EACH X_Filter ~
      WHERE X_Filter.call-point = c-point NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-filter X_Filter
&Scoped-define FIRST-TABLE-IN-QUERY-br-filter X_Filter


/* Definitions for DIALOG-BOX DIALOG-1                                  */
&Scoped-define OPEN-BROWSERS-IN-QUERY-DIALOG-1 ~
    ~{&OPEN-QUERY-br-filter}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-Cancel b-OK b-exit b-add b-update b-del ~
b-help br-filter E-fields E-sorting
&Scoped-Define DISPLAYED-OBJECTS flt-name E-fields E-sorting

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 10 BY 1 TOOLTIP "Добавить новый фильтр".

DEFINE BUTTON b-Cancel AUTO-END-KEY DEFAULT
     LABEL "&Выход "
     SIZE 10 BY 1 TOOLTIP "Выход без изменений"
     BGCOLOR 8 .

DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 10 BY 1 TOOLTIP "Удалить ранее существующий фильтр".

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Снять":L
     SIZE 10 BY 1 TOOLTIP "Отменить действие установок фильтра".

DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь":L
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-OK AUTO-GO DEFAULT
     LABEL "&Применить":L
     SIZE 10 BY 1 TOOLTIP "Применить установки выбранного фильтра"
     BGCOLOR 8 .

DEFINE BUTTON b-update
     LABEL "&Изменить":L
     SIZE 10 BY 1 TOOLTIP "Изменить установки выбранного фильтра".

DEFINE VARIABLE E-fields AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 36.5 BY 4 NO-UNDO.

DEFINE VARIABLE E-sorting AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 36.5 BY 4.17 NO-UNDO.

DEFINE VARIABLE flt-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 73 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-filter FOR
      X_Filter SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-filter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-filter DIALOG-1 _STRUCTURED
  QUERY br-filter NO-LOCK DISPLAY
      X_Filter.Naim FORMAT "X(255)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SIZE 35 BY 9.25.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DIALOG-1
     b-Cancel AT ROW 1 COL 1
     b-OK AT ROW 1 COL 11
     b-exit AT ROW 1 COL 21
     b-add AT ROW 1 COL 31
     b-update AT ROW 1 COL 41
     b-del AT ROW 1 COL 51
     b-help AT ROW 1 COL 61
     flt-name AT ROW 2.25 COL 1.5 NO-LABEL
     br-filter AT ROW 4.33 COL 1.5
     E-fields AT ROW 4.33 COL 38 NO-LABEL
     E-sorting AT ROW 9.33 COL 38 NO-LABEL
     "Список фильтров" VIEW-AS TEXT
          SIZE 35 BY .67 AT ROW 3.5 COL 1.5
          BGCOLOR 1 FGCOLOR 15
     "Критерий выбора" VIEW-AS TEXT
          SIZE 36.5 BY .67 AT ROW 3.5 COL 38
          BGCOLOR 1 FGCOLOR 15
     "Сортировка" VIEW-AS TEXT
          SIZE 36.5 BY .67 AT ROW 8.58 COL 38
          BGCOLOR 1 FGCOLOR 15
     SPACE(0.74) SKIP(4.91)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Ф И Л Ь Т Р Ы":L
         DEFAULT-BUTTON b-OK CANCEL-BUTTON b-Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Temp-Tables and Buffers:
      TABLE: X_Filter B "?" ? ub ubflt.filter
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX DIALOG-1
                                                                        */
/* BROWSE-TAB br-filter flt-name DIALOG-1 */
ASSIGN
       FRAME DIALOG-1:SCROLLABLE       = FALSE.

/* SETTINGS FOR BUTTON b-add IN FRAME DIALOG-1
   NO-DISPLAY                                                           */
/* SETTINGS FOR BUTTON b-del IN FRAME DIALOG-1
   NO-DISPLAY                                                           */
/* SETTINGS FOR BUTTON b-exit IN FRAME DIALOG-1
   NO-DISPLAY                                                           */
/* SETTINGS FOR BUTTON b-update IN FRAME DIALOG-1
   NO-DISPLAY                                                           */
ASSIGN
       E-fields:READ-ONLY IN FRAME DIALOG-1        = TRUE.

ASSIGN
       E-sorting:READ-ONLY IN FRAME DIALOG-1        = TRUE.

/* SETTINGS FOR FILL-IN flt-name IN FRAME DIALOG-1
   NO-ENABLE ALIGN-L                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-filter
/* Query rebuild information for BROWSE br-filter
     _TblList          = "X_Filter"
     _Options          = "NO-LOCK"
     _Where[1]         = "X_Filter.call-point = c-point"
     _FldNameList[1]   = Temp-Tables.X_Filter.Naim
     _Query            is OPENED
*/  /* BROWSE br-filter */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add DIALOG-1
ON CHOOSE OF b-add IN FRAME DIALOG-1 /* Добавить */
DO:
  define variable v-naim            like ubflt.filter.naim no-undo .
  define variable v-where-ysl       as character no-undo .
  define variable v-where-ysl-rus   as character no-undo .
  define variable v-fields-sort     as character no-undo .
  define variable v-fields-sort-rus as character no-undo .
  define variable p-lst-cend        as character no-undo .

  assign
    Kl = 0
  .
  run gbl/updf.w  (
                input parParentProc
              , input c-point
              , input-output v-naim
              , input yes  /*save-in-filter*/
              , input p-enable-sorting  /*enable-sorting*/
              , input yes  /*save-to-file*/
              , input yes  /*enable-name-changeing*/
              , input Tbl
              , input Buf
              , input Fld
              , input Lab
              , input Spr
              , input Dim
              , input-output v-where-ysl
              , input-output v-where-ysl-rus
              , input-output v-fields-sort
              , input-output v-fields-sort-rus
              , input-output p-lst-cend
              , input Kl
              , output ID).
  IF ID = ? THEN DO :
    assign
      ID = IDENT
    .
  END.
  RUN enable_UI.
  REPOSITION br-filter TO RECID ID no-error.

  APPLY "value-changed" TO br-filter.
  apply "entry" to br-filter.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-Cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-Cancel DIALOG-1
ON CHOOSE OF b-Cancel IN FRAME DIALOG-1 /* Выход  */
DO:
     assign flt-rec = ?.
     return {&flt-undo-value}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del DIALOG-1
ON CHOOSE OF b-del IN FRAME DIALOG-1 /* Удалить */
do:
define variable flt-rec-del as recid no-undo .
define buffer buf_filter for ubflt.filter.
do on stop  undo, return:
  if available X_filter then do:
     flt-name = "".
     e-fields = "".
     e-sorting = "".
     flt-rec-del = recid(X_filter).
     get prev br-filter.
     if not available X_filter then do:
        get first br-filter.
        get next br-filter.
        end.
     flt-rec = recid(X_filter).
     FIND FIRST buf_filter WHERE recid(buf_filter) = flt-rec-del EXCLUSIVE-LOCK NO-ERROR.
     DELETE buf_filter.
     find X_filter where recid(X_filter) = flt-rec no-lock no-error.
     RUN enable_UI.
     REPOSITION br-filter TO RECID flt-rec no-error.
     APPLY "value-changed" TO br-filter.
     apply "entry" to br-filter.
     END.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit DIALOG-1
ON CHOOSE OF b-exit IN FRAME DIALOG-1 /* Снять */
DO:
   flt-rec = ?.
   find ubflt.usr-flt where ubflt.usr-flt.user-name = v-cntxt-userid
                        and ubflt.usr-flt.call-point = X_filter.call-point
                        no-error.
   if available ubflt.usr-flt then delete ubflt.usr-flt.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-OK DIALOG-1
ON CHOOSE OF b-OK IN FRAME DIALOG-1 /* Применить */
DO:
if available X_filter  then do:
   flt-rec = recid(X_filter).
   { gbl/flt-put.i X_}
   find ubflt.usr-flt where ubflt.usr-flt.user-name = v-cntxt-userid
                        and ubflt.usr-flt.call-point = X_filter.call-point
                        no-error.
   if not available ubflt.usr-flt then create ubflt.usr-flt.
   ubflt.usr-flt.user-name = v-cntxt-userid.
   ubflt.usr-flt.call-point    = X_filter.call-point.
   ubflt.usr-flt.naim = X_filter.naim.
   end.
else flt-rec = ?.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-update
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-update DIALOG-1
ON CHOOSE OF b-update IN FRAME DIALOG-1 /* Изменить */
DO:
  define variable v-naim            like ubflt.filter.naim no-undo .
  define variable v-where-ysl       as character no-undo .
  define variable v-where-ysl-rus   as character no-undo .
  define variable v-fields-sort     as character no-undo .
  define variable v-fields-sort-rus as character no-undo .
  define variable p-lst-cend        as character no-undo .

  define buffer buf_filter for ubflt.filter.

  FIND FIRST buf_filter WHERE buf_filter.Num-flt = Kl EXCLUSIVE-LOCK NO-ERROR no-wait.
  IF AVAILABLE(buf_filter) THEN DO:
    assign
      Kl = buf_filter.Num-flt
    .
    run gbl/updf.w  (
                  input parParentProc
                , input c-point
                , input-output v-naim
                , input yes  /*save-in-filter*/
                , input p-enable-sorting  /*enable-sorting*/
                , input yes  /*save-to-file*/
                , input yes  /*enable-name-changeing*/
                , input Tbl
                , input Buf
                , input Fld
                , input Lab
                , input Spr
                , input Dim
                , input-output v-where-ysl
                , input-output v-where-ysl-rus
                , input-output v-fields-sort
                , input-output v-fields-sort-rus
                , input-output p-lst-cend
                , input Kl
                , output ID).
     IF ID = ? THEN ID = IDENT.
     RUN enable_UI.
     REPOSITION br-filter TO RECID ID no-error.
     APPLY "value-changed" TO br-filter.
     apply "entry" to br-filter.
     END.
   else
     if locked buf_filter then
        message 'Фильтр в данный момент корректируется другим пользователем'.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-filter
&Scoped-define SELF-NAME br-filter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-filter DIALOG-1
ON MOUSE-SELECT-DBLCLICK OF br-filter IN FRAME DIALOG-1
DO:
apply "choose" to  b-ok.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-filter DIALOG-1
ON RETURN OF br-filter IN FRAME DIALOG-1
DO:
apply "choose" to  b-ok.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-filter DIALOG-1
ON VALUE-CHANGED OF br-filter IN FRAME DIALOG-1
DO:
  IF AVAILABLE(X_filter) THEN DO:
    flt-rec = recid(X_filter).
    flt-name = X_filter.naim.
    Kl = X_filter.Num-flt.
    assign
      e-fields:screen-value = ""
      e-sorting:screen-value = "".
    assign e-fields
                e-sorting.
    do ii = 1 to num-entries(X_filter.where-ysl-rus):
         MethodReturn = e-fields:insert-string(entry(ii ,X_filter.Where-ysl-rus) + chr(13)).
         assign e-fields.
    end.
    if p-enable-sorting then do:
      do ii = 1 to num-entries(X_filter.fields-sort-rus):
          MethodReturn = e-sorting:insert-string(entry(ii ,X_filter.fields-sort-rus) +
                                      (if entry(ii, X_filter.lst-cend) = '0' then "   (возр.)" else "  (убыв.)")
                                    + chr(13)).
          assign e-sorting.
      end.
    end.
    IDENT = RECID(X_filter).
    DISPLAY flt-name e-fields e-sorting WITH FRAME {&FRAME-NAME}.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK DIALOG-1


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

{ gbl/brwrepos.i
&line-num=3
}

{ gbl/brwrefre.i " v-doc-rec = recid(ubflt.filter). ~{&OPEN-QUERY-br-filter~} Reposition br-filter to recid v-doc-rec no-error . ~
               APPLY 'ENTRY' to br-filter. APPLY 'value-changed' TO br-filter. " }

{ gbl/hot-key.i b-add }
&scop b-ok ~{&b-sel~}
&scop b-update ~{&b-chg~}
{ gbl/hot-key.i b-update }
{ gbl/hot-key.i b-del }
{ gbl/hot-key.i b-ok }
&scop b-cancel ~{&b-exit~}
{ gbl/hot-key.i b-cancel }

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

run check-input-parameters in this-procedure
  no-error .
if error-status :error
then do:
  undo, return error return-value .
end.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
on end-error, stop of frame {&frame-name} do:
     assign flt-rec = ?.
     return {&flt-undo-value}.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  /* ЗДЕСЬ НЕЛЬЗЯ ВЫЗЫВАТЬ ПРОЦЕДУРУ getcntxt Т.К. ФИЛЬТРЫ ДОЛЖНЫ РАБОТАТЬ И БЕЗ ТЕКУЩЕГО ОБЪЕКТА */
  run get-userid in parparentproc
    ( output v-cntxt-userid
    ) .
  p-enable-sorting = yes.
  if num-entries(c-point, {&delim-par}) > 2 then do:
    p-enable-sorting = logical(entry(3, c-point, {&delim-par})).
  end.
  p-c-point-name = c-point.
  if num-entries(c-point, {&delim-par}) > 1 then do:
    assign
    p-c-point-name = entry(2, c-point, {&delim-par})
    c-point        = entry(1, c-point, {&delim-par})
    .
  end.
  assign frame {&frame-name}:title = "Ф И Л Ь T Р Ы   (" + p-c-point-name + ")".
  RUN enable_UI.
  reposition br-filter to recid flt-rec no-error.
  apply "value-changed" to br-filter in frame {&frame-name}.
  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus br-filter.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-input-parameters DIALOG-1
PROCEDURE check-input-parameters :

/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  if Fld = ""
  or Fld = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не задан список полей" skip
      view-as alert-box error .
    undo, return error "не задан список полей" .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI DIALOG-1  _DEFAULT-DISABLE
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
  HIDE FRAME DIALOG-1.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI DIALOG-1  _DEFAULT-ENABLE
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
  DISPLAY flt-name E-fields E-sorting
      WITH FRAME DIALOG-1.
  ENABLE b-Cancel b-OK b-exit b-add b-update b-del b-help br-filter E-fields
         E-sorting
      WITH FRAME DIALOG-1.
  {&OPEN-BROWSERS-IN-QUERY-DIALOG-1}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME