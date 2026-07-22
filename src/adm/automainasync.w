&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME automain
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS automain
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Главное окно запуска автоматических процедур по расписанию

Автор: Уханов Дмитрий Юрьевич
Дата создания: 09/10/02
Author: Dmitry Ukhanov
Creation date: 09/10/02

*/

/* Create an unnamed pool to store all the widgets created
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

create widget-pool.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input parameter i-auto-type as character no-undo .

define input parameter i-mode      as character no-undo .
define input parameter inumSession as integer no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Главное окно запуска автоматических процедур по расписанию".
define variable mAsyncHelper as class ibs.th.file.AsyncHelperth  no-undo.
{ cmp/vssrevis.i }
{ cmp/trg-def.i new }
{ cmp/showinf.i  }
{ adm/auto-def.i }
define variable mAllTypeSuport as character no-undo.
mAllTypeSuport = {&btpr-type-autonws} + "," + {&btpr-type-is_diadoc} + "," + {&btpr-type-mercury} + "," + {&btpr-type-is_motp} 
               + "," + {&btpr-type-autoarh} + "," + {&btpr-type-hddtest} + "," + {&btpr-type-autoexp}. 
{ cmp/library.i  }
{utl/asuncprocauto.i &starterasunc = yes}
&global-define tab-shift 2
{ str/auto2dia.i   (this-procedure:handle) }
define variable v-list-key            as character no-undo .
define variable v-for-extsys          as character no-undo .  
{ adm/automain.i }
mAsyncProcRun = yes.
define variable v-time          as integer   no-undo .
define variable v-today         as date      no-undo .

define variable log-exit      as logical   no-undo .
define variable mtitle as character no-undo.
define variable mDbInfo as character no-undo.
   

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-amain

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-help auto-log
&Scoped-Define DISPLAYED-OBJECTS auto-log curr-date curr-time

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
define var automain as widget-handle no-undo.

/* Definitions of the field level widgets                               */
define button b-exit auto-go default
     label "Вы&ход "
     size 10 by 1 tooltip "Выход из автоматической системы"
     bgcolor 8 .

define button b-hand default
     label "&РРежим"
     size 10 by 1 tooltip "Ручной режим приема и отправки новостей"
     bgcolor 8 .

define button b-start default
     label "&Запуск"
     size 10 by 1 tooltip "Запустить один цикл"
     bgcolor 8 .


define button b-help default
     label "Помо&щь"
     size 10 by 1 tooltip "Помощь"
     bgcolor 8 .

define button b-prop default
     label "&Настройки"
     size 10 by 1 tooltip "Настройка СПН"
     bgcolor 8 .

define variable auto-log as character
     view-as editor no-word-wrap scrollbar-horizontal scrollbar-vertical large
     size 96.88 by 19.75 no-undo.

define variable curr-date as date format "99/99/9999":U
      view-as text
     size 11 by .67 no-undo.

define variable curr-time as character format "X(8)":U
      view-as text
     size 8 by .67 no-undo.

define variable f-msg as character format "X(256)":U
      view-as text
     size 63 by .67
     fgcolor 12  no-undo.


/* ************************  Frame Definitions  *********************** */

define frame f-amain
     b-exit at row 1.17 col 2.25
     b-hand at row 1.17 col 12.25
     b-prop at row 1.17 col 22.25
     b-start at row 1.17 col 32.25
     b-help at row 1.17 col 89
     auto-log at row 3.38 col 2.25 no-label
     f-msg at row 2.5 col 13 colon-aligned no-label
     curr-date at row 2.5 col 79 no-label
     curr-time at row 2.5 col 90.5 no-label
     "Сообщения:" view-as text
          size 10.5 by .67 at row 2.5 col 3
    with 1 down no-box keep-tab-order overlay
         side-labels no-underline three-d
         at col 1 row 1
         size 99.38 by 22.42.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
if session:display-type = "GUI":U then
  create window automain assign
         hidden             = yes
         title              = ""
         height             = 22.75
         width              = 99.38
         max-height         = 22.75
         max-width          = 99.38
         virtual-height     = 22.75
         virtual-width      = 99.38
         resize             = no
         scroll-bars        = no
         status-area        = no
         bgcolor            = ?
         fgcolor            = ?
         keep-frame-z-order = yes
         three-d            = yes
         message-area       = no
         sensitive          = yes.
else {&WINDOW-NAME} = current-window.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW automain
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f-amain
   FRAME-NAME                                                           */
assign
       auto-log:READ-ONLY in frame f-amain        = true.

/* SETTINGS FOR BUTTON b-hand IN FRAME f-amain
   NO-ENABLE                                                            */
assign
       b-hand:HIDDEN in frame f-amain           = true.

/* SETTINGS FOR BUTTON b-hand IN FRAME f-amain
   NO-ENABLE                                                            */
assign
      b-start:HIDDEN in frame f-amain           = true.

/* SETTINGS FOR BUTTON b-prop IN FRAME f-amain
   NO-ENABLE                                                            */
assign
       b-prop:HIDDEN in frame f-amain           = true.

/* SETTINGS FOR FILL-IN curr-date IN FRAME f-amain
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN curr-time IN FRAME f-amain
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-msg IN FRAME f-amain
   NO-DISPLAY NO-ENABLE                                                 */
assign
       f-msg:READ-ONLY in frame f-amain        = true.

if session:display-type = "GUI":U and VALID-HANDLE(automain)
then automain:hidden = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME f-amain
/* Query rebuild information for FRAME f-amain
     _Query            is NOT OPENED
*/  /* FRAME f-amain */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME automain
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL automain automain
on end-error of automain
or endkey of {&WINDOW-NAME} anywhere do:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL automain automain
on window-close of automain
do:
  /* This event will close the window and terminate the procedure.  */
  return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit automain
on choose of b-exit in frame f-amain /* Выход  */
do:

  define variable v-answer as logical   no-undo .

  run gbl/q-wait.w
    ( input substitute( "Вы хотите завершить работу авторежима?" )
     ,input false                                         /* p-default-answ */
     ,input 20                                            /* p-timeout      */
     ,output v-answer                                     /* p-answer (сек) */
    ) no-error .

  if error-status :error
    or v-answer = true
  then do:
    if error-status :error then do:
      run write-to-log ( substitute( "&1. Ошибка при завершении работы. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message(1) )
                      ).
    end.
    assign
      log-exit = yes
    .
  end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hand automain
on choose of b-start in frame f-amain /* РРежим */
do:
/*   mstart = yes.*/
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hand
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hand automain
on choose of b-hand in frame f-amain /* РРежим */
do:
   message "Будет реализован чуть позже"
   view-as alert-box.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-prop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-prop automain
on choose of b-prop in frame f-amain /* Настройки */
do:
   message "что за шляпа"
   view-as alert-box.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK automain


/* ***************************  Main Block  *************************** */

/*{ gbl/app_help.i &disable-button=no }*/
{ gbl/app_help.i }

/* Set CURRENT-WINDOW: this will parent dialog-boxes and frames.        */
assign CURRENT-WINDOW                = {&WINDOW-NAME}
       THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}.

/* The CLOSE event can be used from inside or outside the procedure to  */
/* terminate it.                                                        */
on close of this-procedure
do:
  apply "choose" to b-exit in frame {&frame-name}. /* Выход  */
  return no-apply.
end.

/* Best default for GUI applications is...                              */
pause 0 before-hide.
run gbl\inidebug.p.
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
do on error   undo MAIN-BLOCK, leave MAIN-BLOCK
   on end-key undo MAIN-BLOCK, retry MAIN-BLOCK
   on stop    undo MAIN-BLOCK, retry MAIN-BLOCK:

   define variable start-time            as int64     no-undo .
   run initProcMode (i-auto-type,i-mode).
   run adm/autoconn.p no-error.
   if error-status :error then do:
      run write-to-log ( substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message(1) ) ).
   end.
  
   run CheckUpdate no-error.
   if error-status :error then do:
     return error return-value.
   end.

   run adm/chk-db.p no-error .
   if error-status :error then do:
      run write-to-log (  substitute( "&1. Проверка возможности работы сессии.&2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message(1) ) ).
      run gbl/dbdiscon.p no-error.
      if error-status :error then do:
         run write-to-log (  substitute( "&1. Не удалось отсоединиться от БД&2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message(1) ) ).
      end.
      log-exit = true.
   end.
   else do:
      define variable Vdbinfo as character no-undo.
      run adm/db-info.p ( output g#db-num, output Vdbinfo ) no-error.
      run gbl/dbdiscon.p no-error.
      if error-status :error then do:
         run write-to-log (  substitute( "&1. Не удалось отсоединиться от БД&2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message(1) ) ).
      end.
      g#auto = false.
    
      assign
         auto-log-msg-h = auto-log:handle
         auto-window-h = this-procedure:handle
         hand-log-msg-h = ?
         {&window-name}:title = substitute( "PID: &1 &2 Выполнение паралельных процесов.", g#auto-pid, {&window-name}:title )
      .
      run write-to-log ( "Запущена система выполнения автозаданий" ) no-error.
      if error-status:error
      then do:
          run write-to-screen (return-value).
      end.

      if mHiddenMode = false then do:
         run write-to-log ( "Через 5 секунд будет запущено выполнении автозаданий" ) no-error.
         if error-status:error
         then do:
            run write-to-screen (return-value).
         end.
         wait-for
            go of frame {&frame-name}
            or close of this-procedure
            or choose of b-hand in frame {&frame-name}
            or choose of b-help in frame {&frame-name}
            or choose of b-prop in frame {&frame-name}
            or choose of b-start in frame {&frame-name}
            focus frame {&frame-name}
            pause 5
         .
      end.
      if not log-exit
      then do:
         run write-to-log ( "Запущен автоматический режим выполнения заданий" ) no-error.
         if error-status:error
         then do:
            run write-to-screen (return-value).
         end.
      end.
      mtitle = {&window-name}:title.
      if mForDb <> "":U then do:
         run write-to-log ( substitute( "Сессия работает с БД &1", mForDb ) ).
      end.
      if mForExtsys <> "":U then do:
         run write-to-log ( substitute( "Сессия работает с Внешними Системами &1", mForExtsys ) ).
      end.
      if mForProc <> "":U then do:
         run write-to-log ( substitute( "Сессия работает с Произвольными заданиями &1", mForProc ) ).
      end.
      define variable mAutoType as character no-undo.
      define variable mTypeProc as character no-undo.
      if i-auto-type ne ""
      then
         run write-to-log ( substitute( "Переданые типы &1", i-auto-type ) ).
      define variable vi as integer no-undo.
      do vi = 1 to num-entries (i-auto-type):
         mTypeProc = entry(vi,i-auto-type).
         if lookup(mTypeProc,mAllTypeSuport) ne 0
         then
            mAutoType = mAutoType +  "," + mTypeProc.
      end.
      i-auto-type = trim (mAutoType,",").
      if i-auto-type eq ""
      then do:
         i-auto-type = {&btpr-type-autonws} + "," + {&btpr-type-is_diadoc} + "," + {&btpr-type-mercury} + "," + {&btpr-type-is_motp} .
         run write-to-log ( substitute( "Выставлены типы автозаданий по умолчанию &1", i-auto-type ) ).
      end.
      run write-to-log ( substitute( "Типы для обработки &1", i-auto-type ) ).
      run write-to-log ( substitute( "Типы количество сессий задаются -param N:5,T:&1", replace(mAllTypeSuport,",","+") ) ).
      run write-to-log ( substitute( "   N - Количество сессий по умолчанию 10 ") ).
      run write-to-log ( substitute( "   T - Список типов процесов разделитель + ") ).
      run write-to-log ( substitute( "   Поддерживымые типы: ") ).
      run write-to-log ( substitute( "      &1 - Новости", string({&btpr-type-autonws}  ,"x(15)") ) ).
      run write-to-log ( substitute( "      &1 - Диадок ", string({&btpr-type-is_diadoc},"x(15)") ) ).
      run write-to-log ( substitute( "      &1 - Меркурий", string({&btpr-type-mercury}  ,"x(15)") ) ).
      run write-to-log ( substitute( "      &1 - МОТП", string({&btpr-type-is_motp}  ,"x(15)") ) ).
      run write-to-log ( substitute( "      &1 - Архивы", string({&btpr-type-autoarh}  ,"x(15)") ) ).
      run write-to-log ( substitute( "      &1 - SmartHDD", string({&btpr-type-hddtest}  ,"x(15)") ) ).
      run write-to-log ( substitute( "      &1 - Экспрт данных", string({&btpr-type-autoexp}  ,"x(15)") ) ).
      
   
      mAsyncHelper = new ibs.th.file.AsyncHelperth().
      mAsyncHelper:mProcPublish = this-procedure.
      mAsyncHelper:setCurrentUserPasswd().
      mAsyncHelper:MyBachMode = yes.
      mAsyncHelper:WritelogInter = 5.
      mAsyncHelper:MyBachMode = yes.
      if inumSession > 0 and inumSession ne ?
      then
         mAsyncHelper:maxproc = inumSession.
      run write-to-log ( substitute( "Колличество сессий &1", mAsyncHelper:maxproc ) ).
      
      subscribe "EndTaskAsunc" anywhere run-procedure "RunNewTask".
      run initAsyncProc ({&window-name}:title,
                         i-auto-type,
                         mAsyncHelper:getListTask(),
                         no,
                         output mDbInfo) no-error.
      main-cycl:
      do while not log-exit
      on error  undo, leave main-cycl
      on stop   undo, next
      on endkey undo, next
      :
         run cur-time( output v-today
                      ,output v-time
                   ) no-error.
         run CheckUpdate no-error.
         if error-status :error then do:
              return error return-value.
         end.
         run AddCashParam(i-auto-type,v-today, v-time).
        
         run initAsyncProc ({&window-name}:title,
                            i-auto-type,
                            mAsyncHelper:getListTask(),
                            yes,
                            output mDbInfo) no-error.
         if error-status:error
         then do:
            assign
               {&window-name}:title = mTitle
            .
            if return-value = "WaitOK"
            then
               next main-cycl .
            log-exit = true.
            leave main-cycl .
         end.
 
         {&window-name}:title = mtitle + {&space-char} + mDbInfo.
         if num-entries( mListDb ) > 0
         then do:
            run write-to-log ( "Текущая" + {&space-char} + mDbInfo ) no-error.
            if error-status:error
            then do:
               run write-to-screen (return-value).
            end.
         end.
         if mAsyncHelper:isWorkShed()
         then do:
            run waitproc("Ожидаем получение данных").
            run adm/autoconn.p no-error.
            if error-status :error 
            then do:
               run write-to-log ( substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message(1) ) ).
               assign
                  {&window-name}:title = mtitle
               .
            end.
         end.
         
         assign
            start-time = etime
          .
         do while not log-exit:
            if mHiddenMode = false then do:
               wait-for
                     go of frame {&frame-name}
                  or close of this-procedure
                  or choose of b-hand in frame {&frame-name}
                  or choose of b-help in frame {&frame-name}
                  or choose of b-prop in frame {&frame-name}
                  or choose of b-start in frame {&frame-name}
                  focus frame {&frame-name}
                  pause 1
               .
               display
                  string( time, "HH:MM:SS" ) @ curr-time
                  today @ curr-date
                  with frame {&frame-name}
               no-error.
            end.
            else do:
               wait-for
                     go of frame {&frame-name}
                  or close of this-procedure
                  pause 1
               .
            end.
            run ReedFileContext.
            
            if     mHiddenMode = false
               and frame {&frame-name}:visible = false
            then do:
               run myenable in this-procedure
                  ( input i-auto-type
                  ) .
            end.
            if     mHiddenMode = true
               and frame {&frame-name}:visible = true
            then do:
               run myhide in this-procedure .
            end.
            if    etime - start-time > 60000
               or time mod 60 = 1
            then do:
               leave .
            end.
         end.
         if mHiddenMode = false 
         then do:
            display
              "" @ curr-time
              "" @ curr-date
              with frame {&frame-name}
              no-error
            .
         end.
      end.
   end.
end.
unsubscribe "EndTaskAsunc".
delete object mAsyncHelper.
run write-to-log ( "Закончен сеанс выполнения автозаданий" ) no-error.
if error-status:error
then do:
   run write-to-screen (return-value).
end.
run disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI automain  _DEFAULT-DISABLE
procedure disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Delete the WINDOW we created */
  if session:display-type = "GUI":U and VALID-HANDLE(automain)
  then delete widget automain.
  if this-procedure:persistent then delete procedure this-procedure.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI automain  _DEFAULT-ENABLE
procedure enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  display auto-log curr-date curr-time
      with frame f-amain in window automain.
  enable b-exit b-help auto-log
      with frame f-amain in window automain.
  {&OPEN-BROWSERS-IN-QUERY-f-amain}
  view automain.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-db-num automain
procedure get-db-num :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define output parameter p-db-num as integer no-undo .
  do
  on error undo, return error return-value
  :
      run gbl/getdbnum.p (output p-db-num).
  end. /*doe*/


end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-report-num automain
procedure get-report-num :
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

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-userid automain
procedure get-userid :
do
on error undo, return error
:
define output parameter p-userid  as character    no-undo.

    assign
        p-userid = g#userid
    .
end.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE hide-message automain
procedure hide-message :
assign
    f-msg = "":U
  .
  hide f-msg in frame {&frame-name}.
  return .

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE myenable automain
procedure myenable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input  parameter pe-auto-type as character no-undo .

  assign
    automain:hidden = false
  .

  run enable_UI.

  if pe-auto-type = {&btpr-type-autonws}
    or pe-auto-type = {&btpr-type-autooxml}
  then do:
    enable b-hand b-prop with frame {&frame-name}.
  end.
  
  if session:debug-alert
  then do:
    enable b-start b-prop with frame {&frame-name}.
  end.
  /*  if    pe-auto-type = {&btpr-type-is_motp}
     or pe-auto-type = {&btpr-type-is_diadoc}
  then do:
    enable b-hand with frame {&frame-name}.
  end. */

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE myhide automain
procedure myhide :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  disable all with frame {&frame-name} .
  hide all no-pause in window {&window-name} .
  assign
    automain:hidden = true
  .
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE write-message automain
procedure write-message :
define input  parameter p-msg as character no-undo .

  assign
    f-msg = p-msg
  .
  enable f-msg with frame {&frame-name}.
  display
    f-msg
    with frame {&frame-name}
    .
  return .

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE RunNewTask automain
procedure RunNewTask :
define input  parameter iTask as character no-undo .

  run initAsyncProc ({&window-name}:title,
                     i-auto-type, /* попробуем добавить все  что были */
                     mAsyncHelper:getListTask(),
                     yes,
                     output mDbInfo) no-error.

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
