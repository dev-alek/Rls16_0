block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cli-allo.p $
$Archive: ref/cli-allo.p $

Открытие запроса в справочнике клиентов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/10/04
Author: Bakhtadze Natalya
Creation date: 12/10/04

*/

{ ref/cli-all.i  A }

&if "{&db-name_schema}" = "ub" &then
&glob contains-oper contains
&else
&glob contains-oper  begins
&endif



CASE show-as :
  when ("db" + "-" + {&all} + "-" + {&attr} + "-" + {&current})   then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.db-num = g#db-num  ~
                            AND X_clients.stts = 0 ~
                            AND ~{&cli-qor~} "
            &dyn_where-cond = " (substitute('X_clients.db-num = &1  ~
                            AND X_clients.stts = 0 ~
                            AND ', g#db-num) + ~{&cli-qord~} )"

            &use-ind    = "  "
            &by         = " BY X_clients.obj-type by X_clients.obj-code  " }

      end.
      when "NO" then do:
         { gbl/fltopend.i
            &where-cond = " X_clients.db-num = g#db-num  ~
                            AND X_clients.stts = 0 "
            &dyn_where-cond = " substitute('X_clients.db-num = &1  ~
                            AND X_clients.stts = 0 ', g#db-num)"

            &use-ind    = "  "
            &by         = " BY X_clients.obj-type by X_clients.obj-code   " }
      end.
    END CASE .
  end.
  when ("db" + "-" + {&all} + "-" + {&attr} + "-" + {&all})   then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.db-num = g#db-num  ~
                            AND ~{&cli-qor~} "
            &dyn_where-cond = " (substitute('X_clients.db-num = &1  ~
                            AND ', g#db-num) + ~{&cli-qord~} )"

            &use-ind    = " "
            &by         = " BY X_clients.obj-type by X_clients.obj-code   " }

      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.db-num = g#db-num "
            &dyn_where-cond = " substitute('X_clients.db-num = &1', g#db-num) "
            &use-ind    = "  "
            &by         = " BY X_clients.obj-type by X_clients.obj-code   " }
      end.
    END CASE .
  end.
  when ("db" + "-" + {&all} + "-" + {&attr} + "-" + {&deleted}) then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.db-num = g#db-num  ~
                            AND X_clients.stts <> 0 ~
                            AND ~{&cli-qor~} "
            &dyn_where-cond = " (substitute('X_clients.db-num = &1  ~
                            AND X_clients.stts <> 0 ~
                            AND ', g#db-num) + ~{&cli-qord~}) "

            &use-ind    = "  "
            &by         = " BY X_clients.obj-type by X_clients.obj-code   " }
      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.db-num = g#db-num  ~
                            AND X_clients.stts <> 0 "
            &dyn_where-cond = " substitute('X_clients.db-num = &1  ~
                            AND X_clients.stts <> 0 ', g#db-num)"

            &use-ind    = "  "
            &by         = " BY X_clients.obj-type by X_clients.obj-code   " }
      end.
    END CASE .
  end.
  when ("db" + "-" + {&name} + "-" + {&attr} + "-" + {&current}) then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            and X_clients.db-num = g#db-num ~
                            AND X_clients.stts = 0 ~
                            AND ~{&cli-qor~} "
            &dyn_where-cond = " (substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            and X_clients.db-num = &3 ~
                            AND X_clients.stts = 0 ~
                            AND ', ~{&double-quote~}, NameOrCode, g#db-num) + ~{&cli-qord~}) "

            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }

      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            and X_clients.db-num = g#db-num ~
                            AND X_clients.stts = 0 "
            &dyn_where-cond = " substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            and X_clients.db-num = &3 ~
                            AND X_clients.stts = 0 ', ~{&double-quote~}, NameOrCode, g#db-num)"

            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
  when ("db" + "-" + {&name} + "-" + {&attr} + "-" + {&all})  then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            and X_clients.db-num = g#db-num  ~
                            AND ~{&cli-qor~} "
            &dyn_where-cond = " (substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            and X_clients.db-num = &3  ~
                            AND ', ~{&double-quote~}, NameOrCode, g#db-num) + ~{&cli-qord~})"

            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }
      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            and X_clients.db-num = g#db-num  "
            &dyn_where-cond = " substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            and X_clients.db-num = &3  ',  ~{&double-quote~}, NameOrCode, g#db-num)"

            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
  when ("db" + "-" + {&name} + "-" + {&attr} + "-" + {&deleted})  then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            and X_clients.db-num = g#db-num  ~
                            AND X_clients.stts <> 0 ~
                            AND ~{&cli-qor~} "
            &dyn_where-cond = " (substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            and X_clients.db-num = &3  ~
                            AND X_clients.stts <> 0 ~
                            AND ', ~{&double-quote~}, NameOrCode, g#db-num) + ~{&cli-qord~}) "

            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }
      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            and X_clients.db-num = g#db-num  ~
                            AND X_clients.stts <> 0 "
            &dyn_where-cond = " substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            and X_clients.db-num = &3  ~
                            AND X_clients.stts <> 0 ', ~{&double-quote~}, NameOrCode, g#db-num)"


            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
END CASE .
  end. /*doe*/

end procedure. /* proc-main */