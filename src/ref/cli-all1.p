block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cli-all1.p $
$Archive: ref/cli-all1.p $

Бывший Change-Query-Pro

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/10/04
Author: Bakhtadze Natalya
Creation date: 12/10/04

*/

{ ref/cli-all.i }

CASE show-as :
  when ({&pro} + "-" + {&all} + "-" + {&all} + "-" + {&current}) then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.is-prod = yes ~
                            AND X_clients.stts = 0 ~
                            AND {&cli-qor} "
            &dyn_where-cond = " (substitute('X_clients.is-prod = yes ~
                            AND X_clients.stts = 0 ~
                            AND') + ~{&cli-qord~} )"
            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.is-prod = yes ~
                            AND X_clients.stts = 0 "
            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      END.
    END CASE.
  end.
  when ({&pro} + "-" + {&all} + "-" + {&all} + "-" + {&all}) then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.is-prod = yes ~
                            AND ~{&cli-qor~}"
            &dyn_where-cond = " (substitute('X_clients.is-prod = yes ~
                            AND') + ~{&cli-qord~}) "

            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.is-prod = yes "
            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
  when ({&pro} + "-" + {&all} + "-" + {&all} + "-" + {&deleted}) then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.is-prod = yes ~
                            AND X_clients.stts <> 0  ~
                            AND ~{&cli-qor~}"
            &dyn_where-cond = " (substitute('X_clients.is-prod = yes ~
                            AND X_clients.stts <> 0  ~
                            AND') + ~{&cli-qord~})"
            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.is-prod = yes ~
                            AND X_clients.stts <> 0 "
            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
  when ({&pro} + "-" + {&all} + "-" + {&group} + "-" + {&current}) then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.is-prod = yes ~
                            AND X_clients.grp-name begins Curr-Grp-Name ~
                            AND X_clients.stts = 0 ~
                            AND ~{&cli-qor~} "
            &dyn_where-cond = " (substitute('X_clients.is-prod = yes ~
                            AND X_clients.grp-name begins &1&2&1 ~
                            AND X_clients.stts = 0 ~
                            AND ', ~{&double-quote~}, Curr-Grp-Name) + ~{&cli-qord~}) "
            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.is-prod = yes ~
                            AND X_clients.grp-name begins Curr-Grp-Name ~
                            AND X_clients.stts = 0 "
            &dyn_where-cond = " substitute('X_clients.is-prod = yes ~
                            AND X_clients.grp-name begins &1&2&1 ~
                            AND X_clients.stts = 0 ', ~{&double-quote~}, Curr-Grp-Name) "
            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
  when ({&pro} + "-" + {&all} + "-" + {&group} + "-" + {&all}) then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.is-prod = yes ~
                            AND X_clients.grp-name begins Curr-Grp-Name ~
                            AND ~{&cli-qor~} "
            &dyn_where-cond = " (substitute('X_clients.is-prod = yes ~
                            AND X_clients.grp-name begins &1&2&1 ~
                            AND ', ~{&double-quote~}, Curr-Grp-Name) + ~{&cli-qord~})"
            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.is-prod = yes ~
                            AND X_clients.grp-name begins Curr-Grp-Name "
            &dyn_where-cond = " substitute('X_clients.is-prod = yes ~
                            AND X_clients.grp-name begins &1&2&1 ', ~{&double-quote~}, Curr-Grp-Name) "
            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
  when ({&pro} + "-" + {&all} + "-" + {&group} + "-" + {&deleted}) then do:
    CASE JoinType :
      when "Или" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.is-prod = yes ~
                            AND X_clients.grp-name begins Curr-Grp-Name ~
                            AND X_clients.stts <> 0 ~
                            AND ~{&cli-qor~} "
            &dyn_where-cond = "( substitute('X_clients.is-prod = yes ~
                            AND X_clients.grp-name begins &1&2&1 ~
                            AND X_clients.stts <> 0 ~
                            AND ', ~{&double-quote~}, Curr-Grp-Name) + ~{&cli-qord~})"
            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
      when "NO" then do:
        { gbl/fltopend.i
            &where-cond = " X_clients.is-prod = yes ~
                            AND X_clients.grp-name begins Curr-Grp-Name ~
                            AND X_clients.stts <> 0 "
            &where-cond = " substitute('X_clients.is-prod = yes ~
                            AND X_clients.grp-name begins &1&2&1 ~
                            AND X_clients.stts <> 0 ', ~{&double-quote~}, Curr-Grp-Name) "
            &use-ind    = "  "
            &by         = " BY X_clients.obj-name  " }
      end.
    END CASE .
  end.
END CASE. /*CASE Show-as*/

  end. /*doe*/

end procedure. /* proc-main */