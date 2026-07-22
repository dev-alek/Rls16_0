block-level on error undo, throw.
/*

$Revision: f4fc214ea39a, 40, test $
$Author: EShklyar $
$Date: 2014/05/23 10:49:54 $
$Workfile: chk-date.p $
$Archive: gbl/chk-date.p $

Проверка правильного заведения даты в документе

Автор: Чернова Светлана Александровна
Дата создания: 03/24/08
Author: Svetlana Chernova
Creation date: 03/24/08

Автор1: Суслов Алексей Юрьевич
Дата создания: 03/24/06


*/

define input parameter o-type    as character no-undo . /* тип объекта                          */
define input parameter o-code    as integer   no-undo . /* код объекта                          */
define input parameter f-date    as date      no-undo . /* фактическая дата закрытия документа  */
define input parameter f-time    as integer   no-undo . /* фактическое время закрытия документа */
define input parameter s-date    as date      no-undo . /* дата начала смены для документа      */
define input parameter s-num     as integer   no-undo . /* номер смены для документа            */
define input parameter is-berate as logical   no-undo . /* выводить сообщения об ошибках        */

define variable vss-revision    as character no-undo initial "$Revision: f4fc214ea39a, 40, test $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: 2014/05/23 10:49:54 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: chk-date.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: gbl/chk-date.p $":U .
define variable vss-description as character no-undo initial "Проверка правильного заведения даты в документе":U .

{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6',o-type,o-code,f-date,f-time,s-date,s-num)" }
{ cmp/str-glbl.i }
{ cmp/library.i  }

define variable diffshftvalue     as character no-undo initial ? .
define variable diffshfttype      as character no-undo initial ? .
define variable vardiffshft       as integer   no-undo initial ? .

define buffer bf_shop  for ub.shop.
define buffer bf_store for ub.store.

define variable h-code  like ub.shop.host-code.
define variable v-today as   date      no-undo.

if f-date = ? then do:
  if is-berate = yes then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не указана фактическая дата закрытия"
      view-as alert-box error.
  end.
  undo, return error "Не указана фактическая дата закрытия" .
end.

{ gbl/curobjdt.i o-type o-code v-today }
if f-date > v-today then do:
  if is-berate then do:
    message
      vss-workfile vss-revision vss-description skip
      "Фактическая дата закрытия: " f-date skip
      "больше сегодняшней: " v-today skip
      view-as alert-box error .
  end.
  undo, return error substitute( "Фактическая дата закрытия &1 больше сегодняшней &2", f-date, v-today ) .
end.

if f-time = ?
or f-time = 0 then do:
   if is-berate = yes then do:
     message
       vss-workfile vss-revision vss-description skip
       "Не указано фактическое время закрытия"
       "Фактическая дата закрытия" f-date skip
       view-as alert-box error.
   end.
   undo, return error substitute( "Не указано фактическое время закрытия. Фактическая дата закрытия &1.", f-date ) .
end.

define variable l-shift-on as logical no-undo .

{ gbl/objat.i
  o-type
  o-code
  "'shift-on=request'"
  l-shift-on
}
if l-shift-on = yes then do:
  if s-date = ? then do:
    if is-berate = yes then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не указана дата начала смены." s-date skip
        view-as alert-box error.
    end.
    undo, return error substitute( "Не указана дата начала смены &1.", s-date ) .
  end.
if o-type = {&stock} then do:
   find bf_store where bf_store.obj-code = o-code no-lock.
   assign h-code = bf_store.host-code.
end.
else do:
  find bf_shop where bf_shop.obj-code = o-code no-lock.
  assign h-code = bf_shop.host-code.
end.
   define variable v-value-character as character  no-undo .
   define variable v-value-date      as date       no-undo .
   define variable v-value-decimal   as decimal    no-undo .
   define variable v-value-integer   as integer    no-undo .
   define variable v-value-logical   as logical    no-undo .
   define variable v-tth             as handle     no-undo .
   define variable v-param-type            as character no-undo .

   run adm/shattri.p ( input "get":U
                     , input  o-type
                     , input  o-code
                     , input  {&attr-obj-date}
                     , input  {&attr-obj-date_diffshft}
                     , output v-value-character
                     , output v-value-date
                     , output v-value-decimal
                     , output v-value-integer
                     , output v-value-logical
                     , output v-param-type
                     , input-output table-handle v-tth
                     ) no-error .
   if error-status :error
   then do:
      /* параметр может быть не задан */
      assign
         vardiffshft = 3
      .
   end.
   else do:
      assign
         vardiffshft = v-value-integer
      no-error
      .
    if error-status:error
    or vardiffshft < 0
    then do:
      if is-berate = yes then do:
        message "Неверно задан параметр diffshft: " diffshftvalue skip
                "Параметр может принимать целые значения > 0." skip
        view-as alert-box error.
      end.
      undo, return error substitute( "Неверно задан параметр diffshft: &1.&2" +
                                     "Параметр может принимать целые значения > 0.",
                                     diffshftvalue,
                                     {&new-line} ) .
    end.
  end.
  delete object v-tth.

  if s-date > f-date
  or s-date < f-date - vardiffshft then do:
    if is-berate = yes then do:
      message
        vss-workfile vss-revision vss-description skip
        "Дата смены не соответствует фактической дате закрытия." skip
        "Фактическая дата закрытия" f-date skip
        "Дата смены" s-date skip
        "Допустима сменная дата от " f-date - vardiffshft " до " f-date
        view-as alert-box error.
    end.
    undo, return error substitute( "Дата смены не соответствует фактической дате закрытия.&4" +
                                   "Фактическая дата закрытия &1.&4" +
                                   "Дата смены &2.&4" +
                                   "Допустима сменная дата от &3 до &1.",
                                   f-date,
                                   s-date,
                                   f-date - vardiffshft,
                                   {&new-line} ) .
  end.
  if s-num = ?
  or s-num = 0 then do:
    if is-berate = yes then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не указан порядок смены." skip
        "Фактическая дата закрытия" f-date skip
        "Дата смены" s-date skip
        view-as alert-box error.
    end.
    undo, return error substitute( "Не указан порядок смены.&3" +
                                   "Фактическая дата закрытия &1.&3" +
                                   "Дата смены &2.",
                                   f-date,
                                   s-date,
                                   {&new-line} ) .
  end.
end.