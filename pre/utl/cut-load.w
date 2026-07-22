CREATE WIDGET-POOL.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define new  shared variable g#auto as logical no-undo.
define new  shared variable g#news as logical no-undo.
define new  shared variable g#oxml as logical no-undo.
define new  shared variable g#esys as logical no-undo.
define new  shared variable g#news-source-db as integer no-undo.
define new  shared variable g#esys-source-esys as integer no-undo.
define new  shared variable g#db-num as integer   no-undo .
define new  shared variable g#userid as character no-undo .
define new  shared variable g#passwd as character no-undo .
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
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure db-attr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-value :
  define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
  define output parameter p-value     like ub.db-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-value in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-write :
  define input parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input parameter p-code      like ub.db-attr.attr-code  no-undo .
  define input parameter p-value     like ub.db-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-write in g#attr-lib
      (input p-db-num
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-exist :
  define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-exist in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-delete :
  define input  parameter p-db-num   like ub.db-attr.db-num     no-undo .
  define input  parameter p-code     like ub.db-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-delete in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable ret-err              as logical   no-undo .
define variable err-msg              as character no-undo .
define variable sel-rid-list         as character no-undo .
define variable answ-rid-list        as character no-undo .
define variable v-cut-type           as integer   no-undo .
define variable v-cut-run            as logical   no-undo .
define variable v-db-list            as character no-undo .
define variable v-not-answer-db-list as character no-undo .
define variable v-ind                as integer   no-undo .
define variable v-num-entries        as integer   no-undo .
define buffer buf_BatchProcess for ub.BatchProcess .
define buffer buf_db for ub.db .
DEFINE VAR cut-load AS WIDGET-HANDLE NO-UNDO.
DEFINE BUTTON b-exit DEFAULT
     LABEL "&Ввод"
     SIZE 10 BY 1.
DEFINE BUTTON b-mark DEFAULT
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY DEFAULT
     LABEL "&Отмена"
     SIZE 10 BY 1.
DEFINE BUTTON b-refresh DEFAULT
     LABEL "&Обновить"
     SIZE 10 BY 1.
DEFINE VARIABLE type-cut AS CHARACTER FORMAT "X(256)":U INITIAL "Полное"
     LABEL "Тип усечения БД"
     VIEW-AS COMBO-BOX INNER-LINES 2
     LIST-ITEMS "Полное" ,"Усечение документов по БД"
     DROP-DOWN-LIST
     SIZE 28.38 BY 1 NO-UNDO.
DEFINE VARIABLE log-edit AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL LARGE
     SIZE 96.38 BY 9.88 NO-UNDO.
DEFINE VARIABLE date-actual-docs AS DATE FORMAT "99/99/9999":U
     LABEL "Дата актуальности документов и архивов"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE date-actual-findoc AS DATE FORMAT "99/99/9999":U
     LABEL "Дата актуальности финансовых документов"
     VIEW-AS FILL-IN
     SIZE 11.13 BY .92 NO-UNDO.
DEFINE VARIABLE date-actual-goods AS DATE FORMAT "99/99/9999":U
     LABEL "Дата актуальности товаров"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE date-output-zone AS DATE FORMAT "99/99/9999":U
     LABEL "Дата расходной зоны"
     VIEW-AS FILL-IN
     SIZE 11.13 BY .92 NO-UNDO.
DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 3 BY .67 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 57 BY 9.58.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 40 BY 9.54.
DEFINE VARIABLE not-copy-del-goods AS LOGICAL INITIAL yes
     LABEL "Не копировать удаленные товары с ненулевыми остатками"
     VIEW-AS TOGGLE-BOX
     SIZE 55.75 BY 1 NO-UNDO.
DEFINE VARIABLE stay-history AS LOGICAL INITIAL no
     LABEL "Переносить историю по всем таблицам"
     VIEW-AS TOGGLE-BOX
     SIZE 38.25 BY 1 NO-UNDO.
DEFINE VARIABLE stay-recipe-goods AS LOGICAL INITIAL yes
     LABEL "Оставить товары для рецептов"
     VIEW-AS TOGGLE-BOX
     SIZE 31.75 BY 1 NO-UNDO.
DEFINE VARIABLE stay-weight-goods AS LOGICAL INITIAL yes
     LABEL "Оставить все весовые товары"
     VIEW-AS TOGGLE-BOX
     SIZE 30.25 BY 1 NO-UNDO.
DEFINE QUERY br_db FOR
      ub.db SCROLLING.
DEFINE BROWSE br_db
  QUERY br_db NO-LOCK DISPLAY
      (if ( lookup( string( recid( ub.db ) ), answ-rid-list ) <> 0 )
  then "+":U
  else (if ( lookup( string( recid( ub.db ) ), sel-rid-list ) <> 0 )
        then "*":U
        else "":U )
) COLUMN-LABEL "*" FORMAT "x(1)":U
      ub.db.db-num FORMAT ">>>>9":U
      ub.db.db-name FORMAT "X(40)":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 37.75 BY 7.83.
DEFINE FRAME DEFAULT-FRAME
     b-exit AT ROW 1.17 COL 2.5
     b-quit AT ROW 1.17 COL 12.5
     type-cut AT ROW 2.46 COL 19.38 COLON-ALIGNED
     stay-weight-goods AT ROW 3.96 COL 1.75
     b-mark AT ROW 4.04 COL 62.25
     b-refresh AT ROW 4.04 COL 87.5
     not-copy-del-goods AT ROW 5.13 COL 1.75
     br_db AT ROW 5.21 COL 60.25
     stay-recipe-goods AT ROW 6.21 COL 1.75
     date-actual-goods AT ROW 7.42 COL 41.13 COLON-ALIGNED
     date-actual-docs AT ROW 8.54 COL 41.13 COLON-ALIGNED
     date-actual-findoc AT ROW 9.71 COL 41.13 COLON-ALIGNED
     date-output-zone AT ROW 10.83 COL 41.13 COLON-ALIGNED
     stay-history AT ROW 11.88 COL 2.88
     log-edit AT ROW 13.5 COL 2.38 NO-LABEL
     mark-num AT ROW 4.25 COL 64.25 COLON-ALIGNED NO-LABEL
     RECT-1 AT ROW 3.71 COL 1
     RECT-2 AT ROW 3.71 COL 59
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS THREE-D
         AT COL 1 ROW 1
         SIZE 98.88 BY 22.63
         CANCEL-BUTTON b-quit.
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW cut-load ASSIGN
         HIDDEN             = YES
         TITLE              = "'Запуск"
         HEIGHT             = 22.63
         WIDTH              = 98.88
         MAX-HEIGHT         = 23.63
         MAX-WIDTH          = 98.88
         VIRTUAL-HEIGHT     = 23.63
         VIRTUAL-WIDTH      = 98.88
         RESIZE             = no
         SCROLL-BARS        = no
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         KEEP-FRAME-Z-ORDER = yes
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE cut-load = CURRENT-WINDOW.
ASSIGN
       FRAME DEFAULT-FRAME:HIDDEN           = TRUE.
ASSIGN
       date-actual-findoc:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
ASSIGN
       log-edit:READ-ONLY IN FRAME DEFAULT-FRAME        = TRUE.
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(cut-load)
THEN cut-load:HIDDEN = no.
ON END-ERROR OF cut-load
OR ENDKEY OF cut-load ANYWHERE DO:
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.
ON WINDOW-CLOSE OF cut-load
DO:
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.
ON CHOOSE OF b-exit IN FRAME DEFAULT-FRAME
DO:
  define variable v-ok               as logical   no-undo .
  define variable v-date             as date      no-undo .
  define variable v-time             as integer   no-undo .
  define variable v-db-send          as character no-undo .
  define variable v-db-num-str       as character no-undo .
  define variable v-deleted          as logical   no-undo .
  define variable v-unload-after-cut as character no-undo .
  define variable v-ready            as logical   no-undo .
  assign frame DEFAULT-FRAME
    date-actual-goods
    date-actual-docs
    date-output-zone
    stay-recipe-goods
    stay-weight-goods
    stay-history
    not-copy-del-goods
    type-cut
  .
  if date-actual-docs = ? then do:
    assign
      date-actual-docs = TODAY
    .
  end.
  assign
    date-actual-findoc = date-actual-docs
  .
  assign
    v-ok = false
  .
  if ( v-cut-type = 1 and v-cut-run <> true )
     or v-cut-type <> 1
  then do:
    message
      'Вы уверены, что хотите произвести "обрезание" базы данных?' skip
      view-as alert-box question buttons yes-no update v-ok .
    if v-ok <> true then do:
      return no-apply .
    end.
  end.
  if v-cut-type = 1 then do:
    if v-cut-run = true then do:
      run scan-ready in this-procedure
        ( input v-db-list
         ,input date-actual-docs
         ,input date-actual-findoc
         ,output answ-rid-list
         ,output v-not-answer-db-list
        ).
      if v-not-answer-db-list <> "":U then do:
        message
          substitute( "УБД &1 еще не прислали подтверждения о готовности!", v-not-answer-db-list ) skip
          view-as alert-box error
        .
        return no-apply.
      end.
      assign
        v-ok               = true
        not-copy-del-goods = false
        stay-weight-goods  = true
        stay-recipe-goods  = true
        date-actual-goods  = 01/01/1900
        date-output-zone   = 01/01/1900
      .
    end.
    else do:
      do transaction
      on error undo, return no-apply
      :
        assign
          v-num-entries = num-entries( sel-rid-list )
          v-db-list     = "":U
          v-db-send     = "":U
          v-ok          = false
        .
        do v-ind = 1 to v-num-entries
        on error undo, return no-apply
        :
          find first buf_db no-lock
            where recid( buf_db ) = integer( entry( v-ind, sel-rid-list ) )
            .
          assign
            v-db-num-str = string( buf_db.db-num )
            v-db-list    = ( if v-db-list <> "":U then (v-db-list + chr(44)) else "":U ) + v-db-num-str
            v-ready      = false
          .
          if buf_db.db-num <> 0 then do:
            assign
              v-unload-after-cut = "no":U
            .
            if trim( buf_db.db-key ) = "":U then do:
              assign
                v-ready = true
              .
            end.
            else do:
              assign
                v-db-send = ( if v-db-send <> "":U then (v-db-send + chr(1)) else "":U ) + v-db-num-str
                v-ready   = false
              .
            end.
          end.
          else do:
            if lookup( "0":U, v-db-list, chr(44) ) <> 0 then do:
              assign
                v-unload-after-cut = "yes":U
                v-ready            = true
              .
            end.
            else do:
              assign
                v-unload-after-cut = "":U
                v-ready            = false
              .
            end.
          end.
          if v-unload-after-cut <> "":U then do:
            run db-attr-write
              ( input buf_db.db-num
               ,input 'unload-after-cut':U
               ,input v-unload-after-cut
              ) no-error.
            if error-status :error then do:
              message
                vss-workfile vss-revision vss-description skip
                substitute( "Ошибка при записи значения атрибута 'выгрузка после обрезания' для БД &1", buf_db.db-num ) skip
                return-value skip
                error-status :get-message ( error-status :num-messages )
                view-as alert-box error
              .
              return no-apply.
            end.
            if v-ready = true then do:
              run db-attr-write in this-procedure
                ( input buf_db.db-num
                 ,input 'cut-date':U
                 ,input string( date-actual-docs, "99/99/9999" )
                ) no-error.
              if error-status :error then do:
                message
                  vss-workfile vss-revision vss-description skip
                  substitute( "Ошибка при записи значения атрибута 'дата обрезания складских документов' для БД &1", buf_db.db-num ) skip
                  return-value skip
                  error-status :get-message ( error-status :num-messages )
                  view-as alert-box error
                .
                undo, return no-apply.
              end.
              run db-attr-write in this-procedure
                ( input buf_db.db-num
                 ,input 'cut-fin-date':U
                 ,input string( date-actual-findoc, "99/99/9999" )
                ) no-error.
              if error-status :error then do:
                message
                  vss-workfile vss-revision vss-description skip
                  substitute( "Ошибка при записи значения атрибута 'дата обрезания финансовых документов' для БД &1", buf_db.db-num ) skip
                  return-value skip
                  error-status :get-message ( error-status :num-messages )
                  view-as alert-box error
                .
                undo, return no-apply.
              end.
            end.
          end.
        end.
        assign
          v-date    = TODAY
          v-time    = TIME
          v-cut-run = true
        .
        run db-attr-write in this-procedure
          ( input 0
           ,input 'cut-db-list':U
           ,input v-db-list
          ) no-error.
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            substitute( "Ошибка при записи значения атрибута 'Список БД для обрезания' для БД 0" ) skip
            return-value skip
            error-status :get-message ( error-status :num-messages )
            view-as alert-box error
          .
          undo, return no-apply.
        end.
        create buf_BatchProcess.
        assign
          buf_BatchProcess.BatchProcess#     = next-value (s-btpr, ub)
          buf_BatchProcess.BP_Type           = 'cutdbs':U
          buf_BatchProcess.CharKey_Two       = string( date-actual-docs, "99/99/9999" )
          buf_BatchProcess.CharKey_Three     = string( date-actual-findoc, "99/99/9999" )
          buf_BatchProcess.User_ID           = "cut-load":U
          buf_BatchProcess.BP_SysDate        = v-date
          buf_BatchProcess.BP_SysTimeInt     = v-time
          buf_BatchProcess.BP_SysTime        = string(v-time, 'HH:MM:SS':U)
          buf_BatchProcess.BP_ExecSysDate    = v-date
          buf_BatchProcess.BP_ExecSysTimeInt = v-time
          buf_BatchProcess.BP_ExecSysTime    = string(v-time, 'HH:MM:SS':U)
        .
        run nws/cr-route.p
          ( input 'send-cmd':U
           ,input "command" + chr(1) + "cut-doc" + chr(1) + string( date-actual-docs, "99/99/9999" ) + chr(1) + string( date-actual-findoc, "99/99/9999" )
           ,input ?
           ,input v-db-send
          ).
      end.
      apply "value-changed" to type-cut in frame DEFAULT-FRAME.
      message
        "Команда о начале процесса усечения документов отправлена в выбранные БД." skip
        "Обменяйтесь новостями." skip
        "После получения подтверждения запустите процесс усечения документов."
        view-as alert-box information.
    end.
  end.
  else do:
    assign
      v-ok = true
    .
  end.
  if v-ok = true then do:
    run utl/cutld.p
      ( input v-cut-type
       ,input v-db-list
       ,input date-actual-goods
       ,input date-actual-docs
       ,input date-actual-findoc
       ,input date-output-zone
       ,input stay-recipe-goods
       ,input stay-weight-goods
       ,input not-copy-del-goods
       ,input stay-history
       ,input this-procedure :handle
      ) no-error.
    if error-status :error then do:
      assign
        ret-err = TRUE
        err-msg = return-value
      .
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Ошибка при работе утилит!" ) skip
        return-value skip
        error-status :get-message ( error-status :num-messages )
        view-as alert-box error
      .
    end.
    else do:
      if v-cut-type = 1 then do:
        for each buf_BatchProcess
          where buf_BatchProcess.BP_type = 'cutdbs':U
        on error undo, return no-apply
        :
          delete buf_BatchProcess .
        end.
        run db-attr-delete in this-procedure
          ( input 0
           ,input 'cut-db-list':U
           ,output v-deleted
          ).
      end.
      message
        substitute( "Усечение завершено." ) skip
        view-as alert-box information
      .
    end.
    apply "close":u to this-procedure.
    return no-apply.
  end.
END.
ON CHOOSE OF b-mark IN FRAME DEFAULT-FRAME
OR MOUSE-SELECT-DBLCLICK OF br_db IN FRAME DEFAULT-FRAME
DO:
  define variable v-log as logical no-undo.
  if available ub.db then do:
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid2 as character no-undo .
define variable v-num-entry2 as integer   no-undo .
assign
  v-str-recid2 = trim( string( recid( ub.db ) , "->>>>>>>>>>>9":U ) )
  v-num-entry2 = lookup( v-str-recid2 , sel-rid-list )
.
if v-num-entry2 > 0 then do:
  assign
    entry( v-num-entry2, sel-rid-list ) = "":U
    sel-rid-list = trim( replace( sel-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    sel-rid-list = sel-rid-list + ( if sel-rid-list = "":U then "":U else chr(44) ) + v-str-recid2
  .
end.
    v-log = br_db:refresh() .
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
      v-log = br_db:select-next-row ().
      apply "iteration-changed" to br_db in frame DEFAULT-FRAME.
    end.
    if num-entries( sel-rid-list ) = 0 then do:
      hide mark-num in frame DEFAULT-FRAME.
    end.
    else do:
      disp num-entries( sel-rid-list ) @ mark-num with frame DEFAULT-FRAME.
    end.
  end.
  apply "entry" to br_db in frame DEFAULT-FRAME.
END.
ON CHOOSE OF b-quit IN FRAME DEFAULT-FRAME
DO:
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.
ON CHOOSE OF b-refresh IN FRAME DEFAULT-FRAME
DO:
  define variable v-log as logical no-undo.
  run scan-ready in this-procedure
    ( input  v-db-list
     ,input  date-actual-docs
     ,input  date-actual-findoc
     ,output answ-rid-list
     ,output v-not-answer-db-list
    ).
  v-log = br_db:refresh() .
END.
ON VALUE-CHANGED OF type-cut IN FRAME DEFAULT-FRAME
DO:
  assign
    type-cut
  .
  case type-cut :
    when "Полное" then do:
      assign
        v-cut-type = 0
      .
      HIDE
        br_db
        b-mark
        b-refresh
        mark-num
        IN FRAME DEFAULT-FRAME IN WINDOW cut-load.
      ENABLE
        stay-weight-goods
        not-copy-del-goods
        stay-recipe-goods
        stay-history
        date-actual-goods
        date-output-zone
        WITH FRAME DEFAULT-FRAME IN WINDOW cut-load.
    end.
    when "Усечение документов по БД" then do:
      assign
        v-cut-type = 1
      .
      HIDE
        stay-weight-goods
        not-copy-del-goods
        stay-recipe-goods
        date-actual-goods
        date-output-zone
        IN FRAME DEFAULT-FRAME IN WINDOW cut-load.
      ENABLE
        br_db
        b-mark
        b-refresh
        stay-history
        WITH FRAME DEFAULT-FRAME IN WINDOW cut-load.
      if v-cut-run = true then do:
        DISABLE
          b-mark
          date-actual-docs
          date-actual-findoc
          type-cut
          WITH FRAME DEFAULT-FRAME .
      end.
      assign
        mark-num = num-entries( sel-rid-list )
      .
      if mark-num <> 0 then do:
        DISPLAY
          mark-num
          WITH FRAME DEFAULT-FRAME IN WINDOW cut-load.
      end.
      else do:
        HIDE
          mark-num
          IN FRAME DEFAULT-FRAME IN WINDOW cut-load.
      end.
    end.
  end case.
END.
ASSIGN CURRENT-WINDOW                = cut-load
       THIS-PROCEDURE:CURRENT-WINDOW = cut-load.
ON CLOSE OF THIS-PROCEDURE
   RUN disable_UI.
PAUSE 0 BEFORE-HIDE.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of date-actual-goods in frame DEFAULT-FRAME
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of date-actual-goods in frame DEFAULT-FRAME
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of date-actual-goods in frame DEFAULT-FRAME
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of date-actual-goods in frame DEFAULT-FRAME
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of date-actual-goods in frame DEFAULT-FRAME
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of date-actual-goods in frame DEFAULT-FRAME
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date4
    MENU-ITEM m-ed-date4-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date4-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date4-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date4-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if date-actual-goods :POPUP-MENU in frame DEFAULT-FRAME = ?
  then do:
    ASSIGN
      date-actual-goods :POPUP-MENU in frame DEFAULT-FRAME = MENU m-ed-date4 :HANDLE
      date-actual-goods :MENU-MOUSE in frame DEFAULT-FRAME = 3
    .
  end.
  define variable v-label-handle4 as handle no-undo .
  assign
    v-label-handle4 = date-actual-goods :side-label-handle in frame DEFAULT-FRAME
  .
  if valid-handle (v-label-handle4)
  then do:
    if v-label-handle4 :tooltip = ""
    or v-label-handle4 :tooltip = ?
    then do:
      assign
        v-label-handle4 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date4-1 in menu m-ed-date4 DO:
    apply "ctrl-b":U to date-actual-goods in frame DEFAULT-FRAME .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date4-2 in menu m-ed-date4 DO:
    apply "ctrl-d":U to date-actual-goods in frame DEFAULT-FRAME .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date4-3 in menu m-ed-date4 DO:
    apply "ctrl-e":U to date-actual-goods in frame DEFAULT-FRAME .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date4-4 in menu m-ed-date4 DO:
    apply "ctrl-f":U to date-actual-goods in frame DEFAULT-FRAME .
  END.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of date-actual-docs in frame DEFAULT-FRAME
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of date-actual-docs in frame DEFAULT-FRAME
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of date-actual-docs in frame DEFAULT-FRAME
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of date-actual-docs in frame DEFAULT-FRAME
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of date-actual-docs in frame DEFAULT-FRAME
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of date-actual-docs in frame DEFAULT-FRAME
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date6
    MENU-ITEM m-ed-date6-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date6-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date6-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date6-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if date-actual-docs :POPUP-MENU in frame DEFAULT-FRAME = ?
  then do:
    ASSIGN
      date-actual-docs :POPUP-MENU in frame DEFAULT-FRAME = MENU m-ed-date6 :HANDLE
      date-actual-docs :MENU-MOUSE in frame DEFAULT-FRAME = 3
    .
  end.
  define variable v-label-handle6 as handle no-undo .
  assign
    v-label-handle6 = date-actual-docs :side-label-handle in frame DEFAULT-FRAME
  .
  if valid-handle (v-label-handle6)
  then do:
    if v-label-handle6 :tooltip = ""
    or v-label-handle6 :tooltip = ?
    then do:
      assign
        v-label-handle6 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date6-1 in menu m-ed-date6 DO:
    apply "ctrl-b":U to date-actual-docs in frame DEFAULT-FRAME .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date6-2 in menu m-ed-date6 DO:
    apply "ctrl-d":U to date-actual-docs in frame DEFAULT-FRAME .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date6-3 in menu m-ed-date6 DO:
    apply "ctrl-e":U to date-actual-docs in frame DEFAULT-FRAME .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date6-4 in menu m-ed-date6 DO:
    apply "ctrl-f":U to date-actual-docs in frame DEFAULT-FRAME .
  END.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of date-actual-findoc in frame DEFAULT-FRAME
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of date-actual-findoc in frame DEFAULT-FRAME
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of date-actual-findoc in frame DEFAULT-FRAME
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of date-actual-findoc in frame DEFAULT-FRAME
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of date-actual-findoc in frame DEFAULT-FRAME
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of date-actual-findoc in frame DEFAULT-FRAME
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date8
    MENU-ITEM m-ed-date8-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date8-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date8-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date8-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if date-actual-findoc :POPUP-MENU in frame DEFAULT-FRAME = ?
  then do:
    ASSIGN
      date-actual-findoc :POPUP-MENU in frame DEFAULT-FRAME = MENU m-ed-date8 :HANDLE
      date-actual-findoc :MENU-MOUSE in frame DEFAULT-FRAME = 3
    .
  end.
  define variable v-label-handle8 as handle no-undo .
  assign
    v-label-handle8 = date-actual-findoc :side-label-handle in frame DEFAULT-FRAME
  .
  if valid-handle (v-label-handle8)
  then do:
    if v-label-handle8 :tooltip = ""
    or v-label-handle8 :tooltip = ?
    then do:
      assign
        v-label-handle8 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date8-1 in menu m-ed-date8 DO:
    apply "ctrl-b":U to date-actual-findoc in frame DEFAULT-FRAME .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date8-2 in menu m-ed-date8 DO:
    apply "ctrl-d":U to date-actual-findoc in frame DEFAULT-FRAME .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date8-3 in menu m-ed-date8 DO:
    apply "ctrl-e":U to date-actual-findoc in frame DEFAULT-FRAME .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date8-4 in menu m-ed-date8 DO:
    apply "ctrl-f":U to date-actual-findoc in frame DEFAULT-FRAME .
  END.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of date-output-zone in frame DEFAULT-FRAME
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of date-output-zone in frame DEFAULT-FRAME
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of date-output-zone in frame DEFAULT-FRAME
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of date-output-zone in frame DEFAULT-FRAME
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of date-output-zone in frame DEFAULT-FRAME
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of date-output-zone in frame DEFAULT-FRAME
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date10
    MENU-ITEM m-ed-date10-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date10-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date10-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date10-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if date-output-zone :POPUP-MENU in frame DEFAULT-FRAME = ?
  then do:
    ASSIGN
      date-output-zone :POPUP-MENU in frame DEFAULT-FRAME = MENU m-ed-date10 :HANDLE
      date-output-zone :MENU-MOUSE in frame DEFAULT-FRAME = 3
    .
  end.
  define variable v-label-handle10 as handle no-undo .
  assign
    v-label-handle10 = date-output-zone :side-label-handle in frame DEFAULT-FRAME
  .
  if valid-handle (v-label-handle10)
  then do:
    if v-label-handle10 :tooltip = ""
    or v-label-handle10 :tooltip = ?
    then do:
      assign
        v-label-handle10 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date10-1 in menu m-ed-date10 DO:
    apply "ctrl-b":U to date-output-zone in frame DEFAULT-FRAME .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date10-2 in menu m-ed-date10 DO:
    apply "ctrl-d":U to date-output-zone in frame DEFAULT-FRAME .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date10-3 in menu m-ed-date10 DO:
    apply "ctrl-e":U to date-output-zone in frame DEFAULT-FRAME .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date10-4 in menu m-ed-date10 DO:
    apply "ctrl-f":U to date-output-zone in frame DEFAULT-FRAME .
  END.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  define buffer buf_sys-ctrl     for ub.sys-ctrl .
  define variable v-attr-type as character no-undo .
  define variable v-log       as logical   no-undo .
  find first buf_sys-ctrl no-lock .
  if buf_sys-ctrl.db-num <> 0 then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Данная утилита может запускаться только в ГБД" ) skip
      view-as alert-box error
    .
    return error .
  end.
  find first buf_BatchProcess no-lock
    where buf_BatchProcess.BP_type = 'cutdbs':U
    no-error .
  if available buf_BatchProcess then do:
    run db-attr-value in this-procedure
      ( input 0
       ,input 'cut-db-list':U
       ,output v-db-list
       ,output v-attr-type
      ) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Ошибка при чтении значения атрибута 'Список БД для обрезания'" ) skip
        return-value skip
        error-status :get-message ( error-status :num-messages )
        view-as alert-box error
      .
      undo, return error .
    end.
    if v-db-list = "":U then do:
      message
        substitute( "Список БД для обрезания пуст!!!" ) skip
        view-as alert-box error
      .
      undo, return error .
    end.
    assign
      v-cut-run          = true
      type-cut           = "Усечение документов по БД"
      date-actual-docs   = date( buf_BatchProcess.CharKey_Two )
      date-actual-findoc = date( buf_BatchProcess.CharKey_Three )
      v-num-entries      = num-entries( v-db-list )
    .
    do v-ind = 1 to v-num-entries
    on error undo, return error
    :
      find first buf_db no-lock
        where buf_db.db-num = integer( entry( v-ind, v-db-list ) )
        .
      if sel-rid-list = "":U then do:
        assign
          sel-rid-list = string( recid( buf_db ) )
        .
      end.
      else do:
        assign
          sel-rid-list = sel-rid-list + chr(44) + string( recid( buf_db ) )
        .
      end.
    end.
  end.
  find first buf_sys-ctrl .
  if trim( buf_sys-ctrl.status_ ) = 'sttsDB-cutld':u then do:
    message
      substitute( "Предыдущая попытка запуска усечения не была завершена!" ) skip
      substitute( "Вы желаете повторить усечение?" ) skip
      view-as alert-box question buttons yes-no update v-log.
    if v-log <> true then do:
      do transaction
      on error undo, return error return-value
      on stop  undo, return error return-value
      :
        find first buf_sys-ctrl exclusive-lock .
        assign
          buf_sys-ctrl.status_ = "":U
        .
        release buf_sys-ctrl.
      end.
      QUIT .
    end.
  end.
  run scan-ready in this-procedure
    ( input  v-db-list
     ,input  date-actual-docs
     ,input  date-actual-findoc
     ,output answ-rid-list
     ,output v-not-answer-db-list
    ).
  RUN enable_UI.
  assign
    ret-err = FALSE
  .
  apply "value-changed" to type-cut in frame DEFAULT-FRAME.
  create alias src for database ub .
  create alias ubfltsrc for database ub .
  create alias ubfltdst for database dst .
  IF NOT THIS-PROCEDURE:PERSISTENT THEN
    WAIT-FOR CLOSE OF THIS-PROCEDURE.
  QUIT .
END.
PROCEDURE callback-write-to-log :
  define input parameter p-msg-str as character no-undo .
  define variable lok as logical   no-undo .
  do with frame DEFAULT-FRAME
  on error undo, return error return-value
  :
    assign
      lok = log-edit :move-to-eof( )
      lok = log-edit :insert-string( p-msg-str )
      lok = log-edit :move-to-eof( )
    .
  end.
END PROCEDURE.
PROCEDURE disable_UI :
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(cut-load)
  THEN DELETE WIDGET cut-load.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY type-cut stay-weight-goods not-copy-del-goods stay-recipe-goods
          date-actual-goods date-actual-docs date-output-zone stay-history
          log-edit mark-num
      WITH FRAME DEFAULT-FRAME IN WINDOW cut-load.
  ENABLE RECT-1 RECT-2 b-exit b-quit type-cut stay-weight-goods b-mark
         b-refresh not-copy-del-goods br_db stay-recipe-goods date-actual-goods
         date-actual-docs date-output-zone stay-history log-edit
      WITH FRAME DEFAULT-FRAME IN WINDOW cut-load.
  VIEW FRAME DEFAULT-FRAME IN WINDOW cut-load.
  OPEN QUERY br_db FOR EACH ub.db NO-LOCK.
  VIEW cut-load.
END PROCEDURE.
PROCEDURE scan-ready :
  define input  parameter p-db-list            as character no-undo.
  define input  parameter p-cut-date           as date      no-undo .
  define input  parameter p-cut-fin-date       as date      no-undo .
  define output parameter p-ready-db-rid-list  as character no-undo .
  define output parameter p-not-answer-db-list as character no-undo .
  define variable v-db-num          as integer   no-undo .
  define variable v-attr-exist      as logical   no-undo .
  define variable v-cut-date        as character no-undo .
  define variable v-attr-fin-exist  as logical   no-undo .
  define variable v-cut-fin-date    as character no-undo .
  define variable v-attr-type       as character no-undo .
  assign
    v-num-entries        = num-entries( p-db-list )
    p-not-answer-db-list = "":U
    p-ready-db-rid-list  = "":U
  .
  do v-ind = 1 to v-num-entries
  on error undo, return no-apply
  :
    assign
      v-db-num = integer( entry( v-ind, p-db-list ) )
    .
    find first buf_db no-lock
      where buf_db.db-num = v-db-num
      .
    run db-attr-exist ( input v-db-num
                       ,input 'cut-date':U
                       ,output v-attr-exist
                      ) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Ошибка при определении наличия атрибута 'дата обрезания' для БД &1", v-db-num ) skip
        return-value skip
        error-status :get-message ( error-status :num-messages )
        view-as alert-box error
      .
      return no-apply.
    end.
    run db-attr-value ( input v-db-num
                       ,input 'cut-date':U
                       ,output v-cut-date
                       ,output v-attr-type
                      ) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Ошибка при чтении значения атрибута 'дата обрезания' для БД &1", v-db-num ) skip
        return-value skip
        error-status :get-message ( error-status :num-messages )
        view-as alert-box error
      .
      return no-apply.
    end.
    run db-attr-exist ( input v-db-num
                       ,input 'cut-fin-date':U
                       ,output v-attr-fin-exist
                      ) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Ошибка при определении наличия атрибута 'дата обрезания фин.документов' для БД &1", v-db-num ) skip
        return-value skip
        error-status :get-message ( error-status :num-messages )
        view-as alert-box error
      .
      return no-apply.
    end.
    run db-attr-value ( input v-db-num
                       ,input 'cut-fin-date':U
                       ,output v-cut-fin-date
                       ,output v-attr-type
                      ) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Ошибка при чтении значения атрибута 'дата обрезания фин.документов' для БД &1", v-db-num ) skip
        return-value skip
        error-status :get-message ( error-status :num-messages )
        view-as alert-box error
      .
      return no-apply.
    end.
    if v-attr-exist <> true
      or date( v-cut-date ) <> p-cut-date
      or v-attr-fin-exist <> true
      or date( v-cut-fin-date ) <> p-cut-fin-date
    then do:
      if p-not-answer-db-list = "":U then do:
        assign
          p-not-answer-db-list = string( v-db-num )
        .
      end.
      else do:
        assign
          p-not-answer-db-list = p-not-answer-db-list + chr(44) + string( v-db-num )
        .
      end.
    end.
    else do:
      if p-ready-db-rid-list = "":U then do:
        assign
          p-ready-db-rid-list = string( recid( buf_db ) )
        .
      end.
      else do:
        assign
          p-ready-db-rid-list = p-ready-db-rid-list + chr(44) + string( recid( buf_db ) )
        .
      end.
    end.
  end.
END PROCEDURE.
