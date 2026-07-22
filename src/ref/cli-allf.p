block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cli-allf.p $
$Archive: ref/cli-allf.p $

Открытие запроса в справочнике клиентов

Автор: Чернова Светлана Александровна
Дата создания: 12/08/05
Author: Svetlana Chernova
Creation date: 12/08/05
*/


{ ref/cli-all.i B }


CASE show-as :
  when ({&cmp} + "-" + {&all} + "-" + {&all} + "-" + {&current}) OR
  when ({&prs} + "-" + {&all} + "-" + {&all} + "-" + {&current}) OR
  when ({&stock} + "-" + {&all} + "-" + {&all} + "-" + {&current}) OR
  when ({&shop} + "-" + {&all} + "-" + {&all} + "-" + {&current}) then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.stts = 0 and X_clients.obj-type = Cli-Types and ~{&cli-qorB~} "
            &dyn_where-cond = " (substitute('X_clients.stts = 0 and X_clients.obj-type = &1&2&1 and ', ~{&double-quote~}, Cli-Types) + ~{&cli-qorBd~}) "
            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
      when "NO" then  do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-type = Cli-Types ~
                            AND  X_clients.stts = 0 "
            &dyn_where-cond = " substitute('X_clients.obj-type = &1&2&1 ~
                            AND  X_clients.stts = 0 ',  ~{&double-quote~}, Cli-Types)"

            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
  when ({&cmp} + "-" + {&all} + "-" + {&all} + "-" + {&all}) OR
  when ({&prs} + "-" + {&all} + "-" + {&all} + "-" + {&all}) OR
  when ({&stock} + "-" + {&all} + "-" + {&all} + "-" + {&all}) OR
  when ({&shop} + "-" + {&all} + "-" + {&all} + "-" + {&all}) then do:
    CASE JoinType :
      when "Или" then  do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-type = Cli-Types ~
                            AND ~{&cli-qorB~} "
            &dyn_where-cond = " (substitute('X_clients.obj-type = &1&2&1 ~
                            AND ', ~{&double-quote~}, Cli-Types) + ~{&cli-qorBd~}) "

            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
      when "NO" then  do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-type = Cli-Types "
            &dyn_where-cond = " substitute('X_clients.obj-type = &1&2&1', ~{&double-quote~}, Cli-Types )"
            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
  when ({&cmp} + "-" + {&all} + "-" + {&all} + "-" + {&deleted}) OR
  when ({&prs} + "-" + {&all} + "-" + {&all} + "-" + {&deleted}) OR
  when ({&stock} + "-" + {&all} + "-" + {&all} + "-" + {&deleted}) OR
  when ({&shop} + "-" + {&all} + "-" + {&all} + "-" + {&deleted})   then do:
    CASE JoinType :
      when "Или" then  do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-type = Cli-Types ~
                            AND X_clients.stts <> 0 ~
                            AND ~{&cli-qorB~} "
            &dyn_where-cond = " (substitute('X_clients.obj-type = &1&2&1 ~
                            AND X_clients.stts <> 0 ~
                            AND ',  ~{&double-quote~}, Cli-Types) + ~{&cli-qorBd~}) "

            &use-ind    = "   "
            &by         = " BY X_clients.obj-name  " }

      end.
      when "NO" then   do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-type = Cli-Types ~
                            AND X_clients.stts <> 0 "
            &dyn_where-cond = " substitute('X_clients.obj-type = &1&2&1~
                            AND X_clients.stts <> 0 ', ~{&double-quote~}, Cli-Types) "

            &use-ind    = "   "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
  when ({&cmp} + "-" + {&all} + "-" + {&group} + "-" + {&current}) OR
  when ({&prs} + "-" + {&all} + "-" + {&group} + "-" + {&current}) OR
  when ({&stock} + "-" + {&all} + "-" + {&group} + "-" + {&current}) OR
  when ({&shop} + "-" + {&all} + "-" + {&group} + "-" + {&current}) then do:
    CASE JoinType :
      when "Или" then  do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-type = Cli-Types ~
                            AND X_clients.stts = 0 ~
                            AND X_clients.grp-name begins Curr-Grp-Name
                            AND ~{&cli-qorB~} "
            &dyn_where-cond = " (substitute('X_clients.obj-type = &1&2&1 ~
                            AND X_clients.stts = 0 ~
                            AND X_clients.grp-name begins &1&3&1 ~
                            AND ',  {&double-quote}, Cli-Types, Curr-Grp-Name) +  ~{&cli-qorBd~}) "

            &use-ind    = "   "
            &by         = " BY X_clients.obj-name  " }
      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-type = Cli-Types ~
                            AND X_clients.stts = 0 ~
                            AND X_clients.grp-name begins Curr-Grp-Name"
            &dyn_where-cond = " substitute('X_clients.obj-type = &1&2&1 ~
                            AND X_clients.stts = 0 ~
                            AND X_clients.grp-name begins &1&3&1',  ~{&double-quote~}, Cli-Types,  Curr-Grp-Name)"

            &use-ind    = "   "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
  when ({&cmp} + "-" + {&all} + "-" + {&group} + "-" + {&all}) OR
  when ({&prs} + "-" + {&all} + "-" + {&group} + "-" + {&all}) OR
  when ({&stock} + "-" + {&all} + "-" + {&group} + "-" + {&all}) OR
  when ({&shop} + "-" + {&all} + "-" + {&group} + "-" + {&all}) then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-type = Cli-Types ~
                            AND X_clients.grp-name begins Curr-Grp-Name
                            AND ~{&cli-qorB~} "
            &dyn_where-cond = " (substitute('X_clients.obj-type = &1&2&1 ~
                            AND X_clients.grp-name begins &1&3&1 ~
                            AND ', ~{&double-quote~}, Cli-Types, Curr-Grp-Name) + ~{&cli-qorBd~}) "

            &use-ind    = "   "
            &by         = " BY X_clients.obj-name  " }
      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-type = Cli-Types ~
                            AND X_clients.grp-name begins Curr-Grp-Name "
            &dyn_where-cond = " substitute('X_clients.obj-type = &1&2&1~
                            AND X_clients.grp-name begins &1&3&1 ',  ~{&double-quote~}, Cli-Types , Curr-Grp-Name)"

            &use-ind    = "   "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
  when ({&cmp} + "-" + {&all} + "-" + {&group} + "-" + {&deleted}) OR
  when ({&prs} + "-" + {&all} + "-" + {&group} + "-" + {&deleted}) OR
  when ({&stock} + "-" + {&all} + "-" + {&group} + "-" + {&deleted}) OR
  when ({&shop} + "-" + {&all} + "-" + {&group} + "-" + {&deleted}) then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-type = Cli-Types ~
                            AND X_clients.grp-name begins Curr-Grp-Name ~
                            AND X_clients.stts <> 0 ~
                            AND ~{&cli-qorB~} "
            &dyn_where-cond = " (substitute('X_clients.obj-type = &1&2&1 ~
                            AND X_clients.grp-name begins &1&3&1 ~
                            AND X_clients.stts <> 0 ~
                            AND ', ~{&double-quote~}, Cli-Types, Curr-Grp-Name) + ~{&cli-qorBd~}) "

            &use-ind    = "   "
            &by         = " BY X_clients.obj-name  " }
      end.
      when "NO" then  do:
        { gbl/fltopend.i
            &where-cond = " X_clients.obj-type = Cli-Types ~
                            AND X_clients.grp-name begins Curr-Grp-Name ~
                            AND X_clients.stts <> 0 "
            &dyn_where-cond = " substitute('X_clients.obj-type = &1&2&1 ~
                            AND X_clients.grp-name begins &1&3&1 ~
                            AND X_clients.stts <> 0 ', ~{&double-quote~}, Cli-Types, Curr-Grp-Name)"

            &use-ind    = "   "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
END CASE.

  end. /*doe*/

end procedure. /* proc-main */