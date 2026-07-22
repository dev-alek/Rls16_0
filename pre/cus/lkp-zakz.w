define input  parameter parparentproc  as widget-handle no-undo.
define input-output  parameter br-handle as handle no-undo.
define input-output  parameter bf-handle as handle no-undo.
define input-output  parameter next-prev as logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Форма просмотра заказа" .
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
DEFINE SHARED BUFFER   SHAR-BUF_ORD-DOC FOR UB.ORD-DOC.
define buffer   buf_ord-line-attr for ub.ord-line-attr.
define variable head-col        as character no-undo .
define variable v-order-column  as character no-undo .
define variable v-spis-size     as character no-undo .
define variable v-spis-vis      as character no-undo .
define variable hcolumn         as handle extent 100  no-undo.
define variable v-fact-qnty as decimal   no-undo .
define variable t-action as char no-undo.
define variable v-min-stock as decimal   no-undo .
define variable v-gds-way as decimal   no-undo .
t-action = "lkp":u.
define buffer b-goods   for ub.goods .
define buffer b-gds-prt for ub.gds-prt .
define variable x-mode as character  no-undo .
define variable doc-rec as recid no-undo .
define variable curclivalue   as char initial ? no-undo.
define variable curclitype   as character no-undo .
define variable v-loc-contract as character format "x(15)" label "№ дог-ра" fgcolor 1 no-undo .
define temp-table tt-date no-undo
field exch-date as date
index pi is unique primary   exch-date .
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
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable gdsgrp_recids      as character no-undo.
define new shared variable fin-schet-recid    as character no-undo.
define new shared variable v-d-report-handle  as handle    no-undo .
define new shared temp-table g#customer no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define new shared temp-table g#cli no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define new shared temp-table tmp#grp no-undo
    field node-code like ub.gds-grp.node-code
    field grp-name like ub.gds-grp.node-name
    field lvl-num  like ub.gds-grp.lvl-num
    field is-term  like ub.gds-grp.is-term
    index pi is unique primary grp-name node-code
    index i-node-code    node-code
    index level-num   lvl-num  grp-name
    index is-term is-term  grp-name
    .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def
new shared
temp-table  obj-list no-undo
  field obj-type like ub.clients.obj-type
  field obj-code like ub.clients.obj-code
  field obj-name like ub.clients.obj-name
  field obj-id   as integer
  field db-num   as integer
  index pi is primary unique obj-id
  index ie1 obj-type obj-code
  index ie2 obj-name
.
procedure create_obj-list :
   define input parameter p-obj-type like ub.clients.obj-type no-undo .
   define input parameter p-obj-code like ub.clients.obj-code no-undo .
   do
   on error undo, return error return-value
   :
      define buffer cli-obj for ub.clients .
      define variable p-var as integer no-undo .
      define buffer buf_obj-list for obj-list .
      find last buf_obj-list  use-index pi no-error .
      if available buf_obj-list
      then
         p-var = buf_obj-list.obj-id + 1.
      else
         p-var = 1.
      find first cli-obj where
                cli-obj.obj-type = p-obj-type
            and cli-obj.obj-code = p-obj-code
      no-lock no-error.
      if available cli-obj
      then do:
         create buf_obj-list.
         assign
            buf_obj-list.obj-id   = p-var
            buf_obj-list.obj-code = cli-obj.obj-code
            buf_obj-list.obj-type = cli-obj.obj-type
            buf_obj-list.obj-name = cli-obj.obj-name
            buf_obj-list.db-num   = cli-obj.db-num
         .
      end.
   end.
end.
define new shared temp-table X-init_obj-list no-undo
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
index pi is unique primary obj-type obj-code.
define variable p1 like ub.gds-obj.prod-type no-undo.
define variable p2 like ub.gds-obj.prod-code no-undo.
define variable p3 like ub.gds-obj.artic     no-undo.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable to-day       as date no-undo .
define new shared variable str1   as character  no-undo.
define new shared variable str2   as character  no-undo.
define new shared variable str3   as character  no-undo.
define new shared variable str4   as character  no-undo.
define new shared variable ReportNAme   as character  no-undo.
define new shared variable ReportProc   as character  no-undo.
define new shared variable ReportHeader as character  no-undo.
define new shared variable ReportPageWidth  as integer no-undo.
define new shared variable ReportPageHeight as integer no-undo.
define new shared variable ReportFontNum    as integer no-undo.
define new shared variable my-request as logical  init false no-undo.
define new shared variable v-delim as character no-undo .
define new shared variable v-sdate as character no-undo initial "/":U.
define new shared variable v-shortdate as character no-undo initial "dd/mm/yyyy":U .
define new shared variable my-handle  as handle no-undo .
define new shared variable parent-handle  as handle no-undo .
define new shared variable v-show-all-goods as logical  no-undo .
define new shared variable params-only      as logical   no-undo .
define new shared variable params-only-mode as character no-undo .
define new shared variable place-call       as character no-undo .
define new shared variable x-Goods-Editor   as character  no-undo .
define new shared variable x-Date-Alone     as date format "99/99/9999":u   no-undo .
define new shared variable x-Date-End       as date format "99/99/9999":u   no-undo .
define new shared variable x-Date-Start     as date format "99/99/9999":u   no-undo .
define new shared variable x-Shift-Alone    as integer format ">9":u         no-undo .
define new shared variable x-Shift-End      as integer format ">9":u         no-undo .
define new shared variable x-Shift-Start    as integer format ">9":u         no-undo .
define new shared variable x-SelectGood     as integer                      no-undo .
define new shared variable x-SelectObject   as character                          no-undo .
define new shared variable x-SET_PAY_TYPE   as integer  no-undo .
define new shared variable x-SET_val_TYPE   as integer  no-undo .
define new shared variable x-TOG-Shift      as logical  no-undo .
define new shared variable x-Radio-Task     as integer  no-undo .
define new shared variable x-TOG-Excel      as logical  no-undo .
define new shared variable x-TOG-list-hist  as logical  no-undo .
define new shared variable x-text-1 as character  no-undo .
define new shared variable x-text-2 as character  no-undo .
define new shared variable x-text-3 as character  no-undo .
define new shared variable x-text-4 as character  no-undo .
define new shared variable init-date-start  like x-date-start  no-undo .
define new shared variable init-date-end    like x-date-end    no-undo .
define new shared variable init-date-alone  like x-date-alone  no-undo .
define new shared variable init-shift-alone like x-shift-alone no-undo .
define new shared variable init-shift-start like x-shift-start no-undo .
define new shared variable init-shift-end   like x-shift-end   no-undo .
define new shared variable init-set_pay_type like x-set_pay_type   no-undo .
define new shared variable init-set_val_type like x-set_val_type   no-undo .
define new shared variable ref_date-start    as character   no-undo .
define new shared variable ref_date-end      as character   no-undo .
define new shared variable ref_date-alone    as character   no-undo .
define new shared work-table TDEDT  no-undo
  field id as char
  field name as character  format "x(40)"
  field n as character
  .
define variable tempstr as character  no-undo.
define variable b1-name as character  no-undo.
define variable b2-name as character  no-undo.
define variable source-str   as character no-undo .
define variable I#           as integer    no-undo.
define variable p-price-med  as decimal init 0 no-undo .
define new shared variable str-obj-type as character  no-undo.
define new shared variable str-obj-code as character  no-undo.
define new shared variable str-obj-name as character  no-undo.
define new shared variable str-obj      as character  no-undo.
define new shared variable link#        as logical  no-undo init false.
define new shared variable  Verify-Arc-ot      as logical  no-undo init false.
define new shared variable  Verify-Arc-stk     as logical  no-undo init false.
define new shared variable  Verify-Arc-supp    as logical  no-undo init false.
define new shared variable  Verify-Arc-hold    as logical  no-undo init false.
define new shared variable  Verify-Arc-aht     as logical  no-undo init false.
define new shared variable  Verify-send-check  as logical  no-undo init false.
define new shared variable  Verify-Arc-fin     as logical  no-undo init false.
define new shared variable  Verify-Arc-strong  as logical  no-undo init false.
define new shared variable  Show-Crsa         as logical  no-undo init false.
define new shared variable  Show-Cost         as logical  no-undo init false.
define new shared variable  Show-Sale         as logical  no-undo init false.
define new shared variable  Name-Sale-price   as character no-undo .
define new shared variable  Format-Folder     as logical no-undo .
define new shared variable  Print-List-Hist   as logical no-undo init false.
define new shared variable Make-Excel     as logical  no-undo init false.
define new shared variable Make-Excel-com as logical  no-undo init false.
define new shared stream ForExcel.
define new shared variable Use-column   as logical extent 256 no-undo .
define new shared variable right-column as logical extent 256 no-undo .
define new shared temp-table Sheetf no-undo
field Excel-Column-Lable as character
field Excel-Row-Heder    as integer
field Excel-Row-Title    as integer
field Sizes              as character
field Make-correct       as character
field Rights-column      as character
field MergeCellsH        as character
field MergeCellsV        as character
field sheet-num          as integer
field ColFormat          as character
field Bas-FIle           as character
field Bas-Params         as character
field Bas-Param-Add      as logical
field File-name          as character
field Silent-save        as logical
index pi as primary unique
      sheet-num
.
  create Sheetf.
  assign
  sheetf.sheet-num = 1.
define variable l-stroka as character no-undo .
define new shared  variable ch#ExcelApplication as com-handle no-undo .
define new shared  variable ch#Workbook         as com-handle no-undo .
define new shared  variable ch#Worksheet        as com-handle no-undo .
define new shared  variable Num#Str#            as integer no-undo.
define new shared  variable Number-List         as integer no-undo init 1.
define new shared  variable v-excel-file        as character no-undo .
define variable Col-name as character  extent 256.
define variable Col-format as character  extent 256.
define variable Col-Post-format as character  extent 256.
run proc-page0-assign in this-procedure .
define variable v-del-1 as character no-undo .
if  v-delim = " " or v-delim = ? or v-delim = ""  then do:
    run gbl/getlocal.p ( output v-delim  , output v-del-1, output v-sdate, output v-shortdate ) no-error .
    if error-status :error then do:
      message error-status :error error-status :get-message(1)
              v-delim v-del-1.
        v-delim = ','  .
    end.
end.
procedure proc-page0-assign :
 do
 on error undo, return error return-value
 :
Assign
  Col-name[1] = 'A':U
  Col-name[2] = 'B':U
  Col-name[3] = 'C':U
  Col-name[4] = 'D':U
  Col-name[5] = 'E':U
  Col-name[6] = 'F':U
  Col-name[7] = 'G':U
  Col-name[8] = 'H':U
  Col-name[9] = 'I':U
  Col-name[10]= 'J':U
  Col-name[11]= 'K':U
  Col-name[12]= 'L':U
  Col-name[13]= 'M':U
  Col-name[14]= 'N':U
  Col-name[15]= 'O':U
  Col-name[16]= 'P':U
  Col-name[17]= 'Q':U
  Col-name[18]= 'R':U
  Col-name[19]= 'S':U
  Col-name[20]= 'T':U
  Col-name[21]= 'U':U
  Col-name[22]= 'V':U
  Col-name[23]= 'W':U
  Col-name[24]= 'X':U
  Col-name[25]= 'Y':U
  Col-name[26]= 'Z':U
  Col-name[27]= 'AA':U
  Col-name[28]= 'AB':U
  Col-name[29]= 'AC':U
  Col-name[30]= 'AD':U
  Col-name[31]= 'AE':U
  Col-name[32]= 'AF':U
  Col-name[33]= 'AG':U
  Col-name[34]= 'AH':U
  Col-name[35]= 'AI':U
  Col-name[36]= 'AJ':U
  Col-name[37]= 'AK':U
  Col-name[38]= 'AL':U
  Col-name[39]= 'AM':U
  Col-name[40]= 'AN':U
  Col-name[41]= 'AO':U
  Col-name[42]= 'AP':U
  Col-name[43]= 'AQ':U
  Col-name[44]= 'AR':U
  Col-name[45]= 'AS':U
  Col-name[46]= 'AT':U
  Col-name[47]= 'AU':U
  Col-name[48]= 'AV':U
  Col-name[49]= 'AW':U
  Col-name[50]= 'AX':U
  Col-name[51]= 'AY':U
  Col-name[52]= 'AZ':U
  Col-name[53]= 'BA':U
  Col-name[54]= 'BB':U
  Col-name[55]= 'BC':U
  Col-name[56]= 'BD':U
  Col-name[57]= 'BE':U
  Col-name[58]= 'BF':U
  Col-name[59]= 'BG':U
  Col-name[60]= 'BH':U
  Col-name[61]= 'BI':U
  Col-name[62]= 'BJ':U
  Col-name[63]= 'BK':U
  Col-name[64]= 'BL':U
  Col-name[65]= 'BM':U
  Col-name[66]= 'BN':U
  Col-name[67]= 'BO':U
  Col-name[68]= 'BP':U
  Col-name[69]= 'BQ':U
  Col-name[70]= 'BR':U
  Col-name[71]= 'BS':U
  Col-name[72]= 'BT':U
  Col-name[73]= 'BU':U
  Col-name[74]= 'BV':U
  Col-name[75]= 'BW':U
  Col-name[76]= 'BX':U
  Col-name[77]= 'BY':U
  Col-name[78]= 'BZ':U
  Col-name[79]= 'CA':U
  Col-name[80]= 'CB':U
  Col-name[81]= 'CC':U
  Col-name[82]= 'CD':U
  Col-name[83]= 'CE':U
  Col-name[84]= 'CF':U
  Col-name[85]= 'CG':U
  Col-name[86]= 'CH':U
  Col-name[87]= 'CI':U
  Col-name[88]= 'CJ':U
  Col-name[89]= 'CK':U
  Col-name[90]= 'CL':U
  Col-name[91]= 'CM':U
  Col-name[92]= 'CN':U
  Col-name[93]= 'CO':U
  Col-name[94]= 'CP':U
  Col-name[95]= 'CQ':U
  Col-name[96]= 'CR':U
  Col-name[97]= 'CS':U
  Col-name[98]= 'CT':U
  Col-name[99]= 'CU':U
  Col-name[100]= 'CV':U
Col-name[101]= 'CW':U
Col-name[102]= 'CX':U
Col-name[103]= 'CY':U
Col-name[104]= 'CZ':U
Col-name[105]= 'DA':U
Col-name[106]= 'DB':U
Col-name[107]= 'DC':U
Col-name[108]= 'DD':U
Col-name[109]= 'DE':U
Col-name[110]= 'DF':U
Col-name[111]= 'DG':U
Col-name[112]= 'DH':U
Col-name[113]= 'DI':U
Col-name[114]= 'DJ':U
Col-name[115]= 'DK':U
Col-name[116]= 'DL':U
Col-name[117]= 'DM':U
Col-name[118]= 'DN':U
Col-name[119]= 'DO':U
Col-name[120]= 'DP':U
Col-name[121]= 'DQ':U
Col-name[122]= 'DR':U
Col-name[123]= 'DS':U
Col-name[124]= 'DT':U
Col-name[125]= 'DU':U
Col-name[126]= 'DV':U
Col-name[127]= 'DW':U
Col-name[128]= 'DX':U
Col-name[129]= 'DY':U
Col-name[130]= 'DZ':U
Col-name[131]= 'EA':U
Col-name[132]= 'EB':U
Col-name[133]= 'EC':U
Col-name[134]= 'ED':U
Col-name[135]= 'EE':U
Col-name[136]= 'EF':U
Col-name[137]= 'EG':U
Col-name[138]= 'EH':U
Col-name[139]= 'EI':U
Col-name[140]= 'EJ':U
Col-name[141]= 'EK':U
Col-name[142]= 'EL':U
Col-name[143]= 'EM':U
Col-name[144]= 'EN':U
Col-name[145]= 'EO':U
Col-name[146]= 'EP':U
Col-name[147]= 'EQ':U
Col-name[148]= 'ER':U
Col-name[149]= 'ES':U
Col-name[150]= 'ET':U
Col-name[151]= 'EU':U
Col-name[152]= 'EV':U
Col-name[153]= 'EW':U
Col-name[154]= 'EX':U
Col-name[155]= 'EY':U
Col-name[156]= 'EZ':U
Col-name[157]= 'FA':U
.
assign
  Col-name[158]= 'FB':U
  Col-name[159]= 'FC':U
  Col-name[160]= 'FD':U
  Col-name[161]= 'FE':U
  Col-name[162]= 'FF':U
  Col-name[163]= 'FG':U
  Col-name[164]= 'FH':U
  Col-name[165]= 'FI':U
  Col-name[166]= 'FJ':U
  Col-name[167]= 'FK':U
  Col-name[168]= 'FL':U
  Col-name[169]= 'FM':U
  Col-name[170]= 'FN':U
  Col-name[171]= 'FO':U
  Col-name[172]= 'FP':U
  Col-name[173]= 'FQ':U
  Col-name[174]= 'FR':U
  Col-name[175]= 'FS':U
  Col-name[176]= 'FT':U
  Col-name[177]= 'FU':U
  Col-name[178]= 'FV':U
  Col-name[179]= 'FW':U
  Col-name[180]= 'FX':U
  Col-name[181]= 'FY':U
  Col-name[182]= 'FZ':U
  Col-name[183]= 'GA':U
  Col-name[184]= 'GB':U
  Col-name[185]= 'GC':U
  Col-name[186]= 'GD':U
  Col-name[187]= 'GE':U
  Col-name[188]= 'GF':U
  Col-name[189]= 'GG':U
  Col-name[190]= 'GH':U
  Col-name[191]= 'GI':U
  Col-name[192]= 'GJ':U
  Col-name[193]= 'GK':U
  Col-name[194]= 'GL':U
  Col-name[195]= 'GM':U
  Col-name[196]= 'GN':U
  Col-name[197]= 'GO':U
  Col-name[198]= 'GP':U
  Col-name[199]= 'GQ':U
  Col-name[200]=   'GR':U
  Col-name[201]=   'GS':U
  Col-name[202]=   'GT':U
  Col-name[203]=   'GU':U
  Col-name[204]=   'GV':U
  Col-name[205]=   'GW':U
  Col-name[206]=   'GX':U
  Col-name[207]=   'GY':U
  Col-name[208]=   'GZ':U
  Col-name[209]=   'HA':U
  Col-name[210]=   'HB':U
  Col-name[211]=   'HC':U
  Col-name[212]=   'HD':U
  Col-name[213]=   'HE':U
  Col-name[214]=   'HF':U
  Col-name[215]=   'HG':U
  Col-name[216]=   'HH':U
  Col-name[217]=   'HI':U
  Col-name[218]=   'HJ':U
  Col-name[219]=   'HK':U
  Col-name[220]=   'HL':U
  Col-name[221]=   'HM':U
  Col-name[222]=   'HN':U
  Col-name[223]=   'HO':U
  Col-name[224]=   'HP':U
  Col-name[225]=   'HQ':U
  Col-name[226]=   'HR':U
  Col-name[227]=   'HS':U
  Col-name[228]=   'HT':U
  Col-name[229]=   'HU':U
  Col-name[230]=   'HV':U
  Col-name[231]=   'HW':U
  Col-name[232]=   'HX':U
  Col-name[233]=   'HY':U
  Col-name[234]=   'HZ':U
  Col-name[235]=   'IA':U
  Col-name[236]=   'IB':U
  Col-name[237]=   'IC':U
  Col-name[238]=   'ID':U
  Col-name[239]=   'IE':U
  Col-name[240]=   'IF':U
  Col-name[241]=   'IG':U
  Col-name[242]=   'IH':U
  Col-name[243]=   'II':U
  Col-name[244]=   'IJ':U
  Col-name[245]=   'IK':U
  Col-name[246]=   'IL':U
  Col-name[247]=   'IM':U
  Col-name[248]=   'IN':U
  Col-name[249]=   'IO':U
  Col-name[250]=   'IP':U
  Col-name[251]=   'IQ':U
  Col-name[252]=   'IR':U
  Col-name[253]=   'IS':U
  Col-name[254]=   'IT':U
  Col-name[255]=   'IU':U
  Col-name[256]=   'IV':U
  .
 end.
end procedure.
define variable var-report-r-b as character no-undo .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table tmp#zakaz1 no-undo like ub.ord-line field sum       as decimal   field all-day   as integer   field qnty-sale as decimal   field negative-rest as logical    field gds-name  as character field unit-base as character field unit-type as character field unit-cli-type as character field min-order     as decimal   field service-order as decimal field local-mark    as character field max-stock     as decimal   field season-coef   as decimal   field min-stock-old as decimal   field gds-way       as decimal   index pi is unique primary artic prod-type prod-code  ascending index idx-ln line-num.
define new shared temp-table tmp#zakaz-prn1 no-undo field artic         like ub.goods.artic      field prod-type     like ub.goods.prod-type  field prod-code     like ub.goods.prod-code  field obj-type      like ub.clients.obj-type field obj-code      like ub.clients.obj-code field prt-code      as   integer    field qnty-sale     as   decimal    field qnty-ord      as   decimal    index pi is unique primary artic prod-type prod-code obj-type obj-code prt-code  ascending.
define new shared temp-table tmp#zakaz-dtl1 no-undo like ub.ord-dtl field prt-name as character index bi is unique primary artic prod-type prod-code node-code  ascending.
define new shared buffer clients-doc for ub.clients   .
define  buffer clients-doc1 for ub.clients   .
define  buffer clients-doc2 for ub.clients   .
define new shared buffer buf-goods   for ub.goods     .
define new shared buffer sb-cli-gds  for ub.cli-gds   .
define new shared buffer sb-gds-obj  for ub.gds-obj   .
define new shared buffer tmp#zakaz     for tmp#zakaz1.
define new shared buffer tmp#zakaz-prn     for tmp#zakaz-prn1.
define new shared buffer tmp#zakaz-dtl for tmp#zakaz-dtl1.
define buffer buf_contract for ub.contract .
define new shared  buffer shar_ord-doc  for ub.ord-doc .
define new shared  buffer shar_ord-line for ub.ord-line.
define new shared  buffer shar_ord-dtl  for ub.ord-dtl .
define new shared variable chexcelapplication      as com-handle no-undo .
define new shared variable chworkbook              as com-handle no-undo .
define new shared variable chworksheet             as com-handle no-undo .
define new shared variable chrange                 as com-handle no-undo .
define new shared variable chworksheet2            as com-handle no-undo .
define new shared variable chworksheet3            as com-handle no-undo .
define new shared variable accum-zakaz             as decimal no-undo .
define new shared variable accum-sum-zakaz         as decimal no-undo .
define new shared variable accum-count             as integer no-undo .
define new shared buffer buf-cli for ub.clients.
define new shared variable loc-obj-name as character format "x(256)":u
     view-as text
     size 39.25 by 1 tooltip "Поставщик"
     fgcolor 4  no-undo.
define new shared variable agnt as integer format ">>>>>>>>>" initial ?
     label "И&сп"
     view-as fill-in tooltip "Код исполнителя"
     size 9.75 by 1 no-undo.
define new shared  variable boss as integer format ">>>>>>>>>" initial ?
     label "&М-р"
     view-as fill-in    tooltip "Код менеджера"
     size 9.75 by 1 no-undo.
define  new  shared  variable date-1 as date format "99/99/9999":u
     label "Период с"
     view-as fill-in   tooltip "Период, для которого рассчитан темп продаж"
     size 11 by 1 fgcolor 1 no-undo.
define  new  shared  variable date-2 as date format "99/99/9999":u
     label "по"
     view-as fill-in  tooltip "Период, для которого рассчитан темп продаж"
     size 11 by 1 fgcolor 1 no-undo.
define  new  shared  variable date-sale-1 as date format "99/99/9999":u
     label "Для продажи с"
     view-as fill-in   tooltip "Период продаж товара"
     size 11 by 1  no-undo.
define  new  shared  variable date-sale-2 as date format "99/99/9999":u
     label "по"
     view-as fill-in  tooltip "Период продаж товара"
     size 11 by 1  no-undo.
define  new  shared  variable loc-cli-code as integer format ">>>>>>>>>" initial ?
     view-as fill-in
     size 9.75 by 1 tooltip "Код Поставщика" no-undo.
define  new  shared  variable loc-cli-type as character format "x(3)":u initial "орг"
     label "Код"
     view-as fill-in
     size 5.13 by 1 tooltip "Тип Поставщика" no-undo.
define  new  shared  variable loc-date-ship as date format "99/99/9999":u
     label "&Заказ на"
     view-as fill-in
     size 11 by 1 tooltip "Дата, на которую формируется заказ"
     fgcolor 4
     no-undo.
define  new  shared  variable loc-ord-num as character format "x(256)":u
     label "№"
     view-as text
     size 14 by 1
     fgcolor 4
     no-undo.
define  new  shared  variable wrkr as integer format ">>>>>>>>>" initial ?
     label "К&л-к"
     view-as fill-in
     size 9.75 by 1 tooltip "Код кладовщика"
     no-undo.
define  new  shared  variable loc-service as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Ст-ть обслу&живания"
     view-as fill-in
     size 14 by 1 tooltip "Стоимость обслуживания" no-undo.
define  new  shared  variable paytype as integer format "99999" initial ?
     label "Опл"
     view-as fill-in
     size 7.75 by 1 tooltip "Код типа оплаты"
     no-undo.
define new  shared  variable loc-time-ship as character
      view-as fill-in
      size 7 by 1 tooltip "Время доставки" no-undo.
define new  shared  variable loc-hour as integer format "99":u initial 0
     view-as fill-in
     size 3.5 by 1 no-undo.
define new  shared  variable loc-min as integer format "99":u initial 0
     view-as fill-in
     size 3.5 by 1 no-undo.
define new  shared  variable cycle-day as integer format ">>>":u initial 0
     label "через"
     view-as fill-in
     size 4.75 by 1
     fgcolor 4
     no-undo.
define new shared  variable pay-day as integer format ">>9":u initial 1
     label "На дней продаж"
     view-as fill-in
     size 7.13 by 1
     fgcolor 4
     no-undo.
define  new  shared  variable tog-type as int initial 0
     label "цкл"
     view-as radio-set horizontal radio-buttons
     "П",0,
     "Ц",1,
     "О",4
     size 11 by 1 tooltip "Тип заказа : простой,цикличный,объединенный цикличный" no-undo.
define new shared variable loc-status  as character  no-undo.
define new shared variable loc-base-rate as decimal format "->,>>>,>>>,>>>,>>9.9999":u initial 0
     label "Кур&с б.в."
     view-as fill-in
     size 9.4 by 1 no-undo.
define new shared variable loc-base-scale as integer format ">,>>>,>>9":u initial 0
     label "М&-б"
     view-as fill-in
     size 3.5 by 1 no-undo.
define new shared variable loc-cli-qnty as decimal format "->,>>>,>>>,>>>,>>9.999":u initial 0
     label "Кол.п-ка"
     view-as text
     size 14 by 0.67
     tooltip "Количество в ед.из. поставщика"
     fgcolor 4
     no-undo.
define new shared variable loc-exch-code as integer format "->,>>>,>>9":u initial 0
     label "Вал&."
     view-as fill-in
     size 7 by 1
     no-undo.
define new shared variable loc-exch-rate as decimal format "->,>>>,>>>,>>>,>>9.9999":u initial 0
     label "Курс п&-ка"
     view-as fill-in
     size 9.4 by 1
     no-undo.
define new shared variable loc-exch-scale as integer format ">,>>>,>>9":u initial 0
     label "М&-б"
     view-as fill-in
     size 3.5 by 1
     no-undo.
define new shared variable loc-out-code as character format "x(256)":u
     label "№ Поставки"
     view-as fill-in
     size 9.38 by 1 tooltip "Номер документа поставки по данному заказу"
     no-undo.
define new shared variable loc-cli-out-doc  as character format "x(256)":u
     label "№ Заказа по пост"
     view-as fill-in
     size 14 by 1 tooltip "Номер заказа в системе учета поставщика"
     no-undo.
define new shared variable loc-qnty as decimal format "->,>>>,>>>,>>>,>>9.999":u initial 0
     label "Кол-во"
     view-as text
     size 14 by 0.67 tooltip "Количество по заказу в баз.ед."
     fgcolor 4
     no-undo.
define new shared variable loc-sum-base as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Сумма заказа(б.в.)"
     view-as text
     size 14 by 0.67 tooltip "Сумма заказа(б.в.)"
     fgcolor 4
     no-undo.
define new shared variable loc-sum-cli as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Сумма заказа(в.п.)"
     view-as text
     size 14 by 0.67 tooltip "Сумма заказа в вал. поставщика"
     fgcolor 4
     no-undo.
define new shared variable loc-sum-rubl as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Сумма заказа(руб.)"
     view-as text
     size 14 by 0.67 tooltip "Сумма заказа(руб)"
     fgcolor 4
     no-undo.
define new shared variable loc-tot-lines as integer format "->,>>>,>>9":u initial 0
     label "Строк"
     view-as text
     size 7.38 by .67 tooltip "Контрольное количество строк в заказе"
     fgcolor 4
     no-undo.
define new shared variable doc-date as date format "99/99/99":u
     label "&Дата"
     view-as text
     size 9 by .67 tooltip "Дата документа"
     no-undo.
define new shared variable fact-date as date format "99/99/99":u
     label "&Факт"
     view-as text
     size 9 by .67 tooltip "Дата документа фактическая"
     fgcolor 4
     no-undo.
define new shared var loc-print-rubl as logical no-undo .
define new shared variable slt_type as character format "x(256)":u
     label "НсП"
     view-as combo-box inner-lines 3
     list-items
        'без':U,
        'нет':U,
        'в т. ч.':U
     size 9.75 by 1
     no-undo.
define new shared  variable vat_type as character format "x(256)":u
     label "НДС"
     view-as combo-box inner-lines 3
     list-items
        'без':U,
        'нет':U,
        'в т. ч.':U
     size 9.75 by 1
     no-undo.
define new shared  variable e-method as character
     view-as editor scrollbar-vertical
     size 30 by 3.42 tooltip "Метод расчета темпа продаж и количества заказа/заявки"
     bgcolor 8
     no-undo.
define  new  shared  variable loc-contract as integer
     label "Вн.№ дог-ра"
     view-as fill-in
     size 10 by 1 tooltip "Номер договора"
     format ">>>>>>>>>"
     fgcolor 1
     no-undo.
define new shared  variable loc-store-code like ub.ord-doc.obj-code no-undo .
define new shared  variable loc-store-type like ub.ord-doc.obj-type no-undo .
define new shared  variable loc-doc-type   like ub.ord-doc.doc-type no-undo .
define new shared  variable temp-e-method  as character no-undo .
define new shared  variable x-tog-artic as logical   no-undo .
define new shared  variable x-tog-grp    as logical   no-undo .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
function cross-list returns logical (
  input parfirst-stream  as character,
  input parsecond-stream as character,
  input pardelim         as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  define variable vari            as integer no-undo .
  define variable varresult-cross as logical no-undo .
  assign
    varresult-cross = no
  .
  def var v-num-parfirst-stream as integer no-undo .
  assign
    v-num-parfirst-stream = num-entries(parfirst-stream, pardelim)
  .
  do vari = 1 to v-num-parfirst-stream
  :
    if lookup(entry(vari, parfirst-stream, pardelim)
             ,parsecond-stream
             ,pardelim
             ) > 0 then do:
      assign
        varresult-cross = yes
      .
      leave.
    end.
  end.
  return varresult-cross .
end function.
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-uf-List_        like ubflt.usr-flt.List_        no-undo .
define variable v-uf-Naim         like ubflt.usr-flt.Naim         no-undo .
define variable v-uf-print-graft  like ubflt.usr-flt.print-Graft  no-undo .
define variable v-uf-sort-gr      like ubflt.usr-flt.sort-gr      no-undo .
define variable v-uf-type-price   like ubflt.usr-flt.type-price   no-undo .
define variable v-uf-type-val     like ubflt.usr-flt.type-val     no-undo .
define temp-table usr-flt_custom-labels no-undo like ub.custom-labels.
procedure uf-name :
  define input  parameter p-code         like ubflt.usr-flt.call-point   no-undo .
  define output parameter p-use-List_     as logical   no-undo .
  define output parameter p-type-List_     as character no-undo .
  define output parameter p-format-List_   as character no-undo .
  define output parameter p-use-Naim      as logical   no-undo .
  define output parameter p-type-Naim      as character no-undo .
  define output parameter p-format-Naim    as character no-undo .
  define output parameter p-use-print-graft as logical   no-undo .
  define output parameter p-use-sort-gr   as logical   no-undo .
  define output parameter p-use-type-price as logical   no-undo .
  define output parameter p-use-type-val  as logical   no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-tooltip        as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
    case p-code :
            when 'cli-all-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника клиентов"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника клиентов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'oldscode':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Настройки справочника неиспользуемых весовых кодов"     p-tooltip = "Настройки справочника неиспользуемых весовых кодов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gds-ref-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(8)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = yes      p-label = "Параметры вызова справочника товаров"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника товаров"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gds-grp-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника групп товаров"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника групп товаров"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'fbr-gds-grp-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника групп блюд"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника групп блюд"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-grp-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника групп клиентов"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника групп клиентов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'findoci-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова карточки платежа"     p-tooltip = "Параметры по умолчанию, используемые для вызова карточки платежа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'findocs-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника платежей"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника платежей"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'fin-obi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова карточки платежа"     p-tooltip = "Параметры по умолчанию, используемые для вызова карточки платежа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'seqeallo':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Порядок колонок в АВТО-ЗАКАЗЕ"     p-tooltip = "Порядок колонок в РАСЧЕТЕ потребности заказа и его импорте"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'skm-rep':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова выгрузки файла данных по продажам по СКМ"     p-tooltip = "Параметры по умолчанию, используемые для вызова выгрузки файла данных по продажам по СКМ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'imp-goods':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Импорт в карточке товара"     p-tooltip = "Заполнение по умолчанию параметров импорта товаров из карточки товара"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'discards-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Справочник ДК"     p-tooltip = "Справочник дисконтных карт"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'finsttms-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника банковских выписок"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника банковских выписок"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'fin-ob-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список фин.обязательств"     p-tooltip = "Список фин.обязательств"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'mpl-gds-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список цен по товару"     p-tooltip = "Список цен по товару"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'tpl-mode-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список мод"     p-tooltip = "Список мод"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'ord-sost-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Состояние заказа"     p-tooltip = "Просмотр несоответствий поставок и накладных по заказам ОП ФП и ПО"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'all-docs-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список накладных"     p-tooltip = "Список накладных"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'planplat-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Планирование платежей"     p-tooltip = "Планирование платежей"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа"     p-tooltip = "Форма ввода заказа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-pОП':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа ОП"     p-tooltip = "Форма ввода заказа ОП"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-pФП':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа ФП"     p-tooltip = "Форма ввода заказа ФП"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-pОФ':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа ОФ"     p-tooltip = "Форма ввода заказа ОФ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'list-abc-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список заголовков ABC-анализа"     p-tooltip = "Список заголовков ABC-анализа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'abc-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "ABC-анализ"     p-tooltip = "ABC-анализ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'ord-rc-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Заказ О-РЦ"     p-tooltip = "Заказ О-РЦ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cfin-ob-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список удаленных фин.обязательств"     p-tooltip = "Список удаленных фин.обязательств"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'color-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = yes      p-use-type-price = no      p-use-type-val = no      p-label = "Раскрасить экран"     p-tooltip = "Изменение цветовой палитры брауза"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'bon1-rep':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "НАЧИСЛЕНИЕ И СПИСАНИЕ БОНУСОВ по программе БОНУС-КЛУБ"     p-tooltip = "Параметры вызова отчета НАЧИСЛЕНИЕ И СПИСАНИЕ БОНУСОВ по программе БОНУС-КЛУБ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-shift':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Сменный отчет"     p-tooltip = "Сменный отчет"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'all-docs-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список накладных"     p-tooltip = "Список накладных"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gdsreffi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Справочник товаров - доп поля"     p-tooltip = "Справочник товаров - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gdsfrmfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Карточка товара - доп поля"     p-tooltip = "Карточка товара - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'contspec-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Спецификация"     p-tooltip = "Спецификаци "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'contspec-g':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Спецификация"     p-tooltip = "Спецификаци "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthrst':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = YES      p-use-sort-gr = YES      p-use-type-price = YES      p-use-type-val =       p-label = "Остатки МЦ"     p-tooltip = "Остатки МЦ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthcom':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = YES      p-use-sort-gr = YES      p-use-type-price = no      p-use-type-val =       p-label = "Сводный отчет о реализованных талонах"     p-tooltip = "Сводный отчет о реализованных талонах"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'users-1':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Пользователи"     p-tooltip = "Список пользователей системы 1"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'users-2':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Пользователи"     p-tooltip = "Список пользователей системы 2"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'bge-dper.w':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Параметры для выгрузки документов"     p-tooltip = "Параметры для выгрузки документов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
             when 'bge-active-vbrr':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Параметры для выгрузки документов"     p-tooltip = "Параметры для выгрузки документов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'bge-dper-new':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Параметры для выгрузки документов(расширенный)"     p-tooltip = "Параметры для выгрузки документов(расширенный)"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cus/i-egais.w':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Интерфейс импорта классификатора ЕГАИС"     p-tooltip = "Интерфейс импорта классификатора ЕГАИС"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'alc-rees':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Реестр документов ЕГАИС"     p-tooltip = "Реестр документов ЕГАИС"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-optprc.w':U then do:     assign     p-use-List_ = no      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = yes      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Оптовый прайс-лист"     p-tooltip = "Оптовый прайс-лист"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cus/iecliart.w':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Процедуры импорта экспорта артикулов поставщиков"     p-tooltip = "Процедуры импорта экспорта артикулов поставщиков"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-exp-sl-1':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = YES      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Выгрузка для Nielsen 1"     p-tooltip = "Выгрузка для Nielsen 1"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-exp-sl-2':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Выгрузка для Nielsen 1"     p-tooltip = "Выгрузка для Nielsen 2"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when '':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Выгрузка для Nielsen 1"     p-tooltip = "Выгрузка для Nielsen 2"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthps-zone':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthparts-obj':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when '&bef-wthsref-stts}':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthrd':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthob':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthref-type':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthref-stts':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wrsttl1':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = yes      p-use-sort-gr = yes      p-use-type-price = yes      p-use-type-val =       p-label = "Реестр отоваренных талонов"     p-tooltip = "Реестр отоваренных талонов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wrsttl2':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Реестр отоваренных талонов"     p-tooltip = "Реестр отоваренных талонов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthobr-sup':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Оборотная ведомость серийных МЦ по контрагентам"     p-tooltip = "Оборотная ведомость серийных МЦ по контрагентам"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthobr-wth':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Оборотная ведомость серийных МЦ по контрагентам"     p-tooltip = "Оборотная ведомость серийных МЦ по контрагентам"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-ptlbal':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Оперативный балансовый отчет движения нефтепродуктов"     p-tooltip = "Оперативный балансовый отчет движения нефтепродуктов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'ctrasm':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Контроль ассортиментной матрицы"     p-tooltip = "Контроль ассортиментной матрицы"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-eslg-e':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Оперативный балансовый отчет движения нефтепродуктов"     p-tooltip = "Оперативный балансовый отчет движения нефтепродуктов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'prphoto':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(2256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(2256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Прайс-лист с фото товаров"     p-tooltip = "Прайс-лист с фото товаров"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'chkgdsfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Товарная строка чека - доп поля"     p-tooltip = "Товарная строка чека - доп поля "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'chkdocfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Чек - доп поля"     p-tooltip = "Чек - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'barcodfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Бар-код - доп поля"     p-tooltip = "Бар-код - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
             when 'UPD':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Настройки справочника Электронного документоборота"     p-tooltip = "Настройки справочника Электронного документоборота"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'LK_RECEIPT':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Настройки справочника документов Вывода из оборота (ОСУ)"     p-tooltip = "Настройки справочника документов Вывода из оборота (ОСУ)"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
      otherwise do:
        undo, return error "неизвестная настройка пользователя usr-flt" + " " + p-code .
      end.
    end CASE.
  end.
end procedure.
procedure uf-get :
  define input  parameter p-code         like ubflt.usr-flt.call-point   no-undo .
  define input  parameter p-user-name    like ubflt.usr-flt.user-name    no-undo .
  define output parameter p-List_        like ubflt.usr-flt.List_        no-undo .
  define output parameter p-Naim         like ubflt.usr-flt.Naim         no-undo .
  define output parameter p-print-graft  like ubflt.usr-flt.print-Graft  no-undo .
  define output parameter p-sort-gr      like ubflt.usr-flt.sort-gr      no-undo .
  define output parameter p-type-price   like ubflt.usr-flt.type-price   no-undo .
  define output parameter p-type-val     like ubflt.usr-flt.type-val     no-undo .
  do
  on error undo, return error
  :
    define buffer buf_usr-flt for ubflt.usr-flt .
    define variable v-use-List_     as logical   no-undo .
    define variable v-type-List_     as character no-undo .
    define variable v-format-List_   as character no-undo .
    define variable v-use-Naim      as logical   no-undo .
    define variable v-type-Naim      as character no-undo .
    define variable v-format-Naim    as character no-undo .
    define variable v-use-print-graft as logical   no-undo .
    define variable v-use-sort-gr     as logical   no-undo .
    define variable v-use-type-price  as logical   no-undo .
    define variable v-use-type-val    as logical   no-undo .
    define variable v-label          as character no-undo .
    define variable v-tooltip        as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run uf-name in this-procedure
       (input  entry(1, p-code, chr(4))
      ,output v-use-List_
      ,output v-type-List_
      ,output v-format-List_
      ,output v-use-Naim
      ,output v-type-Naim
      ,output v-format-Naim
      ,output v-use-print-graft
      ,output v-use-sort-gr
      ,output v-use-type-price
      ,output v-use-type-val
      ,output v-label
      ,output v-tooltip
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_usr-flt no-lock where
               buf_usr-flt.Call-point     = p-code AND
               buf_usr-flt.user-name       = p-user-name
      no-error .
    if avail buf_usr-flt then do:
      assign
      p-List_        = (if v-use-List_       then buf_usr-flt.List_       else ?)
      p-Naim         = (if v-use-Naim        then buf_usr-flt.Naim        else ?)
      p-print-graft  = (if v-use-print-graft then buf_usr-flt.print-graft else ?)
      p-sort-gr      = (if v-use-sort-gr     then buf_usr-flt.sort-gr     else ?)
      p-type-price   = (if v-use-type-price  then buf_usr-flt.type-price  else ?)
      p-type-val     = (if v-use-List_       then buf_usr-flt.type-val    else ?)
      .
    end.
    else do:
      assign
      p-List_        = (if v-use-List_       then "":U                    else ?)
      p-Naim         = (if v-use-Naim        then "":U                    else ?)
      p-print-graft  = (if v-use-print-graft then no                      else ?)
      p-sort-gr      = (if v-use-sort-gr     then no                      else ?)
      p-type-price   = (if v-use-type-price  then no                      else ?)
      p-type-val     = (if v-use-List_       then no                      else ?)
      .
    end.
  end.
end procedure.
procedure uf-set :
  define input  parameter p-code         like ubflt.usr-flt.call-point   no-undo .
  define input  parameter p-user-name    like ubflt.usr-flt.user-name    no-undo .
  define input  parameter p-List_        like ubflt.usr-flt.List_        no-undo .
  define input  parameter p-Naim         like ubflt.usr-flt.Naim         no-undo .
  define input  parameter p-print-graft  like ubflt.usr-flt.print-Graft  no-undo .
  define input  parameter p-sort-gr      like ubflt.usr-flt.sort-gr      no-undo .
  define input  parameter p-type-price   like ubflt.usr-flt.type-price   no-undo .
  define input  parameter p-type-val     like ubflt.usr-flt.type-val     no-undo .
  do
  on error undo, return error
  :
    define buffer buf_usr-flt for ubflt.usr-flt .
    define variable v-use-List_     as logical   no-undo .
    define variable v-type-List_     as character no-undo .
    define variable v-format-List_   as character no-undo .
    define variable v-use-Naim      as logical   no-undo .
    define variable v-type-Naim      as character no-undo .
    define variable v-format-Naim    as character no-undo .
    define variable v-use-print-graft as logical   no-undo .
    define variable v-use-sort-gr   as logical   no-undo .
    define variable v-use-type-price as logical   no-undo .
    define variable v-use-type-val  as logical   no-undo .
    define variable v-tooltip        as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run uf-name in this-procedure
      (input  entry(1, p-code, chr(4))
      ,output v-use-List_
      ,output v-type-List_
      ,output v-format-List_
      ,output v-use-Naim
      ,output v-type-Naim
      ,output v-format-Naim
      ,output v-use-print-graft
      ,output v-use-sort-gr
      ,output v-use-type-price
      ,output v-use-type-val
      ,output v-label
      ,output v-tooltip
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_usr-flt where
               buf_usr-flt.Call-point     = p-code AND
               buf_usr-flt.user-name       = p-user-name
      no-error .
    if not avail buf_usr-flt then do:
        create buf_usr-flt .
        assign
        buf_usr-flt.call-point = p-code
        buf_usr-flt.user-name  = p-user-name
        .
    end.
    if avail buf_usr-flt then do:
     assign
     buf_usr-flt.List_       =  (if v-use-List_       then  p-List_        else ?)
     buf_usr-flt.Naim        =  (if v-use-Naim        then  p-Naim         else ?)
     buf_usr-flt.print-graft =  (if v-use-print-graft then  p-print-graft  else ?)
     buf_usr-flt.sort-gr     =  (if v-use-sort-gr     then  p-sort-gr      else ?)
     buf_usr-flt.type-price  =  (if v-use-type-price  then  p-type-price   else ?)
     buf_usr-flt.type-val    =  (if v-use-List_       then  p-type-val     else ?)
    .
    release buf_usr-flt.
    end.
    else undo, return error ("Ошибка при записи usr-flt" + substitute(" call-point=&1, user-name=&2", p-code, p-user-name)).
  end.
end procedure.
define variable g#host-code    as integer   no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable g#log      as logical   no-undo .
define variable g#report-num as integer   no-undo .
define variable base-code as integer   no-undo .
define variable gds-rec as recid no-undo .
define variable g#type as character no-undo .
define variable rep-rec2 as recid no-undo .
define variable v-deliv-type-code    as integer   no-undo .
define variable v-point-obj-code     as integer   no-undo .
define variable v-point-cli-code     as integer   no-undo .
define variable v-point-obj-db-num   as integer   no-undo .
define variable v-point-cli-db-num   as integer   no-undo .
define variable v-transport-host-code     as integer   no-undo .
define variable v-transport-cli-type     as character no-undo .
define variable v-transport-cli-code     as integer   no-undo .
define variable v-transport-contract   as integer   no-undo .
define variable v-transport-condition  as integer   no-undo .
define variable v-transport-value      as decimal   no-undo .
define variable v-transport-sum        as decimal   no-undo .
define variable v-transport-vat        as decimal   no-undo .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
  g#host-code   = v-cntxt-host-code-obj
   .
run get-report-num  in parParentProc ( output g#report-num ).
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  g#host-code
  ,output base-code
  )  .
define buffer buf-units for ub.units.
define buffer for-cli   for ub.clients.
define buffer for-obj   for ub.clients.
define variable p-doc-code like ub.ord-line.doc-code no-undo .
define variable tmp-rec as recid no-undo.
define variable choice   as      logical no-undo    init ?.
define variable var#import as logical init false no-undo .
define var last-curr-code like ub.currency.curr-abbr no-undo.
define var cli-name       like ub.clients.obj-name   no-undo.
define var gds-name       like ub.goods.gds-name     no-undo.
define var unit-base      like ub.goods.unit-base    no-undo.
define stream cg-stream.
define variable date_string     as      char    no-undo.
define variable line            as      char    no-undo.
define variable for-time as char.
define variable producer as char.
define variable f-artic     like ub.goods.artic     no-undo.
define variable f-gds-name  like ub.goods.gds-name  no-undo.
define variable f-unit-base like ub.goods.unit-base no-undo.
define variable f-qnty      like   ub.ord-dtl.qnty  no-undo.
define variable f-price-rubl like  ub.ord-dtl.price-rubl  no-undo.
define variable f-sum-rubl   like  ub.ord-dtl.sum-rubl    no-undo.
define variable f-cli-qnty   like  ub.ord-dtl.cli-qnty    no-undo.
define variable f-price-cli  like  ub.ord-dtl.price-cli   no-undo.
define variable f-sum-cli    like  ub.ord-dtl.sum-cli     no-undo.
define variable f-prt-name   like  ub.gds-prt.f-name      no-undo.
define variable filter-point as character no-undo init "Заказ_поставщику_new" .
define variable sort-column-name as character no-undo .
define variable t#query-was-opened as log init false no-undo .
define variable t-ret as logical no-undo  .
define variable x-prod-type like ub.goods.prod-type no-undo .
define variable x-prod-code like ub.goods.prod-code no-undo .
define variable x-artic     like ub.goods.artic no-undo .
define variable v-fl as logical no-undo .
define variable jj as integer no-undo .
define variable base-abbr as character format "x(3)":u
      view-as text
     size 4 by 1 no-undo.
define menu m-export
       menu-item m_export_text  label "&1. Экспорт в формат Моб.сканера" accelerator "alt-7"
       menu-item m_export_excel label "&2. Экспорт в Excel" accelerator "alt-8"
       .
define menu m-way
       menu-item m_way1         label "&9. Заказано до даты поставки" accelerator "alt-9"
       menu-item m_way2         label "&0. Заказано на период продажи" accelerator "alt-0".
DEFINE BUTTON B-delivery
     LABEL "Доставка"
     SIZE 10 BY 1 TOOLTIP "Условия доставки".
define button b-alt-post
     label "Др&угие"
     size 8 by 1 tooltip "А что у других поставщиков?"
     bgcolor 8 .
define button b-del
     label "&Удал"
     size 8 by 1 tooltip "Удалить товары"
     bgcolor 8 .
define button b-exit   auto-go
     label "&Выход"
     size 6 by 1 tooltip "Выход с сохранением"
     bgcolor 8 .
define button b-export
     label "&Экспорт"
     size 8 by 1 tooltip "Экспорт в формат моб.сканера"
     bgcolor 8 .
define button b-chg
     label "&Изм"
     size 8 by 1 tooltip "Изменить строку заказа.заявки"
     bgcolor 8 .
define button b-help
     label "Помо&щь"
     size 8 by 1 tooltip "Помощь"
     bgcolor 8 .
define button b-import
     label "Имп&орт"
     size 8 by 1 tooltip "Импорт из excel"
     bgcolor 8 .
define button b-ins
     label "&Добав"
     size 8 by 1 tooltip "Добавить товары"
     bgcolor 8 .
define button b-notes
     label "При&м":l
     size 8 by 1 tooltip "Изменить примечание к заказу.заявке".
define button b-producer
     label "&Пр-ль"
     size 8 by 1 tooltip "Данные о Производителе"
     bgcolor 8 .
define button b-remove
     label "&х"
     size 3 by 1 tooltip "Проставить/снять пометку по товару, если его нет у Поставщика"
     bgcolor 8 .
define button b-main-calc
     label "&Расчет"
     size 8 by 1 tooltip "Расчет заказа/заявки"
     bgcolor 8 .
define button b-inf
     label "&Инф"
     size 8 by 1 tooltip "Информация по статусам EDI"
     bgcolor 8 .
define button r-acc
     image-up file "btn-down-arrow":u
     image-down file "btn-down-arrow":u
     image-insensitive file "btn-down-arrow":u
     label "r-acc"
     size 3 by .88 tooltip "Выбор из списка".
define button r-agnt
     image-up file "btn-down-arrow":u
     image-down file "btn-down-arrow":u
     image-insensitive file "btn-down-arrow":u
     label "r-acc"
     size 3 by .88 tooltip "Выбор из списка".
define button r-boss
     image-up file "btn-down-arrow":u
     image-down file "btn-down-arrow":u
     image-insensitive file "btn-down-arrow":u
     label "r-acc"
     size 3 by .88 tooltip "Выбор из списка".
define button r-clients
     image-up file "btn-down-arrow":u
     image-down file "btn-down-arrow":u
     image-insensitive file "btn-down-arrow":u
     label "r-cli"
     size 3 by .88 tooltip "Выбор из списка".
define button r-currency
     image-up file "btn-down-arrow":u
     image-down file "btn-down-arrow":u
     image-insensitive file "btn-down-arrow":u
     label "r-acc"
     size 3 by .88.
define button r-paytype
     image-up file "btn-down-arrow":u
     image-down file "btn-down-arrow":u
     image-insensitive file "btn-down-arrow":u
     label "r-paytype"
     size 3 by .88 tooltip "Выбор из списка типа оплаты".
define button r-wrkr
     image-up file "btn-down-arrow":u
     image-down file "btn-down-arrow":u
     image-insensitive file "btn-down-arrow":u
     label "r-acc"
     size 3 by .88 tooltip "Выбор из списка".
define button b-way
     label "&В пути"
     size 8 by 1 tooltip "Список заказов товара в пути"
     bgcolor 8 .
DEFINE BUTTON b-prev AUTO-GO
     LABEL "&<<":L
     SIZE 3 BY 1 TOOLTIP "Переход к просмотру предыдущего документа списка".
DEFINE BUTTON b-next AUTO-GO
     LABEL "&>>":L
     SIZE 3 BY 1 TOOLTIP "Переход к просмотру следующего документа списка".
DEFINE BUTTON b-contract
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL "b-contract"
     SIZE 3 BY 1 TOOLTIP "Посмотреть До&говор".
DEFINE BUTTON B-protocol
     LABEL "Протокол"
     SIZE 10 BY 1 TOOLTIP "Протокол расчета заказа".
define variable agnt-name as character format "x(256)":u
      view-as text
     size 14 by 1 tooltip "Исполнитель"
     fgcolor 4  no-undo.
define variable boss-name as character format "x(256)":u
     view-as text
     size 14 by 1 tooltip "Менеджер"
     fgcolor 4  no-undo.
define variable goods-name as character format "x(256)":u
     label "Наим."
      view-as text
     size 54.38 by .67 tooltip "Наименование товара"
     fgcolor 4  no-undo.
define variable loc-pay-type as character format "x(256)":u
      view-as text
     size 12.5 by .67 tooltip "Тип оплаты"
     fgcolor 4  no-undo.
define variable prod-name as character format "x(256)":u
     label "Пр.-ль"
      view-as text
     size 54.38 by .67 tooltip "Производитель товара"
     fgcolor 4  no-undo.
define variable t as character format "x(3)":u initial "дн."
      view-as text
     size 3.13 by .67 no-undo.
define variable wrkr-name as character format "x(256)":u
      view-as text
     size 14 by 1 tooltip "Исполнитель"
     fgcolor 4  no-undo.
define variable loc-obj-name-2 as character format "x(256)":u
     label "От"
     view-as text
     size 30.88 by .69 tooltip "От кого"
     fgcolor 4  no-undo.
DEFINE VARIABLE Tog-prt AS LOGICAL INITIAL no
     LABEL "шкала"
     VIEW-AS TOGGLE-BOX
     SIZE 7.25 BY .83 TOOLTIP "Просмотр вместе с признаками" NO-UNDO.
define button r-contract
     image-up file "btn-down-arrow":u
     image-down file "btn-down-arrow":u
     image-insensitive file "btn-down-arrow":u
     size 3 by .88 tooltip "Выбор из списка договоров".
define rectangle rect-4
     edge-pixels 2 graphic-edge  no-fill
     size 30.38 by 8.46.
define rectangle rect-5
     edge-pixels 2 graphic-edge  no-fill
     size 35.25 by 9.92.
define rectangle rect-6
     edge-pixels 2 graphic-edge  no-fill
     size 33.88 by 8.42.
define rectangle rect-7
     edge-pixels 2 graphic-edge  no-fill
     size 64.13 by 1.63.
define variable loc-sum-rcv as decimal no-undo .
define variable loc-err-rcv as character no-undo .
define variable f-loc-sum-rcv as decimal no-undo .
define variable f-loc-err-rcv as character no-undo .
define new shared query br-docs for
      shar_ord-line,  buf-goods  scrolling.
define query br-docs-2 for
      shar_ord-line, b-goods, ub.ord-dtl, buf-goods , ub.gds-prt scrolling.
function roundordline return decimal (buffer local-ord-line for shar_ord-line):
  find first ub.goods where ub.goods.artic     = local-ord-line.artic     and
                         ub.goods.prod-type = local-ord-line.prod-type and
                         ub.goods.prod-code = local-ord-line.prod-code no-lock.
  find first ub.units where ub.units.unit-name = ub.goods.unit-cli.
  if (lookup('шту':U, ub.units.type) > 0
  or lookup('сер':U, ub.units.type) > 0 ) and
    local-ord-line.cli-qnty <> truncate(local-ord-line.cli-qnty, 0) then do:
      return truncate(local-ord-line.cli-qnty, 0) + 1 .
  end.
  else do:
    return local-ord-line.cli-qnty.
  end.
end function.
define variable varroundordline as decimal no-undo.
define browse br-docs
  query br-docs no-lock display
      loc-err-rcv                   column-label "~!!":c1  format "x(1)"
      shar_ord-line.line-num        column-label '№!п/п'   format ">>>>"
      shar_ord-line.prt-ok          column-label 'ш! '    format "+/-"
      shar_ord-line.artic           column-label "Артикул! ":c8
      buf-goods.gds-name            column-label "Название! ":c9
      shar_ord-line.unit-cli        column-label "Е.и.!пост" format "x(3)"
      shar_ord-line.cli-qnty        column-label "Заказ!ед.пост":c13 format "->,>>>,>>9.999"
      shar_ord-line.order-cli-qnty  column-label "Запрошено!количество"   format "->,>>>,>>>,>>9.999"
      shar_ord-line.price-cli       column-label "Последн.цена!пост-ка":c20 format "->>>,>>>,>>9.99"
      shar_ord-line.ord-dec1        column-label 'Запрошена!цена'   format "->,>>>,>>>,>>9.99"
      shar_ord-line.sum-cli         column-label "Сумма!ед.пост":c13 format "->,>>>,>>>,>>9.99"
      shar_ord-line.cli-art         column-label "Артикул!поставщика":c18
      buf-goods.unit-base           column-label "Е.и.!баз." format "x(3)"
      shar_ord-line.qnty            column-label "Заказ! ":c6 format "->,>>>,>>9.999"
      shar_ord-line.price-rubl      column-label "Цена!(руб.)" format "->>>,>>>,>>9.99"
      shar_ord-line.sum-rubl        column-label "Сумма!(руб.) ":c12 format "->,>>>,>>>,>>9.99"
      shar_ord-line.qnty-stk        column-label "Остаток на !момент расчета" format "->,>>>,>>9.999"
      v-fact-qnty                   column-label "Текущий!остаток" format "->,>>>,>>9.999"
      loc-sum-rcv                   column-label "Поставлено! ":c11 format "->>>,>>>,>>9.999"
      shar_ord-line.gds-code        column-label "Код!товара"
      shar_ord-line.initial-qnty    column-label "Расcчитн.!кол-во"
      v-min-stock                   column-label "Мин!остаток" format "->,>>>,>>9.999"
      v-gds-way                     column-label "Товары!в пути" format "->,>>>,>>9.999"
  enable
      shar_ord-line.cli-art
    with no-assign  separators size-char 98.75  by 9.
define browse br-docs-2
  query br-docs-2 no-lock display
      f-loc-err-rcv           column-label "~!!":c1  format "x(1)"
      f-artic                 column-label "Артикул! ":c8
      f-gds-name              column-label "Название! ":c9  format "x(40)"
      f-prt-name              column-label "Признак! ":c9   format "x(20)"
      f-unit-base             column-label "Е.и.!баз." format "x(3)"
      shar_ord-line.qnty      column-label "Заказано!всего по товару"
      v-fact-qnty             column-label "Текущий!остаток" format "->,>>>,>>9.999"
      f-qnty                  column-label "Заказ! ":c6 format "->,>>>,>>9.999"
      f-price-rubl            column-label "Цена!(руб.)":c17 format "->>>,>>>,>>9.99"
      f-sum-rubl              column-label "Сумма!(руб.) ":c11 format "->,>>>,>>>,>>9.99"
      shar_ord-line.unit-cli   column-label "Е.и.!пос." format "x(3)"
      shar_ord-line.cli-qnty   column-label "Заказано!всего по товару"
      f-cli-qnty              column-label "Заказ!ед.пост":c13 format "->,>>>,>>9.999"
      f-price-cli             column-label "Последн.цена!пост-ка":c20 format "->>>,>>>,>>9.99"
      f-sum-cli               column-label "Сумма!ед.пост":c13 format "->,>>>,>>>,>>9.99"
      shar_ord-line.cli-art    column-label "Артикул!поставщика":c18
      f-loc-sum-rcv             column-label "Поставлено! ":c11 format "->>>,>>>,>>9.999"
  enable
      shar_ord-line.qnty
      with no-assign  separators size-char 98.75  by 9.
define frame dialog-frame
     b-exit at row 1.08 col 1
     b-prev AT ROW 1.08 COL 7
     b-next AT ROW 1.08 COL 10
     loc-cli-type at row 1.08 col 11.5  colon-aligned    no-label
     loc-cli-code at row 1.08 col 15.13 colon-aligned no-label
     r-clients at row 1.08 col 27
     doc-date at row 8.88 col 8.38 colon-aligned
     fact-date at row 9.63 col 8.38 colon-aligned
     r-wrkr at row 2.21 col 31.63
     paytype at row 2.25 col 73.25 colon-aligned
     r-paytype at row 2.25 col 97
     wrkr at row 2.29 col 6 colon-aligned
     cycle-day at row 2.33 col 56 colon-aligned
     tog-type  at row 2.42 col 35
     r-agnt at row 3.13 col 31.63
     agnt at row 3.21 col 6 colon-aligned
     loc-date-ship at row 3.38 col 44.5 colon-aligned
     loc-service at row 4.08 col 83.63 colon-aligned
     r-boss at row 4.17 col 31.63
     boss at row 4.25 col 6 colon-aligned
     pay-day      at row 4.38 col 54.88 colon-aligned
     loc-out-code at row 5.38 col 52.75 colon-aligned
     date-sale-1  at row 4.38 col 51.25 colon-aligned
     date-sale-2  at row 5.38 col 51.25 colon-aligned
     loc-qnty at row 5.08 col 83.63 colon-aligned
     r-currency at row 5.29 col 31.63
     loc-exch-code at row 5.38 col 10.5 colon-aligned
     loc-cli-qnty at row 6.08 col 83.63 colon-aligned
     r-acc at row 6.29 col 31.63
     loc-exch-rate at row 6.42 col 10.63 colon-aligned
     loc-exch-scale at row 6.42 col 25.25 colon-aligned
     loc-sum-rubl at row 7.04 col 83.63 colon-aligned
     e-method at row 7.08 col 35 no-label
     loc-base-rate at row 7.46 col 1.63
     loc-base-scale at row 7.46 col 25.25 colon-aligned
     loc-sum-base at row 7.96 col 83.63 colon-aligned
     loc-tot-lines at row 8.88 col 25 colon-aligned
     loc-sum-cli at row 8.92 col 83.63 colon-aligned
     slt_type at row 10.96 col 72.75 colon-aligned
     vat_type at row 10.96 col 87.75 colon-aligned
     br-docs at row 12.08 col 1
     b-ins at row 21.71 col 1
     b-way at row 21.71 col 1
     b-del at row 21.71 col 9
     b-chg at row 21.71 col 17
     b-producer at row 21.71 col 25
     b-alt-post at row 21.71 col 33
     b-export at row 21.71 col 41
     b-import at row 21.71 col 49
     b-main-calc at row 21.71 col 57
     b-notes at row 21.71 col 81
     b-remove at row 21.71 col 89
     b-help at row 21.71 col 92
     b-inf    at row 21.71 col 65
     tog-prt  at row 21.71 col 73
     loc-obj-name at row 1.08 col 28.25 colon-aligned no-label
     loc-obj-name-2 at row 1.08 col 67.5 colon-aligned
     wrkr-name at row 2.33 col 17.63 no-label
     loc-pay-type at row 2.38 col 82.38 colon-aligned no-label
     loc-cli-out-doc at row 3.38 col 82.38 colon-aligned
     t at row 2.58 col 59.63 colon-aligned no-label
     agnt-name at row 3.25 col 17.63 no-label
     boss-name at row 4.29 col 17.63 no-label
     ub.currency.curr-abbr at row 5.42 col 25.25 colon-aligned no-label
          view-as text
          size 4 by 1
          fgcolor 4
     prod-name at row 10.58 col 8.5 colon-aligned
     goods-name at row 11.29 col 8.5 colon-aligned
.
define frame dialog-frame
     b-delivery at row  21.71 col 9
     b-protocol at row 21.71 col 49
     rect-6 at row 2.13  col 1
     rect-7 at row 10.46 col 1
     rect-5 at row 2.13  col 65
     rect-4 at row 2.13  col 34.75
     loc-time-ship at row 3.38 col 54.88 colon-aligned no-label
     v-loc-contract at row 9.88 col 73.25 colon-aligned
     b-contract   at row 9.88 col 94
     r-contract   at row 9.88 col 97
     loc-hour at row 3.38 col 54.88 colon-aligned no-label
     loc-min  at row 3.38 col 59.13 colon-aligned no-label
     ":" view-as text
         size 1.25 by 1 at row 3.38 col 59.5
     "Метод расчета заказа\заявки" view-as text
          size 27 by .67 at row 6.5 col 35.75
    with view-as dialog-box keep-tab-order
         side-labels no-underline three-d  scrollable
         title "ЗАКАЗ".
DEFINE FRAME FRAME-A
 br-docs-2 at row 1 col 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 12.08
         SIZE 99.1 BY 9.5
          .
ASSIGN
       FRAME FRAME-A:FRAME            = FRAME Dialog-Frame:HANDLE
       FRAME FRAME-A:HIDDEN           = TRUE
       FRAME DIALOG-FRAME:SCROLLABLE  = FALSE
       FRAME DIALOG-FRAME:HIDDEN      = TRUE
       b-way:popup-menu in frame dialog-frame       = menu m-way:handle
       b-export:popup-menu in frame dialog-frame    = menu m-export:handle
       B-way:MENU-MOUSE = 1
       BR-DOCS:NUM-LOCKED-COLUMNS   IN FRAME dialog-frame = 1
       b-export:menu-mouse = 1
       .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure gdsoattr-name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-name in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-value :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-value in g#attr-lib
      (input  p-code
      ,input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-gds-code :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-gds-code in g#attr-lib
      (input  p-code
      ,input  p-value
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-gds-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-write :
  define input parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-write in g#attr-lib
      (input p-gds-code
      ,input p-obj-type
      ,input p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-exist :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-delete :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-doc-tickets :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-doc-tickets in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-dop-alt-name :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-dop-alt-name in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-gds-margins :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-gds-margins in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-normal-wastage :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-normal-wastage in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr-margin-value :
  define input  parameter p-gds-code         as integer   no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define output parameter p-min-value        as decimal   no-undo initial ? .
  define output parameter p-max-value        as decimal   no-undo initial ? .
  define output parameter p-increase-pc      as decimal   no-undo initial ? .
  define output parameter p-rmethod          as character no-undo initial '':U .
  define output parameter p-base             as decimal   no-undo initial ? .
  define output parameter p-range-margin     as integer   no-undo .
  define output parameter p-exists-margin    as logical   no-undo .
  define output parameter p-range-increase   as integer   no-undo .
  define output parameter p-exists-increase  as logical   no-undo .
  define output parameter p-range-rmethod    as integer   no-undo .
  define output parameter p-exists-rmethod   as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-margin-value in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-min-value
      ,output p-max-value
      ,output p-increase-pc
      ,output p-rmethod
      ,output p-base
      ,output p-range-margin
      ,output p-exists-margin
      ,output p-range-increase
      ,output p-exists-increase
      ,output p-range-rmethod
      ,output p-exists-rmethod
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-o-normal-wastage-value :
  define input-output parameter objNormWast as class ibs.th.ref.normwastsub no-undo.
do
on error undo, return error
:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-o-normal-wastage-value in g#attr-lib
      (input-output objNormWast
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr_check-code-dt-seasons :
  define input  parameter p-code     like ub.goods.gds-code   no-undo .
  define input  parameter p-obj-type like ub.clients.obj-type no-undo .
  define input  parameter p-obj-code like ub.clients.obj-code no-undo .
  define output parameter p-gds-code like ub.goods.gds-code   no-undo .
  define output parameter p-dt-code  as   integer             no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-code-dt-seasons in g#attr-lib
      (input p-code
      ,input p-obj-type
      ,input p-obj-code
      ,output p-gds-code
      ,output p-dt-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure last-price :
do on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
define input parameter  p-host-code     as integer no-undo .
define input parameter  p-artic         like ub.doc-line.artic  no-undo .
define input parameter  p-prod-type     like ub.doc-line.prod-type  no-undo .
define input parameter  p-prod-code     like ub.doc-line.prod-code  no-undo .
define input parameter  p-cli-code      like ub.ord-doc.cli-code  no-undo .
define input parameter  p-cli-type      like ub.ord-doc.cli-type  no-undo .
define input parameter  p-cli-base-rate like ub.ord-line.cli-base-rate no-undo .
define input parameter  p-curr-code  as integer   no-undo .
define output parameter p-price-base like ub.doc-line.price-base no-undo .
define output parameter p-price-rubl like ub.doc-line.price-rubl no-undo .
define output parameter p-price-cli  like ub.doc-line.price-cli  no-undo .
define buffer buf-lib-doc-line for ub.doc-line.
define buffer buf_cli-gds for ub.cli-gds .
define buffer buf_trn-doc for ub.trn-doc  .
define variable vp-curr-code  like ub.trn-doc.exch-code.
define variable vp-exch-rate  like ub.trn-doc.exch-rate.
define variable vp-exch-scale like ub.trn-doc.exch-scale.
define variable v-last-in-code   like ub.doc-line.doc-code  no-undo .
define variable v-last-obj-type  like ub.clients.obj-type no-undo .
define variable v-last-obj-code  like ub.clients.obj-code no-undo .
define variable v-cli-base-rate as decimal   no-undo .
 find first buf_cli-gds no-lock where
            buf_cli-gds.cli-type   = p-cli-type    and
            buf_cli-gds.cli-code   = p-cli-code    and
            buf_cli-gds.host-code  = p-host-code   and
            buf_cli-gds.artic      = p-artic       and
            buf_cli-gds.prod-type  = p-prod-type   and
            buf_cli-gds.prod-code  = p-prod-code
            no-error .
if available buf_cli-gds then do:
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code  = buf_cli-gds.in-code no-error .
     if available buf_trn-doc then do:
        vp-curr-code  = buf_trn-doc.exch-code.
        vp-exch-rate  = buf_trn-doc.exch-rate.
        vp-exch-scale = buf_trn-doc.exch-scale.
     end.
    find first buf-lib-doc-line no-lock
      where buf-lib-doc-line.doc-code  = buf_cli-gds.in-code
        and buf-lib-doc-line.artic     = p-artic
        and buf-lib-doc-line.prod-type = p-prod-type
        and buf-lib-doc-line.prod-code = p-prod-code
      no-error .
end.
else do:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lastindc in g#library
  (input  p-host-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-last-in-code
  ,output v-last-obj-type
  ,output v-last-obj-code
  )  .
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code  = v-last-in-code no-error .
     if available buf_trn-doc then do:
        vp-curr-code  = buf_trn-doc.exch-code.
        vp-exch-rate  = buf_trn-doc.exch-rate.
        vp-exch-scale = buf_trn-doc.exch-scale.
     end.
    find first buf-lib-doc-line no-lock
      where buf-lib-doc-line.doc-code  = v-last-in-code
        and buf-lib-doc-line.artic     = p-artic
        and buf-lib-doc-line.prod-type = p-prod-type
        and buf-lib-doc-line.prod-code = p-prod-code
      no-error .
end.
    if available buf-lib-doc-line then do:
      assign
        v-cli-base-rate = buf-lib-doc-line.cli-base-rate
        p-price-base = buf-lib-doc-line.price-base
        p-price-rubl = buf-lib-doc-line.price-rubl
        p-price-cli  = (if vp-curr-code = 0 then buf-lib-doc-line.price-rubl else buf-lib-doc-line.price-base) * p-cli-base-rate
      .
      if v-cli-base-rate <> p-cli-base-rate
      then do:
          p-price-cli  = p-price-cli / v-cli-base-rate  .
      end.
       if p-curr-code <> vp-curr-code then do:
          p-price-cli  = p-price-rubl  .
      end.
    end.
    Else do:
      assign
        p-price-base = 0
        p-price-rubl = 0
        p-price-cli  = 0
      .
    end.
  end.
end procedure.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F9 of frame dialog-frame anywhere do:
  run init-gds-rec.
  if gds-rec = ? then
    return no-apply.
  run ref/gds-form.w ( input PARPARENTPROC
                      ,input 'ПРОСМОТР':U
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input-output gds-rec).
  apply "entry" to br-docs in frame dialog-frame.
  return no-apply.
end.
on window-close of frame dialog-frame
do:
  apply "CHOOSE":u to b-exit.
end.
ON ROW-DISPLAY OF BR-DOCS IN FRAME dialog-frame
DO:
  define buffer buf_gds-obj for ub.gds-obj  .
  loc-sum-rcv = 0 .
  loc-err-rcv = "" .
  for each ub.ord-line-rcv where
           ub.ord-line-rcv.doc-code  = shar_ord-line.doc-code  and
           ub.ord-line-rcv.artic     = shar_ord-line.artic     and
           ub.ord-line-rcv.prod-type = shar_ord-line.prod-type and
           ub.ord-line-rcv.prod-code = shar_ord-line.prod-code no-lock  :
       loc-sum-rcv = loc-sum-rcv  + ub.ord-line-rcv.qnty .
  end.
    if loc-sum-rcv   >  shar_ord-line.qnty then do:
       loc-sum-rcv:fgcolor in browse  br-docs  =  12 .
       loc-err-rcv:fgcolor in browse  br-docs  =  12 .
       loc-err-rcv = ">" .
       end.
    if loc-sum-rcv   <  shar_ord-line.qnty then do:
       loc-sum-rcv:fgcolor in browse  br-docs  =  4 .
       loc-err-rcv:fgcolor in browse  br-docs  =  4 .
       loc-err-rcv = "<" .
       end.
  find first buf_gds-obj no-lock where
             buf_gds-obj.artic     = shar_ord-line.artic     and
             buf_gds-obj.prod-type = shar_ord-line.prod-type and
             buf_gds-obj.prod-code = shar_ord-line.prod-code and
             buf_gds-obj.obj-type  = shar_ord-doc.obj-type   and
             buf_gds-obj.obj-code  = shar_ord-doc.obj-code   no-error .
   if available buf_gds-obj then
           v-fact-qnty = buf_gds-obj.fact-qnty.
      else v-fact-qnty = 0 .
  find first buf_ord-line-attr where buf_ord-line-attr.doc-code = shar_ord-line.doc-code
    and buf_ord-line-attr.gds-code = shar_ord-line.gds-code
    and buf_ord-line-attr.attr-code = 'min-stock':U no-error.
  if available buf_ord-line-attr then v-min-stock = decimal(buf_ord-line-attr.attr-value).
  find first buf_ord-line-attr where buf_ord-line-attr.doc-code = shar_ord-line.doc-code
    and buf_ord-line-attr.gds-code = shar_ord-line.gds-code
    and buf_ord-line-attr.attr-code = 'gds-way':U no-error.
  if available buf_ord-line-attr then v-gds-way = decimal(buf_ord-line-attr.attr-value).
end.
ON ROW-DISPLAY OF BR-DOCS-2 IN FRAME FRAME-A
DO:
     if ub.ord-dtl.artic = ? then do:
        f-artic = shar_ord-line.artic  .
    end.
    else do:
      f-artic = ub.ord-dtl.artic  .
      shar_ord-line.qnty:bgcolor in browse  br-docs-2  = 7.
    end.
     assign
        f-prt-name  =  if ub.gds-prt.f-name = ?    then ""                  else ub.gds-prt.f-name
        f-gds-name  =  if b-goods.gds-name = ?  then buf-goods.gds-name  else b-goods.gds-name
        f-unit-base =  if b-goods.unit-base = ? then buf-goods.unit-base else b-goods.unit-base
        f-qnty        =  if ub.ord-dtl.qnty        = ? then shar_ord-line.qnty        else ub.ord-dtl.qnty
        f-price-rubl  =  if ub.ord-dtl.price-rubl  = ? then shar_ord-line.price-rubl  else ub.ord-dtl.price-rubl
        f-sum-rubl    =  if ub.ord-dtl.sum-rubl    = ? then shar_ord-line.sum-rubl    else ub.ord-dtl.sum-rubl
        f-cli-qnty    =  if ub.ord-dtl.cli-qnty    = ? then shar_ord-line.cli-qnty    else ub.ord-dtl.cli-qnty
        f-price-cli   =  if ub.ord-dtl.price-cli   = ? then shar_ord-line.price-cli   else ub.ord-dtl.price-cli
        f-sum-cli     =  if ub.ord-dtl.sum-cli     = ? then shar_ord-line.sum-cli     else ub.ord-dtl.sum-cli
  .
  f-loc-sum-rcv = 0 .
  f-loc-err-rcv = "" .
  for each ub.ord-dtl-rcv where
           ub.ord-dtl-rcv.doc-code  = ub.ord-dtl.doc-code  and
           ub.ord-dtl-rcv.node-code = ub.ord-dtl.node-code and
           ub.ord-dtl-rcv.artic     = ub.ord-dtl.artic     and
           ub.ord-dtl-rcv.prod-type = ub.ord-dtl.prod-type and
           ub.ord-dtl-rcv.prod-code = ub.ord-dtl.prod-code no-lock  :
       f-loc-sum-rcv = f-loc-sum-rcv  + ub.ord-dtl.qnty .
  end.
    if f-loc-sum-rcv   >  ub.ord-dtl.qnty then do:
       f-loc-sum-rcv:fgcolor in browse  br-docs-2  =  12 .
       f-loc-err-rcv:fgcolor in browse  br-docs-2  =  12 .
       f-loc-err-rcv = ">" .
    end.
    if f-loc-sum-rcv   <  ub.ord-dtl.qnty then do:
       f-loc-sum-rcv:fgcolor in browse  br-docs-2  =  4 .
       f-loc-err-rcv:fgcolor in browse  br-docs-2  =  4 .
       f-loc-err-rcv = "<" .
    end.
end.
on value-changed of br-docs in frame dialog-frame
do:
   run select-good-scala no-error .
end.
on value-changed of br-docs-2 in frame frame-a
do:
   run select-good-scala-2 no-error .
end.
on value-changed of tog-prt in frame dialog-frame
do:
   run pr-tog-prt no-error .
   if error-status :error then return no-apply.
end.
ON CHOOSE OF B-delivery IN FRAME Dialog-Frame
DO:
  run cus/pardeliv.w
     ( input        parParentproc
      ,input        if t-action = "lkp" then 'ПРОСМОТР':U else t-action
      ,input        "ord" + g#type
      ,input        loc-store-type
      ,input        loc-store-code
      ,input        loc-cli-type
      ,input        loc-cli-code
      ,input-output v-deliv-type-code
      ,input-output v-point-obj-code
      ,input-output v-point-obj-db-num
      ,input-output v-point-cli-code
      ,input-output v-point-cli-db-num
      ,input-output v-transport-host-code
      ,input-output v-transport-cli-type
      ,input-output v-transport-cli-code
      ,input-output v-transport-contract
      ,input-output v-transport-condition
      ,input-output v-transport-value
      ,input-output v-transport-sum
      ,input-output v-transport-vat
      ) no-error.
    if error-status :error then message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "Ошибка"
      view-as alert-box error
    .
END.
ON CHOOSE OF b-next IN FRAME dialog-frame
DO:
 RUN step-next in this-procedure .
END.
ON CHOOSE OF b-prev IN FRAME dialog-frame
DO:
 run step-prev in this-procedure .
END.
ON CHOOSE OF b-protocol IN FRAME Dialog-Frame
DO:
define variable vss-include-info20 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  run show-protocol in this-procedure .
END.
ON CHOOSE OF b-contract IN FRAME Dialog-Frame
DO:
define variable vss-include-info21 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  run show-contract-code in this-procedure .
END.
ON CHOOSE OF b-inf IN FRAME Dialog-Frame
DO:
  run cus/edi-inf.w ( p-doc-code ) .
END.
ON CHOOSE OF b-producer IN FRAME Dialog-Frame
DO:
  find current shar_ord-line no-lock  .
  if not available shar_ord-line  then  return.
  run ref/showcli.p
  (input parParentProc
  ,input shar_ord-line.prod-type
  ,input shar_ord-line.prod-code
  ).
  return no-apply.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
  next-prev = ?.
  apply "end-error":u to self.
  return .
END.
on choose of b-notes in frame dialog-frame
do:
 run proc-d-notes in this-procedure .
end.
ON CHOOSE OF MENU-ITEM m_Export_TEXT
DO:
  run cus/z-tot2.p ( parparentproc , "order" , shar_ord-doc.doc-type ,  p-doc-code) .
END.
ON CHOOSE OF B-Alt-post IN FRAME Dialog-Frame
DO:
  find current shar_ord-line no-lock no-error  .
  if  not avail shar_ord-line  then do:
        return.
  end.
 run cus/cli-othr.w
   (input shar_ord-line.artic,
    input shar_ord-line.prod-type,
    input shar_ord-line.prod-code,
    input buf-cli.obj-type ,
    input buf-cli.obj-code
    ).
END.
ON CHOOSE OF MENU-ITEM m_way1
DO:
  run CHOOSE-MENU-way1 in this-procedure.
END.
ON CHOOSE OF MENU-ITEM m_way2
DO:
  run CHOOSE-MENU-way2 in this-procedure.
END.
on choose of menu-item m_export_excel
do:
  run b-export-ch  in this-procedure .
end.
if valid-handle(active-window) and frame dialog-frame:parent eq ?
then frame dialog-frame:parent = active-window.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame dialog-frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame dialog-frame
do:
  apply "help":u to frame dialog-frame .
end.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame dialog-frame:width - 0.3
                fh            = frame dialog-frame:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame dialog-frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame dialog-frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame dialog-frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame dialog-frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame dialog-frame :height = v-frame-height
          .
          if frame dialog-frame :scrollable = true
          then do:
            assign
              frame dialog-frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame dialog-frame :scrollable = true
          then do:
            assign
              frame dialog-frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame dialog-frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame dialog-frame :height
      v-frame-virtual-height = frame dialog-frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame dialog-frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame dialog-frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame dialog-frame :scrollable = true
      then do:
        assign
          frame dialog-frame :virtual-height = frame dialog-frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame dialog-frame :height = frame dialog-frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame dialog-frame :height = frame dialog-frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame dialog-frame :scrollable = true
      then do:
        assign
          frame dialog-frame :virtual-height = frame dialog-frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame dialog-frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame dialog-frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame dialog-frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame dialog-frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame dialog-frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame dialog-frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame dialog-frame :width = v-frame-width
          .
          if frame dialog-frame :scrollable = true
          then do:
            assign
              frame dialog-frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame dialog-frame :scrollable = true
          then do:
            assign
              frame dialog-frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame dialog-frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame dialog-frame :width
      v-frame-virtual-width = frame dialog-frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame dialog-frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame dialog-frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame dialog-frame :scrollable = true
      then do:
        assign
          frame dialog-frame :virtual-width = frame dialog-frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame dialog-frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame dialog-frame :width = frame dialog-frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame dialog-frame :scrollable = true
      then do:
        assign
          frame dialog-frame :virtual-width = frame dialog-frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame dialog-frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame dialog-frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame dialog-frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame dialog-frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame dialog-frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame dialog-frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame dialog-frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame dialog-frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame dialog-frame :height
      v-col-delta = v-new-col - frame dialog-frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame dialog-frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame dialog-frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame dialog-frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame dialog-frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame dialog-frame :width
      v-diasize-current-frame-height = frame dialog-frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame dialog-frame
    :
      assign
        v-diasize-orig-frame-height = frame dialog-frame :height
        v-diasize-orig-frame-width  = frame dialog-frame :width
        v-diasize-browse-handle     = browse br-docs :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame dialog-frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of loc-date-ship in frame dialog-frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of loc-date-ship in frame dialog-frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of loc-date-ship in frame dialog-frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of loc-date-ship in frame dialog-frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of loc-date-ship in frame dialog-frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of loc-date-ship in frame dialog-frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date26
    MENU-ITEM m-ed-date26-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date26-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date26-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date26-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if loc-date-ship :POPUP-MENU in frame dialog-frame = ?
  then do:
    ASSIGN
      loc-date-ship :POPUP-MENU in frame dialog-frame = MENU m-ed-date26 :HANDLE
      loc-date-ship :MENU-MOUSE in frame dialog-frame = 3
    .
  end.
  define variable v-label-handle26 as handle no-undo .
  assign
    v-label-handle26 = loc-date-ship :side-label-handle in frame dialog-frame
  .
  if valid-handle (v-label-handle26)
  then do:
    if v-label-handle26 :tooltip = ""
    or v-label-handle26 :tooltip = ?
    then do:
      assign
        v-label-handle26 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date26-1 in menu m-ed-date26 DO:
    apply "ctrl-b":U to loc-date-ship in frame dialog-frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date26-2 in menu m-ed-date26 DO:
    apply "ctrl-d":U to loc-date-ship in frame dialog-frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date26-3 in menu m-ed-date26 DO:
    apply "ctrl-e":U to loc-date-ship in frame dialog-frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date26-4 in menu m-ed-date26 DO:
    apply "ctrl-f":U to loc-date-ship in frame dialog-frame .
  END.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of date-sale-1 in frame dialog-frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of date-sale-1 in frame dialog-frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of date-sale-1 in frame dialog-frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of date-sale-1 in frame dialog-frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of date-sale-1 in frame dialog-frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of date-sale-1 in frame dialog-frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date28
    MENU-ITEM m-ed-date28-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date28-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date28-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date28-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if date-sale-1 :POPUP-MENU in frame dialog-frame = ?
  then do:
    ASSIGN
      date-sale-1 :POPUP-MENU in frame dialog-frame = MENU m-ed-date28 :HANDLE
      date-sale-1 :MENU-MOUSE in frame dialog-frame = 3
    .
  end.
  define variable v-label-handle28 as handle no-undo .
  assign
    v-label-handle28 = date-sale-1 :side-label-handle in frame dialog-frame
  .
  if valid-handle (v-label-handle28)
  then do:
    if v-label-handle28 :tooltip = ""
    or v-label-handle28 :tooltip = ?
    then do:
      assign
        v-label-handle28 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date28-1 in menu m-ed-date28 DO:
    apply "ctrl-b":U to date-sale-1 in frame dialog-frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date28-2 in menu m-ed-date28 DO:
    apply "ctrl-d":U to date-sale-1 in frame dialog-frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date28-3 in menu m-ed-date28 DO:
    apply "ctrl-e":U to date-sale-1 in frame dialog-frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date28-4 in menu m-ed-date28 DO:
    apply "ctrl-f":U to date-sale-1 in frame dialog-frame .
  END.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of date-sale-2 in frame dialog-frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of date-sale-2 in frame dialog-frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of date-sale-2 in frame dialog-frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of date-sale-2 in frame dialog-frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of date-sale-2 in frame dialog-frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of date-sale-2 in frame dialog-frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date30
    MENU-ITEM m-ed-date30-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date30-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date30-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date30-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if date-sale-2 :POPUP-MENU in frame dialog-frame = ?
  then do:
    ASSIGN
      date-sale-2 :POPUP-MENU in frame dialog-frame = MENU m-ed-date30 :HANDLE
      date-sale-2 :MENU-MOUSE in frame dialog-frame = 3
    .
  end.
  define variable v-label-handle30 as handle no-undo .
  assign
    v-label-handle30 = date-sale-2 :side-label-handle in frame dialog-frame
  .
  if valid-handle (v-label-handle30)
  then do:
    if v-label-handle30 :tooltip = ""
    or v-label-handle30 :tooltip = ?
    then do:
      assign
        v-label-handle30 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date30-1 in menu m-ed-date30 DO:
    apply "ctrl-b":U to date-sale-2 in frame dialog-frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date30-2 in menu m-ed-date30 DO:
    apply "ctrl-d":U to date-sale-2 in frame dialog-frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date30-3 in menu m-ed-date30 DO:
    apply "ctrl-e":U to date-sale-2 in frame dialog-frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date30-4 in menu m-ed-date30 DO:
    apply "ctrl-f":U to date-sale-2 in frame dialog-frame .
  END.
def var sort-labelbr-docs   as character no-undo .
def var sort-clmnbr-docs    as handle    no-undo .
def var cur-clmnbr-docs     as handle    no-undo .
def var cur-clmn-locbr-docs as integer   no-undo .
def var re-querybr-docs     as logical   initial no no-undo .
on start-search, ctrl-o of br-docs in frame dialog-frame do:
   run sort-brbr-docs
     (input (if available shar_ord-line
             then recid(shar_ord-line)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-docs :
  define input parameter p-recid as recid no-undo .
  if re-querybr-docs = no then do:
    assign
       cur-clmnbr-docs = br-docs:current-column in frame dialog-frame
    .
    if sort-clmnbr-docs <> ? then sort-clmnbr-docs:column-fgcolor = 0.
    if cur-clmnbr-docs = sort-clmnbr-docs then do:
      assign
         sort-labelbr-docs = ""
         sort-clmnbr-docs = ?
      .
     end.
     else do:
       assign
         sort-labelbr-docs = cur-clmnbr-docs:label
         sort-clmnbr-docs  = cur-clmnbr-docs
         sort-clmnbr-docs:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-docs = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-docs:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-docs then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-docs = cur-clmn-locbr-docs + 1
    .
  end.
  case sort-labelbr-docs:
        when loc-err-rcv:label in browse br-docs then DO:   assign     sort-column-name = "loc-err-rcv"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each buf-goods no-lock where  buf-goods.artic = shar_ord-line.artic and  buf-goods.prod-type = shar_ord-line.prod-type and  buf-goods.prod-code = shar_ord-line.prod-code BY loc-err-rcv .   . END.
        when shar_ord-line.line-num:label in browse br-docs then DO:   assign     sort-column-name = "shar_ord-line.line-num"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each buf-goods no-lock where  buf-goods.artic = shar_ord-line.artic and  buf-goods.prod-type = shar_ord-line.prod-type and  buf-goods.prod-code = shar_ord-line.prod-code BY shar_ord-line.line-num .   . END.
        when shar_ord-line.prt-ok:label in browse br-docs then DO:   assign     sort-column-name = "shar_ord-line.prt-ok"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each buf-goods no-lock where  buf-goods.artic = shar_ord-line.artic and  buf-goods.prod-type = shar_ord-line.prod-type and  buf-goods.prod-code = shar_ord-line.prod-code BY shar_ord-line.prt-ok .   . END.
        when shar_ord-line.artic:label in browse br-docs then DO:   assign     sort-column-name = "shar_ord-line.artic"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each buf-goods no-lock where  buf-goods.artic = shar_ord-line.artic and  buf-goods.prod-type = shar_ord-line.prod-type and  buf-goods.prod-code = shar_ord-line.prod-code BY shar_ord-line.artic .   . END.
        when buf-goods.gds-name:label in browse br-docs then DO:   assign     sort-column-name = "buf-goods.gds-name"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each buf-goods no-lock where  buf-goods.artic = shar_ord-line.artic and  buf-goods.prod-type = shar_ord-line.prod-type and  buf-goods.prod-code = shar_ord-line.prod-code BY buf-goods.gds-name .   . END.
        when shar_ord-line.unit-cli:label in browse br-docs then DO:   assign     sort-column-name = "shar_ord-line.unit-cli"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each buf-goods no-lock where  buf-goods.artic = shar_ord-line.artic and  buf-goods.prod-type = shar_ord-line.prod-type and  buf-goods.prod-code = shar_ord-line.prod-code BY shar_ord-line.unit-cli .   . END.
        when shar_ord-line.cli-qnty:label in browse br-docs then DO:   assign     sort-column-name = "shar_ord-line.cli-qnty"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each buf-goods no-lock where  buf-goods.artic = shar_ord-line.artic and  buf-goods.prod-type = shar_ord-line.prod-type and  buf-goods.prod-code = shar_ord-line.prod-code BY shar_ord-line.cli-qnty .   . END.
        when shar_ord-line.order-cli-qnty:label in browse br-docs then DO:   assign     sort-column-name = "shar_ord-line.order-cli-qnty"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each buf-goods no-lock where  buf-goods.artic = shar_ord-line.artic and  buf-goods.prod-type = shar_ord-line.prod-type and  buf-goods.prod-code = shar_ord-line.prod-code BY shar_ord-line.order-cli-qnty .   . END.
        when shar_ord-line.price-cli:label in browse br-docs then DO:   assign     sort-column-name = "shar_ord-line.price-cli"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each buf-goods no-lock where  buf-goods.artic = shar_ord-line.artic and  buf-goods.prod-type = shar_ord-line.prod-type and  buf-goods.prod-code = shar_ord-line.prod-code BY shar_ord-line.price-cli .   . END.
        when shar_ord-line.ord-dec1:label in browse br-docs then DO:   assign     sort-column-name = "shar_ord-line.ord-dec1"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each buf-goods no-lock where  buf-goods.artic = shar_ord-line.artic and  buf-goods.prod-type = shar_ord-line.prod-type and  buf-goods.prod-code = shar_ord-line.prod-code BY shar_ord-line.ord-dec1 .   . END.
        when shar_ord-line.sum-cli:label in browse br-docs then DO:   assign     sort-column-name = "shar_ord-line.sum-cli"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each buf-goods no-lock where  buf-goods.artic = shar_ord-line.artic and  buf-goods.prod-type = shar_ord-line.prod-type and  buf-goods.prod-code = shar_ord-line.prod-code BY shar_ord-line.sum-cli .   . END.
        when shar_ord-line.cli-art:label in browse br-docs then DO:   assign     sort-column-name = "shar_ord-line.cli-art"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each buf-goods no-lock where  buf-goods.artic = shar_ord-line.artic and  buf-goods.prod-type = shar_ord-line.prod-type and  buf-goods.prod-code = shar_ord-line.prod-code BY shar_ord-line.cli-art .   . END.
        when buf-goods.unit-base:label in browse br-docs then DO:   assign     sort-column-name = "buf-goods.unit-base"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each buf-goods no-lock where  buf-goods.artic = shar_ord-line.artic and  buf-goods.prod-type = shar_ord-line.prod-type and  buf-goods.prod-code = shar_ord-line.prod-code BY buf-goods.unit-base .   . END.
        when shar_ord-line.qnty:label in browse br-docs then DO:   assign     sort-column-name = "shar_ord-line.qnty"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each buf-goods no-lock where  buf-goods.artic = shar_ord-line.artic and  buf-goods.prod-type = shar_ord-line.prod-type and  buf-goods.prod-code = shar_ord-line.prod-code BY shar_ord-line.qnty .   . END.
        when shar_ord-line.price-rubl:label in browse br-docs then DO:   assign     sort-column-name = "shar_ord-line.price-rubl"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each buf-goods no-lock where  buf-goods.artic = shar_ord-line.artic and  buf-goods.prod-type = shar_ord-line.prod-type and  buf-goods.prod-code = shar_ord-line.prod-code BY shar_ord-line.price-rubl .   . END.
        when shar_ord-line.sum-rubl:label in browse br-docs then DO:   assign     sort-column-name = "shar_ord-line.sum-rubl"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each buf-goods no-lock where  buf-goods.artic = shar_ord-line.artic and  buf-goods.prod-type = shar_ord-line.prod-type and  buf-goods.prod-code = shar_ord-line.prod-code BY shar_ord-line.sum-rubl .   . END.
        when loc-sum-rcv:label in browse br-docs then DO:   assign     sort-column-name = "loc-sum-rcv"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each buf-goods no-lock where  buf-goods.artic = shar_ord-line.artic and  buf-goods.prod-type = shar_ord-line.prod-type and  buf-goods.prod-code = shar_ord-line.prod-code BY loc-sum-rcv .   . END.
        when shar_ord-line.qnty-stk:label in browse br-docs then DO:   assign     sort-column-name = "shar_ord-line.qnty-stk"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each buf-goods no-lock where  buf-goods.artic = shar_ord-line.artic and  buf-goods.prod-type = shar_ord-line.prod-type and  buf-goods.prod-code = shar_ord-line.prod-code BY shar_ord-line.qnty-stk .   . END.
        when v-fact-qnty:label in browse br-docs then DO:   assign     sort-column-name = "v-fact-qnty"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each buf-goods no-lock where  buf-goods.artic = shar_ord-line.artic and  buf-goods.prod-type = shar_ord-line.prod-type and  buf-goods.prod-code = shar_ord-line.prod-code BY v-fact-qnty .   . END.
        when shar_ord-line.gds-code:label in browse br-docs then DO:   assign     sort-column-name = "shar_ord-line.gds-code"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each buf-goods no-lock where  buf-goods.artic = shar_ord-line.artic and  buf-goods.prod-type = shar_ord-line.prod-type and  buf-goods.prod-code = shar_ord-line.prod-code BY shar_ord-line.gds-code .   . END.
        when v-min-stock:label in browse br-docs then DO:   assign     sort-column-name = "v-min-stock"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each buf-goods no-lock where  buf-goods.artic = shar_ord-line.artic and  buf-goods.prod-type = shar_ord-line.prod-type and  buf-goods.prod-code = shar_ord-line.prod-code BY v-min-stock .   . END.
        when v-gds-way:label in browse br-docs then DO:   assign     sort-column-name = "v-gds-way"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each buf-goods no-lock where  buf-goods.artic = shar_ord-line.artic and  buf-goods.prod-type = shar_ord-line.prod-type and  buf-goods.prod-code = shar_ord-line.prod-code BY v-gds-way .   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run openbr.
      if sort-labelbr-docs <> "" then do:
        assign
          cur-clmnbr-docs:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-docs = ?
      .
    end.
  end case.
  if p-recid <> ? then do:
    reposition br-docs to recid p-recid no-error.
    apply "value-changed" to br-docs in frame dialog-frame.
  end.
  apply "entry" to br-docs in frame dialog-frame.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-docs:
if cur-clmnbr-docs = ? then do:
   run openbr.
end.
else do:
   assign re-querybr-docs = yes.
   run sort-brbr-docs
     (input (if available shar_ord-line
             then recid(shar_ord-line)
             else ?
            )
     ).
   assign re-querybr-docs = no.
end.
end.
def var sort-labelbr-docs-2   as character no-undo .
def var sort-clmnbr-docs-2    as handle    no-undo .
def var cur-clmnbr-docs-2     as handle    no-undo .
def var cur-clmn-locbr-docs-2 as integer   no-undo .
def var re-querybr-docs-2     as logical   initial no no-undo .
on start-search, ctrl-o of br-docs-2 in frame frame-a do:
   run sort-brbr-docs-2
     (input (if available shar_ord-line
             then recid(shar_ord-line)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-docs-2 :
  define input parameter p-recid as recid no-undo .
  if re-querybr-docs-2 = no then do:
    assign
       cur-clmnbr-docs-2 = br-docs-2:current-column in frame frame-a
    .
    if sort-clmnbr-docs-2 <> ? then sort-clmnbr-docs-2:column-fgcolor = 0.
    if cur-clmnbr-docs-2 = sort-clmnbr-docs-2 then do:
      assign
         sort-labelbr-docs-2 = ""
         sort-clmnbr-docs-2 = ?
      .
     end.
     else do:
       assign
         sort-labelbr-docs-2 = cur-clmnbr-docs-2:label
         sort-clmnbr-docs-2  = cur-clmnbr-docs-2
         sort-clmnbr-docs-2:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-docs-2 = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-docs-2:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-docs-2 then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-docs-2 = cur-clmn-locbr-docs-2 + 1
    .
  end.
  case sort-labelbr-docs-2:
        when f-artic:label in browse br-docs-2 then DO:   assign     sort-column-name = "f-artic"   .   open query br-docs-2 for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each b-goods no-lock where  b-goods.artic     = shar_ord-line.artic and  b-goods.prod-type = shar_ord-line.prod-type and  b-goods.prod-code = shar_ord-line.prod-code , each ub.ord-dtl no-lock where ub.ord-dtl.doc-code = shar_ord-line.doc-code and  ub.ord-dtl.artic     = shar_ord-line.artic and  ub.ord-dtl.prod-type = shar_ord-line.prod-type and  ub.ord-dtl.prod-code = shar_ord-line.prod-code LEFT OUTER-JOIN , each buf-goods no-lock where  buf-goods.artic     = ub.ord-dtl.artic and  buf-goods.prod-type = ub.ord-dtl.prod-type and  buf-goods.prod-code = ub.ord-dtl.prod-code , each ub.gds-prt no-lock where  ub.gds-prt.node-code = ub.ord-dtl.node-code .   . END.
        when f-gds-name:label in browse br-docs-2 then DO:   assign     sort-column-name = "f-gds-name"   .   open query br-docs-2 for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each b-goods no-lock where  b-goods.artic     = shar_ord-line.artic and  b-goods.prod-type = shar_ord-line.prod-type and  b-goods.prod-code = shar_ord-line.prod-code , each ub.ord-dtl no-lock where ub.ord-dtl.doc-code = shar_ord-line.doc-code and  ub.ord-dtl.artic     = shar_ord-line.artic and  ub.ord-dtl.prod-type = shar_ord-line.prod-type and  ub.ord-dtl.prod-code = shar_ord-line.prod-code LEFT OUTER-JOIN , each buf-goods no-lock where  buf-goods.artic     = ub.ord-dtl.artic and  buf-goods.prod-type = ub.ord-dtl.prod-type and  buf-goods.prod-code = ub.ord-dtl.prod-code , each ub.gds-prt no-lock where  ub.gds-prt.node-code = ub.ord-dtl.node-code .   . END.
        when f-prt-name:label in browse br-docs-2 then DO:   assign     sort-column-name = "f-prt-name"   .   open query br-docs-2 for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each b-goods no-lock where  b-goods.artic     = shar_ord-line.artic and  b-goods.prod-type = shar_ord-line.prod-type and  b-goods.prod-code = shar_ord-line.prod-code , each ub.ord-dtl no-lock where ub.ord-dtl.doc-code = shar_ord-line.doc-code and  ub.ord-dtl.artic     = shar_ord-line.artic and  ub.ord-dtl.prod-type = shar_ord-line.prod-type and  ub.ord-dtl.prod-code = shar_ord-line.prod-code LEFT OUTER-JOIN , each buf-goods no-lock where  buf-goods.artic     = ub.ord-dtl.artic and  buf-goods.prod-type = ub.ord-dtl.prod-type and  buf-goods.prod-code = ub.ord-dtl.prod-code , each ub.gds-prt no-lock where  ub.gds-prt.node-code = ub.ord-dtl.node-code .   . END.
        when f-unit-base:label in browse br-docs-2 then DO:   assign     sort-column-name = "f-unit-base"   .   open query br-docs-2 for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each b-goods no-lock where  b-goods.artic     = shar_ord-line.artic and  b-goods.prod-type = shar_ord-line.prod-type and  b-goods.prod-code = shar_ord-line.prod-code , each ub.ord-dtl no-lock where ub.ord-dtl.doc-code = shar_ord-line.doc-code and  ub.ord-dtl.artic     = shar_ord-line.artic and  ub.ord-dtl.prod-type = shar_ord-line.prod-type and  ub.ord-dtl.prod-code = shar_ord-line.prod-code LEFT OUTER-JOIN , each buf-goods no-lock where  buf-goods.artic     = ub.ord-dtl.artic and  buf-goods.prod-type = ub.ord-dtl.prod-type and  buf-goods.prod-code = ub.ord-dtl.prod-code , each ub.gds-prt no-lock where  ub.gds-prt.node-code = ub.ord-dtl.node-code .   . END.
        when shar_ord-line.qnty:label in browse br-docs-2 then DO:   assign     sort-column-name = "shar_ord-line.qnty"   .   open query br-docs-2 for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each b-goods no-lock where  b-goods.artic     = shar_ord-line.artic and  b-goods.prod-type = shar_ord-line.prod-type and  b-goods.prod-code = shar_ord-line.prod-code , each ub.ord-dtl no-lock where ub.ord-dtl.doc-code = shar_ord-line.doc-code and  ub.ord-dtl.artic     = shar_ord-line.artic and  ub.ord-dtl.prod-type = shar_ord-line.prod-type and  ub.ord-dtl.prod-code = shar_ord-line.prod-code LEFT OUTER-JOIN , each buf-goods no-lock where  buf-goods.artic     = ub.ord-dtl.artic and  buf-goods.prod-type = ub.ord-dtl.prod-type and  buf-goods.prod-code = ub.ord-dtl.prod-code , each ub.gds-prt no-lock where  ub.gds-prt.node-code = ub.ord-dtl.node-code .   . END.
        when f-qnty:label in browse br-docs-2 then DO:   assign     sort-column-name = "f-qnty"   .   open query br-docs-2 for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each b-goods no-lock where  b-goods.artic     = shar_ord-line.artic and  b-goods.prod-type = shar_ord-line.prod-type and  b-goods.prod-code = shar_ord-line.prod-code , each ub.ord-dtl no-lock where ub.ord-dtl.doc-code = shar_ord-line.doc-code and  ub.ord-dtl.artic     = shar_ord-line.artic and  ub.ord-dtl.prod-type = shar_ord-line.prod-type and  ub.ord-dtl.prod-code = shar_ord-line.prod-code LEFT OUTER-JOIN , each buf-goods no-lock where  buf-goods.artic     = ub.ord-dtl.artic and  buf-goods.prod-type = ub.ord-dtl.prod-type and  buf-goods.prod-code = ub.ord-dtl.prod-code , each ub.gds-prt no-lock where  ub.gds-prt.node-code = ub.ord-dtl.node-code .   . END.
        when f-price-rubl:label in browse br-docs-2 then DO:   assign     sort-column-name = "f-price-rubl"   .   open query br-docs-2 for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each b-goods no-lock where  b-goods.artic     = shar_ord-line.artic and  b-goods.prod-type = shar_ord-line.prod-type and  b-goods.prod-code = shar_ord-line.prod-code , each ub.ord-dtl no-lock where ub.ord-dtl.doc-code = shar_ord-line.doc-code and  ub.ord-dtl.artic     = shar_ord-line.artic and  ub.ord-dtl.prod-type = shar_ord-line.prod-type and  ub.ord-dtl.prod-code = shar_ord-line.prod-code LEFT OUTER-JOIN , each buf-goods no-lock where  buf-goods.artic     = ub.ord-dtl.artic and  buf-goods.prod-type = ub.ord-dtl.prod-type and  buf-goods.prod-code = ub.ord-dtl.prod-code , each ub.gds-prt no-lock where  ub.gds-prt.node-code = ub.ord-dtl.node-code .   . END.
        when f-sum-rubl:label in browse br-docs-2 then DO:   assign     sort-column-name = "f-sum-rubl"   .   open query br-docs-2 for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each b-goods no-lock where  b-goods.artic     = shar_ord-line.artic and  b-goods.prod-type = shar_ord-line.prod-type and  b-goods.prod-code = shar_ord-line.prod-code , each ub.ord-dtl no-lock where ub.ord-dtl.doc-code = shar_ord-line.doc-code and  ub.ord-dtl.artic     = shar_ord-line.artic and  ub.ord-dtl.prod-type = shar_ord-line.prod-type and  ub.ord-dtl.prod-code = shar_ord-line.prod-code LEFT OUTER-JOIN , each buf-goods no-lock where  buf-goods.artic     = ub.ord-dtl.artic and  buf-goods.prod-type = ub.ord-dtl.prod-type and  buf-goods.prod-code = ub.ord-dtl.prod-code , each ub.gds-prt no-lock where  ub.gds-prt.node-code = ub.ord-dtl.node-code .   . END.
        when shar_ord-line.unit-cli:label in browse br-docs-2 then DO:   assign     sort-column-name = "shar_ord-line.unit-cli"   .   open query br-docs-2 for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each b-goods no-lock where  b-goods.artic     = shar_ord-line.artic and  b-goods.prod-type = shar_ord-line.prod-type and  b-goods.prod-code = shar_ord-line.prod-code , each ub.ord-dtl no-lock where ub.ord-dtl.doc-code = shar_ord-line.doc-code and  ub.ord-dtl.artic     = shar_ord-line.artic and  ub.ord-dtl.prod-type = shar_ord-line.prod-type and  ub.ord-dtl.prod-code = shar_ord-line.prod-code LEFT OUTER-JOIN , each buf-goods no-lock where  buf-goods.artic     = ub.ord-dtl.artic and  buf-goods.prod-type = ub.ord-dtl.prod-type and  buf-goods.prod-code = ub.ord-dtl.prod-code , each ub.gds-prt no-lock where  ub.gds-prt.node-code = ub.ord-dtl.node-code .   . END.
        when shar_ord-line.cli-qnty:label in browse br-docs-2 then DO:   assign     sort-column-name = "shar_ord-line.cli-qnty"   .   open query br-docs-2 for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each b-goods no-lock where  b-goods.artic     = shar_ord-line.artic and  b-goods.prod-type = shar_ord-line.prod-type and  b-goods.prod-code = shar_ord-line.prod-code , each ub.ord-dtl no-lock where ub.ord-dtl.doc-code = shar_ord-line.doc-code and  ub.ord-dtl.artic     = shar_ord-line.artic and  ub.ord-dtl.prod-type = shar_ord-line.prod-type and  ub.ord-dtl.prod-code = shar_ord-line.prod-code LEFT OUTER-JOIN , each buf-goods no-lock where  buf-goods.artic     = ub.ord-dtl.artic and  buf-goods.prod-type = ub.ord-dtl.prod-type and  buf-goods.prod-code = ub.ord-dtl.prod-code , each ub.gds-prt no-lock where  ub.gds-prt.node-code = ub.ord-dtl.node-code .   . END.
        when f-cli-qnty:label in browse br-docs-2 then DO:   assign     sort-column-name = "f-cli-qnty"   .   open query br-docs-2 for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each b-goods no-lock where  b-goods.artic     = shar_ord-line.artic and  b-goods.prod-type = shar_ord-line.prod-type and  b-goods.prod-code = shar_ord-line.prod-code , each ub.ord-dtl no-lock where ub.ord-dtl.doc-code = shar_ord-line.doc-code and  ub.ord-dtl.artic     = shar_ord-line.artic and  ub.ord-dtl.prod-type = shar_ord-line.prod-type and  ub.ord-dtl.prod-code = shar_ord-line.prod-code LEFT OUTER-JOIN , each buf-goods no-lock where  buf-goods.artic     = ub.ord-dtl.artic and  buf-goods.prod-type = ub.ord-dtl.prod-type and  buf-goods.prod-code = ub.ord-dtl.prod-code , each ub.gds-prt no-lock where  ub.gds-prt.node-code = ub.ord-dtl.node-code .   . END.
        when f-price-cli:label in browse br-docs-2 then DO:   assign     sort-column-name = "f-price-cli"   .   open query br-docs-2 for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each b-goods no-lock where  b-goods.artic     = shar_ord-line.artic and  b-goods.prod-type = shar_ord-line.prod-type and  b-goods.prod-code = shar_ord-line.prod-code , each ub.ord-dtl no-lock where ub.ord-dtl.doc-code = shar_ord-line.doc-code and  ub.ord-dtl.artic     = shar_ord-line.artic and  ub.ord-dtl.prod-type = shar_ord-line.prod-type and  ub.ord-dtl.prod-code = shar_ord-line.prod-code LEFT OUTER-JOIN , each buf-goods no-lock where  buf-goods.artic     = ub.ord-dtl.artic and  buf-goods.prod-type = ub.ord-dtl.prod-type and  buf-goods.prod-code = ub.ord-dtl.prod-code , each ub.gds-prt no-lock where  ub.gds-prt.node-code = ub.ord-dtl.node-code .   . END.
        when f-sum-cli:label in browse br-docs-2 then DO:   assign     sort-column-name = "f-sum-cli"   .   open query br-docs-2 for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each b-goods no-lock where  b-goods.artic     = shar_ord-line.artic and  b-goods.prod-type = shar_ord-line.prod-type and  b-goods.prod-code = shar_ord-line.prod-code , each ub.ord-dtl no-lock where ub.ord-dtl.doc-code = shar_ord-line.doc-code and  ub.ord-dtl.artic     = shar_ord-line.artic and  ub.ord-dtl.prod-type = shar_ord-line.prod-type and  ub.ord-dtl.prod-code = shar_ord-line.prod-code LEFT OUTER-JOIN , each buf-goods no-lock where  buf-goods.artic     = ub.ord-dtl.artic and  buf-goods.prod-type = ub.ord-dtl.prod-type and  buf-goods.prod-code = ub.ord-dtl.prod-code , each ub.gds-prt no-lock where  ub.gds-prt.node-code = ub.ord-dtl.node-code .   . END.
        when shar_ord-line.cli-art:label in browse br-docs-2 then DO:   assign     sort-column-name = "shar_ord-line.cli-art"   .   open query br-docs-2 for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each b-goods no-lock where  b-goods.artic     = shar_ord-line.artic and  b-goods.prod-type = shar_ord-line.prod-type and  b-goods.prod-code = shar_ord-line.prod-code , each ub.ord-dtl no-lock where ub.ord-dtl.doc-code = shar_ord-line.doc-code and  ub.ord-dtl.artic     = shar_ord-line.artic and  ub.ord-dtl.prod-type = shar_ord-line.prod-type and  ub.ord-dtl.prod-code = shar_ord-line.prod-code LEFT OUTER-JOIN , each buf-goods no-lock where  buf-goods.artic     = ub.ord-dtl.artic and  buf-goods.prod-type = ub.ord-dtl.prod-type and  buf-goods.prod-code = ub.ord-dtl.prod-code , each ub.gds-prt no-lock where  ub.gds-prt.node-code = ub.ord-dtl.node-code .   . END.
        when f-loc-sum-rcv:label in browse br-docs-2 then DO:   assign     sort-column-name = "f-loc-sum-rcv"   .   open query br-docs-2 for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each b-goods no-lock where  b-goods.artic     = shar_ord-line.artic and  b-goods.prod-type = shar_ord-line.prod-type and  b-goods.prod-code = shar_ord-line.prod-code , each ub.ord-dtl no-lock where ub.ord-dtl.doc-code = shar_ord-line.doc-code and  ub.ord-dtl.artic     = shar_ord-line.artic and  ub.ord-dtl.prod-type = shar_ord-line.prod-type and  ub.ord-dtl.prod-code = shar_ord-line.prod-code LEFT OUTER-JOIN , each buf-goods no-lock where  buf-goods.artic     = ub.ord-dtl.artic and  buf-goods.prod-type = ub.ord-dtl.prod-type and  buf-goods.prod-code = ub.ord-dtl.prod-code , each ub.gds-prt no-lock where  ub.gds-prt.node-code = ub.ord-dtl.node-code .   . END.
        when f-loc-err-rcv:label in browse br-docs-2 then DO:   assign     sort-column-name = "f-loc-err-rcv"   .   open query br-docs-2 for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each b-goods no-lock where  b-goods.artic     = shar_ord-line.artic and  b-goods.prod-type = shar_ord-line.prod-type and  b-goods.prod-code = shar_ord-line.prod-code , each ub.ord-dtl no-lock where ub.ord-dtl.doc-code = shar_ord-line.doc-code and  ub.ord-dtl.artic     = shar_ord-line.artic and  ub.ord-dtl.prod-type = shar_ord-line.prod-type and  ub.ord-dtl.prod-code = shar_ord-line.prod-code LEFT OUTER-JOIN , each buf-goods no-lock where  buf-goods.artic     = ub.ord-dtl.artic and  buf-goods.prod-type = ub.ord-dtl.prod-type and  buf-goods.prod-code = ub.ord-dtl.prod-code , each ub.gds-prt no-lock where  ub.gds-prt.node-code = ub.ord-dtl.node-code .   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      open query br-docs-2 for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each b-goods no-lock where  b-goods.artic     = shar_ord-line.artic and  b-goods.prod-type = shar_ord-line.prod-type and  b-goods.prod-code = shar_ord-line.prod-code , each ub.ord-dtl no-lock where ub.ord-dtl.doc-code = shar_ord-line.doc-code and  ub.ord-dtl.artic     = shar_ord-line.artic and  ub.ord-dtl.prod-type = shar_ord-line.prod-type and  ub.ord-dtl.prod-code = shar_ord-line.prod-code LEFT OUTER-JOIN , each buf-goods no-lock where  buf-goods.artic     = ub.ord-dtl.artic and  buf-goods.prod-type = ub.ord-dtl.prod-type and  buf-goods.prod-code = ub.ord-dtl.prod-code , each ub.gds-prt no-lock where  ub.gds-prt.node-code = ub.ord-dtl.node-code .
      if sort-labelbr-docs-2 <> "" then do:
        assign
          cur-clmnbr-docs-2:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-docs-2 = ?
      .
    end.
  end case.
    if cur-clmn-locbr-docs-2 <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnbr-docs-2') then do:
        run ch-clmnbr-docs-2 in this-procedure (cur-clmn-locbr-docs-2).
      end.
    end.
  if p-recid <> ? then do:
    reposition br-docs-2 to recid p-recid no-error.
    apply "value-changed" to br-docs-2 in frame frame-a.
  end.
  apply "entry" to br-docs-2 in frame frame-a.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-docs-2:
if cur-clmnbr-docs-2 = ? then do:
   open query br-docs-2 for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each b-goods no-lock where  b-goods.artic     = shar_ord-line.artic and  b-goods.prod-type = shar_ord-line.prod-type and  b-goods.prod-code = shar_ord-line.prod-code , each ub.ord-dtl no-lock where ub.ord-dtl.doc-code = shar_ord-line.doc-code and  ub.ord-dtl.artic     = shar_ord-line.artic and  ub.ord-dtl.prod-type = shar_ord-line.prod-type and  ub.ord-dtl.prod-code = shar_ord-line.prod-code LEFT OUTER-JOIN , each buf-goods no-lock where  buf-goods.artic     = ub.ord-dtl.artic and  buf-goods.prod-type = ub.ord-dtl.prod-type and  buf-goods.prod-code = ub.ord-dtl.prod-code , each ub.gds-prt no-lock where  ub.gds-prt.node-code = ub.ord-dtl.node-code .
end.
else do:
   assign re-querybr-docs-2 = yes.
   run sort-brbr-docs-2
     (input (if available shar_ord-line
             then recid(shar_ord-line)
             else ?
            )
     ).
   assign re-querybr-docs-2 = no.
end.
end.
define variable t5 as decimal no-undo .
g#type = shar-buf_ord-doc.doc-type .
doc-rec = recid(shar-buf_ord-doc)  .
define variable firstr as logical   no-undo .
firstr = true .
next-prev = yes.
n-p: do while next-prev :
main-block:
do on error   undo main-block, leave main-block
   on end-key undo main-block, leave main-block
   on stop    undo main-block, leave main-block:
   run mode-on in this-procedure.
  if not ( shar_ord-doc.doc-type = 'ОП':U or shar_ord-doc.doc-type = 'ОФ':U) then do:
      shar_ord-line.qnty-stk:visible in browse br-docs = false .
      v-fact-qnty:visible in browse br-docs = false .
  end.
  t#query-was-opened = true.
  v-fl = true .
  run select-good-scala .
  run pr-tog-prt in this-procedure.
  run openbr.
  if firstr then do:
  run init-browse-p  in this-procedure .
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-docs as INT EXTENT 25 no-undo.
DEF VAR varmvibr-docs       as INT no-undo.
DEF VAR varmvjbr-docs       as INT no-undo.
DEF VAR varmvkbr-docs       as INT no-undo.
DEF VAR varmvlbr-docs       as INT no-undo.
DEF VAR move-elementbr-docs as INT no-undo.
def var jjbr-docs           as int no-undo.
do varmvibr-docs = 1 to EXTENT(cur-clmn-numbr-docs):
  ASSIGN cur-clmn-numbr-docs[varmvibr-docs] = varmvibr-docs.
END.
RUN start-mv-clmnbr-docs.
PROCEDURE start-mv-clmnbr-docs:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
       IF  true = true  THEN DO:
   DO jjbr-docs = NUM-ENTRIES(v-order-column) TO 1 BY -1:
     RUN re-move-clmnbr-docs ( cur-clmn-numbr-docs[INTEGER(ENTRY (jjbr-docs, v-order-column))] , 1).
   END.
       END.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-docs do:
  RUN re-move-clmnbr-docs ( 1, 25).
END.
ON ctrl-cursor-left OF BROWSE br-docs do:
  RUN re-move-clmnbr-docs (25, 1).
END.
PROCEDURE re-move-clmnbr-docs:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-docs = 1 TO EXTENT(cur-clmn-numbr-docs):
    if cur-clmn-numbr-docs[varmvibr-docs] = source-column THEN cur-clmn-numbr-docs[varmvibr-docs] = -1.
  END.
  if br-docs:MOVE-COLUMN(source-column, target-column) IN FRAME dialog-frame then.
  if source-column > target-column THEN
  DO varmvjbr-docs = source-column - 1 to target-column BY -1:
    DO varmvibr-docs = 1 TO EXTENT(cur-clmn-numbr-docs):
        if cur-clmn-numbr-docs[varmvibr-docs] = varmvjbr-docs THEN DO:
          cur-clmn-numbr-docs[varmvibr-docs] = cur-clmn-numbr-docs[varmvibr-docs] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-docs = source-column + 1 to target-column:
    DO varmvibr-docs = 1 TO EXTENT(cur-clmn-numbr-docs):
      if cur-clmn-numbr-docs[varmvibr-docs] = varmvjbr-docs THEN DO:
        cur-clmn-numbr-docs[varmvibr-docs] = cur-clmn-numbr-docs[varmvibr-docs] - 1.
      END.
    END.
  END.
  DO varmvibr-docs = 1 TO EXTENT(cur-clmn-numbr-docs):
    if cur-clmn-numbr-docs[varmvibr-docs] = -1 THEN cur-clmn-numbr-docs[varmvibr-docs] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-docs:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 1 then do:
    return .
  end.
  DO varmvibr-docs = 1 TO EXTENT(cur-clmn-numbr-docs):
    if cur-clmn-numbr-docs[varmvibr-docs] = cur-clmn-loc THEN move-elementbr-docs = varmvibr-docs.
  END.
  RUN re-move-clmnbr-docs (cur-clmn-loc, 1).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-docs:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-docs = 1 to EXTENT(cur-clmn-numbr-docs):
    RUN re-move-clmnbr-docs (cur-clmn-numbr-docs[varmvlbr-docs], varmvlbr-docs).
  END.
  RUN start-mv-clmnbr-docs.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-docs-2 as INT EXTENT 16 no-undo.
DEF VAR varmvibr-docs-2       as INT no-undo.
DEF VAR varmvjbr-docs-2       as INT no-undo.
DEF VAR varmvkbr-docs-2       as INT no-undo.
DEF VAR varmvlbr-docs-2       as INT no-undo.
DEF VAR move-elementbr-docs-2 as INT no-undo.
def var jjbr-docs-2           as int no-undo.
do varmvibr-docs-2 = 1 to EXTENT(cur-clmn-numbr-docs-2):
  ASSIGN cur-clmn-numbr-docs-2[varmvibr-docs-2] = varmvibr-docs-2.
END.
RUN start-mv-clmnbr-docs-2.
PROCEDURE start-mv-clmnbr-docs-2:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-docs-2 do:
  RUN re-move-clmnbr-docs-2 ( 1, 16).
END.
ON ctrl-cursor-left OF BROWSE br-docs-2 do:
  RUN re-move-clmnbr-docs-2 (16, 1).
END.
PROCEDURE re-move-clmnbr-docs-2:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-docs-2 = 1 TO EXTENT(cur-clmn-numbr-docs-2):
    if cur-clmn-numbr-docs-2[varmvibr-docs-2] = source-column THEN cur-clmn-numbr-docs-2[varmvibr-docs-2] = -1.
  END.
  if br-docs-2:MOVE-COLUMN(source-column, target-column) IN FRAME frame-a then.
  if source-column > target-column THEN
  DO varmvjbr-docs-2 = source-column - 1 to target-column BY -1:
    DO varmvibr-docs-2 = 1 TO EXTENT(cur-clmn-numbr-docs-2):
        if cur-clmn-numbr-docs-2[varmvibr-docs-2] = varmvjbr-docs-2 THEN DO:
          cur-clmn-numbr-docs-2[varmvibr-docs-2] = cur-clmn-numbr-docs-2[varmvibr-docs-2] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-docs-2 = source-column + 1 to target-column:
    DO varmvibr-docs-2 = 1 TO EXTENT(cur-clmn-numbr-docs-2):
      if cur-clmn-numbr-docs-2[varmvibr-docs-2] = varmvjbr-docs-2 THEN DO:
        cur-clmn-numbr-docs-2[varmvibr-docs-2] = cur-clmn-numbr-docs-2[varmvibr-docs-2] - 1.
      END.
    END.
  END.
  DO varmvibr-docs-2 = 1 TO EXTENT(cur-clmn-numbr-docs-2):
    if cur-clmn-numbr-docs-2[varmvibr-docs-2] = -1 THEN cur-clmn-numbr-docs-2[varmvibr-docs-2] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-docs-2:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 1 then do:
    return .
  end.
  DO varmvibr-docs-2 = 1 TO EXTENT(cur-clmn-numbr-docs-2):
    if cur-clmn-numbr-docs-2[varmvibr-docs-2] = cur-clmn-loc THEN move-elementbr-docs-2 = varmvibr-docs-2.
  END.
  RUN re-move-clmnbr-docs-2 (cur-clmn-loc, 1).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-docs-2:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-docs-2 = 1 to EXTENT(cur-clmn-numbr-docs-2):
    RUN re-move-clmnbr-docs-2 (cur-clmn-numbr-docs-2[varmvlbr-docs-2], varmvlbr-docs-2).
  END.
  RUN start-mv-clmnbr-docs-2.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
  firstr = false  .
 end.
 wait-for go of frame dialog-frame focus br-docs .
end.
end.
run disable_ui  in this-procedure  .
procedure chg-action :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
define buffer buff_contract for ub.contract .
t-ret =  session:set-wait-state("general") .
 find first shar_ord-doc no-lock  where recid(shar_ord-doc) = doc-rec  no-error.
 if not available shar_ord-doc then  do:
    t-ret =  session:set-wait-state("") .
    return.
 end.
 find first buf-cli      no-lock  where buf-cli.obj-code    = shar_ord-doc.cli-code
                                    and buf-cli.obj-type    = shar_ord-doc.cli-type no-error .
 p-doc-code  = shar_ord-doc.doc-code.
  if available shar_ord-doc then  do:
     find first for-obj where for-obj.obj-code = shar_ord-doc.obj-code and
                              for-obj.obj-type = shar_ord-doc.obj-type no-lock no-error .
     if error-status :error then return error.
    assign
      date-1 = shar_ord-doc.start-date
      date-2 = shar_ord-doc.end-date no-error .
      if error-status :error then
         assign
            date-1 = to-day - 7
            date-2 = to-day.
    find first buff_contract no-lock where buff_contract.host-code     = shar_ord-doc.host-code and
                                           buff_contract.contract-code = shar_ord-doc.contract-code no-error .
    if available buff_contract then
       v-loc-contract        =  buff_contract.contract-prn-code + "(" + string(buff_contract.contract-code) + ")" .
       else v-loc-contract   = "".
    assign
      loc-obj-name-2 = "(" + shar_ord-doc.obj-type + " " + string(shar_ord-doc.obj-code ) + ")" + for-obj.obj-name
      wrkr          = shar_ord-doc.wrkr
      agnt          = shar_ord-doc.agnt
      boss          = shar_ord-doc.boss
      loc-time-ship = string(shar_ord-doc.ship-time,"hh:mm")
      loc-hour      = integer (entry(1,string(shar_ord-doc.ship-time,"hh:mm"),":"))
      loc-min       = integer (entry(2,string(shar_ord-doc.ship-time,"hh:mm"),":"))
      date-sale-1   = shar_ord-doc.date-sale-1
      date-sale-2   = shar_ord-doc.date-sale-2
      e-method      = shar_ord-doc.e-method
      loc-date-ship = shar_ord-doc.ship-date
      loc-status    = shar_ord-doc.status_
      paytype       = shar_ord-doc.pay-code
      loc-service   = shar_ord-doc.sum-service
      cycle-day     = shar_ord-doc.cycle-day
      pay-day       = shar_ord-doc.pay-day
      tog-type      = shar_ord-doc.order-type
      loc-base-rate   = shar_ord-doc.base-rate
      loc-base-scale  = shar_ord-doc.base-scale
      loc-cli-qnty    = shar_ord-doc.cli-qnty
      loc-qnty        = shar_ord-doc.qnty
      loc-sum-base    = shar_ord-doc.sum-base
      loc-sum-cli     = shar_ord-doc.sum-cli
      loc-sum-rubl    = shar_ord-doc.sum-rubl
      loc-tot-lines   = shar_ord-doc.tot-lines
      loc-exch-code   = shar_ord-doc.exch-code
      loc-exch-rate   = shar_ord-doc.exch-rate
      loc-exch-scale  = shar_ord-doc.exch-scale
      loc-out-code    = shar_ord-doc.out-code
      doc-date        = shar_ord-doc.doc-date
      loc-doc-type    = shar_ord-doc.doc-type
      fact-date       = shar_ord-doc.fact-date
      vat_type        = shar_ord-doc.vat-type
      slt_type        = shar_ord-doc.slt-type
      loc-print-rubl  = true
      loc-store-code  = shar_ord-doc.obj-code
      loc-store-type  = shar_ord-doc.obj-type
      v-deliv-type-code     =  shar_ord-doc.deliv-type-code
      v-point-obj-code      =  shar_ord-doc.obj-point-code
      v-point-cli-code      =  shar_ord-doc.cli-point-code
      v-point-obj-db-num    =  shar_ord-doc.obj-point-db-num
      v-point-cli-db-num    =  shar_ord-doc.cli-point-db-num
      v-transport-host-code =  shar_ord-doc.transport-host-code
      v-transport-cli-type  =  shar_ord-doc.transport-cli-type
      v-transport-cli-code  =  shar_ord-doc.transport-cli-code
      v-transport-contract  =  shar_ord-doc.transport-contract
      v-transport-condition =  shar_ord-doc.transport-condition
      v-transport-value     =  shar_ord-doc.transport-value
      v-transport-sum       =  shar_ord-doc.sum-ship
      v-transport-vat       =  shar_ord-doc.transport-vat
      loc-cli-out-doc       =  entry(1, shar_ord-doc.cli-out-doc, chr(4))
      .
      find ub.currency where ub.currency.curr-code = loc-exch-code no-lock no-error.
        if available ub.currency then disp ub.currency.curr-abbr with frame dialog-frame.
                              else disp ? @ ub.currency.curr-abbr with frame dialog-frame.
   end.
   find ub.pay-type where ub.pay-type.obj-code = shar_ord-doc.pay-code no-lock no-error.
   if available ub.pay-type then  do:
    assign
    loc-pay-type = ub.pay-type.obj-name  .
    end.
    find first buf-cli where shar_ord-doc.cli-type = buf-cli.obj-type  and shar_ord-doc.cli-code = buf-cli.obj-code  no-lock no-error.
    if available buf-cli then
    assign
        loc-cli-code = buf-cli.obj-code
        loc-cli-type = buf-cli.obj-type
        loc-obj-name = buf-cli.obj-name
        no-error.
     else
     assign
        loc-cli-code = ?
        loc-cli-type = ?
        loc-obj-name = ?
        no-error.
     assign loc-ord-num = shar_ord-doc.doc-code
            loc-status  = shar_ord-doc.status_  no-error.
    find first clients-doc where clients-doc.obj-code = wrkr
                             and clients-doc.obj-type = 'чел':U no-lock no-error.
         if  error-status :error then error-status :error = false .
        if avail clients-doc then do:
         wrkr-name = clients-doc.obj-name.
       end.
    find first clients-doc1 where clients-doc1.obj-code = agnt
                             and clients-doc1.obj-type = 'чел':U no-lock no-error.
         if  error-status :error then error-status :error = false .
         if avail clients-doc1 then agnt-name = clients-doc1.obj-name.
    find first clients-doc2 where clients-doc2.obj-code = boss
                             and clients-doc2.obj-type = 'чел':U no-lock no-error.
     if  error-status :error then error-status :error = false .
     if avail clients-doc2 then boss-name = clients-doc2.obj-name.
     if  error-status :error then error-status :error = false .
    disable loc-cli-code
            loc-cli-type
            loc-obj-name
            r-clients with frame dialog-frame.
     display
            wrkr agnt boss wrkr-name agnt-name boss-name
            loc-cli-code
            loc-cli-type
            loc-obj-name
            with frame dialog-frame.
  run openbr in this-procedure  .
 t-ret =  session:set-wait-state("") .
end.
end procedure.
procedure disable_ui :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
  hide frame dialog-frame.
  hide frame a-frame.
end.
end procedure.
procedure enable_ui_2 :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
if g#type <> 'ОФ':U then do:
  display  loc-cli-type loc-cli-code  doc-date fact-date paytype wrkr tog-type  tog-prt  cycle-day  agnt r-agnt loc-date-ship  loc-service boss r-boss loc-qnty loc-exch-code  r-currency loc-cli-qnty loc-exch-rate loc-exch-scale r-acc loc-sum-rubl loc-base-rate loc-base-scale loc-sum-base loc-tot-lines  loc-sum-cli slt_type vat_type br-docs e-method loc-obj-name loc-obj-name-2 loc-pay-type loc-cli-out-doc t agnt-name boss-name prod-name goods-name  date-sale-1 date-sale-2  loc-hour loc-min  b-way v-loc-contract b-contract b-protocol      with frame dialog-frame.
end.
else do:
  display loc-cli-type loc-cli-code  doc-date fact-date  wrkr tog-type  tog-prt  cycle-day  agnt r-agnt loc-date-ship boss r-boss loc-qnty loc-cli-qnty loc-tot-lines  br-docs e-method loc-obj-name loc-obj-name-2 loc-pay-type loc-cli-out-doc t agnt-name boss-name prod-name goods-name  date-sale-1 date-sale-2  loc-hour loc-min  b-way      with frame dialog-frame.
end.
disable   all      with frame dialog-frame.
  enable b-exit  b-producer  b-alt-post  b-notes  b-help
         br-docs b-export
         b-next b-prev  b-way
         b-inf b-delivery
         b-contract
         b-protocol
      with frame dialog-frame.
   display
         b-next b-prev
      with frame dialog-frame.
   enable e-method with frame dialog-frame.
   e-method:read-only = true .
  display
   b-exit  b-producer  b-alt-post  b-notes  b-help
   br-docs b-export  b-way
  with frame dialog-frame.
  hide b-chg b-main-calc in frame dialog-frame .
  view frame dialog-frame.
end.
end procedure.
procedure openbr :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
t-ret =  session:set-wait-state("general") .
define variable l-query-was-opened as logical no-undo .
define variable sort-column-phrase as character no-undo .
case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.
        assign frame dialog-frame:title =  ( if g#type = 'ОФ':U then  " ЗАЯВКА № "
                                                                 else  " ЗАКАЗ  № "  )
                                                                 + loc-ord-num .
        if t-action = "lkp":u then  frame dialog-frame:title = frame dialog-frame:title + " (" + shar_ord-doc.doc-type + ") - " + 'ПРОСМОТР':U.
        open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each buf-goods no-lock where  buf-goods.artic = shar_ord-line.artic and  buf-goods.prod-type = shar_ord-line.prod-type and  buf-goods.prod-code = shar_ord-line.prod-code by shar_ord-line.line-num.
   run enable_ui_2 .
  t-ret =  session:set-wait-state("") .
  error-status :error = false .
end.
end procedure.
procedure ex-file :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
define input parameter ff as character no-undo .
define input parameter ex as logical no-undo . .
  if ex = false then do:
      create "excel.application" chexcelapplication connect no-error.
     if error-status:error then
     do:
        create "excel.application" chexcelapplication no-error.
        if error-status :error then
        do:
           message
              "Ошибка при запуске Excel" skip
              error-status :get-message(1) skip
              view-as alert-box error .
           undo, return error .
        end.
     end.
    if ff = ""  then do:
      chworkbook   = chexcelapplication:workbooks:add( ).
    end.
    else do:
      chworkbook   = chexcelapplication:workbooks:open( ff ).
    end.
  end.
  assign     chexcelapplication:interactive = false      chexcelapplication:screenupdating = false      chexcelapplication:visible = false  .
  chworksheet  = chexcelapplication:sheets:item (1).
end.
end procedure.
procedure b-export-ch :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
  g#log = true  .
  message "Экспорт в excel ." skip "Продолжать ?"
           view-as alert-box question buttons ok-cancel update g#log.
           if not g#log then return no-apply.
      run cus/z-tot1.p (PARPARENTPROC , p-doc-code , shar_ord-doc.obj-type , shar_ord-doc.obj-code ).
end.
end procedure.
procedure select-good-scala :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
hide pay-day  in frame dialog-frame.
hide loc-out-code  in frame dialog-frame.
find  current shar_ord-line no-lock  no-error .
if not avail  shar_ord-line then do:  . return. end.
assign
    x-prod-type = shar_ord-line.prod-type
    x-prod-code = shar_ord-line.prod-code
    x-artic     = shar_ord-line.artic
    .
  find first for-cli no-lock where for-cli.obj-type = shar_ord-line.prod-type and
                                   for-cli.obj-code = shar_ord-line.prod-code no-error.
  if avail for-cli then do:
      display for-cli.obj-name      @ prod-name
              buf-goods.gds-name    @ goods-name
              with frame dialog-frame .
  end.
  else do:
      display "" @ prod-name  with frame dialog-frame.
  end.
  if error-status :error  then message "123-" error-status :error.
end.
end procedure .
procedure select-good-scala-2 :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
define buffer bb_goods for ub.goods .
find  current shar_ord-line no-lock  no-error .
if not avail  shar_ord-line then do:
      find  current ub.ord-dtl no-lock  no-error .
      if not avail  ub.ord-dtl then do: return.  end.
      assign
        x-prod-type = ub.ord-dtl.prod-type
        x-prod-code = ub.ord-dtl.prod-code
        x-artic     = ub.ord-dtl.artic
        .
  end.
else
assign
  x-prod-type = shar_ord-line.prod-type
  x-prod-code = shar_ord-line.prod-code
  x-artic     = shar_ord-line.artic
  .
  find first bb_goods no-lock where bb_goods.prod-type = x-prod-type and
                                    bb_goods.prod-code  = x-prod-code  and
                                    bb_goods.artic      = x-artic
                                    no-error.
  find first for-cli no-lock where for-cli.obj-type = x-prod-type and
                                   for-cli.obj-code = x-prod-code no-error.
  if avail for-cli then do:
      display for-cli.obj-name      @ prod-name
              bb_goods.gds-name    @ goods-name
              with frame  dialog-frame .
  end.
  else do:
      display "" @ prod-name  with frame dialog-frame.
  end.
  if error-status :error  then message "123-" error-status :error.
end.
end procedure .
procedure mode-on :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
  assign
    shar_ord-line.cli-art   :read-only in browse br-docs =  true
    shar_ord-line.price-cli :read-only in browse br-docs =  true  no-error .
  run chg-action  in this-procedure  .
  run enable_ui_2  in this-procedure  .
end.
end procedure.
procedure pr-tog-prt :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    assign frame dialog-frame tog-prt
    .
    if tog-prt = true then do:
       FRAME FRAME-A:HIDDEN           = false .
       view frame a-frame.
       enable br-docs-2 with frame frame-a.
       open query br-docs-2 for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,each b-goods no-lock where  b-goods.artic     = shar_ord-line.artic and  b-goods.prod-type = shar_ord-line.prod-type and  b-goods.prod-code = shar_ord-line.prod-code , each ub.ord-dtl no-lock where ub.ord-dtl.doc-code = shar_ord-line.doc-code and  ub.ord-dtl.artic     = shar_ord-line.artic and  ub.ord-dtl.prod-type = shar_ord-line.prod-type and  ub.ord-dtl.prod-code = shar_ord-line.prod-code LEFT OUTER-JOIN , each buf-goods no-lock where  buf-goods.artic     = ub.ord-dtl.artic and  buf-goods.prod-type = ub.ord-dtl.prod-type and  buf-goods.prod-code = ub.ord-dtl.prod-code , each ub.gds-prt no-lock where  ub.gds-prt.node-code = ub.ord-dtl.node-code .
    end.
    else do:
       FRAME FRAME-A:HIDDEN           = TRUE.
       hide frame a-frame.
    end.
 end.
end procedure.
procedure step-next :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
define variable cur-form as char no-undo.
define variable new-form as char no-undo.
if valid-handle (br-handle) then do:
  g#log = br-handle:select-next-row() no-error .
  find first shar-buf_ord-doc no-lock where
              recid(shar-buf_ord-doc) = bf-handle:recid
              no-error .
  if error-status :error then do:
     message "Это режим просмотра одного документа." .
     g#log = false .
     end.
  if not g#log then message "Это последний документ списка.".
end.
    doc-rec = recid ( shar-buf_ord-doc ).
    next-prev = ( cur-form = new-form ).
 end.
end procedure.
procedure step-prev :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
define variable cur-form as char no-undo.
define variable new-form as char no-undo.
if valid-handle (br-handle) then do:
  g#log = br-handle:select-prev-row() no-error .
  find first shar-buf_ord-doc no-lock where
              recid(shar-buf_ord-doc) = bf-handle:recid
              no-error .
  if error-status :error then do:
     message "Это режим просмотра одного документа." .
     g#log = false .
  end.
  if not g#log then message "Это первый документ списка.".
end.
doc-rec = recid (shar-buf_ord-doc).
next-prev = (cur-form = new-form).
 end.
end procedure.
procedure init-gds-rec :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
 define buffer bb_goods for ub.goods.
 gds-rec = ? .
 find current shar_ord-line no-lock  no-error .
   if avail shar_ord-line then do:
      find first bb_goods no-lock where
          bb_goods.artic     = shar_ord-line.artic
      and bb_goods.prod-type = shar_ord-line.prod-type
      and bb_goods.prod-code = shar_ord-line.prod-code  no-error .
      gds-rec = recid (bb_goods).
   end.
 end.
end procedure.
procedure CHOOSE-MENU-way1 :
 do
 on error undo, return error return-value
 :
 assign frame dialog-frame LOC-DATE-SHIP
                            DATE-sale-1
                            DATE-sale-2 .
 find current shar_ord-line no-lock  .
 run cus/ord-way.w (   PARPARENTPROC ,
                   shar_ord-line.artic     ,
                   shar_ord-line.prod-type ,
                   shar_ord-line.prod-code ,
                   1,
                    LOC-DATE-SHIP ,
                    DATE-sale-1,
                    DATE-sale-2,
                    loc-store-type,
                    loc-store-code ,
                    loc-doc-type
                       ) .
 end.
end procedure.
procedure CHOOSE-MENU-way2 :
 do
 on error undo, return error return-value
 :
 assign frame dialog-frame LOC-DATE-SHIP
                            DATE-sale-1
                            DATE-sale-2 .
 find current shar_ord-line no-lock no-error .
  run cus/ord-way.w (  PARPARENTPROC ,
                   shar_ord-line.artic     ,
                   shar_ord-line.prod-type ,
                   shar_ord-line.prod-code ,
                   2,
                  loc-date-ship  ,
                  date-sale-1    ,
                  date-sale-2    ,
                  loc-store-type ,
                  loc-store-code ,
                  loc-doc-type   ) .
 end.
end procedure.
procedure proc-d-notes :
 do
 on error undo, return error return-value
 :
 define variable notes as character no-undo .
 find first shar_ord-doc where recid(shar_ord-doc) = doc-rec no-lock no-error.
   notes = shar_ord-doc.ps.
    run gbl/notes.w ( input 'ПРОСМОТР':U , input-output notes).
    if shar_ord-doc.ps <> notes then do:
      do on stop undo, return error:
        find shar_ord-doc where recid (shar_ord-doc) = doc-rec exclusive no-error .
        shar_ord-doc.ps = notes.
      end.
    end.
    find first shar_ord-doc where recid(shar_ord-doc) = doc-rec no-lock no-error.
 end.
end procedure.
procedure show-contract-code :
  do
  on error undo, return error return-value
  :
  define buffer buf_contract for ub.contract .
  define variable v-host-code as integer   no-undo .
  if available shar_ord-doc
  then do:
    if shar_ord-doc.contract-code = 0
    then do:
      message
        "У заказа не задан договор" skip
        view-as alert-box information .
    end.
    else do:
      define variable v-recid as recid no-undo .
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  shar_ord-doc.obj-type
  ,input  shar_ord-doc.obj-code
  ,output v-host-code
  ) no-error .
      if error-status :error then v-host-code = shar_ord-doc.host-code .
      find first buf_contract no-lock
        where buf_contract.host-code     = v-host-code
          and buf_contract.contract-code = shar_ord-doc.contract-code
        no-error .
      if available buf_contract
      then do:
        assign
          v-recid = recid( buf_contract )
        .
        run str/sh-contr.p
          (input  parParentProc
          ,input v-recid
          ) .
      end.
      else do:
        message
          "Договор не найден" skip
          "Код фирмы" v-host-code skip
          "Код договора" shar_ord-doc.contract-code skip
          "Объект" shar_ord-doc.obj-type shar_ord-doc.obj-code skip
          view-as alert-box error .
      end.
    end.
  end.
  end.
end procedure.
procedure show-protocol :
do
on error undo, return error return-value
:
define variable v-gds-code as integer   no-undo .
define buffer buf1_goods for ub.goods  .
  find current shar_ord-line  no-lock  no-error .
  if not available shar_ord-line then return .
  v-gds-code = shar_ord-line.gds-code .
  if shar_ord-line.gds-code = 0  or shar_ord-line.gds-code = ? then do:
     find first buf1_goods no-lock where
                buf1_goods.artic = shar_ord-line.artic and
                buf1_goods.prod-type = shar_ord-line.prod-type and
                buf1_goods.prod-code = shar_ord-line.prod-code no-error .
     v-gds-code = buf1_goods.gds-code .
  end.
  run cus/ord-prot.w
      ( input loc-ord-num ,
        input v-gds-code
        ) .
  end.
end procedure.
procedure init-browse-p :
  do
  on error undo, return error return-value
  :
if firstr = false then return .
define variable cur-clmn-loc as integer   no-undo .
define variable column-handle as handle no-undo .
  assign
    cur-clmn-loc  = 1
    column-handle = br-docs:first-column   in frame dialog-frame
    hcolumn [cur-clmn-loc] = column-handle
  .
  do while valid-handle(column-handle) :
    if cur-clmn-loc = br-docs:num-columns then do:
      leave .
    end.
    assign
      column-handle = column-handle:NEXT-COLUMN
      cur-clmn-loc  = cur-clmn-loc + 1
      hcolumn [cur-clmn-loc] = column-handle
    .
  end.
run uf-get in this-procedure (
     input  'cli-zakz-p':U + g#type
    ,input  v-cntxt-userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
    ) no-error  .
    if error-status :error then message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "e"
      view-as alert-box error
    .
v-order-column  =  (entry(1, v-uf-List_ ,chr(4))) no-error.
v-spis-size     =  (entry(2, v-uf-List_ ,chr(4))) no-error.
v-spis-vis      =  (entry(3, v-uf-List_ ,chr(4))) no-error.
case g#type :
          when  'ФП':U then do:
            if v-order-column  = ? or v-order-column  = "" or error-status :error  then  v-order-column  =  '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23':U     .
            if v-spis-size     = ? or v-spis-size    = ""  or error-status :error  then  v-spis-size     =  '1,3,1,8,20,4,7,9,12,10,10,10,3,9,9,9,12,14,1,9,10,10,10':U     .
            if v-spis-vis      = ? or v-spis-vis     = ""  or error-status :error  then  v-spis-vis      =  'yes,yes,yes,yes,yes,yes,yes,yes,yes,yes,yes,yes,yes,yes,yes,yes,no,no,yes,yes,no,no,no':U     .
          end.
          when  'ОП':U then do:
              if v-order-column  = ? or v-order-column  = "" or error-status :error  then  v-order-column = '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23':U     .
              if v-spis-size     = ? or v-spis-size    = ""  or error-status :error  then  v-spis-size    = '1,3,1,8,20,4,7,10,12,10,10,10,3,9,9,9,12,14,1,9,10,10,10':U     .
              if v-spis-vis      = ? or v-spis-vis     = ""  or error-status :error  then  v-spis-vis     = trim(fill('yes,',23),',') .
          end.
          when 'ОФ':U then do:
              if v-order-column  = ? or v-order-column  = "" or error-status :error  then  v-order-column = '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23':U      .
              if v-spis-size     = ? or v-spis-size    = ""  or error-status :error  then  v-spis-size    = '1,3,1,10,26,4,7,9,12,10,10,10,3,11,11,11,12,14,1,9,10,10,10':U      .
              if v-spis-vis      = ? or v-spis-vis     = ""  or error-status :error  then  v-spis-vis     = 'yes,yes,yes,yes,yes,no,no,no,no,no,no,no,yes,yes,yes,yes,yes,yes,yes,yes,no,no,no':U      .
          end.
end case.
define variable col-h as handle no-undo .
define variable ii as integer   no-undo .
repeat ii = 1 to cur-clmn-loc   :
    col-h = hcolumn [ ii ]  .
    if decimal(entry(ii,v-spis-size))  = 0 then message ii.
    col-h:width  = decimal(entry(ii,v-spis-size))   .
    col-h:visible  = logical(entry(ii,v-spis-vis))  .
 end.
  v-fact-qnty:width in browse br-docs  = 10 .
  loc-sum-rcv:width in browse br-docs  = 10 .
  shar_ord-line.qnty-stk:width  in browse br-docs  = 15 .
  shar_ord-line.gds-code:width  in browse br-docs  = 13 .
  firstr = false  .
  end.
end procedure.
