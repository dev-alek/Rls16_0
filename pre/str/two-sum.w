 define  temp-table temp-list-buyer no-undo ~
field obj-type as character ~
field obj-code as integer   ~
index pi is primary unique  ~
obj-type ~
obj-code.
define input  parameter p-mode as character no-undo .
define input-output parameter p-sum-1 as decimal   no-undo .
define input-output parameter p-sum-2 as decimal   no-undo .
define output parameter table for temp-list-buyer .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Интервалы сумм ".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure pricing_calc-itogo-buyer :
  do
  on error undo, return error return-value
  :
define input  parameter  p-cli-type as character no-undo .
define input  parameter  p-cli-code as integer   no-undo .
define output parameter  p-itogo-sum-doc-rubl  as decimal   no-undo .
define output parameter  p-itogo-sum-doc-base  as decimal   no-undo .
define output parameter  p-itogo-sum-rash-base as decimal   no-undo .
define output parameter  p-itogo-sum-rash      as decimal   no-undo .
define output parameter  p-itogo-sum-vozv-base as decimal   no-undo .
define output parameter  p-itogo-sum-vozv      as decimal   no-undo .
define output parameter  p-itogo-qnty-doc      as decimal   no-undo .
define output parameter  p-itogo-qnty-check    as decimal   no-undo .
define buffer bb_turnover-buyer      for ub.turnover-buyer.
define buffer bb_turnover-buyer-main for ub.turnover-buyer-main.
assign
  p-ITOGO-sum-doc-rubl =  0
  p-ITOGO-sum-doc-base =  0
  p-ITOGO-sum-rash-base = 0
  p-ITOGO-sum-rash      = 0
  p-ITOGO-sum-vozv-base = 0
  p-ITOGO-sum-vozv      = 0
  p-ITOGO-qnty-doc      = 0
  p-ITOGO-qnty-check    = 0
.
for each bb_turnover-buyer-main no-lock where
         bb_turnover-buyer-main.cli-type = p-cli-type and
         bb_turnover-buyer-main.cli-code = p-cli-code
         :
    p-ITOGO-qnty-doc     = p-ITOGO-qnty-doc     + bb_turnover-buyer-main.qnty-doc-itog .
    p-ITOGO-qnty-check   = p-ITOGO-qnty-check   + bb_turnover-buyer-main.qnty-check-itog .
    p-ITOGO-sum-doc-rubl = p-ITOGO-sum-doc-rubl + bb_turnover-buyer-main.sum-doc-rubl-itog .
    p-ITOGO-sum-doc-base = p-ITOGO-sum-doc-base + bb_turnover-buyer-main.sum-doc-base-itog .
end.
for each bb_turnover-buyer no-lock where
         bb_turnover-buyer.cli-type = p-cli-type and
         bb_turnover-buyer.cli-code = p-cli-code
         :
    if bb_turnover-buyer.ext-doc-type = 'ee':U      or
       bb_turnover-buyer.ext-doc-type = 'es':U or
       bb_turnover-buyer.ext-doc-type = ""
       then do:
        p-ITOGO-sum-rash      = p-ITOGO-sum-rash      + bb_turnover-buyer.sum-doc-rubl .
        p-ITOGO-sum-rash-base = p-ITOGO-sum-rash-base + bb_turnover-buyer.sum-doc-base .
    end.
    else do:
        p-ITOGO-sum-vozv      = p-ITOGO-sum-vozv      + bb_turnover-buyer.sum-doc-rubl .
        p-ITOGO-sum-vozv-base = p-ITOGO-sum-vozv-base + bb_turnover-buyer.sum-doc-base .
    end.
end.
  end.
end procedure.
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
DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-OK AUTO-GO
     LABEL "Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE v-sum-1 AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "C"
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1 NO-UNDO.
DEFINE VARIABLE v-sum-2 AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "ПО"
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     B-OK AT ROW 1 COL 1
     B-Cancel AT ROW 1 COL 11
     B-Help AT ROW 1 COL 43.5
     v-sum-1 AT ROW 3.75 COL 12.5 COLON-ALIGNED
     v-sum-2 AT ROW 5 COL 12.5 COLON-ALIGNED
     SPACE(13.74) SKIP(1.16)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Интервалы сумм"
         DEFAULT-BUTTON B-OK CANCEL-BUTTON B-Cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  RUN save-proc no-error .
  if error-status :error then do:
      message
        return-value
        view-as alert-box error
      .
      return no-apply .
  end.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-Cancel IN FRAME Dialog-Frame
DO:
  p-sum-2 = ? .
  p-sum-1 = ? .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if lookup(p-mode, ('sums' + chr(44) +
                    'calc' + chr(44) +
                    'sums-calc')) = 0 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверынй параметр вызова p-mode" p-mode
    view-as alert-box error .
    return error .
  end.
  for each  temp-list-buyer:
     delete temp-list-buyer.
  end.
  if p-mode = 'sums'
  or p-mode = 'sums-calc' then do:
    RUN enable_UI.
    if p-mode = 'sums-calc'   then do:
       RUN proc-calc IN THIS-PROCEDURE NO-ERROR.
    end.
    WAIT-FOR GO OF FRAME Dialog-Frame FOCUS v-sum-1.
  end.
  if p-mode = 'calc' then do:
    RUN proc-calc IN THIS-PROCEDURE NO-ERROR.
  end.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY v-sum-1 v-sum-2
      WITH FRAME Dialog-Frame.
  ENABLE B-OK B-Cancel B-Help v-sum-1 v-sum-2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-calc :
define variable p-itogo-sum-doc-rubl  as decimal   no-undo .
define variable p-itogo-sum-doc-base  as decimal   no-undo .
define variable p-itogo-sum-rash-base as decimal   no-undo .
define variable p-itogo-sum-rash      as decimal   no-undo .
define variable p-itogo-sum-vozv-base as decimal   no-undo .
define variable p-itogo-sum-vozv      as decimal   no-undo .
define variable p-itogo-qnty-doc      as decimal   no-undo .
define variable p-itogo-qnty-check    as decimal   no-undo .
empty temp-table temp-list-buyer.
for each  clients no-lock where clients.turnover-buyer = true :
      run pricing_calc-itogo-buyer (
            input  clients.obj-type            ,
            input  clients.obj-code            ,
            output p-itogo-sum-doc-rubl  ,
            output p-itogo-sum-doc-base  ,
            output p-itogo-sum-rash-base ,
            output p-itogo-sum-rash      ,
            output p-itogo-sum-vozv-base ,
            output p-itogo-sum-vozv      ,
            output p-itogo-qnty-doc      ,
            output p-itogo-qnty-check    ).
      if p-itogo-sum-doc-rubl >= p-sum-1 and p-itogo-sum-doc-rubl <= p-sum-2 and p-sum-2 <> ? then do:
          create temp-list-buyer.
          assign
          temp-list-buyer.obj-type =  clients.obj-type
          temp-list-buyer.obj-code =  clients.obj-code
          .
      end.
      if p-itogo-sum-doc-rubl >= p-sum-1  and p-sum-2 = ? then do:
          create temp-list-buyer.
          assign
          temp-list-buyer.obj-type =  clients.obj-type
          temp-list-buyer.obj-code =  clients.obj-code
          .
      end.
end.
END PROCEDURE.
PROCEDURE save-proc :
ASSIGN FRAME Dialog-Frame
    v-sum-1
    v-sum-2
    .
if v-sum-2 <> ? then do:
   if  v-sum-2 < v-sum-1 then do:
   return error "Не верно введен интервал сумм!" .
   end.
end.
p-sum-1 =   v-sum-1 .
p-sum-2 =   v-sum-2 .
RUN proc-calc IN THIS-PROCEDURE.
END PROCEDURE.
