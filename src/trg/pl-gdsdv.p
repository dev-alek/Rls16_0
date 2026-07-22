block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверки возможности удаления связи топливо-резервуар

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/24/08
Author: Dmitry Ukhanov
Creation date: 03/24/08

*/

DEFINE INPUT  PARAMETER pobj-type like ub.clients.obj-type     no-undo.
DEFINE INPUT  PARAMETER pobj-code like ub.clients.obj-code     no-undo.
DEFINE INPUT  PARAMETER ppl-code  like ub.place.pl-code        no-undo.
DEFINE INPUT  PARAMETER pgds-code like ub.goods.gds-code       no-undo.
DEFINE OUTPUT PARAMETER loc#log   as logical                   no-undo.

define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Проверки возможности удаления связи топливо-резервуар" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

/*текущая смена*/
define variable v-shift-date as date      no-undo.
define variable v-shift-num  as integer   no-undo.
define variable v-shift-name as character no-undo.

/*ищем текущую открытую смену*/
{ gbl/curshift.i pobj-type pobj-code v-shift-date v-shift-num v-shift-name no-error}
if NOT error-status:error and v-shift-num > 0 then do:
/*есть открытая смена на объекте*/
  FIND FIRST ub.rvs-doc NO-LOCK WHERE
             ub.rvs-doc.obj-type = pobj-type AND
             ub.rvs-doc.obj-code = pobj-code AND
             ub.rvs-doc.shift-date = v-shift-date AND
             ub.rvs-doc.shift-num = v-shift-num AND
             ub.rvs-doc.status_ = {&fact} AND
             ub.rvs-doc.rvs-type = {&rvs-shift} NO-ERROR.
  IF AVAIL ub.rvs-doc then do:
    FOR EACH ub.rvs-line NO-LOCK WHERE
             ub.rvs-line.rvs-code = ub.rvs-doc.rvs-code AND
             ub.rvs-line.gds-code = pgds-code AND
             ub.rvs-line.pl-code  = ppl-code:
      IF ub.rvs-line.system-qnty <> 0 then do:
        return
       ("объект " + pobj-type + string(pobj-code) + {&new-line} +
       "резервуар " + string(ppl-code) + {&new-line} +
       "топливо " + string(pgds-code) + {&new-line} +
       "имеются ненулевые книжные остатки по сверке текущей смены")
       .
      END.
      IF ub.rvs-line.state-measure-qnty <> 0 then do:
        return
       ("объект " + pobj-type + string(pobj-code) + {&new-line} +
       "резервуар " + string(ppl-code) + {&new-line} +
       "топливо " + string(pgds-code) + {&new-line} +
       "имеются ненулевые подтвержденные фактические остатки по сверке текущей смены")
       .
      END.
    END. /*FOR EACH ub.rvs-line WHER*/
  END. /*IF AVAIL ub.rvs-doc*/
  else do:
    return
    ("объект " + pobj-type + string(pobj-code) + {&new-line} +
     "не было сверки по текущей смене типа " + {&rvs-shift})
     .
  end.
end. /*смена открыта*/
else do:
  /*пересменок*/

  /*находим последнюю закрытую смену по объекту*/
  FIND last ub.shift-obj No-LOCK WHERE
            ub.shift-obj.obj-type = pobj-type AND
            ub.shift-obj.obj-code = pobj-code AND
            ub.shift-obj.status_ = {&fact} use-index stts No-ERROR.
  IF AVAIL ub.shift-obj then do:
    /*проверим что в сверке за эту смену связка топливо-резервуар не фигурировала ,
    либо книжные и факт остатки равны нулю*/
    FIND FIRST ub.rvs-doc NO-LOCK WHERE
              ub.rvs-doc.obj-type = ub.shift-obj.obj-type AND
              ub.rvs-doc.obj-code = ub.shift-obj.obj-code AND
              ub.rvs-doc.shift-date = ub.shift-obj.shift-date AND
              ub.rvs-doc.shift-num = ub.shift-obj.shift-num AND
              ub.rvs-doc.status_ = {&fact} AND
              ub.rvs-doc.rvs-type = {&rvs-shift} NO-ERROR.
    IF AVAIL ub.rvs-doc then do:
      FOR EACH ub.rvs-line NO-LOCK WHERE
              ub.rvs-line.rvs-code = ub.rvs-doc.rvs-code AND
              ub.rvs-line.gds-code = pgds-code AND
              ub.rvs-line.pl-code  = ppl-code:
        IF ub.rvs-line.system-qnty <> 0 then do:
          return
        ("объект " + pobj-type + string(pobj-code) + {&new-line} +
        "резервуар " + string(ppl-code) + {&new-line} +
        "топливо " + string(pgds-code) + {&new-line} +
        "имеются ненулевые книжные остатки по сверке последней закрытой смены")
        .
        END.
        IF ub.rvs-line.state-measure-qnty <> 0 then do:
          return
        ("объект " + pobj-type + string(pobj-code) + {&new-line} +
        "резервуар " + string(ppl-code) + {&new-line} +
        "топливо " + string(pgds-code) + {&new-line} +
        "имеются ненулевые подтвержденные фактические остатки по сверке последней закрытой смены")
        .
        END.
      END.
    END.
    else return error.
  END. /*IF AVAIL ub.shift-obj*/
END. /*пересменок*/

_deletion:
DO
ON ERROR undo _deletion, return error
:
/*для всех связок резервуар-трк-топливо*/
FOR EACH ub.pl-gds-pump where
        ub.pl-gds-pump.obj-type = pobj-type AND
        ub.pl-gds-pump.obj-code = pobj-code AND
        ub.pl-gds-pump.pl-code = ppl-code AND
        ub.pl-gds-pump.gds-code = pgds-code:
  /* удалить связку резервуар-трк-топливо*/
  DELETE UB.PL-GDS-PUMP NO-ERROR.
  if error-status:error then do:
    undo _deletion, return  ("Не удалось удалить запись pl-gds-pump " + {&new-line} +
                            "объект " + pobj-type + string(pobj-code) + {&new-line} +
                            "резервуар " + string(ppl-code) + {&new-line} +
                            "топливо " + string(pgds-code) + {&new-line} +
                            "ТРК " + string(ub.pl-gds-pump.pump-code)).
  end.
END.
END.
loc#log = yes.