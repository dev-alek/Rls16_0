block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
DEFINE INPUT PARAMETER prod-bc-rid AS RECID NO-UNDO.
define input parameter p-b-code like ub.bar-code.b-code no-undo .
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: tick-pbc.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/tick-pbc.p $":U .
def var vss-description as character no-undo init "Печать одного ценника по известному бар-коду".
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
define new shared temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table gds-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable tmp-str4  as character no-undo.
  define variable tmp-num4  as character no-undo.
  define variable i4        as integer   no-undo.
  define variable sum4      as integer   no-undo.
  define variable len-code4 as integer   no-undo.
  define variable varcont4  as logical   initial yes no-undo.
  CASE bc-frmt :
    WHEN "EAN13" THEN do:
      assign
        tmp-str4 = string( internal-b-code, "999999999999" )
      .
    end.
    WHEN "EAN8" THEN do:
      assign
        tmp-str4 = string( internal-b-code, "9999999" )
      .
    end.
    OTHERWISE DO:
        message "Неизвестный тип генерации бар-кода процедурой bc-gnrti.i: " bc-frmt " ."
        view-as alert-box error.
        return error.
    END.
  END CASE.
  if varcont4 = yes then do:
    if integer( substring( tmp-str4, 1, length( bc-pfx ) ) ) <> 0
    then do:
      message
        "Невозможно сформировать бар-код" SKIP
        "для товара с кодом: " internal-b-code
        view-as alert-box error title "подрезание кода".
      return error.
    end.
    else do:
      assign
        full-b-code = bc-pfx + substring( tmp-str4, length( bc-pfx ) + 1, length( tmp-str4 ) - length( bc-pfx ) )
        len-code4    = length( full-b-code )
      .
      define variable v-sum-char4 as character no-undo .
      assign
        sum4 = 0
      .
      do i4 = 1 to len-code4 by 2
      :
        assign
          v-sum-char4 = substr(full-b-code, len-code4 - i4 + 1, 1)
        .
        if v-sum-char4 < "0"
        or v-sum-char4 > "9"
        then do:
          message
            "Невозможно сформировать бар-код" skip
            "для товара с кодом: " internal-b-code skip
            view-as alert-box error title "подсчет контрольной суммы".
          return error.
        end.
        assign
          sum4 = sum4 + integer(v-sum-char4)
        .
      end.
      if varcont4 = yes then do:
        assign
          sum4 = sum4 * 3
        .
        do i4 = 2 to len-code4 by 2
        :
          assign
            v-sum-char4 = substr(full-b-code, len-code4 - i4 + 1, 1)
          .
          if v-sum-char4 < "0"
          or v-sum-char4 > "9"
          then do:
            message
              "Невозможно сформировать бар-код" skip
              "для товара с кодом: " internal-b-code skip
              view-as alert-box error title "подсчет контрольной суммы".
            return error.
          end.
          assign
            sum4 = sum4 + integer(v-sum-char4)
          .
        end.
        if varcont4 = yes then do:
           if sum4 mod 10 = 0 then do:
             assign
               full-b-code = full-b-code + '0'
             .
           end.
           else do:
             assign
               full-b-code = full-b-code + string(10 - sum4 mod 10)
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable tmp-str5  as character no-undo.
  define variable tmp-num5  as character no-undo.
  define variable i5        as integer   no-undo.
  define variable sum5      as integer   no-undo.
  define variable len-code5 as integer   no-undo.
  define variable varcont5  as logical   initial yes no-undo.
  CASE pl-frmt :
    WHEN "EAN13" THEN do:
      assign
        tmp-str5 = string( internal-b-code, "999999999999" )
      .
    end.
    WHEN "EAN8" THEN do:
      assign
        tmp-str5 = string( internal-b-code, "9999999" )
      .
    end.
    OTHERWISE DO:
        message "Неизвестный тип генерации бар-кода процедурой bc-gnrti.i: " pl-frmt " ."
        view-as alert-box error.
        return error.
    END.
  END CASE.
  if varcont5 = yes then do:
    if integer( substring( tmp-str5, 1, length( pl-pfx ) ) ) <> 0
    then do:
      message
        "Невозможно сформировать бар-код" SKIP
        "для товара с кодом: " internal-b-code
        view-as alert-box error title "подрезание кода".
      return error.
    end.
    else do:
      assign
        full-b-code = pl-pfx + substring( tmp-str5, length( pl-pfx ) + 1, length( tmp-str5 ) - length( pl-pfx ) )
        len-code5    = length( full-b-code )
      .
      define variable v-sum-char5 as character no-undo .
      assign
        sum5 = 0
      .
      do i5 = 1 to len-code5 by 2
      :
        assign
          v-sum-char5 = substr(full-b-code, len-code5 - i5 + 1, 1)
        .
        if v-sum-char5 < "0"
        or v-sum-char5 > "9"
        then do:
          message
            "Невозможно сформировать бар-код" skip
            "для товара с кодом: " internal-b-code skip
            view-as alert-box error title "подсчет контрольной суммы".
          return error.
        end.
        assign
          sum5 = sum5 + integer(v-sum-char5)
        .
      end.
      if varcont5 = yes then do:
        assign
          sum5 = sum5 * 3
        .
        do i5 = 2 to len-code5 by 2
        :
          assign
            v-sum-char5 = substr(full-b-code, len-code5 - i5 + 1, 1)
          .
          if v-sum-char5 < "0"
          or v-sum-char5 > "9"
          then do:
            message
              "Невозможно сформировать бар-код" skip
              "для товара с кодом: " internal-b-code skip
              view-as alert-box error title "подсчет контрольной суммы".
            return error.
          end.
          assign
            sum5 = sum5 + integer(v-sum-char5)
          .
        end.
        if varcont5 = yes then do:
           if sum5 mod 10 = 0 then do:
             assign
               full-b-code = full-b-code + '0'
             .
           end.
           else do:
             assign
               full-b-code = full-b-code + string(10 - sum5 mod 10)
             .
           end.
        end.
      end.
    end.
  end.
END PROCEDURE.
    define variable new-prn-host-code like ub.sysconf.host-code no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output new-prn-host-code
  )  .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define buffer buf_prod-bc for ub.prod-bc.
define NEW SHARED STREAM OutStream.
DEFINE VARIABLE Action as character no-undo.
DEFINE VARIABLE v-bc-type as character no-undo .
define variable v-user-id as character no-undo .
run get-userid in parparentproc
  ( output v-user-id
  ).
find first buf_prod-bc where recid(buf_prod-bc) = prod-bc-rid no-error .
if not available buf_prod-bc or
   buf_prod-bc.b-code <> p-b-code then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверное значение параметра prod-bc-rid" prod-bc-rid skip
  "или параметра p-b-code" p-b-code
  view-as alert-box error .
  return error.
end.
define variable how-pcnt-kat as character no-undo .
define variable dflt-cd as character no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type8 as character no-undo .
define variable v-value-date8 as date no-undo .
define variable v-value-decimal8 as decimal no-undo .
define variable v-value-integer8 as INTEGER no-undo .
define variable v-value-logical8 AS LOGICAL no-undo .
define variable v-tth8 as handle no-undo .
define variable v-host-code8 as integer no-undo .
define buffer buf_dis-thbj-rule8 for ub.dis-thbj-rule.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type9 as character no-undo .
define variable v-value-date9 as date no-undo .
define variable v-value-decimal9 as decimal no-undo .
define variable v-value-integer9 as INTEGER no-undo .
define variable v-value-logical9 AS LOGICAL no-undo .
define variable v-tth9 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd
    ,output v-value-date9
    ,output v-value-decimal9
    ,output v-value-integer9
    ,output v-value-logical9
    ,output v-param-type9
    ,INPUT-OUTPUT table-handle v-tth9
    )  .
delete object v-tth9 no-error.
how-pcnt-kat = ''.
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-inf-send':U
    ,input  'how-pcnt-kat':U
    ,output how-pcnt-kat
    ,output v-value-date8
    ,output v-value-decimal8
    ,output v-value-integer8
    ,output v-value-logical8
    ,output v-param-type8
    ,INPUT-OUTPUT table-handle v-tth8
    ) no-error .
delete object v-tth8.
if how-pcnt-kat = 'pcnt-kat-pdf':U then do:
  find first  buf_dis-thbj-rule8 No-LOCK  where
              buf_dis-thbj-rule8.obj-type = p-obj-type
        AND  buf_dis-thbj-rule8.obj-code = p-obj-code
        and  buf_dis-thbj-rule8.pos-type = dflt-cd
        and  buf_dis-thbj-rule8.discnt-role = 'pcnt-kat-pdf':U
        and  buf_dis-thbj-rule8.nonunique = ''
        no-error .
  if not available buf_dis-thbj-rule8 then do:
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code8
  )  .
    find first  buf_dis-thbj-rule8 No-LOCK  where
                buf_dis-thbj-rule8.obj-code = v-host-code8
          AND  buf_dis-thbj-rule8.obj-type = 'орг':U
          and  buf_dis-thbj-rule8.pos-type = dflt-cd
          and  buf_dis-thbj-rule8.discnt-role = 'pcnt-kat-pdf':U
          and  buf_dis-thbj-rule8.nonunique = ''
          no-error .
  end.
  if not available buf_dis-thbj-rule8 then do:
    find first  buf_dis-thbj-rule8 No-LOCK  where
                buf_dis-thbj-rule8.obj-code = 0
          AND  buf_dis-thbj-rule8.obj-type = ''
          and  buf_dis-thbj-rule8.pos-type = dflt-cd
          and  buf_dis-thbj-rule8.discnt-role = 'pcnt-kat-pdf':U
          and  buf_dis-thbj-rule8.nonunique = ''
          no-error .
  end.
  if available buf_dis-thbj-rule8 then do:
    how-pcnt-kat = how-pcnt-kat + "=" + string(buf_dis-thbj-rule8.rule-num).
  end.
  else do:
    how-pcnt-kat = how-pcnt-kat + "="  + string(0).
  end.
end.
FIND ub.bar-code WHERE
     ub.bar-code.b-code = p-b-code NO-LOCK.
FIND ub.goods WHERE
     ub.goods.gds-code = ub.bar-code.gds-code NO-LOCK.
FIND ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK.
assign rootnode_code = ub.gds-prt.node-code.
FIND ub.gds-prt WHERE ub.gds-prt.node-code = ub.bar-code.node-code NO-LOCK.
assign
Action = "PROD-BC"
v-bc-type = "main":U
v-bc-type = (if ub.bar-code.in-code <> ""
             then "part":U
             else  (if ub.goods.unit-base <> ub.bar-code.unit-cli
                    then "subs"
                    else v-bc-type)
             )
ListProdbc = buf_prod-bc.b-str
.
DEFINE VARIABLE b-count as integer init 0 no-undo.
DEFINE VARIABLE v-fact-order        like ub.trn-doc.fact-order     no-undo.
run rep/tickets.w (input parparentproc, input p-obj-type, input p-obj-code, input Action, input v-bc-type ).
if TicketName = "" then
    RETURN.
OUTPUT STREAM OutStream TO VALUE( lbc-tmp + "title" ) CONVERT TARGET TitleCP PAGE-SIZE 0 .
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
def var vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
OUTPUT STREAM OutStream CLOSE.
message
  substitute( "Передано на печать &1 этикеток (ценников)", b-count )
  view-as alert-box INFORMATION.
os-command NO-WAIT value( substitute( "start &1run-lbc.bat &1 &2title &3 &4", lbc-path, lbc-tmp, TicketName, v-user-id ) ).
