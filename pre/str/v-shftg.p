block-level on error undo, throw.
DEFINE parameter buffer chk-doc for ub.chk-doc.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter par-mode as character no-undo .
DEFINE input parameter shop-code like ub.clients.obj-code no-undo.
DEFINE input parameter shop-type like ub.clients.obj-type no-undo.
DEFINE input parameter v-shft as integer no-undo.
DEFINE input parameter t-shft as integer no-undo.
DEFINE input parameter shift-err as char no-undo.
DEFINE input-output parameter for-chk-type as char no-undo.
DEFINE input-output parameter p-view-log as logical no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: v-shftg.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/v-shftg.p $":U .
define variable vss-description as character no-undo init "".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
DEFINE buffer for_chk-doc for chk-doc.
define variable choice as integer no-undo.
define variable vrecid as recid no-undo.
define var response as integer no-undo.
define variable log-file-name as character no-undo init "get-chkf.log".
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FIND FIRST ub.shift-cash NO-LOCK WHERE
          ub.shift-cash.obj-code = shop-code AND
          ub.shift-cash.obj-type = shop-type AND
          ub.shift-cash.cash-num = chk-doc.pay-desk AND
          ub.shift-cash.shift-num = chk-doc.shift-num AND
          ub.shift-cash.shift-date = chk-doc.shift-date NO-ERROR.
IF AVAIL ub.shift-cash then do:
    if ub.shift-cash.sale-date <> chk-doc.shift-date then
    assign
    chk-doc.shift-date = ub.shift-cash.sale-date.
    return.
end.
else do:
    if v-shft = 2 then do:
        if t-shft <= 0 then v-shft = 1.
        else do:
            if chk-doc.chk-date = chk-doc.shift-date then do:
              if (chk-doc.chk-time >= t-shft) AND NOT
                  can-find(first for_chk-doc No-LOCK WHERE
                                for_chk-doc.obj-type = shop-type AND
                                for_chk-doc.obj-code = shop-code AND
                                for_chk-doc.pay-desk = chk-doc.pay-desk AND
                                for_chk-doc.shift-date = chk-doc.shift-date AND
                                for_chk-doc.shift-num = chk-doc.shift-num AND
                                for_chk-doc.chk-time >= t-shft AND
                                for_chk-doc.chk-date = chk-doc.chk-date AND
                                recid(for_chk-doc) <> recid(chk-doc)) then do:
                response = 1.
              end.
              if chk-doc.chk-time < t-shft then response = 0.
            end.
            else do:
              if chk-doc.chk-time >= t-shft then do:
                response = -1.
              end.
              else response = -1.
            end.
            if response >= 0 then do:
                run str/shftccr.p ( input shop-type
                              ,input shop-code
                              ,input chk-doc.pay-desk
                              ,input chk-doc.shift-date
                              ,input chk-doc.shift-num
                              ,input string(chk-doc.shift-num)
                              ,input string(chk-doc.shift-num)
                              ,input chk-doc.chk-time
                              ,input 0
                              ,input 'прием-чек':U
                              ,output vrecid) no-error.
              if response = 1 then do:
                FIND FIRST shift-cash where recid(shift-cash) = vrecid.
                assign
                shift-cash.sale-date = chk-doc.shift-date + 1
                chk-doc.shift-date = shift-cash.sale-date
                .
              end.
            end.
            else v-shft = 1.
        end.
    end.
    if v-shft = 1 then do:
        run gbl/d-askw.w (input "Запрос",
                            input ("В соответствии с настройками системы" + chr(10) +
                                       "необходимо ввести дату, за которую будут учитываться" + chr(10) +
                                       "чеки по кассе " + string(chk-doc.pay-desk) + chr(44) +
                                       "пробитые за смену " + string(chk-doc.shift-num) +
                                       " - дата " + string(chk-doc.shift-date, "99/99/9999") + chr(10) +
                                       "(пришел чек N " + string(chk-doc.chk-num) + " от " +
                                       string(chk-doc.chk-date, "99/99/9999") + chr(32) +
                                       string(chk-doc.chk-time, "HH:MM") + ")"
                                   ),
                             input "|",
                             input (string(chk-doc.shift-date, "99/99/9999") + "|" +
                                       string(chk-doc.shift-date + 1, "99/99/9999") + "|" +
                                       "Ошибка"
                                       ),
                             input "||",
                             input 1,
                             input 3,
                             output choice).
        case choice:
            when 1 then do:
                run str/shftccr.p (
                               input shop-type
                              ,input shop-code
                              ,input chk-doc.pay-desk
                              ,input chk-doc.shift-date
                              ,input chk-doc.shift-num
                              ,input string(chk-doc.shift-num)
                              ,input string(chk-doc.shift-num)
                              ,input chk-doc.chk-time
                              ,input 0
                              ,input 'прием-чек':U
                              ,output vrecid) no-error.
            end.
            when 2 then do:
                run str/shftccr.p (
                               input shop-type
                              ,input shop-code
                              ,input chk-doc.pay-desk
                              ,input chk-doc.shift-date
                              ,input chk-doc.shift-num
                              ,input string(chk-doc.shift-num)
                              ,input string(chk-doc.shift-num)
                              ,input chk-doc.chk-time
                              ,input 0
                              ,input 'прием-чек':U
                              ,output vrecid) no-error.
              if error-status:error then do:
                assign
                p-view-log = yes.
                run write-log-and-file in p-log-handle (
                      input 1
                    , input log-file-name
                    , input 1
                    , input substitute( "!!!Не определена дата смены(дата учета) для чеков для кассы &1: смена N&2 за &3"
                                        , chk-doc.pay-desk
                                        , chk-doc.shift-num
                                        , string(chk-doc.shift-date, "99/99/9999")
                                      )
                                                      ).
                undo, return.
              end.
                FIND FIRST shift-cash where recid(shift-cash) = vrecid.
                assign
                shift-cash.sale-date = chk-doc.shift-date + 1
                chk-doc.shift-date = shift-cash.sale-date
                .
            end.
            when 3 then do:
              assign
              p-view-log = yes.
              run write-log-and-file in p-log-handle (
                    input 1
                  , input log-file-name
                  , input 1
                  , input substitute( "!!!Произошла ошибка при попытке создания записи кассовой смены для кассы &1: смена N&2 за &3"
                                        , chk-doc.pay-desk
                                        , chk-doc.shift-num
                                        , string(chk-doc.shift-date, "99/99/9999")
                                    )
                                                    ).
                 assign
                  for-chk-type = for-chk-type + shift-err + chr(44)
                 chk-doc.shift-date = 01/01/1990.
                 return.
            end.
        END CASE.
    end.
end.
