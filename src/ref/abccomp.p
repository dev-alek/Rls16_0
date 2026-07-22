block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: abccomp.p $
$Archive: ref/abccomp.p $

Сравнение ABC (вызов разных режимов )

Автор: Чернова Светлана Александровна
Дата создания: 05/24/05
Author: Svetlana Chernova
Creation date: 05/24/05

*/

define input  parameter parparentproc  as widget-handle no-undo.
define input  parameter p-mode as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: abccomp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/abccomp.p $":U .
define variable vss-description as character no-undo init "Сравнение ABC (вызов разных режимов )".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }


  define variable p-rez as character no-undo .
    run ref/abcanal.w ( input parParentProc ,  "b-sel,b-mark" , output p-rez) .
 if num-entries(p-rez) < 1 then do:
    message
    "Должно быть отмечено не менее одного анализа !!!"
    view-as alert-box information .
    return.
 end.

 if p-mode = "lvl":U then do:
  define variable v-lvl as character no-undo .

  v-lvl   = '1'.
  run gbl/d-prompt.w
   (  'title=':u + "Задание параметров отчета" + '\':u
    + 'text1=':u + "введите уровень группы" + '\':u
    + 'text2=':u + "" + '\':u
    + 'format=>9\':u
    + 'type=int\':u
    ,input-output v-lvl
    ).
  if return-value = 'false':u
  then do:
    return .
  end.
   if v-lvl = '0' or v-lvl = ? or v-lvl = '' then do:
      message "Не верно указан № уровня !" view-as alert-box error .
      return .
   end.
 end.

define variable var-i as integer   no-undo .
define variable var-kol as integer   no-undo .

var-kol = num-entries (p-rez).
define buffer buf1_abc-analysis for ub.abc-analysis.
define buffer buf_abc-analysis for ub.abc-analysis.
define variable g-ok as logical   no-undo .
define variable g1 as logical   no-undo init false  .
define variable g2 as logical   no-undo init false .
define variable g3 as logical   no-undo init false .
define variable g4 as logical   no-undo init false .

find first buf1_abc-analysis no-lock where recid(buf1_abc-analysis) = int(entry(1,p-rez )) no-error .
repeat var-i = 1 to var-kol :
   find first buf_abc-analysis no-lock where recid(buf_abc-analysis) = int(entry(var-i,p-rez )) no-error .
    if buf_abc-analysis.cral-id <> buf1_abc-analysis.cral-id and g1 = false  then do:
        message
            "Есть несоответствия по критерию анализа. " skip
            "Продолжать сравнение ?"
            view-as alert-box question
            button yes-no
            update g-ok .

            if g-ok = false then return .
            else g1 = true .
    end.

    if buf_abc-analysis.abc-hash-string-obj <> buf1_abc-analysis.abc-hash-string-obj and g2 = false then do:
        message
            "Есть несоответствия по списку объектов. " skip
            "Продолжать сравнение ?"
            view-as alert-box question
            button yes-no
            update g-ok .

            if g-ok = false then return .
            else g2 = true .
    end.

    if buf_abc-analysis.abc-hash-string-doc <> buf1_abc-analysis.abc-hash-string-doc and g3 = false then do:
        message
            "Есть несоответствия по списку типов документов. " skip
            "Продолжать сравнение ?"
            view-as alert-box question
            button yes-no
            update g-ok .

            if g-ok = false then return .
            else g3 = true .
    end.
    /*
    if buf_abc-analysis.abc-hash-string-period <> buf1_abc-analysis.abc-hash-string-period and g4 = false  then do:
        message
            "Есть несоответствия по списку периодов. " skip
            "Продолжать сравнение ?"
            view-as alert-box question
            button yes-no
            update g-ok .

            if g-ok = false then return .
            else g4 = true .
    end.
    */

end.
define variable v-user-name as character no-undo .
  { gbl/usrfulnm.i
    v-cntxt-userid
    v-user-name
  }

 case p-mode :
      when "goods" then
          run ref/prexabc.p  ( parParentProc , p-rez , v-user-name) no-error .
      when "gds" then
          run rep/r-abcgds.p ( parParentProc , p-rez , v-user-name) no-error .
      when "grp" then
          run rep/r-abcgrp.p ( parParentProc , p-rez , v-user-name) no-error .
      when "prod" then
          run rep/r-abcpro.p ( parParentProc , p-rez , v-user-name) no-error .
      when "lvl" then
          run rep/r-abcsec.p ( parParentProc , p-rez , int(v-lvl) , v-user-name) no-error .
 end case .