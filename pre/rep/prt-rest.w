define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input parameter p-prt-rec as recid no-undo .
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Остатки по объекту для всех товаров, где есть данный узел шкалы".
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
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
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 7.75 BY 1.17.
DEFINE BUTTON b-quit AUTO-GO DEFAULT
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE fact-qnty_ AS DECIMAL FORMAT "->>,>>>,>>9.99" INITIAL 0
     LABEL "По всем товарам ФАКТ"
     FGCOLOR 4
     VIEW-AS FILL-IN
     SIZE 14 BY 1
     NO-UNDO.
DEFINE  VARIABLE free-qnty_ AS DECIMAL FORMAT "->>,>>>,>>9.999":U INITIAL 0
     LABEL "По всем товарам СВОБОДНО"
     FGCOLOR 4
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE QUERY br-rest FOR prt-obj, goods SCROLLING.
DEFINE BROWSE br-rest QUERY br-rest NO-LOCK DISPLAY
      prt-obj.artic COLUMN-LABEL "Артикул" FORMAT "x(12)"
      goods.gds-name COLUMN-LABEL "Название" FORMAT "x(36)"
      prt-obj.fact-qnty COLUMN-LABEL "Факт" FORMAT "->>,>>>,>>>.<<"
      prt-obj.free-qnty COLUMN-LABEL "Свободно" FORMAT "->>,>>>,>>>.<<"
      prt-obj.price-sale COLUMN-LABEL "Цена продажи" FORMAT "->>,>>>.<<"
    WITH SEPARATORS SIZE 90 BY 13.25.
DEFINE FRAME d-prt-obj
     b-quit AT ROW 1 COL 1
     b-help AT ROW 1 COL 14
     br-rest AT ROW 5 COL 1.5
     fact-qnty_ AT ROW 3.25 COL 26.5 COLON-ALIGNED
     free-qnty_ AT ROW 3.25 COL 60 COLON-ALIGNED
     SPACE(3.24) SKIP(0.45)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
         TITLE ""
         DEFAULT-BUTTON b-quit.
ASSIGN
       FRAME d-prt-obj:SCROLLABLE       = FALSE
       br-rest:NUM-LOCKED-COLUMNS IN FRAME d-prt-obj = 1.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-prt-obj
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
on choose of b-help in frame d-prt-obj
do:
  apply "help":u to frame d-prt-obj .
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
                v-frame-width = frame d-prt-obj:width - 0.3
                fh            = frame d-prt-obj:first-child
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
  find gds-prt where recid (gds-prt) = p-prt-rec no-lock.
  for each prt-obj where prt-obj.prt-code = gds-prt.node-code
                                      and prt-obj.obj-type = p-curr-obj-type
                                      and prt-obj.obj-code = p-curr-obj-code no-lock:
    assign
        fact-qnty_ = fact-qnty_ + prt-obj.fact-qnty
        free-qnty_ = free-qnty_ + prt-obj.free-qnty
        .
  end.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME d-prt-obj.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME d-prt-obj.
END PROCEDURE.
PROCEDURE enable_UI :
  frame d-prt-obj:title = substitute('ОСТАТКИ ПО ТОВАРАМ &1 &2       ДЛЯ ПРИЗНАКА : &3'
                                          ,p-curr-obj-type
                                          ,p-curr-obj-code
                                          ,gds-prt.f-name).
  DISPLAY fact-qnty_ free-qnty_ WITH FRAME d-prt-obj.
  ENABLE br-rest b-quit b-help WITH FRAME d-prt-obj.
  open query br-rest for each prt-obj where prt-obj.prt-code = gds-prt.node-code
                                        and prt-obj.obj-type = p-curr-obj-type
                                        and prt-obj.obj-code = p-curr-obj-code no-lock,
                                      each goods where goods.artic = prt-obj.artic
                                                              and goods.prod-type = prt-obj.prod-type
                                                              and goods.prod-code = prt-obj.prod-code no-lock.
END PROCEDURE.
