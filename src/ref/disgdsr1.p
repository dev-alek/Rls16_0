block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: disgdsr1.p $
$Archive: ref/disgdsr1.p $

Сохранение изменений скидок товара на объекте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/12/06
Author: Bakhtadze Natalya
Creation date: 11/12/06

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
define variable vss-workfile    as character no-undo init "$Workfile: disgdsr1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/disgdsr1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений скидок товара на объекте".
{ cmp/vssrevis.i "substitute('&1|&2|&3':u,p-gds-code,p-obj-type,p-obj-code)" }
{ cmp/trg-def.i }
{ cmp/library.i }
{ str/bc-gnrt.i new bc }
{ ref/disgdsr1.i bc }

define variable v-deleted as logical no-undo .
define variable v-err-mess as character no-undo .
define variable v-bb-list  as character no-undo .
define variable v-cnt      as integer   no-undo .
define variable v-number-action as character no-undo .
define variable v-bar-code as character no-undo .

define buffer buf_dis-gds-rule for ub.dis-gds-rule.
define buffer buf_dis-gds-rule-attr for ub.dis-gds-rule-attr.
define buffer buf_goods for ub.goods.
define buffer buf_bar-code          for ub.bar-code.
define buffer buf_prod-bc           for ub.prod-bc.

/*в параметре p-mode может быть передан список баркодов из dis-gdsi.w*/
do v-cnt = 2 to num-entries(p-mode, {&comma-char}):
    if entry( v-cnt, p-mode, {&comma-char} ) begins "dk" then do:
        find first buf_prod-bc no-lock where recid(buf_prod-bc) = int( substring( entry( v-cnt, p-mode, {&comma-char} ), 3 ) ) no-error .
        if avail buf_prod-bc then do:
            v-bb-list = v-bb-list + ( if v-bb-list = "":U then "":U else {&comma-char} ) + buf_prod-bc.b-str .
        end.
    end.
    else do:
        find first buf_bar-code no-lock where recid(buf_bar-code) = int( entry( v-cnt, p-mode, {&comma-char} ) ) no-error .
        if avail buf_bar-code then do:
            v-bb-list = v-bb-list + ( if v-bb-list = "":U then "":U else {&comma-char} ) + string( buf_bar-code.b-code ) .
        end.
    end.
end.
p-mode = entry( 1, p-mode, {&comma-char} ) .

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
  on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
  on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )  :
    if tt0-dis-gds-rule.obj-type = {&cmp} and g#db-num <> 0 then next.
    if tt0-dis-gds-rule.obj-type = '':U and g#db-num <> 0 then next.
    if p-mode <> {&add-def} then do:
      find FIRST buf_dis-gds-rule WHERE
                buf_dis-gds-rule.gds-code = p-gds-code
            AND buf_dis-gds-rule.obj-type = tt0-dis-gds-rule.obj-type
            AND buf_dis-gds-rule.obj-code = tt0-dis-gds-rule.obj-code
            AND buf_dis-gds-rule.pos-type = tt0-dis-gds-rule.pos-type
            AND buf_dis-gds-rule.discnt-role = tt0-dis-gds-rule.discnt-role
            and buf_dis-gds-rule.nonunique = tt0-dis-gds-rule.nonunique
            no-error.
    end.
    IF p-mode = {&add-def}
    or not available buf_dis-gds-rule
    or buf_dis-gds-rule.rule-num <> tt0-dis-gds-rule.rule-num THEN DO:
      if p-mode = {&add-def}
      or not available buf_dis-gds-rule then do:
        create buf_Dis-gds-rule.
        assign
        buf_dis-gds-rule.gds-code = p-gds-code
        buf_dis-gds-rule.obj-type = tt0-dis-gds-rule.obj-type
        buf_dis-gds-rule.obj-code = tt0-dis-gds-rule.obj-code
        buf_dis-gds-rule.pos-type = tt0-dis-gds-rule.pos-type
        buf_dis-gds-rule.nonunique = tt0-dis-gds-rule.nonunique
        buf_dis-gds-rule.discnt-role = tt0-dis-gds-rule.discnt-role
        .
      end.
      assign
      buf_dis-gds-rule.rule-num = tt0-dis-gds-rule.rule-num
      buf_dis-gds-rule.rl-root = tt0-dis-gds-rule.rule-num /*здесь могут быть только dr-appl-obj*/
      buf_dis-gds-rule.time-templ-rl-root = tt0-dis-gds-rule.time-templ-rl-root
      buf_dis-gds-rule.nonunique = tt0-dis-gds-rule.nonunique
      buf_dis-gds-rule.templ-rl-root = tt0-dis-gds-rule.templ-rl-root
      buf_dis-gds-rule.time-templ-rl-root = tt0-dis-gds-rule.time-templ-rl-root
      .
      if buf_dis-gds-rule.templ-rl-root = 91 then do:    /* NCR марки,фишки на кол-во */
                 do v-cnt = 1 to num-entries(v-bb-list, {&comma-char}):
                 /*for each buf_bb-list no-lock where buf_bb-list.b-code = parb-code :*/
                   /*если есть доп код, значит берем его, если нет, то берем основной код*/
                   v-bar-code = entry( v-cnt, v-bb-list, {&comma-char} ) .

                   find first buf_dis-gds-rule-attr exclusive-lock
                   where buf_dis-gds-rule-attr.gds-code    = buf_dis-gds-rule.gds-code
                     and buf_dis-gds-rule-attr.obj-type    = buf_dis-gds-rule.obj-type
                     and buf_dis-gds-rule-attr.obj-code    = buf_dis-gds-rule.obj-code
                     and buf_dis-gds-rule-attr.pos-type    = buf_dis-gds-rule.pos-type
                     and buf_dis-gds-rule-attr.discnt-role = buf_dis-gds-rule.discnt-role
                     and buf_dis-gds-rule-attr.nonunique   = buf_dis-gds-rule.nonunique
                     and entry(1,buf_dis-gds-rule-attr.attr-value,",") = v-bar-code
                   no-error.
                   if not avail buf_dis-gds-rule-attr then do:
                      create buf_dis-gds-rule-attr .
      end.
                   run def-number-action(buf_dis-gds-rule.templ-rl-root, output v-number-action) .
                   assign
                    buf_dis-gds-rule-attr.gds-code    = buf_dis-gds-rule.gds-code
                    buf_dis-gds-rule-attr.obj-type    = buf_dis-gds-rule.obj-type
                    buf_dis-gds-rule-attr.obj-code    = buf_dis-gds-rule.obj-code
                    buf_dis-gds-rule-attr.pos-type    = buf_dis-gds-rule.pos-type
                    buf_dis-gds-rule-attr.discnt-role = buf_dis-gds-rule.discnt-role
                    buf_dis-gds-rule-attr.nonunique   = buf_dis-gds-rule.nonunique
                    buf_dis-gds-rule-attr.attr-code   = v-number-action
                    buf_dis-gds-rule-attr.attr-value  = v-bar-code + ",A"
                   .
                 end. /*for each buf_bb-list*/

          /*run cr_dis-gds-rule-attr(recid(buf_dis-gds-rule)) .*/
      end. /*if buf_dis-gds-rule.templ-rl-root = 91*/
      release buf_dis-gds-rule no-error.
      IF ERROR-STATUS:ERROR THEN DO:
        assign
        v-err-mess = substitute("Ошибка при сохранении скидки &1 (POS &2) на товар &3 на &4&5&6&7&6&8"
                                ,tt0-dis-gds-rule.templ-rl-root
                                ,tt0-dis-gds-rule.pos-type
                                ,p-gds-code
                                ,tt0-dis-gds-rule.obj-type
                                ,tt0-dis-gds-rule.obj-code
                                ,{&new-line}
                                ,error-status:get-message(1)
                                ,return-value
                                ).
        undo _main, return error v-err-mess.
      END.
    END. /*были изменения*/
  END. /*FOR EACH tt0-dis-gds-rule:*/
  if p-mode <> {&add-def} then do:
    FOR EACH buf_dis-gds-rule where
            buf_dis-gds-rule.gds-code = p-gds-code
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )  :

      if buf_Dis-gds-rule.obj-type = {&cmp} and g#db-num <> 0 then next.
      if buf_dis-gds-rule.obj-type = '':U and g#db-num <> 0 then next.
      if (buf_dis-gds-rule.obj-type = {&shop}
          or
          buf_dis-gds-rule.obj-type = {&stock} )
      and ((buf_dis-gds-rule.obj-type <> p-obj-type
           or buf_dis-gds-rule.obj-code <> p-obj-code))  then next.
      if buf_dis-gds-rule.templ-rl-root = 0 then next.
        FIND FIRST tt0-dis-gds-rule NO-LOCK WHERE
            tt0-dis-gds-rule.gds-code = p-gds-code
        AND tt0-dis-gds-rule.obj-type = buf_dis-gds-rule.obj-type
        AND tt0-dis-gds-rule.obj-code = buf_dis-gds-rule.obj-code
        AND tt0-dis-gds-rule.pos-type = buf_dis-gds-rule.pos-type
        AND tt0-dis-gds-rule.discnt-role = buf_dis-gds-rule.discnt-role
        AND tt0-dis-gds-rule.nonunique = buf_dis-gds-rule.nonunique
        NO-ERROR.
      IF NOT AVAILABLE tt0-dis-gds-rule THEN DO:
            /*удаление из buf_dis-gds-rule-attr*/
            for each buf_dis-gds-rule-attr exclusive-lock
            where buf_dis-gds-rule-attr.gds-code    = buf_dis-gds-rule.gds-code
              and buf_dis-gds-rule-attr.obj-type    = buf_dis-gds-rule.obj-type
              and buf_dis-gds-rule-attr.obj-code    = buf_dis-gds-rule.obj-code
              and buf_dis-gds-rule-attr.pos-type    = buf_dis-gds-rule.pos-type
              and buf_dis-gds-rule-attr.discnt-role = buf_dis-gds-rule.discnt-role
              and buf_dis-gds-rule-attr.nonunique   = buf_dis-gds-rule.nonunique
            :
                delete buf_dis-gds-rule-attr no-error.
                IF error-status:error
                THEN DO:
                  assign
                  v-err-mess = substitute("Ошибка при удалении атрибутов скидки &1 (POS &2) на товар &3 на &4&5&6&7&6&8"
                                          ,buf_dis-gds-rule.templ-rl-root
                                          ,buf_dis-gds-rule.pos-type
                                          ,p-gds-code
                                          ,buf_dis-gds-rule.obj-type
                                          ,buf_dis-gds-rule.obj-code
                                          ,{&new-line}
                                          ,error-status:get-message(1)
                                          ,return-value
                                          ).
                  undo _main, return error v-err-mess.
                END.
            end.
        /*удаляем правило*/
        delete buf_dis-gds-rule no-error.
        IF error-status:error
        THEN DO:
          assign
          v-err-mess = substitute("Ошибка при удалении скидки &1 (POS &2) на товар &3 на &4&5&6&7&6&8"
                                  ,buf_dis-gds-rule.templ-rl-root
                                  ,buf_dis-gds-rule.pos-type
                                  ,p-gds-code
                                  ,buf_dis-gds-rule.obj-type
                                  ,buf_dis-gds-rule.obj-code
                                  ,{&new-line}
                                  ,error-status:get-message(1)
                                  ,return-value
                                  ).
          undo _main, return error v-err-mess.
        END. /*tt0-dis-gds-rule.pos-type*/
      END. /*IF NOT AVAILABLE tt0-dis-gds-rule THEN DO:*/
    END. /*FOR EACH buf_dis-gds-rule where buf_dis-gds-rule.gds-code = p-gds-code:*/
  end.
end. /*doe*/
