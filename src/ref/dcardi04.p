block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dcardi04.p $
$Archive: ref/dcardi04.p $

Проверка возможности ввода ДК, по соответствующей маске и коду объекта выдачи

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/14/04
Author: Bakhtadze Natalya
Creation date: 12/14/04

*/

define input parameter p-d-card                 like ub.dis-card.d-card no-undo .
/*код проверяемой карты*/
define input parameter p-type                   like ub.dis-card.type no-undo .
define input parameter p-emitent-host-code      like ub.dis-card.emitent-host-code no-undo .
define input parameter p-issue-code             like ub.dis-card.issue-code no-undo .
/*объект выдачи*/
define output parameter p-can-issue              as logical no-undo .
/*пользователь может выпустить*/



define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dcardi04.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dcardi04.p $":U .
define variable vss-description as character no-undo init "Проверка возможности ввода ДК, по соответствующей маске и коду объекта выдачи".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4':u,p-d-card,p-type,p-emitent-host-code,p-issue-code)" }

{ cmp/trg-def.i }
{ ref/chdcmask.i }

define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-descr     as character no-undo .
define variable v-is-correct as logical no-undo .
define variable v-found      as logical no-undo .
define variable v-type       as character no-undo .


define buffer buf_dis-card-mask for ub.dis-card-mask.
define buffer buf_dis-card-type for ub.dis-card-type .

do
on error undo, return error substitute("&1 &2 &3:&4&5 &6"
                                        , vss-workfile
                                        , vss-revision
                                        , vss-description
                                        , {&new-line}
                                        , error-status:get-message(1)
                                        , return-value )

:
  if p-issue-code = ?
  or p-issue-code = 0 then do:
     undo, return error substitute( "Не опеределен код магазина, выдавшего карту").
  end.
  { gbl/hostcode.i {&shop} p-issue-code v-host-code }
  find first buf_dis-card-type share-lock where
            buf_dis-card-type.emitent-host-code = p-emitent-host-code
        and buf_dis-card-type.type = p-type
        and buf_dis-card-type.host-code = 0
        and buf_dis-card-type.obj-type = '':U
        and buf_dis-card-type.obj-code = 0 .
  if buf_dis-card-type.check-by-mask = 0 then do:
    assign
    p-can-issue = yes.
    return.
  end.
  _maska:
  for each buf_dis-card-mask no-lock where
          buf_dis-card-mask.emitent-host-code = p-emitent-host-code
      AND buf_dis-card-mask.type              = p-type
      AND buf_Dis-card-mask.stts              = integer({&current-status-int})
  by buf_Dis-card-mask.host-code
  by buf_Dis-card-mask.obj-type
  by buf_Dis-card-mask.obj-code
  by buf_Dis-card-mask.rank:
    if buf_dis-card-type.ho-join = 1
    and
    buf_dis-card-mask.host-code <> 0
    And buf_dis-card-mask.host-code <> v-host-code then next.
    if buf_dis-card-type.ho-join = 1
    and
    buf_dis-card-mask.obj-type <> "":U
    AND
       (buf_dis-card-mask.obj-type <> {&shop}
    or buf_dis-card-mask.obj-code <> p-issue-code) then NEXT.
    if buf_dis-card-mask.use-on = integer({&dcm-only-cd}) then NEXT.
    assign
    v-found = yes
    v-descr = "":U
    .
    assign
    v-is-correct = check-by-mask (buf_dis-card-mask.mask,  p-d-card, output v-descr)
    no-error
    .
    if error-status:error then undo, return error v-descr.
    if v-is-correct then do:
      assign
      p-can-issue = yes.
      return .
    end.
  end. /*for each*/
  if not v-found then do:
    return substitute("Для карты &1 (тип &2 эмитент &3) не определено ни одной действующей маски, для объекта выдачи карты маг&4"
                                  , p-d-card
                                  , p-type
                                  , p-emitent-host-code
                                  , p-issue-code).

  end.
  else do:
    return substitute("Карта &1 (тип &2 эмитент &3) не соответствует ни одной действующей маски, для объекта выдачи карты маг&4"
                                  , p-d-card
                                  , p-type
                                  , p-emitent-host-code
                                  , p-issue-code).
  end.

end. /*doe*/