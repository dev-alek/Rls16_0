using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.subjects from propath.
using ibs.th.bge.1crn.subjects.clients from propath.
using ibs.th.bge.1crn.subjects.clients_suppliers from propath.
using ibs.th.bge.1crn.subjects.clients_carriers from propath.
block-level on error undo, throw.
class ibs.th.bge.1crn.subjects.clients inherits ibs.th.bge.1crn.subjects.asubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define property code_ as character no-undo
    get.
    private set.
  define property del-l as integer no-undo
    get.
    private set.
  define property del-f as integer no-undo
    get.
    private set.
  define property name_ as character no-undo
    get.
    private set.
  define property full-name as character no-undo
    get.
    private set.
  define property nb-carriers     as subjects     no-undo get.
    private set.
  define property nb-suppliers    as subjects     no-undo get.
    private set.
  define property grp-code as character no-undo
    get.
    private set.
  define property city as character no-undo
    get.
    private set.
  define property ind as character no-undo
    get.
    private set.
  define property inn as character no-undo
    get.
    private set.
  define property kpp as character no-undo
    get.
    private set.
  define property agnt as character no-undo
    get.
    private set.
  define property post-adr as character no-undo
    get.
    private set.
  define property e-mail as character no-undo
    get.
    private set.
  define property leg-adr as character no-undo
    get.
    private set.
  define property okpo as character no-undo
    get.
    private set.
  define property post-np     as integer    no-undo
    get.
    private set.
  define property post-sug     as integer    no-undo
    get.
    private set.
  define property own-post    as integer    no-undo
    get.
    private set.
  define property post-npz     as integer    no-undo
    get.
    private set.
  define property code-KSK as character no-undo
    get.
    private set.
  define property code-AIS as character no-undo
    get.
    private set.
  define property org-code as character no-undo
    get.
    private set.
  define override property InitTag as character no-undo init "contractor"
    get.
  constructor public clients ():
    InitListTag = "nb-carriers,nb-suppliers".
  end constructor.
  method override protected void SetPropProtected (inTag as char, inValue as char):
    case inTag:
      when "code"      then
        code_     = if inValue >= "" then inValue else "" .
      when "del-l"     then
        del-l     = if inValue >= "" then integer (inValue) else 0 .
      when "del-f"     then
        del-f     = if inValue >= "" then integer (inValue) else 0 .
      when "name"      then
        name_     = if inValue >= "" then inValue else "" .
      when "full-name" then
        full-name = if inValue >= "" then inValue else "" .
      when "grp-code"  then
        grp-code  = if inValue >= "" then inValue else "" .
      when "city"      then
        city      = if inValue >= "" then inValue else "" .
      when "ind"       then
        ind       = if inValue >= "" then inValue else "" .
      when "inn"       then
        inn       = if inValue >= "" then inValue else "" .
      when "kpp"       then
        kpp       = if inValue >= "" then inValue else "" .
      when "agnt"      then
        agnt      = if inValue >= "" then inValue else "" .
      when "post-adr"  then
        post-adr  = if inValue >= "" then inValue else "" .
      when "e-mail"    then
        e-mail    = if inValue >= "" then inValue else "" .
      when "leg-adr"   then
        leg-adr   = if inValue >= "" then inValue else "" .
      when "okpo"      then
        okpo      = if inValue >= "" then inValue else "" .
      when "post-np"      then
        post-np      = if inValue >= "" then int(inValue) else 0 .
      when "post-sug"      then
        post-sug      = if inValue >= "" then int(inValue) else 0 .
      when "own"      then
        own-post      = if inValue >= "" then int(inValue) else 0 .
      when "npz"      then
        post-npz      = if inValue >= "" then int(inValue) else 0 .
      when "code-KSK"      then
        code-KSK      = if inValue >= "" then inValue else "" .
      when "code-AIS"      then
        code-AIS      = if inValue >= "" then inValue else "" .
      when "org-code"      then
        org-code      = if inValue >= "" then inValue else "" .
    end case.
  end method.
  method override protected void SetPropProtected(SubsObj as subjects):
    case SubsObj:InitTag:
      when "nb-carriers" then
        do:
          nb-carriers = SubsObj.
        end.
      when "nb-suppliers" then
        do:
          nb-suppliers = SubsObj.
        end.
    end case.
  end.
  method override protected void CheckData ():
    def var v-str as char no-undo.
    assign
      v-str = ",code"
      when code_ = ?
      v-str = v-str + ",name"
      when name_ = ?
      .
    v-str = substring(v-str, 2).
    if v-str > "" then undo, throw new Progress.Lang.AppError(
        substitute("Теги [&1] отсутствуют в сообщении [&2]", v-str, InitTag)
        ) .
  end method.
  method override protected void ClearSub():
    assign
      code_     = ?
      del-l     = ?
      del-f     = ?
      name_     = ?
      full-name = ?
      grp-code  = ?
      city      = ?
      ind       = ?
      inn       = ?
      kpp       = ?
      agnt      = ?
      post-adr  = ?
      e-mail    = ?
      leg-adr   = ?
      okpo      = ?
      post-np   = ?
      post-sug  = ?
      own-post  = ?
      post-npz  = ?
      code-KSK  = ?
      code-AIS  = ?
      org-code  = ?
      .
  end method.
end class.
