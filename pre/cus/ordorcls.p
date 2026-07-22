block-level on error undo, throw.
define input parameter parparentproc as handle no-undo .
define input parameter p-rec as recid   no-undo .
define input parameter p-ask as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
define variable vss-author      as character no-undo init "$Author: expertek $":u .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: ordorcls.p $":u .
define variable vss-archive     as character no-undo init "$Archive: cus/ordorcls.p $":u .
define variable vss-description as character no-undo init  "Переход по графу статусов" .
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable to-day       as date no-undo .
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE VARIABLE v-S_CONTRACT               AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE v-S_CODE_LAST_MASTER_NUM   AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE v-DELIM_CHR_3              AS CHARACTER NO-UNDO INITIAL "".
ASSIGN
   v-S_CONTRACT                = "Contract":U
   v-S_CODE_LAST_MASTER_NUM    = "LastMasterNum":U
   v-DELIM_CHR_3               = ","
   .
DEFINE VARIABLE i-gl-Host-Code      AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE i-gl-Contract-Code  AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE i-gl-Extent3        AS INTEGER NO-UNDO INITIAL 0 EXTENT 3.
FUNCTION Can-Find-Spec RETURN LOGICAL (
   INPUT iHost-Code    AS INTEGER,
   INPUT iContract-Num AS INTEGER,
   INPUT iGds-Code     AS INTEGER ):
   DEFINE BUFFER buf_Spec FOR ub.Contract-Specif.
   DEFINE VARIABLE iTmp-Host-Code     AS INTEGER NO-UNDO INITIAL 0.
   DEFINE VARIABLE iTmp-Contract-Num  AS INTEGER NO-UNDO INITIAL 0.
   DEFINE VARIABLE iTmp-Extent3       AS INTEGER NO-UNDO INITIAL 0 EXTENT 3.
   DEFINE VARIABLE lRet               AS LOGICAL NO-UNDO INITIAL FALSE.
   RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
       INPUT  iHost-Code,
       INPUT  iContract-Num,
       OUTPUT iTmp-Extent3
       ).
   IF iTmp-Extent3[1] = 2 THEN DO:
      ASSIGN
         iTmp-Host-Code      = iTmp-Extent3[2]
         iTmp-Contract-Num   = iTmp-Extent3[3]
         .
   END. ELSE DO:
      ASSIGN
         iTmp-Host-Code      = iHost-Code
         iTmp-Contract-Num   = iContract-Num
         .
   END.
   IF iGds-Code = ? THEN DO:
      ASSIGN
         lRet = CAN-FIND(FIRST buf_Spec NO-LOCK WHERE
                               buf_Spec.Host-Code     = iTmp-Host-Code
                           AND buf_Spec.Contract-Num  = iTmp-Contract-Num
                        ).
   END. ELSE DO:
         lRet = CAN-FIND(FIRST buf_Spec NO-LOCK WHERE
                               buf_Spec.Host-Code     = iTmp-Host-Code
                           AND buf_Spec.Contract-Num  = iTmp-Contract-Num
                           AND buf_Spec.Gds-Code      = iGds-Code
                         ).
   END.
   RETURN (lRet).
END FUNCTION.
PROCEDURE MS-Contract-EXTENT-3:
   DEFINE INPUT  PARAMETER i-Host-Code     AS INTEGER NO-UNDO.
   DEFINE INPUT  PARAMETER i-Contract-Code AS INTEGER NO-UNDO.
   DEFINE OUTPUT PARAMETER i-Ret           AS INTEGER NO-UNDO EXTENT 3 INITIAL 0.
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-Classif.
   DEFINE BUFFER buf_Cont        FOR ub.Contract.
   DEFINE BUFFER buf_Cont-2      FOR ub.Contract.
   FIND FIRST buf_Cont-2 WHERE
              buf_Cont-2.Host-Code      = i-Host-Code
          AND buf_Cont-2.Contract-Code  = i-Contract-Code
        NO-LOCK NO-ERROR.
   IF NOT AVAILABLE buf_Cont-2 THEN DO:
      RETURN.
   END.
   FOR FIRST buf_Ext-Classif WHERE
             buf_Ext-Classif.Classif-name = v-S_CONTRACT
        AND  buf_Ext-Classif.CharKey_One  = STRING(i-Host-code) + v-DELIM_CHR_3 +
                                            STRING(i-Contract-code)
        AND  buf_Ext-classif.db-num       = buf_Cont-2.Db-num
       NO-LOCK,
       EACH buf_Cont WHERE
            buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3 ))
        AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
       NO-LOCK:
       ASSIGN
          i-Ret[1] = 1
          i-Ret[2] = buf_Cont.Host-code
          i-Ret[3] = buf_Cont.Contract-code
          .
       LEAVE.
   END.
   IF i-Ret[1] <> 1 THEN DO:
      FOR FIRST buf_Ext-Classif WHERE
                buf_Ext-Classif.Classif-name = v-S_CONTRACT
           AND  buf_Ext-Classif.CharKey_Two  = STRING(i-Host-code) + v-DELIM_CHR_3 +
                                               STRING(i-Contract-code)
           AND  buf_Ext-classif.db-num       = buf_Cont-2.Db-num
          NO-LOCK,
          EACH buf_Cont WHERE
               buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
           AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
          NO-LOCK:
          ASSIGN
             i-Ret[1] = 2
             i-Ret[2] = buf_Cont.Host-code
             i-Ret[3] = buf_Cont.Contract-code
             .
          LEAVE.
      END.
   END.
   RETURN.
END PROCEDURE.
define  buffer buf_ord-doc    for ub.ord-doc.
define  buffer t-doc-rcv      for ub.ord-doc-rcv .
define  buffer t-ord-doc-rcv  for ub.ord-doc-rcv.
define  buffer t-doc-line     for ub.ord-line.
define  buffer t-doc-line-rcv for ub.ord-line-rcv.
define  buffer t-trn-line     for ub.doc-line.
define  buffer t-trn-doc      for ub.trn-doc.
define  buffer obj_clients     for ub.clients .
define  buffer cli_clients     for ub.clients .
define  buffer buf_ord-doc-rcv for ub.ord-doc-rcv  .
define  buffer buf_trn-doc     for ub.trn-doc .
define  buffer buf_doc-line    for ub.doc-line .
define  buffer buf_ord-line    for ub.ord-line .
define temp-table temp-obj-list no-undo
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
index pi obj-type obj-code
.
define variable v-num-chip as character no-undo .
define variable sum-ord like ub.ord-line.qnty no-undo .
define variable sum-rcv like ub.ord-line.qnty no-undo .
define variable sum-trn like ub.ord-line.qnty no-undo .
define variable old-state like ub.ord-doc.status_ no-undo .
define variable old-flag like ub.ord-doc.flag_ no-undo .
define stream   errStream  .
define variable v-flaf-n as logical   no-undo .
define variable g#log  as logical   no-undo .
define variable v-Ok as logical   no-undo .
define variable v-mess as character no-undo .
define variable v-event-code as character no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output to-day
  )  .
 find first buf_ord-doc where recid (buf_ord-doc) = p-rec exclusive-lock no-error.
 if error-status :error then return error 'не найден заказ'.
 assign
  old-state = buf_ord-doc.status_
  old-flag  = buf_ord-doc.flag_
  .
  if buf_ord-doc.ship-date = ? then do:
     if p-ask then
      message "Не задана дата заказа ! "
              skip
              "Документ" buf_ord-doc.doc-code skip
              view-as alert-box error .
      return error.
  end.
  define variable t-date  as date      no-undo .
  define variable t-time  as integer   no-undo .
  run cur-time in this-procedure (output  t-date , output  t-time ).
  if buf_ord-doc.date-sale-1 > buf_ord-doc.date-sale-2 then do:
     if p-ask then
        message "Не верно задан интервал продаж !  "
                skip
                "Документ" buf_ord-doc.doc-code skip
                view-as alert-box error .
      return error.
  end.
define buffer bf_contract-specif for ub.contract-specif  .
      if buf_ord-doc.contract-code > 0 then do:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  buf_ord-doc.host-code,
    INPUT  buf_ord-doc.contract-code,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = buf_ord-doc.host-code
      i-gl-Contract-Code  = buf_ord-doc.contract-code
      .
END.
    FIND FIRST bf_contract-specif
           NO-LOCK
           WHERE
               bf_contract-specif.Host-code    = i-gl-Host-Code
           AND bf_contract-specif.Contract-num = i-gl-Contract-Code
           NO-ERROR
           .
          if available bf_contract-specif then do:
             for each ub.ord-line no-lock where
                      ub.ord-line.doc-code = buf_ord-doc.doc-code :
                if not
                Can-Find-Spec  (buf_ord-doc.host-code,
                                buf_ord-doc.contract-code ,
                                ub.ord-line.gds-code)
                then do:
                                          if p-ask then
                                          message
                                            "Выбран Договор со спецификацией !!!" skip
                                            "Несоответствие списка товаров заказа и спецификации " skip
                                            "Заказ      :" buf_ord-doc.doc-code        skip
                                            "код товара :" ub.ord-line.gds-code skip
                                            "артикл     :" ub.ord-line.artic skip
                                            view-as alert-box error .
                                            return error.
                                       end.
             end.
          end.
      end.
     if buf_ord-doc.status_ = 'новый':U
       then do:
        for each ub.ord-line no-lock where
           ub.ord-line.doc-code = buf_ord-doc.doc-code :
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run goassizt in g#library2
  (input  buf_ord-doc.doc-type
  ,input  ub.ord-line.gds-code
  ,input  buf_ord-doc.obj-type
  ,input  buf_ord-doc.obj-code
  ,input  false
  ,output v-Ok
  ,output v-mess
  ) no-error.
            if v-Ok = false then do:
              if p-ask then
              message
                v-mess skip
                "Товар не может быть включен в заказ " skip
                "Заказ      :" buf_ord-doc.doc-code        skip
                "код товара :" ub.ord-line.gds-code skip
                "артикул    :" ub.ord-line.artic skip
                view-as alert-box error .
                return error substitute("izt &1" ,v-mess ) .
            end.
            v-event-code = substitute("cli_&1",buf_ord-doc.doc-type) .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run goassizt in g#library2
  (input  v-event-code
  ,input  ub.ord-line.gds-code
  ,input  buf_ord-doc.cli-type
  ,input  buf_ord-doc.cli-code
  ,input  false
  ,output v-ok
  ,output v-mess
  ) no-error.
              if v-ok = false then do:
                if p-ask then
                message
                  v-mess skip
                  "Товар не может быть включен в заказ " skip
                  "Заказ      :" buf_ord-doc.doc-code        skip
                  "код товара :" ub.ord-line.gds-code skip
                  "артикул    :" ub.ord-line.artic skip
                  view-as alert-box error .
                  return error substitute("izt &1" ,v-mess ) .
              end.
        end.
  end.
define variable o-host-code as integer   no-undo .
define variable c-host-code as integer   no-undo .
define variable o-base-code as integer   no-undo .
define variable c-base-code as integer   no-undo .
define variable v-find      as logical   no-undo .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_ord-doc.obj-type
  ,input  buf_ord-doc.obj-code
  ,output o-host-code
  )  .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_ord-doc.cli-type
  ,input  buf_ord-doc.cli-code
  ,output c-host-code
  )  .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  o-host-code
  ,output o-base-code
  )  .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  c-host-code
  ,output c-base-code
  )  .
if o-base-code <> c-base-code then do:
  if p-ask then
  message "Контрагенты имеют разную базовую валюту. Создание заказа не возможно ! " view-as alert-box error .
  return error.
end.
 case buf_ord-doc.status_ :
      when 'отказ':U then do:
      if p-ask then
        message
          "Нельзя закрыть заказ"
          "в статусе " caps(buf_ord-doc.status_)
          skip
          "Документ" buf_ord-doc.doc-code view-as alert-box information
          .
        return .
      end.
      when 'новый':U then do:
              if can-find
                ( first   t-doc-line no-lock where t-doc-line.doc-code  = buf_ord-doc.doc-code    and
                        ( t-doc-line.qnty  =  0 or t-doc-line.qnty  = ?)) then do:
                  if p-ask then
                      Message "В заказе есть строки с количеством равным 0 или ? ! "
                              skip
                              "Документ" buf_ord-doc.doc-code skip
                              view-as alert-box error .
                  return error.
              end.
              if buf_ord-doc.ship-date < t-date then do:
                  g#log  = false .
                  if p-ask then
                      Message "Дата заказа меньше текущей даты ! " skip
                          string(buf_ord-doc.ship-date, "99/99/9999" ) skip
                          "Сегодня" string(t-date, "99/99/9999" )
                          skip
                          "Документ" buf_ord-doc.doc-code skip
                          " Будем закрывать ? "
                          view-as alert-box question
                          buttons yes-no
                          title "Закрыть заказ "
                          update g#log
                        .
                  if not g#log then return.
              end.
              find first  t-doc-line where t-doc-line.doc-code  = buf_ord-doc.doc-code no-lock no-error .
              if not available t-doc-line then do:
                  if p-ask then
                  message "Заказ"  buf_ord-doc.doc-code  " не содержит ни одной записи ! "
                          view-as alert-box information  title "Внимание!!! " .
                  return.
               end.
              for each buf_ord-line exclusive-lock where buf_ord-line.doc-code = buf_ord-doc.doc-code :
                  buf_ord-line.order-qnty =  buf_ord-line.qnty .
              end.
              assign
                  buf_ord-doc.status_ = 'запрос':U
                  buf_ord-doc.flag_ = true
                  .
              return.
        end.
       when 'запрос':U then do :
        find first obj_clients no-lock where
                   obj_clients.obj-type = buf_ord-doc.obj-type and
                   obj_clients.obj-code = buf_ord-doc.obj-code no-error .
        find first cli_clients no-lock where
                   cli_clients.obj-type = buf_ord-doc.cli-type and
                   cli_clients.obj-code = buf_ord-doc.cli-code no-error .
         if obj_clients.db-num = v-cntxt-db-num  and obj_clients.db-num <> cli_clients.db-num then do:
                  if p-ask then
                  message "Заказ передан на сторону контрагента. Перевод в другой статус невозможен" .
                  return.
         end.
         v-find = false .
         v-flaf-n = true .
          for each buf_ord-doc-rcv no-lock where buf_ord-doc-rcv.doc-code = buf_ord-doc.doc-code ,
              each ub.ord-chain no-lock where
                   ub.ord-chain.doc-code = buf_ord-doc-rcv.rcv-code and
                   ub.ord-chain.doc-type = 'rcv'                    and
                   ub.ord-chain.rel-doc-type = 'trn' ,
              first buf_trn-doc     no-lock where buf_trn-doc.doc-code = ub.ord-chain.rel-doc-code :
                for each buf_ord-line no-lock where buf_ord-line.doc-code = buf_ord-doc.doc-code :
                    find first buf_doc-line no-lock where
                          buf_doc-line.doc-code  = buf_trn-doc.doc-code and
                          buf_doc-line.artic     = buf_ord-line.artic      and
                          buf_doc-line.prod-type = buf_ord-line.prod-type  and
                          buf_doc-line.prod-code = buf_ord-line.prod-code
                    no-error .
                    if not available buf_doc-line then v-flaf-n = false .
                    else do:
                        if buf_doc-line.fact-qnty <> buf_ord-line.qnty then  v-flaf-n = false .
                    end.
                end.
                v-find = true  .
                leave.
          end.
          if v-find = true then
            assign
                buf_ord-doc.status_ = 'разрешено':U
                buf_ord-doc.flag_ = v-flaf-n
                .
          else do:
                if p-ask then
                   message "Расходная Накладная не создана !!!" view-as alert-box information .
                   return.
          end.
          return .
        end.
       when 'разрешено':U then do :
            find first obj_clients no-lock where
                      obj_clients.obj-type = buf_ord-doc.obj-type and
                      obj_clients.obj-code = buf_ord-doc.obj-code no-error .
            find first cli_clients no-lock where
                      cli_clients.obj-type = buf_ord-doc.cli-type and
                      cli_clients.obj-code = buf_ord-doc.cli-code no-error .
            if obj_clients.db-num = v-cntxt-db-num and obj_clients.db-num <> cli_clients.db-num then do:
                      if p-ask then
                        message "Заказ передан на сторону контрагента. Перевод в другой статус невозможен"  .
                return.
            end.
         define variable v-find2 as logical   no-undo .
         v-find2 = false .
          for each  buf_ord-doc-rcv no-lock where
                    buf_ord-doc-rcv.doc-code = buf_ord-doc.doc-code ,
              each ub.ord-chain no-lock where
                   ub.ord-chain.doc-code = buf_ord-doc-rcv.rcv-code and
                   ub.ord-chain.doc-type = 'rcv'                    and
                   ub.ord-chain.rel-doc-type = 'trn' ,
              first buf_trn-doc     no-lock where
                    buf_trn-doc.doc-code = ub.ord-chain.rel-doc-code and
                    buf_trn-doc.status_ = 'факт':U
                    :
              v-find2 = true  .
              leave.
           end.
          if v-find2  = true then do:
             v-find   = false .
             v-flaf-n = true  .
                for each buf_ord-doc-rcv no-lock where buf_ord-doc-rcv.doc-code = buf_ord-doc.doc-code ,
                    each ub.ord-chain no-lock where
                        ub.ord-chain.doc-code = buf_ord-doc-rcv.rcv-code and
                        ub.ord-chain.doc-type = 'rcv'                    and
                        ub.ord-chain.rel-doc-type = 'trn' ,
                    first buf_trn-doc     no-lock where buf_trn-doc.doc-code = ub.ord-chain.rel-doc-code and
                                                        buf_trn-doc.status_ = 'факт':U
                    :
                      for each buf_ord-line no-lock where buf_ord-line.doc-code = buf_ord-doc.doc-code :
                          find first buf_doc-line no-lock where
                                buf_doc-line.doc-code  = buf_trn-doc.doc-code and
                                buf_doc-line.artic     = buf_ord-line.artic      and
                                buf_doc-line.prod-type = buf_ord-line.prod-type  and
                                buf_doc-line.prod-code = buf_ord-line.prod-code
                          no-error .
                          if not available buf_doc-line then v-flaf-n = false .
                          else do:
                              if buf_doc-line.fact-qnty <> buf_ord-line.qnty then  v-flaf-n = false .
                          end.
                      end.
                      v-find = true  .
                      leave.
                end.
            assign
                buf_ord-doc.status_ = 'отгружено':U
                buf_ord-doc.flag_ = v-flaf-n
                .
          end.
          else do:
                if p-ask then
                   message "Приходная Накладная не создана !!!" view-as alert-box information .
                   return.
          end.
          return .
        end.
       when 'отгружено':U then do :
            for each t-ord-doc-rcv where  t-ord-doc-rcv.doc-code = buf_ord-doc.doc-code no-lock :
                for each ub.ord-chain no-lock where
                   ub.ord-chain.doc-code = t-ord-doc-rcv.rcv-code and
                   ub.ord-chain.doc-type = 'rcv'                    and
                   ub.ord-chain.rel-doc-type = 'trn' :
                 for each t-trn-doc no-lock where
                          t-trn-doc.doc-code  = ub.ord-chain.rel-doc-code and
                          t-trn-doc.doc-type  = 'при':U and
                          t-trn-doc.status_  <> 'факт':U  :
                  if p-ask then
                  message "Документ ПН" t-trn-doc.doc-code " имеет статус " CAPS(t-trn-doc.status_)
                          "Закройте ПН до статуса ФАКТ " view-as alert-box error
                          title "Закрыть заказ "
                          .
                  return error.
                 end.
            end.
            end.
            for each t-ord-doc-rcv where  t-ord-doc-rcv.doc-code = buf_ord-doc.doc-code no-lock :
                for each ub.ord-chain no-lock where
                   ub.ord-chain.doc-code = t-ord-doc-rcv.rcv-code and
                   ub.ord-chain.doc-type = 'rcv'                    and
                   ub.ord-chain.rel-doc-type = 'trn' :
                 for each t-trn-doc no-lock where
                          t-trn-doc.doc-code  = ub.ord-chain.rel-doc-code and
                          t-trn-doc.doc-type  = 'рас':U and
                          t-trn-doc.status_  <> 'факт':U  :
                  if p-ask then
                  message "Документ РН" t-trn-doc.doc-code " имеет статус " CAPS(t-trn-doc.status_)
                          "Закройте РН до статуса ФАКТ (создайте ПН) " view-as alert-box error
                          title "Закрыть заказ "
                          .
                  return error.
                 end.
            end.
            end.
            v-flaf-n = true .
            for each t-ord-doc-rcv where  t-ord-doc-rcv.doc-code = buf_ord-doc.doc-code no-lock :
                for each ub.ord-chain no-lock where
                   ub.ord-chain.doc-code = t-ord-doc-rcv.rcv-code and
                   ub.ord-chain.doc-type = 'rcv'                    and
                   ub.ord-chain.rel-doc-type = 'trn' :
                 for each t-trn-doc no-lock where
                          t-trn-doc.doc-code  = ub.ord-chain.rel-doc-code and
                          t-trn-doc.doc-type  = 'при':U and
                          t-trn-doc.status_  = 'факт':U  :
                    for each buf_ord-line no-lock where buf_ord-line.doc-code = buf_ord-doc.doc-code :
                        find first buf_doc-line no-lock where
                                   buf_doc-line.doc-code  = t-trn-doc.doc-code and
                                   buf_doc-line.artic     = buf_ord-line.artic      and
                                   buf_doc-line.prod-type = buf_ord-line.prod-type  and
                                   buf_doc-line.prod-code = buf_ord-line.prod-code
                                   no-error .
                        if not available buf_doc-line then v-flaf-n = false .
                        else do:
                            if buf_doc-line.fact-qnty <> buf_ord-line.qnty then  v-flaf-n = false .
                        end.
                    end.
                 end.
              end.
            end.
            assign
              buf_ord-doc.status_ = 'факт':U
              buf_ord-doc.flag_   = v-flaf-n
              buf_ord-doc.fact-date = to-day.
            .
            for each t-ord-doc-rcv   exclusive-lock  where  t-ord-doc-rcv.doc-code = buf_ord-doc.doc-code :
                assign
                  t-ord-doc-rcv.status_   = 'факт':U
                  t-ord-doc-rcv.fact-date = to-day
                .
            end.
          return .
        end.
 end case.
