define input  parameter parParentproc as handle no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Толкач выгрузки на прайс-чекер".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure sel-date :
  define input  parameter p-date-handle as handle    no-undo .
  define input  parameter p-description as character no-undo .
  do
  on error undo, return error return-value
  :
    if (can-query (p-date-handle, "sensitive")
      and
      p-date-handle :sensitive = true
      )
    or (can-query (p-date-handle, "read-only")
      and
      p-date-handle :read-only = false
      )
    then do:
      if p-date-handle :handle <> focus :handle
      then do:
        apply "entry":u to p-date-handle .
      end.
      define variable v-ok            as logical no-undo .
      define variable v-curr-sv-date as date no-undo .
      assign
        v-curr-sv-date = date(p-date-handle :screen-value) no-error
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
          ,input p-description
          ,input ""
          ,input-output v-curr-sv-date
          ,output v-ok
          ).
        if v-ok = true
        then do:
          assign
            p-date-handle :screen-value = string(v-curr-sv-date) .
          .
        end.
      end.
    end.
  end.
end procedure.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxp-doc-prt         like ub.store.doc-prt         no-undo.
  define variable v-cntxp-price-calc      like ub.store.price-calc      no-undo.
  define variable v-cntxp-inout-price     like ub.store.inout-price     no-undo.
  define variable v-cntxp-unit-cli-perm   like ub.store.unit-cli-perm   no-undo.
  define variable v-cntxp-out-rate        like ub.store.out-rate        no-undo.
  define variable v-cntxp-out-line-discnt like ub.store.out-line-discnt no-undo.
  define variable v-cntxp-in-ov           like ub.store.in-ov           no-undo.
  define variable v-cntxp-in-perm         like ub.store.in-perm         no-undo.
  define variable v-cntxp-no-eq           like ub.store.no-eq           no-undo.
  define variable v-cntxp-rsrv-time       like ub.store.rsrv-time       no-undo.
  define variable v-cntxp-load-time       like ub.store.load-time       no-undo.
  define variable v-cntxp-holidays        like ub.store.holidays        no-undo.
  define variable v-cntxp-in-pay          like ub.store.in-pay          no-undo.
  define variable v-cntxp-out-pay         like ub.store.out-pay         no-undo.
  define variable v-cntxp-ret-pay         like ub.store.ret-pay         no-undo.
  define variable v-cntxp-ret-sup-pay     like ub.store.ret-sup-pay     no-undo.
  define variable v-cntxp-down-pay        like ub.store.down-pay        no-undo.
  define variable v-cntxp-inv-pay         like ub.store.inv-pay         no-undo.
  define variable v-cntxp-chk-pay         like ub.store.chk-pay         no-undo.
  define variable v-cntxp-retail          like ub.sysconf.ord-prt       no-undo.
  define variable v-cntxp-osn-base        like ub.sysconf.osn-base      no-undo.
  define variable v-cntxp-conf-par        as   character                no-undo.
  define variable v-cntxp-par-type        as   character                no-undo.
  define variable v-cntxp-curr-host-code  like ub.store.host-code       no-undo.
  define variable v-cntxp-obj-type        like ub.clients.obj-type      no-undo.
  define variable v-cntxp-obj-code        like ub.clients.obj-code      no-undo.
  define variable v-cntxp-db-num          as integer   no-undo .
  define variable v-cntxp-userid          as character no-undo .
  define variable v-cntxp-level           as character no-undo .
  define variable v-cntxp-db-num-obj      as integer   no-undo .
  define variable v-cntxp-is-admin        as logical   no-undo .
  define buffer bf-cntxp_store for ub.store.
  define buffer bf-cntxp_shop  for ub.shop.
  define buffer bf-cntxp_sysconf for ub.sysconf.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable print-type as character no-undo.
define buffer chk-slip-head for ub.chk-slip-head .
define buffer buf_cash-desk for ub.cash-desk.
define stream out-slip .
function func-src returns character
    (input v-int-type as integer):
    case v-int-type :
        when 1 then
            return "ФН ККТ" .
        when 2 then
            return "ТУ" .
        when 3 then
            return "Касса" .
        when 4 then
            return "АСУ Заправщик" .
        otherwise
        return " - " .
    end case .
end function .
function func-kind returns character
    (input v-int-type as integer):
    case v-int-type :
        when 1 then
            return "Z-отчет" .
        when 2 then
            return "Отчет ТУ" .
        when 3 then
            return "Кассовый отчет о незавершенных возвратах" .
        when 4 then
            return "Финансовый отчет" .
        when 5 then
            return "Отчет по топливу и платежам" .
        when 6 then
            return "Отчет по услугам" .
        when 7 then
            return "Отчет по аннуляциям" .
        when 8 then
            return "Отчет по сбросам и переливам" .
        when 9 then
            return "Отчет по товарам" .
        when 10 then
            return "Сменный отчет АСУ Заправщик" .
        otherwise
        return " - " .
    end case .
end function .
DEFINE BUTTON b-cd
    IMAGE-UP FILE "btn-down-arrow":U
    IMAGE-DOWN FILE "btn-down-arrow":U
    IMAGE-INSENSITIVE FILE "btn-down-arrow":U
    LABEL "Btn 1"
    SIZE 3 BY 1.
DEFINE BUTTON b-choose-date
    IMAGE-UP FILE "btn-down-arrow":U
    IMAGE-DOWN FILE "btn-down-arrow":U
    IMAGE-INSENSITIVE FILE "btn-down-arrow":U
    LABEL "b-choose-date"
    SIZE 3 BY .88.
DEFINE BUTTON b-choose-shift
    IMAGE-UP FILE "btn-down-arrow":U
    IMAGE-DOWN FILE "btn-down-arrow":U
    IMAGE-INSENSITIVE FILE "btn-down-arrow":U
    LABEL "b-choose-date"
    SIZE 3 BY .88.
DEFINE BUTTON b-exit AUTO-END-KEY
    LABEL "Выход"
    SIZE 15 BY 1.13
    BGCOLOR 8 .
DEFINE BUTTON b-print1
    LABEL "Сохранить в файл"
    SIZE 17 BY 1.13
    BGCOLOR 8 .
DEFINE VARIABLE v-kind     AS INTEGER FORMAT ">>9":U INITIAL 0
    LABEL "Тип"
    VIEW-AS COMBO-BOX INNER-LINES 6
    LIST-ITEM-PAIRS "Все",0,
    "Z-отчет",1,
    "Отчет ТУ",2,
    "Кассовый отчет о незавершенных возвратах",3,
    "Финансовый отчет",4,
    "Отчет по топливу и платежам",5,
    "Отчет по услугам",6,
    "Отчет по аннуляциям",7,
    "Отчет по сбросам и переливам",8,
    "Отчет по товарам",9,
    "Сменный отчет АСУ Заправщик",10
    DROP-DOWN-LIST
    SIZE 50 BY 1 NO-UNDO.
DEFINE VARIABLE v-src      AS INTEGER FORMAT "->>9":U INITIAL 0
    LABEL "Источник"
    VIEW-AS COMBO-BOX INNER-LINES 4
    LIST-ITEM-PAIRS "Все",0,
    "ФН ККТ",1,
    "ТУ",2,
    "Касса",3,
    "АСУ Заправщик",4
    DROP-DOWN-LIST
    SIZE 50 BY 1 NO-UNDO.
DEFINE VARIABLE dateShift  AS DATE    FORMAT "99/99/9999":U
    LABEL "Смена"
    VIEW-AS FILL-IN
    SIZE 12 BY 1 NO-UNDO.
DEFINE VARIABLE numShift   AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
    LABEL "№"
    VIEW-AS FILL-IN
    SIZE 3.5 BY 1 NO-UNDO.
DEFINE VARIABLE v-cash-num AS INTEGER FORMAT ">>>9":U INITIAL 0
    LABEL "Касса"
    VIEW-AS FILL-IN
    SIZE 7 BY 1 NO-UNDO.
DEFINE VARIABLE v-date     AS DATE    FORMAT "99/99/9999":U INITIAL today
    LABEL "Сформирован"
    VIEW-AS FILL-IN
    SIZE 12 BY 1 NO-UNDO.
DEFINE MENU MENU-b-print1
    MENU-ITEM m_one         LABEL "Текущий"
    MENU-ITEM m_all         LABEL "Все"  .
DEFINE BUTTON b-help
    LABEL "Помощь":L
    SIZE 7 BY 1.
define query br-chk-slip-head for chk-slip-head scrolling .
define browse br-chk-slip-head
    query br-chk-slip-head display
    chk-slip-head.CashShiftDate format "99/99/9999" COLUMN-LABEL "Дата смены" width 10
    chk-slip-head.CashShiftNum COLUMN-LABEL "№ смены" width 10
    chk-slip-head.slip-dt format "99/99/9999 HH:MM:SS" COLUMN-LABEL "Сформирован" width 20
    chk-slip-head.cash-num COLUMN-LABEL "Касса" width 10
    func-src(chk-slip-head.src_) COLUMN-LABEL "Источник" width 15 format "X(100)"
    func-kind(chk-slip-head.kind) COLUMN-LABEL "Тип" width 35 format "X(100)"
    chk-slip-head.ID COLUMN-LABEL "ID" format "X(100)"
WITH SEPARATORS SIZE 121.5 BY 12 .
DEFINE FRAME Dialog-Frame
    b-exit AT ROW 1.08 COL 2
    b-print1 AT ROW 1.08 COL 18.75 WIDGET-ID 2
    v-cash-num AT ROW 1.08 COL 48.5 COLON-ALIGNED WIDGET-ID 6
    b-cd AT ROW 1.08 COL 57.75 WIDGET-ID 14
    v-src AT ROW 1.08 COL 71.9 COLON-ALIGNED WIDGET-ID 8
    v-kind AT ROW 2.21 COL 71.9 COLON-ALIGNED WIDGET-ID 12
    b-help AT ROW 1 COL 92.5
    numShift AT ROW 2.25 COL 27.63 COLON-ALIGNED WIDGET-ID 22
    v-date AT ROW 2.25 COL 48.5 COLON-ALIGNED WIDGET-ID 4
    b-choose-date AT ROW 2.25 COL 62.63 WIDGET-ID 16
    dateShift AT ROW 2.29 COL 7.5 COLON-ALIGNED WIDGET-ID 20
    b-choose-shift AT ROW 2.29 COL 22.63 WIDGET-ID 18
    br-chk-slip-head AT ROW 3.46 COL 2
    SPACE(0.75) SKIP(0.41)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
    SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
    TITLE "Отчеты кассового оборудования, ККТ, ТУ"
    CANCEL-BUTTON b-exit WIDGET-ID 100.
ASSIGN
    FRAME Dialog-Frame:SCROLLABLE = FALSE
    FRAME Dialog-Frame:HIDDEN     = TRUE.
ASSIGN
    br-chk-slip-head:COLUMN-RESIZABLE IN FRAME Dialog-Frame = TRUE.
ASSIGN
    b-print1:POPUP-MENU IN FRAME Dialog-Frame = MENU MENU-b-print1:HANDLE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
    DO:
        APPLY "END-ERROR":U TO SELF.
    END.
ON CHOOSE OF b-cd IN FRAME Dialog-Frame
    DO:
        define variable ri-list as character no-undo .
        run ref/cashlist.w
            (input  parparentproc
            ,input  'b-sel':U
            ,input  'объект':U
            ,v-cntxt-db-num
            ,v-cntxt-host-code-obj
            ,v-cntxt-obj-type
            ,v-cntxt-obj-code
            ,input  ?
            ,output ri-list
            ) no-error.
        if ri-list = '' then
        do:
            return no-apply .
        end.
        FIND FIRST buf_cash-desk No-LOCK WHERE
            recid(buf_cash-desk) = integer(ri-list) no-error.
        if not available buf_cash-desk then
        do:
            return no-apply .
        end.
        v-cash-num = buf_cash-desk.cash-num .
        display v-cash-num WITH FRAME Dialog-Frame.
        run reopen-query .
    END.
ON value-changed OF v-cash-num IN FRAME Dialog-Frame
    DO:
        assign v-cash-num .
        if v-cash-num > 0
            then
        do :
            FIND FIRST buf_cash-desk No-LOCK where buf_cash-desk.db-num = v-cntxt-db-num
                and buf_cash-desk.obj-code = v-cntxt-obj-code
                and buf_cash-desk.cash-num = v-cash-num
                no-error .
            if not available buf_cash-desk
                then
            do :
                message "Не найдена касса с кодом " v-cash-num view-as alert-box .
                return no-apply .
            end .
        end .
        run reopen-query .
    END.
on del of v-cash-num in frame Dialog-Frame
    do :
        v-cash-num = ? .
        v-cash-num:screen-value = "?" .
        run reopen-query .
    end .
on delete-character of dateShift in frame Dialog-Frame
    do:
        dateShift = ? .
        dateShift:screen-value = string(dateShift,"99/99/9999")  .
        run reopen-query .
    end.
on del of dateShift in frame Dialog-Frame
    do :
        dateShift = ? .
        dateShift:screen-value = string(dateShift,"99/99/9999")  .
        run reopen-query .
    end .
on ctrl-d of dateShift in frame Dialog-Frame
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
            then
        do:
            if self :handle <> focus :handle
                then
            do:
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
on del of numShift in frame Dialog-Frame
    do :
        numShift = 0 .
        numShift:screen-value = "0" .
        run reopen-query .
    end .
ON leave OF v-date IN FRAME Dialog-Frame
    DO:
        assign v-date .
        run reopen-query .
    END.
ON CHOOSE OF b-choose-date IN FRAME Dialog-Frame
    DO:
        run sel-date in this-procedure
            (input v-date :handle
            ,input ""
            ) .
        apply "leave" to v-date IN FRAME Dialog-Frame .
    END.
ON value-changed OF v-src IN FRAME Dialog-Frame
    DO:
        define variable Kind_ as character no-undo .
        assign v-src .
        case v-src:
            when 0 then
                do:
                    Kind_ = "Все" + chr(44) + '0':U + chr(44) +
                        "Z-отчет" + chr(44) + '1':U + chr(44) +
                        "Отчет ТУ" + chr(44) + '2':U + chr(44) +
                        "Финансовый отчет" + chr(44) + '4':U + chr(44) +
                        "Отчет по топливу и платежам" + chr(44) + '5':U + chr(44) +
                        "Отчет по услугам" + chr(44) + '6':U + chr(44) +
                        "Отчет по аннуляциям" + chr(44) + '7':U + chr(44) +
                        "Отчет по сбросам и переливам" + chr(44) + '8':U + chr(44) +
                        "Отчет по товароам" + chr(44) + '9':U + chr(44) +
                        "Сменный отчет АСУ Заправщик" + chr(44) + '10':U .
                end.
            when 1 then
                do:
                    Kind_ = "Z-отчет" + chr(44) + '1':U .
                end.
            when 2 then
                do:
                    Kind_ = "Отчет ТУ" + chr(44) + '2':U .
                end.
            when 3 then
                do:
                    Kind_ = "Финансовый отчет" + chr(44) + '4':U + chr(44) +
                        "Отчет по топливу и платежам" + chr(44) + '5':U + chr(44) +
                        "Отчет по услугам" + chr(44) + '6':U + chr(44) +
                        "Отчет по аннуляциям" + chr(44) + '7':U + chr(44) +
                        "Отчет по сбросам и переливам" + chr(44) + '8':U + chr(44) +
                        "Отчет по товароам" + chr(44) + '9':U .
                end.
            when 4 then
                do:
                    Kind_ = "Сменный отчет АСУ Заправщик" + chr(44) + '10':U .
                end.
        end case .
        ASSIGN
            v-kind:LIST-ITEM-PAIRS  in frame Dialog-Frame = Kind_ .
        run reopen-query .
    END.
ON value-changed OF v-kind IN FRAME Dialog-Frame
    DO:
        assign v-kind .
        run reopen-query .
    END.
ON CHOOSE OF b-print1 IN FRAME Dialog-Frame
    DO:
        if not available chk-slip-head
            then
        do :
            return no-apply .
        end .
        if print-type = "" then
        do:
            run gbl/pop-up.p ( input b-print1:handle, input no) no-error.
            if error-status:error then return no-apply.
        end.
        if print-type = "" then return no-apply.
        if print-type = "one"
            then
        do :
            run str/chk-slip-print.p (input chk-slip-head.db-num,
                input chk-slip-head.ID,
                input chk-slip-head.CheckID,
                input chk-slip-head.RRN,
                input print-type)
                .
        end .
        else
        do :
            run print-rep .
        end .
    END.
ON RETURN OF br-chk-slip-head IN FRAME Dialog-Frame
    OR mouse-select-dblclick of br-chk-slip-head in frame Dialog-Frame
    do:
        if not available chk-slip-head
            then
        do :
            return no-apply .
        end .
        run str/chk-slip.w (input chk-slip-head.db-num,
            input chk-slip-head.ID,
            input chk-slip-head.CheckID,
            input chk-slip-head.RRN)
            .
    end.
ON leave OF dateShift IN FRAME Dialog-Frame
    DO:
        assign dateShift .
        run reopen-query .
    END.
ON CHOOSE OF MENU-ITEM m_all
    DO:
        print-type = "reports":U.
        apply "choose" to b-print1 in frame Dialog-Frame.
    END.
ON CHOOSE OF MENU-ITEM m_one
    DO:
        print-type = "one":U.
        apply "choose" to b-print1 in frame Dialog-Frame.
    END.
ON CHOOSE OF b-choose-shift IN FRAME Dialog-Frame
    DO:
        run sel-date in this-procedure
            (input dateShift :handle
            ,input ""
            ) .
        apply "leave" to dateShift IN FRAME Dialog-Frame .
    END.
ON leave OF numShift IN FRAME Dialog-Frame
    DO:
        assign numShift .
        run reopen-query .
    END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
    THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame Dialog-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame Dialog-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse br-chk-slip-head :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of v-date in frame Dialog-Frame
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
on delete-character of v-date in frame Dialog-Frame
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
on ctrl-d of v-date in frame Dialog-Frame
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
on ctrl-b of v-date in frame Dialog-Frame
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
on ctrl-e of v-date in frame Dialog-Frame
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
on ctrl-f of v-date in frame Dialog-Frame
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
  define MENU m-ed-date7
    MENU-ITEM m-ed-date7-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date7-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date7-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date7-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if v-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      v-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date7 :HANDLE
      v-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle7 as handle no-undo .
  assign
    v-label-handle7 = v-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle7)
  then do:
    if v-label-handle7 :tooltip = ""
    or v-label-handle7 :tooltip = ?
    then do:
      assign
        v-label-handle7 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date7-1 in menu m-ed-date7 DO:
    apply "ctrl-b":U to v-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date7-2 in menu m-ed-date7 DO:
    apply "ctrl-d":U to v-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date7-3 in menu m-ed-date7 DO:
    apply "ctrl-e":U to v-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date7-4 in menu m-ed-date7 DO:
    apply "ctrl-f":U to v-date in frame Dialog-Frame .
  END.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of dateShift in frame Dialog-Frame
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
on delete-character of dateShift in frame Dialog-Frame
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
on ctrl-d of dateShift in frame Dialog-Frame
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
on ctrl-b of dateShift in frame Dialog-Frame
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
on ctrl-e of dateShift in frame Dialog-Frame
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
on ctrl-f of dateShift in frame Dialog-Frame
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
  define MENU m-ed-date9
    MENU-ITEM m-ed-date9-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date9-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date9-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date9-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if dateShift :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      dateShift :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date9 :HANDLE
      dateShift :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle9 as handle no-undo .
  assign
    v-label-handle9 = dateShift :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle9)
  then do:
    if v-label-handle9 :tooltip = ""
    or v-label-handle9 :tooltip = ?
    then do:
      assign
        v-label-handle9 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date9-1 in menu m-ed-date9 DO:
    apply "ctrl-b":U to dateShift in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date9-2 in menu m-ed-date9 DO:
    apply "ctrl-d":U to dateShift in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date9-3 in menu m-ed-date9 DO:
    apply "ctrl-e":U to dateShift in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date9-4 in menu m-ed-date9 DO:
    apply "ctrl-f":U to dateShift in frame Dialog-Frame .
  END.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    b-print1:MENU-MOUSE = 1 .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxp-db-num
    ,output v-cntxp-userid
    ,output v-cntxp-level
    ,output v-cntxp-curr-host-code
    ,output v-cntxp-obj-type
    ,output v-cntxp-obj-code
    ,output v-cntxp-db-num-obj
    ,output v-cntxp-is-admin
    ) .
  if (v-cntxp-obj-type = 'маг':U or v-cntxp-obj-type = 'скл':U) and
     v-cntxp-obj-code <> 0 then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-prt'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  yes
  ,output v-cntxp-conf-par
  ,output v-cntxp-par-type
  ) no-error .
    case v-cntxp-obj-type :
      when 'скл':U then do:
        find first bf-cntxp_store where bf-cntxp_store.obj-code = v-cntxp-obj-code no-lock.
        find first bf-cntxp_sysconf where bf-cntxp_sysconf.host-code = bf-cntxp_store.host-code no-lock.
        assign
          v-cntxp-doc-prt         = (v-cntxp-conf-par = "yes") and bf-cntxp_store.doc-prt
          v-cntxp-price-calc      = bf-cntxp_store.price-calc
          v-cntxp-inout-price     = bf-cntxp_store.inout-price
          v-cntxp-unit-cli-perm   = bf-cntxp_store.unit-cli-perm
          v-cntxp-out-rate        = bf-cntxp_store.out-rate
          v-cntxp-out-line-discnt = bf-cntxp_store.out-line-discnt
          v-cntxp-in-ov           = bf-cntxp_store.in-ov
          v-cntxp-in-perm         = bf-cntxp_store.in-perm
          v-cntxp-no-eq           = bf-cntxp_store.no-eq
          v-cntxp-rsrv-time       = bf-cntxp_store.rsrv-time
          v-cntxp-load-time       = bf-cntxp_store.load-time
          v-cntxp-holidays        = bf-cntxp_store.holidays
          v-cntxp-in-pay          = bf-cntxp_store.in-pay
          v-cntxp-out-pay         = bf-cntxp_store.out-pay
          v-cntxp-ret-pay         = bf-cntxp_store.ret-pay
          v-cntxp-ret-sup-pay     = bf-cntxp_store.ret-sup-pay
          v-cntxp-down-pay        = bf-cntxp_store.down-pay
          v-cntxp-inv-pay         = bf-cntxp_store.inv-pay
          v-cntxp-chk-pay         = bf-cntxp_store.chk-pay
          v-cntxp-retail          = bf-cntxp_sysconf.ord-prt
          v-cntxp-osn-base        = bf-cntxp_sysconf.osn-base
          .
      end.
      when 'маг':U then do:
        find first bf-cntxp_shop where bf-cntxp_shop.obj-code = v-cntxp-obj-code no-lock.
        find first bf-cntxp_sysconf where bf-cntxp_sysconf.host-code = bf-cntxp_shop.host-code no-lock.
        assign
          v-cntxp-doc-prt         = (v-cntxp-conf-par = "yes") and bf-cntxp_shop.doc-prt
          v-cntxp-price-calc      = bf-cntxp_shop.price-calc
          v-cntxp-inout-price     = bf-cntxp_shop.inout-price
          v-cntxp-unit-cli-perm   = bf-cntxp_shop.unit-cli-perm
          v-cntxp-out-rate        = bf-cntxp_shop.out-rate
          v-cntxp-out-line-discnt = bf-cntxp_shop.out-line-discnt
          v-cntxp-in-ov           = bf-cntxp_shop.in-ov
          v-cntxp-in-perm         = bf-cntxp_shop.in-perm
          v-cntxp-no-eq           = bf-cntxp_shop.no-eq
          v-cntxp-rsrv-time       = bf-cntxp_shop.rsrv-time
          v-cntxp-load-time       = bf-cntxp_shop.load-time
          v-cntxp-holidays        = bf-cntxp_shop.holidays
          v-cntxp-in-pay          = bf-cntxp_shop.in-pay
          v-cntxp-out-pay         = bf-cntxp_shop.out-pay
          v-cntxp-ret-pay         = bf-cntxp_shop.ret-pay
          v-cntxp-ret-sup-pay     = bf-cntxp_shop.ret-sup-pay
          v-cntxp-down-pay        = bf-cntxp_shop.down-pay
          v-cntxp-inv-pay         = bf-cntxp_shop.inv-pay
          v-cntxp-chk-pay         = bf-cntxp_shop.chk-pay
          v-cntxp-retail          = bf-cntxp_sysconf.ord-prt
          v-cntxp-osn-base        = bf-cntxp_sysconf.osn-base
          .
      end.
    end case.
  end.
    RUN enable_UI.
    open query br-chk-slip-head for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
        and date(chk-slip-head.slip-dt) = v-date
        and chk-slip-head.is-report = 1 .
    WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
procedure reopen-query :
  if v-cash-num = ?
  or v-cash-num = 0
  then do :
    if v-src = 0
    then do :
      if v-kind = 0
      then do :
        open query br-chk-slip-head
        for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                         and date(chk-slip-head.slip-dt) = v-date
                                         and chk-slip-head.is-report = 1
        .
      end .
      else do :
        open query br-chk-slip-head
        for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                         and date(chk-slip-head.slip-dt) = v-date
                                         and chk-slip-head.is-report = 1
                                         and chk-slip-head.kind = v-kind
        .
      end .
    end .
    else do :
      if v-kind = 0
      then do :
        open query br-chk-slip-head
        for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                         and date(chk-slip-head.slip-dt) = v-date
                                         and chk-slip-head.is-report = 1
                                         and chk-slip-head.src_ = v-src
        .
      end .
      else do :
        open query br-chk-slip-head
        for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                         and date(chk-slip-head.slip-dt) = v-date
                                         and chk-slip-head.is-report = 1
                                         and chk-slip-head.kind = v-kind
                                         and chk-slip-head.src_ = v-src
        .
      end .
    end .
  end .
  else do :
    if v-src = 0
    then do :
      if v-kind = 0
      then do :
        open query br-chk-slip-head
        for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                         and date(chk-slip-head.slip-dt) = v-date
                                         and chk-slip-head.is-report = 1
                                         and chk-slip-head.cash-num = v-cash-num
        .
      end .
      else do :
        open query br-chk-slip-head
        for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                         and date(chk-slip-head.slip-dt) = v-date
                                         and chk-slip-head.is-report = 1
                                         and chk-slip-head.cash-num = v-cash-num
                                         and chk-slip-head.kind = v-kind
        .
      end .
    end .
    else do :
      if v-kind = 0
      then do :
        open query br-chk-slip-head
        for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                         and date(chk-slip-head.slip-dt) = v-date
                                         and chk-slip-head.is-report = 1
                                         and chk-slip-head.cash-num = v-cash-num
                                         and chk-slip-head.src_ = v-src
        .
      end .
      else do :
        open query br-chk-slip-head
        for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                         and date(chk-slip-head.slip-dt) = v-date
                                         and chk-slip-head.is-report = 1
                                         and chk-slip-head.cash-num = v-cash-num
                                         and chk-slip-head.kind = v-kind
                                         and chk-slip-head.src_ = v-src
        .
      end .
    end .
  end .
    if v-date <> ? then
    do:
        if v-cash-num = ?
            or v-cash-num = 0
            then
        do :
            if v-src = 0
                then
            do :
                if v-kind = 0
                    then
                do :
                    if dateShift = ? then
                    do:
                        if numShift = 0 then
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                .
                        end.
                        else
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftNum = numShift
                                .
                        end.
                    end.
                    else
                    do:
                        if numShift = 0 then
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftDate = dateShift
                                .
                        end.
                        else
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.CashShiftNum = numShift
                                .
                        end.
                    end.
                end .
                else
                do :
                    if dateShift = ? then
                    do:
                        if numShift = 0 then
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.is-report = 1
                                .
                        end.
                        else
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftNum = numShift
                                .
                        end.
                    end.
                    else
                    do:
                        if numShift = 0 then
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftDate = dateShift
                                .
                        end.
                        else
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.CashShiftNum = numShift
                                .
                        end.
                    end.
                end .
            end .
            else
            do :
                if v-kind = 0
                    then
                do :
                    if dateShift = ? then
                    do:
                        if numShift = 0 then
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.src_ = v-src
                                .
                        end.
                        else
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.src_ = v-src
                                .
                        end.
                    end.
                    else
                    do:
                        if numShift = 0 then
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.src_ = v-src
                                .
                        end.
                        else
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.src_ = v-src
                                .
                        end.
                    end.
                end .
                else
                do :
                    if dateShift = ? then
                    do:
                        if numShift = 0 then
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.src_ = v-src
                                .
                        end.
                        else
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.src_ = v-src
                                .
                        end.
                    end.
                    else
                    do:
                        if numShift = 0 then
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.src_ = v-src
                                .
                        end.
                        else
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.src_ = v-src
                                .
                        end.
                    end.
                end .
            end .
        end .
        else
        do :
            if v-src = 0
                then
            do :
                if v-kind = 0
                    then
                do :
                    if dateShift = ? then
                    do:
                        if numShift = 0 then
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                        else
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                    end.
                    else
                    do:
                        if numShift = 0 then
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                        else
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                    end.
                end .
                else
                do :
                    if dateShift = ? then
                    do:
                        if numShift = 0 then
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                        else
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                    end.
                    else
                    do:
                        if numShift = 0 then
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                        else
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                    end.
                end .
            end .
            else
            do :
                if v-kind = 0
                    then
                do :
                    if dateShift = ? then
                    do:
                        if numShift = 0 then
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.src_ = v-src
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                        else
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.src_ = v-src
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                    end.
                    else
                    do:
                        if numShift = 0 then
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.src_ = v-src
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                        else
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.src_ = v-src
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                    end.
                end .
                else
                do :
                    if dateShift = ? then
                    do:
                        if numShift = 0 then
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.src_ = v-src
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                        else
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.src_ = v-src
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                    end.
                    else
                    do:
                        if numShift = 0 then
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.src_ = v-src
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                        else
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.src_ = v-src
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                    end.
                end .
            end .
        end .
    end.
    else
    do:
        if v-cash-num = ?
            or v-cash-num = 0
            then
        do :
            if v-src = 0
                then
            do :
                if v-kind = 0
                    then
                do :
                    if dateShift = ? then
                    do:
                        if numShift = 0 then
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                .
                        end.
                        else
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftNum = numShift
                                .
                        end.
                    end.
                    else
                    do:
                        if numShift = 0 then
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftDate = dateShift
                                .
                        end.
                        else
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.CashShiftNum = numShift
                                .
                        end.
                    end.
                end .
                else
                do :
                    if dateShift = ? then
                    do:
                        if numShift = 0 then
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.is-report = 1
                                .
                        end.
                        else
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftNum = numShift
                                .
                        end.
                    end.
                    else
                    do:
                        if numShift = 0 then
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftDate = dateShift
                                .
                        end.
                        else
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.CashShiftNum = numShift
                                .
                        end.
                    end.
                end .
            end .
            else
            do :
                if v-kind = 0
                    then
                do :
                    if dateShift = ? then
                    do:
                        if numShift = 0 then
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.src_ = v-src
                                .
                        end.
                        else
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.src_ = v-src
                                .
                        end.
                    end.
                    else
                    do:
                        if numShift = 0 then
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.src_ = v-src
                                .
                        end.
                        else
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.src_ = v-src
                                .
                        end.
                    end.
                end .
                else
                do :
                    if dateShift = ? then
                    do:
                        if numShift = 0 then
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.src_ = v-src
                                .
                        end.
                        else
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.src_ = v-src
                                .
                        end.
                    end.
                    else
                    do:
                        if numShift = 0 then
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.src_ = v-src
                                .
                        end.
                        else
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.src_ = v-src
                                .
                        end.
                    end.
                end .
            end .
        end .
        else
        do :
            if v-src = 0
                then
            do :
                if v-kind = 0
                    then
                do :
                    if dateShift = ? then
                    do:
                        if numShift = 0 then
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                        else
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                    end.
                    else
                    do:
                        if numShift = 0 then
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                        else
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                    end.
                end .
                else
                do :
                    if dateShift = ? then
                    do:
                        if numShift = 0 then
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                        else
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                    end.
                    else
                    do:
                        if numShift = 0 then
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                        else
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                    end.
                end .
            end .
            else
            do :
                if v-kind = 0
                    then
                do :
                    if dateShift = ? then
                    do:
                        if numShift = 0 then
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.src_ = v-src
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                        else
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.src_ = v-src
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                    end.
                    else
                    do:
                        if numShift = 0 then
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.src_ = v-src
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                        else
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.src_ = v-src
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                    end.
                end .
                else
                do :
                    if dateShift = ? then
                    do:
                        if numShift = 0 then
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.src_ = v-src
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                        else
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.src_ = v-src
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                    end.
                    else
                    do:
                        if numShift = 0 then
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.src_ = v-src
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                        else
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.src_ = v-src
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                    end.
                end .
            end .
        end .
    end.
end procedure .
procedure print-rep :
  define buffer chk-slip-string for ub.chk-slip-string .
  define variable v-file-name as character no-undo.
  define variable vok as logical no-undo.
  define variable ii as integer no-undo .
  define variable v-slip-txt as character no-undo .
  define variable v-slip-txt-list as character no-undo .
  define variable cmd as character no-undo .
  SYSTEM-DIALOG GET-FILE v-file-name
      TITLE "Сохранить как"
      FILTERS
        " Файл PDF(*.pdf) " "*.pdf",
        " Все файлы (*.*) " "*.*"
      ask-overwrite
      save-as
      use-filename
      update vok
      default-extension "pdf"
      .
  if not vok THEN do:
    return .
  end.
  v-slip-txt-list = "" .
  get first br-chk-slip-head .
  v-slip-txt = "slip_" + string(time) .
  output stream out-slip to value(v-slip-txt)  .
  repeat while available chk-slip-head:
      for each chk-slip-string no-lock where chk-slip-string.db-num = chk-slip-head.db-num
                                         and chk-slip-string.ID = chk-slip-head.ID
                                         and chk-slip-string.CheckID = chk-slip-head.CheckId
                                         and chk-slip-string.RRN = chk-slip-head.RRN
                                         and chk-slip-string.str-num < 10000
                                         by chk-slip-string.str-num
                                         :
        put stream out-slip unformatted chk-slip-string.str-value skip .
      end .
    get next br-chk-slip-head .
  end .
  output stream out-slip close .
  define variable v-extprog-retval as character no-undo .
      run gbl/extprog.p
        (input  'exec':U
        ,input  'txt2pdf':U
        ,input  v-slip-txt
        ,input  v-file-name
        ,input  ""
        ,output v-extprog-retval
        ) .
    do ii = 1 to num-entries(v-slip-txt-list) :
        v-slip-txt = entry(ii, v-slip-txt-list) .
        os-delete value(v-slip-txt) no-error .
    end .
end procedure .
PROCEDURE disable_UI :
    HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
    DISPLAY v-cash-num v-src v-kind numShift v-date dateShift
        WITH FRAME Dialog-Frame.
    ENABLE b-exit b-print1 v-cash-num b-cd v-src v-kind numShift v-date
        b-choose-date dateShift b-choose-shift br-chk-slip-head
        WITH FRAME Dialog-Frame.
    VIEW FRAME Dialog-Frame.
END PROCEDURE.
