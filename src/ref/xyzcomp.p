block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: xyzcomp.p $
$Archive: ref/xyzcomp.p $

Сравнение XYZ

Автор: Чернова Светлана Александровна
Дата создания: 05/24/05
Author: Svetlana Chernova
Creation date: 05/24/05

*/

DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: xyzcomp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/xyzcomp.p $":U .
define variable vss-description as character no-undo init "Сравнение XYZ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }


  define variable p-rez as character no-undo .
    run ref/xyzanal.w
      ( input parParentProc , input "b-sel,b-mark" , output p-rez) no-error .
 if num-entries(p-rez) < 2 then do:
    message
    "Должно быть отмечено более одного анализа !!!"
    view-as alert-box information .
    return .
 end.

define variable var-i as integer   no-undo .
define variable var-kol as integer   no-undo .

var-kol = num-entries (p-rez).
define buffer buf1_xyz-analysis for ub.xyz-analysis.
define buffer buf_xyz-analysis for ub.xyz-analysis.
define variable g-ok as logical   no-undo .
define variable g1 as logical   no-undo init false  .
define variable g2 as logical   no-undo init false .
define variable g3 as logical   no-undo init false .
define variable g4 as logical   no-undo init false .

find first buf1_xyz-analysis no-lock where recid(buf1_xyz-analysis) = int(entry(1,p-rez )) no-error .
repeat var-i = 1 to var-kol :
   find first buf_xyz-analysis no-lock where recid(buf_xyz-analysis) = int(entry(var-i,p-rez )) no-error .
    if buf_xyz-analysis.cral-id <> buf1_xyz-analysis.cral-id and g1 = false  then do:
        message
            "Есть несоответствия по критерию анализа. " skip
            "Продолжать сравнение ?"
            view-as alert-box question
            button yes-no
            update g-ok .

            if g-ok = false then return .
            else g1 = true .
    end.

    if buf_xyz-analysis.xyz-hash-string-obj <> buf1_xyz-analysis.xyz-hash-string-obj and g2 = false then do:
        message
            "Есть несоответствия по списку объектов. " skip
            "Продолжать сравнение ?"
            view-as alert-box question
            button yes-no
            update g-ok .

            if g-ok = false then return .
            else g2 = true .
    end.

    if buf_xyz-analysis.xyz-hash-string-doc <> buf1_xyz-analysis.xyz-hash-string-doc and g3 = false then do:
        message
            "Есть несоответствия по списку типов документов. " skip
            "Продолжать сравнение ?"
            view-as alert-box question
            button yes-no
            update g-ok .

            if g-ok = false then return .
            else g3 = true .
    end.
    if buf_xyz-analysis.xyz-hash-string-period <> buf1_xyz-analysis.xyz-hash-string-period and g4 = false  then do:
        message
            "Есть несоответствия по списку периодов. " skip
            "Продолжать сравнение ?"
            view-as alert-box question
            button yes-no
            update g-ok .

            if g-ok = false then return .
            else g4 = true .
    end.


end.

define variable v-user-name as character no-undo .
  { gbl/usrfulnm.i
    v-cntxt-userid
    v-user-name
  }

run ref/prexxyz.p (input  parParentProc ,input  p-rez , input v-user-name)  no-error .