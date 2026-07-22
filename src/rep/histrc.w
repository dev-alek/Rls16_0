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

Историческая справка по версиям RC на БД.

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

Input:

Output:

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc    as handle           no-undo.
define input parameter p-select-list    as character        no-undo.
/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Историческая справка по версиям RC на БД".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/clntattr.i }
{ gbl/prn-lib.i }

define variable v-obj-list  as character no-undo.
define variable v-host-code as integer   no-undo.
define variable v-host-name as character no-undo.
define variable v-today     as date      no-undo.
define variable v-time      as integer   no-undo.
define variable ii          as integer   no-undo.
define variable jj          as integer   no-undo.
define variable v-list      as character no-undo.
define variable v-menedger  as character no-undo.
define variable v-name      as character no-undo.
define variable select-list as character no-undo .

define temp-table temp_db-list no-undo
  field db-num as integer
  index pi is primary unique db-num
  .

define temp-table tt-upgrade like ub.upgrade
  field db-key        as character
  field compile-date  as character
  field date-time     as character
  field user_         as character
  field reserve1-char as character
  field db-name       as character
  index pi db-num UpgDate UpgTime
  .

define stream out-stream.
define stream OutStr-html.

define variable p-report-id           as integer   no-undo .
define variable v-report-name-html    as CHARACTER no-undo .
define variable v-report-name-html-RC as CHARACTER no-undo .

define variable v-file-date           as character no-undo .
define variable v-file-time           as character no-undo .
 
define buffer buf_db           for ub.db .
define buffer buf_upgrade      for ub.upgrade .
define buffer buf_upgrade-attr for ub.upgrade-attr .
define buffer buf_person       for ub.person .
define buffer buf_user-account for ub.user-account .


&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 


/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 Btn_OK date_from date_to bt-set rs-1 ~
bt-sel-dbs 
&Scoped-Define DISPLAYED-OBJECTS date_from date_to ed-bd rs-1 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-infodb-date d-db 

FUNCTION get-infodb-date RETURNS Character
  ( INPUT p-db-num as integer)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-time d-db 
FUNCTION get-time RETURNS Character
  ( INPUT p-time as integer)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-infodb-ver d-db
FUNCTION get-infodb-ver RETURNS character 
  ( INPUT p-db-num as integer)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_OK date_from date_to bt-set 
&Scoped-Define DISPLAYED-OBJECTS date_from date_to 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-infodb-date Dialog-Frame 
FUNCTION get-infodb-date RETURNS character
  ( INPUT p-db-num as integer)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-set 
  LABEL "Выполнить" 
  SIZE 12 BY 1.

DEFINE BUTTON Btn_OK DEFAULT 
  LABEL "&Выход" 
  SIZE 10 BY 1
  BGCOLOR 8 .

DEFINE VARIABLE date_from AS DATE FORMAT "99/99/9999":U 
  LABEL "Дата с" 
  VIEW-AS FILL-IN 
  SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE date_to   AS DATE FORMAT "99/99/9999":U 
  LABEL "по" 
  VIEW-AS FILL-IN 
  SIZE 12 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
  Btn_OK AT ROW 1.25 COL 1.5
  date_from AT ROW 2.75 COL 11.5 COLON-ALIGNED
  date_to AT ROW 2.75 COL 29 COLON-ALIGNED
  bt-set AT ROW 2.75 COL 45.5
  SPACE(0.74) SKIP(1.03)
  WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
  SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
  TITLE "Историческая справка по версиям".


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

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Историческая справка по версиям */
  DO:
    APPLY "END-ERROR":U TO SELF.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-set
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-set Dialog-Frame
ON CHOOSE OF bt-set IN FRAME Dialog-Frame /* Выполнить */
  DO:
    ASSIGN
      date_from
      date_to
      .
    
    run test-input .
    
    run print_RC .

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* Выход */
  DO:
    APPLY "GO" TO FRAME {&FRAME-NAME}.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME date_from
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL date_from Dialog-Frame
ON RETURN OF date_from IN FRAME Dialog-Frame /* Дата с */
  DO:
    APPLY "ENTRY" TO date_to IN FRAME {&FRAME-NAME}.
    RETURN NO-APPLY.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME date_to
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL date_to Dialog-Frame
ON RETURN OF date_to IN FRAME Dialog-Frame /* по */
  DO:
    APPLY "ENTRY" TO btn_OK IN FRAME {&FRAME-NAME}.
    RETURN NO-APPLY.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
  THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/ed_date.i date_from }
{ gbl/ed_date.i date_to   }

run cur-time in this-procedure ( output v-today
  , output v-time
  ).
ASSIGN
  date_from = 01.01.1990
  date_to   = v-today
.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }

  RUN enable_UI.
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
  DISPLAY date_from date_to 
    WITH FRAME Dialog-Frame.
  ENABLE Btn_OK date_from date_to bt-set 
    WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-report-num Dialog-Frame 
PROCEDURE get-report-num :
  define output parameter p-report-num as integer no-undo .

  do
    on error undo, return error return-value
    :
    run gbl/getrpnum.p (output p-report-num).
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE print_RC Dialog-Frame 
PROCEDURE print_RC :
  /*------------------------------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    ------------------------------------------------------------------------------*/
  do
    on error undo, return error
    :
    run get-report-num in parParentProc (
      output p-report-id
      ).

    v-report-name-html = session:temp-directory + string(p-report-id) + ".html".         
    
    run PROC-print-RC in this-procedure.

  end.
END PROCEDURE. /* print_RC */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-print-RC Dialog-Frame 
PROCEDURE proc-print-RC :
  /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
  do
    on error undo, return error
    :
    ii = 0 .
    /*вызов процедуры печати шапки отчета*/      
    output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' /*no-convert*/.
    put stream OutStr-html unformatted
      "<!DOCTYPE HTML>" skip
      ' <html>' skip
      '  <head>' skip
      '   <meta charset="utf-8">' skip
      '    <style type="text/css">' skip
                        
      '      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
      '      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
      '      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black; height: 14px;' + chr(125) skip
      '   </style>' skip
      '  </head>' skip
      .
                        
                        
    put stream OutStr-html unformatted
      '<body>' skip
      /*Первая таблица*/
      '<TABLE name="1"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
      '<thead>' skip
      .
    if v-cntxt-db-num = 0 then 
    do:
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td style="width: 40px;"></td>' skip
        '<td style="width: 60px;"></td>' skip
        '<td style="width: 60px;"></td>' skip
        '<td style="width: 80px;"></td>' skip
        '<td style="width: 120px;"></td>' skip
        '<td style="width: 80px;"></td>' skip
        '<td style="width: 120px;"></td>' skip
        '</tr>' skip
        .
                        
 
      put stream OutStr-html unformatted
        '<TR>' skip
        '<TD colspan="7" style="font-weight: bold;">Историческая справка по версиям RC на ГБД</TD>' skip 
        '</TR>' skip
        '<TR>' skip
        '<TD colspan="7" style="font-weight: bold;">Дата: ' + string (v-today,"99.99.9999") + '</TD>' skip  
        '</TR>'skip

        '<TR>' skip
        '<TD colspan="7" style="font-weight: bold;">Время: ' + get-time(v-time) + '</TD>' skip        
        '</TR>'skip

        '<TR>' skip
        '<TD colspan="7" style="font-weight: bold;">Фильтры: с ' + string (date_from,"99.99.9999") + " по " + string(date_to,"99.99.9999") + '</TD>' skip
        '</TR>'skip

        '<TR>' skip
        '<TD colspan="7" style="font-weight: bold;">Дата актуальности информации о БД и RC: ' + get-time(v-time) + '</TD>' skip
        '</TR>'skip
        .
      put stream OutStr-html unformatted            
        '</thead>' skip
        '<tbody>' skip
        .
        
        
      put stream OutStr-html unformatted
        '<tr>' skip
        '<th text_wrap="true" style="align: center;">№</th>' skip
        '<th text_wrap="true" style="align: center;">Номер БД</th>' skip
        '<th text_wrap="true" style="align: center;">Название БД</th>' skip
        '<th text_wrap="true" style="align: center;">Индентификатор версии RC</th>' skip
        '<th text_wrap="true" style="align: center;">Дата и время компиляции RC</th>' skip
        '<th text_wrap="true" style="align: center;">Дата и время копирования индентификатора версии RC на ПК</th>' skip
        '<th text_wrap="true" style="align: center;">Дата и время записи данных о версии в БД</th>' skip
        '<th text_wrap="true" style="align: center;">Имя пользователя</th>' skip
        '</tr>' skip
        .
    end.
    else 
    do:
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td style="width: 40px;"></td>' skip
        '<td style="width: 100px;"></td>' skip
        '<td style="width: 60px;"></td>' skip
        '<td style="width: 80px;"></td>' skip
        '<td style="width: 120px;"></td>' skip
        '<td style="width: 80px;"></td>' skip
        '</tr>' skip
        .
                        
 
      put stream OutStr-html unformatted
        '<TR>' skip
        '<TD colspan="6" style="font-weight: bold;">Историческая справка по версиям RC на УБД</TD>' skip 
        '</TR>' skip
        '<TR>' skip
        '<TD colspan="6" style="font-weight: bold;">Дата: ' + string (v-today,"99.99.9999") + '</TD>' skip  
        '</TR>'skip

        '<TR>' skip
        '<TD colspan="6" style="font-weight: bold;">Время: ' + get-time(v-time) + '</TD>' skip        
        '</TR>'skip

        '<TR>' skip
        '<TD colspan="6" style="font-weight: bold;">Фильтры: с ' + string (date_from,"99.99.9999") + " по " + string(date_to,"99.99.9999") + '</TD>' skip
        '</TR>'skip

        '<TR>' skip
        '<TD colspan="6" style="font-weight: bold;">Дата актуальности информации о БД и RC: ' + get-time(v-time) + '</TD>' skip
        '</TR>'skip
        .
      put stream OutStr-html unformatted            
        '</thead>' skip
        '<tbody>' skip
        .
        
        
      put stream OutStr-html unformatted
        '<tr>' skip
        '<th text_wrap="true" style="align: center;">№</th>' skip
        '<th text_wrap="true" style="align: center;">Индентификатор версии RC</th>' skip
        '<th text_wrap="true" style="align: center;">Дата и время компиляции RC</th>' skip
        '<th text_wrap="true" style="align: center;">Дата и время копирования индентификатора версии RC на ПК</th>' skip
        '<th text_wrap="true" style="align: center;">Дата и время записи данных о версии в БД</th>' skip
        '<th text_wrap="true" style="align: center;">Имя пользователя</th>' skip
        '</tr>' skip
        .
    end.  

    define variable v-date_from as character no-undo .
    define variable v-date_to   as character no-undo .

    if string(entry(3,string(date_from),"/")) >= "90" then v-date_from = "19" + string(entry(3,string(date_from),"/")) + "_" + string(entry(2,string(date_from),"/")) + "_" + string(entry(1,string(date_from),"/")) .
    else v-date_from = "20" + string(entry(3,string(date_from),"/")) + "_" + string(entry(2,string(date_from),"/")) + "_" + string(entry(1,string(date_from),"/")) .
    if string(entry(3,string(date_to),"/")) >= "90" then v-date_to = "19" + string(entry(3,string(date_to),"/")) + "_" + string(entry(2,string(date_to),"/")) + "_" + string(entry(1,string(date_to),"/")) .
    else v-date_to = "20" + string(entry(3,string(date_to),"/")) + "_" + string(entry(2,string(date_to),"/")) + "_" + string(entry(1,string(date_to),"/")) .

    if v-cntxt-db-num = 0 then 
    do:
      if p-select-list = "" then 
      do:
        for each ub.db no-lock:
          if select-list = "" then select-list = string(ub.db.db-num) .
          else select-list = select-list + {&comma-char} + string(ub.db.db-num) .
        end.  
      end.
      else 
      do:
        do jj = 1 to num-entries (p-select-list,{&comma-char}):
          for each ub.db no-lock where recid (ub.db) = integer(entry(jj,p-select-list)):
            if select-list = "" then select-list = string(ub.db.db-num) .
            else select-list = select-list + {&comma-char} + string(ub.db.db-num) .
          end.  
        end.  
      end.  
    end.
    else select-list = string(v-cntxt-db-num) .
    empty temp-table tt-upgrade .
    do jj = 1 to num-entries (select-list,{&comma-char}):
      for last buf_db no-lock where buf_db.db-num = integer (entry(jj,select-list)):
        next_:
        /*        for each buf_upgrade where buf_upgrade.db-num = buf_db.db-num and entry(1,buf_upgrade.version-num," ") >= v-date_from and entry(1,buf_upgrade.version-num," ") <= v-date_to:*/
        for each buf_upgrade where buf_upgrade.db-num = buf_db.db-num and buf_upgrade.UpgDate >= date_from and buf_upgrade.UpgDate <= date_to:
          find first tt-upgrade where tt-upgrade.db-num = buf_upgrade.db-num and tt-upgrade.version-num = buf_upgrade.version-num no-error .
          if available (tt-upgrade) then leave Next_ .
          create tt-upgrade .
          buffer-copy buf_upgrade to tt-upgrade .
          assign
            tt-upgrade.db-name = buf_db.db-name
            .
            v-file-date = "" .
            v-file-time = "" . 
          if buf_upgrade.version-num begins "?" or buf_upgrade.version-num = "'?'" then tt-upgrade.version-num = "Ошибка обновления" .                         
          find first buf_upgrade-attr no-lock where 
            buf_upgrade-attr.db-num = buf_upgrade.db-num and 
            buf_upgrade-attr.version-num = buf_upgrade.version-num and
            buf_upgrade-attr.attr-code = "compile-date" no-error .
          if available (buf_upgrade-attr) then 
            tt-upgrade.compile-date = buf_upgrade-attr.attr-value 
              .
          for first buf_upgrade-attr no-lock where 
            buf_upgrade-attr.db-num = buf_upgrade.db-num and 
            buf_upgrade-attr.version-num = buf_upgrade.version-num and
            buf_upgrade-attr.attr-code = "file-date" :
            v-file-date = buf_upgrade-attr.attr-value .
          end.  
          for first buf_upgrade-attr no-lock where 
            buf_upgrade-attr.db-num = buf_upgrade.db-num and 
            buf_upgrade-attr.version-num = buf_upgrade.version-num and
            buf_upgrade-attr.attr-code = "file-time" :
            v-file-time = get-time(integer(buf_upgrade-attr.attr-value)) .
          end.  
          if v-file-date = ? or v-file-time = ? then tt-upgrade.date-time = "" .
          else tt-upgrade.date-time = string(v-file-date) + "_" + string (v-file-time) .
          for first buf_upgrade-attr no-lock where 
            buf_upgrade-attr.db-num = buf_upgrade.db-num and 
            buf_upgrade-attr.version-num = buf_upgrade.version-num and
            buf_upgrade-attr.attr-code = "user",
            first ub.user-login no-lock where ub.user-login.db-num = buf_upgrade.db-num
            and ub.user-login.user-login = buf_upgrade-attr.attr-value,
            first buf_user-account no-lock where buf_user-account.user-id = ub.user-login.user-id: 
            tt-upgrade.user_ = buf_user-account.last-name + '  ' + buf_user-account.first-name + ' ':U + buf_user-account.second-name.
          end.
        end.
      end.
    end.

    /*    for each tt-upgrade where lookup ("Patch",tt-upgrade.version-num," ") > 0 or tt-upgrade.version-num = "v16_0000.000.000" by tt-upgrade.db-num by tt-upgrade.UpgDate desc by tt-upgrade.UpgTime desc:*/
    for each tt-upgrade by tt-upgrade.db-num by tt-upgrade.UpgDate desc by tt-upgrade.UpgTime desc:
      ii = ii + 1 .
      if v-cntxt-db-num = 0 then 
      do:
        put stream OutStr-html unformatted
          '<tr>' skip
          '<td style="align:center;">' + string(ii) + '</td>' skip
          '<td text_wrap="true" style="align:center;">' + string(tt-upgrade.db-num) + '</td>' skip
          '<td text_wrap="true" style="align:center;">' + string(tt-upgrade.db-name) + '</td>' skip
          '<td text_wrap="true" style="align:center;">' + string(entry(1,tt-upgrade.version-num,{&delim-par})) + '</td>' skip
          '<td text_wrap="true" style="align:center;">' + if string(tt-upgrade.compile-date) <> ? then string(tt-upgrade.compile-date) + '</td>' else " " + '</td>' skip
          '<td text_wrap="true" style="align:center;">' + string(tt-upgrade.date-time) + '</td>' skip
          '<td text_wrap="true" style="align:center;">' + string(tt-upgrade.UpgDate) + "_" + string(tt-upgrade.UpgTime) + '</td>' skip 
          '<td text_wrap="true" style="align:center;">' + string(tt-upgrade.user_) + '</td>' skip
          '</tr>' skip
          .
      end.
      else 
      do:
        put stream OutStr-html unformatted
          '<tr>' skip
          '<td style="align:center;">' + string(ii) + '</td>' skip
          '<td text_wrap="true" style="align:center;">' + string(entry(1,tt-upgrade.version-num,{&delim-par})) + '</td>' skip
          '<td text_wrap="true" style="align:center;">' + if string(tt-upgrade.compile-date) <> ? then string(tt-upgrade.compile-date) + '</td>' else " " + '</td>' skip
          '<td text_wrap="true" style="align:center;">' + string(tt-upgrade.date-time) + '</td>' skip
          '<td text_wrap="true" style="align:center;">' + string(tt-upgrade.UpgDate) + "_" + string(tt-upgrade.UpgTime) + '</td>' skip 
          '<td text_wrap="true" style="align:center;">' + string(tt-upgrade.user_) + '</td>' skip
          '</tr>' skip
          .
  
      end.  
    end.
    put stream OutStr-html unformatted
      '</tbody>' skip  
      '</table>' skip
      .

    put stream OutStr-html unformatted
        
      '</body>' skip
      '</html>' skip
      .
    put stream OutStr-html unformatted   
      '</tbody>' skip
      '</table>' skip
      .
    output stream OutStr-html close.   
 


    /*вызов программы печати*/ 
    run prn-lib-reportviewer-report-name in this-procedure (
      input parParentProc
      ,input v-report-name-html
      ).


  end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE test-input Dialog-Frame 
PROCEDURE test-input :
  /*------------------------------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    ------------------------------------------------------------------------------*/
  do
    on error undo, return error
    :
    if date_from > date_to
      then 
    do:
      message
        "Даты интервала заданы неверно. "
        skip 
        " Нижняя дата интервала должна быть меньше верхней."
        skip(1) "Задайте интервал дат правильно или отмените экспорт."
        view-as alert-box information.
      apply "entry" to date_from in frame {&frame-name} .
      undo, return error.
    end.
  end.
END PROCEDURE. /* test-input */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-infodb-date Dialog-Frame 
FUNCTION get-infodb-date RETURNS character
  ( INPUT p-db-num as integer) :
  DEFINE BUFFER buf_db-info FOR ub.db-info.
  find last buf_db-info no-lock where
    buf_db-info.db-num = p-db-num use-index  pi no-error.
  IF AVAILABLE buf_db-info  THEN RETURN string(buf_db-info.date-info).
  RETURN "".   /* Function return value. */

END FUNCTION.


FUNCTION get-time RETURNS character
  ( INPUT p-time as integer) :
  define variable v-time_ as character no-undo .

  v-time_ = string(truncate (p-time / 3600, 0)) + ":" + string((p-time modulo 3600) / 60,"99") .
  RETURN v-time_.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

