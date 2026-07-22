block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cli-alla.p $
$Archive: ref/cli-alla.p $

Открытие запроса в справочнике клиентов

Автор: Чернова Светлана Александровна
Дата создания: 12/07/05
Author: Svetlana Chernova
Creation date: 12/07/05

*/

{ ref/cli-all.i  B }

&if "{&db-name_schema}" = "ub" &then
&glob contains-oper contains
&else
&glob contains-oper  begins
&endif

CASE show-as :
  when ({&all} + "-" + {&all} + "-" + {&all} + "-" + {&current}) then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.stts = 0 and ~{&cli-qorB~} "
            &dyn_where-cond = "(substitute(' X_clients.stts = 0 and ') + ~{&cli-qorBd~}) "
            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }
      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.stts = 0 "
            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      END.
    END CASE.
  end.
  when ({&all} + "-" + {&all} + "-" + {&all} + "-" + {&all}) then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " ~{&cli-qorB~}  "
            &dyn_where-cond = " ~{&cli-qorBd~}  "
            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = "  "
            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
  when ({&all} + "-" + {&all} + "-" + {&all} + "-" + {&deleted}) then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.stts <> 0  AND ~{&cli-qorB~}"
            &dyn_where-cond = " (substitute('X_clients.stts <> 0  AND ') + ~{&cli-qorBd~})"
            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.stts <> 0 "
            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
  when ({&all} + "-" + {&all} + "-" + {&group} + "-" + {&all}) then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.grp-name begins Curr-Grp-Name ~
                            AND ~{&cli-qorB~} "
            &dyn_where-cond = " (substitute('X_clients.grp-name begins &1&2&1 ~
                            AND ', ~{&double-quote~}, Curr-Grp-Name) + ~{&cli-qorBd~}) "

            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.grp-name begins Curr-Grp-Name "
            &dyn_where-cond = " substitute('X_clients.grp-name begins &1&2&1 ', ~{&double-quote~}, Curr-Grp-Name)"
            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
  when ({&all} + "-" + {&all} + "-" + {&group} + "-" + {&deleted}) then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.grp-name begins Curr-Grp-Name ~
                            AND X_clients.stts <> 0 ~
                            AND ~{&cli-qorB~} "
            &dyn_where-cond = " (substitute('X_clients.grp-name begins &1&2&1 ~
                            AND X_clients.stts <> 0 ~
                            AND ', ~{&double-quote~}, Curr-Grp-Name) + ~{&cli-qorBd~}) "

            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.grp-name begins Curr-Grp-Name ~
                            AND X_clients.stts <> 0 "
            &dyn_where-cond = " substitute('X_clients.grp-name begins &1&2&1 ~
                            AND X_clients.stts <> 0 ', ~{&double-quote~}, Curr-Grp-Name)"

            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
  when ({&all} + "-" + {&all} + "-" + {&group} + "-" + {&current}) then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.grp-name begins Curr-Grp-Name ~
                            AND X_clients.stts = 0 ~
                            AND ~{&cli-qorB~} "
            &dyn_where-cond = " (substitute('X_clients.grp-name begins &1&2&1 ~
                            AND X_clients.stts = 0 ~
                            AND ', ~{&double-quote~}, Curr-Grp-Name) + ~{&cli-qorBd~}) "

            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.grp-name begins Curr-Grp-Name ~
                            AND X_clients.stts = 0 "
            &dyn_where-cond = " substitute('X_clients.grp-name begins &1&2&1 ~
                            AND X_clients.stts = 0 ', ~{&double-quote~}, Curr-Grp-Name)"
            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.

END CASE. /*CASE Show-as*/

  end. /*doe*/

end procedure. /* proc-main */