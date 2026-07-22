block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверки возможности удаления ТРК

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/24/08
Author: Dmitry Ukhanov
Creation date: 03/24/08

*/

DEFINE INPUT  PARAMETER pobj-type like ub.clients.obj-type     no-undo.
DEFINE INPUT  PARAMETER pobj-code like ub.clients.obj-code     no-undo.
DEFINE INPUT  PARAMETER ppump-code like ub.pump.pump-code        no-undo.
DEFINE OUTPUT PARAMETER loc#log   as logical                   no-undo.

define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Проверки возможности удаления ТРК" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

/*текущая смена*/
define variable v-shift-date as date      no-undo.
define variable v-shift-num  as integer   no-undo.
define variable v-shift-name as character no-undo.
/*ищем текущую открытую смену*/
{ gbl/curshift.i pobj-type pobj-code v-shift-date v-shift-num v-shift-name no-error}
if not error-status:error and v-shift-num > 0 then  do:
/*есть открытая смена на объекте*/
  find first ub.rvs-doc no-lock where
             ub.rvs-doc.obj-type = pobj-type and
             ub.rvs-doc.obj-code = pobj-code and
             ub.rvs-doc.shift-date = v-shift-date and
             ub.rvs-doc.shift-num = v-shift-num and
             ub.rvs-doc.status_ = {&fact} and
             ub.rvs-doc.rvs-type = {&rvs-shift} no-error.
  if not avail ub.rvs-doc then do: /*нет сверки за текущую смену*/
    return error
    ("объект " + pobj-type + string(pobj-code) + {&new-line} +
     "не было сверки по текущей смене типа " + {&rvs-shift})
     .
  end.

end. /*есть открытая смена на объекте*/
/*пересменок или есть сверка за текущую смену*/

_deletion:
do on error undo _deletion, return error return-value :

  /*удаляем записи резервуар ТРК-пистолет*/
  for each ub.pl-pump-nozzle where
          ub.pl-pump-nozzle.obj-type = pobj-type and
          ub.pl-pump-nozzle.obj-code = pobj-code and
          ub.pl-pump-nozzle.pump-code = ppump-code:

    /*удалить связку резервуар-трк-топливо*/
    delete ub.pl-pump-nozzle no-error.
      if error-status:error then do:
        undo _deletion, return error ("Не удалось удалить запись pl-pump-nozzle " + {&new-line} +
                                      "объект " + pobj-type + string(pobj-code) + {&new-line} +
                                      "резервуар " + string(ub.pl-pump-nozzle.pl-code) + {&new-line} +
                                      "ТРК " + string(ppump-code) +
                                      "пистолет " + string(ub.pl-pump-nozzle.nozzle-code)).
      end.
  end. /*for each ub.pl-pump-nozzle*/

  /*для всех связок резервуар-трк-топливо*/
  for each ub.pl-gds-pump where
          ub.pl-gds-pump.obj-type  = pobj-type  and
          ub.pl-gds-pump.obj-code  = pobj-code  and
          ub.pl-gds-pump.pump-code = ppump-code on error undo, return error return-value :

    /*удалить связку резервуар-трк-топливо*/
    delete ub.pl-gds-pump no-error.
      if error-status:error then do:
        undo _deletion, return error ("Не удалось удалить запись pl-gds-pump " + {&new-line} +
                                      "объект " + pobj-type + string(pobj-code) + {&new-line} +
                                      "резервуар " + string(ub.pl-gds-pump.pl-code) + {&new-line} +
                                      "топливо " + string(ub.pl-gds-pump.gds-code) + {&new-line} +
                                      "ТРК " + string(ppump-code)).
      end.
  end. /*for each ub.pl-gds-pump*/

  /*для всех связок резервуар-трк*/
  for each ub.pl-pump where
          ub.pl-pump.obj-type  = pobj-type  and
          ub.pl-pump.obj-code  = pobj-code  and
          ub.pl-pump.pump-code = ppump-code on error undo, return error return-value :

    /*удалить связку резервуар-трк-топливо*/
    delete ub.pl-pump no-error.
      if error-status:error then do:
        undo _deletion, return error ("Не удалось удалить запись pl-pump " + {&new-line} +
                                      "объект " + pobj-type + string(pobj-code) + {&new-line} +
                                      "резервуар " + string(ub.pl-pump.pl-code) + {&new-line} +
                                      "ТРК " + string(ppump-code)).
      end.
  end. /*for each ub.pl-gds-pump*/


  /*для всех связок  ТРК пистолет*/
  for each ub.pump-nozzle where
           ub.pump-nozzle.obj-type  = pobj-type and
           ub.pump-nozzle.obj-code  = pobj-code and
           ub.pump-nozzle.pump-code = ppump-code on error undo, return error return-value :

    /*удалить связку резервуар-трк-топливо*/
    delete ub.pump-nozzle no-error.
      if error-status:error then do:
        undo _deletion, return error ("Не удалось удалить запись pump-nozzle " + {&new-line} +
                                      "объект " + pobj-type + string(pobj-code) + {&new-line} +
                                      "ТРК " + string(ub.pump-nozzle.pump-code) + {&new-line} +
                                      "пистолет " + string(ub.pump-nozzle.nozzle-code)).
      end.
  end.

end. /*_deletion*/

assign
loc#log = yes.