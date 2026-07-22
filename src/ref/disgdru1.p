block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: disgdru1.p $
$Archive: ref/disgdru1.p $

Сохранение изменеий скидок товара на объекте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/10/06
Author: Bakhtadze Natalya
Creation date: 12/10/06

*/

define input parameter p-mode            as character no-undo .
define input parameter p-gds-code        like ub.dis-gds-rule.gds-code no-undo .
define input parameter p-obj-type        like ub.dis-gds-rule.obj-type no-undo .
define input parameter p-obj-code        like ub.dis-gds-rule.obj-code no-undo .
define temp-table tt0-dis-gds-rule no-undo like ub.dis-gds-rule.
DEFINE INPUT PARAMETER TABLE FOR tt0-dis-gds-rule.


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: disgdru1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/disgdru1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменеий атрибутов товара на объекте".
{ cmp/vssrevis.i "substitute('&1|&2|&3':u,p-gds-code,p-obj-type,p-obj-code)" }
{ cmp/trg-def.i }
{ cmp/library.i }
{ ref/disgdsru.i }

define variable v-deleted as logical no-undo .
define variable v-err-mess as character no-undo .
define buffer buf_dis-gds-rule for ub.dis-gds-rule.
define buffer buf_goods for ub.goods.

_main:
do
on error undo, return error return-value
:
  find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
  if not available buf_goods then do:
    undo, return error substitute("&1 &2 &3&4Не найден товар с кодом &5"
                                 , vss-workfile
                                 , vss-revision
                                 , vss-description
                                 , {&new-line}
                                 , p-gds-code).
  end.
  /*обновим dis-gds-rule */
  FOR EACH tt0-dis-gds-rule
  on error  undo _Main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo _Main, return error substitute( "&1. stop", vss-workfile )
  on endkey undo _Main, return error substitute( "&1. endkey", vss-workfile )
  :
    if tt0-dis-gds-rule.obj-type = {&cmp} and g#db-num <> 0 then next.
    if tt0-dis-gds-rule.obj-type = '':U and g#db-num <> 0 then next.
    if (tt0-dis-gds-rule.obj-type = {&shop}
        or
        tt0-dis-gds-rule.obj-type = {&stock} )
    and ((tt0-dis-gds-rule.obj-type <> p-obj-type
          or tt0-dis-gds-rule.obj-code <> p-obj-code))  then next.

    if p-mode <> {&add-def} then do:
      find FIRST buf_dis-gds-rule WHERE buf_dis-gds-rule.gds-code = p-gds-code
      AND buf_dis-gds-rule.obj-type = tt0-dis-gds-rule.obj-type
      AND buf_dis-gds-rule.obj-code = tt0-dis-gds-rule.obj-code
      AND buf_dis-gds-rule.pos-type = tt0-dis-gds-rule.pos-type
      AND buf_dis-gds-rule.discnt-role = tt0-dis-gds-rule.discnt-role
      and buf_dis-gds-rule.nonunique = tt0-dis-gds-rule.nonunique no-error.
    end.
    IF p-mode = {&add-def}
    or not available buf_dis-gds-rule
    or buf_dis-gds-rule.rule-num <> tt0-dis-gds-rule.rule-num THEN DO:
      run disgdsru-write in this-procedure (
                                           INPUT tt0-dis-gds-rule.obj-type
                                          ,INPUT tt0-dis-gds-rule.obj-code
                                          ,input p-gds-code
                                          ,INPUT tt0-dis-gds-rule.pos-type
                                          ,INPUT tt0-dis-gds-rule.discnt-role
                                          ,INPUT tt0-dis-gds-rule.templ-rl-root
                                          ,INPUT tt0-dis-gds-rule.time-templ-rl-root
                                          ,INPUT tt0-dis-gds-rule.rule-num
                                          ,INPUT tt0-dis-gds-rule.nonunique
                                          ) NO-ERROR.
      IF ERROR-STATUS:ERROR THEN DO:
        assign
        v-err-mess = substitute("Ошибка при сохранении скидки товара &1 на объекте &2 POS &3 тип скидки &4:&5&6 &7"
                                , p-gds-code
                                , (tt0-dis-gds-rule.obj-type + string(tt0-dis-gds-rule.obj-code))
                                , tt0-dis-gds-rule.pos-type
                                , tt0-dis-gds-rule.discnt-role
                                , {&new-line}
                                ,error-status:get-message(1)
                                ,return-value).
        undo _main, return error v-err-mess.
      END.
    END. /*были изменения*/
  END. /*FOR EACH tt0-dis-gds-rule:*/
  if p-mode <> {&add-def} then do:
    FOR EACH buf_dis-gds-rule where
            buf_dis-gds-rule.gds-code = p-gds-code
    on error  undo _Main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo _Main, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _Main, return error substitute( "&1. endkey", vss-workfile )
    :
      if buf_dis-gds-rule.obj-type = {&cmp} and g#db-num <> 0 then next.
      if buf_dis-gds-rule.obj-type = '':U and g#db-num <> 0 then next.
      if (buf_dis-gds-rule.obj-type = {&shop}
          or
          buf_dis-gds-rule.obj-type = {&stock} )
      and ((buf_dis-gds-rule.obj-type <> p-obj-type
           or buf_dis-gds-rule.obj-code <> p-obj-code))  then next.
      if buf_dis-gds-rule.pos-type = '':U
      and buf_dis-gds-rule.discnt-role = '':U
      and buf_dis-gds-rule.nonunique = '':U
      then next.
      FIND FIRST tt0-dis-gds-rule NO-LOCK WHERE
            tt0-dis-gds-rule.gds-code = p-gds-code
        AND tt0-dis-gds-rule.obj-type = buf_dis-gds-rule.obj-type
        AND tt0-dis-gds-rule.obj-code = buf_dis-gds-rule.obj-code
        AND tt0-dis-gds-rule.pos-type = buf_dis-gds-rule.pos-type
        AND tt0-dis-gds-rule.discnt-role = buf_dis-gds-rule.discnt-role
        AND tt0-dis-gds-rule.nonunique = buf_dis-gds-rule.nonunique NO-ERROR.
      IF NOT AVAILABLE tt0-dis-gds-rule THEN DO:
        ASSIGN
        v-deleted = NO.
        delete buf_Dis-gds-rule no-error.
        IF  error-status:error
        THEN DO:
          assign
          v-err-mess = substitute("Ошибка при удалении скидки товара на объекте &1 &2 &3 тип скидки &4:&5&6 &7"
                                  , p-gds-code
                                  , (buf_dis-gds-rule.obj-type + string(buf_dis-gds-rule.obj-code))
                                  , buf_dis-gds-rule.pos-type
                                  ,buf_dis-gds-rule.discnt-role
                                  ,{&new-line}
                                  ,error-status:get-message(1)
                                  ,return-value
                                  ).
          undo _main, return error v-err-mess.
        END. /*tt0-dis-gds-rule.attr-code*/
      END. /*IF NOT AVAILABLE tt0-dis-gds-rule THEN DO:*/
    END. /*FOR EACH buf_dis-gds-rule where buf_dis-gds-rule.gds-code = p-gds-code:*/
  end.
end. /*doe*/