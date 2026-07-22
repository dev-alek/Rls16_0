block-level on error undo, throw.
define temp-table temp-dates no-undo
field exch-date as date
index pi is unique primary   exch-date
.
define temp-table temp-abc-day no-undo
field abc-type as character
field gar-day  as decimal
index pi abc-type
.
define input parameter parParentProc   as widget-handle no-undo.
define input parameter p-round-m       as character no-undo .
define input parameter p-round-base    as decimal   no-undo .
define input parameter p-e-method  as character no-undo .
define input parameter p-mode-calc as character no-undo .
define input parameter p-ord-doc   as character no-undo .
define input parameter xdate-1    as date no-undo .
define input parameter xdate-2    as date no-undo .
define input parameter t-action   as character no-undo .
define input parameter var#import as logical  no-undo .
define input parameter p-r-algoritm    as integer no-undo .
define input parameter p-type-qnty-day as integer no-undo .
define input parameter p-r-min-rest    as integer no-undo .
define input parameter p-r-min-rest3   as logical no-undo .
define input parameter p-code     as character no-undo   .
define input parameter p-t-rv     as logical no-undo .
define input parameter p-t-rvz    as logical no-undo .
define input parameter p-t-rvc    as logical no-undo .
define input parameter p-t-rvzc   as logical no-undo .
define input parameter p-t-sp     as logical no-undo .
define input parameter p-t-sppv   as logical no-undo .
define input parameter p-t-sppv-2 as logical no-undo .
define input parameter p-t-sppv-3 as logical no-undo .
define input parameter p-t-sppv-4 as logical no-undo .
define input parameter p-t-way    as logical no-undo .
define input parameter p-t-rcv    as logical no-undo .
define input parameter p-t-clos   as logical no-undo .
define input parameter table for  temp-dates.
define input parameter table for  temp-abc-day.
define input parameter p-neg-sale as logical no-undo .
define input parameter p-t-gar    as logical no-undo .
define input parameter p-t-min-zapas as logical no-undo .
define input parameter p-t-min-ost   as logical no-undo .
define input parameter p-t-deadline as logical no-undo .
define input parameter store-type    as character no-undo .
define input parameter store-code    as integer   no-undo .
define input parameter g#type        as character no-undo .
define input parameter p-tog-det-prizn as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: 2a79bf27b012, 291, rls $":u .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":u .
define variable vss-date        as character no-undo init "$Date: Tue Dec 01 19:11:26 2015 +0300 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: qntysale.p $":u .
define variable vss-archive     as character no-undo init "$Archive: cus/qntysale.p $":u .
define variable vss-description as character no-undo init "Предпологанмое значение заказа" .
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable gdsgrp_recids      as character no-undo.
define  shared variable fin-schet-recid    as character no-undo.
define  shared variable v-d-report-handle  as handle    no-undo .
define  shared temp-table g#customer no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define  shared temp-table g#cli no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define  shared temp-table tmp#grp no-undo
    field node-code like ub.gds-grp.node-code
    field grp-name like ub.gds-grp.node-name
    field lvl-num  like ub.gds-grp.lvl-num
    field is-term  like ub.gds-grp.is-term
    index pi is unique primary grp-name node-code
    index i-node-code    node-code
    index level-num   lvl-num  grp-name
    index is-term is-term  grp-name
    .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared temp-table gds-list no-undo like ub.goods
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define   shared  temp-table gds-list-hist no-undo
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def
 shared
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
define  shared temp-table X-init_obj-list no-undo
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
index pi is unique primary obj-type obj-code.
define variable p1 like ub.gds-obj.prod-type no-undo.
define variable p2 like ub.gds-obj.prod-code no-undo.
define variable p3 like ub.gds-obj.artic     no-undo.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable to-day       as date no-undo .
define   shared variable str1   as character  no-undo.
define   shared variable str2   as character  no-undo.
define   shared variable str3   as character  no-undo.
define   shared variable str4   as character  no-undo.
define   shared variable ReportNAme   as character  no-undo.
define   shared variable ReportProc   as character  no-undo.
define   shared variable ReportHeader as character  no-undo.
define   shared variable ReportPageWidth  as integer no-undo.
define   shared variable ReportPageHeight as integer no-undo.
define   shared variable ReportFontNum    as integer no-undo.
define   shared variable my-request as logical  init false no-undo.
define   shared variable v-delim as character no-undo .
define   shared variable v-sdate as character no-undo initial "/":U.
define   shared variable v-shortdate as character no-undo initial "dd/mm/yyyy":U .
define   shared variable my-handle  as handle no-undo .
define   shared variable parent-handle  as handle no-undo .
define   shared variable v-show-all-goods as logical  no-undo .
define   shared variable params-only      as logical   no-undo .
define   shared variable params-only-mode as character no-undo .
define   shared variable place-call       as character no-undo .
define   shared variable x-Goods-Editor   as character  no-undo .
define   shared variable x-Date-Alone     as date format "99/99/9999":u   no-undo .
define   shared variable x-Date-End       as date format "99/99/9999":u   no-undo .
define   shared variable x-Date-Start     as date format "99/99/9999":u   no-undo .
define   shared variable x-Shift-Alone    as integer format ">9":u         no-undo .
define   shared variable x-Shift-End      as integer format ">9":u         no-undo .
define   shared variable x-Shift-Start    as integer format ">9":u         no-undo .
define   shared variable x-SelectGood     as integer                      no-undo .
define   shared variable x-SelectObject   as character                          no-undo .
define   shared variable x-SET_PAY_TYPE   as integer  no-undo .
define   shared variable x-SET_val_TYPE   as integer  no-undo .
define   shared variable x-TOG-Shift      as logical  no-undo .
define   shared variable x-Radio-Task     as integer  no-undo .
define   shared variable x-TOG-Excel      as logical  no-undo .
define   shared variable x-TOG-list-hist  as logical  no-undo .
define   shared variable x-text-1 as character  no-undo .
define   shared variable x-text-2 as character  no-undo .
define   shared variable x-text-3 as character  no-undo .
define   shared variable x-text-4 as character  no-undo .
define   shared variable init-date-start  like x-date-start  no-undo .
define   shared variable init-date-end    like x-date-end    no-undo .
define   shared variable init-date-alone  like x-date-alone  no-undo .
define   shared variable init-shift-alone like x-shift-alone no-undo .
define   shared variable init-shift-start like x-shift-start no-undo .
define   shared variable init-shift-end   like x-shift-end   no-undo .
define   shared variable init-set_pay_type like x-set_pay_type   no-undo .
define   shared variable init-set_val_type like x-set_val_type   no-undo .
define   shared variable ref_date-start    as character   no-undo .
define   shared variable ref_date-end      as character   no-undo .
define   shared variable ref_date-alone    as character   no-undo .
define   shared work-table TDEDT  no-undo
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
define   shared variable str-obj-type as character  no-undo.
define   shared variable str-obj-code as character  no-undo.
define   shared variable str-obj-name as character  no-undo.
define   shared variable str-obj      as character  no-undo.
define   shared variable link#        as logical  no-undo init false.
define   shared variable  Verify-Arc-ot      as logical  no-undo init false.
define   shared variable  Verify-Arc-stk     as logical  no-undo init false.
define   shared variable  Verify-Arc-supp    as logical  no-undo init false.
define   shared variable  Verify-Arc-hold    as logical  no-undo init false.
define   shared variable  Verify-Arc-aht     as logical  no-undo init false.
define   shared variable  Verify-send-check  as logical  no-undo init false.
define   shared variable  Verify-Arc-fin     as logical  no-undo init false.
define   shared variable  Verify-Arc-strong  as logical  no-undo init false.
define   shared variable  Show-Crsa         as logical  no-undo init false.
define   shared variable  Show-Cost         as logical  no-undo init false.
define   shared variable  Show-Sale         as logical  no-undo init false.
define   shared variable  Name-Sale-price   as character no-undo .
define   shared variable  Format-Folder     as logical no-undo .
define   shared variable  Print-List-Hist   as logical no-undo init false.
define   shared variable Make-Excel     as logical  no-undo init false.
define   shared variable Make-Excel-com as logical  no-undo init false.
define   shared stream ForExcel.
define   shared variable Use-column   as logical extent 256 no-undo .
define   shared variable right-column as logical extent 256 no-undo .
define shared  temp-table Sheetf no-undo
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
find first sheetf where sheet-num = 1 no-error.
define variable l-stroka as character no-undo .
define   shared  variable ch#ExcelApplication as com-handle no-undo .
define   shared  variable ch#Workbook         as com-handle no-undo .
define   shared  variable ch#Worksheet        as com-handle no-undo .
define   shared  variable Num#Str#            as integer no-undo.
define   shared  variable Number-List         as integer no-undo init 1.
define   shared  variable v-excel-file        as character no-undo .
define variable Col-name as character  extent 256.
define variable Col-format as character  extent 256.
define variable Col-Post-format as character  extent 256.
run proc-page0-assign in this-procedure .
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define shared temp-table tmp#zakaz1 no-undo like ub.ord-line field sum       as decimal   field all-day   as integer   field qnty-sale as decimal   field negative-rest as logical    field gds-name  as character field unit-base as character field unit-type as character field unit-cli-type as character field min-order     as decimal   field service-order as decimal field local-mark    as character field max-stock     as decimal   field season-coef   as decimal   field min-stock-old as decimal   field gds-way       as decimal   index pi is unique primary artic prod-type prod-code  ascending index idx-ln line-num.
define shared temp-table tmp#zakaz-prn1 no-undo field artic         like ub.goods.artic      field prod-type     like ub.goods.prod-type  field prod-code     like ub.goods.prod-code  field obj-type      like ub.clients.obj-type field obj-code      like ub.clients.obj-code field prt-code      as   integer    field qnty-sale     as   decimal    field qnty-ord      as   decimal    index pi is unique primary artic prod-type prod-code obj-type obj-code prt-code  ascending.
define shared temp-table tmp#zakaz-dtl1 no-undo like ub.ord-dtl field prt-name as character index bi is unique primary artic prod-type prod-code node-code  ascending.
define  shared buffer clients-doc for ub.clients   .
define  buffer clients-doc1 for ub.clients   .
define  buffer clients-doc2 for ub.clients   .
define  shared buffer buf-goods   for ub.goods     .
define  shared buffer sb-cli-gds  for ub.cli-gds   .
define  shared buffer sb-gds-obj  for ub.gds-obj   .
define  shared buffer tmp#zakaz     for tmp#zakaz1.
define  shared buffer tmp#zakaz-prn     for tmp#zakaz-prn1.
define  shared buffer tmp#zakaz-dtl for tmp#zakaz-dtl1.
define buffer buf_contract for ub.contract .
define  shared  buffer shar_ord-doc  for ub.ord-doc .
define  shared  buffer shar_ord-line for ub.ord-line.
define  shared  buffer shar_ord-dtl  for ub.ord-dtl .
define  shared variable chexcelapplication      as com-handle no-undo .
define  shared variable chworkbook              as com-handle no-undo .
define  shared variable chworksheet             as com-handle no-undo .
define  shared variable chrange                 as com-handle no-undo .
define  shared variable chworksheet2            as com-handle no-undo .
define  shared variable chworksheet3            as com-handle no-undo .
define  shared variable accum-zakaz             as decimal no-undo .
define  shared variable accum-sum-zakaz         as decimal no-undo .
define  shared variable accum-count             as integer no-undo .
define  shared buffer buf-cli for ub.clients.
define  shared variable loc-obj-name as character format "x(256)":u
     view-as text
     size 39.25 by 1 tooltip "Поставщик"
     fgcolor 4  no-undo.
define  shared variable agnt as integer format ">>>>>>>>>" initial ?
     label "И&сп"
     view-as fill-in tooltip "Код исполнителя"
     size 9.75 by 1 no-undo.
define  shared  variable boss as integer format ">>>>>>>>>" initial ?
     label "&М-р"
     view-as fill-in    tooltip "Код менеджера"
     size 9.75 by 1 no-undo.
define    shared  variable date-1 as date format "99/99/9999":u
     label "Период с"
     view-as fill-in   tooltip "Период, для которого рассчитан темп продаж"
     size 11 by 1 fgcolor 1 no-undo.
define    shared  variable date-2 as date format "99/99/9999":u
     label "по"
     view-as fill-in  tooltip "Период, для которого рассчитан темп продаж"
     size 11 by 1 fgcolor 1 no-undo.
define    shared  variable date-sale-1 as date format "99/99/9999":u
     label "Для продажи с"
     view-as fill-in   tooltip "Период продаж товара"
     size 11 by 1  no-undo.
define    shared  variable date-sale-2 as date format "99/99/9999":u
     label "по"
     view-as fill-in  tooltip "Период продаж товара"
     size 11 by 1  no-undo.
define    shared  variable loc-cli-code as integer format ">>>>>>>>>" initial ?
     view-as fill-in
     size 9.75 by 1 tooltip "Код Поставщика" no-undo.
define    shared  variable loc-cli-type as character format "x(3)":u initial "орг"
     label "Код"
     view-as fill-in
     size 5.13 by 1 tooltip "Тип Поставщика" no-undo.
define    shared  variable loc-date-ship as date format "99/99/9999":u
     label "&Заказ на"
     view-as fill-in
     size 11 by 1 tooltip "Дата, на которую формируется заказ"
     fgcolor 4
     no-undo.
define    shared  variable loc-ord-num as character format "x(256)":u
     label "№"
     view-as text
     size 14 by 1
     fgcolor 4
     no-undo.
define    shared  variable wrkr as integer format ">>>>>>>>>" initial ?
     label "К&л-к"
     view-as fill-in
     size 9.75 by 1 tooltip "Код кладовщика"
     no-undo.
define    shared  variable loc-service as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Ст-ть обслу&живания"
     view-as fill-in
     size 14 by 1 tooltip "Стоимость обслуживания" no-undo.
define    shared  variable paytype as integer format "99999" initial ?
     label "Опл"
     view-as fill-in
     size 7.75 by 1 tooltip "Код типа оплаты"
     no-undo.
define   shared  variable loc-time-ship as character
      view-as fill-in
      size 7 by 1 tooltip "Время доставки" no-undo.
define   shared  variable loc-hour as integer format "99":u initial 0
     view-as fill-in
     size 3.5 by 1 no-undo.
define   shared  variable loc-min as integer format "99":u initial 0
     view-as fill-in
     size 3.5 by 1 no-undo.
define   shared  variable cycle-day as integer format ">>>":u initial 0
     label "через"
     view-as fill-in
     size 4.75 by 1
     fgcolor 4
     no-undo.
define  shared  variable pay-day as integer format ">>9":u initial 1
     label "На дней продаж"
     view-as fill-in
     size 7.13 by 1
     fgcolor 4
     no-undo.
define    shared  variable tog-type as int initial 0
     label "цкл"
     view-as radio-set horizontal radio-buttons
     "П",0,
     "Ц",1,
     "О",4
     size 11 by 1 tooltip "Тип заказа : простой,цикличный,объединенный цикличный" no-undo.
define  shared variable loc-status  as character  no-undo.
define  shared variable loc-base-rate as decimal format "->,>>>,>>>,>>>,>>9.9999":u initial 0
     label "Кур&с б.в."
     view-as fill-in
     size 9.4 by 1 no-undo.
define  shared variable loc-base-scale as integer format ">,>>>,>>9":u initial 0
     label "М&-б"
     view-as fill-in
     size 3.5 by 1 no-undo.
define  shared variable loc-cli-qnty as decimal format "->,>>>,>>>,>>>,>>9.999":u initial 0
     label "Кол.п-ка"
     view-as text
     size 14 by 0.67
     tooltip "Количество в ед.из. поставщика"
     fgcolor 4
     no-undo.
define  shared variable loc-exch-code as integer format "->,>>>,>>9":u initial 0
     label "Вал&."
     view-as fill-in
     size 7 by 1
     no-undo.
define  shared variable loc-exch-rate as decimal format "->,>>>,>>>,>>>,>>9.9999":u initial 0
     label "Курс п&-ка"
     view-as fill-in
     size 9.4 by 1
     no-undo.
define  shared variable loc-exch-scale as integer format ">,>>>,>>9":u initial 0
     label "М&-б"
     view-as fill-in
     size 3.5 by 1
     no-undo.
define  shared variable loc-out-code as character format "x(256)":u
     label "№ Поставки"
     view-as fill-in
     size 9.38 by 1 tooltip "Номер документа поставки по данному заказу"
     no-undo.
define  shared variable loc-cli-out-doc  as character format "x(256)":u
     label "№ Заказа по пост"
     view-as fill-in
     size 14 by 1 tooltip "Номер заказа в системе учета поставщика"
     no-undo.
define  shared variable loc-qnty as decimal format "->,>>>,>>>,>>>,>>9.999":u initial 0
     label "Кол-во"
     view-as text
     size 14 by 0.67 tooltip "Количество по заказу в баз.ед."
     fgcolor 4
     no-undo.
define  shared variable loc-sum-base as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Сумма заказа(б.в.)"
     view-as text
     size 14 by 0.67 tooltip "Сумма заказа(б.в.)"
     fgcolor 4
     no-undo.
define  shared variable loc-sum-cli as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Сумма заказа(в.п.)"
     view-as text
     size 14 by 0.67 tooltip "Сумма заказа в вал. поставщика"
     fgcolor 4
     no-undo.
define  shared variable loc-sum-rubl as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Сумма заказа(руб.)"
     view-as text
     size 14 by 0.67 tooltip "Сумма заказа(руб)"
     fgcolor 4
     no-undo.
define  shared variable loc-tot-lines as integer format "->,>>>,>>9":u initial 0
     label "Строк"
     view-as text
     size 7.38 by .67 tooltip "Контрольное количество строк в заказе"
     fgcolor 4
     no-undo.
define  shared variable doc-date as date format "99/99/99":u
     label "&Дата"
     view-as text
     size 9 by .67 tooltip "Дата документа"
     no-undo.
define  shared variable fact-date as date format "99/99/99":u
     label "&Факт"
     view-as text
     size 9 by .67 tooltip "Дата документа фактическая"
     fgcolor 4
     no-undo.
define  shared var loc-print-rubl as logical no-undo .
define  shared variable slt_type as character format "x(256)":u
     label "НсП"
     view-as combo-box inner-lines 3
     list-items
        'без':U,
        'нет':U,
        'в т. ч.':U
     size 9.75 by 1
     no-undo.
define  shared  variable vat_type as character format "x(256)":u
     label "НДС"
     view-as combo-box inner-lines 3
     list-items
        'без':U,
        'нет':U,
        'в т. ч.':U
     size 9.75 by 1
     no-undo.
define  shared  variable e-method as character
     view-as editor scrollbar-vertical
     size 30 by 3.42 tooltip "Метод расчета темпа продаж и количества заказа/заявки"
     bgcolor 8
     no-undo.
define    shared  variable loc-contract as integer
     label "Вн.№ дог-ра"
     view-as fill-in
     size 10 by 1 tooltip "Номер договора"
     format ">>>>>>>>>"
     fgcolor 1
     no-undo.
define  shared  variable loc-store-code like ub.ord-doc.obj-code no-undo .
define  shared  variable loc-store-type like ub.ord-doc.obj-type no-undo .
define  shared  variable loc-doc-type   like ub.ord-doc.doc-type no-undo .
define  shared  variable temp-e-method  as character no-undo .
define  shared  variable x-tog-artic as logical   no-undo .
define  shared  variable x-tog-grp    as logical   no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
procedure thbjattr_code :
   define input  parameter p-upper-code     as character no-undo .
   define input  parameter p-code           as character no-undo .
   define output parameter p-label          as character no-undo .
   define output parameter p-user-can-edit  as logical   no-undo .
   define output parameter p-output-display as logical   no-undo .
   define output parameter p-other          as character no-undo .
   define output parameter p-prop-list      as character no-undo .
   define output parameter p-prop-type-list as character no-undo .
   define output parameter p-prop-label-list as character no-undo .
   define output parameter p-global          as logical no-undo .
   define output parameter p-host           as logical no-undo .
   define output parameter p-shop           as logical no-undo .
   define output parameter p-store          as logical no-undo .
   define output parameter p-db             as logical no-undo .
   define variable p-region as logical no-undo.
   run thbjattr_code_reg in this-procedure (
                                            p-upper-code,
                                            p-code,
                                            output p-label,
                                            output p-user-can-edit,
                                            output p-output-display,
                                            output p-other,
                                            output p-prop-list,
                                            output p-prop-type-list,
                                            output p-prop-label-list,
                                            output p-global,
                                            output p-host,
                                            output p-shop,
                                            output p-store,
                                            output p-db,
                                            output p-region
                                            ).
end procedure.
procedure thbjattr_code_reg :
define input  parameter p-upper-code     as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-label          as character no-undo .
define output parameter p-user-can-edit  as logical   no-undo .
define output parameter p-output-display as logical   no-undo .
define output parameter p-other          as character no-undo .
define output parameter p-prop-list      as character no-undo .
define output parameter p-prop-type-list as character no-undo .
define output parameter p-prop-label-list as character no-undo .
define output parameter p-global          as logical no-undo .
define output parameter p-host           as logical no-undo .
define output parameter p-shop           as logical no-undo .
define output parameter p-store          as logical no-undo .
define output parameter p-db             as logical no-undo .
define output parameter p-region         as logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_code in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-label
    ,output p-user-can-edit
    ,output p-output-display
    ,output p-other
    ,output p-prop-list
    ,output p-prop-type-list
    ,output p-prop-label-list
    ,output p-global
    ,output p-host
    ,output p-shop
    ,output p-store
    ,output p-db
    ,output p-region
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info9, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_tooltip :
define input  parameter p-upper-code  as character no-undo .
define input  parameter p-code      as character no-undo .
define output parameter p-tooltip   as character no-undo .
define output parameter p-label     as character no-undo .
define output parameter p-tooltip-code as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_tooltip in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-tooltip
    ,output p-label
    ,output p-tooltip-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_legacy :
define input  parameter p-upper-code     as character no-undo .
define output parameter p-level-way      as character no-undo .
define output parameter p-up-way         as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_legacy in g#attr-lib
    (input  p-upper-code
    ,output p-level-way
    ,output p-up-way
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info9, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_value :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define output parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define output parameter p-value-date    like ub.thbj-attr.property-value-date no-undo .
define output parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define output parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define output parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
define output parameter p-type     as character no-undo .
define output parameter p-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_value in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-value-character
    ,output p-value-date
    ,output p-value-decimal
    ,output p-value-integer
    ,output p-value-logical
    ,output p-type
    ,output p-found
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_get-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-param-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-mode as character no-undo .
define input-output parameter table-handle p-tth.
define output parameter p-all-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_get-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-param-code
    ,input  p-mode
    ,input-output table-handle p-tth
    ,output p-all-found
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_write :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define input  parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define input  parameter p-value-date like ub.thbj-attr.property-value-date no-undo .
define input  parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define input  parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define input  parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_write in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,input  p-value-character
    ,input  p-value-date
    ,input  p-value-decimal
    ,input  p-value-integer
    ,input  p-value-logical
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_set-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter table-handle p-tth.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_set-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  table-handle p-tth
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_delete :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code       like ub.thbj-attr.prop-code  no-undo .
define output parameter p-deleted  as logical no-undo.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-deleted
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_delete-section :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_manual-edit :
define input  parameter p-ucode          as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-section-num    as integer no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_manual-edit in g#attr-lib
    (input  p-ucode
    ,input  p-code
    ,output  p-section-num
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
define variable l-Ostatok-today  as decimal   no-undo .
define variable l-negative-rest  as logical   no-undo .
define variable l-qnty-day       as integer   no-undo .
define variable l-pay-day        as integer   no-undo .
define variable l-Temp-rash      as decimal   no-undo .
define variable l-null-day       as integer   no-undo init 0 .
define variable l-min-zap        as decimal   no-undo .
define variable l-order          as decimal   no-undo .
define variable l-a              as decimal   no-undo .
define variable l-b              as decimal   no-undo .
define variable l-negative-sale  as logical   no-undo .
define variable l-goods-way      as decimal   no-undo .
define variable l-min-order      as decimal   no-undo .
define variable l-tog-min-order  as logical   no-undo .
define variable loc-unit-base    as character no-undo .
define variable l-min-ost        as logical   no-undo .
define variable l-tog-deadline   as logical   no-undo .
define variable l-deadline       as integer   no-undo .
define variable l-type-MR        as character no-undo .
define variable par-ord-min-ost  as logical   no-undo .
define variable v-media-qnty     as decimal   no-undo .
define variable l-corr-coeff     as decimal   no-undo .
define stream stream_order .
define variable is-log             as logical   no-undo .
define variable p-val              as character no-undo .
define variable p-type             as character no-undo .
define variable v-value-character  as character no-undo .
define variable v-value-date       as date      no-undo .
define variable v-value-decimal    as decimal   no-undo .
define variable v-value-integer    as integer   no-undo .
define variable v-stroka-protocol  as character no-undo .
define variable v-protocol-date    as date      no-undo .
define variable v-protocol-time    as integer   no-undo .
run adm/shattri.p (
  input "get":U
  ,input ""
  ,input 0
  ,input 'ord-global':U
  ,input 'ord-log':U
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output is-log
  ,output p-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
  if error-status :error then is-log = false .
run adm/shattri.p (
  input "get":U
  ,input ""
  ,input 0
  ,input 'ord-global':U
  ,input 'ord-min-ost-day':U
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output par-ord-min-ost
  ,output p-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
  if error-status :error then par-ord-min-ost = false .
procedure recalc-cli-qnty :
  do
  on error undo, return error return-value
  :
define input  parameter p-gds-code      as integer   no-undo .
define input  parameter p-round-m       as character no-undo .
define input  parameter p-round-base    as decimal   no-undo .
define input  parameter p-unit-cli      as character no-undo .
define input  parameter p-cli-base-rate as decimal   no-undo .
define input  parameter p-price-cli     as decimal   no-undo .
define input  parameter p-price-rubl    as decimal   no-undo .
define input  parameter p-price-base    as decimal   no-undo .
define input-output parameter p-cli-qnty as decimal   no-undo .
define input-output parameter p-qnty     as decimal   no-undo .
define input-output parameter p-sum-cli  as decimal   no-undo .
define input-output parameter p-sum-rubl as decimal   no-undo .
define input-output parameter p-sum-base as decimal   no-undo .
define buffer buf_goods for ub.goods  .
define buffer buf_units for ub.units  .
define variable v-cli-qnty as decimal   no-undo .
find first buf_goods no-lock where
           buf_goods.gds-code = p-gds-code no-error .
v-cli-qnty = p-cli-qnty .
if can-find (
first buf_units where
      buf_units.unit-name = p-unit-cli and
      lookup ('шту':U, buf_units.type) > 0 ) and
  truncate ( p-cli-qnty, 0 ) <> p-cli-qnty then do:
  assign
    v-cli-qnty = trunc( p-cli-qnty, 0 ) .
end.
   case p-round-m :
          when 'Кол-во_в_коробке':U then do:
           if buf_goods.qnty-cart  <> 0 then do:
                if ( p-qnty  > 0 and p-qnty <  buf_goods.qnty-cart ) then p-qnty = buf_goods.qnty-cart .
                assign
                  p-qnty     = round ( p-qnty / buf_goods.qnty-cart, 0 ) *  buf_goods.qnty-cart
                  .
                  if ( p-qnty > 0 and p-qnty <  buf_goods.qnty-cart ) then p-qnty = buf_goods.qnty-cart .
                assign
                  p-cli-qnty = p-qnty / p-cli-base-rate
                  p-sum-cli  = p-price-cli  * p-cli-qnty
                  p-sum-rubl = p-price-rubl * p-qnty
                  p-sum-base = p-price-base * p-qnty
                .
             end.
             else do:
                assign
                  p-qnty     = v-cli-qnty   * p-cli-base-rate
                  p-sum-cli  = p-price-cli  * v-cli-qnty
                  p-sum-rubl = p-price-rubl * p-qnty
                  p-sum-base = p-price-base * p-qnty
                .
             end.
          end.
          when 'Без-дробных':U then do:
              if can-find(first buf_units where
                      buf_units.unit-name = p-unit-cli and
                      lookup ('шту':U, buf_units.type) > 0 ) and
                      trunc ( p-cli-qnty, 0 ) <> p-cli-qnty then do:
                      assign
                        p-cli-qnty = trunc( p-cli-qnty, 0 ) + 1
                        p-qnty     = p-cli-qnty   * p-cli-base-rate
                        p-sum-cli  = p-price-cli  * p-cli-qnty
                        p-sum-rubl = p-price-rubl * p-qnty
                        p-sum-base = p-price-base * p-qnty
                      .
              end.
              else do:
                      assign
                        p-cli-qnty = round( p-cli-qnty, 0 )
                        p-qnty     = p-cli-qnty   * p-cli-base-rate
                        p-sum-cli  = p-price-cli  * p-cli-qnty
                        p-sum-rubl = p-price-rubl * p-qnty
                        p-sum-base = p-price-base * p-qnty
                      .
              end.
          end.
          when 'Произвольно':U then do:
            if p-round-base <> 0 then do:
              assign
                p-cli-qnty = round ( p-cli-qnty / p-round-base , 0 ) * p-round-base
              .
            end.
            assign
                p-qnty     = p-cli-qnty   * p-cli-base-rate
                p-sum-cli  = p-price-cli  * p-cli-qnty
                p-sum-rubl = p-price-rubl * p-qnty
                p-sum-base = p-price-base * p-qnty
              .
          end.
          when 'Отключено':U or when ""  then do:
            assign
                p-cli-qnty = v-cli-qnty
                p-qnty     = p-cli-qnty   * p-cli-base-rate
                p-sum-cli  = p-price-cli  * p-cli-qnty
                p-sum-rubl = p-price-rubl * p-qnty
                p-sum-base = p-price-base * p-qnty
              .
          end.
   end case.
if is-log = true then  Output stream stream_order to value ("order_raschet.txt") APPEND .
if is-log = true then  put stream stream_order unformatted
        " После округления кол-во в баз.ед. изм. : " p-qnty  skip
        " Метод округления :  " p-round-m
          ( if p-round-m = 'Произвольно':U
              then  string(p-round-base)
              else  "" )
          ( if p-round-m = 'Кол-во_в_коробке':U
              then  string(buf_goods.qnty-cart)
              else  "" ) skip
        "__________________________________________________"     skip  .
if is-log = true then  OUTPUT  STREAM  stream_order CLOSE.
v-stroka-protocol = v-stroka-protocol + chr(4) +
                  "18.Метод округления : " +  p-round-m +
                    ( if p-round-m = 'Произвольно':U
                        then  string(p-round-base)
                        else  " " )  +
                    ( if p-round-m = 'Кол-во_в_коробке':U
                        then  string(buf_goods.qnty-cart)
                        else  "" ) + chr(4) +
                  "19.После округления кол-во в баз.ед. изм. : " + string( p-qnty)
                    .
  end.
end procedure.
procedure create-protocol :
define input  parameter p-ord-doc  as character no-undo .
define input  parameter p-gds-code as integer   no-undo .
define input  parameter p-date     as date     no-undo .
define input  parameter p-time     as integer   no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define input  parameter p-str      as character no-undo .
define buffer buf_ord-line-attr for ub.ord-line-attr  .
  do
  on error undo, return error return-value
  :
  if p-gds-code = ? or p-gds-code = 0 then return.
  if p-ord-doc = ? or p-ord-doc = ""   then return.
  if p-obj-type = ?  then return.
  if p-obj-code = ?  then return.
  if p-date = ?  then return.
    find first buf_ord-line-attr exclusive-lock where
              buf_ord-line-attr.doc-code = p-ord-doc  and
              buf_ord-line-attr.gds-code = p-gds-code and
              buf_ord-line-attr.attr-code =  "protocol"           + chr(4) +
                                              p-obj-type          + chr(4) +
                                              string(p-obj-code)  + chr(4) +
                                              string(p-date, "99-99-9999" )  + chr(4) +
                                              string(p-time,"hh:mm:ss"  )
                                              no-error .
    if not available buf_ord-line-attr then do:
       create buf_ord-line-attr no-error .
    end.
    if available buf_ord-line-attr then do:
    assign
      buf_ord-line-attr.doc-code  = p-ord-doc
      buf_ord-line-attr.gds-code  = p-gds-code
      buf_ord-line-attr.attr-code =  "protocol"           + chr(4) +
                                      p-obj-type          + chr(4) +
                                      string(p-obj-code)  + chr(4) +
                                      string(p-date, "99-99-9999" )  + chr(4) +
                                      string(p-time, "hh:mm:ss"  )
      buf_ord-line-attr.attr-value  = p-str
      no-error
    .
    end.
  end.
end procedure.
procedure create-obj-temp :
define input  parameter p-ord-doc as character no-undo .
define input  parameter p-gds-code as integer   no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define input  parameter p-qnty as decimal   no-undo .
define buffer buf_ord-line-attr for ub.ord-line-attr  .
  do
  on error undo, return error return-value
  :
  if p-gds-code = ? or p-gds-code = 0 then return.
  if p-ord-doc = ? or p-ord-doc = "" then return.
  if p-obj-type = ?  then return.
  if p-obj-code = ?  then return.
    find first buf_ord-line-attr exclusive-lock where
              buf_ord-line-attr.doc-code = p-ord-doc  and
              buf_ord-line-attr.gds-code = p-gds-code and
              buf_ord-line-attr.attr-code =  "objqnty"   + chr(4) +
                                              p-obj-type + chr(4) +
                                              string(p-obj-code)  no-error .
    if not available buf_ord-line-attr then do:
       create buf_ord-line-attr no-error .
    end.
    assign
      buf_ord-line-attr.doc-code  = p-ord-doc
      buf_ord-line-attr.gds-code  = p-gds-code
      buf_ord-line-attr.attr-code = "objqnty"  + chr(4) +
                                    p-obj-type + chr(4) +
                                    string(p-obj-code)
      buf_ord-line-attr.attr-value = string( p-qnty )
      no-error
    .
  end.
end procedure.
procedure create-min-stock-gds-way :
define input  parameter p-ord-doc   as character no-undo .
define input  parameter p-gds-code  as integer   no-undo .
define input  parameter p-min-stock as decimal   no-undo .
define input  parameter p-gds-way   as decimal   no-undo .
define buffer buf_ord-line-attr for ub.ord-line-attr  .
  do
  on error undo, return error return-value
  :
  if p-gds-code = ? or p-gds-code = 0 then return.
  if p-ord-doc  = ? or p-ord-doc = "" then return.
    find first buf_ord-line-attr exclusive-lock where
              buf_ord-line-attr.doc-code = p-ord-doc  and
              buf_ord-line-attr.gds-code = p-gds-code and
              buf_ord-line-attr.attr-code = 'min-stock':U
                                             no-error .
    if not available buf_ord-line-attr then do:
       create buf_ord-line-attr no-error .
    end.
    if available buf_ord-line-attr then do:
    assign
      buf_ord-line-attr.doc-code  = p-ord-doc
      buf_ord-line-attr.gds-code  = p-gds-code
      buf_ord-line-attr.attr-code = 'min-stock':U
      buf_ord-line-attr.attr-value = string (p-min-stock)
      no-error
    .
    end.
    find first buf_ord-line-attr exclusive-lock where
              buf_ord-line-attr.doc-code = p-ord-doc  and
              buf_ord-line-attr.gds-code = p-gds-code and
              buf_ord-line-attr.attr-code = 'gds-way':U
                                             no-error .
    if not available buf_ord-line-attr then do:
       create buf_ord-line-attr no-error .
    end.
    if available buf_ord-line-attr then do:
    assign
      buf_ord-line-attr.doc-code  = p-ord-doc
      buf_ord-line-attr.gds-code  = p-gds-code
      buf_ord-line-attr.attr-code = 'gds-way':U
      buf_ord-line-attr.attr-value = string (p-gds-way)
      no-error
    .
    end.
  end.
end procedure.
def var vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure normobr_invers-erf :
  define input  parameter p-x     as decimal   no-undo .
  define output parameter p-value as decimal   no-undo .
  define variable vss-description as character no-undo init "normobr_invers-erf-01: Обратная функция Erf".
  do
  on error undo, return error return-value
  :
    if p-x = ?
    or p-x > 1
    or p-x < -1
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info11 skip
        "Ошибка задания входных параметров" skip
        "p-x" p-x skip
        view-as alert-box error .
      undo, return error .
    end.
    define variable p-x-power2  as decimal   no-undo .
    define variable p-x-power4  as decimal   no-undo .
    define variable p-x-power8  as decimal   no-undo .
    define variable p-x-power16 as decimal   no-undo .
    assign
      p-x-power2  = p-x * p-x
      p-x-power4  = p-x-power2 * p-x-power2
      p-x-power8  = p-x-power4 * p-x-power4
      p-x-power16 = p-x-power8 * p-x-power8
    .
    assign
      p-value = 08862269254.5275790 * p-x
              + 02320136665.3465444 * p-x * p-x-power2
              + 01275561753.0559793 * p-x * p-x-power4
              + 00865521292.4154752 * p-x * p-x-power2 * p-x-power4
              + 00649596177.4538540 * p-x * p-x-power8
              + 00517312819.8461636 * p-x * p-x-power2 * p-x-power8
              + 00428367206.5179733 * p-x * p-x-power4 * p-x-power8
              + 00364659293.0853162 * p-x * p-x-power2 * p-x-power4 * p-x-power8
              + 00316890050.2160544 * p-x * p-x-power16
              + 00279806329.6499521 * p-x * p-x-power2 * p-x-power16
              + 00250222758.4119834 * p-x * p-x-power4 * p-x-power16
              + 00226098633.1889757 * p-x * p-x-power2 * p-x-power4 * p-x-power16
              + 00206067803.7905899 * p-x * p-x-power8 * p-x-power16
    .
    assign
      p-value = p-value / 10000000000
    .
  end.
end procedure.
procedure normobr :
  define input  parameter p-p     as decimal   no-undo .
  define input  parameter p-m     as decimal   no-undo .
  define input  parameter p-sigma as decimal   no-undo .
  define output parameter p-x     as decimal   no-undo .
  define variable vss-description as character no-undo init "normobr-01: Обратная функция нормального распределения".
  do
  on error undo, return error return-value
  :
    if p-p > 1
    or p-p < 0
    or p-p = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info11 skip
        "Ошибка задания входных параметров" skip
        "Неверные значения парметра p-p  " skip
        "Он не может быть больше нуля и меньше единицы" skip
        "p-p (- уровень постоянного присутствия)              " p-p skip
        "p-m (Темп продаж )                                   " p-m skip
        "p-sigma (среднеквадратичное отклонение Темпа продаж) " p-sigma skip
        view-as alert-box error .
      undo, return error .
    end.
    if p-m = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info11 skip
        "Ошибка задания входных параметров" skip
        "Не задано значение парметра p-m" skip
        "p-p (- уровень постоянного присутствия)              " p-p skip
        "p-m (Темп продаж )                                   " p-m skip
        "p-sigma (среднеквадратичное отклонение Темпа продаж) " p-sigma skip
        view-as alert-box error .
      undo, return error .
    end.
    if p-sigma = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info11 skip
        "Ошибка задания входных параметров" skip
        "Не задано значение парметра p-sigma" skip
        "p-p (- уровень постоянного присутствия)              " p-p skip
        "p-m (Темп продаж )                                   " p-m skip
        "p-sigma (среднеквадратичное отклонение Темпа продаж) " p-sigma skip
        view-as alert-box error .
      undo, return error .
    end.
    define variable v-inverse-erf as decimal   no-undo .
    run normobr_invers-erf in this-procedure
      (input  1 - 2 * p-p
      ,output v-inverse-erf
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове функции normobr_invers-erf" skip
        "p-p (- уровень постоянного присутствия)              " p-p skip
        "p-m (Темп продаж )                                   " p-m skip
        "p-sigma (среднеквадратичное отклонение Темпа продаж) " p-sigma skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      p-x = p-m - 1.4142135623730950488 * p-Sigma * v-inverse-erf
    .
  end.
end procedure.
procedure normobr_test :
  do
  on error undo, return error return-value
  :
    define variable v-test as decimal no-undo .
    run normobr in this-procedure
      (input .85
      ,input 2
      ,input 1.528
      ,output v-test
      ) .
    message
      "НОРМОБР(0,85; 2; 1,528) = 3.58366944" skip
      "normobr" v-test skip
      view-as alert-box .
    run normobr in this-procedure
      (input .75
      ,input 8.267
      ,input 1.745
      ,output v-test
      ) .
    message
      "НОРМОБР(0,75; 8,267; 1,745) = 9.44398569" skip
      "normobr" v-test skip
      view-as alert-box .
    run normobr in this-procedure
      (input .5
      ,input 10
      ,input 1.745
      ,output v-test
      ) .
    message
      "НОРМОБР(0,5; 10; 1,745) = 10" skip
      "normobr" v-test skip
      view-as alert-box .
    run normobr in this-procedure
      (input .05
      ,input 10
      ,input 1.745
      ,output v-test
      ) .
    message
      "НОРМОБР(0,05; 10; 1,745) = 7.12973151" skip
      "normobr" v-test skip
      view-as alert-box .
  end.
end procedure.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-pl-gds no-undo   like ub.pl-gds .
define temp-table temp-prt-obj no-undo   field prt-code         like ub.prt-obj.prt-code     field price-sale       like ub.prt-obj.price-sale   field fact-qnty        like ub.prt-obj.fact-qnty    field price-list-qnty  like ub.prt-obj.fact-qnty    field is-term          as logical   field prt-obj-recid    as recid     field price-list-recid as recid     index xpk is primary unique prt-code   index xie1 is-term .
procedure prdoclib-process-goods :
  define input  parameter p-obj-type          as character no-undo .
  define input  parameter p-obj-code          as integer   no-undo .
  define input  parameter p-artic             as character no-undo .
  define input  parameter p-prod-type         as character no-undo .
  define input  parameter p-prod-code         as integer   no-undo .
  define input  parameter p-check-price-list  as logical   no-undo .
  define input  parameter p-check-price-parts as logical   no-undo .
  define input  parameter p-doc-num           as character no-undo .
  define input  parameter p-fact-date         as date      no-undo .
  define input  parameter p-corr-user-db-num  as integer   no-undo .
  define input  parameter p-corr-user-name    as character no-undo .
  define input  parameter p-corr-date         as date      no-undo .
  define input  parameter p-corr-time         as integer   no-undo .
  define input  parameter p-corr-time-str     as character no-undo .
  define output parameter p-gds-obj-fact-qnty as decimal   no-undo .
  define variable vss-description as character no-undo initial "prdoclib-process-goods-01: обработка продажных цен товара".
  define buffer buf_gds-obj      for ub.gds-obj .
  define buffer buf_prt-obj      for ub.prt-obj .
  define buffer buf_price-list   for ub.price-list .
  define buffer buf_bar-code     for ub.bar-code .
  define buffer buf_temp-prt-obj for temp-prt-obj .
  define variable v-gds-code             like ub.goods.gds-code    no-undo .
  define variable v-root-node            like ub.prt-obj.prt-code  no-undo .
  define variable v-root-b-code          like ub.bar-code.b-code   no-undo .
  define variable v-total-term-fact-qnty like ub.prt-obj.fact-qnty no-undo .
  define variable v-total-fact-sale      like ub.gds-obj.fact-sale no-undo .
  define variable v-doc-num     like ub.price-list.doc-num    no-undo .
  define variable v-price-sale  like ub.price-list.price-sale no-undo .
  define variable v-road-tax    like ub.price-list.road-tax   no-undo .
  define variable v-excise      like ub.price-list.excise     no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-root-node
  )  .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  v-root-node
  ,buffer buf_gds-obj
  ,buffer buf_prt-obj
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info12 skip
        "Ошибка при начале товародвижения товара на объекте" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    find current buf_gds-obj  exclusive-lock .
    find current buf_prt-obj  exclusive-lock .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-gds-code
  )  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  v-gds-code
  ,input  v-root-node
  ,output v-root-b-code
  )  .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  v-root-b-code
  ,input  v-root-b-code
  ,input  0
  ,output v-doc-num
  ,output v-price-sale
  ,output v-road-tax
  ,output v-excise
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info12 skip
        "Ошибка при определении цены признака на объекте" skip
        "Объект"     p-obj-type p-obj-code  skip
        "Бар-код"    v-root-b-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    run prdoclib-init-temp-prt-obj in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input v-price-sale
      ) .
    find first buf_price-list no-lock
      where buf_price-list.doc-num    = v-doc-num
        and buf_price-list.price-type = ""
        and buf_price-list.b-code     = v-root-b-code
      .
    find first buf_temp-prt-obj
      where buf_temp-prt-obj.prt-code = v-root-node
      .
    assign
      buf_temp-prt-obj.price-sale       = v-price-sale
      buf_temp-prt-obj.price-list-qnty  = buf_price-list.doc-qnty
      buf_temp-prt-obj.price-list-recid = recid(buf_price-list)
    .
    define variable l-empty-scale as logical no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  v-root-node
  ,input  'empty-scale=request'
  ,output l-empty-scale
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info12 skip
        "Ошибка при определении атрибута шкалы" skip
        "Код признака" v-root-node skip
        "Запрашивался атрибут" "empty-scale=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      v-total-term-fact-qnty = 0
      v-total-fact-sale      = 0
    .
    if l-empty-scale = true
    then do:
      for each buf_price-list
        where buf_price-list.doc-num    = v-doc-num
          and buf_price-list.main-price = false
          and buf_price-list.artic      = p-artic
          and buf_price-list.prod-type  = p-prod-type
          and buf_price-list.prod-code  = p-prod-code
          and buf_price-list.price-type = ""
      on error undo, return error return-value
      :
        if buf_price-list.doc-qnty <> ? and p-check-price-parts
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info12 skip
            "Ошибка при закрытии переоценки" skip
            "Для неосновного бар-кода товара с пустой шкалой" skip
            "указано количество отличное от ?" skip
            "Переоценка" v-doc-num skip
            "Бар-код" buf_price-list.b-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            "Количество" buf_price-list.doc-qnty skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
    end.
    if l-empty-scale = false
    then do:
      define variable v-unit-base like ub.goods.unit-base no-undo .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run unitbase in g#library
  (input  v-gds-code
  ,output v-unit-base
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info12 skip
          "Ошибка при определении базовой единицы измерения товара" skip
          "Код товара" v-gds-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      for each buf_price-list
        where buf_price-list.doc-num    = v-doc-num
          and buf_price-list.main-price = false
          and buf_price-list.artic      = p-artic
          and buf_price-list.prod-type  = p-prod-type
          and buf_price-list.prod-code  = p-prod-code
          and buf_price-list.price-type = ""
      on error undo, return error
      :
        if buf_price-list.doc-qnty = ?
        then do:
          find first buf_bar-code no-lock
            where buf_bar-code.b-code = buf_price-list.b-code
            no-error .
          if  available buf_bar-code
          and buf_bar-code.unit-cli = v-unit-base
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info12 skip
              "Ошибка при закрытии переоценки" skip
              "Не задано количество для бар-кода с основной единицей измерения" skip
              "Переоценка" v-doc-num skip
              "Бар-код" buf_price-list.b-code skip
              "Артикул" p-artic p-prod-type p-prod-code skip
              "Количество" buf_price-list.doc-qnty skip
              "Основная единица измерения" v-unit-base skip
              "Единица измерения бар-кода" buf_bar-code.unit-cli skip
              view-as alert-box error .
            undo, return error .
          end.
          next .
        end.
        find first buf_bar-code no-lock
          where buf_bar-code.b-code = buf_price-list.b-code
          no-error .
        if not available buf_bar-code
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info12 skip
            "В переоценке задан несуществующий бар-код" skip
            "Переоценка" v-doc-num skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            "Бар-код" buf_price-list.b-code skip
            view-as alert-box error .
          undo, return error .
        end.
        if buf_bar-code.in-code <> ""
        or buf_bar-code.part-code <> ""
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info12 skip
            "В переоценке задан бар-код партии" skip
            "Данная версия системы не рассчитана на работу со специальными ценами по партиям" skip
            "Переоценка" v-doc-num skip
            "Бар-код" buf_price-list.b-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            "Код ПН" buf_bar-code.in-code buf_bar-code.part-code skip
            view-as alert-box error .
          undo, return error .
        end.
        if buf_bar-code.node-code <> v-root-node
        then do:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  buf_bar-code.node-code
  ,buffer buf_prt-obj
  ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info12 skip
              "Невозможно найти prt-obj" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error .
          end.
          run prdoclib-create-temp-prt-obj in this-procedure
            (input  v-price-sale
            ,buffer buf_prt-obj
            ,buffer buf_temp-prt-obj
            ).
          assign
            buf_temp-prt-obj.price-sale       = buf_price-list.price-sale
            buf_temp-prt-obj.price-list-qnty  = buf_price-list.doc-qnty
            buf_temp-prt-obj.price-list-recid = recid(buf_price-list)
          .
        end.
      end.
      for each buf_temp-prt-obj
        where buf_temp-prt-obj.is-term = true
      :
        if buf_temp-prt-obj.price-list-recid <> ?
        then do:
          assign
            v-total-term-fact-qnty = v-total-term-fact-qnty
                                  + buf_temp-prt-obj.fact-qnty
            v-total-fact-sale = v-total-fact-sale
                              + buf_temp-prt-obj.fact-qnty * buf_temp-prt-obj.price-sale
          .
        end.
        if p-check-price-list = true
        then do:
          if buf_temp-prt-obj.price-list-recid = ?
          or buf_temp-prt-obj.fact-qnty = buf_temp-prt-obj.price-list-qnty
          then do:
          end.
          else do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info12 skip
              "Ошибка при закрытии переоценки" skip
              "Несовпадают текущие количества по признаку" skip
              "и количество признака в переоценке" skip
              "Переоценка" v-doc-num skip
              "Артикул" p-artic p-prod-type p-prod-code skip
              "Код признака" buf_temp-prt-obj.prt-code skip
              "Количество по признаку" buf_temp-prt-obj.fact-qnty skip
              "Количество по переоценке" buf_temp-prt-obj.price-list-qnty skip
              "Корень шкалы товара" v-root-node skip
              view-as alert-box error .
            undo, return error .
          end.
        end.
      end.
    end.
    find first buf_temp-prt-obj
      where buf_temp-prt-obj.prt-code = v-root-node
      .
    assign
      buf_temp-prt-obj.fact-qnty = buf_temp-prt-obj.fact-qnty
                                  - v-total-term-fact-qnty
    .
    if p-check-price-list = true
    then do:
      if buf_temp-prt-obj.fact-qnty <> buf_temp-prt-obj.price-list-qnty and p-check-price-parts
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info12 skip
          "Ошибка при закрытии переоценки" skip
          "Несовпадают текущие количества по корневому признаку" skip
          "и количество признака в переоценке" skip
          "Переоценка" v-doc-num skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "Код признака" buf_temp-prt-obj.prt-code skip
          "Количество по признаку" buf_temp-prt-obj.fact-qnty skip
          "Количество по переоценке" buf_temp-prt-obj.price-list-qnty skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
    assign
      v-total-fact-sale = v-total-fact-sale
                        + buf_temp-prt-obj.fact-qnty * buf_temp-prt-obj.price-sale
    .
    if v-total-fact-sale = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info12 skip
        "Ошибка при вычислении суммы в продажных ценах" skip
        "Получено неопределенное значение" skip
        "Переоценка" v-doc-num skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Код признака" buf_temp-prt-obj.prt-code skip
        "Сумма в продажных ценах" v-total-fact-sale skip
        view-as alert-box error .
      undo, return error .
    end.
    define variable v-old-fact-qnty     as decimal   no-undo .
    define variable v-old-fact-cli-qnty as decimal   no-undo .
    define variable v-old-fact-base     as decimal   no-undo .
    define variable v-old-fact-rubl     as decimal   no-undo .
    define variable v-old-fact-sale     as decimal   no-undo .
    assign
      v-old-fact-qnty     = buf_gds-obj.fact-qnty
      v-old-fact-cli-qnty = buf_gds-obj.fact-cli-qnty
      v-old-fact-base     = buf_gds-obj.fact-base
      v-old-fact-rubl     = buf_gds-obj.fact-rubl
      v-old-fact-sale     = buf_gds-obj.fact-sale
    .
    assign
      buf_gds-obj.price-sale = v-price-sale
      buf_gds-obj.fact-sale  = v-total-fact-sale
    .
    define variable v-corr-date as date      no-undo .
    define variable v-corr-time as integer   no-undo .
    run cur-time in this-procedure
      (output v-corr-date
      ,output v-corr-time
      ) .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gohist in g#library
  (input  buf_gds-obj.obj-type
  ,input  buf_gds-obj.obj-code
  ,input  buf_gds-obj.gds-code
  ,input  'close':U
  ,input  buf_gds-obj.fact-qnty
  ,input  buf_gds-obj.fact-cli-qnty
  ,input  buf_gds-obj.fact-base
  ,input  buf_gds-obj.fact-rubl
  ,input  buf_gds-obj.fact-sale
  ,input  v-old-fact-qnty
  ,input  v-old-fact-cli-qnty
  ,input  v-old-fact-base
  ,input  v-old-fact-rubl
  ,input  v-old-fact-sale
  ,input  'price-doc':U
  ,input  p-doc-num
  ,input  p-fact-date
  ,input  p-corr-user-db-num
  ,input  p-corr-user-name
  ,input  p-corr-date
  ,input  p-corr-time
  ,input  p-corr-time-str
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при создании истории по товару на объекте" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      p-gds-obj-fact-qnty = buf_gds-obj.fact-qnty
    .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if  buf_gds-obj.first-doc <> ?
and buf_gds-obj.first-doc > p-fact-date then do:
  assign
    buf_gds-obj.first-doc  = p-fact-date
  .
end.
if  buf_gds-obj.last-doc <> ?
and buf_gds-obj.last-doc < p-fact-date then do:
  assign
    buf_gds-obj.last-doc   = p-fact-date
  .
end.
    for each buf_temp-prt-obj
    ,first buf_prt-obj exclusive-lock
      where recid(buf_prt-obj) = buf_temp-prt-obj.prt-obj-recid
    on error undo, return error return-value
    :
      assign
        buf_prt-obj.price-sale = buf_temp-prt-obj.price-sale
      .
    end.
  end.
end procedure.
procedure prdoclib-clear-temp-prt-obj :
  define buffer buf_temp-prt-obj for temp-prt-obj .
  do
  on error undo, return error return-value
  :
    for each buf_temp-prt-obj
    on error undo, return error return-value
    :
      delete buf_temp-prt-obj .
    end.
  end.
end procedure.
procedure prdoclib-create-temp-prt-obj :
  define input parameter  p-root-price-sale like ub.price-list.price-sale no-undo .
  define parameter buffer buf_prt-obj       for ub.prt-obj .
  define parameter buffer buf_temp-prt-obj  for temp-prt-obj .
  define buffer buf_gds-prt for ub.gds-prt .
  do
  on error undo, return error return-value
  :
    find first buf_temp-prt-obj
      where buf_temp-prt-obj.prt-code = buf_prt-obj.prt-code
      no-error .
    if not available buf_temp-prt-obj
    then do:
      create buf_temp-prt-obj .
      assign
        buf_temp-prt-obj.prt-code         = buf_prt-obj.prt-code
        buf_temp-prt-obj.price-sale       = ?
        buf_temp-prt-obj.fact-qnty        = buf_prt-obj.fact-qnty
        buf_temp-prt-obj.price-list-qnty  = ?
        buf_temp-prt-obj.prt-obj-recid    = recid(buf_prt-obj)
        buf_temp-prt-obj.price-list-recid = ?
      .
      find first buf_gds-prt no-lock
        where buf_gds-prt.node-code = buf_temp-prt-obj.prt-code
        .
      assign
        buf_temp-prt-obj.is-term = buf_gds-prt.is-term
      .
      if buf_temp-prt-obj.is-term
      then do:
        assign
          buf_temp-prt-obj.price-sale = p-root-price-sale
        .
      end.
    end.
  end.
end procedure.
procedure prdoclib-temp-prt-obj-by-prt-root :
  define input parameter  p-prt-code like ub.prt-obj.prt-code no-undo .
  define parameter buffer buf_temp-prt-obj  for temp-prt-obj .
  define buffer buf_gds-prt for ub.gds-prt .
  do
  on error undo, return error return-value
  :
    find first buf_temp-prt-obj
      where buf_temp-prt-obj.prt-code = p-prt-code
      no-error .
    if not available buf_temp-prt-obj
    then do:
      create buf_temp-prt-obj .
      assign
        buf_temp-prt-obj.prt-code         = p-prt-code
        buf_temp-prt-obj.price-sale       = ?
        buf_temp-prt-obj.fact-qnty        = 0
        buf_temp-prt-obj.price-list-qnty  = ?
        buf_temp-prt-obj.prt-obj-recid    = ?
        buf_temp-prt-obj.price-list-recid = ?
      .
      find first buf_gds-prt no-lock
        where buf_gds-prt.node-code = buf_temp-prt-obj.prt-code
        .
      assign
        buf_temp-prt-obj.is-term = buf_gds-prt.is-term
      .
      if buf_temp-prt-obj.is-term
      then do:
        assign
          buf_temp-prt-obj.price-sale = 0
        .
      end.
    end.
  end.
end procedure.
procedure prdoclib-init-temp-prt-obj :
  define input parameter p-obj-type        like ub.prt-obj.obj-type  no-undo .
  define input parameter p-obj-code        like ub.prt-obj.obj-code  no-undo .
  define input parameter p-artic           like ub.prt-obj.artic     no-undo .
  define input parameter p-prod-type       like ub.prt-obj.prod-type no-undo .
  define input parameter p-prod-code       like ub.prt-obj.prod-code no-undo .
  define input parameter p-root-price-sale like ub.prt-obj.price-sale no-undo .
  define buffer buf_prt-obj      for ub.prt-obj .
  define buffer buf_temp-prt-obj for temp-prt-obj .
  do
  on error undo, return error return-value
  :
    run prdoclib-clear-temp-prt-obj in this-procedure .
    for each buf_prt-obj
      where buf_prt-obj.obj-type  = p-obj-type
        and buf_prt-obj.obj-code  = p-obj-code
        and buf_prt-obj.artic     = p-artic
        and buf_prt-obj.prod-type = p-prod-type
        and buf_prt-obj.prod-code = p-prod-code
    on error undo, return error return-value
    :
      run prdoclib-create-temp-prt-obj in this-procedure
        (input  p-root-price-sale
        ,buffer buf_prt-obj
        ,buffer buf_temp-prt-obj
        ).
    end.
  end.
end procedure.
procedure prdoclib-calc-fact-sale :
  define input  parameter p-price-list-recid   as recid     no-undo .
  define output parameter p-fact-qnty          as decimal   no-undo .
  define output parameter p-cur-base           as decimal   no-undo .
  define output parameter p-cur-VAT-base       as decimal   no-undo .
  define output parameter p-cur-SLT-base       as decimal   no-undo .
  define output parameter p-cur-road-tax-base  as decimal   no-undo .
  define output parameter p-cur-excise-base    as decimal   no-undo .
  define buffer buf_main_price-list for ub.price-list .
  define buffer buf_price-list      for ub.price-list .
  define buffer buf_goods           for ub.goods .
  define buffer buf_gds-obj         for ub.gds-obj .
  define buffer buf_bar-code        for ub.bar-code .
  define variable l-empty-scale   as logical   no-undo .
  do
  on error undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  )
  on stop undo, return error substitute(" stop &1 &2" , return-value , error-status :get-message(1)  )
  on end-key undo, return error substitute(" end-key &1 &2" , return-value , error-status :get-message(1)  )
  :
    find first buf_main_price-list no-lock
      where recid(buf_main_price-list) = p-price-list-recid
      no-error .
    if not available buf_main_price-list
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info12 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка переоценки" skip
        "Код записи (recid)" p-price-list-recid skip
        view-as alert-box error .
      undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  )   .
    end.
    if buf_main_price-list.main-price <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info12 skip
        "Ошибка задания входных параметров" skip
        "Строка переоценки не является основной" skip
        "Код записи (recid)" p-price-list-recid skip
        "Переоценка" buf_main_price-list.doc-num skip
        "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
        "Бар-код" buf_main_price-list.b-code skip
        view-as alert-box error .
      undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  )  .
    end.
    find first buf_goods no-lock
      where buf_goods.artic     = buf_main_price-list.artic
        and buf_goods.prod-type = buf_main_price-list.prod-type
        and buf_goods.prod-code = buf_main_price-list.prod-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info12 skip
        "Не найден товар" skip
        "Переоценка" buf_main_price-list.doc-num skip
        "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
        view-as alert-box error .
      undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
    end.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  buf_main_price-list.artic
  ,input  buf_main_price-list.prod-type
  ,input  buf_main_price-list.prod-code
  ,input  'empty-scale=request':u
  ,output l-empty-scale
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info12 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
        'empty-scale=request':u skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
    end.
    find first buf_gds-obj no-lock
      where buf_gds-obj.gds-code = buf_goods.gds-code
        and buf_gds-obj.obj-type = buf_main_price-list.obj-type
        and buf_gds-obj.obj-code = buf_main_price-list.obj-code
      no-error .
      if not available buf_gds-obj then do:
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  buf_main_price-list.obj-type
  ,input  buf_main_price-list.obj-code
  ,input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,buffer buf_gds-obj
  ) no-error .
        if error-status :error then do:
           undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
        end.
      end.
    define variable price-rubl-with-tax-sale-prl    as decimal   no-undo .
    define variable price-base-with-tax-sale-prl    as decimal   no-undo .
    define variable price-rubl-without-tax-sale-prl as decimal   no-undo .
    define variable price-base-without-tax-sale-prl as decimal   no-undo .
    define variable vat-base-sale-prl               as decimal   no-undo .
    define variable vat-rubl-sale-prl               as decimal   no-undo .
    define variable vat-base-buyer-prl              as decimal   no-undo .
    define variable vat-rubl-buyer-prl              as decimal   no-undo .
    define variable slt-base-sale-prl               as decimal   no-undo .
    define variable slt-rubl-sale-prl               as decimal   no-undo .
    define variable road-tax-base-sale-prl          as decimal   no-undo .
    define variable road-tax-rubl-sale-prl          as decimal   no-undo .
    define variable excise-base-sale-prl            as decimal   no-undo .
    define variable excise-rubl-sale-prl            as decimal   no-undo .
    define variable discnt-base-sale-prl            as decimal   no-undo .
    define variable discnt-rubl-sale-prl            as decimal   no-undo .
    if buf_main_price-list.doc-qnty <> 0
    then do:
      run prl-vat in this-procedure
        (input  recid(buf_main_price-list)
        ,output price-rubl-with-tax-sale-prl
        ,output price-base-with-tax-sale-prl
        ,output price-rubl-without-tax-sale-prl
        ,output price-base-without-tax-sale-prl
        ,output vat-base-sale-prl
        ,output vat-rubl-sale-prl
        ,output vat-base-buyer-prl
        ,output vat-rubl-buyer-prl
        ,output slt-base-sale-prl
        ,output slt-rubl-sale-prl
        ,output road-tax-base-sale-prl
        ,output road-tax-rubl-sale-prl
        ,output excise-base-sale-prl
        ,output excise-rubl-sale-prl
        ,output discnt-base-sale-prl
        ,output discnt-rubl-sale-prl
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info12 skip
          "Ошибка при вызове процеды prl-vat" skip
          "Документ" buf_main_price-list.doc-num skip
          "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
      end.
    end.
    else do:
      assign
        price-rubl-with-tax-sale-prl    = 0
        price-base-with-tax-sale-prl    = 0
        price-rubl-without-tax-sale-prl = 0
        price-base-without-tax-sale-prl = 0
        vat-base-sale-prl               = 0
        vat-rubl-sale-prl               = 0
        vat-base-buyer-prl              = 0
        vat-rubl-buyer-prl              = 0
        slt-base-sale-prl               = 0
        slt-rubl-sale-prl               = 0
        road-tax-base-sale-prl          = 0
        road-tax-rubl-sale-prl          = 0
        excise-base-sale-prl            = 0
        excise-rubl-sale-prl            = 0
        discnt-base-sale-prl            = 0
        discnt-rubl-sale-prl            = 0
      .
    end.
    define variable v-curr-r-b as character no-undo .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
    if v-curr-r-b = 'base':U
    then do:
      assign
        p-fact-qnty         = buf_main_price-list.doc-qnty
        p-cur-base          = price-base-with-tax-sale-prl * buf_main_price-list.doc-qnty
        p-cur-VAT-base      = vat-base-sale-prl * buf_main_price-list.doc-qnty
        p-cur-SLT-base      = slt-base-sale-prl * buf_main_price-list.doc-qnty
        p-cur-road-tax-base = road-tax-base-sale-prl * buf_main_price-list.doc-qnty
        p-cur-excise-base   = excise-base-sale-prl * buf_main_price-list.doc-qnty
      .
    end.
    else do:
      assign
        p-fact-qnty         = buf_main_price-list.doc-qnty
        p-cur-base          = price-rubl-with-tax-sale-prl * buf_main_price-list.doc-qnty
        p-cur-VAT-base      = vat-rubl-sale-prl * buf_main_price-list.doc-qnty
        p-cur-SLT-base      = slt-rubl-sale-prl * buf_main_price-list.doc-qnty
        p-cur-road-tax-base = road-tax-rubl-sale-prl * buf_main_price-list.doc-qnty
        p-cur-excise-base   = excise-rubl-sale-prl * buf_main_price-list.doc-qnty
      .
    end.
      define variable v-unit-base like ub.goods.unit-base no-undo .
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run unitbase in g#library
  (input  buf_goods.gds-code
  ,output v-unit-base
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info12 skip
          "Ошибка при определении базовой единицы измерения товара" skip
          "Код товара" buf_goods.gds-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
      end.
      for each buf_price-list no-lock
        where buf_price-list.doc-num    = buf_main_price-list.doc-num
          and buf_price-list.main-price = false
          and buf_price-list.artic      = buf_main_price-list.artic
          and buf_price-list.prod-type  = buf_main_price-list.prod-type
          and buf_price-list.prod-code  = buf_main_price-list.prod-code
      :
        if buf_price-list.doc-qnty = ?
        then do:
          find first buf_bar-code no-lock
            where buf_bar-code.b-code = buf_price-list.b-code
            no-error .
          if available buf_bar-code
          and buf_bar-code.unit-cli = v-unit-base
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info12 skip
              "Ошибка при закрытии переоценки" skip
              "Не задано количество для бар-кода с основной единицей измерения" skip
              "Переоценка" buf_main_price-list.doc-num skip
              "Бар-код" buf_price-list.b-code skip
              "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
              "Количество" buf_price-list.doc-qnty skip
              "Основная единица измерения" v-unit-base skip
              "Единица измерения бар-кода" buf_bar-code.unit-cli skip
              view-as alert-box error .
            undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
          end.
          next .
        end.
        if not can-find
          (first buf_bar-code
          where buf_bar-code.b-code = buf_price-list.b-code
          )
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info12 skip
            "В переоценке задан несуществующий бар-код" skip
            "Переоценка" buf_price-list.doc-num skip
            "Артикул" buf_price-list.artic buf_price-list.prod-type buf_price-list.prod-code skip
            "Бар-код" buf_price-list.b-code skip
            view-as alert-box error .
          undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
        end.
        if buf_price-list.doc-qnty <> 0
        then do:
          run prl-vat in this-procedure
            (input  recid(buf_price-list)
            ,output price-rubl-with-tax-sale-prl
            ,output price-base-with-tax-sale-prl
            ,output price-rubl-without-tax-sale-prl
            ,output price-base-without-tax-sale-prl
            ,output vat-base-sale-prl
            ,output vat-rubl-sale-prl
            ,output vat-base-buyer-prl
            ,output vat-rubl-buyer-prl
            ,output slt-base-sale-prl
            ,output slt-rubl-sale-prl
            ,output road-tax-base-sale-prl
            ,output road-tax-rubl-sale-prl
            ,output excise-base-sale-prl
            ,output excise-rubl-sale-prl
            ,output discnt-base-sale-prl
            ,output discnt-rubl-sale-prl
            ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info12 skip
              "Ошибка при вызове процеды prl-vat" skip
              "Документ" buf_price-list.doc-num skip
              "Артикул" buf_price-list.artic buf_price-list.prod-type buf_price-list.prod-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
          end.
        end.
        else do:
          assign
            price-rubl-with-tax-sale-prl    = 0
            price-base-with-tax-sale-prl    = 0
            price-rubl-without-tax-sale-prl = 0
            price-base-without-tax-sale-prl = 0
            vat-base-sale-prl               = 0
            vat-rubl-sale-prl               = 0
            vat-base-buyer-prl              = 0
            vat-rubl-buyer-prl              = 0
            slt-base-sale-prl               = 0
            slt-rubl-sale-prl               = 0
            road-tax-base-sale-prl          = 0
            road-tax-rubl-sale-prl          = 0
            excise-base-sale-prl            = 0
            excise-rubl-sale-prl            = 0
            discnt-base-sale-prl            = 0
            discnt-rubl-sale-prl            = 0
          .
        end.
        if v-curr-r-b = 'base':U
        then do:
          assign
            p-fact-qnty         = p-fact-qnty
                                + buf_price-list.doc-qnty
            p-cur-base          = p-cur-base
                                + price-base-with-tax-sale-prl * buf_price-list.doc-qnty
            p-cur-VAT-base      = p-cur-VAT-base
                                + vat-base-sale-prl * buf_price-list.doc-qnty
            p-cur-SLT-base      = p-cur-SLT-base
                                + slt-base-sale-prl * buf_price-list.doc-qnty
            p-cur-road-tax-base = p-cur-road-tax-base
                                + road-tax-base-sale-prl * buf_price-list.doc-qnty
            p-cur-excise-base   = p-cur-excise-base
                                + excise-base-sale-prl * buf_price-list.doc-qnty
          .
        end.
        else do:
          assign
            p-fact-qnty         = p-fact-qnty
                                + buf_price-list.doc-qnty
            p-cur-base          = p-cur-base
                                + price-rubl-with-tax-sale-prl * buf_price-list.doc-qnty
            p-cur-VAT-base      = p-cur-VAT-base
                                + vat-rubl-sale-prl * buf_price-list.doc-qnty
            p-cur-SLT-base      = p-cur-SLT-base
                                + slt-rubl-sale-prl * buf_price-list.doc-qnty
            p-cur-road-tax-base = p-cur-road-tax-base
                                + road-tax-rubl-sale-prl * buf_price-list.doc-qnty
            p-cur-excise-base   = p-cur-excise-base
                                + excise-rubl-sale-prl * buf_price-list.doc-qnty
          .
        end.
      end.
  end.
end procedure.
procedure prdoclib-calc-prc :
  define input  parameter p-price-doc-recid as   recid                  no-undo.
  define input  parameter p-cons-pay        as   integer                no-undo.
  define output parameter p-ov-cons         like ub.doc-line.price-base no-undo.
  define output parameter p-ov-VAT-cons     like ub.doc-line.price-base no-undo.
  define output parameter p-ov-SLT-cons     like ub.doc-line.price-base no-undo.
  define output parameter p-ov-prch         like ub.doc-line.price-base no-undo.
  define output parameter p-ov-VAT-prch     like ub.doc-line.price-base no-undo.
  define output parameter p-ov-SLT-prch     like ub.doc-line.price-base no-undo.
  do
  on error undo, return error return-value
  :
    define buffer buf_price-doc       for ub.price-doc .
    define buffer buf_price-list      for ub.price-list .
    define buffer buf_parts           for ub.parts .
    define variable v-ov-qnty     as decimal   no-undo .
    define variable v-ov-base     as decimal   no-undo .
    define variable v-ov-VAT-base as decimal   no-undo .
    define variable v-ov-SLT-base as decimal   no-undo .
    define variable v-cons-qnty   as decimal   no-undo .
    define variable v-prch-qnty   as decimal   no-undo .
    define variable v-cons-mult   as decimal   no-undo .
    define variable v-prch-mult   as decimal   no-undo .
    find first buf_price-doc no-lock
      where recid(buf_price-doc) = p-price-doc-recid
      no-error .
    if not available buf_price-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info12 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ переоценки" skip
        "Код записи (recid)" p-price-doc-recid skip
        view-as alert-box error .
      undo, return error .
    end.
    for each buf_price-list no-lock
      where buf_price-list.doc-num    = buf_price-doc.doc-num
        and buf_price-list.main-price = true
    on error undo, return error return-value
    :
      run prdoclib-calc-ov
        (input recid(buf_price-list)
        ,output v-ov-qnty
        ,output v-ov-base
        ,output v-ov-VAT-base
        ,output v-ov-SLT-base
        ) no-error .
      if error-status :error
      then do:
        if error-status :get-message(1) <> ""
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info12 skip
            "Ошибка при вызове процедуры prdoclib-calc-ov" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        end.
        undo, return error return-value .
      end.
      assign
        v-cons-qnty = 0
        v-prch-qnty = 0
      .
      for each buf_parts no-lock
        where buf_parts.out-code  = buf_price-list.doc-num
          and buf_parts.obj-type  = buf_price-list.obj-type
          and buf_parts.obj-code  = buf_price-list.obj-code
          and buf_parts.artic     = buf_price-list.artic
          and buf_parts.prod-type = buf_price-list.prod-type
          and buf_parts.prod-code = buf_price-list.prod-code
      on error undo, return error return-value
      :
        if buf_parts.pay-code = p-cons-pay
        then do:
          assign
            v-cons-qnty = v-cons-qnty + buf_parts.fact-qnty
          .
        end.
        else do:
          assign
            v-prch-qnty = v-prch-qnty + buf_parts.fact-qnty
          .
        end.
      end.
      if (v-cons-qnty + v-prch-qnty) = 0
      then do:
        assign
          v-cons-mult = 0
          v-prch-mult = 1
        .
      end.
      else do:
        assign
          v-cons-mult = v-cons-qnty / (v-cons-qnty + v-prch-qnty)
          v-prch-mult = v-prch-qnty / (v-cons-qnty + v-prch-qnty)
        .
      end.
      assign
        p-ov-cons     = p-ov-cons     + v-ov-base     * v-cons-mult
        p-ov-VAT-cons = p-ov-VAT-cons + v-ov-VAT-base * v-cons-mult
        p-ov-SLT-cons = p-ov-SLT-cons + v-ov-SLT-base * v-cons-mult
        p-ov-prch     = p-ov-prch     + v-ov-base     * v-prch-mult
        p-ov-VAT-prch = p-ov-VAT-prch + v-ov-VAT-base * v-prch-mult
        p-ov-SLT-prch = p-ov-SLT-prch + v-ov-SLT-base * v-prch-mult
      .
    end.
  end.
end procedure.
procedure prdoclib-calc-ov :
  define input  parameter p-price-list-recid as recid     no-undo .
  define output parameter p-fact-qnty        as decimal   no-undo .
  define output parameter p-ov-base          as decimal   no-undo .
  define output parameter p-ov-VAT-base      as decimal   no-undo .
  define output parameter p-ov-SLT-base      as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    define buffer buf_main_price-list    for ub.price-list .
    define buffer buf_prev_price-list    for ub.price-list .
    define buffer buf_special_price-list for ub.price-list .
    define buffer buf_goods              for ub.goods .
    define variable v-fact-qnty             like ub.doc-line.price-base no-undo.
    define variable v-cur-base              like ub.doc-line.price-base no-undo.
    define variable v-cur-VAT-base          like ub.doc-line.price-base no-undo.
    define variable v-cur-SLT-base          like ub.doc-line.price-base no-undo.
    define variable v-cur-road-tax-base     like ub.doc-line.price-base no-undo.
    define variable v-cur-excise-base       like ub.doc-line.price-base no-undo.
    define variable v-prev-price-list-recid as   recid                  no-undo.
    define variable v-prev-cli-base-rate    like ub.goods.cli-base-rate no-undo.
    define variable v-prev-fact-qnty        like ub.doc-line.price-base no-undo.
    define variable v-prev-cur-base         like ub.doc-line.price-base no-undo.
    define variable v-prev-cur-VAT-base     like ub.doc-line.price-base no-undo.
    define variable v-prev-cur-SLT-base     like ub.doc-line.price-base no-undo.
    find first buf_main_price-list no-lock
      where recid(buf_main_price-list) = p-price-list-recid
      no-error .
    if not available buf_main_price-list
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info12 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка переоценки" skip
        "Код записи (recid)" p-price-list-recid skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_main_price-list.main-price <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info12 skip
        "Ошибка задания входных параметров" skip
        "Строка переоценки не является основной" skip
        "Код записи (recid)" p-price-list-recid skip
        "Переоценка" buf_main_price-list.doc-num skip
        "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
        "Бар-код" buf_main_price-list.b-code skip
        view-as alert-box error .
      undo, return error .
    end.
    run prdoclib-calc-fact-sale in this-procedure
      (input  recid(buf_main_price-list)
      ,output v-fact-qnty
      ,output v-cur-base
      ,output v-cur-VAT-base
      ,output v-cur-SLT-base
      ,output v-cur-road-tax-base
      ,output v-cur-excise-base
      ) no-error.
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info12 skip
        "Ошибка при расчете сумм переоценки." skip
        "Документ переоценки" buf_main_price-list.doc-num skip
        "Товар" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodepls in g#library
  (input  buf_main_price-list.obj-type
  ,input  buf_main_price-list.obj-code
  ,input  buf_main_price-list.b-code
  ,input  buf_main_price-list.b-code
  ,input  buf_main_price-list.fact-order
  ,output v-prev-price-list-recid
  ,output v-prev-cli-base-rate
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info12 skip
        "Ошибка при поиске предыдущей переоценки." skip
        "Документ переоценки " buf_main_price-list.doc-num skip
        "Товар " buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if v-prev-price-list-recid <> ?
    then do:
      find first buf_prev_price-list no-lock
        where recid(buf_prev_price-list) = v-prev-price-list-recid
        .
      find first buf_special_price-list no-lock
        where buf_special_price-list.doc-num    = buf_prev_price-list.doc-num
          and buf_special_price-list.main-price = false
          and buf_special_price-list.artic      = buf_prev_price-list.artic
          and buf_special_price-list.prod-type  = buf_prev_price-list.prod-type
          and buf_special_price-list.prod-code  = buf_prev_price-list.prod-code
          and buf_special_price-list.doc-qnty   <> ?
        no-error .
      if available buf_special_price-list
      then do:
        message
          "Товар имеет специальные цены на признаки" skip
          "Разбиение суммы переоценки по консигнации, выкупу невозможно" skip
          "Переоценка" buf_prev_price-list.doc-num skip
          "Товар" buf_prev_price-list.artic buf_prev_price-list.prod-type buf_prev_price-list.prod-code skip
          view-as alert-box error .
        undo, return error .
      end.
      find first buf_goods no-lock
        where buf_goods.artic     = buf_main_price-list.artic
          and buf_goods.prod-type = buf_main_price-list.prod-type
          and buf_goods.prod-code = buf_main_price-list.prod-code
        no-error .
      if not available buf_goods
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info12 skip
          "Не найден товар" skip
          "Переоценка" buf_main_price-list.doc-num skip
          "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
          view-as alert-box error .
        undo, return error .
      end.
      if buf_prev_price-list.vat-pc = ?
      or buf_prev_price-list.slt-pc = ?
      then do:
        message
          "В переоценке не заданы налоги товара" skip
          "Разбиение суммы переоценки по консигнации, выкупу невозможно" skip
          "Переоценка" buf_prev_price-list.doc-num skip
          "Товар" buf_prev_price-list.artic buf_prev_price-list.prod-type buf_prev_price-list.prod-code skip
          "НДС" buf_prev_price-list.vat-pc skip
          "НП" buf_prev_price-list.slt-pc skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      define variable v-prev-cur-SLT-pc as decimal no-undo .
      assign
        v-prev-cur-SLT-pc   = buf_prev_price-list.price-sale * buf_prev_price-list.slt-pc / (100 + buf_prev_price-list.slt-pc)
      .
      assign
        v-prev-cur-base     = v-fact-qnty * buf_prev_price-list.price-sale
        v-prev-cur-VAT-base = v-fact-qnty
                            * (buf_prev_price-list.price-sale - v-prev-cur-SLT-pc)
                            * buf_prev_price-list.vat-pc / (100 + buf_prev_price-list.vat-pc)
        v-prev-cur-SLT-base = v-fact-qnty * v-prev-cur-SLT-pc
      .
      assign
        p-fact-qnty   = v-fact-qnty
        p-ov-base     = v-cur-base     - v-prev-cur-base
        p-ov-VAT-base = v-cur-VAT-base - v-prev-cur-VAT-base
        p-ov-SLT-base = v-cur-SLT-base - v-prev-cur-SLT-base
      .
    end.
    else do:
      assign
        v-prev-cur-base     = 0
        v-prev-cur-VAT-base = 0
        v-prev-cur-SLT-base = 0
        .
      assign
        p-fact-qnty   = v-fact-qnty
        p-ov-base     = v-cur-base     - v-prev-cur-base
        p-ov-VAT-base = v-cur-VAT-base - v-prev-cur-VAT-base
        p-ov-SLT-base = v-cur-SLT-base - v-prev-cur-SLT-base
      .
    end.
  end.
end procedure.
procedure prdoclib-init-prt-obj-by-factord :
  define input parameter p-obj-type           like ub.gds-obj.obj-type  no-undo .
  define input parameter p-obj-code           like ub.gds-obj.obj-code  no-undo .
  define input parameter p-artic              like ub.gds-obj.artic     no-undo .
  define input parameter p-prod-type          like ub.gds-obj.prod-type no-undo .
  define input parameter p-prod-code          like ub.gds-obj.prod-code no-undo .
  define input parameter p-fact-order         as decimal   no-undo .
  define input parameter p-include-fact-order as logical   no-undo .
  define variable vss-description as character no-undo init "prdoclib-init-prt-obj-by-factord: определение остатков по признакам на любой момент времени".
  define buffer buf_gds-obj      for ub.gds-obj .
  define buffer buf_doc-line     for ub.doc-line .
  define buffer buf_temp-prt-obj for temp-prt-obj .
  define variable v-total-gds-dtl-qnty as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    do transaction
    on error undo, return error return-value
    :
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info12 skip
          "Невозможно найти gds-obj" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      find current buf_gds-obj exclusive-lock .
    end.
    run prdoclib-init-temp-prt-obj in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input 0
      ) .
    for each buf_temp-prt-obj
      where buf_temp-prt-obj.is-term <> true
    on error undo, return error return-value
    :
      delete buf_temp-prt-obj .
    end.
    if p-include-fact-order = true
    then do:
      assign
       p-fact-order = p-fact-order - 0.0000000001
      .
    end.
    for each buf_doc-line no-lock
      where buf_doc-line.obj-type   = p-obj-type
        and buf_doc-line.obj-code   = p-obj-code
        and buf_doc-line.artic      = p-artic
        and buf_doc-line.prod-type  = p-prod-type
        and buf_doc-line.prod-code  = p-prod-code
        and buf_doc-line.status_    = 'факт':U
        and buf_doc-line.fact-order >= p-fact-order
    on error undo, return error return-value
    :
      run prdoclib-process-document in this-procedure
        (input  buf_doc-line.doc-code
        ,input  p-obj-type
        ,input  p-obj-code
        ,input  p-artic
        ,input  p-prod-type
        ,input  p-prod-code
        ,output v-total-gds-dtl-qnty
        ) .
    end.
  end.
end procedure.
procedure prdoclib-process-document :
  define input  parameter p-doc-code           as character no-undo .
  define input  parameter p-obj-type           as character no-undo .
  define input  parameter p-obj-code           as integer   no-undo .
  define input  parameter p-artic              as character no-undo .
  define input  parameter p-prod-type          as character no-undo .
  define input  parameter p-prod-code          as integer   no-undo .
  define output parameter p-total-gds-dtl-qnty as decimal   no-undo .
  define buffer buf_trn-doc      for ub.trn-doc .
  define buffer buf_gds-dtl      for ub.gds-dtl .
  define buffer buf_temp-prt-obj for temp-prt-obj .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info12 skip
        "Ошибка при поиске документа" skip
        "Документ" p-doc-code skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      p-total-gds-dtl-qnty = 0
    .
    for each buf_gds-dtl no-lock
      where buf_gds-dtl.doc-code  = p-doc-code
        and buf_gds-dtl.artic     = p-artic
        and buf_gds-dtl.prod-type = p-prod-type
        and buf_gds-dtl.prod-code = p-prod-code
    on error undo, return error
    :
      define variable v-term-node as integer   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run termnode in g#library
  (input  buf_gds-dtl.prt-code
  ,output v-term-node
  )  .
      run prdoclib-temp-prt-obj-by-prt-root in this-procedure
        (input  v-term-node
        ,buffer buf_temp-prt-obj
        ) .
      if buf_temp-prt-obj.is-term <> true then do:
        undo, return error substitute("Документ ссылается на нетерминальный признак. Код признака &1"
                                     ,buf_gds-dtl.prt-code
                                     ) .
      end.
      case buf_trn-doc.doc-type :
        when 'при':U or
        when 'возврат':U
        then do:
          assign
            p-total-gds-dtl-qnty        = p-total-gds-dtl-qnty
                                        - buf_gds-dtl.fact-qnty
            buf_temp-prt-obj.fact-qnty  = buf_temp-prt-obj.fact-qnty
                                        - buf_gds-dtl.fact-qnty
          .
        end.
        when 'рас':U or
        when 'спи':U
        then do:
          assign
            p-total-gds-dtl-qnty        = p-total-gds-dtl-qnty
                                        + buf_gds-dtl.fact-qnty
            buf_temp-prt-obj.fact-qnty  = buf_temp-prt-obj.fact-qnty
                                        + buf_gds-dtl.fact-qnty
          .
        end.
        when 'инв':U
        then do:
          assign
            p-total-gds-dtl-qnty        = p-total-gds-dtl-qnty
                                        - buf_gds-dtl.doc-qnty
            buf_temp-prt-obj.fact-qnty  = buf_temp-prt-obj.fact-qnty
                                        - buf_gds-dtl.doc-qnty
          .
        end.
        otherwise do:
          undo, return error substitute("Неизвестный тип документа &1"
                                       ,buf_trn-doc.doc-type
                                       ) .
        end.
      end.
    end.
  end.
end procedure.
procedure prdoclib-prc-pl-document :
  define input  parameter p-doc-code              as character no-undo .
  define input  parameter p-obj-type              as character no-undo .
  define input  parameter p-obj-code              as integer   no-undo .
  define input  parameter p-gds-code              as integer   no-undo .
  define output parameter p-total-pl-gds-qnty     as decimal   no-undo .
  define output parameter p-total-pl-gds-cli-qnty as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    define buffer buf_trn-doc      for ub.trn-doc .
    define buffer buf_doc-pl       for ub.doc-pl .
    define buffer buf_temp-pl-gds for temp-pl-gds .
    define variable v-sign as decimal   no-undo .
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info12 skip
        "Ошибка при поиске документа" skip
        "Документ" p-doc-code skip
        "Объект" p-obj-type p-obj-code skip
        "Товар" p-gds-code skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      p-total-pl-gds-qnty     = 0
      p-total-pl-gds-cli-qnty = 0
    .
    for each buf_doc-pl no-lock
      where buf_doc-pl.out-code  = p-doc-code
        and buf_doc-pl.gds-code  = p-gds-code
    on error undo, return error return-value
    :
      find first buf_temp-pl-gds
        where buf_temp-pl-gds.obj-type = buf_trn-doc.obj-type
          and buf_temp-pl-gds.obj-code = buf_trn-doc.obj-code
          and buf_temp-pl-gds.pl-code  = buf_doc-pl.pl-code
        .
      case buf_trn-doc.doc-type :
        when 'при':U
        or when 'возврат':U
        or when 'инв':U
        then do:
          assign
            v-sign = -1.0
          .
        end.
        when 'рас':U or
        when 'спи':U
        then do:
          assign
            v-sign = 1.0
          .
        end.
        otherwise do:
          undo, return error substitute("(prdoclib-prc-pl-document) Неизвестный тип документа &1", buf_trn-doc.doc-type ) .
        end.
      end case.
      assign
        p-total-pl-gds-qnty           = p-total-pl-gds-qnty           + buf_doc-pl.fact-qnty     * v-sign
        p-total-pl-gds-cli-qnty       = p-total-pl-gds-cli-qnty       + buf_doc-pl.cli-fact-qnty * v-sign
        buf_temp-pl-gds.fact-qnty     = buf_temp-pl-gds.fact-qnty     + buf_doc-pl.fact-qnty     * v-sign
        buf_temp-pl-gds.cli-fact-qnty = buf_temp-pl-gds.cli-fact-qnty + buf_doc-pl.cli-fact-qnty * v-sign
      .
    end.
  end.
end procedure.
procedure prdoclib-init-prt-obj-by-date :
  define input parameter p-obj-type   like ub.gds-obj.obj-type  no-undo .
  define input parameter p-obj-code   like ub.gds-obj.obj-code  no-undo .
  define input parameter p-artic      like ub.gds-obj.artic     no-undo .
  define input parameter p-prod-type  like ub.gds-obj.prod-type no-undo .
  define input parameter p-prod-code  like ub.gds-obj.prod-code no-undo .
  define input parameter p-fact-date  as date      no-undo .
  define variable vss-description as character no-undo init "prdoclib-init-prt-obj-by-date: определение остатков по признакам на конец дня".
  do
  on error undo, return error return-value
  :
    define variable v-fact-order                as decimal   no-undo .
    define variable v-shift-end-fact-order      as decimal   no-undo .
    define variable v-day-end-fact-order        as decimal   no-undo .
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  ?
      ,input  0
      ,input  false
      ,output v-fact-order
      ,output v-shift-end-fact-order
      ,output v-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info12 skip
        "Ошибка при определении момента времени, на который требуется остаток" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.
    run prdoclib-init-prt-obj-by-date-factord in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input v-day-end-fact-order
      ,input false
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info12 skip
        "Ошибка при вызове метода prdoclib-init-prt-obj-by-date-factord" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure prdoclib-calc-temp-fact-sale :
  define input  parameter p-obj-type           as character no-undo .
  define input  parameter p-obj-code           as integer   no-undo .
  define input  parameter p-gds-code           as integer   no-undo .
  define input  parameter p-day-end-fact-order as decimal   no-undo .
  define input  parameter p-curr-r-b           as character no-undo .
  define output parameter p-fact-qnty          as decimal   no-undo .
  define output parameter p-cur-base           as decimal   no-undo .
  define output parameter p-cur-VAT-base       as decimal   no-undo .
  define output parameter p-cur-SLT-base       as decimal   no-undo .
  define output parameter p-cur-road-tax-base  as decimal   no-undo .
  define output parameter p-cur-excise-base    as decimal   no-undo .
  define buffer buf_temp-prt-obj for temp-prt-obj .
  define variable v-prt-b-code        like ub.bar-code.b-code no-undo .
  define variable v-cli-base-rate     like ub.bar-code.cli-base-rate no-undo .
  define variable parrecid-prl        as recid     no-undo .
  define variable v-fact-qnty         as decimal   no-undo .
  define variable v-cur-base          as decimal   no-undo .
  define variable v-cur-VAT-base      as decimal   no-undo .
  define variable v-cur-SLT-base      as decimal   no-undo .
  define variable v-cur-road-tax-base as decimal   no-undo .
  define variable v-cur-excise-base   as decimal   no-undo .
  define variable price-rubl-with-tax-sale-prl    as decimal   no-undo .
  define variable price-base-with-tax-sale-prl    as decimal   no-undo .
  define variable price-rubl-without-tax-sale-prl as decimal   no-undo .
  define variable price-base-without-tax-sale-prl as decimal   no-undo .
  define variable vat-base-sale-prl               as decimal   no-undo .
  define variable vat-rubl-sale-prl               as decimal   no-undo .
  define variable vat-base-buyer-prl              as decimal   no-undo .
  define variable vat-rubl-buyer-prl              as decimal   no-undo .
  define variable slt-base-sale-prl               as decimal   no-undo .
  define variable slt-rubl-sale-prl               as decimal   no-undo .
  define variable road-tax-base-sale-prl          as decimal   no-undo .
  define variable road-tax-rubl-sale-prl          as decimal   no-undo .
  define variable excise-base-sale-prl            as decimal   no-undo .
  define variable excise-rubl-sale-prl            as decimal   no-undo .
  define variable discnt-base-sale-prl            as decimal   no-undo .
  define variable discnt-rubl-sale-prl            as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    for each buf_temp-prt-obj no-lock
    on error undo, return error return-value
    :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  p-gds-code
  ,input  buf_temp-prt-obj.prt-code
  ,output v-prt-b-code
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении бар-кода признака" skip
          "Код товара"   p-gds-code skip
          "Код признака" buf_temp-prt-obj.prt-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodepls in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  v-prt-b-code
  ,input  0
  ,input  p-day-end-fact-order
  ,output parrecid-prl
  ,output v-cli-base-rate
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении цены бар-кода" skip
          "Объект" p-obj-type p-obj-code skip
          "Бар-код" v-prt-b-code skip
          "fact-order" p-day-end-fact-order skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      if parrecid-prl <> ?
      then do:
        run prl-vat in this-procedure
          (input  parrecid-prl
          ,output price-rubl-with-tax-sale-prl
          ,output price-base-with-tax-sale-prl
          ,output price-rubl-without-tax-sale-prl
          ,output price-base-without-tax-sale-prl
          ,output vat-base-sale-prl
          ,output vat-rubl-sale-prl
          ,output vat-base-buyer-prl
          ,output vat-rubl-buyer-prl
          ,output slt-base-sale-prl
          ,output slt-rubl-sale-prl
          ,output road-tax-base-sale-prl
          ,output road-tax-rubl-sale-prl
          ,output excise-base-sale-prl
          ,output excise-rubl-sale-prl
          ,output discnt-base-sale-prl
          ,output discnt-rubl-sale-prl
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процеды prl-vat" skip
            "Объект" p-obj-type p-obj-code skip
            "Код товара" p-gds-code skip
            "Указатель на запись переоценки" parrecid-prl skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
      else do:
        assign
          price-rubl-with-tax-sale-prl    = 0
          price-base-with-tax-sale-prl    = 0
          price-rubl-without-tax-sale-prl = 0
          price-base-without-tax-sale-prl = 0
          vat-base-sale-prl               = 0
          vat-rubl-sale-prl               = 0
          slt-base-sale-prl               = 0
          slt-rubl-sale-prl               = 0
          road-tax-base-sale-prl          = 0
          road-tax-rubl-sale-prl          = 0
          excise-base-sale-prl            = 0
          excise-rubl-sale-prl            = 0
          discnt-base-sale-prl            = 0
          discnt-rubl-sale-prl            = 0
        .
      end.
      assign
        v-fact-qnty         = v-fact-qnty
                            + buf_temp-prt-obj.fact-qnty
        v-cur-base          = v-cur-base
                            + (if p-curr-r-b = 'base':U
                                then price-base-with-tax-sale-prl
                                else price-rubl-with-tax-sale-prl
                              )
                            * buf_temp-prt-obj.fact-qnty
        v-cur-VAT-base      = v-cur-VAT-base
                            + (if p-curr-r-b = 'base':U
                                then vat-base-sale-prl
                                else vat-rubl-sale-prl
                              )
                            * buf_temp-prt-obj.fact-qnty
        v-cur-SLT-base      = v-cur-SLT-base
                            + (if p-curr-r-b = 'base':U
                                then slt-base-sale-prl
                                else slt-rubl-sale-prl
                              )
                            * buf_temp-prt-obj.fact-qnty
        v-cur-road-tax-base = v-cur-road-tax-base
                            + (if p-curr-r-b = 'base':U
                                then road-tax-base-sale-prl
                                else road-tax-rubl-sale-prl
                              )
                            * buf_temp-prt-obj.fact-qnty
        v-cur-excise-base   = v-cur-excise-base
                            + (if p-curr-r-b = 'base':U
                                then excise-base-sale-prl
                                else excise-rubl-sale-prl
                              )
                            * buf_temp-prt-obj.fact-qnty
      .
    end.
    assign
      p-fact-qnty         = v-fact-qnty
      p-cur-base          = v-cur-base
      p-cur-VAT-base      = v-cur-VAT-base
      p-cur-SLT-base      = v-cur-SLT-base
      p-cur-road-tax-base = v-cur-road-tax-base
      p-cur-excise-base   = v-cur-excise-base
    .
  end.
end procedure.
procedure prdoclib-clear-temp-pl-gds :
  define buffer buf_temp-pl-gds for temp-pl-gds .
  do
  on error undo, return error return-value
  :
    for each buf_temp-pl-gds
    on error undo, return error return-value
    :
      delete buf_temp-pl-gds .
    end.
  end.
end procedure.
procedure prdoclib-init-temp-pl-gds :
  define input parameter p-obj-type        like ub.pl-gds.obj-type  no-undo .
  define input parameter p-obj-code        like ub.pl-gds.obj-code  no-undo .
  define input parameter p-gds-code        like ub.pl-gds.gds-code  no-undo .
  define buffer buf_pl-gds      for ub.pl-gds .
  define buffer buf_temp-pl-gds for temp-pl-gds .
  do
  on error undo, return error return-value
  :
    run prdoclib-clear-temp-pl-gds in this-procedure .
    for each buf_pl-gds
      where buf_pl-gds.obj-type = p-obj-type
        and buf_pl-gds.obj-code = p-obj-code
        and buf_pl-gds.gds-code = p-gds-code
    on error undo, return error return-value
    :
      create buf_temp-pl-gds .
      buffer-copy buf_pl-gds to buf_temp-pl-gds .
    end.
  end.
end procedure.
procedure prdoclib-init-pl-gds-by-factord :
  define input parameter p-obj-type           like ub.gds-obj.obj-type  no-undo .
  define input parameter p-obj-code           like ub.gds-obj.obj-code  no-undo .
  define input parameter p-artic              like ub.gds-obj.artic     no-undo .
  define input parameter p-prod-type          like ub.gds-obj.prod-type no-undo .
  define input parameter p-prod-code          like ub.gds-obj.prod-code no-undo .
  define input parameter p-fact-order         as decimal   no-undo .
  define input parameter p-include-fact-order as logical   no-undo .
  define variable vss-description as character no-undo init "prdoclib-init-pl-gds-by-factord: определение остатков по признакам на любой момент времени".
  define buffer buf_goods       for ub.goods .
  define buffer buf_gds-obj     for ub.gds-obj .
  define buffer buf_doc-line    for ub.doc-line .
  define buffer buf_temp-pl-gds for temp-pl-gds .
  define variable v-total-pl-gds-qnty     as decimal   no-undo .
  define variable v-total-pl-gds-cli-qnty as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    do transaction
    on error undo, return error return-value
    :
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info12 skip
          "Невозможно найти gds-obj" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find current buf_gds-obj exclusive-lock .
    end.
    find first buf_goods no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code
      .
    run prdoclib-init-temp-pl-gds in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input buf_goods.gds-code
      ) .
    if p-include-fact-order = true
    then do:
      assign
       p-fact-order = p-fact-order - 0.0000000001
      .
    end.
    for each buf_doc-line no-lock
      where buf_doc-line.obj-type   = p-obj-type
        and buf_doc-line.obj-code   = p-obj-code
        and buf_doc-line.artic      = p-artic
        and buf_doc-line.prod-type  = p-prod-type
        and buf_doc-line.prod-code  = p-prod-code
        and buf_doc-line.status_    = 'факт':U
        and buf_doc-line.fact-order >= p-fact-order
    on error undo, return error return-value
    :
      run prdoclib-prc-pl-document in this-procedure
        ( input  buf_doc-line.doc-code
         ,input  p-obj-type
         ,input  p-obj-code
         ,input  buf_goods.gds-code
         ,output v-total-pl-gds-qnty
         ,output v-total-pl-gds-cli-qnty
        ) .
    end.
  end.
end procedure.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION determined RETURNS DECIMAL (INPUT parundefine-var AS DECIMAL):
   IF parundefine-var = ? THEN RETURN 0.00.
                          ELSE RETURN parundefine-var.
END FUNCTION.
FUNCTION dtm-char RETURNS CHARACTER (INPUT p-undef-char AS CHARACTER):
   IF p-undef-char = ? THEN do:
     RETURN "?".
   end.
   ELSE do:
     RETURN p-undef-char .
   end.
END FUNCTION.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure factord :
  define input  parameter p-fact-date            as date    no-undo .
  define input  parameter p-fact-time            as integer no-undo .
  define input  parameter p-fact-num             as integer no-undo .
  define input  parameter p-shift-date           as date    no-undo .
  define input  parameter p-shift-num            as integer no-undo .
  define input  parameter p-shift-on             as logical no-undo .
  define output parameter p-fact-order           as decimal no-undo .
  define output parameter p-shift-end-fact-order as decimal no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  define variable vss-description as character no-undo init "factord: Определение порядкового номера документа".
  if p-fact-date = ?
  then do:
    return error "Не указана фактическая дата" .
  end.
  define variable v-fact-date-num as integer no-undo .
  assign
    v-fact-date-num = integer(p-fact-date)
  .
  if p-fact-num = ?
  or p-fact-num = 0
  then do:
    return error "Не задан p-fact-num " + string(p-fact-num) .
  end.
  if p-fact-num < 0
  then do:
    return error "Отрицательный fact-num " + string(p-fact-num) .
  end.
  if p-fact-num >= 100000000
  then do:
    return error "Недопустимо большой fact-num " + string(p-fact-num) .
  end.
  if p-shift-on = true
  then do:
    if p-shift-date = ?
    then do:
      return error "Не задана дата смены" .
    end.
    if p-shift-num = ?
    or p-shift-num = 0
    then do:
      return error "Не задан номер смены" .
    end.
  end.
  else do:
    assign
      p-shift-date = p-fact-date
      p-shift-num  = 24
    .
  end.
  define variable v-shift-offset as integer no-undo .
  if p-shift-date = p-fact-date
  then do:
    assign
      v-shift-offset = 1
    .
  end.
  if p-shift-date < p-fact-date
  then do:
    assign
      v-shift-offset = 0
    .
  end.
  if p-shift-date > p-fact-date
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная дата закрытия смены" skip
      "Дата закрытия не смены не может быть раньше чем дата открытия смены" skip
      view-as alert-box error .
    undo, return error
      substitute("Дата закрытия не смены &1 не может быть раньше чем дата открытия смены &2"
        ,string(p-fact-date, '99/99/9999':U)
        ,string(p-shift-date, '99/99/9999':U)
        )
    .
  end.
  if p-shift-num < 1
  or p-shift-num > 24
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер смены" skip
      "p-shift-num" p-shift-num skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    p-fact-order           = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02 - 0.01
                           + p-fact-num     * 0.0000000001
    p-shift-end-fact-order = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02
    p-day-end-fact-order   = v-fact-date-num
                           + 0.99
  .
  if p-fact-order           <= v-fact-date-num
  or p-shift-end-fact-order <= v-fact-date-num
  or p-fact-order           >= p-shift-end-fact-order - 0.0000000001
  or p-shift-end-fact-order >= p-day-end-fact-order
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при генерации фактического номера" skip
      "p-fact-date"            p-fact-date            skip
      "p-fact-time"            p-fact-time            skip
      "p-fact-num"             p-fact-num             skip
      "p-shift-date"           p-shift-date           skip
      "p-shift-num"            p-shift-num            skip
      "p-shift-on"             p-shift-on             skip
      "p-shift-end-fact-order" p-shift-end-fact-order skip
      "p-day-end-fact-order"   p-day-end-fact-order   skip
      "v-fact-date-num"        v-fact-date-num        skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end procedure.
procedure day-begin-fact-order :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-begin-fact-order as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      assign
        p-day-begin-fact-order = 0
      .
    end.
    else do:
      assign
        p-day-begin-fact-order = integer(p-fact-date)
      .
    end.
  end.
end procedure.
procedure factord-max-fact-order :
  define output parameter p-max-fact-order as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    run day-begin-fact-order in this-procedure
      (input  date(1, 1, 5000)
      ,output p-max-fact-order
      ) .
  end.
end procedure.
procedure factord-cut-archive :
  define input  parameter p-obj-type             as character no-undo .
  define input  parameter p-obj-code             as integer   no-undo .
  define input  parameter p-fact-date            as date      no-undo .
  define output parameter p-shift-on             as logical   no-undo .
  define output parameter p-shift-date           as date      no-undo .
  define output parameter p-shift-num            as integer   no-undo .
  define output parameter p-day-end-fact-order   as decimal   no-undo .
  define output parameter p-shift-end-fact-order as decimal   no-undo .
  define variable v-fact-order as decimal   no-undo .
  define buffer buf_shift-obj for ub.shift-obj .
  do
  on error undo, return error return-value
  :
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output p-shift-on
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута объекта" skip
        "Объект" p-obj-type p-obj-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-shift-on = false
    then do:
      assign
        p-shift-date               = ?
        p-shift-num                = 0
      .
    end.
    else do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно вычислить последнюю смену" skip
          "Отсутствует закрытая смена с датой большей чем дата инициализации архива" skip
          "Объект" p-obj-type p-obj-code skip
          "Дата" p-fact-date skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find last buf_shift-obj share-lock
        where buf_shift-obj.obj-type = p-obj-type
          and buf_shift-obj.obj-code = p-obj-code
          and buf_shift-obj.shift-date <= p-fact-date
        use-index pi
        no-error .
      if available buf_shift-obj
      then do:
        if  buf_shift-obj.status_ = 'зкр':U
        then do:
          assign
            p-shift-date = buf_shift-obj.shift-date
            p-shift-num  = buf_shift-obj.shift-num
          .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно вычислить последнюю смену" skip
            "Статус смены отличен от статуса" 'зкр':U skip
            "Объект" p-obj-type p-obj-code skip
            "Дата" p-fact-date skip
            "Смена" buf_shift-obj.shift-date buf_shift-obj.shift-num skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
      else do:
        assign
          p-shift-date = p-fact-date - 1
          p-shift-num  = 1
        .
      end.
    end.
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  p-shift-date
      ,input  p-shift-num
      ,input  p-shift-on
      ,output v-fact-order
      ,output p-shift-end-fact-order
      ,output p-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры factord"
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure factord-lock-shift :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .
  define parameter buffer buf_shift-obj for ub.shift-obj .
  define variable v-shift-on      as logical   no-undo .
  define variable v-extra-message as character no-undo .
  define variable v-error as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  ) no-error .
    if error-status :error
    then do:
      v-error = substitute("Ошибка при определении атрибута объекта  &1 &2 &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value) .
      undo, return error v-error .
    end.
    if v-shift-on = true
    then do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        find last buf_shift-obj
          where buf_shift-obj.obj-type = p-obj-type
            and buf_shift-obj.obj-code = p-obj-code
            and buf_shift-obj.status_  = 'зкр':U
          use-index stts
          no-error .
        if available buf_shift-obj
        then do:
          assign
            v-extra-message =
                  substitute("Дата начала последеней закрытой смены на объекте &1"
                            ,string(buf_shift-obj.shift-date, '99/99/9999':u)
                            )
          .
        end.
        v-error = substitute("Ошибка при блокировке смены объекта  &1 &2 Отсутствует закрытая смена с датой большей чем указанная дата  &5  &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value , p-fact-date) .
        undo, return error v-error .
      end.
    end.
  end.
end procedure.
procedure factord-end-day :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      return error "Не указана фактическая дата" .
    end.
    assign
      p-day-end-fact-order = integer(p-fact-date) + 0.99
    .
  end.
end procedure.
procedure factord-to-date :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-date  as date    no-undo .
  define variable v-ref-date  as date      no-undo .
  define variable v-ref-delta as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
      v-ref-date  = date(1, 1, 2000)
    .
    assign
      v-ref-delta = integer(truncate(p-fact-order, 0)) - integer(v-ref-date)
    .
    assign
      p-fact-date = v-ref-date + v-ref-delta
    .
  end.
end procedure.
procedure factord-to-fact-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-num   as integer no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)
    .
    assign
      p-fact-num = (p-fact-order - v-fact-order-trunc ) * 10000000000
    .
  end.
end procedure.
procedure factord-to-shift-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-shift-num   as integer no-undo .
  define variable  p-shift-numd  as decimal   no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)  - truncate(p-fact-order,0)
    .
    if v-fact-order-trunc < 0.5 then do:
      v-fact-order-trunc = v-fact-order-trunc + 0.5.
    end.
    assign
      p-shift-numd = (( v-fact-order-trunc  * 100 - 50 ) + 1 ) / 2
      .
     assign
      p-shift-num = truncate (p-shift-numd , 0)
    .
  end.
end procedure.
define temp-table temp-gds-qnty no-undo
field day as date
field prih as decimal
field rash as decimal
field ost  as decimal
field qnty-day as integer
index pi is unique primary day
index by-ost ost .
define variable qnty-lib-v-fact-order-2 as decimal no-undo .
procedure qnty-lib-clear-tt :
 do
 on error undo, return error return-value
 :
 for each temp-gds-qnty :
     delete temp-gds-qnty .
 end.
 end.
end procedure.
procedure qnty-lib-create-tt :
 do
 on error undo, return error return-value
 :
define input parameter p-fact-order-1 as decimal no-undo .
define input parameter p-fact-order-2 as decimal no-undo .
define input parameter p-gds-code like ub.goods.gds-code no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define variable p-include-fact-order as logical no-undo .
define buffer buf_goods for ub.goods .
define variable quantity      as decimal no-undo .
define variable p-fact-date   as date no-undo .
define variable p-fact-date-0 as date no-undo .
define variable p-fact-date-2 as date no-undo .
define buffer p-doc-line for ub.doc-line .
define variable p-prih as decimal no-undo .
define variable p-rash as decimal no-undo .
qnty-lib-v-fact-order-2 = p-fact-order-2.
p-include-fact-order = true .
find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
     if error-status :error then return error .
       run prdoclib-init-prt-obj-by-factord in this-procedure
            (input  p-obj-type
            ,input  p-obj-code
            ,input  buf_goods.artic
            ,input  buf_goods.prod-type
            ,input  buf_goods.prod-code
            ,input  p-fact-order-1  + 0.99
            ,input  p-include-fact-order
            ) .
      for each temp-prt-obj :
          quantity   = quantity + temp-prt-obj.fact-qnty.
      end.
      run prdoclib-clear-temp-prt-obj in this-procedure .
    run factord-to-date in this-procedure
                        (  input  p-fact-order-1  ,
                           output p-fact-date-0     ).
    find first temp-gds-qnty where temp-gds-qnty.day      = p-fact-date-0 no-error .
     if not available temp-gds-qnty then do:
          create temp-gds-qnty.
          assign
            temp-gds-qnty.day      = p-fact-date-0
            temp-gds-qnty.prih     = 0
            temp-gds-qnty.rash     = 0
            temp-gds-qnty.ost      = quantity
            temp-gds-qnty.qnty-day = 0
          .
     end.
     else do:
          assign
            temp-gds-qnty.day      = p-fact-date-0
            temp-gds-qnty.prih     = 0
            temp-gds-qnty.rash     = 0
            temp-gds-qnty.ost      =  temp-gds-qnty.ost + quantity
            temp-gds-qnty.qnty-day = 0
          .
    end.
  run factord-to-date in this-procedure
                      (  input  p-fact-order-2  ,
                         output p-fact-date     ).
   find first temp-gds-qnty where temp-gds-qnty.day      = p-fact-date no-error .
     if not available temp-gds-qnty then do:
          create temp-gds-qnty.
          assign
            temp-gds-qnty.day      = p-fact-date
            temp-gds-qnty.prih     = 0
            temp-gds-qnty.rash     = 0
            temp-gds-qnty.ost      = 0
            temp-gds-qnty.qnty-day = 0
          .
     end.
assign
  p-prih  = 0
  p-rash  = 0
.
define variable i as integer no-undo .
       for each p-doc-line no-lock where
                p-doc-line.obj-type    = p-obj-type
            and p-doc-line.obj-code    = p-obj-code
            and p-doc-line.artic       = buf_goods.artic
            and p-doc-line.prod-type   = buf_goods.prod-type
            and p-doc-line.prod-code   = buf_goods.prod-code
            and p-doc-line.status_     = 'факт':U
            and p-doc-line.fact-order >= p-fact-order-1
            and p-doc-line.fact-order <= p-fact-order-2 break by integer(p-doc-line.fact-order) :
        case p-doc-line.ext-doc-type:
             when   'ie':U  or
             when   'im':U     then
               do:
                  assign p-prih   = p-prih  +  p-doc-line.fact-qnty.
               end.
              when  'we':U      then if  p-t-sp      then assign p-rash = p-rash   +  p-doc-line.fact-qnty.
              when  'wm':U       then if  p-t-sppv    then assign p-rash = p-rash   +  p-doc-line.fact-qnty.
              when  'em':U       then if  p-t-sppv-2  then assign p-rash = p-rash   +  p-doc-line.fact-qnty.
              when  'ev':U      then if  p-t-sppv-3  then assign p-rash = p-rash   +  p-doc-line.fact-qnty.
              when  'rv':U  then if  p-t-sppv-4  then assign p-rash = p-rash   -  p-doc-line.fact-qnty.
              when  'ee':U      then if  p-t-rv      then assign p-rash = p-rash   +  p-doc-line.fact-qnty.
              when  're':U  then if  p-t-rvz     then assign p-rash   = p-rash  -  p-doc-line.fact-qnty.
              when  'es':U     then if p-t-rvc  then assign p-rash  = p-rash  +  p-doc-line.fact-qnty.
              when  'rs':U then if p-t-rvzc then assign p-rash  = p-rash  -  p-doc-line.fact-qnty.
          end case.
          assign
            p-rash  = p-rash
          .
          if last-of(integer(p-doc-line.fact-order)) then do:
            run factord-to-date in this-procedure (  input  p-doc-line.fact-order  ,
                                   output p-fact-date-2   ).
                find first temp-gds-qnty where temp-gds-qnty.day      = p-fact-date-2 no-error .
                if not available temp-gds-qnty then do:
                    create temp-gds-qnty.
                    assign
                      temp-gds-qnty.day      = p-fact-date-2
                      temp-gds-qnty.prih     = p-prih
                      temp-gds-qnty.rash     = p-rash
                      temp-gds-qnty.ost      = 0
                      temp-gds-qnty.qnty-day = 0
                    .
                end.
                else do:
                    assign
                      temp-gds-qnty.prih     = temp-gds-qnty.prih + p-prih
                      temp-gds-qnty.rash     = temp-gds-qnty.rash + p-rash
                      temp-gds-qnty.ost      = temp-gds-qnty.ost
                      temp-gds-qnty.qnty-day = 0
                    .
                end.
                if temp-gds-qnty.rash <> 0  and
                   p-fact-date-2 + 1  <  p-fact-date then  do:
                   find first temp-gds-qnty where
                              temp-gds-qnty.day      = p-fact-date-2 + 1 no-error .
                    if not available temp-gds-qnty then do:
                        create temp-gds-qnty.
                        assign
                          temp-gds-qnty.day      = p-fact-date-2 + 1
                          temp-gds-qnty.prih     = 0
                          temp-gds-qnty.rash     = 0
                          temp-gds-qnty.ost      = 0
                          temp-gds-qnty.qnty-day = 0
                        .
                    end.
                 end.
                assign
                  p-prih  = 0
                  p-rash  = 0
                .
          end.
    end.
 define variable old-ost as decimal no-undo .
 old-ost = 0 .
 for each temp-gds-qnty break by temp-gds-qnty.day :
    if  temp-gds-qnty.day      <> p-fact-date-0 then do:
              assign
                 temp-gds-qnty.ost    = old-ost +    temp-gds-qnty.prih  - temp-gds-qnty.rash
              .
              end.
    assign
      old-ost = temp-gds-qnty.ost
    .
 end.
 end.
end procedure.
procedure qnty-lib-2 :
 do
 on error undo, return error return-value
 :
define variable p-fact-date-3 as date no-undo .
define variable old-day as date no-undo .
run factord-to-date in this-procedure (  input  qnty-lib-v-fact-order-2  ,
                       output p-fact-date-3   ).
 old-day = p-fact-date-3 + 1.
 for each temp-gds-qnty break by temp-gds-qnty.day DESCENDING :
    assign
      temp-gds-qnty.qnty-day  =  old-day - temp-gds-qnty.day
      old-day = temp-gds-qnty.day
    .
 end .
 end.
end procedure.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table export-ras no-undo like ub.ord-line field sum       as decimal   field all-day   as integer   field qnty-sale as decimal   field negative-rest as logical    field gds-name  as character field unit-base as character field unit-type as character field unit-cli-type as character field min-order     as decimal   field service-order as decimal field max-stock     as decimal   field local-mark    as character field ostatok-today as decimal    field gds-way-all as decimal index pi1 is unique primary       artic                       prod-type                   prod-code                   obj-type                    obj-code                    ascending             .
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gdspoatr-name :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdspoatr-name in g#attr-lib
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
end procedure.
procedure gdspoatr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdspoatr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gdspoatr-value :
  define input  parameter p-code     like ub.gds-obj-prop-attr.attr-code  no-undo .
  define input  parameter p-gds-code like ub.gds-obj-prop-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-prop-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-prop-attr.obj-code   no-undo .
  define output parameter p-value    like ub.gds-obj-prop-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdspoatr-value in g#attr-lib
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
end procedure.
procedure gdspoatr-write :
  define input parameter p-gds-code like ub.gds-obj-prop-attr.gds-code   no-undo .
  define input parameter p-obj-type like ub.gds-obj-prop-attr.obj-type   no-undo .
  define input parameter p-obj-code like ub.gds-obj-prop-attr.obj-code   no-undo .
  define input parameter p-code     like ub.gds-obj-prop-attr.attr-code  no-undo .
  define input parameter p-value    like ub.gds-obj-prop-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdspoatr-write in g#attr-lib
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
end procedure.
procedure gdspoatr-exist :
  define input  parameter p-gds-code like ub.gds-obj-prop-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-prop-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-prop-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-prop-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdspoatr-exist in g#attr-lib
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
end procedure.
procedure gdspoatr-delete :
  define input  parameter p-gds-code like ub.gds-obj-prop-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-prop-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-prop-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-prop-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdspoatr-delete in g#attr-lib
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
end procedure.
procedure gdspoatr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdspoatr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable g#log as logical   no-undo .
define variable  fact-order-1       like ub.stk-tot.fact-order no-undo.
define variable  fact-order-2       like ub.stk-tot.fact-order no-undo.
define variable  fact-order-today   like ub.stk-tot.fact-order no-undo.
define variable v-ex-date as date   no-undo .
define variable i-date    as integer   no-undo .
define variable i-date-start as integer   no-undo .
define variable i-date-to    as integer   no-undo .
define variable ret-day as date no-undo .
define variable  ostatok-goods  like ub.stk-tot.fact-qnty  init 0 no-undo.
define variable  coast       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast_r     like ub.stk-tot.sum-rubl   no-undo.
define variable  coast_v     like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_r       like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_v       like ub.stk-tot.sum-rubl   no-undo.
define variable  slt_r       like ub.stk-tot.sum-rubl   no-undo.
define variable  slt_v       like ub.stk-tot.sum-rubl   no-undo.
define variable  prih        like ub.stk-tot.sum-rubl   no-undo.
define variable  rash        like ub.stk-tot.sum-rubl   no-undo.
define variable  kassa       like ub.stk-tot.sum-rubl   no-undo.
define variable l-new-zakaz as decimal init 0 no-undo .
define variable l-action    as logical no-undo init false .
define variable sum-qnty    like  ub.doc-line.fact-qnty init 0 no-undo.
define variable sum-ost     like  ub.doc-line.fact-qnty init 0 no-undo.
define variable all-day     as int init 0 no-undo.
define variable l-qnty-qnty as integer no-undo .
define variable date-today as date no-undo .
define variable v-prih    like ub.stk-tot.sum-rubl   no-undo.
define variable v-rash    like ub.stk-tot.sum-rubl   no-undo.
define variable v-kassa   like ub.stk-tot.sum-rubl   no-undo.
define variable v-gds-way as decimal no-undo .
define variable v-gds-way-all as decimal no-undo .
define variable kk as integer no-undo .
define variable Quantity  as decimal no-undo .
define variable d-kassa as decimal no-undo .
define variable d-rash as decimal no-undo .
define variable ddd as decimal no-undo .
define variable v-code       like ub.gds-obj-prop-attr.attr-code  no-undo .
define variable v-obj-type   like ub.gds-obj-prop-attr.obj-type   no-undo .
define variable v-obj-code   like ub.gds-obj-prop-attr.obj-code   no-undo .
define variable v-value      like ub.gds-obj-prop-attr.attr-value no-undo .
define variable v-type       as character no-undo .
define variable v-corr-coeff as decimal   no-undo .
define variable sum-kv-raz as decimal no-undo .
define temp-table temp-rash no-undo
field tt-ostatok as decimal
field tt-rash as decimal
field tt-date as date
index by-date tt-date
.
define variable old-pay-day as integer   no-undo .
old-pay-day = pay-day.
define variable v-sum-qnty-prt as decimal no-undo .
for each export-ras :
 delete export-ras.
end.
if p-mode-calc = ? then p-mode-calc = "" .
run qnty-lib-clear-tt in this-procedure .
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  store-type
  ,input  store-code
  ,output to-day
  )  .
  date-today = to-day .
  l-qnty-qnty = ( loc-date-ship - date-today ) .
 if l-qnty-qnty = ? then l-qnty-qnty  = 0 .
 if l-qnty-qnty < 0 and G#type <> 'ОО':U  and G#type <> 'ОР':U then do:
    message "Заказ не может быть рассчитан, разница Дата заказа и текущей датой " l-qnty-qnty " дней !" view-as alert-box error .
    return.
 end.
if not can-find (first obj-list) then do:
    message "Ни задан ни один объект для расчета" view-as alert-box error .
    return.
end.
assign l-action = true .
if p-mode-calc = ""  then do:
    if  var#import = true   then do:
      message "Данные были введены через ИМПОРТ , делать изменения количества заказа ?" view-as alert-box question
        buttons
        ok-cancel update g#log.
        if g#log = false then return.
        var#import = false.
        end.
    if t-action = "calc":u then do:
      message
       "Пересчитать заказ в соответствии с новыми параметрами расчета ?" skip
       "В результате пересчета количество заказа может измениться."
      view-as alert-box question
        buttons
        ok-cancel update g#log.
        l-action = g#log .
        end.
 end.
else do:
  var#import = false .
  l-action = true .
end.
if  var#import = false  then do:
  IF p-type-qnty-day = 1 Then do:
    all-day = xdate-2 - xdate-1  + 1.
  end.
  IF p-type-qnty-day = 3 Then do:
    all-day = 0 .
    for each temp-dates :
        all-day = all-day  + 1.
    end.
  end.
run calcitog in this-procedure  no-error .
for each tmp#zakaz :
    if p-mode-calc <> ""  then do:
        for each obj-list :
            create export-ras.
            BUFFER-COPY tmp#zakaz to export-ras
            assign
              export-ras.obj-code = obj-list.obj-code
              export-ras.obj-type = obj-list.obj-type
            .
        end.
    end.
    assign
        prih  = 0
        rash  = 0
        kassa = 0
        ostatok-goods = 0
        v-gds-way-all = 0
      .
      IF p-type-qnty-day = 2 Then do:
        all-day = xdate-2 - xdate-1  + 1 .
        l-null-day = 0 .
        run qnty-lib-clear-tt in this-procedure .
        for each obj-list no-lock :
            run qnty-lib-create-tt in this-procedure
                ( input  integer(xdate-1)       ,
                  input  fact-order-2       ,
                  input  tmp#zakaz.gds-code ,
                  input  obj-list.obj-type  ,
                  input  obj-list.obj-code  )
                  .
        end.
        run qnty-lib-2 in this-procedure .
        run calc-null-day in this-procedure .
        run calc-sale in this-procedure  .
      end.
      for each obj-list no-lock ,
          each ub.gds-obj no-lock where ub.gds-obj.artic     = tmp#zakaz.artic      and
                                    ub.gds-obj.prod-code = tmp#zakaz.prod-code   and
                                    ub.gds-obj.prod-type = tmp#zakaz.prod-type   and
                                    ub.gds-obj.obj-code  = obj-list.obj-code     and
                                    ub.gds-obj.obj-type  = obj-list.obj-type     :
          ostatok-goods = ostatok-goods + ub.gds-obj.fact-qnty  .
          run goods-way in this-procedure  ( input obj-list.obj-type , input obj-list.obj-code , output  v-gds-way ) .
          v-gds-way-all = v-gds-way-all + v-gds-way .
          tmp#zakaz.gds-way = v-gds-way.
          tmp#zakaz.min-stock-old = tmp#zakaz.min-stock.
      end.
  if p-r-algoritm = 3  then do :
          d-rash  = 0 .
          d-kassa = 0 .
          IF p-type-qnty-day = 1  Then do:
                run qnty-lib-clear-tt in this-procedure .
                for each obj-list no-lock :
                    run qnty-lib-create-tt in this-procedure
                        ( input  integer(xdate-1)       ,
                          input  fact-order-2       ,
                          input  tmp#zakaz.gds-code ,
                          input  obj-list.obj-type  ,
                          input  obj-list.obj-code  )
                          .
                end.
                run qnty-lib-2 in this-procedure .
                run calc-sale  in this-procedure .
          end.
          IF p-type-qnty-day = 3   then do :
                    run qnty-lib-clear-tt.
                    for each temp-dates no-lock :
                        d-rash  = 0 .
                        d-kassa = 0 .
                      for each obj-list no-lock :
                        run ob-line in this-procedure  (
                            input   obj-list.obj-code   ,
                            input   obj-list.obj-type   ,
                            input   tmp#zakaz.artic       ,
                            input   tmp#zakaz.prod-code   ,
                            input   tmp#zakaz.prod-type   ,
                            input    integer(temp-dates.exch-date)    ,
                            input    integer(temp-dates.exch-date)  + 0.99  ,
                            input   'cost':U    ,
                            input   '##,##':U ,
                            input   ""    ,
                            input   false ,
                            input   false ,
                            output v-prih ,
                            output v-rash ,
                            output v-kassa
                            )  no-error .
                          assign
                            d-rash  = d-rash  + v-rash
                            d-kassa = d-kassa + v-kassa
                            prih  = prih +  v-prih
                            rash  = rash  + v-rash
                            kassa = kassa + v-kassa
                          .
                          end.
                          if  d-rash + d-kassa <> 0  then
                              run create-temp-rash in this-procedure  ( temp-dates.exch-date , d-rash + d-kassa ) .
                    end.
          end.
  end.
  if  p-r-algoritm = 4 then do :
          d-rash  = 0 .
          d-kassa = 0 .
          IF p-type-qnty-day = 1  Then do:
              i-date-start = integer(xdate-1) .
              i-date-to    = integer(xdate-2) .
              run qnty-lib-clear-tt .
              repeat  i-date = i-date-start to i-date-to :
                d-rash  = 0 .
                d-kassa = 0 .
                for each obj-list no-lock :
                  run ob-line (
                    input obj-list.obj-code   ,
                    input obj-list.obj-type   ,
                    input tmp#zakaz.artic     ,
                    input tmp#zakaz.prod-code ,
                    input tmp#zakaz.prod-type ,
                    input i-date              ,
                    input i-date  + 0.99      ,
                    input 'cost':U         ,
                    input '##,##':U      ,
                    input ""                  ,
                    input false               ,
                    input false               ,
                    output v-prih             ,
                    output v-rash             ,
                    output v-kassa
                    )  no-error .
                    assign
                      d-rash  = d-rash  + v-rash
                      d-kassa = d-kassa + v-kassa
                      prih    = prih    + v-prih
                      rash    = rash    + v-rash
                      kassa   = kassa   + v-kassa
                    .
                    end.
                    if  d-rash + d-kassa <> 0  then
                      run create-temp-rash ( date(i-date) , d-rash + d-kassa ) .
              end.
           end.
          IF p-type-qnty-day = 3   then do :
                run qnty-lib-clear-tt.
                for each temp-dates no-lock :
                    d-rash  = 0 .
                    d-kassa = 0 .
                  for each obj-list :
                    run ob-line in this-procedure  (
                        input   obj-list.obj-code     ,
                        input   obj-list.obj-type     ,
                        input   tmp#zakaz.artic       ,
                        input   tmp#zakaz.prod-code   ,
                        input   tmp#zakaz.prod-type   ,
                        input   integer(temp-dates.exch-date) ,
                        input   integer(temp-dates.exch-date)  + 0.99  ,
                        input   'cost':U    ,
                        input   '##,##':U ,
                        input   ""    ,
                        input   false ,
                        input   false ,
                        output v-prih ,
                        output v-rash ,
                        output v-kassa
                        )  no-error .
                      assign
                        d-rash  = d-rash  + v-rash
                        d-kassa = d-kassa + v-kassa
                        prih  = prih +  v-prih
                        rash  = rash  + v-rash
                        kassa = kassa + v-kassa
                      .
                      end.
                      if  d-rash + d-kassa <> 0  then
                          run create-temp-rash in this-procedure  ( temp-dates.exch-date , d-rash + d-kassa ) .
                end.
          end.
  end.
 IF p-r-algoritm = 1  Then do:
      IF p-type-qnty-day = 1  Then do:
         for each obj-list no-lock :
          run ob-line in this-procedure  (
              input   obj-list.obj-code   ,
              input   obj-list.obj-type   ,
              input   tmp#zakaz.artic       ,
              input   tmp#zakaz.prod-code   ,
              input   tmp#zakaz.prod-type   ,
              input   fact-order-1   ,
              input   fact-order-2   ,
              input   'cost':U    ,
              input   '##,##':U ,
              input   ""    ,
              input   false ,
              input   p-tog-det-prizn ,
              output v-prih ,
              output v-rash ,
              output v-kassa
              )  no-error .
            assign
              prih  = prih +  v-prih
              rash  = rash  + v-rash
              kassa = kassa + v-kassa
            .
            end.
      end.
      IF p-type-qnty-day = 3 Then do:
                     run qnty-lib-clear-tt.
                    for each temp-dates no-lock :
                      for each obj-list :
                          run ob-line in this-procedure  (
                              input   obj-list.obj-code   ,
                              input   obj-list.obj-type   ,
                              input tmp#zakaz.artic     ,
                              input tmp#zakaz.prod-code ,
                              input tmp#zakaz.prod-type ,
                              input integer(temp-dates.exch-date)         ,
                              input integer(temp-dates.exch-date) + 0.99  ,
                              input 'cost':U    ,
                              input '##,##':U ,
                              input ""    ,
                              input false ,
                              input   p-tog-det-prizn ,
                              output v-prih ,
                              output v-rash ,
                              output v-kassa
                              )          no-error .
                            assign
                              prih  = prih +  v-prih
                              rash  = rash  + v-rash
                              kassa = kassa + v-kassa
                            .
                        end.
                    end.
      end.
end.
if p-mode-calc = ""  then do:
assign
  tmp#zakaz.qnty-kassa  = kassa
  tmp#zakaz.qnty-prih   = prih
  tmp#zakaz.qnty-rash   = rash
  tmp#zakaz.qnty-stk    = ostatok-goods
  tmp#zakaz.qnty-sale   = (rash + kassa)
  .
end.
else do:
assign
  export-ras.qnty-kassa  = kassa
  export-ras.qnty-prih   = prih
  export-ras.qnty-rash   = rash
  export-ras.qnty-stk    = ostatok-goods
  export-ras.qnty-sale   = (rash + kassa)
  .
end.
 all-day = all-day - l-null-day.
    IF p-r-algoritm <> 2 Then do :
        if p-mode-calc = ""  then do:
           tmp#zakaz.temp-rash  = (rash + kassa) / all-day  .
           tmp#zakaz.all-day    =  all-day  .
           tmp#zakaz.zero-day    = l-null-day  .
        end.
        else do:
           export-ras.temp-rash  = (rash + kassa) / all-day  .
           export-ras.all-day    =  all-day  .
           export-ras.zero-day    = l-null-day  .
        end.
    end.
    else do:
         if can-find (first temp-abc-day) then do:
         if p-mode-calc <> ""  then export-ras.temp-rash = tmp#zakaz.temp-rash .
      end.
      else do:
      find first ub.tmp-sale-gds where
          ub.tmp-sale-gds.artic     = tmp#zakaz.artic     and
          ub.tmp-sale-gds.prod-code = tmp#zakaz.prod-code and
          ub.tmp-sale-gds.prod-type = tmp#zakaz.prod-type and
          ub.tmp-sale-gds.tmp-code  = p-code no-lock no-error .
          if available ub.tmp-sale-gds then do:
             if p-mode-calc = ""  then do:
                assign  tmp#zakaz.temp-rash = ub.tmp-sale-gds.tmp-value .
                end.
                else do:
                assign  export-ras.temp-rash = ub.tmp-sale-gds.tmp-value .
                end.
             end.
             else do:
               if tmp#zakaz.add-qnty = 0 or tmp#zakaz.add-qnty = ? then do:
                    if p-mode-calc = ""  then do:
                        assign  tmp#zakaz.temp-rash = 0 .
                    end.
                    else do:
                        assign  export-ras.temp-rash = 0 .
                    end.
                end.
             end.
        end.
    end.
    for each obj-list :
      assign v-corr-coeff = decimal(v-value) * decimal (tmp#zakaz.season-coef).
      if v-corr-coeff = 0 then v-corr-coeff = 1.
    end.
find first temp-abc-day where
           temp-abc-day.abc-type  = chr(int(tmp#zakaz.add-cli-qnty)) no-error .
if available  temp-abc-day then do:
   pay-day = temp-abc-day.gar-day .
end.
else  pay-day = old-pay-day .
define variable p-l-max0 as decimal no-undo .
define variable p-l-max as decimal no-undo .
    if l-action = true  then do :
        if l-action = true  then do :
           if tmp#zakaz.temp-rash = ? then tmp#zakaz.temp-rash = 0 .
           end.
        else do:
          if export-ras.temp-rash = ? then export-ras.temp-rash = 0 .
        end.
          case  p-r-algoritm :
               when 1  or when 2 then do :
                   run z-qnty in this-procedure .
                   run z-qnty-e in this-procedure .
               end.
               when 3 then do :
                   run v-qnty in this-procedure .
                   run v-qnty-e in this-procedure .
               end.
               when 4 then do :
                   run m-qnty in this-procedure    (output p-l-max0).
                   run m-qnty-e in this-procedure  (output p-l-max).
               end.
               when 5 then do :
                   run u-qnty in this-procedure .
                   run u-qnty-e in this-procedure .
               end.
           end case.
      if  p-mode-calc = ""   then do:
      assign
          tmp#zakaz.qnty     = l-new-zakaz
          tmp#zakaz.cli-qnty = tmp#zakaz.qnty / tmp#zakaz.cli-base-rate
          tmp#zakaz.sum-cli = tmp#zakaz.price-cli * tmp#zakaz.cli-qnty
          tmp#zakaz.sum-rubl = tmp#zakaz.price-rubl * tmp#zakaz.qnty
          tmp#zakaz.sum-base = tmp#zakaz.price-base * tmp#zakaz.qnty
      .
      end.
      else do:
      assign
          export-ras.qnty     = l-new-zakaz
          export-ras.cli-qnty = export-ras.qnty       / export-ras.cli-base-rate
          export-ras.sum-cli  = export-ras.price-cli  * export-ras.cli-qnty
          export-ras.sum-rubl = export-ras.price-rubl * export-ras.qnty
          export-ras.sum-base = export-ras.price-base * export-ras.qnty
          export-ras.ostatok-today = export-ras.qnty-stk
          export-ras.gds-way-all   = v-gds-way-all
      .
      end.
      if  p-mode-calc = ""   then do:
              run recalc-cli-qnty in this-procedure  (
                 input        tmp#zakaz.gds-code
                ,input        p-round-m
                ,input        p-round-base
                ,input        tmp#zakaz.unit-cli
                ,input        tmp#zakaz.cli-base-rate
                ,input        tmp#zakaz.price-cli
                ,input        tmp#zakaz.price-rubl
                ,input        tmp#zakaz.price-base
                ,input-output tmp#zakaz.cli-qnty
                ,input-output tmp#zakaz.qnty
                ,input-output tmp#zakaz.sum-cli
                ,input-output tmp#zakaz.sum-rubl
                ,input-output tmp#zakaz.sum-base
                ).
          tmp#zakaz.initial-qnty = tmp#zakaz.qnty.
          tmp#zakaz.order-qnty = tmp#zakaz.qnty  .
          for each obj-list no-lock :
          run create-obj-temp in this-procedure (
             input p-ord-doc ,
             input tmp#zakaz.gds-code ,
             input obj-list.obj-type ,
             input obj-list.obj-code ,
             input tmp#zakaz.qnty
             ) .
          run create-min-stock-gds-way in this-procedure (
             input p-ord-doc ,
             input tmp#zakaz.gds-code ,
             input tmp#zakaz.min-stock,
             input tmp#zakaz.gds-way
             ) .
      end.
      end.
      else do:
          run recalc-cli-qnty in this-procedure  (
               input        export-ras.gds-code
              ,input        p-round-m
              ,input        p-round-base
              ,input        export-ras.unit-cli
              ,input        export-ras.cli-base-rate
              ,input        export-ras.price-cli
              ,input        export-ras.price-rubl
              ,input        export-ras.price-base
              ,input-output export-ras.cli-qnty
              ,input-output export-ras.qnty
              ,input-output export-ras.sum-cli
              ,input-output export-ras.sum-rubl
              ,input-output export-ras.sum-base
              ).
            export-ras.Temp-rash = ( if export-ras.Temp-rash <> ?  then export-ras.Temp-rash else 0 )  .
            if p-r-algoritm = 4 then  export-ras.temp-rash = p-l-max .
            export-ras.initial-qnty = export-ras.qnty.
            export-ras.Temp-rash = ( if export-ras.Temp-rash <> ?  then export-ras.Temp-rash
                                                                    else 0 ) .
        if p-r-algoritm = 4 then  export-ras.temp-rash = p-l-max .
      end.
      if g#type = 'ФП':U then
              run create-protocol in this-procedure
              (  input p-ord-doc
                ,input tmp#zakaz.gds-code
                ,input v-protocol-date
                ,input v-protocol-time
                ,input "По списку"
                ,input 0
                ,input v-stroka-protocol).
      else do:
          for each obj-list:
              run create-protocol in this-procedure
              (  input p-ord-doc
                ,input tmp#zakaz.gds-code
                ,input v-protocol-date
                ,input v-protocol-time
                ,input obj-list.obj-type
                ,input obj-list.obj-code
                ,input v-stroka-protocol).
          end.
      end.
    end.
    if p-tog-det-prizn then do :
        v-sum-qnty-prt = 0.
        for each tmp#zakaz-prn where tmp#zakaz-prn.artic     = export-ras.artic     and
                                     tmp#zakaz-prn.prod-type = export-ras.prod-type and
                                     tmp#zakaz-prn.prod-code = export-ras.prod-code no-lock
        :
          assign
            tmp#zakaz-prn.qnty-ord = round((export-ras.qnty * (tmp#zakaz-prn.qnty-sale / export-ras.qnty-sale)), 0)
            v-sum-qnty-prt = v-sum-qnty-prt + tmp#zakaz-prn.qnty-ord
          .
          if tmp#zakaz-prn.qnty-ord = ? then tmp#zakaz-prn.qnty-ord = 0 .
        end.
        for each tmp#zakaz-prn where tmp#zakaz-prn.artic     = export-ras.artic     and
                                     tmp#zakaz-prn.prod-type = export-ras.prod-type and
                                     tmp#zakaz-prn.prod-code = export-ras.prod-code no-lock break by tmp#zakaz-prn.prt-code descending
        :
            if v-sum-qnty-prt > export-ras.qnty then
              assign
                tmp#zakaz-prn.qnty-ord = tmp#zakaz-prn.qnty-ord - 1
                v-sum-qnty-prt         = v-sum-qnty-prt         - 1
              .
            if v-sum-qnty-prt < export-ras.qnty then
              assign
                tmp#zakaz-prn.qnty-ord = tmp#zakaz-prn.qnty-ord + 1
                v-sum-qnty-prt         = v-sum-qnty-prt         + 1
              .
        end.
    end.
 end.
 if p-mode-calc <> ""  and p-mode-calc <> "all-ord":U  then do:
   run cus/z-tot5.p ( parParentProc , input table export-ras , input p-ord-doc , input p-e-method , input v-show-all-goods ) .
 end.
  if  p-mode-calc = "all-ord":U  then do:
     run cus/z-tot6.p ( parParentProc , input table export-ras , input table tmp#zakaz-prn , g#type ) .
  end.
end.
procedure calcitog :
   assign
     fact-order-1 = integer(xdate-1 - 1 ) + 0.99
     fact-order-2 = integer(xdate-2) + 0.99
     fact-order-today = integer(date-today) + 0.99
   .
end procedure.
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ob-line  :
define input  parameter x-store-code     like ub.clients.obj-code     no-undo.
define input  parameter x-store-type     like ub.clients.obj-type     no-undo.
define input  parameter x-artic          like ub.ot-line.artic        no-undo.
define input  parameter x-prod-code      like ub.ot-line.prod-code    no-undo.
define input  parameter x-prod-type      like ub.ot-line.prod-type    no-undo.
define input  parameter x-fact-order-1   like ub.ot-line.fact-order   no-undo.
define input  parameter x-fact-order-2   like ub.ot-line.fact-order   no-undo.
define input  parameter x-sum-type       like ub.ot-line.sum-type     no-undo.
define input  parameter x-cat-id         like ub.ot-line.cat-id       no-undo.
define input  parameter x-ext-doc-type   like ub.ot-line.ext-doc-type no-undo.
define input  parameter xtog-obj         as   logical no-undo.
define input  parameter xtog-prn         as   logical no-undo.
define output parameter p-prih  as decimal no-undo .
define output parameter p-rash  as decimal no-undo .
define output parameter p-kassa as decimal no-undo .
define buffer p-doc-line for ub.doc-line.
define buffer p-gds-dtl  for ub.gds-dtl.
define variable p-doc-type as character no-undo .
define variable str-doc-type as character no-undo .
str-doc-type =
'ie':U      + "," +
'im':U     + "," +
'we':U      + "," +
'wm':U       + "," +
'em':U       + "," +
'ev':U      + "," +
'rv':U  + "," +
'ee':U      + "," +
're':U  + "," +
'es':U + "," +
'rs':U .
assign
  p-prih  = 0
  p-rash  = 0
  p-kassa = 0
.
define variable i as integer no-undo .
define variable v-nn as integer   no-undo .
v-nn = num-entries( str-doc-type ) .
  repeat i = 1 to v-nn :
    p-doc-type = entry( i, str-doc-type) .
       for each p-doc-line where
                p-doc-line.obj-type    = x-store-type
            and p-doc-line.obj-code    = x-store-code
            and p-doc-line.artic       = x-artic
            and p-doc-line.prod-type   = x-prod-type
            and p-doc-line.prod-code   = x-prod-code
            and p-doc-line.ext-doc-type = p-doc-type
            and p-doc-line.status_     = 'факт':U
            and p-doc-line.fact-order >= x-fact-order-1
            and p-doc-line.fact-order <= x-fact-order-2 no-lock :
        case p-doc-line.ext-doc-type:
             when   'ie':U  or
             when   'im':U     then
               do:
               assign p-prih   = p-prih  +  p-doc-line.fact-qnty.
               end.
              when  'we':U      then if  p-t-sp      then assign p-rash = p-rash   +  p-doc-line.fact-qnty.
              when  'wm':U       then if  p-t-sppv    then assign p-rash = p-rash   +  p-doc-line.fact-qnty.
              when  'em':U       then if  p-t-sppv-2  then assign p-rash = p-rash   +  p-doc-line.fact-qnty.
              when  'ev':U      then if  p-t-sppv-3  then assign p-rash = p-rash   +  p-doc-line.fact-qnty.
              when  'rv':U  then if  p-t-sppv-4  then assign p-rash = p-rash   -  p-doc-line.fact-qnty.
              when  'ee':U      then if  p-t-rv      then assign p-rash = p-rash   +  p-doc-line.fact-qnty.
              when  're':U  then if  p-t-rvz     then assign p-rash = p-rash   -  p-doc-line.fact-qnty.
              when  'es':U     then if p-t-rvc  then assign p-kassa  = p-kassa  +  p-doc-line.fact-qnty.
              when  'rs':U then if p-t-rvzc then assign p-kassa  = p-kassa  -  p-doc-line.fact-qnty.
          end case.
          if xtog-prn then
          for each p-gds-dtl where p-gds-dtl.doc-code  = p-doc-line.doc-code  and
                                   p-gds-dtl.artic     = p-doc-line.artic     and
                                   p-gds-dtl.prod-type = p-doc-line.prod-type and
                                   p-gds-dtl.prod-code = p-doc-line.prod-code no-lock  :
              find first tmp#zakaz-prn where tmp#zakaz-prn.artic     = p-gds-dtl.artic     and
                                             tmp#zakaz-prn.prod-type = p-gds-dtl.prod-type and
                                             tmp#zakaz-prn.prod-code = p-gds-dtl.prod-code and
                                             tmp#zakaz-prn.obj-type  = p-gds-dtl.obj-type  and
                                             tmp#zakaz-prn.obj-code  = p-gds-dtl.obj-code  and
                                             tmp#zakaz-prn.prt-code  = p-gds-dtl.prt-code  no-lock no-error .
              if not available tmp#zakaz-prn then do :
                create tmp#zakaz-prn.
                assign
                   tmp#zakaz-prn.artic     = p-gds-dtl.artic
                   tmp#zakaz-prn.prod-type = p-gds-dtl.prod-type
                   tmp#zakaz-prn.prod-code = p-gds-dtl.prod-code
                   tmp#zakaz-prn.obj-type  = p-gds-dtl.obj-type
                   tmp#zakaz-prn.obj-code  = p-gds-dtl.obj-code
                   tmp#zakaz-prn.prt-code  = p-gds-dtl.prt-code
                .
    end.
              case p-doc-line.ext-doc-type:
                    when  'we':U      then if  p-t-sp      then assign tmp#zakaz-prn.qnty-sale = tmp#zakaz-prn.qnty-sale   +  p-gds-dtl.fact-qnty.
                    when  'wm':U       then if  p-t-sppv    then assign tmp#zakaz-prn.qnty-sale = tmp#zakaz-prn.qnty-sale   +  p-gds-dtl.fact-qnty.
                    when  'em':U       then if  p-t-sppv-2  then assign tmp#zakaz-prn.qnty-sale = tmp#zakaz-prn.qnty-sale   +  p-gds-dtl.fact-qnty.
                    when  'ev':U      then if  p-t-sppv-3  then assign tmp#zakaz-prn.qnty-sale = tmp#zakaz-prn.qnty-sale   +  p-gds-dtl.fact-qnty.
                    when  'rv':U  then if  p-t-sppv-4  then assign tmp#zakaz-prn.qnty-sale = tmp#zakaz-prn.qnty-sale   -  p-gds-dtl.fact-qnty.
                    when  'ee':U      then if  p-t-rv      then assign tmp#zakaz-prn.qnty-sale = tmp#zakaz-prn.qnty-sale   +  p-gds-dtl.fact-qnty.
                    when  're':U  then if  p-t-rvz     then assign tmp#zakaz-prn.qnty-sale = tmp#zakaz-prn.qnty-sale   -  p-gds-dtl.fact-qnty.
                    when  'es':U     then if p-t-rvc  then assign tmp#zakaz-prn.qnty-sale = tmp#zakaz-prn.qnty-sale   +  p-gds-dtl.fact-qnty.
                    when  'rs':U then if p-t-rvzc then assign tmp#zakaz-prn.qnty-sale = tmp#zakaz-prn.qnty-sale   -  p-gds-dtl.fact-qnty.
                end case.
          end.
    end.
  end.
assign
  p-rash  = p-rash
  p-kassa = p-kassa
.
end procedure.
procedure goods-way :
 do
 on error undo, return error return-value
 :
 define buffer later_ord-doc for ub.ord-doc.
 define buffer later_ord-line for ub.ord-line.
 define buffer later_ord-doc-rcv for ub.ord-doc-rcv.
 define buffer later_ord-line-rcv for ub.ord-line-rcv.
 define input parameter p-obj-type like ub.clients.obj-type no-undo .
 define input parameter p-obj-code like ub.clients.obj-code no-undo .
 define output parameter p-qnty as decimal no-undo .
 p-qnty = 0 .
 if p-t-way = true then do:
   for each later_ord-line no-lock where
            later_ord-line.artic     = tmp#zakaz.artic       and
            later_ord-line.prod-code = tmp#zakaz.prod-code   and
            later_ord-line.prod-type = tmp#zakaz.prod-type  ,
       each later_ord-doc  no-lock where
            later_ord-doc.doc-code  = later_ord-line.doc-code and
            later_ord-doc.ship-date <= loc-date-ship          and
            later_ord-doc.obj-type = p-obj-type               and
            later_ord-doc.obj-code = p-obj-code               and
            later_ord-doc.status_   <>  'новый':U            and
            later_ord-doc.status_   <>  'факт':U            :
          find first later_ord-line-rcv where
              later_ord-line-rcv.doc-code = later_ord-line.doc-code and
              later_ord-line-rcv.artic     = tmp#zakaz.artic        and
              later_ord-line-rcv.prod-code = tmp#zakaz.prod-code    and
              later_ord-line-rcv.prod-type = tmp#zakaz.prod-type
              no-error.
          find first later_ord-doc-rcv where
              later_ord-doc-rcv.doc-code  = later_ord-line.doc-code     and
              later_ord-doc-rcv.rcv-code  = later_ord-line-rcv.rcv-code and
              later_ord-doc-rcv.status_   = 'факт':U
              no-error.
          if available later_ord-doc-rcv then next.
          if  G#type <> 'ОО':U  then do:
                if ( p-t-rcv  and  later_ord-doc.status_   =  'поставка':U)
                  OR
                  ( p-t-clos  and  later_ord-doc.status_ = 'закрыто':U ) then do:
                      p-qnty = p-qnty +  ( if  later_ord-line.qnty <> ? then later_ord-line.qnty
                                                                            else 0  ) .
                      end.
            end.
            else do:
              if  p-t-rcv  and  later_ord-doc.status_   =  'запрос':U  and later_ord-doc.doc-type = 'ОО':U  then do:
                    p-qnty = p-qnty +  ( if  later_ord-line.qnty <> ? then later_ord-line.qnty
                                                                      else 0  ) .
                end.
            end.
     end.
 end.
 end.
end procedure.
procedure create-temp-rash :
 do
 on error undo, return error return-value
 :
  define input parameter p-date as date   no-undo .
  define input parameter p-val as decimal no-undo .
  find first temp-gds-qnty where
        temp-gds-qnty.day = p-date no-error
        .
  if not available temp-gds-qnty then do:
     create temp-gds-qnty.
     assign
        temp-gds-qnty.day = p-date
        temp-gds-qnty.rash = p-val
        temp-gds-qnty.qnty-day = 1
        .
  end.
  else do:
     assign
        temp-gds-qnty.rash = temp-gds-qnty.rash + p-val
        temp-gds-qnty.qnty-day = 1
        .
  end.
 end.
end procedure.
procedure z-qnty :
 do
 on error undo, return error return-value
 :
  if p-mode-calc = ""  then do:
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if is-log = true then Output stream stream_order to value ("order_raschet.txt") APPEND .
Assign
  l-Ostatok-today =  tmp#zakaz.qnty-stk
  l-negative-rest =  tmp#zakaz.negative-rest
  l-qnty-day      =  l-qnty-qnty
  l-pay-day       =  pay-day
  l-Temp-rash     = if tmp#zakaz.temp-rash < 0  then 0 else tmp#zakaz.temp-rash
  l-min-zap       =  tmp#zakaz.min-stock
  l-negative-sale =  p-neg-sale
  l-goods-way     =  v-gds-way-all
  l-tog-min-order =  p-t-min-zapas
  l-min-order     =  tmp#zakaz.min-order
  loc-unit-base   =  tmp#zakaz.unit-base
  l-min-ost       =  p-t-min-ost
  l-TOG-deadline  =  p-t-deadline
  l-deadline      =  tmp#zakaz.deadline
  l-type-MR       =  p-e-method
  l-corr-coeff    =  v-corr-coeff
  .
if l-Temp-rash = ? then l-Temp-rash = 0.
  if par-ord-min-ost = yes then do:
    assign l-min-zap = l-Temp-rash * l-corr-coeff * tmp#zakaz.min-stock .
  end.
  assign L-a = l-Ostatok-today - (l-Temp-rash * l-corr-coeff * l-qnty-day) .
  if L-a  <= 0 then do:
    if l-negative-rest = true then do:
      if l-negative-sale then do:
        Assign
          l-a = 0
          l-order = ABSOLUTE(l-a) + l-min-zap + (l-pay-day * l-Temp-rash * l-corr-coeff)
        .
      end.
      else do:
        assign l-order = ABSOLUTE(l-a) + l-min-zap + (l-pay-day * l-Temp-rash * l-corr-coeff).
      end.
    end.
    else do:
      Assign
        l-a = 0
        l-order = ABSOLUTE(l-a) + l-min-zap + (l-pay-day * l-Temp-rash * l-corr-coeff)
      .
    end.
  end.
  Else do :
    assign l-b = l-Ostatok-today - (l-Temp-rash * l-corr-coeff * (l-qnty-day + l-pay-day ) ) .
          if l-b >= l-min-zap then l-order = 0.
                              else DO:
                              If l-b < 0 Then l-order = absolute(l-b) + l-min-zap.
                                         Else l-order = l-min-zap - absolute(l-b).
                              End.
   End.
 assign
  v-protocol-date = today
  v-protocol-time = time
 .
if is-log = true then  put stream stream_order unformatted
">> Базовый способ расчета заказа "  v-protocol-date " " string(v-protocol-time,"hh:mm:ss") skip
   tmp#zakaz.gds-code " " tmp#zakaz.gds-name skip
   "Остаток на сегодня:" l-Ostatok-today skip
   "Отриц.остатки     :" l-negative-rest skip
   "дней до доставки  :" l-qnty-day      skip
   "дней в продаже    :" l-pay-day       skip
   "Темп продаж       :" l-Temp-rash     skip
   "Коррект.коэфф.    :" l-corr-coeff    skip
   "Дней без продажи  :" l-null-day      skip
   "MIN остаток       :" l-min-zap       skip
   "отриц.продажа     :" l-negative-sale skip
   "рассчитано заказа :" l-order         skip
   "_________________  "                 skip
   "min заказ         :" l-min-order     skip
   "товар в пути      :" l-goods-way     skip
   "срок хранения     :" l-deadline      skip
   .
l-type-MR = entry(2, entry(1,l-type-MR,";"),":") no-error .
if l-type-MR = ? then l-type-MR = "Базовый способ расчета заказа" .
v-stroka-protocol = "" .
v-stroka-protocol =
   "00.Метод расчета заказа:" + l-type-MR  + chr(4) +
   "01.Остаток на сегодня:" + string(l-Ostatok-today) + chr(4) +
   "02.Отриц.остатки     :" + string(l-negative-rest) + chr(4) +
   "03.дней до доставки  :" + string(l-qnty-day     ) + chr(4) +
   "04.дней в продаже    :" + string(l-pay-day      ) + chr(4) +
   "05.Темп продаж       :" + string(l-Temp-rash    ) + chr(4) +
   "05.1>>Коррект.коэфф. :" + string(l-corr-coeff   ) + chr(4) +
   "06.Дней без продажи  :" + string(l-null-day     ) + chr(4) +
   "07.MIN остаток       :" + string(l-min-zap      ) + chr(4) +
   "08.отриц.продажа     :" + string(l-negative-sale) + chr(4) +
   "09.рассчитано заказа :" + string(l-order        ) + chr(4) +
   "10.MIN заказ         :" + string(l-min-order    ) + chr(4) +
   "11.товар в пути      :" + string(l-goods-way    ) + chr(4) +
   "12.срок хранения     :" + string(l-deadline     ) + chr(4) .
  v-media-qnty = l-order .
  if (l-order - l-goods-way) < 0 then
     l-new-zakaz = 0 .
  else
     l-new-zakaz = l-order - l-goods-way .
 assign v-stroka-protocol = v-stroka-protocol + "13.1>>После учета товара в пути:" + string(l-new-zakaz) + chr(4)  .
  if l-min-ost = true then do:
      if l-Ostatok-today > l-min-zap then
          l-new-zakaz = 0 .
      assign v-stroka-protocol = v-stroka-protocol + "13.2>>После проверки на MIN остаток:" + string(l-new-zakaz) + chr(4)  .
  end.
if can-find(first ub.units where ub.units.unit-name = loc-unit-base
    and lookup('шту':U, ub.units.type) > 0)
    and trunc( l-new-zakaz, 0 ) <> l-new-zakaz then do:
        l-new-zakaz = trunc( l-new-zakaz, 0 ) + 1 .
        assign v-stroka-protocol = v-stroka-protocol + "13.3>>После округления до штук + 1:" + string(l-new-zakaz) + chr(4)  .
    end.
  if  l-deadline > 0 and l-tog-deadline = true   then do:
     l-new-zakaz = min(l-new-zakaz, l-Temp-rash * l-deadline ) .
     v-stroka-protocol = v-stroka-protocol + "13.4>>После проверки на срок хронения:" + string(l-new-zakaz) + chr(4)  .
 end .
 if l-tog-min-order then do:
  if ( l-new-zakaz - l-min-order) < 0 and l-min-order > 0 then
     l-new-zakaz = 0 .
     assign v-stroka-protocol = v-stroka-protocol + "13.5>>После проверки на MIN заказ:" + string(l-new-zakaz) + chr(4)  .
 end .
if l-new-zakaz = ? then l-new-zakaz = 0 .
if is-log = true then  put STREAM  stream_order unformatted "Итого (БЕЗ ОКР)"  l-new-zakaz skip
 .
if is-log = true then  OUTPUT  STREAM  stream_order CLOSE.
 assign v-stroka-protocol = v-stroka-protocol + "17.Итого рассчитано(БЕЗ ОКР):" + string(l-new-zakaz) .
  end.
 end.
end procedure.
procedure z-qnty-e :
 do
 on error undo, return error return-value
 :
  if p-mode-calc <> ""  then do:
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if is-log = true then Output stream stream_order to value ("order_raschet.txt") APPEND .
Assign
  l-Ostatok-today =  export-ras.qnty-stk
  l-negative-rest =  export-ras.negative-rest
  l-qnty-day      =  l-qnty-qnty
  l-pay-day       =  pay-day
  l-Temp-rash     = if export-ras.temp-rash < 0  then 0 else export-ras.temp-rash
  l-min-zap       =  export-ras.min-stock
  l-negative-sale =  p-neg-sale
  l-goods-way     =  v-gds-way-all
  l-tog-min-order =  p-t-min-zapas
  l-min-order     =  export-ras.min-order
  loc-unit-base   =  export-ras.unit-base
  l-min-ost       =  p-t-min-ost
  l-TOG-deadline  =  p-t-deadline
  l-deadline      =  export-ras.deadline
  l-type-MR       =  p-e-method
  l-corr-coeff    =  v-corr-coeff
  .
if l-Temp-rash = ? then l-Temp-rash = 0.
  if par-ord-min-ost = yes then do:
    assign l-min-zap = l-Temp-rash * l-corr-coeff * export-ras.min-stock .
  end.
  assign L-a = l-Ostatok-today - (l-Temp-rash * l-corr-coeff * l-qnty-day) .
  if L-a  <= 0 then do:
    if l-negative-rest = true then do:
      if l-negative-sale then do:
        Assign
          l-a = 0
          l-order = ABSOLUTE(l-a) + l-min-zap + (l-pay-day * l-Temp-rash * l-corr-coeff)
        .
      end.
      else do:
        assign l-order = ABSOLUTE(l-a) + l-min-zap + (l-pay-day * l-Temp-rash * l-corr-coeff).
      end.
    end.
    else do:
      Assign
        l-a = 0
        l-order = ABSOLUTE(l-a) + l-min-zap + (l-pay-day * l-Temp-rash * l-corr-coeff)
      .
    end.
  end.
  Else do :
    assign l-b = l-Ostatok-today - (l-Temp-rash * l-corr-coeff * (l-qnty-day + l-pay-day ) ) .
          if l-b >= l-min-zap then l-order = 0.
                              else DO:
                              If l-b < 0 Then l-order = absolute(l-b) + l-min-zap.
                                         Else l-order = l-min-zap - absolute(l-b).
                              End.
   End.
 assign
  v-protocol-date = today
  v-protocol-time = time
 .
if is-log = true then  put stream stream_order unformatted
">> Базовый способ расчета заказа "  v-protocol-date " " string(v-protocol-time,"hh:mm:ss") skip
   tmp#zakaz.gds-code " " tmp#zakaz.gds-name skip
   "Остаток на сегодня:" l-Ostatok-today skip
   "Отриц.остатки     :" l-negative-rest skip
   "дней до доставки  :" l-qnty-day      skip
   "дней в продаже    :" l-pay-day       skip
   "Темп продаж       :" l-Temp-rash     skip
   "Коррект.коэфф.    :" l-corr-coeff    skip
   "Дней без продажи  :" l-null-day      skip
   "MIN остаток       :" l-min-zap       skip
   "отриц.продажа     :" l-negative-sale skip
   "рассчитано заказа :" l-order         skip
   "_________________  "                 skip
   "min заказ         :" l-min-order     skip
   "товар в пути      :" l-goods-way     skip
   "срок хранения     :" l-deadline      skip
   .
l-type-MR = entry(2, entry(1,l-type-MR,";"),":") no-error .
if l-type-MR = ? then l-type-MR = "Базовый способ расчета заказа" .
v-stroka-protocol = "" .
v-stroka-protocol =
   "00.Метод расчета заказа:" + l-type-MR  + chr(4) +
   "01.Остаток на сегодня:" + string(l-Ostatok-today) + chr(4) +
   "02.Отриц.остатки     :" + string(l-negative-rest) + chr(4) +
   "03.дней до доставки  :" + string(l-qnty-day     ) + chr(4) +
   "04.дней в продаже    :" + string(l-pay-day      ) + chr(4) +
   "05.Темп продаж       :" + string(l-Temp-rash    ) + chr(4) +
   "05.1>>Коррект.коэфф. :" + string(l-corr-coeff   ) + chr(4) +
   "06.Дней без продажи  :" + string(l-null-day     ) + chr(4) +
   "07.MIN остаток       :" + string(l-min-zap      ) + chr(4) +
   "08.отриц.продажа     :" + string(l-negative-sale) + chr(4) +
   "09.рассчитано заказа :" + string(l-order        ) + chr(4) +
   "10.MIN заказ         :" + string(l-min-order    ) + chr(4) +
   "11.товар в пути      :" + string(l-goods-way    ) + chr(4) +
   "12.срок хранения     :" + string(l-deadline     ) + chr(4) .
  export-ras.order-qnty = l-order .
  if (l-order - l-goods-way) < 0 then
     l-new-zakaz = 0 .
  else
     l-new-zakaz = l-order - l-goods-way .
 assign v-stroka-protocol = v-stroka-protocol + "13.1>>После учета товара в пути:" + string(l-new-zakaz) + chr(4)  .
  if l-min-ost = true then do:
      if l-Ostatok-today > l-min-zap then
          l-new-zakaz = 0 .
      assign v-stroka-protocol = v-stroka-protocol + "13.2>>После проверки на MIN остаток:" + string(l-new-zakaz) + chr(4)  .
  end.
if can-find(first ub.units where ub.units.unit-name = loc-unit-base
    and lookup('шту':U, ub.units.type) > 0)
    and trunc( l-new-zakaz, 0 ) <> l-new-zakaz then do:
        l-new-zakaz = trunc( l-new-zakaz, 0 ) + 1 .
        assign v-stroka-protocol = v-stroka-protocol + "13.3>>После округления до штук + 1:" + string(l-new-zakaz) + chr(4)  .
    end.
  if  l-deadline > 0 and l-tog-deadline = true   then do:
     l-new-zakaz = min(l-new-zakaz, l-Temp-rash * l-deadline ) .
     v-stroka-protocol = v-stroka-protocol + "13.4>>После проверки на срок хронения:" + string(l-new-zakaz) + chr(4)  .
 end .
 if l-tog-min-order then do:
  if ( l-new-zakaz - l-min-order) < 0 and l-min-order > 0 then
     l-new-zakaz = 0 .
     assign v-stroka-protocol = v-stroka-protocol + "13.5>>После проверки на MIN заказ:" + string(l-new-zakaz) + chr(4)  .
 end .
if l-new-zakaz = ? then l-new-zakaz = 0 .
if is-log = true then  put STREAM  stream_order unformatted "Итого (БЕЗ ОКР)"  l-new-zakaz skip
 .
if is-log = true then  OUTPUT  STREAM  stream_order CLOSE.
 assign v-stroka-protocol = v-stroka-protocol + "17.Итого рассчитано(БЕЗ ОКР):" + string(l-new-zakaz) .
  end.
 end.
end procedure.
procedure v-qnty :
 do
 on error undo, return error return-value
 :
  if p-mode-calc = ""  then do:
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if is-log = true then Output stream stream_order to value ("order_raschet.txt") APPEND .
define variable loc-unit-base    as character no-undo .
define variable l-gar-zapas      as logical no-undo .
define variable l-tog-min-order  as logical no-undo .
define variable l-min-order      as decimal no-undo .
define variable l-min-ost         as logical   no-undo .
define variable  v-sigma          as decimal no-undo .
define variable  loc-rkv as decimal no-undo .
define variable  loc-q as integer no-undo .
define variable  p-serv     as decimal   no-undo .
define variable  p-x     as decimal   no-undo .
define variable v-norm-obr as decimal   no-undo .
Assign
  l-Ostatok-today =  tmp#zakaz.qnty-stk
  l-negative-rest =  tmp#zakaz.negative-rest
  l-qnty-day      =  l-qnty-qnty
  l-pay-day       =  pay-day
  l-Temp-rash     = if tmp#zakaz.temp-rash < 0  then 0 else tmp#zakaz.temp-rash
  l-min-zap       =  tmp#zakaz.min-stock
  l-negative-sale =  p-neg-sale
  l-goods-way     =  v-gds-way-all
  p-serv          =  tmp#zakaz.service-order
  l-gar-zapas     =  p-t-gar
  l-tog-min-order =  p-t-min-zapas
  l-min-order     =  tmp#zakaz.min-order
  loc-unit-base   =  tmp#zakaz.unit-base
  l-min-ost       =  p-t-min-ost
  l-TOG-deadline  =  p-t-deadline
  l-deadline      =  tmp#zakaz.deadline
  l-corr-coeff    =  v-corr-coeff
  .
if l-Temp-rash = ? then l-Temp-rash = 0.
 if par-ord-min-ost = yes then do:
    assign l-min-zap =  l-Temp-rash * l-corr-coeff * tmp#zakaz.min-stock .
 end.
   loc-rkv  = 0 .
   loc-q  = 0 .
   for each temp-gds-qnty :
       loc-rkv = loc-rkv + exp((temp-gds-qnty.rash  - l-Temp-rash * l-corr-coeff) , 2 ) .
       loc-q = loc-q  + temp-gds-qnty.qnty-day.
   end.
   define variable ll-i as integer no-undo .
   if  all-day - loc-q > 0 then do:
      do ll-i = 1 to  (all-day - loc-q) :
         loc-rkv = loc-rkv + exp(( 0  - l-Temp-rash * l-corr-coeff) , 2 ) .
      end.
   end.
   assign v-sigma =   sqrt( loc-rkv / ( all-day  - 1)) .
   if v-sigma = ? then v-sigma = 0 .
   if p-serv = ? or p-serv = 0 or p-serv = 1
   then p-serv = .5 .
   if l-Temp-rash = ? then l-Temp-rash = 0.
   run normobr in this-procedure
   ( input   p-serv    ,
     input   l-Temp-rash * l-corr-coeff  ,
     input   v-sigma ,
     output  p-x     )
     .
     assign v-norm-obr = p-x .
  if  p-x  - l-Temp-rash * l-corr-coeff < 0
      then p-x =  0 .
      else p-x = (p-x  - l-Temp-rash * l-corr-coeff ) * ( l-pay-day + l-qnty-day ) .
  assign L-a = l-Ostatok-today - ( l-Temp-rash * l-corr-coeff * l-qnty-day ) .
  if L-a  <= 0 then do:
          if l-negative-sale = true or l-negative-rest = false  then do:
              assign
             l-order = p-x + ( l-temp-rash * l-corr-coeff * l-pay-day )  +  l-min-zap .
             end.
             else do:
               assign
            l-order = p-x + ( l-temp-rash * l-corr-coeff  * l-pay-day )  + absolute(l-a)  +  l-min-zap .
              end.
            end.
   Else do :
      assign l-order = p-x + ( l-Temp-rash * l-corr-coeff * l-pay-day )  - l-a   +  l-min-zap .
   End.
   if  l-order < 0 then l-order = 0 .
 assign
  v-protocol-date = today
  v-protocol-time = time
 .
if is-log = true then  put stream stream_order unformatted
">> Вероятностный способ расчета заказа "  today " " string(time,"hh:mm:ss") skip
   tmp#zakaz.gds-code " " tmp#zakaz.gds-name skip
   "Остаток на сегодня:" l-Ostatok-today skip
   "Отриц.остатки     :" l-negative-rest skip
   "дней до доставки  :" l-qnty-day      skip
   "дней в продаже    :" l-pay-day       skip
   "Темп продаж       :" l-Temp-rash     skip
   "Корр.коеффициент  :" l-corr-coeff    skip
   "Уровень пост прис :" p-serv          skip
   "Среднеквадр откл  :" v-sigma         skip
   "F_нормобр         :" v-norm-obr      skip
   "гар.запас         :" p-x             skip
   "Дней без продажи  :" l-null-day      skip
   "MIN остаток       :" l-min-zap       skip
   "отриц.продажа     :" l-negative-sale skip
   "рассчитано заказа :" l-order         skip
   "_________________ "                  skip
   "min заказ         :" l-min-order     skip
   "товар в пути      :" l-goods-way     skip
   "срок хранения     :" l-deadline      skip
   .
v-stroka-protocol = "" .
v-stroka-protocol =
   "00.Метод расчета заказа:" + "Вероятностный способ расчета заказа" + chr(4) +
   "01.Остаток на сегодня:" + string(l-Ostatok-today) + chr(4) +
   "02.Отриц.остатки     :" + string(l-negative-rest) + chr(4) +
   "03.дней до доставки  :" + string(l-qnty-day     ) + chr(4) +
   "04.дней в продаже    :" + string(l-pay-day      ) + chr(4) +
   "05.Темп продаж       :" + string(l-Temp-rash    ) + chr(4) +
   "05.1>>Корр.коэфф.    :" + string(l-corr-coeff   ) + chr(4) +
   "06.Уровень постоянного присутствия :" + string(p-serv) + chr(4) +
   "07.Среднеквадр откл  :" + string(v-sigma        ) + chr(4) +
   "08.F_нормобр         :" + string(v-norm-obr     ) + chr(4) +
   "09.Гарантийный запас :" + string(p-x            ) + chr(4) +
   "10.Дней без продажи  :" + string(l-null-day     ) + chr(4) +
   "11.MIN остаток       :" + string(l-min-zap      ) + chr(4) +
   "12.отриц.продажа     :" + string(l-negative-sale) + chr(4) +
   "13.рассчитано заказа :" + string(l-order        ) + chr(4) +
   "14.MIN заказ         :" + string(l-min-order    ) + chr(4) +
   "15.товар в пути      :" + string(l-goods-way    ) + chr(4) +
   "16. срок хранения    :" + string(l-deadline     ) + chr(4) .
   v-media-qnty = l-order .
   if l-gar-zapas = true then do:
       if l-Ostatok-today >  p-x then
           assign
           l-order = 0
           l-new-zakaz = 0
           .
      assign v-stroka-protocol = v-stroka-protocol + "16.1>>После проверки на гарантийный запас:" + string(l-order) + chr(4)  .
   end.
   if l-min-ost = true then do:
       if l-Ostatok-today > l-min-zap then
           assign
           l-order = 0
           l-new-zakaz = 0
           .
      assign v-stroka-protocol = v-stroka-protocol + "16.2>>После проверки на MIN остаток:" + string(l-order) + chr(4)  .
   end.
  if (l-order - l-goods-way) < 0 then
     l-new-zakaz = 0 .
  else
     l-new-zakaz = l-order - l-goods-way .
assign v-stroka-protocol = v-stroka-protocol + "16.3>>После учета товара в пути:" + string(l-new-zakaz) + chr(4)  .
if can-find(first ub.units where ub.units.unit-name = loc-unit-base
    and lookup('шту':U, ub.units.type) > 0)
    and trunc( l-new-zakaz, 0 ) <> l-new-zakaz then do:
        l-new-zakaz = trunc( l-new-zakaz, 0 )  + 1 .
        assign v-stroka-protocol = v-stroka-protocol + "16.4>>После округления до штук + 1:" + string(l-new-zakaz) + chr(4)  .
 end.
 if  l-deadline > 0 and l-tog-deadline = true  then do:
     l-new-zakaz = min(l-new-zakaz, l-Temp-rash * l-deadline ) .
     v-stroka-protocol = v-stroka-protocol + "16.5>>После проверки на срок хронения:" + string(l-new-zakaz) + chr(4)  .
 end .
 if l-tog-min-order then do:
  if ( l-new-zakaz - l-min-order) < 0 and l-min-order > 0 then
     l-new-zakaz = 0 .
     assign v-stroka-protocol = v-stroka-protocol + "16.6>>После проверки на MIN заказ:" + string(l-new-zakaz) + chr(4)  .
 end .
 if l-new-zakaz = ? then l-new-zakaz = 0 .
if is-log = true then  put STREAM  stream_order unformatted "Итого(БЕЗ ОКР) "  l-new-zakaz skip
 "__________________________________________________"     skip
 .
if is-log = true then  OUTPUT  STREAM  stream_order CLOSE.
assign v-stroka-protocol = v-stroka-protocol + "17.Итого рассчитано(БЕЗ ОКР):" + string(l-new-zakaz) .
  end.
 end.
end procedure.
procedure v-qnty-e :
 do
 on error undo, return error return-value
 :
  if p-mode-calc <> ""  then do:
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if is-log = true then Output stream stream_order to value ("order_raschet.txt") APPEND .
define variable loc-unit-base    as character no-undo .
define variable l-gar-zapas      as logical no-undo .
define variable l-tog-min-order  as logical no-undo .
define variable l-min-order      as decimal no-undo .
define variable l-min-ost         as logical   no-undo .
define variable  v-sigma          as decimal no-undo .
define variable  loc-rkv as decimal no-undo .
define variable  loc-q as integer no-undo .
define variable  p-serv     as decimal   no-undo .
define variable  p-x     as decimal   no-undo .
define variable v-norm-obr as decimal   no-undo .
Assign
  l-Ostatok-today =  export-ras.qnty-stk
  l-negative-rest =  export-ras.negative-rest
  l-qnty-day      =  l-qnty-qnty
  l-pay-day       =  pay-day
  l-Temp-rash     = if export-ras.temp-rash < 0  then 0 else export-ras.temp-rash
  l-min-zap       =  export-ras.min-stock
  l-negative-sale =  p-neg-sale
  l-goods-way     =  v-gds-way-all
  p-serv          =  export-ras.service-order
  l-gar-zapas     =  p-t-gar
  l-tog-min-order =  p-t-min-zapas
  l-min-order     =  export-ras.min-order
  loc-unit-base   =  export-ras.unit-base
  l-min-ost       =  p-t-min-ost
  l-TOG-deadline  =  p-t-deadline
  l-deadline      =  export-ras.deadline
  l-corr-coeff    =  v-corr-coeff
  .
if l-Temp-rash = ? then l-Temp-rash = 0.
 if par-ord-min-ost = yes then do:
    assign l-min-zap =  l-Temp-rash * l-corr-coeff * export-ras.min-stock .
 end.
   loc-rkv  = 0 .
   loc-q  = 0 .
   for each temp-gds-qnty :
       loc-rkv = loc-rkv + exp((temp-gds-qnty.rash  - l-Temp-rash * l-corr-coeff) , 2 ) .
       loc-q = loc-q  + temp-gds-qnty.qnty-day.
   end.
   define variable ll-i as integer no-undo .
   if  all-day - loc-q > 0 then do:
      do ll-i = 1 to  (all-day - loc-q) :
         loc-rkv = loc-rkv + exp(( 0  - l-Temp-rash * l-corr-coeff) , 2 ) .
      end.
   end.
   assign v-sigma =   sqrt( loc-rkv / ( all-day  - 1)) .
   if v-sigma = ? then v-sigma = 0 .
   if p-serv = ? or p-serv = 0 or p-serv = 1
   then p-serv = .5 .
   if l-Temp-rash = ? then l-Temp-rash = 0.
   run normobr in this-procedure
   ( input   p-serv    ,
     input   l-Temp-rash * l-corr-coeff  ,
     input   v-sigma ,
     output  p-x     )
     .
     assign v-norm-obr = p-x .
  if  p-x  - l-Temp-rash * l-corr-coeff < 0
      then p-x =  0 .
      else p-x = (p-x  - l-Temp-rash * l-corr-coeff ) * ( l-pay-day + l-qnty-day ) .
  assign L-a = l-Ostatok-today - ( l-Temp-rash * l-corr-coeff * l-qnty-day ) .
  if L-a  <= 0 then do:
          if l-negative-sale = true or l-negative-rest = false  then do:
              assign
             l-order = p-x + ( l-temp-rash * l-corr-coeff * l-pay-day )  +  l-min-zap .
             end.
             else do:
               assign
            l-order = p-x + ( l-temp-rash * l-corr-coeff  * l-pay-day )  + absolute(l-a)  +  l-min-zap .
              end.
            end.
   Else do :
      assign l-order = p-x + ( l-Temp-rash * l-corr-coeff * l-pay-day )  - l-a   +  l-min-zap .
   End.
   if  l-order < 0 then l-order = 0 .
 assign
  v-protocol-date = today
  v-protocol-time = time
 .
if is-log = true then  put stream stream_order unformatted
">> Вероятностный способ расчета заказа "  today " " string(time,"hh:mm:ss") skip
   tmp#zakaz.gds-code " " tmp#zakaz.gds-name skip
   "Остаток на сегодня:" l-Ostatok-today skip
   "Отриц.остатки     :" l-negative-rest skip
   "дней до доставки  :" l-qnty-day      skip
   "дней в продаже    :" l-pay-day       skip
   "Темп продаж       :" l-Temp-rash     skip
   "Корр.коеффициент  :" l-corr-coeff    skip
   "Уровень пост прис :" p-serv          skip
   "Среднеквадр откл  :" v-sigma         skip
   "F_нормобр         :" v-norm-obr      skip
   "гар.запас         :" p-x             skip
   "Дней без продажи  :" l-null-day      skip
   "MIN остаток       :" l-min-zap       skip
   "отриц.продажа     :" l-negative-sale skip
   "рассчитано заказа :" l-order         skip
   "_________________ "                  skip
   "min заказ         :" l-min-order     skip
   "товар в пути      :" l-goods-way     skip
   "срок хранения     :" l-deadline      skip
   .
v-stroka-protocol = "" .
v-stroka-protocol =
   "00.Метод расчета заказа:" + "Вероятностный способ расчета заказа" + chr(4) +
   "01.Остаток на сегодня:" + string(l-Ostatok-today) + chr(4) +
   "02.Отриц.остатки     :" + string(l-negative-rest) + chr(4) +
   "03.дней до доставки  :" + string(l-qnty-day     ) + chr(4) +
   "04.дней в продаже    :" + string(l-pay-day      ) + chr(4) +
   "05.Темп продаж       :" + string(l-Temp-rash    ) + chr(4) +
   "05.1>>Корр.коэфф.    :" + string(l-corr-coeff   ) + chr(4) +
   "06.Уровень постоянного присутствия :" + string(p-serv) + chr(4) +
   "07.Среднеквадр откл  :" + string(v-sigma        ) + chr(4) +
   "08.F_нормобр         :" + string(v-norm-obr     ) + chr(4) +
   "09.Гарантийный запас :" + string(p-x            ) + chr(4) +
   "10.Дней без продажи  :" + string(l-null-day     ) + chr(4) +
   "11.MIN остаток       :" + string(l-min-zap      ) + chr(4) +
   "12.отриц.продажа     :" + string(l-negative-sale) + chr(4) +
   "13.рассчитано заказа :" + string(l-order        ) + chr(4) +
   "14.MIN заказ         :" + string(l-min-order    ) + chr(4) +
   "15.товар в пути      :" + string(l-goods-way    ) + chr(4) +
   "16. срок хранения    :" + string(l-deadline     ) + chr(4) .
   export-ras.order-qnty = l-order .
   if l-gar-zapas = true then do:
       if l-Ostatok-today >  p-x then
           assign
           l-order = 0
           l-new-zakaz = 0
           .
      assign v-stroka-protocol = v-stroka-protocol + "16.1>>После проверки на гарантийный запас:" + string(l-order) + chr(4)  .
   end.
   if l-min-ost = true then do:
       if l-Ostatok-today > l-min-zap then
           assign
           l-order = 0
           l-new-zakaz = 0
           .
      assign v-stroka-protocol = v-stroka-protocol + "16.2>>После проверки на MIN остаток:" + string(l-order) + chr(4)  .
   end.
  if (l-order - l-goods-way) < 0 then
     l-new-zakaz = 0 .
  else
     l-new-zakaz = l-order - l-goods-way .
assign v-stroka-protocol = v-stroka-protocol + "16.3>>После учета товара в пути:" + string(l-new-zakaz) + chr(4)  .
if can-find(first ub.units where ub.units.unit-name = loc-unit-base
    and lookup('шту':U, ub.units.type) > 0)
    and trunc( l-new-zakaz, 0 ) <> l-new-zakaz then do:
        l-new-zakaz = trunc( l-new-zakaz, 0 )  + 1 .
        assign v-stroka-protocol = v-stroka-protocol + "16.4>>После округления до штук + 1:" + string(l-new-zakaz) + chr(4)  .
 end.
 if  l-deadline > 0 and l-tog-deadline = true  then do:
     l-new-zakaz = min(l-new-zakaz, l-Temp-rash * l-deadline ) .
     v-stroka-protocol = v-stroka-protocol + "16.5>>После проверки на срок хронения:" + string(l-new-zakaz) + chr(4)  .
 end .
 if l-tog-min-order then do:
  if ( l-new-zakaz - l-min-order) < 0 and l-min-order > 0 then
     l-new-zakaz = 0 .
     assign v-stroka-protocol = v-stroka-protocol + "16.6>>После проверки на MIN заказ:" + string(l-new-zakaz) + chr(4)  .
 end .
 if l-new-zakaz = ? then l-new-zakaz = 0 .
if is-log = true then  put STREAM  stream_order unformatted "Итого(БЕЗ ОКР) "  l-new-zakaz skip
 "__________________________________________________"     skip
 .
if is-log = true then  OUTPUT  STREAM  stream_order CLOSE.
assign v-stroka-protocol = v-stroka-protocol + "17.Итого рассчитано(БЕЗ ОКР):" + string(l-new-zakaz) .
  end.
 end.
end procedure.
procedure m-qnty :
 do
 on error undo, return error return-value
 :
  if p-mode-calc = ""  then do:
define variable  vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable l-gar-zapas      as logical no-undo .
define variable l-tog-min-order  as logical no-undo .
define variable l-min-order      as decimal no-undo .
define variable loc-unit-base  as character no-undo .
define variable v-sigma    as decimal no-undo .
define variable loc-max    as decimal no-undo .
define variable loc-max-old as decimal no-undo .
define variable loc-q      as integer no-undo .
define variable p-serv     as decimal   no-undo .
define variable p-x        as decimal   no-undo .
define variable l-min-ost         as logical   no-undo .
define output parameter par-loc-max as decimal no-undo .
if is-log = true then Output stream stream_order to value ("order_raschet.txt") APPEND .
Assign
  l-Ostatok-today =  tmp#zakaz.qnty-stk
  l-negative-rest =  tmp#zakaz.negative-rest
  l-qnty-day      =  l-qnty-qnty
  l-pay-day       =  pay-day
  l-Temp-rash     =  if tmp#zakaz.temp-rash < 0  then 0 else tmp#zakaz.temp-rash
  l-min-zap       =  tmp#zakaz.min-stock
  l-negative-sale =  p-neg-sale
  l-goods-way     =  v-gds-way-all
  p-serv          =  tmp#zakaz.service-order
  l-gar-zapas     =  p-t-gar
  l-tog-min-order =  p-t-min-zapas
  l-min-order     =  tmp#zakaz.min-order
  loc-unit-base   =  tmp#zakaz.unit-base
  l-min-ost = p-t-min-ost
  l-TOG-deadline  =  p-t-deadline
  l-deadline      =  tmp#zakaz.deadline
  .
if l-Temp-rash = ? then l-Temp-rash = 0.
   assign
    loc-q  = 0
    loc-max-old = 0
    loc-max = 0
   .
  for each temp-gds-qnty where temp-gds-qnty.rash >= 0 :
      if temp-gds-qnty.rash > loc-max   then   loc-max = temp-gds-qnty.rash  .
      assign loc-max-old = temp-gds-qnty.rash  .
   end.
  for each temp-gds-qnty where temp-gds-qnty.rash >= 0 :
      delete temp-gds-qnty.
   end.
   if loc-max < 0     then loc-max = 0 .
   if loc-max-old < 0 then loc-max-old = 0 .
 if par-ord-min-ost = yes then do:
    assign l-min-zap =  loc-max * tmp#zakaz.min-stock .
 end.
  par-loc-max = loc-max .
  L-a = l-Ostatok-today - ( loc-max  * l-qnty-day ) .
  if L-a  <= 0 then do:
          if l-negative-sale = true or l-negative-rest = false   then do:
              assign
                  l-order = ( loc-max  * l-pay-day )  +  l-min-zap .
             end.
             else do:
               assign
                  l-order =  ( loc-max  * l-pay-day )  + absolute(l-a)  +  l-min-zap .
              end.
            end.
   Else do :
        assign l-order = ( loc-max  * l-pay-day )  - l-a   +  l-min-zap .
   End.
   if  l-order < 0 then l-order = 0 .
 assign
  v-protocol-date = today
  v-protocol-time = time
 .
 if is-log = true then  put stream stream_order unformatted
">> Расчет заказа по максимальной продаже "  today " " string(time,"hh:mm:ss") skip
   tmp#zakaz.gds-code " " tmp#zakaz.gds-name skip
   "Остаток на сегодня:" l-Ostatok-today skip
   "Отриц.остатки     :" l-negative-rest skip
   "отриц.продажа     :" l-negative-sale skip
   "дней до доставки  :" l-qnty-day      skip
   "дней в продаже    :" l-pay-day       skip
   "MAX продажа       :" loc-max         skip
   "MIN остаток       :" l-min-zap       skip
   "рассчитано заказа :" l-order         skip
   "_________________ "                  skip
   "min заказ         :" l-min-order     skip
   "товар в пути      :" l-goods-way     skip
   "срок хранения     :" l-deadline skip
   .
v-stroka-protocol = "" .
v-stroka-protocol =
   "00.Метод расчета заказа:" + "Расчет до максимальной продажи" + chr(4) +
   "01.Остаток на сегодня:" + string(l-Ostatok-today) + chr(4) +
   "02.Отриц.остатки     :" + string(l-negative-rest) + chr(4) +
   "03.отриц.продажа     :" + string(l-negative-sale) + chr(4) +
   "04.дней до доставки  :" + string(l-qnty-day     ) + chr(4) +
   "05.дней в продаже    :" + string(l-pay-day      ) + chr(4) +
   "06.MAX продажа       :" + string(loc-max        ) + chr(4) +
   "07.MIN остаток       :" + string(l-min-zap      ) + chr(4) +
   "08.рассчитано заказа :" + string(l-order        ) + chr(4) +
   "09.MIN заказ         :" + string(l-min-order    ) + chr(4) +
   "10.товар в пути      :" + string(l-goods-way    ) + chr(4) +
   "11.срок хранения     :" + string(l-deadline     ) + chr(4) .
v-media-qnty = l-order .
  if l-min-ost = true then do:
     if l-Ostatok-today > l-min-zap then
       assign
        l-order = 0
        l-new-zakaz = 0
        .
     assign v-stroka-protocol = v-stroka-protocol + "12.1>>После проверки на MIN остаток:" + string(l-order) + chr(4).
  end.
  if (l-order - l-goods-way) < 0 then
     l-new-zakaz = 0 .
  else
     l-new-zakaz = l-order - l-goods-way .
  assign v-stroka-protocol = v-stroka-protocol + "12.2>>После учета товара в пути:" + string(l-new-zakaz) + chr(4)  .
if can-find(first ub.units where ub.units.unit-name = loc-unit-base
  and lookup('шту':U, ub.units.type) > 0)
  and trunc( l-new-zakaz, 0 ) <> l-new-zakaz then do:
      l-new-zakaz = trunc( l-new-zakaz, 0 )  + 1 .
      v-stroka-protocol = v-stroka-protocol + "12.3>>После округления до штук + 1:" + string(l-new-zakaz) + chr(4)  .
  end.
 if  l-deadline > 0 and l-tog-deadline = true  then do:
     l-new-zakaz = min(l-new-zakaz, l-Temp-rash * l-deadline ) .
     assign v-stroka-protocol = v-stroka-protocol + "12.4>>После проверки на срок хронения:" + string(l-new-zakaz) + chr(4)  .
 end .
 if l-tog-min-order then do:
    if (l-new-zakaz - l-min-order) < 0 and l-min-order > 0 then
        l-new-zakaz = 0 .
    assign v-stroka-protocol = v-stroka-protocol + "12.5>>После проверки на MIN заказ:" + string(l-new-zakaz) + chr(4)  .
 end .
if l-new-zakaz = ? then l-new-zakaz = 0 .
if is-log = true then  put STREAM  stream_order unformatted "Итого(БЕЗ ОКР) "  l-new-zakaz skip
 "__________________________________________________"     skip
 .
if is-log = true then  OUTPUT  STREAM  stream_order CLOSE.
assign v-stroka-protocol = v-stroka-protocol + "17.Итого рассчитано(БЕЗ ОКР):" + string(l-new-zakaz) .
  end.
 end.
end procedure.
procedure m-qnty-e :
 do
 on error undo, return error return-value
 :
 if p-mode-calc <> ""  then do:
define variable  vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable l-gar-zapas      as logical no-undo .
define variable l-tog-min-order  as logical no-undo .
define variable l-min-order      as decimal no-undo .
define variable loc-unit-base  as character no-undo .
define variable v-sigma    as decimal no-undo .
define variable loc-max    as decimal no-undo .
define variable loc-max-old as decimal no-undo .
define variable loc-q      as integer no-undo .
define variable p-serv     as decimal   no-undo .
define variable p-x        as decimal   no-undo .
define variable l-min-ost         as logical   no-undo .
define output parameter par-loc-max as decimal no-undo .
if is-log = true then Output stream stream_order to value ("order_raschet.txt") APPEND .
Assign
  l-Ostatok-today =  export-ras.qnty-stk
  l-negative-rest =  export-ras.negative-rest
  l-qnty-day      =  l-qnty-qnty
  l-pay-day       =  pay-day
  l-Temp-rash     =  if export-ras.temp-rash < 0  then 0 else export-ras.temp-rash
  l-min-zap       =  export-ras.min-stock
  l-negative-sale =  p-neg-sale
  l-goods-way     =  v-gds-way-all
  p-serv          =  export-ras.service-order
  l-gar-zapas     =  p-t-gar
  l-tog-min-order =  p-t-min-zapas
  l-min-order     =  export-ras.min-order
  loc-unit-base   =  export-ras.unit-base
  l-min-ost = p-t-min-ost
  l-TOG-deadline  =  p-t-deadline
  l-deadline      =  export-ras.deadline
  .
if l-Temp-rash = ? then l-Temp-rash = 0.
   assign
    loc-q  = 0
    loc-max-old = 0
    loc-max = 0
   .
  for each temp-gds-qnty where temp-gds-qnty.rash >= 0 :
      if temp-gds-qnty.rash > loc-max   then   loc-max = temp-gds-qnty.rash  .
      assign loc-max-old = temp-gds-qnty.rash  .
   end.
  for each temp-gds-qnty where temp-gds-qnty.rash >= 0 :
      delete temp-gds-qnty.
   end.
   if loc-max < 0     then loc-max = 0 .
   if loc-max-old < 0 then loc-max-old = 0 .
 if par-ord-min-ost = yes then do:
    assign l-min-zap =  loc-max * export-ras.min-stock .
 end.
  par-loc-max = loc-max .
  L-a = l-Ostatok-today - ( loc-max  * l-qnty-day ) .
  if L-a  <= 0 then do:
          if l-negative-sale = true or l-negative-rest = false   then do:
              assign
                  l-order = ( loc-max  * l-pay-day )  +  l-min-zap .
             end.
             else do:
               assign
                  l-order =  ( loc-max  * l-pay-day )  + absolute(l-a)  +  l-min-zap .
              end.
            end.
   Else do :
        assign l-order = ( loc-max  * l-pay-day )  - l-a   +  l-min-zap .
   End.
   if  l-order < 0 then l-order = 0 .
 assign
  v-protocol-date = today
  v-protocol-time = time
 .
 if is-log = true then  put stream stream_order unformatted
">> Расчет заказа по максимальной продаже "  today " " string(time,"hh:mm:ss") skip
   tmp#zakaz.gds-code " " tmp#zakaz.gds-name skip
   "Остаток на сегодня:" l-Ostatok-today skip
   "Отриц.остатки     :" l-negative-rest skip
   "отриц.продажа     :" l-negative-sale skip
   "дней до доставки  :" l-qnty-day      skip
   "дней в продаже    :" l-pay-day       skip
   "MAX продажа       :" loc-max         skip
   "MIN остаток       :" l-min-zap       skip
   "рассчитано заказа :" l-order         skip
   "_________________ "                  skip
   "min заказ         :" l-min-order     skip
   "товар в пути      :" l-goods-way     skip
   "срок хранения     :" l-deadline skip
   .
v-stroka-protocol = "" .
v-stroka-protocol =
   "00.Метод расчета заказа:" + "Расчет до максимальной продажи" + chr(4) +
   "01.Остаток на сегодня:" + string(l-Ostatok-today) + chr(4) +
   "02.Отриц.остатки     :" + string(l-negative-rest) + chr(4) +
   "03.отриц.продажа     :" + string(l-negative-sale) + chr(4) +
   "04.дней до доставки  :" + string(l-qnty-day     ) + chr(4) +
   "05.дней в продаже    :" + string(l-pay-day      ) + chr(4) +
   "06.MAX продажа       :" + string(loc-max        ) + chr(4) +
   "07.MIN остаток       :" + string(l-min-zap      ) + chr(4) +
   "08.рассчитано заказа :" + string(l-order        ) + chr(4) +
   "09.MIN заказ         :" + string(l-min-order    ) + chr(4) +
   "10.товар в пути      :" + string(l-goods-way    ) + chr(4) +
   "11.срок хранения     :" + string(l-deadline     ) + chr(4) .
export-ras.order-qnty = l-order .
  if l-min-ost = true then do:
     if l-Ostatok-today > l-min-zap then
       assign
        l-order = 0
        l-new-zakaz = 0
        .
     assign v-stroka-protocol = v-stroka-protocol + "12.1>>После проверки на MIN остаток:" + string(l-order) + chr(4).
  end.
  if (l-order - l-goods-way) < 0 then
     l-new-zakaz = 0 .
  else
     l-new-zakaz = l-order - l-goods-way .
  assign v-stroka-protocol = v-stroka-protocol + "12.2>>После учета товара в пути:" + string(l-new-zakaz) + chr(4)  .
if can-find(first ub.units where ub.units.unit-name = loc-unit-base
  and lookup('шту':U, ub.units.type) > 0)
  and trunc( l-new-zakaz, 0 ) <> l-new-zakaz then do:
      l-new-zakaz = trunc( l-new-zakaz, 0 )  + 1 .
      v-stroka-protocol = v-stroka-protocol + "12.3>>После округления до штук + 1:" + string(l-new-zakaz) + chr(4)  .
  end.
 if  l-deadline > 0 and l-tog-deadline = true  then do:
     l-new-zakaz = min(l-new-zakaz, l-Temp-rash * l-deadline ) .
     assign v-stroka-protocol = v-stroka-protocol + "12.4>>После проверки на срок хронения:" + string(l-new-zakaz) + chr(4)  .
 end .
 if l-tog-min-order then do:
    if (l-new-zakaz - l-min-order) < 0 and l-min-order > 0 then
        l-new-zakaz = 0 .
    assign v-stroka-protocol = v-stroka-protocol + "12.5>>После проверки на MIN заказ:" + string(l-new-zakaz) + chr(4)  .
 end .
if l-new-zakaz = ? then l-new-zakaz = 0 .
if is-log = true then  put STREAM  stream_order unformatted "Итого(БЕЗ ОКР) "  l-new-zakaz skip
 "__________________________________________________"     skip
 .
if is-log = true then  OUTPUT  STREAM  stream_order CLOSE.
assign v-stroka-protocol = v-stroka-protocol + "17.Итого рассчитано(БЕЗ ОКР):" + string(l-new-zakaz) .
  end.
 end.
end procedure.
procedure calc-null-day :
 do
 on error undo, return error return-value
 :
 l-null-day = 0 .
 IF p-type-qnty-day = 2   then do :
    for each temp-gds-qnty  :
       if  temp-gds-qnty.rash = 0  and  temp-gds-qnty.ost = 0 then
          l-null-day = l-null-day + temp-gds-qnty.qnty-day  .
     end.
  end.
  end.
end procedure.
procedure calc-sale :
 do
 on error undo, return error return-value
 :
      for each obj-list no-lock :
        run ob-line in this-procedure  (
            input   obj-list.obj-code   ,
            input   obj-list.obj-type   ,
            input   tmp#zakaz.artic       ,
            input   tmp#zakaz.prod-code   ,
            input   tmp#zakaz.prod-type   ,
            input    fact-order-1,
            input    fact-order-2,
            input   'cost':U    ,
            input   '##,##':U ,
            input   ""    ,
            input   false ,
            input   false ,
            output v-prih ,
            output v-rash ,
            output v-kassa
            )  no-error .
          assign
            d-rash  = d-rash  + v-rash
            d-kassa = d-kassa + v-kassa
            prih  = prih +  v-prih
            rash  = rash  + v-rash
            kassa = kassa + v-kassa
          .
          end.
 end.
end procedure.
procedure u-qnty :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
  if p-mode-calc = ""  then do:
def var vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if is-log = true then Output stream stream_order to value ("order_raschet.txt") APPEND .
define var l-max-zap        as decimal no-undo .
define variable l-min-ost         as logical   no-undo .
Assign
  l-max-zap       =  tmp#zakaz.max-stock
  l-Ostatok-today =  tmp#zakaz.qnty-stk
  l-negative-rest =  tmp#zakaz.negative-rest
  l-min-zap       =  tmp#zakaz.min-stock
  l-negative-sale =  p-neg-sale
  l-goods-way     =  v-gds-way
  l-tog-min-order =  p-t-min-zapas
  l-min-order     =  tmp#zakaz.min-order
  loc-unit-base   =  tmp#zakaz.unit-base
  l-min-ost       =  p-t-min-ost
  l-TOG-deadline  =  p-t-deadline
  l-deadline      =  tmp#zakaz.deadline
  l-Temp-rash     =  tmp#zakaz.temp-rash
  l-corr-coeff    =  v-corr-coeff
  .
if l-Temp-rash = ? then l-Temp-rash = 0.
 if par-ord-min-ost = yes then do:
    assign l-min-zap =  l-Temp-rash * l-corr-coeff * tmp#zakaz.min-stock .
 end.
  L-a = l-Ostatok-today  .
  if L-a  <= 0 then do:
      if l-negative-rest = true then do:
          if l-negative-sale then do:
            assign
            l-order =  l-max-zap
            .
          end.
          else do:
            assign
              l-order = absolute(l-a) + l-max-zap
            .
          end.
      end.
      else do:
          assign
            l-order = l-max-zap
            .
      end.
   End.
   Else do :
      if ( l-max-zap - l-Ostatok-today ) >= 0 then  l-order = l-max-zap - l-Ostatok-today .
                                              else  l-order = 0 .
   End.
 assign
  v-protocol-date = today
  v-protocol-time = time
 .
 if is-log = true then  put stream stream_order unformatted
">> Довести заказ до максимального остатка "  today " " string(time,"hh:mm:ss") skip
   tmp#zakaz.gds-code " " tmp#zakaz.gds-name skip
   "Остаток на сегодня:" l-Ostatok-today skip
   "Отриц.остатки     :" l-negative-rest skip
   "MIN остаток       :" l-min-zap       skip
   "MAX остаток       :" l-max-zap       skip
   "отриц.продажа     :" l-negative-sale skip
   "рассчитано заказа :" l-order         skip
   "_________________ "                  skip
   "min заказ         :" l-min-order     skip
   "товар в пути      :" l-goods-way     skip
   "срок хранения     :" l-deadline      skip
   .
v-stroka-protocol = "" .
v-stroka-protocol =
   "00.Метод расчета заказа:" + "Довести заказ до максимального остатка" + chr(4) +
   "01.Остаток на сегодня:" + string(l-Ostatok-today) + chr(4) +
   "02.Отриц.остатки     :" + string(l-negative-rest) + chr(4) +
   "03.MIN остаток       :" + string(l-min-zap      ) + chr(4) +
   "04.MAX остаток       :" + string(l-max-zap      ) + chr(4) +
   "05.отриц.продажа     :" + string(l-negative-sale) + chr(4) +
   "06.рассчитано заказа :" + string(l-order        ) + chr(4) +
   "07.min заказ         :" + string(l-min-order    ) + chr(4) +
   "08.товар в пути      :" + string(l-goods-way    ) + chr(4) +
   "09.срок хранения     :" + string(l-deadline     ) + chr(4) .
v-media-qnty = l-order .
   if l-min-ost = true then do:
       if l-Ostatok-today > l-min-zap then
           assign
            l-order = 0
            l-new-zakaz = 0
           .
      assign v-stroka-protocol = v-stroka-protocol + "10.1>>После проверки на MIN остаток:" + string(l-order) + chr(4)  .
   end.
  if (l-order - l-goods-way) < 0 then
     l-new-zakaz = 0 .
  else
     l-new-zakaz = l-order - l-goods-way .
  assign v-stroka-protocol = v-stroka-protocol + "10.2>>После учета товара в пути:" + string(l-new-zakaz) + chr(4)  .
if can-find(first ub.units where ub.units.unit-name = loc-unit-base
    and lookup('шту':U, ub.units.type) > 0)
    and trunc( l-new-zakaz, 0 ) <> l-new-zakaz then do:
        l-new-zakaz = trunc( l-new-zakaz, 0 ) + 1 .
        assign v-stroka-protocol = v-stroka-protocol + "10.3>>После округления до штук + 1:" + string(l-new-zakaz) + chr(4)  .
    end.
  if  l-deadline > 0 and l-tog-deadline = true  then do:
     l-new-zakaz = min(l-new-zakaz, l-Temp-rash * l-deadline ) .
     v-stroka-protocol = v-stroka-protocol + "10.4>>После проверки на срок хронения:" + string(l-new-zakaz) + chr(4)  .
 end .
 if l-tog-min-order then do:
  if (l-new-zakaz - l-min-order) < 0 and l-min-order > 0 then
     l-new-zakaz = 0 .
     assign v-stroka-protocol = v-stroka-protocol + "10.5>>После проверки на MIN заказ:" + string(l-new-zakaz) + chr(4)  .
 end .
if l-new-zakaz = ? then l-new-zakaz = 0 .
if is-log = true then  put STREAM  stream_order unformatted "Итого(БЕЗ ОКР) "  l-new-zakaz skip
 "__________________________________________________"     skip
 .
if is-log = true then  OUTPUT  STREAM  stream_order CLOSE.
assign v-stroka-protocol = v-stroka-protocol + "17.Итого рассчитано(БЕЗ ОКР):" + string(l-new-zakaz) .
  end.
 end.
end procedure.
procedure u-qnty-e :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
  if p-mode-calc <> ""  then do:
def var vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if is-log = true then Output stream stream_order to value ("order_raschet.txt") APPEND .
define var l-max-zap        as decimal no-undo .
define variable l-min-ost         as logical   no-undo .
Assign
  l-max-zap       =  export-ras.max-stock
  l-Ostatok-today =  export-ras.qnty-stk
  l-negative-rest =  export-ras.negative-rest
  l-min-zap       =  export-ras.min-stock
  l-negative-sale =  p-neg-sale
  l-goods-way     =  v-gds-way
  l-tog-min-order =  p-t-min-zapas
  l-min-order     =  export-ras.min-order
  loc-unit-base   =  export-ras.unit-base
  l-min-ost       =  p-t-min-ost
  l-TOG-deadline  =  p-t-deadline
  l-deadline      =  export-ras.deadline
  l-Temp-rash     =  export-ras.temp-rash
  l-corr-coeff    =  v-corr-coeff
  .
if l-Temp-rash = ? then l-Temp-rash = 0.
 if par-ord-min-ost = yes then do:
    assign l-min-zap =  l-Temp-rash * l-corr-coeff * export-ras.min-stock .
 end.
  L-a = l-Ostatok-today  .
  if L-a  <= 0 then do:
      if l-negative-rest = true then do:
          if l-negative-sale then do:
            assign
            l-order =  l-max-zap
            .
          end.
          else do:
            assign
              l-order = absolute(l-a) + l-max-zap
            .
          end.
      end.
      else do:
          assign
            l-order = l-max-zap
            .
      end.
   End.
   Else do :
      if ( l-max-zap - l-Ostatok-today ) >= 0 then  l-order = l-max-zap - l-Ostatok-today .
                                              else  l-order = 0 .
   End.
 assign
  v-protocol-date = today
  v-protocol-time = time
 .
 if is-log = true then  put stream stream_order unformatted
">> Довести заказ до максимального остатка "  today " " string(time,"hh:mm:ss") skip
   tmp#zakaz.gds-code " " tmp#zakaz.gds-name skip
   "Остаток на сегодня:" l-Ostatok-today skip
   "Отриц.остатки     :" l-negative-rest skip
   "MIN остаток       :" l-min-zap       skip
   "MAX остаток       :" l-max-zap       skip
   "отриц.продажа     :" l-negative-sale skip
   "рассчитано заказа :" l-order         skip
   "_________________ "                  skip
   "min заказ         :" l-min-order     skip
   "товар в пути      :" l-goods-way     skip
   "срок хранения     :" l-deadline      skip
   .
v-stroka-protocol = "" .
v-stroka-protocol =
   "00.Метод расчета заказа:" + "Довести заказ до максимального остатка" + chr(4) +
   "01.Остаток на сегодня:" + string(l-Ostatok-today) + chr(4) +
   "02.Отриц.остатки     :" + string(l-negative-rest) + chr(4) +
   "03.MIN остаток       :" + string(l-min-zap      ) + chr(4) +
   "04.MAX остаток       :" + string(l-max-zap      ) + chr(4) +
   "05.отриц.продажа     :" + string(l-negative-sale) + chr(4) +
   "06.рассчитано заказа :" + string(l-order        ) + chr(4) +
   "07.min заказ         :" + string(l-min-order    ) + chr(4) +
   "08.товар в пути      :" + string(l-goods-way    ) + chr(4) +
   "09.срок хранения     :" + string(l-deadline     ) + chr(4) .
export-ras.order-qnty = l-order .
   if l-min-ost = true then do:
       if l-Ostatok-today > l-min-zap then
           assign
            l-order = 0
            l-new-zakaz = 0
           .
      assign v-stroka-protocol = v-stroka-protocol + "10.1>>После проверки на MIN остаток:" + string(l-order) + chr(4)  .
   end.
  if (l-order - l-goods-way) < 0 then
     l-new-zakaz = 0 .
  else
     l-new-zakaz = l-order - l-goods-way .
  assign v-stroka-protocol = v-stroka-protocol + "10.2>>После учета товара в пути:" + string(l-new-zakaz) + chr(4)  .
if can-find(first ub.units where ub.units.unit-name = loc-unit-base
    and lookup('шту':U, ub.units.type) > 0)
    and trunc( l-new-zakaz, 0 ) <> l-new-zakaz then do:
        l-new-zakaz = trunc( l-new-zakaz, 0 ) + 1 .
        assign v-stroka-protocol = v-stroka-protocol + "10.3>>После округления до штук + 1:" + string(l-new-zakaz) + chr(4)  .
    end.
  if  l-deadline > 0 and l-tog-deadline = true  then do:
     l-new-zakaz = min(l-new-zakaz, l-Temp-rash * l-deadline ) .
     v-stroka-protocol = v-stroka-protocol + "10.4>>После проверки на срок хронения:" + string(l-new-zakaz) + chr(4)  .
 end .
 if l-tog-min-order then do:
  if (l-new-zakaz - l-min-order) < 0 and l-min-order > 0 then
     l-new-zakaz = 0 .
     assign v-stroka-protocol = v-stroka-protocol + "10.5>>После проверки на MIN заказ:" + string(l-new-zakaz) + chr(4)  .
 end .
if l-new-zakaz = ? then l-new-zakaz = 0 .
if is-log = true then  put STREAM  stream_order unformatted "Итого(БЕЗ ОКР) "  l-new-zakaz skip
 "__________________________________________________"     skip
 .
if is-log = true then  OUTPUT  STREAM  stream_order CLOSE.
assign v-stroka-protocol = v-stroka-protocol + "17.Итого рассчитано(БЕЗ ОКР):" + string(l-new-zakaz) .
   end.
 end.
end procedure.
