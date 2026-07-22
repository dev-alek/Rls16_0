&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-sel


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-staff NO-UNDO LIKE staff.
DEFINE TEMP-TABLE tt-staff-attr NO-UNDO LIKE staff-attr.
DEFINE BUFFER X_clients FOR clients.
DEFINE BUFFER X_person FOR person.
DEFINE BUFFER X_staff FOR staff.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-sel 
/*

$Revision: a44284873617, 2302, rls $
$Author: SSlivenko $
$Date: Fri Feb 14 16:31:04 2020 +0300 $
$Workfile: staffs.w $
$Archive: ref/staffs.w $

Справочник персонала

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/18/05
Author: Bakhtadze Natalya
Creation date: 10/18/05

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input parameter parparentproc as widget-handle no-undo .
define input parameter bttns  as char   no-undo .
DEFINE input parameter p-role AS CHARACTER NO-UNDO .
DEFINE input parameter p-db-num   like ub.db.db-num NO-UNDO .
DEFINE input parameter p-psn-code like ub.person.psn-code NO-UNDO .
define output parameter rid-list    as  char no-undo . /* список recid'ов выбранных человеков */

define variable vss-revision    as character no-undo init "$Revision: a44284873617, 2302, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Fri Feb 14 16:31:04 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: staffs.w $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/staffs.w $":U .
define variable vss-description as character no-undo init "Справочник персонала".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/r-pril.i new }
{ gbl/cur-time.i }
{ gbl/prn-lib.i }
{ gbl/waitfram.i }
{ gbl/gbclcode.i }
{ cmp/mrk-strf.i }
{ gbl/getcntxt.i def }
{ gbl/flt-def.i }
{ gbl/fltfield.i }
{ gbl/fltopend.i defproc }
{ str/defc-csh.i "NEW SHARED" }

/* Local Variable Definitions ---                                       */

define variable log-res as log no-undo.
define variable choice as log no-undo.

define variable cli-name as char no-undo.
define variable ri-str  as char no-undo.

define variable per-stts      like  ub.clients.stts     no-undo .
define variable glog as logical no-undo .
/*Бд для browse*/
define variable v-db-num like ub.db.db-num no-undo .
define variable v-date-end like ub.staff.date-end no-undo .
DEFINE VARIABLE v-role AS CHARACTER NO-UNDO.
define variable title0 as character no-undo .
DEFINE VARIABLE v-tab-order as character no-undo .
define variable v-doc-rec   as recid no-undo .
define variable v-role-name as character no-undo .
DEFINE VARIABLE add-option AS CHARACTER NO-UNDO.
DEFINE VARIABLE change-option AS CHARACTER NO-UNDO.
DEFINE VARIABLE delete-option AS CHARACTER NO-UNDO.
define variable sort-column-name as character no-undo .
define variable filter-label0 as character no-undo init "Список персонала" .
define variable filter-label as character no-undo init "Список персонала" .
define variable filter-point0 as character no-undo init "staffs" .
define variable filter-point as character no-undo init "staffs" .
define variable log-file-name as character no-undo init "send-cd.txt".
define variable v-view-log as logical no-undo .

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

&SCOPED-DEFINE sort-clmn_1 (mark-string ( INPUT RECID( X_staff), INPUT rid-list))
&scoped-define label-clmn_1 '*'
&SCOPED-DEFINE dyn_sort-clmn_1  substitute('dynamic-function(&1mark-string&1, RECID( X_staff), &1&2&1)', ~{&double-quote~},rid-list)
&SCOPED-DEFINE sort-clmn_2 X_staff.staff-code
&scoped-define label-clmn_2 'Код!перс.'
&SCOPED-DEFINE sort-clmn_3 get-staff-name ( X_clients.obj-name, X_clients.obj-code, X_clients.stts )
&SCOPED-DEFINE dyn_sort-clmn_3  substitute('dynamic-function(&1get-staff-name&1, X_clients.obj-name, X_clients.obj-code, X_clients.stts)', ~{&double-quote~})
&scoped-define label-clmn_3 'Имя'
&SCOPED-DEFINE sort-clmn_4 X_person.firm-name
&scoped-define label-clmn_4 'Организация'
&SCOPED-DEFINE sort-clmn_5 X_person.psn-code
&scoped-define label-clmn_5 'Код!физ.лица'
&SCOPED-DEFINE sort-clmn_6 X_staff.db-num
&scoped-define label-clmn_6 'БД!№'
&SCOPED-DEFINE sort-clmn_7 X_staff.date-start
&scoped-define label-clmn_7 'c'
&SCOPED-DEFINE sort-clmn_8 (IF X_staff.date-end = {&end-of-age} THEN '':u ELSE string(X_staff.date-end, '99/99/9999'))
&SCOPED-DEFINE dyn_sort-clmn_8 substitute('string(X_staff.date-end)')
&scoped-define label-clmn_8 'по'

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-sel
&Scoped-define BROWSE-NAME br-staff

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_staff X_person X_clients

/* Definitions for BROWSE br-staff                                      */
&Scoped-define FIELDS-IN-QUERY-br-staff {&sort-clmn_1} {&sort-clmn_2} {&sort-clmn_3} {&sort-clmn_4} {&sort-clmn_5} {&sort-clmn_6} {&sort-clmn_7} {&sort-clmn_8}   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-staff {&sort-clmn_2}   
&Scoped-define SELF-NAME br-staff
&Scoped-define QUERY-STRING-br-staff FOR EACH X_staff NO-LOCK , ~
       first X_person NO-LOCK   WHERE X_person.psn-code = X_staff.num-code, ~
         first X_clients NO-LOCK WHERE X_clients.obj-type = {&prs} AND X_clients.obj-code = X_staff.num-code BY X_staff.staff-code
&Scoped-define OPEN-QUERY-br-staff OPEN QUERY {&SELF-NAME} FOR EACH X_staff NO-LOCK , ~
       first X_person NO-LOCK   WHERE X_person.psn-code = X_staff.num-code, ~
         first X_clients NO-LOCK WHERE X_clients.obj-type = {&prs} AND X_clients.obj-code = X_staff.num-code BY X_staff.staff-code.
&Scoped-define TABLES-IN-QUERY-br-staff X_staff X_person X_clients
&Scoped-define FIRST-TABLE-IN-QUERY-br-staff X_staff
&Scoped-define SECOND-TABLE-IN-QUERY-br-staff X_person
&Scoped-define THIRD-TABLE-IN-QUERY-br-staff X_clients


/* Definitions for DIALOG-BOX d-sel                                     */
&Scoped-define OPEN-BROWSERS-IN-QUERY-d-sel ~
    ~{&OPEN-QUERY-br-staff}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-mark b-sel b-add b-lkp b-chg b-del ~
b-qrCode b-print b-hist b-sch b-help RS-status b-arch f-db-num f-staff-code ~
br-staff mark-num 
&Scoped-Define DISPLAYED-OBJECTS RS-status f-db-num f-staff-code mark-num 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-add 
       MENU-ITEM m-add-new      LABEL "Новое физ-лицо"
       MENU-ITEM m-add-old      LABEL "Выбрать из справочника".

DEFINE MENU MENU-b-chg 
       MENU-ITEM m_psn          LABEL "Физ.лицо"      
       MENU-ITEM m_staff        LABEL "Данные персонала".

DEFINE MENU MENU-b-chg-2 
       MENU-ITEM m_psn-2        LABEL "Физ.лицо"      
       MENU-ITEM m_staff-2      LABEL "Данные персонала".

DEFINE MENU MENU-b-del 
       MENU-ITEM m_client       LABEL "Физ.лицо"      
       MENU-ITEM m_delstaff     LABEL "Данные персонала".


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add 
     LABEL "&Добавить" 
     SIZE 10 BY 1.

DEFINE BUTTON b-arch 
     LABEL "&Архив" 
     SIZE 10 BY 1.

DEFINE BUTTON b-chg 
     LABEL "&Изменить" 
     SIZE 10 BY 1.

DEFINE BUTTON b-del 
     LABEL "&Удалить" 
     SIZE 10 BY 1.

DEFINE BUTTON b-help 
     LABEL "Помо&щь":L 
     SIZE 3 BY 1.

DEFINE BUTTON b-hist 
     LABEL "Ис&тория" 
     SIZE 3 BY 1.

DEFINE BUTTON b-lkp 
     LABEL "&Просмотр" 
     SIZE 10 BY 1.

DEFINE BUTTON b-mark 
     LABEL "&*" 
     SIZE 3 BY 1.

DEFINE BUTTON b-print 
     LABEL "Пе&чать":L 
     SIZE 3 BY 1.

DEFINE BUTTON b-qrCode 
     LABEL "&QR-код кассира" 
     SIZE 15 BY 1.

DEFINE BUTTON b-quit AUTO-GO 
     LABEL "&Выход ":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-sch 
     LABEL "&Фильтр" 
     SIZE 3 BY 1.

DEFINE BUTTON b-sel AUTO-GO 
     LABEL "Вы&бор ":L 
     SIZE 10 BY 1.

DEFINE VARIABLE f-db-num AS INTEGER FORMAT ">>>>9":U INITIAL 0 
     LABEL "№ БД" 
     VIEW-AS FILL-IN 
     SIZE 7 BY 1 NO-UNDO.

DEFINE VARIABLE f-staff-code AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0 
     LABEL "Код" 
     VIEW-AS FILL-IN 
     SIZE 9.5 BY 1 NO-UNDO.

DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>9":U INITIAL 0 
      VIEW-AS TEXT 
     SIZE 4.75 BY .75
     FGCOLOR 10  NO-UNDO.

DEFINE VARIABLE RS-status AS INTEGER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Все", 0,
"Текущие", 1
     SIZE 28 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-staff FOR 
      X_staff, 
      X_person, 
      X_clients SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-staff
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-staff d-sel _FREEFORM
  QUERY br-staff NO-LOCK DISPLAY
      {&sort-clmn_1} COLUMN-LABEL {&label-clmn_1} FORMAT "x(1)":U
{&sort-clmn_2} COLUMN-LABEL {&label-clmn_2} FORMAT ">>>>9":U
{&sort-clmn_3} COLUMN-LABEL {&label-clmn_3} FORMAT "x(40)":U
{&sort-clmn_4} COLUMN-LABEL {&label-clmn_4} FORMAT "x(20)":U
{&sort-clmn_5} COLUMN-LABEL {&label-clmn_5} FORMAT ">>>>>>>>9":U
{&sort-clmn_6} COLUMN-LABEL {&label-clmn_6} FORMAT ">>>>9":U
{&sort-clmn_7} COLUMN-LABEL {&label-clmn_7} FORMAT "99/99/9999":U
{&sort-clmn_8} COLUMN-LABEL {&label-clmn_8} FORMAT "X(10)":U
ENABLE {&sort-clmn_2}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 15.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-sel
     b-quit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 15
     b-add AT ROW 1 COL 25
     b-lkp AT ROW 1 COL 35
     b-chg AT ROW 1 COL 45
     b-del AT ROW 1 COL 55
     b-qrCode AT ROW 1 COL 65 WIDGET-ID 2
     b-print AT ROW 1 COL 86
     b-hist AT ROW 1 COL 89
     b-sch AT ROW 1 COL 92
     b-help AT ROW 1 COL 95
     RS-status AT ROW 2 COL 15.5 NO-LABEL
     b-arch AT ROW 2 COL 45
     f-db-num AT ROW 3 COL 24.5 COLON-ALIGNED
     f-staff-code AT ROW 3 COL 42 COLON-ALIGNED
     br-staff AT ROW 4 COL 1
     mark-num AT ROW 2.96 COL 3.5 COLON-ALIGNED NO-LABEL
     SPACE(88.75) SKIP(15.41)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "ПЕРСОНАЛ":L.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Temp-Tables and Buffers:
      TABLE: tt-staff T "?" NO-UNDO ub staff
      TABLE: X_clients B "?" ? ub clients
      TABLE: X_person B "?" ? ub person
      TABLE: X_staff B "?" ? ub staff
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-sel
   FRAME-NAME                                                           */
/* BROWSE-TAB br-staff f-staff-code d-sel */
ASSIGN 
       FRAME d-sel:SCROLLABLE       = FALSE
       FRAME d-sel:PRIVATE-DATA     = 
                "DLGCLOSE".

ASSIGN 
       b-add:POPUP-MENU IN FRAME d-sel       = MENU MENU-add:HANDLE.

ASSIGN 
       b-arch:HIDDEN IN FRAME d-sel           = TRUE.

ASSIGN 
       b-chg:POPUP-MENU IN FRAME d-sel       = MENU MENU-b-chg:HANDLE.

ASSIGN 
       b-del:POPUP-MENU IN FRAME d-sel       = MENU MENU-b-del:HANDLE.

ASSIGN 
       b-qrCode:POPUP-MENU IN FRAME d-sel       = MENU MENU-b-chg-2:HANDLE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-staff
/* Query rebuild information for BROWSE br-staff
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_staff NO-LOCK ,
first X_person NO-LOCK
  WHERE X_person.psn-code = X_staff.num-code,
  first X_clients NO-LOCK WHERE X_clients.obj-type = {&prs}
AND X_clients.obj-code = X_staff.num-code
BY X_staff.staff-code.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _OrdList          = "ub.person.cashier|yes"
     _Where[1]         = "person.cashier <> 0"
     _JoinCode[2]      = "clients.obj-type = "
     _Query            is OPENED
*/  /* BROWSE br-staff */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-sel d-sel
ON ENDKEY OF FRAME d-sel /* ПЕРСОНАЛ */
DO:
/*
, END-ERROR of frame d-sel
, GO of frame d-sel  DO:
  */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME B-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-quit d-sel
ON CHOOSE OF B-quit IN FRAME d-sel /* Ввод */
DO:
  define variable recid_attr as character no-undo .
  /*Отправка qrCode на кассу*/
  for each tt-staff-attr :
    find first X_staff no-lock where X_staff.staff-code = tt-staff-attr.staff-code and
    X_staff.role = tt-staff-attr.role no-error .
    find first X_clients NO-LOCK WHERE X_clients.obj-type = {&prs}
        AND X_clients.obj-code = X_staff.psn-code no-error .
          create cash-cash.
          assign
          cash-cash.cash-code = X_staff.staff-code
          cash-cash.cash-name = X_clients.obj-name
          cash-cash.stts = (if X_staff.date-end < today then 1 else 0)
          cash-cash.psn-code = X_staff.psn-code
          cash-cash.psswd = X_staff.password
          .
          find first ub.staff-attr no-lock where ub.staff-attr.attr-code = "CashierQRCode"
          and ub.staff-attr.role = X_staff.role 
          and ub.staff-attr.role-level = X_staff.role-level
          and ub.staff-attr.staff-code = X_staff.staff-code no-error .
          if available (ub.staff-attr) then 
          recid_attr = recid_attr + {&comma-char} + string(recid(ub.staff-attr)) .
          
   end.
  if can-find(first cash-cash) then do:
          
  /* Отсылка на кассу */
      run str/diallog.w (
            input parparentproc
          , input this-procedure
          , input "str/send-all.p":U
          , input ( v-cntxt-obj-type + {&delim-par} + string(v-cntxt-obj-code) + {&delim-par} + 'U':U + {&delim-par} + 'qrCode' + {&delim-par} + 'Отсылка QR-code на кассы':U + {&delim-par} + string(recid_attr))
          , input ? /*p-auto-go*/
          , input "":U
          , input substitute("Отсылка QR-code на кассы &1", {&cd-type-IBm-XML})
        ) no-error.

  end.
END.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add d-sel
ON CHOOSE OF b-add IN FRAME d-sel /* Добавить */
DO:
DEFINE VARIABLE v-option AS CHARACTER NO-UNDO.
IF add-option = '':U THEN DO:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
   if error-status :error then do: return no-apply. end.
END.
if add-option = '':U then return no-apply.
v-option = add-option.
add-option = '':U.
run proc-b-add in this-procedure ( input v-option) no-error.
if error-status:error then do:
   return no-apply.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-arch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-arch d-sel
ON CHOOSE OF b-arch IN FRAME d-sel /* Архив */
DO:
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
DEFINE VARIABLE v-cashier-db-num like ub.clients.db-num no-undo .
define variable v-cashier-code as integer no-undo .
define buffer shop_cli for ub.clients .

  if available X_person then do:
    run calc-arch in this-procedure .
    if return-value <> "0" then do:
        run cur-time in this-procedure ( output v-today, output v-time) .
        assign
        v-cashier-code = X_staff.staff-code
        .
        run ref/cshrsarc.w (
                        input parparentproc
                       ,input X_staff.staff-code
                       ,input  X_person.psn-code ) .
        if month(v-today) > 1 then do:
          FOR EACH ub.cshr-month WHERE
                (ub.cshr-month.cashier-psn-code = X_person.psn-code
                or ub.cshr-month.cashier-psn-code = 0)
                AND
                ub.cshr-month.cshr-code = v-cashier-code AND
                ub.cshr-month.year_ = year( v-today ) AND
                (ub.cshr-month.month_ = month( v-today ) or ub.cshr-month.month_ = month(v-today) - 1):
            if ub.cshr-month.obj-code <> 0 then do:
              find first shop_cli no-lock where
                         shop_cli.obj-type = cshr-month.obj-type .
              assign
              v-cashier-db-num = shop_cli.db-num
              .
            end.
            else v-cashier-db-num = ?.
            if v-cashier-db-num = ? or v-cashier-db-num = v-cntxt-db-num then
            delete cshr-month .
          END.
       end.
       else do:
          FOR EACH cshr-month WHERE
                (cshr-month.cashier-psn-code = X_person.psn-code
                or cshr-month.cashier-psn-code = 0)
                AND
                cshr-month.cshr-code = v-cashier-code AND
                (cshr-month.year_ = year( v-today ) AND
                cshr-month.month_ = month( v-today )) or
                (cshr-month.year_ = year( v-today ) - 1 AND
                cshr-month.month_ = 12 ):
            if cshr-month.obj-code <> 0 then do:
              find first shop_cli no-lock where
                         shop_cli.obj-type = cshr-month.obj-type .
              assign
              v-cashier-db-num = shop_cli.db-num
              .
            end.
            else v-cashier-db-num = ?.
            if v-cashier-db-num = ? or v-cashier-db-num = v-cntxt-db-num then

            delete cshr-month .
          END.

       end.
    end.
  end.
  apply "entry" to br-staff .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg d-sel
ON CHOOSE OF b-chg IN FRAME d-sel /* Изменить */
DO:
DEFINE VARIABLE v-option AS CHARACTER NO-UNDO.
IF change-option = '':U THEN DO:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
   if error-status :error then do: return no-apply. end.
END.
if change-option = '':U then return no-apply.
v-option = change-option.
change-option = '':U.
run proc-b-chg in this-procedure (input v-option) no-error.
if error-status:error then do:
  return no-apply.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del d-sel
ON CHOOSE OF b-del IN FRAME d-sel /* Удалить */
DO:
DEFINE VARIABLE v-option AS CHARACTER NO-UNDO.
IF delete-option = '':U THEN DO:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
   if error-status :error then do: return no-apply. end.
END.
if delete-option = '':U then return no-apply.
v-option = delete-option.
delete-option = '':U.
run proc-b-del in this-procedure ( input v-option) no-error.
if error-status:error then do:
  v-option ='':U.
  return no-apply.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist d-sel
ON CHOOSE OF b-hist IN FRAME d-sel /* История */
DO:
define variable v-rid-list as character no-undo .
    if available X_staff THEN

    run ref/cstaffs.w (
                      input parparentproc
                    , input v-cntxt-obj-type  /*p-curr-obj-type*/
                    , input v-cntxt-obj-code  /*p-curr-obj-code*/
                    , input "":U /*bttns*/
                    , "one":U /*p-mode*/
                    , input X_staff.role
                    , input X_staff.role-level
                    , input X_staff.work-place
                    , input X_staff.staff-code
                    , input X_staff.date-start
                    , input-output v-rid-list  ) no-error .
    apply "entry" to br-staff .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp d-sel
ON CHOOSE OF b-lkp IN FRAME d-sel /* Просмотр */
DO:
define variable ri as recid no-undo .
  if available X_staff then do:
    run ref/showcli.p (
      input parParentProc
      ,input X_clients.obj-type /* p-obj-type */
      ,input X_clients.obj-code /* p-obj-code */
      ).
  end.
  apply "entry" to br-staff .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark d-sel
ON CHOOSE OF b-mark IN FRAME d-sel /* * */
DO:
define variable glog as logical no-undo .
if available X_staff then  do:
{ gbl/markstrn.i X_staff rid-list }
glog = br-staff:refresh() .
if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
  glog = br-staff:select-next-row ().
  apply "iteration-changed" to br-staff in frame {&frame-name}.
end.
if num-entries( rid-list ) = 0 then
    hide mark-num in frame {&frame-name}.
else
    disp num-entries( rid-list ) @ mark-num with frame {&frame-name}.
end.
apply "entry" to br-staff in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print d-sel
ON CHOOSE OF b-print IN FRAME d-sel /* Печать */
DO:
define variable Line                    as char         no-undo.
define variable cli-attr                 as char         no-undo.
define variable ii                  as integer   no-undo.
define variable ri as recid no-undo .
DEFINE VARIABLE v-work-place AS CHARACTER no-undo.
define variable v-role-level as character no-undo .
define variable v-obj-type as character no-undo .
DEFINE VARIABLE v-date-end-chr AS CHARACTER NO-UNDO.
DEFINE FRAME List
X_staff.staff-code column-label "Код" format ">>>>9"
X_person.name1 column-label "Имя " format "X(60)"
X_person.firm-name column-label "Организация" format "x(30)"
X_staff.psn-code column-label "Код физ.лица" format ">>>>>>>>9"
v-work-place COLUMN-LABEL "Работает" FORMAT "X(15)"
X_staff.date-start COLUMN-LABEL "c" FORMAT "99/99/9999"
v-date-end-chr COLUMN-LABEL "по" FORMAT "X(10)"
HEADER
cur-time-print() AT 5 format "X(35)"
string( "Страница " + string( PAGE-NUMBER( PrnLibStream ) , ">>9") )
AT 85 format "X(15)" SKIP
Line format "x(105)" AT 1
with width {&A4_CW} down use-text stream-io no-box .

if num-results( "br-staff" ) = 0 then do:
    message "Список  П У С Т !" skip view-as alert-box information .
    return no-apply .
end.

if session:set-wait-state( "compiler" ) then .
Line = fill( "-" , 150 ) .
/*
    Это из-за того, что в QUERY br-staff используется index reposition и,
    как следствие, не работает GET first br-staff  ( ошибка 3157 )
*/
ri = recid(X_staff).
DO WHILE available X_staff :
  GET prev br-staff NO-LOCK .
END.
GET next br-staff NO-LOCK .
ii = 1 .
run prn-lib-open-stream  in this-procedure (
                                          input parParentProc
                                          ,input {&CS_PS}
                                          ,input yes /*p-is-stream*/
                                          ,input no /*p-append*/
                                          ).

FORM HEADER
Line format "X(105)" SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME CliBottomFrame width {&A4_CW} PAGE-BOTTOM NO-LABELS no-box.
VIEW stream PrnLibStream FRAME CliBottomFrame .
PUT stream PrnLibStream unformatted space(20) frame {&frame-name}:title skip.
FORM with frame List .
DO WHILE available X_staff :
  assign
  v-role-level =  X_staff.role-level
  no-error .
  if p-psn-code = 0 then do:
    CASE X_staff.role-level:
      when {&role-level-db} then do:
        v-work-place = substitute("БД &1", X_staff.db-num).
      end.
      when {&role-level-firm} then do:
        v-work-place = substitute("Фирма &1", X_staff.host-code).
      end.
      when {&role-level-object} then do:
        v-work-place =  X_staff.work-place.
      end.
      otherwise do:
        v-work-place = ''.
      end.
    END CASE.
  end.
  else do:
    v-work-place = gbclcode-get-position ( input X_staff.role
                                          ,input X_staff.role-level
                                          ,input X_staff.work-place
                                          ,input X_staff.staff-code ).

  end.
  DISPLAY stream PrnLibStream
  X_staff.staff-code
  get-staff-name ( X_clients.obj-name, X_clients.obj-code, X_clients.stts ) @ X_person.name1
  X_person.firm-name
  X_staff.psn-code
  v-work-place
  X_staff.date-start
  IF X_staff.date-end = {&end-of-age} THEN "":U ELSE string(X_staff.date-end, "99/99/9999") @ v-date-end-chr
  with frame List .
  DOWN stream PrnLibStream 1 with frame List .
  ii =  ii + 1 .
  if ( ( ii modulo 10 ) = 0 ) AND ( ii >= 10 ) then
    run waitfram-show in this-procedure ( input "Просмотрено строк : " + string( ii ) ) .
  GET next br-staff NO-LOCK .
END.
PUT stream PrnLibStream Line format "X(105)" SKIP.
HIDE stream PrnLibStream FRAME CliBottomFrame .
output stream PrnLibStream close .
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                        input parParentProc
                                        ,input 0
                                        ).

reposition br-staff to recid ri no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-qrCode
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-qrCode d-sel
ON CHOOSE OF b-qrCode IN FRAME d-sel /* QR-код кассира */
DO:
  define variable v-update as logical no-undo .
  define variable attr-value as character no-undo .
  
  if available (X_staff) then do:
    buffer-copy X_staff to tt-staff .
    find first ub.staff-attr no-lock where ub.staff-attr.attr-code = "CashierQRCode" and
    ub.staff-attr.date-start <= today and
    ub.staff-attr.role = X_staff.role and
    ub.staff-attr.staff-code = X_staff.staff-code no-error .
    attr-value = if available (ub.staff-attr) then ub.staff-attr.attr-value else "" .
    run ref\view-qrCode.w(parparentproc, input-output attr-value, input table tt-staff, output v-update).
  if v-update then do:
    find first tt-staff-attr no-lock where tt-staff-attr.attr-code = "CashierQRCode" and
    tt-staff-attr.date-start = today and
    tt-staff-attr.role = X_staff.role and
    tt-staff-attr.staff-code = X_staff.staff-code no-error .
    if not available (tt-staff-attr) then do:
      create tt-staff-attr .
      assign
      tt-staff-attr.attr-code = "CashierQRCode"
      tt-staff-attr.date-start = today
      tt-staff-attr.role = X_staff.role
      tt-staff-attr.role-level = X_staff.role-level
      tt-staff-attr.staff-code = X_staff.staff-code
      .
    end.
    tt-staff-attr.attr-value = attr-value .
  end.
  end.
  else do:
    message "Не выбран кассир."
    view-as alert-box.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sch d-sel
ON CHOOSE OF b-sch IN FRAME d-sel /* Фильтр */
DO:
    run proc-b-sch IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:error THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel d-sel
ON CHOOSE OF b-sel IN FRAME d-sel /* Выбор  */
DO:
    if ( available X_staff ) AND ( rid-list = "" ) then
        rid-list = string( recid( X_staff ) ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-staff
&Scoped-define SELF-NAME br-staff
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-staff d-sel
ON MOUSE-SELECT-DBLCLICK OF br-staff IN FRAME d-sel
OR INSERT-MODE  OF br-staff IN FRAME d-sel DO:
    if can-do(bttns, "b-mark") then
    apply "choose" to b-mark in frame {&frame-name} .
    else if can-do( bttns, "b-sel" ) then
        apply "choose" to b-sel in frame {&frame-name} .
    else
        apply "choose" to b-lkp in frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-staff d-sel
ON RETURN OF br-staff IN FRAME d-sel
DO:
    if can-do( bttns, "b-sel" ) then
        apply "choose" to b-sel in frame {&frame-name} .
    else
        apply "choose" to b-lkp in frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-db-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-db-num d-sel
ON RETURN OF f-db-num IN FRAME d-sel /* № БД */
DO:
  DEFINE VARIABLE v-int AS INTEGER NO-UNDO.
  DEFINE BUFFER buf_db FOR ub.db.
  ASSIGN
  f-db-num
  v-int = f-db-num
  .
  IF v-int <> ? THEN DO:
      FIND FIRST buf_db NO-LOCK WHERE
                buf_db.db-num = v-int NO-ERROR.
      IF NOT AVAILABLE buf_db THEN DO:
          MESSAGE
          substitute("Нет БД № &1", f-db-num)
          VIEW-AS ALERT-BOX ERROR.
          RETURN NO-APPLY.
      END.
  END.
  assign
  v-db-num = f-db-num.
  run OpenBr IN THIS-PROCEDURE ( INPUT yes, INPUT no, INPUT '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-staff-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-staff-code d-sel
ON RETURN OF f-staff-code IN FRAME d-sel /* Код */
DO:
  run proc-find_staff-code in THIS-PROCEDURE ( INPUT no, input frame {&frame-name} f-staff-code) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-add-new
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-add-new d-sel
ON CHOOSE OF MENU-ITEM m-add-new /* Новое физ-лицо */
DO:
DEFINE VARIABLE v-option AS CHARACTER NO-UNDO.
  ASSIGN
  add-option = "new":U.
  run proc-b-add IN THIS-PROCEDURE ( INPUT add-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      ASSIGN
      add-option = '':U.
      RETURN NO-APPLY.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-add-old
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-add-old d-sel
ON CHOOSE OF MENU-ITEM m-add-old /* Выбрать из справочника */
DO:
DEFINE VARIABLE v-option AS CHARACTER NO-UNDO.
ASSIGN
 add-option = "old":U.
 run proc-b-add IN THIS-PROCEDURE ( INPUT add-option) NO-ERROR.
 IF ERROR-STATUS:ERROR THEN DO:
     ASSIGN
     add-option = '':U.
     RETURN NO-APPLY.
 END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_client
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_client d-sel
ON CHOOSE OF MENU-ITEM m_client /* Физ.лицо */
DO:
  ASSIGN
  delete-option = {&prs}.
  APPLY "CHOOSE" TO b-del IN FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_delstaff
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_delstaff d-sel
ON CHOOSE OF MENU-ITEM m_delstaff /* Данные персонала */
DO:

 ASSIGN
 delete-option = 'staff'.
 APPLY "CHOOSE" TO b-del IN FRAME {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_psn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_psn d-sel
ON CHOOSE OF MENU-ITEM m_psn /* Физ.лицо */
DO:
  ASSIGN
  change-option = {&prs}.
  APPLY "CHOOSE" TO b-chg IN FRAME {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_psn-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_psn-2 d-sel
ON CHOOSE OF MENU-ITEM m_psn-2 /* Физ.лицо */
DO:
  ASSIGN
  change-option = {&prs}.
  APPLY "CHOOSE" TO b-chg IN FRAME {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_staff
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_staff d-sel
ON CHOOSE OF MENU-ITEM m_staff /* Данные персонала */
DO:
  ASSIGN
  change-option = 'staff'.
  APPLY "CHOOSE" TO b-chg  IN FRAME {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_staff-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_staff-2 d-sel
ON CHOOSE OF MENU-ITEM m_staff-2 /* Данные персонала */
DO:
  ASSIGN
  change-option = 'staff'.
  APPLY "CHOOSE" TO b-chg  IN FRAME {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-status
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-status d-sel
ON VALUE-CHANGED OF RS-status IN FRAME d-sel
DO:
  ASSIGN
  rs-status
  .
  assign
  v-date-end = (IF rs-status = 0 THEN ? ELSE {&end-of-age}) .
  run OpenBr IN THIS-PROCEDURE ( INPUT yes, INPUT no, INPUT '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-sel 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/srt-clmd.i
&browse-name = "br-staff"
&frame-name  = {&frame-name}
&table-name = "X_staff"
&ext-col = 8
&start-column  = 2
&label-clmn_1  = "{&label-clmn_1}"
&sort-clmn_1   = "{&sort-clmn_1}"
&dyn_sort-clmn_1   = "{&dyn_sort-clmn_1}"
&label-clmn_2  = "{&label-clmn_2}"
&sort-clmn_2   = "{&sort-clmn_2}"
&label-clmn_3  = "{&label-clmn_3}"
&sort-clmn_3   = "{&sort-clmn_3}"
&dyn_sort-clmn_3   = "{&dyn_sort-clmn_3}"
&label-clmn_4  = "{&label-clmn_4}"
&sort-clmn_4   = "{&sort-clmn_4}"
&label-clmn_5  = "{&label-clmn_5}"
&sort-clmn_5   = "{&sort-clmn_5}"
&label-clmn_6  = "{&label-clmn_6}"
&sort-clmn_6   = "{&sort-clmn_6}"
&label-clmn_7  = "{&label-clmn_7}"
&sort-clmn_7   = "{&sort-clmn_7}"
&label-clmn_8  = "{&label-clmn_8}"
&sort-clmn_8   = "{&sort-clmn_8}"
&dyn_sort-clmn_8   = "{&dyn_sort-clmn_8}"

&open-query = "run OpenBr in this-procedure ( INPUT yes, INPUT no, INPUT '':U)."
&open-query-otherwise = "run OpenBr in this-procedure ( INPUT yes, INPUT no, INPUT '':U)."
&re-move-clmn = "no"
&mv-brw-default = "no"
&sort-column-name     = "sort-column-name"
}
{ gbl/setfltnm.i }

{ gbl/app_help.i }
{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-del }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }
{ gbl/hot-key.i b-print }

{ gbl/brwrepos.i
  &line-num=5
}
{ ref/tabhndmv.i v-tab-order }
{ gbl/rethndmv.i v-tab-order }
{ gbl/brwrefre.i "v-doc-rec = ?. if available X_staff then assign v-doc-rec = recid(X_staff) no-error. Run OpenBr in this-procedure ( INPUT yes, INPUT no, INPUT '':U). reposition br-staff to recid v-doc-rec no-error. ~
              APPLY 'entry' to br-staff. APPLY 'VALUE-CHANGED' to br-staff. v-doc-rec = ?. " }

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   { gbl/getcntxt.i get }
    if v-cntxt-db-num <> 0
    or (v-cntxt-db-num = 0  and p-db-num = 0)
    then do:
      assign
      p-db-num = v-cntxt-db-num
      v-db-num = p-db-num
      .
    end.

    run enable_UI  in this-procedure .
    HIDE mark-num in frame {&frame-name} .
    WAIT-FOR GO OF FRAME {&FRAME-NAME}.

END.
run disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-arch d-sel 
PROCEDURE calc-arch :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable StartMonth  like ub.cshr-month.month_ no-undo .
define variable StartYear   like ub.cshr-month.year_       no-undo .
define variable StartMonth-psn  like ub.cshr-month.month_ no-undo .
define variable StartYear-psn   like ub.cshr-month.year_       no-undo .
define variable StartDate   as date no-undo .
define variable StartDate-psn   as date no-undo .

define variable ChkMonth as integer no-undo.
define variable ChkYear as integer no-undo.
define variable DateBuf-Start as date no-undo .
define variable DateBuf-End as date no-undo .
define variable EndDay_ as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
DEFINE VARIABLE v-v12-3 as date no-undo .
define variable v-out-totchk  as integer no-undo .
define variable v-out-totsum  as decimal no-undo .
define variable v-out-count   as integer no-undo .
define variable v-out-qnty    as decimal no-undo .
define variable v-out-sum     as decimal no-undo .
define variable v-ret-totchk  as integer no-undo .
define variable v-ret-totsum  as decimal no-undo .
define variable v-ret-count   as integer no-undo .
define variable v-ret-qnty    as decimal no-undo .
define variable v-ret-sum     as decimal no-undo .


define buffer shop_cli for ub.clients.
find first ub.upgrade no-lock where
           ub.upgrade.db-num = v-db-num
      and  ub.upgrade.version-num = "12.3":U no-error .
assign
StartDate = ?
StartDate-psn = ?
v-db-num = v-cntxt-db-num
v-v12-3 = if available ub.upgrade then ub.upgrade.upgdate else ?
.
/*сначала ищем по старым записям архивам до upgrade на 12.3*/
FIND FIRST ub.cshr-month WHERE
            ub.cshr-month.cshr-code = X_staff.staff-code
        AND ub.cshr-month.cashier-psn-code = 0
NO-LOCK NO-ERROR .
if available ub.cshr-month then do:
  if ub.cshr-month.month_ < 12 then do:
    assign
        StartMonth = ub.cshr-month.month_ + 1
        StartYear = ub.cshr-month.year_ .
  end.
  else do:
    assign
        StartMonth = 1
        StartYear = ub.cshr-month.year_ + 1 .
  end.
  StartDate = date( StartMonth, 1, StartYear ) .
end.
/*теперь новые записи*/
for each  cshr-month NO-LOCK WHERE
            cshr-month.cshr-code = X_staff.staff-code
        AND cshr-month.cashier-psn-code = X_person.psn-code:
  if StartDate-psn = ? or
    Startdate-psn > date(cshr-month.month_, 1, cshr-month.year_) then do:
    if cshr-month.month_ < 12 then do:
      assign
          StartMonth-PSN = cshr-month.month_ + 1
          StartYear-PSN = cshr-month.year_ .
    end.
    else do:
      assign
          StartMonth-PSN = 1
          StartYear-PSN = cshr-month.year_ + 1 .
    end.
    StartDate-PSN = date( StartMonth-PSN, 1, StartYear-pSN ) .
  end.
END.
if startdate = ? or startdate-psn = ? then do:
  FOR EACH ub.shop NO-LOCK :
    FIND LAST ub.chk-doc NO-LOCK WHERE
            ub.chk-doc.obj-type = {&shop} AND
            ub.chk-doc.obj-code = shop.obj-code AND
            ub.chk-doc.cashier = X_staff.staff-code
            use-index cash-desk no-error.
    if available ub.chk-doc then do:
      if ub.chk-doc.cashier-psn-code = ? then do:
        if StartDate = ? then do:
          assign
          StartDate = date( month( chk-doc.chk-date ), 1, year( chk-doc.chk-date ) ) .
        end.
        else do:
          if StartDate > chk-doc.chk-date then do:
            assign
            StartDate = date( month( chk-doc.chk-date ), 1, year( chk-doc.chk-date ) )
            .
          end.
        end.
      end. /*if chk-doc.cashier-psn-code = ? */
      if chk-doc.cashier-psn-code <> ? and chk-doc.cashier-psn-code = X_person.psn-code then do:
        if StartDate-psn = ? then do:
          assign
          StartDate-psn = date( month( chk-doc.chk-date ), 1, year( chk-doc.chk-date ) ) .
        end.
        else do:
          if StartDate-psn > chk-doc.chk-date then do:
            assign
            StartDate-psn = date( month( chk-doc.chk-date ), 1, year( chk-doc.chk-date ) )
            .
          end.
        end.
      end. /*if chk-doc.cashier-psn-code <> ? and chk-doc.cashier-psn-code = X_person.psn-code then do:*/
    END. /*if avail chk-doc*/
  END . /*for each shop*/
  if startdate <> ? and startdate-psn = ? then do:
    if v-v12-3 = ? then v-v12-3 = Startdate.
    /*на границу чеков с заполненными cashier-psn-code не наткнулись*/
    FOR EACH shop_cli NO-LOCK where
            shop_cli.obj-type = {&shop}
        AND  shop_cli.db-num = v-cntxt-db-num,
        EACH chk-doc NO-LOCK WHERE
              chk-doc.obj-type = {&shop} AND
              chk-doc.obj-code = shop_cli.obj-code AND
              chk-doc.cashier = X_staff.staff-code AND
              chk-doc.chk-date > v-v12-3
    by chk-doc.chk-date descending
    by chk-doc.chk-time descending:
      if chk-doc.cashier-psn-code <> ? and chk-doc.cashier-psn-code <> X_person.psn-code then NEXT.
      if StartDate-psn = ? then do:
        assign
        StartDate-psn = date( month( chk-doc.chk-date ), 1, year( chk-doc.chk-date ) ) .
      end.
      else do:
        if StartDate-psn > chk-doc.chk-date then do:
          assign
          StartDate-psn = date( month( chk-doc.chk-date ), 1, year( chk-doc.chk-date ) )
          .
        end.
      end.
    END . /*for each shop_cli*/
  end. /*startdate-psn = ?*/
end.
if StartDate = ? and startdate-psn = ? then do:
  message
  "Архивы по данному кассиру пусты."
  view-as alert-box INFORMATION .
  return "0" .
end.

run waitfram-show in this-procedure ( input "Подождите ..." ) .
run cur-time in this-procedure ( output v-today, output v-time).
assign
v-v12-3 = (if StartDate-psn <> ? then startdate-psn else v-today)
.
DO TRANSACTION
ON STOP undo, return no-apply
ON ERROR undo, return no-apply
ON END-KEY undo, return no-apply :
  if StartDate = ? then.
  else do:
    assign
    DateBuf-Start = StartDate
    StartMonth = month( StartDate )
    StartYear = year( StartDate )
    .
    DO WHILE DateBuf-Start < v-v12-3  :
      run gbl/lastday.p ( input DateBuf-Start, output EndDay_ ) .
      assign
      DateBuf-End = date( StartMonth, EndDay_ , StartYear )
      DateBuf-end = min(dateBuf-end, v-v12-3)
      .
  shop-cycle:
      FOR EACH shop NO-LOCK:
        FIND FIRST chk-doc WHERE
                  chk-doc.obj-type = {&shop} AND
                  chk-doc.obj-code = shop.obj-code AND
                  chk-doc.cashier = X_staff.staff-code AND
                  chk-doc.chk-date >= DateBuf-Start AND
                  chk-doc.chk-date <= DateBuf-End AND
                  chk-doc.out-code <> ? NO-LOCK NO-ERROR .
        if available chk-doc AND
            ( NOT can-find( cshr-month WHERE
                            cshr-month.cshr-code = X_staff.staff-code AND
                            cshr-month.cashier-psn-code = 0 AND
                            cshr-month.obj-type = "":U and
                            cshr-month.obj-code = 0 AND
                            cshr-month.year_ = StartYear AND
                            cshr-month.month_ = StartMonth ) ) then do:
          CREATE cshr-month .
          assign
          cshr-month.cshr-code = X_staff.staff-code
          cshr-month.year_ = year( chk-doc.chk-date )
          cshr-month.month_ = month( chk-doc.chk-date )
          cshr-month.cashier-psn-code = 0
          cshr-month.obj-type = "":U
          cshr-month.obj-code = 0
          .
          LEAVE shop-cycle.
        end. /*if available chk-doc AND*/
      END. /*FOR EACH shop NO-LOCK :*/
      if month( DateBuf-Start ) < 12 then do:
        assign
        StartMonth = month( DateBuf-Start ) + 1
        StartYear = year( DateBuf-Start )
        .
      end.
      else do:
        assign
        StartMonth = 1
        StartYear = year( DateBuf-Start ) + 1
        .
      end.
      DateBuf-Start = date( StartMonth, 1, StartYear ) .
    END .   /* DO WHILE DateBuf-Start < v-v12-3 ... */
    assign
    StartMonth = month( StartDate )
    StartYear = year( StartDate )
    .
    FOR EACH cshr-month WHERE
            cshr-month.cshr-code = X_staff.staff-code AND
            cshr-month.cashier-psn-code = 0 AND
            cshr-month.obj-type = "":U and
            cshr-month.obj-code = 0 and
            ( ( cshr-month.year_ = StartYear ) AND
              ( cshr-month.month_ >= StartMonth )
            OR ( cshr-month.year_ > StartYear ) ) :
      assign
      DateBuf-Start = date( cshr-month.month_ , 1, cshr-month.year_ )
      .
      run gbl/lastday.p ( input DateBuf-Start, output EndDay_ ) .
      assign
      DateBuf-End = date( cshr-month.month_ , EndDay_ , cshr-month.year_ ) .
      assign
      v-out-totchk  = 0
      v-out-totsum  = 0
      v-out-count   = 0
      v-out-qnty    = 0
      v-out-sum     = 0
      v-ret-totchk  = 0
      v-ret-totsum  = 0
      v-ret-count   = 0
      v-ret-qnty    = 0
      v-ret-sum     = 0
      .
      FOR EACH shop NO-LOCK,
          EACH chk-doc WHERE
            chk-doc.obj-type = {&shop} AND
            chk-doc.obj-code = shop.obj-code AND
            chk-doc.cashier = X_staff.staff-code AND
            chk-doc.chk-date >= DateBuf-Start AND
            chk-doc.chk-date <= DateBuf-End AND
            chk-doc.out-code <> ?  NO-LOCK :
          if chk-doc.cashier-psn-code <> ? then NEXT.
          if lookup(string(chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next .
          if chk-doc.netto >= 0 then do:
            assign
            v-out-totchk = v-out-totchk + 1
            v-out-totsum = v-out-totsum + chk-doc.netto
            .
            if v-out-totchk modulo 20 = 0
            AND v-out-totchk >= 20 then
            run waitfram-show in this-procedure ( input substitute("Обработано чеков : &1",  v-out-totchk) ) .
          end.
          else do:
            assign
            v-ret-totchk = v-ret-totchk + 1
            v-ret-totsum = v-ret-totsum + chk-doc.netto
            .
          end.
          if ( ( chk-doc.netto < 0 ) AND
              can-find( first ub.chk-gds where
                              ub.chk-gds.doc-code = chk-doc.doc-code AND
                              ub.chk-gds.doc-qnty > 0 ) ) OR
                  ( ( ub.chk-doc.netto > 0 ) AND
                      can-find( first ub.chk-gds where
                                      ub.chk-gds.doc-code = chk-doc.doc-code AND
                                      ub.chk-gds.doc-qnty < 0 ) ) then do:
            if ub.chk-doc.netto < 0 then  do:
              FOR EACH ub.chk-gds WHERE
                      ub.chk-gds.doc-code = chk-doc.doc-code AND
                      ub.chk-gds.doc-qnty > 0 NO-LOCK :
                assign
                v-ret-count = v-ret-count + 1
                v-ret-qnty = v-ret-qnty + abs(chk-gds.doc-qnty)
                v-ret-sum = v-ret-sum + abs(  chk-gds.price-base - chk-gds.discnt ) * chk-gds.doc-qnty
                .
              END .
            end.
            else do:
              /* Продажи */
              FOR EACH chk-gds WHERE
                        chk-gds.doc-code = chk-doc.doc-code AND
                        chk-gds.doc-qnty < 0 NO-LOCK :
                assign
                v-out-count = v-out-count + 1
                v-out-qnty = v-out-qnty + chk-gds.doc-qnty
                v-out-sum = v-out-sum + ( chk-gds.price-base - chk-gds.discnt ) * chk-gds.doc-qnty
                .
              END .
            end.
          end.
      END .   /* FOR EACH shop NO-LOCK ... */
      assign
      cshr-month.out-totchk = v-out-totchk
      cshr-month.out-totsum = v-out-totsum
      cshr-month.out-count  = v-out-count
      cshr-month.out-qnty   = v-out-qnty
      cshr-month.out-sum    = v-out-sum
      cshr-month.ret-totchk = v-ret-totchk
      cshr-month.ret-totsum = v-ret-totsum
      cshr-month.ret-count  = v-ret-count
      cshr-month.ret-qnty   = v-ret-qnty
      cshr-month.ret-sum    = v-ret-sum
      .
    END.    /* FOR EACH cshr-month ... */
  end.
  /*теперь родим записи по новому с psn-code и obj-type obj-code*/
  if StartDate-Psn = ? then .
  else do:
    assign
    DateBuf-Start = StartDate-PSN
    StartMonth-PSN = month( StartDate-PSN )
    StartYear-PSN = year( StartDate-PSN )
    .
    DO WHILE DateBuf-Start < v-today  :
      run gbl/lastday.p ( input DateBuf-Start, output EndDay_ ) .
      assign
      DateBuf-End = date( StartMonth-PSN, EndDay_ , StartYear-PSN )
      .
  shop-cycle:
      FOR EACH shop_cli NO-LOCK WHERE
               shop_cli.obj-type = {&shop}
           AND shop_cli.db-num = v-cntxt-db-num:
        _chk-doc:
        FOR EACH chk-doc NO-LOCK WHERE
                  chk-doc.obj-type = {&shop} AND
                  chk-doc.obj-code = shop_cli.obj-code AND
                  chk-doc.cashier = X_staff.staff-code AND
                  chk-doc.chk-date >= DateBuf-Start AND
                  chk-doc.chk-date <= DateBuf-End AND
                  chk-doc.out-code <> ?:
          if lookup(string(chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc.
          if chk-doc.cashier-psn-code <> X_person.psn-code then NEXT _chk-doc.
          if ( NOT can-find( cshr-month WHERE
                            cshr-month.cshr-code = X_staff.staff-code AND
                            cshr-month.cashier-psn-code = X_person.psn-code AND
                            cshr-month.obj-type = {&shop} and
                            cshr-month.obj-code = shop_cli.obj-code AND
                            cshr-month.year_ = StartYear-PSN AND
                            cshr-month.month_ = StartMonth-PSN ) ) then do:
            CREATE cshr-month .
            assign
            cshr-month.cshr-code = X_staff.staff-code
            cshr-month.year_ = year( chk-doc.chk-date )
            cshr-month.month_ = month( chk-doc.chk-date )
            cshr-month.cashier-psn-code = X_person.psn-code
            cshr-month.obj-type = {&shop}
            cshr-month.obj-code = shop_cli.obj-code
            .
            NEXT shop-cycle.
          END. /*if not can-find */
        end. /*for each _chk-doc*/
      END. /*FOR EACH shop_cli NO-LOCK :*/
      if month( DateBuf-Start ) < 12 then do:
        assign
        StartMonth-PSN = month( DateBuf-Start ) + 1
        StartYear-PSN = year( DateBuf-Start )
        .
      end.
      else do:
        assign
        StartMonth-PSN = 1
        StartYear-PSN = year( DateBuf-Start ) + 1
        .
      end.
      DateBuf-Start = date( StartMonth-PSN, 1, StartYear-PSN ) .
    END .   /* DO WHILE DateBuf-Start < v-v12-3 ... */
    assign
    StartMonth-PSN = month( StartDate-PSN )
    StartYear-PSN = year( StartDate-PSN )
    .
    FOR EACH cshr-month WHERE
            cshr-month.cshr-code = X_staff.staff-code AND
            cshr-month.cashier-psn-code = X_person.psn-code AND
            ( ( cshr-month.year_ = StartYear-pSN ) AND
              ( cshr-month.month_ >= StartMonth-PSN )
            OR ( cshr-month.year_ > StartYear-PSN ) ) :
      assign
      DateBuf-Start = date( cshr-month.month_ , 1, cshr-month.year_ )
      .
      run gbl/lastday.p ( input DateBuf-Start, output EndDay_ ) .
      assign
      DateBuf-End = date( cshr-month.month_ , EndDay_ , cshr-month.year_ ) .
      assign
      v-out-totchk  = 0
      v-out-totsum  = 0
      v-out-count   = 0
      v-out-qnty    = 0
      v-out-sum     = 0
      v-ret-totchk  = 0
      v-ret-totsum  = 0
      v-ret-count   = 0
      v-ret-qnty    = 0
      v-ret-sum     = 0
      .
      FOR  EACH chk-doc WHERE
          chk-doc.obj-type = cshr-month.obj-type AND
          chk-doc.obj-code = cshr-month.obj-code AND
          chk-doc.cashier = X_staff.staff-code AND
          chk-doc.chk-date >= DateBuf-Start AND
          chk-doc.chk-date <= DateBuf-End AND
          chk-doc.out-code <> ?  NO-LOCK :
        if lookup(string(chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next.
        if chk-doc.cashier-psn-code <> X_person.psn-code then NEXT.
        if chk-doc.netto > 0 then do:
          assign
          v-out-totchk = v-out-totchk + 1
          v-out-totsum = v-out-totsum + chk-doc.netto
          .
          if v-out-totchk modulo 20  = 0
          and v-out-totchk >= 20 then
          run waitfram-show in this-procedure ( input substitute("Обработано чеков : &1",  v-out-totchk ) ) .
        end.
        else do:
          assign
          v-ret-totchk = v-ret-totchk + 1
          v-ret-totsum = v-ret-totsum + chk-doc.netto
          .
        end.
        if ( ( chk-doc.netto < 0 ) AND
            can-find( first chk-gds where
                            chk-gds.doc-code = chk-doc.doc-code AND
                            chk-gds.doc-qnty > 0 ) ) OR
                ( ( chk-doc.netto > 0 ) AND
                    can-find( first chk-gds where
                                    chk-gds.doc-code = chk-doc.doc-code AND
                                    chk-gds.doc-qnty < 0 ) ) then do:
          if chk-doc.netto < 0 then  do:
            FOR EACH chk-gds WHERE
                    chk-gds.doc-code = chk-doc.doc-code AND
                    chk-gds.doc-qnty > 0 NO-LOCK :
              assign
              v-ret-count = v-ret-count +  1
              v-ret-qnty = v-ret-qnty + abs( chk-gds.doc-qnty )
              v-ret-sum = v-ret-sum + abs( ( chk-gds.price-base - chk-gds.discnt ) * chk-gds.doc-qnty )
              .
            END .
          end.
          else do:
            /* Продажи */
            FOR EACH chk-gds WHERE
                      chk-gds.doc-code = chk-doc.doc-code AND
                      chk-gds.doc-qnty < 0 NO-LOCK :
              assign
              v-out-count = v-out-count + 1
              v-out-qnty = v-out-qnty +  chk-gds.doc-qnty
              v-out-sum = v-out-sum   + ( chk-gds.price-base - chk-gds.discnt ) * chk-gds.doc-qnty
              .
            END .
          end.
        end.
        assign
        cshr-month.out-totchk = v-out-totchk
        cshr-month.out-totsum = v-out-totsum
        cshr-month.out-count  = v-out-count
        cshr-month.out-qnty   = v-out-qnty
        cshr-month.out-sum    = v-out-sum
        cshr-month.ret-totchk = v-ret-totchk
        cshr-month.ret-totsum = v-ret-totsum
        cshr-month.ret-count  = v-ret-count
        cshr-month.ret-qnty   = v-ret-qnty
        cshr-month.ret-sum    = v-ret-sum
        .
      END .   /* FOR EACH cshr-month NO-LOCK ... */
    END.    /* FOR EACH cshr-month ... */
  END. /*startdate-psn <> ?*/
END. /*DO TRANSACTION*/
run waitfram-hide in this-procedure .
return "1" .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-sel  _DEFAULT-DISABLE
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
  HIDE FRAME d-sel.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-sel 
PROCEDURE enable_UI :
define buffer buf_db for ub.db.
ASSIGN
br-staff:NUM-LOCKED-COLUMNS IN FRAME {&frame-name} = 2
X_staff.staff-code:read-only in browse br-staff = yes
.
ASSIGN
b-add:MENU-MOUSE = 1
b-chg:MENU-MOUSE = 1
b-del:MENU-MOUSE = 1
f-db-num = p-db-num
.
find first buf_db no-lock where buf_db.db-num = v-cntxt-db-num.
ASSIGN
v-tab-order = "b-exit,b-mark,b-add,b-sel,b-lkp,b-chg,b-del,b-hist,b-print,b-help,f-db-num," +
              "rs-status,b-arch,b-sch,f-db-num,f-staff-code" .
ENABLE
br-staff
b-quit
b-qrCode when p-role = {&role-cashier}
b-mark WHEN lookup( "b-mark", bttns) > 0
b-sel  WHEN lookup( "b-sel", bttns) > 0
b-print
b-hist
b-help
b-add WHEN lookup( "b-add", bttns) > 0
b-del WHEN lookup( "b-add", bttns) > 0
b-chg WHEN lookup( "b-add", bttns) > 0
b-sch
b-lkp
f-db-num WHEN v-cntxt-db-num = 0
f-staff-code
RS-status
b-arch when p-role = {&role-cashier}
WITH FRAME {&frame-name} .

disable b-qrCode  WHEN lookup( "b-sel", bttns) > 0 with frame {&frame-name} .
if p-role <> {&role-cashier} then
hide b-qrCode in frame {&frame-name} .
assign
MENU-ITEM m-add-new:sensitive in menu menu-add = (lookup( "b-add", bttns) > 0  and buf_db.add-clients)
MENU-ITEM m_psn:sensitive in menu menu-b-chg = (lookup( "b-add", bttns) > 0  and buf_db.add-clients)
MENU-ITEM m_client:sensitive in menu menu-b-del = (lookup( "b-add", bttns) > 0  and buf_db.add-clients)
.
CASE p-role:
  when {&role-cashier} then do.
    title0 = "КАССИРЫ".
  end.
  when {&role-seller} then do.
    title0 = "ПРОДАВЦЫ".
  end.
END CASE.
&scop role-code p-role
v-role-name = {&role-name}.
IF NOT (v-cntxt-db-num = 0 AND p-db-num = ?)THEN DO:
    HIDE
    f-db-num
    IN FRAME {&FRAME-NAME}.
END.
else do:
  display
  f-db-num
  with frame {&frame-name} .
end.
/*ВНИМАНИЕ ! возможность включения кнопки b-add проверяется при вызове*/
Run OpenBr in this-procedure ( INPUT yes, INPUT no, INPUT '':U)  .
if available X_staff
then log-res = br-staff:select-focused-row( ).
APPLY "ENTRY" to br-staff.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr d-sel 
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
define variable v-stts as integer no-undo .
define variable p-user-name as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
title0 = substitute("Список персонала").
run waitfram-show in this-procedure ("Ждите...").
def var sort-column-phrase as character no-undo .

case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.


&scop flt-open-open-query OPEN QUERY br-staff FOR EACH X_staff no-lock

&scop flt-open-dyn_open-query FOR EACH X_staff no-lock

&scop flt-open-query-handle QUERY br-staff:handle

&scop flt-open-open-query-tail , first X_person NO-LOCK ~
WHERE X_person.psn-code = X_staff.psn-code, ~
first X_clients NO-LOCK WHERE X_clients.obj-type = ~{&prs~} ~
        AND X_clients.obj-code = X_staff.psn-code ~

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_staff

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_staff

&scop flt-open-waitfram true

define variable l-open-query as logical   no-undo .
 ASSIGN
 frame {&frame-name}:TITLE = title0.
if v-db-num = ? then do:
&scop role-code p-role
if p-open-query then do:
 assign
 frame {&frame-name}:title = substitute("&1 &2 &3 &4"
                                               , title0
                                               , {&role-name}
                                               , (IF rs-status = 0 THEN "Все" ELSE "Текущие")
                                               , if p-psn-code= 0 then '':U else ({&prs} + string(p-psn-code))).
end.

  IF p-psn-code = 0 THEN DO:
    IF rs-status = 0  THEN DO:
         { gbl/fltopend.i
            &where-cond = " X_staff.role = p-role "
            &dyn_where-cond = " substitute('X_staff.role = &1&2&1', ~{&double-quote~}, p-role )"
            &use-ind    = "  "
            &by         = " BY X_staff.staff-code " }

    END.
    ELSE DO:
      run cur-time in this-procedure ( output v-today, output v-time).
         { gbl/fltopend.i
            &where-cond = " X_staff.role = p-role and X_staff.date-end >= v-today "
            &dyn_where-cond = " substitute('X_staff.role = &1&2&1 and X_staff.date-end >= &3 ', ~{&double-quote~}, p-role, v-today)"
            &use-ind    = "  "
            &by         = " BY X_staff.staff-code " }

    END.
  END. /*p-psn-code*/
  ELSE DO:
      IF rs-status = 0  THEN DO:
           { gbl/fltopend.i
              &where-cond = " X_staff.role = p-role and X_staff.psn-code = p-psn-code "
              &dyn_where-cond = " substitute('X_staff.role = &1&2&1 and X_staff.psn-code = &3 ', ~{&double-quote~}, p-role, p-psn-code)"
              &use-ind    = "  "
              &by         = " BY X_staff.staff-code " }

      END.
      ELSE DO:
        run cur-time in this-procedure ( output v-today, output v-time).
           { gbl/fltopend.i
              &where-cond = " X_staff.role = p-role and X_staff.psn-code = p-psn-code ~
                              and X_staff.date-end >= v-today "
              &dyn_where-cond = " substitute('X_staff.role = &1&2&1 and X_staff.psn-code = &3 ~
                              and X_staff.date-end >= &4 ', ~{&double-quote~}, p-role, p-psn-code, v-today)"

              &use-ind    = "  "
              &by         = " BY X_staff.staff-code " }
     END.
  END.
end.
ELSE DO:
  if p-open-query then do:
    assign
    frame {&frame-name}:title = substitute("&1 &2 БД &3 &4"
                                          , title0
                                          , (IF rs-status = 0 THEN "Все" ELSE "Текущие")
                                          , v-db-num
                                          , if p-psn-code= 0 then '':U else ({&prs} + string(p-psn-code)) ).
  end.
  IF p-psn-code = 0 THEN DO:
    IF rs-status = 0  THEN DO:
         { gbl/fltopend.i
            &where-cond = " X_staff.role = p-role and X_staff.db-num = v-db-num "
            &dyn_where-cond = " substitute('X_staff.role = &1&2&1 and X_staff.db-num = &3 ', ~{&double-quote~}, p-role, v-db-num)"
            &use-ind    = "  "
            &by         = " BY X_staff.staff-code " }

    END.
    ELSE DO:
        run cur-time in this-procedure ( output v-today, output v-time).
         { gbl/fltopend.i
            &where-cond = " X_staff.role = p-role ~
                           and X_staff.db-num = v-db-num ~
                           and X_staff.date-end >= v-today "
            &dyn_where-cond = " substitute('X_staff.role = &1&2&1 ~
                           and X_staff.db-num = &3 ~
                           and X_staff.date-end >= &4 ', ~{&double-quote~}, p-role, v-db-num, v-today)"

            &use-ind    = "  "
            &by         = " BY X_staff.staff-code " }

    END.
  END. /*p-psn-code*/
  ELSE DO:
      IF rs-status = 0  THEN DO:
           { gbl/fltopend.i
              &where-cond = " X_staff.role = p-role  ~
                             and X_staff.db-num = v-db-num ~
                             and X_staff.psn-code = p-psn-code "
              &dyn_where-cond = " substitute('X_staff.role = &1&2&1  ~
                             and X_staff.db-num = &3 ~
                             and X_staff.psn-code = &4 ', ~{&double-quote~}, p-role, v-db-num, p-psn-code)"

              &use-ind    = "  "
              &by         = " BY X_staff.staff-code " }

      END.
      ELSE DO:
        run cur-time in this-procedure ( output v-today, output v-time).
           { gbl/fltopend.i
              &where-cond = " X_staff.role = p-role
                              and X_staff.psn-code = p-psn-code ~
                              and X_staff.db-num = v-db-num ~
                              and X_staff.date-end >= v-today "
              &dyn_where-cond = " substitute('X_staff.role = &1&2&1
                              and X_staff.psn-code = &3 ~
                              and X_staff.db-num = &4 ~
                              and X_staff.date-end >= &5 ', ~{&double-quote~}, p-role, p-psn-code, v-db-num , v-today)"

              &use-ind    = "  "
              &by         = " BY X_staff.staff-code " }
    END.
  END.
END.
if not p-open-query then
REPOSITION br-staff to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-staff:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure.
APPLY "VALUE-CHANGED" TO br-staff in frame {&frame-name}.
APPLY "ENTRY" TO br-staff.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add d-sel 
PROCEDURE proc-b-add :
DEFINE INPUT PARAMETER p-option AS CHARACTER NO-UNDO.
define variable glog as logical no-undo .
define variable ri as recid no-undo .
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_client-reference-prs_add-del':U
{&cntxt-global}
0
'':U
0
0
0
0
true
glog
}
if NOT glog then  return no-apply .
run ref/rolei.p ( INPUT parparentproc
            ,input {&add-def}
            ,input (IF add-option = "new":u
                    THEN 0 /*0 значит client нет в БД*/
                    ELSE ? /*? значит client есть в БД*/  )
            ,input p-role
            ,input ? /*p-role-level*/
            ,input-output ri
            ,input-output table tt-staff
            ) .
if ri <> ? then  do:
    Run OpenBr in this-procedure ( INPUT yes, INPUT no, INPUT '':U ).
    reposition br-staff to recid ri no-error .
end.
apply "entry" to br-staff IN FRAME {&FRAME-NAME} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-chg d-sel 
PROCEDURE proc-b-chg :
DEFINE INPUT PARAMETER p-option AS CHARACTER NO-UNDO.
define variable v-old-cshr as integer no-undo .
define variable glog as logical no-undo .
define variable ri as recid no-undo .
define variable ric as recid no-undo .
define buffer buf_person for ub.person.
IF NOT AVAILABLE X_staff THEN RETURN.
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_client-reference_update':U
{&cntxt-global}
0
'':U
0
0
0
0
false
glog
}
if NOT glog
and p-option = "staff":U
and X_staff.role = {&role-cashier}
then do :
  { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_cashdesk-cashiers_update':U
  {&cntxt-object}
  v-cntxt-host-code-obj
  v-cntxt-obj-type
  v-cntxt-obj-code
  0
  0
  0
  false
  glog
  }
  if NOT glog
  then do :
    message "У вас не хватает прав на изменение." skip
            "(actn_cashdesk-cashiers_update)"
    view-as alert-box error .
    return no-apply .
  end .
end.
if NOT glog
then do :
  message "У вас не хватает прав на изменение." skip
          "(actn_client-reference_update)"
  view-as alert-box error .
  return no-apply .
end .
assign
ric = recid( X_clients )
ri = recid( X_staff )
.
CASE p-option:
  WHEN {&prs} THEN DO:
    run ref/personi.w (
                     input parparentproc
                    ,input {&update}
                    ,input X_clients.obj-code
                    ,input X_clients.grp-code
                    ,input p-role
                    ,input-output  ric) .
    if ric <> ? then do:
      run OpenBr in this-procedure ( INPUT yes, INPUT no, INPUT '':U).
      reposition br-staff to recid ri no-error .
    end.
  END.
  WHEN  "staff":U THEN DO:
     run ref/rolei.p (
                     input parparentproc
                    ,input {&update}
                    ,input X_clients.obj-code
                    ,input X_staff.role
                    ,input X_staff.role-level
                    ,input-output  ri
                    ,input-output table tt-staff
                    ) .
    IF ri <> ? THEN DO:
        run OpenBr in this-procedure ( INPUT yes, INPUT no, INPUT '':U).
        reposition br-staff to recid ri no-error .
    END.
  END.
END CASE.
apply "entry" to br-staff IN FRAME {&FRAME-NAME} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del d-sel 
PROCEDURE proc-b-del :
DEFINE INPUT PARAMETER p-option AS CHARACTER NO-UNDO.
define variable glog as logical no-undo .
define variable ri as recid no-undo .
define variable ric as recid no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer buf_clients for ub.clients.
IF NOT AVAILABLE X_staff  THEN RETURN.
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_client-reference-prs_add-del':U
{&cntxt-global}
0
'':U
0
0
0
0
true
glog
}
if NOT glog then return no-apply .
CASE p-option :
  WHEN 'staff' THEN DO:
    run cur-time in this-procedure ( output v-today, output v-time).
    message
    substitute("Вы уверены, что хотите удалить запись типа &1&2" +
               "для физ.лица &3 (дата удаления - сегодня, &4)?&2" +
               "Это может привести к ошибкам при разборе чеков&2"
               ,v-role-name
               ,{&new-line}
               ,X_clients.obj-name
               , string(v-today, "99/99/9999")
               )
    view-as alert-box QUESTION buttons yes-no update glog.
    if not glog then do:
       undo, return no-apply.
    end.
    ri = recid (X_staff).
    run ref/staff01.p (
                   input-output ri
                  ,input {&deletion}
                  ,input no /*p-silent*/
                  ,input X_staff.role
                  ,input X_staff.staff-code
                  ,input X_staff.psn-code
                  ,input X_staff.role-level
                  ,input X_staff.date-start
                  ,input ? /*для удаления*/
                  ,input X_staff.db-num
                  ,input X_staff.host-code
                  ,input X_staff.obj-type
                  ,input X_staff.obj-code
                  ,input X_staff.work-place
                  ,input X_staff.password) no-error .
    if error-status:error then do:
      undo, return error.
    end.
  END.
  WHEN {&prs} THEN DO:
    if X_clients.stts <> 0 then do:
      message
      SUBSTITUTE("Данное физ.лицо&1&2&1У Ж Е  имеет статус У Д А Л Е Н. &1Восстановить"
                 , {&NEW-LINE}
                 ,X_clients.obj-name )
      view-as alert-box question buttons yes-no update choice .
      if choice then  do:
        ri = recid( X_staff ).
        ric = recid( X_clients ).
        FIND FIRST buf_clients WHERE recid( buf_clients ) = ric .
        buf_clients.stts = 0 .
        br-staff:refresh() IN FRAME {&frame-name}.
      end.
    end.
    else do:

      message "Установить статус УДАЛЕН  для данного клиента?"
      view-as alert-box question buttons yes-no update choice .
      if choice then  do:
        ri = recid( X_clients ).
        ric = recid( X_clients ).
        FIND FIRST buf_clients WHERE recid( buf_clients ) = ric .
        buf_clients.stts = 1.
      end.
    end.
  END. /*when {&prs}*/
END CASE.
br-staff:refresh().
reposition br-staff to row 1 no-error .
apply "ENTRY" to br-staff .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch d-sel 
PROCEDURE proc-b-sch :
assign
  tbl = 'staff'
  join-tbl = 'X_staff'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
IF p-psn-code = 0 THEN DO:
  run fltfield-add in this-procedure('psn-code', 'Код Физ.лица', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
END.
run fltfield-add in this-procedure('staff-code', 'Код персонала', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('date-start', 'Работает с', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('date-end', 'Работал по', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
                   , INPUT filter-point0 + {&delim-par} + filter-label
                   , INPUT tbl
                   , INPUT join-tbl
                   , INPUT fld
                   , INPUT lab
                   , INPUT spr
                   , INPUT dim ).
  run OpenBr IN THIS-PROCEDURE ( INPUT yes, INPUT no, INPUT '':U).
END. /* Filter-Block */


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find_staff-code d-sel 
PROCEDURE proc-find_staff-code :
define input parameter p-next as logical no-undo.
define input parameter p-staff-code like ub.staff.staff-code no-undo.
run OpenBr in THIS-PROCEDURE (
                              input false /* p-open-query */
                             ,input p-next  /* p-find-next  */
                             ,input substitute("and X_staff.staff-code = &1 ", p-staff-code)
                            ).
apply "entry":u to f-staff-code in frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

