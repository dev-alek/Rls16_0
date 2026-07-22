using Ibs.Th.Gbl.ProgressBar.
block-level on error undo, throw.
define input parameter parparentproc            as   widget-handle         no-undo .
define input parameter p-parent-handle          as handle                  no-undo .
define input parameter p-log-handle             as handle                  no-undo .
define input parameter p-cont-handle            as handle                  no-undo .
define input parameter p-call-handle            as handle                  no-undo .
define input parameter p-rebh                   as handle                  no-undo .
define input parameter p-rdbh                   as handle                  no-undo .
define input parameter p-report-id              as character               no-undo .
define input parameter p-log-file-name          as character               no-undo .
define input parameter p-batch                  as integer                 no-undo .
define input parameter p-codex-id               as integer no-undo .
define input parameter p-ruleset-id             as integer no-undo .
define input parameter p-without-vat as logical no-undo .
define input parameter p-tax-rate-list as character no-undo .
define input parameter p-break-by-cp as logical no-undo .
define input parameter p-no-covered-techrfsl as logical no-undo .
define input parameter p-ext-doc-type-subtotals as logical no-undo .
define input parameter p-plain-txt              as   logical               no-undo .
define input parameter p-xls                    as   logical               no-undo .
define input parameter p-dir-name               as   character             no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Форма ТОРГ-29 по документам".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_p-fmt_string-part no-undo
    field str-key       as integer
    field string-part   as character
    index pi is primary unique
        str-key
.
define variable v-p-fmt-12-str-key    as integer      no-undo.
FUNCTION center-field RETURNS INTEGER (INPUT iStartPix AS INTEGER, iEndPix AS INTEGER,
                                  iInput AS INTEGER).
  def var v-start-print as integer no-undo .
  if (iStartPix < 0) or (iEndPix < iStartPix) then return 0.
  assign
    v-start-print = INTEGER(iStartPix + ((iEndPix - iStartPix) / 2) - (iInput / 2))
  .
  RETURN v-start-print .
END FUNCTION.
FUNCTION right-field RETURNS INTEGER ( iEndPix AS INTEGER,
                                  iInput AS INTEGER).
  def var v-start-print as integer no-undo .
  assign
    v-start-print = INTEGER(iEndPix - 1 - iInput)
  .
  if v-start-print < 0 then return 0.
  RETURN v-start-print .
END FUNCTION.
function p-fmt-align-string returns character (
      p-in-string      as character
    , p-page-width     as integer
    , p-align-type     as character
).
    define variable v-string-length     as integer      no-undo.
    define variable v-out-string        as character    no-undo.
    assign
        v-string-length = length( trim( p-in-string ) )
    .
    if v-string-length >= p-page-width
    then do:
        assign
            v-out-string = trim( p-in-string )
        .
    end.
    else do:
        case p-align-type
        :
            when 'left':U
            then do:
                assign
                    v-out-string = trim( p-in-string )
                .
            end.
            when 'right':U
            then do:
                assign
                    v-out-string = fill( " ":U, p-page-width - v-string-length ) + trim( p-in-string )
                .
            end.
            when 'center':U
            then do:
                assign
                    v-out-string = fill( " ":U, integer( ( p-page-width - v-string-length ) / 2 ) ) + trim( p-in-string )
                .
            end.
        end case.
    end.
    return v-out-string .
end function.
procedure p-fmt-split-string :
define input parameter p-source-string  as character        no-undo.
define input parameter p-split-length   as integer          no-undo.
define output parameter p-string-1      as character        no-undo.
define output parameter p-string-2      as character        no-undo.
do
on error undo, return error
:
    define variable v-space-pos    as integer      no-undo.
    if length( p-source-string ) <= p-split-length
    then do:
        assign
            p-string-1 = p-source-string
        .
    end.
    else do:
        assign
            v-space-pos = r-index( p-source-string, " ":U, p-split-length )
        .
        if v-space-pos = 0
        then do:
            assign
                v-space-pos = index( p-source-string, " ":U )
            .
        end.
        if v-space-pos = 0
        then do:
            assign
                p-string-1 = substring( p-source-string, 1, p-split-length )
                p-string-2 = trim( substring( p-source-string, p-split-length, p-split-length ) )
            .
        end.
        else do:
            assign
                p-string-1 = substring( p-source-string, 1, v-space-pos )
                p-string-2 = trim( substring( p-source-string, v-space-pos ) )
            .
        end.
    end.
end.
end procedure.
procedure p-fmt-round :
define input parameter p-qnty               as decimal          no-undo.
define input parameter p-price-no-VAT       as decimal          no-undo.
define input parameter p-VAT                as decimal          no-undo.
define input parameter p-SLT                as decimal          no-undo.
define input parameter p-road-tax           as decimal          no-undo.
define output parameter p-new-price-no-VAT  as decimal          no-undo.
define output parameter p-new-VAT           as decimal          no-undo.
define output parameter p-new-SLT           as decimal          no-undo.
define output parameter p-new-sum-VAT       as decimal          no-undo.
define output parameter p-new-sum-SLT       as decimal          no-undo.
define output parameter p-new-sum-road-tax  as decimal          no-undo.
define output parameter p-new-sum-no-VAT    as decimal          no-undo.
define output parameter p-new-sum-full      as decimal          no-undo.
    define variable v-vat-pc    as decimal      no-undo.
    define variable v-slt-pc    as decimal      no-undo.
do
on error undo, return error
:
    if p-price-no-VAT = 0
    then do:
        assign
            p-new-price-no-VAT = 0.0
            p-new-VAT          = ?
            p-new-SLT          = ?
            p-new-sum-VAT      = 0.0
            p-new-sum-SLT      = 0.0
            p-new-sum-no-VAT   = 0.0
            p-new-sum-road-tax = 0.0
            p-new-sum-full     = 0.0
        .
    end.
    else do:
        assign
            v-vat-pc            = p-VAT / p-price-no-VAT
            v-slt-pc            = p-SLT / ( p-price-no-VAT + p-VAT )
            p-new-price-no-VAT  = round( p-price-no-VAT, 2 )
            p-new-VAT           = round( p-new-price-no-VAT * v-vat-pc, 2 )
            p-new-SLT           = round( ( p-new-price-no-VAT + p-new-VAT ) * v-slt-pc, 2 )
            p-new-sum-VAT       = round( p-new-VAT          * p-qnty, 2 )
            p-new-sum-SLT       = round( ( p-new-price-no-VAT + p-new-VAT ) * p-qnty * v-slt-pc, 2 )
            p-new-sum-no-VAT    = round( p-new-price-no-VAT * p-qnty, 2 )
            p-new-sum-road-tax  = round( p-road-tax * p-qnty, 2 )
            p-new-sum-full      = round( ( p-new-price-no-VAT + p-new-VAT + p-new-SLT + p-road-tax ) * p-qnty, 2 )
        .
    end.
end.
end procedure.
procedure p-fmt-split :
define input parameter p-in-string      as character        no-undo.
define input parameter p-split-length   as integer          no-undo.
    define variable v-start-pos     as integer      no-undo.
    define variable v-end-pos       as integer      no-undo.
    define buffer buf_temp_p-fmt_string-part        for temp_p-fmt_string-part.
do
for buf_temp_p-fmt_string-part
on error undo, return error
:
    empty temp-table buf_temp_p-fmt_string-part.
    if p-split-length < 1
    then do:
        undo, return error substitute( "p-fmt-split: Строка не может быть разбита на &1 частей", p-split-length ).
    end.
    assign
        p-in-string                 = trim( p-in-string )
        v-p-fmt-12-str-key   = 0
        v-start-pos                 = 1
        v-end-pos                   = length( p-in-string )
    .
    run p-fmt-get-string-range in this-procedure (
          input p-in-string
        , input p-split-length
        , input v-start-pos
        , output v-start-pos
        , output v-end-pos
    ).
    do while v-end-pos <> 0
    :
        create buf_temp_p-fmt_string-part.
        assign
            v-p-fmt-12-str-key = v-p-fmt-12-str-key + 1
        .
        assign
            buf_temp_p-fmt_string-part.str-key      = v-p-fmt-12-str-key
            buf_temp_p-fmt_string-part.string-part  = substring( p-in-string, v-start-pos, v-end-pos - v-start-pos )
        .
        assign
            v-start-pos = v-end-pos + 1
        .
        run p-fmt-get-string-range in this-procedure (
              input p-in-string
            , input p-split-length
            , input v-start-pos
            , output v-start-pos
            , output v-end-pos
        ).
    end.
end.
end procedure.
procedure p-fmt-get-string-range :
define input parameter p-in-string      as character        no-undo.
define input parameter p-split-length   as integer          no-undo.
define input parameter p-old-start-pos  as integer          no-undo.
define output parameter p-start-pos     as integer          no-undo.
define output parameter p-end-pos       as integer          no-undo.
    define variable v-init-string    as character    no-undo.
    define variable v-temp-char      as character    no-undo.
    define variable v-temp-pos       as integer      no-undo.
    define variable v-counter        as integer      no-undo.
do
on error undo, return error
:
    assign
        p-start-pos   = p-old-start-pos
        v-init-string = substring( p-in-string, p-start-pos )
    no-error.
    if error-status :error
    or trim( v-init-string ) = "":U
    then do:
        assign
            p-end-pos = 0
        .
        undo, return .
    end.
    assign
        v-temp-char   = substring( v-init-string, 1, 1 )
    .
    do
    while trim( v-temp-char ) = "":U
    :
        assign
            p-start-pos     = p-start-pos + 1
            v-init-string   = substring( p-in-string, p-start-pos )
            v-temp-char     = substring( v-init-string, 1, 1 )
        .
    end.
    assign
        v-temp-pos  = p-split-length
        v-temp-char = substring( v-init-string, v-temp-pos, 1 )
        v-counter   = 0
    .
    search-word-end:
    do
    while trim( v-temp-char ) <> "":U
    :
        assign
            v-counter   = v-counter + 1
        .
        if v-counter > 20
        then do:
            assign
                v-temp-pos  = p-split-length
            .
            leave search-word-end.
        end.
        assign
            v-temp-pos  = v-temp-pos - 1
            v-temp-char = substring( v-init-string, v-temp-pos, 1 )
        .
    end.
    assign
        p-end-pos = p-start-pos + v-temp-pos - 1
    .
end.
end procedure.
define temp-table temp-font no-undo
  field fontnum  as integer
  field fontname as character
  field fontsize as character
  field fonttype as character
  field font-h   as integer
  field font-w   as integer
  field v-row    as integer
  field v-col    as integer
  field v-row-lans as integer
  field v-col-lans as integer
index pi fontnum
.
procedure get-font-ini :
  do
  on error undo, return error return-value
  :
define variable ii as integer   no-undo .
define variable v-font7 as character no-undo .
define variable v-font as character no-undo .
define variable loc-name as character no-undo .
define variable loc-size as character no-undo .
define variable loc-type as character no-undo .
define variable old_H as integer   no-undo .
define variable old_w as integer   no-undo .
define variable old-row  as integer   no-undo .
define variable old-col  as integer   no-undo .
define variable old-row-lans  as integer   no-undo .
define variable old-col-lans  as integer   no-undo .
define variable vv as integer   no-undo .
empty temp-table temp-font.
  GET-KEY-VALUE SECTION "fonts" KEY "font7" VALUE v-font7 .
    case num-entries (v-font7) :
      when 4 then do:
          assign
            loc-name = entry ( 1 , v-font7 )
            loc-size = entry ( 2 , v-font7 )
            loc-type = entry ( 3 , v-font7 ) + "," +  entry ( 4 , v-font7 )
          .
      end.
      when 3 then do:
          assign
            loc-name = entry ( 1 , v-font7 )
            loc-size = entry ( 2 , v-font7 )
            loc-type = entry ( 3 , v-font7 )
          .
      end.
      when 2 then  do:
          assign
            loc-name = entry ( 1 , v-font7 )
            loc-size = entry ( 2 , v-font7 )
            loc-type = ""
          .
      end.
      when 1 then do:
          assign
            loc-name = trim(entry ( 1 , v-font7 ))
            loc-size = ""
            loc-type = ""
          .
      end.
    end case.
  create temp-font.
  assign
    temp-font.fontnum  = 7
    temp-font.fontname = trim(loc-name)
    temp-font.fontsize = trim(loc-size)
    temp-font.fonttype = trim(loc-type)
    temp-font.v-row    = 62
    temp-font.v-col    = 136
    temp-font.v-row-lans = 43
    temp-font.v-col-lans = 198
  .
  repeat ii = 16 to 100 :
    get-key-value section 'fonts' key 'font' + string(ii)   value v-font  .
    if v-font = "" or v-font = ? then leave.
    case num-entries (v-font) :
      when 4 then do:
          assign
            loc-name = entry ( 1 , v-font )
            loc-size = entry ( 2 , v-font )
            loc-type = entry ( 3 , v-font ) + "," +  entry ( 4 , v-font )
          .
      end.
      when 3 then do:
          assign
            loc-name = entry ( 1 , v-font )
            loc-size = entry ( 2 , v-font )
            loc-type = entry ( 3 , v-font )
          .
      end.
      when 2 then do:
          assign
            loc-name = entry ( 1 , v-font )
            loc-size = entry ( 2 , v-font )
            loc-type = ""
          .
      end.
      when 1 then do:
          assign
            loc-name = trim(entry ( 1 , v-font ))
            loc-size = ""
            loc-type = ""
          .
      end.
    end case.
  create temp-font.
  assign
    temp-font.fontnum  = ii
    temp-font.fontname = trim(loc-name)
    temp-font.fontsize = trim(loc-size)
    temp-font.fonttype = trim(loc-type)
  .
  end.
    for each temp-font :
       vv = integer(entry(2,temp-font.fontsize, "=" )) no-error .
       if  vv = ? then vv =  0 .
        run rep/exfont.p (
          input   temp-font.fontname ,
          input   vv ,
          input   temp-font.fonttype ,
          output  temp-font.font-h   ,
          output  temp-font.font-w   )
        .
    end.
find first temp-font where  temp-font.fontnum  = 7  .
old_H = temp-font.font-H .
old_w = temp-font.font-W .
old-row = temp-font.v-row .
old-col = temp-font.v-col .
old-row-lans = temp-font.v-row-lans .
old-col-lans = temp-font.v-col-lans .
    for each temp-font where
             temp-font.fontnum  <> 7 :
        assign
            temp-font.v-row    = old_H * old-row / temp-font.font-h
            temp-font.v-col    = old_W * old-col / temp-font.font-W
            temp-font.v-row-lans    = old_H * old-row-lans / temp-font.font-h
            temp-font.v-col-lans    = old_W * old-col-lans / temp-font.font-W
        .
    end.
  end.
end procedure.
PROCEDURE How-name :
define input  parameter h as integer no-undo .
define input  parameter w as integer no-undo .
define output parameter n as character  no-undo .
define variable A4port-H as integer   no-undo init 63.
define variable A4port-W as integer   no-undo init 136.
define variable A4lans-H as integer   no-undo init 43.
define variable A4lans-W as integer   no-undo init 198.
define variable Strim-W  as integer   no-undo init 278.
run define-a4-size (
     input ReportFontNum
    ,output A4port-H
    ,output A4port-W
    ,output A4lans-H
    ,output A4lans-W ).
If w >= 1 and w <= A4port-W Then DO:
  If h >= 1  and h <= A4lans-H Then n = "A4-lans":U.
  If h > A4lans-H  and h <= A4port-H Then n = "A4-port":U.
  If h > A4port-H              Then n = "to-file":U.
End.
If w > A4port-W and w <= A4lans-W Then DO:
  If h >= 1  and h <= A4lans-H Then n = "A4-lans":U.
  If h > A4lans-H  and h <= A4port-H Then n = "A3-lans":U.
  If h > A4port-H              Then n = "to-file":U.
End.
If w > A4lans-W and w <= Strim-W Then DO:
  If h >= 1  and h <= A4lans-H Then n = "to-file":U.
  If h > A4lans-H  and h <= A4port-H Then n = "A3-lans":U.
  If h > A4port-H              Then n = "to-file":U.
End.
If w > Strim-W Then DO:
   n = "to-file":U.
End.
END PROCEDURE.
PROCEDURE define-a4-size :
define input  parameter p-ReportFontNum as integer   no-undo .
define output parameter A4port-H as integer   no-undo .
define output parameter A4port-W as integer   no-undo .
define output parameter A4lans-H as integer   no-undo .
define output parameter A4lans-W as integer   no-undo .
if not can-find (first temp-font ) then do:
   run get-font-ini .
end.
find first temp-font where temp-font.fontnum = p-ReportFontNum no-error .
if available temp-font then do:
assign
  A4port-H = temp-font.v-row
  A4port-W = temp-font.v-col
  A4lans-H = temp-font.v-row-lans
  A4lans-W = temp-font.v-col-lans
.
end.
else do:
assign
  A4port-H = 63
  A4port-W = 136
  A4lans-H = 43
  A4lans-W = 198
.
end.
END PROCEDURE.
PROCEDURE ostatok :
def input parameter x-store-code  like ub.clients.obj-code    no-undo.
def input parameter x-store-type  like ub.clients.obj-type    no-undo.
def input parameter x-tog-shift   as   logical             no-undo.
def input parameter x-date-start  like ub.stk-tot.Fact-date   no-undo.
def input parameter x-date-end    like ub.stk-tot.Fact-date   no-undo.
def input parameter x-shift-start as integer               no-undo.
def input parameter x-shift-end   as integer               no-undo.
def input parameter x-sum-type    like ub.stk-tot.sum-type    no-undo.
def input parameter x-cat-id      like ub.stk-tot.cat-id      no-undo.
def input parameter xTog-obj   as log no-undo.
def output parameter Quantity    like ub.stk-tot.fact-qnty   no-undo.
def output parameter Coast_R     like ub.stk-tot.sum-rubl    no-undo.
def output parameter Coast_V     like ub.stk-tot.sum-rubl    no-undo.
def output parameter VAT_R       like ub.stk-tot.sum-rubl    no-undo.
def output parameter VAT_V       like ub.stk-tot.sum-rubl    no-undo.
def output parameter Fact-order  like ub.stk-tot.Fact-order  no-undo.
def var              Fact-order#   like ub.stk-tot.Fact-order  no-undo.
def var              Fact-orderS   as char  no-undo.
def var x-date-start-t  like ub.stk-tot.shift-date   no-undo.
   Assign
      Fact-order   = 0
      Quantity     = 0
      Coast_R      = 0
      Coast_V      = 0
      VAT_R        = 0
      VAT_V        = 0 .
 x-date-start-t  = x-date-start + 1 .
IF x-date-end = date('') then DO:
   Fact-order = 0 .
   for each obj-list
       where  ( not xtog-obj or
              ( x-store-type = obj-list.obj-type and x-store-code = obj-list.obj-code ))
              no-lock :
      if  x-tog-shift = false then do:
                       find last ub.stk-tot where ub.stk-tot.obj-type = obj-list.obj-type and                             ub.stk-tot.obj-code = obj-list.obj-code and                             ub.stk-tot.sum-type = x-sum-type and                             ub.stk-tot.cat-id   = x-cat-id   and
                            ub.stk-tot.Fact-date <=  x-date-start
                            and ub.stk-tot.shift-num = 0
                            USE-INDEX fact-date no-lock no-error .
           if Available ub.stk-tot THEN  Assign                           Quantity     = Quantity   + ub.stk-tot.fact-qnty                           Coast_R      = Coast_R    + ub.stk-tot.sum-rubl                           Coast_V      = Coast_V    + ub.stk-tot.sum-base                           VAT_R        = VAT_R      + ub.stk-tot.VAT-rubl                           VAT_V        = VAT_V      + ub.stk-tot.VAT-base                           Fact-order#  = ub.stk-tot.Fact-order.
      End.
      Else  DO :
          find last ub.stk-tot where ub.stk-tot.obj-type = obj-list.obj-type and                             ub.stk-tot.obj-code = obj-list.obj-code and                             ub.stk-tot.sum-type = x-sum-type and                             ub.stk-tot.cat-id   = x-cat-id   and
           (ub.stk-tot.shift-date  = x-date-start-t and
            ub.stk-tot.shift-num  < x-shift-start or
            ub.stk-tot.shift-date  < x-date-start-t  )
            and ub.stk-tot.shift-num  > 0
            USE-INDEX Shift-num no-lock no-error .
         If Available ub.stk-tot then  Assign                           Quantity     = Quantity   + ub.stk-tot.fact-qnty                           Coast_R      = Coast_R    + ub.stk-tot.sum-rubl                           Coast_V      = Coast_V    + ub.stk-tot.sum-base                           VAT_R        = VAT_R      + ub.stk-tot.VAT-rubl                           VAT_V        = VAT_V      + ub.stk-tot.VAT-base                           Fact-order#  = ub.stk-tot.Fact-order.
        END.
    If Fact-order < Fact-order#  and Fact-order# <> 0  THEN  Fact-order = Fact-order# .
  End.
End.
Else DO:
  For each obj-list  WHERE
     (NOT xTog-obj OR (x-store-type = obj-list.obj-type AND x-store-code = obj-list.obj-code))
      no-lock :
   IF  x-TOG-Shift = False Then DO:
       find last ub.stk-tot where ub.stk-tot.obj-type = obj-list.obj-type and                             ub.stk-tot.obj-code = obj-list.obj-code and                             ub.stk-tot.sum-type = x-sum-type and                             ub.stk-tot.cat-id   = x-cat-id   and
            ub.stk-tot.Fact-date <= x-date-end
            and ub.stk-tot.shift-num = 0
            USE-INDEX fact-date no-lock no-error.
       if available ub.stk-tot then  Assign                           Quantity     = Quantity   + ub.stk-tot.fact-qnty                           Coast_R      = Coast_R    + ub.stk-tot.sum-rubl                           Coast_V      = Coast_V    + ub.stk-tot.sum-base                           VAT_R        = VAT_R      + ub.stk-tot.VAT-rubl                           VAT_V        = VAT_V      + ub.stk-tot.VAT-base                           Fact-order#  = ub.stk-tot.Fact-order.
   END.
   Else DO:
        find last ub.stk-tot where ub.stk-tot.obj-type = obj-list.obj-type and                             ub.stk-tot.obj-code = obj-list.obj-code and                             ub.stk-tot.sum-type = x-sum-type and                             ub.stk-tot.cat-id   = x-cat-id   and
            (ub.stk-tot.shift-date  = x-date-end and
            ub.stk-tot.shift-num  <= x-shift-end or
            ub.stk-tot.shift-date  < x-date-end       ) and
            ub.stk-tot.shift-num   > 0      use-index shift-num no-lock no-error.
            if Available ub.stk-tot THEN Assign                           Quantity     = Quantity   + ub.stk-tot.fact-qnty                           Coast_R      = Coast_R    + ub.stk-tot.sum-rubl                           Coast_V      = Coast_V    + ub.stk-tot.sum-base                           VAT_R        = VAT_R      + ub.stk-tot.VAT-rubl                           VAT_V        = VAT_V      + ub.stk-tot.VAT-base                           Fact-order#  = ub.stk-tot.Fact-order.
    End.
    if Fact-order < Fact-order#  THEN  Fact-order = Fact-order#.
  End.
End.
END PROCEDURE.
procedure ost-line :
  define input  parameter x-store-code like ub.clients.obj-code    no-undo .
  define input  parameter x-store-type like ub.clients.obj-type    no-undo .
  define input  parameter x-artic      like ub.stk-line.artic      no-undo .
  define input  parameter x-prod-code  like ub.stk-line.prod-code  no-undo .
  define input  parameter x-prod-type  like ub.stk-line.prod-type  no-undo .
  define input  parameter x-tog-shift  as logical no-undo .
  define input  parameter x-fact-order like ub.stk-line.fact-order no-undo .
  define input  parameter x-sum-type   like ub.stk-line.sum-type   no-undo .
  define input  parameter x-cat-id     like ub.stk-line.cat-id     no-undo .
  define input  parameter xtog-obj     as logical no-undo .
  define output parameter quantity     like ub.stk-line.fact-qnty  no-undo .
  define output parameter coast_r      like ub.stk-line.sum-rubl   no-undo .
  define output parameter coast_v      like ub.stk-line.sum-rubl   no-undo .
  define output parameter vat_r        like ub.stk-line.sum-rubl   no-undo .
  define output parameter vat_v        like ub.stk-line.sum-rubl   no-undo .
  define output parameter slt_r        like ub.stk-line.sum-rubl   no-undo .
  define output parameter slt_v        like ub.stk-line.sum-rubl   no-undo .
  define buffer buff-obj-list  for obj-list .
  define buffer buff-stk-line  for ub.stk-line .
  assign
    Quantity = 0
    Coast_R  = 0
    Coast_V  = 0
    VAT_R    = 0
    VAT_V    = 0
    SLT_R    = 0
    SLT_V    = 0
  .
  if  x-tog-shift = false then do:
    for each buff-obj-list no-lock
      where xtog-obj = false
         or (buff-obj-list.obj-type = x-store-type
            and buff-obj-list.obj-code = x-store-code
            )
    on error undo, return error
    :
      find last buff-stk-line no-lock
        where buff-stk-line.obj-type   = buff-obj-list.obj-type
          and buff-stk-line.obj-code   = buff-obj-list.obj-code
          and buff-stk-line.artic      = x-artic
          and buff-stk-line.prod-type  = x-prod-type
          and buff-stk-line.prod-code  = x-prod-code
          and buff-stk-line.sum-type   = x-sum-type
          and buff-stk-line.cat-id     = '##,##':U
          and buff-stk-line.fact-order <= x-fact-order
          and buff-stk-line.shift-num  = 0
        use-index category
        no-error .
      if available buff-stk-line then do:
        assign
          Quantity = Quantity +  buff-stk-line.fact-qnty
          Coast_R  = Coast_R  +  buff-stk-line.sum-rubl
          Coast_V  = Coast_V  +  buff-stk-line.sum-base
          VAT_R    = VAT_R    +  buff-stk-line.VAT-rubl
          VAT_V    = VAT_V    +  buff-stk-line.VAT-base
          SLT_R    = SLT_R    +  buff-stk-line.SLT-rubl
          SLT_V    = SLT_V    +  buff-stk-line.SLT-base
        .
      end.
    end.
  end.
  else do:
    for each buff-obj-list no-lock
      where xtog-obj = false
         or (buff-obj-list.obj-type = x-store-type
            and buff-obj-list.obj-code = x-store-code
            )
    on error undo, return error
    :
      find last buff-stk-line no-lock
        where buff-stk-line.obj-type   = buff-obj-list.obj-type
          and buff-stk-line.obj-code   = buff-obj-list.obj-code
          and buff-stk-line.artic      = x-artic
          and buff-stk-line.prod-type  = x-prod-type
          and buff-stk-line.prod-code  = x-prod-code
          and buff-stk-line.sum-type   = x-sum-type
          and buff-stk-line.cat-id     = '##,##':U
          and buff-stk-line.fact-order <= x-fact-order
          and buff-stk-line.shift-num  > 0
        use-index category
        no-error .
      if available buff-stk-line then do:
        assign
          Quantity = Quantity +  buff-stk-line.fact-qnty
          Coast_R  = Coast_R  +  buff-stk-line.sum-rubl
          Coast_V  = Coast_V  +  buff-stk-line.sum-base
          VAT_R    = VAT_R    +  buff-stk-line.VAT-rubl
          VAT_V    = VAT_V    +  buff-stk-line.VAT-base
          SLT_R    = SLT_R    +  buff-stk-line.SLT-rubl
          SLT_V    = SLT_V    +  buff-stk-line.SLT-base
        .
      end.
    end.
  end.
end procedure.
procedure ost-lineother-tax :
  define input  parameter x-store-code like ub.clients.obj-code      no-undo.
  define input  parameter x-store-type like ub.clients.obj-type      no-undo.
  define input  parameter x-artic      like ub.stk-line.artic        no-undo.
  define input  parameter x-prod-code  like ub.stk-line.prod-code    no-undo.
  define input  parameter x-prod-type  like ub.stk-line.prod-type    no-undo.
  define input  parameter x-tog-shift  as logical no-undo .
  define input  parameter x-fact-order like ub.stk-line.fact-order   no-undo.
  define input  parameter x-sum-type   like ub.stk-line.sum-type     no-undo.
  define input  parameter x-type-id    like ub.stk-line.cat-id       no-undo.
  define input  parameter xTog-obj     as logical no-undo .
  define output parameter Quantity     like ub.stk-line.fact-qnty   no-undo.
  define output parameter Coast_R      like ub.stk-line.sum-rubl    no-undo.
  define output parameter Coast_V      like ub.stk-line.sum-rubl    no-undo.
  define output parameter VAT_R        like ub.stk-line.sum-rubl    no-undo.
  define output parameter VAT_V        like ub.stk-line.sum-rubl    no-undo.
  define output parameter SLT_R        like ub.stk-line.sum-rubl    no-undo.
  define output parameter SLT_V        like ub.stk-line.sum-rubl    no-undo.
  define output parameter other_R      like ub.stk-line.sum-rubl    no-undo.
  define output parameter other_V      like ub.stk-line.sum-rubl    no-undo.
  define buffer buff-obj-list  for obj-list .
  define buffer buff-stk-line  for ub.stk-line .
  assign
    Quantity = 0
    Coast_R  = 0
    Coast_V  = 0
    VAT_R    = 0
    VAT_V    = 0
    SLT_R    = 0
    SLT_V    = 0
    other_R  = 0
    other_V  = 0
  .
  if  x-tog-shift = false then do:
    for each buff-obj-list no-lock
      where xtog-obj = false
         or (buff-obj-list.obj-type = x-store-type
            and buff-obj-list.obj-code = x-store-code
            )
    on error undo, return error
    :
      find last buff-stk-line no-lock
        where buff-stk-line.obj-type   = buff-obj-list.obj-type
          and buff-stk-line.obj-code   = buff-obj-list.obj-code
          and buff-stk-line.artic      = x-artic
          and buff-stk-line.prod-type  = x-prod-type
          and buff-stk-line.prod-code  = x-prod-code
          and buff-stk-line.sum-type   = x-sum-type
          and buff-stk-line.cat-id     = '##,##':U
          and buff-stk-line.fact-order <= x-fact-order
          and buff-stk-line.shift-num  = 0
        use-index category
        no-error .
      if available buff-stk-line then do:
        assign
          Quantity = Quantity +  buff-stk-line.fact-qnty
          Coast_R  = Coast_R  +  buff-stk-line.sum-rubl
          Coast_V  = Coast_V  +  buff-stk-line.sum-base
          VAT_R    = VAT_R    +  buff-stk-line.VAT-rubl
          VAT_V    = VAT_V    +  buff-stk-line.VAT-base
          SLT_R    = SLT_R    +  buff-stk-line.SLT-rubl
          SLT_V    = SLT_V    +  buff-stk-line.SLT-base
          other_R  = other_R  +  buff-stk-line.other-rubl
          other_V  = other_V  +  buff-stk-line.other-base
        .
      end.
    end.
  end.
  else do:
    for each buff-obj-list no-lock
      where xtog-obj = false
         or (buff-obj-list.obj-type = x-store-type
            and buff-obj-list.obj-code = x-store-code
            )
    on error undo, return error
    :
      find last buff-stk-line no-lock
        where buff-stk-line.obj-type   = buff-obj-list.obj-type
          and buff-stk-line.obj-code   = buff-obj-list.obj-code
          and buff-stk-line.artic      = x-artic
          and buff-stk-line.prod-type  = x-prod-type
          and buff-stk-line.prod-code  = x-prod-code
          and buff-stk-line.sum-type   = x-sum-type
          and buff-stk-line.cat-id     = '##,##':U
          and buff-stk-line.fact-order <= x-fact-order
          and buff-stk-line.shift-num  > 0
        use-index category
        no-error .
      if available buff-stk-line then do:
        assign
          Quantity = Quantity +  buff-stk-line.fact-qnty
          Coast_R  = Coast_R  +  buff-stk-line.sum-rubl
          Coast_V  = Coast_V  +  buff-stk-line.sum-base
          VAT_R    = VAT_R    +  buff-stk-line.VAT-rubl
          VAT_V    = VAT_V    +  buff-stk-line.VAT-base
          SLT_R    = SLT_R    +  buff-stk-line.SLT-rubl
          SLT_V    = SLT_V    +  buff-stk-line.SLT-base
          other_R = other_R   +  buff-stk-line.other-rubl
          other_V = other_V   +  buff-stk-line.other-base
        .
      end.
    end.
  end.
end procedure.
procedure ost-line-kg :
  define  input parameter p-obj-code    like ub.stk-line.obj-code   no-undo .
  define  input parameter p-obj-type    like ub.stk-line.obj-type   no-undo .
  define  input parameter p-artic       like ub.stk-line.artic      no-undo .
  define  input parameter p-prod-code   like ub.stk-line.prod-code  no-undo .
  define  input parameter p-prod-type   like ub.stk-line.prod-type  no-undo .
  define  input parameter p-fact-order  like ub.stk-line.fact-order no-undo .
  define output parameter p-quantity-kg like ub.stk-line.fact-qnty  no-undo initial 0.00 .
  define buffer buff-obj-list  for obj-list .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_inv-line for ub.inv-line .
  do
  on error undo, return error
  :
    for each buf_doc-line no-lock where
             buf_doc-line.obj-type    = p-obj-type   and
             buf_doc-line.obj-code    = p-obj-code   and
             buf_doc-line.prod-type   = p-prod-type  and
             buf_doc-line.prod-code   = p-prod-code  and
             buf_doc-line.artic       = p-artic      and
             buf_doc-line.status_     = 'факт':U      and
             buf_doc-line.fact-order <= p-fact-order
          by buf_doc-line.fact-order    descending
    :
      find first buf_inv-line no-lock where
                 buf_inv-line.doc-code  = buf_doc-line.doc-code  and
                 buf_inv-line.artic     = buf_doc-line.artic     and
                 buf_inv-line.prod-type = buf_doc-line.prod-type and
                 buf_inv-line.prod-code = buf_doc-line.prod-code no-error .
      if available buf_inv-line
      then do:
        if buf_inv-line.after-cli-qnty <> ?
        then do:
          assign
            p-quantity-kg = buf_inv-line.after-cli-qnty
          .
          leave .
        end.
      end.
    end.
    if p-quantity-kg = ?
    then do:
      assign
        p-quantity-kg = 0
      .
    end.
  end.
end procedure.
define variable vss-include-info13 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure grplib-get-full-name :
   define input parameter p-node-code  as integer      no-undo.
   define output parameter p-full-name as character    no-undo.
   do
on error undo, return error
:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_gds-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end .
procedure grplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_gds-grp       for ub.gds-grp.
do
on error undo, return error
:
  find first buf_gds-grp no-lock
      where buf_gds-grp.upper-code = 0
  no-error .
  if not available buf_gds-grp
  then do:
      undo, return error substitute("Не найдена корневая группа товаров (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_gds-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_gds-grp no-lock where
              buf_gds-grp.node-name = v-entry
          and buf_gds-grp.upper-code = v-upper-code
          no-error.
    if not available buf_gds-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_gds-grp.node-code.
      v-upper-code = buf_gds-grp.node-code.
    end.
  end.
end.
end .
define variable vss-include-info14 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable v-fmtcli-name          as character    no-undo.
define variable v-fmtcli-engl-name     as character    no-undo.
define variable v-fmtcli-addres        as character    no-undo.
define variable v-fmtcli-post-addres   as character    no-undo.
define variable v-fmtcli-full-addres   as character    no-undo.
define variable v-fmtcli-phone         as character    no-undo.
define variable v-fmtcli-inn           as character    no-undo.
define variable v-fmtcli-kpp           as character    no-undo.
define variable v-fmtcli-okpo          as character    no-undo.
define variable v-fmtcli-country       as character    no-undo.
define variable v-fmtcli-city          as character    no-undo.
define variable v-fmtcli-index         as character    no-undo.
define variable v-fmtcli-schet-exists  as logical      no-undo.
define variable v-fmtcli-bank-exists   as logical      no-undo.
define variable v-fmtcli-bank-r-schet  as character    no-undo.
define variable v-fmtcli-bank-c-schet  as character    no-undo.
define variable v-fmtcli-bank-bik      as character    no-undo.
define variable v-fmtcli-bank-name     as character    no-undo.
define variable v-fmtcli-bank-addres   as character    no-undo.
define variable v-fmtcli-bank-city     as character    no-undo.
procedure fmtcli-get-bank :
define input parameter p-host-code      as integer          no-undo.
define input parameter p-obj-type       as character        no-undo.
define input parameter p-obj-code       as integer          no-undo.
define input parameter p-curr-code      as integer          no-undo.
    define buffer buf_fin-schet     for ub.fin-schet.
    define buffer buf_fin-bank      for ub.fin-bank.
do
for buf_fin-schet
  , buf_fin-bank
on error undo, return error
:
    assign
        v-fmtcli-schet-exists       = no
        v-fmtcli-bank-exists        = no
        v-fmtcli-bank-r-schet       = "":U
        v-fmtcli-bank-c-schet       = "":U
        v-fmtcli-bank-bik           = "":U
        v-fmtcli-bank-name          = "":U
        v-fmtcli-bank-addres        = "":U
        v-fmtcli-bank-city          = "":U
    .
    search-for-schet:
    for each buf_fin-schet no-lock
       where buf_fin-schet.host-code = p-host-code
         and buf_fin-schet.cli-type  = p-obj-type
         and buf_fin-schet.cli-code  = p-obj-code
         and buf_fin-schet.curr-code = p-curr-code
    on error undo, return error
    :
        if buf_fin-schet.status_   = 'удал':U
        then do:
        end.
        else do:
            assign
                v-fmtcli-schet-exists   = yes
                v-fmtcli-bank-r-schet   = trim( buf_fin-schet.r-schet )
                v-fmtcli-bank-c-schet   = trim( buf_fin-schet.c-schet )
            .
            find first buf_fin-bank no-lock
                 where buf_fin-bank.host-code = p-host-code
                   and buf_fin-bank.code-bank = buf_fin-schet.code-bank
            no-error.
            if available buf_fin-bank
            then do:
                assign
                    v-fmtcli-bank-exists      = yes
                    v-fmtcli-bank-bik         = trim( buf_fin-bank.bik )
                    v-fmtcli-bank-name        = trim( buf_fin-bank.bank-name )
                    v-fmtcli-bank-addres      = trim(buf_fin-bank.addres)
                    v-fmtcli-bank-city      = trim(buf_fin-bank.bank-city)
                .
            end.
            else do:
                assign
                    v-fmtcli-bank-exists    = no
                    v-fmtcli-bank-bik       = "":U
                    v-fmtcli-bank-name      = "":U
                    v-fmtcli-bank-addres    = "":U
                    v-fmtcli-bank-city      = "":U
                .
            end.
            leave search-for-schet.
        end.
    end.
end.
end procedure.
procedure fmtcli-get-client :
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.
    define variable v-temp-fmtcli-address      as character     no-undo.
    define variable v-num-country-city    as integer      no-undo.
    define buffer buf_clients   for ub.clients.
    define buffer buf_firm      for ub.firm.
    define buffer buf_store     for ub.store.
    define buffer buf_shop      for ub.shop.
    define buffer buf_person    for ub.person.
do
for buf_clients
  , buf_firm
  , buf_store
  , buf_shop
  , buf_person
on error undo, return error
:
    assign
        v-fmtcli-name           = "":U
        v-fmtcli-addres         = "":U
        v-fmtcli-post-addres    = "":U
        v-fmtcli-full-addres    = "":U
        v-fmtcli-phone          = "":U
        v-fmtcli-inn            = "":U
        v-fmtcli-kpp            = "":U
        v-fmtcli-okpo           = "":U
        v-fmtcli-city           = "":U
        v-fmtcli-index          = "":U
        v-fmtcli-country        = "":U
    .
    find first buf_clients no-lock
         where buf_clients.obj-type = p-obj-type
           and buf_clients.obj-code = p-obj-code
    .
    assign
        v-fmtcli-name = buf_clients.obj-name
    .
    case buf_clients.obj-type:
       when 'орг':U
       then do:
            find first buf_firm no-lock
                 where buf_firm.firm-code = buf_clients.obj-code
                 no-error
            .
            if available buf_firm
            then do:
                assign
                    v-num-country-city = num-entries( buf_firm.city )
                    v-fmtcli-engl-name = buf_firm.engl-name
                .
                if v-num-country-city > 0
                then do:
                    assign
                        v-fmtcli-country    = trim( entry( 1, buf_firm.city ) )
                    .
                end.
                if v-num-country-city > 1
                then do:
                    assign
                        v-fmtcli-city       = trim( entry( 2, buf_firm.city ) )
                    .
                end.
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-full-addres
                    , input v-fmtcli-country
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-full-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-full-addres
                    , input v-fmtcli-city
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-full-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-full-addres
                    , input IF buf_firm.ind = 0 THEN "" ELSE string( buf_firm.ind )
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-full-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input v-fmtcli-country
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input v-fmtcli-city
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input string( buf_firm.ind )
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input substring( buf_firm.addres1, 1, 50 )
                    , input buf_firm.addres2
                    , input " ":U
                    , input 50
                    , output v-temp-fmtcli-address
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-temp-fmtcli-address
                    , input substring( buf_firm.addres1, 51, 50 )
                    , input " ":U
                    , input 50
                    , output v-temp-fmtcli-address
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-temp-fmtcli-address
                    , input substring( buf_firm.addres1, 101, 50 )
                    , input " ":U
                    , input 50
                    , output v-temp-fmtcli-address
                ).
                assign
                    v-fmtcli-addres = v-temp-fmtcli-address
                .
                if buf_firm.addres1 <> ?
                then do:
                    run fmtcli-concatenate-strings in this-procedure (
                          input v-fmtcli-full-addres
                        , input v-fmtcli-addres
                        , input ", ":U
                        , input 0
                        , output v-fmtcli-full-addres
                    ).
                end.
                run fmtcli-concatenate-strings in this-procedure (
                      input substring( buf_firm.post-addr1, 1, 50 )
                    , input buf_firm.post-addr2
                    , input " ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input substring( buf_firm.post-addr1, 51, 50 )
                    , input " ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input substring( buf_firm.post-addr1, 101, 50 )
                    , input " ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                assign
                    v-fmtcli-phone         = buf_firm.phone
                    v-fmtcli-inn           = buf_firm.inn
                    v-fmtcli-kpp           = buf_firm.kpp
                    v-fmtcli-okpo          = buf_firm.okpo
                    v-fmtcli-index         = string( buf_firm.ind )
                .
            end.
       end.
       when 'маг':U
       then do:
            find first buf_shop no-lock
                 where buf_shop.obj-code = buf_clients.obj-code
            .
            if available buf_shop
            then do:
                run fmtcli-concatenate-strings in this-procedure (
                      input buf_shop.addres1
                    , input buf_shop.addres2
                    , input " ":U
                    , input 50
                    , output v-fmtcli-addres
                ).
                assign
                    v-fmtcli-full-addres = v-fmtcli-addres
                    v-fmtcli-post-addres = v-fmtcli-addres
                    v-fmtcli-phone       = buf_shop.phone
                    v-fmtcli-inn         = "":U
                    v-fmtcli-kpp         = "":U
                    v-fmtcli-okpo        = "":U
                    v-fmtcli-city        = "":U
                    v-fmtcli-index       = "":U
                .
            end.
       end.
       when 'скл':U
       then do:
            find first buf_store no-lock
                 where buf_store.obj-code = buf_clients.obj-code
            .
            if available buf_store
            then do:
                run fmtcli-concatenate-strings in this-procedure (
                      input buf_store.addres1
                    , input buf_store.addres2
                    , input " ":U
                    , input 50
                    , output v-fmtcli-addres
                ).
                assign
                    v-fmtcli-full-addres = v-fmtcli-addres
                    v-fmtcli-phone       = buf_store.phone
                    v-fmtcli-inn         = "":U
                    v-fmtcli-kpp         = "":U
                    v-fmtcli-okpo        = "":U
                    v-fmtcli-city        = "":U
                    v-fmtcli-index       = "":U
                .
            end.
       end.
       when 'чел':U
       then do:
            find first buf_person no-lock
                 where buf_person.psn-code = buf_clients.obj-code
            .
            if available buf_person
            then do:
                run fmtcli-concatenate-strings in this-procedure (
                      input ( if buf_person.ind = 0 or buf_person.ind = ?
                              then "":U
                              else string( buf_person.ind, "999999")
                              )
                    , input buf_person.city
                    , input ", ":U
                    , input 0
                    , output v-fmtcli-full-addres
                ).
                assign
                    v-fmtcli-addres = buf_person.address
                .
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-full-addres
                    , input v-fmtcli-addres
                    , input ", ":U
                    , input 0
                    , output v-fmtcli-full-addres
                ).
                assign
                    v-fmtcli-phone     = buf_person.phone1
                    v-fmtcli-inn       = buf_person.inn
                    v-fmtcli-kpp       = buf_person.kpp
                    v-fmtcli-okpo      = buf_person.okpo
                    v-fmtcli-city      = buf_person.city
                    v-fmtcli-index     = string( buf_person.ind )
                .
            end.
       end.
    end case.
end.
end procedure.
procedure fmtcli-concatenate-strings :
define input parameter p-string-1       as character        no-undo.
define input parameter p-string-2       as character        no-undo.
define input parameter p-delimiter      as character        no-undo.
define input parameter p-length         as integer          no-undo.
define output parameter p-out-string    as character        no-undo.
do
on error undo, return error
:
    assign
        p-out-string = ( if p-string-1 = ?
                         then "":U
                         else trim( p-string-1 ) )
    .
    assign
        p-out-string = p-out-string
                     + ( if p-out-string = "":U
                         or length( p-out-string ) = p-length
                         or p-string-2 = ?
                         or trim( p-string-2 ) = "":U
                         then "":U
                         else p-delimiter )
                     + ( if p-string-2 = ?
                         or trim( p-string-2 ) = "":U
                         then "":U
                         else trim( p-string-2 ) )
    .
end.
end procedure.
def var vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-param no-undo   field param-code     as character   field param-sub-code as character   field param-value    as character   index xpk is primary unique param-code param-sub-code   .
procedure paramls-clear :
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    for each buf_temp-param
    on error undo, return error
    :
      delete buf_temp-param .
    end.
  end.
end procedure.
procedure paramls-write :
  define input  parameter p-code     as character no-undo .
  define input  parameter p-sub-code as character no-undo .
  define input  parameter p-value    as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
      where buf_temp-param.param-code     = p-code
        and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if not available buf_temp-param then do:
      create buf_temp-param .
      assign
        buf_temp-param.param-code     = p-code
        buf_temp-param.param-sub-code = p-sub-code
      .
    end.
    assign
      buf_temp-param.param-value = p-value
    .
  end.
end procedure.
procedure paramls-read :
  define input  parameter p-code          as character no-undo .
  define input  parameter p-sub-code      as character no-undo .
  define input  parameter p-default-value as character no-undo .
  define output parameter p-value         as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
      where buf_temp-param.param-code     = p-code
        and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if available buf_temp-param then do:
      assign
        p-value = buf_temp-param.param-value
      .
    end.
    else do:
      assign
        p-value = p-default-value
      .
    end.
  end.
end procedure.
procedure paramls-append :
  define input  parameter p-code     as character no-undo .
  define input  parameter p-sub-code as character no-undo .
  define input  parameter p-value    as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
         where buf_temp-param.param-code     = p-code
           and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if not available buf_temp-param then do:
      create buf_temp-param .
      assign
        buf_temp-param.param-code     = p-code
        buf_temp-param.param-sub-code = p-sub-code
        buf_temp-param.param-value    = p-value
      .
    end.
    else do:
        assign
            buf_temp-param.param-value = buf_temp-param.param-value + ",":U + p-value
        .
    end.
  end.
end procedure.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION ShiftRight RETURNS CHARACTER ( INPUT i-string AS CHARACTER, INPUT i-length AS INTEGER ) :
  DEFINE VARIABLE v-outstring AS CHARACTER NO-UNDO.
  RUN get-right-string IN THIS-PROCEDURE ( INPUT i-string, INPUT i-length, OUTPUT v-outstring ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN i-string ELSE v-outstring ).
END FUNCTION.
PROCEDURE get-right-string :
  DEFINE  INPUT PARAMETER p-instring  AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-length    AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-outstring AS CHARACTER NO-UNDO INITIAL "":U.
  DEFINE VARIABLE j-format AS INTEGER NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-instring = TRIM(   p-instring )
           j-format   = LENGTH( p-instring ).
    IF           j-format > p-length THEN DO:
      ASSIGN p-outstring = SUBSTRING( p-instring, 1, p-length ).
    END. ELSE IF j-format < p-length THEN DO:
      ASSIGN p-outstring = FILL( " ":U, p-length - j-format ) + p-instring.
    END.                             ELSE DO:
      ASSIGN p-outstring = p-instring.
    END.
  END.
END PROCEDURE.
def var vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function func-get-name-from-ext-type   returns char
  ( p-ext-type as character   ,
    p-caps     as logical ).
define variable v-ext-name as character no-undo .
run get-name-from-ext-type in this-procedure (
    input p-ext-type  ,
    input p-caps  ,
    output v-ext-name )
    no-error .
    if error-status :error then do:
       assign
         v-ext-name = p-ext-type
       .
    end.
 return (v-ext-name) .
end.
procedure get-name-from-ext-type :
 do
 on error undo, return error return-value
 :
define input  parameter p-ext-type as character no-undo .
define input  parameter p-caps     as logical no-undo   .
define output parameter p-ext-name as character no-undo .
define variable v-num as integer no-undo .
  if lookup ( p-ext-type , 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U ) = 0 then do :
    message
      vss-include-info17 skip
      "Неправильно задано значение входящего параметра! "
      "Нет такого типа документов " p-ext-type
      view-as alert-box error .
      undo, return error .
  end.
  v-num      = lookup ( p-ext-type , 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U ) .
  p-ext-name = entry  ( v-num , 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U ) .
  if p-caps  = true then do :
     p-ext-name = caps(substring(p-ext-name,1,1) ) + substring(p-ext-name, 2 , length (p-ext-name) - 1 ) .
  end .
  end.
end procedure.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure ggoattr-code :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-code in g#attr-lib
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
procedure ggoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-tooltip in g#attr-lib
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
procedure ggoattr-value :
  define input  parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-value     like ub.gds-grp-obj-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-value in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-write :
  define input parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define input parameter p-value     like ub.gds-grp-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-write in g#attr-lib
      (input p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-exist :
  define input  parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-exist in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
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
procedure ggoattr-delete :
  define input  parameter p-node-code   like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code     like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-delete in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
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
procedure ggoattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure grp-obj-notcorr-value :
do
on error undo, return error
:
define input parameter p-node-code             as integer      no-undo.
define input parameter p-obj-type              as character    no-undo.
define input parameter p-obj-code              as integer      no-undo.
define output parameter p-notcorr              as character    no-undo init ?.
define output parameter p-range-notcorr     as integer      no-undo.
define output parameter p-exists-notcorr    as logical      no-undo.
define variable v-host-code as integer      no-undo.
DEFINE VARIABLE v-found as logical no-undo .
DEFINE VARIABLE v-exists as logical no-undo .
DEFINE VARIABLE v-range as integer no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE v-notcorr-found as logical no-undo .
DEFINE VARIABLE v-notcorr-value as char      no-undo.
define buffer buf_gds-grp for ub.gds-grp.
define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
find first buf_gds-grp no-lock where
           buf_gds-grp.node-code = p-node-code no-error .
if not avail buf_gds-grp and p-node-code <> 0 then do:
  message
    vss-workfile vss-revision vss-description
    skip "Не удалось найти группу товаров с кодом" p-node-code
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  ) no-error .
if error-status :error
then do:
    message
      vss-workfile vss-revision vss-description
      skip "Не удалось найти фирму объекта"
      skip p-obj-type p-obj-code
      skip return-value
      skip trim(error-status :get-message(1))
    view-as alert-box error.
    undo, return error .
end.
define buffer buf_gds-grp-obj      for ub.gds-grp-obj.
do while v-found = no and jj < 2:
  if v-range <> 3 then do:
    find first buf_gds-grp-obj no-lock
        where buf_gds-grp-obj.node-code = p-node-code
          and buf_gds-grp-obj.host-code = v-host-code
          and buf_gds-grp-obj.obj-type  = p-obj-type
          and buf_gds-grp-obj.obj-code  = p-obj-code
    no-error .
  end.
  if v-range = 3 or not available buf_gds-grp-obj
  then do:
     if v-range <> 2 then do:
        find first buf_gds-grp-obj no-lock
            where buf_gds-grp-obj.node-code = p-node-code
              and buf_gds-grp-obj.host-code = v-host-code
              and buf_gds-grp-obj.obj-type  = ""
              and buf_gds-grp-obj.obj-code  = 0
        no-error .
      end.
      if v-range = 2 or not available buf_gds-grp-obj
      then do:
          if v-range <> 1 then do:
            find first buf_gds-grp-obj no-lock
                where buf_gds-grp-obj.node-code = p-node-code
                and buf_gds-grp-obj.host-code = 0
                and buf_gds-grp-obj.obj-type  = ""
                and buf_gds-grp-obj.obj-code  = 0
            no-error .
          end.
          if v-range = 1 or not available buf_gds-grp-obj
          then do:
              assign
                  v-exists = no
              .
          end.
          else do:
              assign
                  v-exists = yes
                  v-range = 1
              .
          end.
      end.
      else do:
          assign
              v-exists = yes
              v-range  = 2
          .
      end.
  end.
  else do:
      assign
          v-exists = yes
          v-range  = 3
      .
  end.
  if available buf_gds-grp-obj
  then do:
    find first buf_gds-grp-obj-attr no-lock
      where buf_gds-grp-obj-attr.node-code   = p-node-code
        and buf_gds-grp-obj-attr.host-code   = buf_gds-grp-obj.host-code
        and buf_gds-grp-obj-attr.obj-type    = buf_gds-grp-obj.obj-type
        and buf_gds-grp-obj-attr.obj-code    = buf_gds-grp-obj.obj-code
        and buf_gds-grp-obj-attr.attr-code   = 'NotCorrOP':U
      no-error .
    if available buf_gds-grp-obj-attr then do:
      assign
        v-notcorr-value = (if buf_gds-grp-obj-attr.attr-value = '' then ? else buf_gds-grp-obj-attr.attr-value)
      .
    end.
    else do:
      assign
        v-notcorr-value = ?
      .
    end.
    assign
    p-exists-notcorr = (if v-notcorr-value <> ? and p-notcorr = ?
                        then yes
                        else p-exists-notcorr)
    p-range-notcorr = if p-exists-notcorr and p-notcorr = ?
                      then v-range
                      else p-range-notcorr
    p-notcorr   =  if p-exists-notcorr and  p-notcorr = ?
                      then v-notcorr-value
                      else p-notcorr
    v-found =  (p-exists-notcorr ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
  else do:
    assign
    v-found =  (p-exists-notcorr  ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
end.
end.
end procedure.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable g#report-num   as integer no-undo .
run get-report-num in parparentproc (output g#report-num).
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  stream PrnLibStream.
procedure prn-lib-prn-file :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-DIsabledoptions as integer no-undo .
  define variable v-report-name as character no-undo .
  define variable v-user-action as character no-undo .
  define variable v-printed     as logical   no-undo .
  define variable v-exist       as logical   no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run filenmln in g#library
  (input  v-report-name
  ,input  2
  ,output v-exist
  )  .
    if NOT v-exist then
    DO:
      Message
        "Нет заданий на печать ! "
        view-as alert-box .
      Return  .
    End.
    run gbl/prnfilen.w
      (input  ""
      ,input  p-DisabledOptions
      ,input  string(v-report-name )
      ,input  7
      ,output v-user-action
      ,output v-printed
      ) .
    if v-printed then
    do:
      return "YES" .
    end.
    else
    do:
      return "NO" .
    end.
  end.
end procedure.
procedure prn-lib-open-stream :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-page-size    as integer no-undo .
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-append       as logical no-undo .
  define variable v-report-name as character no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
    if p-is-stream then
    do:
      if p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
    if not p-is-stream then
    do:
      if p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
  end.
end procedure.
procedure prn-lib-open-exp :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-is-append    as logical no-undo .
  define output parameter p-ReportFileName as char init "report" no-undo.
  define output parameter p-process as logical no-undo .
  define variable glog as logical no-undo .
  do
    on error undo, return error
    :
    SYSTEM-DIALOG GET-FILE p-ReportFileName
      TITLE      "Укажите путь"
      FILTERS "Текстовый файл (*.txt)"   "*.txt"
      ASK-OVERWRITE
      CREATE-TEST-FILE
      SAVE-AS
      USE-FILENAME
      DEFAULT-EXTENSION "txt"
      UPDATE glog
      .
    if not glog then  return.
    p-ReportFileName = trim( string( p-ReportFileName ) ) .
    if p-is-stream then
    do:
      if p-is-append then
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    else
    do:
      if p-is-append then
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    p-process = yes.
  end.
end procedure.
procedure prn-lib-get-report-name :
  define input parameter parParentProc  as widget-handle no-undo.
  define output parameter p-report-name as character no-undo .
  p-report-name = ibs.th.gbl.gbl-inipar:prn-lib-get-report-name("rpt").
end procedure.
procedure prn-lib-reportviewer-report-name :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer-report-name(p-report-name-html) no-error.
end procedure.
procedure prn-lib-reportviewer :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  define input parameter p-param        as character no-undo .
  define variable v-excel           as character no-undo init 'TRUE' .
  define variable v-value-character as character no-undo .
  define variable v-value-integer   as character no-undo .
  define variable v-value-date      as date      no-undo .
  define variable v-value-decimal   as decimal   no-undo .
  define variable rep-excel         as logical   no-undo .
  define variable excel-string      as character no-undo .
  define variable v-param-type      as character no-undo .
  define variable v-tth             as handle    no-undo .
  run adm/shattri.p (
    input "get":U
    ,input  ""
    ,input  0
    ,input  'report-glob':U
    ,input  'rep-excel':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output rep-excel
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    )  .
  if rep-excel then v-excel = "TRUE" .
  else v-excel = "FALSE" .
  if p-param eq ""
  then
     p-param = "EXCEL:" + v-excel.
  else
     p-param = p-param + chr(4) + "EXCEL:" + v-excel .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer(p-report-name-html, p-param).
end procedure.
procedure reprumpr_print-plain-text :
define input parameter p-dir-name as character no-undo .
define input parameter p-subdir-name as character no-undo .
define input parameter p-custom-name as character no-undo .
define input parameter p-disable-option as integer no-undo .
define input parameter p-font-number as integer no-undo .
define variable v-file-name as character no-undo .
define variable v-report-name as character no-undo .
define variable v-err-status as integer no-undo .
define variable v-err-mess as character no-undo .
v-file-name = p-dir-name + (if p-subdir-name <> ''
                            then (p-subdir-name + chr(47))
                            else '') +
              p-custom-name.
run prn-lib-get-report-name  in this-procedure (
                                                  input parParentProc
                                                  ,output v-report-name
                                                ).
os-copy
value(v-report-name)
value(v-file-name)
.
assign
v-err-status = os-error
.
if v-err-status <> 0 then do:
  run gbl/os-errnm.p ( input v-err-status
                      ,output v-err-mess).
  return error v-err-mess.
end.
else do:
  run cb_fill-report-destination in p-parent-handle (  input p-rdbh
                                                ,input p-report-id
                                                ,input 'text':U
                                                ,input v-file-name
                                                ,input string(p-disable-option) + chr(4) + string(p-font-number)
                                                ).
end.
end procedure.
procedure reprumpr_print-printer :
define input parameter p-font-number as integer no-undo .
define input parameter p-flags as integer no-undo .
define variable v-quest-print as logical no-undo .
define variable lok as logical no-undo .
define variable v-report-name as character no-undo .
run get-quest-print in parparentproc ( output v-quest-print) .
if not v-quest-print then do:
    .
  run prn-lib-get-report-name  in this-procedure (
                                                    input parParentProc
                                                   ,output v-report-name
                                                  ).
  run adecomm/_osprint.p
    (input  ?
    ,input  v-report-name
    ,input  p-font-number
    ,input  p-flags
    ,input  0
    ,input  0
    ,output lok
    ).
  if not lok then do:
  end.
end.
end procedure.
define stream temp-stream.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure prnexldl_clear:
define input parameter p-txl-file-name as character no-undo .
define variable v-template-file-name as character no-undo .
define variable v-vb-file-name as character no-undo .
define variable v-data-header-filename as character no-undo .
define variable v-data-filename as character no-undo .
if search( p-txl-file-name ) <> ? then do:
  input stream temp-stream from value( p-txl-file-name ).
  repeat
  :
      import stream temp-stream v-template-file-name   .
      import stream temp-stream v-vb-file-name         .
      import stream temp-stream v-data-header-filename .
      os-delete value(v-data-header-filename).
      import stream temp-stream v-data-filename        .
      os-delete value(v-data-filename).
  end.
  input stream temp-stream close.
  os-delete value( p-txl-file-name ).
end.
end procedure .
define stream reprumpr_in.
procedure reprumpr_print-xlt :
define input parameter p-dir-name as character no-undo .
define input parameter p-subdir-name as character no-undo .
define input parameter p-custom-name as character no-undo .
define input parameter p-disable-option as integer no-undo .
define input parameter p-font-number as integer no-undo .
define buffer buf_temp-param for temp-param .
define variable v-report-num            as integer no-undo .
define variable v-filename              as character    no-undo .
define variable v-obj-dir               as character    no-undo .
define variable v-report-filename       as character    no-undo .
define variable v-home-dir-filename     as character    no-undo .
define variable v-error-num             as integer      no-undo .
define variable v-template-file-name    as character    no-undo .
define variable v-vb-file-name          as character    no-undo .
define variable v-data-header-filename  as character    no-undo .
define variable v-data-filename         as character    no-undo .
define variable v-excel-file-name       as character    no-undo .
define variable v-err-message           as character    no-undo .
define variable v-os-err-str            as character    no-undo .
define variable v-report-dir            as character    no-undo .
do for buf_temp-param
on error undo, return error return-value
:
assign
  v-report-dir  = trim( replace( p-dir-name, '/' , '\' ) , '\' )
.
  assign
  v-report-num = g#report-num
  v-obj-dir           = v-report-dir + chr(47) +
                        (if p-subdir-name <> '' then (p-subdir-name + chr(47)) else '')
  v-filename          = string( session:temp-directory ) + "rpt" + string( v-report-num )
  v-excel-file-name   = string( session:temp-directory ) + "rpt" + string( v-report-num ) + ".xls"
  v-home-dir-filename = v-obj-dir +  p-custom-name
  .
  os-delete value( v-filename + ".txl" )  .
  os-rename
    value( string( session:temp-directory ) + "$" + string( v-report-num ) + ".txl" )
    value( v-filename + ".txl" )
  .
  assign
    v-filename = search( v-filename + ".txl" )
  .
  if v-filename = "" or v-filename = ?
  then do:
    assign
      v-err-message = v-err-message + substitute( "Не найден файл &1 для формирования Excel-файла по объекту p-custom-name"
                                                , string( session:temp-directory ) + "rpt" + string( v-report-num )
                                                )
    .
    return error v-err-message.
  end.
  input stream reprumpr_in from value( v-filename ).
  import stream reprumpr_in v-template-file-name   no-error .
  import stream reprumpr_in v-vb-file-name         no-error .
  import stream reprumpr_in v-data-header-filename no-error .
  import stream reprumpr_in v-data-filename        no-error .
  input stream reprumpr_in close.
  if search( v-template-file-name ) = ?
  then do:
    assign
      v-err-message = v-err-message + substitute( "Не найден шаблон Excel для вывода данных.&2Указан файл шаблона:&1&2&2"
                                                , v-template-file-name
                                                , chr(10)
                                                )
    .
    return error v-err-message.
  end.
  if search( v-vb-file-name ) = ?
  then do:
    assign
      v-err-message = v-err-message + substitute( "Не найден текст программы заполнения шаблона Excel.&3Файл шаблона:&1&3Указан файл программы:&2&3&3"
                                                , v-template-file-name
                                                , v-vb-file-name
                                                , chr(10)
                                                )
    .
    return error v-err-message.
  end.
  if v-data-header-filename <> "":U
  and search( v-data-header-filename ) = ?
  then do:
    assign
      v-err-message = v-err-message + substitute( "Не найден файл шапки.&3Файл шаблона:&1&3Указан файл шапки:&2&3&3"
                                                , v-template-file-name
                                                , v-data-header-filename
                                                , chr(10)
                                                )
    .
    return error v-err-message.
  end.
  if v-data-filename <> "":U
  and search( v-data-filename )   = ?
  then do:
    assign
      v-err-message = v-err-message + substitute( "Не найден файл строк данных.&3Файл шаблона:&1&3Указан файл строк данных:&2&3&3"
                                                , v-template-file-name
                                                , v-data-filename
                                                , chr(10)
                                                )
    .
    return error v-err-message.
  end.
  create buf_temp-param.
  assign
    v-template-file-name = search( v-template-file-name )
    file-info :file-name = v-template-file-name
    v-template-file-name = file-info :full-pathname
    v-vb-file-name       = search( v-vb-file-name )
    file-info :file-name = v-vb-file-name
    v-vb-file-name       = file-info :full-pathname
  .
  if v-template-file-name = ? or v-template-file-name = "":U
  then do:
    RETURN error substitute("Не найден шаблон &1", v-template-file-name).
  end.
  run paramls-write in this-procedure ( input "template":U
                                      , input "template-file-name":U
                                      , input v-template-file-name
                                      ).
  run paramls-write in this-procedure ( input "template":U
                                      , input "vb-file-name":U
                                      , input v-vb-file-name
                                      ).
  run paramls-write in this-procedure ( input "data":U
                                      , input "data-header-filename":U
                                      , input v-data-header-filename
                                      ).
  run paramls-write in this-procedure ( input "data":U
                                      , input "data-filename":U
                                      , input v-data-filename
                                      ).
  run paramls-write in this-procedure ( input "saveas":U
                                      , input "excel-file-name":U
                                      , input v-excel-file-name
                                      ).
  run paramls-write in this-procedure ( input "file":U
                                      , input "file-no-open":U
                                      , input "yes":U
                                      ).
  run gbl/macroxlt.p ( input-output table buf_temp-param ) no-error.
  if error-status :error
  then do:
    assign
      v-err-message = v-err-message + substitute( "&1&2&3&4Ошибка создания файла Excel.&4&5&4&6&4&7&4&8&4&4"
                                                , vss-workfile
                                                , vss-revision
                                                , vss-description
                                                , chr(10)
                                                , return-value
                                                , trim(error-status :get-message(1))
                                                , trim(error-status :get-message(2))
                                                , trim(error-status :get-message(3))
                                                )
    .
    return error v-err-message.
  end.
  run prnexldl_clear in this-procedure ( input v-filename) no-error.
  if error-status :error
  then do:
    assign
      v-err-message = v-err-message + substitute( "Ошибка удаления файла &1: &2 &3&3"
                                                , v-filename
                                                , return-value
                                                , chr(10)
                                                )
    .
    return error v-err-message.
  end.
  run gbl/dir-cre.p ( input v-obj-dir ) no-error  .
  if error-status :error
  then do:
    assign
      v-err-message = v-err-message + substitute( "Ошибка создания директории &1: &2&4&3&4&4"
                                                , v-filename
                                                , return-value
                                                , trim(error-status :get-message(1))
                                                , chr(10)
                                                )
    .
  end.
  run gbl/del-file.p ( input v-home-dir-filename ) no-error .
  if error-status :error
  then do:
    assign
      v-err-message = v-err-message + substitute( "Ошибка удаления файла &1: &2 &3&3"
                                                , v-home-dir-filename
                                                , return-value
                                                , chr(10)
                                                )
    .
    return error v-err-message.
  end.
  run gbl/ren-file.p ( input v-excel-file-name
                  , input v-home-dir-filename
                  ) no-error .
  if error-status :error
  then do:
    assign
      v-err-message = v-err-message + substitute( "Ошибка перемещения файла &1 -> &2: &3&4&4"
                                                , v-excel-file-name
                                                , v-home-dir-filename
                                                , return-value
                                                , chr(10)
                                                )
    .
    return error v-err-message.
  end.
  run cb_fill-report-destination in p-parent-handle (  input p-rdbh
                                                ,input p-report-id
                                                ,input 'excel':U
                                                ,input v-home-dir-filename
                                                ,input string(p-disable-option) + chr(4) + string(p-font-number)
                                                ).
end.
end procedure.
define variable vss-include-info26 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define stream excel-line.
define stream excel-cell.
define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character
    index pi is primary unique data-key
.
define temp-table temp_sheet1_line-data no-undo
    field sheet-name    as character
    field xl-line-id    as integer
    field gdsname         as character
    field docdate         as character
    field doccode         as character
    field gdssum          as character
    field tarasum         as character
    field buhone          as character
    field buhtwo          as character
    index pi is primary unique
        xl-line-id
.
define temp-table temp_sheet2_line-data no-undo
    field sheet-name      as character
    field xl-line-id      as integer
    field gdsname         as character
    field docdate         as character
    field doccode         as character
    field gdssum          as character
    field tarasum         as character
    field buhone          as character
    field buhtwo          as character
index pi is primary unique
    xl-line-id
.
define variable v-torg29xl-sheet1-cur-data-row     as integer      no-undo.
define variable v-torg29xl-sheet2-cur-data-row     as integer      no-undo.
define variable v-torg29xl-cell-file-name       as character    no-undo.
define variable v-torg29xl-data-file-name       as character    no-undo.
procedure torg29xl-init :
do
on error undo, return error
:
    assign
        v-torg29xl-sheet1-cur-data-row = 0
        v-torg29xl-sheet2-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-torg29xl-data-file-name
    ).
    output stream excel-line to value( v-torg29xl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-torg29xl-cell-file-name
    ).
    output stream excel-cell to value( v-torg29xl-cell-file-name ).
    run torg29xl-write-cell-data in this-procedure (
          input "sheetList":U
        , input "лист1,лист2":U
    ).
    if printrubl
    then do:
        run torg29xl-write-cell-data in this-procedure (
              input "лист1_valutCode":U
            , input "0":U
        ).
        run torg29xl-write-cell-data in this-procedure (
              input "лист2_valutCode":U
            , input "0":U
        ).
    end.
    else do:
        run torg29xl-write-cell-data in this-procedure (
              input "лист1_valutCode":U
            , input "1":U
        ).
        run torg29xl-write-cell-data in this-procedure (
              input "лист2_valutCode":U
            , input "1":U
        ).
    end.
    run torg29xl-write-cell-data in this-procedure (
          input "лист1_columnList":U
        , input "gdsname,docdate,doccode,gdssum,tarasum,buhone,buhtwo":U
    ).
    run torg29xl-write-cell-data in this-procedure (
          input "лист1_columnType":U
        , input "S,S,S,S,S,S,S":U
    ).
    run torg29xl-write-cell-data in this-procedure (
          input "лист1_subtotalList":U
        , input "":U
    ).
    run torg29xl-write-cell-data in this-procedure (
          input "лист1_subtotalType":U
        , input "":U
    ).
    run torg29xl-write-cell-data in this-procedure (
          input "лист2_columnList":U
        , input "gdsname,docdate,doccode,gdssum,tarasum,buhone,buhtwo":U
    ).
    run torg29xl-write-cell-data in this-procedure (
          input "лист2_columnType":U
        , input "S,S,S,S,S,S,S":U
    ).
    run torg29xl-write-cell-data in this-procedure (
          input "лист2_subtotalList":U
        , input "":U
    ).
    run torg29xl-write-cell-data in this-procedure (
          input "лист2_subtotalType":U
        , input "":U
    ).
end.
end procedure.
procedure torg29xl-sheet1-write-line-data :
define input parameter p-gdsname as character        no-undo.
define input parameter p-docdate as character        no-undo.
define input parameter p-doccode as character        no-undo.
define input parameter p-gdssum  as character        no-undo.
define input parameter p-tarasum as character        no-undo.
define input parameter p-buhone  as character        no-undo.
define input parameter p-buhtwo  as character        no-undo.
    define buffer buf_temp_sheet1_line-data        for temp_sheet1_line-data.
do
for buf_temp_sheet1_line-data
on error undo, return error
:
    for each buf_temp_sheet1_line-data
    :
        delete buf_temp_sheet1_line-data.
    end.
    create buf_temp_sheet1_line-data.
    assign
        v-torg29xl-sheet1-cur-data-row       = v-torg29xl-sheet1-cur-data-row + 1
        buf_temp_sheet1_line-data.sheet-name = "лист1":U
        buf_temp_sheet1_line-data.xl-line-id = v-torg29xl-sheet1-cur-data-row
        buf_temp_sheet1_line-data.gdsname    = p-gdsname
        buf_temp_sheet1_line-data.docdate    = p-docdate
        buf_temp_sheet1_line-data.doccode    = p-doccode
        buf_temp_sheet1_line-data.gdssum     = p-gdssum
        buf_temp_sheet1_line-data.tarasum    = p-tarasum
        buf_temp_sheet1_line-data.buhone     = p-buhone
        buf_temp_sheet1_line-data.buhtwo     = p-buhtwo
    .
    put stream excel-line unformatted
                        buf_temp_sheet1_line-data.sheet-name
        CHR(9)   "DTA":U
        CHR(9)   buf_temp_sheet1_line-data.gdsname
        CHR(9)   buf_temp_sheet1_line-data.docdate
        CHR(9)   buf_temp_sheet1_line-data.doccode
        CHR(9)   buf_temp_sheet1_line-data.gdssum
        CHR(9)   buf_temp_sheet1_line-data.tarasum
        CHR(9)   buf_temp_sheet1_line-data.buhone
        CHR(9)   buf_temp_sheet1_line-data.buhtwo
        chr(10)
    .
    .
end.
end procedure.
procedure torg29xl-sheet2-write-line-data :
define input parameter p-gdsname as character        no-undo.
define input parameter p-docdate as character        no-undo.
define input parameter p-doccode as character        no-undo.
define input parameter p-gdssum  as character        no-undo.
define input parameter p-tarasum as character        no-undo.
define input parameter p-buhone  as character        no-undo.
define input parameter p-buhtwo  as character        no-undo.
    define buffer buf_temp_sheet2_line-data        for temp_sheet2_line-data.
do
for buf_temp_sheet2_line-data
on error undo, return error
:
    for each buf_temp_sheet2_line-data
    :
        delete buf_temp_sheet2_line-data.
    end.
    create buf_temp_sheet2_line-data.
    assign
        v-torg29xl-sheet2-cur-data-row = v-torg29xl-sheet2-cur-data-row + 1
    .
    assign
        buf_temp_sheet2_line-data.sheet-name = "лист2":U
        buf_temp_sheet2_line-data.xl-line-id = v-torg29xl-sheet2-cur-data-row
        buf_temp_sheet2_line-data.gdsname    = p-gdsname
        buf_temp_sheet2_line-data.docdate    = p-docdate
        buf_temp_sheet2_line-data.doccode    = p-doccode
        buf_temp_sheet2_line-data.gdssum     = p-gdssum
        buf_temp_sheet2_line-data.tarasum    = p-tarasum
        buf_temp_sheet2_line-data.buhone     = p-buhone
        buf_temp_sheet2_line-data.buhtwo     = p-buhtwo
    .
    put stream excel-line unformatted
                        buf_temp_sheet2_line-data.sheet-name
        CHR(9)   "DTA":U
        CHR(9)   buf_temp_sheet2_line-data.gdsname
        CHR(9)   buf_temp_sheet2_line-data.docdate
        CHR(9)   buf_temp_sheet2_line-data.doccode
        CHR(9)   buf_temp_sheet2_line-data.gdssum
        CHR(9)   buf_temp_sheet2_line-data.tarasum
        CHR(9)   buf_temp_sheet2_line-data.buhone
        CHR(9)   buf_temp_sheet2_line-data.buhtwo
        chr(10)
    .
end.
end procedure.
procedure torg29xl-write-cell-data :
define input parameter p-data-key   as character        no-undo.
define input parameter p-data-value as character        no-undo.
    define buffer buf_temp_cell-data     for temp_cell-data.
do
for buf_temp_cell-data
on error undo, return error
:
    find first buf_temp_cell-data
         where buf_temp_cell-data.data-key = p-data-key
    no-error.
    if not available buf_temp_cell-data
    then do:
        create buf_temp_cell-data.
        assign
            buf_temp_cell-data.data-key = p-data-key
        .
    end.
    assign
        buf_temp_cell-data.data-value = p-data-value
    .
    put stream excel-cell unformatted
                        buf_temp_cell-data.data-key
        CHR(9)   buf_temp_cell-data.data-value
        chr(10)
    .
end.
end procedure.
procedure torg29xl-run-excel :
define input parameter p-header-filename    as character        no-undo.
define input parameter p-data-filename      as character        no-undo.
    define variable v-template-file-name    as character    no-undo.
    define variable v-vb-file-name          as character    no-undo.
    define buffer buf_temp-param for temp-param .
do
for buf_temp-param
on error undo, return error
:
    create buf_temp-param.
    assign
        v-template-file-name    = search( "exe/torg29.xlt" )
        v-vb-file-name          = search( "exe/t_form.bas")
    .
    if v-template-file-name = ?
    or v-template-file-name = "":U
    then do:
        message
            "Ошибка имени файла шаблона."
        view-as alert-box error.
    end.
    if v-vb-file-name = ?
    or v-vb-file-name = "":U
    then do:
        message
            "Ошибка имени файла кода обработки."
        view-as alert-box error.
    end.
    run paramls-write in this-procedure (
          input "template":U
        , input "template-file-name":U
        , input v-template-file-name
    ).
    run paramls-write in this-procedure (
          input "template":U
        , input "vb-file-name":U
        , input v-vb-file-name
    ).
    run paramls-write in this-procedure (
          input "data":U
        , input "data-header-filename":U
        , input p-header-filename
    ).
    run paramls-write in this-procedure (
          input "data":U
        , input "data-filename":U
        , input p-data-filename
    ).
    run gbl/macroxlt.p (
        input-output table buf_temp-param
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка создания файла Excel."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
end.
end procedure.
procedure torg29xl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) .
        export "exe/torg29.xlt":U.
        export "exe/t_form.bas":U.
        export v-torg29xl-cell-file-name.
        export v-torg29xl-data-file-name.
    output close.
end.
end procedure.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define temp-table tt-goods no-undo
  field gds-code      like ub.goods.gds-code
  field artic         like ub.goods.artic
  field prod-type     like ub.goods.prod-type
  field prod-code     like ub.goods.prod-code
index pi is primary unique
  artic
  prod-type
  prod-code
.
define temp-table tt-report-object no-undo
  field obj-type      like ub.clients.obj-type
  field obj-code      like ub.clients.obj-code
  field ost-gds-sum-1   as decimal
  field ost-tara-sum-1  as decimal
  field ost-gds-sum-2   as decimal
  field ost-tara-sum-2  as decimal
index pi is primary unique
  obj-type
  obj-code
.
define temp-table tt-report no-undo
  field ext-doc-type  like ub.trn-doc.ext-doc-type
  field real-ext-doc-type like ub.trn-doc.ext-doc-type
  field break-ext-doc-type like ub.trn-doc.ext-doc-type
  field cli-name      as character
  field fact-order    as decimal
  field fact-date     as date
  field doc-code      like ub.trn-doc.doc-code
  FIELD num-ship      like ub.trn-doc.doc-code
  field doc-sum       as decimal
  field tara-sum      as decimal
  field buh-1         as character
  field obj-type      like ub.clients.obj-type
  field obj-code      like ub.clients.obj-code
index pi is primary unique
  doc-code ext-doc-type
index fo fact-order
index exdoc ext-doc-type
index obj
  obj-type
  obj-code
index fo2 break-ext-doc-type fact-order
.
define temp-table tt-ignore-docs no-undo
field doc-code as character
index pi is unique primary
doc-code.
define temp-table temp-inkas no-undo
field ras-doc-code as character
field ret-doc-code as character
field obj-type as character
field obj-code as integer
field inkas-code as character
index pi is unique primary
inkas-code
index iret ret-doc-code
index idoc ras-doc-code
index iobj obj-type obj-code
.
define temp-table temp-cp no-undo
field gds-code as integer
field cdpay-code as integer
field curr-code as integer
field eff-doc-qnty as decimal
field doc-code  as character
field inkas-code as character
field tot-rb as decimal
field doc-date as date
field sum as decimal
index pi
is unique primary
doc-code
gds-code
cdpay-code
curr-code
index iinkas
inkas-code
.
define buffer buf_gds-obj   for ub.gds-obj.
define buffer buf_goods     for ub.goods.
define buffer buf_gds-grp   for ub.gds-grp.
define buffer buf_trn-doc   for ub.trn-doc.
define buffer buf_doc-line  for ub.doc-line.
define buffer buf_ot-line   for ub.ot-line.
define buffer buf_obj-list  for obj-list.
define buffer buf2_obj-list  for obj-list.
define stream out-stream.
define variable v-fact-order-1           as decimal   no-undo .
define variable v-fact-order-2           as decimal   no-undo .
define variable v-curr-r-b               as character no-undo .
define variable v-line                   as character no-undo .
define variable v-print-rubl             as logical   no-undo .
define variable v-gds-counter            as integer   no-undo .
define variable v-host-code-1 like ub.clients.host-code no-undo .
define variable v-host-code-2 like ub.clients.host-code no-undo .
define variable v-name              as character no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo init -1.
define variable v-upper-code as integer no-undo.
define variable v-value as character no-undo.
define variable v-type as character no-undo.
define variable v-p-accsup as character no-undo.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'accsup'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output v-p-accsup
  ,output v-type
  ) no-error .
function w-date returns character ( input p-date as date ) forward .
define frame torg29
  sym7                            column-label ":" format "X(1)"                             space(0)
  v-name                          column-label "  Наименование" format "X(25)":U     space(0)
  sym1                            column-label ": " format "X(2)"                             space(0)
  tt-report.fact-date             column-label "   Дата" format "99/99/9999":U                space(0)
  sym2                            column-label ": " format "X(2)"                             space(0)
  tt-report.num-ship              column-label "  Номер документа" format "X(25)":U     space(0)
  sym3                            column-label ":" format "X(2)"                             space(0)
  tt-report.doc-sum               column-label "Сумма товара    " format "->>>>,>>>,>>>,>>9.99":U          space(0)
  sym4                            column-label ":" format "X(2)"                             space(0)
  tt-report.tara-sum              column-label "Сумма тары" format "->>,>>9.99":U            space(0)
  sym5                            column-label ":" format "X(2)"                             space(0)
  tt-report.buh-1                 column-label "       Отметки бухгалтерии" format "X(14)":U  space(0)
  sym6                            column-label ":" format "X(1)"                             space(0)
header
    ":-------------------------:-----------:--------------------------:---------------------:-----------:---------------------------:":U skip
with width 130 down stream-io .
form header
        v-line format "X(130)" at 1 SKIP
        "Продолжение - на следующей странице" at 1 SKIP
with frame BottomFrame width 198 PAGE-BOTTOM NO-LABELS NO-BOX .
do on error undo, return error return-value :
if session :set-wait-state( "compiler" ) then.
  run clear-tt in this-procedure .
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  assign  v-line = fill( "-" , 300 ) .
  case x-SET_val_TYPE :
    when 1 then do:
      assign  v-print-rubl = yes .
    end.
    when 2 then do:
      assign  v-print-rubl = no .
    end.
    otherwise do:
      if x-SET_PAY_TYPE <> 1 then  message "Неизвестный тип валюты!" skip "Отчет формируется в базовой валюте" view-as alert-box information .
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
      assign  v-print-rubl = ( v-curr-r-b = 'rubl':U )  .
    end.
  end case.
  find first buf_obj-list no-error .
  if not available buf_obj-list then do:
        if p-batch > 0 then do:      run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input substitute("Не указан объект для формирования отчета")).    end.    else do:       run write-to-log in p-log-handle ( input substitute("Не указан объект для формирования отчета")).    end.
    undo, return error.
  end.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_obj-list.obj-type
  ,input  buf_obj-list.obj-code
  ,output v-host-code-1
  )  .
  for each buf_obj-list :
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_obj-list.obj-type
  ,input  buf_obj-list.obj-code
  ,output v-host-code-2
  )  .
    if v-host-code-1 <> v-host-code-2 then do:
            if p-batch > 0 then do:      run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input substitute("Отчет формируется по объектам одной фирмы!")).    end.    else do:       run write-to-log in p-log-handle ( input substitute("Отчет формируется по объектам одной фирмы!")).    end.
      undo, return error.
    end.
  end.
  if not x-TOG-Shift then do:
    run day-begin-fact-order in this-procedure ( input x-Date-Start , output v-fact-order-1 ).
    run  factord-end-day in this-procedure ( input x-Date-End , output v-fact-order-2 ).
  end.
output stream out-stream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size 62 .
  run torg29xl-init in this-procedure.
  run create-report in this-procedure .
  run print-report in this-procedure .
  run waitfram-hide in this-procedure .
  run torg29xl-close in this-procedure .
  output stream out-stream close.
  if Make-Excel then output stream ForExcel close.
  run clear-tt in this-procedure .
if session :set-wait-state( "" ) then.
  define variable DisabledOptions as integer   no-undo .
  define variable v-orient-page as character no-undo .
  run How-name in this-procedure ( input ReportPageHeight
                                  , input ReportPageWidth
                                  , output v-orient-page ) .
  if v-orient-page = "A4-lans":U then DisabledOptions = 8 .
                                else DisabledOptions = 0 .
  assign
  ReportFontNum = 7.
  if p-batch > 0 then do:
    run reprumpr_print-printer in this-procedure ( input ReportFontNum
                                                  ,input (if v-orient-page = "A4-lans":U
                                                          then 2
                                                          else 0)
                                                  ) no-error.
    if error-status:error then do:
            if p-batch > 0 then do:      run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input "Печать на принтер завершилась ошибкой...").    end.    else do:       run write-to-log in p-log-handle ( input "Печать на принтер завершилась ошибкой...").    end.
    end.
    IF p-xls THEN DO:
      RUN reprumpr_print-xlt ( input p-dir-name
                              ,input ''
                              ,input substitute("torg29d_&1&2_&3&4&5_&6.xls"
                                                , v-obj-type
                                                , v-obj-code
                                                , string(year(X-date-end), "9999")
                                                , string(month(X-date-end), "99")
                                                , string(day(X-date-end), "99")
                                                , X-shift-end)
                               ,input DisabledOptions
                               ,input ReportFontNum
                                ) no-error  .
      if error-status:error then do:
                if p-batch > 0 then do:      run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input return-value).    end.    else do:       run write-to-log in p-log-handle ( input return-value).    end.
      end.
    END.
    if p-plain-txt then do:
      run reprumpr_print-plain-text in this-procedure ( input p-dir-name
                                                        ,input ''
                                                        ,input substitute("torg29d_&1&2_&3&4&5_&6.txt"
                                                                        , v-obj-type
                                                                        , v-obj-code
                                                                        , string(year(X-date-end), "9999")
                                                                        , string(month(X-date-end), "99")
                                                                        , string(day(X-date-end), "99")
                                                                        , X-shift-end)
                                                        ,input DisabledOptions
                                                        ,input ReportFontNum
                                                        ) no-error.
      if error-status:error then do:
                if p-batch > 0 then do:      run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input return-value).    end.    else do:       run write-to-log in p-log-handle ( input return-value).    end.
      end.
    end.
  end.
  else do:
    define variable v-user-action   as character no-undo .
    define variable v-printed       as logical   no-undo .
  os-delete value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )  .
  os-rename
    value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
    value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )
  .
  run gbl/prnfilen.w
      ( input  ""
      , input  DisabledOptions
      , input  string(session :temp-directory) + "rpt" + string( g#report-num )
      , input  ReportFontNum
      , output v-user-action
      , output v-printed
      ) .
  os-delete value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )  .
end.
end.
procedure clear-tt :
do
on error undo, return error return-value
:
  empty temp-table tt-report-object.
  empty temp-table tt-report.
  empty temp-table tt-goods.
end.
end procedure.
procedure print-header-list-1 :
  define buffer buf_clients for ub.clients.
  define variable v-obj-list as character format "X(78)" no-undo .
do
on error undo, return error return-value
:
find first buf_clients no-lock
  where buf_clients.obj-type = 'орг':U
    and buf_clients.obj-code = v-host-code-1
no-error .
if not available buf_clients then do:
    if p-batch > 0 then do:      run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input substitute("Не найдена фирма с кодом &1&2" +                                "Отчет не может быть сформирован"                                , v-host-code-1, chr(10))).    end.    else do:       run write-to-log in p-log-handle ( input substitute("Не найдена фирма с кодом &1&2" +                                "Отчет не может быть сформирован"                                , v-host-code-1, chr(10))).    end.
  return error.
end.
for each buf_obj-list :
  assign
    v-obj-list = v-obj-list + buf_obj-list.obj-name + ','
  .
end.
assign
  v-obj-list = trim( v-obj-list , ',' ).
.
run fmtcli-get-client in this-procedure ( input  buf_clients.obj-type , input buf_clients.obj-code ).
put stream out-stream unformatted
  "                                                                                                 Унифицированная форма N ТОРГ-29" skip
  "                                                                                                                                " skip
  "                                                                                                 Утверждена                     " skip
  "                                                                                                 Постановлением                 " skip
  "                                                                                                 Госкомстата России             " skip
  "                                                                                                 от 25.12.98 N 132              " skip
  "                                                                                                                                " skip
  "                                                                                                                      ----------" skip
  "                                                                                                                      |  Код   |" skip
  "                                                                                                                      |--------|" skip
  "                                                                                                        Форма по ОКУД |0330229 |" skip
  "                                                                                                                      |--------|" skip
  substitute( "             &1    по ОКПО |&2|"
            , string( p-fmt-align-string( v-fmtcli-name , 93 , "left") , "X(93)" )
            , string( v-fmtcli-okpo , "X(8)"  )
            )
  skip
  "             -----------------------------------------------------------------------------------------------          |--------|" skip
  "                                                   организация                                                        |        |" skip
  substitute( "             &1                           |--------|"
            , string( p-fmt-align-string( v-obj-list , 78 , "left") , "X(78)" )
            )
  skip
  "             ------------------------------------------------------------------------------  Вид деятельности по ОКДП |        |" skip
  "                                           структурное подразделение                                                  |--------|" skip
  "                                                                                                         Вид операции |        |" skip
  "                                                                                                                      ----------" skip
  "                                                                                                                                " skip
  "                                                                                  ----------------------------------------------" skip
  "                                                                                  |  Номер  |    Дата   |        Отчетный      |" skip
  "                                                                                  |документа|составления|         период       |" skip
  "                                                                                  |         |           |----------------------|" skip
  "                                                                                  |         |           |     с     |    по    |" skip
  "                                                                                  |---------|-----------|-----------|----------|" skip
  substitute( "                                                                   ТОВАРНЫЙ ОТЧЕТ |         |&1 |&2 |&3|"
            , string( today , "99.99.9999" )
            , string( x-Date-Start , "99.99.9999" )
            , string( x-Date-End , "99.99.9999" )
            )
  skip
  "                                                                                  ----------------------------------------------" skip
  "                                                                                                                                " skip
  "                                                                                                               -----------------" skip
  "                                                                                                               |Табельный номер|" skip
  "                                                                                                               |---------------|" skip
  "                                                                                                               |               |" skip
  "                        Материально ответственное лицо _______________________________________________________ -----------------" skip
  "                                                                             должность, фамилия,                                " skip
  "                                                                                имя, отчество                                   " skip(1)
.
run print-table-header in this-procedure .
run torg29xl-write-cell-data in this-procedure ( input "h_firmname":U, input v-fmtcli-name ).
run torg29xl-write-cell-data in this-procedure ( input "h_objlist":U,  input v-obj-list ).
run torg29xl-write-cell-data in this-procedure ( input "h_okpo":U, input v-fmtcli-okpo ).
run torg29xl-write-cell-data in this-procedure ( input "h_printdate":U, input string( today , "99.99.9999") ).
run torg29xl-write-cell-data in this-procedure ( input "h_datestart":U, input string( x-Date-Start, "99.99.9999" ) ).
run torg29xl-write-cell-data in this-procedure ( input "h_dateend":U, input string( x-Date-End , "99.99.9999" ) ).
end.
end procedure.
procedure print-header-list-2 :
do
on error undo, return error return-value
:
  put stream out-stream "Оборотная сторона формы N ТОРГ-29" skip(1).
  run print-table-header in this-procedure .
end.
end procedure.
procedure print-table-header :
  define variable v-str     as character no-undo .
  define variable v-length  as integer   no-undo .
  define variable v-result  as character no-undo .
  define variable v-i       as integer   no-undo .
  define variable v-j       as integer   no-undo .
do
:
  assign
    v-str     = "Сумма, руб. коп."
    v-length  = length(v-str)
  .
  if v-length > 31 then do:
    assign  v-result = substring( v-str , 1 , 31 ) .
  end.
  else do:
    assign v-i = center-field( 1, 31, v-length ) .
    do v-j = 1 to 31 :
      if v-j <> v-i then do:
        assign v-result = v-result + " " .
      end.
      else do:
        assign
          v-result  = v-result + v-str
          v-j       = v-j + length(v-str) - 1
        .
      end.
    end.
  end.
end.
end procedure.
procedure print-footer-list-2 :
do on error undo, return error return-value :
  put stream out-stream unformatted
    "Приложение ____________________________________________ документов                    ":U skip
    "                                                                                      ":U skip
    "Отчет с документами                                                                   ":U skip
    "принял и проверил   _________________________ __________________ _____________________":U skip
    "                              должность              подпись      расшифровка подписи ":U skip
    "                                                                                      ":U skip
    "Материально                                                                           ":U skip
    "ответственное лицо  _________________________ __________________ _____________________":U skip
    "                              должность              подпись      расшифровка подписи ":U skip
  .
  end.
end procedure.
procedure create-tt-goods :
  define buffer buf_goods   for ub.goods.
  define buffer buf_cli-gds for ub.cli-gds.
  define variable v-curr-grp-name as character no-undo .
  define variable v-host-code     like ub.clients.host-code  no-undo .
  do on error undo, return error return-value :
    run waitfram-show in this-procedure ( "Формирование списка товаров..." ) .
    empty temp-table tt-goods.
    for each buf_obj-list :
      case x-SelectGood :
        when 1 then do:
          for each buf_gds-obj no-lock
            where buf_gds-obj.obj-type  = buf_obj-list.obj-type
              and buf_gds-obj.obj-code  = buf_obj-list.obj-code
            :
            run fill-tt in this-procedure .
          end.
        end.
        when 3 then do:
          for each G#cli :
            for each buf_gds-obj  no-lock
              where buf_gds-obj.obj-type  = buf_obj-list.obj-type
                and buf_gds-obj.obj-code  = buf_obj-list.obj-code
                and buf_gds-obj.prod-type = G#cli.obj-type
                and buf_gds-obj.prod-code = G#cli.obj-code
              use-index pi  :
              run fill-tt in this-procedure .
            end .
          end .
        end .
        when 2 then do:
          for each tmp#grp :
            run grplib-get-full-name in this-procedure( input tmp#grp.node-code, output v-curr-grp-name ) .
            for each buf_gds-obj no-lock
              where buf_gds-obj.obj-type = buf_obj-list.obj-type
                and buf_gds-obj.obj-code = buf_obj-list.obj-code
                and buf_gds-obj.grp-name begins v-curr-grp-name
              use-index obj-grp :
              run fill-tt in this-procedure .
            end .
          end.
        end.
        otherwise do:
          for each gds-list ,
              each buf_gds-obj no-lock
            where buf_gds-obj.obj-type  = buf_obj-list.obj-type
              and buf_gds-obj.obj-code  = buf_obj-list.obj-code
              and buf_gds-obj.artic     = gds-list.artic
              and buf_gds-obj.prod-type = gds-list.prod-type
              and buf_gds-obj.prod-code = gds-list.prod-code
            :
            run fill-tt in this-procedure .
          end.
        end.
      end case.
    end.
    run waitfram-hide in this-procedure .
  end.
end procedure.
procedure fill-tt :
  do  on error undo, return error return-value :
    find first tt-goods no-lock
      where tt-goods.prod-type = buf_gds-obj.prod-type
        and tt-goods.prod-code = buf_gds-obj.prod-code
        and tt-goods.artic     = buf_gds-obj.artic
    no-error.
    find first buf_goods where buf_goods.gds-code = buf_gds-obj.gds-code.
    v-upper-code = buf_goods.grp-code.
    v-value = "".
    do while v-upper-code > 0 and v-p-accsup = "yes" and p-batch > 0 :
        find first buf_gds-grp where buf_gds-grp.node-code = v-upper-code.
        run ggoattr-value(
          input buf_gds-grp.node-code,
          input 0,
          input "",
          input 0,
          input 'no-inc-auto-rep':U,
          output v-value,
          output v-type
        ).
        if v-value = "yes" then
          leave.
        else
          v-upper-code = buf_gds-grp.upper-code.
    end.
    if not available tt-goods and v-value <> "yes" then do:
      create tt-goods.
      assign
        v-gds-counter      = v-gds-counter + 1
        tt-goods.prod-type = buf_gds-obj.prod-type
        tt-goods.prod-code = buf_gds-obj.prod-code
        tt-goods.artic     = buf_gds-obj.artic
        tt-goods.gds-code  = buf_gds-obj.gds-code
      .
    end.
  end.
end procedure.
procedure create-report :
  define variable var-x-store-code    like ub.clients.obj-code    no-undo.
  define variable var-x-store-type    like ub.clients.obj-type    no-undo.
  define variable var-x-date-start    like ub.stk-tot.Fact-date   no-undo.
  define variable var-x-date-endt     like ub.stk-tot.Fact-date   no-undo.
  define variable var-x-sum-type      like ub.stk-tot.sum-type    no-undo.
  define variable var-x-ost-sum-type  like ub.stk-tot.sum-type    no-undo.
  define variable var-x-cat-id        like ub.stk-tot.cat-id      no-undo.
  define variable var-xTog-obj        as   log                 no-undo.
  define variable var-Quantity        like ub.stk-tot.fact-qnty   initial ? no-undo.
  define variable var-Coast_R         like ub.stk-tot.sum-rubl    no-undo.
  define variable var-Coast_V         like ub.stk-tot.sum-rubl    no-undo.
  define variable var-VAT_R           like ub.stk-tot.sum-rubl    no-undo.
  define variable var-VAT_V           like ub.stk-tot.sum-rubl    no-undo.
  define variable var-Fact-order      like ub.stk-tot.Fact-order  no-undo.
  define variable var-x-artic         like ub.stk-line.artic      no-undo.
  define variable var-x-prod-code     like ub.stk-line.prod-code  no-undo.
  define variable var-x-prod-type     like ub.stk-line.prod-type  no-undo.
  define variable var-SLT_R           like ub.stk-tot.sum-rubl    no-undo.
  define variable var-SLT_V           like ub.stk-tot.sum-rubl    no-undo.
  define variable v-ost-gds-1         as decimal   no-undo .
  define variable v-ost-tara-1        as decimal   no-undo .
  define variable v-ost-gds-2         as decimal   no-undo .
  define variable v-ost-tara-2        as decimal   no-undo .
  define variable v-ost-qnty          as decimal   no-undo .
  define variable v-counter           as integer   no-undo .
  define variable v-prg               as class ProgressBar no-undo .
  define variable v-none-sym-1        as character no-undo .
  define variable v-none-sym-2        as character no-undo .
  define buffer buf_tax-rate-gds for ub.tax-rate-gds.
do
on error undo, return error return-value
:
  run create-tt-goods in this-procedure .
  empty temp-table tt-report.
  case x-SET_PAY_TYPE :
    when 2 then do:
      assign
        var-x-sum-type      = 'cost':U
        var-x-ost-sum-type  = 'cost':U
      .
    end.
    when 1 then do:
      assign
        var-x-sum-type      = 'crsa':U
        var-x-ost-sum-type  = 'crsa':U
      .
    end.
    when 3 then do:
      assign
        var-x-sum-type      = 'sale':U
        var-x-ost-sum-type  = 'crsa':U
      .
    end.
    otherwise do:
      assign
        var-x-sum-type      = 'cost':U
        var-x-ost-sum-type  = 'cost':U
      .
    end.
  end case.
  var-x-cat-id      = '##,##':U.
  for each buf_obj-list :
    if v-obj-code = -1 then do:
      assign
      v-obj-type = buf_obj-list.obj-type
      v-obj-code = buf_obj-list.obj-code.
    end.
    else do:
      assign
      v-obj-type = ''
      v-obj-code = 0
      .
    end.
    v-prg = new ProgressBar( 1 , v-gds-counter ).
    assign
      v-prg:frame-title = buf_obj-list.obj-name
      v-prg:fg-color = 9
    .
    v-prg:show-bar().
    if x-TOG-Shift then do:
      run ostatok in this-procedure (
        input buf_obj-list.obj-code
       ,input buf_obj-list.obj-type
       ,input x-TOG-Shift
       ,input x-date-start - 1
       ,input date('')
       ,input x-Shift-Start
       ,input x-Shift-End
       ,input var-x-ost-sum-type
       ,input var-x-cat-id
       ,input true
       ,output  var-Quantity
       ,output  var-Coast_R
       ,output  var-Coast_V
       ,output  var-VAT_R
       ,output  var-VAT_V
       ,output  v-fact-order-1 ).
       run ostatok in this-procedure (
        input buf_obj-list.obj-code
       ,input buf_obj-list.obj-type
       ,input x-TOG-Shift
       ,input x-date-start
       ,input x-date-end
       ,input x-Shift-Start
       ,input x-Shift-End
       ,input var-x-ost-sum-type
       ,input var-x-cat-id
       ,input true
       ,output  var-Quantity
       ,output  var-Coast_R
       ,output  var-Coast_V
       ,output  var-VAT_R
       ,output  var-VAT_V
       ,output v-Fact-order-2 ).
    end.
    if p-break-by-cp  then do:
    run break-by-cp-prep in this-procedure ( input buf_obj-list.obj-type
                                       ,input buf_obj-list.obj-code
                                       ,input v-fact-order-1
                                       ,input v-fact-order-2
                                       ) .
    end.
    _goods-loop:
    for each tt-goods :
      v-prg:increment().
       if p-tax-rate-list > '' then do:
          find last buf_tax-rate-gds no-lock
              where buf_tax-rate-gds.tax-code  = integer('1':U)
                and buf_tax-rate-gds.gds-code  = tt-goods.gds-code
                and buf_tax-rate-gds.host-code  = 0
                and buf_tax-rate-gds.obj-type  = ''
                and buf_tax-rate-gds.obj-code  = 0
                and buf_tax-rate-gds.fact-order <= v-fact-order-1 no-error.
          if not available buf_tax-rate-gds then do:
            next _goods-loop.
          end.
          if lookup(string(buf_tax-rate-gds.rate-code), p-tax-rate-list) = 0
          then do:
            next _goods-loop.
          end.
        end.
      assign
        var-x-store-code  = buf_obj-list.obj-code
        var-x-store-type  = buf_obj-list.obj-type
        var-x-artic       = tt-goods.artic
        var-x-prod-code   = tt-goods.prod-code
        var-x-prod-type   = tt-goods.prod-type
        var-x-cat-id      = '##,##':U
        var-xTog-obj      = yes
        v-counter         = v-counter + 1
      .
      RUN ost-line in this-procedure (
          input   var-x-store-code    ,
          input   var-x-store-type    ,
          input   var-x-artic         ,
          input   var-x-prod-code     ,
          input   var-x-prod-type     ,
          input   X-tog-shift         ,
          input   v-fact-order-1      ,
          input   var-x-ost-sum-type  ,
          input   var-x-cat-id        ,
          input   var-xTog-obj        ,
          output  var-Quantity        ,
          output  var-Coast_R         ,
          output  var-Coast_V         ,
          output  var-VAT_R           ,
          output  var-VAT_V           ,
          output  var-SLT_R           ,
          output  var-SLT_V          ) .
      assign  v-ost-gds-1 = v-ost-gds-1 +
                           ( if v-print-rubl = yes
                           then (var-Coast_R  - (if p-without-vat
                                                 then var-VAT_R
                                                 else 0)
                                )
                           else (var-Coast_V  - (if p-without-vat
                                                then var-VAT_V
                                                else 0)
                                )
                           )  .
      RUN ost-line in this-procedure (
          input   var-x-store-code    ,
          input   var-x-store-type    ,
          input   var-x-artic         ,
          input   var-x-prod-code     ,
          input   var-x-prod-type     ,
          input   X-tog-shift         ,
          input   v-fact-order-2      ,
          input   var-x-ost-sum-type  ,
          input   var-x-cat-id        ,
          input   var-xTog-obj        ,
          output  var-Quantity        ,
          output  var-Coast_R         ,
          output  var-Coast_V         ,
          output  var-VAT_R           ,
          output  var-VAT_V           ,
          output  var-SLT_R           ,
          output  var-SLT_V          ) .
      assign  v-ost-gds-2 = v-ost-gds-2 +
                           ( if v-print-rubl = yes
                           then (var-Coast_R  - (if p-without-vat
                                                 then var-VAT_R
                                                 else 0)
                                )
                           else (var-Coast_V  - (if p-without-vat
                                                then var-VAT_V
                                                else 0)
                                )
                           )  .
      _ot-line:
      for each buf_ot-line no-lock
          where buf_ot-line.obj-type     = buf_obj-list.obj-type
            and buf_ot-line.obj-code     = buf_obj-list.obj-code
            and buf_ot-line.artic        = tt-goods.artic
            and buf_ot-line.prod-type    = tt-goods.prod-type
            and buf_ot-line.prod-code    = tt-goods.prod-code
            and buf_ot-line.fact-order   >= v-fact-order-1
            and buf_ot-line.fact-order   <= v-fact-order-2
            and buf_ot-line.sum-type     = var-x-sum-type
      :
        if buf_ot-line.ext-doc-type <>  'ot':U then do:
        find first buf_trn-doc no-lock  where buf_trn-doc.doc-code = buf_ot-line.doc-code  no-error .
        if available buf_trn-doc then do:
           find first buf2_obj-list no-lock
            where buf2_obj-list.obj-type = buf_trn-doc.cli-type
              and buf2_obj-list.obj-code = buf_trn-doc.cli-code
           no-error .
           if available buf2_obj-list then do:
            next _ot-line.
           end.
        end.
        end.
        case buf_ot-line.ext-doc-type :
          when 'ie':U           or
          when 'iv':U           or
          when 'rv':U       or
          when 'im':U
          then do:
            if x-SET_PAY_TYPE = 3 then do:
              next _ot-line.
            end.
            run fill-tt-rep ( input tt-goods.gds-code, input "inc":U) .
          end.
          when 're':U       or
          when 'rs':U
          then do:
            run fill-tt-rep ( input tt-goods.gds-code, input "inc":U) .
          end.
          when 'ee':U           or
          when 'es':U      or
          when 'ep':U        or
          when 'we':U           or
          when 'ev':U           or
          when 'em':U            or
          when 'wm':U
          then do:
            run fill-tt-rep ( input tt-goods.gds-code, input "out":U) .
          end.
          when 'vt':U               or
          when 'vp':U          or
          when 'ot':U          or
          when 'ap':U    or
          when 'mp':U
          then do:
            if x-SET_PAY_TYPE = 3 then next _ot-line.
            run fill-tt-rep (
                               input tt-goods.gds-code
                              ,input if ( buf_ot-line.sum-base > 0 or buf_ot-line.sum-rubl > 0 )
                                    then "inc":U
                                     else "out":U) .
          end.
          otherwise do:
            next _ot-line.
          end.
        end case.
        assign
          tt-report.doc-sum       = tt-report.doc-sum + abs( if v-print-rubl = yes
                                                             then (buf_ot-line.sum-rubl  - (if p-without-vat
                                                                                            then buf_ot-line.vat-rubl
                                                                                            else 0)
                                                                  )
                                                             else (buf_ot-line.sum-base   - (if p-without-vat
                                                                                            then buf_ot-line.vat-base
                                                                                            else 0)
                                                                   )
                                                             )
          v-counter               = v-counter + 1
         .
      end.
      if x-SET_PAY_TYPE = 3 then do:
        _ot-line-sale :
        for each buf_ot-line no-lock
            where buf_ot-line.obj-type     = buf_obj-list.obj-type
              and buf_ot-line.obj-code     = buf_obj-list.obj-code
              and buf_ot-line.artic        = tt-goods.artic
              and buf_ot-line.prod-type    = tt-goods.prod-type
              and buf_ot-line.prod-code    = tt-goods.prod-code
              and buf_ot-line.fact-order   >= v-fact-order-1
              and buf_ot-line.fact-order   <= v-fact-order-2
              and buf_ot-line.sum-type     = 'crsa':U
        :
          case buf_ot-line.ext-doc-type :
            when 'ie':U           or
            when 'iv':U           or
            when 'rv':U       or
            when 'im':U
            then do:
              run fill-tt-rep ( input tt-goods.gds-code
                               ,input "inc":U) .
            end.
            when 'vt':U               or
            when 'vp':U          or
            when 'ot':U          or
            when 'ap':U    or
            when 'mp':U
            then do:
              run fill-tt-rep (  input tt-goods.gds-code
                                ,input if ( buf_ot-line.sum-base > 0 or buf_ot-line.sum-rubl > 0 )
                                      then "inc":U
                                      else "out":U) .
            end.
            otherwise do:
              next _ot-line-sale.
            end.
          end case.
          assign
            tt-report.doc-sum       = tt-report.doc-sum + abs( if v-print-rubl = yes
                                                               then (buf_ot-line.sum-rubl - (if p-without-vat
                                                                                             then buf_ot-line.vat-rubl
                                                                                             else 0)
                                                                    )
                                                               else (buf_ot-line.sum-base  - (if p-without-vat
                                                                                             then buf_ot-line.vat-base
                                                                                             else 0)
                                                                     )
                                                                 )
            v-counter               = v-counter + 1
          .
        end.
      end.
    end.
    create tt-report-object.
    assign
      tt-report-object.obj-type       = buf_obj-list.obj-type
      tt-report-object.obj-code       = buf_obj-list.obj-code
      tt-report-object.ost-gds-sum-1  = v-ost-gds-1
      tt-report-object.ost-gds-sum-2  = v-ost-gds-2
      v-ost-gds-1                     = 0
      v-ost-gds-2                     = 0
    .
    v-prg:hide-bar().
    delete object v-prg.
    assign
        v-prg = ?
    .
  end.
  for each tt-report :
    if tt-report.doc-sum = 0 and tt-report.tara-sum = 0 then delete tt-report.
  end.
  for each tt-ignore-docs,
      each tt-report where
      tt-report.doc-code = tt-ignore-docs.doc-code :
  delete tt-report.
  end.
end.
end procedure.
procedure fill-tt-rep :
  do on error undo, return error return-value :
    define input parameter p-gds-code as integer no-undo .
    define input  parameter p-type as character no-undo .
    DEFINE VARIABLE v-attr-type     as character no-undo .
    DEFINE VARIABLE v-attr-value    as character no-undo .
    define variable v-doc-date          as date      no-undo .
    define variable v-vat-pc            as decimal   no-undo.
    define buffer goods_temp-cp for temp-cp.
    define buffer doc_temp-cp for temp-cp.
    define buffer buf_trn-doc for ub.trn-doc.
    find first tt-report where
             tt-report.doc-code = buf_ot-line.doc-code
         and tt-report.ext-doc-type = p-type no-error .
    if not available tt-report then do:
      run factord-to-date in this-procedure ( input buf_ot-line.fact-order , output v-doc-date ) .
      if buf_ot-line.ext-doc-type <> 'ot':U then do:
        find first buf_trn-doc where
                buf_trn-doc.doc-code = buf_ot-line.doc-code no-error.
      end.
      if available buf_trn-doc
      and buf_trn-doc.ext-doc-type = 'we':U
      and (buf_trn-doc.out-code <> ?
           and
           buf_trn-doc.out-code <> '') then do:
        if p-no-covered-techrfsl then run  process-covered-techrfsl ( buffer buf_trn-doc) no-error.
      end.
      create tt-report.
      assign
        tt-report.doc-code      = buf_ot-line.doc-code
        tt-report.fact-order    = buf_ot-line.fact-order
        tt-report.fact-date     = v-doc-date
        tt-report.ext-doc-type  = p-type
        tt-report.real-ext-doc-type  = buf_ot-line.ext-doc-type
      tt-report.break-ext-doc-type  = (if p-ext-doc-type-subtotals
                                       then  tt-report.real-ext-doc-type
                                       else '').
      if tt-report.real-ext-doc-type = 'ie':U then do:
                run gbl/trdcat-v.p   ( input tt-report.doc-code
                           , input 'nids':U
                           , output v-attr-value
                           , output v-attr-type
                           ) NO-ERROR .
        if v-attr-value <> "" then tt-report.num-ship = v-attr-value. else tt-report.num-ship = tt-report.doc-code .
      end.
      if tt-report.real-ext-doc-type <> 'ie':U then do:
                run gbl/trdcat-v.p   ( input tt-report.doc-code
                           , input 'print-num':U
                           , output v-attr-value
                           , output v-attr-type
                           ) NO-ERROR .
        if v-attr-value <> "" then tt-report.num-ship = v-attr-value. else tt-report.num-ship = tt-report.doc-code .
      end.
      tt-report.cli-name      = (if available buf_trn-doc
                                 then buf_trn-doc.cli-name
                                 else (if buf_ot-line.ext-doc-type = 'ot':U
                                       then "(Переоценка)"
                                       else "")
                                 )
      .
    end.
    if p-break-by-cp
    and (buf_ot-line.ext-doc-type = 'es':U
         or
         buf_ot-line.ext-doc-type = 'rs':U)
    then do:
      for each  goods_temp-cp where
                goods_temp-cp.gds-code = p-gds-code
            and goods_temp-cp.doc-code = buf_ot-line.doc-code :
         find first doc_temp-cp where
                    doc_temp-cp.gds-code = 0
                and doc_temp-cp.doc-code = buf_ot-line.doc-code
                and doc_temp-cp.cdpay-code = goods_temp-cp.cdpay-code
                and doc_temp-cp.curr-code = goods_temp-cp.curr-code no-error.
         if not available doc_temp-cp then do:
           create doc_temp-cp.
           assign
           doc_temp-cp.gds-code = 0
           doc_temp-cp.doc-code = buf_ot-line.doc-code
           doc_temp-cp.cdpay-code = goods_temp-cp.cdpay-code
           doc_temp-cp.curr-code = goods_temp-cp.curr-code
           .
         end.
         assign
         doc_temp-cp.eff-doc-qnty = doc_temp-cp.eff-doc-qnty  + goods_temp-cp.eff-doc-qnty
         doc_temp-cp.tot-rb = doc_temp-cp.tot-rb + goods_temp-cp.tot-rb
         .
         if x-SET_PAY_TYPE = 3 then do:
             if not p-without-vat then do:
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  goods_temp-cp.gds-code
  ,input  '1':U
  ,input  buf_trn-doc.fact-date
  ,input  buf_trn-doc.host-code
  ,input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,output v-vat-pc
  ) no-error .
             end.
             doc_temp-cp.sum = doc_temp-cp.sum  + goods_temp-cp.tot-rb - (if p-without-vat then (goods_temp-cp.tot-rb * v-vat-pc / (100 + v-vat-pc)) else 0).
         end.
         else do:
         doc_temp-cp.sum = doc_temp-cp.sum +
                           goods_temp-cp.eff-doc-qnty * abs(if v-print-rubl = yes
                                                            then (buf_ot-line.sum-rubl - (if p-without-vat
                                                                                          then buf_ot-line.vat-rubl
                                                                                          else 0)
                                                                 )
                                                            else (buf_ot-line.sum-base  - (if p-without-vat
                                                                                          then buf_ot-line.vat-base
                                                                                          else 0)
                                                                 )
                                                            ) / if buf_ot-line.fact-qnty <> 0 then abs(buf_ot-line.fact-qnty) else 1.
         end.
         release doc_temp-cp.
      end.
    end.
  end.
end procedure.
procedure print-report :
  define variable v-total-gds         as decimal   no-undo .
  define variable v-total-tara        as decimal   no-undo .
  define variable v-ost-gds-1         as decimal   no-undo .
  define variable v-ost-tara-1        as decimal   no-undo .
  define variable v-ost-gds-2         as decimal   no-undo .
  define variable v-ost-tara-2        as decimal   no-undo .
  define variable v-itog-s-ost-gds    as decimal   no-undo .
  define variable v-itog-s-ost-tara   as decimal   no-undo .
  define variable v-avt-ovt-gds       as decimal   no-undo .
  define variable v-avt-ovt-tara      as decimal   no-undo .
  define variable v-ii                as integer no-undo .
  define variable v-ext-doc-type-doc-sum as decimal no-undo .
  define variable v-ext-doc-type-tara-sum as decimal no-undo .
  define buffer buf_cash-pay for ub.cash-pay.
  define buffer doc_temp-cp for temp-cp.
do
on error undo, return error return-value
:
  view stream out-stream frame BottomFrame .
  run print-header-list-1 in this-procedure .
  for each tt-report-object :
    assign
      v-ost-gds-1   = v-ost-gds-1  + tt-report-object.ost-gds-sum-1
      v-ost-tara-1  = v-ost-tara-1 + tt-report-object.ost-tara-sum-1
      v-ost-gds-2   = v-ost-gds-2  + tt-report-object.ost-gds-sum-2
      v-ost-tara-2  = v-ost-tara-2 + tt-report-object.ost-tara-sum-2
    .
  end.
    display stream out-stream
    sym7   substitute("Остаток на &1" , string(x-date-start, "99/99/9999"))   @ v-name
    sym2    p-fmt-align-string( "X" , 10 , "center")  @ tt-report.fact-date
    sym3    p-fmt-align-string( "X" , 25 , "center")  @ tt-report.num-ship
      sym4   v-ost-gds-1  @ tt-report.doc-sum
      sym5   v-ost-tara-1 @ tt-report.tara-sum
    sym6
    sym1
    with frame torg29.
    down stream out-stream with frame torg29.
    display stream out-stream
     sym7   "Приход "  @ v-name
     sym2    p-fmt-align-string( "X" , 10 , "center") @ tt-report.fact-date
     sym3    p-fmt-align-string( "X" , 25 , "center") @ tt-report.num-ship
    sym4
    sym5
    sym6
    sym1
    with frame torg29.
    down stream out-stream with frame torg29.
    run torg29xl-sheet1-write-line-data ( input substitute("Остаток на &1" , w-date( x-Date-Start ))
                                        , input ""
                                        , input ""
                                        , input string( v-ost-gds-1  )
                                        , input string( v-ost-tara-1 )
                                        , input " ":U
                                        , input " ":U
                                        ) .
    run torg29xl-sheet1-write-line-data ( input "Приход"
                                        , input " ":U
                                        , input " ":U
                                        , input " ":U
                                        , input " ":U
                                        , input " ":U
                                        , input " ":U
                                        ) .
    for each tt-report where tt-report.ext-doc-type = "inc":U
    break
    by tt-report.break-ext-doc-type
    by tt-report.fact-order  :
      if first-of(tt-report.break-ext-doc-type)
      and p-ext-doc-type-subtotals
      then do:
        assign
        v-ext-doc-type-doc-sum = 0
        v-ext-doc-type-tara-sum = 0
        .
        display stream out-stream
        sym7
        func-get-name-from-ext-type( tt-report.real-ext-doc-type, no) @ v-name
        sym2
        sym3
        sym4
        sym5
        sym6
        sym1
        with frame torg29.
        down stream out-stream with frame torg29.
        run torg29xl-sheet1-write-line-data ( input func-get-name-from-ext-type( tt-report.real-ext-doc-type, no)
                                            , input ""
                                            , input ""
                                            , input ""
                                            , input ""
                                            , input ""
                                            , input ""
                                            ) .
      end.
      display stream out-stream
      sym7
      tt-report.cli-name @ v-name
      sym2        tt-report.fact-date
      sym3        tt-report.num-ship
      sym4        tt-report.doc-sum
      sym5        tt-report.tara-sum
      sym6        tt-report.buh-1
      sym1
      with frame torg29.
      down stream out-stream with frame torg29.
      run torg29xl-sheet1-write-line-data ( input tt-report.cli-name
                                          , input tt-report.fact-date
                                          , input tt-report.num-ship
                                          , input string(tt-report.doc-sum)
                                          , input string(tt-report.tara-sum)
                                          , input tt-report.buh-1
                                          , input ""
                                          ) .
      assign
        v-total-gds  = v-total-gds  + tt-report.doc-sum
        v-total-tara = v-total-tara + tt-report.tara-sum
      v-ext-doc-type-doc-sum = v-ext-doc-type-doc-sum + tt-report.doc-sum
      v-ext-doc-type-tara-sum = v-ext-doc-type-tara-sum + tt-report.tara-sum
      .
      if p-break-by-cp
      and tt-report.real-ext-doc-type = 'rs':U then do:
        display stream out-stream
       sym7
       "В т.ч.по типам касс.плат." @ v-name
        sym3
        sym2
        sym4
        sym5
        sym6
        sym1
        with frame torg29.
        down stream out-stream with frame torg29.
        v-ii = 0.
        run torg29xl-sheet1-write-line-data ( input "В т.ч.по типам касс.плат."
                                            , input ""
                                            , input ""
                                            , input ""
                                            , input ""
                                            , input ""
                                            , input ""
                                            ) .
        for each doc_temp-cp where
                doc_temp-cp.doc-code = tt-report.doc-code
            and doc_temp-cp.gds-code = 0,
            first buf_cash-pay no-lock where
                  buf_cash-pay.cdpay-code = doc_temp-cp.cdpay-code
              and buf_cash-pay.curr-code = doc_temp-cp.curr-code:
          v-ii = v-ii + 1.
          display stream out-stream
          sym7 shiftright(buf_cash-pay.obj-name, 25)  @ v-name
          sym3
          sym2
          sym4 (- doc_temp-cp.sum)   @ tt-report.doc-sum
          sym5
          sym6
          sym1
          with frame torg29.
          down stream out-stream with frame torg29.
          run torg29xl-sheet1-write-line-data ( input shiftright(buf_cash-pay.obj-name, 25)
                                              , input ""
                                              , input ""
                                              , input string(doc_temp-cp.sum)
                                              , input ""
                                              , input ""
                                              , input ""
                                              ) .
        end.
      end.
      if last-of(tt-report.break-ext-doc-type)
      and p-ext-doc-type-subtotals
      then do:
        display stream out-stream
        sym7
        substitute("ИТОГО &1", func-get-name-from-ext-type( tt-report.real-ext-doc-type, no)) @ v-name
        sym2    p-fmt-align-string( "X" , 10 , "center")  @ tt-report.fact-date
        sym3    p-fmt-align-string( "X" , 25 , "center")  @ tt-report.num-ship
        sym4 v-ext-doc-type-doc-sum   @ tt-report.doc-sum
        sym5 v-ext-doc-type-tara-sum  @ tt-report.tara-sum
        sym6
        sym1
        with frame torg29.
        down stream out-stream with frame torg29.
        run torg29xl-sheet1-write-line-data ( input substitute("ИТОГО &1", func-get-name-from-ext-type( tt-report.real-ext-doc-type, no))
                                            , input "X"
                                            , input "X"
                                            , input string(v-ext-doc-type-doc-sum)
                                            , input string(v-ext-doc-type-tara-sum)
                                            , input ""
                                            , input ""
                                            ) .
      end.
    end.
    put stream out-stream v-line format "X(130)" skip.
    display stream out-stream
      sym7
      "Итого по приходу"  @ v-name
     sym2    p-fmt-align-string( "X" , 10 , "center") @ tt-report.fact-date
     sym3    p-fmt-align-string( "X" , 25 , "center") @ tt-report.num-ship
      sym4     v-total-gds @ tt-report.doc-sum
      sym5     v-total-tara @ tt-report.tara-sum
      sym6
      sym1
    with frame torg29.
    down stream out-stream with frame torg29.
    put stream out-stream v-line format "X(130)" skip.
    run torg29xl-write-cell-data in this-procedure ( input "f_incomegds":U  , input string(v-total-gds)  ).
    run torg29xl-write-cell-data in this-procedure ( input "f_incometara":U , input string(v-total-tara) ).
    assign
      v-itog-s-ost-gds  = (v-ost-gds-1 + v-total-gds)
      v-itog-s-ost-tara = (v-ost-tara-1 + v-total-tara)
    .
    display stream out-stream
      sym7
      "Итого с остатком" @ v-name
     sym2    p-fmt-align-string( "X" , 10 , "center") @ tt-report.fact-date
     sym3    p-fmt-align-string( "X" , 25 , "center") @ tt-report.num-ship
      sym4   v-itog-s-ost-gds @ tt-report.doc-sum
      sym5   v-itog-s-ost-tara @ tt-report.tara-sum
      sym6    sym1
    with frame torg29.
    down stream out-stream with frame torg29.
    put stream out-stream v-line format "X(130)" skip.
    run torg29xl-write-cell-data in this-procedure ( input "f_incostgds":U  , input string(v-itog-s-ost-gds)  ).
    run torg29xl-write-cell-data in this-procedure ( input "f_incosttara":U , input string(v-itog-s-ost-tara) ).
  hide stream out-stream frame BottomFrame .
  page stream out-stream.
  view stream out-stream frame BottomFrame .
  run print-header-list-2 in this-procedure .
    display stream out-stream
    sym7
    "Расход" @ v-name
     sym2    p-fmt-align-string( "X" , 10 , "center") @ tt-report.fact-date
     sym3    p-fmt-align-string( "X" , 25 , "center") @ tt-report.num-ship
    sym4
    sym5
    sym6
    sym1
    with frame torg29.
    down stream out-stream with frame torg29.
    run torg29xl-sheet2-write-line-data ( input "Расход":U
                                        , input " ":U
                                        , input " ":U
                                        , input " ":U
                                        , input " ":U
                                        , input " ":U
                                        , input " ":U
                                        ) .
    assign
      v-total-gds  = 0
      v-total-tara = 0
    .
    for each tt-report  where
    tt-report.ext-doc-type = "out":U
    break
    by tt-report.break-ext-doc-type
    by tt-report.fact-order
     :
      if first-of(tt-report.break-ext-doc-type)
      and p-ext-doc-type-subtotals
      then do:
        assign
        v-ext-doc-type-doc-sum = 0
        v-ext-doc-type-tara-sum = 0
        .
        display stream out-stream
        sym7
        func-get-name-from-ext-type( tt-report.real-ext-doc-type, no) @ v-name
        sym2
        sym3
        sym4
        sym5
        sym6
        with frame torg29.
        down stream out-stream with frame torg29.
        run torg29xl-sheet2-write-line-data ( input func-get-name-from-ext-type( tt-report.real-ext-doc-type, no)
                                            , input ""
                                            , input ""
                                            , input ""
                                            , input ""
                                            , input ""
                                            , input ""
                                            ) .
      end.
      display stream out-stream
      sym7        tt-report.cli-name @ v-name
      sym2        tt-report.fact-date
      sym3        tt-report.num-ship
      sym4        tt-report.doc-sum
      sym5        tt-report.tara-sum
      sym6        tt-report.buh-1
      sym1
      with frame torg29.
      down stream out-stream with frame torg29.
      run torg29xl-sheet2-write-line-data ( input tt-report.cli-name
                                          , input tt-report.fact-date
                                          , input tt-report.num-ship
                                          , input string(tt-report.doc-sum)
                                          , input string(tt-report.tara-sum)
                                          , input tt-report.buh-1
                                          , input ""
                                          ) .
      assign
        v-total-gds  = v-total-gds  + tt-report.doc-sum
        v-total-tara = v-total-tara + tt-report.tara-sum
      v-ext-doc-type-doc-sum = v-ext-doc-type-doc-sum + tt-report.doc-sum
      v-ext-doc-type-tara-sum = v-ext-doc-type-tara-sum + tt-report.tara-sum
      .
      if p-break-by-cp
      and tt-report.real-ext-doc-type = 'es':U then do:
        display stream out-stream
        sym7 "В т.ч.по типам касс.плат." @ v-name
        sym3
        sym2
        sym4
        sym5
        sym6
        sym1
        with frame torg29.
        down stream out-stream with frame torg29.
        run torg29xl-sheet2-write-line-data ( input "В т.ч.по типам касс.плат."
                                            , input ""
                                            , input ""
                                            , input ""
                                            , input ""
                                            , input ""
                                            , input ""
                                            ) .
        v-ii = 0.
        for each doc_temp-cp where
                doc_temp-cp.doc-code = tt-report.doc-code
            and doc_temp-cp.gds-code = 0,
            first buf_cash-pay no-lock where
                  buf_cash-pay.cdpay-code = doc_temp-cp.cdpay-code
              and buf_cash-pay.curr-code = doc_temp-cp.curr-code:
          v-ii = v-ii + 1.
          display stream out-stream
          sym7 shiftright(buf_cash-pay.obj-name, 25) @ v-name
          sym3
          sym2
          sym4 doc_temp-cp.sum   @ tt-report.doc-sum
          sym5
          sym6
          sym1
          with frame torg29.
          down stream out-stream with frame torg29.
          run torg29xl-sheet2-write-line-data ( input shiftright(buf_cash-pay.obj-name, 25)
                                              , input ""
                                              , input ""
                                              , input string(doc_temp-cp.sum)
                                              , input ""
                                              , input ""
                                              , input ""
                                              ) .
        end.
      end.
      if last-of(tt-report.break-ext-doc-type)
      and p-ext-doc-type-subtotals
      then do:
        display stream out-stream
        sym7
        substitute("ИТОГО &1", func-get-name-from-ext-type( tt-report.real-ext-doc-type, no)) @ v-name
        sym2    p-fmt-align-string( "X" , 10 , "center")  @ tt-report.fact-date
        sym3    p-fmt-align-string( "X" , 25 , "center")  @ tt-report.num-ship
        sym4 v-ext-doc-type-doc-sum  @ tt-report.doc-sum
        sym5 v-ext-doc-type-tara-sum @ tt-report.tara-sum
        sym6
        sym1
        with frame torg29.
        down stream out-stream with frame torg29.
        run torg29xl-sheet2-write-line-data ( input substitute("ИТОГО &1", func-get-name-from-ext-type( tt-report.real-ext-doc-type, no))
                                            , input "X"
                                            , input "X"
                                            , input string(v-ext-doc-type-doc-sum)
                                            , input string(v-ext-doc-type-tara-sum)
                                            , input ""
                                            , input ""
                                            ) .
      end.
    end.
    if x-SET_PAY_TYPE = 3 then do:
      assign
        v-avt-ovt-gds       = v-itog-s-ost-gds  - (v-total-gds + v-ost-gds-2)
        v-avt-ovt-tara      = v-itog-s-ost-tara - (v-total-tara + v-ost-tara-2)
      .
    end.
    else do:
      assign
        v-avt-ovt-gds       = 0
        v-avt-ovt-tara      = 0
      .
    end.
    assign
      v-total-gds         = v-total-gds  + v-avt-ovt-gds
      v-total-tara        = v-total-tara + v-avt-ovt-tara
    .
    if x-SET_PAY_TYPE = 3 and ( v-avt-ovt-gds <> 0 or v-avt-ovt-tara <> 0 ) then do:
      put stream out-stream v-line format "X(130)" skip.
      display stream out-stream
      sym7 "Автоматическая переоценка" @ v-name
     sym2    p-fmt-align-string( "X" , 10 , "center") @ tt-report.fact-date
     sym3    p-fmt-align-string( "X" , 25 , "center") @ tt-report.num-ship
        sym4   v-avt-ovt-gds @ tt-report.doc-sum
        sym5   v-avt-ovt-tara @ tt-report.tara-sum
      sym6
      sym1
      with frame torg29.
      down stream out-stream with frame torg29.
      run torg29xl-sheet2-write-line-data ( input "Автоматическая переоценка":U
                                          , input ""
                                          , input ""
                                          , input string(v-avt-ovt-gds)
                                          , input string(v-avt-ovt-tara)
                                          , input ""
                                          , input ""
                                          ) .
    end.
    put stream out-stream v-line format "X(130)" skip.
    display stream out-stream
    sym7 "Итого по расходу" @ v-name
    sym2    p-fmt-align-string( "X" , 10 , "center") @ tt-report.fact-date
    sym3    p-fmt-align-string( "X" , 25 , "center") @ tt-report.num-ship
      sym4     v-total-gds @ tt-report.doc-sum
      sym5     v-total-tara @ tt-report.tara-sum
    sym6
    sym1
    with frame torg29.
    down stream out-stream with frame torg29.
    put stream out-stream v-line format "X(130)" skip.
    display stream out-stream
    sym7   substitute("Остаток на &1" , string(x-date-end, "99/99/9999"))   @ v-name
    sym2    p-fmt-align-string( "X" , 10 , "center")  @ tt-report.fact-date
    sym3    p-fmt-align-string( "X" , 25 , "center")  @ tt-report.num-ship
      sym4      v-ost-gds-2   @ tt-report.doc-sum
      sym5      v-ost-tara-2  @ tt-report.tara-sum
    sym6
    sym1
    with frame torg29.
    down stream out-stream with frame torg29.
    put stream out-stream v-line format "X(130)" skip(2).
    run torg29xl-write-cell-data in this-procedure ( input "f_expgds":U       , input string(v-total-gds)  ).
    run torg29xl-write-cell-data in this-procedure ( input "f_exptara":U      , input string(v-total-tara) ).
    run torg29xl-write-cell-data in this-procedure ( input "f_expostdateend":U, input substitute("Остаток на &1 " , w-date(x-Date-End) )  ).
    run torg29xl-write-cell-data in this-procedure ( input "f_expostgds":U    , input string(v-ost-gds-2)  ).
    run torg29xl-write-cell-data in this-procedure ( input "f_exposttara":U   , input string(v-ost-tara-2) ).
  run print-footer-list-2 in this-procedure .
  hide stream out-stream frame BottomFrame .
end.
end procedure.
function w-date returns character ( input p-date as date ) .
do
on error undo, return error
:
  define variable month-str as character init "января;февраля;марта;апреля;мая;июня;июля;августа;сентября;октября;ноября;декабря":U no-undo.
  return ( string( DAY( p-date ) ) + " " + entry( month( p-date ) , month-str , ";" ) + " " + string( year( p-date ) ) + " г." ).
end.
end function.
procedure break-by-cp-prep :
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-fact-order-1 as decimal no-undo .
define input parameter p-fact-order-2 as decimal no-undo .
define buffer buf_ot-tot for ub.ot-tot.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_temp-inkas for temp-inkas.
define buffer buf_goods for ub.goods.
define buffer buf_temp-cp for temp-cp.
define buffer buf_chk-gds-pay for ub.chk-gds-pay.
define buffer buf_bar-code for ub.bar-code.
if p-obj-type = 'скл':U then return.
for each buf_ot-tot no-lock where
        buf_ot-tot.obj-type = p-obj-type
    and buf_ot-tot.obj-code = p-obj-code
    and buf_ot-tot.fact-order >= p-fact-order-1
    and buf_ot-tot.fact-order <= p-fact-order-2:
  case buf_ot-tot.ext-doc-type:
    when  'es':U then do:
      find first buf_temp-inkas no-lock where
                buf_temp-inkas.inkas-code = buf_ot-tot.doc-code no-error.
      if not available buf_temp-inkas then do:
        run rep/rpychk0.p ( input "r-trg29d"
                            ,input p-obj-type
                            ,input p-obj-code
                            ,input ?
                            ,input ?
                            ,input ?
                            ,input ?
                            ,input ?
                            ,input ?
                            ,input buf_ot-tot.doc-code
                            ) no-error.
        create buf_temp-inkas.
        assign
        buf_temp-inkas.inkas-code = buf_ot-tot.doc-code
        buf_temp-inkas.ras-doc-code = buf_ot-tot.doc-code
        buf_temp-inkas.obj-type = p-obj-type
        buf_temp-inkas.obj-code = p-obj-code
        .
      end.
    end.
    when 'rs':U   then do:
      find first buf_trn-doc no-lock where
               buf_trn-doc.doc-code = buf_ot-tot.doc-code no-error.
      if available buf_trn-doc then do:
        find first buf_temp-inkas no-lock where
                  buf_temp-inkas.inkas-code = buf_trn-doc.out-code
             no-error.
        if not available buf_temp-inkas then do:
          run rep/rpychk0.p ( input "r-trg29d"
                              ,input p-obj-type
                              ,input p-obj-code
                              ,input ?
                              ,input ?
                              ,input ?
                              ,input ?
                              ,input ?
                              ,input ?
                              ,input buf_ot-tot.doc-code
                              ) no-error.
          create buf_temp-inkas.
          assign
          buf_temp-inkas.inkas-code = buf_trn-doc.out-code
          buf_temp-inkas.ras-doc-code = buf_trn-doc.out-code
          buf_temp-inkas.ret-doc-code = buf_ot-tot.doc-code
          buf_temp-inkas.obj-type = p-obj-type
          buf_temp-inkas.obj-code = p-obj-code
          .
        end.
        else do:
          assign
          buf_temp-inkas.ret-doc-code = buf_ot-tot.doc-code
          .
        end.
      end.
    end.
  end case.
end.
define variable v-exp as logical   no-undo .
define variable v-inc as logical   no-undo .
for each buf_temp-inkas where
       buf_temp-inkas.obj-type = p-obj-type
   and buf_temp-inkas.obj-code = p-obj-code
 break
 by buf_temp-inkas.inkas-code:
  if first-of(buf_temp-inkas.inkas-code) then do:
    for each buf_chk-gds-pay no-lock where
        buf_chk-gds-pay.out-code = buf_temp-inkas.inkas-code,
    first buf_bar-code no-lock where
          buf_bar-code.b-code = buf_chk-gds-pay.b-code :
      if buf_chk-gds-pay.algo-num <> "1.8" then next.
      if num-entries(buf_chk-gds-pay.line-type, chr(4)) > 1 then do:
        if entry(2, buf_chk-gds-pay.line-type, chr(4)) = 'es':U then do:
          assign
          v-exp = yes
          v-inc = no
          .
        end.
        if entry(2, buf_chk-gds-pay.line-type, chr(4)) = 'rs':U then do:
          assign
          v-exp = no
          v-inc = yes
          .
        end.
      end.
      else do:
        define buffer buf_chk-doc for ub.chk-doc.
        find first buf_chk-doc no-lock where
        buf_chk-doc.doc-code = buf_chk-gds-pay.doc-code .
        assign
        v-exp = lookup(string(buf_chk-doc.chk-type), '1,69,14,15,16,36':U) > 0
        v-inc = lookup(string(buf_chk-doc.chk-type), '6,96':U) > 0
        .
      end.
      if v-exp then do:
    find first buf_temp-cp where
              buf_temp-cp.doc-code = buf_temp-inkas.ras-doc-code
          and buf_temp-cp.gds-code = buf_bar-code.gds-code
          and buf_temp-cp.cdpay-code = buf_chk-gds-pay.pay-code
          and buf_temp-cp.curr-code = buf_chk-gds-pay.curr-code no-error.
    if not available buf_temp-cp then do:
      create buf_temp-cp.
      assign
      buf_temp-cp.doc-code = buf_temp-inkas.ras-doc-code
      buf_temp-cp.gds-code = buf_bar-code.gds-code
      buf_temp-cp.cdpay-code = buf_chk-gds-pay.pay-code
      buf_temp-cp.curr-code = buf_chk-gds-pay.curr-code
      .
    end .
        assign
          buf_temp-cp.eff-doc-qnty =  buf_temp-cp.eff-doc-qnty + buf_chk-gds-pay.eff-doc-qnty
          buf_temp-cp.tot-rb = buf_temp-cp.tot-rb + buf_chk-gds-pay.tot-r-b
        .
  end.
      if v-inc then do:
    find first buf_temp-cp where
                  buf_temp-cp.doc-code = buf_temp-inkas.ret-doc-code
          and buf_temp-cp.gds-code = buf_bar-code.gds-code
          and buf_temp-cp.cdpay-code = buf_chk-gds-pay.pay-code
          and buf_temp-cp.curr-code = buf_chk-gds-pay.curr-code no-error.
    if not available buf_temp-cp then do:
      create buf_temp-cp.
      assign
          buf_temp-cp.doc-code = buf_temp-inkas.ret-doc-code
      buf_temp-cp.gds-code = buf_bar-code.gds-code
      buf_temp-cp.cdpay-code = buf_chk-gds-pay.pay-code
      buf_temp-cp.curr-code = buf_chk-gds-pay.curr-code
      .
    end.
        assign
          buf_temp-cp.eff-doc-qnty =  buf_temp-cp.eff-doc-qnty + buf_chk-gds-pay.eff-doc-qnty
          buf_temp-cp.tot-rb = buf_temp-cp.tot-rb + buf_chk-gds-pay.tot-r-b
        .
end.
    end.
  end.
end.
end procedure.
procedure process-covered-techrfsl :
define parameter buffer buf_trn-doc for ub.trn-doc.
define variable v-covered as logical no-undo .
define variable v-doc-qnty as decimal no-undo .
define buffer buf2_trn-doc for ub.trn-doc.
define buffer buf_sale-doc for ub.sale-doc.
define buffer buf2_sale-doc for ub.sale-doc.
do
on error undo, return error
:
  def var v-value as character no-undo.
  def var v-type  as character no-undo.
  def var v-tech-pass as logical no-undo.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'techpass':U ,
                       output v-value ,
                       output v-type ) no-error .
  assign
    v-tech-pass = yes when v-value = "yes".
  find first buf_sale-doc no-lock where
            buf_sale-doc.doc-code = buf_trn-doc.doc-code
        and buf_sale-doc.doc-kind = 'trf':U no-error.
  if available buf_sale-doc then do:
    for each buf2_sale-doc no-lock where
            buf2_sale-doc.inkas-code = buf_sale-doc.inkas-code
        and buf2_sale-doc.doc-kind = 'itr':U ,
        first buf2_trn-doc no-lock where
              buf2_trn-doc.doc-code = buf2_sale-doc.doc-code:
      assign
      v-covered = (buf2_trn-doc.fact-qnty = buf2_trn-doc.doc-qnty) and v-covered
      v-doc-qnty = v-doc-qnty + buf2_trn-doc.fact-qnty
      .
    end.
    v-covered = (v-doc-qnty = buf_sale-doc.doc-qnty).
    if v-covered then do:
      for each buf2_sale-doc no-lock where
              buf2_sale-doc.inkas-code = buf_sale-doc.inkas-code
          and buf2_sale-doc.doc-kind = 'itr':U:
        create tt-ignore-docs.
        assign
        tt-ignore-docs.doc-code = buf2_sale-doc.doc-code.
        release tt-ignore-docs.
      end.
      create tt-ignore-docs.
      assign
      tt-ignore-docs.doc-code = buf_trn-doc.doc-code.
    end.
  end.
end.
end procedure.
