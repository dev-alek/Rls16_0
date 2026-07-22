define input  parameter parparentproc as handle no-undo .
define input  parameter p-mode as character no-undo .
define input  parameter p-db-num  as integer   no-undo .
define input  parameter p-id     as integer   no-undo .
define input  parameter p-name as character no-undo .
define input-output parameter p-recid as recid no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Добавление и корректировка состава группы оборотов".
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
PROCEDURE oio-ADD :
define input  parameter p-db-num       as integer   no-undo .
define input  parameter p-id           as integer   no-undo .
define input  parameter p-ttg-summa    as decimal   no-undo .
define input  parameter p-use-discnt           as logical   no-undo .
define input  parameter p-discnt-pc            as decimal   no-undo .
define input  parameter p-discnt-method-round  as character no-undo .
define input  parameter p-stts         as integer   no-undo .
define input  parameter p-db-num-usr   as integer   no-undo .
define input  parameter p-userid       as character no-undo .
define output parameter p-recid as recid no-undo .
  do
  on error undo, return error return-value
  :
find first ub.tnv-in-turnover-group exclusive-lock where
        ub.tnv-in-turnover-group.tog-db-num   = p-db-num  and
        ub.tnv-in-turnover-group.tog-id       = p-id      and
        ub.tnv-in-turnover-group.ttg-summa    = p-ttg-summa
        no-error .
      if not available ub.tnv-in-turnover-group then do:
          create ub.tnv-in-turnover-group.
            assign
                ub.tnv-in-turnover-group.tog-db-num          = p-db-num
                ub.tnv-in-turnover-group.tog-id              = p-id
                ub.tnv-in-turnover-group.ttg-summa           = p-ttg-summa
                ub.tnv-in-turnover-group.use-discnt          = p-use-discnt
                ub.tnv-in-turnover-group.discnt-pc           = p-discnt-pc
                ub.tnv-in-turnover-group.discnt-method-round = p-discnt-method-round
            .
      end.
      assign
        ub.tnv-in-turnover-group.db-num-chg    = p-db-num-usr
        ub.tnv-in-turnover-group.stts          = p-stts
        ub.tnv-in-turnover-group.sys-date      = today
        ub.tnv-in-turnover-group.sys-time      = time
        ub.tnv-in-turnover-group.sys-time-chr  = string ( ub.tnv-in-turnover-group.sys-time,"hh:mm" )
        ub.tnv-in-turnover-group.who           = p-userid
        p-recid = recid ( ub.tnv-in-turnover-group )
      .
  end.
end procedure.
PROCEDURE oio-DEL :
define input  parameter p-db-num       as integer   no-undo .
define input  parameter p-id           as integer   no-undo .
define input  parameter p-ttg-summa     as decimal   no-undo .
define input  parameter p-db-num-usr   as integer   no-undo .
define input  parameter p-userid       as character no-undo .
  do
  on error undo, return error return-value
  :
find first ub.tnv-in-turnover-group exclusive-lock where
        ub.tnv-in-turnover-group.tog-db-num   = p-db-num  and
        ub.tnv-in-turnover-group.tog-id       = p-id      and
        ub.tnv-in-turnover-group.ttg-summa = p-ttg-summa
        no-error .
 if not available ub.tnv-in-turnover-group then  return error .
      assign
        ub.tnv-in-turnover-group.db-num-chg    = p-db-num-usr
        ub.tnv-in-turnover-group.stts          = 1
        ub.tnv-in-turnover-group.sys-date      = today
        ub.tnv-in-turnover-group.sys-time      = time
        ub.tnv-in-turnover-group.sys-time-chr  = string(ub.tnv-in-turnover-group.sys-time,"hh:mm")
        ub.tnv-in-turnover-group.who           = p-userid
      .
  end.
end procedure.
PROCEDURE oio-update :
define input  parameter p-recid       as recid no-undo .
define input  parameter p-db-num       as integer   no-undo .
define input  parameter p-id           as integer   no-undo .
define input  parameter p-ttg-summa    as decimal   no-undo .
define input  parameter p-use-discnt           as logical   no-undo .
define input  parameter p-discnt-pc            as decimal   no-undo .
define input  parameter p-discnt-method-round  as character no-undo .
define input  parameter p-stts         as integer   no-undo .
define input  parameter p-db-num-usr   as integer   no-undo .
define input  parameter p-userid       as character no-undo .
  do
  on error undo, return error return-value
  :
find first ub.tnv-in-turnover-group exclusive-lock where
        recid(ub.tnv-in-turnover-group) = p-recid
        no-error .
      if not available ub.tnv-in-turnover-group then do:
          create ub.tnv-in-turnover-group.
            assign
                ub.tnv-in-turnover-group.tog-db-num          = p-db-num
                ub.tnv-in-turnover-group.tog-id              = p-id
                ub.tnv-in-turnover-group.ttg-summa           = p-ttg-summa
                ub.tnv-in-turnover-group.use-discnt          = p-use-discnt
                ub.tnv-in-turnover-group.discnt-pc           = p-discnt-pc
                ub.tnv-in-turnover-group.discnt-method-round = p-discnt-method-round
            .
      end.
      assign
        ub.tnv-in-turnover-group.tog-db-num          = p-db-num
        ub.tnv-in-turnover-group.tog-id              = p-id
        ub.tnv-in-turnover-group.ttg-summa           = p-ttg-summa
        ub.tnv-in-turnover-group.use-discnt          = p-use-discnt
        ub.tnv-in-turnover-group.discnt-pc           = p-discnt-pc
        ub.tnv-in-turnover-group.discnt-method-round = p-discnt-method-round
        ub.tnv-in-turnover-group.db-num-chg    = p-db-num-usr
        ub.tnv-in-turnover-group.stts          = p-stts
        ub.tnv-in-turnover-group.sys-date      = today
        ub.tnv-in-turnover-group.sys-time      = time
        ub.tnv-in-turnover-group.sys-time-chr  = string ( ub.tnv-in-turnover-group.sys-time,"hh:mm" )
        ub.tnv-in-turnover-group.who           = p-userid
      .
  end.
end procedure.
DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-save AUTO-GO
     LABEL "Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE rubl AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 19.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE V-discnt-method-round LIKE ub.tnv-in-turnover-group.discnt-method-round
     LABEL "Метод округления по скидке"
     VIEW-AS FILL-IN
     SIZE 25 BY 1 NO-UNDO.
DEFINE VARIABLE v-discnt-pc LIKE ub.tnv-in-turnover-group.discnt-pc
     LABEL "Процент скидки"
     VIEW-AS FILL-IN
     SIZE 7 BY 1 NO-UNDO.
DEFINE VARIABLE v-name LIKE ub.turnover-group.name
     LABEL "Группа"
      VIEW-AS TEXT
     SIZE 76.5 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE v-ttg-summa LIKE ub.tnv-in-turnover-group.ttg-summa
     LABEL "Оборот покупателей"
     VIEW-AS FILL-IN
     SIZE 26.5 BY 1 NO-UNDO.
DEFINE VARIABLE v-use-d AS LOGICAL INITIAL no
     LABEL "Использовать скидку"
     VIEW-AS TOGGLE-BOX
     SIZE 28 BY .83 NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      ub.tnv-in-turnover-group SCROLLING.
DEFINE FRAME Dialog-Frame
     B-save AT ROW 1 COL 1
     B-Cancel AT ROW 1 COL 11
     B-Help AT ROW 1 COL 77
     v-ttg-summa AT ROW 4.75 COL 33.5 COLON-ALIGNED HELP
          ""
          LABEL "Оборот покупателей" FORMAT ">>>,>>>,>>>,>>9.99"
     v-use-d AT ROW 5.75 COL 35.5
     v-discnt-pc AT ROW 6.75 COL 33.5 COLON-ALIGNED HELP
          ""
          LABEL "Процент скидки" FORMAT ">>9.99"
     V-discnt-method-round AT ROW 7.92 COL 33.5 COLON-ALIGNED HELP
          ""
          LABEL "Метод округления по скидке" FORMAT "X(28)"
     v-name AT ROW 3 COL 7.5 COLON-ALIGNED HELP
          ""
          LABEL "Группа" FORMAT "X(80)"
          FGCOLOR 1
     rubl AT ROW 4.92 COL 61 COLON-ALIGNED NO-LABEL
     "%" VIEW-AS TEXT
          SIZE 1.75 BY 1 AT ROW 6.75 COL 43.25
          FGCOLOR 4
     SPACE(42.49) SKIP(3.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Добавление Оборота покупателей "
         DEFAULT-BUTTON B-save CANCEL-BUTTON B-Cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       V-discnt-method-round:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       v-use-d:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  run save-proc in this-procedure no-error .
  if error-status :error then do:
     return no-apply .
  end.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON VALUE-CHANGED OF v-use-d IN FRAME Dialog-Frame
DO:
  ASSIGN v-use-d .
  IF v-use-d  THEN DO:
     ENABLE v-discnt-pc WITH FRAME Dialog-Frame.
  END.
  ELSE DO:
      v-discnt-pc = 0 .
      DISABLE v-discnt-pc WITH FRAME Dialog-Frame.
  END.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run init-proc in this-procedure .
  run enable_ui in this-procedure .
  if p-mode = 'ИЗМЕНЕНИЕ':U then do:
     disable v-ttg-summa with frame Dialog-Frame.
     WAIT-FOR GO OF FRAME Dialog-Frame FOCUS v-discnt-pc .
  end.
  else do:
     WAIT-FOR GO OF FRAME Dialog-Frame FOCUS v-ttg-summa .
  end.
END.
run disable_ui in this-procedure .
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH ub.tnv-in-turnover-group SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY v-ttg-summa v-discnt-pc v-name rubl
      WITH FRAME Dialog-Frame.
  ENABLE B-save B-Cancel B-Help v-ttg-summa v-discnt-pc v-name rubl
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE init-proc :
  v-name = p-name .
  rubl = "РУБ" .
define buffer buf_tnv-in-turnover-group for ub.tnv-in-turnover-group  .
  if p-mode = 'ИЗМЕНЕНИЕ':U  then do:
  find first buf_tnv-in-turnover-group no-lock where recid(buf_tnv-in-turnover-group) = p-recid no-error .
  if not available buf_tnv-in-turnover-group then
  message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    "Ошибка "
    view-as alert-box error
  .
  assign
   v-ttg-summa  =  buf_tnv-in-turnover-group.ttg-summa
   v-use-d      =  buf_tnv-in-turnover-group.use-discnt
   v-discnt-pc  =  buf_tnv-in-turnover-group.discnt-pc
   V-discnt-method-round =  buf_tnv-in-turnover-group.discnt-method-round
  .
  end.
END PROCEDURE.
PROCEDURE save-proc :
ASSIGN frame Dialog-Frame
    V-discnt-method-round
    v-discnt-pc
    v-ttg-summa
    v-use-d
     .
if v-discnt-pc >= 100 then do:
   message "Процент не может быть 100 и выше !"  view-as alert-box error .
   return error return-value .
end.
if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    run oio-ADD in this-procedure (
        input  p-db-num      ,
        input  p-id          ,
        input  v-ttg-summa   ,
        input  v-use-d  ,
        input  v-discnt-pc   ,
        input  v-discnt-method-round,
        input  0        ,
        input  v-cntxt-db-num  ,
        input  v-cntxt-userid  ,
        output p-recid
        ).
 end.
 else do:
    run oio-update in this-procedure (
        input  p-recid       ,
        input  p-db-num      ,
        input  p-id          ,
        input  v-ttg-summa   ,
        input  v-use-d       ,
        input  v-discnt-pc   ,
        input  v-discnt-method-round,
        input  0               ,
        input  v-cntxt-db-num  ,
        input  v-cntxt-userid
        ).
 end.
END PROCEDURE.
