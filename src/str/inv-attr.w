&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision: dbafd66ddb70, 2290, rls $
$Author: ShklyarEL $
$Date: Thu Dec 26 15:31:55 2019 +0300 $
$Workfile: inv-attr.w $
$Archive: str/inv-attr.w $

Редактирование атрибутов инвентаризации

Автор: Шкляр Елена
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Шкляр Елена
*/

define variable vss-revision as character no-undo initial "$Revision: dbafd66ddb70, 2290, rls $":U .
define variable vss-author      as character no-undo initial "$Author: ShklyarEL $":U .
define variable vss-date        as character no-undo initial "$Date: Thu Dec 26 15:31:55 2019 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: inv-attr.w $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/inv-attr.w $":U .
define variable vss-description as character no-undo initial "Редактирование атрибутов инвентаризации":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ str/trdcalib.i }

{ str/attrlist.i }
{ str/funcgrzp.i }
{ gbl/getsect.i def }
{ gbl/color.i    }
{ str/lib-trn.i  }

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parParentProc as handle no-undo .
define input parameter parbtn as character no-undo.
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
define input parameter table for tt-upd-attr .

/* Local Variable Definitions ---                                       */
define variable varrec-id          as recid     no-undo.
define variable v-no-news          as logical   no-undo init false .
define variable v-attr-mandat-wayb as character no-undo .

define variable ii                 as integer   no-undo .
define variable bcol               as handle    extent no-undo.
define variable hBrowse            as handle    no-undo.

define buffer buf_trn-doc for ub.trn-doc .

define temp-table tt-inv-attr no-undo
  field attr-code     as character
  field attr-value    as character
  field second-code   as character
  field second-value  as character
  field label-attr    as character
  field user-can-edit as logical
  field sort_         as integer

  index code is primary unique attr-code
  index by-sort                sort_
  .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME b-doc-attr

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-inv-attr

/* Definitions for BROWSE b-doc-attr                                    */
&Scoped-define FIELDS-IN-QUERY-b-doc-attr tt-inv-attr.label-attr tt-inv-attr.attr-value tt-inv-attr.second-value    
&Scoped-define ENABLED-FIELDS-IN-QUERY-b-doc-attr   
&Scoped-define SELF-NAME b-doc-attr
&Scoped-define QUERY-STRING-b-doc-attr FOR EACH tt-inv-attr NO-LOCK   by tt-inv-attr.sort
&Scoped-define OPEN-QUERY-b-doc-attr OPEN QUERY {&SELF-NAME} FOR EACH tt-inv-attr NO-LOCK by tt-inv-attr.sort                                         .
&Scoped-define TABLES-IN-QUERY-b-doc-attr tt-inv-attr
&Scoped-define FIRST-TABLE-IN-QUERY-b-doc-attr tt-inv-attr


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-b-doc-attr}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit tech b-doc-attr 
&Scoped-Define DISPLAYED-OBJECTS tech 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-chg 
  LABEL "&Изменить" 
  SIZE 10 BY 1
  BGCOLOR 8 .

DEFINE BUTTON b-exit AUTO-END-KEY 
  LABEL "&Выход" 
  SIZE 10 BY 1
  BGCOLOR 8 .

DEFINE BUTTON b-lkp 
  LABEL "&Просмотр" 
  SIZE 10 BY 1
  BGCOLOR 8 .

DEFINE VARIABLE tech AS LOGICAL INITIAL no 
  LABEL "Техническая операция" 
  VIEW-AS TOGGLE-BOX
  SIZE 24.5 BY .83 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY b-doc-attr FOR 
  tt-inv-attr SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE b-doc-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b-doc-attr Dialog-Frame _FREEFORM
  QUERY b-doc-attr NO-LOCK DISPLAY
  tt-inv-attr.label-attr COLUMN-LABEL "Код" FORMAT "X(45)"
  tt-inv-attr.attr-value COLUMN-LABEL "Значение" FORMAT "X(30)"
  tt-inv-attr.second-value COLUMN-LABEL "Должность" FORMAT "X(30)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.63 BY 19.29.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
  b-exit AT ROW 1 COL 1
  b-lkp AT ROW 1 COL 21
  b-chg AT ROW 1 COL 31
  tech AT ROW 1.08 COL 44 WIDGET-ID 2
  b-doc-attr AT ROW 2.46 COL 1.75
  SPACE(0.00) SKIP(0.07)
  WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
  SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
  TITLE "Атрибуты инвентаризации"
  DEFAULT-BUTTON b-exit.


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
/* BROWSE-TAB b-doc-attr tech Dialog-Frame */
ASSIGN 
  FRAME Dialog-Frame:SCROLLABLE = FALSE
  FRAME Dialog-Frame:HIDDEN     = TRUE.

/* SETTINGS FOR BUTTON b-chg IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
  b-doc-attr:COLUMN-RESIZABLE IN FRAME Dialog-Frame = TRUE.

/* SETTINGS FOR BUTTON b-lkp IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b-doc-attr
/* Query rebuild information for BROWSE b-doc-attr
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ub.doc-attr NO-LOCK
      WHERE ub.doc-attr.doc-code = pardoc-code,
      first tt-upd-attr where tt-upd-attr.code = ub.doc-attr.attr-code and
                                       tt-upd-attr.output-display = yes  by tt-upd-attr.sort
                                        .
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "doc-attr.doc-code = pardoc-code"
     _Query            is OPENED
*/  /* BROWSE b-doc-attr */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Атрибуты документа */
  DO:
    apply "chose":U to b-exit .
    APPLY "END-ERROR":U TO SELF.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выход */
  DO:
    /* Проверка на заполнение атрибутов */
    define variable is-check as logical   no-undo .
    define variable is-mes   as character no-undo .
    define variable varlog   as logical   no-undo .
    define buffer fio_inv-attr    for tt-inv-attr .
    define buffer pos_inv-attr    for tt-inv-attr .
    define buffer prikaz_inv-attr for tt-inv-attr .
    
    if lookup ("b-chg", parbtn) = 0 then return .
    if not tech then 
    do:
      if not can-find (first prikaz_inv-attr no-lock where 
        prikaz_inv-attr.attr-code = {&trdcattr-prikaz-date} and
        prikaz_inv-attr.attr-value <> "") then 
      do:
        is-check = true .
      end.
      if not can-find (first fio_inv-attr no-lock where 
        (fio_inv-attr.attr-code = {&trdcattr-fio-agent} or
        fio_inv-attr.attr-code = {&trdcattr-fio-player1} or
        fio_inv-attr.attr-code = {&trdcattr-fio-player2} or
        fio_inv-attr.attr-code = {&trdcattr-fio-player3}) and
        fio_inv-attr.attr-value <> "") then 
      do:
        is-check = true .
      end.
      if not can-find (first fio_inv-attr no-lock where 
        (fio_inv-attr.second-code = {&trdcattr-pos-agent} or
        fio_inv-attr.second-code = {&trdcattr-pos-player1} or
        fio_inv-attr.second-code = {&trdcattr-pos-player2} or
        fio_inv-attr.second-code = {&trdcattr-pos-player3}) and
        fio_inv-attr.second-value <> "")then 
      do:
        is-check = true .
      end.
      if is-check then is-mes = "Не заполнены обязательные атрибуты накладной инвентаризации." + {&new-line}.
      /* Проверка на заполнение по парам ФИО и должность */
      
        find first fio_inv-attr no-lock where 
        fio_inv-attr.attr-code = {&trdcattr-fio-agent} and 
        fio_inv-attr.attr-value <> "" no-error .
        if not available (fio_inv-attr) then do:
        find first pos_inv-attr no-lock where 
        pos_inv-attr.second-code = {&trdcattr-pos-agent} and 
        pos_inv-attr.second-value <> "" no-error . 
        if available (pos_inv-attr) then is-mes = is-mes + "Не заполнена ФИО председателя комиссии." + {&new-line}.          
        end. 
        else do:
        find first pos_inv-attr no-lock where 
        pos_inv-attr.second-code = {&trdcattr-pos-agent} and 
        pos_inv-attr.second-value <> "" no-error . 
        if not available (pos_inv-attr) then is-mes = is-mes + "Не заполнена должность председателя комиссии." + {&new-line}.                
        end. 
        
        find first fio_inv-attr no-lock where 
        fio_inv-attr.attr-code = {&trdcattr-fio-player1} and 
        fio_inv-attr.attr-value <> "" no-error .
        if not available (fio_inv-attr) then do:
        find first pos_inv-attr no-lock where 
        pos_inv-attr.second-code = {&trdcattr-pos-player1} and 
        pos_inv-attr.second-value <> "" no-error . 
        if available (pos_inv-attr) then is-mes = is-mes + "Не заполнена ФИО первого участника комиссии." + {&new-line}.          
        end. 
        else do:
        find first pos_inv-attr no-lock where 
        pos_inv-attr.second-code = {&trdcattr-pos-player1} and 
        pos_inv-attr.second-value <> "" no-error . 
        if not available (pos_inv-attr) then is-mes = is-mes + "Не заполнена должность первого участника комиссии." + {&new-line}.                
        end.           

        find first fio_inv-attr no-lock where 
        fio_inv-attr.attr-code = {&trdcattr-fio-player2} and 
        fio_inv-attr.attr-value <> "" no-error .
        if not available (fio_inv-attr) then do:
        find first pos_inv-attr no-lock where 
        pos_inv-attr.second-code = {&trdcattr-pos-player2} and 
        pos_inv-attr.second-value <> "" no-error . 
        if available (pos_inv-attr) then is-mes = is-mes + "Не заполнена ФИО второго участника комиссии." + {&new-line}.          
        end. 
        else do:
        find first pos_inv-attr no-lock where 
        pos_inv-attr.second-code = {&trdcattr-pos-player2} and 
        pos_inv-attr.second-value <> "" no-error . 
        if not available (pos_inv-attr) then is-mes = is-mes + "Не заполнена должность второго участника комиссии." + {&new-line}.                
        end.   

        find first fio_inv-attr no-lock where 
        fio_inv-attr.attr-code = {&trdcattr-fio-player3} and 
        fio_inv-attr.attr-value <> "" no-error .
        if not available (fio_inv-attr) then do:
        find first pos_inv-attr no-lock where 
        pos_inv-attr.second-code = {&trdcattr-pos-player3} and 
        pos_inv-attr.second-value <> "" no-error . 
        if available (pos_inv-attr) then is-mes = is-mes + "Не заполнена ФИО третьего участника комиссии." + {&new-line}.          
        end. 
        else do:
        find first pos_inv-attr no-lock where 
        pos_inv-attr.second-code = {&trdcattr-pos-player3} and 
        pos_inv-attr.second-value <> "" no-error . 
        if not available (pos_inv-attr) then is-mes = is-mes + "Не заполнена должность третьего участника комиссии." + {&new-line}.                
        end.   
        
        if is-mes <> "" then is-mes = is-mes + "Вы уверены, что хотите выйти, не заполнив обязательные атрибуты?" .
                  
      if is-mes <> "" then 
      do:
        message
          is-mes
          view-as alert-box question buttons yes-no update varlog.
          if not varlog then return no-apply.
      end.
      
    end.                 

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
  DO:
    define variable vartemp-char  as character no-undo.
    define variable p-anyfromproc as character no-undo .
    define variable p-start-h     as integer   no-undo.
    define variable p-start-m     as integer   no-undo.
    define variable p-end-h       as integer   no-undo.
    define variable p-end-m       as integer   no-undo.

    if available tt-inv-attr then 
    do:
      find first tt-upd-attr no-lock where tt-upd-attr.code = tt-inv-attr.attr-code no-error .
      if available (tt-upd-attr) then 
      do:
        if tt-inv-attr.second-code = "" then 
        do:

          run gbl/d-prompt.w (
            'title=':u + 'Изменение атрибутов инвентаризации' + '\':u
            + 'text1=':u + tt-upd-attr.label-attr + '\':u
            + 'format=' + tt-upd-attr.format-attr + '\':u
            + 'type=' + tt-upd-attr.type-attr + '\':u
            + 'fillin_row=2\':u
            + 'fillin_col=4\':u
            + 'fillin_width=':u  + string(tt-upd-attr.fillin_width) + '\':u
            + 'fillin_height=':u + string(tt-upd-attr.fillin_height) + '\':u
            + 'max-chars=70\':u
            + 'readonly=' + 'no':u + '\':u
            , input-output tt-inv-attr.attr-value
            ) no-error.
          if error-status:error then 
          do:
            message "Ошибка при изменении атрибута." skip
              return-value skip
              error-status:get-message(1) view-as alert-box error.
            return no-apply.
          end.
          if return-value = 'false':u then 
          do:
            return no-apply.
          end.
/*  Проверка года */
/*  message "*" tt-upd-attr.code {&trdcattr-prikaz-date} {&trdcattr-inv-date} view-as alert-box.*/
          if tt-inv-attr.attr-code = {&trdcattr-prikaz-date} or tt-inv-attr.attr-code = {&trdcattr-inv-date}      
          then do:
              define variable ddate as date no-undo.
              if tt-inv-attr.attr-value <> "" then do:
                  ddate = date(tt-inv-attr.attr-value) no-error.
                  if error-status:error then do:
                      message "Некорректный формат даты." view-as alert-box error.
                      return no-apply.
                  end.
                  if year(ddate) < 2000 or year(ddate) > 2100 then do:
                      message "Год должен быть от 2000 до 2100. " view-as alert-box error.
                      return no-apply.
                  end.
              end.
          end.

          { str/tdatinv-wrt.i
         pardoc-code
         tt-inv-attr.attr-code
         tt-inv-attr.attr-value
         no-error
     }
          if error-status :error then 
          do:
            message "Ошибка при сохранении атрибута." view-as alert-box.
            undo, return no-apply.
          end.
        end.
        else 
        do:
          run ref/d-invAttr.w (
            'title=':u + 'Изменение атрибутов инвентаризации' + '\':u
            + 'text1=':u + tt-upd-attr.label-attr + '\':u
            + 'text2=':u + "Должность" + '\':u
            + 'format=' + tt-upd-attr.format-attr + '\':u
            + 'type=' + tt-upd-attr.type-attr + '\':u
            + 'fillin_row=2\':u
            + 'fillin_col=4\':u
            + 'fillin_width=':u  + string(tt-upd-attr.fillin_width) + '\':u
            + 'fillin_height=':u + string(tt-upd-attr.fillin_height) + '\':u
            + 'max-chars=70\':u
            + 'readonly=' + 'no':u + '\':u
            , input tech
            , input-output tt-inv-attr.attr-value
            , input-output tt-inv-attr.second-value
            ) no-error.
          if error-status:error then 
          do:
            message "Ошибка при изменении атрибута." skip
              return-value skip
              error-status:get-message(1) view-as alert-box error.
            return no-apply.
          end.
          { str/tdatinv-wrt.i
         pardoc-code
         tt-inv-attr.second-code
         tt-inv-attr.second-value
         no-error
     }
          if error-status :error then 
          do:
            message "Ошибка при сохранении атрибута." view-as alert-box.
            undo, return no-apply.
          end.

/* --- Проверка года для основного атрибута (только если это дата) --- */




/* --- Конец проверки --- */

                  { str/tdatinv-wrt.i
         pardoc-code
         tt-inv-attr.attr-code
         tt-inv-attr.attr-value
         no-error
     }
          if error-status :error then 
          do:
            message "Ошибка при сохранении атрибута." view-as alert-box.
            undo, return no-apply.
          end.
        end.
        assign
          varrec-id = recid(tt-inv-attr).
/*       tt-inv-attr.attr-value = vartemp-char .*/
        {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
        reposition {&browse-name} to recid varrec-id.
      end.

    end.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b-doc-attr
&Scoped-define SELF-NAME b-doc-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-doc-attr Dialog-Frame
ON return OF b-doc-attr IN FRAME Dialog-Frame
  DO:
    if  b-chg:sensitive THEN apply "CHOOSE":U to b-chg.
    else apply "choose":U to b-lkp.
    return no-apply.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-doc-attr Dialog-Frame
ON ROW-DISPLAY OF b-doc-attr IN FRAME Dialog-Frame
  DO:
    run rowdisp .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
  DO:

    define variable vartemp-char as character no-undo.
    if available tt-inv-attr then 
    do:
      find first tt-upd-attr no-lock where tt-upd-attr.code = tt-inv-attr.attr-code no-error .
      if available (tt-upd-attr) then 
      do:
        assign
          vartemp-char = tt-inv-attr.attr-value
          .
        if tt-inv-attr.second-code = "" then 
        do:  
          run gbl/d-prompt.w (
            'title=':u + 'Изменение атрибутов документа' + '\':u
            + 'text1=':u + tt-upd-attr.label-attr + '\':u
            + 'format=' + tt-upd-attr.format-attr + '\':u
            + 'type=' + tt-upd-attr.type-attr + '\':u
            + 'fillin_row=2\':u
            + 'fillin_col=4\':u
            + 'fillin_width=':u  + string(tt-upd-attr.fillin_width) + '\':u
            + 'fillin_height=':u + string(tt-upd-attr.fillin_height) + '\':u
            + 'max-chars=70\':u
            + 'readonly=' + 'yes':u + '\':u
            , input-output vartemp-char
            ) no-error.
        end.
        else 
        do:
          run ref/d-invAttr.w (
            'title=':u + 'Изменение атрибутов инвентаризации' + '\':u
            + 'text1=':u + tt-upd-attr.label-attr + '\':u
            + 'text2=':u + "Должность" + '\':u
            + 'format=' + tt-upd-attr.format-attr + '\':u
            + 'type=' + tt-upd-attr.type-attr + '\':u
            + 'fillin_row=2\':u
            + 'fillin_col=4\':u
            + 'fillin_width=':u  + string(tt-upd-attr.fillin_width) + '\':u
            + 'fillin_height=':u + string(tt-upd-attr.fillin_height) + '\':u
            + 'max-chars=70\':u
            + 'readonly=' + 'yes':u + '\':u
            , input-output tt-inv-attr.attr-value
            , input-output tt-inv-attr.second-value
            ) no-error.     
        end.
      end.
    end.
  end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tech
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tech Dialog-Frame
ON VALUE-CHANGED OF tech IN FRAME Dialog-Frame /* Техническая операция */
  DO:
    assign tech .
    find first ub.inv-doc-attr exclusive-lock where ub.inv-doc-attr.doc-code = pardoc-code and
      ub.inv-doc-attr.attr-code = "invTech" no-error .
    if not available (ub.inv-doc-attr) then 
    do:
      create ub.inv-doc-attr .
      assign
        ub.inv-doc-attr.doc-code  = pardoc-code
        ub.inv-doc-attr.attr-code = "invTech"
        .
    end.
    ub.inv-doc-attr.attr-value = string(tech) .
  
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
  THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-chg }

{ gbl/brwrefre.i }
{ gbl/brwrepos.i &line-num=4 }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  /*              parbtn = "b-lkp,b-chg" .*/
  if lookup ("b-lkp", parbtn) > 0 then 
  do:
    enable b-lkp with frame {&frame-name}.
  end.
  if lookup ("b-chg", parbtn) > 0 then 
  do:
    enable b-chg tech with frame {&frame-name}.
  end.

  run init-proc in this-procedure .
  hbrowse = browse b-doc-attr:handle.
  extent (bcol) = hbrowse:num-columns.
  bcol[1] = hbrowse:first-column.
  do ii = 1 to extent (bcol).  
    bcol[ii] = hbrowse:get-browse-column (ii).
  end.
  RUN enable_UI.
  apply 'entry':u to browse {&browse-name} .
  wait-for go of frame {&frame-name}.
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
  DISPLAY tech 
    WITH FRAME Dialog-Frame.
  ENABLE b-exit b-doc-attr 
    WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame 
PROCEDURE init-proc :
  /* -----------------------------------------------------------
    Purpose:
    Parameters:  <none>
    Notes:
  -------------------------------------------------------------*/
  define variable v-func-name as character no-undo .
  define variable v-proc-name as character no-undo .
  define variable tt          as character no-undo .
  define variable i           as integer   no-undo .
  define variable list-attr   as character no-undo .

  list-attr = {&trdcattr-fio-player3} + "/" + {&trdcattr-fio-player2} + "/" + {&trdcattr-fio-player1} + "/" + {&trdcattr-fio-agent} .
  for each tt-upd-attr where tt-upd-attr.output-display = yes  :
    create tt-inv-attr .
    assign
      tt-inv-attr.label-attr = tt-upd-attr.label-attr
      tt-inv-attr.attr-code  = tt-upd-attr.code 
      tt-inv-attr.sort_      = tt-upd-attr.sort_
      .
    if lookup(tt-inv-attr.attr-code,list-attr,"/") > 0 then 
    do:
      case tt-inv-attr.attr-code:
        when {&trdcattr-fio-agent} then 
          do:
            tt-inv-attr.second-code = {&trdcattr-pos-agent} .
          end.
        when {&trdcattr-fio-player1} then 
          do:
            tt-inv-attr.second-code = {&trdcattr-pos-player1} .
          end.
        when {&trdcattr-fio-player2} then 
          do:
            tt-inv-attr.second-code = {&trdcattr-pos-player2} .
          end.
        when {&trdcattr-fio-player3} then 
          do:
            tt-inv-attr.second-code = {&trdcattr-pos-player3} .
          end.
      end case .
    end.
  end.
  
  for each tt-inv-attr:
    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = tt-inv-attr.attr-code and
      ub.inv-doc-attr.doc-code = pardoc-code:
      tt-inv-attr.attr-value = ub.inv-doc-attr.attr-value .
    end.
    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = tt-inv-attr.second-code and
      ub.inv-doc-attr.doc-code = pardoc-code:
      tt-inv-attr.second-value = ub.inv-doc-attr.attr-value .
    end.    
    
  end.
  
  find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = pardoc-code and
    ub.inv-doc-attr.attr-code = "invTech" no-error .
  if available (ub.inv-doc-attr) then tech = logical (ub.inv-doc-attr.attr-value) .
 
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE rowdisp Dialog-Frame 
PROCEDURE rowdisp :
  
/*do ii = 1 to extent (bcol).                                                                      */
/*    if valid-handle (bcol[ii])                                                                   */
/*    then do:                                                                                     */
/*      assign                                                                                     */
/*        bcol[ii]:fgcolor = RED_COLOR when lookup (ub.doc-attr.attr-code, v-attr-mandat-wayb) > 0.*/
/*    end.                                                                                         */
/*  end.                                                                                           */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE st-attr Dialog-Frame 
PROCEDURE st-attr :
  /* -----------------------------------------------------------
    Purpose:
    Parameters:  <none>
    Notes:
  -------------------------------------------------------------*/
  define variable varattr-code like ub.doc-attr.attr-code no-undo.
  define buffer bf_doc-attr for ub.doc-attr.
  define variable vartemp-char as character no-undo.

  define buffer buf_doc-attr    for ub.doc-attr .
  define buffer buf_tt-upd-attr for tt-upd-attr .

  do
    transaction on error undo, return error return-value
    :
    /* устанавливаем признаки на атрибутах, которые можно выбрать */
    for each buf_tt-upd-attr
      on error undo, return error return-value
      :
      find first buf_doc-attr no-lock
        where buf_doc-attr.doc-code  = pardoc-code
        and buf_doc-attr.attr-code = buf_tt-upd-attr.code
        no-error .
      if available buf_doc-attr
        then 
      do:
        assign
          buf_tt-upd-attr.can-select = false
          .
      end.
      else 
      do:
        assign
          buf_tt-upd-attr.can-select = true
          .
      end.
    end.

    run str/b-attr.w
      (input table tt-upd-attr
      ,output varattr-code
      ) no-error .
    if error-status :error
      then 
    do:
      if return-value <> ""
        then 
      do:
        message
          "Ошибка при выборе добавляемого атрибута."
          view-as alert-box error.
      end.
      undo, return error.
    end.
    find first tt-upd-attr where tt-upd-attr.code = varattr-code no-error.
    if not available tt-upd-attr then 
    do:
      message "Не верно выбран атрибут для добавления." view-as alert-box error.
      undo, return error.
    end.
    if tt-upd-attr.user-can-edit <> yes then 
    do:
      message "Атрибут нельзя добавить в данном интерфейсе." view-as alert-box.
      undo, return error.
    end.
    find first bf_doc-attr where bf_doc-attr.doc-code   = pardoc-code and
      bf_doc-attr.attr-code = varattr-code no-lock no-error.
    if available bf_doc-attr then  
    do:
      message "Атрибут " tt-upd-attr.label-attr " уже есть в документе " pardoc-code " ."
        view-as alert-box error.
      undo, return error.
    end.
    create ub.inv-doc-attr.
    assign
      ub.inv-doc-attr.doc-code  = pardoc-code
      ub.inv-doc-attr.attr-code = varattr-code.
    run gbl/d-prompt.w (
      'title=':u + 'Изменение атрибутов документа' + '\':u
      + 'text1=':u + tt-upd-attr.label-attr + '\':u
      + 'format=' + tt-upd-attr.format-attr + '\':u
      + 'type=' + tt-upd-attr.type-attr + '\':u
      + 'fillin_row=2\':u
      + 'fillin_col=4\':u
      + 'fillin_width=':u  + string(tt-upd-attr.fillin_width) + '\':u
      + 'fillin_height=':u + string(tt-upd-attr.fillin_height) + '\':u
      + 'max-chars=70\':u
      + 'readonly=' + 'no':u + '\':u
      , input-output vartemp-char
      ) no-error.
    if error-status:error then 
    do:
      message "Ошибка при изменении атрибута." skip
        return-value skip
        error-status:get-message(1) view-as alert-box error.
      undo, return error.
    end.
    if return-value = 'false':u then 
    do:
      undo, return error.
    end.
    { str/tdatinv-wrt.i
        ub.inv-doc-attr.doc-code
        ub.inv-doc-attr.attr-code
        vartemp-char
        no-error
    }
    if error-status :error then 
    do:
      message "Ошибка при сохранении атрибута." view-as alert-box.
      undo, return error.
    end.

    assign
      varrec-id = recid(ub.doc-attr)
      .

    if not v-no-news  then 
    do:
    { str/tdatinv-oth.i
              ub.inv-doc-attr.doc-code
              ub.inv-doc-attr.attr-code
              vartemp-char
              no-error
          }
      if error-status :error then 
      do:
        message "Ошибка при обработке атрибута." view-as alert-box.
        undo, return no-apply.
      end.
    end.

  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



