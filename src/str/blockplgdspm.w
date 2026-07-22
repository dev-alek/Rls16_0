&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

define temp-table tt_marking no-undo
   field marking-string as character label "*"
   field obj-type       as character 
   field obj-code       as integer
   field pl-code        as integer   label "Код резервуара"
   field gds-code       as integer   label "Код товара"
   field pump-code      as integer   label "Номер ТРК"
   field nozzle-code    as integer   label "Номер пистолета"
   field artic          as character label "Артикул"
   field gds-name       as character label "Название"
   field loc1           as character label "Резервуар"
   field status_        as character label "Статус"
   field pl-name        as character label "Название резервуара"
   field prod-code      as integer   label "Производитель"
   field prod-type      as character label "товара"
   field search-log     as logical
   index pi as UNIQUE pl-code gds-code pump-code nozzle-code.


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_goods          FOR goods.
DEFINE BUFFER X_pl-gds-pump    FOR pl-gds-pump.
DEFINE BUFFER X_pl-pump-nozzle FOR pl-pump-nozzle.
DEFINE BUFFER X_place          FOR place.
define buffer X_marking        for tt_marking .


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Блокировка пистолетов

Автор: Шкляр Елена 
Дата создания: 08/15/07
Author: Elena Shklyar
Creation date: 08/15/07


*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter parobj-type like ub.clients.obj-type no-undo.
define input parameter parobj-code like ub.clients.obj-code no-undo.
define input parameter parbutton   as   character           no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Блокировка пистолетов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ cmp/library.i  }
{ str/nzpl-spl.i }
{ trg/cplgdspm.i }
{ gbl/getcntxt.i def }
{ gbl/waitfram.i }

define variable varlog            as logical   no-undo.
define variable gds-rec           as recid     no-undo .
define variable v-doc-rec         as recid     no-undo .
define variable pl-list           as character no-undo .
define variable v-tth             as handle    no-undo.
define variable v-Param-Type      as character no-undo.
define variable glog              as logical   no-undo.
define variable v-value-character as character no-undo.
define variable v-value-date      as date      no-undo.
define variable v-value-decimal   as decimal   no-undo.
define variable v-value-integer   as integer   no-undo.
define variable v-value-logical   as logical   no-undo.
define variable filter-label      as character no-undo init "Блокировка пистолетов" .
define variable filter-label0     as character no-undo init "Блокировка пистолетов" .
define variable filter-point      as character no-undo init "blockplgdspm".
define variable filter-point0     as character no-undo init "blockplgdspm".
define variable v-ok              as logical   no-undo .
define variable v-title           as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME b-plgdspm

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_marking

/* Definitions for BROWSE b-plgdspm                                     */
&Scoped-define FIELDS-IN-QUERY-b-plgdspm X_marking.marking-string X_marking.pump-code X_marking.nozzle-code X_marking.artic X_marking.gds-code X_marking.gds-name X_marking.loc1 X_marking.status_ X_marking.pl-code X_marking.pl-name X_marking.prod-code X_marking.prod-type   
&Scoped-define ENABLED-FIELDS-IN-QUERY-b-plgdspm   
&Scoped-define SELF-NAME b-plgdspm
&Scoped-define QUERY-STRING-b-plgdspm FOR EACH X_marking OUTER-JOIN BY X_marking.obj-type      BY X_marking.obj-code       BY X_marking.pump-code        BY X_marking.nozzle-code
&Scoped-define OPEN-QUERY-b-plgdspm OPEN QUERY {&SELF-NAME} FOR EACH X_marking OUTER-JOIN BY X_marking.obj-type      BY X_marking.obj-code       BY X_marking.pump-code        BY X_marking.nozzle-code.
&Scoped-define TABLES-IN-QUERY-b-plgdspm X_marking 

&Scoped-define firtht-TABLE-IN-QUERY-b-plgdspm X_marking


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-b-plgdspm}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-cur b-block B-hist b-help ~
search-goods b-mark bt-not-sel-all bt-not-sel-desel-all b-plgdspm 
&Scoped-Define DISPLAYED-OBJECTS search-goods 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-block 
   LABEL "&Блок в МП" 
   SIZE 10 BY 1 TOOLTIP "Установить статут <Блокированный>".
   
DEFINE BUTTON b-cur 
   LABEL "&Текущий" 
   SIZE 10 BY 1 TOOLTIP "Установить статут <Текущий>".

DEFINE BUTTON b-exit AUTO-GO 
   LABEL "&Выход" 
   SIZE 10 BY 1
   BGCOLOR 8 .

DEFINE BUTTON b-help 
   LABEL "&Помощь" 
   SIZE 3 BY 1
   BGCOLOR 8 .

DEFINE BUTTON B-hist 
   LABEL "Ис&тория" 
   SIZE 3 BY 1.

DEFINE BUTTON b-mark 
   LABEL "&*" 
   SIZE 3 BY 1.

DEFINE BUTTON b-repeate-block 
   LABEL "b-repeate-block" 
   SIZE 10 BY 1.

DEFINE BUTTON b-repeate-unblock 
   LABEL "b-repeate-unblock" 
   SIZE 10 BY 1.

DEFINE BUTTON b-unblock 
   LABEL "&Разблок" 
   SIZE 10 BY 1.

DEFINE BUTTON bt-not-sel-all 
   LABEL "+" 
   SIZE 3 BY 1 TOOLTIP "Выбрать все".

DEFINE BUTTON bt-not-sel-desel-all 
   LABEL "-" 
   SIZE 3 BY 1 TOOLTIP "Отменить выбор".

DEFINE VARIABLE c-nozzle-code AS INTEGER   FORMAT ">>9":U INITIAL 0 
   LABEL "Номер пистолета" 
   VIEW-AS COMBO-BOX INNER-LINES 5
   LIST-ITEMS "0","1","2","3","4" 
   DROP-DOWN-LIST
   SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE c-pump-code   AS INTEGER   FORMAT ">>9":U INITIAL 0 
   LABEL "Номер ТРК" 
   VIEW-AS COMBO-BOX INNER-LINES 5
   LIST-ITEMS "0","1","2","3","4" 
   DROP-DOWN-LIST
   SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE search-goods  AS CHARACTER FORMAT "X(256)":U 
   LABEL "Фильтр по товару" 
   VIEW-AS FILL-IN 
   SIZE 60 BY 1 TOOLTIP "Введите начало любого слова в названии товара и нажать Enter" NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY b-plgdspm FOR 
   X_marking
   SCROLLING.
&ANALYZE-RESUME

if parbutton = "un-block" then v-title = "Разблокировка пистолетов" .
else v-title = "Блокировка пистолетов" . 
   
/* Browse definitions                                                   */
DEFINE BROWSE b-plgdspm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b-plgdspm Dialog-Frame _FREEFORM
   QUERY b-plgdspm NO-LOCK DISPLAY
   X_marking.marking-string column-label "*" format "X(3)":U
   X_marking.pump-code FORMAT ">9":U
   X_marking.nozzle-code FORMAT ">9":U
   X_marking.artic FORMAT "X(16)":U
   X_marking.gds-code FORMAT "999999999":U
   X_marking.gds-name FORMAT "X(10)":U
   X_marking.loc1 COLUMN-LABEL "Резервуар" FORMAT "X(8)":U
   X_marking.status_ FORMAT "X(8)":U
   X_marking.pl-code COLUMN-LABEL "Код резервуара" FORMAT ">>>>>>>>>>>>9":U
   X_marking.pl-name COLUMN-LABEL "Название резервуара"
   X_marking.prod-code FORMAT ">>>>>>>>9":U
   X_marking.prod-type COLUMN-LABEL "товара" FORMAT "X(3)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 15.42.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
   b-exit AT ROW 1 COL 1.25
   b-cur AT ROW 1 COL 11.25
   b-unblock AT ROW 1 COL 21.25
   b-block AT ROW 1 COL 22
   b-repeate-block AT ROW 1 COL 22
   b-repeate-unblock AT ROW 1 COL 22
   B-hist AT ROW 1 COL 92.88
   b-help AT ROW 1 COL 95.88
   search-goods AT ROW 2.25 COL 18 COLON-ALIGNED WIDGET-ID 2
   c-pump-code AT ROW 3.38 COL 29 COLON-ALIGNED WIDGET-ID 16
   c-nozzle-code AT ROW 3.38 COL 62.38 COLON-ALIGNED WIDGET-ID 18
   b-mark AT ROW 3.75 COL 1.13 WIDGET-ID 4
   bt-not-sel-all AT ROW 3.75 COL 4 WIDGET-ID 10 NO-TAB-STOP 
   bt-not-sel-desel-all AT ROW 3.75 COL 6.88 WIDGET-ID 12 NO-TAB-STOP 
   b-plgdspm AT ROW 4.67 COL 1
   SPACE(0.24) SKIP(0.44)
   WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
   SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
   TITLE v-title
   DEFAULT-BUTTON b-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_goods B "?" ? ub goods
      TABLE: X_pl-gds-pump B "?" ? ub pl-gds-pump
      TABLE: X_pl-pump-nozzle B "?" ? ub pl-pump-nozzle
      TABLE: X_place B "?" ? ub place
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB b-plgdspm bt-not-sel-desel-all Dialog-Frame */
ASSIGN 
   FRAME Dialog-Frame:SCROLLABLE = FALSE
   FRAME Dialog-Frame:HIDDEN     = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b-plgdspm
/* Query rebuild information for BROWSE b-plgdspm
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_pl-gds-pump
      WHERE X_pl-gds-pump.obj-type = parobj-type
 AND X_pl-gds-pump.obj-code = parobj-code NO-LOCK,
      EACH X_goods WHERE X_goods.gds-code = X_pl-gds-pump.gds-code NO-LOCK,
      EACH X_place WHERE X_place.pl-code = X_pl-gds-pump.pl-code NO-LOCK,
      EACH X_pl-pump-nozzle WHERE X_pl-pump-nozzle.obj-type = X_pl-gds-pump.obj-type
  AND X_pl-pump-nozzle.obj-code = X_pl-gds-pump.obj-code
  AND X_pl-pump-nozzle.pl-code = X_pl-gds-pump.pl-code
  AND X_pl-pump-nozzle.pump-code = X_pl-gds-pump.pump-code OUTER-JOIN NO-LOCK
    BY X_pl-gds-pump.obj-type
     BY X_pl-gds-pump.obj-code
      BY X_pl-pump-nozzle.pump-code
       BY X_pl-pump-nozzle.nozzle-code.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _TblOptList       = ",,, OUTER"
     _OrdList          = "ub.pl-gds-pump.obj-type|yes,ub.pl-gds-pump.obj-code|yes,ub.pl-pump-nozzle.pump-code|yes,ub.pl-pump-nozzle.nozzle-code|yes"
     _Where[1]         = "pl-gds-pump.obj-type = parobj-type
 AND pl-gds-pump.obj-code = parobj-code"
     _JoinCode[2]      = "goods.gds-code = pl-gds-pump.gds-code"
     _JoinCode[3]      = "place.pl-code = pl-gds-pump.pl-code"
     _JoinCode[4]      = "pl-pump-nozzle.obj-type = pl-gds-pump.obj-type
  AND pl-pump-nozzle.obj-code = pl-gds-pump.obj-code
  AND pl-pump-nozzle.pl-code = pl-gds-pump.pl-code
  AND pl-pump-nozzle.pump-code = pl-gds-pump.pump-code"
     _Query            is OPENED
*/  /* BROWSE b-plgdspm */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Блокировка пистолетов */
   DO:
      APPLY "END-ERROR":U TO SELF.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME search-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL search-goods Dialog-Frame
ON return OF search-goods IN FRAME dialog-frame /* Фильтр по товару */
   DO:
      define variable ii as integer no-undo .

      assign search-goods .

      run sort_ .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME search-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL search-goods Dialog-Frame
ON leave OF search-goods IN FRAME dialog-frame /* Фильтр по товару */
   DO:
      assign search-goods .
      run sort_ .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-block
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-block Dialog-Frame
ON CHOOSE OF b-block IN FRAME Dialog-Frame /* Блок в МП */
   DO:
      define variable quest-ok as logical   no-undo .
      define variable ii       as integer   no-undo .
      define variable jj       as integer   no-undo .
      define variable list-pl  as character no-undo .
  
     
      { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_nozzle-sts_work':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    glog
  }
      IF NOT glog THEN RETURN NO-APPLY.
      if available X_marking then 
      do:
         message "Блокировать выбранные пистолеты в" skip
            "АСУ 'Заправщик'" 
            view-as alert-box question buttons yes-no update quest-ok.
         if quest-ok then 
         do:
        
            pl-list = "".
            for each X_marking where X_marking.marking-string = "*" :
               if pl-list = "" then 
               do:
                  pl-list = 
                     string(X_marking.nozzle-code) + ":" +
                     string(X_marking.pump-code)
                     .
               end.
               else 
               do:
                  pl-list = pl-list + ";" +
                     string(X_marking.nozzle-code) + ":" +
                     string(X_marking.pump-code)
                     .         
               end.   
            end.   

            if pl-list = "" then 
            do:
               message "Ни один пистолет не выбран для блокировки"
                  view-as alert-box.
               {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
               return no-apply .
            end.   
            
            run str/diallog.w ( input parparentproc
               ,input this-procedure
               ,input 'str/get-block-nozzle.p':U
               ,input (v-cntxt-obj-type + {&delim-par} +
               string(v-cntxt-obj-code) + {&delim-par} +
               string(0) + {&delim-par} +  /*p-remote */
               string(0) + {&delim-par} + /*p-shft-close*/
               {&delim-par} +
               {&delim-par} +
               {&delim-par} +
               substitute("&1,&2"
               ,"block"
               ,pl-list))
               ,input yes
               ,input ''
               ,input 'Блокировка выбранных пистолетов') .
            if not error-status:error then 
            do:
               if return-value begins "Для кассы" then 
               do:
                  message return-value
                     view-as alert-box question buttons yes-no update v-ok as logical  .
                  if v-ok then apply "choose" to b-repeate-block in frame {&frame-name} .
                  else                   message "Сообщите в службу поддержки о неуспешной попытке блокировки пистолетов"
                        view-as alert-box.
               end.
               else 
               do:
                  message "Блокировка пистолетов прошла успешно"
                     view-as alert-box.
               end.   
            end.
            else 
            do:
               message return-value
                  view-as alert-box question buttons yes-no update v-ok .
               if v-ok then apply "choose" to b-repeate-block in frame {&frame-name} .
               else                   message "Сообщите в службу поддержки о неуспешной попытке блокировки пистолетов"
                     view-as alert-box.
   
            end.
            apply "choose" to b-exit in frame {&frame-name}.
         end.   
      end.

   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
   DO:
      DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
      IF AVAILABLE X_marking  THEN 
      DO:

         run ref/cplchist.w (
            INPUT parParentProc
            , input parobj-type
            , input parobj-code
            , input "":U /*bttns  */
            , input "subject":U /*p-mode*/
            , input X_marking.obj-type
            , input X_marking.obj-code
            , input X_marking.pl-code
            , input X_marking.gds-code /*p-gds-code*/
            , input X_marking.pump-code /*p-pump-code*/
            , input 0 /*p-nozzle-code*/
            , input {&table_pl-gds-pump} /*p-subject*/
            , input-output v-rid-list
            ) no-error .

      END.

   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
   DO:
      define variable loc#log     as logical no-undo .
      define variable row-marking as rowid   no-undo .
      if available x_marking then 
      do:
         if x_marking.marking-string = "*" then X_marking.marking-string = "" .
         else X_marking.marking-string = "*" . 
         /*      { gbl/markstrn.i X_marking v-rid-list }*/
         row-marking = rowid(X_marking).
 
         loc#log = b-plgdspm:refresh() .
         reposition b-plgdspm to rowid row-marking.
      
         loc#log = b-plgdspm:refresh() .

         if last-event:function <> "MOUSE-SELECT-DBLCLICK" then 
         do:
            loc#log = b-plgdspm:select-next-row () .
            apply "VALUE-CHANGED" to b-plgdspm in frame {&frame-name} .
         end.
         apply "entry" to b-plgdspm in frame {&frame-name}.
      end.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-repeate-block
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-repeate-block Dialog-Frame
ON CHOOSE OF b-repeate-block IN FRAME Dialog-Frame /* b-repeate-block */
   DO:
      define variable quest-ok as logical   no-undo .
      define variable ii       as integer   no-undo .
      define variable jj       as integer   no-undo .
      define variable list-pl  as character no-undo .

            
      run str/diallog.w ( input parparentproc
         ,input this-procedure
         ,input 'str/get-block-nozzle.p':U
         ,input (v-cntxt-obj-type + {&delim-par} +
         string(v-cntxt-obj-code) + {&delim-par} +
         string(0) + {&delim-par} +  /*p-remote */
         string(0) + {&delim-par} + /*p-shft-close*/
         {&delim-par} +
         {&delim-par} +
         {&delim-par} +
         substitute("&1,&2"
         ,"block"
         ,pl-list))
         ,input yes
         ,input ''
         ,input 'Блокировка выбранных пистолетов') .
      if not error-status:error then 
      do:
         if return-value begins "Для кассы" then 
         do:
            message return-value
               view-as alert-box question buttons yes-no update v-ok as logical  .
            if v-ok then apply "choose" to b-repeate-block in frame {&frame-name} .
            else message "Сообщите в службу поддержки о неуспешной попытке блокировки пистолетов"
                  view-as alert-box.
               
         end.
         else 
         do:
            message "Блокировка пистолетов прошла успешно"
               view-as alert-box.
         end.   

      end.
      else 
      do:
         message return-value
            view-as alert-box question buttons yes-no update v-ok .
         if v-ok then apply "choose" to b-repeate-block in frame {&frame-name} .
         else                   message "Сообщите в службу поддержки о неуспешной попытке блокировки пистолетов"
               view-as alert-box.
   
      end.
      apply "choose" to b-exit in frame {&frame-name}.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-repeate-unblock
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-repeate-unblock Dialog-Frame
ON CHOOSE OF b-repeate-unblock IN FRAME Dialog-Frame /* b-repeate-unblock */
   DO:
      define variable quest-ok as logical   no-undo .
      define variable ii       as integer   no-undo .
      define variable jj       as integer   no-undo .
      define variable list-pl  as character no-undo .

            
      run str/diallog.w ( input parparentproc
         ,input this-procedure
         ,input 'str/get-block-nozzle.p':U
         ,input (v-cntxt-obj-type + {&delim-par} +
         string(v-cntxt-obj-code) + {&delim-par} +
         string(0) + {&delim-par} +  /*p-remote */
         string(0) + {&delim-par} + /*p-shft-close*/
         {&delim-par} +
         {&delim-par} +
         {&delim-par} +
         substitute("&1,&2"
         ,"unblock"
         ,pl-list))
         ,input yes
         ,input ''
         ,input 'Разблокировка пистолетов') .
      if not error-status:error then 
      do:
         if return-value begins "Для кассы" then 
         do:
            message return-value
               view-as alert-box question buttons yes-no update v-ok as logical  .
            if v-ok then apply "choose" to b-repeate-unblock in frame {&frame-name} .
            else message "Сообщите в службу поддержки о неуспешной попытке разблокировки пистолетов"
                  view-as alert-box.
               
         end.
         else 
         do:
            message "Разблокировка пистолетов прошла успешно"
               view-as alert-box.
         end.   

      end.
      else 
      do:
         message return-value
            view-as alert-box question buttons yes-no update v-ok .
         if v-ok then apply "choose" to b-repeate-block in frame {&frame-name} .
         else                   message "Сообщите в службу поддержки о неуспешной попытке разблокировки пистолетов"
               view-as alert-box.
   
      end.
      apply "choose" to b-exit in frame {&frame-name}.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-unblock
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-unblock Dialog-Frame
ON CHOOSE OF b-unblock IN FRAME Dialog-Frame /* Разблок */
   DO:
      define variable quest-ok as logical no-undo .
      
      { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_nozzle-sts_work':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    glog
  }
      IF NOT glog THEN RETURN NO-APPLY.

      if available X_marking then 
      do:
         /*         run local-stts in this-procedure*/
         /*            ( input {&blocked-status}    */
         /*            ).                           */
         message "Разблокировать все пистолеты в" skip
            "АСУ 'Заправщик'?" 
            view-as alert-box question buttons yes-no update quest-ok.
         if quest-ok then 
         do:
            pl-list = "".
            for each X_marking :
               if pl-list = "" then 
               do:
                  pl-list = 
                     string(X_marking.nozzle-code) + ":" +
                     string(X_marking.pump-code)
                     .
               end.
               else 
               do:
                  pl-list = pl-list + ";" +
                     string(X_marking.nozzle-code) + ":" +
                     string(X_marking.pump-code)
                     .         
               end.   
            end.   

            run str/diallog.w ( input parparentproc
               ,input this-procedure
               ,input 'str/get-block-nozzle.p':U
               ,input (v-cntxt-obj-type + {&delim-par} +
               string(v-cntxt-obj-code) + {&delim-par} +
               string(1) + {&delim-par} +  /*p-remote */
               string(0) + {&delim-par} + /*p-shft-close*/
               {&delim-par} +
               {&delim-par} +
               {&delim-par} +
               substitute("&1,&2"
               ,"unblock"
               ,pl-list))
               ,input yes
               ,input ''
               ,input 'Разблокировка пистолетов') .
            if not error-status:error then 
            do:
               if return-value begins "Для кассы" then 
               do:
                  message return-value
                     view-as alert-box question buttons yes-no update v-ok as logical  .
                  if v-ok then apply "choose" to b-repeate-unblock in frame {&frame-name} .
                  else message "Сообщите в службу поддержки о неуспешной попытке разблокировки пистолетов"
                        view-as alert-box.
               
               end.
               else 
               do:
                  message "Разблокировка пистолетов прошла успешно"
                     view-as alert-box.
               end.   

            end.
            else 
            do:
               message return-value
                  view-as alert-box question buttons yes-no update v-ok .
               if v-ok then apply "choose" to b-repeate-block in frame {&frame-name} .
               else                   message "Сообщите в службу поддержки о неуспешной попытке разблокировки пистолетов"
                     view-as alert-box.
   
            end.
            apply "choose" to b-exit in frame {&frame-name}.


         end.   
      end.

   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-not-sel-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-not-sel-all Dialog-Frame
ON CHOOSE OF bt-not-sel-all IN FRAME Dialog-Frame /* + */
   DO:
      define variable loc#log as logical no-undo .

      if available X_marking then 
      do:
         for each X_marking :
            X_marking.marking-string = "*" .
            loc#log = b-plgdspm:refresh() no-error.
         end.
      end.
      apply "entry" to b-plgdspm in frame {&frame-name}.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-not-sel-desel-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-not-sel-desel-all Dialog-Frame
ON CHOOSE OF bt-not-sel-desel-all IN FRAME Dialog-Frame /* - */
   DO:
      define variable loc#log as logical no-undo .
      For each X_marking where X_marking.marking-string = "*":
         X_marking.marking-string = "" .
      end.    
      loc#log = b-plgdspm:refresh() no-error.
        
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-nozzle-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-nozzle-code Dialog-Frame
ON VALUE-CHANGED OF c-nozzle-code IN FRAME Dialog-Frame /* Номер пистолета */
   DO:
      assign c-nozzle-code .
      run sort_ .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-pump-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-pump-code Dialog-Frame
ON VALUE-CHANGED OF c-pump-code IN FRAME Dialog-Frame /* Номер ТРК */
   DO:
      assign c-pump-code .
      run sort_ .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME search-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL search-goods Dialog-Frame
ON leave OF search-goods IN FRAME Dialog-Frame /* Фильтр по товару */
   DO:
      assign search-goods .
      run sort_ .
      
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL search-goods Dialog-Frame
ON return OF search-goods IN FRAME Dialog-Frame /* Фильтр по товару */
   DO:
      assign search-goods .
      run sort_ .

   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b-plgdspm
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
   THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }
{ gbl/f2.i b-plgdspm " " " " parparentproc }
{ gbl/brwrepos.i
&line-num=5
}
{ gbl/brwrefre.i
" if available X_marking then v-doc-rec = recid(X_marking). ~{&OPEN-QUERY-b-plgdspm~} ~
  reposition b-plgdspm to recid v-doc-rec no-error. apply 'ENTRY' to b-plgdspm. "
}

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

   { gbl/getcntxt.i get }
   { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_nozzle-sts_work':U
      {&cntxt-object}
      v-cntxt-host-code-obj
      v-cntxt-obj-type
      v-cntxt-obj-code
      0
      0
      0
      false
      v-ok
    }

   if NOT v-ok then 
   do:
      message "Недостаточно прав доступа для выполнения блокировки\разблокировки пистолетов в ручную." skip
         "нет права - 'actn_nozzle-sts_work' "  
         view-as alert-box.
      return no-apply .
   end.
   
   RUN enable_tt.   
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_tt Dialog-Frame  _DEFAULT-ENABLE
PROCEDURE enable_tt :
   /*------------------------------------------------------------------------------
     Purpose:     ENABLE the User Interface
     Parameters:  <none>
     Notes:       Here we display/view/enable the widgets in the
                  user-interface.  In addition, OPEN all queries
                  associated with each FRAME and BROWSE.
                  These statements here are based on the "Other 
                  Settings" section of the widget Property Sheets.
   ------------------------------------------------------------------------------*/
   FOR EACH X_pl-gds-pump       WHERE X_pl-gds-pump.obj-type = parobj-type  AND X_pl-gds-pump.obj-code = parobj-code NO-LOCK, ~
      EACH X_goods WHERE X_goods.gds-code = X_pl-gds-pump.gds-code NO-LOCK, ~
      EACH X_place WHERE X_place.pl-code = X_pl-gds-pump.pl-code NO-LOCK, ~
      EACH X_pl-pump-nozzle WHERE X_pl-pump-nozzle.obj-type = X_pl-gds-pump.obj-type   AND X_pl-pump-nozzle.obj-code = X_pl-gds-pump.obj-code   AND X_pl-pump-nozzle.pl-code = X_pl-gds-pump.pl-code   AND X_pl-pump-nozzle.pump-code = X_pl-gds-pump.pump-code NO-LOCK     BY X_pl-gds-pump.obj-type      BY X_pl-gds-pump.obj-code       BY X_pl-pump-nozzle.pump-code        BY X_pl-pump-nozzle.nozzle-code:
             
      find first X_marking where X_marking.pl-code = X_pl-gds-pump.pl-code and
         X_marking.pump-code = X_pl-gds-pump.pump-code and
         X_marking.gds-code = X_pl-gds-pump.gds-code and
         X_marking.nozzle-code = X_pl-pump-nozzle.nozzle-code no-error .
      if not available (X_marking) then 
      do:
         create X_marking .
         assign
            X_marking.obj-code    = X_pl-gds-pump.obj-code
            X_marking.obj-type    = X_pl-gds-pump.obj-type
            X_marking.pl-code     = X_pl-gds-pump.pl-code 
            X_marking.pump-code   = X_pl-gds-pump.pump-code
            X_marking.gds-code    = X_pl-gds-pump.gds-code
            X_marking.nozzle-code = X_pl-pump-nozzle.nozzle-code
            X_marking.artic       = X_goods.artic
            X_marking.gds-code    = X_goods.gds-code
            X_marking.gds-name    = X_goods.gds-name
            X_marking.loc1        = X_place.loc1
            X_marking.status_     = X_pl-gds-pump.status_ 
            X_marking.pl-name     = X_place.pl-name 
            X_marking.prod-code   = X_goods.prod-code 
            X_marking.prod-type   = X_goods.prod-type
            X_marking.search-log  = false
            .
      end.
   end.   

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE iniTable Dialog-Frame  _DEFAULT-ENABLE
PROCEDURE iniTable :
   /*------------------------------------------------------------------------------
     Purpose:     ENABLE the User Interface
     Parameters:  <none>
     Notes:       Here we display/view/enable the widgets in the
                  user-interface.  In addition, OPEN all queries
                  associated with each FRAME and BROWSE.
                  These statements here are based on the "Other 
                  Settings" section of the widget Property Sheets.
   ------------------------------------------------------------------------------*/
   for each X_marking:
      for first X_pl-pump-nozzle WHERE X_pl-pump-nozzle.obj-type = X_marking.obj-type   AND 
         X_pl-pump-nozzle.obj-code = X_marking.obj-code   AND 
         X_pl-pump-nozzle.pl-code = X_marking.pl-code   AND 
         X_pl-pump-nozzle.pump-code = X_marking.pump-code ,
         first X_place no-lock where X_place.pl-code = X_marking.pl-code,
         first X_pl-gds-pump exclusive-lock where X_pl-gds-pump.gds-code = X_marking.gds-code and
         X_pl-gds-pump.obj-code = X_pl-pump-nozzle.obj-code and
         X_pl-gds-pump.obj-type = X_pl-pump-nozzle.obj-type and
         X_pl-gds-pump.pl-code = X_pl-pump-nozzle.pl-code and
         X_pl-gds-pump.pump-code = X_pl-pump-nozzle.pump-code:
         X_pl-gds-pump.status_ = X_marking.status_ .
      end.
   end.   
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
   define variable ii            as integer   no-undo .
   define variable v-pump-code   as character no-undo .
   define variable v-nozzle-code as character no-undo .
    
   for each X_marking by X_marking.pump-code by X_marking.nozzle-code:
      if lookup(string(X_marking.pump-code), v-pump-code, ",") = 0 then
         v-pump-code = v-pump-code + "," + string(X_marking.pump-code) . 
      if lookup(string(X_marking.nozzle-code), v-nozzle-code, ",") = 0 then
         v-nozzle-code = v-nozzle-code + "," + string(X_marking.nozzle-code) .
   end.      

   ASSIGN
      c-pump-code:list-items  in frame {&frame-name}   = v-pump-code 
      c-nozzle-code:list-items  in frame {&frame-name} = v-nozzle-code .

   DISPLAY search-goods 
      WITH FRAME Dialog-Frame.
   if parbutton = "block" then 
   do:
      ENABLE b-exit b-block B-hist b-help search-goods b-mark bt-not-sel-all c-nozzle-code c-pump-code 
         bt-not-sel-desel-all b-plgdspm 
         WITH FRAME Dialog-Frame.
      hide b-unblock in frame {&frame-name} .   
   end.
   if parbutton = "un-block" then 
   do:
      ENABLE b-exit b-unblock B-hist b-help search-goods b-plgdspm c-nozzle-code c-pump-code
         WITH FRAME Dialog-Frame.
      hide b-block in frame {&frame-name} .
   end.
   else 
   do:
      ENABLE b-exit B-hist b-help b-plgdspm 
         WITH FRAME Dialog-Frame.
   end.
   VIEW FRAME Dialog-Frame.
   hide b-repeate-block b-repeate-unblock in frame {&frame-name} .
   {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-stts Dialog-Frame 
PROCEDURE local-stts :
   define input  parameter p-stts as character no-undo .

   define variable varrecid    as recid   no-undo.
   define variable v-host-code as integer no-undo .
   define buffer buf_pl-gds-pump for ub.pl-gds-pump.

   do transaction
      on error undo, retry
      :
      if retry then 
      do:
         message
            vss-workfile vss-revision vss-description skip(1)
            substitute( "Ошибка при приcвоении статуса <&1>!", p-stts ) skip
            return-value skip
            error-status :get-message(1)
            view-as alert-box error.
         undo, return error .
      end.

      find first buf_pl-gds-pump exclusive-lock where
         recid(buf_pl-gds-pump) = recid(X_pl-gds-pump).

      if buf_pl-gds-pump.status_ = p-stts then 
      do:
         message
            substitute( "Запись уже имеет статус <&1>.", p-stts )
            view-as alert-box information
            .
         undo, return error .
      end.
      { gbl/hostcode.i
      parobj-type
      parobj-code
      v-host-code
    }
      { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_plgdspm-sts_work':U
      {&cntxt-object}
      v-host-code
      parobj-type
      parobj-code
      0
      0
      0
      true
      varlog
    }
      if not varlog then 
      do:
         undo, return error .
      end.
      assign
         buf_pl-gds-pump.status_ = p-stts
         .
      if p-stts = {&current-status} then 
      do:
         run cplgdspm in this-procedure
            ( input buf_pl-gds-pump.obj-type
            ,input buf_pl-gds-pump.obj-code
            ,input buf_pl-gds-pump.pl-code
            ,input buf_pl-gds-pump.gds-code
            ,input buf_pl-gds-pump.pump-code
            ,input p-stts
            ).
      end.
   end.
   assign
      varrecid = recid(X_pl-gds-pump)
      .
   {&OPEN-QUERY-b-plgdspm}
   reposition {&browse-name} to recid varrecid.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE sort_ Dialog-Frame 
PROCEDURE sort_ :

   define variable ii as integer no-undo .
   empty temp-table X_marking .

   run enable_tt .

   if c-pump-code <> ? and c-pump-code <> 0 then 
   do:
      for each X_marking where X_marking.pump-code <> c-pump-code:
         delete X_marking .
      end.        
   end.  
   if c-nozzle-code <> ? and c-nozzle-code <> 0 then 
   do:
      for each X_marking where X_marking.nozzle-code <> c-nozzle-code:
         delete X_marking .
      end.        
   end.   
   if search-goods <> "" then 
   do:
      for each X_marking:
         do ii = 1 to num-entries (X_marking.gds-name," "):
            if entry(ii,X_marking.gds-name," ") begins search-goods then X_marking.search-log = true .
         end.   
      end. 
      for each X_marking where X_marking.search-log <> true:
         delete X_marking .
      end.        
   end.  
   {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

