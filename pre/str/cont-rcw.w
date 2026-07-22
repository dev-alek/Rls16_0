def var vss-revision    as character no-undo init "$Revision$":u .
def var vss-author      as character no-undo init "$Author$":u .
def var vss-date        as character no-undo init "$Date$":u .
def var vss-workfile    as character no-undo init "$Workfile$":u .
def var vss-archive     as character no-undo init "$Archive$":u .
def var vss-description as character no-undo init "Карточка договора - реквизиты" .
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
define input  parameter parParentProc      AS WIDGET-HANDLE NO-UNDO.
define input  parameter p-host-code        as integer   no-undo .
define input  parameter p-type             as integer   no-undo .
define input  parameter ref-mode           as character no-undo .
define input  parameter p-obj-code         as integer   no-undo .
define input  parameter p-obj-type         as character no-undo .
define input-output parameter p-obj-name     as character no-undo .
define input-output parameter p-code-schet   as integer   no-undo .
define input-output parameter p-code-schet-2 as integer   no-undo .
define input-output parameter p-kpp          as character no-undo .
define input-output parameter p-inn          as character no-undo .
define input-output parameter p-addres       as character no-undo .
define input-output parameter p-sign         as character no-undo .
define input-output parameter p-sign-post    as character no-undo .
define input-output parameter p-point-io-code   as integer   no-undo .
define input-output parameter p-db-num as integer   no-undo .
define variable ri-schet    as recid  no-undo .
define variable ri-schet-2  as recid  no-undo .
define variable v-current-db-num as integer   no-undo .
define buffer buf_point-io for ub.point-io .
DEFINE BUTTON b-add
     LABEL "О&бновить"
     SIZE 10 BY 1.
DEFINE BUTTON b-bank
     LABEL "&Счет"
     SIZE 10 BY 1.
DEFINE BUTTON b-bank-2
     LABEL "С&чет"
     SIZE 10 BY 1.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Отмена":L
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-OK AUTO-GO
     LABEL "&Ввод ":L
     SIZE 10 BY 1.
DEFINE BUTTON BUTTON-point-io
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2"
     SIZE 2.88 BY 1.
DEFINE VARIABLE addres AS CHARACTER FORMAT "X(100)"
     LABEL "Адрес"
      VIEW-AS TEXT
     SIZE 61.25 BY .79.
DEFINE VARIABLE bank-name AS CHARACTER FORMAT "X(40)"
     LABEL "Банк"
      VIEW-AS TEXT
     SIZE 49.5 BY .79.
DEFINE VARIABLE bank-name-2 AS CHARACTER FORMAT "X(40)"
     LABEL "в банке"
      VIEW-AS TEXT
     SIZE 58 BY .79.
DEFINE VARIABLE bik AS CHARACTER FORMAT "X(18)"
     LABEL "БИК"
      VIEW-AS TEXT
     SIZE 23 BY .79.
DEFINE VARIABLE c-schet AS CHARACTER FORMAT "X(20)"
     LABEL "Кор.счет"
      VIEW-AS TEXT
     SIZE 29.63 BY .79.
DEFINE VARIABLE curr AS CHARACTER FORMAT "X(20)"
     LABEL "Валюта"
      VIEW-AS TEXT
     SIZE 15.38 BY .79.
DEFINE VARIABLE curr-2 AS CHARACTER FORMAT "X(20)"
     LABEL "Валюта"
      VIEW-AS TEXT
     SIZE 15.38 BY .79.
DEFINE VARIABLE point-io-name AS CHARACTER FORMAT "X(56)":U
     VIEW-AS FILL-IN
     SIZE 35 BY 1 NO-UNDO.
DEFINE VARIABLE inn AS CHARACTER FORMAT "X(15)"
     LABEL ""
      VIEW-AS TEXT
     SIZE 28.25 BY .79.
DEFINE VARIABLE kpp AS CHARACTER FORMAT "X(15)"
     LABEL ""
      VIEW-AS TEXT
     SIZE 28.25 BY .79.
DEFINE VARIABLE name AS CHARACTER FORMAT "X(40)"
     LABEL "Наименование"
      VIEW-AS TEXT
     SIZE 41 BY .79.
DEFINE VARIABLE r-schet AS CHARACTER FORMAT "X(20)"
     LABEL "Рас.счет"
      VIEW-AS TEXT
     SIZE 27.5 BY .79.
DEFINE VARIABLE r-schet-2 AS CHARACTER FORMAT "X(20)"
     LABEL "Р/C"
      VIEW-AS TEXT
     SIZE 24.13 BY .79.
DEFINE VARIABLE sign AS CHARACTER FORMAT "X(20)"
     LABEL "ФИО"
     VIEW-AS FILL-IN
     SIZE 26.5 BY 1.
DEFINE VARIABLE sign-post AS CHARACTER FORMAT "X(20)"
     LABEL "Должность"
     VIEW-AS FILL-IN
     SIZE 24.63 BY 1.
DEFINE VARIABLE point-io-code AS INTEGER FORMAT "99999" INITIAL 0
     LABEL "Пункт отгрузки/доставки"
     VIEW-AS FILL-IN
     SIZE 6.75 BY 1 NO-UNDO.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 68.88 BY 3.63.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 69 BY 2.79.
DEFINE FRAME Dialog-Frame
     b-OK AT ROW 1.04 COL 2
     b-exit AT ROW 1.04 COL 12
     b-add AT ROW 1.04 COL 22.13
     B-Help AT ROW 1.08 COL 60
     b-bank AT ROW 5.79 COL 60
     b-bank-2 AT ROW 9.79 COL 60
     sign-post AT ROW 12.5 COL 10.88 COLON-ALIGNED
     sign AT ROW 12.5 COL 42.5 COLON-ALIGNED
     point-io-code AT ROW 13.88 COL 24.88 COLON-ALIGNED
     BUTTON-point-io AT ROW 13.88 COL 33.38
     point-io-name AT ROW 13.88 COL 34 COLON-ALIGNED NO-LABEL
     name AT ROW 2.08 COL 14 COLON-ALIGNED
     inn AT ROW 3.21 COL 5.5 COLON-ALIGNED
     kpp AT ROW 3.21 COL 40.25 COLON-ALIGNED
     addres AT ROW 4.29 COL 2.38
     bank-name AT ROW 6 COL 7.13 COLON-ALIGNED
     bik AT ROW 7 COL 6.13 COLON-ALIGNED
     r-schet AT ROW 7 COL 40.5 COLON-ALIGNED
     c-schet AT ROW 8 COL 11.5 COLON-ALIGNED
     curr AT ROW 8 COL 52.5 COLON-ALIGNED
     r-schet-2 AT ROW 10 COL 5.25 COLON-ALIGNED
     curr-2 AT ROW 10 COL 41 COLON-ALIGNED
     bank-name-2 AT ROW 11 COL 9.5 COLON-ALIGNED
     "Реквизиты договора" VIEW-AS TEXT
          SIZE 18.25 BY .92 AT ROW 5 COL 26.63
          FGCOLOR 4
     "Текущий счет" VIEW-AS TEXT
          SIZE 12.88 BY .92 AT ROW 9 COL 29.38
          FGCOLOR 4
     RECT-2 AT ROW 5.42 COL 1.88
     RECT-3 AT ROW 9.42 COL 1.75
     SPACE(0.74) SKIP(2.99)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Реквизиты".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       point-io-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-add IN FRAME Dialog-Frame
DO:
  find first ub.clients no-lock where ub.clients.obj-type = p-obj-type and ub.clients.obj-code = p-obj-code no-error .
  if p-obj-type = 'орг':U then do:
    if p-host-code = p-obj-code then do:
      define buffer buf_sysconf for ub.sysconf .
      find first buf_sysconf no-lock where buf_sysconf.host-code = p-host-code .
      assign
        sign-post = buf_sysconf.pay-sign-post
        sign      = buf_sysconf.pay-sign
      .
    end.
    find first ub.firm no-lock where ub.firm.firm-code = p-obj-code no-error.
    if available ub.firm then assign    inn = ub.firm.inn    addres = ub.firm.addres1       kpp = ub.firm.kpp .
  end.
  else do:
    find first ub.person no-lock where ub.person.psn-code = p-obj-code no-error.
    if available ub.person then   assign   inn = ub.person.inn   addres = ub.person.address    kpp = ub.person.kpp .
  end.
  assign name = ub.clients.obj-name .
  display name inn addres kpp sign sign-post with frame Dialog-Frame.
END.
ON CHOOSE OF b-bank IN FRAME Dialog-Frame
DO:
  find first ub.clients no-lock where ub.clients.obj-type = p-obj-type and ub.clients.obj-code = p-obj-code no-error .
  if not available ub.clients then return.
  define variable rid-list as  char no-undo .
  define variable v-status_ like ub.fin-schet.status_ no-undo init 'тек':U.
  if ri-schet <> ? then assign rid-list = string(ri-schet) .
  run ref/finschts.w (input parParentProc, input p-host-code, input "b-sel,b-add", input "cmp-host", input p-obj-type,
                 input p-obj-code, input 0, input p-host-code, input 0, input-output v-status_, input-output rid-list).
  if rid-list <> "" then do:
    find first ub.fin-schet no-lock where RECID(fin-schet) = int (rid-list) no-error .
    if available ub.fin-schet then do:
      if ub.fin-schet.status_ = 'удал':U then message "Вы выбрали удаленный счет!"  view-as alert-box.
      find first ub.fin-bank no-lock where ub.fin-bank.host-code = ub.fin-schet.host-code and ub.fin-bank.code-bank = ub.fin-schet.code-bank no-error .
      find first ub.currency no-lock where ub.currency.curr-code = ub.fin-schet.curr-code .
      assign
        ri-schet   = int (rid-list)
        p-code-schet = ub.fin-schet.code-schet
        bank-name  = ub.fin-bank.short-name
        bik        = ub.fin-bank.bik
        c-schet    = ub.fin-schet.c-schet
        r-schet    = ub.fin-schet.r-schet
        curr       = ub.currency.curr-abbr
      .
    end.
  end.
  else assign  ri-schet = ?  p-code-schet = ?  bank-name = ""    bik = ""  c-schet = ""   r-schet = "" curr = "" .
  display bank-name bik c-schet r-schet curr with frame Dialog-Frame.
END.
ON CHOOSE OF b-bank-2 IN FRAME Dialog-Frame
DO:
  find first ub.clients no-lock where ub.clients.obj-type = p-obj-type and ub.clients.obj-code = p-obj-code no-error .
  if not available ub.clients then return.
  define variable rid-list as  char no-undo .
  define variable v-status_ like ub.fin-schet.status_ no-undo init 'тек':U.
  if ri-schet-2 <> ? then
  assign rid-list = string(ri-schet-2) .
  run ref/finschts.w (input parParentProc, input p-host-code, input "b-sel,b-add", input "cmp-host", input p-obj-type,
                 input p-obj-code, input 0, input p-host-code, input 0, input-output v-status_, input-output rid-list).
  if rid-list <> "" then do:
    find first ub.fin-schet no-lock where RECID(fin-schet) = int (rid-list) no-error .
    if available ub.fin-schet then do:
      if ub.fin-schet.status_ = 'удал':U then message "Вы выбрали удаленный счет!"  view-as alert-box.
      find first ub.fin-bank no-lock where ub.fin-bank.host-code = ub.fin-schet.host-code and ub.fin-bank.code-bank = ub.fin-schet.code-bank no-error .
      find first ub.currency no-lock where ub.currency.curr-code = ub.fin-schet.curr-code .
      assign
        ri-schet-2   = int (rid-list)
        p-code-schet-2 = ub.fin-schet.code-schet
        bank-name-2  = ub.fin-bank.short-name
        r-schet-2    = ub.fin-schet.r-schet
        curr-2       = ub.currency.curr-abbr
      .
    end.
  end.
  else assign  ri-schet-2 = ?  p-code-schet-2 = ?  bank-name-2 = ""   r-schet-2 = "" curr-2 = ""   .
  display bank-name-2 curr-2  r-schet-2 with frame Dialog-Frame.
END.
ON CHOOSE OF b-OK IN FRAME Dialog-Frame
DO:
  if ref-mode <> 'ПРОСМОТР':U and ref-mode <> "history" then do:
    assign inn name addres kpp  sign  sign-post .
    assign
      p-obj-name  = name
      p-kpp       = kpp
      p-inn       = inn
      p-addres    = addres
      p-sign      = sign
      p-sign-post = sign-post
      p-point-io-code = point-io-code
      p-db-num    = v-current-db-num
    .
  end.
END.
ON CHOOSE OF BUTTON-point-io IN FRAME Dialog-Frame
DO:
  define variable ri-list as character no-undo.
define variable vss-include-info0 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  if available buf_point-io then  assign ri-list = string(recid(buf_point-io)) .
  run ref/point-io.w
        (input  parparentproc
        ,input  "b-add,b-sel"
        ,input  v-current-db-num
        ,input  p-obj-type
        ,input  p-obj-code
        ,input  'объект':U
        ,input  'all'
        ,input-output ri-list
        ).
  if ri-list <> "":U then do:
    FIND FIRST buf_point-io WHERE recid( buf_point-io ) = integer(entry(1, ri-list)) NO-LOCK .
    assign
      point-io-code = buf_point-io.point-code
      point-io-name = buf_point-io.point-name
    .
  end.
  else do:
    assign
      point-io-code = 0
      point-io-name = ""
    .
  end.
  display point-io-code  point-io-name  with frame Dialog-Frame .
  apply "CHOOSE"  to sign-post  IN FRAME Dialog-Frame .
END.
ON LEAVE OF point-io-code IN FRAME Dialog-Frame
DO:
  assign point-io-code .
  if point-io-code > 0 then do:
    find first buf_point-io no-lock
      where buf_point-io.point-code = point-io-code
        and buf_point-io.db-num        = v-current-db-num
        and buf_point-io.cli-type      = p-obj-type
       and buf_point-io.cli-code      = p-obj-code
    no-error .
    if available buf_point-io then do:
      assign
        point-io-code = buf_point-io.point-code
        point-io-name = buf_point-io.point-name
      .
      display point-io-code  point-io-name  with frame Dialog-Frame .
    end.
    else apply "CHOOSE"  to BUTTON-point-io  IN FRAME Dialog-Frame .
  end.
END.
ON RETURN OF point-io-code IN FRAME Dialog-Frame
DO:
  assign point-io-code .
  find first buf_point-io no-lock
    where buf_point-io.point-code = point-io-code
      and buf_point-io.db-num  = v-current-db-num
      and buf_point-io.cli-type      = p-obj-type
      and buf_point-io.cli-code      = p-obj-code
  no-error .
  if available buf_point-io then do:
    assign
      point-io-code = buf_point-io.point-code
      point-io-name = buf_point-io.point-name
    .
    display point-io-code  point-io-name  with frame Dialog-Frame .
  end.
  else apply "CHOOSE"  to BUTTON-point-io  IN FRAME Dialog-Frame .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-current-db-num
  )  .
  ASSIGN inn :LABEL IN FRAME Dialog-Frame = "ИНН"
         kpp :LABEL IN FRAME Dialog-Frame = "КПП".
  RUN enable_UI.
  run go-proc no-error.
  if error-status:error then return no-apply.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY sign-post sign point-io-code point-io-name name inn kpp addres bank-name
          bik r-schet c-schet curr r-schet-2 curr-2 bank-name-2
      WITH FRAME Dialog-Frame.
  ENABLE b-OK b-exit b-add B-Help RECT-2 RECT-3 b-bank b-bank-2 sign-post sign
         point-io-code BUTTON-point-io point-io-name name kpp bank-name bik r-schet
         c-schet curr r-schet-2 curr-2 bank-name-2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE go-proc :
  find first ub.fin-schet no-lock where ub.fin-schet.host-code = p-host-code and ub.fin-schet.code-schet = p-code-schet no-error .
  if available ub.fin-schet then do:
    find first ub.currency no-lock where ub.currency.curr-code = ub.fin-schet.curr-code .
    find first ub.fin-bank no-lock where ub.fin-bank.host-code = p-host-code and ub.fin-bank.code-bank = ub.fin-schet.code-bank no-error .
    assign
      ri-schet   = recid (fin-schet)
      bank-name  = ub.fin-bank.short-name
      bik        = ub.fin-bank.bik
      name       = p-obj-name
      c-schet    = ub.fin-schet.c-schet
      r-schet    = ub.fin-schet.r-schet
      curr       = ub.currency.curr-abbr
    .
  end.
  else assign  ri-schet = ?  p-code-schet = ?  bank-name = ""    bik = ""  c-schet = ""   r-schet = "" curr = "" .
  display bank-name kpp bik c-schet r-schet curr with frame Dialog-Frame.
  find first ub.fin-schet no-lock where ub.fin-schet.host-code = p-host-code and ub.fin-schet.code-schet = p-code-schet-2 no-error .
  if available ub.fin-schet then do:
    find first ub.currency no-lock where ub.currency.curr-code = ub.fin-schet.curr-code .
    find first ub.fin-bank no-lock where ub.fin-bank.host-code = p-host-code and ub.fin-bank.code-bank = ub.fin-schet.code-bank no-error .
    assign
      ri-schet-2   = recid (fin-schet)
      p-code-schet-2 = ub.fin-schet.code-schet
      bank-name-2  = ub.fin-bank.short-name
      r-schet-2    = ub.fin-schet.r-schet
      curr-2       = ub.currency.curr-abbr
    .
  end.
  else assign  ri-schet-2 = ?  p-code-schet-2 = ?  bank-name-2 = ""   r-schet-2 = ""  curr-2 = "" .
  display bank-name-2  r-schet-2  curr-2  with frame Dialog-Frame.
  define variable str      as character no-undo .
  find first ub.clients no-lock where ub.clients.obj-type = p-obj-type and ub.clients.obj-code = p-obj-code no-error .
  case p-type :
    when 0 then do:
      assign str = "Реквизиты фирмы "       + p-obj-name + " код " + string(p-obj-code) .
    end.
    when 1 then do:
      assign str = "Реквизиты контрагента " + p-obj-name + " (" + p-obj-type + " " + string(p-obj-code) + ")" .
    end.
    when 2 then do:
      assign str = "Реквизиты посредника "  + p-obj-name + " (" + p-obj-type + " " + string(p-obj-code) + ")" .
    end.
    when 3 then do:
      assign str = "Реквизиты агента "      + p-obj-name + " (" + p-obj-type + " " + string(p-obj-code) + ")" .
    end.
  end.
  ASSIGN frame Dialog-Frame:TITLE = str.
  if ref-mode = 'ПРОСМОТР':U or ref-mode = "history"  then do:
    disable b-bank b-bank-2 inn addres sign sign-post b-add point-io-code point-io-name BUTTON-point-io with frame Dialog-Frame.
    b-OK:label in frame Dialog-Frame = "&Выход " .
    b-exit:visible = no .
  end.
  if ref-mode = 'ИЗМЕНЕНИЕ':U then do:
    if ri-schet <> ? then disable b-bank with frame Dialog-Frame.
  end.
  if p-point-io-code > 0 then do:
    find first buf_point-io no-lock
      where buf_point-io.point-code = p-point-io-code
        and buf_point-io.db-num     = v-current-db-num
        and buf_point-io.cli-type   = p-obj-type
        and buf_point-io.cli-code   = p-obj-code
    no-error .
  end.
  else do:
    find first buf_point-io no-lock
      where buf_point-io.point-code = p-point-io-code
        and buf_point-io.db-num     = v-current-db-num
        and buf_point-io.cli-type   = p-obj-type
        and buf_point-io.cli-code   = p-obj-code
        and buf_point-io.is-default = yes
    no-error .
  end.
  if available buf_point-io then do:
    assign
      point-io-code = buf_point-io.point-code
      point-io-name = buf_point-io.point-name
    .
    display point-io-code  point-io-name  with frame Dialog-Frame .
  end.
  assign
    name      = p-obj-name
    inn       = p-inn
    addres    = p-addres
    sign      = p-sign
    sign-post = p-sign-post
    kpp       = p-kpp
  .
  display sign-post sign point-io-code point-io-name name inn kpp addres bank-name bik r-schet c-schet curr r-schet-2 curr-2 bank-name-2 with frame Dialog-Frame.
END PROCEDURE.
