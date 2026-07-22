&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME D-Dialog
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS D-Dialog
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Окно для вызова отчетов (содержит 2 страницы)

Автор: Чернова Светлана Александровна
Дата создания: 16/10/00
Author: Svetlana Chernova
Creation date: 16/10/00

*/
using Ibs.Th.Gbl.ProgressBar.

CREATE WIDGET-POOL.
DEFINE INPUT PARAMETER  parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter  procname       as character no-undo . /* имя процедуры на 2 закладке  */
define input parameter  namereport     as character no-undo . /* имя процедуры на 2 закладке  */
define input parameter  param-date     as integer   no-undo . /* Дата  1 2 3 */
define input parameter  param-goods    as character no-undo . /* Товары */
define input parameter  param-obj      as character no-undo . /* Объекты */
define input parameter  param-pay      as character no-undo . /* Цены */
define input parameter  param-pay-hide as character no-undo . /* Цены - какие цены не паказывать*/
define input parameter  param-universal as character no-undo . /* многое другое см документ vss Использование d-report*/
define input parameter  param-alon     as logical   no-undo . /* 1 закладка*/

/* бывшее  s t r - d e f . i  */

define variable G#rep-updflds as character no-undo .
define variable v-nn as integer   no-undo .
define variable v-nn2 as integer   no-undo .
define variable v-nn3 as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Окно для вызова отчетов (содержит 2 страницы)".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7|&8|&9',procname,namereport,param-date,param-goods,param-obj,param-pay,param-pay-hide,param-universal,param-alon)" }
{ cmp/trg-def.i     }
{ cmp/r-page1.i NEW }

  my-handle = parParentProc .

{ rep/rep-bt.i      }
{ cmp/r-pril.i NEW  }
{ rep/opclexcl.i    }
{ gbl/cur-time.i    }
{ rep/par-actu.i    }
{ rep/prg-bar.i def }
{ gbl/getsect.i def }

define variable v-type-folder-list  as character no-undo .
define variable b_ach as handle no-undo .
define variable g#log as logical no-undo .
define new shared variable lns-cnt as integer no-undo .
define new shared variable s-notes as character no-undo .
define variable v-progress-bar as class ProgressBar no-undo .

define stream str-export .


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartDialog
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER DIALOG-BOX

&Scoped-define ADM-SUPPORTED-LINKS Record-Target

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME D-Dialog

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit Btn_OK B-lkp B-Help i-exit

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of handles for SmartObjects                              */
DEFINE VARIABLE h_folder AS HANDLE NO-UNDO.
DEFINE VARIABLE h_format AS HANDLE NO-UNDO.
DEFINE VARIABLE h_list AS HANDLE NO-UNDO.
DEFINE VARIABLE h_main AS HANDLE NO-UNDO.
DEFINE VARIABLE h_special AS HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "_ В&ыполнить"
     SIZE 12 BY 1
     BGCOLOR 8 .

DEFINE BUTTON i-exit
     IMAGE-UP FILE "cmp/i-run.bmp":U
     IMAGE-DOWN FILE "cmp/i-run.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/i-rund.bmp":U
     LABEL ""
     SIZE 2.5 BY .75.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME D-Dialog
     b-exit AT ROW 1 COL 1
     Btn_OK AT ROW 1 COL 11
     i-exit AT ROW 1.08 COL 11.13 NO-TAB-STOP
     B-lkp  AT ROW 1 COL 61
     B-Help AT ROW 1 COL 71
     SPACE(14.24) SKIP(20.66)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert SmartDialog title>"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON b-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartDialog
   Allow: Basic,Browse,DB-Fields,Query,Smart
   Design Page: 3
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB D-Dialog
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX D-Dialog
                                                                        */
ASSIGN
       FRAME D-Dialog:SCROLLABLE       = FALSE
       FRAME D-Dialog:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX D-Dialog
/* Query rebuild information for DIALOG-BOX D-Dialog
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX D-Dialog */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME D-Dialog
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL D-Dialog D-Dialog
ON WINDOW-CLOSE OF FRAME D-Dialog /* <insert SmartDialog title> */
DO:
  /* Add Trigger to equate WINDOW-CLOSE to END-ERROR. */
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lkp D-Dialog
ON CHOOSE OF B-lkp IN FRAME D-Dialog /* Просмотр */
DO:
  run verify-obj in h_main.
  run assign-frame in  h_main.


  if not param-alon
  then do:
        if format-folder
        then do:
           run get-var-2 in h_format no-error.
           { rep/link-err.i 2}
        end.
     run my-var in h_special no-error.
    { rep/link-err.i }
  end.
  run rep/r-prev.w .
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK D-Dialog
ON CHOOSE OF Btn_OK IN FRAME D-Dialog /* Выполнить */
DO:
  define buffer buf_sys-ctrl for ub.sys-ctrl.

  find first buf_sys-ctrl no-lock no-error.
  
  if (X-Date-Alone <> ? and 
     X-date-alone < buf_sys-ctrl.sys-date)
  or (X-Date-Start <> ? and 
     X-Date-Start < buf_sys-ctrl.sys-date)
  or (X-Date-End <> ? and 
     X-Date-End < buf_sys-ctrl.sys-date) then
  do:
    message "Нельзя сформировать отчет на дату меньше," skip
            "чем дата чистки БД " string(buf_sys-ctrl.sys-date, "99/99/9999") "."
    view-as alert-box. 
    return no-apply.
  end. 

  if params-only then do:
     run proc-save-param-RUM in this-procedure no-error .
     if error-status :error then do:
        return no-apply .
     end.
  end.
  else do:
    run trg/userlog.p (
          input "report":U
        , input namereport + {&delim-key} + procname 
        , input ?
        , input ?
        , input ""
    ) no-error.
    if error-status :error
    then do:
        message return-value + error-status:get-message(1) view-as alert-box title "Ошибка записи истории действий пользователя".
    end.    
   

    run print-report in this-procedure no-error .
    if error-status :error
    then do:
      return no-apply .
    end.
    return no-apply .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME i-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-exit D-Dialog
ON CHOOSE OF i-exit IN FRAME D-Dialog
DO:
  APPLY "choose" TO btn_ok.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK D-Dialog


/* ***************************  Main Block  *************************** */

{ gbl/minbtn.i }
run minbtn-set in this-procedure .

on help of frame {&frame-name}
do:
  /* в этой программе для вызова помощи нельзя использовать имя текущей процедуры */
  /* так как оно всегда одно и то же для всех отчетов */

  /* поэтому вместо этого используется имя программы отчета, */
  /* которое задается входным параметром procname */
  run gbl/app_help.p
    (input procname /* p-procedure */
    ,input ''       /* p-detail    */
    ,input ?        /* l-help-edit */
    ) no-error.
  if error-status :error
  then do:
    message
      "Ошибка при вызове помощи" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box .
  end.
end.

on choose of b-help in frame {&frame-name}
do:
  apply "help":u to frame {&frame-name} .
end.

{src/adm/template/dialogmn.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects D-Dialog  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

  DEFINE VARIABLE adm-current-page  AS INTEGER NO-UNDO.

  RUN get-attribute IN THIS-PROCEDURE ('Current-Page':U).
  ASSIGN adm-current-page = INTEGER(RETURN-VALUE).

  CASE adm-current-page:

    WHEN 0 THEN DO:
       RUN init-object IN THIS-PROCEDURE (
             INPUT  'adm/objects/folder.w':U ,
             INPUT  FRAME D-Dialog:HANDLE ,
             INPUT  'FOLDER-LABELS = ':U + 'Параметры|Продолжение|Формат' + ',
                     FOLDER-TAB-TYPE = 1':U ,
             OUTPUT h_folder ).
       RUN set-position IN h_folder ( 2.04 , 1.00 ) NO-ERROR.
       RUN set-size IN h_folder ( 20.38 , 93.63 ) NO-ERROR.

       RUN init-object IN THIS-PROCEDURE (
             INPUT  'rep/b-listf.w':U ,
             INPUT  FRAME D-Dialog:HANDLE ,
             INPUT  '':U ,
             OUTPUT h_list ).
       /* Position in AB:  ( 3.50 , 19.63 ) */
       /* Size in UIB:  ( 17.25 , 59.38 ) */

       RUN init-object IN THIS-PROCEDURE (
           &IF DEFINED(UIB_is_Running) ne 0 &THEN
             INPUT  'v-2.w':U ,
           &ELSE
             INPUT PROCNAME ,
           &ENDIF
             INPUT  FRAME D-Dialog:HANDLE ,
             INPUT  '':U ,
             OUTPUT h_special ).
       /* Position in AB:  ( 3.54 , 2.00 ) */
       /* Size in UIB:  ( 17.29 , 77.38 ) */

       RUN init-object IN THIS-PROCEDURE (
             INPUT  'rep/s-format.w':U ,
             INPUT  FRAME D-Dialog:HANDLE ,
             INPUT  '':U ,
             OUTPUT h_format ).
       /* Position in AB:  ( 3.63 , 2.13 ) */
       /* Size in UIB:  ( 5.21 , 17.00 ) */

       RUN init-object IN THIS-PROCEDURE (
             INPUT  'rep/s-object.w':U ,
             INPUT  FRAME D-Dialog:HANDLE ,
             INPUT  '':U ,
             OUTPUT h_main ).
       /* Position in AB:  ( 3.67 , 1.50 ) */
       /* Size in UIB:  ( 16.25 , 70.25 ) */

       /* Links to SmartFolder h_folder. */
       RUN add-link IN adm-broker-hdl ( h_folder , 'Page':U , THIS-PROCEDURE ).

       /* Links to  h_list. */
       RUN add-link IN adm-broker-hdl ( THIS-PROCEDURE , 'Record':U , h_list ).

       /* Links to  h_special. */
       RUN add-link IN adm-broker-hdl ( h_main , 'State':U , h_special ).
       RUN add-link IN adm-broker-hdl ( THIS-PROCEDURE , 'Record':U , h_special ).

       /* Links to  h_format. */
       RUN add-link IN adm-broker-hdl ( THIS-PROCEDURE , 'Record':U , h_format ).

       /* Links to  h_main. */
       RUN add-link IN adm-broker-hdl ( THIS-PROCEDURE , 'Record':U , h_main ).

       /* Adjust the tab order of the smart objects. */
       RUN adjust-tab-order IN adm-broker-hdl ( h_folder ,
             B-Help:HANDLE , 'AFTER':U ).
    END. /* Page 0 */

  END CASE.
  /* Select a Startup page. */
  IF adm-current-page eq 0
  THEN RUN select-page IN THIS-PROCEDURE ( 1 ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available D-Dialog  _ADM-ROW-AVAILABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI D-Dialog  _DEFAULT-DISABLE
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
  HIDE FRAME D-Dialog.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI D-Dialog  _DEFAULT-ENABLE
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
  ENABLE b-exit Btn_OK B-lkp B-Help i-exit
      WITH FRAME D-Dialog.
  VIEW FRAME D-Dialog.
  {&OPEN-BROWSERS-IN-QUERY-D-Dialog}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Get-Var D-Dialog
PROCEDURE Get-Var :
define output parameter  temp-str as char no-undo.
define output parameter  temp-param-date as int no-undo.
define output parameter  temp-param-date-type-period as character no-undo.
DEFINE output PARAMETER  temp-param-goods as char.    /* Товары */
DEFINE output PARAMETER  temp-param-obj as char.      /* Объекты */
DEFINE output PARAMETER  temp-param-Pay as char.      /* Цены */
DEFINE output PARAMETER  temp-param-Pay-hide as char. /* Цены */
DEFINE output PARAMETER  temp-param-obj-type as char. /* Типы объектов - all stok shop*/
DEFINE output PARAMETER  temp-param-alon as log.      /* 1 закладка*/
DEFINE output PARAMETER  temp-param-customer as character no-undo . /* контрагенты */
DEFINE output PARAMETER  temp-param-customer-type as character no-undo . /* контрагенты */
DEFINE output PARAMETER  temp-param-schet        as character no-undo .
DEFINE output PARAMETER  temp-param-schet-hide   as character no-undo .
DEFINE output PARAMETER  temp-param-schet-init   as character no-undo .
DEFINE output PARAMETER  temp-param-schet-mode   as character no-undo .
define output parameter  all-object            as logical   no-undo .

define variable customer-yes as logical init false no-undo .
define variable customer-name as character INIT "" no-undo .
define variable customer-type as character INIT "" no-undo .

define variable schet-yes  as logical init false no-undo .
define variable schet-name as character INIT "" no-undo .
define variable schet-hide as character INIT "" no-undo .
define variable schet-init as character INIT "" no-undo .
define variable ed_date-ref as character no-undo .

define variable Jv as integer no-undo.
define variable v-ii as integer no-undo .
define variable plase-cost as integer no-undo .
define variable plase-crsa as integer no-undo .
define variable plase-sale as integer no-undo .
define variable radio-period as character   no-undo .

param-universal = param-universal + ",".
temp-param-obj-type  = "".
all-object = false .

assign temp-param-schet-mode = {&company} .
v-nn3 = NUM-ENTRIES(param-universal).
REPEAT Jv = 1 to v-nn3:
    CASE Entry(Jv,param-universal ) :
        WHEN  "all":U OR
        WHEN  "shop":U OR
        WHEN  "stok":U Then temp-param-obj-type    =  Entry(Jv,param-universal ).
        WHEN  String({&Excel-yes})             Then Make-Excel       = TRUE.
        WHEN  String({&Excel-yes-com})         Then Make-Excel-com   = TRUE.
        WHEN  String({&Arc-aht-yes})           Then Verify-Arc-aht   = TRUE.
        WHEN  String({&Arc-ot-yes})            Then Verify-Arc-ot    = TRUE.
        WHEN  String({&Arc-stk-yes})           Then Verify-Arc-stk   = TRUE.
        WHEN  String({&Arc-supp-yes})          Then Verify-Arc-supp  = TRUE.
        WHEN  String({&Arc-hold-yes})          Then Verify-Arc-hold  = TRUE.
        WHEN  String({&Arc-strong-yes})        Then Verify-Arc-strong  = TRUE.
        WHEN  String({&send-check})            Then Verify-send-check = TRUE.
        WHEN  String({&Show-Crsa})             Then Show-Crsa = TRUE.
        WHEN  String({&show-cost})             Then show-cost = TRUE.
        WHEN  String({&show-sale})             Then show-sale = TRUE.
        WHEN  String({&format-folder})         Then format-folder = TRUE.
        WHEN  String({&customer-yes})          Then customer-yes = TRUE.
        WHEN  String({&schet-yes})             Then schet-yes = TRUE.
        WHEN  String({&hide-schet-all-firm})   Then schet-hide = schet-hide + string( {&schet-all-firm}   ) + "," .  /* то что нужно задисаблить*/
        WHEN  String({&hide-schet-firm})       Then schet-hide = schet-hide + string( {&schet-firm}       ) + "," .  /* то что нужно задисаблить*/
        WHEN  String({&hide-schet-choice})     Then schet-hide = schet-hide + string( {&schet-choice}     ) + "," .  /* то что нужно задисаблить*/
        WHEN  String({&hide-schet-one})        Then schet-hide = schet-hide + string( {&schet-one}        ) + "," .  /* то что нужно задисаблить*/
        WHEN  String({&hide-schet-rubl})       Then schet-hide = schet-hide + string( {&schet-rubl}       ) + "," .  /* то что нужно задисаблить*/
        WHEN  String({&hide-schet-no-rubl})    Then schet-hide = schet-hide + string( {&schet-no-rubl}    ) + "," .  /* то что нужно задисаблить*/
        WHEN  String({&hide-schet-choice-val}) Then schet-hide = schet-hide + string( {&schet-choice-val} ) + "," .  /* то что нужно задисаблить*/
        WHEN  "X-OWN-CMP":U Then temp-param-schet-mode = "company-host":U .  /* для счетов - выборка только нашей фирмы "company-host":U или всех {&company} */
        WHEN  String({&Print-List-Hist-yes})    Then Print-List-Hist   = TRUE.
        WHEN  String({&Arc-fin-yes})            Then verify-arc-fin    = TRUE.
    END Case.
   if trim(Entry(Jv,param-universal)) begins "name-sale" then  name-sale-price = Entry(2,Entry(Jv,param-universal ),"=") .
   if CAPS(trim(Entry(Jv,param-universal))) begins "X-DATE-START"      then  init-DATE-START  = date(Entry(2,Entry(Jv,param-universal ),"="))  .
   if CAPS(trim(Entry(Jv,param-universal))) begins "X-DATE-END"        then  init-DATE-END    = date(Entry(2,Entry(Jv,param-universal ),"=")) .
   if CAPS(trim(Entry(Jv,param-universal))) begins "X-DATE-ALONE"      then  init-DATE-ALONE  = date(Entry(2,Entry(Jv,param-universal ),"=")) .
   if CAPS(trim(Entry(Jv,param-universal))) begins "X-SHIFT-ALONE"     then  init-Shift-ALONE = int(Entry(2,Entry(Jv,param-universal ),"=")) .
   if CAPS(trim(Entry(Jv,param-universal))) begins "X-SHIFT-START"     then  init-Shift-Start = int(Entry(2,Entry(Jv,param-universal ),"=")) .
   if CAPS(trim(Entry(Jv,param-universal))) begins "X-SHIFT-END"       then  init-Shift-End   = int(Entry(2,Entry(Jv,param-universal ),"=")) .
   if CAPS(trim(Entry(Jv,param-universal))) begins "X-CUSTOMER-NAME"   then  customer-name    = Entry(2,Entry(Jv,param-universal ),"=") . /* имя блока выбор контрагента */
   if CAPS(trim(Entry(Jv,param-universal))) begins "X-CUSTOMER-TYPE"   then  customer-type    = Entry(2,Entry(Jv,param-universal ),"=") . /* фильтр для справочника контрагента */
   if CAPS(trim(Entry(Jv,param-universal))) begins "X-SCHET-NAME"      then  schet-name       = Entry(2,Entry(Jv,param-universal ),"=") .    /* имя блока выбор счета */
   if CAPS(trim(Entry(Jv,param-universal))) begins "X-SCHET-INIT"      then  schet-init       = Entry(2,Entry(Jv,param-universal ),"=") .    /* начальное значение счета */
   if CAPS(trim(Entry(Jv,param-universal))) begins "X-SET_PAY_TYPE"    then  init-SET_PAY_TYPE = int(Entry(2,Entry(Jv,param-universal ),"=")) .    /* начальное значение типа цены прод\ учетная \документа */
   if CAPS(trim(Entry(Jv,param-universal))) begins "X-SET_VAL_TYPE"    then  init-SET_VAL_TYPE = int(Entry(2,Entry(Jv,param-universal ),"=")) .    /* начальное значение типа валюты */
   if CAPS(trim(Entry(Jv,param-universal))) begins "ED_DATE-REF="      then  ed_date-ref       = Entry(2,Entry(Jv,param-universal ),"=") .    /* строка для установки справочника привызове универсального триггера на дату ed_date */
   if CAPS(trim(Entry(Jv,param-universal))) begins "parent-handle="    then  parent-handle     = widget-handle(Entry(2,Entry(Jv,param-universal ),"=")) .
   if CAPS(trim(Entry(Jv,param-universal))) begins "all-object"        then  all-object        = true  .
   if CAPS(trim(Entry(Jv,param-universal))) begins "params-only="      then  params-only       = logical(Entry(2,Entry(Jv,param-universal ),"=")) .
   if CAPS(trim(Entry(Jv,param-universal))) begins "params-only-mode=" then  params-only-mode  = Entry(2,Entry(Jv,param-universal ),"=") .
   if CAPS(trim(Entry(Jv,param-universal))) begins "call="             then  place-call        = Entry(2,Entry(Jv,param-universal ),"=") .
   if CAPS(trim(Entry(Jv,param-universal))) begins "radio-period="     then  radio-period      = Entry(2,Entry(Jv,param-universal ),"=") .
 End.

  run local-pre-initialize in this-procedure no-error .

  if params-only then do:
     Btn_OK:label in frame {&frame-name} = '&Ввод' .
     b-exit:label in frame {&frame-name} = '&Отмена' .
     if params-only-mode  = "{&lookup}" or  params-only-mode  = {&lookup} then do:
        params-only-mode  = {&lookup}.
        b-exit:label in frame {&frame-name} = '&Выход' .
        hide Btn_OK i-exit in frame {&frame-name} .
     end.
  end.
  if customer-yes = TRUE then do:
      if trim(customer-name) = "" then temp-param-customer =  "Выбор контрагента" .
                                  else temp-param-customer =  customer-name .
      temp-param-customer-type =  customer-type .
  end.
  else
    assign
      temp-param-customer =  ""
      temp-param-customer-type =  ""
    .

  if schet-yes = TRUE then do:
      if trim(schet-name) = "" then temp-param-schet =  "Выбор счета" .
                               else temp-param-schet =  schet-name .
      temp-param-schet-hide =  schet-hide .
      temp-param-schet-init =  schet-init .
  end.
  else do:
    assign
      temp-param-schet =  ""
      temp-param-schet-hide = ""
      temp-param-schet-init = ""
    .
  end.
  if ed_date-ref <> '':U then do:
    do v-ii = 1 to num-entries(ed_date-ref, ';'):
      if entry(1, entry(v-ii, ed_date-ref, ';'), {&delim-key}) = 'X-DATE-START':U then do:
        assign
        ref_date-start = entry(2, entry(v-ii, ed_date-ref, ';'), {&delim-key}).
      end.
      if entry(v-ii, ed_date-ref, ';') begins 'X-DATE-END':U then do:
        assign
        ref_date-end = entry(2, entry(v-ii, ed_date-ref, ';'), {&delim-key}).
      end.
      if entry(v-ii, ed_date-ref, ';') begins 'X-DATE-ALONE':U then do:
        assign
        ref_date-alone = entry(2, entry(v-ii, ed_date-ref, ';'), {&delim-key}).
      end.
    end.
  end.
temp-param-date     = param-date .
temp-param-goods    = param-goods.
temp-param-obj      = param-obj.
temp-param-pay      = param-pay.
temp-param-pay-hide = param-pay-hide.
temp-param-alon     = param-alon.
/*if temp-param-date = 9 then do:                                                                                                       */
/*   temp-param-date-type-period = radio-period.                                                                                        */
/*   if temp-param-date-type-period = ? or temp-param-date-type-period = "" then temp-param-date-type-period = {&period-type-yesterday}.*/
/*end.                                                                                                                                  */

temp-str =  ReportHeader.

g#log = true .

/* Проверка прав на учетные цены */
if show-cost = true
or lookup( "{&p-cost}" , temp-param-pay ) > 0
then do:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    "'actn_reports_lookup-cost':U"
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    g#log
  }
  if not g#log
  then do:
      Assign
        show-cost  = false
        plase-cost = INDEX (temp-param-Pay , "{&p-cost}" )
        substring(temp-param-Pay,plase-cost) = "0"
        no-error .
  end.
end.

/* Проверка прав на продажные цены */
if  show-crsa = true
or lookup( "{&p-crsa}" , temp-param-pay ) > 0
then do:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    "'actn_reports_lookup-crsa':U"
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    no
    g#log
  }
  if not g#log
  then do:
    /* Если прав нет то .....*/
    assign
      show-crsa  = false
      plase-crsa = index (temp-param-pay , "{&p-crsa}" )
      substring(temp-param-pay,plase-crsa) = "0"
      no-error
      .
  end.
end.

 /* Проверка прав на цены документа */
if  show-sale = true
or lookup( "{&p-sale}" , temp-param-pay ) > 0
then do:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    "'actn_reports_lookup-sale':U"
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    no
    g#log
  }
  if not g#log
  then do:
      /* Если прав нет то .....*/
      assign
        show-sale  = false
        plase-sale = index (temp-param-pay , "{&p-sale}" )
        substring(temp-param-pay,plase-sale) = "0"
        no-error .
  end.
End.

run initilize-page-3 in this-procedure .
END PROCEDURE .

procedure initilize-page-3:
define variable temp-str- as character no-undo .
define variable temp-i as integer no-undo .
define variable  l-ind as integer no-undo .

 find first ubflt.usr-flt no-lock where
         ubflt.usr-flt.user-name  = v-cntxt-userid and
         ubflt.usr-flt.call-point = ReportProc  no-error .

     if available ubflt.usr-flt then  DO:
          v-nn = num-entries( ubflt.usr-flt.list_) .

          repeat l-ind = 1 to v-nn :
                    if entry(1,entry(l-ind, ubflt.usr-flt.list_),"=")  = "ReportPageHeight":U then
                       ReportPageHeight = integer(entry(2,entry(l-ind, ubflt.usr-flt.list_),"=")) no-error .
                       if error-status :error  then message "qq1" .

                    if entry(1,entry(l-ind,ubflt.usr-flt.list_),"=")  = "ReportPageWidth":U then
                       ReportPageWidth = integer(entry(2,entry(l-ind, ubflt.usr-flt.list_),"=")) no-error .
                       if error-status :error  then message "qq2" .

                    if entry(1,entry(l-ind, ubflt.usr-flt.list_ ),"=")  = "Use-Column":U then
                    do :

                        temp-str- = entry( 2 , entry(l-ind, ubflt.usr-flt.list_)  ,"=" ) no-error .
                        v-nn2 = num-entries ( temp-str- , ";") .
                        repeat temp-i = 1 to v-nn2:
                            if temp-i <= 50 then
                            use-column[temp-i] = ( if trim(entry(temp-i,temp-str-,";")) = "true" then true else false) .
                        end.

                    end.

                    if error-status :error  then message "qq3" .

               End.
          End.
      Else assign ReportPageHeight = 0 ReportPageWidth  = 0.

    run op-br in h_list no-error .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-create-objects D-Dialog
PROCEDURE local-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

  DEFINE VARIABLE adm-current-page  AS INTEGER NO-UNDO.

  RUN get-attribute IN THIS-PROCEDURE ('Current-Page':U).
  ASSIGN adm-current-page = INTEGER(RETURN-VALUE).

  If Lookup("{&format-folder}",param-universal) <> 0 then format-folder = true .
                                                         else format-folder = false .

  If format-folder then
  Assign  v-type-folder-list =
  (if param-alon THEN 'FOLDER-LABELS = ':U + 'Параметры||Формат' + ', FOLDER-TAB-TYPE = 1':U
                 ELSE 'FOLDER-LABELS = ':U + 'Параметры|Продолжение|Формат' + ', FOLDER-TAB-TYPE = 1':U  )
                .

  Else
  Assign  v-type-folder-list =
  (if param-alon THEN 'FOLDER-LABELS = ':U + 'Параметры' + ', FOLDER-TAB-TYPE = 1':U
                 ELSE 'FOLDER-LABELS = ':U + 'Параметры|Продолжение' + ', FOLDER-TAB-TYPE = 1':U  )
                .

  /*'FOLDER-LABELS = ':U + 'Параметры|Продолжение|Формат' + ',*/
  CASE adm-current-page:

    WHEN 0
    THEN DO:
       RUN init-object IN THIS-PROCEDURE (
             INPUT  'adm/objects/folder.w':U ,
             INPUT  FRAME D-Dialog:HANDLE ,
             INPUT  v-type-folder-list ,
             OUTPUT h_folder ).
       /*
       RUN set-position IN h_folder ( 2.25 , 1.00 ) NO-ERROR.
       RUN set-size IN h_folder ( 18.88 , 79.38 ) NO-ERROR.
       */
       RUN set-position IN h_folder ( 2.04 , 1.00 ) NO-ERROR.
       RUN set-size IN h_folder ( 20.38 , 93.63 ) NO-ERROR.

       /* Links to SmartFolder h_folder. */
       RUN add-link IN adm-broker-hdl ( h_folder , 'Page':U , THIS-PROCEDURE ).

    END. /* Page 0 */

    WHEN 1
    THEN DO:
       RUN init-object IN THIS-PROCEDURE (
             INPUT  'rep/s-object.w':U ,
             INPUT  FRAME D-Dialog:HANDLE ,
             INPUT  'Layout = ':U ,
             OUTPUT h_main ).
       RUN set-position IN h_main ( 3.67 , 1.50 ) NO-ERROR.
       /* Size in UIB:  ( 16.25 , 70.25 ) */

       /* Links to SmartViewer h_main. */
       RUN add-link IN adm-broker-hdl ( THIS-PROCEDURE , 'Record':U , h_main ).

    END. /* Page 1 */

    WHEN 2
    THEN DO:
       RUN init-object IN THIS-PROCEDURE (
           &IF DEFINED(UIB_is_Running) ne 0 &THEN
             INPUT  'v-2.w':U ,
           &ELSE
             INPUT PROCNAME ,
           &ENDIF
             INPUT  FRAME D-Dialog:HANDLE ,
             INPUT  'Layout = ':U ,
             OUTPUT h_special ).
       RUN set-position IN h_special ( 3.54 , 2.00 ) NO-ERROR.
       /* Size in UIB:  ( 17.29 , 77.38 ) */

       /* Initialize other pages that this page requires. */
       RUN init-pages IN THIS-PROCEDURE ('1') NO-ERROR.

       /* Links to SmartViewer h_special. */
       RUN add-link IN adm-broker-hdl ( h_main , 'State':U , h_special ).
       RUN add-link IN adm-broker-hdl ( THIS-PROCEDURE , 'Record':U , h_special ).
    END. /* Page 2 */
    WHEN 3
    THEN DO:
        Run my-var in h_special no-error.
        { rep/link-err.i }

        RUN init-object IN THIS-PROCEDURE (
              INPUT  'rep/b-listf.w':U ,
              INPUT  FRAME D-Dialog:HANDLE ,
              INPUT  'Layout = ':U ,
              OUTPUT h_list ).
        RUN set-position IN h_list ( 3.50 , 19.63 ) NO-ERROR.

        /* Size in UIB:  ( 17.25 , 59.38 ) */

       RUN init-object IN THIS-PROCEDURE (
             INPUT  'rep/s-format.w':U ,
             INPUT  FRAME D-Dialog:HANDLE ,
             INPUT  'Layout = ':U ,
             OUTPUT h_format ).
       RUN set-position IN h_format ( 3.63 , 2.13 ) NO-ERROR.
       /* Size in UIB:  ( 5.21 , 17.00 ) */

       /* Links to SmartBrowser h_list. */
       RUN add-link IN adm-broker-hdl ( THIS-PROCEDURE , 'Record':U , h_list ).

       /* Links to SmartViewer h_format. */
       RUN add-link IN adm-broker-hdl ( THIS-PROCEDURE , 'Record':U , h_format ).

       RUN add-link IN adm-broker-hdl ( h_format , 'State':U , h_list ).

       /* Adjust the tab order of the smart objects. */
    END. /* Page 3 */

  END CASE.
  /* Select a Startup page. */
  IF adm-current-page eq 0
  THEN RUN select-page IN THIS-PROCEDURE ( 1 ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize D-Dialog
PROCEDURE local-initialize :
define variable par-type  as character no-undo .   /* тип параметра конфигурации */
define variable p-actuate as logical   no-undo .

run get-report-num   in parParentProc(output g#report-num).
my-handle = parParentProc .

RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

Assign
  ReportName = namereport
  ReportProc = procname
.
Frame D-Dialog:Title  = Trim(namereport).
if params-only then do:
    if params-only-mode  = {&lookup} then do:
      Frame D-Dialog:Title  = substitute("Просмотр ПАРАМЕТРОВ отчета:  &1" ,  Trim( namereport ) ) .
    end.
    else do:
      Frame D-Dialog:Title  = substitute("Задание ПАРАМЕТРОВ отчета:  &1" ,  Trim( namereport ) ) .
    end.
end.

  { gbl/getsect.i run "''" 0 {&attr-report-glob} }
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'actuate'  then p-actuate   = thbjattr_thbj-attr.property-value-logical .
  end.

   if p-actuate
   then do:
   if param-Alon = false
   then do: /* если есть 2 и более закладок */
      run select-page in this-procedure ( 2 ) no-error.
      run select-page in this-procedure ( 1 ) no-error.
      run make-btn    in this-procedure  no-error.
    end.
   end.
   else do:
     run select-page in this-procedure
       (input 1
       ) no-error .
   end.

   if params-only  then do:
      if param-Alon = false
      then do: /* если есть 2 и более закладок */
          run select-page in this-procedure ( 2 ) no-error.
      end.
    /*888*/
      run select-page in this-procedure ( 1 ) no-error .
      run my-params in h_special ( input "get" ) no-error .
      run local-apply-layout in h_main no-error .
  end.



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-pre-initialize D-Dialog
PROCEDURE local-pre-initialize :

/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable v-today as date      no-undo .
  define variable v-time  as integer   no-undo .
  define variable v-ok    as logical   no-undo .

  run cur-time in this-procedure
    (output v-today
    ,output v-time
    ).

   if init-date-start = date("") or init-date-start = ? then init-date-start  = v-today .
   if init-date-end = date("") or init-date-end = ? then  init-date-end    = v-today .
   if init-date-alone = date("") or init-date-alone = ? then  init-date-alone  = v-today.
   if init-shift-alone = ? then init-shift-alone = 0 .
   if init-shift-start = ? then init-shift-start = 0 .
   if init-shift-end   = ? then init-shift-end   = 0 .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE make-btn D-Dialog
PROCEDURE make-btn :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :
   run report-to-ach in h_special
     (input-output table param-to-export ) no-error.  /* есть ли выброс в АКЧУэйт  */
   /* message error-status :get-message(1) . */
   if not error-status :error
   then do:
        create button b_ach
        assign row = 1
        column = 23
        height-chars = 1
        width-chars  = 15
        label = "Actuate"
        tooltip = "выполнение отчета при помощи внешней программы"
        frame = frame {&frame-name}:handle
        sensitive = true
        visible = true
        triggers:
              on choose persistent run make-ach.
        end triggers.
   end.


  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE print-report D-Dialog
PROCEDURE print-report :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

define variable choice             as logical   no-undo .
define variable v-total-archive-ok as logical   no-undo .
define variable v-archive-ok       as logical init true  no-undo .
define variable v-comment          as character no-undo .
define variable v-can-print        as logical   no-undo .
define variable temp-date      as date no-undo.
define variable temp-shift     as integer no-undo .
define variable v-date-start as date      no-undo .
define variable v-date-end   as date      no-undo .
define variable spis-obj     as character no-undo .

  /* проверка правильности интервала дат */
  run verify-date in h_main no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.

  /* проверка правильности объекта (что он выбран) */
  run verify-obj in h_main no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.

  /* считывание всех переменных с экрана */
  run assign-frame in h_main .

  /* составление списка товаров по производителям и группам */
  run make-6-gds-list in h_main .

  assign
    v-total-archive-ok = true
  .

  /* Проверка наличия финансовых архивов */
  if verify-arc-fin = true then do:
    define variable p-status       as integer   no-undo .
    define variable p-cut-date     as date      no-undo .
    define variable p-cut-fin-date as date      no-undo .
    { gbl/cutd-db.i v-cntxt-db-num  p-status p-cut-date p-cut-fin-date no-error }
      if param-date = 1
      then do:
        assign
          v-date-start = x-date-alone
          v-date-end   = x-date-alone
        .
      end.
      else do:
        assign
          v-date-start = x-date-start
          v-date-end   = x-date-end
        .
      end.

    if p-cut-date <> ? and ( v-date-start < p-cut-date  or v-date-end < p-cut-date) then do:  /* было обрезание */
      message
        "ВНИМАНИЕ!" skip
        "БД была обрезана на " string(p-cut-fin-date, "99/99/9999")  skip
        "Данные в отчете будут не корректны." skip
        "Продолжить формирование отчета?" skip
        view-as alert-box question
            buttons yes-no
            title "Финансовые архивы"
            update choice .

      if choice = false
      then do:
        assign
          v-total-archive-ok = false
        .
        undo, return error return-value .
      end.
      else do:
          if param-date = 1 then do:
          v-date-end = p-cut-fin-date .
          end .
          else do:
            v-date-start = p-cut-fin-date .
            v-date-end   = p-cut-fin-date .
          end.

        assign
          v-total-archive-ok = true
        .
      end.
    end.
  end.

  /* Проверка наличия межфирменных архивов */
  if verify-arc-hold = true
  then do:
    iF param-date = 1
    then do:
      assign
        temp-date = x-date-alone
      .
    end.
    else do:
      assign
        TEMP-DATE = x-Date-End
      .
    end.

     run trg/bt_hold.p
      (input  temp-date      /* p-last-date         */
      ,input  true           /* p-check-act         */
      ,input  v-cntxt-db-num /* p-check-act-db-num  */
      ,input  v-cntxt-userid /* p-check-act-user-id */
      ) no-error .
    if error-status :error
    then do:
      message
        "ВНИМАНИЕ!" skip
        "Межфирменные архивы" skip
        return-value skip
        "Данные по выбранному периоду могут быть неполными или некорректными."
        "Продолжить формирование отчета?" skip
        view-as alert-box question buttons yes-no update choice .
      if choice = false
      then do:
        assign
          v-total-archive-ok = false
        .
      end.
      else do:
        assign
          v-total-archive-ok = true
        .
      end.
    end.
  end.

  if verify-arc-ot   = true
      or verify-arc-stk  = true
      or verify-arc-aht  = true
      or verify-arc-supp = true
      then do:

        if  verify-arc-ot = true
        and verify-arc-stk <> true
        then do:
          assign
            verify-arc-stk = true
          .
        end.

    spis-obj = "" .
    v-total-archive-ok  = true .

    for each obj-list no-lock :
      if param-date = 1
      then do:
        assign
          v-date-start = x-date-alone
          v-date-end   = x-date-alone
        .
      end.
      else do:
        assign
          v-date-start = x-date-start
          v-date-end   = x-date-end
        .
      end.

      run rep/chk-ahz.p
        (input        obj-list.obj-type /* p-obj-type          */
        ,input        obj-list.obj-code /* p-obj-code          */
        ,input        verify-arc-ot     /* p-verify-detail     */
        ,input        verify-arc-stk    /* p-verify-arh        */
        ,input        verify-arc-supp   /* p-verify-ahsp       */
        ,input        verify-arc-aht    /* p-verify-aht        */
        ,input        true              /* p-check-act         */
        ,input        v-cntxt-db-num    /* p-check-act-db-num  */
        ,input        v-cntxt-userid    /* p-check-act-user-id */
        ,input-output v-date-start      /* p-date-start        */
        ,input-output v-date-end        /* p-date-end          */
        ,output       v-archive-ok      /* p-archive-ok        */
        ,output       v-comment         /* p-comment           */
        ,output       v-can-print       /* p-can-print         */
        ) .
      if v-archive-ok = false
      then do:
        if v-can-print = false or verify-arc-strong  = true
        then do:
          message
            "ВНИМАНИЕ !!!" skip
            "Отчет не может быть сформирован!" skip
            "На запрошенную дату нет архивов или они сжаты" skip
            v-comment skip
            view-as alert-box information .

          run select-page in this-procedure
            (input 0
            ).
          run select-page in this-procedure
            (input 1
            ).
          undo, return error return-value .
        end.
        else do:     /* можно печатать */
          assign
            v-total-archive-ok = false
            spis-obj =  spis-obj + substitute("&1&2," , obj-list.obj-type , obj-list.obj-code)  /* Кривые объекты*/
          .
        end.
      end.
    end.

    spis-obj = trim(spis-obj, ',') .

    if v-total-archive-ok = false
    then do:
      define variable v-period-description as character no-undo .

      if param-date = 1
      then do:
        assign
          v-period-description = substitute("на конец дня &1"
                                           ,string(x-date-end, '99/99/9999':u)
                                           )
        .
      end.
      else do:
        assign
          v-period-description = substitute("с начала дня &1 по конец дня &2"
                                           ,string(x-date-start, '99/99/9999':u)
                                           ,string(x-date-end,   '99/99/9999':u)
                                           )
        .
      end.

      message
        "ВНИМАНИЕ!" skip
        v-comment skip
        spis-obj skip
        "" skip

        "Данные по выбранному периоду" v-period-description "могут быть неполными или некорректными." skip
        "Продолжить формирование отчета?" skip
        view-as alert-box question buttons yes-no update choice .
      if choice = false
      then do:
        assign
          v-archive-ok = false
        .
        return.
      end.
      else do:
        assign
          v-total-archive-ok = true
        .
      end.
    end.
  end.

  if v-total-archive-ok = true
  then do:
    if param-alon = false
    then do:
      run initilize-page-3 in this-procedure .
      run return-var in this-procedure .
      if  (reportpageheight = 0  or reportpagewidth = 0)
      and format-folder
      then do:
        run get-var-2 in h_format no-error.
        if (reportpageheight = 0  or reportpagewidth = 0)
        then do:
          run select-page in this-procedure
            (input 3
            ) no-error .
          /* message "Задайте значения для размера страницы отчета !". */
          undo, return error return-value .
        end.
      end.
      run my-var in h_special no-error.
      { rep/link-err.i }
    end.

    if v-archive-ok = false and
        (  verify-arc-ot   = true
        or verify-arc-stk  = true
        or verify-arc-aht  = true
        or verify-arc-supp = true )

    then do:
      assign
        reportheader = reportheader + {&new-line}
                     + "Архивы рассчитаны не полностью. Информация в отчете может быть неполной или некорректной."
                     + {&new-line} +
                     (if spis-obj <> "" then substitute("Не корректная информация об архивах на объектах: &1" ,spis-obj ) else "")

      .
    end.

    assign
      G#rep-updflds = ReportName + " " + str1
    .
    assign
      v-d-report-handle = this-procedure
    .
    /* вызов отчета */
    RUN set-cursor IN adm-broker-hdl ("WAIT").
    If param-Alon
    then do:
      run openforexcel in this-procedure .
      if num-entries (trim(procname), " " ) > 1  then do:

          define variable p-proc-par1 as character no-undo .
          define variable p-proc-par2 as character no-undo .

          assign
            p-proc-par1 = entry(1, procname, " ")
            p-proc-par2 = entry(2, procname, " ")
          .

          run value ( p-proc-par1 )
            (input p-proc-par2
            ).
      end.
      else do:
          run value ( procname ) . /* если закладка одна */
      end.

      run CloseForExcel in this-procedure .
    End.
    else do:
      run OpenForExcel in this-procedure  .
      run my-report in h_special no-error .  /* вызов отчета с параметрами*/
      { rep/link-err.i }
      run CloseForExcel in this-procedure  .
    end.
    run set-cursor in adm-broker-hdl ("").
  End.
  assign
    v-d-report-handle = ?
  .
  run prg-bar_delete-progress-bar in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE return-var D-Dialog
PROCEDURE return-var :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  run read-table IN h_list no-error.
  run get-var-2 IN h_format no-error.
  run my-var IN h_special no-error.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records D-Dialog  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* SEND-RECORDS does nothing because there are no External
     Tables specified for this SmartDialog, and there are no
     tables specified in any contained Browse, Query, or Frame. */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed D-Dialog
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
END PROCEDURE.


PROCEDURE make-ach :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :
  run my-var in h_special  no-error.  /* есть ли выброс в АКЧУэйт  */
  run assign-frame in h_main no-error .
  run report-to-ach  in h_special (input-output table param-to-export ) no-error.  /* есть ли выброс в АКЧУэйт  */
  if error-status :error = true then return error .


  define variable exp-name as character no-undo .
  /* создается временный командный файл для выполнения команды */

  run gbl/_tmpfile.p ( "t", ".par", output exp-name) .
/*
  message "параметры запуска в файле " exp-name
  .
*/

  OUTPUT STREAM str-export TO  VALUE(exp-name).

      for each param-to-export :
        EXPORT STREAM str-export param-to-export .
      end.

  OUTPUT STREAM str-export CLOSE.

define variable res as integer no-undo .
define variable name-exe as character no-undo .

  assign
    file-info:file-name = "exe/run-act.bat".
    name-exe = file-info:full-pathname
  no-error .
  if error-status :error then return error .

run gbl/syn.p ( input name-exe , input  exp-name , input  "Запуск " + name-exe , output res ).
if  res > 0
then do:
  message  "Ошибка  при выполнении команды в ОС "  res .
end.

  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save-param-RUM W-Win
PROCEDURE proc-save-param-RUM :
/* -----------------------------------------------------------
  Purpose: СОХРАНЕНИЕ параметров отчета в БД по ПРАВИЛАМ RUM
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  /* проверка правильности интервала дат */
  run verify-date in h_main no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.

  /* проверка правильности объекта (что он выбран) */

  run verify-obj in h_main no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.

  /* считывание всех переменных с экрана */
  run assign-frame in h_main .

  /* составление списка товаров по производителям и группам */
  run make-6-gds-list in h_main .

  if param-alon = false   then do:
    run initilize-page-3 in this-procedure .
    run return-var in this-procedure .
    if  (reportpageheight = 0  or reportpagewidth = 0)
    and format-folder
    then do:
      run get-var-2 in h_format no-error.
      if (reportpageheight = 0  or reportpagewidth = 0)
      then do:
        run select-page in this-procedure
          (input 3
          ) no-error .
        undo, return error return-value .
      end.
    end.
    run my-var in h_special no-error.
    if error-status:error then
     do:
        case return-value:
            When 'First-page':U then  do:
                return error.
            end.
            When 'Second-page':U then  do:
                  message "Проверьте правильность заполнения формы!".
                  run select-page in this-procedure ( 2 ).
                  return  error .
            end.
            when 'format-page' then DO:
                  message "Необходимо сходить на закладку <Формат...> !".
                  run select-page in this-procedure ( 3 ).
                  return error.
            end.
            otherwise  do:
                message "Необходимо сходить на закладку <Продолжение...> !".
                run select-page in this-procedure ( 2 ).
                return error.
            end.
        end case.
     end.
  end.

  run my-params in h_special ( input "set" ) no-error .
  { rep/link-err.i }


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME