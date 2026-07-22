/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Верификация на создание и создание записи резервуар-ТРК-пистолет

Автор: Уханов Дмитрий Юрьевич
Дата создания: 09/04/07
Author: Dmitry Ukhanov
Creation date: 09/04/07

Автор1: Суслов Алексей Юрьевич
Дата создания1: 03/27/06

*/
{ str/nzpl-spl.i }
{ str/ptrlv.i "def"}
procedure plpmnzav:
  define input parameter parobj-type    like ub.clients.obj-type   no-undo.
  define input parameter parobj-code    like ub.clients.obj-code   no-undo.
  define input parameter parpl-code     like ub.place.pl-code      no-undo.
  define input parameter parpump-code   like ub.pump.pump-code     no-undo.
  define input parameter parnozzle-code like ub.nozzle.nozzle-code no-undo.

  do
  on error undo, return error return-value
  :
    define buffer bf_clients              for ub.clients.
    define buffer bf_place                for ub.place.
    define buffer bf_pump                 for ub.pump.
    define buffer bf_nozzle               for ub.nozzle.
    define buffer bf_pl-pump              for ub.pl-pump.
    define buffer bf_pump-nozzle          for ub.pump-nozzle.
    define buffer bf_pl-pump-nozzle       for ub.pl-pump-nozzle.
    define buffer bf-other_pl-pump-nozzle for ub.pl-pump-nozzle.
    define buffer bf_rvs-doc              for ub.rvs-doc.
    define buffer bf_icnt-doc             for ub.icnt-doc.
    define buffer bf_pl-gds-pump          for ub.pl-gds-pump.
    define buffer bf-other_pl-gds-pump    for ub.pl-gds-pump.

    { str/ptrlv.i "ov+"       }
    { str/ptrlv.i "ppv+"      }
    { str/ptrlv.i "plv+"      }
    { str/ptrlv.i "nv+"       }
    { str/ptrlv.i "plppv+"    }
    { str/ptrlv.i "ppnv+"     }
    { str/ptrlv.i "rvs-doc-"  }
    { str/ptrlv.i "icnt-doc-" }
    /*Проверяем то, что нет еще такой связки резервуар-ТРК в журнале резервуар-ТРК-пистолет*/
    if nzpl-spl(parobj-type, parobj-code) <> yes then do:
      find first bf_pl-pump-nozzle no-lock
        where bf_pl-pump-nozzle.obj-type   = parobj-type
          and bf_pl-pump-nozzle.obj-code   = parobj-code
          and bf_pl-pump-nozzle.pl-code    = parpl-code
          and bf_pl-pump-nozzle.pump-code  = parpump-code
        no-error.
      if available bf_pl-pump-nozzle then do:
        return error substitute("Резервуар &1 уже связан с ТРК &2, через пистолет &3", parpl-code, parpump-code, bf_pl-pump-nozzle.nozzle-code) {&str-obj}.
      end.
    end.
    do transaction
    on error undo, return error return-value
    :
      /*Если есть привязка к топливу*/
      find first bf_pl-gds-pump no-lock
        where bf_pl-gds-pump.obj-type  = parobj-type
          and bf_pl-gds-pump.obj-code  = parobj-code
          and bf_pl-gds-pump.pl-code   = parpl-code
          and bf_pl-gds-pump.pump-code = parpump-code
        no-error.
      if available bf_pl-gds-pump then do:
        /*Если есть еще резервуар который льет такое же топливо через эту же ТРК*/
        find first bf-other_pl-gds-pump no-lock
          where bf-other_pl-gds-pump.obj-type  = bf_pl-gds-pump.obj-type
            and bf-other_pl-gds-pump.obj-code  = bf_pl-gds-pump.obj-code
            and bf-other_pl-gds-pump.gds-code  = bf_pl-gds-pump.gds-code
            and bf-other_pl-gds-pump.pump-code = bf_pl-gds-pump.pump-code
            and bf-other_pl-gds-pump.pl-code  <> bf_pl-gds-pump.pl-code
          no-error.

        if available bf-other_pl-gds-pump then do:
          if nzpl-spl(parobj-type, parobj-code) <> yes then do:
            /*А из какого резервуара он льет*/
            find first bf-other_pl-pump-nozzle no-lock
              where bf-other_pl-pump-nozzle.obj-type  = bf-other_pl-gds-pump.obj-type
                and bf-other_pl-pump-nozzle.obj-code  = bf-other_pl-gds-pump.obj-code
                and bf-other_pl-pump-nozzle.pl-code   = bf-other_pl-gds-pump.pl-code
                and bf-other_pl-pump-nozzle.pump-code = bf-other_pl-gds-pump.pump-code
              no-error.
            if available bf-other_pl-pump-nozzle then do:
              /*Из разных пистолетов на одной ТРК нельзя торговать одним и тем же топливом*/
              if bf-other_pl-pump-nozzle.nozzle-code <> parnozzle-code then do:
                return error substitute ("На объекте &1 &2 ТРК &3 через пистолет &4 торгует топливом с внутренним кодом &5 из резервуара &6.&7"
                                         + "КАСССА не возвращает номер пистолета в чеке, .&7"
                                         + "поэтому нельзя торговать одним и тем же топливом на одной ТРК через разные пистолеты.&7"
                                         , bf-other_pl-pump-nozzle.obj-type
                                         , bf-other_pl-pump-nozzle.obj-code
                                         , bf-other_pl-pump-nozzle.pump-code
                                         , bf-other_pl-pump-nozzle.nozzle-code
                                         , bf-other_pl-gds-pump.gds-code
                                         , bf-other_pl-gds-pump.pl-code
                                         , {&new-line}
                                        ).
              end.
            end.
          end.
          else do:
            find current bf_pl-gds-pump exclusive-lock.
            assign
              bf_pl-gds-pump.status_ = {&blocked-status}.
          end.
        end.
        /*Идем по остальным резервуарам льющим через данный пистолет на данной ТРК*/
        for each bf-other_pl-pump-nozzle where bf-other_pl-pump-nozzle.obj-type    = parobj-type
                                            and bf-other_pl-pump-nozzle.obj-code    = parobj-code
                                            and bf-other_pl-pump-nozzle.pump-code   = parpump-code
                                            and bf-other_pl-pump-nozzle.nozzle-code = parnozzle-code
                                            no-lock on error undo, return error return-value :
          find first bf-other_pl-gds-pump where bf-other_pl-gds-pump.obj-type  = bf-other_pl-pump-nozzle.obj-type
                                            and bf-other_pl-gds-pump.obj-code  = bf-other_pl-pump-nozzle.obj-code
                                            and bf-other_pl-gds-pump.pl-code   = bf-other_pl-pump-nozzle.pl-code
                                            and bf-other_pl-gds-pump.pump-code = bf-other_pl-pump-nozzle.pump-code no-lock no-error.
          if available bf-other_pl-gds-pump then do:
            if bf-other_pl-gds-pump.gds-code <> bf_pl-gds-pump.gds-code then do:
              return error substitute ("На объекте &1 &2 ТРК &3 через пистолет &4 торгует топливом с внутренним кодом &5 из резервуара &6. Вы хотите торговать топливом с внутренним кодом &7. Разными видами топлива через один пистолет на одной ТРК торговать нельзя.",
                                        bf-other_pl-pump-nozzle.obj-type,
                                        bf-other_pl-pump-nozzle.obj-code,
                                        bf-other_pl-pump-nozzle.pump-code,
                                        bf-other_pl-pump-nozzle.nozzle-code,
                                        bf-other_pl-gds-pump.gds-code,
                                        bf-other_pl-gds-pump.pl-code,
                                        bf_pl-gds-pump.gds-code).
            end.
          end.
        end.
      end.

      create bf_pl-pump-nozzle.
      assign
        bf_pl-pump-nozzle.obj-type    = parobj-type
        bf_pl-pump-nozzle.obj-code    = parobj-code
        bf_pl-pump-nozzle.pl-code     = parpl-code
        bf_pl-pump-nozzle.pump-code   = parpump-code
        bf_pl-pump-nozzle.nozzle-code = parnozzle-code
      .
    end. /*transaction*/
    { str/ptrlv.i "undef"}
  end.
end procedure.
/* $Workfile$ e n d */