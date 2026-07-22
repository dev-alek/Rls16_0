using Progress.Lang.*.
using Ibs.Th.Gbl.ReportXml.
using Ibs.Th.Gbl.rep-out.
block-level on error undo, throw.
define input parameter parParentProc as handle no-undo.
define input parameter p-cb-disType as character no-undo.
def var vss-revision    as character no-undo init "$Revision: a8e2cf75ddf6, 2506, rls $":U .
def var vss-author      as character no-undo init "$Author: EShklyar $":U .
def var vss-date        as character no-undo init "$Date: Ср июл 08 17:09:06 2020 +0300 $":U .
def var vss-workfile    as character no-undo init "$Workfile: r-xldln2.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/r-xldln2.p $":U .
def var vss-description as character no-undo init "r-Отчет по типам скидки (карты ЛНР)".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable var-report-r-b as character no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable xml_tmp as character no-undo.
define variable Report as class ReportXml no-undo.
define variable gds-str as character no-undo init "".
define variable xslt-path as character no-undo.
define variable rep-out-unit as class rep-out no-undo.
define variable v-total-qnty as decimal no-undo.
define variable v-total-sum1 as decimal no-undo.
define variable v-total-sum2 as decimal no-undo.
define variable v-cnt as integer no-undo.
define variable v-cnt2 as integer no-undo.
define variable g#report-num as integer no-undo.
define variable v-full-path-RepView as character no-undo.
define variable v-file-name-rep-htm as character no-undo.
define variable v-choice-gds as character no-undo.
define variable v-type-discount as character no-undo.
define variable v-choice-obj as character no-undo.
define temp-table tt-line no-undo
    field chk-date as date
    field chk-time as integer
    field d-card as character
    field pay-desk as integer
    field obj-name as character
    field obj-type as character
    field obj-code as integer
    field b-code like chk-gds-pay.b-code
    field grp-code like ub.goods.grp-code
    field grp-lvl as integer
    field upper-code like gds-grp.upper-code
    field gds-name as character
    field eff-doc-qnty as decimal
    field object-sum as decimal
    field discount as decimal
    field tot-r-b as decimal
    field line-type as character
    field doc-code as character
    field type-line as character
    index pi is primary obj-type obj-code
    index bcode b-code
    index grp_lvl       grp-lvl
    index upper_code    upper-code
.
define stream OutStr-html.
function fnc-DD-MM-YYYY returns character
(input p-dat-date as date) forward.
function fnc-convert-dot-to-colon returns character
(input p-data as decimal, p-accur as character) forward.
    run my-report.
procedure create-file:
    define input parameter p-file-name as character no-undo.
    output to value(string(p-file-name)).
    output close.
end procedure.
procedure define-full-path-Report:
    define input parameter p-rep-num as integer no-undo.
    define output parameter p-file-name-rep-htm as character no-undo.
    p-file-name-rep-htm = session:temp-directory + "rpt" + string(p-rep-num) + ".html".
end procedure.
procedure get-full-path-RepViewer:
    define output parameter p-fill-path-RepView as character no-undo.
    if search("exe\ReportViewer\reportviewer.exe") <> ? then
    do:
        p-fill-path-RepView = search("exe\ReportViewer\reportviewer.exe").
    end.
    else
    do:
        message "Не найдена программа просмотра отчёта!" view-as alert-box error.
    end.
end procedure.
procedure my-report:
    run get-full-path-RepViewer(output v-full-path-RepView).
    run get-report-num in parParentProc(output g#report-num).
    run define-full-path-Report(input g#report-num, output v-file-name-rep-htm).
    run create-file(v-file-name-rep-htm).
    define variable v-type as integer no-undo.
    v-type = if p-cb-disType = '1' then integer('20':U) else integer('22':U).
    for each tt-line no-lock:
        delete tt-line.
    end.
    for each obj-list no-lock:
         run rep/rpychk0.p (input "r-shftc2"
                        ,input obj-list.obj-type
                        ,input obj-list.obj-code
                        ,input ?
                        ,input ?
                        ,input X-date-start
                        ,input X-date-end
                        ,input 1
                        ,input 99
                        ,input ?
                        ) no-error.
         if error-status:error then
         do:
             message error-status:get-message(1) view-as alert-box.
         end.
         if x-TOG-Shift = yes then
         do:
            for each ub.chk-doc no-lock
                where ub.chk-doc.obj-type = obj-list.obj-type
                and ub.chk-doc.obj-code = obj-list.obj-code
                and (ub.chk-doc.shift-date > x-Date-Start or
                    (ub.chk-doc.shift-date = x-Date-Start and ub.chk-doc.shift-num >= x-Shift-Start))
                and (ub.chk-doc.shift-date < x-Date-End or
                    (ub.chk-doc.shift-date = x-Date-End and ub.chk-doc.shift-num <= x-Shift-End))
                and  ub.chk-doc.out-code > "",
            first ub.chk-discnt no-lock
                where ub.chk-discnt.doc-code = ub.chk-doc.doc-code
                and ub.chk-discnt.discnt-type = v-type
            :
                for each chk-gds no-lock
                where ub.chk-gds.doc-code = ub.chk-doc.doc-code
                :
                    for each ub.chk-gds-pay no-lock
                    where ub.chk-gds-pay.doc-code = ub.chk-doc.doc-code
                    and ub.chk-gds-pay.b-code = chk-gds.b-code
                    and ub.chk-gds-pay.line-num = chk-gds.line-num
                    :
                        run proc-tt.
                    end.
                end.
             end.
         end.
         else
         do:
            for each ub.chk-doc no-lock
                where ub.chk-doc.obj-type = obj-list.obj-type
                and ub.chk-doc.obj-code = obj-list.obj-code
                and ub.chk-doc.chk-date >= x-Date-Start
                and ub.chk-doc.chk-date <= x-Date-End
                and  ub.chk-doc.out-code > "",
            first ub.chk-discnt no-lock
                where ub.chk-discnt.doc-code = ub.chk-doc.doc-code
                and ub.chk-discnt.discnt-type = v-type
            :
                for each chk-gds no-lock
                where ub.chk-gds.doc-code = ub.chk-doc.doc-code
                :
                    for each ub.chk-gds-pay no-lock
                    where ub.chk-gds-pay.doc-code = ub.chk-doc.doc-code
                    and ub.chk-gds-pay.b-code = chk-gds.b-code
                    and ub.chk-gds-pay.line-num = chk-gds.line-num
                    :
                        run proc-tt.
                    end.
                end.
             end.
         end.
         run transform-tt-level.
    end.
    str1 = (if X-TOG-Shift then "С " + fnc-DD-MM-YYYY(date(string(X-Date-Start,"99/99/9999"))) + ", смена № "  + string(X-Shift-Start) +
                                " по " + fnc-DD-MM-YYYY(date(string(X-Date-End,"99/99/9999"))) + ", смена № " + string(X-Shift-End)
                           else
                                "За период с " + fnc-DD-MM-YYYY(date(string(X-Date-Start,"99/99/9999"))) + " по " + fnc-DD-MM-YYYY(date(string(X-Date-End,"99/99/9999")))
    ).
    if X-selectGood = 4 then
    do:
        v-choice-gds = "По списку товаров: ".
        for each gds-list no-lock:
            gds-str = gds-str + gds-list.gds-name + ", ".
        end.
        gds-str = right-trim( gds-str, " " ).
        gds-str = right-trim( gds-str, "," ).
        if length(gds-str) > 115 then
        do:
            v-choice-gds = (substring(gds-str, 1, 115) + "..." ).
        end.
        else
        do:
            v-choice-gds = gds-str.
        end.
    end.
    if length(str2) > 115 then
    do:
        v-choice-gds = substring(str2, 1, 115) + "...".
    end.
    else
    do:
        v-choice-gds = str2.
    end.
    str4 = replace(str4, chr(10), " ").
    str4 = replace(str4, chr(13), " ").
    str4 = replace(str4, chr(9), " ").
    str4 = trim(str4, " ").
    if length(str4) > 115 then
    do:
        v-choice-obj = substring(str4, 1, 115) + "...".
    end.
    else
    do:
        v-choice-obj = str4.
    end.
    if p-cb-disType = "1" then
    do:
        v-type-discount = "Тип скидки: ЛНР.".
    end.
    else
    do:
        v-type-discount = "Тип скидки: бонусы.".
    end.
    run proc-create-HTML(input v-file-name-rep-htm, input str1, input v-choice-gds, input v-choice-obj, input v-type-discount).
    run search-full-path-Report(input v-file-name-rep-htm).
    run Report-Viewer(input v-full-path-RepView, input v-file-name-rep-htm).
end procedure.
procedure proc-create-HTML:
    define input parameter p-file-name-rep-htm as character no-undo.
    define input parameter p-period-date as character no-undo.
    define input parameter p-choice-gds as character no-undo.
    define input parameter p-choice-obj as character no-undo.
    define input parameter p-type-discount as character no-undo.
    define buffer buf2_tt-line for tt-line.
    do:
        output stream OutStr-html to value(p-file-name-rep-htm) append convert target 'UTF-8'.
            put stream OutStr-html unformatted
                "<!DOCTYPE HTML>" skip
                ' <html>' skip
                '  <head>' skip
                '   <meta charset="utf-8">' skip
                '    <style type="text/css">' skip
                '      table ' + chr(123) + ' border-collapse: collapse; font-size: 9pt; table-layout: fixed; width: 1157px; padding: 14px; ' + chr(125) skip
                '      td ' + chr(123) ' border: 1px black ridge; word-wrap:break-word; ' + chr(125) skip
                '      htm' skip
                '      .rotate ' + chr(123) skip
                '        -webkit-transform: rotate(-90deg);' skip
                '        -moz-transform: rotate(-90deg);' skip
                '        -ms-transform: rotate(-90deg);' skip
                '        -o-transform: rotate(-90deg);' skip
                '        transform: rotate(-90deg);' skip
                '        -webkit-transform-origin: 50% 50%;' skip
                '        -moz-transform-origin: 50% 50%;' skip
                '        -ms-transform-origin: 50% 50%;' skip
                '        -o-transform-origin: 50% 50%;' skip
                '        transform-origin: 50% 50%;' skip
                '        filter: progid:DXImageTransform.Microsoft.BasicImage(rotation=3);' skip
                '          ' + chr(125) skip
                '            th' + ' ' + chr(123) skip
                '            border: 1px black solid;' skip
                '            word-wrap: break-word;' skip
                '          ' + chr(125) skip
                '   </style>' skip
                '  </head>' skip
            .
    end.
    do:
            put stream OutStr-html unformatted
                ' <body>' skip
                '   <table name="Лист1" outline_below="false">' skip
                '     <thead>' skip
                '       <tr class="set_columns">' skip
                '         <td style="width: 252px; border: none;"></td>' skip
                '         <td style="width: 252px; border: none;"></td>' skip
                '         <td style="width: 123px; border: none;"></td>' skip
                '         <td style="width: 123px; border: none;"></td>' skip
                '         <td style="width: 123px; border: none;"></td>' skip
                '         <td style="width: 123px; border: none;"></td>' skip
                '       </tr>' skip
            .
    end.
    do:
            put stream OutStr-html unformatted
                '       <tr>' skip
                '         <td style="border: none; height: 14px"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '       </tr>' skip
                '       <tr>' skip
                '         <td colspan="6" style="border: none; height: 14px; font-weight: bold">Отчёт по типам скидки</td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '       </tr>' skip
                '       <tr>' skip
                '         <td colspan="6" style="border: none; height: 14px; font-weight: bold">' + p-period-date + '</td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '       </tr>' skip
                '       <tr>' skip
                '         <td colspan="6" style="border: none; height: 14px; font-weight: bold">' + p-choice-gds + '</td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '       </tr>' skip
                '       <tr>' skip
                '         <td colspan="6" style="border: none; height: 14px; font-weight: bold">' + p-choice-obj + '</td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '       </tr>' skip
                '       <tr>' skip
                '         <td colspan="6" style="border: none; height: 14px; font-weight: bold">' + p-type-discount + '</td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '       </tr>' skip
                '       <tr>' skip
                '         <td style="border: none; height: 14px"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '       </tr>' skip
                '     </thead>' skip
            .
    end.
    do:
            put stream OutStr-html unformatted
                '     <tbody>' skip
                '       <tr>' skip
                '         <th style="text-align: center; height: 30px">Объект</th>' skip
                '         <th style="text-align: center;">Товар</th>' skip
                '         <th style="text-align: center;">Количество</th>' skip
                '         <th style="text-align: center;">Сумма без скидки</th>' skip
                '         <th style="text-align: center;">Скидка</th>' skip
                '         <th style="text-align: center;">Сумма со скидкой</th>' skip
                '       </tr>' skip
                '       <tr>' skip
                '         <th num="" style="text-align: center;">1</th>' skip
                '         <th num="" style="text-align: center;">2</th>' skip
                '         <th num="" style="text-align: center;">3</th>' skip
                '         <th num="" style="text-align: center;">4</th>' skip
                '         <th num="" style="text-align: center;">5</th>' skip
                '         <th num="" style="text-align: center;">6</th>' skip
                '       </tr>' skip
            .
        output stream OutStr-html close.
    end.
    do:
        output stream OutStr-html to value(p-file-name-rep-htm) append convert target 'UTF-8'.
        find first buf2_tt-line no-lock no-error.
        if not error-status:error and available buf2_tt-line then
        do:
            for each buf2_tt-line where
            buf2_tt-line.grp-code = 0 no-lock
            by buf2_tt-line.obj-type by buf2_tt-line.obj-code
            :
                put stream OutStr-html unformatted
                '       <tr level="1">' skip
                '         <td style="text-align: left; height: 30px; font-weight: bold">' + buf2_tt-line.obj-name + '</td>' skip
                '         <td style="text-align: left; font-weight: bold">' + buf2_tt-line.gds-name + '</td>' skip
                '         <td num="0.00" style="text-align: right; font-weight: bold">' + if buf2_tt-line.eff-doc-qnty <> ? then fnc-convert-dot-to-colon(buf2_tt-line.eff-doc-qnty, ">>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                '         <td num="0.00" style="text-align: right; font-weight: bold">' + if buf2_tt-line.object-sum <> ? then fnc-convert-dot-to-colon(buf2_tt-line.object-sum, ">>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                '         <td num="0.00" style="text-align: right; font-weight: bold">' + if buf2_tt-line.discount <> ? then fnc-convert-dot-to-colon(buf2_tt-line.discount, ">>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                '         <td num="0.00" style="text-align: right; font-weight: bold">' + if buf2_tt-line.tot-r-b <> ? then fnc-convert-dot-to-colon(buf2_tt-line.tot-r-b, ">>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                '       </tr>' skip
            .
            run tt-print-line (input buf2_tt-line.obj-type, input buf2_tt-line.obj-code, input 1, input 2).
            end.
        end.
        else
        do:
                put stream OutStr-html unformatted
                '       <tr>' skip
                '         <td style="text-align: left; height: 14px"></td>' skip
                '         <td style="text-align: left;"></td>' skip
                '         <td num="0.00" style="text-align: right;">0,00</td>' skip
                '         <td num="0.00" style="text-align: right;">0,00</td>' skip
                '         <td num="0.00" style="text-align: right;">0,00</td>' skip
                '         <td num="0.00" style="text-align: right;">0,00</td>' skip
                '       </tr>' skip
                '       <tr>' skip
                '         <td num="0.00" style="text-align: left; height: 14px; font-weight: bold">Итого:</td>' skip
                '         <td num="0.00" style="text-align: left; font-weight: bold"></td>' skip
                '         <td num="0.00" style="text-align: right; font-weight: bold">0,00</td>' skip
                '         <td num="0.00" style="text-align: right; font-weight: bold">0,00</td>' skip
                '         <td num="0.00" style="text-align: right; font-weight: bold">0,00</td>' skip
                '         <td num="0.00" style="text-align: right; font-weight: bold">0,00</td>' skip
                '       </tr>' skip
                .
        end.
    end.
    do:
                put stream OutStr-html unformatted
                '     </tbody>' skip
                '   </table>' skip
                '  </body>' skip
                ' </html>' skip
                .
        output stream OutStr-html close.
    end.
end procedure.
procedure proc-tt:
    for first ub.bar-code no-lock where ub.bar-code.b-code = chk-gds-pay.b-code
    :
        if (x-SelectGood = 1) or (can-find(first gds-list no-lock where gds-list.gds-code = ub.bar-code.gds-code)) then
        do:
            find first tt-line where
            tt-line.obj-code = obj-list.obj-code and
            tt-line.obj-type = obj-list.obj-type and
            tt-line.b-code = chk-gds-pay.b-code no-error.
            if not available tt-line then
            do:
                create tt-line.
                tt-line.b-code = chk-gds-pay.b-code.
                tt-line.obj-name = obj-list.obj-name.
                tt-line.obj-code = obj-list.obj-code.
                tt-line.obj-type = obj-list.obj-type.
                for first ub.goods fields(gds-name grp-code) where
                ub.goods.gds-code = ub.bar-code.gds-code
                no-lock:
                    tt-line.gds-name = ub.goods.gds-name.
                    tt-line.grp-code = ub.goods.grp-code.
                end.
            end.
            tt-line.eff-doc-qnty = tt-line.eff-doc-qnty + ub.chk-gds-pay.eff-doc-qnty.
            tt-line.object-sum = tt-line.object-sum + (if chk-gds.doc-qnty <> 0 then (chk-gds.src-sum * (chk-gds-pay.eff-doc-qnty / chk-gds.doc-qnty))
                                                       else 0) no-error.
            tt-line.tot-r-b = tt-line.tot-r-b + ub.chk-gds-pay.tot-r-b.
            tt-line.discount = tt-line.discount + (if tt-line.object-sum <> 0 then (((tt-line.object-sum - tt-line.tot-r-b) * 100) / tt-line.object-sum)
                                                   else 0) no-error.
        end.
    end.
v-cnt = v-cnt + 1.
end procedure.
procedure Report-Viewer:
    define input parameter p-full-path-RepView as character no-undo.
    define input parameter p-file-name-rep-htm as character no-undo.
os-command no-wait value(p-full-path-RepView + " true " + search(p-file-name-rep-htm)).
end procedure.
procedure search-full-path-Report:
    define input parameter p-file-name as character no-undo.
    if search(p-file-name) = ? then
        do:
            message "Не найден файл отчёта: " p-file-name view-as alert-box error.
        end.
    else
        do:
            p-file-name = search(p-file-name).
        end.
end procedure.
procedure transform-tt-level:
    define variable v-eff-doc-qnty as decimal no-undo.
    define variable v-object-sum as decimal no-undo.
    define variable v-tot-r-b as decimal no-undo.
    define variable v-discount as decimal no-undo.
    define variable v-ii as integer no-undo.
    define variable v-gds-name as character no-undo.
    define variable v-cur-lvl as integer no-undo.
    define variable v-upper-code as integer initial ? no-undo.
    define buffer buf_tt-line for tt-line.
    define buffer buf2_goods for ub.goods.
    define buffer bufobj_tt-line for tt-line.
    create bufobj_tt-line.
    assign
        bufobj_tt-line.grp-code = 0
        bufobj_tt-line.obj-type = obj-list.obj-type
        bufobj_tt-line.obj-code = obj-list.obj-code
        bufobj_tt-line.obj-name = obj-list.obj-name
    .
    do while v-upper-code <> 0:
        v-upper-code = 0.
        for each tt-line where tt-line.grp-lvl = v-cur-lvl
        and tt-line.obj-type = obj-list.obj-type
        and tt-line.obj-code = obj-list.obj-code
        break by tt-line.grp-code
        :
            v-ii = v-ii + 1.
            if first-of (tt-line.grp-code) then
            do:
                assign
                    v-eff-doc-qnty = 0
                    v-object-sum = 0
                    v-tot-r-b = 0
                    v-discount = 0
                .
                find first ub.gds-grp where
                ub.gds-grp.node-code = tt-line.grp-code no-lock.
                if available ub.gds-grp then
                do:
                    assign
                        v-upper-code = ub.gds-grp.upper-code
                        v-gds-name = ub.gds-grp.node-name
                    .
                end.
            end.
            tt-line.upper-code = if  tt-line.grp-lvl = 0 then tt-line.grp-code else v-upper-code.
            assign
                v-eff-doc-qnty = v-eff-doc-qnty + tt-line.eff-doc-qnty
                v-object-sum = v-object-sum + tt-line.object-sum
                v-tot-r-b = v-tot-r-b + tt-line.tot-r-b
                v-discount = v-discount + tt-line.discount
            .
            if tt-line.grp-lvl = 0 then
                assign
                    bufobj_tt-line.eff-doc-qnty = bufobj_tt-line.eff-doc-qnty + tt-line.eff-doc-qnty
                    bufobj_tt-line.object-sum = bufobj_tt-line.object-sum + tt-line.object-sum
                    bufobj_tt-line.tot-r-b = bufobj_tt-line.tot-r-b +  tt-line.tot-r-b
                    bufobj_tt-line.discount = bufobj_tt-line.discount + tt-line.discount
                .
            if last-of (tt-line.grp-code) then
            do:
                create buf_tt-line.
                assign
                    buf_tt-line.grp-code =
                        (if tt-line.grp-lvl = 0 then tt-line.grp-code
                         else v-upper-code)
                    buf_tt-line.eff-doc-qnty = v-eff-doc-qnty
                    buf_tt-line.object-sum = v-object-sum
                    buf_tt-line.tot-r-b = v-tot-r-b
                    buf_tt-line.discount = v-discount
                    buf_tt-line.grp-lvl = buf_tt-line.grp-lvl + 1
                    buf_tt-line.gds-name = v-gds-name
                    buf_tt-line.obj-type = obj-list.obj-type
                    buf_tt-line.obj-code = obj-list.obj-code
                .
            end.
        end.
        v-cur-lvl = v-cur-lvl + 1.
end.
end procedure.
procedure tt-print-line:
    define input parameter v-obj-type as character no-undo.
    define input parameter v-obj-code as integer no-undo.
    define input parameter v-upper-code like ub.gds-grp.upper-code no-undo.
    define input parameter v-print-lvl as integer no-undo.
    define buffer buf3_tt-line for tt-line.
    for each buf3_tt-line where
    buf3_tt-line.upper-code = v-upper-code and
    buf3_tt-line.obj-type = v-obj-type and
    buf3_tt-line.obj-code = v-obj-code
    no-lock:
        if v-print-lvl < 3 then
        do:
            put stream OutStr-html unformatted
                '       <tr level="' + string(v-print-lvl) + '">' skip
                '         <td style="text-align: left; height: 30px">' + '</td>' skip
                '         <td style="text-align: left; padding-left: ' + string((v-print-lvl - 1) * 10) + 'px">'
                            + string(fill(" ", ((v-print-lvl - 2) * 4))) + buf3_tt-line.gds-name
                            + '</td>' skip
                '         <td num="0.00" style="text-align: right">' + if buf3_tt-line.eff-doc-qnty <> ? then fnc-convert-dot-to-colon(buf3_tt-line.eff-doc-qnty, ">>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                '         <td num="0.00" style="text-align: right">' + if buf3_tt-line.object-sum <> ? then fnc-convert-dot-to-colon(buf3_tt-line.object-sum, ">>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                '         <td num="0.00" style="text-align: right">' + if buf3_tt-line.discount <> ? then fnc-convert-dot-to-colon(buf3_tt-line.discount, ">>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                '         <td num="0.00" style="text-align: right">' + if buf3_tt-line.tot-r-b <> ? then fnc-convert-dot-to-colon(buf3_tt-line.tot-r-b, ">>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                '       </tr>' skip
            .
        end.
        else
        do:
            put stream OutStr-html unformatted
                '       <tr level="' + string(v-print-lvl) + '">' skip
                '         <td style="text-align: left; height: 30px; display: none">' + '</td>' skip
                '         <td style="text-align: left; padding-left: ' + string((v-print-lvl - 1) * 10) + 'px; display: none">'
                            + string(fill(" ", ((v-print-lvl - 2) * 4))) + buf3_tt-line.gds-name
                            + '</td>' skip
                '         <td num="0.00" style="text-align: right; display: none">' + if buf3_tt-line.eff-doc-qnty <> ? then fnc-convert-dot-to-colon(buf3_tt-line.eff-doc-qnty, ">>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                '         <td num="0.00" style="text-align: right; display: none">' + if buf3_tt-line.object-sum <> ? then fnc-convert-dot-to-colon(buf3_tt-line.object-sum, ">>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                '         <td num="0.00" style="text-align: right; display: none">' + if buf3_tt-line.discount <> ? then fnc-convert-dot-to-colon(buf3_tt-line.discount, ">>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                '         <td num="0.00" style="text-align: right; display: none">' + if buf3_tt-line.tot-r-b <> ? then fnc-convert-dot-to-colon(buf3_tt-line.tot-r-b, ">>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                '       </tr>' skip
            .
        end.
        if buf3_tt-line.grp-lvl <> 0 then run tt-print-line (input v-obj-type, input v-obj-code, input buf3_tt-line.grp-code, input v-print-lvl + 1).
    end.
end procedure.
function fnc-convert-dot-to-colon returns character
(input p-data as decimal, input p-accur as character):
        define variable result as character no-undo.
    define variable v-str-result as character no-undo.
    p-data = round(p-data, 4).
    v-str-result = trim(replace(string(p-data, p-accur), ".", ",")).
        return v-str-result.
end function.
function fnc-DD-MM-YYYY returns character
(input p-dat-date as date):
    define variable result as character no-undo.
    define variable p-str-date as character no-undo.
    p-str-date = replace(string(p-dat-date,'99.99.9999'), "/", ".").
        return p-str-date.
end function.
