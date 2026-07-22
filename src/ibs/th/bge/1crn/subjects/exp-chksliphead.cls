/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Экспорт сообщения с отчетами полученных с касс в 1С ERPRN chk-slip-head

Автор: Шкляр Елена Львовна
Дата создания: 31/03/25
Author: Shklyar Elena
Creation date: 31/03/25

*/

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

    { cmp/str-glbl.i class }
    define stream sinp .
    { gbl/binfileclass.i  &stream-name=sinp class }
    
  &scop tag-interface 'kass-reports':U
    define override public property InitSecTag as character no-undo init {&tag-interface}
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
        do: /* проверяем по keys, т.к. имя таблицы может быть любым */
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

    /*------------------------------------------------------------------------------
     Purpose: выгружает состав сущности в контекст контейнера SAX-writer
     Notes:   обязательный метод
     Param:   insw = create sax-writer
    ------------------------------------------------------------------------------*/
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
                report-txt = report-txt + {&new-line} + bf_chk-slip-string.str-value .
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
                report-json = report-json + {&new-line} + bf_chk-slip-string.str-value .
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
    end method . /* end CrContentToSW */
  
    method private character formatDateTime (iDateTime as datetime) :
        define variable vDateTime as character no-undo . /* возвратное значение */
    
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
