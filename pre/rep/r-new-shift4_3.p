block-level on error undo, throw.
define input parameter parparentproc         as   widget-handle       no-undo.
define input parameter p-parent-handle            as handle    no-undo .
define input parameter p-log-handle               as handle    no-undo .
define input parameter p-cont-handle              as handle    no-undo .
define input parameter p-rebh                     as handle    no-undo .
define input parameter v-report-name-html         as character no-undo .
define input parameter p-xsd-file                 as character no-undo .
define input parameter p-log-file-name            as character no-undo .
define input parameter p-batch                    as integer   no-undo .
define input parameter p-codex-id                 as integer   no-undo .
define input parameter p-ruleset-id               as integer   no-undo .
define input parameter p-obj-type            like ub.clients.obj-type no-undo.
define input parameter p-obj-code            like ub.clients.obj-code no-undo.
define input parameter p-z-number-list       as   character           no-undo.
define input parameter p-previous-shift-date as   date                no-undo.
define input parameter p-param  as logical no-undo .
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision: ac2de8611dbf, 1057, rls $":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author: EShklyar $":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date: Fri Oct 06 18:33:18 2017 +0300 $":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile: r-new-shift4_3.p $":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive: rep/r-new-shift4_3.p $":U.
define variable vss-description AS CHAR NO-UNDO INIT "$Печать сменного отчета - лист 4 $":U.
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
DEFINE SHARED TEMP-TABLE treal-4 no-undo
FIELD gds-code as integer
FIELD cpay-code as integer
FIELD curr-code as integer
FIELD qnty1 as decimal
FIELD netto as decimal
FIELD out-name as character format "X(20)"
FIELD is-pay as logical
FIELD discnt-type   as integer
FIELD brutto as decimal
FIELD discount-sum as decimal
FIELD chk-qnty as int
FIELD ii as integer
INDEX pi IS UNIQUE PRIMARY
      gds-code
      cpay-code
          discnt-type
      curr-code
      is-pay DESCENDING
INDEX vi
      gds-code
      ii
.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE   TEMP-TABLE actreal-4 no-undo
FIELD gds-code as integer
FIELD cpay-code as integer
FIELD curr-code as integer
FIELD qnty1 as decimal
FIELD netto as decimal
FIELD out-name as character format "X(20)"
FIELD is-pay as logical
FIELD discnt-type   as integer
FIELD brutto as decimal
FIELD discount-sum as decimal
FIELD chk-qnty as int
FIELD ii as integer
INDEX pi IS UNIQUE PRIMARY
      gds-code
      cpay-code
          discnt-type
      curr-code
      is-pay DESCENDING
INDEX vi
      gds-code
      ii
.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE NEW SHARED TEMP-TABLE t-4 no-undo
FIELD gds-code like ub.goods.gds-code
FIELD main-code like ub.bar-code.b-code
FIELD artic like ub.goods.artic
FIELD prod-type like ub.goods.prod-type
FIELD prod-code like ub.goods.prod-code
FIELD last-price as decimal FORMAT ">>>>9.99"
FIELD gds-name like ub.goods.gds-name FORMAT "X(24)"
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE create-treal-4.
DEFINE INPUT PARAMETER pgds-code like ub.goods.gds-code no-undo.
DEFINE INPUT PARAMETER pcpay-code like ub.cash-pay.cdpay-code no-undo.
DEFINE INPUT PARAMETER pcurr-code like ub.cash-pay.curr-code no-undo.
DEFINE INPUT PARAMETER pqnty1 as decimal no-undo.
DEFINE INPUT PARAMETER pnetto as decimal no-undo.
DEFINE INPUT PARAMETER pout-name as character no-undo.
DEFINE INPUT PARAMETER pis-pay as logical no-undo.
DEFINE INPUT PARAMETER pii as integer no-undo.
_main:
DO ON ERROR UNDO _main, return error:
    create treal-4.
    assign
    treal-4.gds-code = pgds-code
    treal-4.cpay-code = pcpay-code
    treal-4.curr-code = pcurr-code
    treal-4.qnty1  =  pqnty1
    treal-4.netto = pnetto
    treal-4.out-name = pout-name
    treal-4.is-pay = pis-pay
    treal-4.ii = pii
    no-error
    .
    if error-status:error then undo _main, return error.
END.
END PROCEDURE.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE create-actreal-4.
DEFINE INPUT PARAMETER pgds-code like ub.goods.gds-code no-undo.
DEFINE INPUT PARAMETER pcpay-code like ub.cash-pay.cdpay-code no-undo.
DEFINE INPUT PARAMETER pcurr-code like ub.cash-pay.curr-code no-undo.
DEFINE INPUT PARAMETER pqnty1 as decimal no-undo.
DEFINE INPUT PARAMETER pnetto as decimal no-undo.
DEFINE INPUT PARAMETER pout-name as character no-undo.
DEFINE INPUT PARAMETER pis-pay as logical no-undo.
DEFINE INPUT PARAMETER pii as integer no-undo.
_main:
DO ON ERROR UNDO _main, return error:
    create actreal-4.
    assign
    actreal-4.gds-code = pgds-code
    actreal-4.cpay-code = pcpay-code
    actreal-4.curr-code = pcurr-code
    actreal-4.qnty1  =  pqnty1
    actreal-4.netto = pnetto
    actreal-4.out-name = pout-name
    actreal-4.is-pay = pis-pay
    actreal-4.ii = pii
    no-error
    .
    if error-status:error then undo _main, return error.
END.
END PROCEDURE.
define NEW SHARED temp-table tmat-4 no-undo
  field netto-before as decimal   format "-999,999,999.99":U
  field netto-after  as decimal   format "-999,999,999.99":U
  field in-benefit   as decimal   format "999,999,999.99":U
  field in-other     as decimal   format "999,999,999.99":U
  field out-bank     as decimal   format "999,999,999.99":U
  field out-other    as decimal   format "999,999,999.99":U
  field out-name     as character format "x(16)":U
  field gg           as integer
  index igg          is primary   unique gg
.
define shared stream  PrnLibstream.
define variable pol1 as character no-undo .
define variable pol2 as integer   no-undo .
define variable pol3 as decimal   no-undo .
define variable pol4 as character no-undo .
define variable pol5 as decimal   no-undo .
define variable pol6 as decimal   no-undo .
define variable pol7 as decimal   no-undo .
define variable pol8 as decimal   no-undo .
define variable pol9 as decimal   no-undo .
define stream Out-Stream.
define stream OutStr-html.
define variable line                 as character no-undo .
DEFINE VARIABLE areal-is-pay-qnty1   as decimal   no-undo.
DEFINE VARIABLE areal-is-pay-netto   as decimal   no-undo.
DEFINE VARIABLE areal-no-pay-qnty1   as decimal   no-undo.
DEFINE VARIABLE areal-no-pay-netto   as decimal   no-undo.
DEFINE VARIABLE areal-qnty1          as decimal   no-undo.
DEFINE VARIABLE areal-netto          as decimal   no-undo.
DEFINE VARIABLE v-total-is-pay-qnty1 as decimal   no-undo.
DEFINE VARIABLE v-total-is-pay-netto as decimal   no-undo.
DEFINE VARIABLE v-total-no-pay-qnty1 as decimal   no-undo.
DEFINE VARIABLE v-total-no-pay-netto as decimal   no-undo.
DEFINE VARIABLE v-total-qnty1        as decimal   no-undo.
DEFINE VARIABLE v-total-netto        as decimal   no-undo.
DEFINE VARIABLE a-qnty1              as decimal   no-undo.
DEFINE VARIABLE a-netto              as decimal   no-undo.
DEFINE VARIABLE loc-real-ii          as integer   no-undo.
DEFINE VARIABLE curr-real-ii         as integer   no-undo.
DEFINE VARIABLE jj                   as integer   no-undo.
DEFINE VARIABLE loc-jj               as integer   no-undo.
DEFINE VARIABLE main-line            as logical   no-undo.
DEFINE VARIABLE mat-line             as logical   no-undo.
DEFINE VARIABLE pay-line             as logical   no-undo.
DEFINE VARIABLE a-line               as logical   no-undo.
DEFINE VARIABLE max-line             as integer   no-undo.
DEFINE VARIABLE max-real             as integer   no-undo.
DEFINE VARIABLE rc                   as recid     no-undo.
DEFINE VARIABLE acii                 as integer   no-undo .
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
run rep/r-shft4r.p
    (input p-obj-type,
    input p-obj-code,
    input X-date-Start,
    input X-Shift-Start,
    input X-date-End,
    input X-Shift-End,
    input p-previous-shift-date
    ) no-error.
output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' .
put stream OutStr-html unformatted
    substitute (
    '<tbody> <!-- Здесь начинается таблица отчета -->
                <tr> <!-- Первые строки – шапка таблицы с тэгами tr -->
                <th colspan="3" style="text-align: center;">Информация об услуге</th>
                <th colspan="6" style="text-align: center;">Расшифровка реализации услуг</th>
            </tr>
            <tr>
                <th style="text-align: center;">Наименование услуги</th>
                <th style="text-align: center;">Код услуги</th>
                <th style="text-align: center;">Цена рознич. на конец смены</th>
                <th style="text-align: center;">Тип расхода (тип платежа)</th>
                <th style="text-align: center;">Кол-во</th>
                <th style="text-align: center;">Сумма</th>
                <th style="text-align: center;">Сумма скидки</th>
                <th style="text-align: center;">Сумма брутто</th>
                <th style="text-align: center;">Кол-во покупок</th>
            </tr>
            <tr>
                <th style="text-align: center;">4.1</th>
                <th style="text-align: center;">4.2</th>
                <th style="text-align: center;">4.3</th>
                <th style="text-align: center;">4.4</th>
                <th style="text-align: center;">4.5</th>
                <th style="text-align: center;">4.6</th>
                <th style="text-align: center;">4.7</th>
                <th style="text-align: center;">4.8</th>
                <th style="text-align: center;">4.9</th>
            </tr>
            '
    , chr(123), chr(125)
    ).
for each actreal-4:
    delete actreal-4.
end.
FOR EACH t-4 use-index pi:
    assign
        areal-is-pay-qnty1 = 0
        areal-is-pay-netto = 0
        areal-no-pay-qnty1 = 0
        areal-no-pay-netto = 0
        areal-qnty1        = 0
        areal-netto        = 0
        loc-real-ii        = 1
        curr-real-ii       = 1
        .
    FIND LAST treal-4 No-LOCK WHERE
        treal-4.gds-code = t-4.gds-code AND
        treal-4.is-pay = yes use-index vi No-ERROR.
    if avail treal-4 then
        assign
            loc-real-ii  = treal-4.ii + 1
            curr-real-ii = treal-4.ii + 1
            .
    IF can-find(first treal-4 WHERE
        treal-4.gds-code = t-4.gds-code) then
    do:
        FOR EACh  treal-4 where
            treal-4.gds-code = t-4.gds-code use-index pi:
            if treal-4.discnt-type = -99 then do:
            assign
                areal-qnty1 = areal-qnty1 + treal-4.qnty1
                areal-netto = areal-netto + treal-4.netto
                .
            if treal-4.is-pay then
                assign
                    areal-is-pay-qnty1 = areal-is-pay-qnty1 + treal-4.qnty1
                    areal-is-pay-netto = areal-is-pay-netto + treal-4.netto
                    .
            else
                assign
                    rc                 = recid(treal-4)
                    curr-real-ii       = (if curr-real-ii = loc-real-ii AND
                         (loc-real-ii > 1   OR
                          can-find(first treal-4 No-LOCK WHERE
                                         treal-4.gds-code = t-4.gds-code AND
                                         treal-4.is-pay = no AND
                                         recid(treal-4) <> rc)
                          )
                      then (curr-real-ii + 1)
                      else curr-real-ii
                     )
                    treal-4.ii         = curr-real-ii
                    curr-real-ii       = curr-real-ii + 1
                    areal-no-pay-qnty1 = areal-no-pay-qnty1 + treal-4.qnty1
                    areal-no-pay-netto = areal-no-pay-netto + treal-4.netto
                    .
            end.
        END.
        if curr-real-ii > 2 then
        do:
            run create-treal-4 (
                INPUT t-4.gds-code,
                INPUT 0,
                INPUT 0,
                INPUT areal-is-pay-qnty1,
                INPUT areal-is-pay-netto,
                INPUT "ИТОГО ОПЛАЧ.РАСХОД",
                INPUT yes,
                INPUT loc-real-ii) no-error.
            if loc-real-ii = curr-real-ii then
                curr-real-ii = curr-real-ii + 1.
            run create-treal-4 (
                INPUT t-4.gds-code,
                INPUT 0,
                INPUT 0,
                INPUT areal-no-pay-qnty1,
                INPUT areal-no-pay-netto,
                INPUT "ИТОГО ПРОЧ.РАСХОДОВ",
                INPUT no,
                INPUT curr-real-ii) no-error.
            curr-real-ii = curr-real-ii + 1.
            run create-treal-4 (
                INPUT t-4.gds-code,
                INPUT 0,
                INPUT 0,
                INPUT areal-qnty1,
                INPUT areal-netto,
                INPUT "ВСЕГО  РАСХОД",
                INPUT ?,
                INPUT curr-real-ii) no-error.
        END.
    END.
    assign
        t-4.lines = MAX(curr-real-ii, 1)
        .
END.
FOR EACH t-4 No-LOCK,
    EACH treal-4 No-LOCK WHERE
    treal-4.gds-code = t-4.gds-code
    BREAK BY treal-4.gds-code
    BY treal-4.is-pay descending
    BY treal-4.ii:
    assign
        pol1      = ""
        pol2      = 0
        pol3      = 0
        pol4      = ""
        pol5      = 0
        pol6      = 0
        pol7      = 0
        pol8      = 0
        pol9      = 0
        main-line = no
        pay-line  = no
        .
    IF FIRST-OF(treal-4.gds-code) then
    do:
        assign
            pol1      = t-4.gds-name
            pol2      = t-4.main-code
            pol3      = t-4.last-price
            main-line = yes
            .
    END.
    assign
        pol4 = treal-4.out-name
        pol5 = treal-4.qnty1
        pol6 = treal-4.netto
        pol7 = treal-4.discount-sum
        pol8 = treal-4.brutto
        pol9 = treal-4.chk-qnty
        .
        if treal-4.discnt-type = -99 then do:
        assign
        a-netto   = a-netto + treal-4.netto
        a-qnty1   = a-qnty1 + treal-4.qnty1
        .
        end.
    if treal-4.cpay-code <> 0 and treal-4.discnt-type = -99 then
    dO:
        FIND FIRST actreal-4 WHERE
            actreal-4.gds-code = 0 AND
            actreal-4.cpay-code = treal-4.cpay-code AND
            actreal-4.curr-code = treal-4.curr-code AND
            actreal-4.is-pay = treal-4.is-pay  NO-ERROR.
        if not avail actreal-4 then
        do:
            acii = acii + 1.
            run create-actreal-4 (
                INPUT 0,
                INPUT treal-4.cpay-code,
                INPUT treal-4.curr-code,
                INPUT treal-4.qnty1,
                INPUT treal-4.netto,
                INPUT treal-4.out-name,
                INPUT treal-4.is-pay,
                INPUT acii) no-error.
        end.
        else
            assign
                actreal-4.qnty1 = actreal-4.qnty1 + treal-4.qnty1
                actreal-4.netto = actreal-4.netto + treal-4.netto
                .
    end.
    if pol5 <> 0 then
    do:
        put stream OutStr-html unformatted
            substitute (
            '<tr>
                <td text_wrap="true">&1</td>
                <td style="text-align: right;">&2</td>
                <td style="text-align: right;">&3</td>
                <td text_wrap="true">&4</td>
                <td style="text-align: right;">&5</td>
                <td style="text-align: right;">&6</td>
                <td style="text-align: right;">&7</td>
                <td style="text-align: right;">&8</td>
                <td style="text-align: right;">&9</td>
            </tr>    
                '
            ,
            if main-line = no then "" else string(pol1),
            if main-line = no then "" else string(pol2),
            if main-line = no then "" else string(pol3,"->>>>>>>>>>>9.99"),
            pol4,
            string(pol5,"->>>>>>>>>>>9"),
            string(pol6,"->>>>>>>>>>>9.99"),
            if pol7 = 0 then "" else string(pol7,"->>>>>>>>>>>9.99"),
            if pol8 = 0 then "" else string(pol8,"->>>>>>>>>>>9.99"),
            if pol9 = 0 then "" else string(pol9,"->>>>>>>>>>>9.99")
            ).
    end.
    IF LAST(treal-4.gds-code) then
    do:
        assign
            pol1 = "ВСЕГО РЕАЛИЗОВАНО УСЛУГ  :"
            pol5 = a-qnty1
            pol6 = a-netto
            .
        put stream OutStr-html unformatted
            substitute (
            '<tr>
                <th text_wrap="true" style="text-align: left">&1</th>
                <th></th>
                <th></th>
                <th></th>
                <th style="text-align: right;">&2</th>
                <th style="text-align: right;">&3</th>
                <th style="text-align: right;"></th>
                <th style="text-align: right;"></th>
                <th style="text-align: right;"></th>
            </tr>    
                '
            ,
            pol1,
            string(pol5,"->>>>>>>>>>>9"),
            string(pol6,"->>>>>>>>>>>9.99")
            ).
        if can-find(first actreal-4) then
        do:
            pol4 = "     в том числе:".
            put stream OutStr-html unformatted
                substitute (
                '<tr>
                <td></td>
                <td></td>
                <td></td>
                <td text_wrap="true" style="text-align: left;">&1</td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
            </tr>    
                '
                ,
                pol4
                ).
            assign
                areal-is-pay-qnty1 = 0
                areal-is-pay-netto = 0
                areal-no-pay-qnty1 = 0
                areal-no-pay-netto = 0
                .
RELEASE actreal-4 no-error.
            FOR EACH actreal-4 No-LOCK
                BREAK
                BY actreal-4.gds-code
                By actreal-4.is-pay descending
                BY actreal-4.cpay-code descending
                BY actreal-4.curr-code:
                if actreal-4.is-pay = yes then
                    assign
                        areal-is-pay-qnty1 = areal-is-pay-qnty1 + actreal-4.qnty1
                        areal-is-pay-netto = areal-is-pay-netto + actreal-4.netto
                        .
                else
                    assign
                        areal-no-pay-qnty1 = areal-no-pay-qnty1 + actreal-4.qnty1
                        areal-no-pay-netto = areal-no-pay-netto + actreal-4.netto
                        .
                assign
                    pol4 = actreal-4.out-name
                    pol5 = actreal-4.qnty1
                    pol6 = actreal-4.netto
                    pol7 = actreal-4.discount-sum
                    pol8 = actreal-4.brutto
                    pol9 = actreal-4.chk-qnty
                    .
                put stream OutStr-html unformatted
                    substitute (
                    '<tr>
                <td></td>
                <td></td>
                <td></td>
                <td>&1</td>
                <td style="text-align: right;">&2</td>
                <td style="text-align: right;">&3</td>
                <td style="text-align: right;"></td>
                <td style="text-align: right;"></td>
                <td style="text-align: right;"></td>
            </tr>    
                '
                    ,
                    pol4,
                    string(pol5,"->>>>>>>>>>>9"),
                    string(pol6,"->>>>>>>>>>>9.99"),
                    if pol7 = 0 then "" else string(pol7,"->>>>>>>>>>>9.99"),
                    if pol8 = 0 then "" else string(pol8,"->>>>>>>>>>>9.99"),
                    if pol9 = 0 then "" else string(pol9,"->>>>>>>>>>>9.99")
                    ).
                if last-of(actreal-4.is-pay)  then
                do:
                    if actreal-4.is-pay = yes then
                        assign
                            pol4 = "ИТОГО ОПЛАЧ.РАСХОД"
                            pol5 = areal-is-pay-qnty1
                            pol6 = areal-is-pay-netto
                            .
                    else
                        assign
                            pol4 = "ИТОГО ПРОЧ.РАСХОД"
                            pol5 = areal-no-pay-qnty1
                            pol6 = areal-no-pay-netto
                            .
                    put stream OutStr-html unformatted
                        substitute (
                        '<tr>
                <td></td>
                <td></td>
                <td></td>
                <td text_wrap="true">&1</td>
                <td style="text-align: right;">&2</td>
                <td style="text-align: right;">&3</td>
                <td style="text-align: right;"></td>
                <td style="text-align: right;"></td>
                <td style="text-align: right;"></td>
            </tr>    
                '
                        ,
                        pol4,
                        string(pol5,"->>>>>>>>>>>9"),
                        string(pol6,"->>>>>>>>>>>9.99")
                        ).
                end.
            END.
        end.
    end.
END.
output stream OutStr-html close.
output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' .
put stream OutStr-html unformatted
    substitute (
    '
        </tbody>
        '
    , chr(123), chr(125)
    ).
output stream OutStr-html close.
