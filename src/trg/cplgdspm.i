/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка: Не должно существовать двух записей резервуар-товар-ТРК со статусом текущий у одной ТРК с одним товаром

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/16/07
Author: Dmitry Ukhanov
Creation date: 08/16/07

*/
&if "{1}" = "class"
&then
method private void cplgdspm
( parobj-type  like ub.pl-gds-pump.obj-type ,
  parobj-code  like ub.pl-gds-pump.obj-code , 
  parpl-code   like ub.pl-gds-pump.pl-code  , 
  pargds-code  like ub.pl-gds-pump.gds-code ,
  parpump-code like ub.pl-gds-pump.pump-code,
  parstatus    like ub.pl-gds-pump.status_  ):
&else
procedure cplgdspm :
  define input parameter parobj-type  like ub.pl-gds-pump.obj-type  no-undo.
  define input parameter parobj-code  like ub.pl-gds-pump.obj-code  no-undo.
  define input parameter parpl-code   like ub.pl-gds-pump.pl-code   no-undo.
  define input parameter pargds-code  like ub.pl-gds-pump.gds-code  no-undo.
  define input parameter parpump-code like ub.pl-gds-pump.pump-code no-undo.
  define input parameter parstatus    like ub.pl-gds-pump.status_   no-undo.
&endif
  /*do
  on error undo, return error return-value
  :*/

    define buffer bf_pl-gds-pump          for ub.pl-gds-pump.
    define buffer bf_pl-pump-nozzle       for ub.pl-pump-nozzle.
    define buffer bf-other_pl-pump-nozzle for ub.pl-pump-nozzle.
    define buffer bf-place                for ub.place.

    if parstatus = {&current-status} then do:
      for each bf_pl-gds-pump no-lock
        where bf_pl-gds-pump.obj-type  =  parobj-type
          and bf_pl-gds-pump.obj-code  =  parobj-code
          and bf_pl-gds-pump.gds-code  =  pargds-code
          and bf_pl-gds-pump.pump-code =  parpump-code
          and bf_pl-gds-pump.pl-code   <> parpl-code
          and bf_pl-gds-pump.status_   =  {&current-status}
      on error undo, return error
      :
        find first place where 
                   place.obj-type = parobj-type
               and place.obj-code = parobj-code     
               and place.pl-code  = parpl-code 
             no-lock no-error.
        find first bf-place where 
                   bf-place.obj-type = parobj-type
               and bf-place.obj-code = parobj-code     
               and bf-place.pl-code = bf_pl-gds-pump.pl-code 
             no-lock no-error.
        if nzpl-spl(parobj-type, parobj-code) <> yes then do:
          return error substitute( "Попытка создать запись на объекте &1 &2 резервуар &3 товар с внутренним кодом &4 ТРК &5 статус &6.&7"
                                     ,parobj-type
                                     ,parobj-code
                                     ,if available place then place.loc1 else string(parpl-code)
                                     ,pargds-code
                                     ,parpump-code
                                     ,parstatus
                                     ,{&new-line}
                                    )
                      + substitute( "КАССА не возвращает номер пистолета в чеке, а на объекте уже есть резервуар &1 с тем же товаром и связан он с этой же ТРК."
                                    ,if available bf-place then bf-place.loc1 else string(bf_pl-gds-pump.pl-code)
                                  ).
        end.
        else do:
          find first bf_pl-pump-nozzle no-lock
            where bf_pl-pump-nozzle.obj-type  = parobj-type
              and bf_pl-pump-nozzle.obj-code  = parobj-code
              and bf_pl-pump-nozzle.pump-code = parpump-code
              and bf_pl-pump-nozzle.pl-code   = parpl-code
            no-error.
          if available bf_pl-pump-nozzle then do:
            find first bf-other_pl-pump-nozzle no-lock
              where bf-other_pl-pump-nozzle.obj-type  = bf_pl-gds-pump.obj-type
                and bf-other_pl-pump-nozzle.obj-code  = bf_pl-gds-pump.obj-code
                and bf-other_pl-pump-nozzle.pump-code = bf_pl-gds-pump.pump-code
                and bf-other_pl-pump-nozzle.pl-code   = bf_pl-gds-pump.pl-code
              no-error.
            if available bf-other_pl-pump-nozzle
              and bf-other_pl-pump-nozzle.nozzle-code = bf_pl-pump-nozzle.nozzle-code
            then do:
              return error substitute( "Попытка создать запись на объекте &1 &2 резервуар &3 товар с внутренним кодом &4 ТРК &5 статус &6.&7"
                                       ,parobj-type
                                       ,parobj-code
                                       ,if available place then place.loc1 else string(parpl-code)
                                       ,pargds-code
                                       ,parpump-code
                                       ,parstatus
                                       ,{&new-line}
                                     )
                          + substitute( "На объекте &1 &2 уже есть запись резервуар &3 в статусе &4, в котором находится этот же товар и он связан с этой же ТРК через этот же пистолет."
                                        ,bf_pl-gds-pump.obj-type
                                        ,bf_pl-gds-pump.obj-code
                                        ,if available bf-place then bf-place.loc1 else string(bf_pl-gds-pump.pl-code)
                                        ,bf_pl-gds-pump.status_
                                      ).
            end.
          end.
        end.
      end.
    end.
  /*end.*/
end . // procedure/method /* cplgdspm */