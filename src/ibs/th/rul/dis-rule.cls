/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dis-rule.cls $
$Archive: ibs/th/rul/dis-rule.cls $

Класс Dis-rule

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/28/07
Author: Bakhtadze Natalya
Creation date: 01/28/07

*/
block-level on error undo, throw.
class Ibs.Th.Rul.Dis-rule:
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dis-rule.cls $":U .
define variable vss-archive     as character no-undo init "$Archive: ibs/th/rul/dis-rule.cls $":U .
define variable vss-description as character no-undo init "Класс Dis-rule".
{ cmp/str-glbl.i class }
{ gbl/distruls.i def }

  define protected buffer buf_dis-rule for ub.dis-rule.
  define protected property locked_templ-rl-root as integer no-undo
  get.
  set.
  define private property time-templ-rl-root as integer no-undo
  get.
  set.
  define public property current-lock as integer no-undo
  get.
  set( input p-current-lock as integer):
    case p-current-lock:
      when no-lock
      or when share-lock
      or when exclusive-lock then do:
        define variable glog as logical no-undo .
        glog  = buffer buf_dis-rule:find-current(p-current-lock).
        if not glog then do:
          return error substitute("Не удалось изменить свойство LOCK для скидки &1", buf_dis-rule.rule-num).
        end.
      end.
    end case.
  end set.
  define public property rule-num as integer no-undo
  get():
     if not available buf_dis-rule then do:
        return error substitute("Не установлено правило скидки").
     end.
     return buf_dis-rule.rule-num.
  end get.
  set( input p-rule-num as integer):
    define variable glog as logical no-undo .
    glog  = buffer buf_dis-rule:find-first( substitute('where rule-num = "&1"', p-rule-num), current-lock).
    if not glog then do:
      return error substitute("Не найдено правило скидки с № &1", p-rule-num).
    end.
    time-templ-rl-root = buf_Dis-rule.time-templ-rl-root.
  end set.
  CONSTRUCTOR PUBLIC Dis-rule(  input p-rule-num as integer
                               ,input p-current-lock as integer
                             ):
    define variable glog as logical no-undo .
    glog  = buffer buf_dis-rule:find-first( substitute('where rule-num = "&1"', p-rule-num), p-current-lock).
    if not glog then do:
      return error substitute("Не найдено правило скидки с № &1", p-rule-num).
    end.
    assign
    current-lock = p-current-lock
    locked_templ-rl-root = ?
    time-templ-rl-root = buf_dis-rule.time-templ-rl-root
    .
  END CONSTRUCTOR.
  method public override character ToString ():
    return string(buf_dis-rule.rule-num).
  end method.
  method public integer ToInteger ():
    return buf_dis-rule.rule-num.
  end method.
  method public integer select-value ( input parParentProc  AS WIDGET-HANDLE
                                      ,input p-curr-obj-type as character
                                      ,input p-curr-obj-code as integer
                                      ,input p-mode as character
                                      ,input p-upper-rule-num as integer  /*для p-mode = time-rule-num ьам дежит time-rule-num*/
                                      ,input p-b-code as integer
                                      ,input-output p-sts as integer ) :
          /*{&all}  "upper-rule-num"  "template" {&g___object} "time-rule-num" upper-rule-num-object
            "upper-rule-num-gds-obj dis-gds-rule dis-gds-rule-gds-obj cd-obj */


    define variable v-ok as logical no-undo.
    define variable v-rid-list as character no-undo .
    define buffer buf_dis-rule for ub.dis-rule.
    run ref/dis-ruls.w (   input  parparentproc
                          ,input p-curr-obj-type
                          ,input p-curr-obj-code
                          ,input "b-sel"
                          ,input p-mode
                          ,input p-upper-rule-num
                          ,input ? /*p-time-rule-num*/
                          ,input p-b-code
                          ,input-output p-sts /*p-sts*/
                          ,input-OUTPUT v-rid-list) NO-ERROR.
    if v-rid-list <> '':U then do:
      define variable glog as logical no-undo .
      glog  = buffer buf_dis-rule:find-first( substitute('where recid(rule-num = "&1"', integer(v-rid-list)), current-lock).

      find first buf_dis-rule no-lock where
                recid(buf_dis-rule) = integer(v-rid-list) no-error.
      if not available buf_dis-rule then return error substitute("Не найдено правило скидки c recid &1", v-rid-list).
      assign
      rule-num = buf_dis-rule.rule-num
      time-templ-rl-root = buf_dis-rule.time-templ-rl-root
      .
    end.
  end method.
  method public decimal dis-rule_l20 (
                                          input p-rule-num as integer
                                         ,input p-date as date
                                         ,input p-time as integer
                                         ,input p-tot-sum as decimal
                                        ):
/*@% скидка на итог чека для всех покупателей(POS IBM, IBM-XML, NCR-AS@R)"*/
    define variable v-delta as decimal no-undo .
    define variable v-start as logical no-undo init yes.
    define variable v-discnt-value as decimal no-undo .
    define buffer buf_term-dis-rule for ub.dis-rule.
    /*todo*/
    p-rule-num = rule-num.
&scop time-ok yes
    if buf_dis-rule.sts = integer({&current-status-int})
    and {&time-ok}
    then do:
      for each buf_term-dis-rule no-lock where
              buf_term-dis-rule.upper-rule-num = p-rule-num:
        if buf_term-dis-rule.tot-sum < p-tot-sum then do:
          if v-start
          or v-delta  > (p-tot-sum - buf_term-dis-rule.tot-sum)
          then do:
            assign
            v-discnt-value = buf_term-dis-rule.discnt-value
            v-start = no
            v-delta = p-tot-sum - buf_term-dis-rule.tot-sum
            .
          end.
        end.
      end.
      return v-discnt-value.
    end.
    return 0.0.
  end method.
end class.
