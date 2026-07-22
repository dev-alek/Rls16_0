&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

$Revision: 9995f7bf39ec, 3001, rls $
$Author: SSlivenko $
$Date: Ср апр 06 16:23:44 2022 +0300 $
$Workfile: pl-lvls.w $
$Archive: ref/pl-lvls.w $

Градуировочная таблица для резервуара

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/28/09
Author: Dmitry Ukhanov
Creation date: 01/28/09

Автор1: Белоусов Илья Александрович
Дата создания1: 12/24/07

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
define variable vss-revision    as character no-undo init "$Revision: 9995f7bf39ec, 3001, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Ср апр 06 16:23:44 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: pl-lvls.w $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/pl-lvls.w $":U .
define variable vss-description as character no-undo init "Градуировочная таблица для резервуара".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
/* Parameters Definitions ---                                           */
define input parameter parparentproc   as widget-handle  no-undo .
define input parameter p-obj-type      as character      no-undo .
define input parameter p-obj-code      as integer        no-undo .
define input parameter p-pl-code       as integer        no-undo .
/* Local Variable Definitions ---                                       */
define variable v_ok as LOGICAL no-undo .
define variable v-new as LOGICAL no-undo init no .
define buffer buf_pl-level for ub.pl-level .
define buffer buf_pl-level-mm for ub.pl-level-mm .
define buffer buf_pl-level-attr for ub.pl-level-attr .
define buffer buf2_pl-level-attr for ub.pl-level-attr .
define buffer buf_place    for ub.place .
define buffer buf_place-attr    for ub.place-attr .
define VARIABLE v-ok-level as logical no-undo INIT no .
define variable v-chk-act-host-code as integer   no-undo .
define variable v-place-type as integer no-undo .
define variable glog                as logical   no-undo .
define stream   vTxt.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-2

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_pl-level

/* Definitions for BROWSE BROWSE-2                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2 buf_pl-level.pl-level buf_pl-level.pl-qnty buf_pl-level-attr.attr-value 
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2 
&Scoped-define QUERY-STRING-BROWSE-2 FOR EACH buf_pl-level ~
      WHERE buf_pl-level.obj-type = p-obj-type ~
 AND buf_pl-level.obj-code = p-obj-code ~
 AND buf_pl-level.pl-code = p-pl-code NO-LOCK, ~
 first buf_pl-level-attr where buf_pl-level-attr.obj-type = p-obj-type ~
 and buf_pl-level-attr.obj-code = p-obj-code ~
 and buf_pl-level-attr.pl-code = p-pl-code ~
 and buf_pl-level-attr.pl-level = buf_pl-level.pl-level ~
 and buf_pl-level-attr.attr-code = "tarir-delta" no-lock INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-2 OPEN QUERY BROWSE-2 FOR EACH buf_pl-level ~
      WHERE buf_pl-level.obj-type = p-obj-type ~
 AND buf_pl-level.obj-code = p-obj-code ~
 AND buf_pl-level.pl-code = p-pl-code NO-LOCK, ~
 FIRST buf_pl-level-mm OUTER-JOIN where buf_pl-level-mm.obj-type = p-obj-type ~
 and buf_pl-level-mm.obj-code = p-obj-code ~
 and buf_pl-level-mm.pl-code = p-pl-code ~
 and buf_pl-level-mm.min-level <= buf_pl-level.pl-level ~
 and buf_pl-level-mm.max-level >= buf_pl-level.pl-level NO-LOCK, ~
 first buf_pl-level-attr where buf_pl-level-attr.obj-type = p-obj-type ~
 and buf_pl-level-attr.obj-code = p-obj-code ~
 and buf_pl-level-attr.pl-code = p-pl-code ~
 and buf_pl-level-attr.pl-level = buf_pl-level.pl-level ~
 and buf_pl-level-attr.attr-code = "tarir-delta" no-lock, ~
 first buf2_pl-level-attr OUTER-JOIN where buf2_pl-level-attr.obj-type = p-obj-type ~
 and buf2_pl-level-attr.obj-code = p-obj-code ~
 and buf2_pl-level-attr.pl-code = p-pl-code ~
 and buf2_pl-level-attr.pl-level = buf_pl-level.pl-level ~
 and buf2_pl-level-attr.attr-code = "deltaV" no-lock INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-2 buf_pl-level buf_pl-level-attr
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2 buf_pl-level buf_pl-level-attr


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-2}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-add b-chg b-del b-load b-delete ~
b-help BROWSE-2 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add 
     LABEL "&Добавить" 
     SIZE 10 BY 1.

DEFINE BUTTON b-chg 
     LABEL "&Изменить" 
     SIZE 10 BY 1.

DEFINE BUTTON b-del 
     LABEL "&Удалить" 
     SIZE 10 BY 1.

DEFINE BUTTON b-delete 
     LABEL "Очистить" 
     SIZE 9 BY 1.

DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help 
     LABEL "Помо&щь" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-load 
     LABEL "&Загрузить" 
     SIZE 10 BY 1.

DEFINE BUTTON b-zone 
     LABEL "&Таблица поясов" 
     SIZE 15 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-2 FOR 
      buf_pl-level, buf_pl-level-mm, buf_pl-level-attr, buf2_pl-level-attr SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2 Dialog-Frame _STRUCTURED
  QUERY BROWSE-2 NO-LOCK DISPLAY
      buf_pl-level.pl-level COLUMN-LABEL "Уровень, см"
      buf_pl-level.pl-qnty WIDTH 15.5
      IF AVAIL buf_pl-level-mm THEN string(buf_pl-level-mm.zone,">>>>>>>9") ELSE "" COLUMN-LABEL "        Пояс" WIDTH 12
      decimal(buf_pl-level-attr.attr-value) WIDTH 14 format "9.999" COLUMN-LABEL "Погрешность!составления,%"
      if avail buf2_pl-level-attr then string(decimal(buf2_pl-level-attr.attr-value), ">>>>>>>>>>>9.9999") else "" format "X(17)" WIDTH 18 COLUMN-LABEL "Коэффициент!вместимости,м3/мм"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 85 BY 17.5 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-add AT ROW 1 COL 11 WIDGET-ID 2
     b-chg AT ROW 1 COL 21 WIDGET-ID 4
     b-del AT ROW 1 COL 31 WIDGET-ID 6
     b-load AT ROW 1 COL 41 WIDGET-ID 8
     b-delete AT ROW 1 COL 51 WIDGET-ID 10
     b-zone AT ROW 1 COL 60 WIDGET-ID 12
     b-help AT ROW 1 COL 70
     BROWSE-2 AT ROW 2.25 COL 1 WIDGET-ID 200
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Градуировочная таблица"
         DEFAULT-BUTTON b-exit WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-2 b-help Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-2
/* Query rebuild information for BROWSE BROWSE-2
     _TblList          = "buf_pl-level"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "buf_pl-level.obj-type = p-obj-type
 AND buf_pl-level.obj-code = p-obj-code
 AND buf_pl-level.pl-code = p-pl-code"
     _FldNameList[1]   > "_<CALC>"
"buf_pl-level.pl-level" ? ? ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > "_<CALC>"
"pl-qnty" ? ? "decimal" ? ? ? ? ? ? no ? no no "54.63" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE BROWSE-2 */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Градуировочная таблица */
DO:
  define variable v-gap as character no-undo.
  define variable v-ok  as logical   no-undo.
  
  if v-new
  then do :
    find first buf_pl-level no-lock where buf_pl-level.obj-type = p-obj-type
                                      and buf_pl-level.obj-code = p-obj-code
                                      and buf_pl-level.pl-code  = p-pl-code
                                      no-error .
    if available buf_pl-level
    then do :
      message "Внимание! После подтверждения завершения работы по вводу данных дальнейшая корректировка градуировочной таблицы резервуара будет возможна только в ИС УРТ. Подтвердите завершение работы!"
      view-as alert-box question buttons yes-no update v-ok .
      if not v-ok
      then do :
        return no-apply .
      end .
    end .
  end .

  run check-pl-level in this-procedure ( OUTPUT v-gap ).
  IF v-gap <> ""
      THEN 
  DO:
      message
          "В тарировочной таблице имеются пропуски. Пропущены следующие уровни:"
          skip v-gap
          SKIP 
          "Выйти и оставить пропуски?"
          view-as alert-box information
          BUTTONS YES-NO
          update v-ok
          .
      IF NOT v-ok THEN 
      DO:
          RETURN NO-APPLY.
      END.
  END.

  if AVAILABLE (buf_pl-level) and v-ok-level then 
  do:
/*запуск машины правил для выгрузки резервуара*/
  { gbl/rum-runa.i
  ?
  this-procedure:handle
  ?
  {&thref-proc_ref-event}
  " buffer buf_pl-level:handle "
  " buffer buf_pl-level:handle "
  ''
  ''
  no-error
  }
      if error-status :error
          then
      do:
          message
              error-status:get-message(1) skip
              return-value
              view-as alert-box error .

          return no-apply .
      end.
  end.
  if v-ok-level then 
  do:
      run trg/userlog.p (
          input {&nwsdochs_action_create}
          , input {&table_pl-level}
          , input ( buffer buf_pl-level :handle )
          , input ?
          , input ""
          ) no-error.
      if error-status :error
          then 
      do:
          undo, return substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
              , {&new-line}
              , vss-workfile
              , return-value
              , error-status :get-message ( 1 ) ).
      end.
  end.
  APPLY "END-ERROR":U TO SELF.
END.

on "ESC" ANYWHERE do:
  define variable v-gap as character no-undo.
  define variable v-ok  as logical   no-undo.
  
  if v-new
  then do :
    find first buf_pl-level no-lock where buf_pl-level.obj-type = p-obj-type
                                      and buf_pl-level.obj-code = p-obj-code
                                      and buf_pl-level.pl-code  = p-pl-code
                                      no-error .
    if available buf_pl-level
    then do :
      message "Внимание! После подтверждения завершения работы по вводу данных дальнейшая корректировка градуировочной таблицы резервуара будет возможна только в ИС УРТ. Подтвердите завершение работы!"
      view-as alert-box question buttons yes-no update v-ok .
      if not v-ok
      then do :
        return no-apply .
      end .
    end .
  end .

  run check-pl-level in this-procedure ( OUTPUT v-gap ).
  IF v-gap <> ""
      THEN 
  DO:
      message
          "В тарировочной таблице имеются пропуски. Пропущены следующие уровни:"
          skip v-gap
          SKIP 
          "Выйти и оставить пропуски?"
          view-as alert-box information
          BUTTONS YES-NO
          update v-ok
          .
      IF NOT v-ok THEN 
      DO:
          RETURN NO-APPLY.
      END.
  END.

  if AVAILABLE (buf_pl-level) and v-ok-level then 
  do:
/*запуск машины правил для выгрузки резервуара*/
  { gbl/rum-runa.i
  ?
  this-procedure:handle
  ?
  {&thref-proc_ref-event}
  " buffer buf_pl-level:handle "
  " buffer buf_pl-level:handle "
  ''
  ''
  no-error
  }
      if error-status :error
          then
      do:
          message
              error-status:get-message(1) skip
              return-value
              view-as alert-box error .

          return no-apply .
      end.
  end.
  if v-ok-level then 
  do:
      run trg/userlog.p (
          input {&nwsdochs_action_create}
          , input {&table_pl-level}
          , input ( buffer buf_pl-level :handle )
          , input ?
          , input ""
          ) no-error.
      if error-status :error
          then 
      do:
          undo, return substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
              , {&new-line}
              , vss-workfile
              , return-value
              , error-status :get-message ( 1 ) ).
      end.
  end.
end.

on "F2" ANYWHERE do:
  define variable v-gap as character no-undo.
  define variable v-ok  as logical   no-undo.
  
  if v-new
  then do :
    find first buf_pl-level no-lock where buf_pl-level.obj-type = p-obj-type
                                      and buf_pl-level.obj-code = p-obj-code
                                      and buf_pl-level.pl-code  = p-pl-code
                                      no-error .
    if available buf_pl-level
    then do :
      message "Внимание! После подтверждения завершения работы по вводу данных дальнейшая корректировка градуировочной таблицы резервуара будет возможна только в ИС УРТ. Подтвердите завершение работы!"
      view-as alert-box question buttons yes-no update v-ok .
      if not v-ok
      then do :
        return no-apply .
      end .
    end .
  end .

  run check-pl-level in this-procedure ( OUTPUT v-gap ).
  IF v-gap <> ""
      THEN 
  DO:
      message
          "В тарировочной таблице имеются пропуски. Пропущены следующие уровни:"
          skip v-gap
          SKIP 
          "Выйти и оставить пропуски?"
          view-as alert-box information
          BUTTONS YES-NO
          update v-ok
          .
      IF NOT v-ok THEN 
      DO:
          RETURN NO-APPLY.
      END.
  END.

  if AVAILABLE (buf_pl-level) and v-ok-level then 
  do:
/*запуск машины правил для выгрузки резервуара*/
  { gbl/rum-runa.i
  ?
  this-procedure:handle
  ?
  {&thref-proc_ref-event}
  " buffer buf_pl-level:handle "
  " buffer buf_pl-level:handle "
  ''
  ''
  no-error
  }
      if error-status :error
          then
      do:
          message
              error-status:get-message(1) skip
              return-value
              view-as alert-box error .

          return no-apply .
      end.
  end.
  if v-ok-level then 
  do:
      run trg/userlog.p (
          input {&nwsdochs_action_create}
          , input {&table_pl-level}
          , input ( buffer buf_pl-level :handle )
          , input ?
          , input ""
          ) no-error.
      if error-status :error
          then 
      do:
          undo, return substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
              , {&new-line}
              , vss-workfile
              , return-value
              , error-status :get-message ( 1 ) ).
      end.
  end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
   define variable v-level    as integer      no-undo.
   define variable v-ok       as logical      no-undo.
        { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_place-reference_work':U
        {&cntxt-object}
        v-chk-act-host-code
        p-obj-type
        p-obj-code
        0
        0
        0
        true
        glog
        }
        if NOT glog then return no-apply.
   assign
      v-level = ?
   .
   run ref/pl-lvl.w   ( input parparentproc
                        , input p-obj-type
                        , input p-obj-code
                        , input p-pl-code
                        , input-output v-level
                        , output v-ok
                        ) no-error.
      IF ERROR-STATUS:ERROR then do:
         message
            error-status:get-message(1) skip
            return-value
         view-as alert-box error .

         return no-apply .
      end.
   IF v-ok then do:
      run enable_UI in this-procedure.
      v-ok-level = yes .
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
   define variable v-level    as integer      no-undo.
   define variable v-ok       as logical      no-undo.

        { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_place-reference_work':U
        {&cntxt-object}
        v-chk-act-host-code
        p-obj-type
        p-obj-code
        0
        0
        0
        true
        glog
        }
        if NOT glog then return no-apply.
   if available buf_pl-level then do:
   assign
      v-level = buf_pl-level.pl-level
   .
   run ref/pl-lvl.w   ( input parparentproc
                        , input buf_pl-level.obj-type
                        , input buf_pl-level.obj-code
                        , input buf_pl-level.pl-code
                        , input-output v-level
                        , output v-ok
                        ) no-error.
      IF ERROR-STATUS:ERROR then do:
         message
            error-status:get-message(1) skip
            return-value
         view-as alert-box error .

         return no-apply .
      end.
   end.
   IF v-ok THEN DO:
      run enable_UI in this-procedure.
      v-ok-level = yes .
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
        { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_place-reference_work':U
        {&cntxt-object}
        v-chk-act-host-code
        p-obj-type
        p-obj-code
        0
        0
        0
        true
        glog
        }
        if NOT glog then return no-apply.
      
        if available buf_pl-level then 
        do:
            run del-pl-level in this-procedure no-error.
            IF ERROR-STATUS:ERROR then 
            do:
                message
                    error-status:get-message(1) skip
                    return-value
                    view-as alert-box error .

                return no-apply .
            end.
            else 
            do:
                run enable_UI in this-procedure.
                v-ok-level = yes .
            end.
        end.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-delete
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-delete Dialog-Frame
ON CHOOSE OF b-delete IN FRAME Dialog-Frame /* Очистить */
    DO:
        { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_place-reference_work':U
        {&cntxt-object}
        v-chk-act-host-code
        p-obj-type
        p-obj-code
        0
        0
        0
        true
        glog
        }
        if NOT glog then return no-apply.
   
        define variable v-delete as logical no-undo.
        if available buf_pl-level then 
        do:
            message
                SUBSTITUTE ( "Очистить таблицу? " ) 
                  
                view-as alert-box information
                BUTTONS YES-NO
                update v-delete
                .
            IF v-delete
                THEN 
            DO:
                run waitfram-show in this-procedure ( input "Ждите...").
   
                FOR EACH buf_pl-level 
                    WHERE buf_pl-level.obj-type = p-obj-type 
                    AND buf_pl-level.obj-code = p-obj-code 
                    AND buf_pl-level.pl-code = p-pl-code .
 
                    delete buf_pl-level.

                end.
                FOR EACH buf_pl-level-attr 
                    WHERE buf_pl-level-attr.obj-type = p-obj-type 
                      AND buf_pl-level-attr.obj-code = p-obj-code 
                      AND buf_pl-level-attr.pl-code = p-pl-code :
                  delete buf_pl-level-attr.
                end.
                run waitfram-hide in this-procedure.
                if error-status:error then 
                do:
                    message 
                        error-status:get-message(1) skip
                        return-value
                        view-as alert-box error.
                    return no-apply.
                end.
                else 
                do:
                    run enable_UI in this-procedure.
                    v-ok-level = yes .
                end.
            END.
        end.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выход */
    DO:
        define variable v-gap as character no-undo.
        define variable v-ok  as logical   no-undo.
        
        if v-new
        then do :
          find first buf_pl-level no-lock where buf_pl-level.obj-type = p-obj-type
                                            and buf_pl-level.obj-code = p-obj-code
                                            and buf_pl-level.pl-code  = p-pl-code
                                            no-error .
          if available buf_pl-level
          then do :
            message "Внимание! После подтверждения завершения работы по вводу данных дальнейшая корректировка градуировочной таблицы резервуара будет возможна только в ИС УРТ. Подтвердите завершение работы!"
            view-as alert-box question buttons yes-no update v-ok .
            if not v-ok
            then do :
              return no-apply .
            end .
          end .
        end .

        run check-pl-level in this-procedure ( OUTPUT v-gap ).
        IF v-gap <> ""
            THEN 
        DO:
            message
                "В тарировочной таблице имеются пропуски. Пропущены следующие уровни:"
                skip v-gap
                SKIP 
                "Выйти и оставить пропуски?"
                view-as alert-box information
                BUTTONS YES-NO
                update v-ok
                .
            IF NOT v-ok THEN 
            DO:
                RETURN NO-APPLY.
            END.
        END.

        if AVAILABLE (buf_pl-level) and v-ok-level then 
        do:
      /*запуск машины правил для выгрузки резервуара*/
        { gbl/rum-runa.i
        ?
        this-procedure:handle
        ?
        {&thref-proc_ref-event}
        " buffer buf_pl-level:handle "
        " buffer buf_pl-level:handle "
        ''
        ''
        no-error
        }
            if error-status :error
                then
            do:
                message
                    error-status:get-message(1) skip
                    return-value
                    view-as alert-box error .

                return no-apply .
            end.
        end.
        if v-ok-level then 
        do:
            run trg/userlog.p (
                input {&nwsdochs_action_create}
                , input {&table_pl-level}
                , input ( buffer buf_pl-level :handle )
                , input ?
                , input ""
                ) no-error.
            if error-status :error
                then 
            do:
                undo, return substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                    , {&new-line}
                    , vss-workfile
                    , return-value
                    , error-status :get-message ( 1 ) ).
            end.
        end.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-load
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-load Dialog-Frame
ON CHOOSE OF b-load IN FRAME Dialog-Frame /* Загрузить */
    DO:
        define variable v-file-name as character no-undo.
        define variable v-dir-name  as character no-undo.
        define variable v-ok        as logical   no-undo.
        { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_place-reference_work':U
        {&cntxt-object}
        v-chk-act-host-code
        p-obj-type
        p-obj-code
        0
        0
        0
        true
        glog
        }
        if NOT glog then return no-apply.

        if avail buf_pl-level then do:
          message "Импорт невозможен." skip
                  "Сначала необходимо очистить градуировочную таблицу для резервуара."
                  view-as alert-box error 
                  buttons OK
                  title "ПРЕДУПРЕЖДЕНИЕ".
          return no-apply.  
        end.
        
        run gbl/d-file.p  ( input-output v-file-name
            , input-output v-dir-name
            , input  "Файл импорта (*.txt,*.xlsx)"
            , input  "*.txt;*.xlsx"
            , input  "":U
            , input  "":U
            , input  TRUE
            , input  FALSE
            , input  TRUE
            , input  "Файл для загрузки тарировочной таблицы"
            , output v-ok
            ) .
        IF v-ok
            AND v-file-name <> "":U
            AND v-file-name <> ?
            THEN 
        DO:
            if entry(2,v-file-name,".") = "xlsx" then do:
              run importExcel in this-procedure (v-file-name) no-error.
            end.
            else
              run utl/tarir2.p  ( INPUT v-file-name
                  , INPUT p-obj-type
                  , INPUT p-obj-code
                  , INPUT p-pl-code
                  ) NO-ERROR.
            IF ERROR-STATUS:ERROR THEN 
            DO:
                message
                    error-status:get-message(1) skip
                    return-value
                    view-as alert-box error .

                return no-apply .
            end.
            run enable_UI in this-procedure.
            v-ok-level = yes .
        END.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-zone
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-zone Dialog-Frame
ON CHOOSE OF b-zone IN FRAME Dialog-Frame /* Таблица поясов */
DO:
    run ref/pl-level-mm-brw.w (
        parparentproc,
        p-obj-type,
        p-obj-code,
        p-pl-code,
        {&update}
        
    ).
    
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-2
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
    THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-chg }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
{ gbl/getcntxt.i get }
    find first buf_place
        where buf_place.obj-type = p-obj-type
        and buf_place.obj-code = p-obj-code
        and buf_place.pl-code  = p-pl-code
        no-lock
        no-error
        .
    IF NOT AVAILABLE buf_place THEN 
    DO:
        return error SUBSTITUTE ( "Не найдено складское место &1 &2 &3"
            , p-pl-code
            , p-obj-code
            , p-obj-type
            ) .
    end.
    
    v-place-type = 2 .
    for first buf_place-attr no-lock where buf_place-attr.obj-type = buf_place.obj-type
                                       and buf_place-attr.obj-code = buf_place.obj-code
                                       and buf_place-attr.pl-code = buf_place.pl-code
                                       and buf_place-attr.attr-code = "place-type"
                                       :
      v-place-type = integer(buf_place-attr.attr-value) .                        
    end .
    

    ASSIGN
        FRAME Dialog-Frame:TITLE = SUBSTITUTE  ( "Градуировочная таблица для резервуара &1 (&2) &3 &4"
                                             , p-pl-code
                                             , buf_place.loc1
                                             , p-obj-code
                                             , p-obj-type
                                             )
    .
   
    for each buf_pl-level no-lock where buf_pl-level.obj-type = p-obj-type
                                    and buf_pl-level.obj-code = p-obj-code
                                    and buf_pl-level.pl-code  = p-pl-code
                                    :
      find first buf_pl-level-attr no-lock where buf_pl-level-attr.obj-type  = buf_pl-level.obj-type
                                             and buf_pl-level-attr.obj-code  = buf_pl-level.obj-code
                                             and buf_pl-level-attr.pl-code   = buf_pl-level.pl-code
                                             and buf_pl-level-attr.pl-level  = buf_pl-level.pl-level
                                             and buf_pl-level-attr.attr-code = "tarir-delta"
                                             no-error .
      if not available buf_pl-level-attr
      then do :
        create buf_pl-level-attr .
        assign
          buf_pl-level-attr.obj-type  = buf_pl-level.obj-type
          buf_pl-level-attr.obj-code  = buf_pl-level.obj-code
          buf_pl-level-attr.pl-code   = buf_pl-level.pl-code 
          buf_pl-level-attr.pl-level  = buf_pl-level.pl-level
          buf_pl-level-attr.attr-code = "tarir-delta"        
          buf_pl-level-attr.attr-value = (if v-place-type = 2 then string(0.25) else string(0.20))
        .
      end .                                                                      
    end .

    RUN enable_UI.
    
    find first buf_pl-level no-lock where buf_pl-level.obj-type = p-obj-type
                                      and buf_pl-level.obj-code = p-obj-code
                                      and buf_pl-level.pl-code  = p-pl-code
                                      no-error .
    if available buf_pl-level
    then do :
      disable
        b-add b-chg b-del b-load b-delete
      with frame {&frame-name} .
    end .
    else do :
      assign v-new = yes .
    end .
    
    WAIT-FOR GO OF FRAME {&FRAME-NAME}.

END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-pl-level Dialog-Frame 
PROCEDURE check-pl-level :
    /*------------------------------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    ------------------------------------------------------------------------------*/
    define output parameter p-error as character        no-undo.

    define buffer bf_pl-level for ub.pl-level .

    define variable v-pl-level-begin as integer no-undo.
    define variable v-pl-level-end   as integer no-undo.
    define variable v-count          as integer no-undo.

    FIND FIRST bf_pl-level
        where bf_pl-level.obj-type = p-obj-type
        and bf_pl-level.obj-code = p-obj-code
        and bf_pl-level.pl-code  = p-pl-code
        no-lock
        no-error.
    IF NOT AVAILABLE bf_pl-level THEN 
    DO:
        RETURN.
    END.
    assign
        v-pl-level-begin = bf_pl-level.pl-level
        .
    FIND LAST  bf_pl-level
        where bf_pl-level.obj-type = p-obj-type
        and bf_pl-level.obj-code = p-obj-code
        and bf_pl-level.pl-code  = p-pl-code
        no-lock
        .
    assign
        v-pl-level-end = bf_pl-level.pl-level
        .
    do v-count = v-pl-level-begin to v-pl-level-end :
        IF NOT CAN-FIND(FIRST bf_pl-level
            where bf_pl-level.obj-type = p-obj-type
            and bf_pl-level.obj-code = p-obj-code
            and bf_pl-level.pl-code  = p-pl-code
            and bf_pl-level.pl-level = v-count
            no-lock)
            THEN 
        DO:
            ASSIGN
                p-error = IF p-error = "" THEN STRING(v-count)
                                     ELSE SUBSTITUTE  ( "&1,&2"
                                                      , p-error
                                                      , v-count
                                                      )
                .
        END.

    END.





END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE del-pl-level Dialog-Frame 
PROCEDURE del-pl-level :
    /*------------------------------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    ------------------------------------------------------------------------------*/
    define buffer bf_pl-level for ub.pl-level .
    define buffer bf_pl-level-attr for ub.pl-level-attr .

    define variable v-ok  as logical no-undo.
    define variable v-del as logical no-undo.

    message
        SUBSTITUTE ( "Удалить уровень &1 "
        , buf_pl-level.pl-level
        )
        view-as alert-box information
        BUTTONS YES-NO
        update v-del
        .
    IF v-del
        THEN 
    DO
        on error undo, return error
        :
        IF CAN-FIND(FIRST bf_pl-level
            where bf_pl-level.obj-type = p-obj-type
            and bf_pl-level.obj-code = p-obj-code
            and bf_pl-level.pl-code  = p-pl-code
            and bf_pl-level.pl-level < buf_pl-level.pl-level
            no-lock)
            AND CAN-FIND(FIRST bf_pl-level
            where bf_pl-level.obj-type = p-obj-type
            and bf_pl-level.obj-code = p-obj-code
            and bf_pl-level.pl-code  = p-pl-code
            and bf_pl-level.pl-level > buf_pl-level.pl-level
            no-lock)
            THEN 
        DO:
            message
                SUBSTITUTE ( "Уровень &1 находится в середине градуировочной таблицы"
                , buf_pl-level.pl-level
                )
                skip 
                "При его удалении возникнут пропуски в таблице."
                skip 
                "Все равно удалить Удалить?"
                view-as alert-box information
                BUTTONS YES-NO
                update v-ok
                .
            IF v-ok THEN 
            DO:
                FIND FIRST bf_pl-level
                    where RowID(bf_pl-level) = RowID(buf_pl-level)
                    exclusive-lock
                .
                for each bf_pl-level-attr exclusive-lock where bf_pl-level-attr.obj-type = bf_pl-level.obj-type
                                                           and bf_pl-level-attr.obj-code = bf_pl-level.obj-code
                                                           and bf_pl-level-attr.pl-code  = bf_pl-level.pl-code 
                                                           and bf_pl-level-attr.pl-level = bf_pl-level.pl-level
                :
                  delete bf_pl-level-attr .
                end .
                DELETE bf_pl-level .
            END.
        END.
        ELSE 
        DO:
            FIND FIRST bf_pl-level
                where RowID(bf_pl-level) = RowID(buf_pl-level)
                exclusive-lock
            .
            for each bf_pl-level-attr exclusive-lock where bf_pl-level-attr.obj-type = bf_pl-level.obj-type
                                                       and bf_pl-level-attr.obj-code = bf_pl-level.obj-code
                                                       and bf_pl-level-attr.pl-code  = bf_pl-level.pl-code 
                                                       and bf_pl-level-attr.pl-level = bf_pl-level.pl-level
            :
              delete bf_pl-level-attr .
            end .
            DELETE bf_pl-level .
        END.
    END. /* v-del do on error */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE importExcel f-pl-level-mm 
PROCEDURE importExcel :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
define input parameter fileImport as character no-undo.

define variable mExcelApplication as component-handle no-undo. /* ССЫЛКА НА ПРИЛОЖЕНИЕ */
define variable mWorkBook         as component-handle no-undo. /* ССЫЛКА НА РАБОЧУЮ КНИГУ */
define variable mWorkSheet        as component-handle no-undo. /* ССЫЛКА НА РАБОЧИЙ ЛИСТ */

define variable cntLine           as integer   no-undo.
define variable vLine             as character no-undo.
define variable vErr              as character no-undo.

define variable vTarirDeltaMain   as decimal                no-undo.
define variable vLevel            like ub.pl-level.pl-level no-undo.
define variable vQnty             like ub.pl-level.pl-qnty  no-undo.
define variable vTarirDelta       as decimal                no-undo.
define variable vDeltaV           as decimal                no-undo.
define variable vFileTxt          as character.

define buffer b_pl-level for ub.pl-level.
define buffer b_pl-level-attr for ub.pl-level-attr.

create "Excel.Application":U mExcelApplication no-error.
if error-status :error then 
do:
 return error "Ошибка при запуске Excel".
end.    

ASSIGN
 mExcelApplication:DisplayAlerts = NO
 mWorkbook                       = mExcelApplication:WorkBooks:Add(fileImport)
 mWorkSheet                      = mWorkbook:Sheets:Item(1)
.

if trim(mWorkSheet:Range("A1"):VALUE) <> "Имя/Тип" or
   trim(mWorkSheet:Range("A2"):VALUE) <> "Погрешность определения вместимости, ±%" or
   trim(mWorkSheet:Range("A4"):VALUE) = "" then
do:
  return error "В выбранном файле нет градуировочных таблиц.~nТаблицы не загружены.".
end.

vTarirDeltaMain = mWorkSheet:Range("B2"):VALUE no-error.
/*  if error-status:error then              */
/*  do:                                     */
/*    vErr = "Ошибка при чтении ячейки B2.".*/
/*    return error vErr.                    */
/*  end.                                    */

vFileTxt = substitute("&1&2.&3",
                      session:temp-directory,
                      entry(1,entry(num-entries(fileImport,"\"),fileImport,"\"),"."),
                      "txt").
output stream vTxt to value(vFileTxt).
cntLine = 4.
IMP:
do transaction on error undo IMP, leave IMP:
repeat:
  vLine  = string(cntLine).
  if mWorkSheet:Range("A" + vLine):VALUE = "" or
     mWorkSheet:Range("A" + vLine):VALUE = ? then
    leave IMP.

  assign
    vLevel = mWorkSheet:Range("A" + vLine):VALUE
    vQnty  = mWorkSheet:Range("B" + vLine):VALUE
  no-error.

  if error-status:error then
  do:
    vErr = "Ошибка при чтении строки: " + error-status:get-message(1).
    undo IMP, leave IMP.
  end.
  
  assign
    vTarirDelta = mWorkSheet:Range("C" + vLine):VALUE
    vDeltaV     = mWorkSheet:Range("D" + vLine):VALUE
  no-error.

  put stream vTxt unformatted
    string(buf_place.loc1) {&tabulation}
    string(vLevel) {&tabulation}
    string(round(vQnty * 1000,0)) {&tabulation}
    string(round((if vTarirDelta > 0 then vTarirDelta else vTarirDeltaMain),3)) {&tabulation}
    string(round(vDeltaV,4)) skip
  .
  
  cntLine = cntLine + 1.
end.
end.
output stream vTxt close. 

mExcelApplication:Quit().
release object mExcelApplication.

if vErr = "" then
do:
    run utl/tarir2.p  ( input vFileTxt
        , input p-obj-type
        , input p-obj-code
        , input p-pl-code
    ) no-error.
    if error-status:error then
      vErr = substitute("&1~n&2", error-status:get-message(1), return-value).
end.

os-delete value(vFileTxt).
if vErr <> "" then
  return error vErr.

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
    ENABLE b-exit b-add b-chg b-del b-load b-delete b-zone b-help BROWSE-2 
        WITH FRAME Dialog-Frame.
    VIEW FRAME Dialog-Frame.
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

