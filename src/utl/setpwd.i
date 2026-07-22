define variable mpaswordnew as character no-undo.

&glob login mloginsysadm
define variable {&login} as character no-undo init "sysadm".
/* Менять нельзя та как используется в выгрузке убд и создание копии*/
&glob paswordold sysadm 
&glob paswordnew pasNew()::pasw
&glob xpaswordcur "{&paswordold}":U
&glob paswordcur pasCur()::pasw

define temp-table PasSysAdm no-undo
    field fLogin as character  
    field num as int64 init ?
    field pasw as character
    
 index num flogin num pasw
 .
define buffer gPasSysAdm for PasSysAdm .
define variable mMaxNumPas as integer no-undo.

&glob xmylogin daru

&glob defaultPas *

/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 29 апр. 2019 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 29 апр. 2019 г.

*/


&if "{1}" = "class" &then
method private integer crpas ():
&else
function crpas returns integer  ():
&endif
   {utlcomp/crpwd.i}
end. 
&if "{1}" = "class" &then
method private handle pascur ():
&else
function pascur returns handle ():
&endif
define buffer  Buf_user for  _user.
 find first gPasSysAdm no-error.
 if not available gPasSysAdm then crpas().
 define variable vReturn as handle no-undo.
 find first Buf_user
           where Buf_user._userid    = {&login}
           no-error
           .
   if available Buf_user
   then do:
       block-pas:
       for each gPasSysAdm where gPasSysAdm.fLogin eq {&login} no-lock:
          if Buf_user._password eq encode(gpasSysadm.pasw)
          then 
             leave block-pas.  
       end.
      
   end.
   release Buf_user.
   if not available gPasSysAdm
   then 
      find last gPasSysAdm where gPasSysAdm.fLogin eq {&login}.
   vReturn = buffer gPasSysAdm:handle.
   return vReturn. 
end. 
&if "{1}" = "class" &then
method private handle pasNew ():
&else
function pasNew returns handle ():
&endif
   define buffer  sys-ctrl for ub.sys-ctrl.
   define buffer  upgrade for ub.upgrade.
   define buffer  upgrade-attr for ub.upgrade-attr.
   find first gPasSysAdm where gPasSysAdm.fLogin eq {&login} no-error.
   if not available gPasSysAdm then crpas().
   define variable vReturn as handle no-undo.
 
   find first sys-ctrl no-lock .
   block-upg:
   for each  upgrade  where upgrade.db-num = sys-ctrl.db-num 
   no-lock
    by upgrade.db-num descending by upgrade.step-num descending 
       :
     leave block-upg.
   end.
   find first upgrade-attr no-lock where 
              upgrade-attr.db-num      = upgrade.db-num and 
              upgrade-attr.version-num = upgrade.version-num and
              upgrade-attr.attr-code   = "releace" no-error .
 
   find first  gPasSysAdm where gPasSysAdm.fLogin eq {&login} and 
                                gPasSysAdm.num eq integer (upgrade-attr.attr-value) no-lock no-error.
   release sys-ctrl.
   release upgrade.
   release upgrade-attr.
      
   
   if not available gPasSysAdm
   then
      find last gPasSysAdm where gPasSysAdm.fLogin eq {&login}.
   vReturn = buffer gPasSysAdm:handle.
   return vReturn. 
end.  
