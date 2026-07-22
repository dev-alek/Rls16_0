block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: bc-on.p $
$Archive: utl/bc-on.p $

Включение всех выключенных неповторных дополнительных бар-кодов. Включение первого из повторных доп. БК, если все они выключены.

Автор: Суслов Алексей Юрьевич
Дата создания: 09/19/05
Author: Alexey Suslov
Creation date: 09/19/05

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bc-on.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/bc-on.p $":U .
define variable vss-description as character no-undo init "Включение всех выключенных неповторных дополнительных бар-кодов".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

define buffer buf_prod-bc for ub.prod-bc .
define buffer turn-on_prod-bc for ub.prod-bc .
define buffer buf_bar-code for ub.bar-code .
define buffer buf_goods for ub.goods .
define buffer buf_units for ub.units .


define variable v-all-bc as integer no-undo .
define variable v-on-bc  as integer no-undo .
define variable v-today  as date    no-undo.
define variable v-time   as integer no-undo.
define variable l-prod-bc-pgweight as logical no-undo .

define stream slog .

do
on error undo, return error
:
  def frame a
    v-all-bc label "Всего просмотрено бар-кодов" skip
    v-on-bc label "Включено" skip
    with view-as dialog-box side-labels three-d
    title "Включение бар-кодов"
    .
  view frame a.

  /* TODO ??? Непонятно зачем здесь наложено такое ограничение? */
  /* Почему нельзя запускать утилиту в УБД? */
  if g#db-num <> 0 then do:
    message
      "Утилиту включения доп.БД можно запускать только в ГБД." skip
      view-as alert-box error .
    return.
  end.

  define variable lok as logical   no-undo .
  assign
    lok = false
  .
  message
    "Включение всех выключенных доп. БК. (кроме весовых)" skip
    "При наличии нескольких повторных доп. БК включается первый бар-код." skip
    "Продолжить?" skip
    view-as alert-box question buttons OK-Cancel update lok .
  if lok = false then do:
    return .
  end.

  for each ub.prod-bc no-lock
    where ub.prod-bc.bc-on = false
  on error undo, return error
  :
    assign
      v-all-bc = v-all-bc + 1
    .
    display
      v-all-bc
      v-on-bc
      with frame a.

    /* ищем точно такой-же включенный повторный бар-код */
    find first buf_prod-bc no-lock
      where buf_prod-bc.b-str = prod-bc.b-str
        and buf_prod-bc.bc-on = true
        and recid (buf_prod-bc) <> recid (prod-bc)
      no-error .
    if available buf_prod-bc then do:
      /* уже есть такой включенный бар-код */
      next . /* --->>>--- */
    end.
    /*проверим что мы работаем не с весовым!!!*/
    /*не нужно их скопом включать!*/
    find first buf_bar-code no-lock where
                buf_bar-code.b-code = ub.prod-bc.b-code.
    find first buf_goods No-lock where
                buf_goods.gds-code =buf_bar-code.b-code .
    find first buf_units No-lock where
                buf_units.unit-name = buf_goods.unit-base.
    if lookup({&weight}, buf_units.type) > 0  then do:
      next.
    end.
    if lookup({&pieces}, buf_units.type) > 0  then do:
      l-prod-bc-pgweight = yes.
      { gbl/prodbcat.i
        buf_prod-bc
        "'pgweight=request':u"
        l-prod-bc-pgweight
        no-error
      }
      if l-prod-bc-pgweight then do:
        next.
      end.
    end.




    if prod-bc.bc-on = false then do:
      do transaction
      on error undo, return error
      :
        find first turn-on_prod-bc exclusive-lock
          where recid(turn-on_prod-bc) = recid(ub.prod-bc)
          .
        assign
          v-on-bc = v-on-bc + 1
        .
        assign
          turn-on_prod-bc.bc-on = true
        .
        output stream slog to bc-on.txt append .
        run cur-time in this-procedure ( output v-today
                                       , output v-time
                                       ).
        export stream slog
          string(v-today, '99/99/9999':u)
          string(v-time, 'HH:MM:SS':u)
          "включен доп. бар-код" turn-on_prod-bc.b-str
        .
        output stream slog close .
      end.
    end.
  end.

  message
    "Включение доп. БК закончено." skip
    "Всего включено дополнительных бар-кодов" v-on-bc skip
    "Список бар-кодов можно посмотреть в файле" 'bc-on.txt':u skip
    view-as alert-box information .
end.