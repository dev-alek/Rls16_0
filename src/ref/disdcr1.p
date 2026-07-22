block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: disdcr1.p $
$Archive: ref/disdcr1.p $

Сохранение изменений скидок ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/27/07
Author: Bakhtadze Natalya
Creation date: 05/27/07

*/

define input parameter p-mode            as character no-undo .
define input parameter p-d-card          like ub.dis-dc-rule.d-card no-undo .
define input parameter p-host-code       like ub.dis-dc-rule.host-code no-undo .
define input parameter p-obj-type        like ub.dis-dc-rule.obj-type no-undo .
define input parameter p-obj-code        like ub.dis-dc-rule.obj-code no-undo .
define temp-table tt0-dis-dc-rule no-undo like ub.dis-dc-rule.
DEFINE INPUT PARAMETER TABLE FOR tt0-dis-dc-rule.


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: disdcr1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/disdcr1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений скидок ДК".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4':u,p-d-card,p-host-code,p-obj-type,p-obj-code)" }
{ cmp/trg-def.i }
{ cmp/library.i }

define variable v-deleted as logical no-undo .
define variable v-err-mess as character no-undo .
define buffer buf_dis-dc-rule for ub.dis-dc-rule.
define buffer buf_dis-card for ub.dis-card.

_main:
do
on error undo, return error return-value
:
  find first buf_dis-card no-lock where buf_dis-card.d-card = p-d-card no-error .
  if not available buf_dis-card then do:
    undo, return error substitute("&1 &2 &3&4Не найдена ДК &5"
                                 , vss-workfile
                                 , vss-revision
                                 , vss-description
                                 , {&new-line}
                                 , p-d-card).
  end.
  /*обновим dis-dc-rule */
  FOR EACH tt0-dis-dc-rule where
  on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
  on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )  :
    if tt0-dis-dc-rule.obj-type = {&cmp} and g#db-num <> 0 then next.
    if tt0-dis-dc-rule.obj-type = '':U and g#db-num <> 0 then next.
    if p-mode <> {&add-def} then do:
      find FIRST buf_dis-dc-rule WHERE
                buf_dis-dc-rule.d-card = p-d-card
            AND buf_dis-dc-rule.host-code = tt0-dis-dc-rule.host-code
            AND buf_dis-dc-rule.obj-type = tt0-dis-dc-rule.obj-type
            AND buf_dis-dc-rule.obj-code = tt0-dis-dc-rule.obj-code
            AND buf_dis-dc-rule.pos-type = tt0-dis-dc-rule.pos-type
            AND buf_dis-dc-rule.discnt-role = tt0-dis-dc-rule.discnt-role
            AND buf_dis-dc-rule.nonunique = tt0-dis-dc-rule.nonunique
            no-error.
    end.
    IF p-mode = {&add-def}
    or not available buf_dis-dc-rule
    or buf_dis-dc-rule.rule-num <> tt0-dis-dc-rule.rule-num THEN DO:
      if p-mode = {&add-def}
      or not available buf_dis-dc-rule then do:
        create buf_dis-dc-rule.
        assign
        buf_dis-dc-rule.d-card = p-d-card
        buf_dis-dc-rule.obj-type = tt0-dis-dc-rule.obj-type
        buf_dis-dc-rule.obj-code = tt0-dis-dc-rule.obj-code
        buf_dis-dc-rule.host-code = tt0-dis-dc-rule.host-code
        buf_dis-dc-rule.pos-type = tt0-dis-dc-rule.pos-type
        buf_dis-dc-rule.nonunique = tt0-dis-dc-rule.nonunique
        buf_dis-dc-rule.discnt-role = tt0-dis-dc-rule.discnt-role
        .
      end.
      assign
      buf_dis-dc-rule.rule-num = tt0-dis-dc-rule.rule-num
      buf_dis-dc-rule.rl-root = tt0-dis-dc-rule.rule-num /*здесь могут быть только dr-appl-object*/
      buf_dis-dc-rule.templ-rl-root = tt0-dis-dc-rule.templ-rl-root
      buf_dis-dc-rule.time-templ-rl-root = tt0-dis-dc-rule.time-templ-rl-root
      buf_dis-dc-rule.nonunique = tt0-dis-dc-rule.nonunique
      .
      release buf_dis-dc-rule no-error.
&scop dis-dc-rule-code tt0-dis-dc-rule.discnt-role
      IF ERROR-STATUS:ERROR THEN DO:
        assign
        v-err-mess = substitute("Ошибка при сохранении типа скидки &1 (POS &2) на ДК &3 на ФИРМЕ &4 Объект &5&6&7&8"
                                ,{&dis-dc-rule-name}
                                ,tt0-dis-dc-rule.pos-type
                                ,p-d-card
                                ,tt0-dis-dc-rule.host-code
                                ,tt0-dis-dc-rule.obj-type
                                ,tt0-dis-dc-rule.obj-code
                                ,{&new-line}
                                ,error-status:get-message(1)
                                ,return-value
                                ).
        undo _main, return error v-err-mess.
      END.
    END. /*были изменения*/
  END. /*FOR EACH tt0-dis-dc-rule:*/
  if p-mode <> {&add-def} then do:
    FOR EACH buf_dis-dc-rule where
           buf_dis-dc-rule.d-card = p-d-card
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )  :
      if buf_Dis-dc-rule.obj-type = {&cmp} and g#db-num <> 0 then next.
      if buf_dis-dc-rule.obj-type = '':U and g#db-num <> 0 then next.
      if (buf_dis-dc-rule.obj-type = {&shop}
          or
          buf_dis-dc-rule.obj-type = {&stock} )
      and ((buf_dis-dc-rule.obj-type <> p-obj-type
           or buf_dis-dc-rule.obj-code <> p-obj-code))  then next.
      if buf_dis-dc-rule.templ-rl-root = 0 then next.
        FIND FIRST tt0-dis-dc-rule NO-LOCK WHERE
            tt0-dis-dc-rule.d-card = p-d-card
        AND tt0-dis-dc-rule.host-code = buf_dis-dc-rule.host-code
        AND tt0-dis-dc-rule.obj-type = buf_dis-dc-rule.obj-type
        AND tt0-dis-dc-rule.obj-code = buf_dis-dc-rule.obj-code
        AND tt0-dis-dc-rule.pos-type = buf_dis-dc-rule.pos-type
        AND tt0-dis-dc-rule.discnt-role = buf_dis-dc-rule.discnt-role
        AND tt0-dis-dc-rule.nonunique = buf_dis-dc-rule.nonunique
        NO-ERROR.
      IF NOT AVAILABLE tt0-dis-dc-rule THEN DO:
        delete buf_dis-dc-rule no-error.
        IF error-status:error
        THEN DO:
&scop dis-dc-rule-code buf_dis-dc-rule.discnt-role
          assign
          v-err-mess = substitute("Ошибка при удалении типа скидки скидки &1 (POS &2) на ДК &3 на ФИрме &4 Объект &5&6&7&8&9"
                                  ,{&dis-dc-rule-name}
                                  ,buf_dis-dc-rule.pos-type
                                  ,p-d-card
                                  ,buf_dis-dc-rule.host-code
                                  ,buf_dis-dc-rule.obj-type
                                  ,buf_dis-dc-rule.obj-code
                                  ,{&new-line}
                                  ,error-status:get-message(1)
                                  ,return-value
                                  ).
          undo _main, return error v-err-mess.
        END. /*tt0-dis-dc-rule.pos-type*/
      END. /*IF NOT AVAILABLE tt0-dis-dc-rule THEN DO:*/
    END. /*FOR EACH buf_dis-dc-rule where buf_dis-dc-rule.d-card = p-d-card:*/
  end.
end. /*doe*/