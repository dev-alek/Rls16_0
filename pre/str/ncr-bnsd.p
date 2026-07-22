block-level on error undo, throw.
define input parameter p-parameter     as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ncr-bnsd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/ncr-bnsd.p $":U .
define variable vss-description as character no-undo init "Удаление бонусов 91 с кассы NCR".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
def stream IBMStream.
def var v-found as log no-undo .
def var v-upd   as char no-undo .
def var v-ver   as char no-undo .
def var v-char-delim-1  as char initial ',' no-undo .
def var v-char-delim-2  as char initial ';' no-undo .
def var v-char-1        as char no-undo .
def var v-char-2        as char no-undo .
def var v-char-21       as char no-undo .
def var v-char-3        as char no-undo .
def var v-char-4        as char no-undo .
def var v-char-41       as char no-undo .
def var v-char-42       as char no-undo .
def var v-char-5        as char no-undo .
def var v-char-6        as char no-undo .
def var v-char-61       as char no-undo .
def var v-char-62       as char no-undo .
def var v-char-8        as char no-undo .
def var v-char-9        as char no-undo .
def var v-char-7        as char no-undo .
def var v-char-71       as char no-undo .
def var v-char-72       as char no-undo .
def var v-cassa         as char no-undo .
def var v-is-weight     as log  no-undo init false .
def var v-ean13         as char no-undo .
def var v-tmpchar       as char no-undo .
def var fname           as char no-undo .
def buffer buf_dis-gds-rule-attr for ub.dis-gds-rule-attr .
def buffer buf_dis-gds-rule      for ub.dis-gds-rule .
def buffer buf_dis-rule          for dis-rule .
def buffer buf_dis-time-rule     for dis-time-rule .
def buffer buf_prod-bc           for prod-bc .
def buffer buf_bar-code          for bar-code .
def buffer buf_units             for ub.units .
def buffer buf_goods             for ub.goods.
def var p-recid      as recid no-undo.
def var p-out        as char  no-undo.
def var p-attr-code  as char  no-undo.
def var p-attr-value as char  no-undo.
assign
p-recid      = int(entry(1, p-parameter, chr(4)))
p-out        =     entry(2, p-parameter, chr(4))
p-attr-code  =     entry(3, p-parameter, chr(4))
p-attr-value =     entry(4, p-parameter, chr(4))
no-error
.
if error-status:error then do:
    return error substitute("Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , chr(10)
                         , error-status:get-message(1)
                         , return-value ).
end.
assign
  fname = substring( string( next-value( s-spool, ub ), '99999999999999999999'), 13, 8 )
  v-ver = "2.02.00"
  v-char-1 = "0,0,0,,,,,0,1,0,0,1,;,0,0,1,0,0,"
  v-char-2 = "0,0,0,0,0,0,"
  v-char-21 = "0,0,0,"
  v-char-3 = "0,0,0,"
  v-char-4 =
  ",;,,;,;,,0,0,2,0,0,0,0,0,0,4,0,0,127,0,2359,,,,,,,0,0,3,0,1,0,0,0,6,0,0,"
  v-char-41 =
  ",,,,,,0,0,2,0,0,0,0,0,0,4,0,0,127,0,2359,,,,,,,0,0,3,0,1,0,0,0,6,0,0,"
  v-char-42 =
  ",,,,,,0,0,2,0,0,0,0,0,0,4,0,0,127,0,2359,,,,,,,0,0,3,0,1,0,1,0,21,0,0,"
  v-char-5 =
  "0,0,1,1,0,4,1,"
  v-char-6 =
  ",;,;,;,;,;,0;+                                       ;"
  v-char-61 =
  ",;,;,;,;,;,1;+                                       ;"
  v-char-62 =
  ",;,;,;,;,;,1;Message                                 ;"
  v-char-7 =
  "006;00;000;               ;          ;,0,0"
  v-char-71 =
  "006;04;000;               ;          ;,0,0"
  v-char-72 =
  "021;00;000;               ;          ;Выдать марок$FinalPointsBalance$ шт.,0,0,4,0,1,0,1,0,22,0,0,0,0,0,1,1,0,4,1,"
  v-char-8 =
  ";,;,;,;,;,;,1;" + fill(" ",40) + ";022;06;000;"
  v-char-9 =
  "               ;          ;________________________MAPOK=$FinalPointsBalance$,0,0"
.
find first buf_dis-gds-rule no-lock where recid(buf_dis-gds-rule) = p-recid no-error .
if not avail buf_dis-gds-rule then return error error-status:get-message(1).
find first buf_dis-rule no-lock
where buf_dis-rule.rule-num = buf_dis-gds-rule.rule-num
  and buf_dis-rule.sts = integer('0':U)
no-error .
if not avail buf_dis-rule then return error error-status:get-message(1).
find first buf_dis-time-rule no-lock where buf_dis-time-rule.time-rule-num = buf_dis-rule.time-rule-num no-error .
if not avail buf_dis-time-rule then return error error-status:get-message(1).
if search (p-out + "gmrecmnt.ctl") = ? then do:
    output stream ibmstream to value( p-out + "gmrecmnt.ctl":U) .
    put unformatted skip.
    output stream ibmstream close.
end.
output stream IBMStream to value(p-out + fname + ".dat") convert target "utf-8" .
assign
  v-char-2 = "0,0,0,0,0,0,"
  v-is-weight = false
.
find buf_goods where buf_goods.gds-code = buf_dis-gds-rule.gds-code no-lock no-error.
if avail buf_goods then do:
    find buf_units where buf_units.unit-name = buf_goods.unit-base no-lock no-error.
    if avail buf_units then do:
        if lookup ('вес':U, buf_units.type) > 0 then do:
            assign
              v-char-2    = "0,0,0,2,0,0,"
              v-is-weight = true
            .
        end.
    end.
end.
assign
  v-upd = "D"
  v-ean13 = entry(1, p-attr-value,",")
.
if v-is-weight and length(v-ean13) = 5 then do:
    def var ncrsc-pfx as char no-undo init "23":U .
    def var ncrsc-frmt as char no-undo init "EAN13" .
    assign v-tmpchar = "" .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable tmp-str1  as character no-undo.
  define variable tmp-num1  as character no-undo.
  define variable i1        as integer   no-undo.
  define variable sum1      as integer   no-undo.
  define variable len-code1 as integer   no-undo.
  define variable varcont1  as logical   initial yes no-undo.
  CASE ncrsc-frmt :
    WHEN "EAN13" THEN do:
      assign
        tmp-str1 = string( decimal(string(integer( v-ean13 ), '99999':U) + '00000':U), "999999999999" )
      .
    end.
    WHEN "EAN8" THEN do:
      assign
        tmp-str1 = string( decimal(string(integer( v-ean13 ), '99999':U) + '00000':U), "9999999" )
      .
    end.
    OTHERWISE DO:
        message "Неизвестный тип генерации бар-кода процедурой bc-gnrti.i: " ncrsc-frmt " ."
        view-as alert-box error.
        return error.
    END.
  END CASE.
  if varcont1 = yes then do:
    if integer( substring( tmp-str1, 1, length( ncrsc-pfx ) ) ) <> 0
    then do:
      message
        "Невозможно сформировать бар-код" SKIP
        "для товара с кодом: " decimal(string(integer( v-ean13 ), '99999':U) + '00000':U)
        view-as alert-box error title "подрезание кода".
      return error.
    end.
    else do:
      assign
        v-tmpchar = ncrsc-pfx + substring( tmp-str1, length( ncrsc-pfx ) + 1, length( tmp-str1 ) - length( ncrsc-pfx ) )
        len-code1    = length( v-tmpchar )
      .
      define variable v-sum-char1 as character no-undo .
      assign
        sum1 = 0
      .
      do i1 = 1 to len-code1 by 2
      :
        assign
          v-sum-char1 = substr(v-tmpchar, len-code1 - i1 + 1, 1)
        .
        if v-sum-char1 < "0"
        or v-sum-char1 > "9"
        then do:
          message
            "Невозможно сформировать бар-код" skip
            "для товара с кодом: " decimal(string(integer( v-ean13 ), '99999':U) + '00000':U) skip
            view-as alert-box error title "подсчет контрольной суммы".
          return error.
        end.
        assign
          sum1 = sum1 + integer(v-sum-char1)
        .
      end.
      if varcont1 = yes then do:
        assign
          sum1 = sum1 * 3
        .
        do i1 = 2 to len-code1 by 2
        :
          assign
            v-sum-char1 = substr(v-tmpchar, len-code1 - i1 + 1, 1)
          .
          if v-sum-char1 < "0"
          or v-sum-char1 > "9"
          then do:
            message
              "Невозможно сформировать бар-код" skip
              "для товара с кодом: " decimal(string(integer( v-ean13 ), '99999':U) + '00000':U) skip
              view-as alert-box error title "подсчет контрольной суммы".
            return error.
          end.
          assign
            sum1 = sum1 + integer(v-sum-char1)
          .
        end.
        if varcont1 = yes then do:
           if sum1 mod 10 = 0 then do:
             assign
               v-tmpchar = v-tmpchar + '0'
             .
           end.
           else do:
             assign
               v-tmpchar = v-tmpchar + string(10 - sum1 mod 10)
             .
           end.
        end.
      end.
    end.
  end.
    if not v-tmpchar = "":U then assign v-ean13 = v-tmpchar .
end.
put stream IBMStream unformatted v-ver v-char-delim-1 v-upd v-char-delim-1
 p-attr-code v-char-delim-1
 "3,MAPKA,"
 entry(1,iso-date(buf_dis-time-rule.date-from),"-") + entry(2,iso-date(buf_dis-time-rule.date-from),"-") + entry(3,iso-date(buf_dis-time-rule.date-from),"-") v-char-delim-1
 "0" v-char-delim-1
 entry(1,iso-date(buf_dis-time-rule.date-to),"-") + entry(2,iso-date(buf_dis-time-rule.date-to),"-") + entry(3,iso-date(buf_dis-time-rule.date-to),"-") v-char-delim-1
 "0" v-char-delim-1
 v-char-1
 v-char-2
 trim(string(buf_dis-rule.doc-qnty,'>>>>9')) v-char-delim-1
 v-char-3
 v-ean13 v-char-delim-2
 v-char-4
 trim(string(buf_dis-rule.discnt-value,">>>9")) v-char-delim-1
 v-char-5
 v-ean13 v-char-delim-2
 v-char-6 v-char-7 skip.
output stream IBMStream close .
OS-append
    value( p-out + fname + '.dat':U )
    value( p-out + fname + ".pmt":U).
if search(p-out + 'debug.flg') = ? then do:
    OS-delete value( p-out + fname + '.dat':U ).
end.
if search (p-out + "pmt.ctl") = ? then do:
    output stream ibmstream to value( p-out +  "pmt.ctl":U) append .
    put unformatted skip.
    output stream ibmstream close.
end.
