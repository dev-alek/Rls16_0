using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
using ibs.th.bge.1crn.export.send1cerpsub.
block-level on error undo, throw.
class ibs.th.bge.1crn.subjects.exp-chkSlipHead inherits send1cerpsub:
    define override public property vss-revision    as character no-undo init "$Revision:$":U get .
    define override public property vss-author      as character no-undo init "$Author:$":U get.
    define override public property vss-date        as character no-undo init "$Date:$":U get.
    define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
    define override public property vss-archive     as character no-undo init "$Archive:$":U get.
    define override public property vss-description as character no-undo init "Выгрузка отчетов с касс в 1С" get.
    define stream sinp .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-binfile-converter-program as character no-undo initial 'exe/base64.exe':U .
define temp-table temp-ext-file-line no-undo like ub.ext-file-line
  .
method public void binfile_read (p-db-num       as integer,
p-from-db-num  as integer,
p-file-num     as integer,
p-file-name    as character):
  define variable v-temp-file-name        as character no-undo .
  define variable v-convert-full-pathname as character no-undo .
  define variable v-input-full-pathname   as character no-undo .
  define variable v-temp-full-pathname    as character no-undo .
  define variable v-read-line             as character no-undo .
  define variable v-line-num              as integer   no-undo .
  define variable v-command-line          as character no-undo .
  define buffer buf_temp-ext-file-line for temp-ext-file-line .
  do
  on error undo, return error return-value
  :
    binfile_clear(input p-db-num
      ,input p-from-db-num
      ,input p-file-num
      ) .
    run gbl/_tmpfile.p
      (input  't':U
      ,input  '.b64':U
      ,output v-temp-file-name
      ) .
    RUN gbl/_tmpfile.p ( "report", ".txt", OUTPUT v-temp-file-name ) .
    assign
      file-info :file-name    = v-binfile-converter-program
      v-convert-full-pathname = file-info :full-pathname
    .
    assign
      file-info :file-name    = p-file-name
      v-input-full-pathname   = file-info :full-pathname
    .
    assign
      file-info :file-name    = v-temp-file-name
      v-temp-full-pathname    = file-info :full-pathname
    .
    if v-temp-full-pathname = ? then v-temp-full-pathname = v-temp-file-name .
    assign
      v-command-line = substitute('&1 -e "&2" &3':U
                                      ,v-convert-full-pathname
                                      ,v-input-full-pathname
                                      ,v-temp-full-pathname
                                      )
    .
    os-command silent value(v-command-line) .
    input stream sinp from value(v-temp-full-pathname) .
    assign
      v-line-num = 0
    .
    repeat
    :
      assign
        v-read-line = '':U
      .
      import stream sinp unformatted v-read-line .
      if v-read-line <> '':U
      then do:
        assign
          v-line-num  = v-line-num + 1
        .
        create buf_temp-ext-file-line .
        assign
          buf_temp-ext-file-line.db-num       = p-db-num
          buf_temp-ext-file-line.from-db-num  = p-from-db-num
          buf_temp-ext-file-line.file-num     = p-file-num
          buf_temp-ext-file-line.line-num     = v-line-num
          buf_temp-ext-file-line.sub-line-num = 0
          buf_temp-ext-file-line.line-text    = v-read-line
        .
      end.
    end.
    input stream sinp close .
    os-delete value(v-temp-full-pathname) .
  end.
end method.
method public void binfile_clear (p-db-num       as integer,
p-from-db-num  as integer,
p-file-num     as integer):
  define buffer buf_temp-ext-file-line  for temp-ext-file-line .
  do
  on error undo, return error return-value
  :
    for each buf_temp-ext-file-line
      where buf_temp-ext-file-line.db-num   = p-db-num
        and buf_temp-ext-file-line.from-db-num = p-from-db-num
        and buf_temp-ext-file-line.file-num = p-file-num
    on error undo, return error return-value
    :
      delete buf_temp-ext-file-line .
    end.
  end.
end method.
      define override public property InitSecTag as character no-undo init 'kass-reports':U
  get.
    define override public property sendTableName as character no-undo init "chkSlipHead"
        get.
    method override public void CheckParam(  ):
        define buffer buf_chk-slip-head for ub.chk-slip-head .
        if not valid-handle(oldbh) then
        do:
            Msg = "Не передана ссылка на отчет.".
            return error.
        end.
        if oldbh:keys ne "db-num,ID,CheckID,RRN" then
        do:
            Msg = "Переданы не отчеты.".
            return error.
        end.
        find first buf_chk-slip-head exclusive-lock where
            buf_chk-slip-head.obj-code  = int(oldbh:buffer-field( "obj-code":U  ):buffer-value )
            and buf_chk-slip-head.db-num = int(oldbh:buffer-field( "db-num":U  ):buffer-value )
            and buf_chk-slip-head.is-report = int(oldbh:buffer-field( "is-report":U  ):buffer-value )
            and buf_chk-slip-head.slip-dt  = datetime(oldbh:buffer-field( "slip-dt":U  ):buffer-value ) no-error .
        if not avail buf_chk-slip-head then
        do:
            Msg = substitute("Отчет &1 не найден.", oldbh:buffer-field( "id":U  ):buffer-value).
            return error.
        end.
        return.
    end method.
    method override public void CrContentToSW (insw as handle):
        define buffer buf_chk-slip-head  for ub.chk-slip-head .
        define buffer bf_chk-slip-head   for ub.chk-slip-head .
        define buffer bf_chk-slip-string for ub.chk-slip-string .
        define variable report-txt    as longchar no-undo .
        define variable report-json   as longchar no-undo .
        define variable v-report-txt  as longchar no-undo .
        define variable v-report-json as longchar no-undo .
        define buffer buf_temp-ext-file-line for temp-ext-file-line .
        define variable vMemptr-txt  as memptr no-undo .
        define variable vMemptr-json as memptr no-undo .
        find first buf_chk-slip-head no-lock where
            buf_chk-slip-head.obj-code  = int(oldbh:buffer-field( "obj-code":U  ):buffer-value )
            and buf_chk-slip-head.db-num = int(oldbh:buffer-field( "db-num":U  ):buffer-value )
            and buf_chk-slip-head.is-report = int(oldbh:buffer-field( "is-report":U  ):buffer-value )
            and buf_chk-slip-head.slip-dt  = datetime(oldbh:buffer-field( "slip-dt":U  ):buffer-value ) no-error .
        sendOldRowid = rowid(buf_chk-slip-head) .
        for each bf_chk-slip-head no-lock where bf_chk-slip-head.obj-code = buf_chk-slip-head.obj-code and
            bf_chk-slip-head.db-num = buf_chk-slip-head.db-num and
            bf_chk-slip-head.is-report = buf_chk-slip-head.is-report and
            bf_chk-slip-head.slip-dt > buf_chk-slip-head.slip-dt:
            report-json = "" .
            report-txt = "" .
            for each bf_chk-slip-string no-lock
                where bf_chk-slip-string.db-num = bf_chk-slip-head.db-num
                and bf_chk-slip-string.CheckID = bf_chk-slip-head.CheckID
                and bf_chk-slip-string.ID = bf_chk-slip-head.ID
                and bf_chk-slip-string.RRN = bf_chk-slip-head.RRN
                and bf_chk-slip-string.str-num < 10000
                by bf_chk-slip-string.str-num on error
                undo, return error return-value
                :
                report-txt = report-txt + chr(10) + bf_chk-slip-string.str-value .
            end.
            if report-txt <> "" then
            do:
                copy-lob from report-txt to vMemptr-txt .
                v-report-txt = base64-encode(vMemptr-txt) .
            end.
            for each bf_chk-slip-string no-lock
                where bf_chk-slip-string.db-num = bf_chk-slip-head.db-num
                and bf_chk-slip-string.CheckID = bf_chk-slip-head.CheckID
                and bf_chk-slip-string.ID = bf_chk-slip-head.ID
                and bf_chk-slip-string.RRN = bf_chk-slip-head.RRN
                and bf_chk-slip-string.str-num > 10000
                by bf_chk-slip-string.str-num on error
                undo, return error return-value
                :
                report-json = report-json + chr(10) + bf_chk-slip-string.str-value .
            end.
            if report-json <> "" then
            do:
                copy-lob from report-json to vMemptr-json .
                v-report-json = base64-encode(vMemptr-json) .
            end.
            insw:start-element ("kass-report") .
            insw:write-data-element (  "id":U,   string(bf_chk-slip-head.ID)    ).
            insw:write-data-element (  "generation":U,   iso-date(bf_chk-slip-head.slip-dt) ).
            insw:write-data-element (  "shift-date":U, iso-date(bf_chk-slip-head.CashShiftDate) ) .
            insw:write-data-element (  "shift-number":U,   string(bf_chk-slip-head.CashShiftNum)    ).
            insw:write-data-element (  "kass-num":U,   string(bf_chk-slip-head.cash-num)    ).
            insw:write-data-element (  "type":U,   string(bf_chk-slip-head.kind)    ).
            insw:write-data-element (  "report-txt":U,  v-report-txt ).
            insw:write-data-element (  "report-json":U,  v-report-json ).
            insw:end-element ("kass-report") .
        end.
        finally:
            if Msg <> "" then
                return error Msg.
        end finally.
    end method .
    method private character formatDateTime (iDateTime as datetime) :
        define variable vDateTime as character no-undo .
        if (iDateTime = ?) then vDateTime = "" .
        else
            vDateTime =  entry(1,iso-date(iDateTime),".")
                .
        return vDateTime .
    end method .
    method private character formatDate (iDate as date) :
        return if (iDate = ?) then "" else iso-date(iDate) .
    end method .
    method private character getCreatorOrder (iUserId as character) :
        define variable vUserName as character no-undo.
        define buffer buf_user-account for ub.user-account .
        if iUserId <> '' then
        do:
            find first buf_user-account no-lock where
                buf_user-account.user-id = iUserId no-error .
            if available (buf_user-account) then
                vUserName = trim(buf_user-account.last-name + " " + buf_user-account.first-name + " " + buf_user-account.second-name) .
        end.
        return vUserName.
    end method .
end class.
