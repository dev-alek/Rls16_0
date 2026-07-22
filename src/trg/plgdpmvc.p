block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Связывание резервуара с топливом

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/24/08
Author: Dmitry Ukhanov
Creation date: 03/24/08

*/

define input  parameter pobj-type like ub.clients.obj-type     no-undo.
define input  parameter pobj-code like ub.clients.obj-code     no-undo.
define input  parameter ppl-code  like ub.place.pl-code        no-undo.
define input  parameter pgds-code like ub.goods.gds-code       no-undo.
define output parameter parresult as logical                   no-undo.

define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Связывание резервуара с топливом" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ str/nzpl-spl.i }
{ trg/cplgdspm.i }
define buffer other-pl-gds-pump       for ub.pl-gds-pump.
define buffer bf_pl-pump-nozzle       for ub.pl-pump-nozzle.
define buffer bf-other_pl-pump-nozzle for ub.pl-pump-nozzle.
define variable v-ok      as logical   no-undo .
define variable varstatus as character no-undo.
define variable v-is-petrol-place as logical no-undo .
find first ub.pl-gds no-lock where
           ub.pl-gds.obj-type = pobj-type and
           ub.pl-gds.obj-code = pobj-code and
           ub.pl-gds.pl-code  = ppl-code
           no-error.
 if available ub.pl-gds then do:
    return error
    ("объект " + pobj-type + string(pobj-code) + {&new-line} +
     "резервуар " + string(ppl-code) + " уже занят - товар " + string(ub.pl-gds.gds-code)).

 end.

find first ub.rvs-doc no-lock where
           ub.rvs-doc.obj-type = pobj-type and
           ub.rvs-doc.obj-code = pobj-code and
           ub.rvs-doc.rvs-type <> {&test-asi} and
           ub.rvs-doc.status_ <> {&fact}  no-error.
if available ub.rvs-doc then do:
  return error
    ("объект " + pobj-type + string(pobj-code) + {&new-line} +
     "сверка " + string(ub.rvs-doc.rvs-code) + " не закрыта").
end.

find first ub.icnt-doc no-lock where
           ub.icnt-doc.obj-type = pobj-type and
           ub.icnt-doc.obj-code = pobj-code and
           ub.icnt-doc.status_ <> {&fact} no-error.
if available ub.icnt-doc then do:
  if ub.icnt-doc.doc-type = {&icnt-doc} then do:
    return error
      ("объект " + pobj-type + string(pobj-code) + {&new-line} +
      "инвентаризация счетчиков ТРК " + string(ub.icnt-doc.doc-code) + " не закрыта").
  end.
  if ub.icnt-doc.doc-type = {&icnt-err} then do:
    return error
      ("объект " + pobj-type + string(pobj-code) + {&new-line} +
      "док-т измерения погрешности счетчиков ТРК " + string(ub.icnt-doc.doc-code) + " не закрыт").
  end.
end.

/*проверка корректности loc1 для топливных резервуаров*/
find first ub.place no-lock where
           ub.place.obj-type = pobj-type and
           ub.place.obj-code = pobj-code and
           ub.place.pl-code = ppl-code   no-error.
if not available ub.place then do:
  return error
  ("объект " + pobj-type + string(pobj-code) + {&new-line} +
   "резервуар " + string(ppl-code) + {&space-char} + "не найден").
end.
v-is-petrol-place = yes.
run trg/plloc1wv.p (
                     input pobj-type
                    ,input pobj-code
                    ,input ppl-code
                    ,input ub.place.loc1
                    ,input ub.place.is-meas
                    ,input-output v-is-petrol-place
                    ,output v-ok) no-error.
if error-status:error or
   v-ok <> yes        then do:
  return error return-value.
end.

_creation:
do on error undo _creation, return error return-value:
  assign
    varstatus = {&current-status}.
  /*Идем по всем привязаным ТРК*/
  for each  ub.pl-pump no-lock where
            ub.pl-pump.obj-type = pobj-type and
            ub.pl-pump.obj-code = pobj-code and
            ub.pl-pump.pl-code  = ppl-code  on error undo, return error return-value :
    /*Ищем пистолет через который мы торгуем на данной ТРК*/
    find first bf_pl-pump-nozzle where bf_pl-pump-nozzle.obj-type  = ub.pl-pump.obj-type  and
                                       bf_pl-pump-nozzle.obj-code  = ub.pl-pump.obj-code  and
                                       bf_pl-pump-nozzle.pl-code   = ub.pl-pump.pl-code   and
                                       bf_pl-pump-nozzle.pump-code = ub.pl-pump.pump-code no-lock no-error.
    /*Просматриваем резервуары которые торгуют с этой ТРК этим же топливом*/
    for each other-pl-gds-pump no-lock where
             other-pl-gds-pump.obj-type  = pobj-type            and
             other-pl-gds-pump.obj-code  = pobj-code            and
             other-pl-gds-pump.pump-code = ub.pl-pump.pump-code and
             other-pl-gds-pump.gds-code  = pgds-code            on error undo, return error return-value :
      if other-pl-gds-pump.pl-code <> ppl-code then do:
        find first bf-other_pl-pump-nozzle where bf-other_pl-pump-nozzle.obj-type  = other-pl-gds-pump.obj-type  and
                                                 bf-other_pl-pump-nozzle.obj-code  = other-pl-gds-pump.obj-code  and
                                                 bf-other_pl-pump-nozzle.pl-code   = other-pl-gds-pump.pl-code   and
                                                 bf-other_pl-pump-nozzle.pump-code = other-pl-gds-pump.pump-code no-lock no-error.
        /*Недопустимо торговать одним топливом из двух пистолетов*/
        if available bf_pl-pump-nozzle       and
           available bf-other_pl-pump-nozzle and
           bf_pl-pump-nozzle.nozzle-code <> bf-other_pl-pump-nozzle.nozzle-code then do:
              undo _creation, return error
               ("объект " + pobj-type + string(pobj-code) + {&new-line} +
                "ТРК " + string(ub.pl-pump.pump-code) + " наливает топливо c внутренним кодом " + string(pgds-code) +
                " из резервуара " + string(other-pl-gds-pump.pl-code) + " через пистолет " + string(bf-other_pl-pump-nozzle.nozzle-code) +
                " . А данный резервур " + string(ub.pl-pump.pl-code) + " наливает на этой ТРК через пистолет " + string (bf_pl-pump-nozzle.nozzle-code) + ".Это недопустимо.").
         end.
         else do:
              if other-pl-gds-pump.status_ = {&current-status} and nzpl-spl (input other-pl-gds-pump.obj-type, input other-pl-gds-pump.obj-code) then do:
                message "На ТРК "  string(ub.pl-pump.pump-code)  " наливает топливо с внутренним кодом "  string(pgds-code)
                        " из резервуара " string(other-pl-gds-pump.pl-code) "."
                        "Данная привязка получит статус блокированный."
                view-as alert-box.
                assign
                  varstatus = {&blocked-status}.
              end.
         end.
      end.
    end.
    create ub.pl-gds-pump.
    assign
      ub.pl-gds-pump.obj-type  = pobj-type
      ub.pl-gds-pump.obj-code  = pobj-code
      ub.pl-gds-pump.pl-code   = ppl-code
      ub.pl-gds-pump.gds-code  = pgds-code
      ub.pl-gds-pump.pump-code = ub.pl-pump.pump-code
      ub.pl-gds-pump.status_   = varstatus
      .
    run cplgdspm in this-procedure (input ub.pl-gds-pump.obj-type ,
                                    input ub.pl-gds-pump.obj-code ,
                                    input ub.pl-gds-pump.pl-code  ,
                                    input ub.pl-gds-pump.gds-code ,
                                    input ub.pl-gds-pump.pump-code,
                                    input ub.pl-gds-pump.status_     )
    no-error.
    if error-status:error then do:
      return error return-value.
    end.
  end.
  create ub.pl-gds.
  assign
    ub.pl-gds.obj-type = pobj-type
    ub.pl-gds.obj-code = pobj-code
    ub.pl-gds.pl-code  = ppl-code
    ub.pl-gds.gds-code = pgds-code
    ub.pl-gds.status_  = {&current-status}
  .
end. /*do on error*/
assign
 parresult = yes
.