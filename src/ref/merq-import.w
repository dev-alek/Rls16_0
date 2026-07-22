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

Импорт товаров

Автор: Шкляр Елена  
Дата создания: 10/10/08
Author: Shklyar Elena
Creation date: 10/10/08

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
using ibs.th.str.gds.*.
using ibs.th.str.mercury.*.
using ibs.th.gbl.storage.*.
using ibs.th.bge.mercury.*.

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE OUTPUT PARAMETER p-list AS character NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Импорт товаров".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ str/temp_merq.i}
{ str/checkmerq.i}

define variable gdsMercsubsObj as class gdsmercsubs.
define variable gdsmercstrObj  as class gdsmercstr.

define stream imp.
define stream err.
define variable v_file      as char    no-undo.
DEFINE variable text-string as char    no-undo.
DEFINE variable impc        as integer No-UNDO.
DEFINE variable imp-save    as integer No-UNDO.
DEFINE variable N-param     AS DEC     NO-UNDO.
DEFINE variable log-save    as log     no-undo.

define BUFFER buf_goods      for ub.goods .
define buffer buf_goods-attr for ub.goods-attr .

define temp-table tt-gds-answer no-undo like tt-gds-merq .


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help file-name B-file 
&Scoped-Define DISPLAYED-OBJECTS file-name 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO 
  LABEL "&Выполнить" 
  SIZE 10 BY 1
  BGCOLOR 8 .

DEFINE BUTTON B-file 
  IMAGE-UP FILE "btn-down-arrow":U
  IMAGE-DOWN FILE "btn-down-arrow":U
  IMAGE-INSENSITIVE FILE "btn-down-arrow":U
  LABEL "" 
  SIZE 3 BY 1.

DEFINE BUTTON B-Help 
  LABEL "Помо&щь" 
  SIZE 3 BY 1
  BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY 
  LABEL "&Отмена" 
  SIZE 10 BY 1
  BGCOLOR 8 .

DEFINE VARIABLE file-name AS CHARACTER FORMAT "X(256)":U 
  LABEL "Файл для импорта" 
  VIEW-AS FILL-IN 
  SIZE 35.88 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
  B-exit AT ROW 1 COL 1
  b-quit AT ROW 1 COL 11
  B-Help AT ROW 1 COL 58
  file-name AT ROW 3.42 COL 1.38 WIDGET-ID 16
  B-file AT ROW 3.42 COL 55.75 WIDGET-ID 20
  SPACE(2.99) SKIP(2.36)
  WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
  SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
  TITLE "Импорт товаров"
  DEFAULT-BUTTON B-exit.


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
ASSIGN 
  FRAME Dialog-Frame:SCROLLABLE = FALSE
  FRAME Dialog-Frame:HIDDEN     = TRUE.

/* SETTINGS FOR FILL-IN file-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Импорт товаров */
  DO:
    APPLY "END-ERROR":U TO SELF.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Выполнить */
  DO:
    if  trim(file-name) = "" then 
    do:
      message "Не задан файл для импорта "
        view-as alert-box ERROR.
      return no-apply.
    end.
    RUN proc-save IN THIS-PROCEDURE NO-ERROR.
    IF ERROR-STATUS:error THEN RETURN NO-APPLY.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-file
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-file Dialog-Frame
ON CHOOSE OF B-file IN FRAME Dialog-Frame
  DO:

    DEF VAR ll_commit AS LOG NO-UNDO INIT NO.

    SYSTEM-DIALOG GET-FILE v_file
      TITLE "Выберите файл для импорта"
      FILTERS "Текстовый файл (*.txt)" "*.txt"
      MUST-EXIST
      USE-FILENAME
      .
    ASSIGN 
      file-name = ( IF SEARCH( v_file ) = ? THEN v_file ELSE SEARCH( v_file ) ).
    DISP file-name WITH FRAME {&FRAME-NAME}.

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME file-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL file-name Dialog-Frame
ON LEAVE OF file-name IN FRAME Dialog-Frame /* Файл для импорта */
  DO:
    ASSIGN file-name.
    IF SEARCH( file-name ) <> ? AND SEARCH( file-name ) <> "":U THEN 
    DO:
      ASSIGN 
        FILE-INFO:FILE-NAME = file-name.
      IF FILE-INFO:FULL-PATHNAME <> ? THEN ASSIGN file-name = FILE-INFO:FULL-PATHNAME.

      DISP file-name WITH FRAME {&FRAME-NAME}.
    END.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
  THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI IN THIS-PROCEDURE.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
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
  DISPLAY file-name 
    WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help file-name B-file 
    WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
  define variable gdsMercsubsObj as class     gdsmercsubs.
  define variable gdsMercObj     as class     gdsmercsub.
  define variable gdsmercstrObj  as class     gdsmercstr.
  define variable ii             as integer   no-undo .
  DEFINE VARIABLE V-GUID         AS CHARACTER NO-UNDO .
  define VARIABLE Msg            as character no-undo .
  
  empty TEMP-TABLE tt-gds-answer .
  gdsMercsubsObj = new gdsmercsubs ().
  gdsmercstrObj = new gdsmercstr ().

  gdsMercObj = new gdsmercsub().

  input stream imp from value (file-name) .
  repeat:
    IMPORT stream imp UNFORMATTED text-string .
    if trim(text-string) = "" then   leave.
    impc = impc + 1.    
    
    /*проверка на кол-во данных в строке*/
    if num-entries (text-string, ";") < 3 then 
    do:
      N-param = num-entries (text-string, ";").
      OUTPUT stream Err TO value ("Imp_mercur.err") append.
      put stream Err unformatted
        string(today, "99/99/9999") " "
        string(time, "HH:MM")
        " Неправильное число параметров в строке, должно быть 3 "  N-param skip.
      export stream  Err text-string .
      output stream Err close.
      next.
    end.
    find first buf_goods NO-LOCK where buf_goods.gds-code = INTEGER (ENTRY( 1, text-string, ";")) no-error .
    if not AVAILABLE (buf_goods) then 
    do:
      find FIRST buf_goods  NO-LOCK where buf_goods.artic = ENTRY( 2, text-string, ";") no-error .
      if not AVAILABLE (buf_goods) then 
      do:
        OUTPUT stream Err TO value ("Imp_mercur.err") append.
        put stream Err unformatted
          string(today, "99/99/9999") " "
          string(time, "HH:MM")
          " Нет товара с таким кодом и артикулом"  skip.
        export stream  Err text-string .
        output stream Err close.
        next.
      end.   
    end.  
    else 
    do:
      find first buf_goods-attr no-lock where buf_goods-attr.gds-code = buf_goods.gds-code and buf_goods-attr.attr-code = {&attr-mercur_FGIS}
        and buf_goods-attr.attr-value = "yes" no-error .
      if not AVAILABLE (buf_goods-attr) then 
      do:
        OUTPUT stream Err TO value ("Imp_mercur.err") append.
        put stream Err unformatted
          string(today, "99/99/9999") " "
          string(time, "HH:MM")
          " У товара нет атрибута - не загружен"  skip.
        export stream  Err text-string .
        output stream Err close.
        next.
      end.   
      else 
      do:
        V-GUID = ENTRY( 3, text-string, ";") .
        run checkguid(INPUT-OUTPUT V-GUID,OUTPUT Msg) no-error .
        if Msg <> "" then 
        do:
          OUTPUT stream Err TO value ("Imp_mercur.err") append.
          put stream Err unformatted
            string(today, "99/99/9999") " "
            string(time, "HH:MM")
            " Неверный формат поля GUID - не загружен" skip.
          export stream  Err text-string .
          output stream Err close.      
          next.    
        end.
        p-list = p-list + "," + STRING (buf_goods-attr.gds-code) .
        gdsMercsubsObj = gdsmercstrObj:getgdsmercs(buf_goods-attr.gds-code).
        if VALID-OBJECT (gdsMercsubsObj:GdsMercsubsCurr) then
        do:
          do ii = 1 to gdsMercsubsObj:GetItem (ii):
            gdsMercObj = gdsMercsubsObj:GdsMercsubsCurr. /* выдернула конкретный объект*/
          end.
          gdsMercObj:GUID_       = V-GUID .
    
          gdsmercstrObj:updateDB(gdsMercObj). /*измение записи в бд */
          OUTPUT stream Err TO value ("Imp_mercur.err") append.
          put stream Err unformatted
            string(today, "99/99/9999") " "
            string(time, "HH:MM")
            " Изменили GUID у товара" skip.
          export stream  Err text-string .
          output stream Err close.          
          next.
        end.   
        else 
        do:
          gdsMercObj = new gdsmercsub().
          gdsMercObj:GUID_       = V-GUID .
          gdsMercObj:GdsCode     = buf_goods-attr.gds-code .
          
          gdsmercstrObj:insertDB(gdsMercObj).
 
        end.
      end.  
      
      display
        impc  label "Прочитано"
        text-string format "x(40)" label "Строка файла"
        with frame ff view-as dialog-box
        title ": Импорт справочника товаров из файла".
      pause 0.

    end.  /*  repeat:  */
      
  end.
  input stream imp close.
  p-list = TRIM (p-list) .   

  message ("Импорт из файла " + file-name + " закончен, прочитано " + string(impc) +
    ",  " ) skip
    "Все строки из файла которые не удалось импортировать можно посмотреть в файле Imp_goods.err "
    view-as alert-box  .   
  delete object gdsMercObj no-error .
  delete object gdsmercstrObj no-error .
  delete object gdsMercsubsObj no-error .    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-news Dialog-Frame 
PROCEDURE send-news :
  /*------------------------------------------------------------------------------
    Purpose:     
    Parameters:  <none>
    Notes:       
  ------------------------------------------------------------------------------*/

  for each ub.gds-mercury EXCLUSIVE-LOCK:
    run str/callnews.p
      (input {&table_gds-mercury}
      ,input (buffer ub.gds-mercury:handle)
      ) no-error .

    if error-status :error then 
    do:
      message
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box.
      return error.
    end.
  end.  

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



