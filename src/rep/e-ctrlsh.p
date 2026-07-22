block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: e-ctrlsh.p $
$Archive: rep/e-ctrlsh.p $

Запускалка отчета r-ctrlsh.p

Автор: Уханов Дмитрий Юрьевич
Дата создания: 11/12/10
Author: Dmitry Ukhanov
Creation date: 11/12/10

*/
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: e-ctrlsh.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/e-ctrlsh.p $":U .
define variable vss-description as character no-undo initial "Запускалка отчета r-inptl.p":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ cmp/r-page1.i  }

define variable is-petrol   as logical   no-undo.
define variable is-pieces   as logical   no-undo.

define variable store-name as character no-undo.
define variable v-count as integer initial 0  no-undo .

define buffer bf-gds-list for gds-list.
define buffer buf_clients for ub.clients.

&scop display-message run write-to-log in this-procedure ( input ~{&my-message~}).

if not can-find( first obj-list ) then do:
  message "Вы не выбрали объект." view-as alert-box error.
  return.
end.

find first obj-list.

if not can-find( first gds-list ) then do:
  message "Вы не выбрали товар." view-as alert-box error.
  return.
end.


find first gds-list.

for each bf-gds-list :
  find first ub.goods no-lock where
              ub.goods.artic     = bf-gds-list.artic     and
              ub.goods.prod-type = bf-gds-list.prod-type and
              ub.goods.prod-code = bf-gds-list.prod-code no-error.
  if not available ub.goods then do: next. end.
  { str/is-petrl.i
      ub.goods.artic
      ub.goods.prod-type
      ub.goods.prod-code
      is-petrol
      is-pieces
      no-error
  }
  if error-status :error
    or is-petrol <> yes
    or is-pieces <> no
  then do:
    message
      substitute("Отчет может быть запущен только для топливного товара") skip
      view-as alert-box error .
    return .
  end.
end. /* for each bf-gds-list */

define temp-table temp-shift-obj no-undo like ub.shift-obj
  FIELD num as integer
  INDEX ii IS UNIQUE num
.

for each obj-list no-lock
:
  for each ub.shift-obj  no-lock
    where ub.shift-obj.obj-code   =  obj-list.obj-code
      and ub.shift-obj.obj-type   =  obj-list.obj-type
      and ub.shift-obj.shift-date >= X-date-Start
      and ub.shift-obj.shift-date <= X-date-End
  :
    if x-TOG-Shift = true
      and ( ( ub.shift-obj.shift-date = X-date-Start
              and ub.shift-obj.shift-num < X-Shift-Start
            )
            or ( ub.shift-obj.shift-date = X-date-End
                 and ub.shift-obj.shift-num > X-Shift-End
               )
          )
    then do:
      next .
    end.

    if ub.shift-obj.status_ <> {&sht-closed} then do:
      &scop my-message  substitute("На объекте &1 смена &2 с датой начала &3&4"  + ~
                                  "еще не закрыта!&4Отчет сделать нельзя!"  ~
                                , obj-list.obj-name ~
                                ,ub.shift-obj.shift-num ~
                                ,string(ub.shift-obj.shift-date,"99/99/9999") ~
                                , ~{&new-line~})
      {&display-message}
      return.
    end.
    create temp-shift-obj .
    assign v-count = v-count + 1 .
    assign temp-shift-obj.num = v-count .
    buffer-copy ub.shift-obj to temp-shift-obj .

  end.
end.

/* корректируем первую смену  */
find first temp-shift-obj where temp-shift-obj.num = 1 no-error .
if not available temp-shift-obj Then DO:
  &scop my-message substitute("Нет смены &1 с датой начала &2&3" + ~
                              "Исправьте запрашиваемые данные!" ~
                              , X-shift-start ~
                              ,string(X-date-start,"99/99/9999") ~
                              , ~{&new-line~} )
  {&display-message}
  return.
End.
assign
  x-date-Start  = temp-shift-obj.shift-date
  X-Shift-Start = temp-shift-obj.shift-num
.
/* корректируем последнюю смену  */
find first temp-shift-obj  where temp-shift-obj.num = v-count no-error .
if available temp-shift-obj then do:
  assign
    x-date-End   = temp-shift-obj.shift-date
    X-Shift-End  = temp-shift-obj.shift-num
  .
end.



run rep/r-ctrlsh.p
  ( input my-handle
  , input this-procedure :handle
  ).

PROCEDURE write-to-log :
define input param p-str as char no-undo.

do
on error undo, return error
:
   message
      p-str
      skip
   view-as alert-box error.

end. /* do on error */
END PROCEDURE.