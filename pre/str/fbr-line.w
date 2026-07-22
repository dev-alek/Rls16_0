define input parameter p-fbrhist-handle     as widget-handle    no-undo.
define input parameter p-line-mode          as character        no-undo.
define input parameter p-fbr-doc-doc-code   as character        no-undo.
define input parameter p-fbr-line-recid     as recid            no-undo.
define input parameter p-mark-qnty          as decimal          no-undo.
define output parameter p-cancel            as logical          no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Работа со строкой составного товара в производстве".
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
define buffer f-doc for fbr-doc.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод "
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE avail-qnty AS DECIMAL FORMAT "->>>,>>9.999":U INITIAL 0
     LABEL "Допустимо"
     VIEW-AS FILL-IN
     SIZE 14 BY 1.08
     FGCOLOR 4  NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 75 BY 3.13.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 75 BY 2.04.
DEFINE FRAME d-fbr-line
     b-help AT ROW 1 COL 73.5
     b-exit AT ROW 1.13 COL 1.63
     b-quit AT ROW 1.13 COL 11.88
     ub.fbr-line.artic AT ROW 3.54 COL 16.25 COLON-ALIGNED
          LABEL "Артикул"
          VIEW-AS FILL-IN
          SIZE 15 BY 1.08
     ub.goods.gds-name AT ROW 3.58 COL 31.13 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 42.5 BY 1.08
          FGCOLOR 4
     ub.fbr-line.prod-code AT ROW 4.71 COL 16.25 COLON-ALIGNED
          LABEL "Производитель"
          VIEW-AS FILL-IN
          SIZE 8.38 BY 1.08
     ub.fbr-line.prod-type AT ROW 4.71 COL 24.75 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 6.25 BY 1.08
     ub.clients.obj-name AT ROW 4.75 COL 31.13 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 42.63 BY 1.08
          FGCOLOR 4
     ub.fbr-line.recipe-code AT ROW 6.96 COL 16.38 COLON-ALIGNED
          LABEL "Рецепт"
          VIEW-AS FILL-IN
          SIZE 11 BY 1.08
     ub.recipe.recipe-name AT ROW 6.96 COL 27.25 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 46.63 BY 1.08
          FGCOLOR 4
     ub.fbr-line.fact-qnty AT ROW 9.58 COL 16.63 COLON-ALIGNED
          LABEL "&Количество" FORMAT ">>,>>>,>>9.999"
          VIEW-AS FILL-IN
          SIZE 11 BY 1.08
     ub.goods.unit-base AT ROW 9.58 COL 27.5 COLON-ALIGNED HELP
          "" NO-LABEL
          VIEW-AS FILL-IN
          SIZE 6 BY 1.08
          FGCOLOR 4
     avail-qnty AT ROW 9.58 COL 45 COLON-ALIGNED
     ub.fbr-line.price-sale AT ROW 11.13 COL 45.25 COLON-ALIGNED HELP
          ""
          LABEL "&Цена продажи" FORMAT ">>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 19.25 BY 1.08
     ub.fbr-line.price-base AT ROW 13.08 COL 45.25 COLON-ALIGNED HELP
          ""
          LABEL "Учет. цена (&баз.вал)" FORMAT ">>>,>>>,>>9.9999999999"
          VIEW-AS FILL-IN
          SIZE 19.25 BY 1.08
     ub.fbr-line.price-rubl AT ROW 14.29 COL 45.25 COLON-ALIGNED HELP
          ""
          LABEL "Учет. цена " FORMAT ">>>,>>>,>>9.9999999999"
          VIEW-AS FILL-IN
          SIZE 19.25 BY 1.08
     RECT-2 AT ROW 6.58 COL 2
     RECT-1 AT ROW 3.13 COL 2
     SPACE(0.74) SKIP(10.15)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME d-fbr-line:SCROLLABLE       = FALSE
       FRAME d-fbr-line:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME d-fbr-line
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-exit IN FRAME d-fbr-line
DO:
def buffer b-fbr-line for fbr-line.
    if input frame d-fbr-line fbr-line.fact-qnty <= 0
    then do:
        message
            "Количество товара введено неверно."
            skip(1) "Введите количество или отмените добавление товара."
        view-as alert-box information
        title "Неверное количество".
        undo, return no-apply.
    end.
    else do:
        assign
            fbr-line.fact-qnty
        .
        if input frame d-fbr-line fbr-line.price-sale <> fbr-line.price-sale
        and f-doc.status_ = 'новый':U
        then do:
            for each b-fbr-line
               where b-fbr-line.doc-code  = f-doc.doc-code
                 and b-fbr-line.artic     = fbr-line.artic
                 and b-fbr-line.prod-type = fbr-line.prod-type
                 and b-fbr-line.prod-code = fbr-line.prod-code
            on error undo, return no-apply
            :
                    assign
                        b-fbr-line.price-sale = input frame d-fbr-line fbr-line.price-sale
                        b-fbr-line.is-calc = yes
                    .
            end.
        end.
    end.
END.
ON CHOOSE OF b-quit IN FRAME d-fbr-line
DO:
    assign
        p-cancel = yes
    .
END.
ON RETURN OF ub.fbr-line.fact-qnty IN FRAME d-fbr-line
DO:
  apply "choose" to b-exit in frame d-fbr-line.
  return no-apply.
END.
ON RETURN OF ub.fbr-line.price-base IN FRAME d-fbr-line
DO:
  apply "entry" to fbr-line.price-rubl in frame d-fbr-line.
  return no-apply.
END.
ON RETURN OF ub.fbr-line.price-rubl IN FRAME d-fbr-line
DO:
  apply "entry" to b-exit in frame d-fbr-line.
  return no-apply.
END.
ON RETURN OF ub.fbr-line.price-sale IN FRAME d-fbr-line
DO:
  apply "entry" to b-exit in frame d-fbr-line.
  return no-apply.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-fbr-line:PARENT eq ?
THEN FRAME d-fbr-line:PARENT = ACTIVE-WINDOW.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-fbr-line
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
on choose of b-help in frame d-fbr-line
do:
  apply "help":u to frame d-fbr-line .
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
                v-frame-width = frame d-fbr-line:width - 0.3
                fh            = frame d-fbr-line:first-child
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
DO
ON ERROR UNDO MAIN-BLOCK, return error
:
     fbr-line.price-rubl:label = "Учет. цена (руб)" .
    VIEW FRAME d-fbr-line.
    find first f-doc no-lock
         where f-doc.doc-code = p-fbr-doc-doc-code
    .
    frame d-fbr-line :title = "Производство № " + f-doc.doc-code + "       "
                                    + f-doc.status_ + "      - " + p-line-mode .
    enable
        b-quit
        b-help
    with frame d-fbr-line.
    if p-line-mode = 'ПРОСМОТР':U
    then do:
        find first fbr-line no-lock
            where recid( fbr-line ) = p-fbr-line-recid
        .
    end.
    else do:
        find first fbr-line exclusive-lock
            where recid( fbr-line ) = p-fbr-line-recid
        .
    end.
    if fbr-line.recipe-code <> ""
    then do:
        find first recipe no-lock
            where recipe.recipe-code = fbr-line.recipe-code
        .
    end.
    find first goods no-lock
         where goods.artic     = fbr-line.artic
           and goods.prod-type = fbr-line.prod-type
           and goods.prod-code = fbr-line.prod-code
    .
    find first clients no-lock
         where clients.obj-code = goods.prod-code
           and clients.obj-type = goods.prod-type
    .
    if available recipe
    then do:
        display
            recipe.recipe-code @ fbr-line.recipe-code
            recipe.recipe-name
        with frame d-fbr-line.
    end.
    display
        goods.artic     @ fbr-line.artic
        goods.prod-code @ fbr-line.prod-code
        goods.prod-type @ fbr-line.prod-type
        fbr-line.fact-qnty
        fbr-line.price-sale
        goods.gds-name
        clients.obj-name
        goods.unit-base
    with frame d-fbr-line.
    if f-doc.status_ = 'новый':U
    then do:
        hide
            fbr-line.price-base
            fbr-line.price-rubl
        in frame d-fbr-line.
    end.
    else do:
        display
            fbr-line.price-base
            fbr-line.price-rubl
        with frame d-fbr-line.
    end.
    if f-doc.status_ = 'факт':U
    or not available recipe
    then do:
        hide avail-qnty in frame d-fbr-line.
    end.
    else do:
        run str/fbr-avl.p (
              input f-doc.doc-code
            , input recipe.recipe-code
            , input fbr-line.trn-type
            , output avail-qnty
        ) no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip "Ошибка при вычислении необходимого количества."
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
        display avail-qnty with frame d-fbr-line.
    end.
    if p-line-mode = 'ПРОСМОТР':U
    then do:
        wait-for go of frame d-fbr-line focus b-quit.
    end.
    else do:
        enable
            b-exit
            fbr-line.fact-qnty
            fbr-line.price-sale
        with frame d-fbr-line.
        if p-mark-qnty <> ?
        then do :
          assign fbr-line.fact-qnty = p-mark-qnty .
          display fbr-line.fact-qnty with frame d-fbr-line.
          disable fbr-line.fact-qnty with frame d-fbr-line.
        end .
        wait-for go of frame d-fbr-line focus fbr-line.fact-qnty.
    end.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME d-fbr-line.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY avail-qnty
      WITH FRAME d-fbr-line.
  IF AVAILABLE ub.clients THEN
    DISPLAY ub.clients.obj-name
      WITH FRAME d-fbr-line.
  IF AVAILABLE ub.fbr-line THEN
    DISPLAY ub.fbr-line.artic ub.fbr-line.prod-code ub.fbr-line.prod-type
          ub.fbr-line.recipe-code ub.fbr-line.fact-qnty ub.fbr-line.price-sale
          ub.fbr-line.price-base ub.fbr-line.price-rubl
      WITH FRAME d-fbr-line.
  IF AVAILABLE ub.goods THEN
    DISPLAY ub.goods.gds-name ub.goods.unit-base
      WITH FRAME d-fbr-line.
  IF AVAILABLE ub.recipe THEN
    DISPLAY ub.recipe.recipe-name
      WITH FRAME d-fbr-line.
  ENABLE b-help b-exit RECT-2 RECT-1 b-quit ub.fbr-line.price-sale
      WITH FRAME d-fbr-line.
  VIEW FRAME d-fbr-line.
END PROCEDURE.
