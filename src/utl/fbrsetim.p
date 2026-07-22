block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fbrsetim.p $
$Archive: utl/fbrsetim.p $

Установка признака блюда для товаров с рецептом производства.

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:
    p-obj-type
    p-obj-code - объект для поиска признаков ресторана
Output:

*/

define input parameter p-mainmenu-handle    as handle           no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fbrsetim.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/fbrsetim.p $":U .
define variable vss-description as character no-undo init "Установка признака блюда для товаров с рецептом производства.".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
/*define input parameter p-obj-type as character    no-undo.*/
/*define input parameter p-obj-code as integer      no-undo.*/

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
    { gbl/getcntxt.i get " " p-mainmenu-handle }
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
    { gbl/working.i }
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
            if buf_recipe.recipe-type = {&manufacturing}
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
            if buf_recipe.recipe-type = {&manufacturing}
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
    end.        /* do transaction */
    message
        "Атрибут 'блюдо' установлен."
        skip(1)
        skip "Объект:" p-obj-type p-obj-code
    view-as alert-box question
    title "Установка атрибута 'блюдо' на объекте"
    .
    { gbl/stopwork.i }
end.

/*==========================================================================*/
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
    then do:        /* Создать buf_fbr-gds-obj */
        run ref/fgdsobj1.p (
              input-output v-fbr-gds-obj-recid
            , input {&add-def}                      /* par-mode          */
            , input no                              /* p-silent          */
            , input p-gds-code                      /* p-gds-code        */
            , input p-obj-type                      /* p-obj-type        */
            , input p-obj-code                      /* p-obj-code        */
            , input 0                               /* p-fbr-grp-code    */
            , input p-obj-type                      /* p-fbr-obj-type    */
            , input p-obj-code                      /* p-fbr-obj-code    */
            , input no                              /* p-is-cd           */
            , input yes                             /* p-is-menu         */
            , input no                              /* p-is-modificator  */
            , input no                              /* p-is-null-price   */
            , input no                              /* p-is-season       */
            , input no                              /* p-is-semi-finished*/
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
    end.        /* if not available buf_fbr-gds-obj  */
    else do:
        assign
            v-fbr-gds-obj-recid = recid( buf_fbr-gds-obj )
        .
        run ref/fgdsobj1.p (
              input-output v-fbr-gds-obj-recid
            , input {&update}                            /* par-mode          */
            , input no                                   /* p-silent          */
            , input buf_fbr-gds-obj.gds-code             /* p-gds-code        */
            , input buf_fbr-gds-obj.obj-type             /* p-obj-type        */
            , input buf_fbr-gds-obj.obj-code             /* p-obj-code        */
            , input buf_fbr-gds-obj.fbr-grp-code         /* p-fbr-grp-code    */
            , input buf_fbr-gds-obj.obj-type             /* p-fbr-obj-type    */
            , input buf_fbr-gds-obj.obj-code             /* p-fbr-obj-code    */
            , input buf_fbr-gds-obj.is-cd                /* p-is-cd           */
            , input yes                                  /* p-is-menu         */
            , input buf_fbr-gds-obj.is-modificator       /* p-is-modificator  */
            , input buf_fbr-gds-obj.is-null-price        /* p-is-null-price   */
            , input buf_fbr-gds-obj.is-season            /* p-is-season       */
            , input buf_fbr-gds-obj.is-semi-finished     /* p-is-semi-finished*/
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
    end.        /* NOT ( if not available buf_fbr-gds-obj  ) */
end.
end procedure. /* set-is-menu */