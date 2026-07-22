&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE InitForm DIALOG-1
procedure InitForm :
   define variable v-time as integer no-undo .
   define variable dca as integer no-undo .
   define variable v-label as character no-undo .
   define variable v-tooltip as character no-undo .
   define variable ii as integer no-undo .
   define variable v-device-kind as character no-undo .
   define variable v-device-integer as character no-undo .
   DEFINE VARIABLE v-ii         AS INTEGER   NO-UNDO.
   define variable objType    as ibs.th.gbl.propmap no-undo.
   
   define variable mCashDevice      as ibs.th.str.cash.CashDevice no-undo.
    
   assign
      vlistValue    = ""
      vlistValueRet = ""
   .
   publish "getComboList" (spr,output vlistValue, output vlistValueRet).
   if vlistValue eq ""
   then 
      vlistValue = ?.
   if vlistValueRet eq ""
   then 
      vlistValueRet = ?.
   case type:
      when "character" then do:
         if can-do( "trn-stat,trn-type,order-status-all,order-type-all,ext-doc-type,pr-stat,fbr-stat,gds-type,form-type,actions," +
                     "tbl-name,purch-code,fin-doc-stat,fin-doc-type,fin-ext-doc-type," +
                     "gds-hist-subject,cli-hist-subject,dc-hist-subject,dc-type-hist-subject,tax-hist-subject,hist-source-type,scl-hist-subject," +
                     "contract-type,usl-opl,db-rec-attr-type,db-rec-attr-cmd,nws-coll_codes," +
                     "gds-grp-hist-subject,cli-grp-hist-subject,fbr-gds-grp-hist-subject,plc-hist-subject,pmp-hist-subject,nzl-hist-subject," +
                     "sht-hist-subject,sert-hist-subject," +
                     "cd-types,cd-types-real,cd-types-discnt,rcv-type-all,wth-ext-type", spr )
            or vlistValue ne ?            
         then do:
            frame {&frame-name}:title = "Выберите значение".
            if vlistValue eq ?
            then  
               case spr:
                  when "trn-stat"            then vlistValue = {&trn-stat}.
                  when "order-status-all"    then vlistValue = {&ord-status}.
                  when "order-type-all"      then vlistValue = {&order-type-all}.
                  when "trn-type"            then vlistValue = {&trn-type}.
                  when "db-rec-attr-type"    then vlistValue = "commit,execution,recover".
                  when "fin-doc-stat"        then vlistValue = {&fin-status-all}.
                  when "fin-doc-type"        then vlistValue = {&fin-doc-types}.
                  when "pr-stat"             then vlistValue = {&pr-stat}.
                  when "fbr-stat"            then vlistValue = {&fbr-stat}.
                  when "gds-type"            then vlistValue = {&gds-type}.
                  when "actions"             then vlistValue = {&h-actions}.
                  when "tbl-name"            then vlistValue = {&h-tbl-names}.
                  when "purch-code"          then vlistValue = {&purchase-codes-full}.
                  when "form-type"           then vlistValue = "{&form-type}".
                  when "contract-type"       then vlistValue = {&contract-type-list} .
                  when "usl-opl"             then vlistValue = {&contr-usl-opl-list} .
                  when "rcv-type-all"        then
                     assign
                        vlistValue    = {&rcv-type-spis_full}
                        vlistValueRet = {&rcv-type-spis}
                     .
                  when "ext-doc-type"        then
                     assign
                        vlistValue    = {&TDEDT_List-full}
                        vlistValueRet = {&TDEDT_List}
                     .
                  when "db-rec-attr-cmd"     then do:
                     assign
                        vlistValueRet = {&db-rec-attr-list}
                        vlistValue = "":U
                     .
                     do ii = 1 to num-entries(vlistValueRet):
                        vlistValue = (if ii = 1 then "":U else vlistValue) +
                                     (if ii = 1 then "":U else {&comma-char}) +
                                     progs-title-function(entry(ii, vlistValueRet))
                        .
                     end.
                  end.
                  when "nws-coll_codes" then do:
                     assign
                        vlistValueRet = {&nws-coll_codes}
                        vlistValue    = "":U
                     .
                     &scop nws-coll_code entry(ii, vlistValue)
                     do ii = 1 to num-entries({&nws-coll_codes}):
                        vlistValue = (if ii = 1 then "":U else vlistValue) +
                                     (if ii = 1 then "":U else {&comma-char}) +
                                     {&nws-coll_name}
                        .
                     end.
                  end.
                  when "fin-ext-doc-type" then do:
                     assign
                        vlistValue = {&fin-ext-doc-types-full}
                        vlistValueRet = {&fin-ext-doc-types}
                     .
                  end.
                  when "gds-hist-subject"  then do:
                     assign
                        vlistValue    = {&gds-hist-subject-full}
                        vlistValueRet = {&gds-hist-subject}
                     .
                  end.
                  when "cli-hist-subject"  then
                     assign
                        vlistValue    = {&cli-hist-subject-full}
                        vlistValueRet = {&cli-hist-subject}
                     .
                  when "dc-hist-subject"  then
                     assign
                        vlistValue    = {&dc-hist-subject-full}
                        vlistValueRet = {&dc-hist-subject}
                     .
                  when "dc-type-hist-subject"  then
                     assign
                        vlistValue    = {&dc-type-hist-subject-full}
                        vlistValueRet = {&dc-type-hist-subject}
                     .
                  when "tax-hist-subject"  then do:
                     assign
                        vlistValue    = {&tax-hist-subject-full}
                        vlistValueRet = {&tax-hist-subject}
                     .
                  end.
                  when "gds-grp-hist-subject"  then
                     assign
                        vlistValue    = {&gds-grp-hist-subject-full}
                        vlistValueRet = {&gds-grp-hist-subject}
                     .
                  when "cli-grp-hist-subject"  then
                     assign
                        vlistValue    = {&cli-grp-hist-subject-full}
                        vlistValueRet = {&cli-grp-hist-subject}
                     .
                  when "fbr-gds-grp-hist-subject"  then
                     assign
                        vlistValue    = {&fbr-gds-grp-hist-subject-full}
                        vlistValueRet = {&fbr-gds-grp-hist-subject}
                     .
                  when "plc-hist-subject"  then
                     assign
                        vlistValue    = {&plc-hist-subject-full}
                        vlistValueRet = {&plc-hist-subject}
                     .
                  when "pmp-hist-subject"  then
                     assign
                        vlistValue    = {&pmp-hist-subject-full}
                        vlistValueRet = {&pmp-hist-subject}
                     .
                  when "nzl-hist-subject"  then
                     assign
                        vlistValue    = {&nzl-hist-subject-full}
                        vlistValueRet = {&nzl-hist-subject}
                     .
                  when "sht-hist-subject"  then
                     assign
                        vlistValue    = {&sht-hist-subject-full}
                        vlistValueRet = {&sht-hist-subject}
                     .
                  when "sert-hist-subject"  then
                     assign
                        vlistValue = {&sert-hist-subject-full}
                        vlistValueRet = {&sert-hist-subject}
                     .
                  when "hist-source-type"  then do:
                     assign
                        vlistValue    = {&hn-sources-full}
                        vlistValueRet = {&hn-sources}
                     .
                  end.
                  when "scl-hist-subject"  then do:
                     assign
                        vlistValue    = {&scl-hist-subject-full}
                        vlistValueRet = {&scl-hist-subject}
                     .
                  end.
                  when "cd-types" then do:
                     assign
                        vlistValue    = {&cd-type-codes-full}
                        vlistValueRet = {&cd-type-codes}
                     .
                  end.
                  when "cd-types-real" then do:
                     assign
                        vlistValue    = {&cd-type-codes-real-full}
                        vlistValueRet = {&cd-type-codes-real}
                     .
                  end.
                  when "cd-types-discnt" then do:
                     assign
                        vlistValue    = {&cd-type-codes-discnt-full}
                        vlistValueRet = {&cd-type-codes-discnt}
                     .
                  end.
                  when "wth-ext-type" then do:
                     assign
                        vlistValue    = {&WDEDT_List-full}
                        vlistValueRet = {&WDEDT_List}
                     .
                  end.
               end case.
            comb:list-items   = vlistValue.
            if num-entries(vlistValue) > 2
            then
               comb:inner-lines = num-entries(vlistValue).
            comb = entry(1,comb:list-items).
            disp comb with frame {&frame-name}.
            enable comb  Btn_OK Btn_Cancel {&Btn_Help} with frame {&frame-name}.
            assign
               in-char     :visible = no
               in-date     :visible = no
               toggle-date :visible = no
               in-dec      :visible = no
               in-int      :visible = no
               in-log      :visible = no
            .
         end.
         else do:
            frame {&frame-name}:title = "Введите символьное значение".
            disp in-char with frame {&frame-name}.
            enable in-char  Btn_OK Btn_Cancel {&Btn_Help} with frame {&frame-name}.
            assign
               comb        :visible = no
               in-date     :visible = no
               toggle-date :visible = no
               in-dec      :visible = no
               in-int      :visible = no
               in-log      :visible = no
            .
         end.
      end.
      when "date" then do:
         frame {&frame-name}:title = "Введите дату".
         run cur-time in this-procedure (output in-date, output v-time).
         disp in-date toggle-date with frame {&frame-name}.
         enable in-date toggle-date Btn_OK Btn_Cancel {&Btn_Help} with frame {&frame-name}.
         assign
            comb        :visible = no
            in-char     :visible = no
            in-dec      :visible = no
            in-int      :visible = no
            in-log      :visible = no
         .
      end.
      when "decimal" then do:
         frame {&frame-name}:title = "Введите десятичное значение".
         disp in-dec with frame {&frame-name}.
         enable in-dec  Btn_OK Btn_Cancel {&Btn_Help} with frame {&frame-name}.
         assign
            comb        :visible = no
            in-date     :visible = no
            toggle-date :visible = no
            in-char     :visible = no
            in-int      :visible = no
            in-log      :visible = no
         .
      end.
      when "integer" then do:
       mCashDevice      = new ibs.th.str.cash.CashDevice().
       do v-ii = 1 to mCashDevice:mapType:GetItem(v-ii):
           objType = mCashDevice:CurrProp.
           v-device-kind = v-device-kind + {&comma-char} + objType:Label_ .
           v-device-integer = v-device-integer + {&comma-char} + string(objType:KeyIntDB) .
       end.          
         if    can-do( "course-type,purch-code,hist-action,receipt-code,wth-receipt-code,cd-device-kind", spr ) 
            or vlistValue ne ?
         then do:
            frame {&frame-name}:title = "Выберите значение".
            if vlistValue eq ?
            then 
               case spr :
                  when "course-type" then assign vlistValue = "ЦБ,ММВБ" vlistValueRet = "1,2".
                  when "purch-code"  then assign vlistValue = {&purchase-codes-full}
                                                 vlistValueRet = {&purchase-codes}
                                     .
                  when "hist-action"  then
                     assign
                        vlistValue    = {&hn-actions-full}
                        vlistValueRet = {&hn-actions}
                     .
                  when "receipt-code" then assign vlistValue    = {&receipt-codes-full}
                                                  vlistValueRet = {&receipt-codes}
                                           .
                  when "wth-receipt-code" then assign vlistValue    = {&wth-receipt-codes-full}
                                                      vlistValueRet = {&wth-receipt-codes}
                                               .
                  when "cd-device-kind" then do:
                      assign
                      vlistValue = trim(v-device-kind,",")
                      vlistValueRet = trim(v-device-integer,",")
                      .
                  end.                                               
               end case.
            comb:list-items   = vlistValue.
            if num-entries(vlistValue) > 2
            then
               comb:inner-lines = num-entries(vlistValue).
            assign comb = entry( 1, comb:list-items ).
            disp comb with frame {&frame-name}.
            enable comb  Btn_OK Btn_Cancel {&Btn_Help} with frame {&frame-name}.
            assign
               in-char:visible = no
               in-date:visible = no
               toggle-date:visible = no
               in-dec:visible  = no
               in-int:visible    = no
               in-log:visible   = no.
         end.
         else do:
            frame {&frame-name}:title = "Введите целое значение".
            disp in-int with frame {&frame-name}.
            enable in-int  Btn_OK Btn_Cancel {&Btn_Help} with frame {&frame-name}.
            assign
               comb        :visible = no
               in-date     :visible = no
               toggle-date :visible = no
               in-dec      :visible = no
               in-char     :visible = no
               in-log      :visible = no
            .
         end.
      end.
      when "logical" then do:
         frame {&frame-name}:title = "Выберите логическое значение".
         disp in-log with frame {&frame-name}.
         enable in-log  Btn_OK Btn_Cancel {&Btn_Help} with frame {&frame-name}.
         assign
            comb        :visible = no
            in-date     :visible = no
            toggle-date :visible = no
            in-dec      :visible = no
            in-int      :visible = no
            in-char     :visible = no
         .
      end.
   end case.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME