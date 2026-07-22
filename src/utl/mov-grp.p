block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: mov-grp.p $
$Archive: utl/mov-grp.p $

Перемещение в группу по списку товаров

Автор: Белоусов Илья Александрович
Дата создания: 02/01/07
Author: Ilia Belousov
Creation date: 02/01/07

Input:

Output:

*/
define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mov-grp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/mov-grp.p $":U .
define variable vss-description as character no-undo init "Перемещение в группу по списку товаров".
{ cmp/trg-def.i }
{ gbl/getcntxt.i def }
{ cmp/gds-list.i gds-list def "new shared" }

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
    { gbl/getcntxt.i get }
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