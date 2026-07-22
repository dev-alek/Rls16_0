define input  parameter parParentProc as handle no-undo .
define input  parameter v-db-num as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Настройки ценообразования ".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
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
define buffer buf_global-state for ub.global-state  .
define buffer buf_global-state-attr for ub.global-state-attr  .
define variable v-val1 as decimal   no-undo .
define variable v-val2 as decimal   no-undo .
define variable v-prc as decimal   no-undo .
DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 12 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 5.5 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-OK AUTO-GO
     LABEL "&Ввод"
     SIZE 12 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE R-date AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Только дата объекта", 0,
"Сменная дата объекта(Смена+№)", 1,
"Дата и время сервера", 2
     SIZE 33 BY 2.25 NO-UNDO.
DEFINE VARIABLE T-cash-pay AS LOGICAL INITIAL no
     LABEL "По типам кассовых платежей"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY .83 NO-UNDO.
DEFINE VARIABLE T-cass AS LOGICAL INITIAL no
     LABEL "По кассам"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY .83 NO-UNDO.
DEFINE VARIABLE T-child AS LOGICAL INITIAL no
     LABEL "Есть подчиненные типы прайс-листов"
     VIEW-AS TOGGLE-BOX
     SIZE 38 BY .83 NO-UNDO.
DEFINE VARIABLE T-currency AS LOGICAL INITIAL no
     LABEL "Валюта"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY .83 NO-UNDO.
DEFINE VARIABLE T-date-time-server AS LOGICAL INITIAL no
     LABEL "Дата-время сервера"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY .83 NO-UNDO.
DEFINE VARIABLE T-group-buer AS LOGICAL INITIAL no
     LABEL "Группы покупателей"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY .83 NO-UNDO.
DEFINE VARIABLE T-group-qnty AS LOGICAL INITIAL no
     LABEL "Количественные группы"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY .83 NO-UNDO.
DEFINE VARIABLE T-group-summ AS LOGICAL INITIAL no
     LABEL "Суммовые группы"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY .83 NO-UNDO.
DEFINE VARIABLE T-main-price-list AS LOGICAL INITIAL no
     LABEL "Только главные прайс-листы"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY .83 NO-UNDO.
DEFINE VARIABLE T-no-base-edizm AS LOGICAL INITIAL no
     LABEL "Не базовая единица"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY .83 NO-UNDO.
DEFINE VARIABLE T-pal-nws AS LOGICAL INITIAL no
     LABEL "Цены по новостям ходят только в свои УБД"
     VIEW-AS TOGGLE-BOX
     SIZE 44 BY .83 NO-UNDO.
DEFINE VARIABLE T-pay-type AS LOGICAL INITIAL no
     LABEL "По типам оплат"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY .83 NO-UNDO.
DEFINE VARIABLE T-shift-obj AS LOGICAL INITIAL no
     LABEL "Сменная дата-номер объекта"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY .83 NO-UNDO.
DEFINE VARIABLE T-summ-oborot AS LOGICAL INITIAL no
     LABEL "Суммарный оборот покупателя"
     VIEW-AS TOGGLE-BOX
     SIZE 30 BY .83 NO-UNDO.
DEFINE FRAME Dialog-Frame
     B-OK AT ROW 1 COL 1
     B-Cancel AT ROW 1 COL 13
     B-Help AT ROW 1 COL 67.5
     T-main-price-list AT ROW 2.25 COL 2
     T-group-buer AT ROW 3 COL 2
     T-summ-oborot AT ROW 3.75 COL 2
     T-group-qnty AT ROW 4.5 COL 2
     T-group-summ AT ROW 5.25 COL 2
     T-no-base-edizm AT ROW 6 COL 2
     R-date AT ROW 6.79 COL 2 NO-LABEL WIDGET-ID 4
     T-date-time-server AT ROW 7.5 COL 40.5
     T-shift-obj AT ROW 8.25 COL 40.5
     T-currency AT ROW 9.08 COL 2
     T-cass AT ROW 9.83 COL 2
     T-pay-type AT ROW 10.58 COL 2
     T-cash-pay AT ROW 11.33 COL 2
     T-child AT ROW 12.08 COL 2 WIDGET-ID 2
     T-pal-nws AT ROW 13 COL 2 WIDGET-ID 8
     SPACE(44.37) SKIP(1.00)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Глобальные настройки ценообразования"
         DEFAULT-BUTTON B-OK CANCEL-BUTTON B-Cancel.
ASSIGN
       T-date-time-server:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       T-shift-obj:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  run save-proc in this-procedure  no-error .
  if error-status :error then return no-apply.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON VALUE-CHANGED OF R-date IN FRAME Dialog-Frame
DO:
  assign r-date.
  case r-date :
     when 0 then
      assign
        t-date-time-server  = no
        T-shift-obj = no
        .
     when 1 then
       assign
        t-date-time-server  = no
        T-shift-obj = yes
        .
     when 2 then
       assign
         t-date-time-server  = yes
         T-shift-obj = no
        .
  end case.
END.
ON VALUE-CHANGED OF T-main-price-list IN FRAME Dialog-Frame
DO:
  ASSIGN t-main-price-list.
  IF t-main-price-list THEN DO:
      ASSIGN
          T-currency          = false
          T-date-time-server  = false
          T-group-buer        = false
          T-group-qnty        = false
          T-group-summ        = false
          T-shift-obj         = false
          T-summ-oborot       = false
          T-pay-type          = false
          T-cash-pay          = false
          T-cass              = false
          T-child             = false
          r-date              = 0
          .
      display
          T-currency T-group-buer T-group-qnty T-group-summ T-no-base-edizm  T-summ-oborot
          T-cass
          T-child
          T-pay-type
          T-cash-pay
          r-date
          WITH FRAME Dialog-Frame.
      DISABLE
          T-currency T-date-time-server T-group-buer T-group-qnty T-group-summ  T-shift-obj T-summ-oborot
          T-cass
          T-child
          T-pay-type
          T-cash-pay
          r-date
          WITH FRAME Dialog-Frame.
  END.
  ELSE DO:
      ENABLE
          t-child
          T-currency  T-group-buer T-group-qnty T-group-summ T-no-base-edizm  T-summ-oborot
          T-pay-type
          T-cash-pay
          r-date
          with frame Dialog-Frame .
  END.
   run enable_sp1 in this-procedure .
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
  if v-db-num = 0 then do:
    apply "VALUE-CHANGED" to T-main-price-list in frame Dialog-Frame .
  end.
  else run my-enable in this-procedure  .
  T-cass = false .
  disable T-cass with frame Dialog-Frame .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
run disable_ui in this-procedure .
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_sp :
  DISPLAY T-main-price-list T-group-buer T-summ-oborot T-group-qnty T-group-summ
          T-no-base-edizm R-date T-currency T-cass T-pay-type T-cash-pay T-child
      WITH FRAME Dialog-Frame.
  ENABLE B-OK B-Cancel B-Help
         T-main-price-list
         T-group-buer
         T-no-base-edizm
         T-cash-pay
      WITH FRAME Dialog-Frame.
  disable
          T-summ-oborot
          T-group-qnty
          T-group-summ
          R-date
          T-currency
          T-cass
          T-pay-type
          T-child
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_sp1 :
  DISPLAY T-main-price-list T-group-buer T-summ-oborot T-group-qnty T-group-summ
          T-no-base-edizm R-date T-currency T-cass T-pay-type T-cash-pay T-child
      WITH FRAME Dialog-Frame.
  ENABLE B-OK B-Cancel B-Help
         T-main-price-list
         T-group-buer
         T-summ-oborot
         T-group-qnty
         T-group-summ
         T-no-base-edizm
          R-date
          T-currency
          T-pay-type
          T-cash-pay
          T-child
          t-pal-nws
      WITH FRAME Dialog-Frame.
  disable
          T-cass
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY T-main-price-list T-group-buer T-summ-oborot T-group-qnty T-group-summ
          T-no-base-edizm R-date T-currency T-cass T-pay-type T-cash-pay T-child
          T-pal-nws
      WITH FRAME Dialog-Frame.
  ENABLE B-OK B-Cancel B-Help T-main-price-list T-group-buer T-summ-oborot
         T-group-qnty T-group-summ T-no-base-edizm R-date T-currency T-cass
         T-pay-type T-cash-pay T-child T-pal-nws
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE init-proc :
define variable loc#log as logical   no-undo .
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_global-state_lookup':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output loc#log
    )  .
end.
  if loc#log <> yes then do:
     return error.
  end.
 find first  buf_global-state no-lock no-error .
 if not available buf_global-state then create buf_global-state .
    assign
      T-main-price-list  = logical ( buf_global-state.db-num-chg )
      T-group-buer       = buf_global-state.pl-use-grp-buy
      T-summ-oborot      = buf_global-state.pl-use-oborot-buy
      T-group-qnty       = buf_global-state.pl-use-qnty-group
      T-group-summ       = buf_global-state.pl-use-sum-group
      T-no-base-edizm    = buf_global-state.pl-use-add-code
      T-date-time-server = buf_global-state.pl-use-sys-date-time
      T-shift-obj        = buf_global-state.pl-use-shift-date-num
      T-cass             = buf_global-state.pl-use-cassa
      T-child            = buf_global-state.pl-use-child
      T-currency         = buf_global-state.pl-use-val
      T-pay-type         = buf_global-state.pl-use-pay-type
      T-cash-pay         = buf_global-state.pl-use-cash-pay
    .
    r-date = 0.
    if t-date-time-server = true then r-date = 2.
    if T-shift-obj = true then r-date = 1.
    find first buf_global-state-attr no-lock where
               buf_global-state-attr.gls-id = buf_global-state.gls-id and
               buf_global-state-attr.attr-code = 'pal-nws':U no-error .
    if not available buf_global-state-attr then do:
              create buf_global-state-attr.
              assign
                buf_global-state-attr.gls-id  = buf_global-state.gls-id
                buf_global-state-attr.attr-code  = 'pal-nws':U
                buf_global-state-attr.attr-value = 'no'
              .
     end.
     assign
      T-pal-nws = logical(buf_global-state-attr.attr-value) no-error
     .
     if error-status :error then T-pal-nws = false .
display T-main-price-list
        T-group-buer
        T-summ-oborot
        T-group-qnty
        T-group-summ
        T-no-base-edizm
        T-currency
        T-pay-type
        T-cash-pay
        r-date
        T-pal-nws
        with frame Dialog-Frame .
END PROCEDURE.
PROCEDURE my-enable :
  DISPLAY T-main-price-list T-group-buer
          T-summ-oborot T-group-qnty T-group-summ
          T-no-base-edizm T-date-time-server
          T-shift-obj T-currency t-cass t-child
          T-pay-type      T-cash-pay
          T-pal-nws
      WITH FRAME Dialog-Frame.
  ENABLE B-Cancel b-help
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  B-Cancel:label = "Выход" .
END PROCEDURE.
PROCEDURE save-proc :
define variable loc#log as logical   no-undo .
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_global-state_update':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output loc#log
    )  .
end.
  if loc#log <> yes then do: return error. end.
  assign  frame Dialog-Frame
    T-main-price-list
    T-group-buer
    T-summ-oborot
    T-group-qnty
    T-group-summ
    T-no-base-edizm
    T-date-time-server
    T-shift-obj
    T-currency
    t-cass
    t-child
    T-pay-type
    T-cash-pay
    r-date
    T-pal-nws
   .
     if  T-main-price-list  = true   and
          (T-currency         = true or
          T-date-time-server  = true or
          T-group-buer        = true or
          T-group-qnty        = true or
          T-group-summ        = true or
          T-cass              = true or
          T-child             = true or
          T-shift-obj         = true or
          T-pay-type          = true or
          T-cash-pay          = true or
          T-summ-oborot       = true  )  then do:
            message "Только Главные прайс-листы не могут быть выполнено !!!" view-as alert-box information .
            return error return-value .
     end.
  find current buf_global-state exclusive-lock no-error .
  if available buf_global-state then
  assign
    buf_global-state.pl-use-grp-buy         =  T-group-buer
    buf_global-state.pl-use-oborot-buy      =  T-summ-oborot
    buf_global-state.pl-use-qnty-group      =  T-group-qnty
    buf_global-state.pl-use-sum-group       =  T-group-summ
    buf_global-state.pl-use-add-code        =  T-no-base-edizm
    buf_global-state.pl-use-val             =  T-currency
    buf_global-state.pl-use-cassa           =  T-cass
    buf_global-state.pl-use-child           =  T-child
    buf_global-state.pl-use-cash-pay        =  T-cash-pay
    buf_global-state.pl-use-pay-type        =  T-pay-type
    buf_global-state.db-num-chg             =  integer(T-main-price-list)
  .
  case r-date :
      when 0 then
          assign
        t-date-time-server  = no
        T-shift-obj = no
        .
     when 1 then
          assign
        t-date-time-server  = no
        T-shift-obj = yes
        .
     when 2 then
     assign
        t-date-time-server  = yes
        T-shift-obj = no
        .
  end case.
    buf_global-state.pl-use-sys-date-time   =  T-date-time-server .
    buf_global-state.pl-use-shift-date-num  =  T-shift-obj        .
    find first buf_global-state-attr exclusive-lock where
               buf_global-state-attr.gls-id = buf_global-state.gls-id and
               buf_global-state-attr.attr-code = 'pal-nws':U no-error .
    if not available buf_global-state-attr then do:
              create buf_global-state-attr.
              assign
                buf_global-state-attr.gls-id  = buf_global-state.gls-id
                buf_global-state-attr.attr-code  = 'pal-nws':U
              .
     end.
      buf_global-state-attr.attr-value = string(T-pal-nws)
      .
    for each  buf_global-state-attr          exclusive-lock where
              buf_global-state-attr.gls-id = buf_global-state.gls-id and
              buf_global-state-attr.attr-code begins 'level-discnt':U
              :
              delete buf_global-state-attr.
    end.
    if buf_global-state.whole-send-news = 0 then buf_global-state.whole-send-news = 1.
                                            else buf_global-state.whole-send-news = 0.
END PROCEDURE.
