block-level on error undo, throw.
 /*
 $Revision:$
 $Author:$
 $Date:$
 $Workfile:$
 $Archive:$
 
 Автор: Рубан Дмитрий Андреевич 
 Дата создания: 5 мая 2019 г.
 Author:  Ruban Dmitriy Andreevich
 Creation date: 5 мая 2019 г.
 
 */
 define variable vss-revision    as character no-undo init "$Revision:$":U .
 define variable vss-author      as character no-undo init "$Author:$":U .
 define variable vss-date        as character no-undo init "$Date:$":U .
 define variable vss-workfile    as character no-undo init "$Workfile:$":U .
 define variable vss-archive     as character no-undo init "$Archive:$":U .
 define variable vss-description as character no-undo init "Процедура заполнения истории версий".
 { cmp/vssrevis.i }
 
 { cmp/str-glbl.i }
    define variable v-version           as character no-undo .
    define variable v-locale            as character no-undo .
    define variable v-SVNRev            as integer   no-undo .
    define variable v-compilerVersion   as character no-undo .
    define variable v-compile-date      as date      no-undo .
    define variable v-time              as integer   no-undo .
    define variable v-THVer             as character no-undo .
    define variable v-file-date         as date      no-undo .
    define variable v-file-time         as integer   no-undo .
    define variable v-releace           as integer   no-undo.
    define variable v-patch             as integer   no-undo.
    define variable v-branch            as integer  no-undo.
  
    define variable mstep as integer no-undo.
    define variable mCountVer as integer no-undo.

function update-attr returns logical (iDb-num as integer,
                                      iVersion as character,
                                      iAttrCode as character, 
                                      iAttrValue as character) forward.


   run gbl/vertag.p (
         output v-THver
       , output v-locale
       , output v-SVNRev
       , output v-compilerVersion
       , output v-compile-date
       , output v-time
       , output v-version 
       , output v-file-date
       , output v-file-time
       , output v-releace
       , output v-patch
       , output v-branch     
   ) .
   find first sys-ctrl.
   if    v-version eq ""
      or v-version eq ?  
   then 
      v-version = "?".
   block-step:
   for each upgrade where upgrade.db-num   eq sys-ctrl.db-num
                        
   no-lock by upgrade.db-num descending 
           by upgrade.step-num descending :
      leave block-step.        
   end.
   if      available upgrade
      and (
         upgrade.version-num eq     v-version 
      or upgrade.version-num begins v-version + {&delim-par})
   then
      return. /* последняя версия совпадает с текущей */
                          
   mstep = if available upgrade then (upgrade.step-num + 1) else 1.
/* Проверим ставилась ли верия раньше */
   find  first upgrade where upgrade.db-num      eq sys-ctrl.db-num
                         and upgrade.version-num eq v-version
      no-lock no-error.
   if available upgrade
   then do:
/*находим последний номер установки версии */
       block-ver-num:
      for each upgrade where upgrade.db-num      eq sys-ctrl.db-num
                         and upgrade.version-num begins v-version +  {&delim-par}
      no-lock by int(entry(2,upgrade.version-num,{&delim-par})) descending :
         leave block-ver-num.
      end.
      mCountVer = if available upgrade then int(entry(2,upgrade.version-num,{&delim-par})) + 1 else 1.
       
   end.
   do trans:
   create upgrade.
   assign
      upgrade.complete = yes
      upgrade.db-num   = sys-ctrl.db-num
      upgrade.step-num = mstep
      upgrade.UpgDate  = today
      upgrade.UpgTimeInt  = time
      upgrade.UpgTime     = string( time, "HH:MM:SS" )
      upgrade.version-num = v-version + if mCountVer ne 0 then {&delim-par} + string (mCountVer) else ""
      upgrade.version-ord = next-value( s-upg-ord, ub )
   .
   validate upgrade. 
/* здесь необходимо переложить информацию из переменных в атрибуты*/    
   update-attr(upgrade.db-num,
               upgrade.version-num,
               "locale",
               v-locale).
   update-attr(upgrade.db-num,
               upgrade.version-num,
               "SVNRev",
               string(v-SVNRev)).
   update-attr(upgrade.db-num,
               upgrade.version-num,
               "compilerVersion",
               v-compilerVersion).
   update-attr(upgrade.db-num,
               upgrade.version-num,
               "compile-date",
               string(v-compile-date)).
   update-attr(upgrade.db-num,
               upgrade.version-num,
               "time",
               string(v-time)).
   update-attr(upgrade.db-num,
               upgrade.version-num,
               "thver",
               v-thver).             

   update-attr(upgrade.db-num,
               upgrade.version-num,
               "file-date",
               string(v-file-date)).             

   update-attr(upgrade.db-num,
               upgrade.version-num,
               "file-time",
               string(v-file-time)).
   update-attr(upgrade.db-num,
               upgrade.version-num,
               "user",
               userid("ub")).
   update-attr(upgrade.db-num,
               upgrade.version-num,
               "releace",
               string(v-releace)).
   update-attr(upgrade.db-num,
               upgrade.version-num,
               "patch",
               string(v-patch)).
   update-attr(upgrade.db-num,
               upgrade.version-num,
               "branch",
               string(v-branch)).             
               
    release upgrade.
    end.           


function update-attr returns logical (iDb-num as integer,
                                      iVersion as character,
                                      iAttrCode as character, 
                                      iAttrValue as character):
    find first upgrade-attr where upgrade-attr.db-num eq iDb-num
                              and upgrade-attr.version-num eq iVersion
                              and upgrade-attr.attr-code eq iAttrCode
       no-lock no-error.
    if available upgrade-attr
    then
       find current upgrade-attr exclusive-lock.
    else do:
       create upgrade-attr.
       assign
          upgrade-attr.db-num      = iDb-num
          upgrade-attr.version-num = iVersion
          upgrade-attr.attr-code   = iAttrCode
       .
    end.
    upgrade-attr.attr-value = iAttrValue.
    release upgrade-attr.
    return yes.   
end function.    
    