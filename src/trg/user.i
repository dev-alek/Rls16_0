/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

создание записи _user при создании логина user-login

Автор: Белоусов Илья Александрович
Дата создания:
Author: Ilia Belousov
Creation date:

*/
&if defined (deftempUser) eq 0
&then
DEFINE TEMP-TABLE tempUser NO-UNDO LIKE 
&if "{1}" ne "def"
&then {1}._User
&else {2}._User
&endif
.
&glob deftempUser = yes
&endif

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&if "{1}" ne "def"
&then
    if {1}.user-login.status_ = {&bef-user-status-normal}
    then do:
      find first {1}.user-account
           where {1}.user-account.user-id = {1}.user-login.user-id
           no-lock
           no-error .
      if not available {1}.user-account
      then do:
        create {1}.user-account.
        assign
            {1}.user-account.user-id               = {1}.user-login.user-id
            {1}.user-account.status_               = 0
            {1}.user-account.first-name            = '':U
            {1}.user-account.second-name           = '':U
            {1}.user-account.last-name             = {1}.user-login.user-login
            {1}.user-account.nik                   = {1}.user-login.user-login
            {1}.user-account.company               = '':U
            {1}.user-account.department            = '':U
            {1}.user-account.e-mail                = '':U
            {1}.user-account.internal-phone-number = '':U
            {1}.user-account.mobile-phone-number   = '':U
            {1}.user-account.phone-number          = '':U
            {1}.user-account.position              = '':U
            {1}.user-account.PS                    = '':U
            {1}.user-account.room                  = '':U
            {1}.user-account.parent-user-id        = '':U
            {1}.user-account.check-parent          = false
        .
      end.
      else
         {1}.user-login.status_ = {1}.user-account.status_.
   end.
   if {1}.user-login.status_ = {&bef-user-status-normal}
   then do:
    

      find first {1}._user
           where {1}._user._userid    = {1}.user-login.user-login
           no-error
           .
      if not available {1}._user then do:
         create {1}._user .
         assign
            {1}._user._userid    = {1}.user-login.user-login
            {1}._user._password  = {1}.user-login.user-password-encoded
         .
      end.
      ELSE DO:
         
         BUFFER-COPY {1}._User EXCEPT {1}._User._Password {1}._User._TenantId TO tempUser ASSIGN tempUser._Password = {1}.user-login.user-password-encoded
         .
         DELETE {1}._User.
         CREATE {1}._User.
         BUFFER-COPY tempUser EXCEPT tempUser._TenantId TO _User.
      END.
      assign
        {1}._user._user-name = substitute('&1 &2 &3'
                                        ,{1}.user-account.last-name
                                        ,{1}.user-account.first-name
                                        ,{1}.user-account.second-name
                                        )
      .
      release _user.
    end.
&endif
/* $Workfile$ e n d */