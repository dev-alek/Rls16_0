block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
DEFINE INPUT PARAMETER bc-rid AS RECID NO-UNDO.
DEFINE INPUT PARAMETER p-db-Num AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER ScaleNum AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER ScaleRid AS CHARacter NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: tick-scl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/tick-scl.p $":U .
define variable vss-description as character no-undo init "Печать ценников для товаров на весах".
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
define variable v-user-id as character no-undo .
run get-userid in parparentproc
  ( output v-user-id
  ).
define NEW SHARED STREAM OutStream.
do
on error undo, return error
:
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define  new shared variable     lbc-path                     as  char        no-undo.
define  new shared variable     lbc-tmp                      as  char        no-undo.
define new shared variable TicketName  as character   init ""    no-undo.
define new shared variable ScalePrice    as decimal init 0     no-undo.
define new shared variable TitleCP    as character   init ""    no-undo.
define new shared variable TicketType    as character   init ""    no-undo.
define new shared variable BCodeType    as character   init ""    no-undo.
define new shared variable UnitName    as character   init ""    no-undo.
define new shared variable TickOnN       as logical   init no   no-undo.
define new shared variable TickOnW       as logical   init no   no-undo.
define new shared variable TickOnS         as logical  init no    no-undo.
define new shared variable OnlyChgPr    as logical     init no    no-undo.
define new shared variable QntyType     as character   init ""    no-undo.
define new shared variable PriceType    as character   init ""    no-undo.
define new shared variable tick-w       as logical     init no    no-undo.
define new shared variable TickPS       as character   init ""    no-undo.
define  new shared variable     GdsName   as character   no-undo.
define  new shared variable     curr-date                      as  date      no-undo.
define  new shared variable     curr-rate                      as  decimal      no-undo.
define  new shared variable     bc-type   as character   no-undo.
define  new shared variable     obj_name  as character   no-undo.
define  new shared variable     list-sort      as character no-undo .
define variable Artic as char no-undo.
define variable i-art as int no-undo.
define variable i as int no-undo.
define variable pr-doc-rubl like ub.price-list.price-sale no-undo.
define variable pr-doc-rb like ub.price-list.price-sale no-undo.
define variable pr-doc-rubl-old like ub.price-list.price-sale no-undo.
define variable pr-doc-rb-old like ub.price-list.price-sale no-undo.
define variable upper as integer no-undo.
define variable nakl-qnty like ub.gds-dtl.fact-qnty no-undo.
define variable list-qnty like ub.gds-dtl.fact-qnty no-undo.
define variable rootnode_code as integer no-undo.
define variable tmp-var as char no-undo.
define variable type-par as char no-undo.
    GET-KEY-VALUE section "REP-SETS" key "lbc_path" value lbc-path .
    GET-KEY-VALUE section "REP-SETS" key "lbc_tmp" value lbc-tmp .
    assign TitleCP = "".
    GET-KEY-VALUE section "REP-SETS" key "TitleCodePage" value TitleCP .
    if TitleCP = "" OR TitleCP = ? then
        assign TitleCP = "ibm866".
def new shared var bc-frmt as character no-undo .
def new shared var bc-pfx  as character no-undo .
def var bc-par-type as character no-undo .
    run gbl/conf-rd.p ("bc-frmt", "", "", 0, "", "", "",  no , output bc-frmt, output bc-par-type) no-error.
    if "new" = "bc" AND ( error-status:error OR bc-par-type <> "C":U OR not can-do ("EAN8,EAN13", bc-frmt) ) then
        do:
            message "Не задан или не верно задан ТИП собственного бар-кода!"
                view-as alert-box ERROR TITLE "".
            return error.
        end.
    run gbl/conf-rd.p ("bc-pfx", "", "", 0, "", "", "",  no , output bc-pfx, output bc-par-type) no-error.
    if "new" = "bc" AND ( error-status:error OR bc-par-type <> "C":U ) then
        do:
            message "Не задан или не верно задан ПРЕФИКС бар-кода складского места!"
                view-as alert-box ERROR TITLE "".
            return error.
        end.
PROCEDURE gen-bc:
  def input  parameter internal-b-code like ub.bar-code.b-code no-undo .
  def output parameter full-b-code     as character init ""    no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable tmp-str2  as character no-undo.
  define variable tmp-num2  as character no-undo.
  define variable i2        as integer   no-undo.
  define variable sum2      as integer   no-undo.
  define variable len-code2 as integer   no-undo.
  define variable varcont2  as logical   initial yes no-undo.
  CASE bc-frmt :
    WHEN "EAN13" THEN do:
      assign
        tmp-str2 = string( internal-b-code, "999999999999" )
      .
    end.
    WHEN "EAN8" THEN do:
      assign
        tmp-str2 = string( internal-b-code, "9999999" )
      .
    end.
    OTHERWISE DO:
        message "Неизвестный тип генерации бар-кода процедурой bc-gnrti.i: " bc-frmt " ."
        view-as alert-box error.
        return error.
    END.
  END CASE.
  if varcont2 = yes then do:
    if integer( substring( tmp-str2, 1, length( bc-pfx ) ) ) <> 0
    then do:
      message
        "Невозможно сформировать бар-код" SKIP
        "для товара с кодом: " internal-b-code
        view-as alert-box error title "подрезание кода".
      return error.
    end.
    else do:
      assign
        full-b-code = bc-pfx + substring( tmp-str2, length( bc-pfx ) + 1, length( tmp-str2 ) - length( bc-pfx ) )
        len-code2    = length( full-b-code )
      .
      define variable v-sum-char2 as character no-undo .
      assign
        sum2 = 0
      .
      do i2 = 1 to len-code2 by 2
      :
        assign
          v-sum-char2 = substr(full-b-code, len-code2 - i2 + 1, 1)
        .
        if v-sum-char2 < "0"
        or v-sum-char2 > "9"
        then do:
          message
            "Невозможно сформировать бар-код" skip
            "для товара с кодом: " internal-b-code skip
            view-as alert-box error title "подсчет контрольной суммы".
          return error.
        end.
        assign
          sum2 = sum2 + integer(v-sum-char2)
        .
      end.
      if varcont2 = yes then do:
        assign
          sum2 = sum2 * 3
        .
        do i2 = 2 to len-code2 by 2
        :
          assign
            v-sum-char2 = substr(full-b-code, len-code2 - i2 + 1, 1)
          .
          if v-sum-char2 < "0"
          or v-sum-char2 > "9"
          then do:
            message
              "Невозможно сформировать бар-код" skip
              "для товара с кодом: " internal-b-code skip
              view-as alert-box error title "подсчет контрольной суммы".
            return error.
          end.
          assign
            sum2 = sum2 + integer(v-sum-char2)
          .
        end.
        if varcont2 = yes then do:
           if sum2 mod 10 = 0 then do:
             assign
               full-b-code = full-b-code + '0'
             .
           end.
           else do:
             assign
               full-b-code = full-b-code + string(10 - sum2 mod 10)
             .
           end.
        end.
      end.
    end.
  end.
END PROCEDURE.
def new shared var pl-frmt as character no-undo .
def new shared var pl-pfx  as character no-undo .
def var pl-par-type as character no-undo .
    run gbl/conf-rd.p ("pl-frmt", "", "", 0, "", "", "",  no , output pl-frmt, output pl-par-type) no-error.
    if "new" = "bc" AND ( error-status:error OR pl-par-type <> "C":U OR not can-do ("EAN8,EAN13", pl-frmt) ) then
        do:
            message "Не задан или не верно задан ТИП собственного бар-кода!"
                view-as alert-box ERROR TITLE "".
            return error.
        end.
    run gbl/conf-rd.p ("pl-pfx", "", "", 0, "", "", "",  no , output pl-pfx, output pl-par-type) no-error.
    if "new" = "bc" AND ( error-status:error OR pl-par-type <> "C":U ) then
        do:
            message "Не задан или не верно задан ПРЕФИКС бар-кода складского места!"
                view-as alert-box ERROR TITLE "".
            return error.
        end.
PROCEDURE gen-pl:
  def input  parameter internal-b-code like ub.bar-code.b-code no-undo .
  def output parameter full-b-code     as character init ""    no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable tmp-str3  as character no-undo.
  define variable tmp-num3  as character no-undo.
  define variable i3        as integer   no-undo.
  define variable sum3      as integer   no-undo.
  define variable len-code3 as integer   no-undo.
  define variable varcont3  as logical   initial yes no-undo.
  CASE pl-frmt :
    WHEN "EAN13" THEN do:
      assign
        tmp-str3 = string( internal-b-code, "999999999999" )
      .
    end.
    WHEN "EAN8" THEN do:
      assign
        tmp-str3 = string( internal-b-code, "9999999" )
      .
    end.
    OTHERWISE DO:
        message "Неизвестный тип генерации бар-кода процедурой bc-gnrti.i: " pl-frmt " ."
        view-as alert-box error.
        return error.
    END.
  END CASE.
  if varcont3 = yes then do:
    if integer( substring( tmp-str3, 1, length( pl-pfx ) ) ) <> 0
    then do:
      message
        "Невозможно сформировать бар-код" SKIP
        "для товара с кодом: " internal-b-code
        view-as alert-box error title "подрезание кода".
      return error.
    end.
    else do:
      assign
        full-b-code = pl-pfx + substring( tmp-str3, length( pl-pfx ) + 1, length( tmp-str3 ) - length( pl-pfx ) )
        len-code3    = length( full-b-code )
      .
      define variable v-sum-char3 as character no-undo .
      assign
        sum3 = 0
      .
      do i3 = 1 to len-code3 by 2
      :
        assign
          v-sum-char3 = substr(full-b-code, len-code3 - i3 + 1, 1)
        .
        if v-sum-char3 < "0"
        or v-sum-char3 > "9"
        then do:
          message
            "Невозможно сформировать бар-код" skip
            "для товара с кодом: " internal-b-code skip
            view-as alert-box error title "подсчет контрольной суммы".
          return error.
        end.
        assign
          sum3 = sum3 + integer(v-sum-char3)
        .
      end.
      if varcont3 = yes then do:
        assign
          sum3 = sum3 * 3
        .
        do i3 = 2 to len-code3 by 2
        :
          assign
            v-sum-char3 = substr(full-b-code, len-code3 - i3 + 1, 1)
          .
          if v-sum-char3 < "0"
          or v-sum-char3 > "9"
          then do:
            message
              "Невозможно сформировать бар-код" skip
              "для товара с кодом: " internal-b-code skip
              view-as alert-box error title "подсчет контрольной суммы".
            return error.
          end.
          assign
            sum3 = sum3 + integer(v-sum-char3)
          .
        end.
        if varcont3 = yes then do:
           if sum3 mod 10 = 0 then do:
             assign
               full-b-code = full-b-code + '0'
             .
           end.
           else do:
             assign
               full-b-code = full-b-code + string(10 - sum3 mod 10)
             .
           end.
        end.
      end.
    end.
  end.
END PROCEDURE.
    define variable new-prn-host-code like ub.sysconf.host-code no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output new-prn-host-code
  )  .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input 'орг':U
  ,input new-prn-host-code
  ,input 'prt-firm':U
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
      if thbjattr_thbj-attr.prop-code = 'tick-w'  then tick-w  = thbjattr_thbj-attr.property-value-logical .
  end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-prt'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  yes
  ,output tmp-var
  ,output type-par
  ) no-error .
define variable v-cntxp-doc-prt as logical no-undo .
define buffer new-prn_shop for ub.shop.
define buffer new-prn_store for ub.store.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-prt'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  yes
  ,output tmp-var
  ,output type-par
  ) no-error .
case p-obj-type :
  when 'скл':U then do:
    find first new-prn_store where new-prn_store.obj-code = p-obj-code no-lock.
    assign
      v-cntxp-doc-prt         = (tmp-var = "yes") and new-prn_store.doc-prt
      .
  end.
  when 'маг':U then do:
    find first new-prn_shop where new-prn_shop.obj-code = p-obj-code no-lock.
    assign
      v-cntxp-doc-prt         = (tmp-var = "yes") and new-prn_shop.doc-prt
      .
  end.
end case.
define variable curr_cass as dec no-undo.
define variable dob-curr as char no-undo.
define variable Term_Node as logical no-undo.
define variable ListProdBc as char no-undo.
define variable counter as int init 1 no-undo.
define variable Rubl_Coeff as decimal init 0 no-undo.
define variable v-doc-code as character initial "":U no-undo .
define variable v-part-code as character initial "":U no-undo .
define variable v-promo-code as character no-undo .
define variable v-ActionId as int64 no-undo .
define variable v-db-num as integer no-undo .
define variable Action as char init "SCALES" no-undo.
define variable jj as int no-undo.
define variable how-pcnt-kat as character no-undo .
define variable dflt-cd as character no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type6 as character no-undo .
define variable v-value-date6 as date no-undo .
define variable v-value-decimal6 as decimal no-undo .
define variable v-value-integer6 as INTEGER no-undo .
define variable v-value-logical6 AS LOGICAL no-undo .
define variable v-tth6 as handle no-undo .
define variable v-host-code6 as integer no-undo .
define buffer buf_dis-thbj-rule6 for ub.dis-thbj-rule.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type7 as character no-undo .
define variable v-value-date7 as date no-undo .
define variable v-value-decimal7 as decimal no-undo .
define variable v-value-integer7 as INTEGER no-undo .
define variable v-value-logical7 AS LOGICAL no-undo .
define variable v-tth7 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd
    ,output v-value-date7
    ,output v-value-decimal7
    ,output v-value-integer7
    ,output v-value-logical7
    ,output v-param-type7
    ,INPUT-OUTPUT table-handle v-tth7
    )  .
delete object v-tth7 no-error.
how-pcnt-kat = ''.
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-inf-send':U
    ,input  'how-pcnt-kat':U
    ,output how-pcnt-kat
    ,output v-value-date6
    ,output v-value-decimal6
    ,output v-value-integer6
    ,output v-value-logical6
    ,output v-param-type6
    ,INPUT-OUTPUT table-handle v-tth6
    ) no-error .
delete object v-tth6.
if how-pcnt-kat = 'pcnt-kat-pdf':U then do:
  find first  buf_dis-thbj-rule6 No-LOCK  where
              buf_dis-thbj-rule6.obj-type = p-obj-type
        AND  buf_dis-thbj-rule6.obj-code = p-obj-code
        and  buf_dis-thbj-rule6.pos-type = dflt-cd
        and  buf_dis-thbj-rule6.discnt-role = 'pcnt-kat-pdf':U
        and  buf_dis-thbj-rule6.nonunique = ''
        no-error .
  if not available buf_dis-thbj-rule6 then do:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code6
  )  .
    find first  buf_dis-thbj-rule6 No-LOCK  where
                buf_dis-thbj-rule6.obj-code = v-host-code6
          AND  buf_dis-thbj-rule6.obj-type = 'орг':U
          and  buf_dis-thbj-rule6.pos-type = dflt-cd
          and  buf_dis-thbj-rule6.discnt-role = 'pcnt-kat-pdf':U
          and  buf_dis-thbj-rule6.nonunique = ''
          no-error .
  end.
  if not available buf_dis-thbj-rule6 then do:
    find first  buf_dis-thbj-rule6 No-LOCK  where
                buf_dis-thbj-rule6.obj-code = 0
          AND  buf_dis-thbj-rule6.obj-type = ''
          and  buf_dis-thbj-rule6.pos-type = dflt-cd
          and  buf_dis-thbj-rule6.discnt-role = 'pcnt-kat-pdf':U
          and  buf_dis-thbj-rule6.nonunique = ''
          no-error .
  end.
  if available buf_dis-thbj-rule6 then do:
    how-pcnt-kat = how-pcnt-kat + "=" + string(buf_dis-thbj-rule6.rule-num).
  end.
  else do:
    how-pcnt-kat = how-pcnt-kat + "="  + string(0).
  end.
end.
DEFINE VARIABLE b-count as integer init 0 no-undo.
DEFINE VARIABLE v-fact-order        like ub.trn-doc.fact-order     no-undo.
run rep/tickets.w (input parparentproc, input p-obj-type, input p-obj-code, input Action, input "" ).
if TicketName = "" then
    RETURN.
OUTPUT STREAM OutStream TO VALUE( lbc-tmp + "title" ) CONVERT TARGET TitleCP PAGE-SIZE 0 .
if bc-rid = ? then do:
  if ScaleRid <> "" then  do:
          DO jj = 1 TO NUM-ENTRIES( ScaleRid ):
              FIND ub.scales-gds WHERE recid( ub.scales-gds ) = integer( ENTRY( jj, ScaleRid ) ) NO-LOCK.
              FIND ub.bar-code WHERE ub.bar-code.b-code = ub.scales-gds.b-code NO-LOCK.
              run tick-prn.
          END.
  end.
  else do:
    FOR EACH ub.scales-gds WHERE
              ub.scales-gds.db-num = p-db-Num AND
            ub.scales-gds.scales-num = ScaleNum NO-LOCK:
        FIND ub.bar-code WHERE ub.bar-code.b-code = ub.scales-gds.b-code NO-LOCK.
        run tick-prn.
    END.
  end.
end.
else do:
    FIND ub.bar-code WHERE recid(ub.bar-code) = bc-rid NO-LOCK.
    FIND ub.scales-gds WHERE
          ub.scales-gds.db-num = p-db-Num
    AND  ub.scales-gds.scales-num = ScaleNum
    AND ub.scales-gds.b-code = ub.bar-code.b-code NO-LOCK.
    run tick-prn.
end.
def var vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
OUTPUT STREAM OutStream CLOSE.
message
  substitute( "Передано на печать &1 этикеток (ценников)", b-count )
  view-as alert-box INFORMATION.
os-command NO-WAIT value( substitute( "start &1run-lbc.bat &1 &2title &3 &4", lbc-path, lbc-tmp, TicketName, v-user-id ) ).
end.
PROCEDURE tick-prn:
    FIND ub.goods WHERE ub.goods.gds-code = ub.bar-code.gds-code NO-LOCK.
    FIND ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK.
    assign rootnode_code = ub.gds-prt.node-code.
run rep/ticket.p (
               buffer ub.goods
              ,buffer ub.bar-code
              ,buffer ub.scales-gds
              ,input p-obj-type
              ,input p-obj-code
              ,input Action
              ,input rootnode_code
              ,input TickOnw
              ,input TickOnN
              ,input QntyType
              ,input PriceType
              ,input scaleprice
              ,input nakl-qnty
              ,input list-qnty
              ,input pr-doc-rubl
              ,input pr-doc-rb
              ,input pr-doc-rubl-old
              ,input pr-doc-rb-old
              ,input v-fact-order
              ,input ListProdBc
              ,input curr-rate
              ,input TickPS
              ,input dflt-cd
              ,input how-pcnt-kat
              ,input-output b-count
              ,input v-part-code
              ,input v-doc-code
              ,input v-promo-code
              ,input v-ActionId
              ,input v-db-num
              ) no-error .
END PROCEDURE.
