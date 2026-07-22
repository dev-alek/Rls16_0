block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cli-alle.p $
$Archive: ref/cli-alle.p $

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
  when ({&g___object} + "-" + {&all} + "-" + {&attr} + "-" + {&current})   then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " (X_clients.obj-type = ~{&shop~}  ~
                            or X_clients.obj-type = ~{&stock~}) ~
                            AND X_clients.stts = 0 ~
                            AND ~{&cli-qor~} "
            &dyn_where-cond = " (substitute('(X_clients.obj-type = &1&2&1  ~
                            or X_clients.obj-type = &1&3&1) ~
                            AND X_clients.stts = 0 ~
                            AND ', ~{&double-quote~}, ~{&shop~}, ~{&stock~}) + ~{&cli-qord~} )"

            &use-ind    = "  "
            &by         = " BY X_clients.obj-type by X_clients.obj-code  " }

      end.
      when "NO" then do:
         { gbl/fltopend.i
            &where-cond = " (X_clients.obj-type = ~{&shop~}  ~
                            or X_clients.obj-type = ~{&stock~}) ~
                            AND X_clients.stts = 0 "
            &dyn_where-cond = " substitute( ' (X_clients.obj-type = &1&2&1  ~
                            or X_clients.obj-type = &1&3&1) ~
                            AND X_clients.stts = 0 ', ~{&double-quote~}, ~{&shop~}, ~{&stock~})"

            &use-ind    = "  "
            &by         = " BY X_clients.obj-type by X_clients.obj-code   " }
      end.
    END CASE .
  end.
  when ({&g___object} + "-" + {&all} + "-" + {&attr} + "-" + {&all})   then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " (X_clients.obj-type = ~{&shop~}  ~
                            or X_clients.obj-type = ~{&stock~}) ~
                            AND ~{&cli-qor~} "
            &dyn_where-cond = " (substitute('(X_clients.obj-type = &1&2&1  ~
                            or X_clients.obj-type = &1&3&1) ~
                            AND ', ~{&double-quote~}, ~{&shop~}, ~{&stock~}) + ~{&cli-qord~}) "
            &use-ind    = " "
            &by         = " BY X_clients.obj-type by X_clients.obj-code   " }

      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " (X_clients.obj-type = ~{&shop~}  ~
                            or X_clients.obj-type = ~{&stock~}) "
            &dyn_where-cond = " substitute('(X_clients.obj-type = &1&2&1  ~
                            or X_clients.obj-type = &1&3&1)', ~{&double-quote~}, ~{&shop~}, ~{&stock~})"

            &use-ind    = "  "
            &by         = " BY X_clients.obj-type by X_clients.obj-code   " }
      end.
    END CASE .
  end.
  when ({&g___object} + "-" + {&all} + "-" + {&attr} + "-" + {&deleted}) then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " (X_clients.obj-type = ~{&shop~}  ~
                            or X_clients.obj-type = ~{&stock~}) ~
                            AND X_clients.stts <> 0 ~
                            AND ~{&cli-qor~} "
            &dyn_where-cond = " (substitute('(X_clients.obj-type = &1&2&1  ~
                            or X_clients.obj-type = &1&3&1) ~
                            AND X_clients.stts <> 0 ~
                            AND ', ~{&double-quote~}, ~{&shop~}, ~{&stock~}) + ~{&cli-qord~}) "

            &use-ind    = "  "
            &by         = " BY X_clients.obj-type by X_clients.obj-code   " }
      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " (X_clients.obj-type = ~{&shop~}  ~
                            or X_clients.obj-type = ~{&stock~}) ~
                            AND X_clients.stts <> 0 "
            &dyn_where-cond = " substitute('(X_clients.obj-type = &1&2&1  ~
                            or X_clients.obj-type = &1&3&1) ~
                            AND X_clients.stts <> 0 ', ~{&double-quote~}, ~{&shop~}, ~{&stock~})"

            &use-ind    = "  "
            &by         = " BY X_clients.obj-type by X_clients.obj-code   " }
      end.
    END CASE .
  end.
  when ({&g___object} + "-" + {&name} + "-" + {&attr} + "-" + {&current}) then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            and (X_clients.obj-type = ~{&shop~}  ~
                            or X_clients.obj-type = ~{&stock~}) ~
                            AND X_clients.stts = 0 ~
                            AND ~{&cli-qor~} "
            &where-cond = " (substitute(X_clients.obj-name {&contains-oper} &1&2&1 ~
                            and (X_clients.obj-type = &1&3&1  ~
                            or X_clients.obj-type = &1&4&1) ~
                            AND X_clients.stts = 0 ~
                            AND ', ~{&double-quote~}, NameOrCode, ~{&shop~}, ~{&stock~}) + ~{&cli-qord~}) "

            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }

      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            and (X_clients.obj-type = ~{&shop~}  ~
                            or X_clients.obj-type = ~{&stock~}) ~
                            AND X_clients.stts = 0 "
            &dyn_where-cond = " substitute('X_clients.obj-name {&contains-oper} &1&2&1~
                            and (X_clients.obj-type = &1&3&1  ~
                            or X_clients.obj-type = &1&4&1) ~
                            AND X_clients.stts = 0 ', ~{&double-quote~}, NameOrCode, ~{&shop~},~{&stock~}) "

            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
  when ({&g___object} + "-" + {&name} + "-" + {&attr} + "-" + {&all})  then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            and (X_clients.obj-type = ~{&shop~}  ~
                            or X_clients.obj-type = ~{&stock~}) ~
                            AND ~{&cli-qor~} "
            &where-cond = " (substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            and (X_clients.obj-type = &1&3&1  ~
                            or X_clients.obj-type = &1&4&1) ~
                            AND ', ~{&double-quote~}, NameOrCode, ~{&shop~}, ~{&stock~}) + ~{&cli-qord~}) "

            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }
      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            and (X_clients.obj-type = ~{&shop~}  ~
                            or X_clients.obj-type = ~{&stock~}) "
            &dyn_where-cond = " substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            and (X_clients.obj-type = &1&3&1  ~
                            or X_clients.obj-type = &1&4&1) ', ~{&double-quote~}, NameOrCode, ~{&shop~}, ~{&stock~})"

            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
  when ({&g___object} + "-" + {&name} + "-" + {&attr} + "-" + {&deleted})  then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            and (X_clients.obj-type = ~{&shop~}  ~
                            or X_clients.obj-type = ~{&stock~}) ~
                            AND X_clients.stts <> 0 ~
                            AND ~{&cli-qor~} "
            &dyn_where-cond = " (substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            and (X_clients.obj-type = &1&3&1  ~
                            or X_clients.obj-type = &1&4&1) ~
                            AND X_clients.stts <> 0 ~
                            AND ', ~{&double-quote~}, NameOrCode, ~{&shop~}, ~{&stock~}) +  ~{&cli-qord~}) "

            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }
      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            and (X_clients.obj-type = ~{&shop~}  ~
                            or X_clients.obj-type = ~{&stock~}) ~
                            AND X_clients.stts <> 0 "
            &dyn_where-cond = " substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            and (X_clients.obj-type = &1&3&1  ~
                            or X_clients.obj-type = &1&4&1) ~
                            AND X_clients.stts <> 0 ', ~{&double-quote~}, NameOrCode, ~{&shop~}, ~{&stock~})"

            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
END CASE .
  end. /*doe*/

end procedure. /* proc-main */