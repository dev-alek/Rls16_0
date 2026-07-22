&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Загрузка GTIN и штрих-коды маркированной продукции


*/

/* ***************************  Definitions  ************************** */

/* Local Variable Definitions ---                                       */
define variable vss-revision as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Загрузка GTIN и штрих-коды маркированной продукции" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ cmp/library.i }
{ gbl/getcntxt.i def }
{ gbl/thbj-def.i }
{ ref/gds-attr.i }
{ gbl/waitfram.i }
{ gbl/objsrv.i }
define variable MarkType as ibs.th.str.marking.Types no-undo.
MarkType = ObjSrv:Env:Marking:Types.
/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .      
define variable conf-par             as character no-undo.                  /* для чтения параметра конфигурации */
define variable par-type             as character no-undo.
define variable v-init-dir           as character no-undo .
define variable v_os-file            as character no-undo .
define variable MarkingType          as character no-undo .
define variable v-marking            as logical   no-undo .
define variable v-gds-attr-value-old as character no-undo .
define variable v-gds-attr-type      as character no-undo .

define stream str-log .
define stream str-err .

{ bge/temp_gtin.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-file file-name_ t-type_mark ~
t-mark 
&Scoped-Define DISPLAYED-OBJECTS file-name_ t-type_mark t-mark 

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-mark-list-integer Dialog-Frame 
FUNCTION get-mark-list-integer RETURNS CHARACTER
   (input p-mark as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-file 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE file-name_ AS CHARACTER FORMAT "X(256)":U 
     LABEL "Файл загрузки" 
     VIEW-AS FILL-IN 
     SIZE 49.63 BY 1 NO-UNDO.

DEFINE VARIABLE t-mark AS LOGICAL INITIAL no 
     LABEL "Установка признака требует маркировки" 
     VIEW-AS TOGGLE-BOX
     SIZE 42.5 BY .83 NO-UNDO.

DEFINE VARIABLE t-type_mark AS LOGICAL INITIAL no 
     LABEL "Установка типа маркировки" 
     VIEW-AS TOGGLE-BOX
     SIZE 42 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.13 WIDGET-ID 8
     b-quit AT ROW 1 COL 11.13 WIDGET-ID 10
     B-file AT ROW 2.88 COL 67.38 WIDGET-ID 12
     file-name_ AT ROW 2.92 COL 15.38 COLON-ALIGNED WIDGET-ID 14
     t-type_mark AT ROW 4.25 COL 17.38 WIDGET-ID 16
     t-mark AT ROW 5.29 COL 17.38 WIDGET-ID 18
     SPACE(15.24) SKIP(0.45)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Загрузка GTIN и штрих-кодов" WIDGET-ID 16.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB Dialog-Frame 
/* ************************* Included-Libraries *********************** */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Загрузка GTIN и штрих-кодов */
DO:
      APPLY "END-ERROR":U TO SELF.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
      run waitfram-show in this-procedure ( "ЖДИТЕ... Обработка файла данных") .
      run imp-GTIN no-error.
      if return-value = 'cancel' then return no-apply .
      run check-param no-error.
      if return-value = 'cancel' then return no-apply .
      run waitfram-show in this-procedure ( "ЖДИТЕ... Загрузка данных") .
      run proc-save no-error.
      if return-value = 'cancel' then return no-apply .
      run waitfram-hide in this-procedure .
      apply "go".
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-file
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-file Dialog-Frame
ON CHOOSE OF B-file IN FRAME Dialog-Frame
DO:

      define variable ll_commit          AS LOG       NO-UNDO INIT NO.
      define variable v-full-path        as character no-undo .
      define variable v-path             as character no-undo .
      define variable v-file-name        as character no-undo .
      define variable v-file-name-no-ext as character no-undo .
      define variable v-file-name-ext    as character no-undo .


      SYSTEM-DIALOG GET-FILE v_os-file
         TITLE "Выберите файл для импорта"
         FILTERS
         " MS Excel (*.xls,*.xlsx) " "*.xls,*.xlsx"
         INITIAL-DIR v-init-dir
         /*return-to-start-dir*/
         must-exist
         update ll_commit
         default-extension "xls"
         .
      IF ll_commit <> YES THEN 
      do:
         RETURN NO-APPLY.
      end.
      IF v_os-file = PROGRAM-NAME( 1 ) THEN 
      DO:
         BELL.
         MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
         RETURN NO-APPLY.
      END.
      ASSIGN 
         file-name_ = ( IF SEARCH( v_os-file ) = ? THEN v_os-file ELSE SEARCH( v_os-file ) ).
      DISP file-name_ WITH FRAME {&FRAME-NAME}.
      run gbl/filename.p (
         input  file-name_
         ,output v-full-path
         ,output v-path
         ,output v-file-name
         ,output v-file-name-no-ext
         ,output v-file-name-ext
         ) no-error .
      if not error-status:error then v-init-dir = v-path.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отмена */
DO:
      assign 
         v_os-file = "".
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME file-name_
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL file-name_ Dialog-Frame
ON LEAVE OF file-name_ IN FRAME Dialog-Frame /* Файл загрузки */
DO:
      ASSIGN file-name_.
      IF SEARCH( file-name_ ) <> ? AND SEARCH( file-name_ ) <> "":U THEN 
      DO:
         ASSIGN 
            FILE-INFO:FILE-NAME = file-name_.
         IF FILE-INFO:FULL-PATHNAME <> ? THEN ASSIGN file-name_ = FILE-INFO:FULL-PATHNAME.
         DISP file-name_ WITH FRAME {&FRAME-NAME}.
      END.
   /*      APPLY "TAB":U TO file-name IN FRAME {&FRAME-NAME}.*/
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-mark Dialog-Frame
ON VALUE-CHANGED OF t-mark IN FRAME Dialog-Frame /* Установка признака требует маркировки */
DO:
  assign t-mark .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-type_mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-type_mark Dialog-Frame
ON VALUE-CHANGED OF t-type_mark IN FRAME Dialog-Frame /* Установка типа маркировки */
DO:
  assign t-type_mark .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


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
   RUN enable_UI.
   WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-param Dialog-Frame  _DEFAULT-ENABLE
PROCEDURE check-param :
   /*------------------------------------------------------------------------------
     Purpose:     ENABLE the User Interface
     Parameters:  <none>
     Notes:       Here we display/view/enable the widgets in the
                  user-interface.  In addition, OPEN all queries
                  associated with each FRAME and BROWSE.
                  These statements here are based on the "Other 
                  Settings" section of the widget Property Sheets.
   ------------------------------------------------------------------------------*/
   define variable v-value-character as character no-undo .
   define variable v-value-decimal   as decimal   no-undo .
   define variable v-value-integer   as integer   no-undo .
   define variable v-value-logical   as logical   no-undo .
   define variable v-value-type      as character no-undo .
   define variable v-value-date      as date      no-undo .
   /**/ 
   v-marking = yes .
   run adm/shattri.p (
      input "get":U
      ,input v-cntxt-obj-type
      ,input v-cntxt-obj-code
      ,input {&attr-marking}
      ,input "marking-type"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,input-output TABLE thbjattr_thbj-attr
      ) no-error .
   MarkingType = v-value-character.
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
  DISPLAY file-name_ t-type_mark t-mark 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-file file-name_ t-type_mark t-mark 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
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
   
   if v_os-file = "" then 
   do:
      message "Выберите файл для загрузки"
         view-as alert-box.
      return 'cancel' .
   end.   
  
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
      if not available (tt-goods) then 
      do:                                 
         create tt-goods .
         tt-goods.gds-code = integer(v-gds-code) .
         tt-goods.gds-name = v-gds-name .
         tt-goods.barcode = v-bar-code .
         tt-goods.GTIN     = v-GTIN .
         tt-goods.qnty     = integer(v-qnty) .
         tt-goods.type-mark = v-mark-code .  

         release tt-goods .
      end.        
    
   end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame  _DEFAULT-ENABLE
PROCEDURE proc-save :
   /*------------------------------------------------------------------------------
     Purpose:     ENABLE the User Interface
     Parameters:  <none>
     Notes:       Here we display/view/enable the widgets in the
                  user-interface.  In addition, OPEN all queries
                  associated with each FRAME and BROWSE.
                  These statements here are based on the "Other 
                  Settings" section of the widget Property Sheets.
   ------------------------------------------------------------------------------*/
   define buffer buf_goods         for ub.goods .
   define buffer buf_bar-code      for ub.bar-code .
   define buffer buf_bar-code-attr for ub.bar-code-attr .
   define buffer buf_prod-bc       for ub.prod-bc .
   define buffer buf_prod-bc-attr  for ub.prod-bc-attr.
   define buffer buf_goods-attr    for ub.goods-attr .
   define buffer base-bar-code     for ub.bar-code.
   define variable v-rid             as recid     no-undo .
   define variable v-b-str           like ub.prod-bc.b-str no-undo .
   define variable v-load            as logical   no-undo .
   define variable v-err             as logical   no-undo .
   define variable v-err-log         as logical   no-undo .
   define variable v-file-name-load  as character no-undo .
   define variable v-file-name-error as character no-undo .
   define variable v-mes as character no-undo .
   
   v-file-name-load = v_os-file + ".log" .
   v-file-name-error = v_os-file + ".err" .
   
   output stream str-log to value(v-file-name-load) .
   output stream str-err to value(v-file-name-error) .
   
   for each tt-goods:
      find first buf_goods exclusive-lock where buf_goods.gds-code = tt-goods.gds-code no-error .
      if not available (buf_goods) then 
      do:
         put stream str-err unformatted 
            "Не найден товар " tt-goods.gds-code " " tt-goods.gds-name " в системе." skip .
         v-err = true .
         v-err-log = true .
         next .
      end.   
      /* Поиск штрих кода */
      find first buf_bar-code no-lock where buf_bar-code.gds-code = buf_goods.gds-code and
         buf_bar-code.cli-base-rate = tt-goods.qnty no-error .
      if not available (buf_bar-code) then 
      do:
         find base-bar-code no-lock where
            base-bar-code.b-code = tt-goods.gds-code.
         find gds-prt no-lock where
            gds-prt.node-code = base-bar-code.node-code.

         run ref/barcode1.p (
            input {&add-def}
            ,input no /*p-silent*/
            ,input 0
            ,input buf_goods.gds-code
            ,input gds-prt.node-code
            ,input base-bar-code.part-code
            ,input base-bar-code.in-code
            ,input 'уп'
            ,input tt-goods.qnty
            ,output v-rid) no-error.
         if not error-status:error then 
         do:
            /*            put stream str-log unformatted                                                                                  */
            /*               "Создан бар-код для товара " tt-goods.gds-code " " tt-goods.gds-name " с коэффициентом " tt-goods.qnty skip .*/
            find first buf_bar-code no-lock where recid (buf_bar-code) = v-rid no-error .                   
         end.    
         else 
         do:
            put stream str-err unformatted 
               "Ошибка при создании бар-кода для товара " tt-goods.gds-code " " tt-goods.gds-name " с коэффициентом " tt-goods.qnty skip .
            v-err-log = true .
            next .   
         end.   
      end.
      find first buf_prod-bc exclusive-lock where buf_prod-bc.b-code = buf_bar-code.b-code and buf_prod-bc.b-str = string(tt-goods.barcode) no-error .
      if not available (buf_prod-bc) then 
      do:
         run trg/prod-bc2.p ( input parparentproc
            ,input no /*p-silent*/
            ,input no /* dif-pdbc */
            ,input yes /*pbc-veto*/
            ,input no /*send-ref*/
            ,input ''
            ,input '' /*p-ean-type*/
            ,buffer buf_goods
            ,input buf_bar-code.b-code
            ,input t-mark 
            ,input-output tt-goods.barcode /*p-b-str*/
            ,output v-rid
            ) no-error.         
         if error-status:error then 
         do:
            put stream str-err unformatted 
            substitute("Ошибка при создании штрих-кода &1 для товара &2 &3 &4 &5"
                             , tt-goods.barcode
                             , tt-goods.gds-code
                             , tt-goods.gds-name
                             , {&new-line}
                             , return-value
                             ) skip.

            v-err-log = true .
            next .               
         end.         
         else 
         do:
            find first buf_prod-bc exclusive-lock where recid (buf_prod-bc) = v-rid no-error .
         end.                
      end.                                                         
         find first buf_prod-bc-attr where buf_prod-bc-attr.b-code = buf_prod-bc.b-code
            and buf_prod-bc-attr.b-str = buf_prod-bc.b-str 
            and buf_prod-bc-attr.attr-code = {&mark} no-error .
         if not available (buf_prod-bc-attr) then 
         do:
            create buf_prod-bc-attr .
            buf_prod-bc-attr.b-code = buf_prod-bc.b-code .
            buf_prod-bc-attr.b-str = buf_prod-bc.b-str .
            buf_prod-bc-attr.attr-code = {&mark} .
         end.                                 
         buf_prod-bc-attr.attr-value = string (t-mark) .
  

      find first buf_prod-bc exclusive-lock where buf_prod-bc.b-code = buf_bar-code.b-code and buf_prod-bc.b-str = string(tt-goods.GTIN) no-error .
      if not available (buf_prod-bc) then 
      do:
         run trg/prod-bc2.p (
            input parparentproc
            ,input yes /*p-silent*/
            ,input no /*dif-pdbc*/
            ,input yes /*pbc-veto*/
            ,input no /*send-ref*/
            ,input {&gtin} /*p-cdrg-type*/
            ,input '' /*ean-type*/
            ,buffer buf_goods
            ,input buf_bar-code.b-code
            ,input no /*требует маркировки*/
            ,input-output tt-goods.GTIN
            ,output v-rid
            ) no-error .         
         if error-status:error then 
         do:
            put stream str-err unformatted 
               ( substitute("Ошибка при создании GTIN &1 для товара &2 &3 &4 &5"
                             , tt-goods.GTIN
                             , tt-goods.gds-code
                             , tt-goods.gds-name
                             , {&new-line}
                             , return-value
                             )) skip.
            v-err-log = true .
            next .               
         end.         
         else 
         do:
            find first buf_prod-bc exclusive-lock where recid (buf_prod-bc) = v-rid no-error .
         end.                
      end.                                                         

      if t-type_mark then 
      do:
/*         if lookup ( get-mark-char(tt-goods.type-mark), MarkingType ) > 0 then*/
/*         do:                                                                  */
            RUN gds-attr-value (
               INPUT buf_goods.gds-code,
               INPUT {&attr-mark-type},
               OUTPUT v-gds-attr-value-old,
               OUTPUT v-gds-attr-type
               ).
            if v-gds-attr-value-old <> get-mark-char(tt-goods.type-mark) then 
            do:
               RUN gds-attr-write (
                  INPUT buf_goods.gds-code,
                  INPUT {&attr-mark-type},
                  INPUT get-mark-char(tt-goods.type-mark)
                  ). 
            end.                            
/*         end.*/
      end.   
      put stream str-log unformatted 
         "Товар " tt-goods.gds-code " " tt-goods.gds-name " загружен." skip .
      v-load = true .
   end.
   output stream str-log close.
   output stream str-err close.
   if not v-load then 
   do:
      os-delete value(v-file-name-load).
   end.
   if not v-err-log then 
   do:
      os-delete value(v-file-name-error).
   end.                  
   if v-err then 
   do:
      message "В файле загрузки присутствуют товары, не найденные в БД"
         view-as alert-box.
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

   RETURN MarkType:GetNameProp(int(p-mark)).   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-mark-list-integer Dialog-Frame 
FUNCTION get-mark-list-integer RETURNS CHARACTER
   (input p-mark as character ) :
   /*------------------------------------------------------------------------------
     Purpose:  
       Notes:  
   ------------------------------------------------------------------------------*/
   define variable ii     as integer   no-undo .
   define variable v-mark as character no-undo .

   do ii = 0 to num-entries (p-mark,","):
      v-mark = v-mark + "," + string(MarkType:GetKeyIntDB(entry(ii, p-mark,","))).
   end.   
   v-mark = trim(v-mark,",") .
   RETURN v-mark.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

