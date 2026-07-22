block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dgr-lst.p $
$Archive: ref/dgr-lst.p $

Пакетное изменение по списку скидок товара на объекте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/11/06
Author: Bakhtadze Natalya
Creation date: 12/11/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle as handle no-undo .
define input parameter p-parameter   as character no-undo .

/*
p-parameter включает
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter pardelete-OK as logical no-undo .
*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dgr-lst.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dgr-lst.p $":U .
define variable vss-description as character no-undo init "Пакетное изменение по списку скидок товара на объекте".
{ cmp/vssrevis.i }
{ gbl/getcntxt.i def }
{ cmp/trg-def.i }
{ cmp/library.i }
{ ref/disgdsru.i }
{ cmp/gds-list.i gds-list def shared }
{ cmp/bb-list.i bb-list def shared }

{ str/bc-gnrt.i new bc }
{ ref/disgdsr1.i bc }

define variable p-obj-type like ub.clients.obj-type no-undo .
define variable p-obj-code like ub.clients.obj-code no-undo .
define variable pardelete-ok as logical no-undo .
define variable p-list-name as character no-undo .
DEFINE VARIABLE var-object as character no-undo init {&table_dis-gds-rule}.
{ cmp/bitoper.i }
{ ref/temp-dsc.i "SHARED" var-object }


define variable v-no-ask as logical no-undo .
define variable v-view-log as logical no-undo .
define variable log-file-name                as character      no-undo init "dgr-lst.txt".
define variable v-stop                       as logical        no-undo .

define variable v-choice as integer no-undo .
DEFINE VARIABLE num-rec as integer no-undo .
DEFINE VARIABLE num-rec-ok as integer no-undo .
define variable v-mes as character no-undo .
define variable v-ok as logical no-undo .

define variable loc-glob as logical no-undo.
define variable loc-firm as logical no-undo.
define variable loc-object as logical no-undo.

&scoped-define cd-type-code temp-disc.pos-type

&scoped-define dis-gds-rule-code temp-disc.discnt-role


&scoped-define  disgdsru-value-get-error assign ~
v-mes = substitute("товар с кодом &1, &2, POS &3, Тип скидки &4: ошибка при определении значения скидки товара на объекте:&5&6&5&7" ~
                   , ~{&list-code~} ~
                   , (p-obj-type  + string(p-obj-code))   ~
                   , ~{&cd-type-name~} ~
                   , ~{&dis-gds-rule-name}~
                   , ~{&new-line~}     ~
                   , error-status:get-message(1) ~
                   , return-value ).
&scoped-define  disgdsru-write-error assign ~
v-mes = substitute("товар с кодом &1, &2, POS &3, тип скидки &4: ошибка при записи скидки товара на объекте:&5&6&5&7"   ~
                   , ~{&list-code~} ~
                   , (p-obj-type  + string(p-obj-code))   ~
                   , ~{&cd-type-name~} ~
                   , ~{&dis-gds-rule-name}~
                   , ~{&new-line~}     ~
                   , error-status:get-message(1) ~
                   , return-value ).

&scoped-define  disgdsru-delete-error assign ~
v-mes = substitute("товар с кодом &1, &2, POS &3, тип скидки &4: ошибка при удалении скидки товара на объекте:&5&6&5&7" ~
                   , ~{&list-code~} ~
                   , (p-obj-type  + string(p-obj-code))   ~
                   , ~{&cd-type-name~} ~
                   , ~{&dis-gds-rule-name}~
                   , ~{&new-line~}     ~
                   , error-status:get-message(1) ~
                   , return-value ).

&scoped-define  disgdsru-del-attr-error assign ~
v-mes = substitute("товар с кодом &1, &2, POS &3, тип скидки &4: ошибка при удалении атрибутов скидки товара на объекте:&5&6&5&7" ~
                   , ~{&list-code~} ~
                   , (p-obj-type  + string(p-obj-code))   ~
                   , ~{&cd-type-name~} ~
                   , ~{&dis-gds-rule-name}~
                   , ~{&new-line~}     ~
                   , error-status:get-message(1) ~
                   , return-value ).

assign
p-obj-type  = entry(1, p-parameter, {&delim-par})
p-obj-code = integer(entry(2, p-parameter, {&delim-par}))
pardelete-ok = logical(entry(3, p-parameter, {&delim-par}))
p-list-name = entry(4, p-parameter, {&delim-par})
no-error
.
if error-status:error then do:
 run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , {&new-line}
                         , error-status:get-message(1)
                         , return-value
                         )).
  assign
  v-view-log = yes.
  { str/cdviewlg.i
  "'!!!При изменении скидок товара на объекте по списку товаров произошли ошибки!!!'"
  "'dgr-lst.txt'" }
  return .
end.
run write-log  in p-log-handle(
                                 input 0
                               , "&DLine").
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Изменение скидок товара на объекте &1&2 по списку товаров", p-obj-type, p-obj-code)).

{ gbl/getcntxt.i get }
&scop list-code gds-list.gds-code
if p-list-name = "gds-list" then do:
  _gds-list:
  for each gds-list
    ON ERROR undo, NEXT:
      num-rec = num-rec + 1.
      v-ok = false.
      run check-actg in this-procedure (
                                        input gds-list.grp-code
                                        ,input gds-list.gds-code
                                        ,output v-ok ) no-error.
      if v-ok = true then do :
          run do-changes in this-procedure (
                                    input gds-list.gds-code
                                    ,input p-obj-type
                                    ,input p-obj-code) no-error .
      end.
      if error-status:error then do:
        run write-log-and-file in p-log-handle (
                  input 1
                , input log-file-name
                , input 1
                , input return-value
                                            ).
        assign
        v-view-log = yes.
        if v-no-ask  then do:
          run gbl/d-askw.w (
                        input "Изменение скидок товара на объекте по списку товаров"
                        ,input substitute("Товар с кодом &1 &2&3 - не удалось провести изменение скидок товара на объекте"
                                        , gds-list.gds-code
                                        , p-obj-type
                                        , p-obj-code
                                        )
                        ,input "|"
                        ,input ("Продолжить|" +
                              "Продолжить и больше не запрашивать подтверждения на продолжение|" +
                              "Прекратить")
                        ,input "||"
                        ,input 1
                        ,input 3
                        ,output v-choice).
          if v-choice = 3 then do:
            leave.
          end.
          if v-choice = 2 then do:
            assign
            v-no-ask = yes.
          end.
        end.
      end. /*if error-status:error */
      else do:
        num-rec-ok = num-rec-ok + 1.
        if pardelete-ok then delete gds-list.
      end.
      run show-counter in p-log-handle .
      run write-counter in p-log-handle (substitute("Обработано &1 из них успешно &2"
                                                  , num-rec
                                                  , num-rec-ok
                                                  )) no-error.

      run get-stop-state in p-log-handle (
          output v-stop
      ).
      if v-stop then do:
        leave _gds-list.
      end.

  END.
end.
&scop list-code bb-list.gds-code
if p-list-name = "bb-list" then do:
  _bb-list:
  for each bb-list no-lock
  /*group by bb-list.gds-code*/
  group by bb-list.b-code
    ON ERROR undo, NEXT:

      if not first-of(bb-list.b-code) then next _bb-list .
      num-rec = num-rec + 1.
      v-ok = false.
      run check-actg in this-procedure (
                                        input bb-list.grp-code
                                        ,input bb-list.gds-code
                                        ,output v-ok ) no-error.
      if v-ok = true then do :
            run do-changes-bb in this-procedure (
                                          input bb-list.gds-code
                                          ,input bb-list.b-code
                                          ,input p-obj-type
                                          ,input p-obj-code) no-error .
      end.
      if error-status:error then do:
        run write-log-and-file in p-log-handle (
                  input 1
                , input log-file-name
                , input 1
                , input return-value
                                            ).
        assign
        v-view-log = yes.
        if v-no-ask  then do:
          run gbl/d-askw.w (
                        input "Изменение скидок товара на объекте по списку бар-кодов"
                        ,input substitute("Товар с кодом &1 бар-код &2 &3&4 - не удалось провести изменение скидок товара на объекте"
                                        , bb-list.gds-code
                                        , bb-list.b-code
                                        , p-obj-type
                                        , p-obj-code
                                        )
                        ,input "|"
                        ,input ("Продолжить|" +
                              "Продолжить и больше не запрашивать подтверждения на продолжение|" +
                              "Прекратить")
                        ,input "||"
                        ,input 1
                        ,input 3
                        ,output v-choice).
          if v-choice = 3 then do:
            leave.
          end.
          if v-choice = 2 then do:
            assign
            v-no-ask = yes.
          end.
        end.
      end. /*if error-status:error */
      else do:
        num-rec-ok = num-rec-ok + 1.
        if pardelete-ok then delete bb-list.
      end.
      run show-counter in p-log-handle .
      run write-counter in p-log-handle (substitute("Обработано &1 из них успешно &2"
                                                  , num-rec
                                                  , num-rec-ok
                                                  )) no-error.

      run get-stop-state in p-log-handle (
          output v-stop
      ).
      if v-stop then do:
        leave _bb-list.
      end.
  END.
end.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Пакетное изменение скидок по списку завершено: из &1 элементов списка успешно изменено &2", num-rec, num-rec-ok )).
.
{ str/cdviewlg.i
"'!!!При изменении скидок товара на объекте по списку произошли ошибки!!!'"
"'dgr-lst.txt'" }

&scop list-code gds-list.gds-code
procedure do-changes :
define input parameter pargds-code like ub.gds-obj.gds-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .

DEFINE VARIABLE loc#log as logical no-undo .
DEFINE VARIABLE var-deleted as logical no-undo .
define variable v-check as character no-undo .
define variable v-correct as logical no-undo .
define variable v-error-code as character no-undo .
define variable v-rule-num as integer no-undo .

define variable v-obj-type like ub.clients.obj-type no-undo .
define variable v-obj-code like ub.clients.obj-code no-undo .
define variable v-host-code  as integer   no-undo .

define buffer buf_dis-gds-rule for ub.dis-gds-rule.
define buffer buf_del-dis-gds-rule for ub.dis-gds-rule.
define buffer buf_dis-rule         for ub.dis-rule.

  /*Получим код фирмы объекта*/
  { gbl/hostcode.i p-obj-type p-obj-code v-host-code }

    _main:
  do
  on error undo, return error
  :
    _temp-disc:
    for each temp-disc no-lock
        on error undo _main, return error:

      /*получим область действия*/
      find first buf_dis-rule no-lock where buf_dis-rule.rule-num = temp-disc.rule-num no-error.
      if avail buf_dis-rule then do:
          if buf_dis-rule.host-code = 0 then     assign v-obj-type = ''         v-obj-code = 0 .
          else if buf_dis-rule.obj-code = 0 then assign v-obj-type = {&cmp}     v-obj-code = v-host-code .
          else                                   assign v-obj-type = p-obj-type v-obj-code = p-obj-code .
      end.

      CASE temp-disc.action:
        when yes then do:
          if v-obj-type = p-obj-type then do: /*для объектов*/
          run disgdsru-write in this-procedure (
                                                 input p-obj-type
                                                ,input p-obj-code
                                                ,input pargds-code
                                                ,input temp-disc.pos-type
                                                ,input temp-disc.discnt-role
                                                ,input temp-disc.templ-rl-root
                                                ,input temp-disc.time-templ-rl-root
                                                ,input temp-disc.rule-num
                                                ,input temp-disc.nonunique
                                                    )  no-error.
          end.
          else do:
              run cmp-disgdsru-write in this-procedure (
                                                 input pargds-code
                                                ,input v-obj-type
                                                ,input v-obj-code
                                                ,input temp-disc.pos-type
                                                ,input temp-disc.templ-rl-root
                                                ,input temp-disc.time-templ-rl-root
                                                ,input temp-disc.discnt-role
                                                ,input temp-disc.rule-num
                                                ,input temp-disc.nonunique
                                                    )  no-error.
          end.

          if error-status:error then do:
            {&disgdsru-write-error}
            undo _main, return error v-mes.
          end.
        end. /*when yes*/
        when no then do: /*здесь удаляем привязки текущего объекта, а также все фирменные и глобальные.*/
          var-deleted = no.
          /*ищем подходящие привязки*/
          for each buf_dis-gds-rule no-lock where
                    ( buf_dis-gds-rule.obj-type = p-obj-type or buf_dis-gds-rule.obj-type = {&cmp}      or buf_dis-gds-rule.obj-type = '' )
                and ( buf_dis-gds-rule.obj-code = p-obj-code or buf_dis-gds-rule.obj-code = v-host-code or buf_dis-gds-rule.obj-code = 0 )
                and buf_dis-gds-rule.gds-code = pargds-code
                and buf_dis-gds-rule.pos-type = temp-disc.pos-type
                and buf_dis-gds-rule.discnt-role = temp-disc.discnt-role
                and ( if buf_dis-gds-rule.rule-num = temp-disc.rule-num then buf_dis-gds-rule.nonunique = temp-disc.nonunique else true )
          and buf_dis-gds-rule.time-templ-rl-root = temp-disc.time-templ-rl-root
          and buf_dis-gds-rule.templ-rl-root = temp-disc.templ-rl-root
          and (temp-disc.rule-num = ? or temp-disc.rule-num = 0 or buf_dis-gds-rule.rule-num = temp-disc.rule-num )
          :
            assign
            v-rule-num = buf_dis-gds-rule.rule-num
            .
            /*проверим возможность удаления из dis-gds-rule*/
            find first buf_del-dis-gds-rule exclusive-lock where
              recid(buf_del-dis-gds-rule) = recid(buf_dis-gds-rule)
            no-wait no-error.
            if not available buf_del-dis-gds-rule then do:
&scoped-define cd-type-code temp-disc.pos-type
              undo _main, return error substitute( "Товар &1 &2 POS &3 шаблон правила &4, правило &5&6" +
                                                   "занята запись скидки на объекте"
                                                   , pargds-code
                                                   , (p-obj-type  + string(p-obj-code))
                                                   , {&cd-type-name}
                                                   , temp-disc.templ-rl-root
                                                   , v-rule-num
                                                   , {&new-line}
                                                   ).

            end.
            /*удаляем привязку правила к товару*/
            delete buf_del-dis-gds-rule no-error.
            if error-status:error then do:
              {&disgdsru-delete-error}
              undo _main, return error v-mes.
            end.
          end. /*for each buf_dis-gds-rule*/
        end.
      END CASE.
    end. /*for each temp-disc*/
  end.

end procedure. /* do-changes */

&scop list-code bb-list.gds-code
procedure do-changes-bb :
define input parameter pargds-code like ub.gds-obj.gds-code no-undo .
define input parameter parb-code like ub.bar-code.b-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .

DEFINE VARIABLE loc#log as logical no-undo .
DEFINE VARIABLE var-deleted as logical no-undo .
define variable v-check as character no-undo .
define variable v-correct as logical no-undo .
define variable v-error-code as character no-undo .
define variable v-rule-num as integer no-undo .
define variable v-number-action as character no-undo .
define variable v-bar-code as character no-undo .

define variable v-obj-type like ub.clients.obj-type no-undo .
define variable v-obj-code like ub.clients.obj-code no-undo .
define variable v-host-code  as integer             no-undo .

define buffer buf_dis-rule          for ub.dis-rule.
define buffer buf_dis-gds-rule for ub.dis-gds-rule.
define buffer buf_del-dis-gds-rule  for ub.dis-gds-rule.
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
define buffer buf_dis-gds-rule-attr for ub.dis-gds-rule-attr.
define buffer buf_bb-list           for bb-list.

  /*Получим код фирмы объекта*/
  { gbl/hostcode.i p-obj-type p-obj-code v-host-code }

    _main:
  do
  on error undo, return error
  :
    _temp-disc:
    for each temp-disc no-lock
        on error undo _main, return error:

      /*получим область действия*/
      find first buf_dis-rule no-lock where buf_dis-rule.rule-num = temp-disc.rule-num no-error.
      if avail buf_dis-rule then do:
          if buf_dis-rule.host-code = 0 then     assign v-obj-type = ''         v-obj-code = 0 .
          else if buf_dis-rule.obj-code = 0 then assign v-obj-type = {&cmp}     v-obj-code = v-host-code .
          else                                   assign v-obj-type = p-obj-type v-obj-code = p-obj-code .
      end.

      CASE temp-disc.action:
        when yes then do:
          if v-obj-type = p-obj-type then do: /*для объектов*/
          run disgdsru-write in this-procedure (
                                                 input p-obj-type
                                                ,input p-obj-code
                                                ,input pargds-code
                                                ,input temp-disc.pos-type
                                                ,input temp-disc.discnt-role
                                                ,input temp-disc.templ-rl-root
                                                ,input temp-disc.time-templ-rl-root
                                                ,input temp-disc.rule-num
                                                ,input string(parb-code)
                                                    )  no-error.
          end.
          else do:
              run cmp-disgdsru-write in this-procedure (
                                                 input pargds-code
                                                ,input v-obj-type
                                                ,input v-obj-code
                                                ,input temp-disc.pos-type
                                                ,input temp-disc.templ-rl-root
                                                ,input temp-disc.time-templ-rl-root
                                                ,input temp-disc.discnt-role
                                                ,input temp-disc.rule-num
                                                ,input string(parb-code)
                                                    )  no-error.
          end.

          if error-status:error then do:
            {&disgdsru-write-error}
            undo _main, return error v-mes.
          end.

          /*Для бонусов*/
          find first buf_dis-gds-rule no-lock where
                ( buf_dis-gds-rule.obj-type = v-obj-type )
            and ( buf_dis-gds-rule.obj-code = v-obj-code )
            and buf_dis-gds-rule.gds-code           = pargds-code
            and buf_dis-gds-rule.pos-type           = temp-disc.pos-type
            and buf_dis-gds-rule.discnt-role        = temp-disc.discnt-role
            and buf_dis-gds-rule.templ-rl-root      = temp-disc.templ-rl-root
            and buf_dis-gds-rule.time-templ-rl-root = temp-disc.time-templ-rl-root
            and buf_dis-gds-rule.rule-num           = temp-disc.rule-num
            and buf_dis-gds-rule.nonunique          = string(parb-code)
          no-error .
          if avail buf_dis-gds-rule then do:
               find first buf_dis-cfg-rule no-lock
               where buf_dis-cfg-rule.table-name    = {&table_dis-gds-rule}
                 and buf_dis-cfg-rule.templ-rl-root = temp-disc.templ-rl-root
                 and buf_dis-cfg-rule.pos-type      = temp-disc.pos-type
                 and buf_dis-cfg-rule.time-templ-rl-root = temp-disc.time-templ-rl-root
               no-error .
               if avail buf_dis-cfg-rule and
                  buf_dis-cfg-rule.discnt-role = 'bonus-qnty' and
                  buf_dis-cfg-rule.nonunique   = 'bar-code.b-code'
               then do:
                 for each buf_bb-list no-lock where buf_bb-list.b-code = parb-code :
                   /*если есть доп код, значит берем его, если нет, то берем основной код*/
                   if buf_bb-list.b-str = '' then v-bar-code = string(buf_bb-list.b-code) .
                   else v-bar-code = buf_bb-list.b-str .

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
                      run def-number-action(temp-disc.templ-rl-root, output v-number-action) .
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
                      /*run cr_dis-gds-rule-attr(recid(buf_dis-gds-rule)) .*/
                   /*end.*/
                 end. /*for each buf_bb-list*/
               end.
          end.
        end. /*when yes*/
        when no then do: /*здесь удаляем привязки текущего объекта, а также все фирменные и глобальные.*/
          var-deleted = no.
          /*ищем подходящие привязки*/
          for each buf_dis-gds-rule no-lock where
                    ( buf_dis-gds-rule.obj-type = p-obj-type or buf_dis-gds-rule.obj-type = {&cmp}      or buf_dis-gds-rule.obj-type = '' )
                and ( buf_dis-gds-rule.obj-code = p-obj-code or buf_dis-gds-rule.obj-code = v-host-code or buf_dis-gds-rule.obj-code = 0 )
                and buf_dis-gds-rule.gds-code = pargds-code
                and buf_dis-gds-rule.pos-type = temp-disc.pos-type
                and buf_dis-gds-rule.discnt-role = temp-disc.discnt-role
                and buf_dis-gds-rule.nonunique = string(parb-code)
          and buf_dis-gds-rule.time-templ-rl-root = temp-disc.time-templ-rl-root
          and buf_dis-gds-rule.templ-rl-root = temp-disc.templ-rl-root
          and (temp-disc.rule-num = ? or temp-disc.rule-num = 0 or buf_dis-gds-rule.rule-num = temp-disc.rule-num)
          :
            assign
            v-rule-num = buf_dis-gds-rule.rule-num
            .
            /*проверим возможность удаления из dis-gds-rule*/
            find first buf_del-dis-gds-rule exclusive-lock where
              recid(buf_del-dis-gds-rule) = recid(buf_dis-gds-rule)
            no-wait no-error.
            if not available buf_del-dis-gds-rule then do:
&scoped-define cd-type-code temp-disc.pos-type
              undo _main, return error substitute( "Товар &1 бар-код &2 &3 POS &4 шаблон правила &5, правило &6&7" +
                                                   "занята запись скидки на объекте"
                                                   , pargds-code
                                                   , parb-code
                                                   , (p-obj-type  + string(p-obj-code))
                                                   , {&cd-type-name}
                                                   , temp-disc.templ-rl-root
                                                   , v-rule-num
                                                   , {&new-line}
                                                   ).

            end.
            /*удаление из buf_dis-gds-rule-attr, на текущий момент здесь хранятся привязки к доп бар кодам*/
            for each buf_dis-gds-rule-attr exclusive-lock
            where buf_dis-gds-rule-attr.gds-code    = buf_dis-gds-rule.gds-code
              and buf_dis-gds-rule-attr.obj-type    = buf_dis-gds-rule.obj-type
              and buf_dis-gds-rule-attr.obj-code    = buf_dis-gds-rule.obj-code
              and buf_dis-gds-rule-attr.pos-type    = buf_dis-gds-rule.pos-type
              and buf_dis-gds-rule-attr.discnt-role = buf_dis-gds-rule.discnt-role
              and buf_dis-gds-rule-attr.nonunique   = buf_dis-gds-rule.nonunique
            :
                delete buf_dis-gds-rule-attr no-error .
                if error-status:error then do:
                    {&disgdsru-del-attr-error}
                    undo _main, return error v-mes.
                end.
            end.
            /*удаляем привязку правила к товару*/
            delete buf_del-dis-gds-rule no-error.
            if error-status:error then do:
              {&disgdsru-delete-error}
              undo _main, return error v-mes.
            end.
          end. /*for each buf_dis-gds-rule*/
        end. /*when no*/
      END CASE.
    end. /*for each temp-disc*/
  end.

end procedure. /* do-changes */

procedure check-actg :
define input parameter p-grp-code as integer no-undo.
define input parameter p-gds-code as integer no-undo.
define output parameter p-ok as logical no-undo.
do
on error undo, return error
:
      if v-cntxt-db-num = 0 then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_gds-discount_global_work':U
          {&cntxt-global}
          0
          '':U
          0
          0
          p-grp-code
          0
          false
          loc-glob
          }
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_gds-discount_firm_work':U
          {&cntxt-firm}
          v-cntxt-host-code-obj
          '':U
          0
          0
          p-grp-code
          0
          false
          loc-firm
          }

      end.
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_gds-discount_object_work':U
        {&cntxt-object}
        v-cntxt-host-code-obj
        v-cntxt-obj-type
        v-cntxt-obj-code
        0
        p-grp-code
        0
        false
        loc-object
      }
      if ((if v-cntxt-db-num = 0 and loc-glob then 1 else 0) +
      (if v-cntxt-db-num = 0 and loc-firm then 1 else 0) +
      (if loc-object then 1 else 0)) <> 0 then do:
        p-ok = true.
      end.
      else do :
        find first gds-grp no-lock
             where gds-grp.node-code = p-grp-code no-error.
        v-mes = substitute("товар с кодом &1, &2,группа товаров &3 : У Вас отсутствуют права на назначение скидки на товар как по объекту,"
                          + "так и глобально либо Вы находитесь в БД, в которой их назначить невозможно"
                          , p-gds-code
                          , (p-obj-type  + string(p-obj-code))
                          , (string(gds-grp.node-code) + " " + gds-grp.node-name)
                          ).
         undo,return error v-mes.
      end.
end.
end procedure.