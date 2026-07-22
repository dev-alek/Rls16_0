block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cli-allj.p $
$Archive: ref/cli-allj.p $

Открытие запроса в справочнике клиентов

Автор: Чернова Светлана Александровна
Дата создания: 12/08/05
Author: Svetlana Chernova
Creation date: 12/08/05

*/

{ ref/cli-all.i B }
&if "{&db-name_schema}" = "ub" &then
&glob contains-oper contains
&else
&glob contains-oper  begins
&endif


CASE show-as :
  when ({&all} + "-" + {&name} + "-" + {&all} + "-" + {&current}) then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            AND  X_clients.stts = 0 ~
                            AND ~{&cli-qorB~} "
            &dyn_where-cond = " (substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            AND  X_clients.stts = 0 ~
                            AND ', ~{&double-quote~}, NameOrCode) + ~{&cli-qorBd~}) "

            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            AND  X_clients.stts = 0 "
            &dyn_where-cond = " substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            AND  X_clients.stts = 0 ', ~{&double-quote~}, NameOrCode)"

            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
  when ({&all} + "-" + {&name} + "-" + {&all} + "-" + {&all}) then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            AND ~{&cli-qorB~} "
            &dyn_where-cond = " (substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            AND ', ~{&double-quote~}, NameOrCode) + ~{&cli-qorBd~}) "

            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode "
                                        &use-ind    = "  "
            &dyn_where-cond = " substitute('X_clients.obj-name {&contains-oper} &1&2&1', ~{&double-quote~}, NameOrCode) "
                                        &use-ind    = "  "

            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
  when ({&all} + "-" + {&name} + "-" + {&all} + "-" + {&deleted}) then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            AND X_clients.stts <> 0 ~
                            AND ~{&cli-qorB~} "
            &dyn_where-cond = " (substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            AND X_clients.stts <> 0 ~
                            AND ', ~{&double-quote~},  NameOrCode) + ~{&cli-qorBd~}) "

            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            AND X_clients.stts <> 0 "
            &dyn_where-cond = " substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            AND X_clients.stts <> 0 ', ~{&double-quote~}, NameOrCode)"

            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
  when ({&all} + "-" + {&name} + "-" + {&group} + "-" + {&current}) then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode  ~
                            AND X_clients.grp-name begins Curr-Grp-Name ~
                            AND X_clients.stts = 0 ~
                            AND ~{&cli-qorB~} "
            &dyn_where-cond = " (substitute('X_clients.obj-name {&contains-oper} &1&2&1  ~
                            AND X_clients.grp-name begins &1&3&1 ~
                            AND X_clients.stts = 0 ~
                            AND ', ~{&double-quote~}, NameOrCode, Curr-Grp-Name) + ~{&cli-qorBd~}) "

            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode  ~
                            AND X_clients.grp-name begins Curr-Grp-Name ~
                            AND X_clients.stts = 0 "
            &dyn_where-cond = " substitute('X_clients.obj-name {&contains-oper} &1&2&1  ~
                            AND X_clients.grp-name begins &1&3&1 ~
                            AND X_clients.stts = 0 ', ~{&double-quote~}, NameOrCode, Curr-Grp-Name)"
            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
  when ({&all} + "-" + {&name} + "-" + {&group} + "-" + {&all}) then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode  ~
                            AND X_clients.grp-name begins Curr-Grp-Name ~
                            AND ~{&cli-qorB~} "
            &dyn_where-cond = " (substitute('X_clients.obj-name {&contains-oper} &1&2&1  ~
                            AND X_clients.grp-name begins &1&3&1 ~
                            AND ', ~{&double-quote~}, NameOrCode, Curr-Grp-Name) + ~{&cli-qorBd~}) "

            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode  ~
                            AND X_clients.grp-name begins Curr-Grp-Name "
            &dyn_where-cond = " substitute('X_clients.obj-name {&contains-oper} &1&2&1  ~
                            AND X_clients.grp-name begins &1&3&1 ', ~{&double-quote~}, NameOrCode, Curr-Grp-Name)"

            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
  when ({&all} + "-" + {&name} + "-" + {&group} + "-" + {&deleted}) then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode  ~
                            AND X_clients.grp-name begins Curr-Grp-Name ~
                            AND X_clients.stts <> 0 ~
                            AND ~{&cli-qorB~} "
            &dyn_where-cond = " (substitute('X_clients.obj-name {&contains-oper} &1&2&1  ~
                            AND X_clients.grp-name begins &1&3&1 ~
                            AND X_clients.stts <> 0 ~
                            AND ', ~{&double-quote~}, NameOrCode, Curr-Grp-Name) + ~{&cli-qorBd~}) "

            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode  ~
                            AND X_clients.grp-name begins Curr-Grp-Name ~
                            AND X_clients.stts <> 0 "
            &dyn_where-cond = " substitute('X_clients.obj-name {&contains-oper} &1&2&1  ~
                            AND X_clients.grp-name begins &1&3&1 ~
                            AND X_clients.stts <> 0 ', ~{&double-quote~}, NameOrCode, Curr-Grp-Name)"

            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
END CASE . /*CASE show-as*/

  end. /*doe*/

end procedure. /* proc-main */