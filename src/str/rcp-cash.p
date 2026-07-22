block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rcp-cash.p $
$Archive: str/rcp-cash.p $

Пересылка компонентов составных товаров на кассу

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/07/05
Author: Bakhtadze Natalya
Creation date: 09/07/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
def input param action as char no-undo.


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rcp-cash.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/rcp-cash.p $":U .
define variable vss-description as character no-undo init "пересылка компонентов составных товаров на кассу".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/gds-list.i gds-list def "new shared" }
{ str/def-crcp.i "NEW SHARED"}
define variable rid-list as  char    no-undo .
define variable ii as integer no-undo.
define variable choice as integer no-undo.
define variable glog as logical no-undo .
FOR EACH gds-list:
    DELETE gds-list.
END.
run gbl/d-askw.w (input "Выбор топливных рецептов",
                      input ("Передать на кассу "),
                      input "|",
                      input "Все топливные рецепты|Выбрать рецепт из справочника|Отказ",
                      input "|",
                      input 1,
                      input 3,
                      output choice).
CASE choice:
    when 1 then do:
    run ref/rcp-all.w (
          input parparentproc
        , input "b-sel"
        , input {&petrolium-manufacturing}
        , input ?
        , input p-obj-type
        , input p-obj-code
        , output rid-list
    ).
    if rid-list = "" then do:
            message "Вы не определили список топливных рецептов для пересылки их составляющих!"
            view-as alert-box WARNING.
            return.
    end.
    do ii = 1 to NUm-entries(rid-list):
        FIND FIRST ub.recipe no-lock where recid(ub.recipe) = integer(entry(ii, rid-list)) No-ERROR.
        if NOT avail ub.recipe then NEXT.
        if ub.recipe.recipe-type <> {&petrolium-manufacturing} then NEXT.
        FIND FIRST ub.goods no-lock where ub.goods.artic = ub.recipe.artic AND
                                                              ub.goods.prod-type = ub.recipe.prod-type AND
                                                              ub.goods.prod-code = ub.recipe.prod-code NO-ERROR.
        FIND FIRST gds-list NO-LOCK where gds-list.artic = ub.goods.artic AND
                                                                    gds-list.prod-type = ub.goods.prod-type AND
                                                                    gds-list.prod-code = ub.goods.prod-code No-ERROR.
        IF not avail gds-list then do:
            create gds-list.
            buffer-copy goods to gds-list.
        end.
    end.
end.
when 2 then do:
   FOR EACH ub.recipe no-lock where ub.recipe.recipe-type =  {&petrolium-manufacturing}:
        FIND FIRST ub.goods no-lock where ub.goods.artic = ub.recipe.artic AND
                                                              ub.goods.prod-type = ub.recipe.prod-type AND
                                                              ub.goods.prod-code = ub.recipe.prod-code NO-ERROR.
        FIND FIRST gds-list NO-LOCK where gds-list.artic = goods.artic AND
                                                                    gds-list.prod-type = ub.goods.prod-type AND
                                                                    gds-list.prod-code = ub.goods.prod-code No-ERROR.
        IF not avail gds-list then do:
            create gds-list.
            buffer-copy goods to gds-list.
        end.
    END.
end.
END CASE.
if not  can-find(first gds-list no-lock) then do:
        message "К сожалению список топливных рецептов пуст!"
        view-as alert-box WARNING.
        return.
end.
glog = yes.
message
"Передать все товары списка на кассы ?"
view-as alert-box question buttons OK-Cancel update glog.
if glog <> true then return.
run str/diallog.w (
              input parparentproc
            , input this-procedure
            , input 'str/s-cgds.p':U
            , input (string(p-obj-code) + {&delim-par} + action)
            , input no /*p-auto-go*/
            , input '':U
            , input 'Передача товаров на кассы') no-error .