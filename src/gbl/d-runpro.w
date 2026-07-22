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

Запуск произвольной процедуры с параметрами

Автор: Перваков Михаил Сергеевич
Дата создания: 03/12/02
Author: Mikhail Pervakov
Creation date: 03/12/02

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .

/* Local Variable Definitions ---                                       */
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Запуск произвольной процедуры с параметрами".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ gbl/objsrv.i}
{utl\search.i}
define temp-table temp-param no-undo
  field run-name          as character
  field run-date          as date
  field run-time          as integer
  field num-param         as integer
  field param1            as character
  field param2            as character
  field param3            as character
  field run-persistent    as logical
  field run-parparentproc as logical

  index pi is unique primary run-name
  index pi1 run-date run-time
.

define stream runpr.
define stream sReadfile.
define variable v-store-file-name as character no-undo initial "d-runpro.txt" .
       
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-help COMBO-BOX-1 ~
fi-procedure T-persistent rs-num-parameters FI-Parameter1 FI-Parameter2 ~
FI-Parameter3 T-compil T-notsign 
&Scoped-Define DISPLAYED-OBJECTS COMBO-BOX-1 fi-procedure T-parparentproc ~
T-persistent rs-num-parameters FI-Parameter1 FI-Parameter2 FI-Parameter3 ~
T-compil T-notsign 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help 
     LABEL "Помо&щь" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE COMBO-BOX-1 AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS COMBO-BOX INNER-LINES 5
     DROP-DOWN-LIST
     SIZE 46.38 BY 1 NO-UNDO.

DEFINE VARIABLE FI-Parameter1 AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 35.63 BY 1 NO-UNDO.

DEFINE VARIABLE FI-Parameter2 AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 35.63 BY 1 NO-UNDO.

DEFINE VARIABLE FI-Parameter3 AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 35.63 BY 1 NO-UNDO.

DEFINE VARIABLE fi-procedure AS CHARACTER FORMAT "X(256)":U 
     LABEL "Процедура" 
     VIEW-AS FILL-IN 
     SIZE 44.25 BY 1 NO-UNDO.

DEFINE VARIABLE rs-num-parameters AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Без доп. параметров", 0,
"1 параметр", 1,
"2 параметра", 2,
"3 параметра", 3
     SIZE 23 BY 5.04 NO-UNDO.

DEFINE VARIABLE T-compil AS LOGICAL INITIAL no 
     LABEL "Не компилировать" 
     VIEW-AS TOGGLE-BOX
     SIZE 22 BY .83 NO-UNDO.

DEFINE VARIABLE T-notsign AS LOGICAL INITIAL no 
     LABEL "Без подписи" 
     VIEW-AS TOGGLE-BOX
     SIZE 17.5 BY .83 NO-UNDO.

DEFINE VARIABLE T-parparentproc AS LOGICAL INITIAL no 
     LABEL "parparentproc" 
     VIEW-AS TOGGLE-BOX
     SIZE 17.63 BY .79 NO-UNDO.

DEFINE VARIABLE T-persistent AS LOGICAL INITIAL no 
     LABEL "persistent" 
     VIEW-AS TOGGLE-BOX
     SIZE 17 BY .79 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     COMBO-BOX-1 AT ROW 2.42 COL 14.75 COLON-ALIGNED NO-LABEL
     fi-procedure AT ROW 2.5 COL 14.75 COLON-ALIGNED
     T-parparentproc AT ROW 4 COL 3
     T-persistent AT ROW 4 COL 27
     rs-num-parameters AT ROW 5.25 COL 3 NO-LABEL
     FI-Parameter1 AT ROW 6.5 COL 25.63 COLON-ALIGNED NO-LABEL
     FI-Parameter2 AT ROW 7.88 COL 25.63 COLON-ALIGNED NO-LABEL
     FI-Parameter3 AT ROW 9.21 COL 25.63 COLON-ALIGNED NO-LABEL
     T-compil AT ROW 10.5 COL 3 WIDGET-ID 2
     T-notsign AT ROW 10.5 COL 26 WIDGET-ID 4
     SPACE(20.24) SKIP(0.83)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Запуск процедуры"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.


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
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       T-compil:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN 
       T-notsign:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR TOGGLE-BOX T-parparentproc IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Запуск процедуры */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  run run-procedure in this-procedure no-error.
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Ошибка при запуске процедуры") skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    return no-apply .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME COMBO-BOX-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL COMBO-BOX-1 Dialog-Frame
ON VALUE-CHANGED OF COMBO-BOX-1 IN FRAME Dialog-Frame
DO:
  ASSIGN COMBO-BOX-1 .

  run display-procedure-parameters in this-procedure .
 END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

{ gbl/app_help.i }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  if SearchFile(v-store-file-name) <> ?
  then do:
    run fill-temp in this-procedure .

    run fill-combo-box-list in this-procedure .
  end.


  RUN enable_UI .

  if parparentproc <> ?
  and valid-handle(parparentproc)
  then do:
    assign
      t-parparentproc :sensitive = true
    .
  end.
  if not objSrv:SystemSetting:DeveloperMode
  then
     assign
        T-compil:hidden  = no
        T-notsign:hidden = no
     .
  for each temp-param
  by temp-param.run-date descending
  by temp-param.run-time descending
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :
    assign
      COMBO-BOX-1  :screen-value in frame {&frame-name} = temp-param.run-name
    .
    run display-procedure-parameters in this-procedure .
    leave .
  end.
  apply 'entry':u to fi-procedure  in frame {&frame-name} .

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-procedure-parameters Dialog-Frame 
PROCEDURE display-procedure-parameters :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do with frame {&frame-name}
  :
    find first temp-param
      where temp-param.run-name = combo-box-1 :screen-value
      no-error .
    if available temp-param
    then do:
      assign
        fi-procedure  :screen-value = temp-param.run-name
        rs-num-parameters           = temp-param.num-param
        fi-parameter1 :screen-value = temp-param.param1
        fi-parameter2 :screen-value = temp-param.param2
        fi-parameter3 :screen-value = temp-param.param3
        t-persistent                = temp-param.run-persistent
      .
      if t-parparentproc :sensitive = true then do:
        assign
          t-parparentproc = temp-param.run-parparentproc
        .
      end.
    end.
    display
      t-parparentproc /*when t-parparentproc :visible = true*/
      t-persistent
      rs-num-parameters
      with frame {&frame-name} .
  end. /* do with frame */

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
  DISPLAY COMBO-BOX-1 fi-procedure T-parparentproc T-persistent 
          rs-num-parameters FI-Parameter1 FI-Parameter2 FI-Parameter3 T-compil 
          T-notsign 
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-help COMBO-BOX-1 fi-procedure T-persistent 
         rs-num-parameters FI-Parameter1 FI-Parameter2 FI-Parameter3 T-compil 
         T-notsign 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-combo-box-list Dialog-Frame 
PROCEDURE fill-combo-box-list :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do with frame {&frame-name}
  :
    define variable v-file-list as character no-undo .

    assign
      v-file-list = '':U
    .

    for each temp-param
    by temp-param.run-date descending
    by temp-param.run-time descending
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    :
      assign
        v-file-list = v-file-list
                    + (if v-file-list = '':U then '':U else ',':U )
                    + temp-param.run-name
      .
    end.

    assign
      combo-box-1 :list-items = v-file-list
    .
  end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-temp Dialog-Frame 
PROCEDURE fill-temp :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define variable v-run-name          as character no-undo .
  define variable v-run-date          as date      no-undo .
  define variable v-run-time          as integer   no-undo .
  define variable v-num-param         as integer   no-undo .
  define variable v-param1            as character no-undo .
  define variable v-param2            as character no-undo .
  define variable v-param3            as character no-undo .
  define variable v-run-persistent    as logical   no-undo .
  define variable v-run-parparentproc as logical   no-undo .

  input stream runpr from value(v-store-file-name) .
  repeat
  :
    assign
      v-run-name          = '':U
      v-run-date          = ?
      v-run-time          = 0
      v-num-param         = 0
      v-param1            = '':U
      v-param2            = '':U
      v-param3            = '':U
      v-run-persistent    = false
      v-run-parparentproc = false
    .

    import stream runpr
      v-run-name
      v-run-date
      v-run-time
      v-num-param
      v-param1
      v-param2
      v-param3
      v-run-persistent
      v-run-parparentproc
      .

    create temp-param .
    assign
      temp-param.run-name          = v-run-name
      temp-param.run-date          = v-run-date
      temp-param.run-time          = v-run-time
      temp-param.num-param         = v-num-param
      temp-param.param1            = v-param1
      temp-param.param2            = v-param2
      temp-param.param3            = v-param3
      temp-param.run-persistent    = v-run-persistent
      temp-param.run-parparentproc = v-run-parparentproc
    .
  end.
  input stream runpr close .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE run-procedure Dialog-Frame 
PROCEDURE run-procedure :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  def var lok             as logical   no-undo .
  def var h-proc-handle   as handle    no-undo .

  def var v-proc-name      as character no-undo .
  def var v-num-parameters as integer   no-undo .
  def var v-parameter1     as character no-undo .
  def var v-parameter2     as character no-undo .
  def var v-parameter3     as character no-undo .

  define variable  str-tmp as character no-undo .
  define variable  num-pt  as integer   no-undo .

  do with frame {&frame-name}:
    assign
      rs-num-parameters
      t-persistent
      t-parparentproc
      t-compil
      t-notsign
      .

    assign
      v-proc-name      = fi-procedure  :screen-value
      v-num-parameters = rs-num-parameters
      v-parameter1     = fi-parameter1 :screen-value
      v-parameter2     = fi-parameter2 :screen-value
      v-parameter3     = fi-parameter3 :screen-value
    .

    if v-proc-name = '':U
    then do:
      message
        "Необходимо ввести имя процедуры"
        view-as alert-box information .
      apply "entry":U to fi-procedure .
      undo, return error .
    end.

    /* ищем процедуру */
    if SearchFile(v-proc-name) = ?
    then do:
      search_block:
      do
      :
        define variable v-index-sub-dir       as integer   no-undo .
        define variable v-sub-dir-list        as character no-undo .
        define variable v-num-entries-sub-dir as integer   no-undo .
        define variable v-sub-dir-item        as character no-undo .
        define variable v-index-suffix        as integer   no-undo .
        define variable v-suffix-list         as character no-undo .
        define variable v-num-entries-suffix  as integer   no-undo .
        define variable v-suffix-item         as character no-undo .
        define variable v-search-proc-name    as character no-undo .
        define variable v-use-prog            as logical   no-undo .

        assign
          v-sub-dir-list        = ',adm/,arc/,bge/,cmp/,cus/,exe/,gbl/,nws/,osn/,rcs/,ref/,rep/,str/,trg/,utl/':U
          v-num-entries-sub-dir = num-entries(v-sub-dir-list)
          v-suffix-list         = ',.p,.w':U
          v-num-entries-suffix  = num-entries(v-suffix-list)
        .

        do v-index-sub-dir = 1 to v-num-entries-sub-dir
        :
          assign
            v-sub-dir-item = entry(v-index-sub-dir, v-sub-dir-list)
          .

          do v-index-suffix = 1 to v-num-entries-suffix
          :
            assign
              v-suffix-item = entry(v-index-suffix, v-suffix-list)
            .

            assign
              v-search-proc-name = SearchFile(v-sub-dir-item + v-proc-name + v-suffix-item)
            .
            if v-search-proc-name <> ?
            then do:
              message
                substitute("Найдена процедура &1", v-search-proc-name) skip
                "Запустить её?" skip
                view-as alert-box question buttons yes-no update v-use-prog .
              if v-use-prog = true
              then do:
                assign
                  v-proc-name = v-sub-dir-item + v-proc-name + v-suffix-item
                .
                leave search_block . /* --->>>--- */
              end.
            end.
          end.
        end.
      end.
    end.
    if SearchFile(v-proc-name) = ?
    then do:
       message
          substitute("Не найдена процедура &1", v-proc-name) 
       view-as alert-box.
       return no-apply.
       
    end.
    /* запоминаем параметры вызываемой процедуры */
    find first temp-param
      where temp-param.run-name = v-proc-name
      no-error .
    if not available temp-param
    then do:
      create temp-param .
      assign
        temp-param.run-name = v-proc-name
      .
    end.
    assign
      temp-param.num-param         = v-num-parameters
      temp-param.param1            = v-parameter1
      temp-param.param2            = v-parameter2
      temp-param.param3            = v-parameter3
      temp-param.run-persistent    = t-persistent
      temp-param.run-date          = today
      temp-param.run-time          = time
    .
    if t-parparentproc :sensitive = true then do:
      assign
        temp-param.run-parparentproc = t-parparentproc
      .
    end.
    run write-temp in this-procedure .

    run fill-combo-box-list in this-procedure .

    do
    on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    on stop   undo, return error substitute( "&1. stop", vss-workfile )
    on endkey undo, return error substitute( "&1. endkey", vss-workfile )
    :
       define variable vKey as integer no-undo.
       define variable vCheksum as character no-undo.
       define variable vlogfile as character no-undo.
       define variable vText as character no-undo.
       define variable vError as logical no-undo init yes.
       define variable vParamlist as character no-undo.
       if     objSrv:SystemSetting:DeveloperMode
          and T-compil:sensitive
          and not T-compil
       then do:
          run utl\compiler.p(input-output v-proc-name).
          if v-proc-name eq ?
          then return error.
       end.
       if T-notsign:sensitive
          and T-notsign
       then
          verror = no.
       else do:
          vKey = random(1,999999999).
          define variable vAsyncHelper as class ibs.th.file.AsyncHelperth no-undo.
          vAsyncHelper = new ibs.th.file.AsyncHelperth().
          vAsyncHelper:MyUser =  "".
          vAsyncHelper:MyPass =  "nocrypt:".
/*          vAsyncHelper:userDB = yes.*/
          vAsyncHelper:MyBachMode = no.
          vAsyncHelper:AsyncProc("utl/proc-chekproc", substitute("&1&8&2&8&3&8&4&8&5&8&6&8&7":U 
                                                    , SearchFile(v-proc-name) ,v-num-parameters, t-parparentproc :checked, vKey,v-parameter1,v-parameter2,v-parameter3,{&delim-par} ),1).
          vAsyncHelper:myTimeOut = 300.
          
          run ibs\th\file\waithelper.p (vAsyncHelper,"proc-chekproc", 1,"Проверка процедуры.").
          vtext = "Процедура имеет не правильную подпись.".
          vlogfile = vAsyncHelper:getlog(?).
          if vAsyncHelper:FileExists(vlogfile)
          then do:
             input stream sReadfile FROM  VALUE(vlogfile).
             repeat:
                import stream sReadfile unformatted vText.
                if vtext begins "error" 
                then assign
                   vtext = substring(vtext,7)
/*                   vError = yes*/
                .
                else do: 
                   vCheksum = vText.
                   
                   if (vCheksum ne {utl/chekproc.i vKey})
                   then assign
                      vtext = "Процедура имеет не правильную подпись."
/*                      vError = yes*/
                   .
                   else
                      vError = no.
                end.    
             end.
             input stream sReadfile close  .
             os-delete value(vlogfile).
          end.
          else assign
              vtext = "Не получен результат проверки."
              vError = yes.
            
          vAsyncHelper:delworkdir().
          delete object vAsyncHelper.
       end.
       if vError
       then do:
          run trg/userlog.p (
                input 'run-proc'
                , input (substitute( "&1. Не прошла проверка подписи. &2", vss-workfile, vtext)  + {&delim-key} + v-proc-name )
                , input ?
                , input ?
                , input "") no-error.
          undo, return error substitute( "&1. Не прошла проверка подписи. &2", vss-workfile, vtext) .
       end.
       else do:
          if can-do("true,yes", t-persistent :screen-value)
          then do:
              case v-num-parameters :
                when 0
                then do:
                   vParamlist = "".
                end.
                when 1
                then do:
                   vParamlist = v-parameter1.
                end.
                when 2
                then do:
                   vParamlist = v-parameter1 + "|" + v-parameter2.
                end.
                when 3
                then do:
                   vParamlist = v-parameter1 + "|" + v-parameter2 + "|" + v-parameter3.
                end.
             end.
             run trg/userlog.p (
                input 'run-proc'
                , input ("Начато выполнение процедуры "  + {&delim-key} + v-proc-name  + {&delim-key} + vParamlist)
                , input ?
                , input ?
                , input "") no-error.
             case v-num-parameters :
                when 0
                then do:
                   vParamlist = "".
                   if parparentproc <> ?
                  and valid-handle(parparentproc)
                  and t-parparentproc :checked
                   then do:
                      run value (v-proc-name) persistent set h-proc-handle
                         (input vkey
                         ,output vCheksum 
                         ,input parparentproc
                       ) no-error .
                   end.
                   else do:
                      run value (v-proc-name) persistent set h-proc-handle 
                          (input vkey
                          ,output vCheksum 
                           )no-error.
                   end.
                end.
                when 1
                then do:
                   vParamlist = v-parameter1.
                   if parparentproc <> ?
                   and valid-handle(parparentproc)
                   and t-parparentproc :checked
                   then do:
                      run value (v-proc-name) persistent set h-proc-handle
                         (input vkey
                         ,output vCheksum 
                         ,input parparentproc
                         ,input v-parameter1
                         )no-error.
                   end.
                   else do:
                      run value (v-proc-name) persistent set h-proc-handle
                         (input vkey
                         ,output vCheksum 
                         ,input v-parameter1
                         ) no-error .
                   end.
                end.
                when 2
                then do:
                   vParamlist = v-parameter1 + "|" + v-parameter2.
                   if parparentproc <> ?
                   and valid-handle(parparentproc)
                   and t-parparentproc :checked
                   then do:
                      run value (v-proc-name) persistent set h-proc-handle
                         (input vkey
                         ,output vCheksum 
                         ,input parparentproc
                         ,input v-parameter1
                         ,input v-parameter2
                         ) no-error.
                   end.
                   else do:
                      run value (v-proc-name) persistent set h-proc-handle
                         (input vkey
                         ,output vCheksum 
                         ,input v-parameter1
                         ,input v-parameter2
                         ) no-error.
                   end.
                end.
                when 3
                then do:
                   vParamlist = v-parameter1 + "|" + v-parameter2 + "|" + v-parameter3.
                   
                   if parparentproc <> ?
                   and valid-handle(parparentproc)
                   and t-parparentproc :checked
                   then do:
                      run value (v-proc-name) persistent set h-proc-handle
                         (input vkey
                         ,output vCheksum 
                         ,input parparentproc
                         ,input v-parameter1
                         ,input v-parameter2
                         ,input v-parameter3
                         ) no-error.
                   end.
                   else do:
                      run value (v-proc-name) persistent set h-proc-handle
                         (input vkey
                         ,output vCheksum 
                         ,input v-parameter1
                         ,input v-parameter2
                         ,input v-parameter3
                         ) no-error.
                   end.
                end.
             end case .
             if not error-status:error
             then
                message
                   "Процедура запущена" skip
                   "Указатель процедуры" h-proc-handle skip
                   view-as alert-box .
          end.
          else do:
             case v-num-parameters :
                when 0
                then do:
                   vParamlist = "".
                   if parparentproc <> ?
                  and valid-handle(parparentproc)
                  and t-parparentproc :checked
                   then do:
                      run value (v-proc-name)
                         (input vkey
                         ,output vCheksum 
                         ,input parparentproc
                         ) no-error .
                   end.
                   else do:
                      run value (v-proc-name)
                         (input vkey
                         ,output vCheksum 
                         ) no-error.
                   end.
                end.
                when 1
                then do:
                   vParamlist = v-parameter1.
                   if parparentproc <> ?
                  and valid-handle(parparentproc)
                  and t-parparentproc :checked
                   then do:
                      run value (v-proc-name)
                         (input vkey
                         ,output vCheksum 
                         ,input parparentproc
                         ,input v-parameter1
                         )no-error.
                   end.
                   else do:
                      run value (v-proc-name)
                         (input vkey
                         ,output vCheksum 
                         ,input v-parameter1
                         )no-error.
                   end.
                end.
                when 2
                then do:
                   vParamlist = v-parameter1 + "|" + v-parameter2 .
                   if parparentproc <> ?
                  and valid-handle(parparentproc)
                  and t-parparentproc :checked
                   then do:
                      run value (v-proc-name)
                         (input vkey
                         ,output vCheksum 
                         ,input parparentproc
                         ,input v-parameter1
                         ,input v-parameter2
                         )no-error.
                   end.
                   else do:
                      run value (v-proc-name)
                         (input vkey
                         ,output vCheksum 
                         ,input v-parameter1
                         ,input v-parameter2
                         )no-error.
                   end.
                end.
                when 3
                then do:
                   vParamlist = v-parameter1 + "|" + v-parameter2 + "|" + v-parameter3.
                   if parparentproc <> ?
                  and valid-handle(parparentproc)
                  and t-parparentproc :checked
                   then do:
                      run value (v-proc-name)
                         (input vkey
                         ,output vCheksum 
                         ,input parparentproc
                         ,input v-parameter1
                         ,input v-parameter2
                         ,input v-parameter3
                         )no-error.
                   end.
                   else do:
                      run value (v-proc-name)
                         (input vkey
                         ,output vCheksum 
                         ,input v-parameter1
                         ,input v-parameter2
                         ,input v-parameter3
                         )no-error.
                   end.
                end.
             end case.
          end.
          if not error-status :error
          then do:
             run trg/userlog.p (
                input 'run-proc'
                , input ("Завершено выполнение процедуры без ошибок "  + {&delim-key} + v-proc-name  + {&delim-key} + vParamlist)
                , input ?
                , input ?
                , input "") no-error.
             return.
          end.
          else if  not objSrv:SystemSetting:DeveloperMode
          then do:
             run trg/userlog.p (
                input 'run-proc'
                , input ("Завершено выполнение процедуры с ошибками "  + {&delim-key} + v-proc-name + {&delim-key} + vParamlist)
                , input ?
                , input ?
                , input "") no-error.
             undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) ).
          end.
          message "Данная процедура не запустится у клиент."
             view-as alert-box warning . 
         /*-----Только для разработки-----------------------*/
          if can-do("true,yes", t-persistent :screen-value)
          then do:
             case v-num-parameters :
                when 0
                then do:
                   if parparentproc <> ?
                  and valid-handle(parparentproc)
                  and t-parparentproc :checked
                   then do:
                      run value (v-proc-name) persistent set h-proc-handle
                         (input parparentproc
                         ) .
                   end.
                   else do:
                      run value (v-proc-name) persistent set h-proc-handle .
                   end.
                end.
                when 1
                then do:
                   if parparentproc <> ?
                  and valid-handle(parparentproc)
                  and t-parparentproc :checked
                   then do:
                      run value (v-proc-name) persistent set h-proc-handle
                         (input parparentproc
                         ,input v-parameter1
                         ) .
                   end. 
                   else do:
                      run value (v-proc-name) persistent set h-proc-handle
                         (input v-parameter1
                         ) .
                   end.
                end.
                when 2
                then do:
                   if parparentproc <> ?
                  and valid-handle(parparentproc)
                  and t-parparentproc :checked
                   then do:
                      run value (v-proc-name) persistent set h-proc-handle
                         (input parparentproc
                         ,input v-parameter1
                         ,input v-parameter2
                         ) .
                   end.
                   else do:
                      run value (v-proc-name) persistent set h-proc-handle
                         (input v-parameter1
                         ,input v-parameter2
                         ) .
                   end.
                end.
                when 3
                then do:
                   if parparentproc <> ?
                  and valid-handle(parparentproc)
                  and t-parparentproc :checked
                   then do:
                      run value (v-proc-name) persistent set h-proc-handle
                         (input parparentproc
                         ,input v-parameter1
                         ,input v-parameter2
                         ,input v-parameter3
                         ) .
                   end.
                   else do:
                      run value (v-proc-name) persistent set h-proc-handle
                         (input v-parameter1
                         ,input v-parameter2
                         ,input v-parameter3
                         ) .
                   end.
                end.
             end case .
             message
                "Процедура запущена" skip
                "Указатель процедуры" h-proc-handle skip
                view-as alert-box .
          end.
          else do:
             case v-num-parameters :
                when 0
                then do:
                   if parparentproc <> ?
                  and valid-handle(parparentproc)
                  and t-parparentproc :checked
                   then do:
                      run value (v-proc-name)
                         (input parparentproc
                         ) .
                   end.
                   else do:
                      run value (v-proc-name)
                         .
                   end.
                end.
                when 1
                then do:
                   if parparentproc <> ?
                  and valid-handle(parparentproc)
                  and t-parparentproc :checked
                   then do:
                      run value (v-proc-name)
                         (input parparentproc
                         ,input v-parameter1
                         ).
                   end.
                   else do:
                      run value (v-proc-name)
                         (input v-parameter1
                         ).
                   end.
                end.
                when 2
                then do:
                   if parparentproc <> ?
                  and valid-handle(parparentproc)
                  and t-parparentproc :checked
                   then do:
                      run value (v-proc-name)
                         (input parparentproc
                         ,input v-parameter1
                         ,input v-parameter2
                         ).
                   end.
                   else do:
                      run value (v-proc-name)
                         (input v-parameter1
                         ,input v-parameter2
                         ).
                   end.
                end.
                when 3
                then do:
                   if parparentproc <> ?
                  and valid-handle(parparentproc)
                  and t-parparentproc :checked
                   then do:
                      run value (v-proc-name)
                         (input parparentproc
                         ,input v-parameter1
                         ,input v-parameter2
                         ,input v-parameter3
                         ).
                   end.
                   else do:
                      run value (v-proc-name)
                         (input v-parameter1
                         ,input v-parameter2
                         ,input v-parameter3
                         ).
                   end.
                end.
             end case.
             run trg/userlog.p (
                input 'run-proc'
                , input ("Выполнена процедура"  + {&delim-key} + v-proc-name + {&delim-key} + vParamlist)
                , input ?
                , input ?
                , input "") no-error.
          end. 
         
       end.
    end.
  end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE write-temp Dialog-Frame 
PROCEDURE write-temp :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable v-ind as integer   no-undo .

  output stream runpr to value(v-store-file-name) .

  for each temp-param
  by temp-param.run-date descending
  by temp-param.run-time descending
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :
    if temp-param.run-name <> '':U
    then do:
      export stream runpr temp-param .
      assign
        v-ind = v-ind + 1
      .
      if v-ind >= 10 then do:
        leave .
      end.
    end.
  end.

  output stream runpr close .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
