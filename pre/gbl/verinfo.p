block-level on error undo, throw.
 define variable vss-revision    as character no-undo init "$Revision:$":U .
 define variable vss-author      as character no-undo init "$Author:$":U .
 define variable vss-date        as character no-undo init "$Date:$":U .
 define variable vss-workfile    as character no-undo init "$Workfile:$":U .
 define variable vss-archive     as character no-undo init "$Archive:$":U .
 define variable vss-description as character no-undo init "Процедура заполнения истории версий".
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
      or upgrade.version-num begins v-version + chr(4))
   then
      return.
   mstep = if available upgrade then (upgrade.step-num + 1) else 1.
   find  first upgrade where upgrade.db-num      eq sys-ctrl.db-num
                         and upgrade.version-num eq v-version
      no-lock no-error.
   if available upgrade
   then do:
       block-ver-num:
      for each upgrade where upgrade.db-num      eq sys-ctrl.db-num
                         and upgrade.version-num begins v-version +  chr(4)
      no-lock by int(entry(2,upgrade.version-num,chr(4))) descending :
         leave block-ver-num.
      end.
      mCountVer = if available upgrade then int(entry(2,upgrade.version-num,chr(4))) + 1 else 1.
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
      upgrade.version-num = v-version + if mCountVer ne 0 then chr(4) + string (mCountVer) else ""
      upgrade.version-ord = next-value( s-upg-ord, ub )
   .
   validate upgrade.
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
