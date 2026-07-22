block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cli-alln.p $
$Archive: ref/cli-alln.p $

Открытие запроса в справочнике клиентов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/10/04
Author: Bakhtadze Natalya
Creation date: 12/10/04

*/

{ ref/cli-all.i }

&if "{&db-name_schema}" = "ub" &then
&glob contains-oper contains
&else
&glob contains-oper  begins
&endif



CASE show-as :
  when ("db" + "-" + {&name} + "-" + {&all} + "-" + {&current}) then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            AND X_clients.db-num = g#db-num ~
                            AND X_clients.stts = 0 ~
                            AND ~{&cli-qor~} "
            &dyn_where-cond = " (substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            AND X_clients.db-num = &3 ~
                            AND X_clients.stts = 0 ~
                            AND ', ~{&double-quote~}, NameOrCode, g#db-num) + ~{&cli-qord~}) "

            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }
      end.
      when "NO" then  do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            AND X_clients.db-num = g#db-num ~
                            AND X_clients.stts = 0 "
            &dyn_where-cond = " substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            AND X_clients.db-num = &3 ~
                            AND X_clients.stts = 0 ', ~{&double-quote~}, NameOrCode, g#db-num)"

            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
  when ("db" + "-" + {&name} + "-" + {&all} + "-" + {&all})  then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            AND X_clients.db-num = g#db-num ~
                            AND ~{&cli-qor~} "
            &dyn_where-cond = " (substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            AND X_clients.db-num = &3 ~
                            AND ', ~{&double-quote~}, NameOrCode, g#db-num) + ~{&cli-qord~} )"

            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }
      end.
      when "NO" then  do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            AND X_clients.db-num = g#db-num "
            &dyn_where-cond = " substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            AND X_clients.db-num = &3 ', ~{&double-quote~}, NameOrCode, g#db-num)"

            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
  when ("db" + "-" + {&name} + "-" + {&all} + "-" + {&deleted})  then do:
    CASE JoinType :
      when "Или" then  do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            AND X_clients.db-num = g#db-num ~
                            AND X_clients.stts <> 0 ~
                            AND ~{&cli-qor~} "
            &dyn_where-cond = " (substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            AND X_clients.db-num = &3 ~
                            AND X_clients.stts <> 0 ~
                            AND ', ~{&double-quote~}, NameOrCode, g#db-num) + ~{&cli-qord~}) "

            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }
      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            AND X_clients.db-num = g#db-num ~
                            AND X_clients.stts <> 0 "
            &dyn_where-cond = " substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            AND X_clients.db-num = &3 ~
                            AND X_clients.stts <> 0 ', ~{&double-quote~}, NameOrCode, g#db-num)"

            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
  when ("db" + "-" + {&name} + "-" + {&group} + "-" + {&current})  then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            AND X_clients.db-num = g#db-num ~
                            AND X_clients.grp-name begins Curr-Grp-Name ~
                            AND X_clients.stts = 0 ~
                            AND ~{&cli-qor~} "
            &dyn_where-cond = " (substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            AND X_clients.db-num = &3 ~
                            AND X_clients.grp-name begins &1&4&1 ~
                            AND X_clients.stts = 0 ~
                            AND ', ~{&double-quote~}, NameOrCode, g#db-num, Curr-Grp-Name) + ~{&cli-qord~}) "

            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }
      end.
      when "NO" then  do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            AND X_clients.db-num = G#db-num ~
                            AND X_clients.grp-name begins Curr-Grp-Name ~
                            AND X_clients.stts = 0 "
            &dyn_where-cond = " substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            AND X_clients.db-num = &3 ~
                            AND X_clients.grp-name begins &1&4&1 ~
                            AND X_clients.stts = 0 ',  ~{&double-quote~}, NameOrCode, G#db-num, Curr-Grp-Name)"

            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
  when ("db" + "-" + {&name} + "-" + {&group} + "-" + {&all}) then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            AND X_clients.db-num = g#db-num ~
                            AND X_clients.grp-name begins Curr-Grp-Name ~
                            AND ~{&cli-qor~} "
            &dyn_where-cond = " (substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            AND X_clients.db-num = &3 ~
                            AND X_clients.grp-name begins &1&4&1 ~
                            AND ', ~{&double-quote~}, NameOrCode, g#db-num, Curr-Grp-Name) + ~{&cli-qord~}) "

            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }
      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            AND X_clients.db-num = g#db-num ~
                            AND X_clients.grp-name begins Curr-Grp-Name "
            &dyn_where-cond = " substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            AND X_clients.db-num = &3 ~
                            AND X_clients.grp-name begins &1&4&1 ', ~{&double-quote~}, NameOrCode, g#db-num, Curr-Grp-Name)"

            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
  when ("db" + "-" + {&name} + "-" + {&group} + "-" + {&deleted}) then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            AND X_clients.db-num = g#db-num ~
                            AND X_clients.grp-name begins Curr-Grp-Name ~
                            AND X_clients.stts <> 0 ~
                            AND ~{&cli-qor~} "
            &dyn_where-cond = " (substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            AND X_clients.db-num = &3 ~
                            AND X_clients.grp-name begins &1&4&1 ~
                            AND X_clients.stts <> 0 ~
                            AND ', ~{&double-quote~}, NameOrCode, g#db-num, Curr-Grp-Name) + ~{&cli-qord~}) "

            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }
     end.
     when "NO" then  do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            AND X_clients.db-num = g#db-num ~
                            AND X_clients.grp-name begins Curr-Grp-Name ~
                            AND X_clients.stts <> 0 "
            &dyn_where-cond = " substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            AND X_clients.db-num = &3 ~
                            AND X_clients.grp-name begins &1&4&1 ~
                            AND X_clients.stts <> 0 ', ~{&double-quote~}, NameOrCode, g#db-num, Curr-Grp-Name)"

            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.

END CASE.
  end. /*doe*/

end procedure. /* proc-main */