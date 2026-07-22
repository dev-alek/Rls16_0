&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-sertif


/* Temp-Table and Buffer definitions                                    */
define temp-table tt-sertif no-undo
field Name_ as character
field BeginDate as datetime
field EndDate as datetime
field Thumbprint as character
field IssuerName as character
field OrganizationName as character 
field SerialNumber as character
field IsQualifiedElectronicSignature as character
field INN as character 
field KPP as character 
field JobTitle as character 
field CanEncrypt as character
.
define buffer buf_sertif for tt-sertif .



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-sertif 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник оснований для коррекции

Автор: Бахтадзе Наталья Викторовна
Дата создания: 20/04/95
Author: Bakhtadze Natalya
Creation date: 20/04/95

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input parameter  parparentproc as widget-handle no-undo .
define output parameter p-rid-list    as character no-undo   .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Справочник оснований для коррекции".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/r-pril.i new }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ gbl/prn-lib.i }
{ gbl/waitfram.i }
{ cmp/mrk-strf.i }
/* Local Variable Definitions ---                                       */

define variable log-res     as log       no-undo.
define variable rr          as recid     no-undo.
define variable v_type      as char      no-undo.
define variable v-is-deploy as logical   no-undo .
define variable v-rid-list  as character no-undo .
define variable v-sertif    as character no-undo .
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-sertif
&Scoped-define BROWSE-NAME br-sertif

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_pay-type

/* Definitions for BROWSE br-sertif                                     */
&Scoped-define FIELDS-IN-QUERY-br-sertif mark-string(recid(buf_sertif), v-sertif) buf_sertif.BeginDate buf_sertif.EndDate buf_sertif.Name_ buf_sertif.SerialNumber    
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-sertif   
&Scoped-define SELF-NAME br-sertif
&Scoped-define QUERY-STRING-br-sertif FOR EACH buf_sertif NO-LOCK     BY buf_sertif.BeginDate
&Scoped-define OPEN-QUERY-br-sertif OPEN QUERY {&SELF-NAME} FOR EACH buf_sertif NO-LOCK     BY buf_sertif.BeginDate.
&Scoped-define TABLES-IN-QUERY-br-sertif buf_sertif
&Scoped-define FIRST-TABLE-IN-QUERY-br-sertif buf_sertif


/* Definitions for DIALOG-BOX d-sertif                                  */
&Scoped-define OPEN-BROWSERS-IN-QUERY-d-sertif ~
    ~{&OPEN-QUERY-br-sertif}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-mark b-sel br-sertif 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Выход ":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-mark 
     LABEL "&*":L 
     SIZE 3 BY 1.

DEFINE BUTTON b-sel AUTO-GO 
     LABEL "Вы&бор ":L 
     SIZE 10 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-sertif FOR 
      buf_sertif SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-sertif
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-sertif d-sertif _FREEFORM
  QUERY br-sertif NO-LOCK DISPLAY
  mark-string(recid(buf_sertif), v-sertif) COLUMN-LABEL "*" FORMAT "X(1)":U
  buf_sertif.BeginDate COLUMN-LABEL "Дата начала" FORMAT "99.99.9999":U
  buf_sertif.EndDate COLUMN-LABEL "Дата окончания" FORMAT "99.99.9999":U
  buf_sertif.Name_ COLUMN-LABEL "Наименование" FORMAT "X(30)":U
  buf_sertif.SerialNumber COLUMN-LABEL "Серийный номер" FORMAT "X(30)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 96.5 BY 14.75 fit-last-column.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-sertif
     b-exit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 14
     br-sertif AT ROW 3 COL 1.5
     SPACE(0.37) SKIP(0.82)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Сертификаты":L.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-sertif
   FRAME-NAME                                                           */
/* BROWSE-TAB br-sertif b-sel d-sertif */
ASSIGN 
       FRAME d-sertif:SCROLLABLE       = FALSE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-sertif
/* Query rebuild information for BROWSE br-sertif
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_pay-type NO-LOCK
    BY X_pay-type.obj-name.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _OrdList          = "ub.pay-type.obj-name|yes"
     _Query            is OPENED
*/  /* BROWSE br-sertif */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-sertif
/* Query rebuild information for DIALOG-BOX d-sertif
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX d-sertif */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-sertif
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-sertif d-sertif
ON GO OF FRAME d-sertif /* Сертификаты */
DO:
    p-rid-list = v-rid-list.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark d-sertif
ON CHOOSE OF b-mark IN FRAME d-sertif /* * */
DO:
    define variable g-log as logical no-undo.
    if available buf_sertif then 
    do:
      v-sertif = buf_sertif.SerialNumber .
      { gbl/markstrn.i buf_sertif v-sertif }
      v-rid-list = string( buf_sertif.SerialNumber ) .
      g-log = {&browse-name}:refresh() .
      if last-event:function <> "mouse-select-dblclick" then 
      do:
        g-log = {&browse-name}:select-next-row ().
        apply "value-changed" to {&browse-name} in frame {&frame-name}.
      end.

    end.
    apply "entry" to {&browse-name} in frame {&frame-name}.


  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel d-sertif
ON CHOOSE OF b-sel IN FRAME d-sertif /* Выбор  */
DO:
    if ( available buf_sertif )
      AND ( v-rid-list = "" or b-mark:sensitive = no ) then
      v-rid-list = string( buf_sertif.SerialNumber ) .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-sertif
&Scoped-define SELF-NAME br-sertif
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-sertif d-sertif
ON DEFAULT-ACTION OF br-sertif IN FRAME d-sertif
DO:
    case yes:
      when  b-sel:sensitive THEN 
        apply "CHOOSE":U to b-sel.
    end case.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-sertif d-sertif
ON INSERT-MODE OF br-sertif IN FRAME d-sertif
DO:
    if b-mark:sensitive in frame {&frame-name} then
      APPLY "CHOOSE" to b-mark.
    else 
    do:
      if b-sel:sensitive in frame {&frame-name} then
        APPLY "CHOOSE" to b-sel.
    end.

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-sertif d-sertif
ON RETURN OF br-sertif IN FRAME d-sertif
DO:
    apply "DEFAULT-ACTION":U to self.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-sertif 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
  THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} 
  APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }
  run init-temp .
  run enable_UI in this-procedure .
  if p-rid-list eq "" then
  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus {&browse-name}.
END.
run disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-sertif  _DEFAULT-DISABLE
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
  HIDE FRAME d-sertif.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-sertif 
PROCEDURE enable_UI :
/* --------------------------------------------------------------------
    Purpose:     ENABLE the User Interface
    Parameters:  <none>
    Notes:       Here we display/view/enable the widgets in the
                 user-interface.  In addition, OPEN all queries
                 associated with each FRAME and BROWSE.
                 These statements here are based on the "Other
                 Settings" section of the widget Property Sheets.
     -------------------------------------------------------------------- */
  ENABLE
    br-sertif
    b-exit
    b-sel 
    WITH FRAME {&frame-name}.
  disable
    b-mark
  with frame {&frame-name} .  
      
  {&OPEN-BROWSERS-IN-QUERY-d-sertif}
  if available buf_sertif
    then log-res  = br-sertif:select-focused-row( ).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-temp d-sertif 
PROCEDURE init-temp :
/* --------------------------------------------------------------------
    Purpose:     ENABLE the User Interface
    Parameters:  <none>
    Notes:       Here we display/view/enable the widgets in the
                 user-interface.  In addition, OPEN all queries
                 associated with each FRAME and BROWSE.
                 These statements here are based on the "Other
                 Settings" section of the widget Property Sheets.
     -------------------------------------------------------------------- */
define variable vCertificates     as component-handle no-undo.
define variable vCertificate     as component-handle no-undo.
define variable mDiadocApi as component-handle no-undo.
/*define variable mReflector as component-handle no-undo.*/
define variable vCertificateName  as component-handle no-undo .
define variable vi as integer no-undo.
create "Diadoc.DiadocClient":U mDiadocApi no-error.
if mDiadocApi eq ?
then do:
   message "Не установлена библиотека Диадок" skip error-status:get-message(1)
   view-as alert-box.
   return.
end.
/*create "Diadoc.Reflector":U mReflector.*/
   /*Задаем параметры подлючения к серверу*/
   /*Получение списка сертификатов*/

   vCertificates = mDiadocApi:GetPersonalCertificates(true).
   if vCertificates:count = 1 then do:
     v-rid-list = vCertificates:GetItem(0):SerialNumber .
     apply "GO" to FRAME {&frame-name} .
   end.
   else do:  
   do vi = 1 to  vCertificates:count:
      vCertificate = vCertificates:GetItem(vi - 1).
/*      vCertificateName = mReflector:describe(vCertificate) .*/

      create tt-sertif .
      tt-sertif.Name_ = vCertificate:name .
      tt-sertif.BeginDate = vCertificate:begindate .
      tt-sertif.EndDate = vCertificate:enddate .
      tt-sertif.OrganizationName = vCertificate:OrganizationName .
      tt-sertif.SerialNumber = vCertificate:SerialNumber . 
      tt-sertif.Thumbprint  = vCertificate:Thumbprint .
   end.
   end. 
   {&OPEN-BROWSERS-IN-QUERY-d-sertif}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME