DEFINE BUFFER locked_scales FOR ub.scales.
DEFINE TEMP-TABLE tt-scales NO-UNDO LIKE ub.scales.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-mode as char no-undo .
define input parameter p-db-num like ub.db.db-nu  no-undo .
define input parameter p-scales-num like ub.scales.scales-num no-undo .
define output parameter p-rid as recid no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка весов".
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
define buffer b-scales for ub.scales .
define variable ini-types as char no-undo init ?.
define variable ini-model as char no-undo .
define variable ii as int no-undo .
define variable glog as logical no-undo .
define variable v-rid as recid no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
DEFINE BUTTON b-attr
     LABEL "&Атрибуты"
     SIZE 10 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON r-base
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 72.75 BY 16.25.
DEFINE VARIABLE S-type AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
     SIZE 18.25 BY 9
     BGCOLOR 15  NO-UNDO.
DEFINE QUERY d-scalesi FOR
      ub.scales,
      tt-scales SCROLLING.
DEFINE FRAME d-scalesi
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     b-attr AT ROW 1 COL 37
     B-help AT ROW 1 COL 73
     tt-scales.scales-num AT ROW 3 COL 14.88 COLON-ALIGNED
          LABEL "Номер"
          VIEW-AS FILL-IN
          SIZE 7 BY 1
     tt-scales.master AT ROW 4.25 COL 14.88 COLON-ALIGNED
          LABEL "Главные"
          VIEW-AS FILL-IN
          SIZE 6.75 BY 1
     tt-scales.scales-name AT ROW 5.5 COL 14.88 COLON-ALIGNED
          LABEL "Название"
          VIEW-AS FILL-IN
          SIZE 31.38 BY 1
     S-type AT ROW 6.75 COL 17 NO-LABEL
     tt-scales.max-gds AT ROW 7 COL 62 COLON-ALIGNED
          LABEL "Максимальная номенклатура"
          VIEW-AS FILL-IN
          SIZE 6 BY 1.13
     tt-scales.address AT ROW 16 COL 14.88 COLON-ALIGNED
          LABEL "Адрес"
          VIEW-AS FILL-IN
          SIZE 38.13 BY 1
     tt-scales.unit-base AT ROW 17.25 COL 35.88 COLON-ALIGNED
          LABEL "Основная единица измерения"
          VIEW-AS FILL-IN
          SIZE 4.88 BY 1.08
     r-base AT ROW 17.25 COL 44
     " Тип" VIEW-AS TEXT
          SIZE 8 BY 1 AT ROW 7.33 COL 7.63
     RECT-1 AT ROW 2.25 COL 2.38
     SPACE(1.11) SKIP(0.25)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "  Весы"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit.
ASSIGN
       FRAME d-scalesi:SCROLLABLE       = FALSE
       FRAME d-scalesi:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME d-scalesi
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-attr IN FRAME d-scalesi
DO:
    run ref/scl-atti.w ( INPUT parparentproc
                  ,INPUT   'ПРОСМОТР':U
                  ,INPUT tt-scales.db-num
                  ,INPUT tt-scales.scales-num
                 ) NO-ERROR.
END.
ON CHOOSE OF B-exit IN FRAME d-scalesi
DO:
RUN proc-save IN THIS-PROCEDURE no-error.
IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF r-base IN FRAME d-scalesi
DO:
  define variable ref-rec as recid no-undo .
  DEFINE BUFFER buf_units FOR ub.units.
    run ref/units.w ( input parparentproc, input yes, output ref-rec ).
    if ref-rec = ? THEN do:
            apply "entry" to r-base in frame d-scalesi.
            return no-apply.
    end.
    FIND buf_units WHERE recid (buf_units) = ref-rec NO-LOCK.
    if lookup('вес':U, buf_units.type) = 0 then do:
        message "Вы выбрали невесовую единицу измерения!" view-as alert-box ERROR.
        apply "entry" to r-base in frame d-scalesi.
        return no-apply.
    end.
    DISPLAY
    buf_units.unit-name @ tt-scales.unit-base
    with frame d-scalesi.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-scalesi:PARENT eq ?
THEN FRAME d-scalesi:PARENT = ACTIVE-WINDOW.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-scalesi
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
on choose of b-help in frame d-scalesi
do:
  apply "help":u to frame d-scalesi .
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
                v-frame-width = frame d-scalesi:width - 0.3
                fh            = frame d-scalesi:first-child
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
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON STOP UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   :
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
   IF p-mode <> 'ИЗМЕНЕНИЕ':U
   AND p-mode <> 'ДОБАВЛЕНИЕ':U THEN DO:
      MESSAGE
      substitute("Неверное значение параметра p-mode = &1", p-mode)
      VIEW-AS ALERT-BOX ERROR.
      RETURN ERROR.
   END.
   if p-db-num <> v-cntxt-db-num
   and (p-mode = 'ДОБАВЛЕНИЕ':U
        or
        p-mode = 'ИЗМЕНЕНИЕ':U)
   then do:
    message
    "Нельзя изменять/добавлять ВЕСЫ в чужой БД"
    view-as alert-box error .
    undo, return error .
   end.
    run adm/shattri.p (
        input "get":U
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  'scale-inf':U
      ,input  'scales-type':U
      , output v-value-character
      , output v-value-date
      , output v-value-decimal
      , output v-value-integer
      , output v-value-logical
      , output v-param-type
      , INPUT-OUTPUT table-handle v-tth
      ) no-error .
    IF error-status:error then do:
      delete object v-tth.
        message
        substitute("Ошибка при получении настроек, необъодимых для работы весов НА ОБЪЕКТЕ &1&2:&3&4 &5"
                , p-obj-type
                , p-obj-code
                , chr(10)
                , error-status:get-message(1)
                , return-value )
        view-as alert-box error .
        undo, return error .
    end.
    delete object v-tth.
    assign
    ini-types =  v-value-character.
    if ini-types = ?
    or ini-types = '':U then do:
      message
      'Ошибка! Не заданы используемые типы весов!' SKIP
      'АРМ Администратор-Справочники-Магазины-Параметры-Опции работы с весами'
      view-as alert-box error .
      return error .
    end.
    IF p-mode = 'ИЗМЕНЕНИЕ':U THEN DO:
        FIND FIRST LOCKED_scales exclusive-LOCK WHERE
                 LOCKED_scales.db-num = p-db-num
             AND LOCKED_scales.scales-num = p-scales-num .
      v-rid = recid(locked_scales).
    END.
    if p-mode = 'ИЗМЕНЕНИЕ':U then do:
        glog = no.
        DO ii = 1 TO num-entries( ini-types ) :
            if entry(ii, ini-types) = locked_scales.scales-type then glog = yes.
        END .
      if not glog then do:
        message
        substitute("Ошибка! В списке используемых весов&1"  +
                   "нет типа весов &2!", LOCKED_scales.scales-type)
        view-as alert-box error .
        return error .
      end.
    end.
    S-Type:list-items = ini-types .
    if can-do( 'ДОБАВЛЕНИЕ':U, p-mode ) then do:
        CREATE tt-scales.
        assign
        tt-scales.max-gds = 999
        tt-scales.scales-type = entry( 1, ini-types )
        tt-scales.address = "COM1"
        tt-scales.db-num  = p-db-num
        tt-scales.sts     = integer('0':U)
        frame d-scalesi:title = substitute("&1    - &2"
                                               ,frame d-scalesi:title
                                               ,'ДОБАВЛЕНИЕ':U) .
    end.
    else do:
        CREATE tt-scales.
        BUFFER-COPY locked_scales TO tt-scales.
        frame d-scalesi:title = substitute("&1    - &2"
                                               ,frame d-scalesi:title
                                               ,'ИЗМЕНЕНИЕ':U) .
   end.
    RUN MyEnable IN THIS-PROCEDURE.
    if S-Type:num-items < 2 then
        S-Type:inner-lines = 1 .
    S-Type:screen-value = tt-scales.scales-type .
    glog = S-Type:scroll-to-item ( tt-scales.scales-type ) .
    if can-do( 'ДОБАВЛЕНИЕ':U, p-mode ) then
        WAIT-FOR GO OF FRAME d-scalesi focus tt-scales.scales-num.
    else
        WAIT-FOR GO OF FRAME d-scalesi focus tt-scales.scales-name .
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME d-scalesi.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY S-type
      WITH FRAME d-scalesi.
  IF AVAILABLE tt-scales THEN
    DISPLAY tt-scales.scales-num tt-scales.master tt-scales.scales-name
          tt-scales.max-gds tt-scales.address tt-scales.unit-base
      WITH FRAME d-scalesi.
  ENABLE B-exit B-quit b-attr B-help RECT-1 tt-scales.scales-num
         tt-scales.master tt-scales.scales-name S-type tt-scales.max-gds
         tt-scales.address tt-scales.unit-base r-base
      WITH FRAME d-scalesi.
  VIEW FRAME d-scalesi.
END PROCEDURE.
PROCEDURE MyEnable :
IF AVAILABLE tt-scales THEN do:
    if tt-scales.master = 0 and LOOKUP('ДОБАВЛЕНИЕ':U, p-mode) = 0 then
    HIDE tt-scales.master
    IN frame d-scalesi.
    ELSE
    DISPLAY
    tt-scales.master
    WITH FRAME d-scalesi.
    DISPLAY
    tt-scales.max-gds
    tt-scales.scales-num
    tt-scales.scales-name
    tt-scales.address
    tt-scales.unit-base
    S-Type
    WITH FRAME d-scalesi.
end.
ENABLE
tt-scales.max-gds WHEN not(lookup('ИЗМЕНЕНИЕ':U, p-mode) > 0 and tt-scales.master > 0)
b-exit
b-quit
b-help
r-base WHEN not(lookup('ИЗМЕНЕНИЕ':U, p-mode) > 0 and tt-scales.master > 0)
tt-scales.scales-num WHEN can-do( 'ДОБАВЛЕНИЕ':U, p-mode )
tt-scales.master WHEN  can-do( 'ДОБАВЛЕНИЕ':U, p-mode )
tt-scales.scales-name
tt-scales.address
tt-scales.unit-base WHEN not(lookup('ИЗМЕНЕНИЕ':U, p-mode) > 0 and tt-scales.master > 0)
S-Type WHEN not(lookup('ИЗМЕНЕНИЕ':U, p-mode) > 0 and tt-scales.master > 0)
b-attr when p-mode <> 'ДОБАВЛЕНИЕ':U
WITH FRAME d-scalesi.
VIEW FRAME d-scalesi.
END PROCEDURE.
PROCEDURE proc-save :
define variable choice as log no-undo .
define buffer b-scales-gds for ub.scales-gds.
define buffer b-scales-grp for ub.scales-grp.
ASSIGN FRAME d-scalesi
tt-scales.scales-num
tt-scales.scales-name
tt-scales.address
tt-scales.unit-base
tt-scales.master
tt-scales.max-gds
s-type
tt-scales.scales-type = s-type
.
if p-mode = 'ИЗМЕНЕНИЕ':U then p-rid = recid(locked_scales).
run ref/scales1.p (
 input-output p-rid
,input p-mode
,INPUT NO
,input tt-scales.db-num
,input tt-scales.scales-num
,input tt-scales.address
,input tt-scales.master
,input tt-scales.max-gds
,input tt-scales.scales-name
,input tt-scales.scales-type
,input tt-scales.remote
,input tt-scales.sts
,input tt-scales.unit-base
,input tt-scales.wt-cart
) no-error .
if error-status:error then do:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable rv as character no-undo .
assign
rv = entry(1, return-value , chr(4)).
if rv <> "":U then do:
  assign
  fh = frame d-scalesi:first-child
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
END PROCEDURE.
