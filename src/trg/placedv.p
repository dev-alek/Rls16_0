block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверки возможности удаления резервуара

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/24/08
Author: Dmitry Ukhanov
Creation date: 03/24/08

*/

define input  parameter pobj-type like ub.clients.obj-type     no-undo.
define input  parameter pobj-code like ub.clients.obj-code     no-undo.
define input  parameter ppl-code  like ub.place.pl-code        no-undo.
define output parameter loc#log   as logical                   no-undo.

define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Проверки возможности удаления резервуара" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

/*текущая смена*/
define variable v-shift-date as date      no-undo.
define variable v-shift-num  as integer   no-undo.
define variable v-shift-name as character no-undo.

/*ищем текущую открытую смену*/
{ gbl/curshift.i pobj-type pobj-code v-shift-date v-shift-num v-shift-name no-error}

  /*находим последнюю закрытую смену по объекту*/
  find last ub.shift-obj no-lock where
            ub.shift-obj.obj-type = pobj-type and
            ub.shift-obj.obj-code = pobj-code and
            ub.shift-obj.status_ = {&fact} use-index stts no-error.
  if avail ub.shift-obj then do:
    /*проверим что в сверке за эту смену связка топливо-резервуар не фигурировала ,
    либо книжные и факт остатки равны нулю*/
    find first ub.rvs-doc no-lock where
              ub.rvs-doc.obj-type = ub.shift-obj.obj-type and
              ub.rvs-doc.obj-code = ub.shift-obj.obj-code and
              ub.rvs-doc.shift-date = ub.shift-obj.shift-date and
              ub.rvs-doc.shift-num = ub.shift-obj.shift-num and
              ub.rvs-doc.status_ = {&fact} and
              ub.rvs-doc.rvs-type = {&rvs-shift} no-error.
    if avail ub.rvs-doc then do:
      for each ub.rvs-line no-lock where
              ub.rvs-line.rvs-code = ub.rvs-doc.rvs-code and
              ub.rvs-line.pl-code = ppl-code:
        if ub.rvs-line.system-qnty <> 0 then do:
          return error
        ("объект " + pobj-type + string(pobj-code) + {&new-line} +
        "резервуар " + string(ppl-code) + {&new-line} +
        "топливо " + string(ub.rvs-line.gds-code) + {&new-line} +
        "имеются ненулевые книжные остатки по сверке последней закрытой смены")
        .
        end.
        if ub.rvs-line.state-measure-qnty <> 0 then do:
          return error
        ("объект " + pobj-type + string(pobj-code) + {&new-line} +
        "резервуар " + string(ppl-code) + {&new-line} +
        "топливо " + string(ub.rvs-line.gds-code) + {&new-line} +
        "имеются ненулевые подтвержденные фактические остатки по сверке последней закрытой смены")
        .
        end.
      end.
    end.
    else return error.
  end. /*if avail ub.shift-obj*/

find first ub.doc-pl no-lock where
           ub.doc-pl.obj-type = pobj-type and
           ub.doc-pl.obj-code = pobj-code and
           ub.doc-pl.pl-code  = ppl-code  no-error .
if available ub.doc-pl
then do:
  return error substitute( 'объект &1 &2&3резервуар &4&3документ "&5"&3топливо &6 привязано к резервуару.'
                         , ub.doc-pl.obj-type
                         , ub.doc-pl.obj-code
                         , {&new-line}
                         , ub.doc-pl.pl-code
                         , ub.doc-pl.out-code
                         , ub.doc-pl.gds-code
                         ) .
end. /* if available ub.doc-pl */

find first ub.pl-gds no-lock where ub.pl-gds.obj-type = pobj-type and
           ub.pl-gds.obj-code = pobj-code and
           ub.pl-gds.pl-code  = ppl-code  no-error .
           if available (ub.pl-gds) then do:
             return error .
           end.  

_deletion:
do on error undo _deletion, return error return-value:

  /*удаляем записи резервуар ТРК-пистолет*/
  for each ub.pl-pump-nozzle where
          ub.pl-pump-nozzle.obj-type = pobj-type and
          ub.pl-pump-nozzle.obj-code = pobj-code and
          ub.pl-pump-nozzle.pl-code  = ppl-code on error undo, return error return-value :
    /*удалить связку резервуар-трк-топливо*/
    delete ub.pl-pump-nozzle no-error.
    if error-status:error then do:
      undo _deletion, return error ("Не удалось удалить запись pl-pump-nozzle " + {&new-line} +
                                    "объект " + pobj-type + string(pobj-code) + {&new-line} +
                                    "резервуар " + string(ppl-code) + {&new-line} +
                                    "ТРК " + string(ub.pl-pump-nozzle.pump-code) +
                                    "пистолет " + string(ub.pl-pump-nozzle.nozzle-code)).
    end.
  end. /*for each ub.pl-pump-nozzle*/

  /*для всех связок резервуар-трк-топливо*/
  for each ub.pl-gds-pump where
           ub.pl-gds-pump.obj-type = pobj-type and
           ub.pl-gds-pump.obj-code = pobj-code and
           ub.pl-gds-pump.pl-code  = ppl-code on error undo, return error return-value :

    /*удалить связку резервуар-трк-топливо*/
    delete ub.pl-gds-pump no-error.
    if error-status:error then do:
      undo _deletion, return error ("Не удалось удалить запись pl-gds-pump " + {&new-line} +
                                    "объект " + pobj-type + string(pobj-code) + {&new-line} +
                                    "резервуар " + string(ppl-code) + {&new-line} +
                                    "топливо " + string(ub.pl-gds-pump.gds-code) + {&new-line} +
                                    "ТРК " + string(ub.pl-gds-pump.pump-code)).
    end.
  end. /*for each ub.pl-gds-pump*/

  /*для всех связок резервуар-трк*/
  for each ub.pl-pump where
          ub.pl-pump.obj-type = pobj-type and
          ub.pl-pump.obj-code = pobj-code and
          ub.pl-pump.pl-code  = ppl-code  on error undo, return error return-value :

    /*удалить связку резервуар-трк-топливо*/
    delete ub.pl-pump no-error.
    if error-status:error then do:
      undo _deletion, return ("Не удалось удалить запись pl-pump " + {&new-line} +
                              "объект " + pobj-type + string(pobj-code) + {&new-line} +
                              "резервуар " + string(ppl-code) + {&new-line} +
                              "ТРК " + string(ub.pl-pump.pump-code)).
    end.
  end. /*for each ub.pl-gds-pump*/


end. /*_deletion*/

assign
loc#log = yes.