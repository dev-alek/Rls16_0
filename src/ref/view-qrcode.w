&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v7r11 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME DLGCLOSE
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS DLGCLOSE 
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: view-qrCode.w $
$Archive: ref/view-qrCode.w $

Просмотр картинки

Автор: Шкляр Елена
Дата создания: 06/10/05
Author: Shklyar Elena
Creation date: 06/10/05

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input parameter parparentproc as widget-handle no-undo .
define input-output parameter CashierQRCode as char no-undo .
define temp-table tt0-staff no-undo like ub.staff.
DEFINE INPUT PARAMETER TABLE FOR tt0-staff.
define output parameter p-update as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: view-qrCode.w $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/view-qrCode.w $":U .
define variable vss-description as character no-undo init "QrCode".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i  }
{ gbl/img-frm.i }
{ gbl/base64.i  }
{ gbl/db-attr.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/prn-lib.i }
{ rep/frmlib.i }     

/* Local Variable Definitions ---                                       */
define variable stat as log no-undo .
define variable v-param-type as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
define variable v-descriptions as character no-undo .
define variable v-extensiond   as character no-undo .
define variable v-extensiont   as character no-undo .
define variable new-code as character no-undo .
define stream Out-Stream.
define stream OutStr-html.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

FUNCTION get-staff-name RETURNS CHARACTER ( input p-obj-name as character
                                          , input p-psn-code as integer
                                          , input p-stts as integer):
define variable v-full-name as character no-undo .
define buffer buf_person for ub.person.
find first buf_person no-lock where
          buf_person.psn-code = p-psn-code no-error.
v-full-name = substitute("&1 &2 &3"
                   , p-obj-name
                   , (if available buf_person then buf_person.name1 else '')
                   , (if available buf_person then buf_person.name2 else '')
                   ).
RETURN
(IF (p-stts = integer({&current-status-int}))
THEN v-full-name
ELSE (substring (v-full-name,1, 25) +
                FILL ({&space-char}, 25 - LENGTH (substring (v-full-name, 1, 25)) )) +
                {&deleted-stat_}).
END FUNCTION.

&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME DLGCLOSE

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_Close B-qrCode b-print 
&Scoped-Define DISPLAYED-OBJECTS qr-code 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-print 
     IMAGE-UP FILE "cmp/b-print.bmp":U
     IMAGE-DOWN FILE "cmp/b-print.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/b-print.bmp":U NO-CONVERT-3D-COLORS
     LABEL "Печать" 
     SIZE 3 BY 1.

DEFINE BUTTON B-qrCode 
     LABEL "&Новый QR-код" 
     SIZE 15 BY 1.

DEFINE BUTTON Btn_Close AUTO-GO 
     LABEL "&Выход ":L 
     SIZE 15 BY 1
     BGCOLOR 8 .

DEFINE IMAGE qr-code
     STRETCH-TO-FIT RETAIN-SHAPE
     SIZE 30.5 BY 10.75.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DLGCLOSE
     Btn_Close AT ROW 1 COL 1
     B-qrCode AT ROW 1 COL 16
     b-print AT ROW 1 COL 36.75 WIDGET-ID 62
     qr-code AT ROW 3 COL 5.63
     SPACE(4.36) SKIP(0.95)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS THREE-D  SCROLLABLE 
         BGCOLOR 8 
         TITLE BGCOLOR 8 "QR-code кассира":L
         DEFAULT-BUTTON Btn_Close.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX DLGCLOSE
   FRAME-NAME UNDERLINE                                                 */
ASSIGN 
       FRAME DLGCLOSE:SCROLLABLE       = FALSE
       FRAME DLGCLOSE:PRIVATE-DATA     = 
                "DLGCLOSE".

ASSIGN 
       Btn_Close:PRIVATE-DATA IN FRAME DLGCLOSE     = 
                "Btn_Close".

ASSIGN 
       qr-code:RESIZABLE IN FRAME DLGCLOSE        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME B-qrCode
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-qrCode DLGCLOSE
ON CHOOSE OF B-qrCode IN FRAME DLGCLOSE /* Новый QR-код */
DO:
  define variable recid_attr as recid no-undo .
  run generate_qrCode(output CashierQRCode) .

  find first ub.staff-attr exclusive-lock where ub.staff-attr.attr-code = "CashierQRCode" and
    ub.staff-attr.date-start <= today and
    ub.staff-attr.role = tt0-staff.role and
    ub.staff-attr.staff-code = tt0-staff.staff-code and
    ub.staff-attr.role-level = tt0-staff.role-level no-error .
  if not available (ub.staff-attr) then 
  do:
    create ub.staff-attr .
    assign
      ub.staff-attr.attr-code  = "CashierQRCode" 
      ub.staff-attr.date-start = today
      ub.staff-attr.role       = tt0-staff.role
      ub.staff-attr.role-level = tt0-staff.role-level
      ub.staff-attr.staff-code = tt0-staff.staff-code
      .
  end.
  ub.staff-attr.attr-value = CashierQRCode .
  run print_qrCode(CashierQRCode).
  stat = qr-code:load-image( "" + session:temp-directory + "\qr-code.png":U) .
  p-update = true .
    
  DISPLAY
    qr-code
    WITH FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print DLGCLOSE
ON choose of b-print in frame DLGCLOSE /* QR-code */
DO:
  define variable p-report-id as character no-undo .
  define variable v-firm as character no-undo .
  define variable v-obj-name as character no-undo .
  define variable v-hist-code as character no-undo .
  define variable v-hist-name as character no-undo .
  define variable v-file-name-rep-htm as character no-undo .
  define variable par-type as character no-undo .
  
  define buffer buf_clients for ub.clients .
  define buffer buf_shop for ub.shop .

  run get-report-num (output p-report-id).

  v-file-name-rep-htm = session:temp-directory + string(p-report-id) + ".html".

  output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8' .

  find first buf_clients no-lock where buf_clients.obj-type = {&cmp} and buf_clients.obj-code = v-cntxt-host-code-obj no-error .
  if available (buf_clients) then v-firm = buf_clients.obj-name .
  find first ub.firm no-lock where ub.firm.firm-code = v-cntxt-host-code-obj no-error .
  
  find first buf_shop no-lock where buf_shop.obj-code = v-cntxt-obj-code no-error .
   
  
  run db-attr-value(INPUT v-cntxt-db-num,INPUT {&attr-hist-code},OUTPUT v-hist-code ,OUTPUT par-type) .
  run db-attr-value(INPUT v-cntxt-db-num,INPUT {&attr-hist-name},OUTPUT v-hist-name ,OUTPUT par-type) .
  
  if v-hist-name = "" then v-hist-name = v-obj-name .
  
  do: /* заголовок html-файла и заголовок таблицы */
    put stream OutStr-html unformatted
    {rep/htmlhead.i}

      '<body>' skip
      substitute('<TABLE name="&1" fit_to_page="true" orientation="portrait" repeat_rows="1:4" outline_below="false">', 'QR-code') skip
      '<thead>' skip

      /* Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px */
      /* row 1 */
      '  <tr class="set_columns">' skip
      '    <td style="width: 400px;"></td>' skip 
      '  </tr>' skip
          
      '  <tr>' skip
      '    <td text_wrap="true" style="text-align: center;">' + v-firm + '</td>' skip 
      '  </tr>' skip
      '  <tr>' skip
      '    <td text_wrap="true" style="text-align: center;">' + v-hist-name + '</td>' skip 
      '  </tr>' skip
      '  <tr>' skip
      '    <td text_wrap="true" style="text-align: center;">' + buf_shop.addres1 + '</td>' skip 
      '  </tr>' skip
      '  <tr>' skip
      '    <td text_wrap="true" style="text-align: center;">' + buf_shop.addres2 + '</td>' skip 
      '  </tr>' skip
      .
    if search( "" + session:temp-directory + "\qr-code.png":U ) <> ? then 
    do:  
      put stream OutStr-html unformatted   
        '<tr>' skip
        '<td style="text-align: center;"><img src="' + session:temp-directory + '\qr-code.png" width="130" height="130" alt=""/></td>' skip
        '</tr>' skip .
    end.
    else 
    do:
      put stream OutStr-html unformatted   
        '<tr>' skip
        '<td text_wrap="true" style="text-align: center;"></td>' skip
        '</tr>' skip.
    end.
        
    find first ub.clients NO-LOCK WHERE ub.clients.obj-type = {&prs} and ub.clients.obj-code = tt0-staff.psn-code no-error .

    put stream OutStr-html unformatted   
      '<tr>' skip
      '<td text_wrap="true" style="text-align: center;">' + get-staff-name ( ub.clients.obj-name, ub.clients.obj-code, ub.clients.stts ) + '</td>' skip
      '</tr>' skip.        
        
  end.
  put stream OutStr-html unformatted
    '</thead>' skip

    /* Здесь начинается таблица отчета */
    '<tbody>' skip
    .
  put stream OutStr-html unformatted
    '</tbody>' skip
    '<tfoot>' skip
    .
  put stream OutStr-html unformatted
    '</tfoot>' skip
    '</table>' skip
    '</body>' skip
    '</html>' skip
    .
  output stream OutStr-html close.
        
  run prn-lib-reportviewer in this-procedure (
    input this-procedure
    ,input v-file-name-rep-htm
    ,input ""
    ) .
  if error-status:error then
  do:
    message return-value view-as alert-box.
    return .
  end.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK DLGCLOSE 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
find first tt0-staff no-error .

  run print_qrCode(CashierQRCode).
  if CashierQRCode <> "" then
    stat = qr-code:load-image( "" + session:temp-directory + "\qr-code.png":U) .

    run enable_UI in this-procedure .

    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI DLGCLOSE  _DEFAULT-DISABLE
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
  HIDE FRAME DLGCLOSE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE print_qrCode DLGCLOSE 
PROCEDURE print_qrCode :
  define input parameter p-code as character no-undo .
    define variable v-arc as character no-undo .
    define variable v-cmd as character no-undo .  

    assign
      v-arc = search( "exe/qrgen.exe":U )
      .
    if v-arc = ? then 
    do:
      return error "Не найдена программа qrgen.exe" .
    end.   

    os-command silent value (v-arc + ' -size=128 -content="' + p-code + '"' + ' -filename="' + session:temp-directory + '\qr-code"') .
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE generate_qrCode DLGCLOSE  _DEFAULT-ENABLE
PROCEDURE generate_qrCode :
  define output parameter qr-code-out as character no-undo .

  define variable new-code as character no-undo .
  define variable v-code as character no-undo .
  
  v-code = string(v-cntxt-obj-code,"99999") + string(tt0-staff.staff-code,"999") + string(random( 11111 , 99999 )) .
  
  run adm/pswd-enc.p (input v-code, output new-code) .
  run base64-encode (new-code,output qr-code-out).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI DLGCLOSE  _DEFAULT-ENABLE
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
  ENABLE Btn_Close qr-code B-qrCode b-print 
      WITH FRAME DLGCLOSE.
  {&OPEN-BROWSERS-IN-QUERY-DLGCLOSE}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
PROCEDURE get-report-num :
  /*------------------------------------------------------------------------------
    Purpose:
    Parameters:  <none>
    Notes:
  ------------------------------------------------------------------------------*/
  define output parameter p-report-num as integer no-undo .

  do
    on error undo, return error return-value
    :
    run gbl/getrpnum.p (output p-report-num).
  end.

END PROCEDURE.

