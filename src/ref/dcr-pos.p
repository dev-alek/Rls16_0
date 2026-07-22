block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dcr-pos.p $
$Archive: ref/dcr-pos.p $

Подбор POS для вводимой/включаемой скидки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/19/09
Author: Bakhtadze Natalya
Creation date: 05/19/09

*/

define input parameter p-mode as character no-undo .
define input parameter p-silent as logical no-undo .
define input parameter p-templ-rl-root as integer no-undo .
define input parameter p-host-code as integer no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-sts as integer no-undo .
define input parameter p-rule-num as integer no-undo .
define output parameter p-pos-type as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dcr-pos.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dcr-pos.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define variable v-cont-det-pos as logical no-undo .
define variable v-ii as integer no-undo .
define variable glog as logical no-undo .

define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
define buffer buf_dis-thbj-rule  for ub.dis-thbj-rule.

if can-find( first ub.dis-cfg-rule no-lock where
                   ub.dis-cfg-rule.templ-rl-root = p-templ-rl-root
               and ub.dis-cfg-rule.table-name = {&table_dis-thbj-rule})
or p-mode = {&add-def} then do:
  if p-mode = {&update}
  or p-mode = {&lookup} then do:
    if p-sts <> integer({&deleted-status-int}) then do:
      if can-find( first ub.dis-cfg-rule no-lock where
                        ub.dis-cfg-rule.templ-rl-root = p-templ-rl-root
                    and ub.dis-cfg-rule.table-name = {&table_dis-thbj-rule}) then do:
        find first buf_dis-thbj-rule no-lock where
                  buf_dis-thbj-rule.host-code = p-host-code
              and buf_dis-thbj-rule.obj-type = p-obj-type
              and buf_dis-thbj-rule.obj-code = p-obj-code
              and buf_dis-thbj-rule.rule-num = p-rule-num no-error.
        if not available buf_Dis-thbj-rule then do:
          p-pos-type = '':U.
          v-cont-det-pos = yes.
        end.
        else do:
          p-pos-type = buf_Dis-thbj-rule.pos-type.
        end.
      end.
    end.
  end. /*if p-mode = {&update}*/
  if p-mode = {&add-def}
  or v-cont-det-pos then do:
    _v-ii:
    do v-ii = 1 to num-entries({&codes-discnt-not-pos}):
      find first  buf_dis-cfg-rule no-lock where
                buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
            and buf_dis-cfg-rule.pos-type = entry(v-ii, {&codes-discnt-not-pos}) no-error .
      if available buf_dis-cfg-rule then do:
        assign
        p-pos-type = buf_dis-cfg-rule.pos-type.
        leave _v-ii.
      end.
    end.
    if p-pos-type = '':U then do:
      if p-obj-code > 0 then do:
        if p-obj-type = {&stock} then do:
          p-pos-type = {&cd-type-no-cd}.
        end.
        else do:
          { gbl/dflt-cd.i p-obj-type p-obj-code p-pos-type }
            find first  buf_dis-cfg-rule no-lock where
                      buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
                  and buf_dis-cfg-rule.pos-type = p-pos-type no-error .
          if not available buf_dis-cfg-rule then do:
            find first  buf_dis-cfg-rule no-lock where
                      buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
                  and buf_dis-cfg-rule.pos-type = {&cd-type-no-cd} no-error .
            if available buf_dis-cfg-rule then do:
              if p-mode <> {&lookup} then do:
                if not p-silent then do:
                  message
                  substitute("Правило скидки по данному шаблону неприменимо для типа касс, работающих на &1&2&3" +
                              "использование данного правила будет возможно только при расчете скидок по накладной&3" +
                              "все равно хотите добавить/изменить правило скидки?"
                              ,p-obj-type
                              ,p-obj-code
                              ,{&new-line})
                  view-as alert-box question buttons yes-no update glog.
                  if not glog then undo,  return error.
                end.
              end.
              p-pos-type = buf_dis-cfg-rule.pos-type.
            end.
            else do:
              if p-mode <> {&lookup} and p-pos-type = '' then do:
                message
                substitute("Правило скидки по данному шаблону невозможно ввести:&1" +
                            "неопределено для какого типа касс возможно его использование&1"
                            ,{&new-line})
                view-as alert-box error .
                undo,  return error.
              end.
            end.
          end.
        end. /*else stock*/
      end. /*if tt-dis-rule.obj-code > 0 then do:*/
      else do:
        /*надо выбрать POS*/
        if p-mode <> {&lookup} then do:
          find /*не first!!!*/  buf_dis-cfg-rule no-lock where
                    buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
                and buf_dis-cfg-rule.pos-type <> {&cd-type-no-cd} no-error .
          if not available buf_dis-cfg-rule
          and ambiguous  buf_Dis-cfg-rule then do:
            run ref/sel-cdt.w ( input p-templ-rl-root
                              ,output p-pos-type) no-error.
            if p-pos-type = '':U then do:
              return error.
            end.
          end.
          else do:
            p-pos-type = buf_dis-cfg-rule.pos-type.
          end.
        end. /*if p-mode <> {&lookup} then do:*/
      end. /*else /*if tt-dis-rule.obj-code > 0 then do:*/*/
    end. /*if v-pos-type = '':U then do:*/
  end. /*if p-mode = {&add-def}*/
  if p-pos-type = '':U
  and p-mode <> {&lookup}
  then do:
    return error substitute("Не удалось определить место действия для правила скидки &1", p-rule-num).
  end.
end. /*if can-find( first ub.dis-cfg-rule no-lock where*/