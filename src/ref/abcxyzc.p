block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: abcxyzc.p $
$Archive: ref/abcxyzc.p $

Сравнение ABC XYZ

Автор: Чернова Светлана Александровна
Дата создания: 06/22/05
Author: Svetlana Chernova
Creation date: 06/22/05

*/

define input parameter  parparentproc  as widget-handle no-undo .
define output parameter p-recid        as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: abcxyzc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/abcxyzc.p $":U .
define variable vss-description as character no-undo init "Сравнение ABC XYZ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ gbl/waitfram.i }

define variable p-rez as character no-undo .
define variable p-rez2 as character no-undo .

 run ref/abcanal.w (input parParentProc ,  "b-sel" , output p-rez) .
 if num-entries(p-rez) < 1 then do:
    message
    "Не выбран ABC анализ !!!"
    view-as alert-box information .
    return error.
 end.

 run ref/xyzanal.w (input parParentProc ,  "b-sel" , output p-rez2) .
 if num-entries(p-rez2) < 1 then do:
    message
    "Не выбран XYZ анализ !!!"
    view-as alert-box information .
    return error.
 end.


define variable var-i as integer   no-undo .
define variable var-kol as integer   no-undo .

var-kol = num-entries (p-rez).
define buffer buf1_abc-analysis for ub.abc-analysis.
define buffer buf_xyz-analysis for ub.xyz-analysis.
define variable g-ok as logical   no-undo .
define variable g1 as logical   no-undo init false  .
define variable g2 as logical   no-undo init false .
define variable g3 as logical   no-undo init false .
define variable g4 as logical   no-undo init false .

find first buf1_abc-analysis no-lock where recid(buf1_abc-analysis) = int(p-rez ) no-error .
find first buf_xyz-analysis no-lock where recid(buf_xyz-analysis) = int(p-rez2) no-error .

    if buf_xyz-analysis.cral-id <> buf1_abc-analysis.cral-id and g1 = false  then do:
        message
            "Есть несоответствия по критерию анализа. " skip
            "Продолжать сравнение ?"
            view-as alert-box question
            button yes-no
            update g-ok .

            if g-ok = false then return .
            else g1 = true .
    end.

    if buf_xyz-analysis.xyz-hash-string-obj <> buf1_abc-analysis.abc-hash-string-obj and g2 = false then do:
        message
            "Есть несоответствия по списку объектов. " skip
            "Продолжать сравнение ?"
            view-as alert-box question
            button yes-no
            update g-ok .

            if g-ok = false then return .
            else g2 = true .
    end.

    if buf_xyz-analysis.xyz-hash-string-doc <> buf1_abc-analysis.abc-hash-string-doc and g3 = false then do:
        message
            "Есть несоответствия по списку типов документов. " skip
            "Продолжать сравнение ?"
            view-as alert-box question
            button yes-no
            update g-ok .

            if g-ok = false then return .
            else g3 = true .
    end.
    if buf_xyz-analysis.xyz-hash-string-period <> buf1_abc-analysis.abc-hash-string-period and g4 = false  then do:
        message
            "Есть несоответствия по списку периодов. " skip
            "Продолжать сравнение ?"
            view-as alert-box question
            button yes-no
            update g-ok .

            if g-ok = false then return .
            else g4 = true .
    end.

define variable v-date as date no-undo .
define variable v-time as integer no-undo .
run cur-time in this-procedure(output v-date, output v-time).

define buffer buf_abc-analysis-goods for ub.abc-analysis-goods.
define buffer buf_xyz-analysis-goods for ub.xyz-analysis-goods.
define variable v-num as integer   no-undo .
run waitfram-show ("Ждите ....").

do transaction :
 v-num = next-value(s-asmt, {&db-name_schema}).

 create ub.abcxyz-analysis.
 assign
    ub.abcxyz-analysis.abcx-id              = v-num
    ub.abcxyz-analysis.db-num               = g#db-num
    ub.abcxyz-analysis.abc-db-num           = buf1_abc-analysis.db-num
    ub.abcxyz-analysis.abc-id               = buf1_abc-analysis.abc-id
    ub.abcxyz-analysis.xyz-id               = buf_xyz-analysis.xyz-id
    ub.abcxyz-analysis.xyz-db-num           = buf_xyz-analysis.db-num
    ub.abcxyz-analysis.abcx-date-create     = v-date
    ub.abcxyz-analysis.abcx-db-num-create   = g#db-num
    ub.abcxyz-analysis.abcx-des             = ""
    ub.abcxyz-analysis.abcx-name            = trim(buf1_abc-analysis.abc-name) + " + " + trim(buf_xyz-analysis.xyz-name)
    ub.abcxyz-analysis.abcx-time-create     = v-time
    ub.abcxyz-analysis.abcx-who-create      = g#userid
    p-recid = recid(ub.abcxyz-analysis)
 .
 for each buf_abc-analysis-goods no-lock where
          buf_abc-analysis-goods.abc-id = buf1_abc-analysis.abc-id and
          buf_abc-analysis-goods.db-num = buf1_abc-analysis.db-num :

          find first ub.abcxyz-analysis-goods exclusive-lock where
                      ub.abcxyz-analysis-goods.gds-code  = buf_abc-analysis-goods.gds-code  and
                      ub.abcxyz-analysis-goods.abcx-id   = v-num  and
                      ub.abcxyz-analysis-goods.db-num    = g#db-num
                      no-error .

               if available ub.abcxyz-analysis-goods then do:
                  ub.abcxyz-analysis-goods.abcg-abc = buf_abc-analysis-goods.abcg-abc .
               end.
               else do:
                    create ub.abcxyz-analysis-goods.
                    assign
                      ub.abcxyz-analysis-goods.abcx-id   = v-num
                      ub.abcxyz-analysis-goods.db-num    = g#db-num
                      ub.abcxyz-analysis-goods.gds-code  = buf_abc-analysis-goods.gds-code
                      ub.abcxyz-analysis-goods.abcg-abc  = buf_abc-analysis-goods.abcg-abc
                    .
               end.
 end.

 for each buf_xyz-analysis-goods no-lock where
          buf_xyz-analysis-goods.xyz-id = buf_xyz-analysis.xyz-id and
          buf_xyz-analysis-goods.db-num = buf_xyz-analysis.db-num :

          find first ub.abcxyz-analysis-goods exclusive-lock where
                      ub.abcxyz-analysis-goods.gds-code  = buf_xyz-analysis-goods.gds-code  and
                      ub.abcxyz-analysis-goods.abcx-id  = v-num  and
                      ub.abcxyz-analysis-goods.db-num   = g#db-num
                      no-error .

               if available ub.abcxyz-analysis-goods then do:
                   ub.abcxyz-analysis-goods.xyzg-xyz = buf_xyz-analysis-goods.xyzg-xyz .
               end.
               else do:
                    create ub.abcxyz-analysis-goods.
                    assign
                      ub.abcxyz-analysis-goods.abcx-id   = v-num
                      ub.abcxyz-analysis-goods.db-num    = g#db-num
                      ub.abcxyz-analysis-goods.gds-code  = buf_xyz-analysis-goods.gds-code
                      ub.abcxyz-analysis-goods.xyzg-xyz  = buf_xyz-analysis-goods.xyzg-xyz
                    .
               end.
 end.


end.
run waitfram-hide .