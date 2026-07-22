block-level on error undo, throw.
define input parameter parparentproc            as widget-handle           no-undo .
define input parameter p-parent-handle          as handle                  no-undo .
define input parameter p-log-handle             as handle                  no-undo .
define input parameter p-cont-handle            as handle                  no-undo .
define input parameter p-rebh                   as handle                  no-undo .
define input parameter p-report-id              as character               no-undo .
define input parameter p-xsd-file               as character               no-undo .
define input parameter p-log-file-name          as character               no-undo .
define input parameter p-batch                  as integer                 no-undo .
define input parameter p-codex-id               as integer                 no-undo .
define input parameter p-ruleset-id             as integer                 no-undo .
define input parameter p-obj-type               like ub.clients.obj-type   no-undo .
define input parameter p-obj-code               like ub.clients.obj-code   no-undo .
define input parameter p-z-number-list          as character               no-undo .
define input parameter p-previous-shift-date    as date                    no-undo .
define input parameter p-with-cp-grouping       as logical                 no-undo .
define variable vss-revision    as character no-undo initial "$Revision: 5c165f2bb314, 1940, rls $":U.
define variable vss-author      as character no-undo initial "$Author: druban $":U.
define variable vss-date        as character no-undo initial "$Date: Fri Jul 12 15:14:08 2019 +0300 $":U.
define variable vss-workfile    as character no-undo initial "$Workfile: r-shift2.p $":U.
define variable vss-archive     as character no-undo initial "$Archive: rep/r-shift2.p $":U.
define variable vss-description as character no-undo initial "Печать сменного отчета - лист 2 ":U.
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
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
define variable sym1  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym2  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym3  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym4  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym5  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym6  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym7  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym8  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym9  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym10 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym11 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym12 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym13 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym14 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym15 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym16 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym17 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym18 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym19 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym20 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym21 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym22 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym23 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym24 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym25 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym26 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym27 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable temp1 as integer   no-undo.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE SHARED TEMP-TABLE treal-2 no-undo
FIELD gds-code as integer
FIELD cpay-code as integer
FIELD curr-code as integer
FIELD qnty1 as decimal
FIELD qnty2 as decimal
FIELD netto as decimal
FIELD brutto as decimal
FIELD discount-sum as decimal
FIELD chk-qnty as int
FIELD out-name as character format "X(18)"
FIELD is-pay as logical
FIELD ii as integer
field discnt-type as integer
INDEX pi IS
  primary
      gds-code
      cpay-code
      curr-code
      is-pay DESCENDING
INDEX vi
      gds-code
      cpay-code
      discnt-type
      ii
.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE   TEMP-TABLE actreal-2 no-undo
FIELD gds-code as integer
FIELD cpay-code as integer
FIELD curr-code as integer
FIELD qnty1 as decimal
FIELD qnty2 as decimal
FIELD netto as decimal
FIELD brutto as decimal
FIELD discount-sum as decimal
FIELD chk-qnty as int
FIELD out-name as character format "X(18)"
FIELD is-pay as logical
FIELD ii as integer
field discnt-type as integer
INDEX pi IS
  primary
      gds-code
      cpay-code
      curr-code
      is-pay DESCENDING
INDEX vi
      gds-code
      cpay-code
      discnt-type
      ii
.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE NEW SHARED TEMP-TABLE t-2 no-undo
FIELD gds-code like ub.goods.gds-code
FIELD main-code like ub.bar-code.b-code
FIELD artic like ub.goods.artic
FIELD prod-type like ub.goods.prod-type
FIELD prod-code like ub.goods.prod-code
FIELD qnty1-before as decimal FORMAT "->>>>9.99"
FIELD qnty2-before as decimal FORMAT "->>>>9.99"
FIELD qnty1-after as decimal FORMAT "->>>>9.99"
FIELD qnty2-after as decimal FORMAT "->>>>9.99"
FIELD last-price as decimal FORMAT ">>>>9.99"
FIELD gds-name like ub.goods.gds-name FORMAT "X(12)"
FIELD lines as integer
INDEX pi IS UNIQUE primary
gds-code
INDEX art IS UNIQUE
artic
prod-type
prod-code
INDEX pervakov IS UNIQUE
main-code
.
DEFINE NEW SHARED TEMP-TABLE tincome-2 no-undo
FIELD gds-code as integer
FIELD supp-name like ub.clients.obj-name FORMAT "X(18)"
FIELD supp-type like ub.clients.obj-type
FIELD supp-code like ub.clients.obj-code FORMAT ">>>>>>>>9"
FIELD doc-code-trn  like ub.trn-doc.doc-code
FIELD doc-code  like ub.trn-doc.doc-code
FIELD qnty1 as decimal FORMAT "->>>>9.99"
FIELD qnty2 as decimal FORMAT "->>>>9.99"
FIELD qnty3 as decimal FORMAT "->>>>9.99"
FIELD density as decimal FORMAT "9.999"
FIELD temperature as decimal FORMAT ">9.99"
FIELD naturalloss as decimal FORMAT ">9.99"
FIELD is-fact as logical
FIELD ii as integer
INDEX pi IS UNIQUE PRIMARY
      gds-code
      doc-code-trn
      doc-code
      supp-code
INDEX vi IS UNIQUE
      gds-code
      ii
.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE create-treal-2.
DEFINE INPUT PARAMETER pgds-code like ub.goods.gds-code no-undo.
DEFINE INPUT PARAMETER pcpay-code like ub.cash-pay.cdpay-code no-undo.
DEFINE INPUT PARAMETER pcurr-code like ub.cash-pay.curr-code no-undo.
DEFINE INPUT PARAMETER pqnty1 as decimal no-undo.
DEFINE INPUT PARAMETER pqnty2 as decimal no-undo.
DEFINE INPUT PARAMETER pnetto as decimal no-undo.
DEFINE INPUT PARAMETER pout-name as character no-undo.
DEFINE INPUT PARAMETER pis-pay as logical no-undo.
DEFINE INPUT PARAMETER pii as integer no-undo.
_main:
DO ON ERROR UNDO _main, return error:
    create treal-2.
    assign
    treal-2.gds-code = pgds-code
    treal-2.cpay-code = pcpay-code
    treal-2.curr-code = pcurr-code
    treal-2.qnty1  =  pqnty1
    treal-2.qnty2  = pqnty2
    treal-2.netto = pnetto
    treal-2.out-name = pout-name
    treal-2.is-pay = pis-pay
    treal-2.ii = pii
    treal-2.discnt-type = -99
    no-error
    .
    if error-status:error then undo _main, return error.
END.
END PROCEDURE.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE create-actreal-2.
DEFINE INPUT PARAMETER pgds-code like ub.goods.gds-code no-undo.
DEFINE INPUT PARAMETER pcpay-code like ub.cash-pay.cdpay-code no-undo.
DEFINE INPUT PARAMETER pcurr-code like ub.cash-pay.curr-code no-undo.
DEFINE INPUT PARAMETER pqnty1 as decimal no-undo.
DEFINE INPUT PARAMETER pqnty2 as decimal no-undo.
DEFINE INPUT PARAMETER pnetto as decimal no-undo.
DEFINE INPUT PARAMETER pout-name as character no-undo.
DEFINE INPUT PARAMETER pis-pay as logical no-undo.
DEFINE INPUT PARAMETER pii as integer no-undo.
_main:
DO ON ERROR UNDO _main, return error:
    create actreal-2.
    assign
    actreal-2.gds-code = pgds-code
    actreal-2.cpay-code = pcpay-code
    actreal-2.curr-code = pcurr-code
    actreal-2.qnty1  =  pqnty1
    actreal-2.qnty2  = pqnty2
    actreal-2.netto = pnetto
    actreal-2.out-name = pout-name
    actreal-2.is-pay = pis-pay
    actreal-2.ii = pii
    actreal-2.discnt-type = -99
    no-error
    .
    if error-status:error then undo _main, return error.
END.
END PROCEDURE.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
procedure cp-attr-code :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-type           as character no-undo .
    define output parameter p-format         as character no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-range          as integer   no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-other          as character no-undo .
    case p-code :
            when 'paycard-export-prefix':U then do:     assign     p-label = "Префиксы платежных карт (для выгрузки в XML)"     p-type = 'C':U      p-format = "X(19)"     p-label = "Префиксы платежных карт (для выгрузки в XML)"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=paycard-prefix':u      .   end.
            when 'grp-code':U then do:     assign     p-label = "Группа платежа"     p-type = 'C':U      p-format = "X(45)"     p-label = "Группа платежа"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=grp-code':u      .   end.
            when 'is-use':U then do:     assign     p-label = "Используется"     p-type = 'C':U      p-format = "X(255)"     p-label = "Используется"     p-range = 4     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=is-use':u      .   end.
            when 'dop-doc':U then do:     assign     p-label = "Дополнительный документ"     p-type = 'C':U      p-format = "X(255)"     p-label = "Дополнительный документ"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=dop-doc':u      .   end.
            when 'paycard-all-prefix':U then do:     assign     p-label = "Префиксы платежных карт (для разбора чеков и т.д.)"     p-type = 'C':U      p-format = "X(19)"     p-label = "Префиксы платежных карт (для разбора чеков и т.д.)"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=paycard-prefix':u      .   end.
            when 'paycard-edit-prefix':U then do:     assign     p-label = "Префиксы платежных карт, разрешенных для редактирования"     p-type = 'C':U      p-format = "X(19)"     p-label = "Префиксы платежных карт, разрешенных для редактирования"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=paycard-prefix':u      .   end.
            when 'form_km3':U then do:     assign     p-label = "Формировать КМ-3 по чекам возврата"     p-type = 'L':U      p-format = "+/-"     p-label = "Формировать КМ-3 по чекам возврата"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'bal_malina':U then do:     assign     p-label = "Оплата баллами Малина"     p-type = 'L':U      p-format = "+/-"     p-label = "Оплата баллами Малина"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'max_proc_sum':U then do:     assign     p-label = "Максимальный % порог от суммы"     p-type = 'D':U      p-format = ">>9.99"     p-label = "Максимальный % порог от суммы"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'mask_card_kup':U then do:     assign     p-label = "Маска карты\купона"     p-type = 'C':U      p-format = "x(129)"     p-label = "Маска карты\купона"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут типа кассового платежа &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure cp-attr-tooltip :
  do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
            when 'paycard-export-prefix':U then do:     assign     p-tooltip = "Префиксы платежных карт (для выгрузки в XML)"     p-label = "Префиксы платежных карт (для выгрузки в XML)" .   end.
            when 'grp-code':U then do:     assign     p-tooltip = "Группа платежа"     p-label = "Группа платежа" .   end.
            when 'is-use':U then do:     assign     p-tooltip = "Используется"     p-label = "Используется" .   end.
            when 'dop-doc':U then do:     assign     p-tooltip = "Дополнительный документ"     p-label = "Дополнительный документ" .   end.
            when 'paycard-all-prefix':U then do:     assign     p-tooltip = "Префиксы платежных карт (для разбора чеков и т.д.)"     p-label = "Префиксы платежных карт (для разбора чеков и т.д.)" .   end.
            when 'paycard-edit-prefix':U then do:     assign     p-tooltip = "Префиксы платежных карт, разрешенных для редактировани"     p-label = "Префиксы платежных карт, разрешенных для редактирования" .   end.
            when 'form_km3':U then do:     assign     p-tooltip = "Формировать КМ-3 по чекам возврата"     p-label = "Формировать КМ-3 по чекам возврата" .   end.
            when 'bal_malina':U then do:     assign     p-tooltip = "Оплата баллами Малина"     p-label = "Оплата баллами Малина" .   end.
            when 'max_proc_sum':U then do:     assign     p-tooltip = "Максимальный % порог от суммы"     p-label = "Максимальный % порог от суммы" .   end.
            when 'mask_card_kup':U then do:     assign     p-tooltip = "Маска карты\купона"     p-label = "Маска карты\купона" .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут типа кассового платежа &1", p-code) .
      end.
    end.
  end.
end procedure.
procedure cp-attr-value :
  do
  on error undo, return error
  :
    define input parameter p-cdpay-code   like ub.cash-pay-attr.cdpay-code     no-undo .
    define input parameter p-curr-code    like ub.cash-pay-attr.curr-code      no-undo .
    define input parameter p-host-code    like ub.cash-pay-attr.host-code      no-undo .
    define input parameter p-obj-type     like ub.cash-pay-attr.obj-type       no-undo .
    define input parameter p-obj-code     like ub.cash-pay-attr.obj-code       no-undo .
    define input  parameter p-code        like ub.cash-pay-attr.attr-code      no-undo .
    define output parameter p-value       like ub.cash-pay-attr.attr-value    no-undo .
    define output parameter p-type        as character no-undo .
    define buffer buf_cash-pay-attr for ub.cash-pay-attr .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run cp-attr-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-label
      ,output v-range
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_cash-pay-attr no-lock
      where buf_cash-pay-attr.cdpay-code = p-cdpay-code
        and buf_cash-pay-attr.curr-code  = p-curr-code
        and buf_cash-pay-attr.host-code  = p-host-code
        and buf_cash-pay-attr.obj-type   = p-obj-type
        and buf_cash-pay-attr.obj-code   = p-obj-code
        and buf_cash-pay-attr.attr-code  = p-code
      no-error .
    if avail buf_cash-pay-attr then do:
      assign
        p-value =  buf_cash-pay-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure cp-attr-write :
  do
  on error undo, return error
  :
    define input parameter p-cdpay-code   like ub.cash-pay-attr.cdpay-code     no-undo .
    define input parameter p-curr-code    like ub.cash-pay-attr.curr-code      no-undo .
    define input parameter p-host-code    like ub.cash-pay-attr.host-code      no-undo .
    define input parameter p-obj-type     like ub.cash-pay-attr.obj-type       no-undo .
    define input parameter p-obj-code     like ub.cash-pay-attr.obj-code       no-undo .
    define input parameter p-code     like ub.cash-pay-attr.attr-code  no-undo .
    define input parameter p-value    like ub.cash-pay-attr.attr-value no-undo .
    define buffer buf_cash-pay-attr for ub.cash-pay-attr .
    define buffer last_cash-pay-attr for ub.cash-pay-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run cp-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-range
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_cash-pay-attr exclusive-lock
      where buf_cash-pay-attr.cdpay-code = p-cdpay-code
        and buf_cash-pay-attr.curr-code  = p-curr-code
        and buf_cash-pay-attr.host-code  = p-host-code
        and buf_cash-pay-attr.obj-type   = p-obj-type
        and buf_cash-pay-attr.obj-code   = p-obj-code
        and buf_cash-pay-attr.attr-code = p-code
      no-error .
    if not available buf_cash-pay-attr then do:
      create buf_cash-pay-attr .
      assign
      buf_cash-pay-attr.cdpay-code = p-cdpay-code
      buf_cash-pay-attr.curr-code  = p-curr-code
      buf_cash-pay-attr.host-code  = p-host-code
      buf_cash-pay-attr.obj-type   = p-obj-type
      buf_cash-pay-attr.obj-code   = p-obj-code
      buf_cash-pay-attr.attr-code = p-code
      .
    end.
    assign
      buf_cash-pay-attr.attr-value = p-value
    .
    release buf_cash-pay-attr no-error .
    if error-status:error then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cp-attr-exist :
  do
  on error undo, return error
  :
    define input parameter p-cdpay-code   like ub.cash-pay-attr.cdpay-code     no-undo .
    define input parameter p-curr-code    like ub.cash-pay-attr.curr-code      no-undo .
    define input parameter p-host-code    like ub.cash-pay-attr.host-code      no-undo .
    define input parameter p-obj-type     like ub.cash-pay-attr.obj-type       no-undo .
    define input parameter p-obj-code     like ub.cash-pay-attr.obj-code       no-undo .
    define input parameter p-code     like ub.cash-pay-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_cash-pay-attr for ub.cash-pay-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run cp-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-range
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_cash-pay-attr exclusive-lock
      where buf_cash-pay-attr.cdpay-code = p-cdpay-code
        and buf_cash-pay-attr.curr-code  = p-curr-code
        and buf_cash-pay-attr.host-code  = p-host-code
        and buf_cash-pay-attr.obj-type   = p-obj-type
        and buf_cash-pay-attr.obj-code   = p-obj-code
        and buf_cash-pay-attr.attr-code = p-code
      no-error .
    if  available buf_cash-pay-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure cp-attr-delete :
  do
  on error undo, return error
  :
    define input parameter p-cdpay-code   like ub.cash-pay-attr.cdpay-code     no-undo .
    define input parameter p-curr-code    like ub.cash-pay-attr.curr-code      no-undo .
    define input parameter p-host-code    like ub.cash-pay-attr.host-code      no-undo .
    define input parameter p-obj-type     like ub.cash-pay-attr.obj-type       no-undo .
    define input parameter p-obj-code     like ub.cash-pay-attr.obj-code       no-undo .
    define input parameter p-code     like ub.cash-pay-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_cash-pay-attr for ub.cash-pay-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run cp-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-range
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_cash-pay-attr exclusive-lock
      where buf_cash-pay-attr.cdpay-code = p-cdpay-code
        and buf_cash-pay-attr.curr-code  = p-curr-code
        and buf_cash-pay-attr.host-code  = p-host-code
        and buf_cash-pay-attr.obj-type   = p-obj-type
        and buf_cash-pay-attr.obj-code   = p-obj-code
        and buf_cash-pay-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_cash-pay-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_cash-pay-attr no-error .
      if error-status:error then do:
        undo, return error return-value .
      end.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure cp-attr-news :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    case p-code :
            when 'paycard-export-prefix':U then do:     assign     p-news = true.   end.
            when 'grp-code':U then do:     assign     p-news = true.   end.
            when 'is-use':U then do:     assign     p-news = true.   end.
            when 'dop-doc':U then do:     assign     p-news = true.   end.
            when 'paycard-all-prefix':U then do:     assign     p-news = true.   end.
            when 'paycard-edit-prefix':U then do:     assign     p-news = true.   end.
            when 'form_km3':U then do:     assign     p-news = false.   end.
            when 'bal_malina':U then do:     assign     p-news = false.   end.
            when 'max_proc_sum':U then do:     assign     p-news = true.   end.
            when 'mask_card_kup':U then do:     assign     p-news = true.   end.
      otherwise do:
        p-news = no.
      end.
    end.
  end.
end procedure.
procedure cp-attr-hist :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-hist           as logical   no-undo .
    case p-code :
            when 'paycard-export-prefix':U then do:     assign     p-hist = true.   end.
            when 'paycard-all-prefix':U then do:     assign     p-hist = true.   end.
            when 'paycard-edit-prefix':U then do:     assign     p-hist = true.   end.
            when 'form_km3':U then do:     assign     p-hist = true.   end.
            when 'bal_malina':U then do:     assign     p-hist = true.   end.
            when 'max_proc_sum':U then do:     assign     p-hist = true.   end.
            when 'mask_card_kup':U then do:     assign     p-hist = true.   end.
      otherwise do:
        p-hist = no.
      end.
    end.
  end.
end procedure.
define buffer grptreal-2 for treal-2.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE create-grptreal-2.
DEFINE INPUT PARAMETER pgds-code like ub.goods.gds-code no-undo.
DEFINE INPUT PARAMETER pcpay-code like ub.cash-pay.cdpay-code no-undo.
DEFINE INPUT PARAMETER pcurr-code like ub.cash-pay.curr-code no-undo.
DEFINE INPUT PARAMETER pqnty1 as decimal no-undo.
DEFINE INPUT PARAMETER pqnty2 as decimal no-undo.
DEFINE INPUT PARAMETER pnetto as decimal no-undo.
DEFINE INPUT PARAMETER pout-name as character no-undo.
DEFINE INPUT PARAMETER pis-pay as logical no-undo.
DEFINE INPUT PARAMETER pii as integer no-undo.
_main:
DO ON ERROR UNDO _main, return error:
    create grptreal-2.
    assign
    grptreal-2.gds-code = pgds-code
    grptreal-2.cpay-code = pcpay-code
    grptreal-2.curr-code = pcurr-code
    grptreal-2.qnty1  =  pqnty1
    grptreal-2.qnty2  = pqnty2
    grptreal-2.netto = pnetto
    grptreal-2.out-name = pout-name
    grptreal-2.is-pay = pis-pay
    grptreal-2.ii = pii
    grptreal-2.discnt-type = -99
    no-error
    .
    if error-status:error then undo _main, return error.
END.
END PROCEDURE.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table report-headert no-undo
field datetimeStart as datetime
field datetimeEnd as datetime
field report-name as character
field report-label as character
field report-id as character
field report-db-num as integer
field task-num as integer
index pi is unique primary
report-id
.
define  temp-table report-parameterst no-undo
field report-id as character
field parameter-name as character
field parameter-label as character
field parameter-value-type as character
field parameter-value as character
field parameter-index as integer
field parameter-des as character
index pi is unique primary
report-id
parameter-name
parameter-index
.
define  temp-table report-errorst no-undo
field report-id as character
field ErrNum as integer
field ErrCode as integer
field ErrSeverity as integer
field ErrMessage as character
index pi is unique primary
report-id
ErrNum.
define  temp-table report-destinationt no-undo
field report-id as character
field destination-id as character
field destination as character
field destination-details as character
index pi is unique primary
report-id
destination-id.
define shared temp-table shiftt no-undo
field obj-type as character
field obj-code as integer
field obj-name as character
field obj-address as character
field obj-phone as character
field db-num as integer
field shift-date as date
field shift-num as integer
field shift-name as character
field base-code as integer
field curr-abbr as character
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
.
define shared  temp-table shift-pgdst no-undo
field obj-type as character
field obj-code as integer
field shift-date as date
field shift-num as integer
field gds-code as integer
field gds-name as character
field start-state-qnty as decimal
field start-system-qnty as decimal
field start-state-qnty-2 as decimal
field start-system-qnty-2 as decimal
field end-state-qnty as decimal
field end-system-qnty as decimal
field end-state-qnty-2 as decimal
field end-system-qnty-2 as decimal
field in-qnty as decimal
field in-qnty-2 as decimal
field icnt-out-qnty as decimal
field end-price-sale as decimal
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
gds-code
.
define shared  temp-table shift-pgds-int no-undo
field obj-type as character
field obj-code as integer
field shift-date as date
field shift-num as integer
field gds-code as integer
field doc-code as character
field cli-type-code as character
field cli-name as character
field fact-qnty as decimal
field fact-qnty-2 as decimal
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
gds-code
doc-code
.
define shared  temp-table shift-pgds-outt no-undo
field obj-type as character
field obj-code as integer
field shift-date as date
field shift-num as integer
field gds-code as integer
field pay-code as integer
field curr-code as integer
field cp-type as integer
field out-name as character
field fact-qnty as decimal
field fact-qnty-2 as decimal
field fact-sum as decimal
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
gds-code
pay-code
curr-code
.
define shared temp-table shift-grpt no-undo
field obj-type as character
field obj-code as integer
field shift-date as date
field shift-num as integer
field grp-code as integer
field full-grp-name as character
field start-qnty as decimal
field start-sum as decimal
field end-qnty as decimal
field end-sum as decimal
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
grp-code
.
define shared temp-table shift-grp-int no-undo
field obj-type as character
field obj-code as integer
field shift-date as date
field shift-num as integer
field grp-code as integer
field doc-code as character
field cli-type-code as character
field cli-name as character
field fact-qnty as decimal
field fact-cost-sum as decimal
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
grp-code
doc-code
.
define shared temp-table shift-grp-outt no-undo
field obj-type as character
field obj-code as integer
field shift-date as date
field shift-num as integer
field grp-code as integer
field pay-code as integer
field curr-code as integer
field cp-type as integer
field out-name as character
field fact-qnty as decimal
field fact-sum as decimal
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
grp-code
pay-code
curr-code
.
define dataset shift-1t
for shiftt, shift-pgdst, shift-pgds-int, shift-pgds-outt, shift-grpt, shift-grp-int, shift-grp-outt,
report-headert, report-parameterst, report-errorst
data-relation r1 for shiftt, shift-pgdst
relation-fields (obj-type, obj-type, obj-code, obj-code, shift-date, shift-date, shift-num, shift-num) nested
data-relation r2 for shiftt, shift-grpt
relation-fields (obj-type, obj-type, obj-code, obj-code, shift-date, shift-date, shift-num, shift-num) nested
data-relation r11 for shift-pgdst, shift-pgds-outt
relation-fields (obj-type, obj-type, obj-code, obj-code, shift-date, shift-date, shift-num, shift-num, gds-code, gds-code) nested
data-relation r12 for shift-pgdst, shift-pgds-int
relation-fields (obj-type, obj-type, obj-code, obj-code, shift-date, shift-date, shift-num, shift-num, gds-code, gds-code) nested
data-relation r21 for shift-grpt, shift-grp-outt
relation-fields (obj-type, obj-type, obj-code, obj-code, shift-date, shift-date, shift-num, shift-num, grp-code, grp-code) nested
data-relation r22 for shift-grpt, shift-grp-int
relation-fields (obj-type, obj-type, obj-code, obj-code, shift-date, shift-date, shift-num, shift-num, grp-code, grp-code) nested
data-relation rh1 for report-headert, report-parameterst
relation-fields (report-id, report-id) nested
data-relation rh2 for report-headert, report-errorst
relation-fields (report-id, report-id) nested
.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define shared stream PrnLibstream.
define variable pol1  as character no-undo.
define variable pol2  as integer   no-undo.
define variable pol3  as decimal   no-undo.
define variable pol4  as decimal   no-undo.
define variable pol5  as decimal   no-undo.
define variable pol6  as character no-undo.
define variable pol7  as integer   no-undo.
define variable pol8  as character no-undo.
define variable pol9  as decimal   no-undo.
define variable pol10 as decimal   no-undo.
define variable pol11 as decimal   no-undo.
define variable pol12 as decimal   no-undo.
define variable pol13 as character no-undo.
define variable pol14 as decimal   no-undo.
define variable pol15 as decimal   no-undo.
define variable pol16 as decimal   no-undo.
define variable pol17 as decimal   no-undo.
define variable pol18 as decimal   no-undo.
define variable line  as character no-undo.
define variable pol8-excel as character no-undo.
define variable areal-is-pay-qnty1 as decimal   no-undo.
define variable areal-is-pay-qnty2 as decimal   no-undo.
define variable areal-is-pay-netto as decimal   no-undo.
define variable areal-no-pay-qnty1 as decimal   no-undo.
define variable areal-no-pay-qnty2 as decimal   no-undo.
define variable areal-no-pay-netto as decimal   no-undo.
define variable areal-qnty1        as decimal   no-undo.
define variable areal-qnty2        as decimal   no-undo.
define variable areal-netto        as decimal   no-undo.
define variable aincome-qnty1      as decimal   no-undo.
define variable aincome-qnty2      as decimal   no-undo.
define variable loc-real-ii        as integer   no-undo.
define variable curr-real-ii       as integer   no-undo.
define variable loc-income-ii      as integer   no-undo.
define variable jj                 as integer   no-undo.
define variable loc-jj             as integer   no-undo.
define variable main-line          as logical   no-undo.
define variable supp-line          as logical   no-undo.
define variable pay-line           as logical   no-undo.
define variable rc                 as recid     no-undo.
define variable accum-4            as decimal   no-undo.
define variable accum-5            as decimal   no-undo.
define variable accum-9            as decimal   no-undo.
define variable accum-11           as decimal   no-undo.
define variable accum-13           as decimal   no-undo.
define variable accum-14           as decimal   no-undo.
define variable accum-15           as decimal   no-undo.
define variable accum-16           as decimal   no-undo.
define variable accum-17           as decimal   no-undo.
define variable accum-18           as decimal   no-undo.
define variable acii               as integer   no-undo.
define variable v-grp-name         as character no-undo.
define variable v-grp-code         as integer   no-undo.
define variable v-step             as integer   no-undo.
define variable v-is-pay           as logical   no-undo.
define variable loc-grpii          as integer   no-undo.
define variable v-attr-value       as character no-undo.
define variable v-attr-type        as character no-undo.
define variable loc-grp-only-not-single as integer no-undo .
define variable v-delta            as integer no-undo .
define buffer buf_shift-pgds for shift-pgdst.
define buffer buf_shift-pgds-in for shift-pgds-int.
define buffer buf_shift-pgds-out for shift-pgds-outt.
define buffer buf_cash-pay for ub.cash-pay.
  procedure on-same-page :
    define input parameter p-line-number as integer no-undo .
    if p-line-number > page-size( PrnLibstream )
    then do:
      return .
    end.
    if line-counter( PrnLibstream ) + p-line-number > page-size( PrnLibstream )
    then do:
      page stream PrnLibstream .
    end.
  end procedure.
FUNCTION get-grp-name-code RETURNS INTEGER
  ( INPUT p-cdpay-code AS integer, INPUT p-curr-code AS INTEGER, output p-grp-name as character ) :
DEFINE VARIABLE v-dopi AS INTEGER NO-UNDO INIT ?.
DEFINE VARIABLE v-value AS character NO-UNDO.
DEFINE VARIABLE v-type AS character NO-UNDO.
  RUN cp-attr-value  IN THIS-PROCEDURE(
     input p-cdpay-code
    ,input p-curr-code
    ,input 0
    ,input '':U
    ,input 0
    ,INPUT 'grp-code':U
    ,output v-value
    ,OUTPUT v-type) NO-ERROR.
  IF NOT ERROR-STATUS:ERROR THEN DO:
      ASSIGN
      v-dopi = INTEGER(entry(2, v-value, chr(4)))
      p-grp-name = entry(1, v-value, chr(4) )
      NO-ERROR.
  END.
  RETURN v-dopi.
END FUNCTION.
DEFINE FRAME FRAME-2
  pol1  COLUMN-LABEL "2.1":C12  FORMAT "x(12)":U        SPACE( 0 )   sym1  COLUMN-LABEL ":" FORMAT "x(1)":U SPACE( 0 )
  pol2  COLUMN-LABEL "2.2":C10  FORMAT  ">>>>>>>>>9":U  SPACE( 0 )   sym2  COLUMN-LABEL ":" FORMAT "x(1)":U SPACE( 0 )
  pol3  COLUMN-LABEL "2.3":C8   FORMAT  ">>>>9.99":U    SPACE( 0 )   sym3  COLUMN-LABEL ":" FORMAT "x(1)":U SPACE( 0 )
  pol4  COLUMN-LABEL "2.4":C9   FORMAT "->>>>9.99":U    SPACE( 0 )   sym4  COLUMN-LABEL ":" FORMAT "x(1)":U SPACE( 0 )
  pol5  COLUMN-LABEL "2.5":C9   FORMAT "->>>>>.99":U    SPACE( 0 )   sym5  COLUMN-LABEL ":" FORMAT "x(1)":U SPACE( 0 )
  pol6  COLUMN-LABEL "2.6":C18  FORMAT "x(18)":U        SPACE( 0 )   sym6  COLUMN-LABEL ":" FORMAT "x(1)":U SPACE( 0 )
  pol7  COLUMN-LABEL "2.7":C9   FORMAT ">>>>>>>>9":U    SPACE( 0 )   sym7  COLUMN-LABEL ":" FORMAT "x(1)":U SPACE( 0 )
  pol8  COLUMN-LABEL "2.8":C14  FORMAT "x(14)":U        SPACE( 0 )   sym8  COLUMN-LABEL ":" FORMAT "x(1)":U SPACE( 0 )
  pol9  COLUMN-LABEL "2.9":C8   FORMAT ">>>>9.99":U     SPACE( 0 )   sym9  COLUMN-LABEL ":" FORMAT "x(1)":U SPACE( 0 )
  pol10 COLUMN-LABEL "2.10":C5  FORMAT "9.9999":U        SPACE( 0 )   sym10 COLUMN-LABEL ":" FORMAT "x(1)":U SPACE( 0 )
  pol11 COLUMN-LABEL "2.11":C8  FORMAT ">>>>9.99":U     SPACE( 0 )   sym11 COLUMN-LABEL ":" FORMAT "x(1)":U SPACE( 0 )
  pol12 COLUMN-LABEL "2.12":C6  FORMAT "->9.99":U       SPACE( 0 )   sym12 COLUMN-LABEL ":" FORMAT "x(1)":U SPACE( 0 )
  pol13 COLUMN-LABEL "2.13":C18 FORMAT "x(18)":U        SPACE( 0 )   sym13 COLUMN-LABEL ":" FORMAT "x(1)":U SPACE( 0 )
  pol14 COLUMN-LABEL "2.14":C9  FORMAT "->>>>9.99":U    SPACE( 0 )   sym14 COLUMN-LABEL ":" FORMAT "x(1)":U SPACE( 0 )
  pol15 COLUMN-LABEL "2.15":C9  FORMAT "->>>>9.99":U    SPACE( 0 )   sym15 COLUMN-LABEL ":" FORMAT "x(1)":U SPACE( 0 )
  pol16 COLUMN-LABEL "2.16":C12 FORMAT "->>>>>>>9.99":U SPACE( 0 )   sym16 COLUMN-LABEL ":" FORMAT "x(1)":U SPACE( 0 )
  pol17 COLUMN-LABEL "2.17":C9  FORMAT "->>>>9.99":U    SPACE( 0 )   sym17 COLUMN-LABEL ":" FORMAT "x(1)":U SPACE( 0 )
  pol18 COLUMN-LABEL "2.18":C9  FORMAT "->>>>9.99":U    SPACE( 0 )
WITH WIDTH 232 DOWN STREAM-IO USE-TEXT NO-BOX.
run rep/r-shft2r.p ( input p-obj-type
                    ,input p-obj-code
                    ,input X-date-Start
                    ,input X-Shift-Start
                    ,input X-date-End
                    ,input X-Shift-End
                    ,input p-previous-shift-date
                    ,input p-batch
                    ,input p-codex-id
                    ,input p-ruleset-id
                    ) no-error.
if error-status:error then do:
  return error substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6"
                          ,vss-workfile
                          ,vss-revision
                          ,vss-description
                          ,chr(10)
                          , error-status:get-message(1)
                          , return-value ).
end.
FORM HEADER
  string( p-z-number-list, "x(198)":U ) format "x(198)":U skip "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" skip "               ИНФОРМАЦИЯ О ПРОДУКТЕ               :                           РАСШИФРОВКА ПОСТУПЛЕНИЯ                        :               РАСШИФРОВКА РЕАЛИЗАЦИИ              :       ОСТАТОК     " skip "------------------------------------------------------------------------------------------------------------------------------:---------------------------------------------------:       на конец    " skip "НАИМЕНОВАНИЕ:   КОД   :ЦЕНА    : ОСТАТОК НА НАЧАЛО :           ПОСТАВЩИК       :    НОМЕР     :        КОЛИЧЕСТВО      :ТЕМПЕ-:    ТИП РАСХОДА   : КОЛ-ВО  : КОЛ-ВО  :    СУММА   :-------------------" skip "  продукта  : товара  :розничн :-------------------:---------------------------:   документа  :------------------------:РАТУРА:   (тип платежа)  :в литрах :в килогр :            : КОЛ-ВО  : КОЛ-ВО  " skip "            :         :на конец:  ОБЪЕМ  : МАССА   :   Наименование   :  Код   :    прихода   : ОБЪЕМ  :ПЛОТ- : МАССА  :в цис-:                  :         :         :            :в литрах :в килогр." skip "            :         :смены   :         :         :                  :        :     (ТТН)    :        :НОСТЬ :        : терне:                  :         :         :            :         :         " skip "            :         :        :    л    :   кг    :                  :        :              :   л    :кг/м3 :   кг   : гр.С :                  :    л    :    кг   :            :         :         " skip "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
WITH FRAME TopFrame WIDTH 232 PAGE-TOP NO-LABELS NO-BOX.
VIEW STREAM PrnLibstream FRAME TOpFrame.
for each actreal-2 :
  delete actreal-2 .
end.
FOR EACH t-2 USE-INDEX pi :
  assign areal-is-pay-qnty1 = 0
         areal-is-pay-qnty2 = 0
         areal-is-pay-netto = 0
         areal-no-pay-qnty1 = 0
         areal-no-pay-qnty2 = 0
         areal-no-pay-netto = 0
         areal-qnty1        = 0
         areal-qnty2        = 0
         areal-netto        = 0
         aincome-qnty1      = 0
         aincome-qnty2      = 0
         loc-real-ii        = 1
         loc-grpii          = 0
         loc-grp-only-not-single = 0
         loc-income-ii      = 0
         curr-real-ii       = 1.
  FIND LAST treal-2 NO-LOCK WHERE
            treal-2.gds-code = t-2.gds-code AND
            treal-2.is-pay   = YES          USE-INDEX vi NO-ERROR.
  if available treal-2 then do:
    assign loc-real-ii  = treal-2.ii + 1
           curr-real-ii = treal-2.ii + 1.
  end.
  IF CAN-FIND( FIRST treal-2 WHERE
                     treal-2.gds-code = t-2.gds-code ) THEN DO:
    do v-step = 1 to 2:
      if v-step = 1 then assign v-is-pay = yes.
      if v-step = 2 then assign v-is-pay = no .
      FOR EACH treal-2 WHERE treal-2.is-pay = v-is-pay AND treal-2.gds-code = t-2.gds-code and treal-2.curr-code >= 0 USE-INDEX pi :
        assign
          areal-qnty1 = areal-qnty1 + treal-2.qnty1
          areal-qnty2 = areal-qnty2 + treal-2.qnty2
          areal-netto = areal-netto + treal-2.netto
        .
        if treal-2.is-pay = yes then do:
          assign
          areal-is-pay-qnty1 = areal-is-pay-qnty1 + treal-2.qnty1
          areal-is-pay-qnty2 = areal-is-pay-qnty2 + treal-2.qnty2
          areal-is-pay-netto = areal-is-pay-netto + treal-2.netto.
          if p-with-cp-grouping = yes then do:
            assign
            v-grp-code = ?
            v-grp-code = get-grp-name-code(treal-2.cpay-code, treal-2.curr-code, output v-grp-name)
            v-grp-code = (if v-grp-code = ? then 10000 else v-grp-code)
            v-grp-name = (if v-grp-code = 10000
                          then "(По остальным)"
                          else substitute("(По гр. &1)", string(v-grp-name, "X(9)"))
                          )
            .
            FIND FIRST grptreal-2 WHERE
                        grptreal-2.gds-code = treal-2.gds-code AND
                        grptreal-2.cpay-code = - v-grp-code AND
                        grptreal-2.curr-code = - 1 AND
                        grptreal-2.is-pay = treal-2.is-pay NO-ERROR.
            if not available grptreal-2 then do:
              run create-treal-2 in this-procedure ( input treal-2.gds-code,
                                                        input - v-grp-code,
                                                        input - 1 ,
                                                        input treal-2.qnty1,
                                                        input treal-2.qnty2,
                                                        input treal-2.netto,
                                                        input  chr(4) + v-grp-name,
                                                        input treal-2.is-pay,
                                                        input loc-real-ii ) no-error.
              assign
              curr-real-ii = curr-real-ii + 1
              loc-grp-only-not-single = loc-grp-only-not-single + 1
              loc-real-ii = loc-real-ii + 1
              loc-grpii       = loc-grpii + 1
              .
            end.
            else do:
              assign
              loc-grp-only-not-single = (if grptreal-2.out-name  begins chr(4)
                                     then (loc-grp-only-not-single - 1)
                                     else loc-grp-only-not-single)
              grptreal-2.out-name = v-grp-name
              grptreal-2.qnty1 = grptreal-2.qnty1 + treal-2.qnty1
              grptreal-2.qnty2 = grptreal-2.qnty2 + treal-2.qnty2
              grptreal-2.netto = grptreal-2.netto + treal-2.netto
              .
            end.
          end.
        end.
        else do:
          assign
                rc            = recid( treal-2 )
          curr-real-ii         = ( if (curr-real-ii = loc-real-ii)
                                   AND
                                    ( (loc-real-ii - loc-grp-only-not-single) > 1
                                    OR
                                    can-find( first treal-2 no-lock where
                                                    treal-2.gds-code =  t-2.gds-code and
                                                    treal-2.is-pay   =  no           and
                                                    recid( treal-2 ) <> rc ) )
                                  then ( curr-real-ii + 1 )
                                  else   curr-real-ii )
          treal-2.ii           = curr-real-ii
          curr-real-ii         = curr-real-ii + 1.
          if treal-2.cpay-code <> -4 then do:
            assign areal-no-pay-qnty1 = areal-no-pay-qnty1 + treal-2.qnty1
                  areal-no-pay-qnty2 = areal-no-pay-qnty2 + treal-2.qnty2
                  areal-no-pay-netto = areal-no-pay-netto + treal-2.netto.
          end.
        end.
      end.
    END.
    if curr-real-ii - loc-grp-only-not-single > 2 then do:
      run create-treal-2 in this-procedure ( input t-2.gds-code,
                                             input 0,
                                             input 0,
                                             input areal-is-pay-qnty1,
                                             input areal-is-pay-qnty2,
                                             input areal-is-pay-netto,
                                             input "ИТОГО ОПЛАЧ.РАСХОД",
                                             input yes,
                                             input loc-real-ii           ) no-error.
      if loc-real-ii = curr-real-ii then do:
        assign curr-real-ii = curr-real-ii + 1.
      end.
      run create-treal-2 in this-procedure ( input t-2.gds-code,
                                             input 0,
                                             input 0,
                                             input areal-no-pay-qnty1,
                                             input areal-no-pay-qnty2,
                                             input areal-no-pay-netto,
                                             input "ИТОГО ПРОЧ.РАСХОД",
                                             input no,
                                             input curr-real-ii         ) no-error.
      assign curr-real-ii = curr-real-ii + 1.
      run create-treal-2 in this-procedure ( input t-2.gds-code,
                                             input 0,
                                             input 0,
                                             input areal-qnty1,
                                             input areal-qnty2,
                                             input areal-netto,
                                             input "ВСЕГО РАСХОД ",
                                             input ?,
                                             input curr-real-ii     ) no-error.
    end.
  END.
  FOR EACH tincome-2 WHERE
           tincome-2.gds-code = t-2.gds-code
           USE-INDEX vi
           :
    if tincome-2.supp-name = "Итого по поставщику" then do:
      assign loc-income-ii = tincome-2.ii .
      next.
    end.
    assign aincome-qnty1 = aincome-qnty1 + tincome-2.qnty1
           aincome-qnty2 = aincome-qnty2 + tincome-2.qnty2
           loc-income-ii = tincome-2.ii
           .
  END.
  if loc-income-ii > 1 then do:
    run create-tincome-2 in this-procedure ( input t-2.gds-code,
                                             input "",
                                             input aincome-qnty1,
                                             input aincome-qnty2,
                                             input "ИТОГО ПОСТУПЛЕНИЙ",
                                             input 0,
                                             input no,
                                             input ( loc-income-ii + 1 ) ) no-error.
    assign loc-income-ii = loc-income-ii + 1.
  end.
  assign t-2.lines = MAX( curr-real-ii - loc-grp-only-not-single
                        , loc-income-ii, 1 ).
END.
if Make-Excel then  put   stream ForExcel unformatted skip.
FOR EACH t-2 NO-LOCK
    BREAK
      BY t-2.main-code :
  v-delta = 0.
  DO jj = 1 TO t-2.lines :
    assign pol1      = "":U
           pol2      = 0
           pol3      = 0
           pol4      = 0
           pol5      = 0
           pol6      = "":U
           pol7      = 0
           pol8      = "":U
           pol9      = 0
           pol10     = 0
           pol11     = 0
           pol12     = ?
           pol13     = "":U
           pol14     = 0
           pol15     = 0
           pol16     = 0
           pol17     = 0
           pol18     = 0
           main-line = no
           supp-line = no
           pay-line  = no.
    IF jj = 1 then do:
      assign pol1      = t-2.gds-name
             pol2      = t-2.main-code
             pol3      = t-2.last-price
             pol4      = t-2.qnty1-before
             pol5      = t-2.qnty2-before
             pol17     = t-2.qnty1-after
             pol18     = t-2.qnty2-after
             main-line = yes.
      if p-batch > 0
      and p-report-id  = "53/2040"
      then do:
        find first buf_shift-pgds where
                buf_shift-pgds.obj-type = p-obj-type
            and buf_shift-pgds.obj-code = p-obj-code
            and buf_shift-pgds.shift-date = X-date-end
            and buf_shift-pgds.shift-num = X-shift-end
            and buf_shift-pgds.gds-code = t-2.gds-code no-error.
        if available buf_shift-pgds then do:
          assign
          buf_shift-pgds.end-price-sale = t-2.last-price
          .
          release buf_shift-pgds.
        end.
      end.
    END.
    FIND FIRST tincome-2 NO-LOCK WHERE
               tincome-2.gds-code = t-2.gds-code AND
               tincome-2.ii       = jj           NO-ERROR.
    IF AVAIlABLE tincome-2 THEN DO:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input tincome-2.doc-code ,
                        input 'nids':U ,
                       output v-attr-value ,
                       output v-attr-type )  .
      assign
        pol8 = if v-attr-value = "" or v-attr-value = ?
               then tincome-2.doc-code
               else v-attr-value
        pol8-excel = if v-attr-value = "" or v-attr-value = ?
               then tincome-2.doc-code
               else '="' + v-attr-value + '"'
      .
      ASSIGN pol6      = tincome-2.supp-name
             pol7      = tincome-2.supp-code
             pol9      = tincome-2.qnty1
             pol10     = tincome-2.density
             pol11     = tincome-2.qnty2
             pol12     = tincome-2.temperature
             supp-line = yes.
     if p-batch > 0
     and tincome-2.supp-code > 0
     and tincome-2.gds-code > 0
     and p-report-id  = "53/2040"
     then do:
      find first buf_shift-pgds-in where
                buf_shift-pgds-in.obj-type = p-obj-type
            and buf_shift-pgds-in.obj-code = p-obj-code
            and buf_shift-pgds-in.shift-date = X-date-end
            and buf_shift-pgds-in.shift-num = X-shift-end
            and buf_shift-pgds-in.gds-code = t-2.gds-code
            and buf_shift-pgds-in.doc-code = tincome-2.doc-code no-error.
        if not available buf_shift-pgds-in then do:
          create buf_shift-pgds-in.
          assign
          buf_shift-pgds-in.obj-type = p-obj-type
          buf_shift-pgds-in.obj-code = p-obj-code
          buf_shift-pgds-in.shift-date = X-date-end
          buf_shift-pgds-in.shift-num = X-shift-end
          buf_shift-pgds-in.gds-code = t-2.gds-code
          buf_shift-pgds-in.doc-code = tincome-2.doc-code
          buf_shift-pgds-in.cli-type-code = substitute("&1&2", tincome-2.supp-type, tincome-2.supp-code)
          buf_shift-pgds-in.cli-name = tincome-2.supp-name
          buf_shift-pgds-in.fact-qnty = tincome-2.qnty1
          buf_shift-pgds-in.fact-qnty-2 = tincome-2.qnty2
          .
          release buf_shift-pgds-in.
        end.
      end.
    END.
   _not-empty-group:
    do while true :
      FIND FIRST treal-2 NO-LOCK WHERE
                treal-2.gds-code = t-2.gds-code AND
                treal-2.ii       = jj + v-delta          NO-ERROR.
      if not available treal-2  then leave _not-empty-group.
      if available treal-2 then do:
        if treal-2.cpay-code <> 0
        or treal-2.curr-code= - 1
        then do:
          FIND FIRST actreal-2 WHERE
                    actreal-2.gds-code = 0 AND
                    actreal-2.cpay-code = treal-2.cpay-code AND
                    actreal-2.curr-code = treal-2.curr-code AND
                    actreal-2.is-pay = treal-2.is-pay NO-ERROR.
          if not available actreal-2 then do:
            assign acii = acii + 1.
            run create-actreal-2 in this-procedure ( input 0,
                                                    input treal-2.cpay-code,
                                                    input treal-2.curr-code,
                                                    input treal-2.qnty1,
                                                    input treal-2.qnty2,
                                                    input treal-2.netto,
                                                    input trim(treal-2.out-name, chr(4)),
                                                    input treal-2.is-pay,
                                                    input acii               ) no-error.
          end.
          else do:
            assign actreal-2.qnty1 = actreal-2.qnty1 + treal-2.qnty1
                  actreal-2.qnty2 = actreal-2.qnty2 + treal-2.qnty2
                  actreal-2.netto = actreal-2.netto + treal-2.netto.
          end.
        end.
        if treal-2.is-pay = yes
        and treal-2.curr-code < 0
        and treal-2.out-name begins chr(4) then do:
          assign
          v-delta = v-delta + 1
          .
          next _not-empty-group.
        end.
        else do:
          assign
          pol13    = treal-2.out-name
          pol14    = treal-2.qnty1
          pol15    = treal-2.qnty2
          pol16    = treal-2.netto
          pay-line = yes
          .
          if p-batch > 0
        and (treal-2.curr-code > 0
        or not (treal-2.curr-code = 0 and treal-2.cpay-code = 0)
        )
        and treal-2.gds-code > 0
          and p-report-id  = "53/2040"
        then do:
          find first buf_shift-pgds-out where
                buf_shift-pgds-out.obj-type = p-obj-type
            and buf_shift-pgds-out.obj-code = p-obj-code
            and buf_shift-pgds-out.shift-date = X-date-end
            and buf_shift-pgds-out.shift-num = X-shift-end
            and buf_shift-pgds-out.gds-code = treal-2.gds-code
              and buf_shift-pgds-out.pay-code = treal-2.cpay-code
              and buf_shift-pgds-out.curr-code = treal-2.curr-code
              no-error.
          if not available buf_shift-pgds-out then do:
              find first buf_cash-pay no-lock where
                        buf_cash-pay.cdpay-code = treal-2.cpay-code
                  and  buf_cash-pay.curr-code = treal-2.curr-code no-error.
              create buf_shift-pgds-out.
            assign
            buf_shift-pgds-out.obj-type = p-obj-type
            buf_shift-pgds-out.obj-code = p-obj-code
            buf_shift-pgds-out.shift-date = X-date-end
            buf_shift-pgds-out.shift-num = X-shift-end
            buf_shift-pgds-out.gds-code = treal-2.gds-code
            buf_shift-pgds-out.pay-code = treal-2.cpay-code
              buf_shift-pgds-out.curr-code = treal-2.curr-code
            buf_shift-pgds-out.out-name = treal-2.out-name
              buf_shift-pgds-out.cp-type = (if available buf_cash-pay
                                            and buf_cash-pay.is-cash
                                            then 1
                                            else 2)
            buf_shift-pgds-out.fact-qnty = treal-2.qnty1
            buf_shift-pgds-out.fact-qnty-2 = treal-2.qnty2
            buf_shift-pgds-out.fact-sum = treal-2.netto
            .
            release buf_shift-pgds-out.
              .
            end.
          end.
          leave _not-empty-group.
          end.
        end.
    end.
    DISPLAY STREAM PrnLibstream pol1
                             pol2  WHEN main-line = yes
                             pol3  WHEN main-line = yes
                             pol4  WHEN main-line = yes
                             pol5  WHEN main-line = yes
                             pol6
                             pol7  WHEN pol7 <> 0
                             pol8  WHEN pol8 <> ""
                             pol9  WHEN supp-line = yes
                             pol10 when supp-line = yes and pol10 <> ? and pol10 > 0
                             pol11 WHEN supp-line = yes
                             pol12 WHEN pol7 <> 0 and pol12 <> ?
                             pol13
                             pol14 WHEN pay-line  = yes
                             pol15 WHEN pay-line  = yes
                             pol16 WHEN pay-line  = yes
                             pol17 WHEN main-line = yes
                             pol18 WHEN main-line = yes
                             sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym13 sym14 sym15 sym16 sym17
    WITH FRAME FRAME-2.
    if jj < t-2.lines then do: down stream PrnLibstream with frame FRAME-2. end.
    if main-line = yes then do:
      assign accum-4  = accum-4  + pol4
             accum-5  = accum-5  + pol5
             accum-17 = accum-17 + pol17
             accum-18 = accum-18 + pol18.
      if Make-Excel then  put   stream ForExcel unformatted pol1 CHR(9)
                  pol2 CHR(9)
                  pol3 CHR(9)
                  pol4 CHR(9)
                  pol5 CHR(9).
    end.
    else do:
      if Make-Excel then  put   stream ForExcel unformatted CHR(9)
                  CHR(9)
                  CHR(9)
                  CHR(9)
                  CHR(9).
    end.
    if supp-line = yes then do:
      if tincome-2.is-fact = yes then do:
        assign accum-9  = accum-9  + pol9
               accum-11 = accum-11 + pol11.
      end.
      if Make-Excel then  put   stream ForExcel unformatted pol6                                                           CHR(9)
                  ( if pol7 <> 0 then string( pol7  ) else "":U )                CHR(9)
                  ( if pol8-excel <> "" then pol8-excel else "":U)               CHR(9)
                  pol9                                                           CHR(9)
                  ( if pol7 <> 0 and pol10 <> ? then string( pol10 ) else "":U ) CHR(9)
                  pol11                                                          CHR(9)
                  ( if pol7 <> 0 and pol12 <> ? then string( pol12 ) else "":U ) CHR(9).
    end.
    else do:
      if Make-Excel then  put   stream ForExcel unformatted CHR(9)
                  CHR(9)
                  CHR(9)
                  CHR(9)
                  CHR(9)
                  CHR(9)
                  CHR(9).
    end.
    if pay-line = yes then do:
      if treal-2.cpay-code <> 0
      and treal-2.curr-code <>  - 1
      then do:
      assign accum-14 = accum-14 + pol14
             accum-15 = accum-15 + pol15
             accum-16 = accum-16 + pol16.
      end.
      if Make-Excel then  put   stream ForExcel unformatted pol13 CHR(9)
                  pol14 CHR(9)
                  pol15 CHR(9)
                  pol16 CHR(9).
    end.
    else do:
      if Make-Excel then  put   stream ForExcel unformatted CHR(9)
                  CHR(9)
                  CHR(9)
                  CHR(9).
    end.
    if main-line = yes then do:
      if Make-Excel then  put   stream ForExcel unformatted pol17 CHR(9)
                  pol18 skip.
    end.
    else do:
      if Make-Excel then  put   stream ForExcel unformatted CHR(9) skip.
    end.
  END.
  DOWN 1 STREAM PrnLibstream WITH FRAME FRAME-2.
  if Make-Excel then  put   stream ForExcel unformatted FILL( CHR(9), 17 ) skip.
  IF LAST( t-2.main-code ) THEN DO:
    assign pol1  = "ИТОГО"
           pol4  = accum-4
           pol5  = accum-5
           pol9  = accum-9
           pol11 = accum-11
           POL13 = "ИТОГО РАСХОД"
           pol14 = accum-14
           pol15 = accum-15
           pol16 = accum-16
           pol17 = accum-17
           pol18 = accum-18.
        run on-same-page in this-procedure ( input 1 + 2 + acii + ( if acii = 0 then 0 else 1 ) +                              ( if can-find( first actreal-2 where actreal-2.is-pay = yes ) then 1 else 0 ) +                              ( if can-find( first actreal-2 where actreal-2.is-pay = no  ) then 1 else 0 ) ) .
    UNDERLINE STREAM PrnLibstream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym13 sym14 sym15 sym16 sym17 pol1 pol2 pol3 pol4 pol5 pol6 pol7 pol8 pol9 pol10 pol11 pol12 pol13 pol14 pol15 pol16 pol17 pol18 WITH FRAME FRAME-2.
    DISPLAY STREAM PrnLibstream pol1
                             pol4
                             pol5
                             pol9
                             pol11
                             pol13
                             pol14
                             pol15
                             pol16
                             pol17
                             pol18
                             sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym13 sym14 sym15 sym16 sym17
    WITH FRAME FRAME-2.
    if Make-Excel then  put   stream ForExcel unformatted pol1  CHR(9)
                      CHR(9)
                      CHR(9)
                pol4  CHR(9)
                pol5  CHR(9)
                      CHR(9)
                      CHR(9)
                      CHR(9)
                pol9  CHR(9)
                      CHR(9)
                pol11 CHR(9)
                      CHR(9)
                pol13 CHR(9)
                pol14 CHR(9)
                pol15 CHR(9)
                pol16 CHR(9)
                pol17 CHR(9)
                pol18 skip.
    DOWN 1 STREAM PrnLibstream WITH FRAME FRAME-2.
    if can-find( first actreal-2 no-lock ) then do:
      assign pol13 = "     в том числе:".
      DISPLAY STREAM PrnLibstream pol13 sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym13 sym14 sym15 sym16 sym17 WITH FRAME FRAME-2.
      if Make-Excel then  put   stream ForExcel unformatted       CHR(9)
                        CHR(9)
                        CHR(9)
                        CHR(9)
                        CHR(9)
                        CHR(9)
                        CHR(9)
                        CHR(9)
                        CHR(9)
                        CHR(9)
                        CHR(9)
                        CHR(9)
                  pol13 CHR(9)
                        CHR(9)
                        CHR(9)
                        CHR(9)
                        CHR(9) skip.
      DOWN 1 STREAM PrnLibstream WITH FRAME FRAME-2.
      assign areal-is-pay-qnty1 = 0
             areal-is-pay-qnty2 = 0
             areal-is-pay-netto = 0
             areal-no-pay-qnty1 = 0
             areal-no-pay-qnty2 = 0
             areal-no-pay-netto = 0.
      FOR EACH actreal-2 NO-LOCK
          BREAK
            BY actreal-2.gds-code
            By actreal-2.is-pay    DESCENDING
            BY actreal-2.cpay-code DESCENDING
            BY actreal-2.curr-code :
        if actreal-2.is-pay = yes then do:
          if actreal-2.curr-code >= 0 then
          assign areal-is-pay-qnty1 = areal-is-pay-qnty1 + actreal-2.qnty1
                 areal-is-pay-qnty2 = areal-is-pay-qnty2 + actreal-2.qnty2
                 areal-is-pay-netto = areal-is-pay-netto + actreal-2.netto.
        end.
        else do:
          assign areal-no-pay-qnty1 = areal-no-pay-qnty1 + actreal-2.qnty1
                 areal-no-pay-qnty2 = areal-no-pay-qnty2 + actreal-2.qnty2
                 areal-no-pay-netto = areal-no-pay-netto + actreal-2.netto .
        end.
        assign pol13 = actreal-2.out-name
               pol14 = actreal-2.qnty1
               pol15 = actreal-2.qnty2
               pol16 = actreal-2.netto.
        DISPLAY STREAM PrnLibstream pol13
                                 pol14
                                 pol15
                                 pol16
                                 sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym13 sym14 sym15 sym16 sym17
        WITH FRAME FRAME-2.
        if Make-Excel then  put   stream ForExcel unformatted       CHR(9)
                          CHR(9)
                          CHR(9)
                          CHR(9)
                          CHR(9)
                          CHR(9)
                          CHR(9)
                          CHR(9)
                          CHR(9)
                          CHR(9)
                          CHR(9)
                          CHR(9)
                    pol13 CHR(9)
                    pol14 CHR(9)
                    pol15 CHR(9)
                    pol16 CHR(9)
                          CHR(9) skip.
        DOWN 1 STREAM PrnLibstream WITH FRAME FRAME-2.
        if last-of( actreal-2.is-pay )  then do:
          if actreal-2.is-pay = yes then do:
            assign pol13 = "ИТОГО ОПЛАЧ.РАСХОД"
                   pol14 = areal-is-pay-qnty1
                   pol15 = areal-is-pay-qnty2
                   pol16 = areal-is-pay-netto.
          end.
          else do:
            assign pol13 = "ИТОГО ПРОЧ.РАСХОД"
                   pol14 = areal-no-pay-qnty1
                   pol15 = areal-no-pay-qnty2
                   pol16 = areal-no-pay-netto.
          end.
          DISPLAY STREAM PrnLibstream pol13
                                   pol14
                                   pol15
                                   pol16
                                   sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym13 sym14 sym15 sym16 sym17
          WITH FRAME FRAME-2.
          if Make-Excel then  put   stream ForExcel unformatted       CHR(9)
                            CHR(9)
                            CHR(9)
                            CHR(9)
                            CHR(9)
                            CHR(9)
                            CHR(9)
                            CHR(9)
                            CHR(9)
                            CHR(9)
                            CHR(9)
                            CHR(9)
                      pol13 CHR(9)
                      pol14 CHR(9)
                      pol15 CHR(9)
                      pol16 CHR(9)
                            CHR(9) skip.
          DOWN 1 STREAM PrnLibstream WITH FRAME FRAME-2.
        end.
      END.
    END.
    UNDERLINE STREAM PrnLibstream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym13 sym14 sym15 sym16 sym17 pol1 pol2 pol3 pol4 pol5 pol6 pol7 pol8 pol9 pol10 pol11 pol12 pol13 pol14 pol15 pol16 pol17 pol18 WITH FRAME FRAME-2.
  END.
END.
PROCEDURE create-tincome-2 :
  define input parameter p-gds-code  like ub.goods.gds-code   no-undo.
  define input parameter p-doc-code  like ub.trn-doc.doc-code no-undo.
  define input parameter p-qnty1     as   decimal             no-undo.
  define input parameter p-qnty2     as   decimal             no-undo.
  define input parameter p-supp-name as   character           no-undo.
  define input parameter p-supp-code like ub.clients.obj-code no-undo.
  define input parameter p-is-fact   as   logical             no-undo.
  define input parameter p-ii        as   integer             no-undo.
  _main:
  DO ON ERROR UNDO _main, RETURN ERROR :
    CREATE tincome-2.
    assign tincome-2.gds-code    = p-gds-code
           tincome-2.doc-code    = p-doc-code
           tincome-2.qnty1       = p-qnty1
           tincome-2.qnty2       = p-qnty2
           tincome-2.supp-code   = p-supp-code
           tincome-2.supp-name   = p-supp-name
           tincome-2.is-fact     = p-is-fact
           tincome-2.temperature = ?
           tincome-2.ii          = p-ii        no-error.
    IF ERROR-STATUS :ERROR THEN DO: UNDO _main, RETURN ERROR. END.
  END.
END PROCEDURE.
