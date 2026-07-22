block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: factdate.p $
$Archive: gbl/factdate.p $

Инициализация факт даты, времени, номера смены и даты начала смены

Автор: Перваков Михаил Сергеевич
Дата создания: 04/11/06
Author: Mikhail Pervakov
Creation date: 04/11/06

*/

define input        parameter o-type    as character no-undo . /* тип объекта */
define input        parameter o-code    as integer   no-undo . /* код объекта */
define input-output parameter f-date    as date      no-undo . /* факт дата для документа */
define input-output parameter f-time    as integer   no-undo . /* факт время для документа */
define input-output parameter s-date    as date      no-undo . /* дата начала смены для документа */
define input-output parameter s-num     as integer   no-undo . /* порядок смены для документа */
define input-output parameter s-name    as character no-undo . /* номер смены для документа */
define input        parameter is-berate as logical   no-undo . /* выводить сообщения об ошибках */

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: factdate.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: gbl/factdate.p $":U .
define variable vss-description as character no-undo initial "Инициализация факт даты, времени, номера смены и даты начала смены":U .

{ cmp/vssrevis.i "substitute('&1|&2':u,o-type,o-code)" }
{ cmp/trg-def.i }
{ cmp/library.i  }
{ gbl/cur-time.i }

define variable p-shift-date as date      no-undo initial ? .
define variable p-shift-num  as integer   no-undo initial 0 .
define variable p-shift-name as character no-undo initial ? .
define variable v-today      as date      no-undo .

define buffer bf_shift-obj for ub.shift-obj.

do
on error undo, return error
:

  define variable l-shift-on as logical no-undo .

  { gbl/objat.i
    o-type
    o-code
    "'shift-on=request'"
    l-shift-on
  }
  if l-shift-on = true then do:
    /* на объекте включены смены */
    { gbl/curshift.i
      o-type
      o-code
      p-shift-date
      p-shift-num
      p-shift-name
      no-error
    }
    if error-status :error then do:
      if is-berate = true then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при поиске текущей смены на объекте" skip
          error-status :get-message(1) skip
          return-value skip
        view-as alert-box error .
      end.
      undo, return error substitute( "Ошибка при поиске текущей смены на объекте.&1&2&1&3",
                                     {&new-line},
                                     error-status :get-message( 1 ),
                                     return-value ) .
    end.
  end.
  { gbl/curobjdt.i o-type o-code f-date }
  run cur-time in this-procedure ( output v-today
                                 , output f-time
                                 ).
  assign
    s-date = p-shift-date
    s-num  = p-shift-num
    s-name = p-shift-name
  .

  run gbl/chk-date.p
    ( input o-type
    , input o-code
    , input f-date
    , input f-time
    , input s-date
    , input s-num
    , input is-berate
    ) no-error .
  if error-status :error then do:
    if is-berate = true then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при проверке корректности дат" skip
        error-status :get-message(1) skip
        return-value skip
      view-as alert-box error .
    end.
    return error substitute( "Ошибка при проверке корректности дат.&1&2&1&3",
                             {&new-line},
                             error-status :get-message( 1 ),
                             return-value ) .
  end.

  if v-today - f-date > 27 and not g#news THEN DO:
    if is-berate = true then do:
      define variable lok as logical no-undo .

      message
        "Фактическая дата на объекте: " f-date skip
        "отличается от сегодняшней: " today skip
        "более чем на 27 дней." skip
        "Продолжить?" skip
      view-as alert-box question buttons yes-no update lok .
      if lok <> true then do:
        return error.
      end.
    end.
  end.
end.