block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cli-allc.p $
$Archive: ref/cli-allc.p $

Открытие запроса в справочнике клиентов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/10/04
Author: Bakhtadze Natalya
Creation date: 12/10/04

*/

{ ref/cli-all.i }

CASE show-as :
  when ({&g___object} + "-" + {&all} + "-" + {&all} + "-" + {&current})  then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " (X_clients.obj-type = ~{&shop~}  ~
                            or X_clients.obj-type = ~{&stock~}) ~
                            AND  X_clients.stts = 0 ~
                            AND ~{&cli-qor~} "
            &dyn_where-cond = "( substitute('(X_clients.obj-type = &1&2&1  ~
                            or X_clients.obj-type = &1&3&1) ~
                            AND  X_clients.stts = 0 ~
                            AND ', ~{&double-quote~}, ~{&shop~}, ~{&stock~}) + ~{&cli-qord~}) "

            &by         = " BY X_clients.obj-type by X_clients.obj-code   " }
      end.
      when "NO" then  do:
        { gbl/fltopend.i
            &where-cond = " (X_clients.obj-type = ~{&shop~} ~
                            or X_clients.obj-type = ~{&stock~}) ~
                            AND  X_clients.stts = 0 "
            &dyn_where-cond = " substitute('(X_clients.obj-type = &1&2&1 ~
                            or X_clients.obj-type = &1&3&1) ~
                            AND  X_clients.stts = 0 ', ~{&double-quote~}, ~{&shop~}, ~{&stock~})"

            &by         = " BY X_clients.obj-type by X_clients.obj-code   " }
      end.
    END CASE .
  end.
  when ({&g___object} + "-" + {&all} + "-" + {&all} + "-" + {&all})  then do:
    CASE JoinType :
      when "Или" then  do:
        { gbl/fltopend.i
            &where-cond = " (X_clients.obj-type = ~{&shop~}  ~
                            or X_clients.obj-type = ~{&stock~}) ~
                            AND ~{&cli-qor~} "
            &dyn_where-cond = " (substitute('(X_clients.obj-type = &1&2&1  ~
                            or X_clients.obj-type = &1&3&1) ~
                            AND ', ~{&double-quote~}, ~{&shop~}, ~{&stock~}) + ~{&cli-qord~}) "

            &by         = " BY X_clients.obj-type by X_clients.obj-code   " }
      end.
      when "NO" then  do:
        { gbl/fltopend.i
            &where-cond = " (X_clients.obj-type = ~{&shop~}  ~
                            or X_clients.obj-type = ~{&stock~}) "
            &dyn_where-cond = " substitute('(X_clients.obj-type = &1&2&1  ~
                            or X_clients.obj-type = &1&3&1)', ~{&double-quote~}, ~{&shop~}, ~{&stock~}) "

             &by         = " BY X_clients.obj-type by X_clients.obj-code   " }
      end.
    END CASE .
  end.
  when ({&g___object} + "-" + {&all} + "-" + {&all} + "-" + {&deleted}) then do:
    CASE JoinType :
      when "Или" then  do:
        { gbl/fltopend.i
            &where-cond = " (X_clients.obj-type = ~{&shop~}  ~
                            or X_clients.obj-type = ~{&stock~}) ~
                            AND X_clients.stts <> 0 ~
                            AND ~{&cli-qor~} "
            &dyn_where-cond = " (substitute('(X_clients.obj-type = &1&2&1  ~
                            or X_clients.obj-type = &1&3&1) ~
                            AND X_clients.stts <> 0 ~
                            AND ', ~{&double-quote~}, ~{&shop~},  ~{&stock~}) + ~{&cli-qord~}) "

            &by         = " BY X_clients.obj-type by X_clients.obj-code   " }

      end.
      when "NO" then   do:
        { gbl/fltopend.i
            &where-cond = " (X_clients.obj-type = ~{&shop~}  ~
                            or X_clients.obj-type = ~{&stock~}) ~
                            AND X_clients.stts <> 0 "
            &dyn_where-cond = " substitute('(X_clients.obj-type = &1&2&1  ~
                            or X_clients.obj-type = &1&3&1) ~
                            AND X_clients.stts <> 0 ', ~{&double-quote~}, ~{&shop~}, ~{&stock~})"

            &by         = " BY X_clients.obj-type by X_clients.obj-code   " }
      end.
    END CASE .
  end.
  when ({&g___object} + "-" + {&all} + "-" + {&group} + "-" + {&current})  then do:
    CASE JoinType :
      when "Или" then  do:
        { gbl/fltopend.i
            &where-cond = " (X_clients.obj-type = ~{&shop~}  ~
                            or X_clients.obj-type = ~{&stock~}) ~
                            AND X_clients.stts = 0 ~
                            AND X_clients.grp-name begins Curr-Grp-Name ~
                            AND ~{&cli-qor~} "
            &dyn_where-cond = " (substitute('(X_clients.obj-type = &1&2&1  ~
                            or X_clients.obj-type = &1&3&1) ~
                            AND X_clients.stts = 0 ~
                            AND X_clients.grp-name begins &1&4&1 ~
                            AND ', ~{&double-quote~}, ~{&shop~}, ~{&stock~}, Curr-Grp-Name) + ~{&cli-qord~} )"

            &by         = " BY X_clients.obj-type by X_clients.obj-code " }
      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " (X_clients.obj-type = ~{&shop~}  ~
                            or X_clients.obj-type = ~{&stock~}) ~
                            AND X_clients.stts = 0 ~
                            AND X_clients.grp-name begins Curr-Grp-Name"
            &dyn_where-cond = " substitute('(X_clients.obj-type = &1&2&1  ~
                            or X_clients.obj-type = &1&3&1) ~
                            AND X_clients.stts = 0 ~
                            AND X_clients.grp-name begins &1&4&1', ~{&double-quote~}, ~{&shop~}, ~{&stock~}, Curr-Grp-Name)"

            &by         = " BY X_clients.obj-type by X_clients.obj-code " }
      end.
    END CASE .
  end.
  when ({&g___object} + "-" + {&all} + "-" + {&group} + "-" + {&all})  then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " (X_clients.obj-type = ~{&shop~}  ~
                            or X_clients.obj-type = ~{&stock~}) ~
                            AND X_clients.grp-name begins Curr-Grp-Name ~
                            AND ~{&cli-qor~} "
            &dyn_where-cond = " (substitute('(X_clients.obj-type = &1&2&1  ~
                            or X_clients.obj-type = &1&3&1) ~
                            AND X_clients.grp-name begins &1&4&1 ~
                            AND ', ~{&double-quote~}, ~{&shop~}, ~{&stock~}, Curr-Grp-Name) + ~{&cli-qord~}) "

            &by         = " BY X_clients.obj-type by X_clients.obj-code  " }
      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " (X_clients.obj-type = ~{&shop~}  ~
                            or X_clients.obj-type = ~{&stock~}) ~
                            AND X_clients.grp-name begins Curr-Grp-Name "
            &dyn_where-cond = " substitute('(X_clients.obj-type = &1&2&1  ~
                            or X_clients.obj-type = &1&3&1) ~
                            AND X_clients.grp-name begins &1&4&1 ', ~{&double-quote~}, ~{&shop~}, ~{&stock~}, Curr-Grp-Name)"

            &by         = " BY X_clients.obj-type by X_clients.obj-code  " }
      end.
    END CASE .
  end.
  when ({&g___object} + "-" + {&all} + "-" + {&group} + "-" + {&deleted}) then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = "  (X_clients.obj-type = ~{&shop~}  ~
                             or X_clients.obj-type = ~{&stock~}) ~
                            AND X_clients.grp-name begins Curr-Grp-Name ~
                            AND X_clients.stts <> 0 ~
                            AND ~{&cli-qor~} "
            &dyn_where-cond = "  (substitute('(X_clients.obj-type = &1&2&1  ~
                             or X_clients.obj-type = &1&3&1) ~
                            AND X_clients.grp-name begins &1&4&1 ~
                            AND X_clients.stts <> 0 ~
                            AND ', ~{&double-quote~}, ~{&shop~}, ~{&stock~}, Curr-Grp-Name) + ~{&cli-qord~}) "

            &by         = " BY X_clients.obj-type by X_clients.obj-code  "
            }

      end.
      when "NO" then  do:
        { gbl/fltopend.i
            &where-cond = " (X_clients.obj-type = ~{&shop~}  ~
                            or X_clients.obj-type = ~{&stock~}) ~
                            AND X_clients.grp-name begins Curr-Grp-Name ~
                            AND X_clients.stts <> 0 "
            &dyn_where-cond = " substitute('(X_clients.obj-type = &1&2&1  ~
                            or X_clients.obj-type = &1&3&1) ~
                            AND X_clients.grp-name begins &1&4&1 ~
                            AND X_clients.stts <> 0 ', ~{&double-quote~}, ~{&shop~}, ~{&stock~}, Curr-Grp-Name)"

            &by         = " BY X_clients.obj-type by X_clients.obj-code  " }
      end.
    END CASE .
  end.
END CASE.

  end. /*doe*/

end procedure. /* proc-main */