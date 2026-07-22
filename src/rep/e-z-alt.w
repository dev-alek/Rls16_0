&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS s-object
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сравнить объекты (с учетом признаков)

Автор: Чернова Светлана Александровна
Дата создания: 06/08/01
Author: Svetlana Chernova
Creation date: 06/08/01

Created:

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сравнить объекты (с учетом признаков)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }
{ gbl/cur-time.i }
{ gbl/userobjs.i }

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

define variable State-source as  WIDGET-HANDLE.

define variable    str-obj# as char no-undo.
define variable    str-obj2# as char no-undo.
define variable    str-obj3# as char no-undo.
define variable    rec-list as char no-undo.
define variable    temp-param-obj-type as char no-undo.
define variable    temp-param-obj as char no-undo.
def buffer cli-obj  for ub.clients .
define variable  ii             AS INTEGER no-undo.


def new shared temp-table alt-obj-list  NO-UNDO
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartViewer
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-12 RECT-3 Classify SelectObject ~
BUTTON-obj Itog show-zero show-qnty Rs-qnty-type SortType TEXT-3-alt ~
Obj-count
&Scoped-Define DISPLAYED-OBJECTS Classify SelectObject Itog show-zero ~
show-qnty Rs-qnty-type SortType TEXT-3-alt Obj-count

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON BUTTON-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "BUTTON-obj"
     SIZE 3 BY .88.

DEFINE VARIABLE Obj-count AS CHARACTER FORMAT "X(30)":U
      VIEW-AS TEXT
     SIZE 43 BY 2.08
     FGCOLOR 1 FONT 4 NO-UNDO.

DEFINE VARIABLE TEXT-3-alt AS CHARACTER FORMAT "X(256)" INITIAL "Выбор альтернативных объектов"
      VIEW-AS TEXT
     SIZE 31.38 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE Classify AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Без классификации", 1,
"По производителю", 2,
"По группам товаров", 3,
"По НДС из карточки товара", 4
     SIZE 28.63 BY 3.71 NO-UNDO.

DEFINE VARIABLE Rs-qnty-type AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "фактическое количество", 1,
"свободный остаток", 2
     SIZE 27.38 BY 2 NO-UNDO.

DEFINE VARIABLE SelectObject AS CHARACTER INITIAL "not"
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "1", "1":U
     SIZE 12.38 BY 2.54 NO-UNDO.

DEFINE VARIABLE SortType AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "по коду", "sort-code":U,
"по артикулу", "sort-artic":U,
"по наименов.", "sort-name":U
     SIZE 21 BY 3 NO-UNDO.

DEFINE RECTANGLE RECT-12
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 77.75 BY 16.75.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 44.75 BY 16.75.

DEFINE VARIABLE Itog AS LOGICAL INITIAL no
     LABEL "Только итоги"
     VIEW-AS TOGGLE-BOX
     SIZE 28.88 BY .83 NO-UNDO.

DEFINE VARIABLE show-qnty AS LOGICAL INITIAL no
     LABEL "По товарам 1го объекта "
     VIEW-AS TOGGLE-BOX
     SIZE 30.5 BY .83 TOOLTIP "Показывать те товары , у которых есть положительные  остатки по первому объекту" NO-UNDO.

DEFINE VARIABLE show-zero AS LOGICAL INITIAL no
     LABEL "показать нулевые строки"
     VIEW-AS TOGGLE-BOX
     SIZE 28.88 BY .83 TOOLTIP "Показывать нулевые строки по выбранным колонкам" NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     Classify AT ROW 2.96 COL 2.88 NO-LABEL
     SelectObject AT ROW 2.96 COL 44.38 NO-LABEL
     BUTTON-obj AT ROW 4.75 COL 58
     Itog AT ROW 8.33 COL 2.5
     show-zero AT ROW 9.33 COL 2.5
     show-qnty AT ROW 10.25 COL 2.5
     Rs-qnty-type AT ROW 11.25 COL 2.63 NO-LABEL
     SortType AT ROW 14.5 COL 3 NO-LABEL
     TEXT-3-alt AT ROW 1.5 COL 38.13 NO-LABEL
     Obj-count AT ROW 6 COL 33 COLON-ALIGNED NO-LABEL
     "Сортировать" VIEW-AS TEXT
          SIZE 20.5 BY .67 AT ROW 13.75 COL 3
          FGCOLOR 4
     "Классификация:":C28 VIEW-AS TEXT
          SIZE 28.75 BY .75 AT ROW 1.42 COL 3
          FGCOLOR 4
     "Показать:":C28 VIEW-AS TEXT
          SIZE 28.75 BY .75 AT ROW 7.29 COL 2.88
          FGCOLOR 4
     RECT-12 AT ROW 1.13 COL 1
     RECT-3 AT ROW 1.13 COL 34
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1 SCROLLABLE .


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartViewer
   Allow: Basic,DB-Fields
   Frames: 1
   Add Fields to: EXTERNAL-TABLES
   Other Settings: PERSISTENT-ONLY
 */

/* This procedure should always be RUN PERSISTENT.  Report the error,  */
/* then cleanup and return.                                            */
IF NOT THIS-PROCEDURE:PERSISTENT THEN DO:
  MESSAGE "{&FILE-NAME} should only be RUN PERSISTENT.":U
          VIEW-AS ALERT-BOX ERROR BUTTONS OK.
  RETURN.
END.

&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB)
  CREATE WINDOW s-object ASSIGN
         HEIGHT             = 17.25
         WIDTH              = 77.88.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB s-object
/* ************************* Included-Libraries *********************** */

{src/adm/method/viewer.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW s-object
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE FRAME-NAME Size-to-Fit                                   */
ASSIGN
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN TEXT-3-alt IN FRAME F-Main
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME BUTTON-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-obj s-object
ON CHOOSE OF BUTTON-obj IN FRAME F-Main /* BUTTON-obj */
DO:
  assign SelectObject.
  my-request = no.
  run select-objects-proc in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Rs-qnty-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Rs-qnty-type s-object
ON VALUE-CHANGED OF Rs-qnty-type IN FRAME F-Main
DO:
  ASSIGN Rs-qnty-type .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME SelectObject
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL SelectObject s-object
ON VALUE-CHANGED OF SelectObject IN FRAME F-Main
DO:
Assign SelectObject.
run select-objects-proc in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object


/* ***************************  Main Block  *************************** */

do with frame {&frame-name}
:
  assign
    selectobject :radio-buttons =
            "Нет" + {&comma-char} + "not":U + {&comma-char} +
  "Все" + {&comma-char} + {&all} + {&comma-char} +
  "Выборочно" + {&comma-char} + "choice":U
  .
end.

/* If testing in the UIB, initialize the SmartObject. */
&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
  RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI s-object  _DEFAULT-DISABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI s-object  _DEFAULT-ENABLE
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
  DISPLAY Classify SelectObject Itog show-zero show-qnty Rs-qnty-type SortType
          TEXT-3-alt Obj-count
      WITH FRAME F-Main.
  ENABLE RECT-12 RECT-3 Classify SelectObject BUTTON-obj Itog show-zero
         show-qnty Rs-qnty-type SortType TEXT-3-alt Obj-count
      WITH FRAME F-Main.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми параметрами
------------------------------------------------------------------------------*/
define variable v-ii as integer no-undo .
define variable v-ok as logical no-undo .
do v-ii = 1 to {&xlMaxCols}:
  if use-column[v-ii] = yes then do:
     leave.
  end.
end.
if v-ii > {&xlMaxCols}
and use-column[{&xlMaxCols}] = no then do:
  message
  "Не выбрана ни одна колонка для печати в текст!" skip
  "тело отчета при печати в текст будет пустым!" skip
  "Все равно выполнить отчет?"
  view-as alert-box question buttons yes-no update v-ok.
  if not v-ok then return.
end.

 IF Rs-qnty-type = 1 THEN do:
  if x-SelectGood = 1 Then DO:
      If x-SET_val_TYPE = 1 /* р_у_б */
        then
        run rep/r-z-alt1.p
            (input v-cntxt-obj-code ,
             input v-cntxt-obj-type ,
             input base-type ,
             input base-code ,
             input Classify,
             input itog ,
             input show-zero ,
             input sorttype,
             input show-qnty) .
        Else
        run rep/r-z-alt2.p
            (input v-cntxt-obj-code ,
            input v-cntxt-obj-type ,
            input base-type ,
            input base-code ,
            input Classify,
            input itog,
            input show-zero,
            input sorttype,
            input show-qnty) .
  End.
  Else DO:
      If x-SET_val_TYPE = 1 /* р_у_б */
        then
      run rep/r-z-alt3.p
        (input v-cntxt-obj-code ,
        input v-cntxt-obj-type ,
        input base-type ,
        input base-code ,
        input Classify,
        input itog ,
        input show-zero,
        input sorttype,
        input show-qnty) .
      Else
      run rep/r-z-alt4.p
          (input v-cntxt-obj-code ,
           input v-cntxt-obj-type ,
           input base-type ,
           input base-code ,
           input Classify,
           input itog ,
           input show-zero,
           input sorttype,
           input show-qnty) .
  End.
end.
else do:
  if x-SelectGood = 1 Then DO:
      If x-SET_val_TYPE = 1 /* р_у_б */
        then
        run rep/r-z-alt5.p
            (input v-cntxt-obj-code ,
             input v-cntxt-obj-type ,
             input base-type ,
             input base-code ,
             input Classify,
             input itog ,
             input show-zero ,
             input sorttype,
             input show-qnty) .
        Else
        run rep/r-z-alt6.p
            (input v-cntxt-obj-code ,
            input v-cntxt-obj-type ,
            input base-type ,
            input base-code ,
            input Classify,
            input itog,
            input show-zero,
            input sorttype,
            input show-qnty) .
  End.
  Else DO:
      If x-SET_val_TYPE = 1 /* р_у_б */
        then
      run rep/r-z-alt7.p
        (input v-cntxt-obj-code ,
        input v-cntxt-obj-type ,
        input base-type ,
        input base-code ,
        input Classify,
        input itog ,
        input show-zero,
        input sorttype,
        input show-qnty) .
      Else
      run rep/r-z-alt8.p
          (input v-cntxt-obj-code ,
           input v-cntxt-obj-type ,
           input base-type ,
           input base-code ,
           input Classify,
           input itog ,
           input show-zero,
           input sorttype,
           input show-qnty) .
  End.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.

assign frame {&frame-name}
 Classify itog show-zero  SortType show-qnty Rs-qnty-type .
run cur-time in this-procedure ( output v-today
                               , output v-time
                               ).
x-date-start = v-today.
x-date-end   = v-today.


     ReportHeader = "Альтернативные объекты : " + {&new-line}.
     for each alt-obj-list no-lock :
        ReportHeader = ReportHeader + Fill(" ",5) + alt-obj-list.obj-name  + {&new-line}.
     End.
IF Rs-qnty-type = 2 THEN do:
   ReportHeader = ReportHeader + "Свободный остаток" .
end.
ELSE do:
 ReportHeader = ReportHeader + "Фактическое количество" .
end.

if not show-zero then do:
  ReportHeader = ReportHeader +  {&new-line} + "Не показывать нулевые строки".
end.
else do:
  ReportHeader = ReportHeader +  {&new-line} + "Показывать нулевые строки".
end.

     IF show-qnty THEN DO:
        ReportHeader = ReportHeader +  {&new-line} + "Товары , у которых есть положительные остатки по первому объекту".
     END.

Sheetf.ColFOrmat = "2=@;3=@;4=@;5=@;"  .
Sheetf.Excel-Column-Lable = "N п\п,Код,Артикул,Название товара ,Признак товара,".
Sheetf.Sizes = "9,10,16,40,20,".

define variable v-var as integer   no-undo init 1.

repeat v-var = 1 to 2 :

  Sheetf.Excel-Column-Lable = Sheetf.Excel-Column-Lable + " Объект " + string( v-var )  + "," .
          Sheetf.Excel-Column-Lable = Sheetf.Excel-Column-Lable +     ",".
          Sheetf.Excel-Column-Lable = Sheetf.Excel-Column-Lable +     "," .
          Sheetf.Excel-Column-Lable = Sheetf.Excel-Column-Lable +     "," .

     Sheetf.Sizes = Sheetf.Sizes + "12," .
          Sheetf.Sizes = Sheetf.Sizes +     "13," .
          Sheetf.Sizes = Sheetf.Sizes +     "13," .
          Sheetf.Sizes  = Sheetf.Sizes +     "7," .

End.
     /* 2  */
     Sheetf.Excel-Column-Lable = Sheetf.Excel-Column-Lable  + {&new-line} +  ",,,,,".

repeat v-var = 1 to 2 :
     Sheetf.Excel-Column-Lable = Sheetf.Excel-Column-Lable + "Количество,".
           Sheetf.Excel-Column-Lable = Sheetf.Excel-Column-Lable +     "Учетные цены с НДС,".
           Sheetf.Excel-Column-Lable = Sheetf.Excel-Column-Lable +     "Суммы в продажных ценах," .
          Sheetf.Excel-Column-Lable = Sheetf.Excel-Column-Lable +     "% наценки," .
End.
 make-correct = Fill("true,", 13).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-objects-proc s-object
PROCEDURE select-objects-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-all-object as logical   no-undo .
{ rep/s-selobj.i alt-}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE sss s-object
PROCEDURE sss :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define buffer buf_user-obj for ub.user-obj .

  do
  on error undo, return error return-value
  :
    FOR EACH alt-obj-list
    :
        delete alt-obj-list.
    END.
    assign
      str-obj#  = ''
      str-obj2# = ''
    .

    for each buf_user-obj no-lock
      where buf_user-obj.db-num  = v-cntxt-db-num
        and buf_user-obj.user-id = v-cntxt-userid
    ,EACH cli-obj WHERE cli-obj.obj-type = buf_user-obj.obj-type AND
                                    cli-obj.obj-code = buf_user-obj.obj-code AND
                                    ( ( cli-obj.db-num = v-cntxt-db-num ) OR v-cntxt-db-num = 0 ) NO-LOCK :

                                      Find first ub.clients no-lock where
                                                  ub.clients.obj-type = buf_user-obj.obj-type AND
                                                  ub.clients.obj-code = buf_user-obj.obj-code No-ERROR.
            If Verify-send-check  and ub.clients.db-num <> v-cntxt-db-num  THEN DO:
              Find first ub.db where ub.db.db-num = ub.clients.db-num no-lock.
              if ub.db.send-check = false then DO:
                                          str-obj2# = str-obj2#  + " " + ub.clients.obj-name + ",".
                                          NEXT. End.
            END.

            if temp-param-obj-type = 'shop':U then
                                    if buf_user-obj.obj-type = {&stock} then DO:
                                    str-obj# = str-obj#  +  " " + ub.clients.obj-name + ",".
                                    NEXT.
                                    End.

            if temp-param-obj-type = 'stock':U then
                                    if buf_user-obj.obj-type = {&shop} then DO:
                                  str-obj# = str-obj#  +  " " +  ub.clients.obj-name + "," .
                                    NEXT.
                                    End.

                          CASE buf_user-obj.obj-type
                          :
                              when {&stock}
                              then do:
                                find ub.store where ub.store.obj-code = buf_user-obj.obj-code no-lock.
                                find first ub.sysconf no-lock where ub.sysconf.host-code = ub.store.host-code no-error.
                                find first ub.clients no-lock
                                  where ub.clients.obj-type = buf_user-obj.obj-type
                                    and ub.clients.obj-code = buf_user-obj.obj-code
                                  no-error.

                                if ub.sysconf.base-code = base-code
                                then do:
                                    CREATE alt-obj-list.
                                    assign
                                      alt-obj-list.obj-name = ub.clients.obj-name
                                      alt-obj-list.obj-type = buf_user-obj.obj-type
                                      alt-obj-list.obj-code = buf_user-obj.obj-code
                                    .
                                end.
                                else do:
                                  assign
                                    str-obj# = str-obj#  +  " " +   ub.clients.obj-name + ","
                                  .
                                end.
                              end.
                              when {&shop}
                              then do:
                                find ub.shop where ub.shop.obj-code = buf_user-obj.obj-code no-lock.
                                find first ub.sysconf no-lock where ub.sysconf.host-code = ub.shop.host-code no-error.
                                find first ub.clients no-lock
                                  where ub.clients.obj-type = buf_user-obj.obj-type
                                    and ub.clients.obj-code = buf_user-obj.obj-code
                                  no-error.
                                if ub.sysconf.base-code = base-code
                                then do:
                                  create alt-obj-list .
                                  assign
                                      alt-obj-list.obj-name = ub.clients.obj-name
                                      alt-obj-list.obj-type = buf_user-obj.obj-type
                                      alt-obj-list.obj-code = buf_user-obj.obj-code
                                  .
                                end.
                                else do:
                                  assign
                                    str-obj# = str-obj#  +  " " +  ub.clients.obj-name +  ","
                                  .
                                end.
                              end.
                          END CASE.

                  END.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed s-object
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:     Receive and process 'state-changed' methods
               (issued by 'new-state' event).
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.

  CASE p-state:
      /* Object instance CASEs can go here to replace standard behavior
         or add new cases. */
  END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE verify-check s-object
PROCEDURE verify-check :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  message "Не используется"  .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME