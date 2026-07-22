/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Класс для экспорта справочных данных для АТД клиента

Автор: Курбет Антон
Дата создания: 23/07/18
Author: Kurbet Anton
Creation date: 23/07/18

*/

using Progress.Lang.*.

class ibs.th.bge.atd.dict-atd-exp: 
   {cmp/str-glbl.i class}
   {str/lib-trn.i class}
   
   define private property pFilePath    as character no-undo get. set.
   define private property pCurDbNum    as int64     no-undo get. set.
   define private property pCurObjType  as character no-undo get. set.
   define private property pCurObjCode  as int64     no-undo get. set.
   define private property pAtdReg      as character no-undo get. set.

   define temp-table ttgoods no-undo
      field gcode as int64 label "GlobalCode" 
      field lcode as int64 label "LocalCode"
   index ndx gcode.
  
   define temp-table ttclients no-undo
      field objname as character label "Name_Object"
      field objcode as int64     label "SiteID"
      field objaddr as character label "Address"
   index ndx objname.
   
   define temp-table ttcashdesks no-undo
      field objip       as character label "IP"
      field objname     as int64     label "Name"
      field objsiteid   as int64     label "NObjectId_Name"
      field cash-type   as integer   label "cash_type"
   index ndx objip.
   
   define temp-table tttanks no-undo
      field objnum   as int64       label "TankNumber"
      field objgrade as int64       label "Grade"
      field objname  as character   label "Grade_Name"
      field max-volume  as decimal  label "Max_volume"
      field water-level as character label "WaterLevel_Allow"
      field water-alarm as character label "water_alarm"
      field level-alarm as character label "level_alarm"
   index ndx objnum. 
   
   define temp-table ttsched no-undo
      field water-sched as int64  label "water_sched"
      field level-sched as int64  label "level_sched"
   .
   
   constructor public dict-atd-exp (iFilePath as character, 
                                    iDbNum    as int64,
                                    iObjType  as character,
                                    iObjCode  as int64):
      define variable vPType as character no-undo.
      
      run gbl/conf-rd.p ("atd-reg","","",0,"","","",yes,output pAtdReg,output vPType) no-error.
      assign 
         pFilePath   = iFilePath
         pCurDbNum   = iDbNum
         pCurObjType = iObjType
         pCurObjCode = iObjCode
      .
      if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn)
      then run str/lib-trn.p persistent no-error .
   end constructor.
   
   constructor public dict-atd-exp (iDbNum    as int64,
                                    iObjType  as character,
                                    iObjCode  as int64):
      define variable vPType as character no-undo.
      run gbl/conf-rd.p ("atd-reg","","",0,"","","",no,output pAtdReg,output vPType) no-error.
      
      assign 
         pCurDbNum   = iDbNum
         pCurObjType = iObjType
         pCurObjCode = iObjCode
      .
      if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn)
      then run str/lib-trn.p persistent no-error .
   end constructor.

   destructor dict-atd-exp():

   end destructor.
   
   method void WriteFile(input iFileName as char, input iContents as longchar):
      copy-lob iContents to file iFileName.
   end method.
   
   method public void RunFileTask():
      if pCurObjType <> 'маг' then do:
         message substitute("Выгрузка по объекту типа : &1 не производится!",pFilePath)
         view-as alert-box.
         return.
      end.
      if pAtdReg = '' or pAtdReg = ? then do:
         message "Выгрузка при выключенном параметре atd-reg не производится!"
         view-as alert-box.
         return.
      end.
      
      CrtReCodesTable().
      CrtNObjectTable().
      CrtNCassaTable().
      CrtNTankTable().
      CrtNSchedTable().
    
      WriteFile(pFilePath + "\ReCodesTables.tbl",ExpJson(temp-table ttgoods:handle)).
      WriteFile(pFilePath + "\NObject.tbl",ExpJson(temp-table ttclients:handle)).
      WriteFile(pFilePath + "\NCassa.tbl",ExpJson(temp-table ttcashdesks:handle)).
      WriteFile(pFilePath + "\NTank.tbl",ExpJson(temp-table tttanks:handle)).
      WriteFile(pFilePath + "\NSched.tbl",ExpJson(temp-table ttsched:handle)).
     
      message substitute("Выгрузка в &1 завершена!",pFilePath)
      view-as alert-box.
   end method.
   
   method public longchar GetReCodesTable():
      CrtReCodesTable().
      return ExpJson(temp-table ttgoods:handle).
   end method.

   method public longchar GetNObjectTable():
      CrtNObjectTable().
      return ExpJson(temp-table ttclients:handle).
   end method.

   method public longchar GetNCassaTable():
      CrtNCassaTable().
      return ExpJson(temp-table ttcashdesks:handle).
   end method.

   method public longchar GetNTankTable():
      CrtNTankTable().
      return ExpJson(temp-table tttanks:handle).
   end method.
   
   method public longchar GetNSchedTable():
      CrtNSchedTable().
      return ExpJson(temp-table ttsched:handle).
   end method.
   
   method private void CrtReCodesTable():

      define buffer bgoods    for ub.goods.
      define buffer bbar-code for ub.bar-code.
      define buffer bprod-bc  for ub.prod-bc.
      
      define variable vIsPetrol  as logical no-undo init yes.
      define variable vIsPieces  as logical no-undo.
      
      loop:
      for each bgoods where  bgoods.stts = 0  
      no-lock:

         { str/is-petrl.i
           bgoods.artic
           bgoods.prod-type
           bgoods.prod-code
           vIsPetrol
           vIsPieces
         }

         if not vIsPetrol then next loop.
        
         for each bbar-code where bbar-code.gds-code = bgoods.gds-code
         no-lock,
            each bprod-bc where bprod-bc.b-code = bbar-code.b-code
            no-lock:
               create ttgoods.
               assign 
                  ttgoods.gcode = bgoods.gds-code 
                  ttgoods.lcode = int64(bprod-bc.b-str)
               .
         end.
      end.
      
   end method.

   method private void CrtNObjectTable():

      define buffer bclients  for ub.clients.
      define buffer bshop     for ub.shop.
      define buffer bfirm     for ub.firm.
      define buffer bperson   for ub.person.
      
      define variable vAddr   as character no-undo.
      define variable vN      as int64     no-undo.  

      assign 
         vAddr = pAtdReg
         vN = length(vAddr)
      .
      if vN < 3 then vAddr = fill("0", 3 - vN) + vAddr.
       
      for first bclients where bclients.obj-type = pCurObjType
                           and bclients.obj-code = pCurObjCode
                           /*and bclients.db-num   = pCurDbNum*/
                           and bclients.stts     = 0  
      no-lock,
         first bshop where bshop.obj-code = bclients.obj-code
         no-lock:
            
            create ttclients.
            assign 
               ttclients.objname = replace(bclients.obj-name, '"', "&quot;")
               ttclients.objcode = bclients.obj-code
               ttclients.objaddr = vAddr              
            .
      end.
      
   end method.

   method private void CrtNCassaTable():

      define buffer bclients    for ub.clients.
      define buffer bcash-desk  for ub.cash-desk.
      define buffer buf_cash-desk-attr for ub.cash-desk-attr .
      
      for first bclients where bclients.obj-type = pCurObjType
                           and bclients.obj-code = pCurObjCode
                           /*and bclients.db-num   = pCurDbNum*/
                           and bclients.stts     = 0  
      no-lock,
         each bcash-desk where bcash-desk.obj-code = bclients.obj-code
                           and bcash-desk.is-del   = no   
         no-lock:
            
            create ttcashdesks.
            assign 
               ttcashdesks.objname    = bcash-desk.cash-num 
               ttcashdesks.objip      = FilterIPandPort(bcash-desk.addr-path)
               ttcashdesks.objsiteid  = bclients.obj-code              
               ttcashdesks.cash-type  = bcash-desk.device-kind  
            .
         end.
   end method.

   method private void CrtNTankTable():

      define buffer bclients  for ub.clients.
      define buffer bpl-gds   for ub.pl-gds.
      define buffer bbar-code for ub.bar-code.
      define buffer bprod-bc  for ub.prod-bc.
      define buffer bplace    for ub.place.
      define buffer bgoods    for ub.goods.
      define buffer bshift-obj for ub.shift-obj.
      define buffer bplace-attr for ub.place-attr.
      
      define variable v-attr-shift-date   as date     no-undo .
      define variable v-attr-shift-num    as integer  no-undo .
      
      for each bplace where bplace.obj-type = pCurObjType
                        and bplace.obj-code = pCurObjCode
                        /*and bplace.db-num   = pCurDbNum*/
                        and bplace.status_  = ''
      no-lock, 
         each bpl-gds where bpl-gds.obj-type = bplace.obj-type
                        and bpl-gds.pl-code  = bplace.pl-code   
         no-lock,
            first bbar-code where bbar-code.b-code = bpl-gds.gds-code
            no-lock,
               first bgoods where bgoods.gds-code = bpl-gds.gds-code
               no-lock:
    
               find first bprod-bc where bprod-bc.b-code = bbar-code.b-code
               no-lock no-error.
               
               create tttanks.
               assign 
                  tttanks.objnum    = int64(bplace.loc1) 
                  tttanks.objgrade  = if available bprod-bc 
                                      then int64(bprod-bc.b-str)
                                      else bbar-code.b-code
                  tttanks.objname   = bgoods.gds-name   
                  tttanks.max-volume = bplace.max-qnty            
               no-error.
               
               find first bplace-attr no-lock where bplace-attr.attr-code   = "water-level"
                                                and bplace-attr.obj-code    = bplace.obj-code
                                                and bplace-attr.obj-type    = bplace.obj-type
                                                and bplace-attr.pl-code     = bplace.pl-code
                                                no-error .
               if not available bplace-attr
               or bplace-attr.attr-value = ?
               or bplace-attr.attr-value = "?"
               then do :
                 assign tttanks.water-level = "" .
               end .
               else do :
                 assign tttanks.water-level = bplace-attr.attr-value .
               end .                               
               
               find first bshift-obj where bshift-obj.obj-type = bplace.obj-type
                                       and bshift-obj.obj-code = bplace.obj-code
                                       and bshift-obj.status_ = {&sht-current}
                                       use-index stts no-lock no-error .
               if not available bshift-obj
               then do :
                 assign
                   tttanks.level-alarm = "enable"
                   tttanks.water-alarm = "enable"
                 .
               end .
               else do :
                 find first bplace-attr no-lock where bplace-attr.attr-code   = "disable-water-alarm"
                                                  and bplace-attr.obj-code    = bplace.obj-code
                                                  and bplace-attr.obj-type    = bplace.obj-type
                                                  and bplace-attr.pl-code     = bplace.pl-code
                                                  no-error .
                 if not available bplace-attr
                 or num-entries(bplace-attr.attr-value, {&delim-par}) <> 3
                 then do :
                   assign
                     tttanks.water-alarm = "enable"
                   .
                 end .  
                 else do :
                   v-attr-shift-date = date(entry(2, bplace-attr.attr-value, {&delim-par})) .
                   v-attr-shift-num = integer(entry(3, bplace-attr.attr-value, {&delim-par})) .
                   if v-attr-shift-date = bshift-obj.shift-date
                   and v-attr-shift-num = bshift-obj.shift-num
                   then do :
                     assign
                       tttanks.water-alarm = entry(1, bplace-attr.attr-value, {&delim-par})
                     .
                   end .
                   else do :
                     assign
                       tttanks.water-alarm = "enable"
                     .
                   end .
                 end .   /* water-alarm */
                 
                 find first bplace-attr no-lock where bplace-attr.attr-code   = "disable-level-alarm"
                                                  and bplace-attr.obj-code    = bplace.obj-code
                                                  and bplace-attr.obj-type    = bplace.obj-type
                                                  and bplace-attr.pl-code     = bplace.pl-code
                                                  no-error .
                 if not available bplace-attr
                 or num-entries(bplace-attr.attr-value, {&delim-par}) <> 3
                 then do :
                   assign
                     tttanks.level-alarm = "enable"
                   .
                 end .  
                 else do :
                   v-attr-shift-date = date(entry(2, bplace-attr.attr-value, {&delim-par})) .
                   v-attr-shift-num = integer(entry(3, bplace-attr.attr-value, {&delim-par})) .
                   if v-attr-shift-date = bshift-obj.shift-date
                   and v-attr-shift-num = bshift-obj.shift-num
                   then do :
                     assign
                       tttanks.level-alarm = entry(1, bplace-attr.attr-value, {&delim-par})
                     .
                   end .
                   else do :
                     assign
                       tttanks.level-alarm = "enable"
                     .
                   end .
                 end .   /* level-alarm */                            
               end .
      end.
   end method.
   
   method private void CrtNSchedTable():

      define buffer bclients for ub.clients .
      define buffer bclients-attr for ub.clients-attr .
       
      for first bclients where bclients.obj-type = pCurObjType
                           and bclients.obj-code = pCurObjCode
                           and bclients.stts     = 0  
      no-lock,
         first bclients-attr where bclients-attr.obj-type = bclients.obj-type
                               and bclients-attr.obj-code = bclients.obj-code
                               and bclients-attr.attr-code = {&attr-atd-alarm-schedule}
                               and bclients-attr.attr-value > ""
         exclusive-lock:
            
            create ttsched .
            assign 
               ttsched.water-sched = integer(entry(1, bclients-attr.attr-value)) * 60
               ttsched.level-sched = integer(entry(2, bclients-attr.attr-value)) * 60
            .
            
            bclients-attr.attr-value = "" .
      end.
      
   end method.
   
   method private longchar ExpJson(input hTab as handle):
      
      define variable vI    as int64    no-undo.
      define variable vBuff as handle   no-undo.
      define variable vQry  as handle   no-undo.
      define variable vRes  as longchar no-undo init "". 
      
      if not hTab:has-records then return vRes.
       
 
      vRes = vRes + "~[".

      create query vQry.
      
      vBuff = hTab:default-buffer-handle.
      
      vQry:set-buffers(vBuff). 
      vQry:query-prepare(substitute("FOR EACH &1",hTab:name)).
      vQry:query-open.
      vQry:get-next().

      loop:
      repeat:
         vRes = vRes + "~{".
         do vI = 1 to vBuff:num-fields:
            vRes = vRes +  
               quoter(vBuff:buffer-field[vI]:label) + ":" +
               quoter(vBuff:buffer-field[vI]:buffer-value).
            if vI <> vBuff:num-fields then 
               vRes = vRes + ",".
         end.
         vRes = vRes + "~}".
         vQry:get-next().
         if not vQry:query-off-end then vRes = vRes + ",".
         else leave loop.
      end.
      
      vQry:query-close().
      delete object vQry.

      vRes = vRes + "~]".
      
      return vRes.

   end method.

   method private char FilterIPandPort( input iStr as character ):
      
      define variable vRes as character   no-undo.
      define variable vI   as int64       no-undo init 1.
      define variable vC   as character   no-undo.

      do while (vI <= length(iStr)):
         vC = substring(iStr,vI,1).
         if vC >= '0' and vC <= '9' then leave.
         vI = vI + 1.
      end.
      
      if vI < length(iStr) then do:
         vRes = substring(iStr,vI).
         vI = length(vRes).
         do while (vI > 0):
            vC = substring(vRes,vI,1).
            if vC >= '0' and vC <= '9' then leave.
            vI = vI - 1.
         end.
         
         if vI > 0 then do:
            vRes = substring(vRes,1,vI).
            /* TODO: можно еще много чего писать */
         end.
      end.
         
      return vRes.

   end method.

end class.