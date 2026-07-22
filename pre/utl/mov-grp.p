block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mov-grp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/mov-grp.p $":U .
define variable vss-description as character no-undo init "Перемещение в группу по списку товаров".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table gds-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
    define variable v-goods-counter as integer      no-undo.
    define variable v-yesno         as logical      no-undo .
    define variable v-grp           as character    no-undo .
    define variable v-grp-recid     as recid        no-undo.
    define frame f-progress
        v-goods-counter label "Обработано товаров"
    with side-labels view-as dialog-box.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_goods         for ub.goods.
do
for buf_gds-grp
  , buf_goods
on error undo, return error
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
    run str/gds-list.w (
          input parparentproc
        , input v-cntxt-host-code-obj
        , input v-cntxt-obj-type
        , input v-cntxt-obj-code
    ).
    assign
        v-yesno = yes
    .
    message
        "Переместить в выбранную группу все товары списка ?  Вы уверены ?"
    view-as alert-box question
    buttons OK-Cancel
    update v-yesno.
    if v-yesno = yes
    then do:
        assign
            v-grp = "":U
        .
        run ref/gds-grp.w (
              input parparentproc
            , input "b-sel":U
            , input v-cntxt-obj-type
            , input v-cntxt-obj-code
            , input-output v-grp
        ).
        assign
            v-grp-recid = integer( v-grp )
        no-error.
        if not error-status :error
        and v-grp-recid <> 0
        then do:
            find first buf_gds-grp no-lock
                 where recid( buf_gds-grp ) = v-grp-recid
            .
            if buf_gds-grp.is-term = no
            then do:
                message
                    "Товары можно переместить "
                    skip "только в терминальную группу."
                view-as alert-box information.
            end.
            else do:
                view frame f-progress.
                v-goods-counter = 0.
                for each gds-list
                :
                    assign
                        v-goods-counter = v-goods-counter + 1
                    .
                    find first buf_goods exclusive-lock
                         where buf_goods.artic = gds-list.artic
                           and buf_goods.prod-type = gds-list.prod-type
                           and buf_goods.prod-code = gds-list.prod-code
                    .
                    assign
                        buf_goods.grp-code = buf_gds-grp.node-code
                    .
                    display
                        v-goods-counter
                    with frame f-progress.
                    process events.
                end.
                message
                    "Перемещение товаров в выбранную группу закончено успешно"
                    skip
                view-as alert-box information.
            end.
        end.
    end.
end.
