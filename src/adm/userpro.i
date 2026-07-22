define temp-table UserDbAdm
field db-num as integer 
field db-adm as logical
field db-usr as logical
field db-block as logical
index pi is unique db-num 
index adm db-adm db-usr
.
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ gbl/sys-time.i }
function get-user-login returns character
  ( p-user-id as character ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

  define variable v-user-login as character no-undo .

  run procedure-get-user-login in this-procedure (
      input p-user-id
    , output v-user-login
  ) .
  return v-user-login .

end function.

procedure procedure-get-user-login :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input  parameter p-user-id    as character no-undo .
define output parameter p-user-login as character no-undo .

    define buffer buf_user-login for ub.user-login .
do
for buf_user-login
on error undo, return error return-value
:
    assign
        p-user-login = "":U
    .

    for each buf_user-login no-lock
       where buf_user-login.user-id = p-user-id
    by buf_user-login.db-num
    :
        assign
            p-user-login = substitute( "&1&2&3"
                                , p-user-login
                                , ( if p-user-login = "":U then "":U else ",":U )
                                , buf_user-login.db-num )
        .
    end.
end.
end procedure.

&if defined(CheckWorkUser) ne 0
&then
         
function get-work-status returns character
  ( p-user-id as character ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
    define variable v-work-status as character no-undo .

    run procedure-get-work-status in this-procedure (
        input p-user-id
      , output v-work-status
    ) .

    return v-work-status .

end function.

procedure procedure-get-work-status :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input  parameter p-user-id     as character no-undo .
define output parameter p-work-status as character no-undo .

    define buffer buf_user-login for ub.user-login .
do
for buf_user-login
on error undo, return error return-value
:
    if p-user-id = v-cntxt-userid
    then do:
        assign
            p-work-status = "*":U
        .
    end.
    else do:
        find first buf_user-login exclusive-lock
             where buf_user-login.db-num    = v-cntxt-db-num
               and buf_user-login.user-id   = p-user-id
        no-error no-wait .
        if not available buf_user-login
        then do:
            if locked buf_user-login
            then do:
            assign
                p-work-status = "+":U
            .
            end.
            else do:
            assign
                p-work-status = "":U
            .
            end.
        end.
        else do:
            assign
                p-work-status = "":U
            .
        end.
    end.
end.
end procedure.
&endif
procedure SetAttrUserId:
   define input  parameter iDb-num      as integer   no-undo.
   define input  parameter iUserId      as character no-undo.
   define input  parameter iAttrCode    as character no-undo.
   define input  parameter iAttrValue   as character no-undo.
   
   define buffer user-login-attr  for ub.user-login-attr .
   
   find first user-login-attr where user-login-attr.db-num    eq idb-num
                                and user-login-attr.user-id   eq iuserid
                                and user-login-attr.attr-code eq iAttrCode
   exclusive-lock no-error.
   if     not available user-login-attr
      and iAttrValue ne ?
   then do:
      create user-login-attr.
      assign
         user-login-attr.db-num     = idb-num
         user-login-attr.user-id    = iuserid
         user-login-attr.attr-code  = iAttrCode
         
      .
   end.
   if iAttrValue eq ?
   then do:
      if available ub.user-login-attr 
      then 
         delete ub.user-login-attr.
   end.
   else
      user-login-attr.attr-value = iAttrValue.
end procedure.

function GetAttrUserId returns character (
   input iDb-num      as integer  ,
   input iUserId      as character,
   input iAttrCode    as character):
   
   define buffer user-login-attr  for ub.user-login-attr .
   
   find first user-login-attr where user-login-attr.db-num    eq idb-num
                                and user-login-attr.user-id   eq iuserid
                                and user-login-attr.attr-code eq iAttrCode
   no-lock no-error.
   return if not available ub.user-login-attr then ? else ub.user-login-attr.attr-value.
      
end function.

procedure getAccountSetting :
   define input  parameter i-user-id  as character no-undo.
   define output parameter o-adm-Ubd  as logical no-undo init ?.
   define output parameter v-adm-GBD  as logical no-undo. 
   define output parameter o-superAdm as logical no-undo.
   define input-output parameter table for UserDbAdm .
   
   define variable v-adm-Ubd-int as integer no-undo.
   
   define buffer user-login for ub.user-login.
   define buffer db         for ub.db.
   define buffer user-account-attr for ub.user-account-attr.
   /*Поиск пользователя на ГБД*/
   find first user-login where user-login.db-num  eq 0
                           and user-login.user-id eq i-user-id
/*                                and user-login.user-administrator*/
   no-lock no-error.
   if available user-login
   then
      v-adm-gbd = user-login.user-administrator.
   else 
      v-adm-gbd = ?.
   for each userDbAdm:
      delete userDbAdm.
   end.
   block-db:
   for each db where db.db-num ne 0 no-lock:
      if G#db-num ne 0
         and G#db-num ne db.db-num
      then
         next block-db.
      create UserDbAdm.
      UserDbAdm.db-num = ub.db.db-num.
      find first user-login where user-login.db-num  eq db.db-num
                              and user-login.user-id eq i-user-id
      no-lock no-error.
      if not available user-login
      then
         v-adm-Ubd-int = 2.
      else if user-login.status_ eq {&bef-user-status-deleted}
      then do:
         v-adm-Ubd-int = 2.
          UserDbAdm.db-block = yes.
          UserDbAdm.db-usr   = yes.
      end.
      else if user-login.user-administrator
      then do:
         UserDbAdm.db-adm = yes.
         UserDbAdm.db-usr = yes.
         if v-adm-Ubd-int eq 0
         then
            v-adm-Ubd-int = 1.
         else if v-adm-Ubd-int eq 3
         then do:
            v-adm-Ubd-int = 2.
/*            leave block-db.*/
         end.
      end.
      else do:
         if available ub.user-login
         then
            UserDbAdm.db-usr = yes.
         if v-adm-Ubd-int eq 0
         then
            v-adm-Ubd-int = 3.
         else if v-adm-Ubd-int eq 1
         then do:
            v-adm-Ubd-int = 2.
/*            leave block-db.*/
         end.
      end.
   end.
   if  v-adm-Ubd-int eq 1
   then
      o-adm-Ubd = true.
   else if v-adm-Ubd-int eq 3
   then
      o-adm-Ubd = false.  
   
/*   o-adm-Ubd = if v-adm-Ubd-int eq 1     */
/*               then yes                  */
/*               else if v-adm-Ubd-int eq 3*/
/*               then no                   */
/*               else ?.                   */
 
   find first user-account-attr where user-account-attr.user-id  eq i-user-id
                                  and user-account-attr.attr-code  eq "superADm"
   no-lock no-error.
 
   o-superAdm =  available user-account-attr and logical (user-account-attr.attr-value ) no-error.
end.

function check_alphanumeric returns character (
input ipwd as character ,
input itype as character ):
   define variable vCharEng as character no-undo 
   init "abcdefghijklmnopqrstuvwxyz".
      
   define variable vCharRus as character no-undo
   init "йцукенгшщзхъфывапролджэячсмитьбюёЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЯЧСМИТЬБЮЁЭ".
   define variable vi as integer no-undo.
   define variable vdigitFl as logical no-undo.
   define variable vCharEngFl as logical no-undo.
   define variable vCharRusFl as logical no-undo.
   define variable vCharSpeFl as logical no-undo.
  
   define variable vTextNew as character no-undo.
   define variable vTextOld as character no-undo.
   vTextNew = ipwd.
   vTextOld = vTextNew.
   do vi = 0 to 9:
      vTextNew = replace(vTextNew,string (vi),"").
   end.
   if length(vTextOld) ne length(vTextNew)
   then
      vdigitFL = yes.
     
   vTextOld = vTextNew.
   do vi = 1 to length(vCharEng):
      vTextNew = replace(vtextNew,substring(vCharEng,vi,1),"").
   end.
   if length(vTextOld) ne length(vTextNew)
   then
      vCharEngFl = yes.
  
   vTextOld = vTextNew.
   do vi = 1 to length(vCharRus):
      vTextNew = replace(vtextNew,substring(vCharRus,vi,1),"").
   end.
   if length(vTextOld) ne length(vTextNew)
   then
      vCharEngFl = yes.
     
   if length(vTextNew) > 0
   then
      vCharSpeFl = yes.
   define variable vReturn as character no-undo.
   assign
      vReturn = vReturn + ", " + "не содержит цифр"           when lookup ("digit",   itype) > 0 and not vdigitFl
      vReturn = vReturn + ", " + "не содержит латинских букв" when lookup ("CharEng", itype) > 0 and not vCharEngFl
      vReturn = vReturn + ", " + "не содержит русских букв"   when lookup ("CharRus", itype) > 0 and not vCharRusFl
      vReturn = vReturn + ", " + "не содержит спец символов"  when lookup ("CharSpe", itype) > 0 and not vCharSpeFl
      vReturn = vReturn + ", " + "не содержит символов"       when lookup ("Char",    itype) > 0 and not (vCharEngFl or vCharRusFl or vCharSpeFl)
   .
   vReturn = substring (vReturn,3) no-error.
   return vReturn.
  
end.
&Glob maxSavePWD 50
procedure SaveLastPWD:
   define input  parameter iDb-num as integer   no-undo.
   define input  parameter iUserId as character no-undo.
   define input  parameter IPWD    as character no-undo.
   
   define buffer user-login-attr  for ub.user-login-attr .
   
   find first user-login-attr where user-login-attr.db-num    eq idb-num
                                and user-login-attr.user-id   eq iuserid
                                and user-login-attr.attr-code eq "LastPWD"
   exclusive-lock no-error.
   if not available user-login-attr
   then do:
      create user-login-attr.
      assign
         user-login-attr.db-num     = idb-num
         user-login-attr.user-id    = iuserid
         user-login-attr.attr-code  = "LastPWD"
         user-login-attr.attr-value = ipwd
      .
   end.
   else do:
      user-login-attr.attr-value = user-login.user-password-encoded + {&delim-urt} + user-login-attr.attr-value .
      if num-entries (user-login-attr.attr-value , {&delim-urt}) > {&maxSavePWD}
      then
         user-login-attr.attr-value = substring (user-login-attr.attr-value,1,r-index(user-login-attr.attr-value, {&delim-urt}) - 1).
   end.
end procedure.

function  CheckLastPWD returns character  (
   input  iDb-num    as integer  ,
   input  iUserId    as character,
   input  IPWD       as character,
   input  Iadm       as logical ) :
   
   define buffer user-login       for ub.user-login .
   define buffer user-login-attr  for ub.user-login-attr .
   
   define variable vError as character  no-undo.
   
   define variable v-obyznumbukv as logical no-undo .
   define variable v-minparol as integer no-undo .
   define variable v-tth as handle no-undo .
   define variable VadmSuff as character no-undo.
    
   define variable v-param-type as character no-undo .
   define variable v-value-character as character no-undo .
   define variable v-value-date as date no-undo .
   define variable v-value-decimal as decimal no-undo .
   define variable v-value-integer as integer no-undo .
   define variable v-value-logical as logical no-undo .
    
   find first user-login where user-login.db-num    eq idb-num
                           and user-login.user-id   eq iUserId
   no-lock no-error.
   if Iadm
   then
      VadmSuff = {&staff-options_Adm}.
   
   
   run adm/shattri.p (
        input "get":U
        ,input  '':U
        ,input  0
        ,input  {&attr-staff-options}
        ,input  {&attr-staff-options_minparol} + VadmSuff /*p-param-code*/
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-minparol
        ,output v-value-logical
        ,output v-param-type
        ,input-output table-handle v-tth
        )  .
   
    
    if v-minparol <> 0 /* вместо false будет Проверка длины включена и задана */ then do:
       if length(ipwd) < v-minparol /* тут будет переменная из thbjattr */
        then do:
           vError = substitute ("Длина поля должна быть не менее &1" , v-minparol).
            
        end.
    end.
   
    run adm/shattri.p (
        input "get":U
        ,input  '':U
        ,input  0
        ,input  {&attr-staff-options}
        ,input  {&attr-staff-options_obyznumbukv} + VadmSuff /*p-param-code*/
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-obyznumbukv
        ,output v-param-type 
        ,input-output table-handle v-tth
        )  .
    
   if v-obyznumbukv = true /* вместо false будет Проверка численнобуквенная включена */ 
   then do:
      if check_alphanumeric(ipwd,"Digit,Char") ne "" /* тут будет переменная из thbjattr */
      then do:
         vError = vError + (if vError eq "" then "" else ", " ) 
                + "В пароле должны содержаться буквы и цифры".
      end.
   end.
   define variable v-encode-value as character no-undo.
   define variable v-Lastpaswd    as integer no-undo.
   run adm/pswd-enc.p
      (input  encode(ipwd)
      ,output v-encode-value
      ).
   v-encode-value = encode(v-encode-value).
   run adm/shattri.p (
        input "get":U
        ,input  '':U
        ,input  0
        ,input  {&attr-staff-options}
        ,input  {&attr-staff-options_LastPaswd} + VadmSuff /*p-param-code*/
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-Lastpaswd
        ,output v-value-logical
        ,output v-param-type 
        ,input-output table-handle v-tth
        )  .
   if v-Lastpaswd ne 0
   then do:
      define variable vLastPwd as character no-undo. 
      vLastPwd = GetAttrUserId(iDb-num, iUserId, "LastPWD").
      if vLastPwd ne ?
      then do:
         define variable Vi as integer no-undo.
         vi = lookup (v-encode-value,vLastPwd,{&delim-urt}).
         if     vi ne 0
            and vi le v-Lastpaswd
         then
            vError = vError + (if vError eq "" then "" else ", " ) 
                   + substitute ("пароль не должен совпадать с последими &1 паролями",v-Lastpaswd).
      end.
   end.
   delete object v-tth.
   return vError.
end function.

procedure availOneAdm:
   define input-output parameter table for UserDbAdm.
   define output parameter oAdm as logical no-undo.
   find first UserDbAdm where UserDbAdm.db-adm no-lock no-error.
   oadm = available UserDbAdm.
end.

procedure update-user-login:
   define input  parameter i-db-num     as integer          no-undo.
   define input  parameter i-user-id    as character        no-undo.
   define input  parameter i-user-login as character no-undo.
   define input  parameter i-max-discnt as decimal no-undo.
   define input  parameter i-quest-print as logical no-undo.
   define input  parameter i-encoded-pass as character no-undo.
   define input  parameter i-nextcon as logical no-undo.
   define input  parameter i-user-administrator as logical no-undo.
   define input  parameter i-Manual     as logical no-undo.
   define input  parameter i-adm-gbd as logical no-undo.
   define input  parameter i-adm-ubd as logical no-undo.
   define input-output parameter table for UserDbAdm.
   
   define buffer buf_user-login        for user-login.
    
   do
for buf_user-login
/*  , buf_user-account*/
on error undo, return error
:
        if     i-Manual 
           and G#db-num eq 0
          /* and (   i-adm-gbd ne ?
                or i-adm-ubd ne ?
                or can-find(first UserDbAdm)
               )*/
        then do:
           if     i-adm-gbd ne ?
           then do:
              do transaction
              on error undo, return error return-value
              :
                  find first buf_user-login where buf_user-login.db-num             eq 0
                                              and buf_user-login.user-login         eq i-user-login
                                              and buf_user-login.status_            eq {&bef-user-status-normal}
                                              and buf_user-login.user-id            ne i-user-id
                  no-lock no-error.
                  if available buf_user-login
                  then
                     undo, return error "Уже есть такой логин в ГБД".
                  
                  find first buf_user-login where buf_user-login.db-num             = 0
                                              and buf_user-login.user-id            = i-user-id
                  exclusive-lock no-error.
                  if not available buf_user-login
                  then do:
                     create buf_user-login .
                     assign
                         buf_user-login.db-num             = 0
                         buf_user-login.user-id            = i-user-id
                         buf_user-login.status_            = {&bef-user-status-normal}
                     .
                  end.
                  assign
                      buf_user-login.user-login         = i-user-login
                      buf_user-login.user-administrator = i-adm-gbd
                      buf_user-login.max-discnt         = i-max-discnt
                      buf_user-login.quest-print        = i-quest-print
                      buf_user-login.user-password-encoded = i-encoded-pass
                  .
                  if i-nextcon ne ?
                  then do:
                     run SetAttrUserId(buf_user-login.db-num, buf_user-login.user-id, "ChangPwdNextConect", string(i-nextcon )).
                  end.
                  run addobj(buf_user-login.db-num,buf_user-login.user-id) no-error.
                  if error-status:error
                  then
                     return error return-value.
              end. 
           end.
           else do transaction on error undo, return error return-value:
               find first buf_user-login where buf_user-login.db-num             = 0
                                           and buf_user-login.user-id            = i-user-id
               exclusive-lock no-error.
               if available buf_user-login
               then
                  delete buf_user-login.
               
           end.
           if     i-adm-ubd ne ?
           then do:
              do transaction
              on error undo, return error return-value
              :
                  define variable vDbError as character no-undo.
                  block-db:
                  for each db where db.db-num ne 0 
/*                                and db.db-num ne i-db-num*/
                  no-lock:
                     find first buf_user-login where buf_user-login.db-num             eq db.db-num
                                                 and buf_user-login.user-login         eq i-user-login
                                                 and buf_user-login.status_            eq {&bef-user-status-normal}
                                                 and buf_user-login.user-id            ne i-user-id
                     no-lock no-error.
                     if available buf_user-login
                     then do:
                        vDbError = vDbError + "," + String(db.db-num) no-error.
                        next block-db. 
                     end.
                     find first buf_user-login where buf_user-login.db-num             = db.db-num
                                                 and buf_user-login.user-id            = i-user-id
                     exclusive-lock no-error.
                     if not available buf_user-login
                     then do:
                        create buf_user-login .
                        assign
                            buf_user-login.db-num             = db.db-num
                            buf_user-login.user-id            = i-user-id
                            buf_user-login.status_            = {&bef-user-status-normal}
                            buf_user-login.user-password-encoded = i-encoded-pass
                        .
                     end.
                     assign
                         buf_user-login.status_            = {&bef-user-status-normal} when i-db-num ne G#db-num
                         buf_user-login.user-login         = i-user-login
                         buf_user-login.user-administrator = i-adm-ubd
                         buf_user-login.max-discnt         = i-max-discnt
                         buf_user-login.quest-print        = i-quest-print
                     .
                     if i-nextcon ne ?
                     then do:
                        run SetAttrUserId(buf_user-login.db-num, buf_user-login.user-id, "ChangPwdNextConect", string(i-nextcon )).
                     end.
                     run addobj(buf_user-login.db-num,buf_user-login.user-id)no-error.
                     if error-status:error
                     then
                        return error return-value.
                 end.
                 if vDbError ne ""
                 then
                    undo, return error substitute ("Уже есть такой логин в УБД &1",substring (vDbError,2,4000)).
              end. 
           end.
           else do:
              do transaction
              on error undo, return error return-value
              :
                  block-UserDb:
                  for each UserDbAdm where UserDbAdm.db-num ne 0 
/*                                       and UserDbAdm.db-num ne i-db-num*/
                  no-lock:
                     find first buf_user-login where buf_user-login.db-num             eq UserDbAdm.db-num
                                                 and buf_user-login.user-login         eq i-user-login
                                                 and buf_user-login.status_            eq {&bef-user-status-normal}
                                                 and buf_user-login.user-id            ne i-user-id
                     no-lock no-error.
                     if available buf_user-login and UserDbAdm.db-usr
                     then do:
                        vDbError = vDbError + "," + String(db.db-num) no-error.
                        next block-UserDb. 
                     end.
                     
                     find first buf_user-login where buf_user-login.db-num             = UserDbAdm.db-num
                                                 and buf_user-login.user-id            = i-user-id
                     exclusive-lock no-error.
                     if UserDbAdm.db-usr
                     then do:
                        if not available buf_user-login
                        then do:
                           create buf_user-login .
                           assign
                               buf_user-login.db-num             = UserDbAdm.db-num
                               buf_user-login.user-id            = i-user-id
                               buf_user-login.status_            = if UserDbAdm.db-block then {&bef-user-status-deleted} else {&bef-user-status-normal}
                               buf_user-login.user-password-encoded = i-encoded-pass
                           .
                        end.
                        assign
                            buf_user-login.status_            = if UserDbAdm.db-block then {&bef-user-status-deleted} else {&bef-user-status-normal} when i-db-num ne G#db-num or G#db-num = 0
                            buf_user-login.user-login         = i-user-login
                            buf_user-login.user-administrator = UserDbAdm.db-adm
                            buf_user-login.max-discnt         = i-max-discnt
                            buf_user-login.quest-print        = i-quest-print
                        .
                        if i-nextcon ne ?
                        then do:
                           run SetAttrUserId(buf_user-login.db-num, buf_user-login.user-id, "ChangPwdNextConect", string(i-nextcon )).
                        end.
                        if UserDbAdm.db-adm
                        then do:
                           run addobj(buf_user-login.db-num,buf_user-login.user-id)no-error.
                           if error-status:error
                           then
                              undo, return error return-value.
                        end.
                    end.
                    else do:
                       if available buf_user-login
                       then do:
                          define variable vok as logical no-undo.
                          run procedure-user-login-delete-question (UserDbAdm.db-num,i-user-id, no, output vok).
                          if not vok
                          then
                             undo, return error return-value.
                   
                       end.
                           
                    end.
                 end.
                  if vDbError ne ""
                  then
                    undo, return error substitute ("Уже есть такой логин в УБД &1",substring (vDbError,2,4000)).
              end.
           end. 
        end.
        else do transaction
        on error undo, return error return-value
        :
           find first buf_user-login where buf_user-login.db-num             = i-db-num
                                       and buf_user-login.user-id            = i-user-id
           exclusive-lock no-error.
           if not available buf_user-login
           then do:
              create buf_user-login .
              assign
                 buf_user-login.db-num             = i-db-num
                 buf_user-login.user-id            = i-user-id
                 buf_user-login.status_            = {&bef-user-status-normal}
              .
           end.
           assign
                buf_user-login.user-login         = i-user-login
                buf_user-login.user-administrator = i-user-administrator
                buf_user-login.max-discnt         = i-max-discnt
                buf_user-login.quest-print        = i-quest-print
                buf_user-login.user-password-encoded = i-encoded-pass
            .
            if i-user-administrator
            then
               run addobj(buf_user-login.db-num,buf_user-login.user-id).
            if i-nextcon ne ?
            then do:
               run SetAttrUserId(buf_user-login.db-num, buf_user-login.user-id, "ChangPwdNextConect", string(i-nextcon )).
            end.
        end.
    end.
end procedure. /* update-user-login */

procedure addobj:
   define input  parameter i-db-num as integer no-undo.
   define input  parameter i-user-id as character no-undo.
   define buffer buf_user-obj     for ub.user-obj.
   define buffer buf_clients      for ub.clients.
/*   g#db-num = i-db-num.*/
   if i-db-num <> 0 then do:
       for each buf_clients
           where buf_clients.db-num = i-db-num
           and ( buf_clients.obj-type = {&shop}
              or buf_clients.obj-type = {&stock}
               )
           no-lock:
          if can-find (buf_user-obj where buf_user-obj.obj-type = buf_clients.obj-type
                                  and buf_user-obj.obj-code     = buf_clients.obj-code
                                  and buf_user-obj.user-id      = i-user-id
                                  and buf_user-obj.db-num       = i-db-num
                                no-lock)
                                then next.

          run enbl-obj (i-db-num, i-user-id, buf_clients.obj-type, buf_clients.obj-code).
       end.
    end.
    else do:
       for each buf_clients
           where
               ( buf_clients.obj-type = {&shop}
              or buf_clients.obj-type = {&stock}
               )
           no-lock:
          if can-find (buf_user-obj where buf_user-obj.obj-type = buf_clients.obj-type
                                  and buf_user-obj.obj-code     = buf_clients.obj-code
                                  and buf_user-obj.user-id      = i-user-id
                                  and buf_user-obj.db-num       = i-db-num
                                no-lock)
                                then next.

          run enbl-obj (i-db-num, i-user-id, buf_clients.obj-type, buf_clients.obj-code).
       end.
    end.
end.

procedure enbl-obj :
/* -----------------------------------------------------------
  Purpose:     добавление 1 объекта
-------------------------------------------------------------*/
   define input  parameter i-db-num  as integer   no-undo.
   define input  parameter i-user-id as character no-undo.
   define input  parameter i-type    as character no-undo.
   define input  parameter i-code    as integer   no-undo.

    define variable v-host-code    as integer      no-undo.
    define variable v-host-name    as character    no-undo.
    define variable v-base-code    as integer      no-undo.

    define buffer buf_user-obj      for ub.user-obj.
    define buffer buf_user-host     for ub.user-host.
    define buffer buf_clients       for ub.clients.
do
for buf_user-obj
  , buf_user-host
  , buf_clients
on error undo, return error
:
    find first buf_user-obj exclusive-lock
         where buf_user-obj.db-num    = i-db-num
           and buf_user-obj.user-id   = i-user-id
           and buf_user-obj.obj-type  = i-type
           and buf_user-obj.obj-code  = i-code
    no-error.
    if not available buf_user-obj
    then do:
        find first buf_clients no-lock
             where buf_clients.obj-type = i-type
               and buf_clients.obj-code = i-code
        .
        { gbl/hostname.i
            i-type
            i-code
            v-host-code
            v-host-name
        }
         { gbl/basecode.i
            v-host-code
            v-base-code
         }

        create buf_user-obj.
        assign
            buf_user-obj.db-num    = i-db-num
            buf_user-obj.user-id   = i-user-id
            buf_user-obj.obj-type  = i-type
            buf_user-obj.obj-code  = i-code
            buf_user-obj.host-code = v-host-code
        .
/*        create buf_temp-obj-info .
        assign
            buf_temp-obj-info.obj-type        = i-type
            buf_temp-obj-info.obj-code        = i-code
            buf_temp-obj-info.db-num          = i-db-num
            buf_temp-obj-info.brws-obj-name   = buf_clients.obj-name
            buf_temp-obj-info.brws-db-num     = string(buf_clients.db-num, '>>>>9':U)
            buf_temp-obj-info.brws-host-code  = string(buf_clients.host-code, '>>>>>>>>9':U)
            buf_temp-obj-info.brws-host-name  = v-host-name
            buf_temp-obj-info.brws-curr-code  = v-base-code
        .
*/        find first buf_user-host exclusive-lock
             where buf_user-host.db-num    = i-db-num
               and buf_user-host.user-id   = i-user-id
               and buf_user-host.host-code = v-host-code
        no-error.
        if not available buf_user-host
        then do:
            create buf_user-host.
            assign
                buf_user-host.db-num    = i-db-num
                buf_user-host.user-id   = i-user-id
                buf_user-host.host-code = v-host-code
            .
        end.
   end.     /* not available buf_user-obj */
end.
end procedure.

&if defined(CheckWorkUser) ne 0
&then
procedure can-edit-login :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input  parameter p-db-num   as integer   no-undo .
  define output parameter p-can-edit as logical   no-undo .

  define buffer buf_db for ub.db .

  do
  on error undo, return error return-value
  :
    find first buf_db no-lock
         where buf_db.db-num = p-db-num
    no-error.
    if not available buf_db
    then do:
      message
        vss-workfile vss-revision vss-description
        skip "Внутренняя ошибка"
        skip "Неизвестный номер БД" p-db-num
        skip view-as alert-box error .
      undo, return error return-value .
    end.

    assign
      p-can-edit = ( p-db-num = v-cntxt-db-num
                    or
                    buf_db.db-key = '':U
                    or v-cntxt-db-num = 0
                   )
    .
  end.
end procedure. /* can-edit-login */
&endif

procedure procedure-user-login-change-password :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
   define input  parameter p-db-num         as integer          no-undo.
   define input  parameter p-user-id        as character        no-undo.
   define input  parameter iChange          as logical          no-undo.

   define variable v-can-edit         as logical   no-undo .
   define variable v-encoded-pass     as character no-undo .
   define variable v-encoded-pass-old as character no-undo .
   define variable v-nextcon          as logical   no-undo .
   define variable VadmSuff           as character no-undo.
   define variable vChange as logical no-undo.
   
   define variable v-param-type as character no-undo .
   define variable v-value-character as character no-undo .
   define variable v-value-date as date no-undo .
   define variable v-value-decimal as decimal no-undo .
   define variable v-value-integer as integer no-undo .
   define variable v-value-logical as logical no-undo .
   define variable v-tth           as handle  no-undo .
   
   define buffer buf_lock_user-login for user-login.
   define buffer buf_init_user-account for user-account.
   
   do:   
      find first buf_lock_user-login no-lock
              where buf_lock_user-login.db-num  = p-db-num      /* НЕ current, а только текущая !!! */
                and buf_lock_user-login.user-id = p-user-id
      no-error.
      if not available buf_lock_user-login then do:
         message
            "Нельзя редактировать пароль пока не заведен логин для пользователя" skip
            view-as alert-box error .
            undo, return error "Нельзя редактировать пароль пока не заведен логин для пользователя" .
      end.
      vChange = buf_lock_user-login.user-login eq userid ("ub") or iChange.
     
      &if defined(CheckWorkUser) ne 0
      &then
      if vChange
      then do trans:
         
         run can-edit-login in this-procedure
              (input  p-db-num
              ,output v-can-edit
              ) .
            if v-can-edit <> true
            then do:
              message
                "Нельзя редактировать логин пользователя для базы" p-db-num skip
                view-as alert-box error .
              undo, return error return-value .
            end.
         if get-work-status( p-user-id ) = '+':u
         then do:
            message
                "Нельзя редактировать пароль работающего пользователя" skip
               view-as alert-box error .
                 undo, return error "Нельзя редактировать пароль работающего пользователя" .
         end.
      end.
      &endif
      
      if     available buf_lock_user-login
         and buf_lock_user-login.user-administrator 
      then
         VadmSuff = {&staff-options_Adm}.
      
      define variable v-TimeAvail as integer no-undo.
      define variable v-DateChg   as date    no-undo.
      define variable v-Time      as integer no-undo.
      
      run cur-time-mjd-to-date (buf_lock_user-login.user-password-set-mjd, output v-DateChg, output v-Time).
      
      run adm/shattri.p (
           input "get":U
           ,input  '':U
           ,input  0
           ,input  {&attr-staff-options}
           ,input  {&attr-staff-options_TimeBlock} + VadmSuff /*p-param-code*/
           ,output v-value-character
           ,output v-value-date
           ,output v-value-decimal
           ,output v-TimeAvail
           ,output v-value-logical
           ,output v-param-type
           ,input-output table-handle v-tth
           )  .
      
      if     not iChange 
         and v-TimeAvail ne 0 
         and v-DateChg + v-TimeAvail < today
      then do: 
         do trans:
            find current buf_lock_user-login exclusive-lock.
            buf_lock_user-login.status_ = {&uls-disabled}.
         end.
         return error "Ваша учетная запись заблокирована." .
      end.
      
      run adm/shattri.p (
           input "get":U
           ,input  '':U
           ,input  0
           ,input  {&attr-staff-options}
           ,input  {&attr-staff-options_TimeAvail} + VadmSuff /*p-param-code*/
           ,output v-value-character
           ,output v-value-date
           ,output v-value-decimal
           ,output v-TimeAvail
           ,output v-value-logical
           ,output v-param-type
           ,input-output table-handle v-tth
           )  .
      delete object v-tth.
      define variable vfl as logical no-undo.
      vfl = logical(GetAttrUserId(buf_lock_user-login.db-num, buf_lock_user-login.user-id, "ChangPwdNextConect")) no-error. 
      if    vfl eq yes
         or (     v-TimeAvail ne 0
              and v-DateChg + v-TimeAvail < today)
         or iChange
      then do: 
          find first buf_init_user-account where buf_init_user-account.user-id = buf_lock_user-login.user-id
          no-lock.
          assign
          v-encoded-pass-old = buf_lock_user-login.user-password-encoded
          v-encoded-pass     = buf_lock_user-login.user-password-encoded.
          
          
             
          do while v-encoded-pass = v-encoded-pass-old or v-encoded-pass eq ?:
             v-encoded-pass = v-encoded-pass-old. 
          
             
             run adm/chg-pswd.w ( input  this-procedure
                                , input  p-db-num
                                , input  buf_lock_user-login.user-id
                                , input  buf_lock_user-login.user-login
                                , input  substitute('&1 &2 &3':U, buf_init_user-account.last-name
                                                                , buf_init_user-account.first-name
                                                                , buf_init_user-account.second-name
                                       )
                                , input  iChange
                                , input  yes
                                , input  buf_lock_user-login.user-password-encoded
                                , input  yes
                                , input  buf_lock_user-login.user-administrator
                                , output v-encoded-pass
                                , output v-nextcon
                                ) no-error .
            if error-status :error
            then do:
              message
                 vss-workfile vss-revision vss-description skip
                 "Ошибка при вызове процедуры" 'adm/chg-pswd.w':U skip
                 error-status :get-message(1) skip
                 return-value skip
                 view-as alert-box error .
                 /*current-window:hidden = vHidn.*/
              undo, return error return-value .
             end.                 
             if    v-encoded-pass = v-encoded-pass-old
                
             then do:
                 message
                    vss-workfile vss-revision vss-description skip
                    "Старый пароль и новый равны. Смените пароль.":U skip
                    error-status :get-message(1) skip
                    return-value skip
                    view-as alert-box error .
                 
             end.
             else if v-encoded-pass eq ?
             then do:
                message  "Отказ от смены пароля. Работа дальше не возможна"
                view-as alert-box error. 
                return error "Отказ от смены пароля. Работа дальше не возможна".
             end.   
          end.  
                         
          
          if v-encoded-pass <> ? then
          do trans:
            /* run gbl/set-gbl.p (no,buf_lock_user-login.user-login,buf_lock_user-login.user-password-encoded).*/
             find current buf_lock_user-login
                   exclusive-lock
                .
             assign
                buf_lock_user-login.user-password-encoded = v-encoded-pass
             .
             run SetAttrUserId(buf_lock_user-login.db-num, buf_lock_user-login.user-id, "ChangPwdNextConect", if vChange then v-nextcon else ?).
             run SetAttrUserId(buf_lock_user-login.db-num, buf_lock_user-login.user-id, "ChangPwdUserId", string(g#userid)).
             release buf_lock_user-login .
             message
                "Пароль успешно изменен"
                view-as alert-box information
             .
             
          end.
       end.  
   end.   
   /*current-window:hidden = vHidn.*/

end procedure. /* procedure-user-login-change-password */

procedure procedure-user-login-delete :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
   define input  parameter i-db-num     as integer          no-undo.
   define input  parameter i-user-id    as character        no-undo.
   define output parameter o-deleted   as logical          no-undo.
   run procedure-user-login-delete-question (i-db-num,i-user-id,yes,output o-deleted).
end.
procedure procedure-user-login-delete-question :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input  parameter i-db-num     as integer          no-undo.
define input  parameter i-user-id    as character        no-undo.
define input  parameter i-question as logical no-undo.
define output parameter o-deleted   as logical          no-undo.

  define variable v-can-edit as logical   no-undo .

    define buffer buf_user-login         for user-login .
    define buffer buf_user-account       for user-account.
    define buffer buf_init_user-account  for user-account.

do
for buf_user-login
  , buf_user-account
on error undo, return error return-value
:
    assign
        o-deleted = no
    .
    find first buf_init_user-account no-lock
         where buf_init_user-account.user-id = i-user-id 
        .
    if available buf_init_user-account
    then do:
      do transaction
      on error undo, return error return-value
      :
        run can-edit-login in this-procedure (
              input  i-db-num
            , output v-can-edit
        ).
        if v-can-edit <> true
        then do:
          message
            "Нельзя удалять логин пользователя для базы" i-db-num
          view-as alert-box error .
          undo, return error return-value .
        end.
        find first buf_user-login exclusive-lock
             where buf_user-login.db-num  = i-db-num
               and buf_user-login.user-id = i-user-id
        no-error no-wait.
        if not available buf_user-login
        then do:
          if locked( buf_user-login )
          then do:
            find first buf_user-login no-lock
                 where buf_user-login.db-num  = i-db-num
                   and buf_user-login.user-id = i-user-id
            .
            message
              "Удаление логина невозможно" skip
              "Пользователь в данный момент работает в системе" skip
              "БД" i-db-num skip
              "Идентификатор" i-user-id skip
              "Псевдоним"                    buf_init_user-account.nik skip
              "Имя пользователя"             buf_init_user-account.last-name buf_init_user-account.first-name buf_init_user-account.second-name skip
              "Компьютер"                    buf_user-login.last-login-computer-name skip
              "Пользователь компьютера"      buf_user-login.last-login-computer-user skip
              "TCP имя компьютера"           buf_user-login.last-login-computer-tcp-name skip
              "IP адрес компьютера"          buf_user-login.last-login-computer-ip-addr skip
              "Идентификатор процесса"       buf_user-login.last-login-process-id skip
              "Номер подключения к БД"       buf_user-login.last-login-connection-id skip
              "Дата и время входа в систему" sys-time_mjd-to-loc-str-func( buf_user-login.last-login-mjd ) skip
              view-as alert-box error .
          end.
          else do:
            message
              "У пользователя нет логина" skip
              "БД" i-db-num skip
              "Идентификатор" i-user-id skip
              "Удаление невозможно" skip
              view-as alert-box error .
          end.
          undo, return error return-value .
        end.
        &if defined(CheckWorkUser) ne 0
        &then
      
        if  buf_user-login.user-id = v-cntxt-userid
        and buf_user-login.db-num  = v-cntxt-db-num
        then do:
          message
            "Нельзя удалять текущий логин" skip
            "БД"  buf_user-login.db-num skip
            "Идентификатор" buf_user-login.user-id skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        &endif
        define variable v-ok as logical   no-undo .
        if not i-question
        then
           v-ok = yes.
        else do:
           find first buf_user-account no-lock
                where buf_user-account.user-id = buf_user-login.user-id
           .
           message
             "Удаление логина пользователя"
             skip "Идентификатор" buf_user-account.user-id
             skip "Псевдоним"    buf_user-account.nik
             skip "Пользователь" buf_user-account.last-name buf_user-account.first-name buf_user-account.second-name
             skip "Логин для базы данных" buf_user-login.db-num
             skip "Логин" buf_user-login.user-login
             skip (1)
             "После удаления пользователь не сможет работать в базе данных" buf_user-login.db-num skip
             skip (1)
             "Продолжить?"
           view-as alert-box question
           buttons yes-no
           update v-ok .
        end.
        
        if v-ok = yes
        then do:
            run str/usrlog03.p (
                  input buf_user-login.db-num
                , input buf_user-login.user-id
            ).
            assign
                o-deleted = yes
            .
        end.
      end.
    end.
  end.
end procedure. /* procedure-user-login-delete */


