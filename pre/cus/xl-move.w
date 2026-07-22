define input parameter parParentProc  as widget-handle no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Движение по товарам".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable g#report-num as integer   no-undo .
run get-report-num  in parParentProc ( output g#report-num ).
define variable g#log as logical   no-undo .
define variable type-par1 as character no-undo .
define variable tmp-var1  as character no-undo .
define variable p-XL-delim as character no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input v-cntxt-obj-type
  ,input v-cntxt-obj-code
  ,input 'report-firm':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'XL-delim'  then tmp-var1   = thbjattr_thbj-attr.property-value-character.
end.
IF tmp-var1 = "" then p-XL-delim = ";".
else p-XL-delim = tmp-var1.
define temp-table temp_result no-undo
       field cli-type       like ub.trn-doc.cli-type
       field cli-code       like ub.trn-doc.cli-code
       field cli-name       like ub.trn-doc.cli-name
       field rem-beg        as decimal
       field rem-beg-sum    as decimal
       field rem-end        as decimal
       field rem-end-sum    as decimal
       field inp            as decimal
       field sum-in         as decimal
       field outp           as decimal
       field sum-out        as decimal
       field rac            as decimal
       field sum-rac        as decimal
       index code is unique primary
           cli-type
           cli-code
       index name
           cli-name
       .
define temp-table gds-tbl no-undo
       field artic          like ub.doc-line.artic
       field prod-type  like ub.goods.prod-type
       field prod-code like ub.goods.prod-code
       field price as dec
   index art is unique primary
       artic
       prod-type
       prod-code
       .
define variable beg-date    as date     no-undo.
define variable end-date    as date     no-undo.
define variable var-date    as date     no-undo.
define variable v-counter   as integer  no-undo.
define stream out-stream.
DEFINE BUTTON b-entry DEFAULT
     LABEL "&Сбор данных"
     SIZE 12.5 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY DEFAULT
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE enddate AS DATE FORMAT "99/99/9999":U
     LABEL "По"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE fi-counter AS INTEGER FORMAT "->>>>>>>>9":U INITIAL 0
     LABEL "Обработано товаров"
     VIEW-AS FILL-IN
     SIZE 14 BY 1
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE startdate AS DATE FORMAT "99/99/9999":U
     LABEL "С"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE FRAME xl-ob
     b-quit AT ROW 1 COL 1
     b-entry AT ROW 1 COL 11
     b-help AT ROW 1 COL 27.5
     startdate AT ROW 2.75 COL 4 COLON-ALIGNED
     enddate AT ROW 2.75 COL 22.25 COLON-ALIGNED
     fi-counter AT ROW 4.29 COL 20.88 COLON-ALIGNED
     SPACE(0.74) SKIP(2.20)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Движение по товарам"
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME xl-ob:SCROLLABLE       = FALSE.
ASSIGN
       fi-counter:HIDDEN IN FRAME xl-ob           = TRUE.
ON CHOOSE OF b-entry IN FRAME xl-ob
DO:
    assign
        startdate
        enddate
    .
    if (startdate <> ? and enddate <> ?)
    and startdate <= enddate
    then do:
        assign
            beg-date = startdate
            end-date = enddate
        .
        run calc-oborot in this-procedure no-error.
        if error-status :error
        then do:
            message
              vss-workfile vss-revision vss-description
              skip "Ошибка при расчете оборотов."
              skip return-value
              skip trim(error-status :get-message(1))
                   trim(error-status :get-message(2))
                   trim(error-status :get-message(3))
                   trim(error-status :get-message(4))
                   trim(error-status :get-message(5))
            view-as alert-box error.
            undo, return no-apply .
        end.
        run print-result in this-procedure no-error.
        if error-status :error
        then do:
            message
              vss-workfile vss-revision vss-description
              skip "Ошибка при выводе в файл."
              skip return-value
              skip trim(error-status :get-message(1))
                   trim(error-status :get-message(2))
                   trim(error-status :get-message(3))
                   trim(error-status :get-message(4))
                   trim(error-status :get-message(5))
            view-as alert-box error.
            undo, return no-apply .
        end.
        message " Отчет завершен " view-as alert-box information buttons ok.
        hide fi-counter in frame xl-ob.
     end.
     else if startdate = ? then do:
         message "Не задана дата C". pause.
     end.
     else if enddate = ? then do:
         message "Не задана дата По". pause.
     end.
     else if startdate > enddate then do:
         message "Дата начала периода должна быть меньше даты конца". pause.
     end.
END.
ON RETURN OF enddate IN FRAME xl-ob
DO:
    APPLY "ENTRY" TO b-entry IN FRAME xl-ob.
    RETURN NO-APPLY.
END.
ON RETURN OF startdate IN FRAME xl-ob
DO:
    APPLY "ENTRY" TO enddate IN FRAME xl-ob.
    RETURN NO-APPLY.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME xl-ob:PARENT eq ?
THEN FRAME xl-ob:PARENT = ACTIVE-WINDOW.
ON WINDOW-CLOSE OF FRAME xl-ob APPLY "END-ERROR":U TO SELF.
assign
    startdate = date( month( today ), 1, year( today ) )
    enddate = today .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame xl-ob
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
on choose of b-help in frame xl-ob
do:
  apply "help":u to frame xl-ob .
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
                v-frame-width = frame xl-ob:width - 0.3
                fh            = frame xl-ob:first-child
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
  if session:set-wait-state("COMPILER") then.
  run enable_ui.
  if session:set-wait-state("") then.
  APPLY "ENTRY" TO startdate IN FRAME xl-ob.
  WAIT-FOR GO OF FRAME xl-ob.
END.
run disable_ui.
PROCEDURE calc-oborot :
do
on error undo, return error
:
define variable v-ext-doc-type-list  as char format "X(25)" extent 36 init
  [
       "приход внешний",                                   'ie':U,
       "расход внешний",                                   'ee':U,
       "расход внешний возврат поставщику",                'ep':U,
       "расход внешний продажа через кассу",               'es':U,
       "возврат внешний",                                  're':U,
       "возврат внешний через кассу",                      'rs':U,
       "списание внешнее",                                 'we':U,
       "инвентаризация",                                   'vt':U,
       "коррекция учетных цен",                            'ap':U,
       "смена типа приобретения",                          'pc':U,
       "корретировка отрицательных партий",                'mp':U,
       "приход перемещение",                               'iv':U,
       "расход перемещение",                               'ev':U,
       "возврат перемещение",                              'rv':U,
       "списание производство",                            'wm':U,
       "приход производство",                              'im':U,
       "документ переоценки",                              'ot':U,
       "пересортица",                                      'vp':U
  ]
no-undo.
define variable v-fact-order-from like ub.ot-line.fact-order      no-undo.
define variable v-fact-order-to   like ub.ot-line.fact-order      no-undo.
define variable v-oper-num        as integer                      no-undo.
define variable v-docs-exists     as logical           no-undo.
define variable v-ext-doc-type    as character         no-undo.
define variable v-counter         as integer           no-undo.
define variable v-stk-start      as decimal      no-undo.
define variable v-sum-start      as decimal      no-undo.
define variable v-stk-end        as decimal      no-undo.
define variable v-sum-end        as decimal      no-undo.
define variable v-income         as decimal      no-undo.
define variable v-sum-income     as decimal      no-undo.
define variable v-expense        as decimal      no-undo.
define variable v-sum-expence    as decimal      no-undo.
define variable v-kass           as decimal      no-undo.
define variable v-sum-kass       as decimal      no-undo.
define buffer buf_stk-line       for ub.stk-line.
run rep/get-fo.p (
               input v-cntxt-obj-type
             , input v-cntxt-obj-code
             , input beg-date
             , input end-date
             , output v-fact-order-from
             , output v-fact-order-to
             , output v-docs-exists
             ).
for each ub.gds-obj no-lock
   where ub.gds-obj.obj-type      = v-cntxt-obj-type
     and ub.gds-obj.obj-code      = v-cntxt-obj-code
break   by ub.gds-obj.artic
        by ub.gds-obj.prod-type
        by ub.gds-obj.prod-code
:
if first-of( ub.gds-obj.prod-code )
then do:
    assign
        v-counter = v-counter + 1
    .
    if ( v-counter modulo 25 ) = 0
    then do:
        view fi-counter in frame xl-ob.
        assign
            fi-counter :screen-value in frame xl-ob = string( v-counter )
        .
    end.
    find last buf_stk-line no-lock
        where buf_stk-line.obj-type      = ub.gds-obj.obj-type
          and buf_stk-line.obj-code      = ub.gds-obj.obj-code
          and buf_stk-line.artic         = ub.gds-obj.artic
          and buf_stk-line.prod-type     = ub.gds-obj.prod-type
          and buf_stk-line.prod-code     = ub.gds-obj.prod-code
          and buf_stk-line.sum-type      = 'crsa':U
          and buf_stk-line.cat-id        = '##,##':U
          and buf_stk-line.fact-order    <=  v-fact-order-from
    no-error.
    if not available buf_stk-line
    then do:
        assign
            v-stk-start = 0
            v-sum-start = 0
        .
    end.
    else do:
        assign
            v-stk-start = buf_stk-line.fact-qnty
            v-sum-start = buf_stk-line.sum-base
        .
    end.
    find last buf_stk-line no-lock
        where buf_stk-line.obj-type      = ub.gds-obj.obj-type
          and buf_stk-line.obj-code      = ub.gds-obj.obj-code
          and buf_stk-line.artic         = ub.gds-obj.artic
          and buf_stk-line.prod-type     = ub.gds-obj.prod-type
          and buf_stk-line.prod-code     = ub.gds-obj.prod-code
          and buf_stk-line.sum-type      = 'crsa':U
          and buf_stk-line.cat-id        = '##,##':U
          and buf_stk-line.fact-order    <=  v-fact-order-to
    no-error.
    if not available buf_stk-line
    then do:
        assign
            v-stk-end = v-stk-start
            v-sum-end = v-sum-start
        .
    end.
    else do:
        assign
            v-stk-end = buf_stk-line.fact-qnty
            v-sum-end = buf_stk-line.sum-base
        .
    end.
    run update-temp-result in this-procedure (
              input ub.gds-obj.obj-type
            , input ub.gds-obj.obj-code
            , input v-stk-start
            , input v-sum-start
            , input v-stk-end
            , input v-sum-end
            , input 0
            , input 0
            , input 0
            , input 0
            , input 0
            , input 0
    ).
    do v-oper-num = 1 to 14
    :
        assign
            v-ext-doc-type = v-ext-doc-type-list [v-oper-num * 2]
        .
        for each buf_stk-line no-lock
           where buf_stk-line.obj-type      = ub.gds-obj.obj-type
             and buf_stk-line.obj-code      = ub.gds-obj.obj-code
             and buf_stk-line.artic         = ub.gds-obj.artic
             and buf_stk-line.prod-type     = ub.gds-obj.prod-type
             and buf_stk-line.prod-code     = ub.gds-obj.prod-code
             and ( buf_stk-line.sum-type      = 'cgdt':U         + v-ext-doc-type
                or buf_stk-line.sum-type      = 'gdsr':U + v-ext-doc-type
                 )
             and buf_stk-line.cat-id        = '##,##':U
             and buf_stk-line.fact-order    >  v-fact-order-from
             and buf_stk-line.fact-order    <= v-fact-order-to
        :
            case v-ext-doc-type
            :
            when 'ie':U or when 'iv':U or when 'im':U
            then do:
                assign
                    v-income      = buf_stk-line.fact-qnty
                    v-sum-income  = buf_stk-line.sum-base
                    v-expense     = 0
                    v-sum-expence = 0
                    v-kass        = 0
                    v-sum-kass    = 0
                .
            end.
            when 'ee':U or when 'ep':U or when 're':U
            or when 'we':U or when 'ev':U or when 'rv':U
            or when 'wm':U
            then do:
                assign
                    v-income      = 0
                    v-sum-income  = 0
                    v-expense     = buf_stk-line.fact-qnty
                    v-sum-expence = buf_stk-line.sum-base
                    v-kass        = 0
                    v-sum-kass    = 0
                .
            end.
            when 'es':U or when 'rs':U
            then do:
                assign
                    v-income      = 0
                    v-sum-income  = 0
                    v-expense     = 0
                    v-sum-expence = 0
                    v-kass        = buf_stk-line.fact-qnty
                    v-sum-kass    = buf_stk-line.sum-base
                .
            end.
            when 'vt':U or when 'ot':U or when 'vp':U
            then do:
                if buf_stk-line.sum-base > 0
                then do:
                    assign
                        v-income      = buf_stk-line.fact-qnty
                        v-sum-income  = buf_stk-line.sum-base
                        v-expense     = 0
                        v-sum-expence = 0
                    .
                end.
                else do:
                    assign
                        v-income      = 0
                        v-sum-income  = 0
                        v-expense     = buf_stk-line.fact-qnty
                        v-sum-expence = buf_stk-line.sum-base
                    .
                end.
                assign
                    v-kass        = 0
                    v-sum-kass    = 0
                .
            end.
            end case.
            run update-temp-result in this-procedure (
                    input buf_stk-line.prod-type
                  , input buf_stk-line.prod-code
                  , input 0
                  , input 0
                  , input 0
                  , input 0
                  , input v-income
                  , input v-sum-income
                  , input v-expense
                  , input v-sum-expence
                  , input v-kass
                  , input v-sum-kass
            ).
        end.
    end.
end.
end.
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME xl-ob.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY startdate enddate
      WITH FRAME xl-ob.
  ENABLE b-quit b-entry b-help startdate enddate
      WITH FRAME xl-ob.
END PROCEDURE.
PROCEDURE print-result :
do
on error undo, return error
:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable ReportFileName as character no-undo initial "report".
define variable was_OK_opened  as logical   no-undo.
system-dialog get-file          ReportFileName
              title             "Укажите путь"
              filters           "Текстовый файл (*.txt)" "*.txt"
              ask-overwrite
              create-test-file
              save-as
              use-filename
              default-extension "txt"
              update            was_OK_opened.
if was_OK_opened <> yes then do: return "Cancel". end.
assign ReportFileName = trim( string( ReportFileName ) ).
output stream out-stream to value ( ReportFileName ) page-size 0  .
if session :set-wait-state( "compiler" ) then.
    export stream out-stream
        p-xl-delim "" "Отчет по движению товаров"
    .
    put stream out-stream unformatted " " skip.
    find first ub.clients no-lock
            where ub.clients.obj-type  = v-cntxt-obj-type
            and ub.clients.obj-code  = v-cntxt-obj-code
    no-error.
    if not available ub.clients
    then do:
        message
            vss-workfile vss-revision vss-description
            skip "Ошибка поиска объекта."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
                trim(error-status :get-message(4))
                trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.
    export stream out-stream p-xl-delim
        "Магазин/Склад   "
        string(v-cntxt-obj-code, ">>>>>>>>9")
        ub.clients.obj-name
    .
    export stream out-stream p-xl-delim
        "Отчетный период"
        "С:" string(startdate, "99/99/9999")
        "По:" string(enddate, "99/99/9999")
    .
    put stream out-stream unformatted " " skip.
    export stream out-stream p-xl-delim
        "Фирма"
        "Остаток на " string(startdate - 1, "99/99/9999")
        "Приход"                                         " "
        "Расход"                                          " "
        "Реализация"                                   " "
        "Остаток на " string(enddate, "99/99/9999")
    .
    export stream out-stream p-xl-delim
        " "
        "шт"  "Сумма, руб"
        "шт"  "Сумма, руб"
        "шт"  "Сумма, руб"
        "шт"  "Сумма, руб"
        "шт"  "Сумма, руб"
    .
    assign
        v-counter = 0
    .
    for each temp_result
    use-index  name
    :
        assign
            v-counter = v-counter + 1
        .
        EXPORT stream out-stream p-xl-delim
            temp_result.cli-name
            temp_result.rem-beg
            temp_result.rem-beg-sum
            temp_result.inp
            temp_result.sum-in
            temp_result.outp
            temp_result.sum-out
            temp_result.rac
            temp_result.sum-rac
            temp_result.rem-end
            temp_result.rem-end-sum
        .
        ACCUMULATE temp_result.rem-beg     ( TOTAL ).
        ACCUMULATE temp_result.rem-beg-sum ( TOTAL ).
        ACCUMULATE temp_result.inp         ( TOTAL ).
        ACCUMULATE temp_result.sum-in      ( TOTAL ).
        ACCUMULATE temp_result.outp        ( TOTAL ).
        ACCUMULATE temp_result.sum-out     ( TOTAL ).
        ACCUMULATE temp_result.rac         ( TOTAL ).
        ACCUMULATE temp_result.sum-rac     ( TOTAL ).
        ACCUMULATE temp_result.rem-end     ( TOTAL ).
        ACCUMULATE temp_result.rem-end-sum ( TOTAL ).
    end.
    export stream out-stream p-xl-delim
        "ИТОГО  "
        ACCUM TOTAL temp_result.rem-beg
        ACCUM TOTAL temp_result.rem-beg-sum
        ACCUM TOTAL temp_result.inp
        ACCUM TOTAL temp_result.sum-in
        ACCUM TOTAL temp_result.outp
        ACCUM TOTAL temp_result.sum-out
        ACCUM TOTAL temp_result.rac
        ACCUM TOTAL temp_result.sum-rac
        ACCUM TOTAL temp_result.rem-end
        ACCUM TOTAL temp_result.rem-end-sum
    .
    put stream out-stream unformatted " " skip.
    export stream out-stream p-xl-delim
        "Директор Магазина/Склада "    " "  " "  " "  " "
        "Дата составления отчета "
            string( today , "99/99/9999")
    .
    export stream out-stream p-xl-delim
        "Управляющий салоном/Старший товаровед"
    .
if session :set-wait-state( "" ) then.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
output stream out-stream CLOSE.
message "Отчет выведен в файл:" SKIP
                ReportFileName
                view-as alert-box INFORMATION buttons OK TITLE " ".
end.
END PROCEDURE.
PROCEDURE update-temp-result :
do
on error undo, return error
:
define input parameter p-prod-type      as character    no-undo.
define input parameter p-prod-code      as integer      no-undo.
define input parameter p-stk-start      as decimal      no-undo.
define input parameter p-sum-start      as decimal      no-undo.
define input parameter p-stk-end        as decimal      no-undo.
define input parameter p-sum-end        as decimal      no-undo.
define input parameter p-income         as decimal      no-undo.
define input parameter p-sum-income     as decimal      no-undo.
define input parameter p-expense        as decimal      no-undo.
define input parameter p-sum-expence    as decimal      no-undo.
define input parameter p-kass           as decimal      no-undo.
define input parameter p-sum-kass       as decimal      no-undo.
define variable v-cli-name as character    no-undo.
define buffer buf_clients        for ub.clients.
    find first temp_result
            where temp_result.cli-type = p-prod-type
              and temp_result.cli-code = p-prod-code
    no-error.
    if not available temp_result
    then do:
        create temp_result.
        find first buf_clients no-lock
             where buf_clients.obj-type = p-prod-type
               and buf_clients.obj-code = p-prod-code
        no-error.
        if not available buf_clients
        then do:
                message
                vss-workfile vss-revision vss-description
                skip "Не найден производитель."
                skip "Тип производителя:" p-prod-type
                skip "Код производителя:" p-prod-code
                skip(1) "Имя производителя будет образовано"
                skip "из типа и кода:" p-prod-type + string( p-prod-code )
                skip(1) return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
                    trim(error-status :get-message(4))
                    trim(error-status :get-message(5))
                view-as alert-box warning.
                assign
                    v-cli-name = p-prod-type + string( p-prod-code )
                .
        end.
        else do:
            assign
                v-cli-name = buf_clients.obj-name
            .
        end.
        assign
            temp_result.cli-type    = p-prod-type
            temp_result.cli-code    = p-prod-code
            temp_result.cli-name    = v-cli-name
            temp_result.rem-beg     = 0
            temp_result.rem-beg-sum = 0
            temp_result.rem-end     = 0
            temp_result.rem-end-sum = 0
            temp_result.inp         = 0
            temp_result.sum-in      = 0
            temp_result.outp        = 0
            temp_result.sum-out     = 0
            temp_result.rac         = 0
            temp_result.sum-rac     = 0
        .
    end.
    assign
        temp_result.rem-beg     = temp_result.rem-beg       + p-stk-start
        temp_result.rem-beg-sum = temp_result.rem-beg-sum   + p-sum-start
        temp_result.rem-end     = temp_result.rem-end       + p-stk-end
        temp_result.rem-end-sum = temp_result.rem-end-sum   + p-sum-end
        temp_result.inp         = temp_result.inp           + p-income
        temp_result.sum-in      = temp_result.sum-in        + p-sum-income
        temp_result.outp        = temp_result.outp          + p-expense
        temp_result.sum-out     = temp_result.sum-out       + p-sum-expence
        temp_result.rac         = temp_result.rac           + p-kass
        temp_result.sum-rac     = temp_result.sum-rac       + p-sum-kass
    .
end.
END PROCEDURE.
