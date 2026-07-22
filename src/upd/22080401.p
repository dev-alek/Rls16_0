block-level on error undo, throw.
{ cmp/str-glbl.i } 
{ gbl/cur-time.i }
run syper-adm-set.
run password-time-set.
&Scoped-define admin 'адм':U
procedure syper-adm-set:
   define variable vBufUserLogin       as handle no-undo.
   define variable vBufUserAccaunt     as handle no-undo.
   define variable vBufUserAccauntAttr as handle no-undo.
   
   create buffer vBufUserLogin for table "user-login".
   vBufUserLogin:find-first ("where user-login.db-num eq 0 and user-login.user-login = {&admin} and user-login.user-administrator and user-login.status_    = {&uls-normal}" , no-lock) no-error.
   if vBufUserLogin:available
   then do:
      define variable vuser-id as character no-undo.
      vuser-id = vBufUserLogin:buffer-field ("user-id"):buffer-value ().
      create buffer vBufUserAccaunt for table "user-account".
      vBufUserAccaunt:find-first (substitute ("where user-account.user-id = '&1' and user-account.status_ eq {&uls-normal} ",vuser-id) , no-lock)no-error.
      if vBufUserAccaunt:available
      then do transaction: 
         create buffer vBufUserAccauntAttr for table "user-account-attr".
         vBufUserAccauntAttr:find-first (substitute ("where user-account-attr.user-id = '&1' and user-account-attr.attr-code  eq 'superadm'",vuser-id) , exclusive-lock) no-error.
         if not vBufUserAccauntAttr:available 
         then do:
            vBufUserAccauntAttr:buffer-create ().
            vBufUserAccauntAttr:buffer-field ("user-id"  ):buffer-value () = vuser-id.
            vBufUserAccauntAttr:buffer-field ("attr-code"):buffer-value () = "superadm".
         end.
         vBufUserAccauntAttr:buffer-field ("attr-value"  ):buffer-value ()  = "yes".
         vBufUserAccauntAttr:buffer-release ().
         delete object vBufUserAccauntAttr.
      end.
      delete object vBufUserAccaunt.
   end.
   delete object vBufUserLogin.
end.

procedure password-time-set:
   define variable vBufUserLogin   as handle no-undo.
   define variable vBufUserAccaunt as handle no-undo.
   define variable vBufSysCtrl     as handle no-undo.
   define variable vQuery          as handle no-undo.
   
   create buffer vBufSysCtrl for table "sys-ctrl".
   vBufSysCtrl:find-first ("" , no-lock) no-error.
         
   if vBufSysCtrl:available
   then do:
      create buffer vBufUserLogin for table "user-login".
      create query vQuery.
      vQuery:set-buffers(vBufUserLogin).
      vQuery:query-prepare(substitute ("preselect each user-login where user-login.db-num eq &1 and user-login.status_ = {&uls-normal} and (user-login.user-password-set-mjd eq 0 or user-login.user-password-set-mjd eq ?) no-lock",
                                       vBufSysCtrl:buffer-field ("db-num"):buffer-value ()
                                       )
                           ).
      vQuery:query-open().
      vQuery:get-first().
   
      do while vBufUserLogin:available:
         
         do transaction:
            vBufUserLogin:find-current (exclusive-lock).
            vBufUserLogin:buffer-field ("user-password-set-mjd"):buffer-value () = cur-time-mjd().
            vBufUserLogin:buffer-release ().  
         end.
         vQuery:get-next().
      end.
      vQuery:query-close().
      delete object vQuery.
      delete object vBufUserLogin.
   end.
   delete object vBufSysCtrl.
end.
