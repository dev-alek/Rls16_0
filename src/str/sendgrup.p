block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: sendgrup.p $
$Archive: str/sendgrup.p $

Пересылка групп товаров на кассу - пускальник

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/09/05
Author: Bakhtadze Natalya
Creation date: 09/09/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

/*
p-parameter включает
def input parameter i-obj-code like shop.obj-code no-undo.
def input parameter mode as char no-undo .
/*"U' "D" "R" - справочник*/
*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sendgrup.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/sendgrup.p $":U .
define variable vss-description as character no-undo init "Пересылка групп товаров на кассу - пускальник".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
define variable i-obj-code like ub.shop.obj-code no-undo.
define variable mode as char no-undo.
define variable log-file-name as character no-undo init "send-cd.txt":U .
define variable v-view-log as logical no-undo .


{ str/defc-grp.i "NEW SHARED"}
{ cmp/obj-list.i }
{ gbl/getcntxt.i def }

DEFINE VARIABLE choice as integer no-undo.
DEFINE VARIABLE grp-list            as char no-undo.
DEFINE VARIABLE kk                  as int      no-undo.
DEFINE VARIABLE callpoint as char no-undo.
define variable glog as logical no-undo .
/*группы КАССЫ '':U
группы BO "group-BO"
или  признаки  "gds-prt"
или едицины измерения "units"
*/
define variable is-bo as character no-undo .
define variable is-bo-name as character no-undo .

assign
i-obj-code = integer(entry(1, p-parameter, {&delim-par}))
mode       = entry(2, p-parameter, {&delim-par})
is-bo      = (if num-entries(p-parameter, {&delim-par}) > 2
              then entry(3, p-parameter, {&delim-par})
              else '':U
             )
no-error
.
if error-status:error then return error.

{ gbl/getcntxt.i get }

assign
callpoint = mode.
mode = if mode = "R" then "U" else mode.
mode = if mode = "A" then "U" else mode.
for each cash-grp:
  delete cash-grp.
end.
CASE is-bo:
  when '':U then do:
    assign
    is-bo-name = "группы товара на кассе"
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
if is-bo = '':U then do:
  FIND FIRST ub.cash-desk NO-LOCK WHERE
            ub.cash-desk.db-num = g#db-num
        AND (ub.cash-desk.pos-type = {&cd-type-ibm}
            or
            ub.cash-desk.pos-type = {&cd-type-ibm-xml}
            or
            ub.cash-desk.pos-type = {&cd-type-ncr-as-r}
            )
        AND ub.cash-desk.obj-code = i-obj-code No-error.
end.
else do:
  FIND FIRST ub.cash-desk NO-LOCK WHERE
            ub.cash-desk.db-num = g#db-num
        AND ub.cash-desk.pos-type = {&cd-type-infokiosk}
        AND ub.cash-desk.obj-code = i-obj-code No-error.
end.
IF not avail(ub.cash-desk)
then do:
  if callpoint <> "R" then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!&1 &2 реализуется только для касс &3"
                            , (if mode = "U" then "Передача" else "Удаление")
                            , is-bo-name
                            , (if is-bo = '':U
                               then substitute("&1 &2 &3"
                                              , {&cd-type-ibm}
                                              , {&cd-type-ibm-xml}
                                              , {&cd-type-ncr-as-r}
                                              )
                               else {&cd-type-infokiosk}
                              )
                          )
                                         ) .
    return.
  end.
end.
else do:
  if callpoint = "R"
  then do:
    glog = yes.
  end.
  else do:
    define variable v-host-code as integer   no-undo .
    { gbl/hostcode.i
      {&shop}
      abs(i-obj-code)
      v-host-code
    }
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_cashdesk-goods-groups_update':U
      {&cntxt-object}
      v-host-code
      {&shop}
      abs(i-obj-code)
      0
      0
      0
      true
      glog
    }
  end.
  if NOT glog then return .
  glog = yes.
  if callpoint = "R" then choice = 2.
  if callpoint = "A" then choice = 1.
  if choice = 0 then do:
    run gbl/d-askw.w (
                  input substitute("Выбор для пересылки: &1", is-bo-name)
                ,input ( (if mode = "U"
                          then "Переслать на кассу"
                          else "Удалить из кассы" ) +
                          {&new-line} + substitute("информацию по: &1", is-bo-name)
                          )
                ,input "|"
                ,input substitute("Все  имеющиеся в базе|&1Отказ от пересылки", (if is-bo <> '' then '':U else "Выборочно|"))
                ,input (if is-bo <> '':U then "|" else "||")
                ,input 1
                ,input (if is-bo <> '':U then 2 else 3)
                ,output choice).
  end.
  CASE choice :
    when 3 then return .
    when 2 then do:
      if is-bo <> '':U then return.
      if callpoint = "R" then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Подготовка данных")
                                              ).
        FOR EACH obj-list No-LOCK:
          find first ub.sum-grp NO-LOCK WHERE
                  ub.sum-grp.grp-code = obj-list.obj-code no-error .
          FIND FIRST cash-grp WHERE
                      cash-grp.grp-code = ub.sum-grp.grp-code NO-ERROR.
          if not avail cash-grp and
          (available ub.sum-grp or obj-list.obj-name = "D":U) then do:
            create cash-grp.
            assign
            cash-grp.grp-code = obj-list.obj-code
            cash-grp.grp-name = (if available ub.sum-grp
                                 then ub.sum-grp.grp-name
                                 else "":U)
            cash-grp.news-action = (if obj-list.obj-name = "D":U then yes else no)
            .
          end. /*if not avail cash-grp*/
        END. /*FOR EACH obj-list*/
      end. /*"R"*/
      else do:
        run ref/sum-grps.w ( input parparentproc, "b-sel,b-mark", input-output grp-list ) .
        if grp-list <> "" then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("&1 магазина &2: выборочная пересылка: &3"
                                , (if mode = "U" then "Пересылка на кассы" else "Удаление с касс" )
                                , i-obj-code
                                , is-bo-name

                                )
              ).
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Подготовка данных")
                                              ).
          DO kk = 1 TO num-entries( grp-list ) :
            FIND FIRST ub.sum-grp NO-LOCK WHERE
                      recid(ub.sum-grp) = integer(ENTRY(kk, grp-list)) NO-ERROR.
            IF AVAIL ub.sum-grp then do:
              FIND FIRST cash-grp WHERE
                        cash-grp.grp-code = ub.sum-grp.grp-code NO-ERROR.
              if not avail cash-grp then do:
                create cash-grp.
                assign
                cash-grp.grp-code = ub.sum-grp.grp-code
                cash-grp.grp-name = ub.sum-grp.grp-name
                cash-grp.news-action = no
                .
              end. /*if not avail cash-grp*/
            END. /*IF AVAIL ub.sum-grp*/
          END. /*DO kk*/
        end.
        else /*grp-list = ""*/ do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Не определен список для пересылки: &1", is-bo-name)
                                              ).
          return .
        end.
      end. /*not "R"*/
    end. /*when 2 then do:*/
    when 1 then do:
      run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Подготовка данных")
                                              ).
      CASE is-bo:
        when "group-BO" then do:
          FOR EACH ub.gds-grp NO-LOCK:
            FIND FIRST cash-grp WHERE
                    cash-grp.grp-code = ub.gds-grp.node-code NO-ERROR.
            if not avail cash-grp then do:
              create cash-grp.
              assign
              cash-grp.grp-code = ub.gds-grp.node-code
              cash-grp.upper-code = ub.gds-grp.upper-code
              cash-grp.grp-name = ub.gds-grp.node-name
              cash-grp.news-action = no
              .
            end.
          END. /*FOR EACH ub.gds-grp NO-LOCK:*/
        end. /*when group-bo*/
        when '':U then do:
          FOR EACH ub.sum-grp NO-LOCK:
            FIND FIRST cash-grp WHERE
                    cash-grp.grp-code = ub.sum-grp.grp-code NO-ERROR.
            if not avail cash-grp then do:
              create cash-grp.
              assign
              cash-grp.grp-code = ub.sum-grp.grp-code
              cash-grp.grp-name = ub.sum-grp.grp-name
              cash-grp.news-action = no
              .
            end.
          END. /*FOR EACH ub.sum-grp NO-LOCK:*/
        END. /*when '':U*/
        when "units":U then do:
          FOR EACH ub.units NO-LOCK:
            FIND FIRST cash-units WHERE
                    cash-units.unit-name = ub.units.unit-name NO-ERROR.
            if not avail cash-units then do:
              create cash-units.
              assign
              cash-units.unit-name = ub.units.unit-name
              cash-units.long-name = ub.units.long-name
              .
            end.
          END. /*FOR EACH ub.units NO-LOCK:*/
        end. /*when "units":U then do:*/
        when "gds-prt":U then do:
          FOR EACH ub.gds-prt NO-LOCK:
            FIND FIRST cash-gds-prt WHERE
                    cash-gds-prt.node-code = ub.gds-prt.node-code NO-ERROR.
            if not avail cash-gds-prt then do:
              create cash-gds-prt.
              buffer-copy ub.gds-prt to cash-gds-prt.
            end.
          END. /*FOR EACH ub.gds-prt NO-LOCK:*/
        end. /*when "gds-prt":U then do:*/
        when "country":U then do:
          FOR EACH ub.country NO-LOCK:
            FIND FIRST cash-country WHERE
                    cash-country.alpha1 = ub.country.alpha1 NO-ERROR.
            if not avail cash-country then do:
              create cash-country.
              buffer-copy ub.country to cash-country.
            end.
          END. /*FOR EACH ub.gds-prt NO-LOCK:*/
        end. /*when "gds-prt":U then do:*/


      end CASE. /*case is-BO*/
    end. /*when 1*/
  END CASE.
  if ((is-bo = '':U or is-bo = "group-BO")
     and
     can-find(first cash-grp)
     )
  or (is-bo = "Units"
      and
      can-find(first cash-units)
     )
  or (is-bo = "gds-prt":U
      and
      can-find(first cash-gds-prt)
     )
  or (is-bo = "country":U
      and
      can-find(first cash-country)
     )

       then do:
      run str/send-grp.p (
                      input parparentproc
                    , input p-parent-handle
                    , input p-log-handle
                    , input i-obj-code
                    , input  mode
                    , input is-bo
                    , input log-file-name
                    , input-output v-view-log
                    ) no-error.
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("&1 маг&2 &3"
                              , (if mode = "U"
                                then substitute("&1 Передача на кассы", is-bo-name)
                                else substitute("&1 Удаление с касс", is-bo-name)
                                )
                              , i-obj-code
                              , (if mode = "U"
                                then "проведена"
                                else "проведено")
                              )
                                          ).
  end.
  else do:
     run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Не найдено информации по: &1 для передачи на кассы маг&2"
                             , is-bo-name
                             , i-obj-code
                                          )).
  end.
end.