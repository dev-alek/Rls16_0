DEFINE INPUT PARAMETER   ref-mode   as   char  no-undo.
DEFINE INPUT PARAMETER hostcode like ub.shop.host-code no-undo.
DEFINE INPUT PARAMETER objtype like ub.clients.obj-type no-undo.
DEFINE INPUT PARAMETER objcode like ub.shop.obj-code no-undo.
define input parameter p-frame-title as character no-undo .
DEFINE INPUT-OUTPUT PARAMETER all-prt like ub.shop.all-prt no-undo.
DEFINE INPUT-OUTPUT PARAMETER cd-bc-alt like ub.shop.cd-bc-alt no-undo.
DEFINE INPUT-OUTPUT PARAMETER cd-bc-base like ub.shop.cd-bc-base no-undo.
DEFINE INPUT-OUTPUT PARAMETER cd-loc-alt like ub.shop.cd-loc-alt no-undo.
DEFINE INPUT-OUTPUT PARAMETER cd-loc-base like ub.shop.cd-loc-base no-undo.
DEFINE INPUT-OUTPUT PARAMETER cd-parts-all like ub.shop.cd-parts-all no-undo.
DEFINE INPUT-OUTPUT PARAMETER cd-parts-not-blank like ub.shop.cd-parts-not-blank no-undo.
DEFINE INPUT-OUTPUT PARAMETER cd-parts-ser like ub.shop.cd-parts-ser no-undo.
DEFINE INPUT-OUTPUT PARAMETER cd-pb-alt like ub.shop.cd-pb-alt no-undo.
DEFINE INPUT-OUTPUT PARAMETER cd-pb-base like ub.shop.cd-pb-base no-undo.
DEFINE INPUT-OUTPUT PARAMETER cd-sc-base like ub.shop.cd-sc-base no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "".
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
DEFINE BUTTON B-default
     LABEL "По &умолчанию"
     SIZE 16 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE RECTANGLE RECT-bc
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 31.38 BY 6.29.
DEFINE RECTANGLE RECT-part
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 31.38 BY 6.29.
DEFINE RECTANGLE RECT-pb
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 31.38 BY 6.29.
DEFINE VARIABLE T-all-prt AS LOGICAL INITIAL no
     LABEL "Отсылать все коды признаков"
     VIEW-AS TOGGLE-BOX
     SIZE 30.13 BY .79 NO-UNDO.
DEFINE VARIABLE T-bc-alt AS LOGICAL INITIAL no
     LABEL "неосновые бар-коды (EAN)"
     VIEW-AS TOGGLE-BOX
     SIZE 28.88 BY .79 NO-UNDO.
DEFINE VARIABLE T-bc-base AS LOGICAL INITIAL no
     LABEL "основные бар-коды (EAN)"
     VIEW-AS TOGGLE-BOX
     SIZE 28.88 BY .79 NO-UNDO.
DEFINE VARIABLE T-loc-alt AS LOGICAL INITIAL no
     LABEL "неосновные коды"
     VIEW-AS TOGGLE-BOX
     SIZE 28.88 BY .79 NO-UNDO.
DEFINE VARIABLE T-loc-base AS LOGICAL INITIAL no
     LABEL "основные коды"
     VIEW-AS TOGGLE-BOX
     SIZE 28.88 BY .79 NO-UNDO.
DEFINE VARIABLE T-parts-all AS LOGICAL INITIAL no
     LABEL "на весь товар"
     VIEW-AS TOGGLE-BOX
     SIZE 20.38 BY .79 NO-UNDO.
DEFINE VARIABLE T-parts-not-blank AS LOGICAL INITIAL no
     LABEL "на товар с непуст. N партий"
     VIEW-AS TOGGLE-BOX
     SIZE 29.63 BY .79 NO-UNDO.
DEFINE VARIABLE T-parts-ser AS LOGICAL INITIAL no
     LABEL "на серийный товар"
     VIEW-AS TOGGLE-BOX
     SIZE 21.13 BY .79 NO-UNDO.
DEFINE VARIABLE T-pb-alt AS LOGICAL INITIAL no
     LABEL "неосновн. ед.изм"
     VIEW-AS TOGGLE-BOX
     SIZE 21.88 BY .79 NO-UNDO.
DEFINE VARIABLE T-pb-base AS LOGICAL INITIAL no
     LABEL "основн. ед.изм"
     VIEW-AS TOGGLE-BOX
     SIZE 22 BY .79 NO-UNDO.
DEFINE VARIABLE T-sc-base AS LOGICAL INITIAL no
     LABEL "весовые и топливные"
     VIEW-AS TOGGLE-BOX
     SIZE 22.25 BY .79 NO-UNDO.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1.29 COL 1.63
     B-quit AT ROW 1.29 COL 11.63
     B-default AT ROW 1.29 COL 21.63
     B-help AT ROW 1.29 COL 49.75
     T-loc-base AT ROW 4.29 COL 2.5
     T-pb-base AT ROW 4.33 COL 34.5
     T-loc-alt AT ROW 5.42 COL 2.5
     T-pb-alt AT ROW 5.46 COL 34.5
     T-bc-base AT ROW 6.54 COL 2.5
     T-sc-base AT ROW 6.58 COL 34.5
     T-bc-alt AT ROW 7.79 COL 2.5
     T-all-prt AT ROW 9.63 COL 2.25
     T-parts-ser AT ROW 11.08 COL 35
     T-parts-not-blank AT ROW 12.21 COL 35
     T-parts-all AT ROW 13.33 COL 35
     RECT-bc AT ROW 2.75 COL 1.75
     RECT-pb AT ROW 2.79 COL 33.75
     "Отсылать собственные коды:" VIEW-AS TEXT
          SIZE 26.5 BY .71 AT ROW 3.13 COL 2.38
     "Отсылать ДОП.БК:" VIEW-AS TEXT
          SIZE 22.13 BY .71 AT ROW 3.17 COL 34.25
     RECT-part AT ROW 9.33 COL 33.75
     "Отсылать коды партий:" VIEW-AS TEXT
          SIZE 20.88 BY .71 AT ROW 9.92 COL 35.5
     SPACE(9.49) SKIP(5.36)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Настройка параметров отсылки товаров на кассу"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-default:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-default IN FRAME Dialog-Frame
DO:
  FIND FIRST ub.sysconf NO-LOCK WHERE ub.sysconf.host-code = hostcode NO-ERROR.
  IF NOT AVAIL ub.sysconf then return no-apply.
   assign
   T-all-prt = ub.sysconf.all-prt
   T-bc-alt = ub.sysconf.cd-bc-alt
   T-bc-base = ub.sysconf.cd-bc-base
   T-loc-alt = ub.sysconf.cd-loc-alt
   T-loc-base = ub.sysconf.cd-loc-base
   T-parts-all = ub.sysconf.cd-parts-all
   T-parts-not-blank = ub.sysconf.cd-parts-not-blank
   T-parts-ser = ub.sysconf.cd-parts-ser
   T-pb-alt = ub.sysconf.cd-pb-alt
   T-pb-base = ub.sysconf.cd-pb-base
   T-sc-base = ub.sysconf.cd-sc-base.
   DISPLAY
   T-all-prt
   T-bc-alt T-bc-base T-loc-alt T-loc-base
   T-parts-all T-parts-not-blank T-parts-ser
   T-pb-alt T-pb-base T-sc-base
   WITH FRAME Dialog-Frame.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  assign
  T-all-prt
  T-bc-alt T-bc-base T-loc-alt T-loc-base
  T-parts-all T-parts-not-blank T-parts-ser
  T-pb-alt T-pb-base T-sc-base.
  assign
  all-prt = T-all-prt
  cd-bc-alt = T-bc-alt
  cd-bc-base = T-bc-base
  cd-loc-alt = T-loc-alt
  cd-loc-base = T-loc-base
  cd-parts-all = T-parts-all
  cd-parts-not-blank = T-parts-not-blank
  cd-parts-ser = T-parts-ser
  cd-pb-alt = T-pb-alt
  cd-pb-base = T-pb-base
  cd-sc-base = T-sc-base .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   assign
   T-all-prt = all-prt
   T-bc-alt = cd-bc-alt
   T-bc-base = cd-bc-base
   T-loc-alt = cd-loc-alt
   T-loc-base = cd-loc-base
   T-parts-all = cd-parts-all
   T-parts-not-blank = cd-parts-not-blank
   T-parts-ser = cd-parts-ser
   T-pb-alt = cd-pb-alt
   T-pb-base = cd-pb-base
   T-sc-base = cd-sc-base.
  RUN enable_UI.
  assign
  FRAME Dialog-Frame:title = p-frame-title.
  IF ref-mode = 'ПРОСМОТР':U then do:
    b-quit:label = "&Выход ".
    DISPLAY b-exit with FRAME Dialog-Frame.
    DISABLE
    B-default B-exit
    T-all-prt
    T-bc-alt T-bc-base T-loc-alt T-loc-base
    T-parts-all T-parts-not-blank T-parts-ser
    T-pb-alt T-pb-base T-sc-base
    WITH FRAME Dialog-Frame.
  end.
  if objcode = 0 then do:
      DISABLE
      B-default
      WITH FRAME Dialog-Frame.
      HIDE
      B-default
      IN FRAME Dialog-Frame.
  end.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY T-loc-base T-pb-base T-loc-alt T-pb-alt T-bc-base T-sc-base T-bc-alt
          T-all-prt T-parts-ser T-parts-not-blank T-parts-all
      WITH FRAME Dialog-Frame.
  ENABLE RECT-bc RECT-pb RECT-part B-exit B-quit B-default B-help T-loc-base
         T-pb-base T-loc-alt T-pb-alt T-bc-base T-sc-base T-bc-alt T-all-prt
         T-parts-ser T-parts-not-blank T-parts-all
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
