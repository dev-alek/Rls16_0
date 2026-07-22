block-level on error undo, throw.
define input parameter p-mainmenu-handle    as handle           no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fbrsetim.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/fbrsetim.p $":U .
define variable vss-description as character no-undo init "Установка признака блюда для товаров с рецептом производства.".
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
    define variable v-last-gds-code     as integer        no-undo.
    define variable v-yesno             as logical        no-undo.
    define variable p-obj-type    as character      no-undo.
    define variable p-obj-code    as integer        no-undo.
    define buffer buf_recipe        for recipe.
    define buffer buf_goods         for goods.
do
for buf_recipe
  , buf_goods
on error undo, return error
:
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in p-mainmenu-handle
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
    assign
        p-obj-type = v-cntxt-obj-type
        p-obj-code = v-cntxt-obj-code
    .
    message
        "На объекте будет установлен атрибут 'блюдо'"
        skip "для всех товаров, для которых есть"
        skip "хотя бы один рецепт типа 'производство'"
        skip(1)
        skip "Объект:" p-obj-type p-obj-code
        skip(1)
        skip "Установить атрибут?"
    view-as alert-box question
    buttons yes-no
    title "Установка атрибута 'блюдо' на объекте"
    update v-yesno.
    if v-yesno = no
    then do:
        undo, return error.
    end.
if session :set-wait-state( "compiler" ) then.
    do transaction
    on error undo, return error
    :
        assign
            v-last-gds-code = 0
        .
        for each buf_recipe no-lock
           where buf_recipe.obj-type = p-obj-type
             and buf_recipe.obj-code = p-obj-code
        by buf_recipe.artic
        by buf_recipe.prod-type
        by buf_recipe.prod-code
        on error undo, return error
        :
            if buf_recipe.recipe-type = 'производство':U
            then do:
                find first buf_goods no-lock
                     where buf_goods.artic     = buf_recipe.artic
                       and buf_goods.prod-type = buf_recipe.prod-type
                       and buf_goods.prod-code = buf_recipe.prod-code
                .
                if buf_goods.gds-code <> v-last-gds-code
                then do:
                    run set-is-menu in this-procedure (
                        input p-obj-type
                        , input p-obj-code
                        , input buf_goods.gds-code
                    ).
                    assign
                        v-last-gds-code = buf_goods.gds-code
                    .
                end.
            end.
        end.
        assign
            v-last-gds-code = 0
        .
        for each buf_recipe no-lock
           where buf_recipe.obj-type = ""
             and buf_recipe.obj-code = 0
        by buf_recipe.artic
        by buf_recipe.prod-type
        by buf_recipe.prod-code
        on error undo, return error
        :
            if buf_recipe.recipe-type = 'производство':U
            then do:
                find first buf_goods no-lock
                     where buf_goods.artic     = buf_recipe.artic
                       and buf_goods.prod-type = buf_recipe.prod-type
                       and buf_goods.prod-code = buf_recipe.prod-code
                .
                if buf_goods.gds-code <> v-last-gds-code
                then do:
                    run set-is-menu in this-procedure (
                          input p-obj-type
                        , input p-obj-code
                        , input buf_goods.gds-code
                    ).
                    assign
                        v-last-gds-code = buf_goods.gds-code
                    .
                end.
            end.
        end.
    end.
    message
        "Атрибут 'блюдо' установлен."
        skip(1)
        skip "Объект:" p-obj-type p-obj-code
    view-as alert-box question
    title "Установка атрибута 'блюдо' на объекте"
    .
if session :set-wait-state( "" ) then.
end.
procedure set-is-menu :
define input parameter p-obj-type as character    no-undo.
define input parameter p-obj-code as integer      no-undo.
define input parameter p-gds-code as integer      no-undo.
    define variable v-fbr-gds-obj-recid   as recid        no-undo.
    define variable v-fbr-obj-type        as character      no-undo.
    define variable v-fbr-obj-code        as integer        no-undo.
    define buffer buf_fbr-gds-obj   for fbr-gds-obj.
do
for buf_fbr-gds-obj
on error undo, return error
:
    find first buf_fbr-gds-obj exclusive-lock
         where buf_fbr-gds-obj.obj-type = p-obj-type
           and buf_fbr-gds-obj.obj-code = p-obj-code
           and buf_fbr-gds-obj.gds-code = p-gds-code
    no-error.
    if not available buf_fbr-gds-obj
    then do:
        run ref/fgdsobj1.p (
              input-output v-fbr-gds-obj-recid
            , input 'ДОБАВЛЕНИЕ':U
            , input no
            , input p-gds-code
            , input p-obj-type
            , input p-obj-code
            , input 0
            , input p-obj-type
            , input p-obj-code
            , input no
            , input yes
            , input no
            , input no
            , input no
            , input no
        ) no-error.
        if error-status :error
        then do:
            message
                    vss-workfile vss-revision vss-description
            skip "Ошибка при создании записи товара производства на объекте."
            skip return-value
            skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
    end.
    else do:
        assign
            v-fbr-gds-obj-recid = recid( buf_fbr-gds-obj )
        .
        run ref/fgdsobj1.p (
              input-output v-fbr-gds-obj-recid
            , input 'ИЗМЕНЕНИЕ':U
            , input no
            , input buf_fbr-gds-obj.gds-code
            , input buf_fbr-gds-obj.obj-type
            , input buf_fbr-gds-obj.obj-code
            , input buf_fbr-gds-obj.fbr-grp-code
            , input buf_fbr-gds-obj.obj-type
            , input buf_fbr-gds-obj.obj-code
            , input buf_fbr-gds-obj.is-cd
            , input yes
            , input buf_fbr-gds-obj.is-modificator
            , input buf_fbr-gds-obj.is-null-price
            , input buf_fbr-gds-obj.is-season
            , input buf_fbr-gds-obj.is-semi-finished
        ) no-error.
        if error-status :error
        then do:
            message
                    vss-workfile vss-revision vss-description
            skip "Ошибка при изменении записи товара производства на объекте."
            skip return-value
            skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
    end.
end.
end procedure.
