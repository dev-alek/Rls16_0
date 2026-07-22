&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS V-table-Win 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр шапки документа

Автор: Суслов Алексей Юрьевич
Дата создания: 03/27/06
Author: Alexey Suslov
Creation date: 03/27/06

*/

/* Create an unnamed pool to store all the widgets created
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр шапки документа".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/clntattr.i }
{ gbl/thbjattr.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/color.i    }
{ gbl/twowin.i   }
{ str/trdcalib.i }
{ gbl/cur-time.i }
{ gbl/sys-time.i }
{ cmp/trg-def.i  }
/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
DEFINE BUFFER locked_thbj-attr FOR thbj-attr.

define variable v-tth           as   handle       no-undo .
define variable v-to-create     as   logical      no-undo .
DEFINE VARIABLE v-db-num        like ub.db.db-num no-undo.

define variable v-list-dop-info-full as character    no-undo.
define variable v-list-dop-info      as character    no-undo.

define temp-table temp_twowin_itemsSelected_col no-undo
    field its-key   as integer
    field itm-key   as integer
    field itmExtKey as character

    index pi is primary unique
      its-key
    index im
      itm-key
.

define variable v-list-sec-fields-full as character    no-undo.
define variable v-list-sec-fields      as character    no-undo.

define temp-table sect_twowin_itemsSelected_col no-undo
    field its-key   as integer
    field itm-key   as integer
    field itmExtKey as character

    index pi is primary unique
      its-key
    index im
      itm-key
.

DEFINE VARIABLE parparentproc AS WIDGET-HANDLE       NO-UNDO.
DEFINE VARIABLE p-mode        AS CHARACTER           NO-UNDO.
DEFINE VARIABLE p-obj-type  LIKE ub.clients.obj-type NO-UNDO.
DEFINE VARIABLE p-obj-code  LIKE ub.shop.obj-code    NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-8 t-autopump-izm t-autopump t-avtinvpm ~
t-olddens t-trnscanqr t-rvd-own-nb qr-scan-time t-autopump-skip-time ~
t-block-nozzle timeout-block-nozzle rvs-wt-email 
&Scoped-Define DISPLAYED-OBJECTS t-autopump-izm t-autopump t-avtinvpm ~
t-olddens t-trnscanqr t-rvd-own-nb qr-scan-time t-autopump-skip-time ~
t-block-nozzle timeout-block-nozzle rvs-wt-email 

/* Custom List Definitions                                              */
/* ADM-CREATE-FIELDS,ADM-ASSIGN-FIELDS,List-3,List-4,List-5,List-6      */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Foreign Keys" V-table-Win _INLINE
/* Actions: ? adm/support/keyedit.w ? ? ? */
/* STRUCTURED-DATA
<KEY-OBJECT>
THIS-PROCEDURE
</KEY-OBJECT>
<FOREIGN-KEYS>
</FOREIGN-KEYS>
<EXECUTING-CODE>
**************************
* Set attributes related to FOREIGN KEYS
*/
RUN set-attribute-list (
    'Keys-Accepted = "",
     Keys-Supplied = ""':U).
/**************************
</EXECUTING-CODE> */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE qr-scan-time AS INTEGER FORMAT ">>>>>9":U INITIAL 5000 
     LABEL "Время на сканирование QR-кода (мс)" 
     VIEW-AS FILL-IN 
     SIZE 9 BY 1 NO-UNDO.

DEFINE VARIABLE rvs-wt-email AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 90 BY .92 NO-UNDO.

DEFINE VARIABLE t-autopump-skip-time AS INTEGER FORMAT "->,>>>,>>9" INITIAL 0 
     LABEL "Время после приема НП (мин)" 
     VIEW-AS FILL-IN 
     SIZE 5 BY 1 NO-UNDO.

DEFINE VARIABLE timeout-block-nozzle AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 5 
     VIEW-AS FILL-IN 
     SIZE 7.5 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 118.5 BY 27.25.

DEFINE VARIABLE t-autopump AS LOGICAL INITIAL no 
     LABEL "Автоматические сверки создавать с чтением всех счетчиков ТРК" 
     VIEW-AS TOGGLE-BOX
     SIZE 82.5 BY .83 NO-UNDO.

DEFINE VARIABLE t-autopump-izm AS LOGICAL INITIAL no 
     LABEL "Автоматические сверки создавать только по измеряемым резервуарам" 
     VIEW-AS TOGGLE-BOX
     SIZE 82.5 BY .83 NO-UNDO.

DEFINE VARIABLE t-avtinvpm AS LOGICAL INITIAL no 
     LABEL "Автомат. создание инв. счетчиков ТРК при переполнении разрядности эл. счетчика" 
     VIEW-AS TOGGLE-BOX
     SIZE 82.5 BY .83 TOOLTIP "если включено, то контроль и создание происходит при закрытии сверки" NO-UNDO.

DEFINE VARIABLE t-block-nozzle AS LOGICAL INITIAL yes 
     LABEL "Отправлять блокировку пистолетов при приемке" 
     VIEW-AS TOGGLE-BOX
     SIZE 47.5 BY .83 NO-UNDO.

DEFINE VARIABLE t-olddens AS LOGICAL INITIAL no 
     LABEL "В документы по умолчанию ставится плотность и темп. из предыдущего документа" 
     VIEW-AS TOGGLE-BOX
     SIZE 81.5 BY .83 NO-UNDO.

DEFINE VARIABLE t-rvd-own-nb AS LOGICAL INITIAL no 
     LABEL "Разрешить ручное заполнение документа приёма НП при поставках с собственных НБ" 
     VIEW-AS TOGGLE-BOX
     SIZE 83 BY .83 NO-UNDO.

DEFINE VARIABLE t-trnscanqr AS LOGICAL INITIAL no 
     LABEL "Автозаполнение НП" 
     VIEW-AS TOGGLE-BOX
     SIZE 30 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     t-autopump-izm AT ROW 1.25 COL 2.5 WIDGET-ID 40
     t-autopump AT ROW 2 COL 2.5 WIDGET-ID 542
     t-avtinvpm AT ROW 2.75 COL 2.5 WIDGET-ID 42
     t-olddens AT ROW 3.5 COL 2.5 WIDGET-ID 76
     t-trnscanqr AT ROW 4.25 COL 2.5 WIDGET-ID 128
     t-rvd-own-nb AT ROW 5 COL 2.5 WIDGET-ID 544
     qr-scan-time AT ROW 6 COL 37 COLON-ALIGNED WIDGET-ID 546
     t-autopump-skip-time AT ROW 6 COL 79 COLON-ALIGNED WIDGET-ID 250
     t-block-nozzle AT ROW 7 COL 3 WIDGET-ID 600
     timeout-block-nozzle AT ROW 8 COL 3 NO-LABEL WIDGET-ID 604
     rvs-wt-email AT ROW 11 COL 3 NO-LABEL WIDGET-ID 90
     "на список почтовых адресов(разделять адреса запятыми):" VIEW-AS TEXT
          SIZE 62.5 BY .96 AT ROW 10.04 COL 3 WIDGET-ID 94
     "При приеме новостей, если в сверке вода, отправлять сообщения" VIEW-AS TEXT
          SIZE 64.5 BY .96 AT ROW 9.25 COL 3 WIDGET-ID 92
     "Timeout ожидания подтверждения блокировки пистолетов, с" VIEW-AS TEXT
          SIZE 57.5 BY .67 AT ROW 8.25 COL 11.5 WIDGET-ID 606
     RECT-8 AT ROW 1 COL 1 WIDGET-ID 608
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE .


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   Allow: Basic,DB-Fields
   Frames: 1
   Add Fields to: External-Tables
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW V-table-Win ASSIGN
         HEIGHT             = 27.42
         WIDTH              = 118.75.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB V-table-Win 
/* ************************* Included-Libraries *********************** */

{src/adm/method/viewer.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW V-table-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE FRAME-NAME Size-to-Fit                                   */
ASSIGN 
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

ASSIGN 
       RECT-8:HIDDEN IN FRAME F-Main           = TRUE.

/* SETTINGS FOR FILL-IN rvs-wt-email IN FRAME F-Main
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN timeout-block-nozzle IN FRAME F-Main
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

&Scoped-define SELF-NAME t-block-nozzle
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-block-nozzle V-table-Win
ON VALUE-CHANGED OF t-block-nozzle IN FRAME F-Main /* Отправлять блокировку пистолетов при приемке */
DO:
  assign t-block-nozzle .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME timeout-block-nozzle
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL timeout-block-nozzle V-table-Win
ON LEAVE OF timeout-block-nozzle IN FRAME F-Main
DO:
  assign timeout-block-nozzle .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK V-table-Win 


/* ***************************  Main Block  *************************** */
/* no_app_help.i */
{ gbl/personly.i }

  &IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
    RUN dispatch IN THIS-PROCEDURE ('initialize':U).
  &ENDIF
      
  /************************ INTERNAL PROCEDURES ********************/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available V-table-Win  _ADM-ROW-AVAILABLE
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
  if p-mode = {&lookup} then do:        
      run disable-all IN THIS-PROCEDURE.          
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI V-table-Win  _DEFAULT-DISABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable-all V-table-Win  _DEFAULT-DISABLE
PROCEDURE disable-all :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/  
    disable
      all
      with frame {&frame-name} .       
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PartTwo-Init V-table-Win 
PROCEDURE PartTwo-Init :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER iParparentproc AS WIDGET-HANDLE       NO-UNDO.
  DEFINE INPUT PARAMETER iMode          AS CHARACTER           NO-UNDO.
  DEFINE INPUT PARAMETER iObjtype       LIKE ub.clients.obj-type NO-UNDO.
  DEFINE INPUT PARAMETER iObjcode       LIKE ub.shop.obj-code    NO-UNDO.
  DEFINE INPUT PARAMETER TABLE FOR temp-thbj-attr.
  define variable v-entry           as character  no-undo .
  assign
     parparentproc = iParparentproc
     p-mode        = iMode
     p-obj-type    = iObjtype
     p-obj-code    = iObjcode
     .
  for each temp-thbj-attr no-lock      
        :
   /*run utl/dbgprint.p (substitute("prt2 code &1 character &2 logical &3",
      temp-thbj-attr.prop-code, 
      temp-thbj-attr.property-value-character,
      temp-thbj-attr.property-value-logical)).*/
      
    assign
      v-entry = temp-thbj-attr.prop-code
    .
    case v-entry:
        /*
      when {&attr-petrol_denstclc} then do:
        assign
          r-denstclc = temp-thbj-attr.property-value-character
          r-denstclc :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
        .
      end.
       */
      when {&attr-petrol_autopump} then do:
        assign
          t-autopump = temp-thbj-attr.property-value-logical
          t-autopump :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
        .
      end.
        when {&attr-petrol_autopump-izm} then do: 
          assign t-autopump-izm =  temp-thbj-attr.property-value-logical
                 t-autopump-izm :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
        .
          end.     
      when {&attr-petrol_autopump-skip-time} then do: 
          assign t-autopump-skip-time =  temp-thbj-attr.property-value-integer
             t-autopump-skip-time :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
        .
      end.
                
      when {&attr-petrol_avtinvpm} then do:
        assign
          t-avtinvpm = temp-thbj-attr.property-value-logical
          t-avtinvpm :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
        .
      end.
      /*
      when {&attr-petrol_expptrl} then do:
        assign
          r-expptrl = temp-thbj-attr.property-value-character
          r-expptrl :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
        .
      end.
      when {&attr-petrol_inpptrl} then do:
        assign
          r-inpptrl = temp-thbj-attr.property-value-character
          r-inpptrl :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
        .
      end.
      when {&attr-petrol_rvsnmter} then do:
        assign
          t-rvsnmter = temp-thbj-attr.property-value-logical
          t-rvsnmter :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
        .
      end.
      when {&attr-petrol_invclipt} then do:
        assign
          f-invclipt = temp-thbj-attr.property-value-integer
          f-invclipt :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
        .
      end.
      */
      when {&attr-petrol_olddens} then do:
        assign
          t-olddens = temp-thbj-attr.property-value-logical
          t-olddens :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
        .
      end.
      /*
      when {&attr-petrol_algrvspt} then do:
        assign
          r-algrvspt = temp-thbj-attr.property-value-integer
          r-algrvspt :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
        .
      end.
      when {&attr-petrol_temp-for-pomi} then do:
        assign
          r-temp-for-pomi = temp-thbj-attr.property-value-integer
          r-temp-for-pomi :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
        .
      end.
      */
      when {&attr-petrol_rvs-wt-email} then do:
        assign
          rvs-wt-email = temp-thbj-attr.property-value-character
          rvs-wt-email :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
        .
      end.
      /*
      when {&attr-petrol_CriticalDif} then 
          do:
            assign 
              mass-proc = temp-thbj-attr.property-value-character 
              mass-proc :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
            .  
          end.
      when {&attr-petrol_algoincome} then 
          do: 
            assign
              r-algoincptrl = temp-thbj-attr.property-value-integer 
              r-algoincptrl :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
              .
          end.
      when {&attr-petrol_otkl-fact-volue} then 
          do: 
            assign
              otkl-fact-volue = temp-thbj-attr.property-value-decimal 
              otkl-fact-volue :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
              .
          end.
      when {&attr-petrol_otkl-temp} then 
          do: 
            assign
              otkl-temp = temp-thbj-attr.property-value-decimal 
              otkl-temp :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
              .
          end.          
      when {&attr-petrol_otkl-density} then 
          do: 
            assign
              otkl-density = temp-thbj-attr.property-value-character 
              otkl-density :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
              .
              if otkl-density = "" then otkl-density = "0.000" .
          end.          
      when {&attr-petrol_otkl-water} then 
          do: 
            assign
              otkl-water = temp-thbj-attr.property-value-decimal 
              otkl-water :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
              .
          end.                                            
      when {&attr-petrol_mand-choice-autocar} then 
          do: 
            assign
              t-mand-chioce-autocar = temp-thbj-attr.property-value-logical 
              t-mand-chioce-autocar :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
            .  
          end.
          */
      when {&attr-petrol_block-nozzle} then 
          do: 
            assign
              t-block-nozzle = temp-thbj-attr.property-value-logical 
              t-block-nozzle :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
            .  
          end.          
      when {&attr-petrol_timeout-block-nozzle} then 
          do: 
            assign
              timeout-block-nozzle = temp-thbj-attr.property-value-integer 
              timeout-block-nozzle :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
            .  
          end.
          /*  
        when {&attr-petrol_dop-info} then 
          do:
            assign 
              dop-info = temp-thbj-attr.property-value-character 
              dop-info :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
            .  
          end.
        when {&attr-petrol_sec-fields} then 
          do:
            assign 
              sec-fields = temp-thbj-attr.property-value-character 
              sec-fields :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
            .  
          end.
        when {&attr-petrol_CriticalDifInLgas} then 
          do:
            assign 
              mass-proc-in-lgas = temp-thbj-attr.property-value-decimal 
              mass-proc-in-lgas :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
            .  
          end.
        when {&attr-petrol_calc-free-vol} then 
          do: 
            assign
              t-calc-free-vol = temp-thbj-attr.property-value-logical 
              t-calc-free-vol :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
            .  
          end.
        when {&attr-petrol_calc-free-vol-sug} then 
          do: 
            assign
              t-calc-free-vol-sug = temp-thbj-attr.property-value-logical 
              t-calc-free-vol-sug :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
            .  
          end.
        when {&attr-petrol_trn-reas-sug} then 
          do: 
            assign
              t-trn-reas-sug = temp-thbj-attr.property-value-logical 
              t-trn-reas-sug :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
            .  
          end.
        */  
        when {&attr-petrol_rvd-own-nb} then 
          do: 
            assign
              t-rvd-own-nb = temp-thbj-attr.property-value-logical 
              t-rvd-own-nb :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
            .  
          end.          
        when {&attr-petrol_qr-scan-time} then
          do:
            assign
              qr-scan-time = temp-thbj-attr.property-value-integer
              qr-scan-time :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
            .
        end.        
        when {&attr-petrol_trnscanqr} then 
          do: 
            assign
              t-trnscanqr = temp-thbj-attr.property-value-logical 
              t-trnscanqr :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
            .  
          end.        
        otherwise do:
            delete temp-thbj-attr.
        end.  
    end case.    
  end.  
  DISPLAY {&DISPLAYED-OBJECTS}
      WITH FRAME F-Main.    
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records V-table-Win  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* SEND-RECORDS does nothing because there are no External
     Tables specified for this SmartObject, and there are no
     tables specified in any contained Browse, Query, or Frame. */
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed V-table-Win 
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.
  
  CASE p-state:
      /* Object instance CASEs can go here to replace standard behavior
         or add new cases. */
      {src/adm/template/vstates.i}
  END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PartTwo-Get V-table-Win  _ADM-SEND-RECORDS
PROCEDURE PartTwo-Get :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/
   DEFINE INPUT-OUTPUT PARAMETER TABLE FOR temp-thbj-attr append.
  
   define variable wh                as widget-handle  no-undo .
   define variable fh                as widget-handle  no-undo . 
   define buffer buf_clients for ub.clients .
   
   ASSIGN FRAME {&FRAME-NAME} {&DISPLAYED-OBJECTS}.
/*=============
display dop-info sec-fields with frame {&frame-name} .
hide dop-info sec-fields in frame {&frame-name} .
==============*/
  
  assign
/*==    frame {&frame-name} t-invclipt
    frame {&frame-name} f-invclipt  ==*/
    fh = frame {&frame-name}:first-child
    wh = fh:first-child
  .
/*================
  if t-invclipt = true then do:
    find first buf_clients no-lock
      where buf_clients.obj-code = f-invclipt
        and buf_clients.obj-type = {&cmp}
      no-error.
    if not available buf_clients then do:
      message
        "Некорректное значение НАСТРОЙКИ"    skip
        t-invclipt:label                     skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
==================*/
  do while valid-handle(wh):
    if wh:private-data begins "recid=" then do:
      find first temp-thbj-attr  
        where recid(temp-thbj-attr) = integer(entry(2, wh:private-data, '='))
      .
      assign
        buffer temp-thbj-attr:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value
      .
    end.
    wh = wh:next-sibling.
  end.
  /*       
   for each temp-thbj-attr       
        :     
    case temp-thbj-attr.prop-code:
      when {&attr-petrol_CriticalDif} then 
          do:
            assign 
              temp-thbj-attr.property-value-character = mass-proc               
            .  
          end.
      when {&attr-petrol_algoincome} then 
          do: 
            assign
              temp-thbj-attr.property-value-integer = r-algoincptrl               
              .
          end.                             
      when {&attr-petrol_mand-choice-autocar} then 
          do: 
            assign
              temp-thbj-attr.property-value-logical = t-mand-chioce-autocar               
            .  
          end.       
      when {&attr-petrol_CriticalDifInLgas} then 
          do:
            assign 
              temp-thbj-attr.property-value-decimal = mass-proc-in-lgas               
            .  
          end.
      
    end case.  
  end.
  */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME