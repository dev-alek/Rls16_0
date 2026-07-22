block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: diffdstr.p $
$Archive: ref/diffdstr.p $

Поиск расписания идентичного вводимому

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/20/04
Author: Bakhtadze Natalya
Creation date: 09/20/04

*/

define input parameter p-mode as character no-undo .
/*{&add-def} {&update}*/
define temp-table tt0-dis-time-rule no-undo like ub.dis-time-rule.
define temp-table tt0-term_dis-time-rule no-undo like ub.dis-time-rule.
DEFINE INPUT PARAMETER TABLE FOR tt0-dis-time-rule.
DEFINE INPUT PARAMETER TABLE FOR tt0-term_dis-time-rule.
define output parameter p-found-rule-num like ub.dis-time-rule.time-rule-num no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: diffdstr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/diffdstr.p $":U .
define variable vss-description as character no-undo init "Поиск правила скидки идентичного вводимому".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define buffer buf_dis-time-rule for ub.dis-time-rule.
define buffer dub_dis-time-rule for ub.dis-time-rule.
define buffer dub_term-dis-time-rule for ub.dis-time-rule.
define buffer dub-tt0-term_dis-time-rule for tt0-term_dis-time-rule.
define variable v-res as character no-undo .
define variable ii as integer no-undo .
define variable kk as integer no-undo .
define variable dub as integer no-undo .
define temp-table tt-compare no-undo
field f-recid as recid
field time-rule-num like ub.dis-time-rule.time-rule-num
index pi is unique primary f-recid
.

do
on error undo, return error
:
  find first tt0-dis-time-rule no-lock no-error.
  if error-status:error then do:
    undo, return error substitute("Неверно передана таблица tt0-dis-time-rule: нет записи").
  end.
  if tt0-dis-time-rule.is-term and tt0-dis-time-rule.root = no then do:
    undo, return error substitute("Неверно передана таблица tt0-dis-time-rule: запись правила скидки является записью детализации").
  end.
  if p-mode = {&update} then do:
    find first buf_dis-time-rule where
              buf_dis-time-rule.time-rule-num  = tt0-dis-time-rule.time-rule-num no-error .
    if not available buf_dis-time-rule then do:
      undo, return error substitute("Неверно передана таблица tt0-dis-time-rule: нет расписания с № &1", tt0-dis-time-rule.time-rule-num).
    end.
  end.
  if tt0-dis-time-rule.is-term then do:
    for each dub_dis-time-rule no-lock where
            dub_dis-time-rule.templ-rl-root = tt0-dis-time-rule.templ-rl-root:
      if p-mode = {&update}
      and dub_dis-time-rule.time-rule-num = tt0-dis-time-rule.time-rule-num then next.
      buffer-compare
      dub_dis-time-rule
      except
      time-rule-num
      des
      rl-root
      to tt0-dis-time-rule
      case-sensitive
      save result  in v-res
      .
      if v-res = "":u then do:
        assign
        p-found-rule-num = dub_dis-time-rule.time-rule-num
        .
        return.
      end.
    end.
  end.
  else do:
    for each dub_dis-time-rule no-lock where
            dub_dis-time-rule.templ-rl-root = tt0-dis-time-rule.templ-rl-root:
      assign
      dub = 0
      .
      for each tt-compare:
        delete tt-compare.
      end.
      for each dub_term-dis-time-rule no-lock where
            dub_term-dis-time-rule.upper-time-rule-num = dub_dis-time-rule.time-rule-num:
        assign
        dub = dub + 1
        .
        for each dub-tt0-term_dis-time-rule no-lock:
          buffer-compare
          dub_term-dis-time-rule
          except
          time-rule-num des
          upper-time-rule-num
          rl-root
          to dub-tt0-term_dis-time-rule
          case-sensitive
          save result  in v-res
          .
          if v-res = "":u then do:
            create tt-compare.
            assign
            tt-compare.time-rule-num = dub_term-dis-time-rule.time-rule-num
            tt-compare.f-recid = recid(dub-tt0-term_dis-time-rule)
            .
          end.
          /*v-re = ""*/
        end. /*        for each dub-tt0-term_dis-time-rule no-lock:*/
      end. /*for each dub_term-dis-time-rule no-lock where*/
      assign
      ii = 0
      kk = 0
      .
      for each dub-tt0-term_dis-time-rule no-lock:
        assign
        ii = ii + 1
        .
        find first tt-compare no-lock where
                  tt-compare.f-recid = recid(dub-tt0-term_dis-time-rule) no-error .
        if available tt-compare then do:
          assign
          kk = kk + 1
          .
        end.
      end.
      if ii = kk and ii = dub then do:
        assign
        p-found-rule-num = dub_dis-time-rule.time-rule-num
        .
        return.
      end.
    end. /*for each dub_dis-time-rule.no-lock where */
  end. /* not if tt0-dis-time-rule.is-term then do:*/
end. /*doe*/