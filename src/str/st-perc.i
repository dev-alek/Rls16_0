/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Универсальные триггера для работы с персоналом

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

ON MOUSE-SELECT-DBLCLICK, return OF t-doc.agnt IN FRAME {&frame-name} /* Эксп */
DO:
  run local-psn-chk ("agnt", "ret-mouse").
  apply "entry" to t-doc.boss in frame {&frame-name}.
  return no-apply.
END.

ON MOUSE-SELECT-DBLCLICK, return OF t-doc.boss IN FRAME {&frame-name} /* Нач */
DO:
  RUN local-psn-chk ("boss", "ret-mouse").
  apply "entry" to b-exit in frame {&frame-name}.
  return no-apply.
END.

ON MOUSE-SELECT-DBLCLICK, return OF t-doc.wrkr IN FRAME {&frame-name} /* Исп */
DO:
  RUN local-psn-chk ("wrkr", "ret-mouse").
  apply "entry" to t-doc.agnt in frame {&frame-name}.
  return no-apply.
END.

ON CHOOSE OF r-agnt IN FRAME {&frame-name} /* agent */
DO:
  RUN local-psn-chk ("agnt", "button").
  apply "entry" to t-doc.boss in frame {&frame-name}.
  return no-apply.
END.

ON CHOOSE OF r-boss IN FRAME {&frame-name} /* boss */
DO:
  RUN local-psn-chk ("boss", "button").
  apply "entry" to b-exit in frame {&frame-name}.
  return no-apply.
END.

ON CHOOSE OF r-wrkr IN FRAME {&frame-name} /* worker */
DO:
  run local-psn-chk ("wrkr", "button").
  apply "entry" to t-doc.agnt in frame {&frame-name}.
  return no-apply.
END.

on leave of t-doc.agnt in frame {&frame-name} /* agent */ do:
  if not available t-doc then return .
  if input frame {&frame-name} t-doc.agnt <> t-doc.agnt then do:
    run local-psn-chk ("agnt", "leave").
  end.
end.

on leave of t-doc.boss in frame {&frame-name} /* boss */  do:
  if not available t-doc then return .
  if input frame {&frame-name} t-doc.boss <> t-doc.boss then do:
    run local-psn-chk ("boss", "leave").
  end.
end.

on leave of t-doc.wrkr in frame {&frame-name} /* worker */ do:
  if not available t-doc then return .
  if input frame {&frame-name} t-doc.wrkr <> t-doc.wrkr then do:
    run local-psn-chk ("wrkr", "leave").
  end.
end.

procedure local-psn-chk :
  define input parameter parman    as character no-undo.
  define input parameter paraction as character no-undo.

  if parman = "agnt" and paraction = "ret-mouse" then do:
    { str/psn-chk.i agnt ret-mouse t-doc ref-rec }
  end.
  if parman = "agnt" and paraction = "button" then do:
    { str/psn-chk.i agnt button t-doc ref-rec }
  end.
  if parman = "agnt" and paraction = "leave" then do:
    { str/psn-chk.i agnt leave t-doc ref-rec }
  end.
  if parman = "boss" and paraction = "ret-mouse" then do:
    { str/psn-chk.i boss ret-mouse t-doc ref-rec }
  end.
  if parman = "boss" and paraction = "button" then do:
    { str/psn-chk.i boss button t-doc ref-rec }
  end.
  if parman = "boss" and paraction = "leave" then do:
    { str/psn-chk.i boss leave t-doc ref-rec }
  end.
  if parman = "wrkr" and paraction = "ret-mouse" then do:
    { str/psn-chk.i wrkr ret-mouse t-doc ref-rec }
  end.
  if parman = "wrkr" and paraction = "button" then do:
    { str/psn-chk.i wrkr button t-doc ref-rec }
  end.
  if parman = "wrkr" and paraction = "leave" then do:
    { str/psn-chk.i wrkr leave t-doc ref-rec }
  end.
end procedure. /* local-psn-chk */

/* $Workfile$   E n d */