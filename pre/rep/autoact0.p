block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo.
define input parameter rec_id        as recid         no-undo.
define input parameter p-mode        as character     no-undo.
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U.
define variable vss-author      as character no-undo initial "$Author: expertek $":U.
define variable vss-date        as character no-undo initial "$date: 12.09.03 15:57 $":U.
define variable vss-workfile    as character no-undo initial "$Workfile: autoact0.p $":U.
define variable vss-archive     as character no-undo initial "$Archive: rep/autoact0.p $":U.
define variable vss-description as character no-undo initial "Печать акта автоматической переоценки (весовой учет топлива)".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
FUNCTION RedLine RETURNS CHARACTER ( INPUT i-str AS CHARACTER ) :
  DEFINE VARIABLE v-str AS CHARACTER NO-UNDO.
  RUN get-red-line IN THIS-PROCEDURE ( INPUT i-str, OUTPUT v-str ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN i-str ELSE v-str ).
END FUNCTION.
PROCEDURE get-red-line :
  DEFINE  INPUT PARAMETER p-str AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-res AS CHARACTER NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-res = CAPS( SUBSTRING( p-str, 1, 1 ) ) + LC( SUBSTRING( p-str, 2 ) ).
  END.
END PROCEDURE.
FUNCTION Roubles RETURNS CHARACTER ( INPUT i-sum AS DECIMAL ) :
  DEFINE VARIABLE Rouble AS CHARACTER NO-UNDO.
  RUN get-roubles IN THIS-PROCEDURE ( INPUT i-sum, OUTPUT Rouble ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN "":U ELSE Rouble ).
END FUNCTION.
PROCEDURE get-roubles :
  DEFINE  INPUT PARAMETER p-sum AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-rub AS CHARACTER NO-UNDO.
  DEFINE VARIABLE Word   AS CHARACTER NO-UNDO.
  DEFINE VARIABLE jj     AS INTEGER   NO-UNDO.
  DEFINE VARIABLE j_last AS INTEGER   NO-UNDO.
  DEFINE VARIABLE l_prev AS LOGICAL   NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN Word   = STRING( ABS( p-sum ), "999999999999999999999999999999.99":U )
           jj     = LENGTH( Word )
           j_last = INTEGER( SUBSTRING( Word, jj - 3, 1 ) )
           l_prev =        ( SUBSTRING( Word, jj - 4, 1 ) = "1" ).
    IF      j_last = 1                THEN DO: ASSIGN p-rub = ( IF l_prev = YES THEN "рублей" ELSE "рубль" ).  END.
    ELSE IF j_last > 1 AND j_last < 5 THEN DO: ASSIGN p-rub = ( IF l_prev = YES THEN "рублей" ELSE "рубля" ). END.
                                      ELSE DO: ASSIGN p-rub = "рублей". END.
  END.
END PROCEDURE.
FUNCTION Copecks RETURNS CHARACTER ( INPUT i-sum AS DECIMAL ) :
  DEFINE VARIABLE Copeck AS CHARACTER NO-UNDO.
  RUN get-copecks IN THIS-PROCEDURE ( INPUT i-sum, OUTPUT Copeck ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN "":U ELSE Copeck ).
END FUNCTION.
PROCEDURE get-copecks :
  DEFINE  INPUT PARAMETER p-sum AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-kop AS CHARACTER NO-UNDO.
  DEFINE VARIABLE Word   AS CHARACTER NO-UNDO.
  DEFINE VARIABLE jj     AS INTEGER   NO-UNDO.
  DEFINE VARIABLE j_last AS INTEGER   NO-UNDO.
  DEFINE VARIABLE l_prev AS LOGICAL   NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN  Word   = STRING( ABS( p-sum ), "999999999999999999999999999999.99":U )
            jj     = LENGTH( Word )
            j_last = INTEGER( SUBSTRING( Word, jj,     1 ) )
            l_prev =        ( SUBSTRING( Word, jj - 1, 1 ) = "1" ).
    IF           j_last = 1                THEN DO:
      ASSIGN p-kop = ( IF l_prev = YES THEN "копеек" ELSE "копейка" ).
    END. ELSE IF j_last > 1 AND j_last < 5 THEN DO:
      ASSIGN p-kop = ( IF l_prev = YES THEN "копеек" ELSE "копейки" ).
    END.                                   ELSE DO:
      ASSIGN p-kop = "копеек".
    END.
  END.
END PROCEDURE.
FUNCTION get-decade-word RETURNS CHARACTER ( INPUT i-dec AS INTEGER, INPUT i-num AS INTEGER ) :
  DEFINE VARIABLE v-grade AS CHARACTER NO-UNDO.
  RUN get-number-grade IN THIS-PROCEDURE ( INPUT i-dec, INPUT i-num, OUTPUT v-grade ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN "":U ELSE v-grade ).
END FUNCTION.
FUNCTION Word-Sum RETURNS CHARACTER ( INPUT i-sum AS DECIMAL ) :
  DEFINE VARIABLE OutSum AS CHARACTER NO-UNDO.
  RUN conv-sum-to-word IN THIS-PROCEDURE ( INPUT i-sum, OUTPUT OutSum ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE OutSum ).
END FUNCTION.
PROCEDURE get-number-grade :
  DEFINE  INPUT PARAMETER p-dec AS INTEGER   NO-UNDO.
  DEFINE  INPUT PARAMETER p-num AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-res AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-list AS CHARACTER NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    IF      p-dec = 1 THEN DO: ASSIGN v-list = ",один,два,три,четыре,пять,шесть,семь,восемь,девять".    END.
    ELSE IF p-dec = 2 THEN DO: ASSIGN v-list = "десять,одиннадцать,двенадцать,тринадцать,четырнадцать,пятнадцать,шестнадцать,семнадцать,восемнадцать,девятнадцать".    END.
    ELSE IF p-dec = 3 THEN DO: ASSIGN v-list = ",,двадцать,тридцать,сорок,пятьдесят,шестьдесят,семьдесят,восемьдесят,девяносто".   END.
    ELSE IF p-dec = 4 THEN DO: ASSIGN v-list = ",сто,двести,триста,четыреста,пятьсот,шестьсот,семьсот,восемьсот,девятьсот".  END.
                      ELSE DO: ASSIGN v-list = ",,,,,,,,,". END.
    ASSIGN p-res = ENTRY( p-num + 1, v-list ).
  END.
END PROCEDURE.
PROCEDURE conv-sum-to-word :
  DEFINE  INPUT PARAMETER p-sum AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-res AS CHARACTER NO-UNDO.
  DEFINE VARIABLE Formatted  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE Word       AS CHARACTER NO-UNDO.
  DEFINE VARIABLE OutSum     AS CHARACTER NO-UNDO.
  DEFINE VARIABLE jj         AS INTEGER   NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN Formatted = STRING( ABS( p-sum ), "999999999999999.99":U ) NO-ERROR.
    IF ERROR-STATUS :ERROR THEN DO:
      ASSIGN p-res = ?.
      UNDO, RETURN ERROR.
    END.
    DO jj = ( LENGTH( Formatted ) - 3 ) TO 3 BY -3 :
      IF SUBSTRING( Formatted, jj - 2, 3 ) = "000" THEN DO: NEXT. END.
      IF jj < 15 THEN DO:
        ASSIGN Word = ENTRY( jj, ",,триллион,,,миллиард,,,миллион,,,тысяч" ).
        IF SUBSTRING( Formatted, jj,     1 )  = "1" AND
           SUBSTRING( Formatted, jj - 1, 1 ) <> "1" AND jj = 12 THEN DO: ASSIGN Word = TRIM( Word ) + "а". END.
        IF SUBSTRING( Formatted, jj, 1 ) = "2" OR
           SUBSTRING( Formatted, jj, 1 ) = "3" OR
           SUBSTRING( Formatted, jj, 1 ) = "4" THEN DO:
          IF jj = 12 THEN DO:
            IF SUBSTRING( Formatted, jj - 1, 1 ) <> "1" THEN DO: ASSIGN Word = TRIM( Word ) + "и". END.
          END.       ELSE DO:
            IF SUBSTRING( Formatted, jj - 1, 1 ) <> "1" THEN DO: ASSIGN Word = TRIM( Word ) + "а". END.
          END.
        END.
        IF ( SUBSTRING( Formatted, jj,     1 ) <> "1" AND
             SUBSTRING( Formatted, jj,     1 ) <> "2" AND
             SUBSTRING( Formatted, jj,     1 ) <> "3" AND
             SUBSTRING( Formatted, jj,     1 ) <> "4" AND jj <> 12 ) OR
           ( SUBSTRING( Formatted, jj - 1, 1 )  = "1" AND jj <  12 ) THEN DO: ASSIGN Word = TRIM( Word ) + "ов". END.
        IF Word <> "":U THEN DO: ASSIGN OutSum = TRIM( Word ) + " ":U + TRIM( OutSum ). END.
      END.
      IF SUBSTRING( Formatted, jj - 1, 1 ) <> "1" THEN DO:
        IF      jj = 12 AND SUBSTRING( Formatted, jj, 1 ) = "1" THEN DO: ASSIGN Word = "одна". END.
        ELSE IF jj = 12 AND SUBSTRING( Formatted, jj, 1 ) = "2" THEN DO: ASSIGN Word = "две".  END.
        ELSE DO: ASSIGN Word = get-decade-word( 1, INTEGER( SUBSTRING( Formatted, jj, 1 ) ) ). END.
        IF Word <> "":U THEN DO: ASSIGN OutSum = TRIM( Word ) + " ":U + TRIM( OutSum ). END.
        ASSIGN Word = get-decade-word( 3, INTEGER( SUBSTRING( Formatted, jj - 1, 1 ) ) ).
      END.                                        ELSE DO:
        ASSIGN Word = get-decade-word( 2, INTEGER( SUBSTRING( Formatted, jj,     1 ) ) ).
      END.
      IF Word <> "":U THEN DO: ASSIGN OutSum = TRIM( Word ) + " ":U + TRIM( OutSum ). END.
      ASSIGN Word = get-decade-word( 4, INTEGER( SUBSTRING( Formatted, jj - 2, 1 ) ) ).
      IF Word <> "":U THEN DO: ASSIGN OutSum = TRIM( Word ) + " ":U + TRIM( OutSum ). END.
    END.
    ASSIGN OutSum = CAPS( SUBSTRING( OutSum, 1, 1 ) ) + SUBSTRING( OutSum, 2 ).
    IF OutSum = "":U AND TRUNCATE( p-sum, 0 ) = 0 THEN DO: ASSIGN OutSum = "Ноль". END.
    ASSIGN p-res = TRIM( OutSum ).
  END.
END PROCEDURE.
FUNCTION Total-Word RETURNS CHARACTER ( INPUT i-sum AS DECIMAL, INPUT i-curr AS CHARACTER, INPUT i-part AS CHARACTER ) :
  DEFINE VARIABLE word_sum AS CHARACTER NO-UNDO.
  RUN get-total-word IN THIS-PROCEDURE ( INPUT i-sum, INPUT i-curr, INPUT i-part, OUTPUT word_sum ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE word_sum ).
END FUNCTION.
PROCEDURE get-total-word :
  DEFINE  INPUT PARAMETER p-sum  AS DECIMAL   NO-UNDO.
  DEFINE  INPUT PARAMETER p-curr AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-part AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-word AS CHARACTER NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-word = Word-Sum( p-sum ).
               ASSIGN p-word = ( IF p-sum < 0 THEN "- " ELSE "":U ) + TRIM(
                      RedLine( p-word )
               ) +
                      " ":U + p-curr + " ":U +
                      SUBSTRING( STRING( ABS( p-sum ), "999999999999999999999999999999.99" ), 32, 2 ) +
                      " ":U + p-part + ".".
                        END.
END PROCEDURE.
    if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end.
      function invlnsum_sale-price returns decimal ( input p-doc-code   as character,
                                                       input p-artic      as character,
                                                       input p-prod-type  as character,
                                                       input p-prod-code  as integer,
                                                       input p-print-rubl as logical    ) :
        define variable d_out-kg-sale-price as decimal no-undo initial ?.
        if valid-handle( g#lib-trn3 ) = yes then do on error undo, return error :
          run lib-trn3_invlnprc in g#lib-trn3 (
                                                 input p-doc-code
                                              ,  input p-artic
                                              ,  input p-prod-type
                                              ,  input p-prod-code
                                              ,  input "sale"
                                              ,  input p-print-rubl
                                              , output d_out-kg-sale-price
                                              ) .
          return ( if error-status :error then ? else d_out-kg-sale-price ).
        end.
      end function.
      function invlnsum_cli-qnty returns decimal ( input p-doc-code  as character,
                                                       input p-artic     as character,
                                                       input p-prod-type as character,
                                                       input p-prod-code as integer     ) :
        define variable d_out-qnty-kg as decimal no-undo initial ?.
                if valid-handle( g#lib-trn3 ) = yes then do on error undo, return error :
          run lib-trn3_invlnqty in g#lib-trn3 (
                                                 input p-doc-code
                                              ,  input p-artic
                                              ,  input p-prod-type
                                              ,  input p-prod-code
                                              ,  input no
                                              , output d_out-qnty-kg
        ) .
          return ( if error-status :error then ? else d_out-qnty-kg ).
        end.
      end function.
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
  define variable v-cntxp-doc-prt         like ub.store.doc-prt         no-undo.
  define variable v-cntxp-price-calc      like ub.store.price-calc      no-undo.
  define variable v-cntxp-inout-price     like ub.store.inout-price     no-undo.
  define variable v-cntxp-unit-cli-perm   like ub.store.unit-cli-perm   no-undo.
  define variable v-cntxp-out-rate        like ub.store.out-rate        no-undo.
  define variable v-cntxp-out-line-discnt like ub.store.out-line-discnt no-undo.
  define variable v-cntxp-in-ov           like ub.store.in-ov           no-undo.
  define variable v-cntxp-in-perm         like ub.store.in-perm         no-undo.
  define variable v-cntxp-no-eq           like ub.store.no-eq           no-undo.
  define variable v-cntxp-rsrv-time       like ub.store.rsrv-time       no-undo.
  define variable v-cntxp-load-time       like ub.store.load-time       no-undo.
  define variable v-cntxp-holidays        like ub.store.holidays        no-undo.
  define variable v-cntxp-in-pay          like ub.store.in-pay          no-undo.
  define variable v-cntxp-out-pay         like ub.store.out-pay         no-undo.
  define variable v-cntxp-ret-pay         like ub.store.ret-pay         no-undo.
  define variable v-cntxp-ret-sup-pay     like ub.store.ret-sup-pay     no-undo.
  define variable v-cntxp-down-pay        like ub.store.down-pay        no-undo.
  define variable v-cntxp-inv-pay         like ub.store.inv-pay         no-undo.
  define variable v-cntxp-chk-pay         like ub.store.chk-pay         no-undo.
  define variable v-cntxp-retail          like ub.sysconf.ord-prt       no-undo.
  define variable v-cntxp-osn-base        like ub.sysconf.osn-base      no-undo.
  define variable v-cntxp-conf-par        as   character                no-undo.
  define variable v-cntxp-par-type        as   character                no-undo.
  define variable v-cntxp-curr-host-code  like ub.store.host-code       no-undo.
  define variable v-cntxp-obj-type        like ub.clients.obj-type      no-undo.
  define variable v-cntxp-obj-code        like ub.clients.obj-code      no-undo.
  define variable v-cntxp-db-num          as integer   no-undo .
  define variable v-cntxp-userid          as character no-undo .
  define variable v-cntxp-level           as character no-undo .
  define variable v-cntxp-db-num-obj      as integer   no-undo .
  define variable v-cntxp-is-admin        as logical   no-undo .
  define buffer bf-cntxp_store for ub.store.
  define buffer bf-cntxp_shop  for ub.shop.
  define buffer bf-cntxp_sysconf for ub.sysconf.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxp-db-num
    ,output v-cntxp-userid
    ,output v-cntxp-level
    ,output v-cntxp-curr-host-code
    ,output v-cntxp-obj-type
    ,output v-cntxp-obj-code
    ,output v-cntxp-db-num-obj
    ,output v-cntxp-is-admin
    ) .
  if (v-cntxp-obj-type = 'маг':U or v-cntxp-obj-type = 'скл':U) and
     v-cntxp-obj-code <> 0 then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-prt'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  yes
  ,output v-cntxp-conf-par
  ,output v-cntxp-par-type
  ) no-error .
    case v-cntxp-obj-type :
      when 'скл':U then do:
        find first bf-cntxp_store where bf-cntxp_store.obj-code = v-cntxp-obj-code no-lock.
        find first bf-cntxp_sysconf where bf-cntxp_sysconf.host-code = bf-cntxp_store.host-code no-lock.
        assign
          v-cntxp-doc-prt         = (v-cntxp-conf-par = "yes") and bf-cntxp_store.doc-prt
          v-cntxp-price-calc      = bf-cntxp_store.price-calc
          v-cntxp-inout-price     = bf-cntxp_store.inout-price
          v-cntxp-unit-cli-perm   = bf-cntxp_store.unit-cli-perm
          v-cntxp-out-rate        = bf-cntxp_store.out-rate
          v-cntxp-out-line-discnt = bf-cntxp_store.out-line-discnt
          v-cntxp-in-ov           = bf-cntxp_store.in-ov
          v-cntxp-in-perm         = bf-cntxp_store.in-perm
          v-cntxp-no-eq           = bf-cntxp_store.no-eq
          v-cntxp-rsrv-time       = bf-cntxp_store.rsrv-time
          v-cntxp-load-time       = bf-cntxp_store.load-time
          v-cntxp-holidays        = bf-cntxp_store.holidays
          v-cntxp-in-pay          = bf-cntxp_store.in-pay
          v-cntxp-out-pay         = bf-cntxp_store.out-pay
          v-cntxp-ret-pay         = bf-cntxp_store.ret-pay
          v-cntxp-ret-sup-pay     = bf-cntxp_store.ret-sup-pay
          v-cntxp-down-pay        = bf-cntxp_store.down-pay
          v-cntxp-inv-pay         = bf-cntxp_store.inv-pay
          v-cntxp-chk-pay         = bf-cntxp_store.chk-pay
          v-cntxp-retail          = bf-cntxp_sysconf.ord-prt
          v-cntxp-osn-base        = bf-cntxp_sysconf.osn-base
          .
      end.
      when 'маг':U then do:
        find first bf-cntxp_shop where bf-cntxp_shop.obj-code = v-cntxp-obj-code no-lock.
        find first bf-cntxp_sysconf where bf-cntxp_sysconf.host-code = bf-cntxp_shop.host-code no-lock.
        assign
          v-cntxp-doc-prt         = (v-cntxp-conf-par = "yes") and bf-cntxp_shop.doc-prt
          v-cntxp-price-calc      = bf-cntxp_shop.price-calc
          v-cntxp-inout-price     = bf-cntxp_shop.inout-price
          v-cntxp-unit-cli-perm   = bf-cntxp_shop.unit-cli-perm
          v-cntxp-out-rate        = bf-cntxp_shop.out-rate
          v-cntxp-out-line-discnt = bf-cntxp_shop.out-line-discnt
          v-cntxp-in-ov           = bf-cntxp_shop.in-ov
          v-cntxp-in-perm         = bf-cntxp_shop.in-perm
          v-cntxp-no-eq           = bf-cntxp_shop.no-eq
          v-cntxp-rsrv-time       = bf-cntxp_shop.rsrv-time
          v-cntxp-load-time       = bf-cntxp_shop.load-time
          v-cntxp-holidays        = bf-cntxp_shop.holidays
          v-cntxp-in-pay          = bf-cntxp_shop.in-pay
          v-cntxp-out-pay         = bf-cntxp_shop.out-pay
          v-cntxp-ret-pay         = bf-cntxp_shop.ret-pay
          v-cntxp-ret-sup-pay     = bf-cntxp_shop.ret-sup-pay
          v-cntxp-down-pay        = bf-cntxp_shop.down-pay
          v-cntxp-inv-pay         = bf-cntxp_shop.inv-pay
          v-cntxp-chk-pay         = bf-cntxp_shop.chk-pay
          v-cntxp-retail          = bf-cntxp_sysconf.ord-prt
          v-cntxp-osn-base        = bf-cntxp_sysconf.osn-base
          .
      end.
    end case.
  end.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable g#report-num  as integer   no-undo.
define variable g#quest-print as logical   no-undo.
define variable g#log         as logical   no-undo.
define variable base-code     as integer   no-undo.
define variable base-type     as character no-undo.
define variable base-part     as character no-undo.
define variable v-cntxt-host-name-obj as character no-undo .
define buffer buf_rep_currency for ub.currency.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-cntxt-host-code-obj
  ,output v-cntxt-host-name-obj
  )  .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output base-code
  )  .
find first buf_rep_currency no-lock where
           buf_rep_currency.curr-code = base-code
           no-error .
  if available buf_rep_currency
    then do:
      assign
        base-type = buf_rep_currency.curr-abbr
        base-part = buf_rep_currency.part-abbr
      .
    end.
    else do:
      assign
        base-type = "б.в."
        base-part = ""
      .
    end.
run get-report-num  in parparentproc ( output g#report-num ).
run get-quest-print in parparentproc ( output g#quest-print ) .
define variable price-doc        as decimal   no-undo.
define variable doc-sum          as decimal   no-undo.
define variable obj-sum          as decimal   no-undo.
define variable propis           as character no-undo.
define variable abbr             as character no-undo.
define variable Delt             as character no-undo.
define variable v-single-line    as character no-undo.
define variable sym1             as character no-undo initial ":".
define variable sym2             as character no-undo initial ":".
define variable tb-code          as character no-undo.
define variable tdoc-date        as date      no-undo.
define variable tdoc-code        as character no-undo.
define variable v-nids           as character no-undo.
define variable v-parameter-type as character no-undo.
define variable v-rb-is-base     as logical   no-undo.
define variable is-petrol        as logical   no-undo.
define variable is-pieces        as logical   no-undo.
define variable d_qnty-kg        as decimal   no-undo.
define variable d_sale-price     as decimal   no-undo.
define variable d_sale-sum       as decimal   no-undo.
define variable d_obj-price      as decimal   no-undo.
define variable d_obj-sum        as decimal   no-undo.
define variable d_delta          as decimal   no-undo.
define variable d_cli-rate       as decimal   no-undo.
define variable total_qnty-kg    as decimal   no-undo.
define variable total_sale-sum   as decimal   no-undo.
define variable total_obj-sum    as decimal   no-undo.
define variable total_delta      as decimal   no-undo.
define variable total_percent    as decimal   no-undo.
define variable j_total          as integer   no-undo.
define variable print_rubl       as logical   no-undo.
define buffer t-doc    for ub.trn-doc.
define buffer Our_Host for ub.clients.
define stream s-out.
define frame PrintFrame_Act-base
  sym1                 column-label ":!:"                       format "x(1)":U space( 0 )
  tb-code              column-label "Код! "                     format "x(10)":U
  ub.gds-dtl.artic     column-label "Артикул! "                 format "x(16)":U
  ub.goods.gds-name    column-label "Название товара! "         format "x(30)":U
  ub.gds-dtl.fact-qnty column-label "Количество  ! "            format "->>>>>>9.<<<":U
  price-doc            column-label "Цена по!докум.(вал)"       format ">>>>>>9.99":U
  doc-sum              column-label "Сумма по!докум.(вал)"      format "->>>>>>>>9.99":U
  ub.gds-dtl.cur-base  column-label "Цена по!объекту(вал)"      format ">>>>>>9.99":U
  obj-sum              column-label "Сумма цен по!объекту(вал)" format "->>>>>>>>9.99":U
  Delt                 column-label "Процент!разницы"           format "x(8)":U
  sym2                 column-label ":!:"                       format "x(1)":U space( 0 )
header
  cur-time-print( )                                      at   5 format "x(35)":U
  string( "Акт автоматической переоценки по документу N " + tdoc-code + " от " +
  string( tdoc-date,"99/99/9999":U ) )                   at  40 format "x(80)":U
  string( "Страница " + string( page-number( s-out ) ) ) at 120 format "x(15)":U  skip
  v-single-line                                          at   1 format "x(136)":U
with width 235 down stream-io.
define frame PrintFrame_Act-rubl
  sym1                 column-label ":!:"                               format "x(1)":U space( 0 )
  tb-code              column-label "Код! "                             format "x(10)":U
  ub.gds-dtl.artic     column-label "Артикул! "                         format "x(16)":U
  ub.goods.gds-name    column-label "Название товара! "                 format "x(30)":U
  ub.gds-dtl.fact-qnty column-label "Количество  ! "                    format "->>>>>>9.<<<":U
  price-doc            column-label "Цена по!докум.(руб)"       format ">>>>>>9.99":U
  doc-sum              column-label "Сумма по!докум.(руб)"      format "->>>>>>>>9.99":U
  ub.gds-dtl.cur-base  column-label "Цена по!объекту(руб)"      format ">>>>>>9.99":U
  obj-sum              column-label "Сумма цен по!объекту(руб)" format "->>>>>>>>9.99":U
  Delt                 column-label "Процент!разницы"                   format "x(8)":U
  sym2                 column-label ":!:"                               format "x(1)":U space( 0 )
header
  cur-time-print( )                                      at   5 format "x(35)":U
  string( "Акт автоматической переоценки по документу N " + tdoc-code + " от " +
  string( tdoc-date,"99/99/9999":U ) )                   at  40 format "x(80)":U
  string( "Страница " + string( page-number( s-out ) ) ) at 120 format "x(15)":U  skip
  v-single-line                                          at   1 format "x(136)":U
with width 235 down stream-io.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-rb-is-base
  )  .
assign v-single-line = fill( "-", 200 )
       print_rubl    = ( v-rb-is-base <> yes ).
find first t-doc no-lock where recid( t-doc ) = rec_id.
define variable FullGdsName as logical   no-undo .
define variable tmp-var  as character no-undo .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input t-doc.obj-type
  ,input t-doc.obj-code
  ,input 'prt-obj':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'FGdsNinD' then tmp-var =  string(thbjattr_thbj-attr.property-value-logical) .
end.
FullGdsName = (tmp-var = "yes") .
assign tdoc-date = t-doc.doc-date
       tdoc-code = t-doc.doc-code.
find first Our_Host no-lock where
           Our_Host.obj-type = 'орг':U and
           Our_Host.obj-code = t-doc.host-code.
output stream s-out to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
put stream s-out space( 90 ) Our_Host.obj-name format "x(40)":U skip( 2 )
                 space( 20 ) "А К Т   П Е Р Е О Ц Е Н К И   ( автоматической ) по документу  N " format "x(80)":U
                 t-doc.doc-code format "x(10)":U "  от  " t-doc.doc-date format "99.99.9999":U skip( 1 ).
if lookup( "ParCom":U, p-mode ) <> 0 then do:
  if t-doc.doc-type = 'при':U and t-doc.internal <> yes then do:
    put stream s-out substitute( "Основание: накладная поставщика N &1 от &2", t-doc.ord-num,
                     string( t-doc.ship-date, "99.99.9999":U ) ) format "x(110)":U skip( 1 ).
  end.
end.
else do:
  if t-doc.doc-type = 'при':U and t-doc.internal <> yes then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input 'nids':U ,
                       output v-nids ,
                       output v-parameter-type )  .
    if v-nids <> "":U and v-nids <> ? then do:
      put stream s-out space( 20 ) "Основание: накладная поставщика N: " v-nids format "x(110)":U skip( 1 ).
    end.
  end.
end.
if t-doc.doc-type = 'при':U
  or t-doc.ext-doc-type = 'ep':U
then do:
  put stream s-out space( 20 ) string( "ПОСТАВЩИК : " + t-doc.cli-name ) format "x(90)":U skip( 1 ).
end.
form header
  v-single-line format "x(136)":U       at  1 skip
  "Продолжение - на следующей странице" at 30 skip
with frame Bottomframe width 235 page-bottom no-labels no-box.
view stream s-out frame Bottomframe.
if v-rb-is-base = yes then do: form with frame PrintFrame_Act-base. end.
                      else do: form with frame PrintFrame_Act-rubl. end.
for each ub.doc-line no-lock where ub.doc-line.doc-code = t-doc.doc-code
  , each ub.gds-dtl  no-lock where
         ub.gds-dtl.doc-code  = ub.doc-line.doc-code  and
         ub.gds-dtl.artic     = ub.doc-line.artic     and
         ub.gds-dtl.prod-type = ub.doc-line.prod-type and
         ub.gds-dtl.prod-code = ub.doc-line.prod-code and
         ub.gds-dtl.ov        = yes
  , each ub.goods    no-lock where
         ub.goods.prod-type = ub.gds-dtl.prod-type and
         ub.goods.prod-code = ub.gds-dtl.prod-code and
         ub.goods.artic     = ub.gds-dtl.artic
break by ub.gds-dtl.artic
      by ub.gds-dtl.prt-code
:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input ub.goods.artic
  ,  input ub.goods.prod-type
  ,  input ub.goods.prod-code
  , output is-petrol
  , output is-pieces
  ) no-error.
  if error-status :error or is-petrol <> yes or is-pieces <> no then do: next. end.
  find first ub.bar-code no-lock where
             ub.bar-code.gds-code  = ub.goods.gds-code   and
             ub.bar-code.unit-cli  = ub.goods.unit-base  and
             ub.bar-code.node-code = ub.gds-dtl.prt-code and
             ub.bar-code.part-code = "":U                and
             ub.bar-code.in-code   = "":U                no-error.
  assign j_total          =   j_total                      + 1
         d_qnty-kg        =
    invlnsum_cli-qnty (
                   ub.gds-dtl.doc-code
                 , ub.goods.artic
                 , ub.goods.prod-type
                 , ub.goods.prod-code
                 )
         d_cli-rate       =   ub.gds-dtl.fact-qnty         / d_qnty-kg
         d_obj-price      =   ub.gds-dtl.cur-base          * d_cli-rate
         d_obj-sum        =   d_obj-price                  * d_qnty-kg
         d_sale-price     =
    invlnsum_sale-price (
                   ub.gds-dtl.doc-code
                 , ub.goods.artic
                 , ub.goods.prod-type
                 , ub.goods.prod-code
                 , print_rubl
                 )
         d_sale-sum       =   d_sale-price                 * d_qnty-kg
         d_delta          = ( d_obj-price - d_sale-price ) / d_sale-price * 100
         total_qnty-kg    = total_qnty-kg                  + d_qnty-kg
         total_sale-sum   = total_sale-sum                 + d_sale-sum
         total_obj-sum    = total_obj-sum                  + d_obj-sum
         total_delta      = total_delta                    + d_obj-sum    - d_sale-sum.
  if v-rb-is-base = yes then do:
    display stream s-out sym1   trim( string( ub.bar-code.b-code ) )         @ tb-code
                                              ub.gds-dtl.artic
                                              ub.goods.gds-name
                                              d_qnty-kg                      @ ub.gds-dtl.fact-qnty
                                              d_sale-price                   @ price-doc
                                              d_sale-sum                     @ doc-sum
                                              d_obj-price                    @ ub.gds-dtl.cur-base
                                              d_obj-sum                      @ obj-sum
                              string( string( d_delta, "->>>9.9":U ) + "%" ) @ Delt sym2
    with frame PrintFrame_Act-base.
    down stream s-out 1 with frame PrintFrame_Act-base.
    IF LENGTH(ub.goods.gds-name, "CHARACTER") > 30 and FullGdsName THEN  do:
      assign propis = SUBSTRING(ub.goods.gds-name,31) .
      DISPLAY stream s-out sym1 propis @ ub.goods.gds-name  sym2   with frame PrintFrame_Act-base .
      down stream s-out 1 with frame PrintFrame_Act-base .
    end.
  end.
  else do:
    display stream s-out sym1   trim( string( ub.bar-code.b-code ) )         @ tb-code
                                              ub.gds-dtl.artic
                                              ub.goods.gds-name
                                              d_qnty-kg                      @ ub.gds-dtl.fact-qnty
                                              d_sale-price                   @ price-doc
                                              d_sale-sum                     @ doc-sum
                                              d_obj-price                    @ ub.gds-dtl.cur-base
                                              d_obj-sum                      @ obj-sum
                              string( string( d_delta, "->>>9.9":U ) + "%" ) @ Delt sym2
    with frame PrintFrame_Act-rubl.
    down stream s-out 1 with frame PrintFrame_Act-rubl.
    IF LENGTH(ub.goods.gds-name, "CHARACTER") > 30 and FullGdsName THEN  do:
      assign propis = SUBSTRING(ub.goods.gds-name,31) .
      DISPLAY stream s-out sym1 propis @ ub.goods.gds-name  sym2   with frame PrintFrame_Act-rubl .
      down stream s-out 1 with frame PrintFrame_Act-rubl .
    end.
  end.
  if last( ub.gds-dtl.artic ) then do:
    assign total_percent = total_delta / total_sale-sum * 100.
    if v-rb-is-base = yes then do:
      put     stream s-out v-single-line format "x(136)":U skip.
      display stream s-out "  ИТОГО"                                            @ ub.goods.gds-name
                                           total_qnty-kg                        @ ub.gds-dtl.fact-qnty
                                           total_sale-sum                       @ doc-sum
                                           total_obj-sum                        @ obj-sum
                           string( string( total_percent, "->>>9.9":U ) + "%" ) @ Delt
      with frame PrintFrame_Act-base.
      underline stream s-out ub.goods.gds-name
                             ub.gds-dtl.fact-qnty
                             doc-sum
                             obj-sum
                             Delt
      with frame PrintFrame_Act-base.
      down stream s-out 2 with frame PrintFrame_Act-base.
    end.
    else do:
      put     stream s-out v-single-line format "x(136)":U skip.
      display stream s-out "  ИТОГО"                                            @ ub.goods.gds-name
                                           total_qnty-kg                        @ ub.gds-dtl.fact-qnty
                                           total_sale-sum                       @ doc-sum
                                           total_obj-sum                        @ obj-sum
                           string( string( total_percent, "->>>9.9":U ) + "%" ) @ Delt
      with frame PrintFrame_Act-rubl.
      underline stream s-out ub.goods.gds-name
                             ub.gds-dtl.fact-qnty
                             doc-sum
                             obj-sum
                             Delt
      with frame PrintFrame_Act-rubl.
      down stream s-out 2 with frame PrintFrame_Act-rubl.
    end.
  end.
end.
hide stream s-out frame Bottomframe.
if v-rb-is-base = yes then do:
  assign propis = Total-Word(          absolute( total_delta ), base-type, base-part )
         abbr   = base-type.
end.                  else do:
  assign propis = Total-Word(          absolute( total_delta ),
                              Roubles( absolute( total_delta ) ),
                              Copecks( absolute( total_delta ) ) )
         abbr   = " руб.".
end.
put stream s-out space( 10 ) "Всего  " j_total                format ">>>>9":U
                             " наименований."                 format "x(15)":U skip( 1 )
                 space( 10 ) "Разница в суммах составила :  " format "x(35)":U
                             total_delta                      format "->,>>>,>>>,>>9.99":U
                 space(  2 ) trim( abbr )                     format "x(3)":U  skip( 1 ).
if line-counter( s-out ) + 4 > page-size( s-out ) then do: page stream s-out. end.
put stream s-out space( 10 ) ( if trim( propis ) begins trim( abbr ) then "0 " else "":U ) + propis format "x(120)":U skip( 2 ).
put stream s-out space( 20 ) "Зав. складом/Зав. секцией : " format "x(30)":U skip.
output stream s-out close.
if g#quest-print = false
then do:
  run adecomm/_osprint.p ( ?, string( session:temp-directory + "rpt" + string( g#report-num ) ),
                                      7, (if 8 >= 8 then 2 else 0), 0, 0,
                                      OUTPUT g#log ).
end.
else do:
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + " " +
      string( session:temp-directory) +  "$" + string( g#report-num )
              ) .
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl" + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + ".txl" + " " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl"
              ) .
end.
