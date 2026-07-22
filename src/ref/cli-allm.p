block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cli-allm.p $
$Archive: ref/cli-allm.p $

Открытие запроса в справочнике клиентов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/10/04
Author: Bakhtadze Natalya
Creation date: 12/10/04

*/

{ ref/cli-all.i }

CASE show-as :
  when ("db" + "-" + {&all} + "-" + {&all} + "-" + {&current})  then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.db-num = g#db-num ~
                            AND  X_clients.stts = 0 ~
                            AND ~{&cli-qor~} "
            &where-cond = " (substitute('X_clients.db-num = &1 ~
                            AND  X_clients.stts = 0 ~
                            AND ', g#db-num ) + ~{&cli-qord~}) "

            &by         = " BY X_clients.obj-type by X_clients.obj-code   " }
      end.
      when "NO" then  do:
        { gbl/fltopend.i
            &where-cond = " X_clients.db-num = g#db-num ~
                            AND  X_clients.stts = 0 "
            &dyn_where-cond = " substitute('X_clients.db-num = &1 ~
                            AND  X_clients.stts = 0 ', g#db-num)"

            &by         = " BY X_clients.obj-type by X_clients.obj-code   " }
      end.
    END CASE .
  end.
  when ("db" + "-" + {&all} + "-" + {&all} + "-" + {&all})  then do:
    CASE JoinType :
      when "Или" then  do:
        { gbl/fltopend.i
            &where-cond = " X_clients.db-num = g#db-num  ~
                            AND ~{&cli-qor~} "
            &dyn_where-cond = " (substitute('X_clients.db-num = &1  ~
                            AND ', g#db-num) + ~{&cli-qord~} )"

            &by         = " BY X_clients.obj-type by X_clients.obj-code   " }
      end.
      when "NO" then  do:
        { gbl/fltopend.i
            &where-cond = " X_clients.db-num = g#db-num  "
            &dyn_where-cond = " substitute('X_clients.db-num = &1', g#db-num ) "
             &by         = " BY X_clients.obj-type by X_clients.obj-code   " }
      end.
    END CASE .
  end.
  when ("db" + "-" + {&all} + "-" + {&all} + "-" + {&deleted}) then do:
    CASE JoinType :
      when "Или" then  do:
        { gbl/fltopend.i
            &where-cond = " X_clients.db-num = g#db-num  ~
                            AND X_clients.stts <> 0 ~
                            AND ~{&cli-qor~} "
            &dyn_where-cond = " (substitute('X_clients.db-num = &1  ~
                            AND X_clients.stts <> 0 ~
                            AND ', g#db-num) + ~{&cli-qord~}) "

            &by         = " BY X_clients.obj-type by X_clients.obj-code   " }

      end.
      when "NO" then   do:
        { gbl/fltopend.i
            &where-cond = " X_clients.db-num = g#db-num ~
                            AND X_clients.stts <> 0 "
            &dyn_where-cond = " substitute('X_clients.db-num = &1 ~
                            AND X_clients.stts <> 0 ', g#db-num)"

            &by         = " BY X_clients.obj-type by X_clients.obj-code   " }
      end.
    END CASE .
  end.
  when ("db" + "-" + {&all} + "-" + {&group} + "-" + {&current})  then do:
    CASE JoinType :
      when "Или" then  do:
        { gbl/fltopend.i
            &where-cond = " X_clients.db-num = g#db-num  ~
                            AND X_clients.stts = 0 ~
                            AND X_clients.grp-name begins Curr-Grp-Name ~
                            AND ~{&cli-qor~} "
            &dyn_where-cond = " (substitute('X_clients.db-num = &1  ~
                            AND X_clients.stts = 0 ~
                            AND X_clients.grp-name begins &2&3&2 ~
                            AND ', g#db-num, ~{&double-quote~}, Curr-Grp-Name) + ~{&cli-qord~}) "

            &by         = " BY X_clients.obj-type by X_clients.obj-code " }
      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.db-num = g#db-num  ~
                            AND X_clients.stts = 0 ~
                            AND X_clients.grp-name begins Curr-Grp-Name"
            &dyn_where-cond = " substitute('X_clients.db-num = &1  ~
                            AND X_clients.stts = 0 ~
                            AND X_clients.grp-name begins &2&3&2', g#db-num, ~{&double-quote~}, Curr-Grp-Name)"

            &by         = " BY X_clients.obj-type by X_clients.obj-code " }
      end.
    END CASE .
  end.
  when ("db" + "-" + {&all} + "-" + {&group} + "-" + {&all})  then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.db-num = g#db-num  ~
                            AND X_clients.grp-name begins Curr-Grp-Name ~
                            AND ~{&cli-qor~} "
            &dyn_where-cond = " (substitute('X_clients.db-num = &1  ~
                            AND X_clients.grp-name begins &2&3&2 ~
                            AND ', g#db-num, ~{&double-quote~}, Curr-Grp-Name) + ~{&cli-qord~} )"

            &by         = " BY X_clients.obj-type by X_clients.obj-code  " }
      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.db-num = g#db-num  ~
                            AND X_clients.grp-name begins Curr-Grp-Name "
            &dyn_where-cond = " substitute('X_clients.db-num = &1  ~
                            AND X_clients.grp-name begins &2&3&2 ', g#db-num, ~{&double-quote~}, Curr-Grp-Name)"
            &by         = " BY X_clients.obj-type by X_clients.obj-code  " }
      end.
    END CASE .
  end.
  when ("db" + "-" + {&all} + "-" + {&group} + "-" + {&deleted}) then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.db-num = g#db-num  ~
                            AND X_clients.grp-name begins Curr-Grp-Name ~
                            AND X_clients.stts <> 0 ~
                            AND ~{&cli-qor~} "
            &dyn_where-cond = " (substitute('X_clients.db-num = &1  ~
                            AND X_clients.grp-name begins &2&3&2 ~
                            AND X_clients.stts <> 0 ~
                            AND ', g#db-num, ~{&double-quote~}, Curr-Grp-Name) + ~{&cli-qord~}) "

            &by         = " BY X_clients.obj-type by X_clients.obj-code  "
            }

      end.
      when "NO" then  do:
        { gbl/fltopend.i
            &where-cond = " X_clients.db-num = g#db-num  ~
                            AND X_clients.grp-name begins Curr-Grp-Name ~
                            AND X_clients.stts <> 0 "
            &dyn_where-cond = " substitute('X_clients.db-num = &1  ~
                            AND X_clients.grp-name begins &2&3&2 ~
                            AND X_clients.stts <> 0 ', g#db-num, ~{&double-quote~}, Curr-Grp-Name)"
            &by         = " BY X_clients.obj-type by X_clients.obj-code  " }
      end.
    END CASE .
  end.
END CASE.

  end. /*doe*/

end procedure. /* proc-main */