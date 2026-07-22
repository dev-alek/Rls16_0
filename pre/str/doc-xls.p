block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: doc-xls.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/doc-xls.p $":U .
define variable vss-description as character no-undo initial "Экспорт списка товаров в формате EXCEL":U .
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
define  shared  temp-table doc-list no-undo
field doc-date   like ub.trn-doc.doc-date
field doc-code   like ub.trn-doc.doc-code
field obj-type   like ub.trn-doc.obj-type
field obj-code   like ub.trn-doc.obj-code
field fact-num   like ub.trn-doc.fact-num
field fact-date  like ub.trn-doc.fact-date
field shift-date like ub.trn-doc.shift-date
field shift-num  like ub.trn-doc.shift-num
field shift-name like ub.trn-doc.shift-name
field fact-order as decimal
field is-trn-doc as logical
field is-del as logical
field doc-type   like ub.trn-doc.doc-type
field ext-doc-type   like ub.trn-doc.ext-doc-type
field sel-order  as integer
field znak       as integer
field to-del     as logical
field is-archive-exist as logical
index xpk is primary unique doc-code doc-type
index xfact fact-num
index xfact-date fact-date
index sel-order sel-order
index znak-order znak sel-order
index isdel is-del
.
define buffer inkas_trn-doc for ub.trn-doc .
define buffer c-inkas_trn-doc for ub.c-trn-doc .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define   shared   temp-table doc-list-hist no-undo
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable var-report-r-b as character no-undo .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
define variable g#report-num as integer no-undo .
procedure OpenForExcel :
   define variable v-ch#ExcelApplication as com-handle no-undo .
   define variable v-ch#Workbook         as com-handle no-undo .
   define variable v-ch#Worksheet        as com-handle no-undo .
   os-delete value( string( session:temp-directory ) +
                              "rpt" + string( g#report-num ) + ".txt":U ) .
   os-delete value( string( session:temp-directory ) +
                              "rpt" + string( g#report-num ) + ".frm":U ) .
   os-delete value( string( session:temp-directory ) +
                              "rpt" + string( g#report-num ) + ".txl":U ) .
   if Make-Excel
   then do:
      output stream ForExcel to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) + ".txt":U ) ) .
      assign
         v-excel-file = string( session:temp-directory + "rpt" + string( g#report-num ) )
         number-list = 1
      .
      if make-excel-com
      then do:
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#WorkSheet) then
RELEASE OBJECT ch#WorkSheet no-error.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#Workbook) then
RELEASE OBJECT ch#Workbook no-error.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#ExcelApplication) then
RELEASE OBJECT ch#ExcelApplication no-error.
         create "Excel.Application" ch#excelApplication connect no-error.
         if error-status:error
         then do :
        create "Excel.Application" ch#excelApplication no-error.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        undo, return error .
    end.
         end.
         assign
            num#str#  = 0.
            v-ch#excelApplication  = ch#excelApplication.
            v-ch#excelApplication:Interactive = false.
            v-ch#excelApplication:ScreenUpdating = false.
            v-ch#excelApplication:Visible = false.
            ch#Workbook  = v-ch#excelApplication:Workbooks:add ().
            ch#WorkSheet = v-ch#excelApplication:Sheets:Item (1).
            v-ch#Worksheet = ch#WorkSheet.
            v-ch#Worksheet:Range ("A1"):Font:Bold = true.
            v-ch#Worksheet:Range ("A1"):Font:Size = 14.
            v-ch#Worksheet:Range ("A1"):HorizontalAlignment = -4131.
            v-ch#Worksheet:Range ("A1"):VerticalAlignment   = -4160
         no-error .
         if error-status:error
         then do:
            Make-Excel-com = false .
            Make-Excel = false .
            output Stream  ForExcel close.
            os-delete value( string( session:temp-directory ) +
                           "rpt" + string( g#report-num ) + ".txt":U ) .
            os-delete value( string( session:temp-directory ) +
                           "rpt" + string( g#report-num ) + ".frm":U ) .
            return.
         end.
      end.
   end.
end.
procedure CloseForExcel :
   define variable ii as integer no-undo .
   define variable vsheet-num as integer no-undo.
   if Make-Excel
   then  do:
      output Stream  ForExcel close.
      os-delete value( string( session:temp-directory ) +
                             "rpt" + string( g#report-num ) + ".txt":U ) .
      os-delete value( string( session:temp-directory ) +
                             "rpt" + string( g#report-num ) + ".frm":U ) .
      define buffer buf_sheetf for sheetf.
      find last buf_sheetf no-error .
      if available buf_sheetf
      then
         vsheet-num = buf_sheetf.sheet-num.
      if vsheet-num > 1
      then do:
         do ii = 2 to vsheet-num:
            os-delete value( string( session:temp-directory ) +
                                  "rpt" + string( g#report-num ) + ".":U  + string(ii)) .
         end.
      end.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#WorkSheet) then
RELEASE OBJECT ch#WorkSheet no-error.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#Workbook) then
RELEASE OBJECT ch#Workbook no-error.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#ExcelApplication) then
RELEASE OBJECT ch#ExcelApplication no-error.
   end.
end.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile: prtmpldf.i $ $Revision: 06dcfe20b136, 752, rls $".
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable v-size   as character no-undo .
define variable v-format as character no-undo .
define variable dim      as character no-undo .
procedure prnfield-clear :
  define output parameter loc-fld as character no-undo.
  define output parameter loc-lab as character no-undo .
  define output parameter loc-spr as character no-undo .
  define output parameter loc-dim as character no-undo .
  define output parameter loc-size as character no-undo .
  define output parameter loc-format as character no-undo .
  define output parameter loc-type as character no-undo .
  assign
    loc-fld = ""
    loc-lab = ""
    loc-spr = ""
    loc-dim = "0"
    loc-size = "":U
    loc-format = "":U
    loc-type = "":U
  .
end procedure .
procedure prnfield-add :
  define input        parameter par-fld as character no-undo.
  define input        parameter par-lab as character no-undo .
  define input        parameter par-spr as character no-undo .
  define input        parameter par-size as integer no-undo .
  define input        parameter par-format as character no-undo .
  define input-output parameter loc-fld as character no-undo.
  define input-output parameter loc-lab as character no-undo .
  define input-output parameter loc-spr as character no-undo .
  define input-output parameter loc-size as character no-undo .
  define input-output parameter loc-format as character no-undo .
  define input-output parameter loc-dim as character no-undo .
  do
  on error undo, return error
  :
    assign
    loc-fld = if loc-dim = '0'
              then par-fld
              else (loc-fld + chr(44) + par-fld)
    loc-lab = if loc-dim = '0'
              then par-lab
              else (loc-lab + chr(44) + par-lab)
    loc-spr = if loc-dim = '0'
              then par-spr
              else (loc-spr + chr(44) + par-spr)
    loc-size = if loc-dim = '0'
              then string(par-size)
              else (loc-size + chr(44) + string(par-size))
    loc-format = if loc-dim = '0'
              then par-format
              else (loc-format + chr(4) + string(par-format))
    no-error
    .
    assign
    entry(num-entries(loc-dim), loc-dim) = string(integer(entry(num-entries(loc-dim), loc-dim)) + 1)
    no-error
    .
  end.
end procedure.
FUNCTION prnfield_get-fsize returns integer(
input p-type as character,
input p-format as character,
input p-label as character
):
define variable ii as integer no-undo .
define variable v-max as integer no-undo .
  do
  on error undo, return error
  :
    do ii = 1 to num-entries(p-label, chr(32)):
      assign
      v-max = maximum(v-max, length(entry(ii, p-label, chr(32))))
      .
    end.
    if p-format = "99:99" then return MAXIMUM(v-max,8).
    CASE p-type:
       when 'C':U or when 'character':U then do:
        if p-format = "99:99" or p-format = "99:99-99:99" then return maximum(v-max, 8).
        else
        return maximum(v-max, integer(left-trim(right-trim(left-trim(left-trim(p-format, "X":U), "(":U), ")":U),">") )).
      end.
      when 'I':U or when 'D':U or when 'T':U or
      when 'integer':U or when 'decimal':U or when 'date':U
      then do:
        return maximum(v-max,length(p-format)).
      end.
      when 'L':U or when 'logical':U then do:
        return MAXIMUM(v-max, length(entry(1, p-format, chr(47))), length(entry(2, p-format, chr(47)))).
      end.
    END CASE.
  end.
end FUNCTION.
function prnfield_get-fformat returns character ( input p-data-type as character
                                        ,input p-format as character ):
define variable v-excel-format as character no-undo .
case p-data-type:
  when 'character':U then do:
    v-excel-format = "@".
  end.
  when 'integer':U then do:
    v-excel-format = "0".
  end.
  when 'decimal':U then do:
    v-excel-format = substitute("0.&1", fill("0", length(entry(2, p-format, ".")))) no-error.
  end.
  when 'date':U then do:
    v-excel-format = "d/m/yyyy".
  end.
  otherwise do:
    v-excel-format = "@".
  end.
end.
if v-excel-format = '' then
v-excel-format = "@".
return v-excel-format .
end function.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-waitfram-action01         as character   no-undo .
define variable v-waitfram-action02         as character   no-undo .
define variable v-waitfram-action03         as character   no-undo .
define variable mWaitFramTextBeg            as character   no-undo.
define variable mWaitFramTextEnd            as character   no-undo.
define variable mWaitFramView               as logical     no-undo.
define variable mWaitProcEvent              as logical     no-undo init yes.
define variable mWaitFramInterval           as integer     no-undo init 1 .
define variable mWaitFramStop               as logical     no-undo.
define variable mWaitFramStopUser           as logical     no-undo.
define variable mWaitFramStopTimeOut        as logical     no-undo.
define variable mWaitFramStartProc          as datetime-tz no-undo.
define variable mWaitFramTimeOut            as decimal     no-undo init ?.
define button B-WaitFramStop auto-end-key
     label "Стоп"
     size 10 by 1 tooltip "Остоновить процесс".
define button B-viewProcInfo
     label "Информация"
     size 15 by 1 tooltip "Информация о процесс".
define frame waitfram
  v-waitfram-action01 format "x(72)" no-label skip
  v-waitfram-action02 format "x(72)" no-label skip
  v-waitfram-action03 format "x(72)" no-label skip
  B-viewProcInfo
  B-WaitFramStop at row 4 col 30
  with view-as dialog-box side-labels three-d cancel-button B-WaitFramStop
  .
define new global shared variable mBatchMode as logical no-undo init ?.
define variable mFramBachModHandle as handle no-undo.
mFramBachModHandle = frame waitfram:handle.
define variable mFameOldVis as logical no-undo.
define variable mVisCUrentVin as logical no-undo.
if session:batch-mode
then
   mBatchMode = yes.
if mBatchMode = ? then do:
  mVisCUrentVin = current-window:visible.
  mFameOldVis = mFramBachModHandle:visible.
  mFramBachModHandle:visible  = yes.
  mBatchMode = mFramBachModHandle:visible ne yes.
  mFramBachModHandle:visible = mFameOldVis.
  current-window:visible = mVisCUrentVin.
end.
 if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramBachModHandle:visible), "frameRepError").
  end.
on choose of B-WaitFramStop in frame waitfram
do:
  mWaitFramStop = yes.
  mWaitFramStopUser = yes.
end.
function waitfram-check-timeout returns logical():
   define variable vtime as int64 no-undo.
   if mWaitFramStopTimeOut
   then
      return yes.
   vtime = ( now - mWaitFramStartProc ) / 1000 .
   if     mWaitFramTimeOut ne ?
      and mWaitFramTimeOut ne 0
      and mWaitFramTimeOut lt vtime
   then do:
      mWaitFramStopTimeOut = yes.
   end.
   return mWaitFramStopTimeOut.
end.
procedure waitfram-hide :
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    pause 0 before-hide .
    if not mBatchMode then
      hide frame waitfram .
  if     not mWaitFramView
     and mWaitProcEvent
  then
    process events .
  end.
end procedure.
procedure waitfram-show :
  define input  parameter p-message as character no-undo .
  define variable v-left-margin as integer   no-undo .
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    if length(p-message) <= 70 then do:
      assign
        v-left-margin = integer((70 - length(p-message)) / 2)
      .
      assign
        v-left-margin = max(0, v-left-margin - (v-left-margin mod 5))
      .
      assign
        v-waitfram-action01 = " "
        v-waitfram-action02 = " "
                                 + fill(" ", v-left-margin)
                                 + p-message
        v-waitfram-action03 = " "
      .
    end.
    else do:
      define variable vRindex1 as integer no-undo.
      define variable vRindex2 as integer no-undo.
      vRindex1 = r-index(p-message," ",70).
      if vRindex1 = 0
      then
         vRindex1 = 70.
      if length(p-message)  <= vRindex1 + 70 then do:
        assign
          v-waitfram-action01 = " "
          v-waitfram-action02 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action03 = " " + substring(p-message,  vRindex1 + 1, 70      )
        .
      end.
      else do:
        vRindex2 = r-index(p-message," ",vRindex1 + 70).
        if vRindex2 <= vRindex1
        then
           vRindex2 = vRindex1 + 70.
        assign
          v-waitfram-action01 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action02 = " " + substring(p-message,  vRindex1 + 1, vRindex2 - vRindex1 )
          v-waitfram-action03 = " " + substring(p-message,  vRindex2 + 1, 70)
        .
      end.
    end.
    B-viewProcInfo:visible   in frame waitfram = no.
    B-viewProcInfo:sensitive in frame waitfram = no.
    B-WaitFramStop:visible   in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    B-WaitFramStop:sensitive in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    if  (   mWaitFramView
       or  mWaitProcEvent)
       and not mBatchMode
    then
       display
          v-waitfram-action01 skip
          v-waitfram-action02 skip
          v-waitfram-action03 skip
       with frame waitfram .
    if     mWaitFramView
       then do:
          if     mWaitFramInterval ne ?
             and not mBatchMode
          then
             wait-for go of frame waitfram pause mWaitFramInterval.
       end.
       else
          if     mWaitProcEvent
             and not mBatchMode
          then
             process events .
  end.
end procedure.
   procedure waitfram-show-this:
      define input  parameter iInterval as int64 no-undo.
      define variable vtime as int64 no-undo.
      vtime = ( now - mWaitFramStartProc  ) / 1000 .
      mWaitFramInterval = iInterval.
      run waitfram-show (substitute("&1&2 &3&4" ,
                                    mWaitFramTextBeg ,
                                    if vtime eq ? then "" else substitute (" Прошло: &1 сек" , string( vtime)),
                                    if mWaitFramTimeOut ne 0 and mWaitFramTimeOut ne ? then " из " + string(mWaitFramTimeOut) + " сек. " else "",
                                    mWaitFramTextEnd
                                   )
                        ).
   end.
   procedure WaitFramRunPause:
      define input  parameter iInterval as dec no-undo.
      define variable vStart  as datetime-tz no-undo.
      define variable vend    as datetime-tz no-undo.
      define variable vint as int64 no-undo.
      define variable vOk as logical no-undo.
      vStart = now.
      vend   = vStart.
      publish "WaitFramPause" (iInterval,output vOk).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and (   vint > 0
              or (    not vOk
                  and iInterval eq ?
                  )
              )
      then
         run waitfram-show-this (iInterval).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and vint > 0
      then do:
         run gbl/pause.p (vint * 1000).
      end.
      if iInterval ne ?
      then
         publish "WaitFramStop".
      waitfram-check-timeout().
   end.
   procedure WaitFramWaitFor:
      define input  parameter iInterval as dec no-undo.
      assign
         mWaitFramStartProc   = now
         mWaitFramStopUser    = no
         mWaitFramStopTimeOut = no
      .
      block-wait:
      do while not mWaitFramStop:
         run WaitFramRunPause (iInterval).
         if  waitfram-check-timeout()
         then do:
            leave block-wait.
         end.
      end.
      run waitfram-hide.
   end.
procedure waitfram-join :
  define input  parameter p-line-1  as character no-undo .
  define input  parameter p-line-2  as character no-undo .
  define input  parameter p-line-3  as character no-undo .
  define output parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-message = substring(p-line-1 + fill(' ', 70), 1, 70)
                + substring(p-line-2 + fill(' ', 70), 1, 70)
                + substring(p-line-3 + fill(' ', 70), 1, 70)
    .
  end.
end procedure.
function waitfram-join-function returns character
  (input p-line-1 as character
  ,input p-line-2 as character
  ,input p-line-3 as character
  ).
  define variable v-message as character no-undo .
  run waitfram-join in this-procedure
    (input  p-line-1
    ,input  p-line-2
    ,input  p-line-3
    ,output v-message
    ) .
  return v-message .
end function .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure lineattr-value :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-value    like ub.doc-line-attr.attr-value no-undo .
    define output parameter p-type     as character no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error .
    if avail buf_doc-line-attr then do:
      assign
        p-value =  buf_doc-line-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure lineattr-write :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define input parameter p-value    like ub.doc-line-attr.attr-value no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code = p-gds-code
        buf_doc-line-attr.attr-code = p-code
      .
    end.
    assign
      buf_doc-line-attr.attr-value = p-value
    .
     release buf_doc-line-attr.
  end.
end procedure.
procedure lineattr-exist :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error .
    if  available buf_doc-line-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure lineattr-delete :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_doc-line-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_doc-line-attr.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure lineattr-code :
  do on error undo, return error return-value
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-type           as character no-undo .
    define output parameter p-format         as character no-undo .
    define output parameter p-fillin_width   as integer   no-undo .
    define output parameter p-fillin_height  as integer   no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-other          as character no-undo .
    case p-code :
            when 'parts_price-sale':U then do:     assign     p-label          = "Продажная цена партии"     p-type           = 'C':U      p-format         = "x(70)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Продажная цена партии"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'fl_gds-code':U then do:     assign     p-label          = "Количество по букету"     p-type           = 'C':U      p-format         = "x(70)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Количество по букету"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'old_other-ras':U then do:     assign     p-label          = " Первым способом из ПН Сумма дополнительных расходов по строке rubl base"     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = " Первым способом из ПН Сумма дополнительных расходов по строке rubl base"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'new_other-ras':U then do:     assign     p-label          = " Способом из ДопРасх Сумма дополнительных расходов по строке rubl base"     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = " Способом из ДопРасх Сумма дополнительных расходов по строке rubl base"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'flora_ps':U then do:     assign     p-label          = "Описание не товарной позиции"     p-type           = 'C':U      p-format         = "x(70)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Описание не товарной позиции"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
            when 'country-code':U then do:     assign     p-label          = "Страна"     p-type           = 'I':U      p-format         = "->>>>>>>>9"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Страна"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'add-line-cli':U then do:     assign     p-label          = "Курс . шкала . сумма . НДС "     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Курс . шкала . сумма . НДС "     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'corr-price-sale':U then do:     assign     p-label          = "Продажная цена в строке ПН"     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Продажная цена в строке ПН"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'reason-code':U then do:     assign     p-label          = "Причина отклонения"     p-type           = 'I':U      p-format         = "->>>>>>>>9"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Причина отклонения"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
            when 'price-prod':U then do:     assign     p-label          = "Цена производителя Без НДС"     p-type           = 'D':U      p-format         = ">>>>>>>>9.99"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Цена производителя Без НДС"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
            when 'price-prodvat':U then do:     assign     p-label          = "Цена производителя c НДС"     p-type           = 'D':U      p-format         = ">>>>>>>>9.99"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Цена производителя c НДС"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
      otherwise do:
        undo, return error "неизвестный атрибут строки документа" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure lineattr-value-flora-gds :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code    like  ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code    like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define input  parameter p-bk-gds-code like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-code        like  ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-value       as    decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code  + chr(44) + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error .
    if avail buf_doc-line-attr then do:
      assign
        p-value = decimal( buf_doc-line-attr.attr-value)
      .
    end.
    else do:
      assign
        p-value = 0
      .
    end.
  end.
end procedure.
procedure lineattr-write-flora-gds :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-prt-code    as integer   no-undo .
    define input parameter p-bk-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define input parameter p-value    as decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code + chr(44)  + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code  = p-gds-code
        buf_doc-line-attr.attr-code = p-code  + chr(44)  + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      .
    end.
    assign
      buf_doc-line-attr.attr-value = string( p-value )
    .
  end.
end procedure.
procedure lineattr-delete-flora-gds :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define input parameter p-bk-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code + chr(44) + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error NO-WAIT.
    if not available buf_doc-line-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_doc-line-attr.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure lineattr-delete-flora-all :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    for each buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code begins 'fl_gds-code':U + chr(44) + string(p-prt-code)  + chr(44)
     :
      delete buf_doc-line-attr.
    end.
 end.
end procedure.
procedure lineattr-exist-flora-gds :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code    like  ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code    like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define input  parameter p-bk-gds-code like  ub.doc-line-attr.gds-code   no-undo .
    define output parameter p-exist as logical   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    p-exist = false .
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = 'fl_gds-code':U  + chr(44) + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error .
    if avail buf_doc-line-attr then do:
      assign
       p-exist = true
      .
    end.
  end.
end procedure.
procedure lineattr-write-add-line-cli :
define input  parameter p-doc-code      like  ub.doc-line-attr.doc-code   no-undo .
define input  parameter p-gds-code      like  ub.doc-line-attr.gds-code   no-undo .
define input  parameter p-cli-type      as character no-undo .
define input  parameter p-cli-code      as integer   no-undo .
define input  parameter p-contract-code as integer   no-undo .
define input  parameter p-host-code     as integer   no-undo .
define input  parameter p-exch-code     as integer   no-undo .
define input  parameter p-exch-rate     as decimal   no-undo .
define input  parameter p-exch-scale    as integer   no-undo .
define input  parameter p-sum-cli       as decimal   no-undo .
define input  parameter p-sum-vat       as decimal   no-undo .
define buffer buf_doc-line-attr for ub.doc-line-attr .
  do
  on error undo, return error return-value
  :
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = 'add-line-cli':U +
                                          chr(4) + p-cli-type +
                                          chr(4) + string(p-cli-code) +
                                          chr(4) + string(p-contract-code) +
                                          chr(4) + string(p-host-code)
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code  = p-gds-code
        buf_doc-line-attr.attr-code = 'add-line-cli':U  +
                                      chr(4) + p-cli-type +
                                      chr(4) + string(p-cli-code) +
                                      chr(4) + string(p-contract-code) +
                                      chr(4) + string(p-host-code)
      .
    end.
    assign
      buf_doc-line-attr.attr-value =
      string(p-exch-code)  + chr(4) +
      string(p-exch-rate)  + chr(4) +
      string(p-exch-scale) + chr(4) +
      string(p-sum-cli)    + chr(4) +
      string(p-sum-vat)
      .
  end.
end procedure.
procedure lineattr-value-add-line-cli :
define input   parameter p-doc-code      like  ub.doc-line-attr.doc-code   no-undo .
define input   parameter p-gds-code      like  ub.doc-line-attr.gds-code   no-undo .
define input   parameter p-cli-type      as character no-undo .
define input   parameter p-cli-code      as integer   no-undo .
define input   parameter p-contract-code as integer   no-undo .
define input   parameter p-host-code     as integer   no-undo .
define output  parameter p-exch-code     as integer   no-undo .
define output  parameter p-exch-rate     as decimal   no-undo .
define output  parameter p-exch-scale    as integer   no-undo .
define output  parameter p-sum-cli       as decimal   no-undo .
define output  parameter p-sum-vat       as decimal   no-undo .
define buffer buf_doc-line-attr for ub.doc-line-attr .
  do
  on error undo, return error return-value
  :
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = 'add-line-cli':U +
                                          chr(4) + p-cli-type +
                                          chr(4) + string(p-cli-code) +
                                          chr(4) + string(p-contract-code) +
                                          chr(4) + string(p-host-code)
      no-error .
    if available buf_doc-line-attr then do:
     assign
        p-exch-code  = integer ( entry (1 , buf_doc-line-attr.attr-value,  chr(4) ))
        p-exch-rate  = decimal ( entry (2 , buf_doc-line-attr.attr-value, chr(4) ))
        p-exch-scale = integer ( entry (3 , buf_doc-line-attr.attr-value, chr(4) ))
        p-sum-cli    = decimal ( entry (4 , buf_doc-line-attr.attr-value, chr(4) ))
        p-sum-vat    = decimal ( entry (5 , buf_doc-line-attr.attr-value, chr(4) ))
       .
     end.
  end.
end procedure.
function lineattr-get-reason returns character ( buffer local-doc-line for ub.doc-line ) :
  define variable v-code as character no-undo .
  define variable v-type as character no-undo .
  define variable v-gds-code as integer   no-undo .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  local-doc-line.artic
  ,input  local-doc-line.prod-type
  ,input  local-doc-line.prod-code
  ,output v-gds-code
  )  .
  run lineattr-value (
      input   local-doc-line.doc-code ,
      input   v-gds-code              ,
      input   'reason-code':U ,
      output  v-code                  ,
      output  v-type ) .
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = integer ( v-code ) no-error.
  if not available ub.trn-reason then do:
     return "" .
  end.
  else do:
     return ub.trn-reason.reason-name .
  end.
end function.
procedure lineattr-value-parts :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code    like  ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code    like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-part-code   as character no-undo .
    define input  parameter p_in-code     as character no-undo .
    define input  parameter p-code        like  ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-value       as    decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code  + chr(4) + trim(p-part-code)  + chr(4) + trim(p_in-code)
      no-error .
    if avail buf_doc-line-attr then do:
      assign
        p-value = decimal( buf_doc-line-attr.attr-value)
      .
    end.
    else do:
      assign
        p-value = 0
      .
    end.
  end.
end procedure.
procedure lineattr-write-parts :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-part-code  as character no-undo .
    define input parameter p_in-code    as character no-undo .
    define input parameter p-code       like ub.doc-line-attr.attr-code  no-undo .
    define input parameter p-value      as decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code + chr(4)  + trim(p-part-code)  + chr(4) + trim(p_in-code)
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code  = p-gds-code
        buf_doc-line-attr.attr-code = p-code  + chr(4)  + trim(p-part-code)  + chr(4) + trim(p_in-code)
      .
    end.
    assign
      buf_doc-line-attr.attr-value = string( p-value )
    .
  end.
end procedure.
define variable icolumn   as integer no-undo.
define variable ii as integer no-undo.
define variable vat-value like ub.doc-line.vat-pc no-undo .
define variable slt-value like ub.doc-line.slt-pc no-undo .
define variable v-rec as recid no-undo .
define variable jj as integer no-undo .
define variable jj-1 as integer no-undo .
define variable j-n as integer no-undo .
define variable f-value as character no-undo .
define variable f-value-1 as character no-undo .
define variable f-name as character no-undo .
define variable f-name-1 as character no-undo .
define variable f-n as character no-undo .
define variable v-length as integer no-undo .
define variable v-num-clmn as integer no-undo .
define variable v-bc-ne as integer no-undo .
define variable v-pbc-ne as integer no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-f-name like ub.gds-prt.f-name no-undo .
define variable v-osn-frm as character no-undo .
define variable v-eng-frm as character no-undo .
define variable bar-code-field-handle as handle no-undo .
define variable prod-bc-field-handle as handle no-undo .
define variable v-recid_file as recid no-undo extent 3.
define buffer buf_filter for ubflt.filter.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output v-host-code
  )  .
FUNCTION get-function returns character(
input p-f-name as character,
input p-format as character) :
  do
  on error undo, return error
  :
    CASE p-f-name:
      when "iColumn":U then do:
        return string(iColumn, p-format).
      end.
      when "qnty":U then do:
        return string(doc-list.fact-num,  p-format).
      end.
    END CASE.
  end.
end FUNCTION.
run init-prn-template in this-procedure .
run gbl/prntput.p (c-point, output v-rec).
run gbl/prntmpl.w (
                input parparentproc
              , input "":U
              , input c-point
              , input Tbl
              , input join-tbl
              , input Fld
              , input Lab
              , input Spr
              , input v-size
              , input v-format
              , input Dim
              , input-output v-rec
              , OUTPUT V-LENGTH
              , OUTPUT V-NUM-CLMN
            ).
if v-rec = ? then return.
find first ubflt.filter no-lock where
           recid(ubflt.filter) = v-rec no-error .
if not avail ubflt.filter then return.
do ii = 1 to 3:
  find first _file no-lock where
            _file._file-name = entry(ii, 'trn-doc,price-doc,inkas').
  assign
  v-recid_file[ii] = recid(_file).
end.
do jj = 1 to num-entries(ubflt.filter.Fields-sort):
  assign
  f-name-1 = "":U
  .
  do jj-1 = 1 to num-entries(entry(jj, ubflt.filter.Fields-sort), "*":U):
    case entry(1, entry(jj-1, entry(jj, ubflt.filter.Fields-sort), "*":U), "."):
      when "trn-doc":U  then do:
        f-n = entry(jj-1, entry(jj, ubflt.filter.Fields-sort), "*":U)    .
      end.
      when "doc-attr":U then do:
        assign
        f-n = entry(jj-1, entry(jj, ubflt.filter.Fields-sort), "*":U)
        .
      end.
      when "function":U then do:
        assign
        f-n = entry(jj-1, entry(jj, ubflt.filter.Fields-sort), "*":U)
        .
      end.
    END CASE.
    assign
    f-name-1 = f-name-1 + (if f-name-1 = "":U then "":U else "*":U) + f-n
    .
  end.
  assign
  f-name = f-name + (if f-name = "":U then "":U else chr(44)) + f-name-1
  .
end.
assign
j-n = num-entries(f-name)
.
Make-excel = yes.
run get-report-num  in parParentProc(output g#report-num).
if Make-Excel then
RUN OpenForExcel in this-procedure .
FOR EACH sheetf where sheetf.sheet-num > 1:
  delete sheetf.
end.
FIND FIRST sheetf where
           sheetf.sheet-num = 1 No-ERROR.
assign
ReportName = "Список документов"
sheetf.Excel-Column-Lable = ubflt.filter.Fields-sort-rus
sheetf.sizes = ubflt.filter.Where-ysl
.
run waitfram-show in this-procedure ("Экспорт в EXCEL. Ждите ...").
run rep/extitle.p (1).
iColumn = 0.
define variable v-name-field as character no-undo .
define variable v-type as character no-undo .
FOR EACH doc-list no-lock :
  if (iColumn modulo 10) = 0 then  run waitfram-show in this-procedure ("Экспортировано в EXCEL строк : " + string (iColumn)).
  assign
    iColumn = iColumn + 1
  .
  do jj = 1 to j-n:
    assign
    f-value = "":U
    .
    CASE entry(1, entry(jj, f-name), ".") :
      when "doc-attr":U then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input doc-list.doc-code ,
                        input entry( 2, ( entry( jj, ubflt.filter.Fields-sort ) ), '.' ) ,
                       output f-value ,
                       output v-type )  .
      end.
      when "function":U then do:
              f-value = get-function(substr(entry(jj, f-name) , 10 ), entry(jj, ubflt.filter.Where-ysl-rus, chr(4))) .
      end.
      otherwise do:
        if index(entry(jj, f-name), "*":U) > 0 then do:
          do jj-1 = 1 to num-entries(entry(jj, f-name), "*":U):
            assign
            f-value-1 = "":U.
            assign
            f-value = f-value + (if f-value = "":U then "":U else chr(32)) + f-value-1
            .
          end.
        end.
        else do:
           v-name-field = entry(jj, ubflt.filter.Fields-sort) .
            run ret-value (
                 input   doc-list.doc-type
               , input   entry( 1 , v-name-field , "." )
               , input   doc-list.doc-code
               , input   entry(2 , v-name-field  , "." )
               , output  f-value   ).
        end.
        .
      end.
    END CASE.
     if (entry( jj , ubflt.filter.lst-cend) = 'T':U or
         entry( jj , ubflt.filter.lst-cend) = "date":U )
         or
         entry( jj , ubflt.filter.Where-ysl-rus, chr(4) ) = "99:99"
        then
            assign
              f-value =  SUBSTITUTE ('="&1"', f-value) .
              .
        if Make-Excel then  put   stream ForExcel unformatted
          string(f-value, substitute("X(&1)", entry( jj , ubflt.filter.Where-ysl)))
          (if jj < j-n
          then CHR(9)
          else chr(10))
          .
  end.
END.
sheetf.colformat = v-osn-frm + chr(4) + v-eng-frm.
if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
FInd first Sheetf where
           Sheetf.sheet-num = 2 No-ERROR.
if not avail sheetf then
create sheetf.
assign
Sheetf.Sheet-num = 2
sheetf.Excel-Column-Lable =  "№ п/п,Действие,Записей,итого,Множество"
sheetf.sizes = "9,9,9,12,155"
.
run rep/extitle.p (2).
run waitfram-show in this-procedure ("Экспорт в EXCEL истории").
for each doc-list-hist:
  if Make-Excel then  put   stream ForExcel unformatted
  (if doc-list-hist.line = 0
   then string(doc-list-hist.id, ">>>>>>>>9")
   else '':U)
  CHR(9)
  (if doc-list-hist.item_ <> '':U
   then doc-list-hist.hist-mode
   else '':U)  CHR(9)
   (if doc-list-hist.item_ <> '':U
   then string(doc-list-hist.num-add, "->>>>>>>>9")
   else '':U)  CHR(9)
  (if doc-list-hist.item_ <> '':U
  then string(doc-list-hist.num-recs, ">>>>>>>>9")
  else '':U)  CHR(9)
  doc-list-hist.des
  skip.
end.
run waitfram-hide in this-procedure .
if Make-Excel then output stream ForExcel close.
run waitfram-hide in this-procedure .
if Make-Excel then do:
   run rep/runexcel.p (
                   string( session:temp-directory +
                         "rpt" +
                         string( g#report-num ) + ".txt":U )
                 ) .
end.
if Make-Excel then
RUN CLoseForExcel in this-procedure .
procedure init-prn-template :
define variable na                   as integer            no-undo .
DEFINE VARIABLE vtooltip             as character           no-undo.
DEFINE VARIABLE vlabel               as character           no-undo .
DEFINE VARIABLE vtype                as character           no-undo .
DEFINE VARIABLE vformat              as character           no-undo .
DEFINE VARIABLE vuser-can-edit       as character           no-undo .
DEFINE VARIABLE voutput-display      as character           no-undo .
DEFINE VARIABLE vother               as character           no-undo .
  do
  on error undo, return error
  :
    assign
    join-tbl = 'Накладные,Атрибуты,Другое'
    tbl      = 'trn-doc,doc-attr,function'
    c-point  = "Список документов" + chr(4) +  "PRNT":u
    fld = ""
    lab = ""
    spr = ""
    dim = '0'
    v-size = "":U
    v-format = "":U
    .
run prnfield-add in this-procedure('doc-code', 'Номер', '',         16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('doc-type', 'Тип', 'trn-type', 6, "X(6)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('status_', 'Статус', 'trn-stat', 8, "X(8)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure ('flag_', 'OK', '',              3, "X(3)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('doc-date', 'Дата док-та', '',  11,  "99/99/9999":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('fact-date', 'Дата факт', '',    11, "99/99/9999":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('shift-date', 'Дата смены', '',  11, "99/99/9999":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('shift-num', 'Порядок смены', '',  6, "X(6)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
                                    run prnfield-add in this-procedure('shift-name', 'Номер смены', '',  6, "X(6)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
                                    run prnfield-add in this-procedure('cli-type', 'Тип контрагента', '', 3, "X(3)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('cli-code', 'Код контрагента', '', 9, "X(9)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('cli-name', 'Контрагент', '',     20, "X(20)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('obj-type', 'Тип объекта', '',     3, "X(3)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('obj-code', 'Код объекта', '',     5, "X(5)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('ext-doc-type', 'Расширенный тип', '',   16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('rsrv-date', 'Дата резервирования', '',   11, "99/99/99":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('boss', 'Менеджер', '',                             16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('doc-qnty', 'Кол-во по док.', '',                    16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('fact-qnty', 'Кол-во факт', '',                      16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('tot-doc', 'Сумма (вал)', '',                        16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('tot-calc', 'Скидка (вал)', '',                      16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('tot-rubl', 'Сумма (руб)', '',                       16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('discnt-rubl', 'Скидка (руб)', '',                   16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('discnt-pc', 'Скидка (%)', '',                       16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('discnt-type', 'Тип скидки', '',                     16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('tot-fact', 'Сумма (факт)', '',                      16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('pay-code', 'Код оплаты', 'pay',                     16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('internal', 'Внутренняя', '',                        16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('creid', 'Создал', '',                               16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('agnt', 'Исполнитель', 'cli',                        16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('wrkr', 'Кладовщик', 'cli',                          16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('out-code', 'На док-т', '',                          16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('acc-date', 'Проводка', '',                          16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('base-rate', 'Курс', '',                             16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('inv-num', 'Инвойс', '',                             16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('ord-num', 'Заказ', '',                              16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('office', 'Услуги', '',                              3, "X(3)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('print-rubl', 'Рублевый', '',                        3, "X(3)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('ship-num', 'Отгрузка', '',                          16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('ship-date', 'Дата отгрузки', '',                    11, "99/99/99":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('ov', 'Акт', '',                                     3, "X(3)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('tot-ov', 'Сумма акта', '',                          16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('exch-code', 'Валюта', 'cur',                        16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('fact-num', 'Порядок закрытия', '',                  16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('PS', 'Примечание', '',                              80, "X(80)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('purch-code', 'Тип приобретения', 'purch-code',      16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('flora-pay-date', 'Оплата заказа БУКЕТЫ', '',         11, "99/99/99":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('flora-order-date', 'Дата выполненя заказа БУКЕТЫ', '',         11, "99/99/99":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
  assign
    fld = fld
    lab = lab
    dim = dim + chr(44)
    .
    define variable  p-fillin_width   as integer   no-undo .
    define variable   p-fillin_height  as integer   no-undo .
    define variable sum-na as integer   no-undo .
    define variable vproc-attr       as character no-undo .
    define variable vfull-screen-val as character no-undo .
    define variable vsort as integer   no-undo .
    sum-na = num-entries( 'hold-part-code,dov,dids,dateinv,nids,ddog,ndog,dsf,nsf,addsum,clcasol,clcaswt,scanfile,indoclnsum,purchlimit,purchcodelist,expense_own,envd,fbroperator,fbrauto,0rsrv-date,1ord_time,21ord_phone,22ord_contact,2befpay,3ord_Nchek,4dchek,first-price,4ord_dl,5deliv,6sumwrk,7sumsrk,8ord_adr,9ord_hwo,1postpay,2postNchek,3postdchek,QntyPlace,discnt-stop,discnt-other,m_inc,DFinDoc,NFinDoc,PlaceStorage,Packer,Dispath,price-target,edi,negais,egais,ddov,ndov,Recipient,Shipper,Auto,Driver,print-num,idCountryContr,olsuppcntr,t_pass-fname,t_pass-position,t_accept-fname,t_accept-position,ndovwho,car-time,nosn,relprpdf,ora-exp-seq-num,need-saledc,ser_on_pack,cargo-desc,carry-type,cargo-mass,exp-trans,zakaz-number,zakaz-date,delivery-date,delivery-time,,autoent,car-num,fio-driver,date-income,,inspection-cert,condition,seals-condition,doc-not,spisok-not-doc,is-fuel,is-lgas,is-lgas-corr,othermoves,is-return,clear-ac,edo-return,trdcattr-is-not-close-fact-news,trdcattr-prikaz-number,trdcattr-prikaz-date,trdcattr-inv-date,trdcattr-fio-agent,trdcattr-pos-agent,trdcattr-fio-player1,trdcattr-pos-player1,trdcattr-fio-player2,trdcattr-pos-player2,trdcattr-fio-player3,trdcattr-pos-player3':U ) .
    do na = 1 to sum-na:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input entry( na, 'hold-part-code,dov,dids,dateinv,nids,ddog,ndog,dsf,nsf,addsum,clcasol,clcaswt,scanfile,indoclnsum,purchlimit,purchcodelist,expense_own,envd,fbroperator,fbrauto,0rsrv-date,1ord_time,21ord_phone,22ord_contact,2befpay,3ord_Nchek,4dchek,first-price,4ord_dl,5deliv,6sumwrk,7sumsrk,8ord_adr,9ord_hwo,1postpay,2postNchek,3postdchek,QntyPlace,discnt-stop,discnt-other,m_inc,DFinDoc,NFinDoc,PlaceStorage,Packer,Dispath,price-target,edi,negais,egais,ddov,ndov,Recipient,Shipper,Auto,Driver,print-num,idCountryContr,olsuppcntr,t_pass-fname,t_pass-position,t_accept-fname,t_accept-position,ndovwho,car-time,nosn,relprpdf,ora-exp-seq-num,need-saledc,ser_on_pack,cargo-desc,carry-type,cargo-mass,exp-trans,zakaz-number,zakaz-date,delivery-date,delivery-time,,autoent,car-num,fio-driver,date-income,,inspection-cert,condition,seals-condition,doc-not,spisok-not-doc,is-fuel,is-lgas,is-lgas-corr,othermoves,is-return,clear-ac,edo-return,trdcattr-is-not-close-fact-news,trdcattr-prikaz-number,trdcattr-prikaz-date,trdcattr-inv-date,trdcattr-fio-agent,trdcattr-pos-agent,trdcattr-fio-player1,trdcattr-pos-player1,trdcattr-fio-player2,trdcattr-pos-player2,trdcattr-fio-player3,trdcattr-pos-player3':U ) ,
                       output vtype ,
                       output vformat ,
                       output p-fillin_width ,
                       output p-fillin_height ,
                       output vlabel ,
                       output vuser-can-edit ,
                       output voutput-display ,
                       output vother  ,
                       output vproc-attr ,
                       output vfull-screen-val ,
                       output vsort
                       ) no-error .
      if NOT error-status :error and voutput-display = "yes":U  then do:
        vlabel = replace (vlabel , "," , " " ) .
        run prnfield-add in this-procedure(
            entry(na, 'hold-part-code,dov,dids,dateinv,nids,ddog,ndog,dsf,nsf,addsum,clcasol,clcaswt,scanfile,indoclnsum,purchlimit,purchcodelist,expense_own,envd,fbroperator,fbrauto,0rsrv-date,1ord_time,21ord_phone,22ord_contact,2befpay,3ord_Nchek,4dchek,first-price,4ord_dl,5deliv,6sumwrk,7sumsrk,8ord_adr,9ord_hwo,1postpay,2postNchek,3postdchek,QntyPlace,discnt-stop,discnt-other,m_inc,DFinDoc,NFinDoc,PlaceStorage,Packer,Dispath,price-target,edi,negais,egais,ddov,ndov,Recipient,Shipper,Auto,Driver,print-num,idCountryContr,olsuppcntr,t_pass-fname,t_pass-position,t_accept-fname,t_accept-position,ndovwho,car-time,nosn,relprpdf,ora-exp-seq-num,need-saledc,ser_on_pack,cargo-desc,carry-type,cargo-mass,exp-trans,zakaz-number,zakaz-date,delivery-date,delivery-time,,autoent,car-num,fio-driver,date-income,,inspection-cert,condition,seals-condition,doc-not,spisok-not-doc,is-fuel,is-lgas,is-lgas-corr,othermoves,is-return,clear-ac,edo-return,trdcattr-is-not-close-fact-news,trdcattr-prikaz-number,trdcattr-prikaz-date,trdcattr-inv-date,trdcattr-fio-agent,trdcattr-pos-agent,trdcattr-fio-player1,trdcattr-pos-player1,trdcattr-fio-player2,trdcattr-pos-player2,trdcattr-fio-player3,trdcattr-pos-player3':U),
                 vlabel,
                 'ATTR.' + VTYPE,
                 prnfield_get-fsize ( vtype, vformat, vlabel),
                 vformat,
        input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-format, input-output dim)  no-error.
      end.
    end.
    assign
    fld = fld
    lab = lab
    dim = dim + chr(44)
    .
    run prnfield-add in this-procedure('iColumn', '№', 'function.integer', 7, ">>>>>>9":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-format, input-output dim)  no-error.
  end.
end procedure.
procedure ret-value :
  do
  on error undo, return error return-value
  :
define input  parameter p-doc-type as character no-undo .
define input  parameter p-table as character no-undo .
define input  parameter p-doc-code as character no-undo .
define input  parameter p-pole as character no-undo .
define output parameter p-ret as character no-undo .
DEFINE VARIABLE ii AS INTEGER no-undo .
DEFINE VARIABLE qh AS WIDGET-HANDLE no-undo .
define variable usl as character no-undo .
define variable v-trn-doc as character no-undo .
define variable v-doc-num-field as character no-undo .
DEFINE VARIABLE buf_din_trn-doc AS WIDGET-HANDLE.
define buffer BUF_field for ub._field.
  CASE p-doc-type:
    when 'касс':U then do:
      assign
      ii = LOOKUP('INKAS', 'trn-doc,price-doc,inkas')
      v-trn-doc = "inkas"
      v-doc-num-field = "inkas-code"
      .
    end.
    when 'переоценка':U then do:
      assign
      ii = LOOKUP('PRICE-DOC', 'trn-doc,price-doc,inkas')
      v-trn-doc = "price-doc"
      v-doc-num-field = "doc-num"
      .
    end.
    OTHERWISE do:
      assign
      ii = LOOKUP('TRN-DOC', 'trn-doc,price-doc,inkas')
      v-trn-doc = "trn-doc"
      v-doc-num-field = "doc-code"
      .
    end.
  END CASE.
  if lookup(p-table + '.' + p-pole, 'trn-doc.doc-code,inkas.inkas-code,price-doc.doc-num') > 0 then do:
    assign
    p-ret = p-doc-code
    .
    return.
  end.
  else do:
    find first buf_field no-lock where
              buf_field._file-recid = v-recid_FILE[II]
          AND buf_field._field-name = p-pole no-error .
    if not available buf_field then do:
      if v-trn-doc = "inkas" then do:
        find first buf_field no-lock where
                  buf_field._file-recid = v-recid_FILE[LOOKUP('TRN-DOC', 'trn-doc,price-doc,inkas')]
              AND buf_field._field-name = p-pole no-error .
        if available buf_field then do:
          assign
          v-doc-num-field = 'doc-code'
          v-trn-doc = 'trn-doc'.
        end.
        else do:
          assign
          p-ret = '[Не определено]'.
          return.
        end.
      end.
      else do:
        assign
        p-ret = '[Не определено]'.
        return.
      end.
    end.
  end.
  CREATE BUFFER buf_din_trn-doc FOR TABLE v-trn-doc.
  CREATE QUERY qh.
  usl = SUBSTITUTE ( "for each &2 no-lock  where  &2.&3 = '&1' " , p-doc-code, v-trn-doc, v-doc-num-field )    .
  qh:SET-BUFFERS  ( buf_din_trn-doc ).
  qh:QUERY-PREPARE ( usl ).
  qh:QUERY-OPEN.
  qh:GET-FIRST.
  p-ret = buf_din_trn-doc:BUFFER-FIELD(p-pole):BUFFER-VALUE   .
  DELETE WIDGET qh.
  DELETE WIDGET buf_din_trn-doc.
end.
end procedure.
