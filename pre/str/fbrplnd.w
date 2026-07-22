define input parameter parparentproc        as widget-handle    no-undo.
define input parameter p-mode               as character        no-undo.
define input parameter p-doc-code           as character        no-undo.
define input parameter p-gds-code           as integer          no-undo.
define input parameter p-recipe-code        as character        no-undo.
define input parameter p-fbr-obj-type       as character        no-undo.
define input parameter p-fbr-obj-code       as integer          no-undo.
define input parameter p-fact-qnty          as decimal          no-undo.
define output parameter p-new-recipe-code   as character        no-undo.
define output parameter p-new-fbr-obj-type  as character        no-undo.
define output parameter p-new-fbr-obj-code  as integer          no-undo.
define output parameter p-new-fact-qnty     as decimal          no-undo.
define output parameter p-cancel            as logical          no-undo.
define output parameter p-cancel-cycle      as logical          no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр и редактирование строки документа план-меню".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function chkleave returns logical
(input p-widget-enter as handle
,input p-button-list  as character
).
  if  valid-handle(p-widget-enter)
  and can-query(p-widget-enter, "name":u)
  and lookup(p-widget-enter :name, p-button-list) > 0
  then do:
    return false .
  end.
  return true .
end function.
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
define variable v-fbrplnd-kitchen-selected      as logical init no  no-undo.
define buffer buf_init_recipe    for recipe.
define buffer buf_init_goods     for goods.
define buffer buf_init_fbr-pln   for fbr-pln.
DEFINE BUTTON b-cancel
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-exit
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помощ&ь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-stop-cycle
     LABEL "&СтопЦикл"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON bt-sel-kitchen
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.63 BY 1.04.
DEFINE BUTTON bt-sel-recipe
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.63 BY 1.04.
DEFINE VARIABLE fi-artic AS CHARACTER FORMAT "X(20)":U
     LABEL "Артикул"
     VIEW-AS FILL-IN
     SIZE 14.38 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-fact-qnty AS DECIMAL FORMAT ">>,>>9.99":U INITIAL 0
     LABEL "Количество"
     VIEW-AS FILL-IN
     SIZE 14.38 BY 1 NO-UNDO.
DEFINE VARIABLE fi-kitchen-code AS INTEGER FORMAT ">>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 7.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-kitchen-type AS CHARACTER FORMAT "X(3)":U
     LABEL "Кухня"
     VIEW-AS FILL-IN
     SIZE 5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Наименование"
     VIEW-AS FILL-IN
     SIZE 47.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-recipe-code AS CHARACTER FORMAT "X(20)":U
     LABEL "Рецепт"
     VIEW-AS FILL-IN
     SIZE 14.38 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-recipe-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 29.38 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1.17 COL 2
     b-cancel AT ROW 1.17 COL 12
     b-stop-cycle AT ROW 1.17 COL 22
     b-help AT ROW 1.17 COL 52.38
     fi-kitchen-type AT ROW 2.5 COL 13.5 COLON-ALIGNED
     fi-kitchen-code AT ROW 2.5 COL 18.88 COLON-ALIGNED NO-LABEL
     bt-sel-kitchen AT ROW 2.5 COL 28.25
     fi-artic AT ROW 3.79 COL 13.5 COLON-ALIGNED
     fi-name AT ROW 5.04 COL 1.5
     fi-recipe-code AT ROW 6.29 COL 13.5 COLON-ALIGNED
     bt-sel-recipe AT ROW 6.29 COL 29.88
     fi-recipe-name AT ROW 6.29 COL 31.63 COLON-ALIGNED NO-LABEL
     fi-fact-qnty AT ROW 7.54 COL 13.5 COLON-ALIGNED
     SPACE(33.36) SKIP(0.41)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Строка документа".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame
DO:
    assign
        p-cancel   = yes
    .
    apply "WINDOW-CLOSE" TO FRAME Dialog-Frame .
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
    assign
        fi-fact-qnty
        fi-kitchen-type
        fi-kitchen-code
    .
    if fi-kitchen-type = ""
    or fi-kitchen-code = 0
    then do:
        message
            "Выберите объект, с которого"
            skip "должен будет переместиться товар."
        view-as alert-box error.
        apply "entry":U to fi-kitchen-code in frame Dialog-Frame .
        undo, return no-apply.
    end.
    assign
        p-new-fbr-obj-type  = fi-kitchen-type
        p-new-fbr-obj-code  = fi-kitchen-code
        p-new-fact-qnty     = fi-fact-qnty
        p-cancel            = no
        p-cancel-cycle      = no
    .
    if available buf_init_recipe
    then do:
        assign
            fi-recipe-code
        .
        assign
            p-new-recipe-code = fi-recipe-code
        .
    end.
    else do:
        assign
            p-new-recipe-code = ""
        .
    end.
    apply "WINDOW-CLOSE" TO FRAME Dialog-Frame .
END.
ON CHOOSE OF b-stop-cycle IN FRAME Dialog-Frame
DO:
    assign
        p-cancel-cycle   = yes
    .
    apply "WINDOW-CLOSE" TO FRAME Dialog-Frame .
END.
ON CHOOSE OF bt-sel-kitchen IN FRAME Dialog-Frame
DO:
    define variable v-is-invalid    as logical        no-undo.
    run select-kitchen in this-procedure (
          input fi-kitchen-type
        , input fi-kitchen-code
        , output fi-kitchen-type
        , output fi-kitchen-code
    ).
    display
        fi-kitchen-type
        fi-kitchen-code
    with frame Dialog-Frame.
    run check-object in this-procedure (
          input fi-kitchen-type :screen-value
        , input integer( fi-kitchen-code :screen-value )
        , output v-is-invalid
    ).
    if v-is-invalid = yes
    then do:
        message
            "Объект выбран неверно."
            skip(1)
            "Введите код объекта или выберите объект."
        view-as alert-box error.
        apply "entry" to fi-kitchen-code.
    end.
END.
ON CHOOSE OF bt-sel-recipe IN FRAME Dialog-Frame
DO:
    define variable v-recipe-recid-list    as character      no-undo.
    define buffer buf_fbr-pln       for fbr-pln.
    find first buf_fbr-pln no-lock
         where buf_fbr-pln.doc-code = p-doc-code
    .
    run ref/rcp-all.w (
          input parparentproc
        , input "b-add,b-sel"
        , input 'все':U
        , input recid( buf_init_goods )
        , input buf_fbr-pln.obj-type
        , input buf_fbr-pln.obj-code
        , output v-recipe-recid-list
    ) no-error.
    if error-status :error
    or v-recipe-recid-list = ""
    then do:
    end.
    else do:
        find first buf_init_recipe no-lock
             where recid( buf_init_recipe ) = integer( entry( 1, v-recipe-recid-list ) )
        .
        assign
            fi-recipe-code  = buf_init_recipe.recipe-code
            fi-recipe-name  = buf_init_recipe.recipe-name
        .
        display
            fi-recipe-code
            fi-recipe-name
        with frame Dialog-Frame.
    end.
END.
ON RETURN OF fi-fact-qnty IN FRAME Dialog-Frame
DO:
    apply "entry" to b-exit.
    return no-apply.
END.
ON LEAVE OF fi-kitchen-code IN FRAME Dialog-Frame
DO:
    define variable v-is-invalid    as logical        no-undo.
    if chkleave (
         input last-event :widget-enter
       , input "b-cancel,b-help,b-stop-cycle":u
    )
    then do:
        run check-object in this-procedure (
              input fi-kitchen-type :screen-value
            , input integer( fi-kitchen-code :screen-value )
            , output v-is-invalid
        ).
        if v-is-invalid = yes
        then do:
            message
                "Неверно выбран объект."
                skip "Выберите объект из списка."
            view-as alert-box warning.
            run select-kitchen in this-procedure (
                  input fi-kitchen-type :screen-value
                , input integer( fi-kitchen-code :screen-value )
                , output fi-kitchen-type
                , output fi-kitchen-code
            ) no-error.
            if error-status :error
            then do:
                message
                        vss-workfile vss-revision vss-description
                    skip(1)
                    skip "Ошибка выбора объекта."
                    skip return-value
                    skip trim(error-status :get-message(1))
                        trim(error-status :get-message(2))
                        trim(error-status :get-message(3))
                view-as alert-box error.
                undo, return no-apply .
            end.
            run check-object in this-procedure (
                  input fi-kitchen-type
                , input fi-kitchen-code
                , output v-is-invalid
            ).
            if v-is-invalid = yes
            then do:
                message
                    "Объект не найден"
                    skip "или не определен тип объекта"
                view-as alert-box error.
                undo, return no-apply.
            end.
            display
                fi-kitchen-type
                fi-kitchen-code
            with frame Dialog-Frame.
            return no-apply.
        end.
    end.
END.
ON RETURN OF fi-kitchen-code IN FRAME Dialog-Frame
DO:
    define variable v-is-invalid    as logical      no-undo.
    run get-obj-type in this-procedure (
          input integer( fi-kitchen-code :screen-value )
        , output fi-kitchen-type
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Ошибка при определении типа объекта."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    if fi-kitchen-type = ?
    then do:
        run select-kitchen in this-procedure (
              input fi-kitchen-type
            , input fi-kitchen-code
            , output fi-kitchen-type
            , output fi-kitchen-code
        ) no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip(1)
                skip "Ошибка выбора объекта."
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return no-apply .
        end.
        run check-object in this-procedure (
              input fi-kitchen-type
            , input fi-kitchen-code
            , output v-is-invalid
        ).
        if v-is-invalid = yes
        then do:
            message
                "Объект не найден"
                skip "или не определен тип объекта"
            view-as alert-box error.
            undo, return no-apply.
        end.
        display
            fi-kitchen-type
            fi-kitchen-code
        with frame Dialog-Frame.
    end.
    else do:
        display
            fi-kitchen-type
        with frame Dialog-Frame .
    end.
    apply "entry":U to fi-fact-qnty in frame Dialog-Frame .
    return no-apply.
END.
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
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    run init-fields in this-procedure no-error.
    if error-status :error
    then do:
        assign
            p-cancel   = yes
        .
        apply "WINDOW-CLOSE" TO FRAME Dialog-Frame .
    end.
    RUN enable_UI.
    if p-mode = 'ПРОСМОТР':U
    then do:
        apply "entry" to b-exit in frame Dialog-Frame .
        disable
            fi-fact-qnty
            bt-sel-recipe
            bt-sel-kitchen
            fi-kitchen-code
        with frame Dialog-Frame .
        assign
            fi-fact-qnty :fgcolor = 4
        .
    end.
    else do:
        if not available buf_init_recipe
        then do:
            disable
                bt-sel-recipe
            with frame Dialog-Frame .
            apply "entry" to fi-kitchen-code in frame Dialog-Frame .
        end.
        else do:
            apply "entry" to fi-fact-qnty in frame Dialog-Frame .
        end.
    end.
    WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE check-object :
do
on error undo, return error
:
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.
define output parameter p-is-invalid    as logical      no-undo.
    define buffer buf_clients       for clients.
    find first buf_clients no-lock
         where buf_clients.obj-type = p-obj-type
           and buf_clients.obj-code = p-obj-code
    no-error.
    if not available buf_clients
    or ( buf_clients.obj-type <> 'маг':U
        and buf_clients.obj-type <> 'скл':U )
    then do:
        assign
            p-is-invalid = yes
        .
    end.
    else do:
        assign
            p-is-invalid = no
        .
    end.
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY fi-kitchen-type fi-kitchen-code fi-artic fi-name fi-recipe-code
          fi-recipe-name fi-fact-qnty
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-cancel b-stop-cycle b-help fi-kitchen-code bt-sel-kitchen
         bt-sel-recipe fi-fact-qnty
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE get-obj-type :
do
on error undo, return error
:
define input parameter p-obj-code   as integer      no-undo.
define output parameter p-obj-type  as character    no-undo.
    define buffer buf_shop_clients      for clients.
    define buffer buf_stock_clients     for clients.
    find first buf_shop_clients no-lock
         where buf_shop_clients.obj-type = 'маг':U
           and buf_shop_clients.obj-code = p-obj-code
    no-error.
    find first buf_stock_clients no-lock
         where buf_stock_clients.obj-type = 'скл':U
           and buf_stock_clients.obj-code = p-obj-code
    no-error.
    if available buf_shop_clients
    then do:
        if available buf_stock_clients
        then do:
            run str/fbrplnds.w (
                  input "Выберите тип объекта:"
                , output p-obj-type
            ) no-error.
            if error-status :error
            then do:
                message
                         vss-workfile vss-revision vss-description
                    skip "Ошибка определения типа объекта."
                    skip return-value
                    skip trim(error-status :get-message(1))
                         trim(error-status :get-message(2))
                         trim(error-status :get-message(3))
                view-as alert-box error.
                assign
                    p-obj-type = ?
                .
                undo, return error .
            end.
        end.
        else do:
            assign
                p-obj-type = buf_shop_clients.obj-type
            .
        end.
    end.
    else do:
        if available buf_stock_clients
        then do:
            assign
                p-obj-type = buf_stock_clients.obj-type
            .
        end.
        else do:
            assign
                p-obj-type = ?
            .
        end.
    end.
end.
END PROCEDURE.
PROCEDURE init-fields :
do
on error undo, return error
:
    define buffer buf_goods         for goods.
    define buffer buf_recipe        for recipe.
    define buffer buf_fbr-gds-obj   for fbr-gds-obj.
    find first buf_init_fbr-pln no-lock
         where buf_init_fbr-pln.doc-code = p-doc-code
    .
    find first buf_init_goods no-lock
         where buf_init_goods.gds-code = p-gds-code
    .
    find first buf_recipe no-lock
         where buf_recipe.artic     = buf_init_goods.artic
           and buf_recipe.prod-type = buf_init_goods.prod-type
           and buf_recipe.prod-code = buf_init_goods.prod-code
    no-error.
    if available buf_recipe
    and ( buf_recipe.recipe-type = 'производство':U
       or buf_recipe.recipe-type = 'альтернатива':U )
    and p-fbr-obj-type = ""
    and p-fbr-obj-code = 0
    then do:
        find first buf_fbr-gds-obj no-lock
             where buf_fbr-gds-obj.obj-type = buf_init_fbr-pln.obj-type
               and buf_fbr-gds-obj.obj-code = buf_init_fbr-pln.obj-code
               and buf_fbr-gds-obj.gds-code = p-gds-code
        no-error.
        if not available buf_fbr-gds-obj
        then do:
            message
                skip "Не задан объект для производства товара с рецептом."
                skip "Товар: " buf_init_goods.artic buf_init_goods.gds-name
                skip(1)
                skip "Товар не может быть включен в план-меню."
                skip(1)
                skip "Необходимо определить атрибуты товара для ресторана."
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
        else do:
            assign
                p-fbr-obj-type  = buf_fbr-gds-obj.fbr-obj-type
                p-fbr-obj-code  = buf_fbr-gds-obj.fbr-obj-code
            .
        end.
    end.
    find first buf_init_recipe no-lock
         where buf_init_recipe.recipe-code = p-recipe-code
    no-error.
    assign
        fi-artic        = buf_init_goods.artic
        fi-name         = buf_init_goods.gds-name
        fi-kitchen-type = p-fbr-obj-type
        fi-kitchen-code = p-fbr-obj-code
        fi-fact-qnty    = p-fact-qnty
    .
    if available buf_init_recipe
    then do:
        assign
            fi-recipe-code  = p-recipe-code
            fi-recipe-name  = buf_init_recipe.recipe-name
        .
    end.
    else do:
        assign
            fi-kitchen-type :label in frame Dialog-Frame = "Склад"
        .
    end.
end.
END PROCEDURE.
PROCEDURE select-kitchen :
define input parameter p-old-obj-type   as character    no-undo.
define input parameter p-old-obj-code   as integer      no-undo.
define output parameter p-new-obj-type   as character    no-undo.
define output parameter p-new-obj-code   as integer      no-undo.
    define variable v-types as character no-undo .
    define variable v-old-cli-recid    as recid      no-undo.
    define variable v-new-cli-recid    as recid      no-undo.
    define buffer buf_clients       for clients.
do
on error undo, return error
:
    assign
        v-types = 'маг':U
    .
    find first buf_clients no-lock
         where buf_clients.obj-type = p-old-obj-type
           and buf_clients.obj-code = p-old-obj-code
    no-error.
    if available buf_clients
    then do:
        assign
            v-old-cli-recid = recid( buf_clients )
        .
    end.
    else do:
        assign
            v-old-cli-recid = ?
        .
    end.
    run ref/cli-all.w (
          input parparentproc
        , input "b-sel"
        , input v-types
        , input ?
        , input ?
        , input v-old-cli-recid
        , input ?
        , input ?
        , output v-new-cli-recid
    ) .
    find first buf_clients no-lock
         where recid( buf_clients ) = v-new-cli-recid
    no-error.
    if available buf_clients
    then do:
        assign
            p-new-obj-type = buf_clients.obj-type
            p-new-obj-code = buf_clients.obj-code
        .
    end.
    else do:
        assign
            p-new-obj-type = ""
            p-new-obj-code = 0
        .
    end.
end.
END PROCEDURE.
