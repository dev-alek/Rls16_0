block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cli-all6.p $
$Archive: ref/cli-all6.p $

Бвыший Change-QUery-1

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
  when ({&cmp} + "-" + {&name} + "-" + {&all} + "-" + {&current}) OR
  when ({&prs} + "-" + {&name} + "-" + {&all} + "-" + {&current}) OR
  when ({&stock} + "-" + {&name} + "-" + {&all} + "-" + {&current}) OR
  when ({&shop} + "-" + {&name} + "-" + {&all} + "-" + {&current}) then do:
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
      when "NO" then  do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            AND X_clients.obj-type = Cli-Types ~
                            AND X_clients.stts = 0 "
            &dyn_where-cond = " substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            AND X_clients.obj-type = &1&3&1 ~
                            AND X_clients.stts = 0 ', ~{&double-quote~}, NameOrCode, Cli-Types) "
            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
  when ({&cmp} + "-" + {&name} + "-" + {&all} + "-" + {&all}) OR
  when ({&prs} + "-" + {&name} + "-" + {&all} + "-" + {&all}) OR
  when ({&stock} + "-" + {&name} + "-" + {&all} + "-" + {&all}) OR
  when ({&shop} + "-" + {&name} + "-" + {&all} + "-" + {&all}) then do:
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
      when "NO" then  do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            AND X_clients.obj-type = Cli-Types "
            &dyn_where-cond = " substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            AND X_clients.obj-type = &1&3&1 ', ~{&double-quote~}, NameOrCode, Cli-Types) "

            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
  when ({&cmp} + "-" + {&name} + "-" + {&all} + "-" + {&deleted}) OR
  when ({&prs} + "-" + {&name} + "-" + {&all} + "-" + {&deleted}) OR
  when ({&stock} + "-" + {&name} + "-" + {&all} + "-" + {&deleted}) OR
  when ({&shop} + "-" + {&name} + "-" + {&all} + "-" + {&deleted}) then do:
    CASE JoinType :
      when "Или" then  do:
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
  when ({&cmp} + "-" + {&name} + "-" + {&group} + "-" + {&current}) OR
  when ({&prs} + "-" + {&name} + "-" + {&group} + "-" + {&current}) OR
  when ({&stock} + "-" + {&name} + "-" + {&group} + "-" + {&current}) OR
  when ({&shop} + "-" + {&name} + "-" + {&group} + "-" + {&current}) then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            AND X_clients.obj-type = Cli-Types ~
                            AND X_clients.grp-name begins Curr-Grp-Name ~
                            AND X_clients.stts = 0 ~
                            AND ~{&cli-qor~} "
            &dyn+where-cond = " (substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            AND X_clients.obj-type = &1&3&1 ~
                            AND X_clients.grp-name begins &1&4&1 ~
                            AND X_clients.stts = 0 ~
                            AND ', ~{&double-quote~}, NameOrCode, Cli-Types, Curr-Grp-Name) + ~{&cli-qord~}) "

            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }
      end.
      when "NO" then  do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            AND X_clients.obj-type = Cli-Types ~
                            AND X_clients.grp-name begins Curr-Grp-Name ~
                            AND X_clients.stts = 0 "
            &dyn_where-cond = " substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            AND X_clients.obj-type = &1&3&1 ~
                            AND X_clients.grp-name begins &1&4&1 ~
                            AND X_clients.stts = 0 ', ~{&double-quote~}, NameOrCode, Cli-Types, Curr-Grp-Name )"

            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
  when ({&cmp} + "-" + {&name} + "-" + {&group} + "-" + {&all}) OR
  when ({&prs} + "-" + {&name} + "-" + {&group} + "-" + {&all}) OR
  when ({&stock} + "-" + {&name} + "-" + {&group} + "-" + {&all}) OR
  when ({&shop} + "-" + {&name} + "-" + {&group} + "-" + {&all}) then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            AND X_clients.obj-type = Cli-Types ~
                            AND X_clients.grp-name begins Curr-Grp-Name ~
                            AND ~{&cli-qor~} "
            &dyn_where-cond = " (substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            AND X_clients.obj-type = &1&3&1 ~
                            AND X_clients.grp-name begins &1&4&1 ~
                            AND ', ~{&double-quote~}, NameOrCode, Cli-Types, Curr-Grp-Name) +  ~{&cli-qord~}) "

            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }
      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            AND X_clients.obj-type = Cli-Types ~
                            AND X_clients.grp-name begins Curr-Grp-Name "
            &dyn_where-cond = " substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            AND X_clients.obj-type = &1&3&1 ~
                            AND X_clients.grp-name begins Curr-Grp-Name ', ~{&double-quote~}, NameOrCode, Cli-Types)"

            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
  when ({&cmp} + "-" + {&name} + "-" + {&group} + "-" + {&deleted}) OR
  when ({&prs} + "-" + {&name} + "-" + {&group} + "-" + {&deleted}) OR
  when ({&stock} + "-" + {&name} + "-" + {&group} + "-" + {&deleted}) OR
  when ({&shop} + "-" + {&name} + "-" + {&group} + "-" + {&deleted}) then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            AND X_clients.obj-type = Cli-Types ~
                            AND X_clients.grp-name begins Curr-Grp-Name ~
                            AND X_clients.stts <> 0 ~
                            AND ~{&cli-qor~} "
            &dyn_where-cond = " (substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            AND X_clients.obj-type = &1&3&1 ~
                            AND X_clients.grp-name begins &1&4&1 ~
                            AND X_clients.stts <> 0 ~
                            AND ', ~{&double-quote~}, NameOrCode, Cli-Types, Curr-Grp-Name) + ~{&cli-qord~}) "

            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }
     end.
     when "NO" then  do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-name {&contains-oper} NameOrCode ~
                            AND X_clients.obj-type = Cli-Types ~
                            AND X_clients.grp-name begins Curr-Grp-Name ~
                            AND X_clients.stts <> 0 "
            &dyn_where-cond = " substitute('X_clients.obj-name {&contains-oper} &1&2&1 ~
                            AND X_clients.obj-type = &1&3&1 ~
                            AND X_clients.grp-name begins &1&4&1 ~
                            AND X_clients.stts <> 0 ', ~{&double-quote~}, NameOrCode, Cli-Types, Curr-Grp-Name)"

            &use-ind    = " "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
END CASE.

  end. /*doe*/

end procedure. /* proc-main */