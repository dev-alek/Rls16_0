block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cli-allb.p $
$Archive: ref/cli-allb.p $

Бывший Change-Query-1-A

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
  when ({&cmp} + "-" + {&all} + "-" + {&attr} + "-" + {&current}) OR
  when ({&prs} + "-" + {&all} + "-" + {&attr} + "-" + {&current}) OR
  when ({&stock} + "-" + {&all} + "-" + {&attr} + "-" + {&current}) OR
  when ({&shop} + "-" + {&all} + "-" + {&attr} + "-" + {&current}) then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-type = Cli-Types ~
                            AND X_clients.stts = 0 ~
                            AND ~{&cli-qor~} "
            &dyn_where-cond = " (substitute('X_clients.obj-type = &1&2&1 ~
                            AND X_clients.stts = 0 ~
                            AND ', ~{&double-quote~}, Cli-Types) + ~{&cli-qord~} )"

            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }

      end.
      when "NO" then do:
         { gbl/fltopend.i
            &where-cond = " X_clients.obj-type = Cli-Types ~
                            AND X_clients.stts = 0 "
            &dyn_where-cond = " substitute('X_clients.obj-type = &1&2&1 ~
                            AND X_clients.stts = 0 ', ~{&double-quote~}, Cli-Types)"

            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
  when ({&cmp} + "-" + {&all} + "-" + {&attr} + "-" + {&all}) OR
  when ({&prs} + "-" + {&all} + "-" + {&attr} + "-" + {&all}) OR
  when ({&stock} + "-" + {&all} + "-" + {&attr} + "-" + {&all}) OR
  when ({&shop} + "-" + {&all} + "-" + {&attr} + "-" + {&all}) then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-type = Cli-Types ~
                            AND ~{&cli-qor~} "
            &dyn_where-cond = " (substitute('X_clients.obj-type = &1&2&1~
                            AND ', ~{&double-quote~}, Cli-Types) +  ~{&cli-qord~}) "

            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }

      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-type = Cli-Types "
            &dyn_where-cond = " substitute('X_clients.obj-type = &1&2&1', ~{&double-quote~}, Cli-Types) "
            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
  when ({&cmp} + "-" + {&all} + "-" + {&attr} + "-" + {&deleted}) OR
  when ({&prs} + "-" + {&all} + "-" + {&attr} + "-" + {&deleted}) OR
  when ({&stock} + "-" + {&all} + "-" + {&attr} + "-" + {&deleted}) OR
  when ({&shop} + "-" + {&all} + "-" + {&attr} + "-" + {&deleted})   then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-type = Cli-Types ~
                            AND X_clients.stts <> 0 ~
                            AND ~{&cli-qor~} "
            &dyn_where-cond = " (substitute('X_clients.obj-type = &1&2&1 ~
                            AND X_clients.stts <> 0 ~
                            AND ', ~{&double-quote~}, Cli-Types) + ~{&cli-qord~}) "

            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-type = Cli-Types ~
                            AND X_clients.stts <> 0 "
            &dyn_where-cond = " substitute('X_clients.obj-type = &1&2&1 ~
                            AND X_clients.stts <> 0', ~{&double-quote~}, Cli-Types )"

            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
  when ({&cmp} + "-" + {&name} + "-" + {&attr} + "-" + {&current}) OR
  when ({&prs} + "-" + {&name} + "-" + {&attr} + "-" + {&current}) OR
  when ({&stock} + "-" + {&name} + "-" + {&attr} + "-" + {&current}) OR
  when ({&shop} + "-" + {&name} + "-" + {&attr} + "-" + {&current}) then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            AND X_clients.obj-type = Cli-Types ~
                            AND X_clients.stts = 0 ~
                            AND ~{&cli-qor~} "
            &dyn_where-cond = " (substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            AND X_clients.obj-type = &1&3&1 ~
                            AND X_clients.stts = 0 ~
                            AND ', ~{&double-quote~}, NameOrCode, Cli-Types) + ~{&cli-qord~}) "

            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }

      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            AND X_clients.obj-type = Cli-Types ~
                            AND X_clients.stts = 0 "
            &dyn_where-cond = " substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            AND X_clients.obj-type = &1&3&1 ~
                            AND X_clients.stts = 0 ', ~{&double-quote~}, NameOrCode, Cli-Types)"

            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
  when ({&cmp} + "-" + {&name} + "-" + {&attr} + "-" + {&all}) OR
  when ({&prs} + "-" + {&name} + "-" + {&attr} + "-" + {&all}) OR
  when ({&stock} + "-" + {&name} + "-" + {&attr} + "-" + {&all}) OR
  when ({&shop} + "-" + {&name} + "-" + {&attr} + "-" + {&all}) then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            AND X_clients.obj-type = Cli-Types ~
                            AND ~{&cli-qor~} "
            &dyn_where-cond = " (substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            AND X_clients.obj-type = &1&3&1 ~
                            AND ', ~{&double-quote~}, NameOrCode, Cli-Types) + ~{&cli-qord~}) "

            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }
      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            AND X_clients.obj-type = Cli-Types "
            &dyn_where-cond = " substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            AND X_clients.obj-type = &1&3&1 ', ~{&double-quote~}, NameOrCode, Cli-Types)"

            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
  when ({&cmp} + "-" + {&name} + "-" + {&attr} + "-" + {&deleted}) OR
  when ({&prs} + "-" + {&name} + "-" + {&attr} + "-" + {&deleted}) OR
  when ({&stock} + "-" + {&name} + "-" + {&attr} + "-" + {&deleted}) OR
  when ({&shop} + "-" + {&name} + "-" + {&attr} + "-" + {&deleted}) then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            AND X_clients.obj-type = Cli-Types ~
                            AND X_clients.stts <> 0 ~
                            AND ~{&cli-qor~} "
            &dyn_where-cond = " (substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            AND X_clients.obj-type = &1&3&1 ~
                            AND X_clients.stts <> 0 ~
                            AND ', ~{&double-quote~}, NameOrCode, Cli-Types) + ~{&cli-qord~}) "

            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }
      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            AND X_clients.obj-type = Cli-Types ~
                            AND X_clients.stts <> 0 "
            &dyn_where-cond = " substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            AND X_clients.obj-type = &1&3&1 ~
                            AND X_clients.stts <> 0 ', ~{&double-quote~}, NameOrCode, Cli-Types)"

            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
END CASE .
  end. /*doe*/

end procedure. /* proc-main */