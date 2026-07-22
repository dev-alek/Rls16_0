block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-host-name   as character no-undo .
define input parameter p-supp-type like ub.clients.obj-type no-undo .
define input parameter p-supp-code like ub.clients.obj-code no-undo .
define input parameter p-supp-name like ub.clients.obj-name no-undo .
define input parameter RS-by       as integer no-undo .
define input parameter T-parts     as logical no-undo .
define input parameter p-report-header as character no-undo .
define output parameter p-frame-width as integer no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-komis.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/r-komis.p $":U .
define variable vss-description as character no-undo init "Печать отчета РЕАЛИЗАЦИЯ КОМИССИОННОГО ТОВАРА".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    define buffer   in-vatp-trn-doc  for ub.trn-doc .
    define buffer   in-vatp-parts    for ub.parts   .
    define buffer   in-vatp-doc      for ub.trn-doc .
    define buffer   in-vatp-goods    for ub.goods   .
    define buffer   in-vatp-sysconf  for ub.sysconf .
    define buffer   in-vatp_doc-attr for ub.doc-attr.
    define variable in-vatp-have-vat-slt       as   logical initial yes    no-undo.
    define variable vat-pc-loc                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprb                  as   character              no-undo.
    define variable slt-pc-loc                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rate              as   decimal                no-undo.
    define variable price-rubl-with-tax-loc    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loc    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loc     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loc like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loc like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loc  like ub.doc-line.price-base no-undo.
    define variable vat-base-loc               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loc               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loc           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loc         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loc         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loc          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loc             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loc             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loc              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loc          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envd             as   character              no-undo.
    define variable varinvatp-type             as   character              no-undo.
    define  variable price-rubl-with-tax-sale    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-sale    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-sale like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-sale like ub.doc-line.price-base no-undo.
    define  variable vat-base-sale               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-sale               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyer              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyer              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-sale               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-sale               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-sale          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-sale          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-sale            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-sale            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-sale            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-sale            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtl     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtl for ub.gds-dtl.
    define buffer out-vatp_parts       for ub.parts.
    define buffer out-vatp_sysconf     for ub.sysconf.
    define buffer out-vatp_doc-line    for ub.doc-line.
    define buffer out-vatp_goods       for ub.goods.
    define buffer out-vatp_trn-doc     for ub.trn-doc.
    define buffer out-vatp_doc-attr    for ub.doc-attr.
    define variable varprice-base-cons      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-cons      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-type         as   character                           no-undo.
    define variable varfrm-cnsv              as   character                           no-undo.
    define variable varroot-node             as   integer                             no-undo.
    define variable varempty-scale           as   logical                             no-undo.
    define variable varis-cons-parts-have    as   logical                             no-undo.
    define variable varsum-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovp  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovp   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovp  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovp   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qnty             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qnty             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtl        as   logical                             no-undo.
    define variable varcurprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurdiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurdiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprb               as   character                           no-undo.
    define variable out-vatp-have-vat-slt    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-doco  for ub.trn-doc .
    define buffer   in-vatp-partso    for ub.parts   .
    define buffer   in-vatp-doco      for ub.trn-doc .
    define buffer   in-vatp-goodso    for ub.goods   .
    define buffer   in-vatp-sysconfo  for ub.sysconf .
    define buffer   in-vatp_doc-attro for ub.doc-attr.
    define variable in-vatp-have-vat-slto       as   logical initial yes    no-undo.
    define variable vat-pc-loco                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbo                  as   character              no-undo.
    define variable slt-pc-loco                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateo              as   decimal                no-undo.
    define variable price-rubl-with-tax-loco    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loco    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loco     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loco like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loco like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loco  like ub.doc-line.price-base no-undo.
    define variable vat-base-loco               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loco               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loco                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loco               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loco               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loco                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loco          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loco          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loco           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loco         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loco         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loco          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loco             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loco             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loco              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loco          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdo             as   character              no-undo.
    define variable varinvatp-typeo             as   character              no-undo.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define buffer cli_supp for ub.clients.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table sj-goods no-undo
field artic     like ub.goods.artic
field prod-type like ub.goods.prod-type
field prod-code like ub.goods.prod-code
field in-code like ub.parts.in-code
field part-code like ub.parts.part-code
field is-out_    as integer
field gds-name   like ub.goods.gds-name format "x(30)"
field unit like ub.goods.unit-base
field qnty              as   decimal
field VAT-supp  like ub.parts.VAT-pc
field SLT-supp  like ub.parts.SLT-pc
FIELD price-without-tax-cost_ like ub.doc-line.price-rubl
FIELD sum-without-tax-cost_ like ub.doc-line.price-rubl
FIELD sum-vat-cost_        like ub.doc-line.price-rubl
FIELD price-with-tax-cost_ like ub.doc-line.price-rubl
FIELD sum-with-tax-cost_  like ub.doc-line.price-rubl
FIELD price-without-tax-sale_ like ub.doc-line.price-rubl
FIELD sum-with-tax-sale_  like ub.doc-line.price-rubl
FIELD sum-without-tax-sale_ like ub.doc-line.price-rubl
FIELD sum-vat-sale_  like ub.doc-line.price-rubl
FIELD sum-slt-sale_  like ub.doc-line.price-rubl
INDEX pi
artic
prod-type
prod-code
is-out_
Vat-supp
price-with-tax-cost_
in-code
part-code
.
DEFINE VARIABLE my-accum as integer no-undo .
define buffer t-doc for ub.trn-doc.
procedure cr-sj-goods :
define input parameter doc-num like ub.trn-doc.doc-code no-undo.
define input parameter is-out as integer no-undo .
define input parameter ocons-pay like ub.sysconf.purch-code no-undo .
define input parameter ocons-pay-2 like ub.sysconf.purch-code no-undo .
DEFINE VARIABLE prt-qnty as decimal no-undo .
DEFINE VARIABLE v-gds-code like ub.goods.gds-code no-undo .
DEFINE VARIABLE         v-parts-VAt-pc  like ub.parts-attr.vat-pc           no-undo .
DEFINE VARIABLE         v-parts-SLT-pc  like ub.parts-attr.SLT-pc           no-undo .
DEFINE VARIABLE         v-in-code       like ub.parts-attr.income-in-code   no-undo .
DEFINE VARIABLE         v-part-code     like ub.parts-attr.income-part-code no-undo .
define  variable price-rubl-without-tax-sale-b like ub.doc-line.price-rubl no-undo.
define buffer buf_parts-attr for ub.parts-attr.
    define buffer   in-vatp-trn-doc  for ub.trn-doc .
    define buffer   in-vatp-parts    for ub.parts   .
    define buffer   in-vatp-doc      for ub.trn-doc .
    define buffer   in-vatp-goods    for ub.goods   .
    define buffer   in-vatp-sysconf  for ub.sysconf .
    define buffer   in-vatp_doc-attr for ub.doc-attr.
    define variable in-vatp-have-vat-slt       as   logical initial yes    no-undo.
    define variable vat-pc-loc                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprb                  as   character              no-undo.
    define variable slt-pc-loc                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rate              as   decimal                no-undo.
    define variable price-rubl-with-tax-loc    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loc    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loc     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loc like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loc like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loc  like ub.doc-line.price-base no-undo.
    define variable vat-base-loc               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loc               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loc           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loc         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loc         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loc          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loc             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loc             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loc              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loc          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envd             as   character              no-undo.
    define variable varinvatp-type             as   character              no-undo.
    define  variable price-rubl-with-tax-sale    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-sale    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-sale like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-sale like ub.doc-line.price-base no-undo.
    define  variable vat-base-sale               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-sale               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyer              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyer              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-sale               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-sale               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-sale          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-sale          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-sale            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-sale            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-sale            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-sale            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtl     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtl for ub.gds-dtl.
    define buffer out-vatp_parts       for ub.parts.
    define buffer out-vatp_sysconf     for ub.sysconf.
    define buffer out-vatp_doc-line    for ub.doc-line.
    define buffer out-vatp_goods       for ub.goods.
    define buffer out-vatp_trn-doc     for ub.trn-doc.
    define buffer out-vatp_doc-attr    for ub.doc-attr.
    define variable varprice-base-cons      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-cons      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-type         as   character                           no-undo.
    define variable varfrm-cnsv              as   character                           no-undo.
    define variable varroot-node             as   integer                             no-undo.
    define variable varempty-scale           as   logical                             no-undo.
    define variable varis-cons-parts-have    as   logical                             no-undo.
    define variable varsum-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovp  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovp   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovp  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovp   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qnty             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qnty             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtl        as   logical                             no-undo.
    define variable varcurprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurdiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurdiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprb               as   character                           no-undo.
    define variable out-vatp-have-vat-slt    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-doco  for ub.trn-doc .
    define buffer   in-vatp-partso    for ub.parts   .
    define buffer   in-vatp-doco      for ub.trn-doc .
    define buffer   in-vatp-goodso    for ub.goods   .
    define buffer   in-vatp-sysconfo  for ub.sysconf .
    define buffer   in-vatp_doc-attro for ub.doc-attr.
    define variable in-vatp-have-vat-slto       as   logical initial yes    no-undo.
    define variable vat-pc-loco                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbo                  as   character              no-undo.
    define variable slt-pc-loco                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateo              as   decimal                no-undo.
    define variable price-rubl-with-tax-loco    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loco    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loco     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loco like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loco like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loco  like ub.doc-line.price-base no-undo.
    define variable vat-base-loco               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loco               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loco                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loco               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loco               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loco                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loco          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loco          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loco           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loco         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loco         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loco          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loco             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loco             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loco              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loco          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdo             as   character              no-undo.
    define variable varinvatp-typeo             as   character              no-undo.
  do
  on error undo, return error
  :
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FOR  each ub.doc-line NO-LOCk WHERE
         ub.doc-line.doc-code = doc-num:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run doclicod in g#library
  (input  recid(ub.doc-line)
  ,output v-gds-code
  ) no-error .
  if error-status:error then do:
   next.
  end.
  assign
  my-accum = my-accum + 1
  .
  IF my-accum MODULO 50  = 0 then do:
    run waitfram-show in this-procedure ("Обработано " + string(my-accum) + " строк накладных ").
  end.
if t-doc.ext-doc-type = 'ot':U or
   t-doc.ext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-slt = yes.
end.
else do:
  find first out-vatp_doc-attr no-lock
    where out-vatp_doc-attr.doc-code  = t-doc.doc-code
      and out-vatp_doc-attr.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attr then do:
    assign
      out-vatp-have-vat-slt = yes.
  end.
  else do:
     out-vatp-have-vat-slt = no.
  end.
end.
find first out-vatp_goods where out-vatp_goods.artic     = ub.doc-line.artic     and
                                   out-vatp_goods.prod-type = ub.doc-line.prod-type and
                                   out-vatp_goods.prod-code = ub.doc-line.prod-code no-lock.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  ub.doc-line.artic
  ,input  ub.doc-line.prod-type
  ,input  ub.doc-line.prod-code
  ,output varroot-node
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-node
  ,input  'empty-scale=request'
  ,output varempty-scale
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
    "Признак" varroot-node skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprb
  )  .
if varoutvprb = "base":u then do:
  assign
        road-tax-base-sale    =  (if ub.doc-line.road-tax = ? then 0 else ub.doc-line.road-tax * 1)
    excise-base-sale      =  (if ub.doc-line.excise   = ? then 0 else ub.doc-line.excise   * 1)
  .
end.
else do:
  assign
        road-tax-base-sale    =  (if ub.doc-line.road-tax = ? then 0 else ub.doc-line.road-tax / t-doc.base-rate * t-doc.base-scale)
    excise-base-sale      =  (if ub.doc-line.excise   = ? then 0 else ub.doc-line.excise   / t-doc.base-rate * t-doc.base-scale)
  .
end.
if varoutvprb = "rubl":u then do:
  assign
        road-tax-rubl-sale    = (if ub.doc-line.road-tax = ? then 0 else ub.doc-line.road-tax * 1)
    excise-rubl-sale      = (if ub.doc-line.excise   = ? then 0 else ub.doc-line.excise   * 1) .
end.
else do:
  assign
        road-tax-rubl-sale    = (if ub.doc-line.road-tax = ? then 0 else ub.doc-line.road-tax * t-doc.base-rate / t-doc.base-scale)
    excise-rubl-sale      = (if ub.doc-line.excise   = ? then 0 else ub.doc-line.excise   * t-doc.base-rate / t-doc.base-scale) .
end.
assign
  varis-cons-parts-have =  no.
assign
  varfact-qnty       = 0
  varcons-qnty       = 0
  varprice-base-cons = 0
  varprice-rubl-cons = 0.
find first out-vatp_doc-line where
           out-vatp_doc-line.doc-code   = t-doc.doc-code
       and out-vatp_doc-line.artic      = ub.doc-line.artic
       and out-vatp_doc-line.prod-type  = ub.doc-line.prod-type
       and out-vatp_doc-line.prod-code  = ub.doc-line.prod-code no-lock no-error.
if available out-vatp_doc-line           and
  (out-vatp_doc-line.status_ = 'запрос':U or out-vatp_goods.gds-type = 'у':U) then do:
  assign
    varfact-qnty = out-vatp_doc-line.fact-qnty.
end.
else do:
  for each out-vatp_parts where out-vatp_parts.out-code   = t-doc.doc-code
                               and out-vatp_parts.obj-type   = t-doc.obj-type
                               and out-vatp_parts.obj-code   = t-doc.obj-code
                               and out-vatp_parts.artic      = ub.doc-line.artic
                               and out-vatp_parts.prod-type  = ub.doc-line.prod-type
                               and out-vatp_parts.prod-code  = ub.doc-line.prod-code no-lock :
    if out-vatp_parts.purch-code = 2 then do:
assign
  price-rubl-with-tax-loco = out-vatp_parts.price-rubl
  price-base-with-tax-loco = out-vatp_parts.price-base
.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbo
  )  .
  if out-vatp_parts.out-code = 'free-zone':U     or
     out-vatp_parts.out-code = 'out-zone':U   or
     out-vatp_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slto = yes.
  end.
  else do:
    find first in-vatp_doc-attro no-lock
      where in-vatp_doc-attro.doc-code  = out-vatp_parts.out-code
        and in-vatp_doc-attro.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attro then do:
      assign
        in-vatp-have-vat-slto = yes.
    end.
    else do:
         in-vatp-have-vat-slto = no.
    end.
  end.
  assign
   price-cli-with-tax-loco = out-vatp_parts.price-cli
   cli-base-rateo          = out-vatp_parts.cli-base-rate.
  ASSIGN   road-tax-base-loco  = (if out-vatp_parts.road-tax-base  = ? then 0 else out-vatp_parts.road-tax-base)
           road-tax-rubl-loco  = (if out-vatp_parts.road-tax-rubl  = ? then 0 else out-vatp_parts.road-tax-rubl).
  ASSIGN  transport-base-loco = (if out-vatp_parts.transport-base = ? then 0 else out-vatp_parts.transport-base)
          transport-rubl-loco = (if out-vatp_parts.transport-rubl = ? then 0 else out-vatp_parts.transport-rubl)
          other-base-loco     = (if out-vatp_parts.other-base     = ? then 0 else out-vatp_parts.other-base)
          other-rubl-loco     = (if out-vatp_parts.other-rubl     = ? then 0 else out-vatp_parts.other-rubl)
          vat-pc-loco         = (if out-vatp_parts.vat-pc         = ? then 0 else out-vatp_parts.vat-pc)
          slt-pc-loco         = (if out-vatp_parts.slt-pc         = ? then 0 else out-vatp_parts.slt-pc).
          ASSIGN   slt-base-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-base-with-tax-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco)))                           * slt-pc-loco / (100 + slt-pc-loco))                        vat-base-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-base-with-tax-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco))) * (1 - slt-pc-loco / (100 + slt-pc-loco)) * vat-pc-loco / (100 + vat-pc-loco)).
    ASSIGN   slt-rubl-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-rubl-with-tax-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco)))                           * slt-pc-loco / (100 + slt-pc-loco))                        vat-rubl-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-rubl-with-tax-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco))) * (1 - slt-pc-loco / (100 + slt-pc-loco)) * vat-pc-loco / (100 + vat-pc-loco)).
  assign
    exch-rate-cli-loco = (out-vatp_parts.price-rubl - transport-rubl-loco - other-rubl-loco - road-tax-rubl-loco - (if out-vatp_parts.vat-type <> 'в т. ч.':U then vat-rubl-loco else 0) - (if out-vatp_parts.slt-type <> 'в т. ч.':U then slt-rubl-loco else 0)) / out-vatp_parts.price-cli .
  assign
    slt-cli-loco        = slt-rubl-loco       / exch-rate-cli-loco
    vat-cli-loco        = vat-rubl-loco       / exch-rate-cli-loco
    road-tax-cli-loco   = road-tax-rubl-loco  / exch-rate-cli-loco
    transport-cli-loco  = 0
    other-cli-loco      = 0
  .
ASSIGN
          price-base-without-tax-loco = price-base-with-tax-loco - vat-base-loco - slt-base-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco))
    price-rubl-without-tax-loco = price-rubl-with-tax-loco - vat-rubl-loco - slt-rubl-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco))
.
      assign
        varprice-base-cons = varprice-base-cons + (price-base-with-tax-loco - (if road-tax-base-loco = ? then 0 else road-tax-base-loco))* out-vatp_parts.fact-qnty
        varprice-rubl-cons = varprice-rubl-cons + (price-rubl-with-tax-loco - (if road-tax-rubl-loco = ? then 0 else road-tax-rubl-loco))* out-vatp_parts.fact-qnty.
      assign
        varis-cons-parts-have = yes
        varcons-qnty          = varcons-qnty + out-vatp_parts.fact-qnty.
    end.
    assign
      varfact-qnty = varfact-qnty + out-vatp_parts.fact-qnty.
  end.
end.
assign
  varprice-base-cons = varprice-base-cons / varcons-qnty
  varprice-rubl-cons = varprice-rubl-cons / varcons-qnty.
if varprice-base-cons = ? then do:
  assign
    varprice-base-cons = 0.
end.
if varprice-rubl-cons = ? then do:
  assign
    varprice-rubl-cons = 0.
end.
assign
  varsum-base-factovp     = 0
  varslt-base-factovp     = 0
  varvat-base-factovp     = 0
  varvatcons-base-factovp = 0
  vardsc-base-factovp     = 0
  varsum-base-docovp      = 0
  varslt-base-docovp      = 0
  varvat-base-docovp      = 0
  varvatcons-base-docovp  = 0
  vardsc-base-docovp      = 0
  varsum-rubl-factovp     = 0
  varslt-rubl-factovp     = 0
  varvat-rubl-factovp     = 0
  varvatcons-rubl-factovp = 0
  vardsc-rubl-factovp     = 0
  varsum-rubl-docovp      = 0
  varslt-rubl-docovp      = 0
  varvat-rubl-docovp      = 0
  varvatcons-rubl-docovp  = 0
  vardsc-rubl-docovp      = 0.
assign
  varis-one-gds-dtl = no.
find first out-vatp_gds-dtl where out-vatp_gds-dtl.doc-code  = t-doc.doc-code  and
                                     out-vatp_gds-dtl.artic     = ub.doc-line.artic     and
                                     out-vatp_gds-dtl.prod-type = ub.doc-line.prod-type and
                                     out-vatp_gds-dtl.prod-code = ub.doc-line.prod-code no-lock no-error.
if available out-vatp_gds-dtl then do:
  find first buf_out-vatp_gds-dtl where buf_out-vatp_gds-dtl.doc-code  =  t-doc.doc-code                and
                                           buf_out-vatp_gds-dtl.artic     =  ub.doc-line.artic                   and
                                           buf_out-vatp_gds-dtl.prod-type =  ub.doc-line.prod-type               and
                                           buf_out-vatp_gds-dtl.prod-code =  ub.doc-line.prod-code               and
                                           recid(buf_out-vatp_gds-dtl)    <> recid(out-vatp_gds-dtl) no-lock no-error.
  if not available buf_out-vatp_gds-dtl then do:
    assign
      varis-one-gds-dtl = yes.
  end.
  if varoutvprb = "base":u then do:
    assign
      varcurprice-base = out-vatp_gds-dtl.cur-base
      varcurprice-rubl = out-vatp_gds-dtl.cur-base * ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) / (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base)).
  end.
  else do:
    assign
      varcurprice-base = out-vatp_gds-dtl.cur-base / ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) / (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base))
      varcurprice-rubl = out-vatp_gds-dtl.cur-base.
  end.
  if varempty-scale    = yes or
     varis-one-gds-dtl = yes   then do:
    assign
                price-base-with-tax-sale    = (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base)
        slt-base-sale               = (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc)
        vat-base-buyer              = (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-base-sale) * ub.doc-line.vat-pc / (100 + ub.doc-line.vat-pc)
        discnt-base-sale            = out-vatp_gds-dtl.discnt-base
                price-rubl-with-tax-sale    = (out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl)
        slt-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc)
        vat-rubl-buyer              = (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-rubl-sale) * ub.doc-line.vat-pc / (100 + ub.doc-line.vat-pc)
        discnt-rubl-sale            = out-vatp_gds-dtl.discnt-rubl
        .
    if t-doc.doc-type = 'инв':U then do:
      ASSIGN
                vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * ub.doc-line.cons-vat-pc / (100 + ub.doc-line.cons-vat-pc) * out-vatp_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-base-sale) * ub.doc-line.vat-pc / (100 + ub.doc-line.vat-pc) * out-vatp_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
                vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * ub.doc-line.cons-vat-pc / (100 + ub.doc-line.cons-vat-pc) * out-vatp_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-rubl-sale) * ub.doc-line.vat-pc / (100 + ub.doc-line.vat-pc) * out-vatp_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
        .
    end.
    else do:
      ASSIGN
                vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * ub.doc-line.cons-vat-pc / (100 + ub.doc-line.cons-vat-pc) * out-vatp_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-base-sale ) * ub.doc-line.vat-pc / (100 + ub.doc-line.vat-pc) * out-vatp_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
                vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * ub.doc-line.cons-vat-pc / (100 + ub.doc-line.cons-vat-pc) * out-vatp_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-rubl-sale) * ub.doc-line.vat-pc / (100 + ub.doc-line.vat-pc) * out-vatp_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
        .
    end.
  end.
  else do:
    for each out-vatp_gds-dtl where out-vatp_gds-dtl.doc-code  = t-doc.doc-code  and
                                       out-vatp_gds-dtl.artic     = ub.doc-line.artic     and
                                       out-vatp_gds-dtl.prod-type = ub.doc-line.prod-type and
                                       out-vatp_gds-dtl.prod-code = ub.doc-line.prod-code no-lock :
      if varoutvprb = "base":u then do:
        assign
          varcurprice-base = out-vatp_gds-dtl.cur-base
          varcurprice-rubl = out-vatp_gds-dtl.cur-base * ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) / (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base)).
      end.
      else do:
        assign
          varcurprice-base = out-vatp_gds-dtl.cur-base / ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) / (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base))
          varcurprice-rubl = out-vatp_gds-dtl.cur-base.
      end.
      assign
             varsum-base-factovp = varsum-base-factovp + (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base)                 * out-vatp_gds-dtl.fact-qnty
       varslt-base-factovp = varslt-base-factovp + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc)                   * out-vatp_gds-dtl.fact-qnty
       varvat-base-factovp = varvat-base-factovp + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-base-sale) * ub.doc-line.vat-pc / (100 + ub.doc-line.vat-pc)                   * out-vatp_gds-dtl.fact-qnty
       varvatcons-base-factovp = varvatcons-base-factovp + (((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * ub.doc-line.cons-vat-pc / (100 + ub.doc-line.cons-vat-pc) * out-vatp_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-base-sale) * ub.doc-line.vat-pc / (100 + ub.doc-line.vat-pc) * out-vatp_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty)
       vardsc-base-factovp = vardsc-base-factovp + out-vatp_gds-dtl.discnt-base * out-vatp_gds-dtl.fact-qnty
       varsum-base-docovp  = varsum-base-docovp  + (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base)                 * out-vatp_gds-dtl.doc-qnty
       varslt-base-docovp  = varslt-base-docovp  + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc)                   * out-vatp_gds-dtl.doc-qnty
       varvat-base-docovp  = varvat-base-docovp  + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-base-sale) * ub.doc-line.vat-pc / (100 + ub.doc-line.vat-pc)                   * out-vatp_gds-dtl.doc-qnty
       varvatcons-base-docovp  = varvatcons-base-docovp  + (((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * ub.doc-line.cons-vat-pc / (100 + ub.doc-line.cons-vat-pc) * out-vatp_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-base-sale) * ub.doc-line.vat-pc / (100 + ub.doc-line.vat-pc) * out-vatp_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty)
       vardsc-base-docovp  = vardsc-base-docovp  + out-vatp_gds-dtl.discnt-base * out-vatp_gds-dtl.doc-qnty
      .
      assign
             varsum-rubl-factovp = varsum-rubl-factovp + (out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl)                 * out-vatp_gds-dtl.fact-qnty
       varslt-rubl-factovp = varslt-rubl-factovp + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc)                   * out-vatp_gds-dtl.fact-qnty
       varvat-rubl-factovp = varvat-rubl-factovp + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-rubl-sale) * ub.doc-line.vat-pc / (100 + ub.doc-line.vat-pc)                   * out-vatp_gds-dtl.fact-qnty
       varvatcons-rubl-factovp = varvatcons-rubl-factovp + (((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * ub.doc-line.cons-vat-pc / (100 + ub.doc-line.cons-vat-pc) * out-vatp_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-rubl-sale) * ub.doc-line.vat-pc / (100 + ub.doc-line.vat-pc) * out-vatp_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty)
       vardsc-rubl-factovp = vardsc-rubl-factovp + out-vatp_gds-dtl.discnt-rubl * out-vatp_gds-dtl.fact-qnty
       varsum-rubl-docovp  = varsum-rubl-docovp  + (out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl)                 * out-vatp_gds-dtl.doc-qnty
       varslt-rubl-docovp  = varslt-rubl-docovp  + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc)                   * out-vatp_gds-dtl.doc-qnty
       varvat-rubl-docovp  = varvat-rubl-docovp  + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-rubl-sale) * ub.doc-line.vat-pc / (100 + ub.doc-line.vat-pc)                   * out-vatp_gds-dtl.doc-qnty
       varvatcons-rubl-docovp  = varvatcons-rubl-docovp  + (((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * ub.doc-line.cons-vat-pc / (100 + ub.doc-line.cons-vat-pc) * out-vatp_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-rubl-sale) * ub.doc-line.vat-pc / (100 + ub.doc-line.vat-pc) * out-vatp_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty)
       vardsc-rubl-docovp  = vardsc-rubl-docovp  + out-vatp_gds-dtl.discnt-rubl * out-vatp_gds-dtl.doc-qnty   .
    end.
    if t-doc.doc-type = 'инв':U then do:
      ASSIGN
                price-base-with-tax-sale    = varsum-base-docovp / varfact-qnty
        slt-base-sale               = varslt-base-docovp / varfact-qnty
        vat-base-buyer              = varvat-base-docovp / varfact-qnty
        discnt-base-sale            = vardsc-base-docovp / varfact-qnty
        vat-base-sale               = varvatcons-base-docovp / varfact-qnty
                price-rubl-with-tax-sale    = varsum-rubl-docovp / varfact-qnty
        slt-rubl-sale               = varslt-rubl-docovp / varfact-qnty
        vat-rubl-buyer              = varvat-rubl-docovp / varfact-qnty
        discnt-rubl-sale            = vardsc-rubl-docovp / varfact-qnty
        vat-rubl-sale               = varvatcons-rubl-docovp / varfact-qnty.
    end.
    else do:
      ASSIGN
                price-base-with-tax-sale    = varsum-base-factovp / varfact-qnty
        slt-base-sale               = varslt-base-factovp / varfact-qnty
        vat-base-buyer              = varvat-base-factovp / varfact-qnty
        discnt-base-sale            = vardsc-base-factovp / varfact-qnty
        vat-base-sale               = varvatcons-base-factovp / varfact-qnty
                price-rubl-with-tax-sale    = varsum-rubl-factovp / varfact-qnty
        slt-rubl-sale               = varslt-rubl-factovp / varfact-qnty
        vat-rubl-buyer              = varvat-rubl-factovp / varfact-qnty
        discnt-rubl-sale            = vardsc-rubl-factovp / varfact-qnty
        vat-rubl-sale               = varvatcons-rubl-factovp / varfact-qnty.
    end.
  end.
end.
assign
  price-base-without-tax-sale = price-base-with-tax-sale - vat-base-sale - slt-base-sale - road-tax-base-sale
  price-rubl-without-tax-sale = price-rubl-with-tax-sale - vat-rubl-sale - slt-rubl-sale - road-tax-rubl-sale.
  assign
  price-rubl-without-tax-sale-b = price-rubl-with-tax-sale - vat-rubl-buyer - slt-rubl-sale - road-tax-rubl-sale
  .
  _parts:
  FOR EACH ub.parts NO-LOCK WHERE
          ub.parts.artic = ub.doc-line.artic
      AND ub.parts.prod-type = ub.doc-line.prod-type
      AND ub.parts.prod-code = ub.doc-line.prod-code
      AND ub.parts.out-code = doc-num
      AND ub.parts.obj-type = ub.doc-line.obj-type
      AND ub.parts.obj-code = ub.doc-line.obj-code
      :
    find first buf_parts-attr no-lock where
               buf_parts-attr.in-code = ub.parts.in-code
           AND buf_parts-attr.gds-code = v-gds-code
           AND buf_parts-attr.part-code = ub.parts.part-code no-error .
    if available buf_parts-attr then do:
      if
      NOT (buf_parts-attr.supp-type = cli_supp.obj-type
      AND buf_parts-attr.supp-code = cli_supp.obj-code) then NEXT _parts.
      if buf_parts-attr.purch-code <> ocons-pay
      AND buf_parts-attr.purch-code <> ocons-pay-2
      then next _parts.
      assign
      v-parts-VAt-pc = buf_parts-attr.vat-pc
      v-parts-SLT-pc = buf_parts-attr.SLT-pc
      v-in-code = buf_parts-attr.income-in-code
      v-part-code  = buf_parts-attr.income-part-code
      .
    end.
    else do:
      if
      NOT (ub.parts.supp-type = cli_supp.obj-type
      AND ub.parts.supp-code = cli_supp.obj-code) then NEXT _parts.
      if ub.parts.purch-code <> ocons-pay
      AND ub.parts.purch-code <> ocons-pay-2
      then next _parts.
      assign
      v-parts-VAt-pc = ub.parts.vat-pc
      v-parts-SLT-pc = ub.parts.SLT-pc
      v-in-code = ub.parts.in-code
      v-part-code = ub.parts.part-code
      .
    end.
assign
  price-rubl-with-tax-loc  = ub.parts.price-rubl
  price-base-with-tax-loc  = ub.parts.price-base
.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if ub.parts.out-code = 'free-zone':U     or
     ub.parts.out-code = 'out-zone':U   or
     ub.parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt  = yes.
  end.
  else do:
    find first in-vatp_doc-attr  no-lock
      where in-vatp_doc-attr .doc-code  = ub.parts.out-code
        and in-vatp_doc-attr .attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr  then do:
      assign
        in-vatp-have-vat-slt  = yes.
    end.
    else do:
         in-vatp-have-vat-slt  = no.
    end.
  end.
  assign
   price-cli-with-tax-loc  = ub.parts.price-cli
   cli-base-rate           = ub.parts.cli-base-rate.
  ASSIGN   road-tax-base-loc   = (if ub.parts.road-tax-base  = ? then 0 else ub.parts.road-tax-base)
           road-tax-rubl-loc   = (if ub.parts.road-tax-rubl  = ? then 0 else ub.parts.road-tax-rubl).
  ASSIGN  transport-base-loc  = (if ub.parts.transport-base = ? then 0 else ub.parts.transport-base)
          transport-rubl-loc  = (if ub.parts.transport-rubl = ? then 0 else ub.parts.transport-rubl)
          other-base-loc      = (if ub.parts.other-base     = ? then 0 else ub.parts.other-base)
          other-rubl-loc      = (if ub.parts.other-rubl     = ? then 0 else ub.parts.other-rubl)
          vat-pc-loc          = (if ub.parts.vat-pc         = ? then 0 else ub.parts.vat-pc)
          slt-pc-loc          = (if ub.parts.slt-pc         = ? then 0 else ub.parts.slt-pc).
          ASSIGN   slt-base-loc     = (if in-vatp-have-vat-slt  = no then 0 else (price-base-with-tax-loc  - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc  / (100 + slt-pc-loc ))                        vat-base-loc     = (if in-vatp-have-vat-slt  = no then 0 else (price-base-with-tax-loc  - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc  / (100 + slt-pc-loc )) * vat-pc-loc  / (100 + vat-pc-loc )).
    ASSIGN   slt-rubl-loc     = (if in-vatp-have-vat-slt  = no then 0 else (price-rubl-with-tax-loc  - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc  / (100 + slt-pc-loc ))                        vat-rubl-loc     = (if in-vatp-have-vat-slt  = no then 0 else (price-rubl-with-tax-loc  - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc  / (100 + slt-pc-loc )) * vat-pc-loc  / (100 + vat-pc-loc )).
  assign
    exch-rate-cli-loc  = (ub.parts.price-rubl - transport-rubl-loc  - other-rubl-loc  - road-tax-rubl-loc  - (if ub.parts.vat-type <> 'в т. ч.':U then vat-rubl-loc  else 0) - (if ub.parts.slt-type <> 'в т. ч.':U then slt-rubl-loc  else 0)) / ub.parts.price-cli .
  assign
    slt-cli-loc         = slt-rubl-loc        / exch-rate-cli-loc
    vat-cli-loc         = vat-rubl-loc        / exch-rate-cli-loc
    road-tax-cli-loc    = road-tax-rubl-loc   / exch-rate-cli-loc
    transport-cli-loc   = 0
    other-cli-loc       = 0
  .
ASSIGN
          price-base-without-tax-loc  = price-base-with-tax-loc  - vat-base-loc  - slt-base-loc  - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc  = price-rubl-with-tax-loc  - vat-rubl-loc  - slt-rubl-loc  - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
    if T-parts
    then do:
       FIND FIRST sj-goods WHERE
                sj-goods.artic = ub.doc-line.artic
            AND sj-goods.prod-type = ub.doc-line.prod-type
            AND sj-goods.prod-code = ub.doc-line.prod-code
            AND sj-goods.is-out_ = is-out
            AND sj-goods.VAT-supp = v-parts-Vat-pc
            AND sj-goods.price-with-tax-cost_ = price-rubl-with-tax-loc
            AND sj-goods.price-without-tax-sale_ = price-rubl-without-tax-sale-b
            AND sj-goods.part-code = v-part-code
            AND sj-goods.in-code = v-in-code
            No-error.
    end.
    else do:
      FIND FIRST sj-goods WHERE
                sj-goods.artic = ub.doc-line.artic
            AND sj-goods.prod-type = ub.doc-line.prod-type
            AND sj-goods.prod-code = ub.doc-line.prod-code
            AND sj-goods.is-out_ = is-out
            AND sj-goods.VAT-supp = v-parts-Vat-pc
            AND sj-goods.price-with-tax-cost_ = price-rubl-with-tax-loc
            AND sj-goods.price-without-tax-sale_ = price-rubl-without-tax-sale-b
            No-error.
    END.
    if not avail sj-goods
    then do:
      FIND FIRST ub.goods No-LOCK WHERE
                ub.goods.artic = ub.doc-line.artic
            AND ub.goods.prod-type = ub.doc-line.prod-type
            AND ub.goods.prod-code = ub.doc-line.prod-code No-ERROR.
      create sj-goods.
      assign
      sj-goods.artic = ub.goods.artic
      sj-goods.prod-type = ub.goods.prod-type
      sj-goods.prod-code = ub.goods.prod-code
      sj-goods.unit = ub.goods.unit-base
      sj-goods.gds-name = REPLACE(ub.goods.gds-name, " ", "_")
      sj-goods.VAT-supp = v-parts-VAT-pc
      sj-goods.SLT-supp = v-parts-SLT-pc
      sj-goods.in-code = if T-parts then v-in-code else ""
      sj-goods.part-code = if T-parts then v-part-code else ""
      sj-goods.is-out_ = is-out
      sj-goods.price-with-tax-cost_ = price-rubl-with-tax-loc
      .
    END.
    assign
    prt-qnty =  is-out * ub.parts.fact-qnty
    sj-goods.qnty = sj-goods.qnty +  prt-qnty
    sj-goods.price-without-tax-cost_ = price-rubl-without-tax-loc
    sj-goods.sum-without-tax-cost_  =  sj-goods.sum-without-tax-cost_ + price-rubl-without-tax-loc * prt-qnty
    sj-goods.sum-vat-cost_ = sj-goods.sum-vat-cost_ + vat-rubl-loc * prt-qnty
    sj-goods.sum-with-tax-cost_   =  sj-goods.sum-with-tax-cost_ + price-rubl-with-tax-loc * prt-qnty
    sj-goods.sum-without-tax-sale_ = sj-goods.sum-without-tax-sale_ + price-rubl-without-tax-sale-b * prt-qnty
    sj-goods.price-without-tax-sale_ = sj-goods.sum-without-tax-sale_ / sj-goods.qnty
    sj-goods.sum-vat-sale_ = sj-goods.sum-vat-sale + vat-rubl-buyer * prt-qnty
    sj-goods.sum-slt-sale_ = sj-goods.sum-slt-sale + slt-rubl-sale * prt-qnty
    sj-goods.sum-with-tax-sale_ = sj-goods.sum-with-tax-sale_ + price-rubl-with-tax-sale * prt-qnty
    .
  END.
END.
  end.
end procedure.
procedure filltable :
DEFINE VARiable v-host-code like ub.sysconf.host-code no-undo.
DEFINE VARIABLE loc#retail as logical no-undo.
DEFINE VARIABLE real-code like ub.clients.obj-code no-undo.
DEFINE VARIABLE real-type like ub.clients.obj-type no-undo.
DEFINE VARIABLE ocons-pay like ub.sysconf.purch-code no-undo.
DEFINE VARIABLE ocons-pay-2 like ub.sysconf.purch-code no-undo.
DEFINE VARIABLE is-out as integer no-undo .
DEFINE VARIABLE doc-num like ub.trn-doc.doc-code no-undo.
DEFINE VARIABLE offc as logical no-undo.
DEFINE VARIABLE prt-qnty as decimal no-undo .
  do
  on error undo, return error
  :
    run waitfram-show in this-procedure ( input "Ждите") .
    FOR EACH sj-goods :
        delete sj-goods .
    END .
    _obj-list:
    FOR EACH obj-list NO-LOCK:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  obj-list.obj-type
  ,input  obj-list.obj-code
  ,output v-host-code
  )  .
      FIND FIRST ub.sysconf NO-LOCK WHERE ub.sysconf.host-code = v-host-code.
      IF AVAIL ub.sysconf
      then
      assign
      loc#retail = ub.sysconf.ord-prt
      real-code = ub.sysconf.sale-code
      real-type = ub.sysconf.sale-type
      ocons-pay = integer('2':U)
      ocons-pay-2 = integer('4':U)
      .
      else NEXT _obj-list.
      CASE RS-by:
        when 1 then do:
        _inkas:
          FOR EACH ub.inkas WHERE
                  ub.inkas.doc-date >= X-date-start and
                  ub.inkas.doc-date <= X-date-end AND
                  ub.inkas.obj-code = obj-list.obj-code and
                  ub.inkas.obj-type = obj-list.obj-type AND
                  ub.inkas.status_ = 'факт':U NO-LOCK,
              each ub.sale-doc no-lock where
                    ub.sale-doc.inkas-code = ub.inkas.inkas-code
                and ub.sale-doc.order > 0:
            if ub.sale-doc.in-inkas then do:
              FIND FIRST t-doc No-LOCK WHERE
                      t-doc.doc-code = ub.sale-doc.doc-code no-error.
              if available t-doc then do:
                assign
                doc-num = t-doc.doc-code
                is-out = ub.sale-doc.dir
                .
                if t-doc.office then NEXT _inkas.
                run cr-sj-goods in this-procedure (
                                                  input doc-num
                                                  ,input is-out
                                                  ,input ocons-pay
                                                  ,input ocons-pay-2
                                                  ).
              end.
            end.
          END.
        END.
        when 2 then do:
        _trn-doc:
          FOR EACH t-doc NO-LOCK WHERE
                  t-doc.obj-type = obj-list.obj-type AND
                  t-doc.obj-code = obj-list.obj-code AND
                  t-doc.cli-type = real-type AND
                  t-doc.cli-code = real-code AND
                  t-doc.status_ = 'факт':U AND
                  t-doc.doc-date >= X-date-start AND
                  t-doc.doc-date <= X-date-end AND
                  t-doc.ext-doc-type = 'ee':U
                  :
            assign
            doc-num = t-doc.doc-code
            offc = t-doc.office
            is-out = 1.
            if offc then NEXT _trn-doc.
            run cr-sj-goods in this-procedure (
                                                input doc-num
                                               ,input is-out
                                               ,input ocons-pay
                                               ,input ocons-pay-2
                                               ).
          END.
          _ret-doc:
          FOR EACH t-doc NO-LOCK WHERE
                  t-doc.obj-type = obj-list.obj-type AND
                  t-doc.obj-code = obj-list.obj-code AND
                  t-doc.cli-type = real-type AND
                  t-doc.cli-code = real-code AND
                  t-doc.status_ = 'факт':U AND
                  t-doc.doc-date >= X-date-start AND
                  t-doc.doc-date <= X-date-end AND
                  t-doc.ext-doc-type = 're':U:
            assign
            doc-num = t-doc.doc-code
            offc = t-doc.office
            is-out = -1.
            if offc then NEXT _ret-doc.
            run cr-sj-goods in this-procedure (
                                                input doc-num
                                               ,input is-out
                                               ,input ocons-pay
                                               ,input ocons-pay-2
                                               ).
          END.
        END.
        WHEN 3 or when 4 then do:
          _3trn-doc:
          FOR EACH t-doc NO-LOCK WHERE
                  t-doc.obj-type = obj-list.obj-type AND
                  t-doc.obj-code = obj-list.obj-code AND
                  t-doc.status_ = 'факт':U AND
                  t-doc.doc-date >= X-date-start AND
                  t-doc.doc-date <= X-date-end AND
                  (t-doc.ext-doc-type = 'ee':U
                  or t-doc.ext-doc-type = 'es':U) :
            assign
            doc-num = t-doc.doc-code
            offc = t-doc.office
            is-out = 1.
            if offc then NEXT _3trn-doc.
            run cr-sj-goods in this-procedure (
                                                input doc-num
                                               ,input is-out
                                               ,input ocons-pay
                                               ,input ocons-pay-2
                                               ).
            if Rs-by = 3 then do:
              if t-doc.ext-doc-type = 'es':U then NEXT _3trn-doc.
            end.
          END.
          if Rs-by = 4 then do:
            _3trn-doc-ret:
            FOR EACH t-doc NO-LOCK WHERE
                    t-doc.obj-type = obj-list.obj-type AND
                    t-doc.obj-code = obj-list.obj-code AND
                    t-doc.status_ = 'факт':U AND
                    t-doc.doc-date >= X-date-start AND
                    t-doc.doc-date <= X-date-end AND
                    (t-doc.ext-doc-type = 're':U OR
                    t-doc.ext-doc-type = 'rs':U):
              assign
              doc-num = t-doc.doc-code
              offc = t-doc.office
              is-out = - 1.
              if offc then NEXT _3trn-doc-ret.
              run cr-sj-goods in this-procedure (
                                                  input doc-num
                                                ,input is-out
                                                ,input ocons-pay
                                                ,input ocons-pay-2
                                                ).
            END.
          end.
          _spitrn-doc:
          FOR EACH t-doc NO-LOCK WHERE
                  t-doc.obj-type = obj-list.obj-type AND
                  t-doc.obj-code = obj-list.obj-code AND
                  t-doc.status_ = 'факт':U AND
                  t-doc.doc-date >= X-date-start AND
                  t-doc.doc-date <= X-date-end AND
                  t-doc.internal = no AND
                  (t-doc.ext-doc-type = 'wm':U
                  OR (Rs-by = 4 and
                      t-doc.ext-doc-type = 'we':U)
                  )
                  :
            assign
            doc-num = t-doc.doc-code
            offc = t-doc.office
            is-out = 1.
            if offc then NEXT _spitrn-doc.
            run cr-sj-goods in this-procedure (
                                                input doc-num
                                              ,input is-out
                                              ,input ocons-pay
                                              ,input ocons-pay-2
                                              ).
          END.
        end.
      END CASE.
    END.
    run waitfram-hide in this-procedure .
  end.
end procedure.
define variable l-col-type         as character no-undo .
define variable l-col-pos          as integer no-undo .
define variable l-col-len          as integer no-undo .
define variable l-col-format       as character no-undo .
define variable l-col-lable        as character no-undo .
define variable v-dec-sep          as character no-undo init ? .
define variable v-th-sep           as character no-undo init ? .
define variable v-r-col-num        as integer no-undo .
define variable v-reg-replace      as logical no-undo .
define variable v-date-col-format  as character no-undo .
DEFINE VARIABLE last-col-num as integer no-undo.
run gbl/getlocal.p (
                  output v-dec-sep
                 ,output v-th-sep
                 ,output v-sdate
                 ,output v-shortdate
                 ) no-error .
assign
v-reg-replace = NOT (v-dec-sep = ".":U and v-th-sep = chr(44))
                AND (v-dec-sep <> ? and v-th-sep <> ?)
.
  FUNCTION supress-null RETURNS CHARACTER ( INPUT p-string  AS CHARACTER,
                                            INPUT p-dec-sep AS CHARACTER  ) :
    DEFINE VARIABLE v-string AS CHARACTER NO-UNDO.
    IF TRIM( p-string ) = "0"                    OR
       TRIM( p-string ) = "0" + p-dec-sep + "00" OR
       TRIM( p-string ) =       p-dec-sep + "00" OR
       TRIM( p-string ) =       p-dec-sep + "0"  OR
       TRIM( p-string ) = "0" + p-dec-sep + "0"  THEN DO: ASSIGN v-string = "":U.     END.
                                                 ELSE DO: ASSIGN v-string = p-string. END.
    RETURN ( TRIM( v-string ) ).
  END FUNCTION.
FUNCTION reg-output returns character( input p-string as character
                                      ,input p-private-data as character
                                      ,input p-replace as logical
                                      ,input p-supress as logical
                                      ,input p-dec-sep as character
                                      ,input p-th-sep as character
                                      ):
DEFINE VARIABLE v-reg-output as character no-undo .
DEFINE VARIABLE v-data-type as character no-undo .
DEFINE VARIABLE v-progress-format as character no-undo .
assign
v-progress-format = entry(1, p-private-data, chr(4))
v-data-type = entry(2, p-private-data, chr(4))
.
if p-string = ? then return chr(63).
if (v-data-type = "INTEGER"
    OR v-data-type = "DECIMAL" ) THEN DO:
  IF p-replace THEN DO:
    assign
      v-reg-output = replace( p-string
                                      ,chr(44)
                                      ,"":U
                                    )
      v-reg-output = trim(v-reg-output)
    .
  END.
  else do:
    v-reg-output = p-string.
  end.
  IF p-supress THEN DO: ASSIGN v-reg-output = supress-null( TRIM( v-reg-output ), p-dec-sep ). END.
  return v-reg-output.
end.
  return p-string.
END FUNCTION.
define variable g#report-num as integer no-undo .
DEFINE VARIABLE fill5 as character no-undo.
DEFINE VARIABLE fill6 as character no-undo.
DEFINE VARIABLE fill9 as character no-undo.
DEFINE VARIABLE fill13 as character no-undo.
DEFINE VARIABLE fill15 as character no-undo.
DEFINE VARIABLE fill16 as character no-undo.
DEFINE VARIABLE fill18 as character no-undo.
DEFINE VARIABLE fill19 as character no-undo.
DEFINE VARIABLE fill30 as character no-undo.
DEFINE VARIABLE date_string     as      char    no-undo.
DEFINE VARIABLE Line  as character no-undo .
DEFINE VARIABLE v-nn                      as integer                  no-undo .
DEFINE VARIABLE v-artic                   like ub.doc-line.artic      no-undo .
DEFINE VARIABLE v-gds-name                like ub.goods.gds-name      no-undo .
DEFINE VARIABLE v-prod                    as character no-undo .
DEFINE VARIABLE v-unit-base               like ub.goods.unit-base     no-undo .
DEFINE VARIABLE v-qnty                    like ub.doc-line.doc-qnty   no-undo .
DEFINE VARIABLE v-price-without-tax-cost  like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE v-sum-without-tax-cost    like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE v-sum-vat-cost            like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE v-sum-with-tax-cost       like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE v-price-without-tax-sale  like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE v-sum-without-tax-sale    like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE v-sum-vat-sale            like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE v-sum-without-slt-sale    like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE v-sum-slt-sale            like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE v-sum-with-slt-sale       like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE accum-qnty                    like ub.doc-line.doc-qnty   no-undo .
DEFINE VARIABLE accum-sum-without-tax-cost    like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE accum-sum-vat-cost            like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE accum-sum-with-tax-cost       like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE accum-sum-without-tax-sale    like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE accum-sum-vat-sale            like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE accum-sum-without-slt-sale    like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE accum-sum-slt-sale            like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE accum-sum-with-tax-sale       like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE v-choice                      as integer no-undo .
DEFINE VARIABLE v-gen-print                   as logical no-undo init yes.
DEFINE VARIABLE t-1 AS CHARACTER INITIAL "||||"
     VIEW-AS EDITOR
     SIZE 1 BY 4 NO-UNDO.
DEFINE FRAME top-frame
t-1       AT ROW 1 COL 1 no-label
HEADER
string( "Дата печати :" ) AT 5 format "x(15)" TODAY format "99.99.9999"
string( " , " ) format "X(3)" string(TIME, "HH:MM")
string( "Страница" ) AT 45 PAGE-NUMBER( PrnLibStream ) AT 55 FORMAT ">>9" SKIP
with width 232 down stream-io use-text NO-BOX.
DEFINE FRAME FKomis
with width 232 down stream-io use-text NO-BOX.
find first cli_supp no-lock where
          cli_supp.obj-type = p-supp-type
      AND cli_supp.obj-code = p-supp-code no-error .
if not available cli_supp then do:
  message
  vss-workfile vss-revision vss-description skip
  "Не найден поставщик" p-supp-type p-supp-code
  view-as alert-box error .
  return error .
end.
if RS-BY < 1 AND RS-by > 4 then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверное значение параметра RS-by = "RS-by
  view-as alert-box error .
  return error .
end.
run waitfram-show in this-procedure ("Ждите...").
assign
fill5 = fill("-", 5)
fill6 = fill("-", 6)
fill9 = fill("-", 9)
fill13 = fill("-", 13)
fill15 = fill("-", 15)
fill16 = fill("-", 16)
fill18 = fill("-", 18)
fill30 = fill("-", 30)
.
assign
sheetf.Excel-Column-Lable =  ""
sheetf.sizes = ""
.
CREATE WIDGET-POOL "My-pool" PERSISTENT no-error .
l-col-pos = 1.
Assign l-col-type="INTEGER" l-col-len=5 l-col-format= ">>>9"  l-col-lable = chr(32) + "NN" + chr(32) + chr(32).
  define variable ed1 as handle no-undo.
  define variable l-1 as handle no-undo.
  define variable ll-1 as handle no-undo.
  define variable c-v-nn as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[1] = true then DO:
        CREATE EDITOR LL-1 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed1 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-1 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-v-nn IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME FKomis:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[1] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 1
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="CHARACTER" l-col-len=16 l-col-format= "X(16)"  l-col-lable = "Артикул".
  define variable ed2 as handle no-undo.
  define variable l-2 as handle no-undo.
  define variable ll-2 as handle no-undo.
  define variable c-v-artic as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[2] = true then DO:
        CREATE EDITOR LL-2 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed2 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-2 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-v-artic IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME FKomis:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[2] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 2
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="CHARACTER" l-col-len=30 l-col-format= "X(30)"  l-col-lable = "Название товара".
  define variable ed3 as handle no-undo.
  define variable l-3 as handle no-undo.
  define variable ll-3 as handle no-undo.
  define variable c-v-gds-name as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[3] = true then DO:
        CREATE EDITOR LL-3 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed3 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-3 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-v-gds-name IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME FKomis:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[3] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 3
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="CHARACTER" l-col-len=13 l-col-format= "X(13)"  l-col-lable = "Производитель".
  define variable ed4 as handle no-undo.
  define variable l-4 as handle no-undo.
  define variable ll-4 as handle no-undo.
  define variable c-v-prod as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[4] = true then DO:
        CREATE EDITOR LL-4 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed4 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-4 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-v-prod IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME FKomis:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[4] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 4
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="CHARACTER" l-col-len=6 l-col-format= "X(6)"  l-col-lable = "Ед.Изм".
  define variable ed5 as handle no-undo.
  define variable l-5 as handle no-undo.
  define variable ll-5 as handle no-undo.
  define variable c-v-unit-base as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[5] = true then DO:
        CREATE EDITOR LL-5 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed5 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-5 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-v-unit-base IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME FKomis:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[5] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 5
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>,>>>,>>9.999"  l-col-lable = "Количество".
  define variable ed6 as handle no-undo.
  define variable l-6 as handle no-undo.
  define variable ll-6 as handle no-undo.
  define variable c-v-qnty as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[6] = true then DO:
        CREATE EDITOR LL-6 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed6 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-6 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-v-qnty IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME FKomis:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[6] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 6
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="DECIMAL" l-col-len=18 l-col-format= "->>,>>>,>>>,>>9.99"  l-col-lable = "Учетная цена без НДС".
  define variable ed7 as handle no-undo.
  define variable l-7 as handle no-undo.
  define variable ll-7 as handle no-undo.
  define variable c-v-price-without-tax-cost as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[7] = true then DO:
        CREATE EDITOR LL-7 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed7 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-7 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-v-price-without-tax-cost IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME FKomis:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[7] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 7
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="DECIMAL" l-col-len=18 l-col-format= "->>,>>>,>>>,>>9.99"  l-col-lable = "Сумма уч. цен без НДС".
  define variable ed8 as handle no-undo.
  define variable l-8 as handle no-undo.
  define variable ll-8 as handle no-undo.
  define variable c-v-sum-without-tax-cost as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[8] = true then DO:
        CREATE EDITOR LL-8 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed8 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-8 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-v-sum-without-tax-cost IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME FKomis:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[8] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 8
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="DECIMAL" l-col-len=18 l-col-format= "->>,>>>,>>>,>>9.99"  l-col-lable = "НДС поставщика".
  define variable ed9 as handle no-undo.
  define variable l-9 as handle no-undo.
  define variable ll-9 as handle no-undo.
  define variable c-v-sum-vat-cost as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[9] = true then DO:
        CREATE EDITOR LL-9 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed9 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-9 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-v-sum-vat-cost IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME FKomis:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[9] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 9
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="DECIMAL" l-col-len=18 l-col-format= "->>,>>>,>>>,>>9.99"  l-col-lable = "Сумма уч. цен".
  define variable ed10 as handle no-undo.
  define variable l-10 as handle no-undo.
  define variable ll-10 as handle no-undo.
  define variable c-v-sum-with-tax-cost as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[10] = true then DO:
        CREATE EDITOR LL-10 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed10 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-10 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-v-sum-with-tax-cost IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME FKomis:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[10] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 10
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="DECIMAL" l-col-len=18 l-col-format= "->>,>>>,>>>,>>9.99"  l-col-lable = "Цена ед. изм без налога".
  define variable ed11 as handle no-undo.
  define variable l-11 as handle no-undo.
  define variable ll-11 as handle no-undo.
  define variable c-v-price-without-tax-sale as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[11] = true then DO:
        CREATE EDITOR LL-11 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed11 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-11 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-v-price-without-tax-sale IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME FKomis:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[11] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 11
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="DECIMAL" l-col-len=18 l-col-format= "->>,>>>,>>>,>>9.99"  l-col-lable = "Сумма товаров без налога".
  define variable ed12 as handle no-undo.
  define variable l-12 as handle no-undo.
  define variable ll-12 as handle no-undo.
  define variable c-v-sum-without-tax-sale as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[12] = true then DO:
        CREATE EDITOR LL-12 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed12 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-12 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-v-sum-without-tax-sale IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME FKomis:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[12] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 12
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="DECIMAL" l-col-len=18 l-col-format= "->>,>>>,>>>,>>9.99"  l-col-lable = "НДС".
  define variable ed13 as handle no-undo.
  define variable l-13 as handle no-undo.
  define variable ll-13 as handle no-undo.
  define variable c-v-sum-vat-sale as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[13] = true then DO:
        CREATE EDITOR LL-13 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed13 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-13 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-v-sum-vat-sale IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME FKomis:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[13] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 13
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="DECIMAL" l-col-len=18 l-col-format= "->>,>>>,>>>,>>9.99"  l-col-lable = "Сумма товаров без НсП".
  define variable ed14 as handle no-undo.
  define variable l-14 as handle no-undo.
  define variable ll-14 as handle no-undo.
  define variable c-v-sum-without-slt-sale as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[14] = true then DO:
        CREATE EDITOR LL-14 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed14 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-14 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-v-sum-without-slt-sale IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME FKomis:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[14] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 14
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="DECIMAL" l-col-len=18 l-col-format= "->>,>>>,>>>,>>9.99"  l-col-lable = "НсП".
  define variable ed15 as handle no-undo.
  define variable l-15 as handle no-undo.
  define variable ll-15 as handle no-undo.
  define variable c-v-sum-slt-sale as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[15] = true then DO:
        CREATE EDITOR LL-15 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed15 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-15 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-v-sum-slt-sale IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME FKomis:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[15] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 15
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="DECIMAL" l-col-len=18 l-col-format= "->>,>>>,>>>,>>9.99"  l-col-lable = "Сумма".
  define variable ed16 as handle no-undo.
  define variable l-16 as handle no-undo.
  define variable ll-16 as handle no-undo.
  define variable c-v-sum-with-tax-sale as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[16] = true then DO:
        CREATE EDITOR LL-16 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed16 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-16 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-v-sum-with-tax-sale IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME FKomis:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[16] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 16
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
if frame FKomis:width < l-col-pos - 1 then frame FKomis:width = l-col-pos - 1.
assign
Line = fill( "-" , 60 )
p-frame-width = l-col-pos - 1
.
if p-frame-width > 198 then do:
  run waitfram-hide in this-procedure .
  run gbl/d-askw.w (input "Формат вывода",
                input ("Общая ширина интересующих Вас колонок больше:" + string(198) + chr(10) +
                       "отчет не уместится на бумаге формата А4 (ориентация альбомная)"
                      ),
                input "|",
                input ("Выводить только в Excel|" +
                       "Формат А3 (ориентация альбомная)|" +
                       "Уменьшить количество интервалов"),
                input "||",
                input 1,
                input 3,
                output v-choice).
   if v-choice = 3 then do:
     DELETE WIDGET-POOL "My-pool".
     run waitfram-hide in this-procedure .
     return.
   end.
   if v-choice = 1 then v-Gen-Print = no.
end.
run FillTable in this-procedure no-error  .
if error-status:error then do:
  DELETE WIDGET-POOL "My-pool".
  run waitfram-hide in this-procedure .
  return error .
end.
if not avail sj-goods then do:
  DELETE WIDGET-POOL "My-pool".
  run waitfram-hide in this-procedure .
  message
  "Нет данных для отчета"
  view-as alert-box .
  return.
end.
if v-gen-print then do:
output stream PrnLibStream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
  FORM with FRAME FKomis .
  FORM HEADER
  Line format "X(60)" AT 1 SKIP
  string( "Продолжение - на следующей странице" ) FORMAT "X(40)" AT 10 SKIP
  with FRAME NBottomFrame width 232 PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW stream PrnLibStream FRAME NBottomFrame .
  PUT stream PrnLibStream UNFORMATTED
  SPACE(10)
  p-Report-header
  SKIP(1).
  display STREAM PrnLibStream with frame top-Frame .
end.
run rep/extitle.p (1).
assign
accum-qnty                   = 0
accum-sum-without-tax-cost   = 0
accum-sum-vat-cost           = 0
accum-sum-with-tax-cost      = 0
accum-sum-without-tax-sale   = 0
accum-sum-vat-sale           = 0
accum-sum-without-slt-sale   = 0
accum-sum-slt-sale           = 0
accum-sum-with-tax-sale      = 0
.
FOR EACH sj-goods no-lock
By sj-goods.artic
By sj-goods.prod-type
By sj-goods.prod-code:
  assign
  v-nn = v-nn + 1
  v-prod = sj-goods.prod-type + chr(32) + string(sj-goods.prod-code)
  v-sum-without-slt-sale = sj-goods.sum-with-tax-sale_ - sj-goods.sum-slt-sale_
  accum-qnty                   = accum-qnty                   + sj-goods.qnty
  accum-sum-without-tax-cost   = accum-sum-without-tax-cost   + sj-goods.sum-without-tax-cost_
  accum-sum-vat-cost           = accum-sum-vat-cost           + sj-goods.sum-vat-cost_
  accum-sum-with-tax-cost      = accum-sum-with-tax-cost      + sj-goods.sum-with-tax-cost_
  accum-sum-without-tax-sale   = accum-sum-without-tax-sale   + sj-goods.sum-without-tax-sale_
  accum-sum-vat-sale           = accum-sum-vat-sale           + sj-goods.sum-vat-sale_
  accum-sum-without-slt-sale   = accum-sum-without-slt-sale   + v-sum-without-slt-sale
  accum-sum-slt-sale           = accum-sum-slt-sale           + sj-goods.sum-slt-sale_
  accum-sum-with-tax-sale      = accum-sum-with-tax-sale      + sj-goods.sum-with-tax-sale_
  .
  if v-gen-print then do:
  if use-column[1]
  then  C-v-nn:screen-value = string(v-nn, entry(1, c-v-nn:private-data, chr(4))).
  if use-column[2]
  then  C-v-artic:screen-value = string(sj-goods.artic, entry(1, c-v-artic:private-data, chr(4))).
  if use-column[3]
  then  C-v-gds-name:screen-value = string(sj-goods.gds-name, entry(1, c-v-gds-name:private-data, chr(4))).
  if use-column[4]
  then  C-v-prod:screen-value = string(v-prod, entry(1, c-v-prod:private-data, chr(4))).
  if use-column[5]
  then  C-v-unit-base:screen-value = string(sj-goods.unit, entry(1, c-v-unit-base:private-data, chr(4))).
  if use-column[6]
  then  C-v-qnty:screen-value = string(sj-goods.qnty, entry(1, c-v-qnty:private-data, chr(4))).
  if use-column[7]
  then  C-v-price-without-tax-cost:screen-value = string(sj-goods.price-without-tax-cost_, entry(1, c-v-price-without-tax-cost:private-data, chr(4))).
  if use-column[8]
  then  C-v-sum-without-tax-cost:screen-value = string(sj-goods.sum-without-tax-cost_, entry(1, c-v-sum-without-tax-cost:private-data, chr(4))).
  if use-column[9]
  then  C-v-sum-vat-cost:screen-value = string(sj-goods.sum-vat-cost_, entry(1, c-v-sum-vat-cost:private-data, chr(4))).
  if use-column[10]
  then  C-v-sum-with-tax-cost:screen-value = string(sj-goods.sum-with-tax-cost_, entry(1, c-v-sum-with-tax-cost:private-data, chr(4))).
  if use-column[11]
  then  C-v-price-without-tax-sale:screen-value = string(sj-goods.price-without-tax-sale_, entry(1, c-v-price-without-tax-sale:private-data, chr(4))).
  if use-column[12]
  then  C-v-sum-without-tax-sale:screen-value = string(sj-goods.sum-without-tax-sale_, entry(1, c-v-sum-without-tax-sale:private-data, chr(4))).
  if use-column[13]
  then  C-v-sum-vat-sale:screen-value = string(sj-goods.sum-vat-sale_, entry(1, c-v-sum-vat-sale:private-data, chr(4))).
  if use-column[14]
  then  C-v-sum-without-slt-sale:screen-value = string(v-sum-without-slt-sale, entry(1, c-v-sum-without-slt-sale:private-data, chr(4))).
  if use-column[15]
  then  C-v-sum-slt-sale:screen-value = string(sj-goods.sum-slt-sale_, entry(1, c-v-sum-slt-sale:private-data, chr(4))).
  if use-column[16]
  then  C-v-sum-with-tax-sale:screen-value = string(sj-goods.sum-with-tax-sale_, entry(1, c-v-sum-with-tax-sale:private-data, chr(4))).
    DISPLAY stream  PrnLibStream with frame FKomis.                                      DOWN 1 stream PrnLibStream with frame FKomis.
   end.
    if Make-Excel then  put   stream ForExcel unformatted
  if use-column[1]
  then (reg-output(
                    string(v-nn, entry(1, c-v-nn:private-data, chr(4)))
                   ,c-v-nn:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 1 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[2]
  then (reg-output(
                    string(sj-goods.artic, entry(1, c-v-artic:private-data, chr(4)))
                   ,c-v-artic:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 2 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[3]
  then (reg-output(
                    string(sj-goods.gds-name, entry(1, c-v-gds-name:private-data, chr(4)))
                   ,c-v-gds-name:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 3 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[4]
  then (reg-output(
                    string(v-prod, entry(1, c-v-prod:private-data, chr(4)))
                   ,c-v-prod:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 4 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[5]
  then (reg-output(
                    string(sj-goods.unit, entry(1, c-v-unit-base:private-data, chr(4)))
                   ,c-v-unit-base:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 5 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[6]
  then (reg-output(
                    string(sj-goods.qnty, entry(1, c-v-qnty:private-data, chr(4)))
                   ,c-v-qnty:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 6 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[7]
  then (reg-output(
                    string(sj-goods.price-without-tax-cost_, entry(1, c-v-price-without-tax-cost:private-data, chr(4)))
                   ,c-v-price-without-tax-cost:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 7 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[8]
  then (reg-output(
                    string(sj-goods.sum-without-tax-cost_, entry(1, c-v-sum-without-tax-cost:private-data, chr(4)))
                   ,c-v-sum-without-tax-cost:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 8 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[9]
  then (reg-output(
                    string(sj-goods.sum-vat-cost_, entry(1, c-v-sum-vat-cost:private-data, chr(4)))
                   ,c-v-sum-vat-cost:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 9 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[10]
  then (reg-output(
                    string(sj-goods.sum-with-tax-cost_, entry(1, c-v-sum-with-tax-cost:private-data, chr(4)))
                   ,c-v-sum-with-tax-cost:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 10 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[11]
  then (reg-output(
                    string(sj-goods.price-without-tax-sale_, entry(1, c-v-price-without-tax-sale:private-data, chr(4)))
                   ,c-v-price-without-tax-sale:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 11 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[12]
  then (reg-output(
                    string(sj-goods.sum-without-tax-sale_, entry(1, c-v-sum-without-tax-sale:private-data, chr(4)))
                   ,c-v-sum-without-tax-sale:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 12 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[13]
  then (reg-output(
                    string(sj-goods.sum-vat-sale_, entry(1, c-v-sum-vat-sale:private-data, chr(4)))
                   ,c-v-sum-vat-sale:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 13 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[14]
  then (reg-output(
                    string(v-sum-without-slt-sale, entry(1, c-v-sum-without-slt-sale:private-data, chr(4)))
                   ,c-v-sum-without-slt-sale:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 14 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[15]
  then (reg-output(
                    string(sj-goods.sum-slt-sale_, entry(1, c-v-sum-slt-sale:private-data, chr(4)))
                   ,c-v-sum-slt-sale:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 15 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[16]
  then (reg-output(
                    string(sj-goods.sum-with-tax-sale_, entry(1, c-v-sum-with-tax-sale:private-data, chr(4)))
                   ,c-v-sum-with-tax-sale:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 16 < last-col-num
         then CHR(9)
         else ""))
  else "":U
    skip.
END.
if v-gen-print then do:
  run UNDERLINE-FRAME in this-procedure .
  if use-column[1]
  then  C-v-nn:screen-value = string(v-nn, entry(1, c-v-nn:private-data, chr(4))).
  if use-column[6]
  then  C-v-qnty:screen-value = string(accum-qnty, entry(1, c-v-qnty:private-data, chr(4))).
  if use-column[8]
  then  C-v-sum-without-tax-cost:screen-value = string(accum-sum-without-tax-cost, entry(1, c-v-sum-without-tax-cost:private-data, chr(4))).
  if use-column[9]
  then  C-v-sum-vat-cost:screen-value = string(accum-sum-vat-cost, entry(1, c-v-sum-vat-cost:private-data, chr(4))).
  if use-column[10]
  then  C-v-sum-with-tax-cost:screen-value = string(accum-sum-with-tax-cost, entry(1, c-v-sum-with-tax-cost:private-data, chr(4))).
  if use-column[12]
  then  C-v-sum-without-tax-sale:screen-value = string(accum-sum-without-tax-sale, entry(1, c-v-sum-without-tax-sale:private-data, chr(4))).
  if use-column[13]
  then  C-v-sum-vat-sale:screen-value = string(accum-sum-vat-sale, entry(1, c-v-sum-vat-sale:private-data, chr(4))).
  if use-column[14]
  then  C-v-sum-without-slt-sale:screen-value = string(accum-sum-without-slt-sale, entry(1, c-v-sum-without-slt-sale:private-data, chr(4))).
  if use-column[15]
  then  C-v-sum-slt-sale:screen-value = string(accum-sum-slt-sale, entry(1, c-v-sum-slt-sale:private-data, chr(4))).
  if use-column[16]
  then  C-v-sum-with-tax-sale:screen-value = string(accum-sum-with-tax-sale, entry(1, c-v-sum-with-tax-sale:private-data, chr(4))).
  DISPLAY stream  PrnLibStream with frame FKomis.                                      DOWN 1 stream PrnLibStream with frame FKomis.
  Put stream PrnLibStream UNFORMATTED
  skip(2)
  fill(chr(32), 15)
  "ИТОГО продано с учетом НДС" chr(32)
  fill(chr(32), 15)
  string(accum-sum-without-slt-sale, "->>,>>>,>>>,>>9.99")  AT 100
  skip
  fill(chr(32), 15)
  "За проданный товар Комиссионеру причитается вознаграждение в сумме" chr(32)
  fill(chr(32), 15)
  string(accum-sum-without-slt-sale - accum-sum-with-tax-cost, "->>,>>>,>>>,>>9.99") AT 100
  skip
   fill(chr(32), 15)
  "Подлежит перечислению Комитенту сумма" chr(32)
   fill(chr(32), 15)
   string(accum-sum-with-tax-cost, "->>,>>>,>>>,>>9.99") AT 100
   skip(2)
   fill(chr(32), 15)
   "От Комиссионера" chr(32) p-host-name chr(32)
   "отчет сдал" chr(32) fill("_", 15)
   skip
   fill(chr(32), 54)
   "(подпись)"
   skip
   fill(chr(32), 45) "М.П."
   skip(2)
   fill(chr(32), 15)
   "От Комитента" chr(32) p-supp-name chr(32)
   "отчет принял" chr(32) fill("_", 15)
   skip
   fill(chr(32), 54)
   "(подпись)"
   skip
   fill(chr(32), 45) "М.П."
   skip.
end.
run UNDERLINE-EXCEL in this-procedure .
if Make-Excel then  put   stream ForExcel unformatted
  if use-column[1]
  then (reg-output(
                    string(v-nn, entry(1, c-v-nn:private-data, chr(4)))
                   ,c-v-nn:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 1 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[2]
  then (if 2 < last-col-num then CHR(9) else "")
  else ""
  if use-column[3]
  then (if 3 < last-col-num then CHR(9) else "")
  else ""
  if use-column[4]
  then (if 4 < last-col-num then CHR(9) else "")
  else ""
  if use-column[5]
  then (if 5 < last-col-num then CHR(9) else "")
  else ""
  if use-column[6]
  then (reg-output(
                    string(accum-qnty, entry(1, c-v-qnty:private-data, chr(4)))
                   ,c-v-qnty:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 6 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[7]
  then (if 7 < last-col-num then CHR(9) else "")
  else ""
  if use-column[8]
  then (reg-output(
                    string(accum-sum-without-tax-cost, entry(1, c-v-sum-without-tax-cost:private-data, chr(4)))
                   ,c-v-sum-without-tax-cost:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 8 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[9]
  then (reg-output(
                    string(accum-sum-vat-cost, entry(1, c-v-sum-vat-cost:private-data, chr(4)))
                   ,c-v-sum-vat-cost:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 9 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[10]
  then (reg-output(
                    string(accum-sum-with-tax-cost, entry(1, c-v-sum-with-tax-cost:private-data, chr(4)))
                   ,c-v-sum-with-tax-cost:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 10 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[11]
  then (if 11 < last-col-num then CHR(9) else "")
  else ""
  if use-column[12]
  then (reg-output(
                    string(accum-sum-without-tax-sale, entry(1, c-v-sum-without-tax-sale:private-data, chr(4)))
                   ,c-v-sum-without-tax-sale:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 12 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[13]
  then (reg-output(
                    string(accum-sum-vat-sale, entry(1, c-v-sum-vat-sale:private-data, chr(4)))
                   ,c-v-sum-vat-sale:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 13 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[14]
  then (reg-output(
                    string(accum-sum-without-slt-sale, entry(1, c-v-sum-without-slt-sale:private-data, chr(4)))
                   ,c-v-sum-without-slt-sale:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 14 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[15]
  then (reg-output(
                    string(accum-sum-slt-sale, entry(1, c-v-sum-slt-sale:private-data, chr(4)))
                   ,c-v-sum-slt-sale:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 15 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[16]
  then (reg-output(
                    string(accum-sum-with-tax-sale, entry(1, c-v-sum-with-tax-sale:private-data, chr(4)))
                   ,c-v-sum-with-tax-sale:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 16 < last-col-num
         then CHR(9)
         else ""))
  else "":U
SKIP(2).
if Make-Excel then  put   stream ForExcel unformatted
CHR(9)
CHR(9)
"ИТОГО продано с учетом НДС" CHR(9)
string(accum-sum-without-slt-sale, "->>,>>>,>>>,>>9.99")
skip
CHR(9)
CHR(9)
"За проданный товар Комиссионеру причитается вознаграждение в сумме"   CHR(9)
string(accum-sum-without-slt-sale - accum-sum-with-tax-cost, "->>,>>>,>>>,>>9.99")
skip
CHR(9)
CHR(9)
"Подлежит перечислению Комитенту сумма" CHR(9)
string(accum-sum-with-tax-cost, "->>,>>>,>>>,>>9.99")
skip(2)
CHR(9)
CHR(9)
"От Комиссионера" CHR(9)
CHR(9)
CHR(9)
p-host-name CHR(9)
"отчет сдал"
skip
CHR(9)
CHR(9)
CHR(9)
CHR(9)
CHR(9)
CHR(9)
CHR(9)
"(подпись)"
skip
CHR(9)
CHR(9)
CHR(9)
CHR(9)
CHR(9)
CHR(9)
"М.П."
skip(2)
CHR(9)
CHR(9)
"От Комитента" CHR(9)
CHR(9)
CHR(9)
p-supp-name CHR(9)
"отчет принял"
skip
CHR(9)
CHR(9)
CHR(9)
CHR(9)
CHR(9)
CHR(9)
CHR(9)
"(подпись)"
skip
CHR(9)
CHR(9)
CHR(9)
CHR(9)
CHR(9)
CHR(9)
"М.П."
skip.
if v-gen-print then do:
  HIDE STREAM PrnLibStream FRAME FKomis .
  HIDE STREAM PrnLibStream FRAME top-Frame .
  HIDE stream PrnLibStream FRAME NBottomFrame .
  output stream PrnLibStream CLOSE .
end.
if Make-Excel then output stream ForExcel close.
run waitfram-hide in this-procedure .
DELETE WIDGET-POOL "My-pool".
if p-frame-width  <= 198 then do:
  run prn-lib-prn-file in this-procedure (
                                            input parParentProc
                                            ,input 8
                                            ).
end.
else do:
  run get-report-num  in parparentproc (output g#report-num).
  run rep/runexcel.p (string( session:temp-directory) + "rpt" + string( g#report-num ) + ".txt").
end.
procedure underline-frame :
  do
  on error undo, return error
  :
  if use-column[1]
  then  C-v-nn:screen-value = string(fill5).
  if use-column[2]
  then  C-v-artic:screen-value = string(fill16).
  if use-column[3]
  then  C-v-gds-name:screen-value = string(fill30).
  if use-column[4]
  then  C-v-prod:screen-value = string(fill13).
  if use-column[5]
  then  C-v-unit-base:screen-value = string(fill6).
  if use-column[6]
  then  C-v-qnty:screen-value = string(fill15).
  if use-column[7]
  then  C-v-price-without-tax-cost:screen-value = string(fill18).
  if use-column[8]
  then  C-v-sum-without-tax-cost:screen-value = string(fill18).
  if use-column[9]
  then  C-v-sum-vat-cost:screen-value = string(fill18).
  if use-column[10]
  then  C-v-sum-with-tax-cost:screen-value = string(fill18).
  if use-column[11]
  then  C-v-price-without-tax-sale:screen-value = string(fill18).
  if use-column[12]
  then  C-v-sum-without-tax-sale:screen-value = string(fill18).
  if use-column[13]
  then  C-v-sum-vat-sale:screen-value = string(fill18).
  if use-column[14]
  then  C-v-sum-without-slt-sale:screen-value = string(fill18).
  if use-column[15]
  then  C-v-sum-slt-sale:screen-value = string(fill18).
  if use-column[16]
  then  C-v-sum-with-tax-sale:screen-value = string(fill18).
      DISPLAY stream  PrnLibStream with frame FKomis.
      DOWN 1 stream PrnLibStream with frame Fkomis.
  end.
end procedure.
procedure underline-excel :
  do
  on error undo, return error
  :
      if Make-Excel then  put   stream ForExcel unformatted
  if use-column[1]
  then (string(fill5) + (if 1 < last-col-num then CHR(9) else ""))
  else ""
  if use-column[2]
  then (string(fill16) + (if 2 < last-col-num then CHR(9) else ""))
  else ""
  if use-column[3]
  then (string(fill30) + (if 3 < last-col-num then CHR(9) else ""))
  else ""
  if use-column[4]
  then (string(fill13) + (if 4 < last-col-num then CHR(9) else ""))
  else ""
  if use-column[5]
  then (string(fill6) + (if 5 < last-col-num then CHR(9) else ""))
  else ""
  if use-column[6]
  then (string(fill15) + (if 6 < last-col-num then CHR(9) else ""))
  else ""
  if use-column[7]
  then (string(fill18) + (if 7 < last-col-num then CHR(9) else ""))
  else ""
  if use-column[8]
  then (string(fill18) + (if 8 < last-col-num then CHR(9) else ""))
  else ""
  if use-column[9]
  then (string(fill18) + (if 9 < last-col-num then CHR(9) else ""))
  else ""
  if use-column[10]
  then (string(fill18) + (if 10 < last-col-num then CHR(9) else ""))
  else ""
  if use-column[11]
  then (string(fill18) + (if 11 < last-col-num then CHR(9) else ""))
  else ""
  if use-column[12]
  then (string(fill18) + (if 12 < last-col-num then CHR(9) else ""))
  else ""
  if use-column[13]
  then (string(fill18) + (if 13 < last-col-num then CHR(9) else ""))
  else ""
  if use-column[14]
  then (string(fill18) + (if 14 < last-col-num then CHR(9) else ""))
  else ""
  if use-column[15]
  then (string(fill18) + (if 15 < last-col-num then CHR(9) else ""))
  else ""
  if use-column[16]
  then (string(fill18) + (if 16 < last-col-num then CHR(9) else ""))
  else ""
      skip.
  end.
end procedure.
