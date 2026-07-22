&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------


$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сбор данных по GTIN и штрих-кодам

Автор: Шкляр Елена 
Дата создания: 01/16/07
Author: Elena Shklyar
Creation date: 01/16/07

          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .

/* Local Variable Definitions ---                                       */

define variable l-error          as logical   no-undo. /* Есть ли ошибки */
define variable v-proc-name-err  as character no-undo.
define variable v-proc-name-GTIN as character no-undo.  

define stream str-err .
define stream str-log .
  
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сбор данных по GTIN и штрих-кодам".

{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/str-glbl.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ ref/grplibfn.i }
{ ref/gds-attr.i }
{ gbl/waitfram.i }
{ rep/html-conv.i }
{ gbl/getcntxt.i def }
{ bge/temp_gtin.i }
{ gbl/objsrv.i } 
{ cmp/showinf.i  }
function get-mark-integer returns character 
   (input p-mark as character) forward.
   
function get-mark-char returns character 
   (input p-mark as character) forward.
   
define variable v-new      as logical   no-undo init false.
define variable v-open     as logical   no-undo init false.
define variable v-scan-str as character no-undo.
define variable iLang      as integer   no-undo.
define variable v-recid    as recid     no-undo .
define variable v-init-dir as character no-undo .
define variable v_os-file  as character no-undo .

define buffer buf_tt-goods for tt-goods .
define stream OutStr-html.

define variable v-full-path-RepView as character no-undo.   /* Полный путь к файлу Просмотровщика (отчётов) */
define variable v-file-name-rep-htm as character no-undo.   /* Полный путь к файлу отчёта */
define variable v-file-name-rep-exl as character no-undo.
define variable g#report-num        as integer   no-undo.            /* Номер отчёта (получим стандартной процедурой ТН) */
define variable v-report-name       as character no-undo.         /* Наименование отчёта */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-GOODS

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-goods

/* Definitions for BROWSE BROWSE-GOODS                                  */
&Scoped-define FIELDS-IN-QUERY-BROWSE-GOODS tt-goods.gds-code ~
tt-goods.gds-name tt-goods.barcode tt-goods.GTIN tt-goods.qnty ~
tt-goods.type-mark 
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-GOODS 
&Scoped-define QUERY-STRING-BROWSE-GOODS FOR EACH tt-goods NO-LOCK
&Scoped-define OPEN-QUERY-BROWSE-GOODS OPEN QUERY BROWSE-GOODS FOR EACH tt-goods NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BROWSE-GOODS tt-goods
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-GOODS tt-goods


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-GOODS}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_save Btn_Cancel Btn_open Btn_add_goods ~
Btn_add_group Btn_del BROWSE-GOODS 
&Scoped-Define DISPLAYED-OBJECTS f-type-mark 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-mark-char Dialog-Frame 
FUNCTION get-mark-char RETURNS CHARACTER
   ( input p-mark as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-mark-integer Dialog-Frame 
FUNCTION get-mark-integer RETURNS CHARACTER
   ( input p-mark as character)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU POPUP-MENU-Btn_save 
       MENU-ITEM m_save_1       LABEL "с типом 1"     
       MENU-ITEM m_save_2       LABEL "с типом 2"     .


/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_add_goods 
     LABEL "Добавить товар" 
     SIZE 15 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_add_group 
     LABEL "Добавить упаковку" 
     SIZE 20 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_Cancel AUTO-END-KEY 
     LABEL "Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_del 
     LABEL "Удалить строку" 
     SIZE 15 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_open 
     LABEL "Открыть" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_save AUTO-GO 
     LABEL "Сохранить" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-type-mark AS CHARACTER FORMAT "X(256)" 
     LABEL "Тип маркировки" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "","not-type",
                     "Табачная продукция","tabak",
                     "Обувь","shoes",
                     "Духи и парфюмерия","perfume",
                     "Легпром","industry",
                     "Шины","tires",
                     "Лекарства","apteka",
                     "Фотокамеры/фотовспышки","photo",
                     "Молочная продукция","milk",
                     "Упакованная вода","water",
                     "Стики","stiki"
     DROP-DOWN-LIST
     SIZE 34.75 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-GOODS FOR 
      tt-goods SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-GOODS
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-GOODS Dialog-Frame _STRUCTURED
   QUERY BROWSE-GOODS NO-LOCK DISPLAY
   tt-goods.gds-code FORMAT ">>>>>>>>>>>>>>>>>9":U
   tt-goods.gds-name COLUMN-LABEL "Название товара" FORMAT "x(256)":U
   WIDTH 21
   tt-goods.barcode COLUMN-LABEL "Штрих-код" FORMAT "x(256)":U
   WIDTH 25
   tt-goods.GTIN COLUMN-LABEL "GTIN" FORMAT "x(256)":U WIDTH 26
   tt-goods.qnty COLUMN-LABEL "Кол-во" FORMAT ">>>9":U WIDTH 8
   tt-goods.type-mark COLUMN-LABEL "Тип маркировки" FORMAT "X(15)":U
   WIDTH 20
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 115.5 BY 16.25 ROW-HEIGHT-CHARS .79 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_save AT ROW 1.25 COL 2
     Btn_Cancel AT ROW 1.25 COL 12
     Btn_open AT ROW 1.25 COL 22
     Btn_add_goods AT ROW 1.25 COL 67.13 WIDGET-ID 6
     Btn_add_group AT ROW 1.25 COL 82.13 WIDGET-ID 10
     Btn_del AT ROW 1.25 COL 102.13 WIDGET-ID 8
     f-type-mark AT ROW 2.38 COL 116.13 RIGHT-ALIGNED WIDGET-ID 22
     BROWSE-GOODS AT ROW 3.75 COL 2 WIDGET-ID 200
     SPACE(0.87) SKIP(0.07)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Сбор данных по GTIN и штрих-кодам".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt-goods T "?" NO-UNDO ub bar-code
      ADDITIONAL-FIELDS:
          field gds-name as character
          field barcode as character
          field GTIN as character
          field qnty as integer
          field type-mark as character
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-GOODS f-type-mark Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE.

ASSIGN 
       BROWSE-GOODS:COLUMN-RESIZABLE IN FRAME Dialog-Frame       = TRUE.

ASSIGN 
       Btn_save:POPUP-MENU IN FRAME Dialog-Frame       = MENU POPUP-MENU-Btn_save:HANDLE.
ASSIGN 
   Btn_save:menu-mouse = 1.
/* SETTINGS FOR COMBO-BOX f-type-mark IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-R                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-GOODS
/* Query rebuild information for BROWSE BROWSE-GOODS
     _TblList          = "Temp-Tables.tt-goods"
     _Options          = "NO-LOCK"
     _FldNameList[1]   > Temp-Tables.tt-goods.gds-code
"tt-goods.gds-code" ? "->,>>>,>>9" "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > Temp-Tables.tt-goods.gds-name
"tt-goods.gds-name" "Название товара" "x(256)" "character" ? ? ? ? ? ? no ? no no "21" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > Temp-Tables.tt-goods.barcode
"tt-goods.barcode" "Штрих-код" "x(256)" "character" ? ? ? ? ? ? no ? no no "25" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > Temp-Tables.tt-goods.GTIN
"tt-goods.GTIN" "GTIN" "x(256)" "character" ? ? ? ? ? ? no ? no no "26" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > Temp-Tables.tt-goods.qnty
"tt-goods.qnty" "Кол-во" ">>>9" "integer" ? ? ? ? ? ? no ? no no "8" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   > Temp-Tables.tt-goods.type-mark
"tt-goods.type-mark" "Тип маркировки" "X(15)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE BROWSE-GOODS */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Сбор данных по GTIN и штрих-кодам */
DO:
      APPLY "END-ERROR":U TO SELF.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_add_goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_add_goods Dialog-Frame
ON choose OF Btn_add_goods IN FRAME Dialog-Frame /* Добавить товар */
DO:
      run bge/goodsGTINbarcode.w (input parparentproc, input-output table tt-goods by-reference, input f-type-mark:screen-value in frame {&frame-name}, output v-recid)  .
      {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
      reposition BROWSE-GOODS to recid v-recid no-error .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_add_group
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_add_group Dialog-Frame
ON choose OF Btn_add_group IN FRAME Dialog-Frame /* Добавить упаковку */
DO:
      run bge/groupGTINbarcode.w (input parparentproc, input-output table tt-goods by-reference, input f-type-mark:screen-value in frame {&frame-name}, output v-recid)  .
      {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
      reposition BROWSE-GOODS to recid v-recid no-error .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_del Dialog-Frame
ON choose OF Btn_del IN FRAME Dialog-Frame /* Удалить строку */
DO:
      run proc-del no-error .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_open
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_open Dialog-Frame
ON choose OF Btn_open IN FRAME Dialog-Frame /* Открыть */
DO:
      run proc-choose-file no-error .
      {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_save
&Scoped-define SELF-NAME f-type-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-type-mark Dialog-Frame
ON value-changed OF f-type-mark IN FRAME Dialog-Frame /* Тип маркировки */
DO:
      assign f-type-mark .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_save_1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_save_1 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_save_1 /* с типом 1 */
DO:
      define variable undelete as logical no-undo .
      define variable v-dir as character no-undo .
      v-dir = session:temp-directory .
      run bge/to_file.w (input-output v-dir) no-error .
      run define-full-path-Report(input 1, input v-dir, output v-file-name-rep-htm, output v-file-name-rep-exl).   /* Сформируем стандартизованное в ТН имя файла отчёта. */
      message "Сохранить данные в файл?"
      view-as alert-box question buttons yes-no update undelete.
      if undelete then do:
         run file-save in this-procedure no-error .
         if error-status:error
         then
            return no-apply.
      end.
      apply 'choose' to btn_save in frame {&frame-name} .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_save_2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_save_2 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_save_2 /* с типом 2 */
DO:
      define variable undelete as logical no-undo .
      define variable v-dir as character no-undo .
      v-dir = session:temp-directory .
      run bge/to_file.w (input-output v-dir) no-error .
      run define-full-path-Report(input 2, input v-dir, output v-file-name-rep-htm, output v-file-name-rep-exl).   /* Сформируем стандартизованное в ТН имя файла отчёта. */
      message "Сохранить данные в файл?"
      view-as alert-box question buttons yes-no update undelete.
      if undelete then do:
      run file-save in this-procedure no-error .
      end.
      apply 'choose' to btn_save in frame {&frame-name} .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-GOODS
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
   THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   run init-proc.
   { gbl/getcntxt.i get }
   RUN enable_UI.
   WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame 
PROCEDURE init-proc :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
define variable v-list as character no-undo.
define variable vi as integer no-undo.
define variable MarkType as ibs.th.gbl.map.mapstring no-undo.
define variable objType  as ibs.th.gbl.propmap no-undo.

MarkType = ObjSrv:Env:Marking:Types:MAPTYPE.
do vi = 1 to MarkType:GetItemByLab(vi):     
objType  = ObjSrv:Env:Marking:Types:CurrProp.

    v-list = v-list + "," + objType:Label_ + "," + objType:NameProp.
end.

v-list = trim(v-list, ",").
f-type-mark:list-item-pairs in frame {&FRAME-NAME} = v-list.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-file Dialog-Frame 
PROCEDURE create-file :
/*------------------------------------------------------------------------------
        Purpose:     
        Parameters:  <none>
        Notes:       
      ------------------------------------------------------------------------------*/
   /* Создание пустого файла (во входном параметре: полный путь и имя файла) */
   define input parameter p-file-name as character no-undo.
   output to value(string(p-file-name)).
   output close.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE define-full-path-Report Dialog-Frame 
PROCEDURE define-full-path-Report :
/*------------------------------------------------------------------------------
        Purpose:     
        Parameters:  <none>
        Notes:       
      ------------------------------------------------------------------------------*/
   define input parameter p-rep-num as integer no-undo.
   define input parameter p-dir as character no-undo .
   define output parameter p-file-name-rep-htm as character no-undo.
   define output parameter p-file-name-rep-exl as character no-undo.

   /*   p-file-name-rep-htm = session:temp-directory + "GTIN_" + string(v-cntxt-obj-code) + "_" + string(p-rep-num) + ".html".*/
   p-file-name-rep-htm = p-dir + "GTIN_" + string(v-cntxt-obj-code) + "_type_" + string(p-rep-num) + ".html".
   p-file-name-rep-exl = p-dir + "GTIN_" + string(v-cntxt-obj-code) + "_type_" + string(p-rep-num) + ".xlsx".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
   ENABLE Btn_save Btn_Cancel Btn_open Btn_add_goods Btn_add_group Btn_del 
      BROWSE-GOODS f-type-mark
      WITH FRAME Dialog-Frame.
   {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE imp-GTIN Dialog-Frame  _DEFAULT-ENABLE
PROCEDURE imp-GTIN :
   /*------------------------------------------------------------------------------
     Purpose:     ENABLE the User Interface
     Parameters:  <none>
     Notes:       Here we display/view/enable the widgets in the
                  user-interface.  In addition, OPEN all queries
                  associated with each FRAME and BROWSE.
                  These statements here are based on the "Other 
                  Settings" section of the widget Property Sheets.
   ------------------------------------------------------------------------------*/
   DEFINE VARIABLE mExcelApplication AS COMPONENT-HANDLE NO-UNDO. /* ССЫЛКА НА ПРИЛОЖЕНИЕ */
   DEFINE VARIABLE mWorkBook         AS COMPONENT-HANDLE NO-UNDO. /* ССЫЛКА НА РАБОЧУЮ КНИГУ */
   DEFINE VARIABLE mWorkSheet        AS COMPONENT-HANDLE NO-UNDO. /* ССЫЛКА НА РАБОЧИЙ ЛИСТ */
   DEFINE VARIABLE mMaxNoLine        AS INTEGER          INITIAL 10 NO-UNDO. /* Максимально пропусков */
  
   DEFINE VARIABLE vLine             AS INTEGER          NO-UNDO.
   DEFINE VARIABLE vChLine           AS CHARACTER        NO-UNDO.
   DEFINE VARIABLE vCh               AS CHARACTER        NO-UNDO.
   DEFINE VARIABLE vNoLine           AS INTEGER          NO-UNDO.
  
   define variable v-gds-code        as character        no-undo .
   define variable v-gds-name        as character        no-undo .
   define variable v-bar-code        as character        no-undo .
   define variable v-GTIN            as character        no-undo .
   define variable v-qnty            as character        no-undo .
   define variable v-mark-code       as character        no-undo .

   CREATE "Excel.Application":U mExcelApplication no-error.
   if error-status :error then 
   do:
      message
         "Ошибка при запуске Excel" skip
         error-status :get-message(1) skip
         view-as alert-box error .
      undo, return error .
   end.    
   ASSIGN
      mExcelApplication:DisplayAlerts = NO
      mWorkbook                       = mExcelApplication:WorkBooks:Add(v_os-file)
      mWorkSheet                      = mWorkbook:Sheets:Item(1)
      .
  
   loopbl:
   do vLine = 2 to 1000000:
      ASSIGN
         vChLine     = STRING(vLine)
         v-gds-code  = ''
         v-gds-name  = ''
         v-bar-code  = ''
         v-GTIN      = ''
         v-qnty      = ''
         v-mark-code = ''
         .

      v-gds-code = mWorkSheet:Range("B" + vChLine):FORMULA NO-ERROR.  
      if v-gds-code = ? then v-gds-code = mWorkSheet:Range("B" + vChLine):VALUE NO-ERROR.
    
      v-gds-name = mWorkSheet:Range("C" + vChLine):VALUE NO-ERROR.  
      if v-gds-name = ? then v-gds-name = mWorkSheet:Range("C" + vChLine):FORMULA NO-ERROR. 
    
      v-bar-code = mWorkSheet:Range("D" + vChLine):FORMULA NO-ERROR.  
      if v-bar-code = ? then v-bar-code = mWorkSheet:Range("D" + vChLine):VALUE NO-ERROR.

      v-GTIN = mWorkSheet:Range("E" + vChLine):FORMULA NO-ERROR.  
      if v-GTIN = ? then v-GTIN = mWorkSheet:Range("E" + vChLine):VALUE NO-ERROR.
              
      v-qnty = mWorkSheet:Range("F" + vChLine):FORMULA NO-ERROR.  
      if v-qnty = ? then v-qnty = mWorkSheet:Range("F" + vChLine):FORMULA NO-ERROR. 
    
      v-mark-code = mWorkSheet:Range("G" + vChLine):FORMULA NO-ERROR.  
      if v-mark-code = ? then v-mark-code = mWorkSheet:Range("G" + vChLine):VALUE NO-ERROR.
                
      if length(v-gds-code) > 0
         or length(v-gds-name) > 0
         or length(v-bar-code) > 0
         or length(v-GTIN) > 0
         or length(v-qnty) > 0
         or length(v-mark-code) > 0
         then 
      do :
         vNoLine = 0 .
      end.
      else 
      do :
         vNoLine = vNoLine + 1.
         IF vNoLine > mMaxNoLine THEN LEAVE loopbl. 
         ELSE NEXT loopbl. 
      end.
      find first tt-goods where tt-goods.gds-code = integer(v-gds-code) and tt-goods.barcode = v-bar-code and
                                tt-goods.GTIN     = v-GTIN no-error .
      if not available (tt-goods) then do:                                 
      create tt-goods .
      tt-goods.gds-code = integer(v-gds-code) .
      tt-goods.gds-name = v-gds-name .
      tt-goods.barcode = v-bar-code .
      tt-goods.GTIN     = v-GTIN .
      tt-goods.qnty     = integer(v-qnty) .
      tt-goods.type-mark = get-mark-char(v-mark-code) .  

      release tt-goods .
      end.    
    
   end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE file-save Dialog-Frame 
PROCEDURE file-save :
/*------------------------------------------------------------------------------
        Purpose:     
        Parameters:  <none>
        Notes:       
      ------------------------------------------------------------------------------*/
   define variable ii as integer no-undo .
   /*   run gbl/getrpnum.p (output g#report-num).  /* Получим СТАНДАРТНЫМ МЕТОДОМ ТН номер файла отчёта. */*/
      if search (v-file-name-rep-htm) <> ? then 
   do:
      os-delete value(v-file-name-rep-htm).
   end.
   if search (v-file-name-rep-exl) <> ? then 
   do:
      os-delete value(v-file-name-rep-exl).
   end.
   run create-file(v-file-name-rep-htm).   /* Создадим на диске пустой файл со сформированным по стандарту именем файла. */

   run waitfram-show in this-procedure ( "ЖДИТЕ... Формирование отчёта") .

   output stream OutStr-html to value(v-file-name-rep-htm) append convert target 'UTF-8' .
  
  
   /* Системная шапка HTML */
   put stream OutStr-html unformatted
      "<!DOCTYPE HTML>" skip
      ' <html>' skip
      '  <head>' skip
      '   <meta charset="utf-8">' skip
      '    <style type="text/css">' skip
      '      table ' + chr(123) + ' border-collapse: collapse; font-size: 9pt; table-layout: fixed; width: 500px; padding: 3px; ' + chr(125) skip
      '      td ' + chr(123) ' border: 1px black ridge; word-wrap:break-word; ' + chr(125) skip
      '      htm' skip
      '      .rotate ' + chr(123) skip
      '        -webkit-transform: rotate(-90deg);' skip
      '        -moz-transform: rotate(-90deg);' skip
      '        -ms-transform: rotate(-90deg);' skip
      '        -o-transform: rotate(-90deg);' skip
      '        transform: rotate(-90deg);' skip

      /* also accepts left, right, top, bottom coordinates; not required, but a good idea for styling */
      '        -webkit-transform-origin: 50% 50%;' skip
      '        -moz-transform-origin: 50% 50%;' skip
      '        -ms-transform-origin: 50% 50%;' skip
      '        -o-transform-origin: 50% 50%;' skip
      '        transform-origin: 50% 50%;' skip

      /* Should be unset in IE9+ I think.*/
      '        filter: progid:DXImageTransform.Microsoft.BasicImage(rotation=3);' skip
      '          ' + chr(125) skip
      '            th' + ' ' + chr(123) skip
      '            border: 1px black solid;' skip
      '            word-wrap: break-word;' skip
      '          ' + chr(125) skip
      '   </style>' skip
      '  </head>' skip
      .
    
   put stream OutStr-html unformatted
      '<body>' skip
      '<table name="Лист1"  fit_to_page="true" orientation="portrait" CELLSPACING="0" BORDER="0">'skip
      '<thead>' skip
      .
   put stream OutStr-html unformatted
      '<tr class="set_columns">' skip
      '<td style="width: 50px; border: none;"></td>' skip
      '<td style="width: 60px; border: none;"></td>' skip
      '<td style="width: 180px; border: none;"></td>' skip
      '<td style="width: 120px; border: none;"></td>' skip
      '<td style="width: 120px; border: none;"></td>' skip
      '<td style="width: 80px; border: none;"></td>' skip
      '<td style="width: 100px; border: none;"></td>' skip
      '</tr>' skip
      .
   put stream OutStr-html unformatted
      '     <tbody>' skip
      '       <tr>' skip
      '         <th text_wrap="true" style="text-align: center; font-weight:bold;">№П/П</th>' skip      
      '         <th text_wrap="true" style="text-align: center; font-weight:bold;">Код товара</th>' skip
      '         <th text_wrap="true" style="text-align: center; font-weight:bold;">Название товара</th>' skip
      '         <th text_wrap="true" style="text-align: center; font-weight:bold;">Штрих-код упаковки</th>' skip
      '         <th text_wrap="true" style="text-align: center; font-weight:bold;">GTIN упаковки</th>' skip
      '         <th text_wrap="true" style="text-align: center; font-weight:bold;">Кол-во единиц в упаковке</th>' skip
      '         <th text_wrap="true" style="text-align: center; font-weight:bold;">Тип маркировки</th>' skip
      '       </tr>' skip
      . /* Точка для закрытия Put */    
   for each tt-goods:
      ii = ii + 1 .
      put stream OutStr-html unformatted
         '       <tr>' skip
         '         <th text_wrap="true" style="text-align: center;">' + string(ii) + '</th>' skip
         '         <th text_wrap="true" style="text-align: center;">' + string(tt-goods.gds-code) + '</th>' skip
         '         <th text_wrap="true" style="text-align: center;">' + string(tt-goods.gds-name) + '</th>' skip
         '         <th text_wrap="true" style="text-align: center;">' + string(tt-goods.barcode) + '</th>' skip
         '         <th text_wrap="true" style="text-align: center;">' + string(tt-goods.GTIN) + '</th>' skip
         '         <th text_wrap="true" style="text-align: center;">' + string(tt-goods.qnty) + '</th>' skip
         '         <th text_wrap="true" style="text-align: center;">' + get-mark-integer(tt-goods.type-mark) + '</th>' skip
         '       </tr>' skip
         . /* Точка для закрытия Put */         
   end.       
   put stream OutStr-html unformatted
      '     </tbody>' skip
      '   </table>' skip
      '  </body>' skip
      ' </html>' skip
      . /* Точка для закрытия Put */
   output stream OutStr-html close.


   run prn-lib-reportviewer in this-procedure (
      input THIS-PROCEDURE
      ,input v-file-name-rep-htm
      ,input "GUI:FALSE" + {&delim-par} + "OS:7_32" 
      ) no-error.
   if error-status:error then
   do:
      message return-value view-as alert-box.
      run waitfram-hide in this-procedure .
   
      return error. 
   end.
   

   run waitfram-hide in this-procedure .
   if  search (v-file-name-rep-exl) = ?
   then do:
      message "Oшибка создания файла. Промежуточный результат в " v-file-name-rep-htm
      view-as alert-box.
      return error.
   end.
   os-delete value(v-file-name-rep-htm) . 
   
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-choose-file Dialog-Frame 
PROCEDURE proc-choose-file :
/*------------------------------------------------------------------------------
                         Purpose:     
                         Parameters:  <none>
                         Notes:       
                       ------------------------------------------------------------------------------*/
   /* Выбор файла */
   define variable ll_commit          AS LOG       NO-UNDO INIT NO.
   define variable v-full-path        as character no-undo .
   define variable v-path             as character no-undo .
   define variable v-file-name        as character no-undo .
   define variable v-file-name-no-ext as character no-undo .
   define variable v-file-name-ext    as character no-undo .

   if search (v-proc-name-err) <> ? then 
   do:
      os-delete value(v-proc-name-err).
   end.
   if search (v-proc-name-GTIN) <> ? then 
   do:
      os-delete value(v-proc-name-GTIN).
   end.
   SYSTEM-DIALOG GET-FILE v_os-file
      TITLE "Выберите файл для импорта"
      FILTERS
      " MS Excel (*.xls,*.xlsx) " "*.xls,*.xlsx"
      INITIAL-DIR v-init-dir
      /*return-to-start-dir*/
      must-exist
      default-extension "xls"
      .
   IF v_os-file <> "" THEN
   DO:
      
      run imp-GTIN .

      INPUT FROM value(v_os-file). 
 
   end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-del Dialog-Frame 
PROCEDURE proc-del :
/*------------------------------------------------------------------------------
                     Purpose:
                     Parameters:  <none>
                     Notes:
                   ------------------------------------------------------------------------------*/
   delete tt-goods .
   do transaction:
      {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
   end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-mark-char Dialog-Frame 
FUNCTION get-mark-char RETURNS CHARACTER
   ( input p-mark as character ) :
   /*------------------------------------------------------------------------------
     Purpose:  
       Notes:  
   ------------------------------------------------------------------------------*/
   define variable v-mark as character no-undo.
   define variable MarkType as ibs.th.str.marking.Types no-undo.
   MarkType = ObjSrv:Env:Marking:Types. 
   v-mark = MarkType:GetNameProp(int(p-mark)).
   return v-mark .

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-mark-integer Dialog-Frame 
FUNCTION get-mark-integer RETURNS CHARACTER
   ( input p-mark as character) :
   /*------------------------------------------------------------------------------
     Purpose:  
       Notes:  
   ------------------------------------------------------------------------------*/
   
   define variable v-mark as character no-undo .
   define variable MarkType as ibs.th.str.marking.Types no-undo.
   
   MarkType = ObjSrv:Env:Marking:Types. 
   v-mark = string(MarkType:GetKeyIntDB(p-mark)).
   return v-mark .
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

