/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

вывод в поток для разных типов касс - пересылка групп товаров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE putc-8.
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-cash-num like ub.cash-desk.cash-num no-undo .
define input parameter pos-type   like ub.cash-desk.pos-type no-undo.
define variable ii  as  integer   no-undo.
define variable v-ii as integer no-undo .
define variable v-record as character no-undo .
define variable v-maria-discnt-value as character no-undo .
define variable v-group-rule-num as integer no-undo .
define variable v-prev-grp-code as integer no-undo .
define variable v-dop as character no-undo .
define variable v-maria-rule-num as integer no-undo .
define variable v-shift-fields as integer no-undo .
DEFINE variable v-image-group as character no-undo .
DEFINE variable v-image-Visible as character no-undo .
DEFINE BUFFER buf_sum-grp-attr for ub.sum-grp-attr .

CASE pos-type:
    when {&cd-type-ibm}
    then do:
        FOR EACH cash-grp NO-LOCK use-index pi:
            PUT stream IBMstream unformatted
            '8':U {&space-char}
            {&double-quote} string((if cash-grp.news-action
                            then "D":U
                            else action
                            ), "x(1)" ) {&double-quote}  {&space-char}
            cash-grp.grp-code format ">>9" {&space-char}
            {&double-quote}
            cash-grp.grp-name format "X(15)"
            {&double-quote}  {&space-char}
            OS2-time
            SKIP.
        END.
    end.
    when
    {&cd-type-ibm-xml}
    or
    when
    {&cd-type-infokiosk}
    then do:
      CASE p-subject:
        when '':U
        or when "group-BO":U then do:
          FOR EACH cash-grp NO-LOCK use-index pi:
            run bgelib-tag-open in this-procedure ( input 2, input "Group", input substitute("ctrl='&1' tms='&2' code='&3'"
                                                                                          , (if cash-grp.news-action
                                                                                              then "DEL":U
                                                                                              else (if action = "U":U
                                                                                                    then "ADD":U
                                                                                                    else "DEL":U
                                                                                                  )
                                                                                              )
                                                                                                , OS2-time
                                                                                                , cash-grp.grp-code)).
            if p-subject = 'group-BO':U
            and pos-type = {&cd-type-infokiosk}
            then do:
              run bgelib-tag-put in this-procedure ( input 3, input "GroupUpperCode"    , input string(cash-grp.upper-code), input 1 ).
            end.
            run bgelib-tag-put in this-procedure ( input 3, input "GroupName"         , input cash-grp.grp-name, input 1 ).
            if p-subject = '':u then do:
              run bgelib-tag-put in this-procedure ( input 3, input "GroupLock"         , input cash-grp.stts, input 1 ).
            end.

              for each buf_sum-grp-attr where buf_sum-grp-attr.grp-code = cash-grp.grp-code:
                  if buf_sum-grp-attr.attr-code = "grp-image" then 
                  do:
                     if buf_sum-grp-attr.attr-value = "yes" then v-image-Visible = "1".
                     else v-image-Visible = "0" .
                    run bgelib-tag-put in this-procedure ( input 3, input "GroupVisible"         , input v-image-Visible, input 1 ).
                  end.     
                  if buf_sum-grp-attr.attr-code = "image-list" then 
                  do:
                   v-image-group = "grp" + "/" + buf_sum-grp-attr.attr-value .
                      run bgelib-tag-put in this-procedure ( input 3, input "GroupImage"         , input v-image-group, input 1 ).
                  end.         

              end.    
            run bgelib-tag-close in this-procedure ( input 2, input "Group").
          END.
        end.
        when "units" then do:
          if pos-type = {&cd-type-infokiosk} then do:
            for each cash-units no-lock:
              run bgelib-tag-open in this-procedure ( input 2, input "Unit", input substitute("ctrl='&1' tms='&2' name='&3'"
                                                                                            ,
                                                                                                (if action = "U":U
                                                                                                      then "ADD":U
                                                                                                      else "DEL":U
                                                                                                    )
                                                                                                  , OS2-time
                                                                                                  , cash-units.unit-name)).
              run bgelib-tag-put in this-procedure ( input 3, input "UnitLongName"         , input cash-units.long-name, input 1 ).
              run bgelib-tag-close in this-procedure ( input 2, input "Unit").
            end.
          end.
        end.
        when "gds-prt" then do:
          if pos-type = {&cd-type-infokiosk} then do:
            for each cash-gds-prt no-lock:
              run bgelib-tag-open in this-procedure ( input 2, input "SizeColor", input substitute("ctrl='&1' tms='&2' code='&3'"
                                                                                            ,
                                                                                                (if action = "U":U
                                                                                                      then "ADD":U
                                                                                                      else "DEL":U
                                                                                                    )
                                                                                                  , OS2-time
                                                                                                  , cash-gds-prt.node-code)).
              run bgelib-tag-put in this-procedure ( input 3, input "SCUpperCode"         , input cash-gds-prt.upper-code, input 1 ).
              run bgelib-tag-put in this-procedure ( input 3, input "SCName"              , input cash-gds-prt.node-name, input 1 ).
              run bgelib-tag-put in this-procedure ( input 3, input "SCFullName"          , input cash-gds-prt.f-name, input 1 ).
              run bgelib-tag-close in this-procedure ( input 2, input "SizeColor").
            end.
          end.
        end.
        when "country" then do:
          if pos-type = {&cd-type-infokiosk} then do:
            for each cash-country no-lock:
              run bgelib-tag-open in this-procedure ( input 2, input "Country", input substitute("ctrl='&1' tms='&2' code='&3'"
                                                                                            ,
                                                                                                (if action = "U":U
                                                                                                      then "ADD":U
                                                                                                      else "DEL":U
                                                                                                    )
                                                                                                  , OS2-time
                                                                                                  , cash-country.alpha1)).
              run bgelib-tag-put in this-procedure ( input 3, input "CountryAlpha2"             , input cash-country.alpha2, input 1 ).
              run bgelib-tag-put in this-procedure ( input 3, input "CountryCode"             , input string(cash-country.num-code), input 1 ).
              run bgelib-tag-put in this-procedure ( input 3, input "CountryName"             , input cash-country.short-name, input 1 ).
              run bgelib-tag-put in this-procedure ( input 3, input "CountryLongName"         , input cash-country.long-name, input 1 ).
              run bgelib-tag-close in this-procedure ( input 2, input "Country").
            end.
          end.
        end.
      END CASE.
    end. /*when ibm-xml*/
    when {&cd-type-ncr-as-r} then do:
    if action = 'U':U then do:
      for each cash-dis-grp-rule where
              cash-Dis-grp-rule.pos-type = {&cd-type-ncr-as-r}
          and cash-Dis-grp-rule.host-code = v-host-code
          AND cash-dis-grp-rule.obj-type = {&shop}
          AND cash-dis-grp-rule.obj-code = i-obj-code
          and cash-dis-grp-rule.classif-type = {&table_sum-grp}
          and cash-dis-grp-rule.discnt-role = {&dggrr-pcnt},
        first cash-dis-rule no-lock where
            cash-dis-rule.rule-num = cash-dis-grp-rule.rule-num:
          run create-ncr-kat-discnt in this-procedure (
                                                       input '':U
                                                      ,input '':U
                                                      ,input '':U
                                                      ,input cash-dis-rule.rule-num
                                                      ,input 36
                                                      ,input 'time-rule-num':U
                                                      ,input cash-dis-grp-rule.node-code
                                                      ,input ?
                                                      ) no-error .
      end.
      for each cash-dis-grp-rule where
              cash-Dis-grp-rule.pos-type = {&cd-type-ncr-as-r}
          and cash-Dis-grp-rule.host-code = v-host-code
          AND cash-dis-grp-rule.obj-type = {&shop}
          AND cash-dis-grp-rule.obj-code = i-obj-code
          and cash-dis-grp-rule.classif-type = {&table_sum-grp}
          and cash-dis-grp-rule.discnt-role = {&dggrr-pcnt},
        first cash-dis-rule no-lock where
            cash-dis-rule.rule-num = cash-dis-grp-rule.rule-num:
          run create-ncr-kat-discnt in this-procedure (
                                                       input '':U
                                                      ,input '':U
                                                      ,input '':U
                                                      ,input cash-dis-rule.rule-num
                                                      ,input 37
                                                      ,input 'time-rule-num':U
                                                      ,input cash-dis-grp-rule.node-code
                                                      ,input ?
                                                      ) no-error .
          if error-status:error then do:
          end.
        end.
      end.
      if action = "D":U then do:
        FOR EACH cash-grp NO-LOCK use-index pi:
          run create-ncr-kat-discnt in this-procedure (
                                                        input cash-grp.grp-code
                                                        ,input ('DP' + fill( {&space-char} , 10) + string(cash-grp.grp-code, '>>>9'))
                                                        ,input '':U
                                                        ,input 0
                                                        ,input 0
                                                        ,input 'time-rule-num':U
                                                        ,input cash-grp.grp-code
                                                        ,input ?
                                                      ) no-error .
      end.
    end. /*D*/
  end.
  when {&cd-type-maria} then do:
    assign
    v-shift-fields = 474
    v-prev-grp-code = 0
    .
    _maria-grp:
    FOR EACH cash-grp NO-LOCK use-index pi:
      if cash-grp.grp-code < 1 then do:
        next _maria-grp.
      end.
      if cash-grp.grp-code > 99 then do:
        LEAVE _maria-grp.
      end.
      v-maria-discnt-value = string(0, '999').
      _do:
      do v-ii = 1 to num-entries(drgrouprank):
        assign
        v-group-rule-num = integer(entry(2, entry(v-ii, drgrouprank), '-')).
        if action = 'D':U  then do:
          assign
          v-maria-discnt-value = string(0, '999')
          .
        end.
        else do:
          find first buf_dis-rule no-lock where
                    buf_dis-rule.obj-type = {&shop}
                AND buf_dis-rule.obj-code = i-obj-code
                AND buf_dis-rule.dis-kat = cash-grp.grp-code
                AND buf_dis-rule.templ-rl-root = v-group-rule-num
                AND buf_dis-rule.sts = integer({&current-status-int}) no-error .
          if not available buf_dis-rule then do:
            next _do.
          end.
          else do:
            /*найдем код группы на кассе МАРИЯ*/
            if index(dr-list, string(buf_dis-rule.rule-num) + '-') = 0 then do:
              v-maria-discnt-value = string(0, '999').
            end.
            else do:
              assign
              v-dop = substring(dr-list, index(dr-list, string(buf_dis-rule.rule-num) + '-':U))
              v-dop = substring(v-dop, 1, index(v-dop, {&comma-char}) - 1)
              v-maria-rule-num = integer(entry(2, v-dop, '-':U)) - 1
              v-maria-discnt-value = string(v-maria-rule-num * 8 + 2, '999')
              .
            end.
          end.
          /*на каждую группу можно задать только одну скидку - поэтому перехожим теперь к след группе*/
          LEAVE _do.
        end. /*не D*/
      end. /*do v-ii = 1*/
      assign
      v-record = v-record +
                  fill({&question-mark} + {&delim-par}, cash-grp.grp-code - v-prev-grp-code - 1) +
                  v-maria-discnt-value + {&delim-par} .
      assign
      v-prev-grp-code = cash-grp.grp-code.
    END. /*for each cash-grp*/
    run maria-put in this-procedure (
                                    buffer buf_cash-desk
                                  , input out
                                  , input fname
                                  , input yes
                                  , input yes
                                  , input v-shift-fields
                                  , input {&tekka-obj-discount-config}
                                  , input 1
                                  , input string(1)   /*в таблице система скидок одна запись*/
                                  , input v-record
                                    ).
  end. /*when cd-type-maria*/

END CASE .
END PROCEDURE .

/* $Workfile$ e n d */