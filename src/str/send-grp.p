block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: send-grp.p $
$Archive: str/send-grp.p $

Пересылка групп товаров на кассу

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter i-obj-code like ub.shop.obj-code no-undo.
DEFINE INPUT PARAMETER action as char no-undo.
define input parameter p-subject as character no-undo .
define input parameter p-log-file-name as character no-undo .
define input-output parameter p-view-log as logical no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: send-grp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/send-grp.p $":U .
define variable vss-description as character no-undo init "Пересылка групп товаров на кассу".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ str/defc-grp.i SHARED }
{ bge/bgelib.i }
{ str/cd-xml.i }
{ str/cdsnddef.i }
{ str/defcncrd.i }
{ gbl/disrules.i work }
{ gbl/disrules.i cash-desk }
define variable is-bo-name as character no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable conf-attr as character no-undo .
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable dflt-cd as character no-undo .
define variable tot-discnt-template as integer no-undo .
/*счетчик записей текущего пакета категорийных скидок NCR*/
define variable cr-ncr-dis-kat               as integer       no-undo .
/*гдк хранить файлы неприкосоновеннхы ручнхы настроек может быть no TH NCR*/
define variable ncr-save-param               as character         no-undo init 'no'.
define variable vc-obj-type like ub.clients.obj-type no-undo .
define variable vc-obj-code like ub.clients.obj-code no-undo .
define variable vc-host-code like ub.sysconf.host-code no-undo .
define variable vc-region as character no-undo .
define variable ii as integer no-undo .
define variable v-upper-rule-num like ub.dis-rule.rule-num no-undo .
/*список соответствий по скидкам для кассы мария */
define variable dr-list as character no-undo .
/*список приоритетов шаблонов правл скидок для скидок по группе товара*/
define variable drgrouprank as character no-undo .

define variable v-found as logical no-undo .

define buffer buf_dis-rule for ub.dis-rule.
define buffer buf2_dis-rule for ub.dis-rule.
define temp-table cash-dis-grp-rule no-undo like ub.dis-grp-rule.

define stream plucash.
define stream bar.

assign
log-file-name = p-log-file-name
.

CASE p-subject:
  when '':U then do:
    assign
    is-bo-name = "группы товара на кассе и/или скидки на группу товара"
    .
  end.
  when 'group-BO':U then do:
    assign
    is-bo-name = "группы товара TH"
    .
  end.
  when 'units':U then do:
    assign
    is-bo-name = "единицы измерения"
    .
  end.
  when 'gds-prt':U then do:
    assign
    is-bo-name = "шкалы"
    .
  end.
  when 'country':U then do:
    assign
    is-bo-name = "страны"
    .
  end.
END.


/*PROCEDURE putc-gds.*/
/*разнящийся вывод для разных типов касс*/
{ str/putc-8.i }


/*PROCEDURE for-cash-cycle*/
/*пройдем цикл по всем кассам одного типа*/
{ str/cd-cycl8.i }

/*PROCEDURE SENDING.*/
{ str/cd-send8.i }

{ gbl/hostcode.i {&shop} i-obj-code v-host-code }

{ gbl/dflt-cd.i {&shop} i-obj-code dflt-cd }

if dflt-cd = {&cd-type-ncr-as-r}
and p-subject = '':U
then do:
 if action= 'U' then do:
    /*Заполним табличку скидки на группу*/
    run fill-cash-dis-grp-rule.
    if not v-found then do:
        run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Для маг&1 не определены скидки на группу для категорий покупателей)&2" +
                                 "(с областью действия &3)"
                                , i-obj-code
                                , {&new-line}
                                , vc-region
                                )
                                              ).
    end.
  end. /*action = U*/
end. /*ncr*/

RUN SENDING no-error.

assign
p-view-log = v-view-log
.

procedure create-ncr-kat-discnt :
/*обновление файлов s_plurbt.dat и group_xx.dat данными о категорийных скидках*/
define input parameter p-subject-code as character no-undo .
define input parameter p-cd-subject-code as character no-undo .
define input parameter p-subject-name as character no-undo .
define input parameter p-dis-rule-num like ub.dis-rule.rule-num no-undo .
define input parameter p-templ-rl-root like ub.dis-rule.templ-rl-root no-undo .
define input parameter p-tree as character no-undo .
define input parameter p-node-code as integer no-undo .
define input parameter p-discnt as decimal no-undo .

define variable h_buffer as handle no-undo .
define buffer buf_cash-dis-rule for cash-dis-rule.
define buffer buf_cash-dis-time-rule for cash-dis-time-rule.
define buffer buf_dis-rule for dis-rule.

  do
  on error undo, return error
  :
    if p-dis-rule-num > 0 then do:
      find first buf_cash-dis-rule no-lock where
                buf_cash-dis-rule.rule-num = p-dis-rule-num no-error.
      if not available buf_cash-dis-rule
      or buf_cash-dis-rule.templ-rl-root <> p-templ-rl-root
      then do:
        return error .
      end.

      if buf_cash-dis-rule.time-rule-num > 0 then do:
        find first buf_cash-dis-time-rule no-lock where
                buf_cash-dis-time-rule.time-rule-num = buf_cash-dis-rule.time-rule-num no-error.

        if not available buf_cash-dis-time-rule then do:
          return error .
        end.
      end.

      /*категорию воткнем для 37 правила*/
      if p-templ-rl-root = 37 then do:
          find first buf_dis-rule no-lock
          where buf_dis-rule.rule-num = buf_cash-dis-rule.upper-rule-num no-error.
          if avail buf_dis-rule then do:
              assign buf_cash-dis-rule.dis-kat = buf_dis-rule.dis-kat .
          end.
      end.

      _for:
      for each buf_cash-dis-rule no-lock where
              /*buf_cash-dis-rule.upper-rule-num = p-dis-rule-num:*/
              buf_cash-dis-rule.rule-num = p-dis-rule-num:
        if buf_cash-dis-rule.time-rule-num > 0 then do:
          find first buf_cash-dis-time-rule no-lock where
                    buf_cash-dis-time-rule.time-rule-num = buf_cash-dis-rule.time-rule-num no-error.
          if not available buf_cash-dis-time-rule then next _for.
        end.
        /*find first cash-grp no-lock where cash-grp.grp-code = integer(buf_cash-dis-rule.key#_one) no-error.*/
        find first cash-grp no-lock where cash-grp.grp-code = p-node-code no-error.
        if not available cash-grp then do:
          next _for.
        end.
        FIND FIRST cash-ncr-dis-kat where
                cash-ncr-dis-kat.crf = (cr-ncr-dis-kat + 1) No-ERROR.
        if not avail cash-ncr-dis-kat then do:
          create cash-ncr-dis-kat.
          error-status:error = false.
        end.
        cash-ncr-dis-kat.crf = cr-ncr-dis-kat + 1.
        cr-ncr-dis-kat = cr-ncr-dis-kat + 1.
        assign
        /*cash-ncr-dis-kat.subject-code  =  string(buf_cash-dis-rule.key#_one)*/
        cash-ncr-dis-kat.subject-code  =  string(p-node-code)
        /*cash-ncr-dis-kat.cd-subject-code  =  ('DP' + fill( {&space-char} , 10) + string(p-node-code, '9999'))*/

        cash-ncr-dis-kat.cd-subject-code  =  ( if p-templ-rl-root = 37
                                               then ('SI' + fill( {&space-char} , 10) + string(p-node-code, '>>>9'))
                                               else ('DP' + fill( {&space-char} , 10) + string(p-node-code, '9999')) )

        cash-ncr-dis-kat.cd-subject-name  = SUBSTRING(buf_cash-dis-rule.des, 1, 20) +
                                          ( if length(buf_cash-dis-rule.des) < 20 then fill( {&space-char} , 20 - length(buf_cash-dis-rule.des) ) else '' )

        cash-ncr-dis-kat.dis-kat =  (if buf_cash-dis-rule.dis-kat < 0 then 0 else buf_cash-dis-rule.dis-kat)
        cash-ncr-dis-kat.rule-num = buf_cash-dis-rule.rule-num
        cash-ncr-dis-kat.time-rule-num = buf_cash-dis-time-rule.time-rule-num
        cash-ncr-dis-kat.cd-disc-string   = "****":U  +
                                         (if buf_cash-dis-rule.discnt-value > 0 then '80':U else '00':U)
        .
        if p-tree = 'time-rule-num':U and available buf_cash-dis-time-rule then do:
          assign
          cash-ncr-dis-kat.cd-disc-string = cash-ncr-dis-kat.cd-disc-string +
                                         (if buf_cash-dis-time-rule.value-type = {&dtr-t-date-period}
                                          then
                                          ("D":U + substring(string(buf_cash-dis-time-rule.date-from, "99/99/9999"), 9, 2) +
                                                  substring(string(buf_cash-dis-time-rule.date-from, "99/99/9999"), 4, 2) +
                                                  substring(string(buf_cash-dis-time-rule.date-from, "99/99/9999"), 1, 2) +
                                                  "-":U +
                                                  substring(string(buf_cash-dis-time-rule.date-to, "99/99/9999"), 9, 2) +
                                                  substring(string(buf_cash-dis-time-rule.date-to, "99/99/9999"), 4, 2) +
                                                  substring(string(buf_cash-dis-time-rule.date-to, "99/99/9999"), 1, 2)
                                          )
                                          else
                                          ("T00":U +
                                                    (if buf_cash-dis-time-rule.week-day-0  then "0" else "":U) +
                                                    (if buf_cash-dis-time-rule.week-day-1  then "2" else "":U) +
                                                    (if buf_cash-dis-time-rule.week-day-2  then "3" else "":U) +
                                                    (if buf_cash-dis-time-rule.week-day-3  then "4" else "":U) +
                                                    (if buf_cash-dis-time-rule.week-day-4  then "5" else "":U) +
                                                    (if buf_cash-dis-time-rule.week-day-5  then "6" else "":U) +
                                                    (if buf_cash-dis-time-rule.week-day-6  then "7" else "":U) +
                                                    (if buf_cash-dis-time-rule.week-day-7  then "1" else "":U) +
                                                  {&slash-char} +
                                                  replace(string(buf_cash-dis-time-rule.time-from, "HH:MM"), ':':U, '':U) + "-":U +
                                                  replace(string(buf_cash-dis-time-rule.time-to, "HH:MM"), ':':U, '':U)
                                          )
                                        )
        .
        assign
        cash-ncr-dis-kat.cd-other =   fill({&space-char}, 10) +  "xx ":U +  "%":U +                                                                                             ~
                                      replace(string(abs(buf_cash-dis-rule.discnt-value),"9999999.9"), '.':U, '':U)
        .
        end.
      end.
    end. /*p-dis-rule-num > 0*/
    else do:
      FIND FIRST cash-ncr-dis-kat where
              cash-ncr-dis-kat.crf = (cr-ncr-dis-kat + 1) No-ERROR.
      if not avail cash-ncr-dis-kat then do:
      create cash-ncr-dis-kat.
      error-status:error = false.
      end.
      cash-ncr-dis-kat.crf = cr-ncr-dis-kat + 1.
      cr-ncr-dis-kat = cr-ncr-dis-kat + 1.
      assign
      cash-ncr-dis-kat.subject-code  = p-subject-code
      cash-ncr-dis-kat.cd-subject-code  = p-cd-subject-code
      cash-ncr-dis-kat.cd-subject-name  = p-subject-name
      cash-ncr-dis-kat.dis-kat =  - 1
      cash-ncr-dis-kat.rule-num = 0
      cash-ncr-dis-kat.time-rule-num = 0
      .
    end.

  end.
end procedure. /* create-ncr-kat-discnt */

/*fill cash-dis-grp-rule*/
procedure fill-cash-dis-grp-rule.
    define buffer buf_Dis-grp-rule for ub.dis-grp-rule.
    define buffer buf2_dis-thbj-rule for ub.dis-thbj-rule.

    do ii = 1 to 3:
      CASE ii:
        when 3 then do:
          assign
          vc-obj-code = i-obj-code
          vc-obj-type = {&shop}
          vc-host-code = v-host-code
          vc-region    = substitute("&1&2", vc-obj-type, vc-obj-code)
          .
        end.
        when 2 then do:
          assign
          vc-obj-code = 0
          vc-obj-type = '':U
          vc-host-code = v-host-code
          vc-region    = substitute("Фирма &1&2", vc-host-code)
          .
        end.
        when 1 then do:
          assign
          vc-obj-code = 0
          vc-obj-type = '':U
          vc-host-code = 0
          vc-region    = "Глобально"
          .
        end.
      END CASE.

      for each buf_dis-grp-rule no-lock where
              buf_Dis-grp-rule.pos-type = dflt-cd
          and buf_Dis-grp-rule.host-code = vc-host-code
          AND buf_dis-grp-rule.obj-type = vc-obj-type
          AND buf_dis-grp-rule.obj-code = vc-obj-code
          and buf_dis-grp-rule.classif-type = {&table_sum-grp}
          and buf_dis-grp-rule.discnt-role = {&dggrr-pcnt},
         first buf_dis-rule no-lock where
                    buf_dis-rule.rule-num = buf_Dis-grp-rule.rule-num
                AND buf_dis-rule.sts = integer({&current-status-int}):
        find first cash-dis-grp-rule where
              cash-Dis-grp-rule.pos-type = dflt-cd
          and cash-Dis-grp-rule.host-code = v-host-code
          AND cash-dis-grp-rule.obj-type = {&shop}
          AND cash-dis-grp-rule.obj-code = i-obj-code
          and cash-dis-grp-rule.classif-type = {&table_sum-grp}
          and cash-dis-grp-rule.discnt-role = {&dggrr-pcnt}
          and cash-dis-grp-rule.node-code = buf_dis-grp-rule.node-code no-error.
        if not available cash-dis-grp-rule then do:
          create cash-dis-grp-rule.
          buffer-copy buf_dis-grp-rule
          except host-code obj-type obj-code
          to cash-dis-grp-rule
          assign
          cash-Dis-grp-rule.host-code = v-host-code
          cash-dis-grp-rule.obj-type = {&shop}
          cash-dis-grp-rule.obj-code = i-obj-code
          .
        end.
        assign
        cash-Dis-grp-rule.rule-num = buf_Dis-rule.rule-num
        .
        release cash-dis-grp-rule.
        v-found = yes.
        run create-dis-rule in this-procedure (buf_dis-rule.rule-num, yes) no-error .
      end.

      for each buf2_dis-thbj-rule no-lock where
                  buf2_dis-thbj-rule.pos-type = dflt-cd
              and buf2_dis-thbj-rule.host-code = vc-host-code
              AND buf2_dis-thbj-rule.obj-type = vc-obj-type
              AND buf2_dis-thbj-rule.obj-code = vc-obj-code
              and buf2_dis-thbj-rule.discnt-role = {&dthbjr-kat-gds-grp},
         each buf2_dis-rule no-lock where
                    buf2_dis-rule.upper-rule-num = buf2_Dis-thbj-rule.rule-num,
            first buf_dis-grp-rule no-lock where
                  buf_dis-grp-rule.host-code = buf2_dis-rule.host-code
             and  buf_dis-grp-rule.obj-type = buf2_dis-rule.obj-type
             and  buf_dis-grp-rule.obj-code = buf2_dis-rule.obj-code
             and  buf_dis-grp-rule.rule-num = buf2_dis-rule.rule-num
             and buf_dis-grp-rule.node-code = buf2_dis-rule.key#_one
             and buf_dis-grp-rule.pos-type = dflt-cd
             and buf_dis-grp-rule.classif-type = {&table_sum-grp}
             and buf_dis-grp-rule.discnt-role = {&dggrr-pcnt-kat}
               :
        find first cash-dis-grp-rule where
              cash-Dis-grp-rule.pos-type = dflt-cd
          and cash-Dis-grp-rule.host-code = v-host-code
          AND cash-dis-grp-rule.obj-type = {&shop}
          AND cash-dis-grp-rule.obj-code = i-obj-code
          and cash-dis-grp-rule.classif-type = {&table_sum-grp}
          and cash-dis-grp-rule.discnt-role = {&dggrr-pcnt-kat}
          and cash-dis-grp-rule.node-code = buf_dis-grp-rule.node-code no-error.
        if not available cash-dis-grp-rule then do:
          create cash-dis-grp-rule.
          buffer-copy buf_dis-grp-rule
          except host-code obj-type obj-code
          to cash-dis-grp-rule
          assign
          cash-Dis-grp-rule.host-code = v-host-code
          cash-dis-grp-rule.obj-type = {&shop}
          cash-dis-grp-rule.obj-code = i-obj-code
          .
        end.
        assign
        cash-Dis-grp-rule.rule-num = buf2_Dis-rule.rule-num
        .
        release cash-dis-grp-rule.
        v-found = yes.
        run create-dis-rule in this-procedure (buf2_dis-rule.rule-num, yes) no-error .
      end.

    end. /*do ii*/

end procedure.