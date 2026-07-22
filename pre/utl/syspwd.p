block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
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
define input  parameter IBuff as handle no-undo.
define variable mpaswordnew as character no-undo.
define variable mloginsysadm as character no-undo init "sysadm".
define temp-table PasSysAdm no-undo
    field fLogin as character
    field num as int64 init ?
    field pasw as character
 index num flogin num pasw
 .
define buffer gPasSysAdm for PasSysAdm .
define variable mMaxNumPas as integer no-undo.
function crpas returns integer  ():
   create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 1
     pasSysadm.pasw    = "sysadm"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 7
     pasSysadm.pasw    = "!sysadm_new1"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 8
     pasSysadm.pasw    = "rf;lsqj[jnybrljk;typyfnmultcblbnafpfy"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 9
     pasSysadm.pasw    = "byjulfyfijujymufcytnyjlheujqxtkjdtrcyjdfhfpledftntuj"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 10
     pasSysadm.pasw    = "dctltkjdvuyjdtybbjyjjghtltkztn;bpym"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 11
     pasSysadm.pasw    = "byjulf[dfnftnvuyjdtybzxnj,spf,snm;bpym"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 12
     pasSysadm.pasw    = "fbyjulfyt[dfnftn;bpybxnj,spf,snmvuyjdtybt"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 13
     pasSysadm.pasw    = "ytdsgecrfqntcjkywtbpleibjyjntgkjvgj;bpybhfpjqltncz"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 14
     pasSysadm.pasw    = "vfvfdctujxtnsht,erdsfcvscklkbyj.d;bpym"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 15
     pasSysadm.pasw    = "ckj;yttdctujpf,sdfnmnt[k.ltqcrjnjhsvbnspf,sdfkj,jdctv"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 16
     pasSysadm.pasw    = "vjkxfybtdctulfyfgjkytyjckjdfvb"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 17
     pasSysadm.pasw    = "[jhjibtlhepmz[jhjibtrybubbcgzofzcjdtcnmdjnbltfkmyfz;bpym"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 18
     pasSysadm.pasw    = "eqnbytgjldbugjldbuytdthyenmcztctyby"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 19
     pasSysadm.pasw    = "gjhjqxedcndfrfrwdtnjrye;yjdhtvzxnj,shfcgecnbnmcz"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 20
     pasSysadm.pasw    = ";bdtimdtlmnjkmrjhfpnjkmrjhfphtifqcz"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 21
     pasSysadm.pasw    = "cfvjtdf;yjtd;bpyb'njyfexbnmczgflfnm"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 22
     pasSysadm.pasw    = "xfcnjcxfcnmtboennfr;trfrjxrbrjulfjybyfyjce"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 23
     pasSysadm.pasw    = "pfgjvybnt'njnltymdjpdhfnebj,vtyeytgjlkt;bn"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 24
     pasSysadm.pasw    = "tckb[jxtimedbltnmxelj,elmbv"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 25
     pasSysadm.pasw    = "dctecgt[byfxbyf.nczccfvjlbcwbgkbys"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 26
     pasSysadm.pasw    = "dxthf'njbcnjhbzpfdnhf'njpfuflrffctujlyz'njlfh"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 27
     pasSysadm.pasw    = "xtvyb;txtkjdtrleijqntvdsitpflbhftnyjc"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 28
     pasSysadm.pasw    = "cfvjtghtrhfcyjtcvjnhtnmdukfpfxtkjdtrerjnjhsqeks,ftncz"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 29
     pasSysadm.pasw    = "kexifzhtfrwbzyfdhf;tcre.rhbnbreeks,yenmczbpf,snm"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 30
     pasSysadm.pasw    = "gkfnfpfbylbdblefkmyjcnmjlbyjxtcndj"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 31
     pasSysadm.pasw    = "ljdthbt'njdf;yjfnjxytt'njdct"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 32
     pasSysadm.pasw    = ",thtubntdct,txtkjdtrf"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 33
     pasSysadm.pasw    = "btckbghbltnczegfcnmegflbrhfcbdj"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 34
     pasSysadm.pasw    = "ytbpdtcnyfzdthcbzgfhjkzgfhjkz"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "odbc"
     pasSysadm.num     = 1
     pasSysadm.pasw    = "odbc"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "odbc"
     pasSysadm.num     = 7
     pasSysadm.pasw    = "odbc"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "odbc"
     pasSysadm.num     = 8
     pasSysadm.pasw    = "111ikfcfifgjijcctbcjcfkfceire!!!"
  .
end.
function pascur returns handle ():
define buffer  Buf_user for  _user.
 find first gPasSysAdm no-error.
 if not available gPasSysAdm then crpas().
 define variable vReturn as handle no-undo.
 find first Buf_user
           where Buf_user._userid    = mloginsysadm
           no-error
           .
   if available Buf_user
   then do:
       block-pas:
       for each gPasSysAdm where gPasSysAdm.fLogin eq mloginsysadm no-lock:
          if Buf_user._password eq encode(gpasSysadm.pasw)
          then
             leave block-pas.
       end.
   end.
   release Buf_user.
   if not available gPasSysAdm
   then
      find last gPasSysAdm where gPasSysAdm.fLogin eq mloginsysadm.
   vReturn = buffer gPasSysAdm:handle.
   return vReturn.
end.
function pasNew returns handle ():
   define buffer  sys-ctrl for ub.sys-ctrl.
   define buffer  upgrade for ub.upgrade.
   define buffer  upgrade-attr for ub.upgrade-attr.
   find first gPasSysAdm where gPasSysAdm.fLogin eq mloginsysadm no-error.
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
   find first  gPasSysAdm where gPasSysAdm.fLogin eq mloginsysadm and
                                gPasSysAdm.num eq integer (upgrade-attr.attr-value) no-lock no-error.
   release sys-ctrl.
   release upgrade.
   release upgrade-attr.
   if not available gPasSysAdm
   then
      find last gPasSysAdm where gPasSysAdm.fLogin eq mloginsysadm.
   vReturn = buffer gPasSysAdm:handle.
   return vReturn.
end.
IBuff::Usr = "sysadm".
IBuff::Pwd = pasCur()::pasw.
return.
