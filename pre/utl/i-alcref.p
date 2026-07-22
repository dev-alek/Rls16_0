block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: 9ebe6f343c82, 149, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Mon Feb 16 20:50:30 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: i-alcref.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/i-alcref.p $":U .
define variable vss-description as character no-undo init "Утилита закачки видов алкоголя".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define variable v-account as integer init 0 no-undo .
define variable v-account-lavel as character no-undo .
define variable v-button-stop as logical no-undo .
define variable v-kol-spice as integer no-undo .
define variable v-kol-spice2 as integer no-undo .
define variable v-kol-spice3 as integer no-undo .
DEFINE VARIABLE StopProcessing AS LOGICAL NO-UNDO.
DEFINE BUTTON StopBtn AUTO-END-KEY
     LABEL "Стоп"
     SIZE 10 BY 1.
DEFINE VARIABLE RecordsDone AS INTEGER FORMAT ">,>>>,>>>,>>9":U INITIAL 0
     LABEL "Обработано записей"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.
DEFINE VARIABLE RecordsString AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE RecordsString2 AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE RecordsString3 AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 55.13 BY 4.46.
DEFINE FRAME InfoFrame
     StopBtn AT ROW 4.25 COL 21.75
     RecordsString AT ROW 1.21 COL 2 NO-LABEL
     RecordsString2 AT ROW 1.96 COL 2 NO-LABEL
     RecordsString3 AT ROW 2.58 COL 2 NO-LABEL
     RecordsDone AT ROW 3.42 COL 24.88 COLON-ALIGNED
     RECT-1 AT ROW 1 COL 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Процесс"
         DEFAULT-BUTTON StopBtn CANCEL-BUTTON StopBtn.
define variable mFrameView      as logical   no-undo init yes.
  define variable mFramHandle as handle no-undo.
  mFramHandle = frame InfoFrame:handle.
  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramHandle:visible), "frameRepError").
  end.
  mFrameView = not session:batch-mode and mFramHandle:visible.
  if mFrameView
  then do:
    ASSIGN
       FRAME InfoFrame:HIDDEN                           = TRUE
       StopBtn:sensitive IN FRAME InfoFrame             = TRUE.
  end.
ON CHOOSE OF StopBtn IN FRAME InfoFrame
DO:
  IF not StopProcessing THEN
    Message "Вы действительно хотите прервать" SKIP
            "процесс проверки?" view-as alert-box QUESTION BUTTONS yes-no
              UPDATE StopProcessing.
  IF StopProcessing THEN do:
     if mFrameView
     then do:
        HIDE FRAME InfoFrame.
     end.
  End.
END.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define temp-table tt-alc-type no-undo like ub.alc-type.
define stream in-stream.
DEFINE STREAM log-stream.
define buffer buf_alc-type      for ub.alc-type.
define buffer buf_tt-alc-type   for tt-alc-type.
define buffer buf_alc-type-gds  for ub.alc-type-gds.
define variable v-log             as logical   no-undo .
define variable v-repfrm-str      as character no-undo .
define variable v-filename        as character no-undo .
define variable v-alc-type-code   as character no-undo .
define variable v-alc-type-name   as character no-undo .
define variable v-sea-sort        as character no-undo .
define variable v-str             as character no-undo .
define variable v-error           as character no-undo .
define variable v-alc-type-status as integer   no-undo .
define variable v-counter         as integer   no-undo .
define variable v-file-str-num    as integer   no-undo .
define variable v-i               as integer   no-undo .
define variable v-num             as integer   no-undo .
PROCEDURE write-log:
   define input parameter p-log-message as character no-undo.
   define input parameter p-error       as logical no-undo.
   define input parameter p-message     as logical no-undo.
   if p-message then do:
      MESSAGE p-log-message
      VIEW-AS ALERT-BOX INFORMATION .
   end.
   EXPORT STREAM log-stream DELIMITER "~t"
         TODAY
         TIME
         g#userid
         g#db-num
         p-log-message
   .
   if p-error then DO:
      OUTPUT STREAM log-stream CLOSE.
      return error p-log-message.
   end.
end procedure.
do
on error  undo, return error return-value
on endkey undo, return error return-value
on stop   undo, return error return-value
  :
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
  OUTPUT STREAM log-stream TO VALUE( "alctype-log.ref":U ) CONVERT SOURCE "1251" APPEND.
      run write-log in this-procedure
            ( input "Начат импорт справочника видов алкоголя"
            , input no
            , input no
            ) .
     .
  message
    "Импорт справочника видов алкогольной продукции." skip
    "Начать импорт?"
  view-as alert-box question
  buttons yes-no update v-log.
  IF v-log <> YES THEN DO:
     run write-log in this-procedure
            ( input "отказ от импорта справочника"
            , input yes
            , input yes
            ) .
  END.
  ASSIGN
    v-filename     = SEARCH ("cmp/alctype.ref":U)
    v-counter      = 0
    v-file-str-num = 0
    v-repfrm-str   = "Чтение файла...":U
  .
  if v-filename = ? then do :
     run write-log in this-procedure
            ( input substitute( "Не найден файл &1.", "cmp/alctype.ref":U )
            , input yes
            , input yes
            ) .
  END.
  EMPTY TEMP-TABLE tt-alc-type.
  INPUT STREAM in-stream FROM VALUE( v-filename ) CONVERT SOURCE "1251".
      run write-log in this-procedure
            ( input substitute("открыт файл &1", v-filename)
            , input no
            , input no
            ) .
assign v-account = ( if integer( 1 ) = 0 then 100 else integer( 1 ) ).
  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("ON mFrameView=" + string(mFrameView), "frameRepError").
  end.
  if not session:batch-mode then
  do:
    VIEW FRAME InfoFrame.
    mFrameView = true.
  end.
   v-button-stop = false .
      if mFrameView
      then do:
      if v-button-stop then view STOPBTN in frame InfoFrame.
                       else Hide STOPBTN in frame InfoFrame.
      end.
  REPEAT
  :
    ASSIGN
      v-str           = ""
      v-alc-type-code = ""
      v-alc-type-name = ""
      v-sea-sort      = ""
      v-alc-type-status      = 0
      v-num           = 0
    .
    IMPORT STREAM in-stream UNFORMATTED v-str NO-ERROR .
    IF ERROR-STATUS :ERROR THEN DO:
      INPUT  STREAM in-stream  CLOSE.
      run write-log in this-procedure
            ( input SUBSTITUTE( "Ошибка при импорте данных из файла &1."
                              , "cmp/alctype.ref":U )
            , input yes
            , input yes
            ) .
    END.
    ASSIGN
      v-num          = NUM-ENTRIES( v-str , ";":U )
      v-file-str-num = v-file-str-num + 1
    .
    if v-num <> 4 then do:
      INPUT  STREAM in-stream  CLOSE.
      run write-log in this-procedure
            ( input SUBSTITUTE( "В файле &1 неверный формат строки &2."
                             , "cmp/alctype.ref":U
                             , v-file-str-num
                             )
            , input yes
            , input yes
            ) .
    END.
    ASSIGN
       v-alc-type-code = ENTRY( 1 , v-str , ";":U )
       v-alc-type-name = ENTRY( 2 , v-str , ";":U )
       v-sea-sort      = STRING( INTEGER( ENTRY( 3 , v-str , ";":U ) ) , "9999" )
       v-alc-type-status      = INTEGER( entry( 4 , v-str , ";":U ) )
       NO-ERROR
    .
    IF ERROR-STATUS :ERROR THEN DO :
      INPUT  STREAM in-stream  CLOSE.
      run write-log in this-procedure
            ( input SUBSTITUTE( "Ошибка при импорте данных из файла &1 в строке &2.&3&4"
                             , "cmp/alctype.ref":U
                             , v-file-str-num)
            , input yes
            , input yes
            ) .
    END.
    IF CAN-FIND( FIRST buf_tt-alc-type WHERE buf_tt-alc-type.alc-type-code = v-alc-type-code
                                       NO-LOCK)
    THEN DO:
      INPUT  STREAM in-stream  CLOSE.
      run write-log in this-procedure
            ( input SUBSTITUTE( "В файле &1 присутствует более одного вида алкогольной продукции с кодом: &2."
                              , "cmp/alctype.ref":U
                              , v-alc-type-code
                              )
            , input yes
            , input yes
            ) .
    END.
    CREATE tt-alc-type.
    ASSIGN
      v-counter                   = v-counter + 1
      tt-alc-type.alc-type-code   = v-alc-type-code
      tt-alc-type.alc-type-name   = v-alc-type-name
      tt-alc-type.alc-type-status = v-alc-type-status
    .
      run write-log in this-procedure
            ( input substitute("Импортирован &1, &2", v-alc-type-code, v-alc-type-code)
            , input no
            , input no
            ) .
     .
IF ( v-counter modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH(v-repfrm-str)) / 2
    RecordsString = fill(' ',v-kol-spice) + string(v-repfrm-str)
    .
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              v-counter @ RecordsDone
              RecordsString   @ RecordsString
              WITH FRAME InfoFrame.
           end.
End.
   if v-button-stop then  DO:
         if mFrameView
         then
            PROCESS EVENTS.
         IF StopProcessing THEN DO:
         RETURN error.
         End.
   end.
  END.
  INPUT STREAM in-stream CLOSE.
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
   run write-log in this-procedure
         ( input "Достигнут конец файла"
         , input no
         , input no
         ) .
  FOR EACH buf_alc-type
                        EXCLUSIVE-LOCK
                        :
      IF NOT CAN-FIND( FIRST tt-alc-type
                       WHERE tt-alc-type.alc-type-code = buf_alc-type.alc-type-code
                       NO-LOCK )
      THEN DO:
         if can-find ( first buf_alc-type-gds
                       where buf_alc-type-gds.alc-type-inner-code = buf_alc-type.alc-type-inner-code
                       no-lock
                     ) then do:
            ASSIGN
               buf_alc-type.alc-type-status = 1
            .
            run write-log in this-procedure
               ( input SUBSTITUTE("В файле &1 отсутствовал вид алкогольной продукции с кодом: &2. Ему изменен статус с 0 на 1. Не забудьте открепить товары."
                     , "cmp/alctype.ref":U
                     , buf_alc-type.alc-type-code
                     )
               , input no
               , input yes
               ) .
         end.
         else DO:
            delete buf_alc-type.
         end.
      END.
  END.
  ASSIGN
    v-counter     = 0
    v-repfrm-str  = "Загрузка видов алкогольной продукции...":U
  .
  FOR EACH tt-alc-type NO-LOCK :
      ASSIGN
        v-counter = v-counter + 1
      .
      FIND FIRST buf_alc-type WHERE buf_alc-type.alc-type-code = tt-alc-type.alc-type-code
                              NO-LOCK
                              NO-ERROR
                              .
      IF AVAILABLE buf_alc-type THEN DO:
        FIND CURRENT buf_alc-type EXCLUSIVE-LOCK NO-WAIT.
        IF LOCKED buf_alc-type THEN DO :
         run write-log in this-procedure
            ( input SUBSTITUTE ( "Запись вида алкогольной продукции <&1. &2> редактируется.&3Изменение записи невозможно."
                       , tt-alc-type.alc-type-code
                       , tt-alc-type.alc-type-name
                       , chr(10)
                       )
            , input yes
            , input yes
            ) .
        END.
        ELSE DO :
          IF tt-alc-type.alc-type-status <> 0 THEN DO:
             FIND FIRST buf_alc-type-gds WHERE buf_alc-type-gds.alc-type-inner-code = tt-alc-type.alc-type-inner-code
                                           AND buf_alc-type-gds.alc-type-inner-code = tt-alc-type.alc-type-inner-code
                                         NO-LOCK
                                         NO-ERROR
                                         .
             IF AVAILABLE buf_alc-type-gds THEN do:
               run write-log in this-procedure
                  ( input SUBSTITUTE( "К виду алкогольной продукции <&1. &2> есть привязаные товары.&3Удаление вида невозможно."
                                 , tt-alc-type.alc-type-code
                                 , tt-alc-type.alc-type-name
                                 , chr(10)
                                 )
                  , input no
                  , input yes
                  ) .
             END.
             ELSE DO :
               DELETE buf_alc-type.
             END.
          END.
          ELSE DO:
            ASSIGN
              buf_alc-type.alc-type-name = tt-alc-type.alc-type-name
            .
          END.
        END.
      END.
      ELSE DO:
        IF tt-alc-type.alc-type-status = 0 THEN DO:
          v-num = next-value ( s-alc-type , ub).
          CREATE buf_alc-type.
          ASSIGN
             buf_alc-type.alc-type-inner-code = v-num
             buf_alc-type.create-user-db-num  = v-cntxt-db-num
             buf_alc-type.alc-type-code       = tt-alc-type.alc-type-code
             buf_alc-type.alc-type-name       = tt-alc-type.alc-type-name
             buf_alc-type.alc-type-status     = tt-alc-type.alc-type-status
             buf_alc-type.create-user         = ''
             buf_alc-type.create-date         = TODAY
             buf_alc-type.create-time         = TIME
             buf_alc-type.corr-user-name      = ''
             buf_alc-type.corr-date           = TODAY
             buf_alc-type.corr-time           = TIME
          .
        END.
      END.
IF ( v-counter modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH(v-repfrm-str)) / 2
    RecordsString = fill(' ',v-kol-spice) + string(v-repfrm-str)
    .
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              v-counter @ RecordsDone
              RecordsString   @ RecordsString
              WITH FRAME InfoFrame.
           end.
End.
   if v-button-stop then  DO:
         if mFrameView
         then
            PROCESS EVENTS.
         IF StopProcessing THEN DO:
         RETURN error.
         End.
   end.
  END.
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
  EMPTY TEMP-TABLE tt-alc-type.
  run write-log in this-procedure
      ( input "Импорт справочника завершен!"
      , input NO
      , input yes
      ) .
  OUTPUT STREAM log-stream CLOSE.
END.
