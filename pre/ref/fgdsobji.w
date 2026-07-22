DEFINE BUFFER buf_clients FOR ub.clients.
DEFINE BUFFER buf_goods FOR ub.goods.
DEFINE BUFFER loc_fbr-gds-obj FOR ub.fbr-gds-obj.
DEFINE TEMP-TABLE tt-fbr-gds-obj NO-UNDO LIKE ub.fbr-gds-obj.
DEFINE TEMP-TABLE tt0-fbr-gds-obj NO-UNDO LIKE ub.fbr-gds-obj.
define input parameter parparentproc as widget-handle no-undo .
define input parameter par-mode as character no-undo.
define input parameter p-gds-code like ub.fbr-gds-obj.gds-code no-undo.
define input parameter p-obj-type like ub.fbr-gds-obj.obj-type no-undo.
define input parameter p-obj-code like ub.fbr-gds-obj.obj-code no-undo.
define input parameter p-update-instantly as logical no-undo .
define input-output parameter p-template as character    no-undo.
define output parameter p-updated AS LOGICAL no-undo.
define input-output parameter par-recid as recid no-undo.
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Атрибуты товара на объекте- РЕСТОРАН".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
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
define  temp-table temp-host no-undo
  field host-code like ub.store.host-code
  index xpk host-code
.
define  temp-table temp-obj no-undo
  field obj-type  like ub.clients.obj-type
  field obj-code  like ub.clients.obj-code
  field host-code like ub.store.host-code
  field db-num    like ub.clients.db-num
  index xpk  obj-type obj-code
  index xie1 host-code
  index xie2 db-num host-code
.
procedure init-temphost:
  define buffer buf_store   for ub.store .
  define buffer buf_shop    for ub.shop .
  define buffer buf_clients for ub.clients .
  define buffer buf_db for ub.db .
  define buffer buf_temp-host for temp-host .
  define buffer buf_temp-obj for temp-obj .
  do
  on error undo, return error return-value
  :
    for each buf_store
    on error undo, return error
    :
      find first buf_temp-host
        where buf_temp-host.host-code = buf_store.host-code
        no-error .
      if not available buf_temp-host
      then do:
        create buf_temp-host .
        assign
          buf_temp-host.host-code = buf_store.host-code
        .
      end.
      find first buf_clients no-lock
        where buf_clients.obj-type = 'скл':U
          and buf_clients.obj-code = buf_store.obj-code
        no-error .
      if not available buf_clients
      then do:
        message
          "Ошибка при поиске клиента" skip
          "Клиент" 'скл':U buf_store.obj-code skip
          view-as alert-box error .
        undo, return error .
      end.
      create buf_temp-obj .
      assign
        buf_temp-obj.obj-type  = 'скл':U
        buf_temp-obj.obj-code  = buf_store.obj-code
        buf_temp-obj.host-code = buf_store.host-code
        buf_temp-obj.db-num    = buf_clients.db-num
      .
    end.
    for each buf_shop
    on error undo, return error
    :
      find first buf_temp-host
        where buf_temp-host.host-code = buf_shop.host-code
        no-error .
      if not available buf_temp-host
      then do:
        create buf_temp-host .
        assign
          buf_temp-host.host-code = buf_shop.host-code
        .
      end.
      find first buf_clients no-lock
        where buf_clients.obj-type = 'маг':U
          and buf_clients.obj-code = buf_shop.obj-code
        no-error .
      if not available buf_clients then do:
        message
          "Ошибка при поиске клиента" skip
          "Клиент" 'маг':U buf_shop.obj-code skip
          view-as alert-box error .
        undo, return error .
      end.
      create buf_temp-obj .
      assign
        buf_temp-obj.obj-type  = 'маг':U
        buf_temp-obj.obj-code  = buf_shop.obj-code
        buf_temp-obj.host-code = buf_shop.host-code
        buf_temp-obj.db-num    = buf_clients.db-num
      .
    end.
  end.
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION title-mode RETURNS CHARACTER
  ( INPUT pmode as character ) :
DEFINE VARIABLE ptitle-mode as character no-undo.
CASE ENTRY(1, pmode) :
  when 'ДОБАВЛЕНИЕ':U then ptitle-mode = "ДОБАВЛЕНИЕ".
  when 'ИЗМЕНЕНИЕ':U  then ptitle-mode = "ИЗМЕНЕНИЕ".
  when 'ПРОСМОТР':U  then ptitle-mode = "ПРОСМОТР".
END CASE.
  RETURN ptitle-mode.
END FUNCTION.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table userobjs_temp-user-obj no-undo
  field obj-type as character
  field obj-code as integer
  index xpk is primary unique obj-type obj-code
  .
procedure userobjs_clear :
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      delete buf_userobjs_temp-user-obj .
    end.
  end.
end .
procedure userobjs_object-count :
  define output parameter p-total-count as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    assign
      p-total-count = 0
    .
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      assign
        p-total-count = p-total-count + 1
      .
    end.
  end.
end.
procedure userobjs_append :
   define input  parameter p-obj-type as character no-undo .
   define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      where buf_userobjs_temp-user-obj.obj-type = p-obj-type
        and buf_userobjs_temp-user-obj.obj-code = p-obj-code
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      create buf_userobjs_temp-user-obj .
      assign
        buf_userobjs_temp-user-obj.obj-type = p-obj-type
        buf_userobjs_temp-user-obj.obj-code = p-obj-code
      .
    end.
  end.
end.
procedure userobjs_object-exist :
  define output parameter p-object-exist as logical   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      assign
        p-object-exist = false
      .
    end.
    else do:
      assign
        p-object-exist = true
      .
    end.
  end.
end.
procedure userobjs_transfer :
  define input  parameter p-callback-handle as handle no-undo .
  define variable vss-description as character no-undo init "userobjs_transfer: Передача списка объектов".
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    if valid-handle(p-callback-handle) <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестный указатель на процедуру" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-callback-handle :get-signature("userobjs_append") = ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        substitute("В процедуре &1 не найдена внутренняя процедура userobjs_append"
                  ,p-callback-handle :file-name
                  ) skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      run userobjs_append in p-callback-handle
        (input  buf_userobjs_temp-user-obj.obj-type
        ,input  buf_userobjs_temp-user-obj.obj-code
        ) .
    end.
  end.
end procedure.
procedure userobjs_select-one :
   define input  parameter parparentproc     as widget-handle no-undo .
   define input  parameter p-db-num          as integer   no-undo .
   define input  parameter p-user-id         as character no-undo .
   define input  parameter p-host-code-obj   as integer   no-undo .
   define input  parameter p-obj-type        as character no-undo .
   define input  parameter p-obj-code        as integer   no-undo .
   define output parameter p-user-select     as logical   no-undo .
   define output parameter p-select-obj-type as character no-undo .
   define output parameter p-select-obj-code as character no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel"
      ,output p-user-select
      ,output p-select-obj-type
      ,output p-select-obj-code
      ) .
  end.
end.
procedure userobjs_select-many :
  define input  parameter parparentproc   as widget-handle no-undo .
  define input  parameter p-db-num        as integer   no-undo .
  define input  parameter p-user-id       as character no-undo .
  define input  parameter p-host-code-obj as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-user-select   as logical   no-undo .
  define variable v-select-obj-type as character no-undo .
  define variable v-select-obj-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel,b-mark"
      ,output p-user-select
      ,output v-select-obj-type
      ,output v-select-obj-code
      ) .
  end.
end.
procedure thobjs :
   define input        parameter parparentproc     as widget-handle no-undo .
   define input        parameter i-bttns           as character     no-undo .
   define input        parameter i-list-mode       as character     no-undo.
   define input        parameter i-obj-type        as character     no-undo.
   define input        parameter i-db-num          as integer       no-undo.
   define input        parameter i-host-code       as integer       no-undo.
   define input-output parameter p-rid-list        as character     no-undo .
run ref/thobjs.p
        ( input parparentproc
         ,input  this-procedure :handle
        , input i-bttns
        , input i-list-mode
        , input i-obj-type
        , input i-db-num
        , input i-host-code
        , input-output p-rid-list ) no-error .
end.
define variable v-db-num like ub.db.db-num no-undo.
define variable v-fbr-obj-type like ub.fbr-gds-obj.fbr-obj-type no-undo.
define variable v-fbr-obj-code like ub.fbr-gds-obj.fbr-obj-code no-undo.
define buffer X_fbr-gds-grp for ub.fbr-gds-grp.
define buffer X_clients for ub.clients.
function check-is-petrol returns logical
  (  ) forward.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-fbr-gds-grp
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE BUTTON B-fbr-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE EDITOR-fbr AS CHARACTER
     VIEW-AS EDITOR
     SIZE 85 BY 3.04
     BGCOLOR 15 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-fbr-grp-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 45 BY 1 NO-UNDO.
DEFINE VARIABLE F-out-code LIKE ub.fbr-gds-grp.out-code
     LABEL "Код группы меню(на кассе)"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE fbr-obj-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 45 BY 1 NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      tt-fbr-gds-obj SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-hist AT ROW 1 COL 51
     B-Help AT ROW 1 COL 61
     B-fbr-gds-grp AT ROW 2.21 COL 27.63
     F-out-code AT ROW 2.25 COL 13.5 COLON-ALIGNED
          LABEL "Группа меню" FORMAT ">>9"
     f-fbr-grp-name AT ROW 2.25 COL 30 COLON-ALIGNED NO-LABEL
     tt-fbr-gds-obj.fbr-obj-code AT ROW 3.42 COL 13.5 COLON-ALIGNED
          LABEL "Кухня"
          VIEW-AS FILL-IN
          SIZE 7 BY 1
     tt-fbr-gds-obj.fbr-obj-type AT ROW 3.42 COL 21 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     B-fbr-obj AT ROW 3.42 COL 27.63
     fbr-obj-name AT ROW 3.42 COL 29.75 COLON-ALIGNED NO-LABEL
     EDITOR-fbr AT ROW 4.75 COL 2 NO-LABEL
     tt-fbr-gds-obj.is-cd AT ROW 8.13 COL 44
          LABEL "Отправлять на кассу РЕСТОРАНА"
          VIEW-AS TOGGLE-BOX
          SIZE 40 BY 1
     tt-fbr-gds-obj.is-menu AT ROW 8.17 COL 1.25
          LABEL "Является блюдом меню"
          VIEW-AS TOGGLE-BOX
          SIZE 40 BY 1
     tt-fbr-gds-obj.is-semi-finished AT ROW 9.38 COL 1.25
          LABEL "Является полуфабрикатом"
          VIEW-AS TOGGLE-BOX
          SIZE 40 BY 1
     tt-fbr-gds-obj.is-season AT ROW 10.58 COL 1.25
          LABEL "Применять сезонный коэффициент"
          VIEW-AS TOGGLE-BOX
          SIZE 40 BY 1
     tt-fbr-gds-obj.is-modificator AT ROW 11.79 COL 1.25
          LABEL "Модификатор блюда"
          VIEW-AS TOGGLE-BOX
          SIZE 40 BY 1
     tt-fbr-gds-obj.is-null-price AT ROW 13 COL 1.25
          LABEL "Без цены"
          VIEW-AS TOGGLE-BOX
          SIZE 40 BY 1
     SPACE(46.12) SKIP(0.32)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Атрибуты товара - РЕСТОРАН"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       EDITOR-fbr:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  run proc-save in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-fbr-gds-grp IN FRAME Dialog-Frame
DO:
define variable v-recid-list    as character      no-undo.
define buffer buf_fbr-gds-grp for ub.fbr-gds-grp.
find first buf_fbr-gds-grp where
          buf_fbr-gds-grp.node-code = tt-fbr-gds-obj.fbr-grp-code
     AND  buf_fbr-gds-grp.OBJ-TYPE = tt-fbr-gds-obj.obj-type
     and  buf_fbr-gds-grp.obj-code = tt-fbr-gds-obj.obj-code no-error .
if available buf_fbr-gds-grp then do:
  assign
  v-recid-list = string(recid(buf_fbr-gds-grp))
  .
end.
    run ref/fbrggrp.w (
          input parparentproc
        , input p-obj-type
        , input p-obj-code
        , input "b-sel"
        , input-output v-recid-list
    ).
    if v-recid-list <> ""
    then do:
        find first buf_fbr-gds-grp no-lock
             where recid( buf_fbr-gds-grp )  = integer( entry( 1, v-recid-list ) )
        no-error.
        if not available buf_fbr-gds-grp
        then do:
            return no-apply.
        end.
        assign
            f-fbr-grp-name:screen-value = buf_fbr-gds-grp.node-name
            tt-fbr-gds-obj.fbr-grp-code = buf_fbr-gds-grp.node-code
            f-out-code = buf_fbr-gds-grp.out-code
        .
        display
        f-out-code
        with frame Dialog-Frame.
    end.
END.
ON CHOOSE OF B-fbr-obj IN FRAME Dialog-Frame
DO:
def buffer buf_clients for ub.clients .
  define variable v-user-select as logical   no-undo .
  define variable v-host-code   as integer   no-undo .
  define variable v-obj-type    as character no-undo .
  define variable v-obj-code    as integer   no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-one in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-host-code
  ,input  p-obj-type
  ,input  p-obj-code
  ,output v-user-select
  ,output v-obj-type
  ,output v-obj-code
  )  .
  if v-user-select = true
  then do:
    find first buf_clients no-lock
      where buf_clients.obj-type = v-obj-type
        and buf_clients.obj-code = v-obj-code
      no-error .
    if not available buf_clients then do:
      return no-apply.
    end.
    assign
      fbr-obj-name:screen-value                = buf_clients.obj-name
      tt-fbr-gds-obj.fbr-obj-code:screen-value = string(buf_clients.obj-code)
      tt-fbr-gds-obj.fbr-obj-type:screen-value = string(buf_clients.obj-type)
    .
        run fbr-warning in this-procedure (tt-fbr-gds-obj.fbr-obj-type:screen-value, tt-fbr-gds-obj.fbr-obj-code:screen-value) no-error.
  end.
END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
DO:
define variable v-rid-list as character no-undo.
  if available loc_fbr-gds-obj then
  run ref/cfgdsobs.w (
                                input parparentproc
                              , input "":U
                              , input "one":U
                              , input p-obj-type
                              , input p-obj-code
                              , input p-gds-code
                             , output v-rid-list ) no-error.
END.
ON LEAVE OF F-out-code IN FRAME Dialog-Frame
DO:
     define buffer buf_fbr-gds-grp for ub.fbr-gds-grp.
   define buffer buf_clients     for ub.clients.
   find first buf_clients no-lock
        where buf_clients.obj-type = p-obj-type
          and buf_clients.obj-code = p-obj-code
   .
  find first buf_fbr-gds-grp no-lock where
             buf_fbr-gds-grp.obj-type  = p-obj-type
         AND buf_fbr-gds-grp.obj-code  = p-obj-code
         AND buf_fbr-gds-grp.out-code = input frame Dialog-Frame  f-out-code
  no-error.
  if available buf_fbr-gds-grp then do:
    assign
    f-out-code
    tt-fbr-gds-obj.fbr-grp-code = buf_fbr-gds-grp.node-code
    f-fbr-grp-name = buf_fbr-gds-grp.node-name.
  end.
  else do:
      assign
    tt-fbr-gds-obj.fbr-grp-code = 0
    f-fbr-grp-name = "":U
    f-out-code = ?
    .
  end.
    display
    f-out-code
    f-fbr-grp-name
    with frame Dialog-Frame.
END.
ON LEAVE OF tt-fbr-gds-obj.fbr-obj-code IN FRAME Dialog-Frame
DO:
 define buffer buf_shop for ub.shop.
  define buffer buf_clients for ub.clients.
  find first buf_shop no-lock where
                buf_shop.obj-code = input frame Dialog-Frame tt-fbr-gds-obj.fbr-obj-code no-error.
  if available buf_shop then do:
    find first buf_clients no-lock where
                buf_clients.obj-type = 'маг':U
           AND buf_clients.obj-code = buf_shop.obj-code .
    assign
    tt-fbr-gds-obj.fbr-obj-code
    tt-fbr-gds-obj.fbr-obj-type = 'маг':U
    fbr-obj-name = buf_clients.obj-name.
    display
   tt-fbr-gds-obj.fbr-obj-code
    tt-fbr-gds-obj.fbr-obj-type
    fbr-obj-name
    with frame Dialog-Frame.
       run fbr-warning in this-procedure (tt-fbr-gds-obj.fbr-obj-type:screen-value, tt-fbr-gds-obj.fbr-obj-code:screen-value) no-error.
  end.
  else do:
      assign
        tt-fbr-gds-obj.fbr-obj-code = 0
        tt-fbr-gds-obj.fbr-obj-type = "":U
        fbr-obj-name = "":U.
        run fbr-warning in this-procedure (tt-fbr-gds-obj.fbr-obj-type:screen-value, tt-fbr-gds-obj.fbr-obj-code:screen-value) no-error.
      if int(tt-fbr-gds-obj.fbr-obj-code:screen-value) > 0 then return no-apply.
      else tt-fbr-gds-obj.fbr-obj-type:screen-value = ''.
  end.
END.
ON LEAVE OF tt-fbr-gds-obj.fbr-obj-type IN FRAME Dialog-Frame
DO:
    run fbr-warning in this-procedure (self:screen-value, tt-fbr-gds-obj.fbr-obj-code:screen-value) no-error.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if check-is-petrol() then do:
      message "Запрещено для топливных товаров"
      view-as alert-box ERROR.
      return error.
  end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if par-mode <> 'ИЗМЕНЕНИЕ':U
  and par-mode <> 'ДОБАВЛЕНИЕ':U
  and par-mode <> 'ПРОСМОТР':U
  and par-mode <> 'template':U
  then do:
    message
    vss-workfile vss-revision vss-description skip
     "Неверный параметр вызова par-mode"
    view-as alert-box ERROR.
    return error.
  end.
  if par-mode <> 'ДОБАВЛЕНИЕ':U then do:
    find first buf_goods no-lock where
               buf_goods.gds-code = p-gds-code no-error.
        if not available buf_goods
        and par-mode <> 'template':U
        then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверный параметр вызова p-gds-code" p-gds-code
        view-as alert-box ERROR.
        return error.
        end.
  end.
    find first buf_clients no-lock where
                    buf_clients.obj-type = p-obj-type
                AND buf_clients.obj-code = p-obj-code.
        if not available buf_clients
        or (buf_clients.obj-type <> 'маг':U and buf_clients.obj-type <> 'скл':U)
        then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверные параметры вызова p-obj-type и/или p-obj-code" p-obj-type p-obj-code
        view-as alert-box ERROR.
        return error.
    end.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
    if par-mode <> 'ПРОСМОТР':U and
    buf_clients.db-num <> v-db-num then do:
        message
        vss-workfile vss-revision vss-description skip
        "Нельзя редактировать атрибуты товара на объекте-РЕСТОРАН для объекта чужой БД"
        view-as alert-box error.
        return error.
    end.
    case PAR-MODE:
        WHEN 'ИЗМЕНЕНИЕ':U THEN DO:
           do transaction:
            find first loc_fbr-gds-obj exclusive-lock where
                        loc_fbr-gds-obj.gds-code = p-gds-code
                    AND loc_fbr-gds-obj.obj-type = p-obj-type
                    AND loc_fbr-gds-obj.obj-code = p-obj-code no-wait no-error.
            if not available loc_fbr-gds-obj then do:
                if locked loc_fbr-gds-obj then do:
                    message
                    "Запись атрибутов товара на объекте-РЕСТОРАН занята"
                    view-as alerT-box error.
                    return error.
                end.
                else do:
                end.
            end.
            assign
            par-recid = recid(loc_fbr-gds-obj)
            .
          end.
        END.
        when 'ПРОСМОТР':U then do:
        find first loc_fbr-gds-obj no-lock where
                loc_fbr-gds-obj.gds-code = p-gds-code
            AND loc_fbr-gds-obj.obj-type = p-obj-type
            AND loc_fbr-gds-obj.obj-code = p-obj-code no-error.
        end.
        when 'template':U
        then do:
            if p-gds-code <> 0
            then do:
                find first loc_fbr-gds-obj no-lock
                     where loc_fbr-gds-obj.gds-code = p-gds-code
                       and loc_fbr-gds-obj.obj-type = p-obj-type
                       and loc_fbr-gds-obj.obj-code = p-obj-code
                no-error.
            end.
        end.
    end CASE.
    run fill-tables in this-procedure .
    RUN MyEnable.
    if par-mode = 'template':U
    then do:
        hide
            b-hist
            f-out-code
            b-fbr-gds-grp
        in FRAME Dialog-Frame.
        assign
            frame Dialog-Frame:title = "Выбор атрибутов для группы товаров"
        .
    end.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-fbr-gds-obj SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY F-out-code f-fbr-grp-name fbr-obj-name EDITOR-fbr
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-fbr-gds-obj THEN
    DISPLAY tt-fbr-gds-obj.fbr-obj-code tt-fbr-gds-obj.fbr-obj-type
          tt-fbr-gds-obj.is-cd tt-fbr-gds-obj.is-menu
          tt-fbr-gds-obj.is-semi-finished tt-fbr-gds-obj.is-season
          tt-fbr-gds-obj.is-modificator tt-fbr-gds-obj.is-null-price
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-hist B-Help B-fbr-gds-grp F-out-code
         tt-fbr-gds-obj.fbr-obj-code tt-fbr-gds-obj.fbr-obj-type B-fbr-obj
         tt-fbr-gds-obj.is-cd tt-fbr-gds-obj.is-menu
         tt-fbr-gds-obj.is-semi-finished tt-fbr-gds-obj.is-season
         tt-fbr-gds-obj.is-modificator tt-fbr-gds-obj.is-null-price
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE fbr-warning :
define input parameter p-fbr-obj-type-new like ub.fbr-gds-obj.fbr-obj-type no-undo.
define input parameter p-fbr-obj-code-new like ub.fbr-gds-obj.fbr-obj-code no-undo.
if p-fbr-obj-type-new <> v-fbr-obj-type
OR p-fbr-obj-code-new <> v-fbr-obj-code then do:
    assign
    Editor-fbr = "ВНИМАНИЕ!" + chr(10) +
                 "Смена КУХНИ для товара повлечет за собой смену КУХНИ для данного товара в атрибутах <РЕСТОРАН> на ВСЕХ объектах текущей БД," +
                 chr(10) +
                 "однако не влечет за собой смену КУХНИ для товара в ПЛАН-МЕНЮ!!!"
                 .
    display
    editor-fbr
    with frame Dialog-Frame.
end.
else do:
    hide
    editor-fbr
    in frame Dialog-Frame.
end.
END PROCEDURE.
PROCEDURE fill-tables :
define buffer buf0_fbr-gds-grp for ub.fbr-gds-grp.
define buffer bf_fbr-gds-grp for ub.fbr-gds-grp.
define variable v-node-code like ub.fbr-gds-grp.node-code no-undo .
define variable ii as integer no-undo .
for each tt-fbr-gds-obj:
  delete tt-fbr-gds-obj.
end.
if par-mode = 'ДОБАВЛЕНИЕ':U
or (par-mode = 'ИЗМЕНЕНИЕ':U and not available loc_fbr-gds-obj ) then do:
  if par-mode <> 'ДОБАВЛЕНИЕ':U then do:
    if buf_goods.fbr-grp-code <> ? then do:
      find first buf0_fbr-gds-grp no-lock where
                buf0_fbr-gds-grp.obj-type = "":U
            AND buf0_fbr-gds-grp.obj-code = 0
            AND buf0_fbr-gds-grp.node-code = buf_goods.fbr-grp-code no-error .
      if available buf0_fbr-gds-grp then do:
        for each bf_fbr-gds-grp no-lock where
                bf_fbr-gds-grp.global-code = buf0_fbr-gds-grp.global-code
            AND bf_fbr-gds-grp.obj-type = p-obj-type
            AND bf_fbr-gds-grp.obj-code = p-obj-code:
          assign
          v-node-code = bf_fbr-gds-grp.node-code
          ii = ii + 1
          .
        end.
        if ii = 1 then do:
          find first X_fbr-gds-grp no-lock where
                    X_fbr-gds-grp.obj-type = p-obj-type
                AND X_fbr-gds-grp.obj-code = p-obj-code
                AND  X_fbr-gds-grp.node-code = v-node-code no-error .
        end.
      end.
    end.
  end.
end.
create tt-fbr-gds-obj.
case par-mode:
  when 'ДОБАВЛЕНИЕ':U then do:
    assign
    tt-FBR-gds-obj.gds-code = p-gds-code
    tt-FBR-gds-obj.obj-type = p-obj-type
    tt-FBR-gds-obj.obj-code = p-obj-code
    tt-fbr-gds-obj.fbr-grp-code = v-node-code
    .
  end.
  otherwise do:
    if available loc_fbr-gds-obj then do:
      buffer-copy loc_fbr-gds-obj to TT-fbr-gds-OBJ.
    end.
    else do:
      assign
      tt-FBR-gds-obj.gds-code = p-gds-code
      tt-FBR-gds-obj.obj-type = p-obj-type
      tt-FBR-gds-obj.obj-code = p-obj-code
      tt-fbr-gds-obj.fbr-grp-code = v-node-code
      .
    end.
    create tt0-fbr-gds-obj.
    buffer-copy tt-fbr-gds-obj to TT0-fbr-gds-OBJ.
  end.
END CASE.
if p-template <> "":U then do:
  assign
  tt-fbr-gds-obj.is-cd   = logical(entry(1, p-template))
  tt-fbr-gds-obj.is-menu = logical(entry(2, p-template))
  tt-fbr-gds-obj.is-modificator = logical(entry(3, p-template))
  tt-fbr-gds-obj.is-null-price = logical(entry(4, p-template))
  tt-fbr-gds-obj.is-season     = logical(entry(5, p-template))
  tt-fbr-gds-obj.is-semi-finished  = logical(entry(6, p-template))
  tt-fbr-gds-obj.fbr-obj-type      = entry(7, p-template)
  tt-fbr-gds-obj.fbr-obj-code      = integer(entry(8, p-template))
  tt-fbr-gds-obj.fbr-grp-code      = integer(entry(9, p-template))
  .
end.
END PROCEDURE.
PROCEDURE MyEnable :
define buffer other_kitchen for ub.fbr-gds-obj.
define buffer buf_shop for ub.shop.
run init-temphost in this-procedure .
find first buf_shop no-lock where
          buf_shop.obj-code = p-obj-code no-error.
if not avail loc_fbr-gds-obj then do:
  _temp-obj:
  for each temp-obj no-lock where
           temp-obj.db-num = v-db-num,
      first other_kitchen no-lock where
            other_kitchen.gds-code = p-gds-code
        AND other_kitchen.obj-type = temp-obj.obj-type
        AND other_kitchen.obj-code = temp-obj.obj-code
            :
    assign
    tt-fbr-gds-obj.fbr-obj-type = other_kitchen.fbr-obj-type
    tt-fbr-gds-obj.fbr-obj-code = other_kitchen.fbr-obj-code
    .
    find first X_clients no-lock where
              X_clients.obj-type = tt-fbr-gds-obj.fbr-obj-type
          AND X_clients.obj-code = tt-fbr-gds-obj.fbr-obj-code no-error .
    leave _temp-obj.
  end.
  assign
  frame Dialog-Frame:title = frame Dialog-Frame:title + chr(32)  + title-mode('ДОБАВЛЕНИЕ':U).
end.
else do :
  find first X_fbr-gds-grp no-lock where
             X_fbr-gds-grp.obj-type = p-obj-type
         AND X_fbr-gds-grp.obj-code = p-obj-code
         AND  X_fbr-gds-grp.node-code = tt-fbr-gds-obj.fbr-grp-code no-error .
  find first X_clients no-lock where
             X_clients.obj-type = tt-fbr-gds-obj.fbr-obj-type
        AND X_clients.obj-code = tt-fbr-gds-obj.fbr-obj-code no-error .
  assign
  frame Dialog-Frame:title = frame Dialog-Frame:title + chr(32)  + title-mode(par-mode).
end.
assign
v-fbr-obj-type = tt-fbr-gds-obj.fbr-obj-type
v-fbr-obj-code= tt-fbr-gds-obj.fbr-obj-code
.
  IF AVAILABLE tt-fbr-gds-obj THEN
    DISPLAY
    (if avail X_clients then X_clients.obj-name else "":U) @ fbr-obj-name
    tt-fbr-gds-obj.fbr-obj-type
    tt-fbr-gds-obj.fbr-obj-code
    tt-fbr-gds-obj.is-cd
    tt-fbr-gds-obj.is-menu
    tt-fbr-gds-obj.is-modificator
    tt-fbr-gds-obj.is-null-price
    tt-fbr-gds-obj.is-season
    tt-fbr-gds-obj.is-semi-finished
    WITH FRAME Dialog-Frame.
   DISPLAY
  (if avail X_fbr-gds-grp then X_fbr-gds-grp.node-name else "":U) @ f-fbr-grp-name
  (if avail X_fbr-gds-grp then X_fbr-gds-grp.out-code else ?) @ f-out-code
  WITH FRAME Dialog-Frame.
  ENABLE
  b-quit
  B-exit
  b-hist when available loc_fbr-gds-obj
  B-Help
  f-out-code when par-mode <> 'ПРОСМОТР':U
  tt-fbr-gds-obj.fbr-obj-code when par-mode <> 'ПРОСМОТР':U
  tt-fbr-gds-obj.is-menu when par-mode <> 'ПРОСМОТР':U
  tt-fbr-gds-obj.is-modificator when par-mode <> 'ПРОСМОТР':U
  tt-fbr-gds-obj.is-null-price when par-mode <> 'ПРОСМОТР':U
  tt-fbr-gds-obj.is-cd when (par-mode <> 'ПРОСМОТР':U
                        and
                      ((not buf_shop.is-kitchen and not buf_shop.is-kitchen-store )
                        or buf_shop.is-catering
                      )
                     )
  tt-fbr-gds-obj.is-season when par-mode <> 'ПРОСМОТР':U
  tt-fbr-gds-obj.is-semi-finished when par-mode <> 'ПРОСМОТР':U
  b-fbr-gds-grp when par-mode <> 'ПРОСМОТР':U
  b-fbr-obj when (par-mode <> 'ПРОСМОТР':U
                        and
                      ((not buf_shop.is-kitchen and not buf_shop.is-kitchen-store )
                        or buf_shop.is-catering
                      )
                     )
  WITH FRAME Dialog-Frame.
  IF PAR-MODE = 'ПРОСМОТР':U THEN DO:
    ASSIGN
    B-QUIT:LABEL = "&Выход"
    .
    hide
    b-exit in frame Dialog-Frame.
  END.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-save :
define variable v-ident as logical no-undo .
define buffer buf_fbr-gds-grp for ub.fbr-gds-grp.
define buffer buf_inkas for ub.inkas .
define buffer buf_bar-code for ub.bar-code .
define buffer buf_chk-gds for ub.chk-gds .
assign
tt-fbr-gds-obj.is-cd                frame Dialog-Frame
tt-fbr-gds-obj.is-menu
tt-fbr-gds-obj.is-season
tt-fbr-gds-obj.is-semi-finished
f-out-code
tt-fbr-gds-obj.fbr-obj-code
tt-fbr-gds-obj.fbr-obj-type
tt-fbr-gds-obj.is-modificator
tt-fbr-gds-obj.is-null-price
.
if f-out-code = ? then do:
  assign
  tt-fbr-gds-obj.fbr-grp-code = 0
  .
end.
else do:
  find buf_fbr-gds-grp no-lock where
            buf_fbr-gds-grp.obj-type = p-obj-type
      AND  buf_fbr-gds-grp.obj-code = p-obj-code
      AND buf_fbr-gds-grp.out-code = f-out-code no-error .
  if not avail buf_fbr-gds-grp then do:
    if  AMBIGUOUS buf_fbr-gds-grp then do:
      message
      "Неверный код группы меню" skip
      "Есть более одной группы мен. с кодом на кассе равным"  f-out-code
      view-as alert-box error .
      return error .
    end.
    else do:
      message
      "Неверный код группы меню"
      view-as alert-box error .
      return error .
    end.
  end.
end.
for each buf_bar-code no-lock where buf_bar-code.gds-code = buf_goods.gds-code,
first buf_chk-gds no-lock where (buf_chk-gds.out-code = "" or buf_chk-gds.out-code = ?)
                            and buf_chk-gds.b-code = buf_bar-code.b-code
                            :
  message
    ("Есть неучтенный чек с этим товаром " + string(buf_chk-gds.doc-code) + chr(10) +
     "Невозможно изменить атрибуты РЕСТОРАН на товаре. Сначала удалите неучтенный чек." + chr(10) +
     "После этого установите атрибуты РЕСТОРАН на товаре и заново примите чек с кассы.")
  view-as alert-box error .
  return error .
end .
for each buf_inkas no-lock where buf_inkas.obj-type = v-cntxt-obj-type
                             and buf_inkas.obj-code = v-cntxt-obj-code
                             and buf_inkas.status_ <> 'факт':U,
each buf_bar-code no-lock where buf_bar-code.gds-code = buf_goods.gds-code,
first buf_chk-gds no-lock where buf_chk-gds.out-code = buf_inkas.inkas-code
                            and buf_chk-gds.b-code = buf_bar-code.b-code
                            :
  message
    ("Есть незакрытая продажа " + string(buf_inkas.inkas-code) +
     " с этим товаром. Чек " + string(buf_chk-gds.doc-code) + chr(10) +
     "Невозможно изменить атрибуты РЕСТОРАН на товаре. Сначала исключите чек из незакрытой продажи и удалите его." + chr(10) +
     "После этого установите атрибуты РЕСТОРАН на товаре и заново примите чек с кассы.")
  view-as alert-box error .
  return error .
end .
if available tt-fbr-gds-obj
then do:
    assign
        p-template = substitute( "&2&1&3&1&4&1&5&1&6&1&7"
                        , chr(44)
                        , tt-fbr-gds-obj.is-cd
                        , tt-fbr-gds-obj.is-menu
                        , tt-fbr-gds-obj.is-modificator
                        , tt-fbr-gds-obj.is-null-price
                        , tt-fbr-gds-obj.is-season
                        , tt-fbr-gds-obj.is-semi-finished
                                )
    .
    assign
        p-template = p-template
                    + substitute( "&1&2&1&3&1&4"
                        , chr(44)
                        , tt-fbr-gds-obj.fbr-obj-type
                        , tt-fbr-gds-obj.fbr-obj-code
                        , tt-fbr-gds-obj.fbr-grp-code
                    )
    .
    if par-mode <> 'template':U
    then do:
      if p-update-instantly then do:
        run ref/fgdsobj1.p (
                            input-output par-recid
                        , input (if available loc_fbr-gds-obj
                                    then 'ИЗМЕНЕНИЕ':U
                                    else 'ДОБАВЛЕНИЕ':U)
                        , input no
                        , input p-gds-code
                        , input p-obj-type
                        , input p-obj-code
                        , input tt-fbr-gds-obj.fbr-grp-code
                        , input tt-fbr-gds-obj.fbr-obj-type
                        , input tt-fbr-gds-obj.fbr-obj-code
                        , input tt-fbr-gds-obj.is-cd
                        , input tt-fbr-gds-obj.is-menu
                        , input tt-fbr-gds-obj.is-modificator
                        , input tt-fbr-gds-obj.is-null-price
                        , input tt-fbr-gds-obj.is-season
                        , input tt-fbr-gds-obj.is-semi-finished
                        ) no-error.
        if error-status:error then do:
          if return-value <> '' then do:
            define variable v-rv as character no-undo .
            v-rv = return-value .
            entry(1, v-rv, chr(10)) = ''.
            message
            left-trim(v-rv, chr(10))
            view-as alert-box error.
          end.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable rv as character no-undo .
assign
rv = entry(1, return-value , chr(4)).
if rv <> "":U then do:
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = rv then do:
      APPLY "ENTRY" to hh.
      undo ,
      return error.
    end.
    hh = hh:next-sibling.
  end.
end.
           undo, return error.
        end.
      end.
      else do:
        if par-mode = 'ДОБАВЛЕНИЕ':U then do:
          p-updated = yes.
        end.
        else do:
          buffer-compare tt0-fbr-gds-obj
          to
          tt-fbr-gds-obj
          case-sensitive
          save result in v-ident.
          assign
          p-updated = not v-ident.
        end.
      end.
    end.
end.
END PROCEDURE.
function check-is-petrol returns logical
  (  ):
define variable v-is-petrolium as logical no-undo .
define variable v-is-pieces as logical no-undo .
define buffer lc_goods for ub.goods.
find first lc_goods no-lock where lc_goods.gds-code = p-gds-code.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input lc_goods.artic
  ,  input lc_goods.prod-type
  ,  input lc_goods.prod-code
  , output v-is-petrolium
  , output v-is-pieces
  ) .
return v-is-petrolium.
end function.
