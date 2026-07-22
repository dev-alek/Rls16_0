DEFINE BUFFER X_sysconf FOR sysconf.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Настройки системы Sysconf".
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
define variable all-prt_ like ub.shop.all-prt no-undo.
define variable cd-bc-alt_ like ub.shop.cd-bc-alt no-undo.
define variable cd-bc-base_ like ub.shop.cd-bc-base no-undo.
define variable cd-loc-alt_ like ub.shop.cd-loc-alt no-undo.
define variable cd-loc-base_ like ub.shop.cd-loc-base no-undo.
define variable cd-parts-all_ like ub.shop.cd-parts-all no-undo.
define variable cd-parts-not-blank_ like ub.shop.cd-parts-not-blank no-undo.
define variable cd-parts-ser_ like ub.shop.cd-parts-ser no-undo.
define variable cd-pb-alt_ like ub.shop.cd-pb-alt no-undo.
define variable cd-pb-base_ like ub.shop.cd-pb-base no-undo.
define variable cd-sc-base_ like ub.shop.cd-sc-base no-undo.
define variable v-to-c-d as logical no-undo .
define buffer buf_clients for ub.clients.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод ":L
     SIZE 10 BY 1.
DEFINE BUTTON b-fbrpay
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3 BY .91.
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 3 BY 1.
DEFINE BUTTON b-inpay
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3 BY .91.
DEFINE BUTTON b-invpay
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3 BY .91.
DEFINE BUTTON b-outpay
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3 BY .91.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена":L
     SIZE 10 BY 1.
DEFINE BUTTON b-realpay
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3 BY .91.
DEFINE BUTTON b-retpay
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3 BY .91.
DEFINE BUTTON b-spipay
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3 BY .91.
DEFINE BUTTON b-suppay
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3 BY .91.
DEFINE BUTTON b-tocd
     LABEL "&На кассу"
     SIZE 10 BY 1.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 3 GRAPHIC-EDGE
     SIZE 34 BY 9.24
     BGCOLOR 8 .
DEFINE FRAME d-config
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-tocd AT ROW 1 COL 41
     b-help AT ROW 1 COL 69
     X_sysconf.rsrv-time AT ROW 2 COL 31.8 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     X_sysconf.load-time AT ROW 2 COL 60 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     X_sysconf.holidays AT ROW 3 COL 52.6 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 11.6 BY 1
     X_sysconf.out-line-discnt AT ROW 5 COL 43
          VIEW-AS TOGGLE-BOX
          SIZE 22 BY .81
     X_sysconf.price-calc AT ROW 6 COL 2
          VIEW-AS TOGGLE-BOX
          SIZE 36.6 BY .81
     X_sysconf.out-rate AT ROW 6 COL 43
          VIEW-AS TOGGLE-BOX
          SIZE 22 BY .81
     X_sysconf.no-eq AT ROW 7 COL 2
          VIEW-AS TOGGLE-BOX
          SIZE 37.6 BY .81
     X_sysconf.in-ov AT ROW 7 COL 43
          VIEW-AS TOGGLE-BOX
          SIZE 23 BY .81
     X_sysconf.unit-cli-perm AT ROW 8 COL 2
          VIEW-AS TOGGLE-BOX
          SIZE 32.6 BY .81
     X_sysconf.inout-price AT ROW 8 COL 43
          VIEW-AS TOGGLE-BOX
          SIZE 32 BY .81
     X_sysconf.in-perm AT ROW 9 COL 2
          VIEW-AS TOGGLE-BOX
          SIZE 69 BY .81
     X_sysconf.in-pay AT ROW 11.52 COL 30.6 COLON-ALIGNED
          LABEL "п&рихода"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     b-inpay AT ROW 11.52 COL 39.6 WIDGET-ID 6
     X_sysconf.out-pay AT ROW 12.52 COL 30.6 COLON-ALIGNED
          LABEL "рас&хода"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     b-outpay AT ROW 12.52 COL 39.6 WIDGET-ID 10
     X_sysconf.ret-pay AT ROW 13.52 COL 30.6 COLON-ALIGNED
          LABEL "во&зврата"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     b-retpay AT ROW 13.52 COL 39.6 WIDGET-ID 14
     X_sysconf.ret-sup-pay AT ROW 14.52 COL 30.6 COLON-ALIGNED
          LABEL "возвра&та пост."
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     b-suppay AT ROW 14.52 COL 39.6 WIDGET-ID 18
     X_sysconf.down-pay AT ROW 15.52 COL 30.6 COLON-ALIGNED
          LABEL "списани&я"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     b-spipay AT ROW 15.52 COL 39.6 WIDGET-ID 16
     X_sysconf.inv-pay AT ROW 16.52 COL 30.6 COLON-ALIGNED
          LABEL "и&нвентар."
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     b-invpay AT ROW 16.52 COL 39.6 WIDGET-ID 8
     X_sysconf.chk-pay AT ROW 17.52 COL 30.6 COLON-ALIGNED
          LABEL "продажи"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     b-realpay AT ROW 17.52 COL 39.6 WIDGET-ID 12
     X_sysconf.fbr-pay AT ROW 18.52 COL 30.6 COLON-ALIGNED
          LABEL "производства"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     b-fbrpay AT ROW 18.52 COL 39.6 WIDGET-ID 4
     X_sysconf.xdn-grp-code AT ROW 20.52 COL 70 COLON-ALIGNED HELP
          "" WIDGET-ID 24
          LABEL "Номер БД для копирования прав при импорте из 1С" FORMAT ">>>>>>>>9"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     "Оплаты :" VIEW-AS TEXT
          SIZE 8.6 BY .91 AT ROW 11.52 COL 15 WIDGET-ID 2
          FGCOLOR 4
     RECT-1 AT ROW 10.76 COL 13
     SPACE(36.99) SKIP(2.04)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Системные настройки для объекта (начальные значения)":L
         DEFAULT-BUTTON b-exit.
ASSIGN
       FRAME d-config:SCROLLABLE       = FALSE.
ON GO OF FRAME d-config
DO:
assign
        X_sysconf.chk-pay
        X_sysconf.down-pay
        X_sysconf.in-pay
        X_sysconf.inv-pay
        X_sysconf.out-pay
        X_sysconf.ret-pay
        X_sysconf.ret-sup-pay
        X_sysconf.fbr-pay
        X_sysconf.out-rate
        X_sysconf.out-line-discnt
        X_sysconf.inout-price
        X_sysconf.no-eq
        X_sysconf.unit-cli-perm
        X_sysconf.in-ov
        X_sysconf.in-perm
        X_sysconf.price-calc
        X_sysconf.rsrv-time
        X_sysconf.load-time
        X_sysconf.holidays
        X_sysconf.xdn-grp-code
        .
        if v-to-c-d = yes then
        assign
        X_sysconf.all-prt = all-prt_
        X_sysconf.cd-bc-alt = cd-bc-alt_
        X_sysconf.cd-bc-base = cd-bc-base_
        X_sysconf.cd-loc-alt = cd-loc-alt_
        X_sysconf.cd-loc-base = cd-loc-base_
        X_sysconf.cd-parts-all = cd-parts-all_
        X_sysconf.cd-parts-not-blank = cd-parts-not-blank_
        X_sysconf.cd-parts-ser = cd-parts-ser_
        X_sysconf.cd-pb-alt = cd-pb-alt_
        X_sysconf.cd-pb-base = cd-pb-base_
        X_sysconf.cd-sc-base =cd-sc-base_
        .
END.
ON CHOOSE OF b-fbrpay IN FRAME d-config
DO:
    define variable ref-rec as character no-undo .
    define buffer buf_pay-type for ub.pay-type.
    run ref/paytype.w (input parparentproc, "b-sel", output ref-rec ).
    apply "ENTRY" to self .
    if ref-rec = "" then return no-apply.
    else do:
        FIND buf_pay-type WHERE
                 recid( buf_pay-type ) = integer(ref-rec) NO-LOCK .
        assign
        X_sysconf.fbr-pay = buf_pay-type.obj-code .
        display
        X_sysconf.fbr-pay
        with frame d-config.
    end.
END.
ON CHOOSE OF b-inpay IN FRAME d-config
DO:
    define variable ref-rec as character no-undo .
    define buffer buf_pay-type for ub.pay-type.
    run ref/paytype.w (input parparentproc, "b-sel", output ref-rec ).
    apply "ENTRY" to self .
    if ref-rec = "" then return no-apply.
    else do:
        FIND buf_pay-type WHERE
                recid( buf_pay-type ) = integer(ref-rec) NO-LOCK .
        assign
        X_sysconf.in-pay = buf_pay-type.obj-code .
        display X_sysconf.in-pay with frame d-config.
   end.
END.
ON CHOOSE OF b-invpay IN FRAME d-config
DO:
    define variable ref-rec as character no-undo .
    define buffer buf_pay-type for ub.pay-type.
    run ref/paytype.w (input parparentproc, "b-sel", output ref-rec ).
    apply "ENTRY" to self .
    if ref-rec = "" then  return no-apply.
    else do:
        FIND buf_pay-type WHERE
               recid( buf_pay-type ) = integer(ref-rec) NO-LOCK .
        assign
        X_sysconf.inv-pay = buf_pay-type.obj-code .
        display
              X_sysconf.inv-pay with frame d-config.
    end.
END.
ON CHOOSE OF b-outpay IN FRAME d-config
DO:
    define variable ref-rec as character no-undo .
    define buffer buf_pay-type for ub.pay-type.
    run ref/paytype.w (input parparentproc, "b-sel", output ref-rec ).
    apply "ENTRY" to self .
    if ref-rec = "" then return no-apply.
    else do:
        FIND buf_pay-type WHERE
                recid( buf_pay-type ) = int(ref-rec) NO-LOCK .
        assign
        X_sysconf.out-pay = buf_pay-type.obj-code .
        display
        X_sysconf.out-pay
        with frame d-config.
    end.
END.
ON CHOOSE OF b-realpay IN FRAME d-config
DO:
    define variable ref-rec as character no-undo .
    define buffer buf_pay-type for ub.pay-type.
    run ref/paytype.w (input parparentproc, "b-sel", output ref-rec ).
    apply "ENTRY" to self .
    if ref-rec = ? then return no-apply.
    else do:
        FIND buf_pay-type WHERE
                 recid( buf_pay-type ) = int(ref-rec) NO-LOCK .
        assign
        X_sysconf.chk-pay = buf_pay-type.obj-code .
        display
        X_sysconf.chk-pay
        with frame d-config.
    end.
END.
ON CHOOSE OF b-retpay IN FRAME d-config
DO:
    define variable ref-rec as character no-undo .
    define buffer buf_pay-type for ub.pay-type.
    run ref/paytype.w (input parparentproc, "b-sel", output ref-rec ).
    apply "ENTRY" to self .
    if ref-rec = "" then return no-apply.
    else do:
        FIND buf_pay-type WHERE
                 recid( buf_pay-type ) = int(ref-rec) NO-LOCK .
        assign
        X_sysconf.ret-pay = buf_pay-type.obj-code .
        display
        X_sysconf.ret-pay
        with frame d-config.
   end.
END.
ON CHOOSE OF b-spipay IN FRAME d-config
DO:
    define variable ref-rec as character no-undo .
    define buffer buf_pay-type for ub.pay-type.
    run ref/paytype.w (input parparentproc, "b-sel", output ref-rec ).
    apply "ENTRY" to self .
    if ref-rec = "" then return no-apply.
    else do:
        FIND buf_pay-type WHERE
                 recid( buf_pay-type ) = int(ref-rec) NO-LOCK .
        assign
        X_sysconf.down-pay = buf_pay-type.obj-code .
        display
        X_sysconf.down-pay
        with frame d-config.
   end.
END.
ON CHOOSE OF b-suppay IN FRAME d-config
DO:
    define variable ref-rec as character no-undo .
    define buffer buf_pay-type for ub.pay-type.
    run ref/paytype.w (input parparentproc, "b-sel", output ref-rec ).
    apply "ENTRY" to self .
    if ref-rec = "" then return no-apply.
    else do:
        FIND buf_pay-type WHERE
                recid( buf_pay-type ) = int(ref-rec) NO-LOCK .
        assign
        X_sysconf.ret-sup-pay = buf_pay-type.obj-code .
        display
               X_sysconf.ret-sup-pay with frame d-config.
    end.
END.
ON CHOOSE OF b-tocd IN FRAME d-config
DO:
    assign
    all-prt_ = X_sysconf.all-prt
    cd-bc-alt_ = X_sysconf.cd-bc-alt
    cd-bc-base_ = X_sysconf.cd-bc-base
    cd-loc-alt_ = X_sysconf.cd-loc-alt
    cd-loc-base_ = X_sysconf.cd-loc-base
    cd-parts-all_ = X_sysconf.cd-parts-all
    cd-parts-not-blank_ = X_sysconf.cd-parts-not-blank
    cd-parts-ser_ = X_sysconf.cd-parts-ser
    cd-pb-alt_ = X_sysconf.cd-pb-alt
    cd-pb-base_ = X_sysconf.cd-pb-base
    cd-sc-base_ = X_sysconf.cd-sc-base.
    run adm/to-cd.w ( INPUT (if ibs.th.gbl.gbl-var:g#db-num = 0 then 'ИЗМЕНЕНИЕ':U else 'ПРОСМОТР':U)
                     ,INPUT X_sysconf.host-code
                     ,INPUT 'маг':U
                     ,INPUT 0
                     ,input  ("Параметры отсылки товаров на кассу по умолчанию для маг-нов фирмы " +
                                                string(X_sysconf.host-code))
                      ,INPUT-OUTPUT all-prt_
                      ,INPUT-OUTPUT cd-bc-alt_
                      ,INPUT-OUTPUT cd-bc-base_
                      ,INPUT-OUTPUT cd-loc-alt_
                      ,INPUT-OUTPUT cd-loc-base_
                      ,INPUT-OUTPUT cd-parts-all_
                      ,INPUT-OUTPUT cd-parts-not-blank_
                      ,INPUT-OUTPUT cd-parts-ser_
                      ,INPUT-OUTPUT cd-pb-alt_
                      ,INPUT-OUTPUT cd-pb-base_
                      ,INPUT-OUTPUT cd-sc-base_) .
    assign
    v-to-c-d = yes.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-config:PARENT eq ?
THEN FRAME d-config:PARENT = ACTIVE-WINDOW.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-config
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
on choose of b-help in frame d-config
do:
  apply "help":u to frame d-config .
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame d-config:width - 0.3
                fh            = frame d-config:first-child
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
ON WINDOW-CLOSE OF FRAME d-config APPLY "END-ERROR":U TO SELF.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  find X_sysconf where X_sysconf.host-code = p-curr-host-code.
  find first buf_clients no-lock where
            buf_clients.obj-type = 'орг':U
        and buf_clients.obj-code = p-curr-host-code.
  RUN enable_UI.
  assign
  frame d-config:title = substitute("&1 для фирмы &2"
                                        , frame d-config:title
                                       , buf_clients.obj-name).
  WAIT-FOR GO OF FRAME d-config.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME d-config.
END PROCEDURE.
PROCEDURE enable_UI :
  IF AVAILABLE X_sysconf THEN
    DISPLAY X_sysconf.rsrv-time X_sysconf.load-time X_sysconf.holidays
          X_sysconf.out-line-discnt X_sysconf.price-calc X_sysconf.out-rate
          X_sysconf.no-eq X_sysconf.in-ov X_sysconf.unit-cli-perm
          X_sysconf.inout-price X_sysconf.in-perm X_sysconf.in-pay
          X_sysconf.out-pay X_sysconf.ret-pay X_sysconf.ret-sup-pay
          X_sysconf.down-pay X_sysconf.inv-pay X_sysconf.chk-pay
          X_sysconf.fbr-pay X_sysconf.xdn-grp-code
      WITH FRAME d-config.
  ENABLE b-exit b-quit b-tocd b-help RECT-1 X_sysconf.rsrv-time
         X_sysconf.load-time X_sysconf.holidays X_sysconf.out-line-discnt
         X_sysconf.price-calc X_sysconf.out-rate X_sysconf.no-eq
         X_sysconf.in-ov X_sysconf.unit-cli-perm X_sysconf.inout-price
         X_sysconf.in-perm X_sysconf.in-pay b-inpay X_sysconf.out-pay b-outpay
         X_sysconf.ret-pay b-retpay X_sysconf.ret-sup-pay b-suppay
         X_sysconf.down-pay b-spipay X_sysconf.inv-pay b-invpay
         X_sysconf.chk-pay b-realpay X_sysconf.fbr-pay b-fbrpay
         X_sysconf.xdn-grp-code
      WITH FRAME d-config.
END PROCEDURE.
PROCEDURE Myenable :
IF AVAILABLE X_sysconf THEN
    DISPLAY X_sysconf.rsrv-time X_sysconf.load-time X_sysconf.holidays
          X_sysconf.out-line-discnt X_sysconf.price-calc X_sysconf.out-rate
          X_sysconf.no-eq X_sysconf.in-ov X_sysconf.unit-cli-perm
          X_sysconf.inout-price X_sysconf.in-perm X_sysconf.in-pay
          X_sysconf.down-pay X_sysconf.out-pay X_sysconf.inv-pay
          X_sysconf.ret-pay X_sysconf.chk-pay X_sysconf.ret-sup-pay
          X_sysconf.fbr-pay X_sysconf.xdn-grp-code
      WITH FRAME d-config.
  ENABLE b-exit b-quit b-tocd b-help X_sysconf.rsrv-time X_sysconf.load-time
         X_sysconf.holidays X_sysconf.out-line-discnt X_sysconf.price-calc
         X_sysconf.out-rate X_sysconf.no-eq X_sysconf.in-ov
         X_sysconf.unit-cli-perm X_sysconf.inout-price X_sysconf.in-perm
         X_sysconf.in-pay X_sysconf.down-pay X_sysconf.out-pay
         X_sysconf.inv-pay X_sysconf.ret-pay X_sysconf.chk-pay
         X_sysconf.ret-sup-pay X_sysconf.fbr-pay RECT-1 X_sysconf.xdn-grp-code
      WITH FRAME d-config.
IF ibs.th.gbl.gbl-var:g#db-num <> 0 THEN DO:
    HIDE
    b-exit IN FRAME d-config.
    ASSIGN
    b-quit:COLUMN = 1
    b-quit:LABEL = "&Выход".
END.
END PROCEDURE.
