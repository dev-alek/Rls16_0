using Progress.Lang.*.
using ibs.th.adm.upd.*.
class ibs.th.adm.upd.observupd:
  define variable vss-revision    as character no-undo init "$Revision$":U .
  define variable vss-author      as character no-undo init "$Author$":U .
  define variable vss-date        as character no-undo init "$Date$":U .
  define variable vss-workfile    as character no-undo init "$Workfile$":U .
  define variable vss-archive     as character no-undo init "$Archive$":U .
  define variable vss-description as character no-undo init "Модуль обновления БД".
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
method private integer crpas ():
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
method private handle pascur ():
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
method private handle pasNew ():
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
  define property List1 as character init "vsd,gds-mercury,c-vsd,c-gds-mercury" no-undo
    get.
  define property TargetDBShm as integer no-undo
    get.
    private set.
  define property CurrDBShm as integer  no-undo
    get.
    private set.
  define property CurrDB0Shm as integer  no-undo
    get.
    private set.
  define property isUpdShm as logical no-undo
    get.
    private set.
  define property DbNum as integer init ?  no-undo
    get.
    private set.
  define property IsErr as logical no-undo
    get.
    private set.
  define property Msg as character no-undo
    get.
    private set.
  define property PublisHandle as handle no-undo
    get.
    set.
  define private property IsComp as logical no-undo
    get.
    set.
  define property ModeUpd as character  no-undo
    get.
    set (iarg as character ):
       modeupd = iarg.
       IsComp = lookup("iscomp",iarg) ne 0 or lookup("UpdBlank",iarg) ne 0.
    end.
  define public variable pwd as character no-undo.
    define public property  m-upd-list-df      as character extent 54 no-undo
    initial ["cmp/18051601.df"
            ,"cmp/18062801.df"
            ,"cmp/18091701.df"
            ,"cmp/18091901.df"
            ,"cmp/18091902.df"
            ,"cmp/18101701_1.df"
            ,"cmp/18102101.df"
            ,"cmp/18102102.df"
            ,"cmp/18112201.df"
            ,"cmp/19022601.df"
            ,'proc:ibs/th/adm/upd/copytable.p;"arh-fin-doc-contr-schet-nal|arh-fin-doc-schet-nal-obj|fin-doc"'
            ,"cmp/19022602.df"
            ,"cmp/19052201.df"
            ,"cmp/19082001.df"
            ,"cmp/19092301.df"
            ,"cmp/19102401.df"
            ,"cmp/19122301.df"
            ,"cmp/20041001.df"
            ,"cmp/20041002.df"
            ,"cmp/20051501.df"
            ,"cmp/20052001.df"
            ,"cmp/20060901.df"
            ,"cmp/20082501.df"
            ,"cmp/20111601.df"
            ,"cmp/21070101.df"
            ,"cmp/21070102.df"
            ,"cmp/21091001.df"
            ,"cmp/21102101.df"
            ,"cmp/22041401.df"
            ,"cmp/22042901.df"
            ,"proc:upd/22080401.p"
            ,"cmp/22122601.df"
            ,"cmp/24761907.df"
            ,'proc:ibs/th/adm/upd/copytable.p;"marking|marking-lines"'
            ,"cmp/24760308.df"
            ,"cmp/26601010.df"
            ,"cmp/26682311.df"
            ,"cmp/06051202.df"
            ,"cmp/24042201.df"
            ,'proc:ibs/th/adm/upd/copytable.p;"chk-doc-attr"'
            ,"cmp/24042202.df"
            ,"cmp/24042203.df"
            ,"cmp/24121001.df"
            ,"cmp/25012701.df"
            ,"proc:upd/25012701.p"
            ,"cmp/25042801.df"
            ,"cmp/25041501.df"
            ,"cmp/21011501.df"
            ,"cmp/25110701.df"
            ,"cmp/49250910.df"
            ,"cmp/26022401.df"
                        ,"cmp/26033001.df"
            ,"cmp/26070601.df"
            ,"cmp/26062901.df"
            ]
     get.
  define public property m-upd-list-chk      as character extent 54 no-undo
    initial ["TABLE:gds-mercury"
            ,"TABLE:PromoAction"
            ,"FIELD:chk-gds-pay.density"
            ,"FIELD:chk-gds.VAT-pc"
            ,"TABLE:norm-loss"
            ,"FIELD:norm-loss.sec-vol1"
            ,"TABLE:tech-prol-pwd"
            ,"FIELD:c-norm-loss.sec-vol1"
            ,"FIELD:tech-prol-pwd.f-cash-num"
            ,"TABLE:arh-fin-doc-contr-schet-nal,TABLE:arh-fin-doc-contr-schet-nal_old,TABLE:arh-fin-doc-schet-nal-obj,TABLE:arh-fin-doc-schet-nal-obj_old,TABLE:fin-doc,TABLE:fin-doc_old"
            ,"proc:ibs/th/adm/upd/chkemptable.p;arh-fin-doc-contr-schet-nal_old|arh-fin-doc-schet-nal-obj_old|fin-doc_old"
            ,"TABLE:cashbook,TABLE:operserv"
            ,"Initial:db.reserve1-char=13"
            ,"TABLE:code"
            ,"FIELD:cashbook.CorrRko"
            ,"Table:devisPC"
            ,"Initial:db.reserve1-char=17"
            ,"TABLE:Utd"
            ,"FIELD:marking-lines.prt-code"
            ,"FIELD:c-utd-head.CheckObj"
            ,"TABLE:c-contract-specif-attr"
            ,"Initial:db.reserve1-char=22"
            ,"TABLE:auto-section"
            ,"TABLE:xattr"
            ,"TABLE:c-code"
            ,"FIELD:code.nwsgbd"
            ,"TABLE:tran-fuel"
            ,"FIELD:sr-izmerenia.sr-not-used,FIELD:c-sr-izmerenia.sr-not-used"
            ,"TABLE:chk-slip-head,TABLE:chk-slip-string"
            ,"INDEX:chk-slip-head.reps-full"
            ,"proc:upd/22080402.p"
            ,"TABLE:cash-param-hist"
            ,"TABLE:c-marking"
            ,"proc:ibs/th/adm/upd/chkemptable.p;marking_old|marking-lines_old"
            ,"Initial:db.reserve1-char=35"
            ,"Initial:db.reserve1-char=36"
            ,"Initial:db.reserve1-char=37"
            ,"proc:utl/checksi1056.p"
            ,"TABLE:chk-doc-attr"
            ,"proc:ibs/th/adm/upd/chkemptable.p;chk-doc-attr_old"
            ,"Initial:db.reserve1-char=41"
            ,"TABLE:c-marking-chk"
            ,"Initial:db.reserve1-char=43"
            ,"TABLE:shift-period"
            ,"proc:upd/25012702.p"
            ,"TABLE:place-imp,TABLE:place-imp-attr,TABLE:pl-level-imp,TABLE:pl-level-mm-imp"
            ,"TABLE:order-doc"
            ,"INDEX:utd-marking-lines.gds_sts"
            ,"FIELD:marking.expDate"
            ,"TABLE:esys-pck-rcvd-err"
            ,"FIELD:pl-level-imp.deltaV"
            ,"TABLE:shift-param"
            ,"FIELD:chk-slip-head.CashShiftNum"
            ,"FIELD:cash-desk.device-kind"
            ]
    get.
  define public property  upd-all-list-df      as character  no-undo
    get.
  define property upd-df as character no-undo
  get():
    return if extent (m-upd-list-df) > CurrDBShm
           then m-upd-list-df[CurrDBShm + 1]
           else "".
  end.
  constructor observupd ():
    define buffer buf_sys-ctrl for ub.sys-ctrl.
    define buffer buf_db for ub.db.
    define variable vVerStuct as integer no-undo.
    define variable vVerDB    as integer no-undo.
    TargetDBShm = extent(m-upd-list-df).
    find first buf_sys-ctrl no-lock no-error.
    if available buf_sys-ctrl
    then do:
       DbNum = buf_sys-ctrl.db-num.
       find first buf_db no-lock where buf_db.db-num = DbNum no-error.
       if available buf_db
       then do:
          if buf_db.reserve1-char begins "updto:"
          then
             vVerStuct = integer (substring(buf_db.reserve1-char,7)) no-error.
          else
             vVerStuct = integer (buf_db.reserve1-char) no-error.
       end.
    end.
    find first _file no-lock where _file._file-name = "db"  no-error.
    if available _file
    then do:
       find first _field of _file where _field._Field-Name =  "reserve1-char" no-lock no-error.
       if available (_field)
       then do:
          vVerDB = integer (_field._initial) no-error.
          release _field.
       end.
       release _file.
    end.
    CurrDBShm = max(vVerDB,vVerStuct).
    find first buf_db no-lock where buf_db.db-num = 0 no-error.
    if available buf_db
    then do:
       if buf_db.reserve1-char begins "updto:"
       then
          CurrDB0Shm = integer (substring(buf_db.reserve1-char,7)) no-error.
       else
          CurrDB0Shm = integer (buf_db.reserve1-char) no-error.
    end.
    pwd = pasCur()::pasw.
    release buf_db.
    release buf_sys-ctrl.
  end.
  method public void dbexcept( input-output inListDb as char, input inTableName as char ):
    def var ii as int no-undo.
    def var iDB as int no-undo.
    def var numentr as int no-undo.
    def var newListDB as char no-undo init "NULL".
    def var dBShm0 as integer no-undo.
    def var TempInt as integer no-undo.
    define buffer buf_db for ub.db.
    if DbNum <> 0
        then return.
    dbShm0 = CurrDB0Shm.
    numentr = num-entries (inListDb, chr(1)) no-error.
    if numentr = ?
    then do:
      return .
    end.
    if lookup (inTableName, List1) > 0
    then do:
      do ii = 1 to numentr:
        TempInt = 0.
        iDB = integer (entry (ii, inListDb, chr(1) )) no-error.
        for each buf_db where buf_db.db-num = iDB and buf_db.db-num <> 0:
           if buf_db.reserve1-char begins "updto:"
           then
              TempInt = integer (substring(buf_db.reserve1-char,7)) no-error.
           else
              TempInt = integer (buf_db.reserve1-char) no-error.
          if TempInt = ?
            then TempInt = 0.
          if TempInt = 1
          then do:
            if newListDB = "NULL"
              then newListDB = "".
            newListDB = newListDB + chr(1) + string (iDB).
          end.
        end.
      end.
      inListDb = trim (newListDB, chr(1)).
    end.
    return.
  end method.
  method private logical chkdbforupd ():
    define variable v-process-id   as integer   no-undo.
    define variable v-process-list as character no-undo.
    define variable vUserIgnor     as character no-undo.
    define buffer buf_thbj-attr for ub.thbj-attr.
    run gbl/getprcid.p ( output v-process-id ) no-error.
    if error-status:error
    then do:
      Msg = ( "Невозможно получить PID процесса. Обновление схемы БД невозможно. Работа с ней запрещена!" ).
      IsErr = true.
      return false.
    end.
    find first buf_thbj-attr no-lock
       where buf_thbj-attr.obj-type        = 'БД':U
         and buf_thbj-attr.obj-code        = DbNum
         and buf_thbj-attr.upper-prop-code = 'auto-task':U
         and buf_thbj-attr.prop-code       = 'user-list':U
    no-error.
    if available buf_thbj-attr
    then do:
       vUserIgnor = buf_thbj-attr.property-value-character.
       release buf_thbj-attr.
    end.
    else
       vUserIgnor = "nws".
    for each _Connect where _Connect._Connect-Type = "REMC"
                        and _Connect._Connect-Pid <> ?
                        and _Connect._Connect-Pid <> v-process-id
                        and not can-do(vUserIgnor,_Connect._Connect-Name)
    no-lock:
      v-process-list = v-process-list + chr(10) + string (_Connect._Connect-Pid) + " - " + _Connect._Connect-Name +  " - " + _Connect._Connect-Device.
    end.
    if v-process-list <> ""
    then do:
      Msg = substitute ( "Для обновления схемы БД завершите процессы. &1",  v-process-list).
      IsErr = true.
      return false.
    end.
    return true.
  end.
  method public void writeResult (input inShm as integer):
    define variable vI       as integer no-undo.
    define variable vStrChk  as character no-undo.
    define variable vAttr    as character no-undo.
    define variable vSearch  as character no-undo.
    define variable vValue   as character no-undo.
    define variable vProc    as character no-undo.
    define variable vparam   as character no-undo.
    define variable vOK      as logical   no-undo.
    define variable VTestStr as character no-undo.
    define variable vrunProc as logical   no-undo.
    define buffer buf_db for ub.db.
    define buffer buf_sys-ctrl for ub.sys-ctrl.
    on write of ub.db override do: end.
    if inShm > 0
    then do:
    VTestStr = m-upd-list-chk[inShm] .
       do vi = 1 to num-entries(VTestStr):
         assign
           vStrChk = entry(vi,VTestStr)
           vattr   = ""
           vValue  = ""
           vSearch = entry(1,vStrChk,":")
           vStrChk = substring(vStrChk,length(vSearch) + 2)
           vValue  = entry (2,vStrChk,"=")
           vStrChk = entry (1,vStrChk,"=")
         no-error.
         if    can-do("Desc,Help,Valmsg,Valexp,Order,Column-label,Decimals,Extent,Data-Type,Initial,Mandatory,inactive",vSearch)
         then assign
            vattr = "_" + vSearch
            vSearch = "FIELD".
          .
         if vSearch eq "proc"
         then do:
            assign
               vProc  = entry(1,vStrChk,";")
               vParam = entry(2,vStrChk,";")
            no-error.
            if SearchPFile (vProc) eq ?
            then do:
               Msg = substitute ( "Обновление схемы БД до версии &1 завершилось неудачно. Не найден файл '&2' . Работа с ней запрещена!",inShm,Vproc ).
               IsErr = true.
               return.
            end.
            run value(vProc) (vParam, output vOk) no-error.
            if not vOk
            then do:
               Msg = substitute ( "Обновление схемы БД до версии &1 завершилось неудачно. Не прошла провека '&2' c параметрром '&3' . Работа с ней запрещена!",inShm,Vproc,vParam ).
               IsErr = true.
               return.
            end.
            else
               vrunProc = yes.
         end.
         else if vSearch eq "TABLE"
         then do:
           find first _file no-lock where _file._file-name = vStrChk  no-error.
           if not available (_file)
           then do:
             Msg = substitute ( "Обновление схемы БД до версии &1 завершилось неудачно. Отсутствует таблица &2. Работа с ней запрещена!",inShm,vStrChk ).
             IsErr = true.
             return.
           end.
         end.
         else if vSearch eq "SEQUENCE"
         then do:
           find first _Sequence no-lock where _Sequence._Seq-Name = vStrChk  no-error.
           if not available (_Sequence)
           then do:
             Msg = substitute ( "Обновление схемы БД до версии &1 завершилось неудачно. Отсутствует Sequence &2. Работа с ней запрещена!",inShm,vStrChk ).
             IsErr = true.
             return.
           end.
         end.
         else if vSearch eq "FIELD"
         then do:
           find first _file no-lock where _file._file-name = entry(1,vStrChk,".")  no-error.
           if available _file
           then
              find first _field of _file where _field._Field-Name =  entry(2,vStrChk,".") no-lock no-error.
           if not available (_field)
           then do:
             Msg = substitute ( "Обновление схемы БД до версии &1 завершилось неудачно. Отсутствует поле &2. Работа с ней запрещена!", inShm,vStrChk ).
             IsErr = true.
             return.
           end.
           else do:
             define variable vBuffHandle as handle no-undo.
             vBuffHandle = buffer _field:handle.
             if     vattr ne ""
                and vBuffHandle:buffer-field(vattr):buffer-value ne vvalue
             then do:
               Msg = substitute ( "Обновление схемы БД до версии &1 завершилось неудачно. У поля &2 реквизит &3 не равен &4. Работа с ней запрещена!", inShm,vStrChk,vAttr,vValue ).
               IsErr = true.
               return.
             end.
           end.
         end.
       end.
    end.
    if not iscomp
    then do:
       find first buf_sys-ctrl no-lock no-error.
       if available buf_sys-ctrl
       then do:
          find first buf_db exclusive-lock where buf_db.db-num = buf_sys-ctrl.db-num no-error.
          buf_db.reserve1-char = "updto:" + string (inShm).
          CurrDBShm = inShm.
          buf_db.reserve2-char = "deferred-callnews".
          release buf_db.
          release buf_sys-ctrl.
       end.
    end.
    else do:
       if     vrunProc
          and inShm >= TargetDBShm
       then do:
          find first _file no-lock where _file._file-name = "db"  no-error.
          if available _file
          then do:
             find first _field of _file where _field._Field-Name =  "reserve1-char" no-lock no-error.
             if     available (_field)
                and _field._initial ne string (inShm)
             then do:
                find first _field of _file where _field._Field-Name =  "reserve1-char" exclusive-lock no-error.
               _field._initial = string (inShm).
               release _field.
             end.
             release _file.
          end.
       end.
    end.
    CurrDBShm = inShm.
    isUpdShm = true.
  end.
  method public logical isneedupg (input flag as logical):
    return CurrDBShm < TargetDBShm .
  end.
  method public logical isneedupg ():
    if CurrDBShm < TargetDBShm
      then
    do:
      if not chkdbforupd ()
        then return ?.
      return true.
    end.
    if upd-all-list-df ne "" and not IsComp then return true.
    return false.
  end.
  method public void putstat (input itext as char):
     if valid-handle(PublisHandle)
     then
        publish "putstat" from PublisHandle (itext ).
   end.
method public character objExists
(input  ifolder as character,
 input  iType   as character  ):
    define variable vFileType as character no-undo init "D,F".
    define variable vi        as integer no-undo.
    define variable vtype as character no-undo.
    if iType ne ?
    then
       vFileType = iType.
    do vi = 1 to num-entries(vFileType):
       file-information:file-name = ".\" + right-trim(replace(ifolder,"/","\"),"\").
       vtype = file-information:file-type.
       if entry(num-entries(file-information:file-name, "\"), file-information:file-name, "\")
          = entry(num-entries(file-information:full-pathname, "\"), file-information:full-pathname ,"\") and
          index(vtype , entry(vi,vFileType )) > 0
       then return file-information:full-pathname .
       file-information:file-name = right-trim(replace(ifolder,"/","\"),"\").
       vtype = file-information:file-type.
       if file-information:file-name <> "" and
          entry(num-entries(file-information:file-name, "\"), file-information:file-name, "\")
          = entry(num-entries(file-information:full-pathname, "\"), file-information:full-pathname ,"\") and
          index( vtype, entry(vi,vFileType )) > 0
       then return file-information:full-pathname .
    end.
    return ? .
end.
method public character SearchFile
(input  ifile as character):
   return objExists(ifile,?).
end.
method public character SearchPFile
(input inFile as char):
     define variable oFile       as character no-undo.
     define variable vFileSearch as character no-undo.
     define variable vNumEntry   as integer no-undo.
     if inFile = "" then return ?.
     vNumEntry = num-entries(inFile,".").
     vFileSearch = inFile.
     if    vNumEntry > 0
        and (   entry(vNumEntry,inFile,".") eq "p"
             or entry(vNumEntry,inFile,".") eq "w")
     then do:
        entry(vNumEntry,vFileSearch, ".") = "r".
        oFile = search(vFileSearch ).
        if oFile eq ?
        then
           oFile = search(inFile).
     end.
     else
        oFile = search(vFileSearch).
     return oFile.
  end.
end class.
