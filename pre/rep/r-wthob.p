block-level on error undo, throw.
define temp-table temp_goods no-undo
    field gds-code  as integer
    field gds-name  as character
    index pi is primary unique
        gds-code
.
define temp-table temp_wthPar no-undo
    field par-code   as integer
    index pi is primary unique
        par-code
.
define temp-table temp_hideCol no-undo
    field colName   as character
    index pi is primary unique
        colName
.
define stream out-stream.
define input parameter p-begin-date         as date             no-undo.
define input parameter p-end-date           as date             no-undo.
define input parameter p-begin-shift        as integer          no-undo.
define input parameter p-end-shift          as integer          no-undo.
define input parameter p-obj-selection-type as character        no-undo.
define input parameter p-ext-doc-type-list  as character        no-undo.
define input parameter p-detal              as logical          no-undo.
define input parameter p-ob-liter           as logical          no-undo.
define input parameter p-ob-rubl            as logical          no-undo.
define input parameter p-ob-tal             as logical          no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-wthob.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-wthob.p $":U .
define variable vss-description as character no-undo init "Отчёт Оборотная ведомость по матценностям".
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
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_shiftfo_fo-range no-undo
    field frn-key           as integer
    field obj-type          as character
    field obj-code          as integer
    field fact-order-from   as decimal
    field fact-order-to     as decimal
    field date-from         as date
    field date-to           as date
    field shift-from        as integer
    field shift-to          as integer
    index pi is primary unique
        frn-key
.
define temp-table temp_shiftfo_obj-list no-undo
    field obj-type  as character
    field obj-code  as integer
    index pi is primary unique
        obj-type
        obj-code
.
define variable v-shiftfo15-frn-key     as integer      no-undo.
procedure fill-temp_shiftfo_fo-range :
define input parameter p-mode               as integer          no-undo.
define input parameter p-date-beg           as date             no-undo.
define input parameter p-date-end           as date             no-undo.
define input parameter p-shift-num-beg      as integer          no-undo.
define input parameter p-shift-num-end      as integer          no-undo.
define input parameter p-shift-num-alone    as integer          no-undo.
define output parameter p-date-string       as character        no-undo.
define output parameter p-date-from-string  as character        no-undo.
define output parameter p-date-to-string    as character        no-undo.
    define variable v-fact-order-beg    as decimal      no-undo.
    define variable v-fact-order-end    as decimal      no-undo.
    define variable v-date-from         as date         no-undo.
    define variable v-date-to           as date         no-undo.
    define variable v-shift-from        as integer      no-undo.
    define variable v-shift-to          as integer      no-undo.
    define variable v-docs-exists       as logical      no-undo.
    define variable v-max-fact-order    as decimal      no-undo.
    define variable v-shift-obj-on      as logical      no-undo.
    define buffer buf_temp_shiftfo_fo-range     for temp_shiftfo_fo-range.
    define buffer buf_obj-list                  for temp_shiftfo_obj-list.
    define buffer buf_shift-obj                 for ub.shift-obj.
    define buffer buf_prev_shift-obj            for ub.shift-obj.
do
for buf_temp_shiftfo_fo-range
  , buf_obj-list
  , buf_shift-obj
  , buf_prev_shift-obj
on error undo, return error
:
    empty temp-table buf_temp_shiftfo_fo-range.
    assign
        v-shiftfo15-frn-key = 0
    .
    case p-mode
    :
        when 1
        then do:
            run day-begin-fact-order in this-procedure (
                  input p-date-beg
                , output v-fact-order-beg
            ).
            run factord-end-day in this-procedure (
                  input p-date-end
                , output v-fact-order-end
            ).
            for each buf_obj-list
            :
                    assign
                        v-shiftfo15-frn-key = v-shiftfo15-frn-key + 1
                    .
                    create buf_temp_shiftfo_fo-range.
                    assign
                        buf_temp_shiftfo_fo-range.frn-key           = v-shiftfo15-frn-key
                        buf_temp_shiftfo_fo-range.obj-type          = buf_obj-list.obj-type
                        buf_temp_shiftfo_fo-range.obj-code          = buf_obj-list.obj-code
                        buf_temp_shiftfo_fo-range.fact-order-from   = v-fact-order-beg
                        buf_temp_shiftfo_fo-range.fact-order-to     = v-fact-order-end
                        buf_temp_shiftfo_fo-range.date-from         = p-date-beg
                        buf_temp_shiftfo_fo-range.date-to           = p-date-end
                        buf_temp_shiftfo_fo-range.shift-from        = 0
                        buf_temp_shiftfo_fo-range.shift-to          = 0
                    .
                    assign
                        p-date-string       = substitute( "Диапазон дат: с &1 по &2", p-date-beg, p-date-end )
                        p-date-from-string  = substitute( "&1", p-date-beg )
                        p-date-to-string    = substitute( "&1", p-date-end   )
                    .
            end.
        end.
        when 2
        then do:
            define variable v-is-first    as logical      no-undo.
            for each buf_obj-list
            :
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  buf_obj-list.obj-type
  ,input  buf_obj-list.obj-code
  ,input  'shift-on=request'
  ,output v-shift-obj-on
  ) no-error .
                if v-shift-obj-on = yes
                then do:
                    assign
                        v-is-first          = yes
                        v-fact-order-beg    = 0
                        v-fact-order-end    = 0
                        v-shift-from        = 0
                        v-shift-to          = 0
                        v-date-from         = ?
                        v-date-to           = ?
                    .
                    for each buf_shift-obj no-lock
                    where buf_shift-obj.obj-type = buf_obj-list.obj-type
                        and buf_shift-obj.obj-code = buf_obj-list.obj-code
                        and buf_shift-obj.status_  = 'зкр':U
                        and buf_shift-obj.shift-date >= p-date-beg
                        and buf_shift-obj.shift-date <= p-date-end
                    by buf_shift-obj.shift-date
                    by buf_shift-obj.shift-num
                    on error undo, return error
                    :
                        if v-is-first = yes
                        then do:
                            find last buf_prev_shift-obj
                                where buf_prev_shift-obj.obj-type = buf_obj-list.obj-type
                                and buf_prev_shift-obj.obj-code = buf_obj-list.obj-code
                                and buf_prev_shift-obj.fact-order < buf_shift-obj.fact-order
                            no-error.
                            if available buf_prev_shift-obj
                            then do:
                                assign
                                    v-fact-order-beg   = buf_prev_shift-obj.fact-order
                                    v-date-from        = buf_shift-obj.shift-date
                                    v-shift-from       = buf_shift-obj.shift-num
                                .
                            end.
                            assign
                                v-is-first          = no
                            .
                        end.
                        assign
                            v-fact-order-end = buf_shift-obj.fact-order
                            v-date-to        = buf_shift-obj.shift-date
                            v-shift-to       = buf_shift-obj.shift-num
                        .
                    end.
                    if v-fact-order-end <> 0
                    and v-fact-order-end >= v-fact-order-beg
                    then do:
                        assign
                            v-shiftfo15-frn-key = v-shiftfo15-frn-key + 1
                        .
                        create buf_temp_shiftfo_fo-range.
                        assign
                            buf_temp_shiftfo_fo-range.frn-key           = v-shiftfo15-frn-key
                            buf_temp_shiftfo_fo-range.obj-type          = buf_obj-list.obj-type
                            buf_temp_shiftfo_fo-range.obj-code          = buf_obj-list.obj-code
                            buf_temp_shiftfo_fo-range.fact-order-from   = v-fact-order-beg
                            buf_temp_shiftfo_fo-range.fact-order-to     = v-fact-order-end
                            buf_temp_shiftfo_fo-range.date-from         = p-date-beg
                            buf_temp_shiftfo_fo-range.date-to           = p-date-end
                            buf_temp_shiftfo_fo-range.shift-from        = 0
                            buf_temp_shiftfo_fo-range.shift-to          = 0
                        .
                    end.
                end.
            end.
            assign
                p-date-string = substitute( "Сменные сутки: с &1 по &2", p-date-beg, p-date-end )
                p-date-from-string  = substitute( "&1 (сменные сутки)", p-date-beg )
                p-date-to-string    = substitute( "&1 (сменные сутки)", p-date-end   )
            .
        end.
        when 3
        then do:
            for each buf_obj-list
            :
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  buf_obj-list.obj-type
  ,input  buf_obj-list.obj-code
  ,input  'shift-on=request'
  ,output v-shift-obj-on
  ) no-error .
                if v-shift-obj-on = yes
                then do:
                    assign
                        v-fact-order-beg    = 0
                        v-shift-from        = 0
                        v-date-from         = ?
                        v-fact-order-end    = 0
                        v-shift-to          = 0
                        v-date-to           = ?
                    .
                    find first buf_shift-obj no-lock
                        where buf_shift-obj.obj-type = buf_obj-list.obj-type
                        and buf_shift-obj.obj-code = buf_obj-list.obj-code
                        and buf_shift-obj.status_  = 'зкр':U
                        and buf_shift-obj.shift-date = p-date-beg
                        and buf_shift-obj.shift-num >= p-shift-num-beg
                    use-index stts
                    no-error.
                    if not available buf_shift-obj
                    then do:
                        find first buf_shift-obj no-lock
                            where buf_shift-obj.obj-type = buf_obj-list.obj-type
                            and buf_shift-obj.obj-code = buf_obj-list.obj-code
                            and buf_shift-obj.status_  = 'зкр':U
                            and buf_shift-obj.shift-date > p-date-beg
                        use-index stts
                        no-error.
                    end.
                    if not available buf_shift-obj
                    then do:
                        assign
                            v-fact-order-beg    = 0
                            v-date-from         = 01/01/1900
                            v-shift-from        = 1
                        .
                    end.
                    else do:
                        assign
                            v-fact-order-beg    = buf_shift-obj.fact-order
                            v-date-from         = buf_shift-obj.shift-date
                            v-shift-from        = buf_shift-obj.shift-num
                        .
                        find first buf_shift-obj no-lock
                            where buf_shift-obj.obj-type = buf_obj-list.obj-type
                            and buf_shift-obj.obj-code = buf_obj-list.obj-code
                            and buf_shift-obj.status_  = 'зкр':U
                            and buf_shift-obj.shift-date = p-date-end
                            and buf_shift-obj.shift-num  > p-shift-num-end
                        use-index stts
                        no-error.
                        if not available buf_shift-obj
                        then do:
                            find first buf_shift-obj no-lock
                                where buf_shift-obj.obj-type = buf_obj-list.obj-type
                                and buf_shift-obj.obj-code = buf_obj-list.obj-code
                                and buf_shift-obj.status_  = 'зкр':U
                                and buf_shift-obj.shift-date > p-date-end
                            use-index stts
                            no-error.
                        end.
                        if not available buf_shift-obj
                        then do:
                            assign
                                v-max-fact-order = integer( 01/01/9999 ) * 10.0
                            .
                            assign
                                v-fact-order-end    = v-max-fact-order
                                v-date-to           = 01/01/9999
                                v-shift-to          = 24
                            .
                        end.
                        else do:
                            assign
                                v-fact-order-end    = buf_shift-obj.fact-order
                                v-date-to           = buf_shift-obj.shift-date
                                v-shift-to          = buf_shift-obj.shift-num
                            .
                        end.
                        assign
                            v-shiftfo15-frn-key = v-shiftfo15-frn-key + 1
                        .
                        create buf_temp_shiftfo_fo-range.
                        assign
                            buf_temp_shiftfo_fo-range.frn-key           = v-shiftfo15-frn-key
                            buf_temp_shiftfo_fo-range.obj-type          = buf_obj-list.obj-type
                            buf_temp_shiftfo_fo-range.obj-code          = buf_obj-list.obj-code
                            buf_temp_shiftfo_fo-range.fact-order-from   = v-fact-order-beg
                            buf_temp_shiftfo_fo-range.fact-order-to     = v-fact-order-end
                            buf_temp_shiftfo_fo-range.date-from         = v-date-from
                            buf_temp_shiftfo_fo-range.date-to           = v-date-to
                            buf_temp_shiftfo_fo-range.shift-from        = v-shift-from
                            buf_temp_shiftfo_fo-range.shift-to          = v-shift-to
                        .
                    end.
                end.
            end.
            assign
                p-date-string = substitute( "Сменные сутки и порядок: со смены &1 (&2) по смену &3 (&4)"
                    , p-shift-num-beg
                    , p-date-beg
                    , p-shift-num-end
                    , p-date-end )
                p-date-from-string  = substitute( "смена &1 (&2, сменные сутки и порядок)", p-shift-num-beg, p-date-beg )
                p-date-to-string    = substitute( "смена &1 (&2, сменные сутки и порядок)", p-shift-num-end  , p-date-end   )
            .
        end.
        when 4
        then do:
            for each buf_obj-list
            :
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  buf_obj-list.obj-type
  ,input  buf_obj-list.obj-code
  ,input  'shift-on=request'
  ,output v-shift-obj-on
  ) no-error .
                if v-shift-obj-on = yes
                then do:
                    for each buf_shift-obj no-lock
                    where buf_shift-obj.obj-type     = buf_obj-list.obj-type
                        and buf_shift-obj.obj-code     = buf_obj-list.obj-code
                        and buf_shift-obj.status_      = 'зкр':U
                        and buf_shift-obj.shift-date   >= p-date-beg
                        and buf_shift-obj.shift-date   <= p-date-end
                    use-index stts
                    on error undo, return error
                    :
                        if buf_shift-obj.shift-num = p-shift-num-alone
                        then do:
                            run rep/getfosht.p (
                                input buf_obj-list.obj-type
                                , input buf_obj-list.obj-code
                                , input buf_shift-obj.shift-date
                                , input buf_shift-obj.shift-num
                                , output v-fact-order-beg
                                , output v-fact-order-end
                                , output v-docs-exists
                            ).
                            assign
                                v-shiftfo15-frn-key = v-shiftfo15-frn-key + 1
                            .
                            create buf_temp_shiftfo_fo-range.
                            assign
                                buf_temp_shiftfo_fo-range.frn-key           = v-shiftfo15-frn-key
                                buf_temp_shiftfo_fo-range.obj-type          = buf_obj-list.obj-type
                                buf_temp_shiftfo_fo-range.obj-code          = buf_obj-list.obj-code
                                buf_temp_shiftfo_fo-range.fact-order-from   = v-fact-order-beg
                                buf_temp_shiftfo_fo-range.fact-order-to     = v-fact-order-end
                                buf_temp_shiftfo_fo-range.date-from         = buf_shift-obj.shift-date
                                buf_temp_shiftfo_fo-range.date-to           = buf_shift-obj.shift-date
                                buf_temp_shiftfo_fo-range.shift-from        = buf_shift-obj.shift-num
                                buf_temp_shiftfo_fo-range.shift-to          = buf_shift-obj.shift-num
                            .
                        end.
                    end.
                end.
            end.
            assign
                p-date-string = substitute( "По смене: смена &1, с &2 по &3"
                                        , p-shift-num-alone
                                        , p-date-beg
                                        , p-date-end )
                p-date-from-string  = substitute( "смена &1 (&2, по смене)", p-shift-num-alone, p-date-beg )
                p-date-to-string    = substitute( "смена &1 (&2, по смене)", p-shift-num-alone, p-date-end   )
            .
        end.
    end case.
end.
end procedure.
define variable g#report-num              as integer              no-undo .
run get-report-num in my-handle (output g#report-num).
define variable vss-include-info19 as character format "X(65)" no-undo
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
    field obj-type      as character
    field obj-code      as integer
    field wth-code      as integer
    field par-code      as integer
    field goodsName     as character
    field wthPar        as character
    field stkRealSt     as decimal
    field stkPOffSt     as decimal
    field stkRealLt     as decimal
    field stkPOffLt     as decimal
    field stkRealRb     as decimal
    field stkPOffRb     as decimal
    index pi is primary unique
        xl-line-id
.
define temp-table temp_sheet3_line-data no-undo
    field sheet-name    as character
    field xl-line-id    as integer
    field obj-type      as character
    field obj-code      as integer
    field wth-code      as integer
    field par-code      as integer
    field goodsName     as character
    field wthPar        as character
    field stkRealSt     as decimal
    field stkPOffSt     as decimal
    field stkRealLt     as decimal
    field stkPOffLt     as decimal
    field stkRealRb     as decimal
    field stkPOffRb     as decimal
    index pi is primary unique
        xl-line-id
.
define temp-table temp_sheet2_line-data no-undo
    field sheet-name      as character
    field xl-line-id      as integer
    field obj-type        as character
    field obj-code        as integer
    field wth-code        as integer
    field par-code        as integer
    field goodsName       as character
    field wthPar          as character
    field incIncmSt       as decimal
    field incIncmLt       as decimal
    field incRetnSt       as decimal
    field incRetnLt       as decimal
    field outSaleSt       as decimal
    field outSaleLt       as decimal
    field outSaleRb       as decimal
    field outExchSt       as decimal
    field outExchLt       as decimal
    field outExchRb       as decimal
    field payPaydDeskSt   as decimal
    field payPaydDeskLt   as decimal
    field payPaydDeskRb   as decimal
    field payPaydSt       as decimal
    field payPaydLt       as decimal
    field payPaydRb       as decimal
    field payExchSt       as decimal
    field payExchLt       as decimal
    field payExchRb       as decimal
    field payRetnSt       as decimal
    field payRetnLt       as decimal
    field payRetnRb       as decimal
    field clrRealSt       as decimal
    field clrRealLt       as decimal
    field clrRealRb       as decimal
    field clrPOffSt       as decimal
    field clrPOffLt       as decimal
    field clrPOffRb       as decimal
    field trsRealExpsSt   as decimal
    field trsRealExpsLt   as decimal
    field trsRealIncmSt   as decimal
    field trsRealIncmLt   as decimal
    field trsRealTrnsSt   as decimal
    field trsRealTrnsLt   as decimal
    field trsPOffExpsSt   as decimal
    field trsPOffExpsLt   as decimal
    field trsPOffExpsRb   as decimal
    field trsPOffIncmSt   as decimal
    field trsPOffIncmLt   as decimal
    field trsPOffIncmRb   as decimal
    field trsPOffTrnsSt   as decimal
    field trsPOffTrnsLt   as decimal
    field trsPOffTrnsRb   as decimal
    field total-code      as integer
    index pi is primary unique
        xl-line-id
    index basepi
        total-code
        obj-type
        obj-code
        wth-code
        par-code
.
define variable v-rwthobxl-sheet1-cur-data-row     as integer      no-undo.
define variable v-rwthobxl-sheet2-cur-data-row     as integer      no-undo.
define variable v-rwthobxl-sheet3-cur-data-row     as integer      no-undo.
define variable v-rwthobxl-cell-file-name       as character    no-undo.
define variable v-rwthobxl-data-file-name       as character    no-undo.
procedure rwthobxl-init :
do
on error undo, return error
:
    assign
        v-rwthobxl-sheet1-cur-data-row = 0
        v-rwthobxl-sheet2-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-rwthobxl-data-file-name
    ).
    output stream excel-line to value( v-rwthobxl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-rwthobxl-cell-file-name
    ).
    output stream excel-cell to value( v-rwthobxl-cell-file-name ).
    run rwthobxl-write-cell-data in this-procedure (
          input "sheetList":U
        , input "НачалоПериода,Обороты,КонецПериода":U
    ).
    if printrubl
    then do:
        run rwthobxl-write-cell-data in this-procedure (
              input "НачалоПериода_valutCode":U
            , input "0":U
        ).
        run rwthobxl-write-cell-data in this-procedure (
              input "Обороты_valutCode":U
            , input "0":U
        ).
        run rwthobxl-write-cell-data in this-procedure (
              input "КонецПериода_valutCode":U
            , input "0":U
        ).
    end.
    else do:
        run rwthobxl-write-cell-data in this-procedure (
              input "НачалоПериода_valutCode":U
            , input "1":U
        ).
        run rwthobxl-write-cell-data in this-procedure (
              input "Обороты_valutCode":U
            , input "1":U
        ).
        run rwthobxl-write-cell-data in this-procedure (
              input "КонецПериода_valutCode":U
            , input "1":U
        ).
    end.
    run rwthobxl-write-cell-data in this-procedure (
          input "НачалоПериода_columnList":U
        , input "goodsName,wthPar,stkRealSt,stkPOffSt,stkRealLt,stkPOffLt":U
    ).
    run rwthobxl-write-cell-data in this-procedure (
          input "НачалоПериода_columnType":U
        , input "S,S,D,D,D,D":U
    ).
    run rwthobxl-write-cell-data in this-procedure (
          input "НачалоПериода_subtotalList":U
        , input "":U
    ).
    run rwthobxl-write-cell-data in this-procedure (
          input "НачалоПериода_subtotalType":U
        , input "":U
    ).
    run rwthobxl-write-cell-data in this-procedure (
          input "КонецПериода_columnList":U
        , input "goodsName,wthPar,stkRealSt,stkPOffSt,stkRealLt,stkPOffLt":U
    ).
    run rwthobxl-write-cell-data in this-procedure (
          input "КонецПериода_columnType":U
        , input "S,S,D,D,D,D":U
    ).
    run rwthobxl-write-cell-data in this-procedure (
          input "КонецПериода_subtotalList":U
        , input "":U
    ).
    run rwthobxl-write-cell-data in this-procedure (
          input "КонецПериода_subtotalType":U
        , input "":U
    ).
    run rwthobxl-write-cell-data in this-procedure (
          input "Обороты_columnList":U
        , input "goodsName,wthPar,incIncmSt,incIncmLt,incRetnSt,incRetnLt,outSaleSt,outSaleLt,outSaleRb,outExchSt,outExchLt,outExchRb,payPaydDeskSt,payPaydDeskLt,payPaydDeskRb,payPaydSt,payPaydLt,payPaydRb,payExchSt,payExchLt,payExchRb,payRetnSt,payRetnLt,payRetnRb,clrRealSt,clrRealLt,clrRealRb,clrPOffSt,clrPOffLt,clrPOffRb,trsRealExpsSt,trsRealExpsLt,trsRealIncmSt,trsRealIncmLt,trsRealTrnsSt,trsRealTrnsLt,trsPOffExpsSt,trsPOffExpsLt,trsPOffExpsRb,trsPOffIncmSt,trsPOffIncmLt,trsPOffIncmRb,trsPOffTrnsSt,trsPOffTrnsLt,trsPOffTrnsRb":U
    ).
    run rwthobxl-write-cell-data in this-procedure (
          input "Обороты_columnType":U
        , input "S,S,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D":U
    ).
    run rwthobxl-write-cell-data in this-procedure (
          input "Обороты_subtotalList":U
        , input "":U
    ).
    run rwthobxl-write-cell-data in this-procedure (
          input "Обороты_subtotalType":U
        , input "":U
    ).
end.
end procedure.
procedure rwthobxl-sheet1-add-line-data :
define input parameter p-obj-type       as character        no-undo.
define input parameter p-obj-code       as integer          no-undo.
define input parameter p-wth-code       as integer          no-undo.
define input parameter p-par-code       as integer          no-undo.
define input parameter p-ext-doc-type   as character        no-undo.
define input parameter p-sum-type       as character        no-undo.
define input parameter p-stkSt          as decimal          no-undo.
define input parameter p-stkLt          as decimal          no-undo.
define input parameter p-stkRb          as decimal          no-undo.
    define variable v-gds-name    as character    no-undo.
    define buffer buf_temp_sheet1_line-data        for temp_sheet1_line-data.
    define buffer buf_wth-par       for ub.wth-par.
    define buffer buf_wealth        for ub.wealth.
do
for buf_temp_sheet1_line-data
  , buf_wth-par
  , buf_wealth
on error undo, return error
:
    find first buf_temp_sheet1_line-data
         where buf_temp_sheet1_line-data.obj-type   = p-obj-type
           and buf_temp_sheet1_line-data.obj-code   = p-obj-code
           and buf_temp_sheet1_line-data.wth-code   = p-wth-code
           and buf_temp_sheet1_line-data.par-code   = p-par-code
    no-error.
    if not available buf_temp_sheet1_line-data
    then do:
        find first buf_wealth no-lock
             where buf_wealth.wth-code = p-wth-code
        .
        assign
            v-gds-name = buf_wealth.wth-name
        .
        find first buf_wth-par no-lock
             where buf_wth-par.par-code = p-par-code
        no-error.
        create buf_temp_sheet1_line-data.
        assign
            v-rwthobxl-sheet1-cur-data-row          = v-rwthobxl-sheet1-cur-data-row + 1
            buf_temp_sheet1_line-data.sheet-name    = "НачалоПериода":U
            buf_temp_sheet1_line-data.xl-line-id    = v-rwthobxl-sheet1-cur-data-row
            buf_temp_sheet1_line-data.obj-type      = p-obj-type
            buf_temp_sheet1_line-data.obj-code      = p-obj-code
            buf_temp_sheet1_line-data.wth-code      = p-wth-code
            buf_temp_sheet1_line-data.par-code      = p-par-code
            buf_temp_sheet1_line-data.goodsName     = v-gds-name
            buf_temp_sheet1_line-data.wthPar        = ( if available buf_wth-par then string( buf_wth-par.par-val ) else "":U )
        .
        assign
            buf_temp_sheet1_line-data.stkRealSt     = 0.0
            buf_temp_sheet1_line-data.stkPOffSt     = 0.0
            buf_temp_sheet1_line-data.stkRealLt     = 0.0
            buf_temp_sheet1_line-data.stkPOffLt     = 0.0
            buf_temp_sheet1_line-data.stkRealRb     = 0.0
            buf_temp_sheet1_line-data.stkPOffRb     = 0.0
        .
    end.
    case p-ext-doc-type
    :
        when 'ie':U
        or when 'ff':U
        or when 'rf':U
        then do:
            assign
                buf_temp_sheet1_line-data.stkRealSt     = buf_temp_sheet1_line-data.stkRealSt  + p-stkSt
                buf_temp_sheet1_line-data.stkRealLt     = buf_temp_sheet1_line-data.stkRealLt  + p-stkLt
                buf_temp_sheet1_line-data.stkRealRb     = buf_temp_sheet1_line-data.stkRealRb  + p-stkRb
            .
        end.
        when 'ee':U
        or when 'df':U
        or when 'rf':U
        or when 'ef':U
        then do:
            assign
                buf_temp_sheet1_line-data.stkRealSt     = buf_temp_sheet1_line-data.stkRealSt  + p-stkSt
                buf_temp_sheet1_line-data.stkRealLt     = buf_temp_sheet1_line-data.stkRealLt  + p-stkLt
                buf_temp_sheet1_line-data.stkRealRb     = buf_temp_sheet1_line-data.stkRealRb  + p-stkRb
            .
        end.
        when 'ip':U
        or when 'rp':U
        or when 'pc':U
        or when 'ps':U
        or when 'pz':U
        then do:
            assign
                buf_temp_sheet1_line-data.stkPOffSt     = buf_temp_sheet1_line-data.stkPOffSt  + p-stkSt
                buf_temp_sheet1_line-data.stkPOffLt     = buf_temp_sheet1_line-data.stkPOffLt  + p-stkLt
                buf_temp_sheet1_line-data.stkPOffRb     = buf_temp_sheet1_line-data.stkPOffRb  + p-stkRb
            .
        end.
        when 'ep':U
        or when 'dp':U
        then do:
            assign
                buf_temp_sheet1_line-data.stkPOffSt     = buf_temp_sheet1_line-data.stkPOffSt  + p-stkSt
                buf_temp_sheet1_line-data.stkPOffLt     = buf_temp_sheet1_line-data.stkPOffLt  + p-stkLt
                buf_temp_sheet1_line-data.stkPOffRb     = buf_temp_sheet1_line-data.stkPOffRb  + p-stkRb
            .
        end.
        when 'xc':U
        then do:
            if p-sum-type = 'при':U
            then do:
                assign
                    buf_temp_sheet1_line-data.stkPOffSt     = buf_temp_sheet1_line-data.stkPOffSt  + p-stkSt
                    buf_temp_sheet1_line-data.stkPOffLt     = buf_temp_sheet1_line-data.stkPOffLt  + p-stkLt
                    buf_temp_sheet1_line-data.stkPOffRb     = buf_temp_sheet1_line-data.stkPOffRb  + p-stkRb
                .
            end.
            else do:
                assign
                    buf_temp_sheet1_line-data.stkRealSt     = buf_temp_sheet1_line-data.stkRealSt  + p-stkSt
                    buf_temp_sheet1_line-data.stkRealLt     = buf_temp_sheet1_line-data.stkRealLt  + p-stkLt
                    buf_temp_sheet1_line-data.stkRealRb     = buf_temp_sheet1_line-data.stkRealRb  + p-stkRb
                .
            end.
        end.
        otherwise do:
        end.
    end case.
end.
end procedure.
procedure rwthobxl-sheet1-write-line-data :
    define buffer buf_temp_sheet1_line-data        for temp_sheet1_line-data.
do
for buf_temp_sheet1_line-data
on error undo, return error
:
    for each buf_temp_sheet1_line-data
    break by buf_temp_sheet1_line-data.obj-type
          by buf_temp_sheet1_line-data.obj-code
          by buf_temp_sheet1_line-data.wth-code
          by buf_temp_sheet1_line-data.par-code
    :
        if first-of ( buf_temp_sheet1_line-data.obj-code )
        then do:
            put stream excel-line unformatted
                                buf_temp_sheet1_line-data.sheet-name
                CHR(9)   "DTA":U
                CHR(9)   substitute( "По объекту &1 &2", buf_temp_sheet1_line-data.obj-type, buf_temp_sheet1_line-data.obj-code )
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                chr(10)
            .
            run rwthobxl-sheet1-write-line-format in this-procedure (
                input "Объект":U
            ).
        end.
        put stream excel-line unformatted
                            buf_temp_sheet1_line-data.sheet-name
            CHR(9)   "DTA":U
            CHR(9)   buf_temp_sheet1_line-data.goodsName
            CHR(9)   buf_temp_sheet1_line-data.wthPar
            CHR(9)   string( buf_temp_sheet1_line-data.stkRealSt )
            CHR(9)   string( buf_temp_sheet1_line-data.stkPOffSt )
            CHR(9)   string( buf_temp_sheet1_line-data.stkRealLt )
            CHR(9)   string( buf_temp_sheet1_line-data.stkPOffLt )
            chr(10)
        .
    end.
end.
end procedure.
procedure rwthobxl-sheet3-add-line-data :
define input parameter p-obj-type       as character        no-undo.
define input parameter p-obj-code       as integer          no-undo.
define input parameter p-wth-code       as integer          no-undo.
define input parameter p-par-code       as integer          no-undo.
define input parameter p-ext-doc-type   as character        no-undo.
define input parameter p-sum-type       as character        no-undo.
define input parameter p-stkSt          as decimal          no-undo.
define input parameter p-stkLt          as decimal          no-undo.
define input parameter p-stkRb          as decimal          no-undo.
    define variable v-gds-name    as character    no-undo.
    define buffer buf_temp_sheet3_line-data        for temp_sheet3_line-data.
    define buffer buf_wth-par       for ub.wth-par.
    define buffer buf_wealth        for ub.wealth.
do
for buf_temp_sheet3_line-data
  , buf_wth-par
  , buf_wealth
on error undo, return error
:
    find first buf_temp_sheet3_line-data
         where buf_temp_sheet3_line-data.obj-type   = p-obj-type
           and buf_temp_sheet3_line-data.obj-code   = p-obj-code
           and buf_temp_sheet3_line-data.wth-code   = p-wth-code
           and buf_temp_sheet3_line-data.par-code   = p-par-code
    no-error.
    if not available buf_temp_sheet3_line-data
    then do:
        find first buf_wealth no-lock
             where buf_wealth.wth-code = p-wth-code
        .
        assign
            v-gds-name = buf_wealth.wth-name
        .
        find first buf_wth-par no-lock
             where buf_wth-par.par-code = p-par-code
        no-error.
        create buf_temp_sheet3_line-data.
        assign
            v-rwthobxl-sheet3-cur-data-row          = v-rwthobxl-sheet3-cur-data-row + 1
            buf_temp_sheet3_line-data.sheet-name    = "КонецПериода":U
            buf_temp_sheet3_line-data.xl-line-id    = v-rwthobxl-sheet3-cur-data-row
            buf_temp_sheet3_line-data.obj-type      = p-obj-type
            buf_temp_sheet3_line-data.obj-code      = p-obj-code
            buf_temp_sheet3_line-data.wth-code      = p-wth-code
            buf_temp_sheet3_line-data.par-code      = p-par-code
            buf_temp_sheet3_line-data.goodsName     = v-gds-name
            buf_temp_sheet3_line-data.wthPar        = ( if available buf_wth-par then string( buf_wth-par.par-val ) else "":U )
        .
        assign
            buf_temp_sheet3_line-data.stkRealSt     = 0.0
            buf_temp_sheet3_line-data.stkPOffSt     = 0.0
            buf_temp_sheet3_line-data.stkRealLt     = 0.0
            buf_temp_sheet3_line-data.stkPOffLt     = 0.0
            buf_temp_sheet3_line-data.stkRealRb     = 0.0
            buf_temp_sheet3_line-data.stkPOffRb     = 0.0
        .
    end.
    case p-ext-doc-type
    :
        when 'ie':U
        or when 'ff':U
        or when 'rf':U
        then do:
            assign
                buf_temp_sheet3_line-data.stkRealSt     = buf_temp_sheet3_line-data.stkRealSt  + p-stkSt
                buf_temp_sheet3_line-data.stkRealLt     = buf_temp_sheet3_line-data.stkRealLt  + p-stkLt
                buf_temp_sheet3_line-data.stkRealRb     = buf_temp_sheet3_line-data.stkRealRb  + p-stkRb
            .
        end.
        when 'ee':U
        or when 'df':U
        or when 'rf':U
        or when 'ef':U
        then do:
            assign
                buf_temp_sheet3_line-data.stkRealSt     = buf_temp_sheet3_line-data.stkRealSt  + p-stkSt
                buf_temp_sheet3_line-data.stkRealLt     = buf_temp_sheet3_line-data.stkRealLt  + p-stkLt
                buf_temp_sheet3_line-data.stkRealRb     = buf_temp_sheet3_line-data.stkRealRb  + p-stkRb
            .
        end.
        when 'ip':U
        or when 'rp':U
        or when 'pc':U
        or when 'ps':U
        or when 'pz':U
        then do:
            assign
                buf_temp_sheet3_line-data.stkPOffSt     = buf_temp_sheet3_line-data.stkPOffSt  + p-stkSt
                buf_temp_sheet3_line-data.stkPOffLt     = buf_temp_sheet3_line-data.stkPOffLt  + p-stkLt
                buf_temp_sheet3_line-data.stkPOffRb     = buf_temp_sheet3_line-data.stkPOffRb  + p-stkRb
            .
        end.
        when 'ep':U
        or when 'dp':U
        then do:
            assign
                buf_temp_sheet3_line-data.stkPOffSt     = buf_temp_sheet3_line-data.stkPOffSt  + p-stkSt
                buf_temp_sheet3_line-data.stkPOffLt     = buf_temp_sheet3_line-data.stkPOffLt  + p-stkLt
                buf_temp_sheet3_line-data.stkPOffRb     = buf_temp_sheet3_line-data.stkPOffRb  + p-stkRb
            .
        end.
        when 'xc':U
        then do:
            if p-sum-type = 'при':U
            then do:
                assign
                    buf_temp_sheet3_line-data.stkPOffSt     = buf_temp_sheet3_line-data.stkPOffSt  + p-stkSt
                    buf_temp_sheet3_line-data.stkPOffLt     = buf_temp_sheet3_line-data.stkPOffLt  + p-stkLt
                    buf_temp_sheet3_line-data.stkPOffRb     = buf_temp_sheet3_line-data.stkPOffRb  + p-stkRb
                .
            end.
            else do:
                assign
                    buf_temp_sheet3_line-data.stkRealSt     = buf_temp_sheet3_line-data.stkRealSt  + p-stkSt
                    buf_temp_sheet3_line-data.stkRealLt     = buf_temp_sheet3_line-data.stkRealLt  + p-stkLt
                    buf_temp_sheet3_line-data.stkRealRb     = buf_temp_sheet3_line-data.stkRealRb  + p-stkRb
                .
            end.
        end.
    end case.
end.
end procedure.
procedure rwthobxl-sheet3-write-line-data :
    define buffer buf_temp_sheet3_line-data        for temp_sheet3_line-data.
do
for buf_temp_sheet3_line-data
on error undo, return error
:
    for each buf_temp_sheet3_line-data
    break by buf_temp_sheet3_line-data.obj-type
          by buf_temp_sheet3_line-data.obj-code
          by buf_temp_sheet3_line-data.wth-code
          by buf_temp_sheet3_line-data.par-code
    :
        if first-of ( buf_temp_sheet3_line-data.obj-code )
        then do:
            put stream excel-line unformatted
                                buf_temp_sheet3_line-data.sheet-name
                CHR(9)   "DTA":U
                CHR(9)   substitute( "По объекту &1 &2", buf_temp_sheet3_line-data.obj-type, buf_temp_sheet3_line-data.obj-code )
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                chr(10)
            .
            run rwthobxl-sheet3-write-line-format in this-procedure (
                input "Объект":U
            ).
        end.
        put stream excel-line unformatted
                            buf_temp_sheet3_line-data.sheet-name
            CHR(9)   "DTA":U
            CHR(9)   buf_temp_sheet3_line-data.goodsName
            CHR(9)   buf_temp_sheet3_line-data.wthPar
            CHR(9)   string( buf_temp_sheet3_line-data.stkRealSt )
            CHR(9)   string( buf_temp_sheet3_line-data.stkPOffSt )
            CHR(9)   string( buf_temp_sheet3_line-data.stkRealLt )
            CHR(9)   string( buf_temp_sheet3_line-data.stkPOffLt )
            chr(10)
        .
    end.
end.
end procedure.
procedure rwthobxl-sheet2-add-line-data :
define input parameter p-obj-type       as character        no-undo.
define input parameter p-obj-code       as integer          no-undo.
define input parameter p-wth-code       as integer          no-undo.
define input parameter p-par-code       as integer          no-undo.
define input parameter p-incIncmSt      as decimal          no-undo.
define input parameter p-incIncmLt      as decimal          no-undo.
define input parameter p-incRetnSt      as decimal          no-undo.
define input parameter p-incRetnLt      as decimal          no-undo.
define input parameter p-outSaleSt      as decimal          no-undo.
define input parameter p-outSaleLt      as decimal          no-undo.
define input parameter p-outSaleRb      as decimal          no-undo.
define input parameter p-outExchSt      as decimal          no-undo.
define input parameter p-outExchLt      as decimal          no-undo.
define input parameter p-outExchRb      as decimal          no-undo.
define input parameter p-payPaydDeskSt  as decimal          no-undo.
define input parameter p-payPaydDeskLt  as decimal          no-undo.
define input parameter p-payPaydDeskRb  as decimal          no-undo.
define input parameter p-payPaydSt      as decimal          no-undo.
define input parameter p-payPaydLt      as decimal          no-undo.
define input parameter p-payPaydRb      as decimal          no-undo.
define input parameter p-payExchSt      as decimal          no-undo.
define input parameter p-payExchLt      as decimal          no-undo.
define input parameter p-payExchRb      as decimal          no-undo.
define input parameter p-payRetnSt      as decimal          no-undo.
define input parameter p-payRetnLt      as decimal          no-undo.
define input parameter p-payRetnRb      as decimal          no-undo.
define input parameter p-clrRealSt      as decimal          no-undo.
define input parameter p-clrRealLt      as decimal          no-undo.
define input parameter p-clrRealRb      as decimal          no-undo.
define input parameter p-clrPOffSt      as decimal          no-undo.
define input parameter p-clrPOffLt      as decimal          no-undo.
define input parameter p-clrPOffRb      as decimal          no-undo.
define input parameter p-trsRealExpsSt  as decimal          no-undo.
define input parameter p-trsRealExpsLt  as decimal          no-undo.
define input parameter p-trsRealIncmSt  as decimal          no-undo.
define input parameter p-trsRealIncmLt  as decimal          no-undo.
define input parameter p-trsRealTrnsSt  as decimal          no-undo.
define input parameter p-trsRealTrnsLt  as decimal          no-undo.
define input parameter p-trsPOffExpsSt  as decimal          no-undo.
define input parameter p-trsPOffExpsLt  as decimal          no-undo.
define input parameter p-trsPOffExpsRb  as decimal          no-undo.
define input parameter p-trsPOffIncmSt  as decimal          no-undo.
define input parameter p-trsPOffIncmLt  as decimal          no-undo.
define input parameter p-trsPOffIncmRb  as decimal          no-undo.
define input parameter p-trsPOffTrnsSt  as decimal          no-undo.
define input parameter p-trsPOffTrnsLt  as decimal          no-undo.
define input parameter p-trsPOffTrnsRb  as decimal          no-undo.
    define variable v-gds-name    as character    no-undo.
    define buffer buf_temp_sheet2_line-data        for temp_sheet2_line-data.
    define buffer buf_wth-par       for ub.wth-par.
    define buffer buf_wealth        for ub.wealth.
do
for buf_temp_sheet2_line-data
  , buf_wth-par
  , buf_wealth
on error undo, return error
:
    find first buf_temp_sheet2_line-data
         where buf_temp_sheet2_line-data.total-code = 0
           and buf_temp_sheet2_line-data.obj-type   = p-obj-type
           and buf_temp_sheet2_line-data.obj-code   = p-obj-code
           and buf_temp_sheet2_line-data.wth-code   = p-wth-code
           and buf_temp_sheet2_line-data.par-code   = p-par-code
         no-error
         .
    if not available buf_temp_sheet2_line-data
    then do:
        find first buf_wealth no-lock
             where buf_wealth.wth-code = p-wth-code
        .
        assign
            v-gds-name = buf_wealth.wth-name
        .
        find first buf_wth-par no-lock
             where buf_wth-par.par-code = p-par-code
        no-error.
        create buf_temp_sheet2_line-data.
        assign
            v-rwthobxl-sheet2-cur-data-row = v-rwthobxl-sheet2-cur-data-row + 1
        .
        assign
            buf_temp_sheet2_line-data.sheet-name      = "Обороты":U
            buf_temp_sheet2_line-data.xl-line-id      = v-rwthobxl-sheet2-cur-data-row
            buf_temp_sheet2_line-data.obj-type        = p-obj-type
            buf_temp_sheet2_line-data.obj-code        = p-obj-code
            buf_temp_sheet2_line-data.total-code      = 0
            buf_temp_sheet2_line-data.wth-code        = p-wth-code
            buf_temp_sheet2_line-data.par-code        = p-par-code
            buf_temp_sheet2_line-data.goodsName       = v-gds-name
            buf_temp_sheet2_line-data.wthPar          = ( if available buf_wth-par then string( buf_wth-par.par-val ) else "":U )
            buf_temp_sheet2_line-data.incIncmSt       = 0.0
            buf_temp_sheet2_line-data.incIncmLt       = 0.0
            buf_temp_sheet2_line-data.incRetnSt       = 0.0
            buf_temp_sheet2_line-data.incRetnLt       = 0.0
            buf_temp_sheet2_line-data.outSaleSt       = 0.0
            buf_temp_sheet2_line-data.outSaleLt       = 0.0
            buf_temp_sheet2_line-data.outSaleRb       = 0.0
            buf_temp_sheet2_line-data.outExchSt       = 0.0
            buf_temp_sheet2_line-data.outExchLt       = 0.0
            buf_temp_sheet2_line-data.outExchRb       = 0.0
            buf_temp_sheet2_line-data.payPaydDeskSt   = 0.0
            buf_temp_sheet2_line-data.payPaydDeskLt   = 0.0
            buf_temp_sheet2_line-data.payPaydDeskRb   = 0.0
            buf_temp_sheet2_line-data.payPaydSt       = 0.0
            buf_temp_sheet2_line-data.payPaydLt       = 0.0
            buf_temp_sheet2_line-data.payPaydRb       = 0.0
            buf_temp_sheet2_line-data.payExchSt       = 0.0
            buf_temp_sheet2_line-data.payExchLt       = 0.0
            buf_temp_sheet2_line-data.payExchRb       = 0.0
            buf_temp_sheet2_line-data.payRetnSt       = 0.0
            buf_temp_sheet2_line-data.payRetnLt       = 0.0
            buf_temp_sheet2_line-data.payRetnRb       = 0.0
            buf_temp_sheet2_line-data.clrRealSt       = 0.0
            buf_temp_sheet2_line-data.clrRealLt       = 0.0
            buf_temp_sheet2_line-data.clrRealRb       = 0.0
            buf_temp_sheet2_line-data.clrPOffSt       = 0.0
            buf_temp_sheet2_line-data.clrPOffLt       = 0.0
            buf_temp_sheet2_line-data.clrPOffRb       = 0.0
            buf_temp_sheet2_line-data.trsRealExpsSt   = 0.0
            buf_temp_sheet2_line-data.trsRealExpsLt   = 0.0
            buf_temp_sheet2_line-data.trsRealIncmSt   = 0.0
            buf_temp_sheet2_line-data.trsRealIncmLt   = 0.0
            buf_temp_sheet2_line-data.trsRealTrnsSt   = 0.0
            buf_temp_sheet2_line-data.trsRealTrnsLt   = 0.0
            buf_temp_sheet2_line-data.trsPOffExpsSt   = 0.0
            buf_temp_sheet2_line-data.trsPOffExpsLt   = 0.0
            buf_temp_sheet2_line-data.trsPOffExpsRb   = 0.0
            buf_temp_sheet2_line-data.trsPOffIncmSt   = 0.0
            buf_temp_sheet2_line-data.trsPOffIncmLt   = 0.0
            buf_temp_sheet2_line-data.trsPOffIncmRb   = 0.0
            buf_temp_sheet2_line-data.trsPOffTrnsSt   = 0.0
            buf_temp_sheet2_line-data.trsPOffTrnsLt   = 0.0
            buf_temp_sheet2_line-data.trsPOffTrnsRb   = 0.0
        .
    end.
    assign
        buf_temp_sheet2_line-data.incIncmSt       = buf_temp_sheet2_line-data.incIncmSt      + p-incIncmSt
        buf_temp_sheet2_line-data.incIncmLt       = buf_temp_sheet2_line-data.incIncmLt      + p-incIncmLt
        buf_temp_sheet2_line-data.incRetnSt       = buf_temp_sheet2_line-data.incRetnSt      + p-incRetnSt
        buf_temp_sheet2_line-data.incRetnLt       = buf_temp_sheet2_line-data.incRetnLt      + p-incRetnLt
        buf_temp_sheet2_line-data.outSaleSt       = buf_temp_sheet2_line-data.outSaleSt      + p-outSaleSt
        buf_temp_sheet2_line-data.outSaleLt       = buf_temp_sheet2_line-data.outSaleLt      + p-outSaleLt
        buf_temp_sheet2_line-data.outSaleRb       = buf_temp_sheet2_line-data.outSaleRb      + p-outSaleRb
        buf_temp_sheet2_line-data.outExchSt       = buf_temp_sheet2_line-data.outExchSt      + p-outExchSt
        buf_temp_sheet2_line-data.outExchLt       = buf_temp_sheet2_line-data.outExchLt      + p-outExchLt
        buf_temp_sheet2_line-data.outExchRb       = buf_temp_sheet2_line-data.outExchRb      + p-outExchRb
        buf_temp_sheet2_line-data.payPaydDeskSt   = buf_temp_sheet2_line-data.payPaydDeskSt  + p-payPaydDeskSt
        buf_temp_sheet2_line-data.payPaydDeskLt   = buf_temp_sheet2_line-data.payPaydDeskLt  + p-payPaydDeskLt
        buf_temp_sheet2_line-data.payPaydDeskRb   = buf_temp_sheet2_line-data.payPaydDeskRb  + p-payPaydDeskRb
        buf_temp_sheet2_line-data.payPaydSt       = buf_temp_sheet2_line-data.payPaydSt      + p-payPaydSt
        buf_temp_sheet2_line-data.payPaydLt       = buf_temp_sheet2_line-data.payPaydLt      + p-payPaydLt
        buf_temp_sheet2_line-data.payPaydRb       = buf_temp_sheet2_line-data.payPaydRb      + p-payPaydRb
        buf_temp_sheet2_line-data.payExchSt       = buf_temp_sheet2_line-data.payExchSt      + p-payExchSt
        buf_temp_sheet2_line-data.payExchLt       = buf_temp_sheet2_line-data.payExchLt      + p-payExchLt
        buf_temp_sheet2_line-data.payExchRb       = buf_temp_sheet2_line-data.payExchRb      + p-payExchRb
        buf_temp_sheet2_line-data.payRetnSt       = buf_temp_sheet2_line-data.payRetnSt      + p-payRetnSt
        buf_temp_sheet2_line-data.payRetnLt       = buf_temp_sheet2_line-data.payRetnLt      + p-payRetnLt
        buf_temp_sheet2_line-data.payRetnRb       = buf_temp_sheet2_line-data.payRetnRb      + p-payRetnRb
        buf_temp_sheet2_line-data.clrRealSt       = buf_temp_sheet2_line-data.clrRealSt      + p-clrRealSt
        buf_temp_sheet2_line-data.clrRealLt       = buf_temp_sheet2_line-data.clrRealLt      + p-clrRealLt
        buf_temp_sheet2_line-data.clrRealRb       = buf_temp_sheet2_line-data.clrRealRb      + p-clrRealRb
        buf_temp_sheet2_line-data.clrPOffSt       = buf_temp_sheet2_line-data.clrPOffSt      + p-clrPOffSt
        buf_temp_sheet2_line-data.clrPOffLt       = buf_temp_sheet2_line-data.clrPOffLt      + p-clrPOffLt
        buf_temp_sheet2_line-data.clrPOffRb       = buf_temp_sheet2_line-data.clrPOffRb      + p-clrPOffRb
        buf_temp_sheet2_line-data.trsRealExpsSt   = buf_temp_sheet2_line-data.trsRealExpsSt  + p-trsRealExpsSt
        buf_temp_sheet2_line-data.trsRealExpsLt   = buf_temp_sheet2_line-data.trsRealExpsLt  + p-trsRealExpsLt
        buf_temp_sheet2_line-data.trsRealIncmSt   = buf_temp_sheet2_line-data.trsRealIncmSt  + p-trsRealIncmSt
        buf_temp_sheet2_line-data.trsRealIncmLt   = buf_temp_sheet2_line-data.trsRealIncmLt  + p-trsRealIncmLt
        buf_temp_sheet2_line-data.trsRealTrnsSt   = buf_temp_sheet2_line-data.trsRealTrnsSt  + p-trsRealTrnsSt
        buf_temp_sheet2_line-data.trsRealTrnsLt   = buf_temp_sheet2_line-data.trsRealTrnsLt  + p-trsRealTrnsLt
        buf_temp_sheet2_line-data.trsPOffExpsSt   = buf_temp_sheet2_line-data.trsPOffExpsSt  + p-trsPOffExpsSt
        buf_temp_sheet2_line-data.trsPOffExpsLt   = buf_temp_sheet2_line-data.trsPOffExpsLt  + p-trsPOffExpsLt
        buf_temp_sheet2_line-data.trsPOffExpsRb   = buf_temp_sheet2_line-data.trsPOffExpsRb  + p-trsPOffExpsRb
        buf_temp_sheet2_line-data.trsPOffIncmSt   = buf_temp_sheet2_line-data.trsPOffIncmSt  + p-trsPOffIncmSt
        buf_temp_sheet2_line-data.trsPOffIncmLt   = buf_temp_sheet2_line-data.trsPOffIncmLt  + p-trsPOffIncmLt
        buf_temp_sheet2_line-data.trsPOffIncmRb   = buf_temp_sheet2_line-data.trsPOffIncmRb  + p-trsPOffIncmRb
        buf_temp_sheet2_line-data.trsPOffTrnsSt   = buf_temp_sheet2_line-data.trsPOffTrnsSt  + p-trsPOffTrnsSt
        buf_temp_sheet2_line-data.trsPOffTrnsLt   = buf_temp_sheet2_line-data.trsPOffTrnsLt  + p-trsPOffTrnsLt
        buf_temp_sheet2_line-data.trsPOffTrnsRb   = buf_temp_sheet2_line-data.trsPOffTrnsRb  + p-trsPOffTrnsRb
    .
end.
end procedure.
procedure rwthobxl-sheet2-write-line-data :
    define buffer buf_temp_sheet2_line-data        for temp_sheet2_line-data.
    define buffer bf_temp_sheet2_line-data         for temp_sheet2_line-data.
    define buffer b_temp_sheet2_line-data          for temp_sheet2_line-data.
do
for buf_temp_sheet2_line-data
  , bf_temp_sheet2_line-data
  , b_temp_sheet2_line-data
on error undo, return error
:
   create b_temp_sheet2_line-data.
   assign
      v-rwthobxl-sheet2-cur-data-row = v-rwthobxl-sheet2-cur-data-row + 1
   .
   assign
      b_temp_sheet2_line-data.sheet-name      = "Обороты":U
      b_temp_sheet2_line-data.xl-line-id      = v-rwthobxl-sheet2-cur-data-row
      b_temp_sheet2_line-data.obj-type        = "":U
      b_temp_sheet2_line-data.obj-code        = 0
      b_temp_sheet2_line-data.total-code      = 2
      b_temp_sheet2_line-data.wth-code        = 0
      b_temp_sheet2_line-data.par-code        = 0
      b_temp_sheet2_line-data.goodsName       = "Итого:"
      b_temp_sheet2_line-data.wthPar          = "":U
      b_temp_sheet2_line-data.incIncmSt       = 0.0
      b_temp_sheet2_line-data.incIncmLt       = 0.0
      b_temp_sheet2_line-data.incRetnSt       = 0.0
      b_temp_sheet2_line-data.incRetnLt       = 0.0
      b_temp_sheet2_line-data.outSaleSt       = 0.0
      b_temp_sheet2_line-data.outSaleLt       = 0.0
      b_temp_sheet2_line-data.outSaleRb       = 0.0
      b_temp_sheet2_line-data.outExchSt       = 0.0
      b_temp_sheet2_line-data.outExchLt       = 0.0
      b_temp_sheet2_line-data.outExchRb       = 0.0
      b_temp_sheet2_line-data.payPaydDeskSt   = 0.0
      b_temp_sheet2_line-data.payPaydDeskLt   = 0.0
      b_temp_sheet2_line-data.payPaydDeskRb   = 0.0
      b_temp_sheet2_line-data.payPaydSt       = 0.0
      b_temp_sheet2_line-data.payPaydLt       = 0.0
      b_temp_sheet2_line-data.payPaydRb       = 0.0
      b_temp_sheet2_line-data.payExchSt       = 0.0
      b_temp_sheet2_line-data.payExchLt       = 0.0
      b_temp_sheet2_line-data.payExchRb       = 0.0
      b_temp_sheet2_line-data.payRetnSt       = 0.0
      b_temp_sheet2_line-data.payRetnLt       = 0.0
      b_temp_sheet2_line-data.payRetnRb       = 0.0
      b_temp_sheet2_line-data.clrRealSt       = 0.0
      b_temp_sheet2_line-data.clrRealLt       = 0.0
      b_temp_sheet2_line-data.clrRealRb       = 0.0
      b_temp_sheet2_line-data.clrPOffSt       = 0.0
      b_temp_sheet2_line-data.clrPOffLt       = 0.0
      b_temp_sheet2_line-data.clrPOffRb       = 0.0
      b_temp_sheet2_line-data.trsRealExpsSt   = 0.0
      b_temp_sheet2_line-data.trsRealExpsLt   = 0.0
      b_temp_sheet2_line-data.trsRealIncmSt   = 0.0
      b_temp_sheet2_line-data.trsRealIncmLt   = 0.0
      b_temp_sheet2_line-data.trsRealTrnsSt   = 0.0
      b_temp_sheet2_line-data.trsRealTrnsLt   = 0.0
      b_temp_sheet2_line-data.trsPOffExpsSt   = 0.0
      b_temp_sheet2_line-data.trsPOffExpsLt   = 0.0
      b_temp_sheet2_line-data.trsPOffExpsRb   = 0.0
      b_temp_sheet2_line-data.trsPOffIncmSt   = 0.0
      b_temp_sheet2_line-data.trsPOffIncmLt   = 0.0
      b_temp_sheet2_line-data.trsPOffIncmRb   = 0.0
      b_temp_sheet2_line-data.trsPOffTrnsSt   = 0.0
      b_temp_sheet2_line-data.trsPOffTrnsLt   = 0.0
      b_temp_sheet2_line-data.trsPOffTrnsRb   = 0.0
   .
    for each  buf_temp_sheet2_line-data
        WHERE buf_temp_sheet2_line-data.total-code = 0
    break by buf_temp_sheet2_line-data.total-code
          by buf_temp_sheet2_line-data.obj-type
          by buf_temp_sheet2_line-data.obj-code
    :
        if first-of ( buf_temp_sheet2_line-data.obj-code )
        then do:
            put stream excel-line unformatted
                                buf_temp_sheet2_line-data.sheet-name
                CHR(9)   "DTA":U
                CHR(9)   substitute( "По объекту &1 &2", buf_temp_sheet2_line-data.obj-type, buf_temp_sheet2_line-data.obj-code )
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                CHR(9)   " ":U
                chr(10)
            .
            run rwthobxl-sheet2-write-line-format in this-procedure (
                input "Объект":U
            ).
            find first bf_temp_sheet2_line-data
                 where bf_temp_sheet2_line-data.total-code = 1
                   and bf_temp_sheet2_line-data.obj-type   = buf_temp_sheet2_line-data.obj-type
                   and bf_temp_sheet2_line-data.obj-code   = buf_temp_sheet2_line-data.obj-code
                   and bf_temp_sheet2_line-data.wth-code   = 0
                   and bf_temp_sheet2_line-data.par-code   = 0
                  no-error
                  .
            if not available bf_temp_sheet2_line-data
            then do:
               create bf_temp_sheet2_line-data.
               assign
                     v-rwthobxl-sheet2-cur-data-row = v-rwthobxl-sheet2-cur-data-row + 1
               .
               assign
                     bf_temp_sheet2_line-data.sheet-name      = "Обороты":U
                     bf_temp_sheet2_line-data.xl-line-id      = v-rwthobxl-sheet2-cur-data-row
                     bf_temp_sheet2_line-data.obj-type        = buf_temp_sheet2_line-data.obj-type
                     bf_temp_sheet2_line-data.obj-code        = buf_temp_sheet2_line-data.obj-code
                     bf_temp_sheet2_line-data.total-code      = 1
                     bf_temp_sheet2_line-data.wth-code        = 0
                     bf_temp_sheet2_line-data.par-code        = 0
                     bf_temp_sheet2_line-data.goodsName       = SUBSTITUTE("Итого по объекту &1 &2:", buf_temp_sheet2_line-data.obj-type, buf_temp_sheet2_line-data.obj-code)
                     bf_temp_sheet2_line-data.wthPar          = "":U
                     bf_temp_sheet2_line-data.incIncmSt       = 0.0
                     bf_temp_sheet2_line-data.incIncmLt       = 0.0
                     bf_temp_sheet2_line-data.incRetnSt       = 0.0
                     bf_temp_sheet2_line-data.incRetnLt       = 0.0
                     bf_temp_sheet2_line-data.outSaleSt       = 0.0
                     bf_temp_sheet2_line-data.outSaleLt       = 0.0
                     bf_temp_sheet2_line-data.outSaleRb       = 0.0
                     bf_temp_sheet2_line-data.outExchSt       = 0.0
                     bf_temp_sheet2_line-data.outExchLt       = 0.0
                     bf_temp_sheet2_line-data.outExchRb       = 0.0
                     bf_temp_sheet2_line-data.payPaydDeskSt   = 0.0
                     bf_temp_sheet2_line-data.payPaydDeskLt   = 0.0
                     bf_temp_sheet2_line-data.payPaydDeskRb   = 0.0
                     bf_temp_sheet2_line-data.payPaydSt       = 0.0
                     bf_temp_sheet2_line-data.payPaydLt       = 0.0
                     bf_temp_sheet2_line-data.payPaydRb       = 0.0
                     bf_temp_sheet2_line-data.payExchSt       = 0.0
                     bf_temp_sheet2_line-data.payExchLt       = 0.0
                     bf_temp_sheet2_line-data.payExchRb       = 0.0
                     bf_temp_sheet2_line-data.payRetnSt       = 0.0
                     bf_temp_sheet2_line-data.payRetnLt       = 0.0
                     bf_temp_sheet2_line-data.payRetnRb       = 0.0
                     bf_temp_sheet2_line-data.clrRealSt       = 0.0
                     bf_temp_sheet2_line-data.clrRealLt       = 0.0
                     bf_temp_sheet2_line-data.clrRealRb       = 0.0
                     bf_temp_sheet2_line-data.clrPOffSt       = 0.0
                     bf_temp_sheet2_line-data.clrPOffLt       = 0.0
                     bf_temp_sheet2_line-data.clrPOffRb       = 0.0
                     bf_temp_sheet2_line-data.trsRealExpsSt   = 0.0
                     bf_temp_sheet2_line-data.trsRealExpsLt   = 0.0
                     bf_temp_sheet2_line-data.trsRealIncmSt   = 0.0
                     bf_temp_sheet2_line-data.trsRealIncmLt   = 0.0
                     bf_temp_sheet2_line-data.trsRealTrnsSt   = 0.0
                     bf_temp_sheet2_line-data.trsRealTrnsLt   = 0.0
                     bf_temp_sheet2_line-data.trsPOffExpsSt   = 0.0
                     bf_temp_sheet2_line-data.trsPOffExpsLt   = 0.0
                     bf_temp_sheet2_line-data.trsPOffExpsRb   = 0.0
                     bf_temp_sheet2_line-data.trsPOffIncmSt   = 0.0
                     bf_temp_sheet2_line-data.trsPOffIncmLt   = 0.0
                     bf_temp_sheet2_line-data.trsPOffIncmRb   = 0.0
                     bf_temp_sheet2_line-data.trsPOffTrnsSt   = 0.0
                     bf_temp_sheet2_line-data.trsPOffTrnsLt   = 0.0
                     bf_temp_sheet2_line-data.trsPOffTrnsRb   = 0.0
               .
            end.
        end.
        put stream excel-line unformatted
                            buf_temp_sheet2_line-data.sheet-name
            CHR(9)   "DTA":U
            CHR(9)   buf_temp_sheet2_line-data.goodsName
            CHR(9)   buf_temp_sheet2_line-data.wthPar
            CHR(9)   string( buf_temp_sheet2_line-data.incIncmSt     )
            CHR(9)   string( buf_temp_sheet2_line-data.incIncmLt     )
            CHR(9)   string( buf_temp_sheet2_line-data.incRetnSt     )
            CHR(9)   string( buf_temp_sheet2_line-data.incRetnLt     )
            CHR(9)   string( buf_temp_sheet2_line-data.outSaleSt     )
            CHR(9)   string( buf_temp_sheet2_line-data.outSaleLt     )
            CHR(9)   string( buf_temp_sheet2_line-data.outSaleRb     )
            CHR(9)   string( buf_temp_sheet2_line-data.outExchSt     )
            CHR(9)   string( buf_temp_sheet2_line-data.outExchLt     )
            CHR(9)   string( buf_temp_sheet2_line-data.outExchRb     )
            CHR(9)   string( buf_temp_sheet2_line-data.payPaydDeskSt )
            CHR(9)   string( buf_temp_sheet2_line-data.payPaydDeskLt )
            CHR(9)   string( buf_temp_sheet2_line-data.payPaydDeskRb )
            CHR(9)   string( buf_temp_sheet2_line-data.payPaydSt     )
            CHR(9)   string( buf_temp_sheet2_line-data.payPaydLt     )
            CHR(9)   string( buf_temp_sheet2_line-data.payPaydRb     )
            CHR(9)   string( buf_temp_sheet2_line-data.payExchSt     )
            CHR(9)   string( buf_temp_sheet2_line-data.payExchLt     )
            CHR(9)   string( buf_temp_sheet2_line-data.payExchRb     )
            CHR(9)   string( buf_temp_sheet2_line-data.payRetnSt     )
            CHR(9)   string( buf_temp_sheet2_line-data.payRetnLt     )
            CHR(9)   string( buf_temp_sheet2_line-data.payRetnRb     )
            CHR(9)   string( buf_temp_sheet2_line-data.clrRealSt     )
            CHR(9)   string( buf_temp_sheet2_line-data.clrRealLt     )
            CHR(9)   string( buf_temp_sheet2_line-data.clrRealRb     )
            CHR(9)   string( buf_temp_sheet2_line-data.clrPOffSt     )
            CHR(9)   string( buf_temp_sheet2_line-data.clrPOffLt     )
            CHR(9)   string( buf_temp_sheet2_line-data.clrPOffRb     )
            CHR(9)   string( buf_temp_sheet2_line-data.trsRealExpsSt )
            CHR(9)   string( buf_temp_sheet2_line-data.trsRealExpsLt )
            CHR(9)   string( buf_temp_sheet2_line-data.trsRealIncmSt )
            CHR(9)   string( buf_temp_sheet2_line-data.trsRealIncmLt )
            CHR(9)   string( buf_temp_sheet2_line-data.trsRealTrnsSt )
            CHR(9)   string( buf_temp_sheet2_line-data.trsRealTrnsLt )
            CHR(9)   string( buf_temp_sheet2_line-data.trsPOffExpsSt )
            CHR(9)   string( buf_temp_sheet2_line-data.trsPOffExpsLt )
            CHR(9)   string( buf_temp_sheet2_line-data.trsPOffExpsRb )
            CHR(9)   string( buf_temp_sheet2_line-data.trsPOffIncmSt )
            CHR(9)   string( buf_temp_sheet2_line-data.trsPOffIncmLt )
            CHR(9)   string( buf_temp_sheet2_line-data.trsPOffIncmRb )
            CHR(9)   string( buf_temp_sheet2_line-data.trsPOffTrnsSt )
            CHR(9)   string( buf_temp_sheet2_line-data.trsPOffTrnsLt )
            CHR(9)   string( buf_temp_sheet2_line-data.trsPOffTrnsRb )
            chr(10)
        .
         assign
            bf_temp_sheet2_line-data.incIncmSt       = bf_temp_sheet2_line-data.incIncmSt      + buf_temp_sheet2_line-data.incIncmSt
            bf_temp_sheet2_line-data.incIncmLt       = bf_temp_sheet2_line-data.incIncmLt      + buf_temp_sheet2_line-data.incIncmLt
            bf_temp_sheet2_line-data.incRetnSt       = bf_temp_sheet2_line-data.incRetnSt      + buf_temp_sheet2_line-data.incRetnSt
            bf_temp_sheet2_line-data.incRetnLt       = bf_temp_sheet2_line-data.incRetnLt      + buf_temp_sheet2_line-data.incRetnLt
            bf_temp_sheet2_line-data.outSaleSt       = bf_temp_sheet2_line-data.outSaleSt      + buf_temp_sheet2_line-data.outSaleSt
            bf_temp_sheet2_line-data.outSaleLt       = bf_temp_sheet2_line-data.outSaleLt      + buf_temp_sheet2_line-data.outSaleLt
            bf_temp_sheet2_line-data.outSaleRb       = bf_temp_sheet2_line-data.outSaleRb      + buf_temp_sheet2_line-data.outSaleRb
            bf_temp_sheet2_line-data.outExchSt       = bf_temp_sheet2_line-data.outExchSt      + buf_temp_sheet2_line-data.outExchSt
            bf_temp_sheet2_line-data.outExchLt       = bf_temp_sheet2_line-data.outExchLt      + buf_temp_sheet2_line-data.outExchLt
            bf_temp_sheet2_line-data.outExchRb       = bf_temp_sheet2_line-data.outExchRb      + buf_temp_sheet2_line-data.outExchRb
            bf_temp_sheet2_line-data.payPaydDeskSt   = bf_temp_sheet2_line-data.payPaydDeskSt  + buf_temp_sheet2_line-data.payPaydDeskSt
            bf_temp_sheet2_line-data.payPaydDeskLt   = bf_temp_sheet2_line-data.payPaydDeskLt  + buf_temp_sheet2_line-data.payPaydDeskLt
            bf_temp_sheet2_line-data.payPaydDeskRb   = bf_temp_sheet2_line-data.payPaydDeskRb  + buf_temp_sheet2_line-data.payPaydDeskRb
            bf_temp_sheet2_line-data.payPaydSt       = bf_temp_sheet2_line-data.payPaydSt      + buf_temp_sheet2_line-data.payPaydSt
            bf_temp_sheet2_line-data.payPaydLt       = bf_temp_sheet2_line-data.payPaydLt      + buf_temp_sheet2_line-data.payPaydLt
            bf_temp_sheet2_line-data.payPaydRb       = bf_temp_sheet2_line-data.payPaydRb      + buf_temp_sheet2_line-data.payPaydRb
            bf_temp_sheet2_line-data.payExchSt       = bf_temp_sheet2_line-data.payExchSt      + buf_temp_sheet2_line-data.payExchSt
            bf_temp_sheet2_line-data.payExchLt       = bf_temp_sheet2_line-data.payExchLt      + buf_temp_sheet2_line-data.payExchLt
            bf_temp_sheet2_line-data.payExchRb       = bf_temp_sheet2_line-data.payExchRb      + buf_temp_sheet2_line-data.payExchRb
            bf_temp_sheet2_line-data.payRetnSt       = bf_temp_sheet2_line-data.payRetnSt      + buf_temp_sheet2_line-data.payRetnSt
            bf_temp_sheet2_line-data.payRetnLt       = bf_temp_sheet2_line-data.payRetnLt      + buf_temp_sheet2_line-data.payRetnLt
            bf_temp_sheet2_line-data.payRetnRb       = bf_temp_sheet2_line-data.payRetnRb      + buf_temp_sheet2_line-data.payRetnRb
            bf_temp_sheet2_line-data.clrRealSt       = bf_temp_sheet2_line-data.clrRealSt      + buf_temp_sheet2_line-data.clrRealSt
            bf_temp_sheet2_line-data.clrRealLt       = bf_temp_sheet2_line-data.clrRealLt      + buf_temp_sheet2_line-data.clrRealLt
            bf_temp_sheet2_line-data.clrRealRb       = bf_temp_sheet2_line-data.clrRealRb      + buf_temp_sheet2_line-data.clrRealRb
            bf_temp_sheet2_line-data.clrPOffSt       = bf_temp_sheet2_line-data.clrPOffSt      + buf_temp_sheet2_line-data.clrPOffSt
            bf_temp_sheet2_line-data.clrPOffLt       = bf_temp_sheet2_line-data.clrPOffLt      + buf_temp_sheet2_line-data.clrPOffLt
            bf_temp_sheet2_line-data.clrPOffRb       = bf_temp_sheet2_line-data.clrPOffRb      + buf_temp_sheet2_line-data.clrPOffRb
            bf_temp_sheet2_line-data.trsRealExpsSt   = bf_temp_sheet2_line-data.trsRealExpsSt  + buf_temp_sheet2_line-data.trsRealExpsSt
            bf_temp_sheet2_line-data.trsRealExpsLt   = bf_temp_sheet2_line-data.trsRealExpsLt  + buf_temp_sheet2_line-data.trsRealExpsLt
            bf_temp_sheet2_line-data.trsRealIncmSt   = bf_temp_sheet2_line-data.trsRealIncmSt  + buf_temp_sheet2_line-data.trsRealIncmSt
            bf_temp_sheet2_line-data.trsRealIncmLt   = bf_temp_sheet2_line-data.trsRealIncmLt  + buf_temp_sheet2_line-data.trsRealIncmLt
            bf_temp_sheet2_line-data.trsRealTrnsSt   = bf_temp_sheet2_line-data.trsRealTrnsSt  + buf_temp_sheet2_line-data.trsRealTrnsSt
            bf_temp_sheet2_line-data.trsRealTrnsLt   = bf_temp_sheet2_line-data.trsRealTrnsLt  + buf_temp_sheet2_line-data.trsRealTrnsLt
            bf_temp_sheet2_line-data.trsPOffExpsSt   = bf_temp_sheet2_line-data.trsPOffExpsSt  + buf_temp_sheet2_line-data.trsPOffExpsSt
            bf_temp_sheet2_line-data.trsPOffExpsLt   = bf_temp_sheet2_line-data.trsPOffExpsLt  + buf_temp_sheet2_line-data.trsPOffExpsLt
            bf_temp_sheet2_line-data.trsPOffExpsRb   = bf_temp_sheet2_line-data.trsPOffExpsRb  + buf_temp_sheet2_line-data.trsPOffExpsRb
            bf_temp_sheet2_line-data.trsPOffIncmSt   = bf_temp_sheet2_line-data.trsPOffIncmSt  + buf_temp_sheet2_line-data.trsPOffIncmSt
            bf_temp_sheet2_line-data.trsPOffIncmLt   = bf_temp_sheet2_line-data.trsPOffIncmLt  + buf_temp_sheet2_line-data.trsPOffIncmLt
            bf_temp_sheet2_line-data.trsPOffIncmRb   = bf_temp_sheet2_line-data.trsPOffIncmRb  + buf_temp_sheet2_line-data.trsPOffIncmRb
            bf_temp_sheet2_line-data.trsPOffTrnsSt   = bf_temp_sheet2_line-data.trsPOffTrnsSt  + buf_temp_sheet2_line-data.trsPOffTrnsSt
            bf_temp_sheet2_line-data.trsPOffTrnsLt   = bf_temp_sheet2_line-data.trsPOffTrnsLt  + buf_temp_sheet2_line-data.trsPOffTrnsLt
            bf_temp_sheet2_line-data.trsPOffTrnsRb   = bf_temp_sheet2_line-data.trsPOffTrnsRb  + buf_temp_sheet2_line-data.trsPOffTrnsRb
            b_temp_sheet2_line-data.incIncmSt       = b_temp_sheet2_line-data.incIncmSt      + buf_temp_sheet2_line-data.incIncmSt
            b_temp_sheet2_line-data.incIncmLt       = b_temp_sheet2_line-data.incIncmLt      + buf_temp_sheet2_line-data.incIncmLt
            b_temp_sheet2_line-data.incRetnSt       = b_temp_sheet2_line-data.incRetnSt      + buf_temp_sheet2_line-data.incRetnSt
            b_temp_sheet2_line-data.incRetnLt       = b_temp_sheet2_line-data.incRetnLt      + buf_temp_sheet2_line-data.incRetnLt
            b_temp_sheet2_line-data.outSaleSt       = b_temp_sheet2_line-data.outSaleSt      + buf_temp_sheet2_line-data.outSaleSt
            b_temp_sheet2_line-data.outSaleLt       = b_temp_sheet2_line-data.outSaleLt      + buf_temp_sheet2_line-data.outSaleLt
            b_temp_sheet2_line-data.outSaleRb       = b_temp_sheet2_line-data.outSaleRb      + buf_temp_sheet2_line-data.outSaleRb
            b_temp_sheet2_line-data.outExchSt       = b_temp_sheet2_line-data.outExchSt      + buf_temp_sheet2_line-data.outExchSt
            b_temp_sheet2_line-data.outExchLt       = b_temp_sheet2_line-data.outExchLt      + buf_temp_sheet2_line-data.outExchLt
            b_temp_sheet2_line-data.outExchRb       = b_temp_sheet2_line-data.outExchRb      + buf_temp_sheet2_line-data.outExchRb
            b_temp_sheet2_line-data.payPaydDeskSt   = b_temp_sheet2_line-data.payPaydDeskSt  + buf_temp_sheet2_line-data.payPaydDeskSt
            b_temp_sheet2_line-data.payPaydDeskLt   = b_temp_sheet2_line-data.payPaydDeskLt  + buf_temp_sheet2_line-data.payPaydDeskLt
            b_temp_sheet2_line-data.payPaydDeskRb   = b_temp_sheet2_line-data.payPaydDeskRb  + buf_temp_sheet2_line-data.payPaydDeskRb
            b_temp_sheet2_line-data.payPaydSt       = b_temp_sheet2_line-data.payPaydSt      + buf_temp_sheet2_line-data.payPaydSt
            b_temp_sheet2_line-data.payPaydLt       = b_temp_sheet2_line-data.payPaydLt      + buf_temp_sheet2_line-data.payPaydLt
            b_temp_sheet2_line-data.payPaydRb       = b_temp_sheet2_line-data.payPaydRb      + buf_temp_sheet2_line-data.payPaydRb
            b_temp_sheet2_line-data.payExchSt       = b_temp_sheet2_line-data.payExchSt      + buf_temp_sheet2_line-data.payExchSt
            b_temp_sheet2_line-data.payExchLt       = b_temp_sheet2_line-data.payExchLt      + buf_temp_sheet2_line-data.payExchLt
            b_temp_sheet2_line-data.payExchRb       = b_temp_sheet2_line-data.payExchRb      + buf_temp_sheet2_line-data.payExchRb
            b_temp_sheet2_line-data.payRetnSt       = b_temp_sheet2_line-data.payRetnSt      + buf_temp_sheet2_line-data.payRetnSt
            b_temp_sheet2_line-data.payRetnLt       = b_temp_sheet2_line-data.payRetnLt      + buf_temp_sheet2_line-data.payRetnLt
            b_temp_sheet2_line-data.payRetnRb       = b_temp_sheet2_line-data.payRetnRb      + buf_temp_sheet2_line-data.payRetnRb
            b_temp_sheet2_line-data.clrRealSt       = b_temp_sheet2_line-data.clrRealSt      + buf_temp_sheet2_line-data.clrRealSt
            b_temp_sheet2_line-data.clrRealLt       = b_temp_sheet2_line-data.clrRealLt      + buf_temp_sheet2_line-data.clrRealLt
            b_temp_sheet2_line-data.clrRealRb       = b_temp_sheet2_line-data.clrRealRb      + buf_temp_sheet2_line-data.clrRealRb
            b_temp_sheet2_line-data.clrPOffSt       = b_temp_sheet2_line-data.clrPOffSt      + buf_temp_sheet2_line-data.clrPOffSt
            b_temp_sheet2_line-data.clrPOffLt       = b_temp_sheet2_line-data.clrPOffLt      + buf_temp_sheet2_line-data.clrPOffLt
            b_temp_sheet2_line-data.clrPOffRb       = b_temp_sheet2_line-data.clrPOffRb      + buf_temp_sheet2_line-data.clrPOffRb
            b_temp_sheet2_line-data.trsRealExpsSt   = b_temp_sheet2_line-data.trsRealExpsSt  + buf_temp_sheet2_line-data.trsRealExpsSt
            b_temp_sheet2_line-data.trsRealExpsLt   = b_temp_sheet2_line-data.trsRealExpsLt  + buf_temp_sheet2_line-data.trsRealExpsLt
            b_temp_sheet2_line-data.trsRealIncmSt   = b_temp_sheet2_line-data.trsRealIncmSt  + buf_temp_sheet2_line-data.trsRealIncmSt
            b_temp_sheet2_line-data.trsRealIncmLt   = b_temp_sheet2_line-data.trsRealIncmLt  + buf_temp_sheet2_line-data.trsRealIncmLt
            b_temp_sheet2_line-data.trsRealTrnsSt   = b_temp_sheet2_line-data.trsRealTrnsSt  + buf_temp_sheet2_line-data.trsRealTrnsSt
            b_temp_sheet2_line-data.trsRealTrnsLt   = b_temp_sheet2_line-data.trsRealTrnsLt  + buf_temp_sheet2_line-data.trsRealTrnsLt
            b_temp_sheet2_line-data.trsPOffExpsSt   = b_temp_sheet2_line-data.trsPOffExpsSt  + buf_temp_sheet2_line-data.trsPOffExpsSt
            b_temp_sheet2_line-data.trsPOffExpsLt   = b_temp_sheet2_line-data.trsPOffExpsLt  + buf_temp_sheet2_line-data.trsPOffExpsLt
            b_temp_sheet2_line-data.trsPOffExpsRb   = b_temp_sheet2_line-data.trsPOffExpsRb  + buf_temp_sheet2_line-data.trsPOffExpsRb
            b_temp_sheet2_line-data.trsPOffIncmSt   = b_temp_sheet2_line-data.trsPOffIncmSt  + buf_temp_sheet2_line-data.trsPOffIncmSt
            b_temp_sheet2_line-data.trsPOffIncmLt   = b_temp_sheet2_line-data.trsPOffIncmLt  + buf_temp_sheet2_line-data.trsPOffIncmLt
            b_temp_sheet2_line-data.trsPOffIncmRb   = b_temp_sheet2_line-data.trsPOffIncmRb  + buf_temp_sheet2_line-data.trsPOffIncmRb
            b_temp_sheet2_line-data.trsPOffTrnsSt   = b_temp_sheet2_line-data.trsPOffTrnsSt  + buf_temp_sheet2_line-data.trsPOffTrnsSt
            b_temp_sheet2_line-data.trsPOffTrnsLt   = b_temp_sheet2_line-data.trsPOffTrnsLt  + buf_temp_sheet2_line-data.trsPOffTrnsLt
            b_temp_sheet2_line-data.trsPOffTrnsRb   = b_temp_sheet2_line-data.trsPOffTrnsRb  + buf_temp_sheet2_line-data.trsPOffTrnsRb
         .
        if last-of ( buf_temp_sheet2_line-data.obj-code )
        then do:
            put stream excel-line unformatted
                                 bf_temp_sheet2_line-data.sheet-name
                  CHR(9)  "DTA":U
                  CHR(9)  bf_temp_sheet2_line-data.goodsName
                  CHR(9)  bf_temp_sheet2_line-data.wthPar
                  CHR(9)  string( bf_temp_sheet2_line-data.incIncmSt     )
                  CHR(9)  string( bf_temp_sheet2_line-data.incIncmLt     )
                  CHR(9)  string( bf_temp_sheet2_line-data.incRetnSt     )
                  CHR(9)  string( bf_temp_sheet2_line-data.incRetnLt     )
                  CHR(9)  string( bf_temp_sheet2_line-data.outSaleSt     )
                  CHR(9)  string( bf_temp_sheet2_line-data.outSaleLt     )
                  CHR(9)  string( bf_temp_sheet2_line-data.outSaleRb     )
                  CHR(9)  string( bf_temp_sheet2_line-data.outExchSt     )
                  CHR(9)  string( bf_temp_sheet2_line-data.outExchLt     )
                  CHR(9)  string( bf_temp_sheet2_line-data.outExchRb     )
                  CHR(9)  string( bf_temp_sheet2_line-data.payPaydDeskSt )
                  CHR(9)  string( bf_temp_sheet2_line-data.payPaydDeskLt )
                  CHR(9)  string( bf_temp_sheet2_line-data.payPaydDeskRb )
                  CHR(9)  string( bf_temp_sheet2_line-data.payPaydSt     )
                  CHR(9)  string( bf_temp_sheet2_line-data.payPaydLt     )
                  CHR(9)  string( bf_temp_sheet2_line-data.payPaydRb     )
                  CHR(9)  string( bf_temp_sheet2_line-data.payExchSt     )
                  CHR(9)  string( bf_temp_sheet2_line-data.payExchLt     )
                  CHR(9)  string( bf_temp_sheet2_line-data.payExchRb     )
                  CHR(9)  string( bf_temp_sheet2_line-data.payRetnSt     )
                  CHR(9)  string( bf_temp_sheet2_line-data.payRetnLt     )
                  CHR(9)  string( bf_temp_sheet2_line-data.payRetnRb     )
                  CHR(9)  string( bf_temp_sheet2_line-data.clrRealSt     )
                  CHR(9)  string( bf_temp_sheet2_line-data.clrRealLt     )
                  CHR(9)  string( bf_temp_sheet2_line-data.clrRealRb     )
                  CHR(9)  string( bf_temp_sheet2_line-data.clrPOffSt     )
                  CHR(9)  string( bf_temp_sheet2_line-data.clrPOffLt     )
                  CHR(9)  string( bf_temp_sheet2_line-data.clrPOffRb     )
                  CHR(9)  string( bf_temp_sheet2_line-data.trsRealExpsSt )
                  CHR(9)  string( bf_temp_sheet2_line-data.trsRealExpsLt )
                  CHR(9)  string( bf_temp_sheet2_line-data.trsRealIncmSt )
                  CHR(9)  string( bf_temp_sheet2_line-data.trsRealIncmLt )
                  CHR(9)  string( bf_temp_sheet2_line-data.trsRealTrnsSt )
                  CHR(9)  string( bf_temp_sheet2_line-data.trsRealTrnsLt )
                  CHR(9)  string( bf_temp_sheet2_line-data.trsPOffExpsSt )
                  CHR(9)  string( bf_temp_sheet2_line-data.trsPOffExpsLt )
                  CHR(9)  string( bf_temp_sheet2_line-data.trsPOffExpsRb )
                  CHR(9)  string( bf_temp_sheet2_line-data.trsPOffIncmSt )
                  CHR(9)  string( bf_temp_sheet2_line-data.trsPOffIncmLt )
                  CHR(9)  string( bf_temp_sheet2_line-data.trsPOffIncmRb )
                  CHR(9)  string( bf_temp_sheet2_line-data.trsPOffTrnsSt )
                  CHR(9)  string( bf_temp_sheet2_line-data.trsPOffTrnsLt )
                  CHR(9)  string( bf_temp_sheet2_line-data.trsPOffTrnsRb )
                  chr(10)
            .
        END.
    end.
    put stream excel-line unformatted
                        b_temp_sheet2_line-data.sheet-name
         CHR(9)  "DTA":U
         CHR(9)  b_temp_sheet2_line-data.goodsName
         CHR(9)  b_temp_sheet2_line-data.wthPar
         CHR(9)  string( b_temp_sheet2_line-data.incIncmSt     )
         CHR(9)  string( b_temp_sheet2_line-data.incIncmLt     )
         CHR(9)  string( b_temp_sheet2_line-data.incRetnSt     )
         CHR(9)  string( b_temp_sheet2_line-data.incRetnLt     )
         CHR(9)  string( b_temp_sheet2_line-data.outSaleSt     )
         CHR(9)  string( b_temp_sheet2_line-data.outSaleLt     )
         CHR(9)  string( b_temp_sheet2_line-data.outSaleRb     )
         CHR(9)  string( b_temp_sheet2_line-data.outExchSt     )
         CHR(9)  string( b_temp_sheet2_line-data.outExchLt     )
         CHR(9)  string( b_temp_sheet2_line-data.outExchRb     )
         CHR(9)  string( b_temp_sheet2_line-data.payPaydDeskSt )
         CHR(9)  string( b_temp_sheet2_line-data.payPaydDeskLt )
         CHR(9)  string( b_temp_sheet2_line-data.payPaydDeskRb )
         CHR(9)  string( b_temp_sheet2_line-data.payPaydSt     )
         CHR(9)  string( b_temp_sheet2_line-data.payPaydLt     )
         CHR(9)  string( b_temp_sheet2_line-data.payPaydRb     )
         CHR(9)  string( b_temp_sheet2_line-data.payExchSt     )
         CHR(9)  string( b_temp_sheet2_line-data.payExchLt     )
         CHR(9)  string( b_temp_sheet2_line-data.payExchRb     )
         CHR(9)  string( b_temp_sheet2_line-data.payRetnSt     )
         CHR(9)  string( b_temp_sheet2_line-data.payRetnLt     )
         CHR(9)  string( b_temp_sheet2_line-data.payRetnRb     )
         CHR(9)  string( b_temp_sheet2_line-data.clrRealSt     )
         CHR(9)  string( b_temp_sheet2_line-data.clrRealLt     )
         CHR(9)  string( b_temp_sheet2_line-data.clrRealRb     )
         CHR(9)  string( b_temp_sheet2_line-data.clrPOffSt     )
         CHR(9)  string( b_temp_sheet2_line-data.clrPOffLt     )
         CHR(9)  string( b_temp_sheet2_line-data.clrPOffRb     )
         CHR(9)  string( b_temp_sheet2_line-data.trsRealExpsSt )
         CHR(9)  string( b_temp_sheet2_line-data.trsRealExpsLt )
         CHR(9)  string( b_temp_sheet2_line-data.trsRealIncmSt )
         CHR(9)  string( b_temp_sheet2_line-data.trsRealIncmLt )
         CHR(9)  string( b_temp_sheet2_line-data.trsRealTrnsSt )
         CHR(9)  string( b_temp_sheet2_line-data.trsRealTrnsLt )
         CHR(9)  string( b_temp_sheet2_line-data.trsPOffExpsSt )
         CHR(9)  string( b_temp_sheet2_line-data.trsPOffExpsLt )
         CHR(9)  string( b_temp_sheet2_line-data.trsPOffExpsRb )
         CHR(9)  string( b_temp_sheet2_line-data.trsPOffIncmSt )
         CHR(9)  string( b_temp_sheet2_line-data.trsPOffIncmLt )
         CHR(9)  string( b_temp_sheet2_line-data.trsPOffIncmRb )
         CHR(9)  string( b_temp_sheet2_line-data.trsPOffTrnsSt )
         CHR(9)  string( b_temp_sheet2_line-data.trsPOffTrnsLt )
         CHR(9)  string( b_temp_sheet2_line-data.trsPOffTrnsRb )
         chr(10)
    .
end.
end procedure.
procedure rwthobxl-write-cell-data :
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
procedure rwthobxl-run-excel :
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
        v-template-file-name    = search( "exe/rwthob.xlt" )
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
procedure rwthobxl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/rwthob.xlt":U.
        export "exe/t_form.bas":U.
        export v-rwthobxl-cell-file-name.
        export v-rwthobxl-data-file-name.
    output close.
end.
end procedure.
procedure rwthobxl-sheet1-write-line-format :
define input parameter p-fmt-label       as character  no-undo.
    define buffer buf_temp_sheet1_line-data        for temp_sheet1_line-data.
do
for buf_temp_sheet1_line-data
on error undo, return error
:
    put stream excel-line unformatted
                        "НачалоПериода":U
        CHR(9)   "FMT":U
        CHR(9)   p-fmt-label
        chr(10)
    .
end.
end procedure.
procedure rwthobxl-sheet2-write-line-format :
define input parameter p-fmt-label       as character  no-undo.
    define buffer buf_temp_sheet2_line-data        for temp_sheet2_line-data.
do
for buf_temp_sheet2_line-data
on error undo, return error
:
    put stream excel-line unformatted
                        "Обороты":U
        CHR(9)   "FMT":U
        CHR(9)   p-fmt-label
        chr(10)
    .
end.
end procedure.
procedure rwthobxl-sheet3-write-line-format :
define input parameter p-fmt-label       as character  no-undo.
    define buffer buf_temp_sheet3_line-data        for temp_sheet3_line-data.
do
for buf_temp_sheet3_line-data
on error undo, return error
:
    put stream excel-line unformatted
                        "КонецПериода":U
        CHR(9)   "FMT":U
        CHR(9)   p-fmt-label
        chr(10)
    .
end.
end procedure.
    define variable v-obj-list-string   as character    no-undo.
    define variable v-date-from         as date         no-undo.
    define variable v-date-to           as date         no-undo.
    define variable v-date-string       as character    no-undo.
    define variable v-date-from-string  as character    no-undo.
    define variable v-date-to-string    as character    no-undo.
    define variable v-ext-doc-type-list as character    no-undo.
    define variable v-counter           as integer      no-undo.
    define variable v-fact-order-start  as decimal      no-undo.
    define variable v-fact-order-end    as decimal      no-undo.
    define variable v-hide-list         as character    no-undo.
    define buffer buf_clients               for ub.clients.
    define buffer buf_obj-list              for obj-list.
    define buffer buf_temp_shiftfo_obj-list for temp_shiftfo_obj-list.
do
for buf_clients
  , buf_obj-list
  , buf_temp_shiftfo_obj-list
on error undo, return error
:
if session :set-wait-state( "compiler" ) then.
output stream out-stream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
    put stream out-stream unformatted
          chr(10)
        + "Печатная форма предназначена только для вывода в Microsoft Excel."
        + chr(10)
    .
    output stream out-stream close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) .
    output close.
    run rwthobxl-init in this-procedure.
    run rwthobxl-write-cell-data in this-procedure (
          input "НачалоПериода_datePrint":U
        , input cur-time-string()
    ).
    run get-hide-list in this-procedure (
          input p-ext-doc-type-list
        , input p-ob-liter
        , input p-ob-rubl
        , input p-ob-tal
        , output v-hide-list
    ).
    run rwthobxl-write-cell-data in this-procedure (
          input "Обороты_hideColList":U
        , input v-hide-list
    ).
    run write-stLtRbList in this-procedure (
          input p-ob-tal
        , input p-ob-liter
        , input p-ob-rubl
    ).
    find first buf_obj-list
    no-error.
    if not available buf_obj-list
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Список объектов пуст."
        view-as alert-box error.
        undo, return error.
    end.
    case p-obj-selection-type
    :
        when "1"
        then do:
            assign
                v-obj-list-string = substitute( "Все по фирме: &1", buf_obj-list.obj-name )
            .
        end.
        when "2"
        then do:
            assign
                v-obj-list-string = substitute( "Текущий объект: &1", buf_obj-list.obj-name )
            .
        end.
        otherwise do:
            assign
                v-obj-list-string = ""
            .
            for each buf_obj-list
            on error undo, return error
            :
                assign
                    v-obj-list-string = substitute( "&1&2 &3"
                                            , v-obj-list-string
                                            , ( if v-obj-list-string = "" then "" else "," )
                                            , buf_obj-list.obj-name )
                .
            end.
        end.
    end case.
    run rwthobxl-write-cell-data in this-procedure (
          input "НачалоПериода_objList":U
        , input v-obj-list-string
    ).
    for each buf_obj-list
    on error undo, return error
    :
        create buf_temp_shiftfo_obj-list.
        assign
            buf_temp_shiftfo_obj-list.obj-type = buf_obj-list.obj-type
            buf_temp_shiftfo_obj-list.obj-code = buf_obj-list.obj-code
        .
    end.
    run fill-temp_shiftfo_fo-range in this-procedure (
          input x-Radio-Task
        , input x-Date-Start
        , input x-Date-End
        , input x-Shift-Start
        , input x-Shift-End
        , input x-Shift-Alone
        , output v-date-string
        , output v-date-from-string
        , output v-date-to-string
    ).
     ASSIGN
        v-date-string       = substitute( "с &1 по &2", v-date-from-string, v-date-to-string )
    .
    run rwthobxl-write-cell-data in this-procedure (
          input "НачалоПериода_dateString":U
        , input v-date-string
    ).
    run rwthobxl-write-cell-data in this-procedure (
          input "Обороты_dateString":U
        , input v-date-string
    ).
    run rwthobxl-write-cell-data in this-procedure (
          input "НачалоПериода_dateFromString":U
        , input v-date-from-string
    ).
    run rwthobxl-write-cell-data in this-procedure (
          input "КонецПериода_dateToString":U
        , input v-date-to-string
    ).
    run rwthobxl-write-cell-data in this-procedure (
          input "НачалоПериода_detail":U
        , input ( if p-detal = yes then "есть" else "нет" )
    ).
    run rwthobxl-write-cell-data in this-procedure (
          input "НачалоПериода_detail":U
        , input ( if p-detal = yes then "есть" else "нет" )
    ).
    if p-ext-doc-type-list = "":U
    then do:
        assign
            v-ext-doc-type-list = "все"
        .
    end.
    else do:
        do v-counter = 1 to num-entries( p-ext-doc-type-list )
        on error undo, return error
        :
            assign
                v-ext-doc-type-list = substitute( "&1&2&3"
                                            , v-ext-doc-type-list
                                            , ( if v-ext-doc-type-list = "":U then "":U else ", ":U )
                                            , entry( v-counter, 'приход внешний,расход внешний,приход внутренний,расход внутренний,приход внутри объекта,расход внутри объекта,приход внутриобъектн. в своб. зону,расход внутриобъектн. из своб. зоны,приход внутриобъектн. в зону погаш.,расход внутриобъектн. из зоны погаш.,списание,приход внешний через кассы,возврат покупателю через кассы,инвентаризация,возврат внутренний,приход внутр. в зону погашения,расход внутр. из зоны погашения,возврат внутр. в зону погашения,приход внутр. в своб. зону,расход внутр. из своб. зоны,возврат внутр. в своб зону,погашение через кассу,погашение за реализованное топливо,возврат от покупателя,уничтожение в свободной зоне,уничтожение в зоне погашения,уничтожение в зоне клиента,декларация,обмен':u ) )
            .
        end.
    end.
    run rwthobxl-write-cell-data in this-procedure (
          input "НачалоПериода_extDocTypeList":U
        , input v-ext-doc-type-list
    ).
    for each temp_shiftfo_fo-range
    :
        run fill-temp-tables in this-procedure (
              input temp_shiftfo_fo-range.obj-type
            , input temp_shiftfo_fo-range.obj-code
            , input temp_shiftfo_fo-range.fact-order-from
            , input temp_shiftfo_fo-range.fact-order-to
        ).
    end.
    run rwthobxl-sheet1-write-line-data in this-procedure .
    run rwthobxl-sheet2-write-line-data in this-procedure .
    run rwthobxl-sheet3-write-line-data in this-procedure .
    run rwthobxl-close in this-procedure .
    os-delete value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )  .
    os-rename
        value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
        value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )
    .
if session :set-wait-state( "" ) then.
    define variable v-user-action   as character no-undo .
    define variable v-printed       as logical   no-undo .
    define variable DisabledOptions as integer   no-undo .
    define variable v-orient-page as character no-undo .
    run gbl/prnfilen.w (
          input "":U
        , input 8
        , input string(session :temp-directory) + "rpt" + string( g#report-num )
        , input ReportFontNum
        , output v-user-action
        , output v-printed
    ).
    os-delete value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )  .
end.
procedure fill-temp-tables :
define input parameter p-obj-type           as character        no-undo.
define input parameter p-obj-code           as integer          no-undo.
define input parameter p-fact-order-from    as decimal          no-undo.
define input parameter p-fact-order-to      as decimal          no-undo.
    define variable v-counter           as integer      no-undo.
    define variable v-counter-sum-type  as integer      no-undo.
    define variable v-sum-type          as character    no-undo.
    define variable v-ext-doc-type          as character    no-undo.
    define buffer buf_wealth        for ub.wealth.
    define buffer buf_wth-par       for ub.wth-par.
    define buffer buf_obj-list      for obj-list.
do
for buf_wealth
  , buf_wth-par
  , buf_obj-list
on error undo, return error
:
    for each buf_wealth no-lock
        where buf_wealth.is-ser = 1
    on error undo, return error
    :
        for each buf_wth-par no-lock
            where buf_wth-par.wth-code = buf_wealth.wth-code
        on error undo, return error
        :
            loop-sum-type:
            do v-counter-sum-type = 1 to num-entries( 'рас,при,возврат,спи':U )
            on error undo, return error
            :
                assign
                    v-sum-type = entry( v-counter-sum-type, 'рас,при,возврат,спи':U )
                .
                loop-ext-type:
                do v-counter = 1 to num-entries( 'ie,ee,ii,ei,ij,ej,fj,jj,pj,oj,we,ci,ce,iy,rj,ip,ep,rp,ff,ef,rf,pc,ps,pz,df,dp,dc,de,xc':u )
                on error undo, return error
                :
                    assign
                        v-ext-doc-type = entry( v-counter, 'ie,ee,ii,ei,ij,ej,fj,jj,pj,oj,we,ci,ce,iy,rj,ip,ep,rp,ff,ef,rf,pc,ps,pz,df,dp,dc,de,xc':u )
                    .
                    if ( v-sum-type = 'при':U
                    and lookup( v-ext-doc-type, 'ie,ii,ij,fj,pj,ip,ff,pc,ps,pz,ci':U ) <> 0 )
                    or ( v-sum-type = 'возврат':U
                    and lookup( v-ext-doc-type, 'rj,rf,rp':U ) <> 0 )
                    or ( v-sum-type = 'рас':U
                    and lookup( v-ext-doc-type, 'ee,ei,ej,jj,oj,ce,ef,ep':U ) <> 0 )
                    or ( v-sum-type = 'спи':U
                    and lookup( v-ext-doc-type, 'we,dc,dp,df':U ) <> 0 )
                    or ( lookup( v-sum-type, 'рас,при':U ) <> 0
                    and v-ext-doc-type = 'xc':U )
                    then do:
                        run fill-temp-tables-by-doc-type in this-procedure (
                              input p-obj-type
                            , input p-obj-code
                            , input buf_wealth.wth-code
                            , input buf_wth-par.par-code
                            , input v-ext-doc-type
                            , input v-sum-type
                            , input p-fact-order-from
                            , input p-fact-order-to
                            , input buf_wth-par.par-val
                        ).
                    end.
                end.
            end.
        end.
    end.
end.
end procedure.
procedure fill-temp-tables-by-doc-type :
define input parameter p-obj-type           as character        no-undo.
define input parameter p-obj-code           as integer          no-undo.
define input parameter p-wth-code           as integer          no-undo.
define input parameter p-par-code           as integer          no-undo.
define input parameter p-ext-doc-type       as character        no-undo.
define input parameter p-sum-type           as character        no-undo.
define input parameter p-fact-order-from    as decimal          no-undo.
define input parameter p-fact-order-to      as decimal          no-undo.
define input parameter p-par-val            as decimal          no-undo.
    define variable v-incIncmSt          as decimal      no-undo.
    define variable v-incIncmLt          as decimal      no-undo.
    define variable v-incRetnSt          as decimal      no-undo.
    define variable v-incRetnLt          as decimal      no-undo.
    define variable v-outSaleSt          as decimal      no-undo.
    define variable v-outSaleLt          as decimal      no-undo.
    define variable v-outSaleRb          as decimal      no-undo.
    define variable v-outExchSt          as decimal      no-undo.
    define variable v-outExchLt          as decimal      no-undo.
    define variable v-outExchRb          as decimal      no-undo.
    define variable v-payPaydDeskSt      as decimal      no-undo.
    define variable v-payPaydDeskLt      as decimal      no-undo.
    define variable v-payPaydDeskRb      as decimal      no-undo.
    define variable v-payPaydSt          as decimal      no-undo.
    define variable v-payPaydLt          as decimal      no-undo.
    define variable v-payPaydRb          as decimal      no-undo.
    define variable v-payExchSt          as decimal      no-undo.
    define variable v-payExchLt          as decimal      no-undo.
    define variable v-payExchRb          as decimal      no-undo.
    define variable v-payRetnSt          as decimal      no-undo.
    define variable v-payRetnLt          as decimal      no-undo.
    define variable v-payRetnRb          as decimal      no-undo.
    define variable v-clrRealSt          as decimal      no-undo.
    define variable v-clrRealLt          as decimal      no-undo.
    define variable v-clrRealRb          as decimal      no-undo.
    define variable v-clrPOffSt          as decimal      no-undo.
    define variable v-clrPOffLt          as decimal      no-undo.
    define variable v-clrPOffRb          as decimal      no-undo.
    define variable v-trsRealExpsSt      as decimal      no-undo.
    define variable v-trsRealExpsLt      as decimal      no-undo.
    define variable v-trsRealIncmSt      as decimal      no-undo.
    define variable v-trsRealIncmLt      as decimal      no-undo.
    define variable v-trsRealTrnsSt      as decimal      no-undo.
    define variable v-trsRealTrnsLt      as decimal      no-undo.
    define variable v-trsPOffExpsSt      as decimal      no-undo.
    define variable v-trsPOffExpsLt      as decimal      no-undo.
    define variable v-trsPOffExpsRb      as decimal      no-undo.
    define variable v-trsPOffIncmSt      as decimal      no-undo.
    define variable v-trsPOffIncmLt      as decimal      no-undo.
    define variable v-trsPOffIncmRb      as decimal      no-undo.
    define variable v-trsPOffTrnsSt      as decimal      no-undo.
    define variable v-trsPOffTrnsLt      as decimal      no-undo.
    define variable v-trsPOffTrnsRb      as decimal      no-undo.
    define variable v-stkRealSt          as decimal      no-undo.
    define variable v-stkPOffSt          as decimal      no-undo.
    define variable v-stkRealLt          as decimal      no-undo.
    define variable v-stkPOffLt          as decimal      no-undo.
    define variable v-stkRealRb          as decimal      no-undo.
    define variable v-stkPOffRb          as decimal      no-undo.
    define variable v-arh-exists         as logical      no-undo.
    define variable v-sum-St-start    as decimal      no-undo.
    define variable v-sum-Lt-start    as decimal      no-undo.
    define variable v-sum-Rb-start    as decimal      no-undo.
    define variable v-sum-St-end      as decimal      no-undo.
    define variable v-sum-Lt-end      as decimal      no-undo.
    define variable v-sum-Rb-end      as decimal      no-undo.
    define buffer buf_arh-wth-tot       for ub.arh-wth-tot.
do
for buf_arh-wth-tot
on error undo, return error
:
    assign
        v-sum-St-start = 0.0
        v-sum-Lt-start = 0.0
        v-sum-Rb-start = 0.0
    .
    find last buf_arh-wth-tot
        where buf_arh-wth-tot.obj-type       = p-obj-type
          and buf_arh-wth-tot.obj-code       = p-obj-code
          and buf_arh-wth-tot.wth-code       = p-wth-code
          and buf_arh-wth-tot.par-code       = p-par-code
          and buf_arh-wth-tot.ext-doc-type   = p-ext-doc-type
          and buf_arh-wth-tot.sum-type       = p-sum-type
          and buf_arh-wth-tot.fact-order    <= p-fact-order-from
    use-index pi
    no-error.
    if available buf_arh-wth-tot
    then do:
        assign
            v-sum-St-start = buf_arh-wth-tot.in-qnty - buf_arh-wth-tot.out-qnty
            v-sum-Lt-start = ( buf_arh-wth-tot.in-qnty - buf_arh-wth-tot.out-qnty ) * p-par-val
            v-sum-Rb-start = buf_arh-wth-tot.in-sum-rubl - buf_arh-wth-tot.out-sum-rubl
        .
    end.
    assign
        v-sum-St-end   = 0.0
        v-sum-Lt-end   = 0.0
        v-sum-Rb-end   = 0.0
    .
    find last buf_arh-wth-tot
        where buf_arh-wth-tot.obj-type       = p-obj-type
          and buf_arh-wth-tot.obj-code       = p-obj-code
          and buf_arh-wth-tot.wth-code       = p-wth-code
          and buf_arh-wth-tot.par-code       = p-par-code
          and buf_arh-wth-tot.ext-doc-type   = p-ext-doc-type
          and buf_arh-wth-tot.sum-type       = p-sum-type
          and buf_arh-wth-tot.fact-order    <= p-fact-order-to
    use-index pi
    no-error.
    if available buf_arh-wth-tot
    then do:
        assign
            v-sum-St-end   = buf_arh-wth-tot.in-qnty - buf_arh-wth-tot.out-qnty
            v-sum-Lt-end   = ( buf_arh-wth-tot.in-qnty - buf_arh-wth-tot.out-qnty ) * p-par-val
            v-sum-Rb-end   = buf_arh-wth-tot.in-sum-rubl - buf_arh-wth-tot.out-sum-rubl
        .
    end.
    run rwthobxl-sheet1-add-line-data in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-wth-code
        , input p-par-code
        , input p-ext-doc-type
        , input p-sum-type
        , input v-sum-St-start
        , input v-sum-Lt-start
        , input v-sum-Rb-start
    ).
    run rwthobxl-sheet3-add-line-data in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-wth-code
        , input p-par-code
        , input p-ext-doc-type
        , input p-sum-type
        , input v-sum-St-end
        , input v-sum-Lt-end
        , input v-sum-Rb-end
    ).
    assign
        v-incIncmSt     = 0.0
        v-incIncmLt     = 0.0
        v-incRetnSt     = 0.0
        v-incRetnLt     = 0.0
        v-outSaleSt     = 0.0
        v-outSaleLt     = 0.0
        v-outSaleRb     = 0.0
        v-outExchSt     = 0.0
        v-outExchLt     = 0.0
        v-outExchRb     = 0.0
        v-payPaydDeskSt = 0.0
        v-payPaydDeskLt = 0.0
        v-payPaydDeskRb = 0.0
        v-payPaydSt     = 0.0
        v-payPaydLt     = 0.0
        v-payPaydRb     = 0.0
        v-payExchSt     = 0.0
        v-payExchLt     = 0.0
        v-payExchRb     = 0.0
        v-payRetnSt     = 0.0
        v-payRetnLt     = 0.0
        v-payRetnRb     = 0.0
        v-clrRealSt     = 0.0
        v-clrRealLt     = 0.0
        v-clrRealRb     = 0.0
        v-clrPOffSt     = 0.0
        v-clrPOffLt     = 0.0
        v-clrPOffRb     = 0.0
        v-trsRealExpsSt = 0.0
        v-trsRealExpsLt = 0.0
        v-trsRealIncmSt = 0.0
        v-trsRealIncmLt = 0.0
        v-trsRealTrnsSt = 0.0
        v-trsRealTrnsLt = 0.0
        v-trsPOffExpsSt = 0.0
        v-trsPOffExpsLt = 0.0
        v-trsPOffExpsRb = 0.0
        v-trsPOffIncmSt = 0.0
        v-trsPOffIncmLt = 0.0
        v-trsPOffIncmRb = 0.0
        v-trsPOffTrnsSt = 0.0
        v-trsPOffTrnsLt = 0.0
        v-trsPOffTrnsRb = 0.0
    .
    case p-ext-doc-type
    :
        when 'ie':U
        then do:
            assign
                v-incIncmSt = v-sum-St-end - v-sum-St-start
                v-incIncmLt = v-sum-Lt-end - v-sum-Lt-start
            .
        end.
        when 'ee':U
        then do:
            assign
                v-outSaleSt = - ( v-sum-St-end - v-sum-St-start )
                v-outSaleLt = - ( v-sum-Lt-end - v-sum-Lt-start )
                v-outSaleRb = - ( v-sum-Rb-end - v-sum-Rb-start )
            .
        end.
        when 'pc':U
        then do:
            assign
                v-payPaydDeskSt = v-sum-St-end - v-sum-St-start
                v-payPaydDeskLt = v-sum-Lt-end - v-sum-Lt-start
                v-payPaydDeskRb = v-sum-Rb-end - v-sum-Rb-start
            .
        end.
        when 'ps':U
        then do:
            assign
                v-payPaydSt     = v-sum-St-end - v-sum-St-start
                v-payPaydLt     = v-sum-Lt-end - v-sum-Lt-start
                v-payPaydRb     = v-sum-Rb-end - v-sum-Rb-start
            .
        end.
        when 'pz':U
        then do:
            assign
                v-payRetnSt     = v-sum-St-end - v-sum-St-start
                v-payRetnLt     = v-sum-Lt-end - v-sum-Lt-start
                v-payRetnRb     = v-sum-Rb-end - v-sum-Rb-start
            .
        end.
        when 'df':U
        then do:
            assign
                v-clrRealSt = - ( v-sum-St-end - v-sum-St-start )
                v-clrRealLt = - ( v-sum-Lt-end - v-sum-Lt-start )
                v-clrRealRb = - ( v-sum-Rb-end - v-sum-Rb-start )
            .
        end.
        when 'dp':U
        then do:
            assign
                v-clrPOffSt = - ( v-sum-St-end - v-sum-St-start )
                v-clrPOffLt = - ( v-sum-Lt-end - v-sum-Lt-start )
                v-clrPOffRb = - ( v-sum-Rb-end - v-sum-Rb-start )
            .
        end.
        when 'ip':U
        then do:
            assign
                v-trsPOffIncmSt =  ( v-sum-St-end - v-sum-St-start )
                v-trsPOffIncmLt =  ( v-sum-Lt-end - v-sum-Lt-start )
                v-trsPOffIncmRb =  ( v-sum-Rb-end - v-sum-Rb-start )
            .
        end.
        when 'ep':U
        then do:
            assign
                v-trsPOffExpsSt = - ( v-sum-St-end - v-sum-St-start )
                v-trsPOffExpsLt = - ( v-sum-Lt-end - v-sum-Lt-start )
                v-trsPOffExpsRb = - ( v-sum-Rb-end - v-sum-Rb-start )
            .
        end.
        when 'rp':U
        then do:
            assign
                v-trsPOffTrnsSt = v-sum-St-end - v-sum-St-start
                v-trsPOffTrnsLt = v-sum-Lt-end - v-sum-Lt-start
                v-trsPOffTrnsRb = v-sum-Rb-end - v-sum-Rb-start
            .
        end.
        when 'ff':U
        then do:
            assign
                v-trsRealIncmSt = v-sum-St-end - v-sum-St-start
                v-trsRealIncmLt = v-sum-Lt-end - v-sum-Lt-start
            .
        end.
        when 'ef':U
        then do:
            assign
                v-trsRealExpsSt = - ( v-sum-St-end - v-sum-St-start )
                v-trsRealExpsLt = - ( v-sum-Lt-end - v-sum-Lt-start )
            .
        end.
        when 'rf':U
        then do:
            assign
                v-trsRealTrnsSt = v-sum-St-end - v-sum-St-start
                v-trsRealTrnsLt = v-sum-Lt-end - v-sum-Lt-start
            .
        end.
        when 'xc':U
        then do:
            if p-sum-type = 'при':U
            then do:
                assign
                    v-payExchSt = v-sum-St-end - v-sum-St-start
                    v-payExchLt = v-sum-Lt-end - v-sum-Lt-start
                    v-payExchRb = v-sum-Rb-end - v-sum-Rb-start
                .
            end.
            else do:
                assign
                    v-outExchSt = - ( v-sum-St-end - v-sum-St-start )
                    v-outExchLt = - ( v-sum-Lt-end - v-sum-Lt-start )
                    v-outExchRb = - ( v-sum-Rb-end - v-sum-Rb-start )
                .
            end.
        end.
    end case.
    run rwthobxl-sheet2-add-line-data in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-wth-code
        , input p-par-code
        , input v-incIncmSt
        , input v-incIncmLt
        , input v-incRetnSt
        , input v-incRetnLt
        , input v-outSaleSt
        , input v-outSaleLt
        , input v-outSaleRb
        , input v-outExchSt
        , input v-outExchLt
        , input v-outExchRb
        , input v-payPaydDeskSt
        , input v-payPaydDeskLt
        , input v-payPaydDeskRb
        , input v-payPaydSt
        , input v-payPaydLt
        , input v-payPaydRb
        , input v-payExchSt
        , input v-payExchLt
        , input v-payExchRb
        , input v-payRetnSt
        , input v-payRetnLt
        , input v-payRetnRb
        , input v-clrRealSt
        , input v-clrRealLt
        , input v-clrRealRb
        , input v-clrPOffSt
        , input v-clrPOffLt
        , input v-clrPOffRb
        , input v-trsRealExpsSt
        , input v-trsRealExpsLt
        , input v-trsRealIncmSt
        , input v-trsRealIncmLt
        , input v-trsRealTrnsSt
        , input v-trsRealTrnsLt
        , input v-trsPOffExpsSt
        , input v-trsPOffExpsLt
        , input v-trsPOffExpsRb
        , input v-trsPOffIncmSt
        , input v-trsPOffIncmLt
        , input v-trsPOffIncmRb
        , input v-trsPOffTrnsSt
        , input v-trsPOffTrnsLt
        , input v-trsPOffTrnsRb
    ).
end.
end procedure.
procedure get-hide-list :
define input parameter p-ext-doc-type-list  as character        no-undo.
define input parameter p-ob-liter           as logical          no-undo.
define input parameter p-ob-rubl            as logical          no-undo.
define input parameter p-ob-tal             as logical          no-undo.
define output parameter p-hide-list         as character        no-undo.
    define variable v-counter       as integer      no-undo.
    define variable v-rec-amount    as integer      no-undo.
    define variable v-ext-doc-type  as character    no-undo.
    define buffer buf_temp_hideCol      for temp_hideCol.
do
for buf_temp_hideCol
on error undo, return error
:
    empty temp-table buf_temp_hideCol.
    if p-ob-tal = no
    then do:
        assign
            v-rec-amount =  num-entries( "incIncmSt,incRetnSt,outSaleSt,outExchSt,payPaydDeskSt,payPaydSt,payExchSt,payRetnSt,clrRealSt,clrPOffSt,trsRealExpsSt,trsRealIncmSt,trsRealTrnsSt,trsPOffExpsSt,trsPOffIncmSt,trsPOffTrnsSt":U )
        .
        do v-counter = 1 to v-rec-amount
        :
            run hide-list-add-item in this-procedure ( input entry( v-counter, "incIncmSt,incRetnSt,outSaleSt,outExchSt,payPaydDeskSt,payPaydSt,payExchSt,payRetnSt,clrRealSt,clrPOffSt,trsRealExpsSt,trsRealIncmSt,trsRealTrnsSt,trsPOffExpsSt,trsPOffIncmSt,trsPOffTrnsSt":U ) ).
        end.
    end.
    if p-ob-liter = no
    then do:
        assign
            v-rec-amount =  num-entries( "incIncmLt,incRetnLt,outSaleLt,outExchLt,payPaydDeskLt,payPaydLt,payExchLt,payRetnLt,clrRealLt,clrPOffLt,trsRealExpsLt,trsRealIncmLt,trsRealTrnsLt,trsPOffExpsLt,trsPOffIncmLt,trsPOffTrnsLt":U )
        .
        do v-counter = 1 to v-rec-amount
        :
            run hide-list-add-item in this-procedure ( input entry( v-counter, "incIncmLt,incRetnLt,outSaleLt,outExchLt,payPaydDeskLt,payPaydLt,payExchLt,payRetnLt,clrRealLt,clrPOffLt,trsRealExpsLt,trsRealIncmLt,trsRealTrnsLt,trsPOffExpsLt,trsPOffIncmLt,trsPOffTrnsLt":U ) ).
        end.
    end.
    if p-ob-rubl  = no
    then do:
        assign
            v-rec-amount =  num-entries( "outSaleRb,outExchRb,payPaydRb,payExchRb,payPaydDeskRb,payRetnRb,clrRealRb,clrPOffRb,trsPOffExpsRb,trsPOffIncmRb,trsPOffTrnsRb":U )
        .
        do v-counter = 1 to v-rec-amount
        :
            run hide-list-add-item in this-procedure ( input entry( v-counter, "outSaleRb,outExchRb,payPaydRb,payExchRb,payPaydDeskRb,payRetnRb,clrRealRb,clrPOffRb,trsPOffExpsRb,trsPOffIncmRb,trsPOffTrnsRb":U ) ).
        end.
    end.
    if p-ext-doc-type-list <> "":U
    then do:
        assign
            v-rec-amount =  num-entries( 'ie,ee,ii,ei,ij,ej,fj,jj,pj,oj,we,ci,ce,iy,rj,ip,ep,rp,ff,ef,rf,pc,ps,pz,df,dp,dc,de,xc':u )
        .
        do v-counter = 1 to v-rec-amount
        :
            assign
                v-ext-doc-type = entry( v-counter, 'ie,ee,ii,ei,ij,ej,fj,jj,pj,oj,we,ci,ce,iy,rj,ip,ep,rp,ff,ef,rf,pc,ps,pz,df,dp,dc,de,xc':u )
            .
            if lookup( v-ext-doc-type, p-ext-doc-type-list ) = 0
            then do:
                case v-ext-doc-type
                :
                    when 'ie':U
                    then do:
                        run hide-list-add-item in this-procedure ( input "incIncmSt":U ).
                        run hide-list-add-item in this-procedure ( input "incIncmLt":U ).
                    end.
                    when 'ee':U
                    then do:
                        run hide-list-add-item in this-procedure ( input "outSaleSt":U ).
                        run hide-list-add-item in this-procedure ( input "outSaleLt":U ).
                    end.
                    when 'pc':U
                    then do:
                        run hide-list-add-item in this-procedure ( input "payPaydDeskSt":U ).
                        run hide-list-add-item in this-procedure ( input "payPaydDeskLt":U ).
                        run hide-list-add-item in this-procedure ( input "payPaydDeskRb":U ).
                    end.
                    when 'ps':U
                    then do:
                        run hide-list-add-item in this-procedure ( input "payPaydSt":U ).
                        run hide-list-add-item in this-procedure ( input "payPaydLt":U ).
                        run hide-list-add-item in this-procedure ( input "payPaydRb":U ).
                    end.
                    when 'pz':U
                    then do:
                        run hide-list-add-item in this-procedure ( input "payRetnSt":U ).
                        run hide-list-add-item in this-procedure ( input "payRetnLt":U ).
                        run hide-list-add-item in this-procedure ( input "payRetnRb":U ).
                    end.
                    when 'df':U
                    then do:
                        run hide-list-add-item in this-procedure ( input "clrRealSt":U ).
                        run hide-list-add-item in this-procedure ( input "clrRealLt":U ).
                        run hide-list-add-item in this-procedure ( input "clrRealRb":U ).
                    end.
                    when 'dp':U
                    then do:
                        run hide-list-add-item in this-procedure ( input "clrPOffSt":U ).
                        run hide-list-add-item in this-procedure ( input "clrPOffLt":U ).
                        run hide-list-add-item in this-procedure ( input "clrPOffRb":U ).
                    end.
                    when 'ip':U
                    then do:
                        run hide-list-add-item in this-procedure ( input "trsPOffIncmSt":U ).
                        run hide-list-add-item in this-procedure ( input "trsPOffIncmLt":U ).
                        run hide-list-add-item in this-procedure ( input "trsPOffIncmRb":U ).
                    end.
                    when 'ep':U
                    then do:
                        run hide-list-add-item in this-procedure ( input "trsPOffExpsSt":U ).
                        run hide-list-add-item in this-procedure ( input "trsPOffExpsLt":U ).
                        run hide-list-add-item in this-procedure ( input "trsPOffExpsRb":U ).
                    end.
                    when 'rp':U
                    then do:
                        run hide-list-add-item in this-procedure ( input "trsPOffTrnsSt":U ).
                        run hide-list-add-item in this-procedure ( input "trsPOffTrnsLt":U ).
                        run hide-list-add-item in this-procedure ( input "trsPOffTrnsRb":U ).
                    end.
                    when 'ff':U
                    then do:
                        run hide-list-add-item in this-procedure ( input "trsRealIncmSt":U ).
                        run hide-list-add-item in this-procedure ( input "trsRealIncmLt":U ).
                    end.
                    when 'ef':U
                    then do:
                        run hide-list-add-item in this-procedure ( input "trsRealExpsSt":U ).
                        run hide-list-add-item in this-procedure ( input "trsRealExpsLt":U ).
                    end.
                    when 'rf':U
                    then do:
                        run hide-list-add-item in this-procedure ( input "trsRealTrnsSt":U ).
                        run hide-list-add-item in this-procedure ( input "trsRealTrnsLt":U ).
                    end.
                    when 'xc':U
                    then do:
                        run hide-list-add-item in this-procedure ( input "payExchSt":U ).
                        run hide-list-add-item in this-procedure ( input "payExchLt":U ).
                        run hide-list-add-item in this-procedure ( input "payExchRb":U ).
                        run hide-list-add-item in this-procedure ( input "outExchSt":U ).
                        run hide-list-add-item in this-procedure ( input "outExchLt":U ).
                        run hide-list-add-item in this-procedure ( input "outExchRb":U ).
                    end.
                end case.
            end.
        end.
    end.
    assign
        p-hide-list = "":U
    .
    for each buf_temp_hideCol
    on error undo, return error
    :
        assign
            p-hide-list = substitute( "&1&2&3"
                                    , p-hide-list
                                    , ( if p-hide-list = "":U then "":U else ",":U )
                                    , buf_temp_hideCol.colName )
        .
    end.
end.
end procedure.
procedure hide-list-add-item :
define input parameter p-item-name  as character        no-undo.
    define buffer buf_temp_hideCol      for temp_hideCol.
do
for buf_temp_hideCol
on error undo, return error
:
    find first buf_temp_hideCol
         where buf_temp_hideCol.colName = p-item-name
    no-error.
    if not available buf_temp_hideCol
    then do:
        create buf_temp_hideCol.
        assign
            buf_temp_hideCol.colName = p-item-name
        .
    end.
end.
end procedure.
procedure write-stLtRbList :
define input parameter p-ob-tal   as logical          no-undo.
define input parameter p-ob-liter as logical          no-undo.
define input parameter p-ob-rubl  as logical          no-undo.
    define variable v-stLtRbList    as character    no-undo.
    define variable v-list-num      as integer      no-undo.
do
on error undo, return error
:
    assign
        v-stLtRbList = "":U
    .
    if p-ob-tal = yes
    then do:
        assign
            v-stLtRbList = substitute( "&1&2&3":U
                            , v-stLtRbList
                            , ( if v-stLtRbList = "":U then "":U else ",":U )
                            , "количестве талонов"
                            )
        .
    end.
    if p-ob-liter = yes
    then do:
        assign
            v-stLtRbList = substitute( "&1&2&3":U
                            , v-stLtRbList
                            , ( if v-stLtRbList = "":U then "":U else ",":U )
                            , "л топлива"
                            )
        .
    end.
    if p-ob-rubl = yes
    then do:
        assign
            v-stLtRbList = substitute( "&1&2&3":U
                            , v-stLtRbList
                            , ( if v-stLtRbList = "":U then "":U else ",":U )
                            , "суммах в рубл"
                            )
        .
    end.
                run rwthobxl-write-cell-data in this-procedure (
                  input "НачалоПериода_showStLtRb1":U
                , input v-stLtRbList
            ).
end.
end procedure.
