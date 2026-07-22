using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.gbl.gbl-var:
  define static property g#auto as logical no-undo
    get.
    private set.
  define static property g#news-source-db as integer no-undo
    get.
    private set.
  define static property g#db-num as integer no-undo
    get.
    private set.
  define static property g#userid as character no-undo
    get.
    private set.
  define static property g#passwd as character no-undo
    get.
    private set.
  define static property g#esys as logical no-undo
    get.
    private set.
  define static property isInit as logical no-undo
    get.
    private set.
  define static property rcode as logical no-undo
    get.
    private set.
  constructor public gbl-var():
  end constructor.
        method public void InitObj (
         in_g#auto as log,
         in_g#news-source-db as int,
         in_g#db-num as int,
         in_g#userid as char,
         in_g#passwd as char,
         in_g#esys as log
         )
  :
    assign
      ibs.th.gbl.gbl-var:g#auto = in_g#auto
      ibs.th.gbl.gbl-var:g#news-source-db = in_g#news-source-db
      ibs.th.gbl.gbl-var:g#db-num = in_g#db-num
      ibs.th.gbl.gbl-var:g#userid = in_g#userid
      ibs.th.gbl.gbl-var:g#passwd = in_g#passwd
      ibs.th.gbl.gbl-var:g#esys = in_g#esys
    .
    rcode = search("gbl\library2.r") ne ?.
    ibs.th.gbl.gbl-var:isInit =  true.
  end method.
end class.
