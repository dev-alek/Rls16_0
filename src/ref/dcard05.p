block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dcard05.p $
$Archive: ref/dcard05.p $

Определение полного номера карты по первой подходящей маске для данной карты

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/12/05
Author: Bakhtadze Natalya
Creation date: 10/12/05

в маске должны быть символы дисконтной кода DDDD и могут быть символы контрольной цифры C

*/

define input parameter p-d-card                 like ub.dis-card.d-card no-undo .
/*код проверяемой карты*/
define input parameter p-type                   like ub.dis-card.type no-undo .
define input parameter p-emitent-host-code      like ub.dis-card.emitent-host-code no-undo .
define input parameter p-issue-code             like ub.dis-card.issue-code no-undo .
/*объект выдачи*/
define output parameter p-cli-mask              like ub.dis-card-mask.cli-mask no-undo .
define output parameter p-full-number           like ub.dis-card.d-card no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dcard05.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dcard05.p $":U .
define variable vss-description as character no-undo init "Определение полного номера карты по первой подходящей маске для данной карты".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4':u,p-d-card,p-type,p-emitent-host-code,p-issue-code)" }

{ cmp/str-glbl.i }
{ cmp/library.i }

define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-descr     as character no-undo .
define variable v-is-correct as logical no-undo .
define variable v-found      as logical no-undo .
define variable v-type       as character no-undo .
define variable v-d-str   as character no-undo .
define variable ii as integer no-undo .
define variable v-cli-mask as character no-undo .
define variable v-full-number as character no-undo .



define buffer buf_dis-card-mask for ub.dis-card-mask.

do
on error undo, return error substitute("&1 &2 &3:&4&5 &6"
                                        , vss-workfile
                                        , vss-revision
                                        , vss-description
                                        , {&new-line}
                                        , error-status:get-message(1)
                                        , return-value )

:

  { gbl/hostcode.i {&shop} p-issue-code v-host-code }
  _maska:
  for each buf_dis-card-mask no-lock where
          buf_dis-card-mask.emitent-host-code = p-emitent-host-code
      AND buf_dis-card-mask.type              = p-type
      AND buf_Dis-card-mask.stts              = integer({&current-status-int})
  by buf_Dis-card-mask.host-code
  by buf_Dis-card-mask.obj-type
  by buf_Dis-card-mask.obj-code
  by buf_Dis-card-mask.rank:
    if index(buf_Dis-card-mask.cli-mask, 'D':U) = 0 then next.
    if index(buf_Dis-card-mask.cli-mask, {&question-mark}) > 0 then next.
    if buf_dis-card-mask.host-code <> 0
    And buf_dis-card-mask.host-code <> v-host-code then next.
    if
    buf_dis-card-mask.obj-type <> "":U
    AND
       (buf_dis-card-mask.obj-type <> {&shop}
    or buf_dis-card-mask.obj-code <> p-issue-code) then NEXT.
    if buf_Dis-card-mask.use-on = integer({&dcm-only-TH}) then NEXT.
    assign
    v-found = yes
    v-descr = "":U
    .
    /*кол-во D в cli-mask должно быть равно количеству символов в сравниваемом номере*/
    assign
    v-cli-mask =  buf_dis-card-mask.cli-mask
    v-is-correct = ((num-entries(v-cli-mask, 'D') - 1) = length(p-d-card))
    no-error
    .
    if v-is-correct then do:
      assign
      v-full-number = v-cli-mask
      .
      do ii = 1 to length(p-d-card):
        substring(v-full-number, index(v-full-number, 'D'), 1)  =  substring(p-d-card, ii, 1).
      end.
      if index(v-full-number, 'C') > 0 then do:
        /*есть контрольная цифра*/
        case buf_dis-card-mask.cc-run:
          when integer({&dcm-cc-algo-luhn}) then do:
            run gbl/pluhnalg.p ( input v-full-number, output p-full-number) no-error .
            if error-status:error then do:
              undo, return error substitute("Ошибка при определении КЦ полного номера карты &1 по маске &2:&3&4&3&5"
                                              , p-d-card
                                              , v-cli-mask
                                              , {&new-line}
                                              , error-status:get-message(1)
                                              , return-value ).
            end.
          end.
          otherwise do:
            undo, return error substitute("Ошибка при определении полного номера карты &1 по маске &2:&3" +
                                        "Не задан алгоритм расчета КЦ"
                                        , p-d-card
                                        , v-cli-mask
                                        , {&new-line}
                                        ).
          end.
        end case.
      end.
      else do:
        p-full-number = v-full-number.
      end.
      p-cli-mask = v-cli-mask.
      return .
    end.
  end. /*for each*/
  if not v-found then do:
    return substitute("Не удалось определить ПОЛНЫЙ номер ДК&5Для карты &1 (тип &2 эмитент &3) не определено ни одной действующей маски, для объекта выдачи карты маг&4"
                                  , p-d-card
                                  , p-type
                                  , p-emitent-host-code
                                  , p-issue-code
                                  , {&new-line}
                                  ).

  end.
  else do:
    return substitute("Не удалось определить ПОЛНЫЙ номер ДК&5Карта &1 (тип &2 эмитент &3) не соответствует ни одной действующей маске, для объекта выдачи карты маг&4"
                                  , p-d-card
                                  , p-type
                                  , p-emitent-host-code
                                  , p-issue-code
                                  , {&new-line}
                                  ).
  end.

end. /*doe*/