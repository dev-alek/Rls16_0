define input parameter p-ri    as recid no-undo .
def var vss-revision    as character no-undo init "$Revision$":u .
def var vss-author      as character no-undo init "$Author$":u .
def var vss-date        as character no-undo init "$Date$":u .
def var vss-workfile    as character no-undo init "$Workfile$":u .
def var vss-archive     as character no-undo init "$Archive$":u .
def var vss-description as character no-undo init "Карточка истории договора" .
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
DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "&Выход":L
     size 10 by 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE QUERY Dialog-Frame FOR
      ub.c-contract SCROLLING.
DEFINE FRAME Dialog-Frame
     b-exit at row 1.08 col 1
     B-Help AT ROW 1.08 COL 11
     ub.c-contract.contract-prn-code AT ROW 1.13 COL 26.38 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 11.75 BY 1
     ub.c-contract.contract-date AT ROW 1.13 COL 45 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 11.75 BY 1
     ub.c-contract.doc-type AT ROW 1.13 COL 62.5 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 6.25 BY 1
     ub.c-contract.curr-code AT ROW 1.13 COL 74.5 COLON-ALIGNED
          LABEL "вал"
          VIEW-AS FILL-IN
          SIZE 3 BY 1
     ub.c-contract.status_ AT ROW 1.13 COL 86.5 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 7.75 BY 1
     ub.c-contract.srok-opl AT ROW 2.25 COL 88.63 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 5.75 BY 1
     ub.c-contract.contract-type AT ROW 2.33 COL 4.25 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 30.75 BY 1
     ub.c-contract.usl-opl AT ROW 2.33 COL 52 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 22.38 BY 1
     ub.c-contract.contract-date-beg AT ROW 3.42 COL 16 COLON-ALIGNED
          LABEL "Начало действия"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     ub.c-contract.contract-date-end AT ROW 3.42 COL 49 COLON-ALIGNED
          LABEL "Окончание действия"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     ub.c-contract.contract-city AT ROW 3.42 COL 69.38 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 24.75 BY 1
     ub.c-contract.user-name AT ROW 4.46 COL 70 COLON-ALIGNED
          LABEL "Пользователь"
          VIEW-AS FILL-IN
          SIZE 15.88 BY 1
     ub.c-contract.contract-name AT ROW 4.5 COL 10 COLON-ALIGNED
          LABEL "Заголовок"
          VIEW-AS FILL-IN
          SIZE 45 BY 1
     ub.c-contract.user-db-num AT ROW 4.5 COL 91 COLON-ALIGNED
          LABEL "БД"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     ub.c-contract.mngr-code AT ROW 5.63 COL 16.25 COLON-ALIGNED
          LABEL "Код исполнителя"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     ub.c-contract.cor-acc-in AT ROW 5.63 COL 38 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 10.13 BY 1
     ub.c-contract.cel-nazn-code-in AT ROW 5.63 COL 63 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 8 BY 1
     ub.c-contract.an-uchet-code-in AT ROW 5.63 COL 85.75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 8.63 BY 1
     ub.c-contract.own-name AT ROW 6.67 COL 8 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 64.75 BY 1
     ub.c-contract.own-inn AT ROW 6.67 COL 78.38 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     ub.c-contract.own-kpp AT ROW 7.67 COL 5.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 18 BY 1
     ub.c-contract.own-addres AT ROW 7.67 COL 26.13
          VIEW-AS FILL-IN
          SIZE 63.25 BY 1
     ub.c-contract.own-bank-name AT ROW 8.67 COL 6.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 33.5 BY 1
     ub.c-contract.own-bik AT ROW 8.67 COL 45.75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 19 BY 1
     ub.c-contract.own-r-schet AT ROW 8.67 COL 76.25 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 18.13 BY 1
     ub.c-contract.own-c-schet AT ROW 9.67 COL 10.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 18.88 BY 1
.
DEFINE FRAME Dialog-Frame
     ub.c-contract.own-sign AT ROW 9.67 COL 40.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 21 BY 1
     ub.c-contract.own-sign-post AT ROW 9.67 COL 73.38 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 21 BY 1
     ub.c-contract.cli-type AT ROW 10.67 COL 17.63 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     ub.c-contract.cli-name AT ROW 10.67 COL 22.75 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 50 BY 1
     ub.c-contract.cli-inn AT ROW 10.67 COL 78.38 COLON-ALIGNED
          LABEL "abbr_inn_allshift"
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     ub.c-contract.cli-code AT ROW 10.71 COL 11 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 5.88 BY 1
     ub.c-contract.cli-addres AT ROW 11.63 COL 26
          LABEL "Адрес"
          VIEW-AS FILL-IN
          SIZE 63.25 BY 1
     ub.c-contract.cli-kpp AT ROW 11.67 COL 5.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 18 BY 1
     ub.c-contract.cli-bik AT ROW 12.67 COL 45.75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 19 BY 1
     ub.c-contract.cli-r-schet AT ROW 12.67 COL 76.25 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 18.13 BY 1
     ub.c-contract.cli-bank-name AT ROW 12.71 COL 6 COLON-ALIGNED
          LABEL "Банк"
          VIEW-AS FILL-IN
          SIZE 33.5 BY 1
     ub.c-contract.cli-c-schet AT ROW 13.67 COL 10.75 COLON-ALIGNED
          LABEL "Кор. счет"
          VIEW-AS FILL-IN
          SIZE 18.25 BY 1
     ub.c-contract.cli-sign AT ROW 13.67 COL 40.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 21 BY 1
     ub.c-contract.cli-sign-post AT ROW 13.67 COL 73.38 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 21 BY 1
     ub.c-contract.posr-code AT ROW 14.58 COL 11 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 5.88 BY 1
     ub.c-contract.posr-name AT ROW 14.67 COL 22.75 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 50 BY 1
     ub.c-contract.posr-inn AT ROW 14.67 COL 78.38 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     ub.c-contract.posr-type AT ROW 14.71 COL 17.63 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     ub.c-contract.posr-kpp AT ROW 15.67 COL 5.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 18 BY 1
     ub.c-contract.posr-addres AT ROW 15.67 COL 26.13
          VIEW-AS FILL-IN
          SIZE 63.25 BY 1
     ub.c-contract.posr-bank-name AT ROW 16.67 COL 6.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 33.5 BY 1
     ub.c-contract.posr-bik AT ROW 16.67 COL 45.75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 19 BY 1
     ub.c-contract.posr-r-schet AT ROW 16.67 COL 76.25 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 18.13 BY 1
     ub.c-contract.posr-c-schet AT ROW 17.67 COL 10.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 18.88 BY 1
     ub.c-contract.posr-sign AT ROW 17.67 COL 40.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 21 BY 1
     ub.c-contract.posr-sign-post AT ROW 17.67 COL 73.38 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 21 BY 1
     ub.c-contract.agnt-code AT ROW 18.63 COL 11 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 6.63 BY 1
.
DEFINE FRAME Dialog-Frame
     ub.c-contract.agnt-type AT ROW 18.63 COL 17.63 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     ub.c-contract.agnt-name AT ROW 18.67 COL 22.75 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 50 BY 1
     ub.c-contract.agnt-inn AT ROW 18.67 COL 78.38 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     ub.c-contract.agnt-kpp AT ROW 19.67 COL 5.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 18 BY 1
     ub.c-contract.agnt-addres AT ROW 19.67 COL 26.13
          VIEW-AS FILL-IN
          SIZE 63.25 BY 1
     ub.c-contract.agnt-bank-name AT ROW 20.67 COL 6.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 33.5 BY 1
     ub.c-contract.agnt-bik AT ROW 20.67 COL 45.75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 19 BY 1
     ub.c-contract.agnt-r-schet AT ROW 20.67 COL 76.25 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 18.13 BY 1
     ub.c-contract.agnt-c-schet AT ROW 21.67 COL 10.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 18.88 BY 1
     ub.c-contract.agnt-sign AT ROW 21.67 COL 40.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 21 BY 1
     ub.c-contract.agnt-sign-post AT ROW 21.67 COL 73.38 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 21 BY 1
     "Посредник" VIEW-AS TEXT
          SIZE 9.75 BY .67 AT ROW 14.79 COL 1.75
          FGCOLOR 4
     "Фирма" VIEW-AS TEXT
          SIZE 6.63 BY .67 AT ROW 6.83 COL 2.5
          FGCOLOR 4
     "Агент" VIEW-AS TEXT
          SIZE 6.63 BY .67 AT ROW 18.88 COL 2.25
          FGCOLOR 4
     "Контрагент" VIEW-AS TEXT
          SIZE 10.63 BY .67 AT ROW 10.88 COL 1.88
          FGCOLOR 4
     SPACE(83.86) SKIP(11.44)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "История договора".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:ROW              = 1
       FRAME Dialog-Frame:COLUMN           = 1.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  find first ub.c-contract WHERE recid (ub.c-contract) = p-ri NO-LOCK.
  assign
  ub.c-contract.cli-inn:label in frame Dialog-Frame = ''
  .
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  IF AVAILABLE ub.c-contract THEN
    DISPLAY ub.c-contract.contract-prn-code ub.c-contract.contract-date
          ub.c-contract.doc-type ub.c-contract.curr-code ub.c-contract.status_
          ub.c-contract.srok-opl ub.c-contract.contract-type ub.c-contract.usl-opl
          ub.c-contract.contract-date-beg ub.c-contract.contract-date-end
          ub.c-contract.contract-city ub.c-contract.user-name ub.c-contract.contract-name
          ub.c-contract.user-db-num ub.c-contract.mngr-code ub.c-contract.cor-acc-in
          ub.c-contract.cel-nazn-code-in ub.c-contract.an-uchet-code-in ub.c-contract.own-name
          ub.c-contract.own-inn ub.c-contract.own-kpp ub.c-contract.own-addres
          ub.c-contract.own-bank-name ub.c-contract.own-bik ub.c-contract.own-r-schet
          ub.c-contract.own-c-schet ub.c-contract.own-sign ub.c-contract.own-sign-post
          ub.c-contract.cli-type ub.c-contract.cli-name ub.c-contract.cli-inn
          ub.c-contract.cli-code ub.c-contract.cli-addres ub.c-contract.cli-kpp
          ub.c-contract.cli-bik ub.c-contract.cli-r-schet ub.c-contract.cli-bank-name
          ub.c-contract.cli-c-schet ub.c-contract.cli-sign ub.c-contract.cli-sign-post
          ub.c-contract.posr-code ub.c-contract.posr-name ub.c-contract.posr-inn
          ub.c-contract.posr-type ub.c-contract.posr-kpp ub.c-contract.posr-addres
          ub.c-contract.posr-bank-name ub.c-contract.posr-bik ub.c-contract.posr-r-schet
          ub.c-contract.posr-c-schet ub.c-contract.posr-sign ub.c-contract.posr-sign-post
          ub.c-contract.agnt-code ub.c-contract.agnt-type ub.c-contract.agnt-name
          ub.c-contract.agnt-inn ub.c-contract.agnt-kpp ub.c-contract.agnt-addres
          ub.c-contract.agnt-bank-name ub.c-contract.agnt-bik ub.c-contract.agnt-r-schet
          ub.c-contract.agnt-c-schet ub.c-contract.agnt-sign ub.c-contract.agnt-sign-post
      WITH FRAME Dialog-Frame.
  ENABLE b-exit B-Help ub.c-contract.contract-prn-code ub.c-contract.contract-date
         ub.c-contract.doc-type ub.c-contract.curr-code ub.c-contract.status_
         ub.c-contract.srok-opl ub.c-contract.contract-type ub.c-contract.usl-opl
         ub.c-contract.contract-date-beg ub.c-contract.contract-date-end
         ub.c-contract.contract-city ub.c-contract.user-name ub.c-contract.contract-name
         ub.c-contract.user-db-num ub.c-contract.mngr-code ub.c-contract.cor-acc-in
         ub.c-contract.cel-nazn-code-in ub.c-contract.an-uchet-code-in ub.c-contract.own-name
         ub.c-contract.own-inn ub.c-contract.own-kpp ub.c-contract.own-addres
         ub.c-contract.own-bank-name ub.c-contract.own-bik ub.c-contract.own-r-schet
         ub.c-contract.own-c-schet ub.c-contract.own-sign ub.c-contract.own-sign-post
         ub.c-contract.cli-type ub.c-contract.cli-name ub.c-contract.cli-inn
         ub.c-contract.cli-code ub.c-contract.cli-addres ub.c-contract.cli-kpp
         ub.c-contract.cli-bik ub.c-contract.cli-r-schet ub.c-contract.cli-bank-name
         ub.c-contract.cli-c-schet ub.c-contract.cli-sign ub.c-contract.cli-sign-post
         ub.c-contract.posr-code ub.c-contract.posr-name ub.c-contract.posr-inn
         ub.c-contract.posr-type ub.c-contract.posr-kpp ub.c-contract.posr-addres
         ub.c-contract.posr-bank-name ub.c-contract.posr-bik ub.c-contract.posr-r-schet
         ub.c-contract.posr-c-schet ub.c-contract.posr-sign ub.c-contract.posr-sign-post
         ub.c-contract.agnt-code ub.c-contract.agnt-type ub.c-contract.agnt-name
         ub.c-contract.agnt-inn ub.c-contract.agnt-kpp ub.c-contract.agnt-addres
         ub.c-contract.agnt-bank-name ub.c-contract.agnt-bik ub.c-contract.agnt-r-schet
         ub.c-contract.agnt-c-schet ub.c-contract.agnt-sign ub.c-contract.agnt-sign-post
      WITH FRAME Dialog-Frame.
END PROCEDURE.
