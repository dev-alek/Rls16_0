/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Экспорт сообщения с отчетами сформированными после закрытия смены в 1С ERPRN reportShift

Автор: Ростовцев Александр Михайлович
Дата создания: 31/03/25
Author: Rostovtsev Aleksandr
Creation date: 31/03/25

*/

using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
using ibs.th.bge.1crn.export.send1cerpsub.
block-level on error undo, throw.


class ibs.th.bge.1crn.subjects.exp-reportShift inherits send1cerpsub:
    define override public property vss-revision    as character no-undo init "$Revision:$":U get .
    define override public property vss-author      as character no-undo init "$Author:$":U get.
    define override public property vss-date        as character no-undo init "$Date:$":U get.
    define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
    define override public property vss-archive     as character no-undo init "$Archive:$":U get.
    define override public property vss-description as character no-undo init "Выгрузка отчетов в 1С" get.

    { cmp/str-glbl.i class }
    define stream sinp .
    { gbl/binfileclass.i  &stream-name=sinp class }
    
  &scop tag-interface 'TH-reports':U
    define override public property InitSecTag as character no-undo init {&tag-interface}
  get.

    define override public property sendTableName as character no-undo init "reportShift"
        get.
   
    method override public void CheckParam(  ):
        define buffer buf_reportShift for ub.reportShift .
        define variable mypar       as character no-undo .
        define variable report-html as character no-undo .
        define variable report-json as character no-undo .

        if not valid-handle(oldbh) then 
        do:
            Msg = "Не передана ссылка на отчет.".
            return error.
        end.

        if oldbh:keys ne "obj-code,obj-type,shift-date,shift-num,report-type" then 
        do: /* проверяем по keys, т.к. имя таблицы может быть любым */
            Msg = "Переданы не отчеты.".
            return error.
        end.
        find first buf_reportShift exclusive-lock where 
            buf_reportShift.obj-code  = int(oldbh:buffer-field( "obj-code":U  ):buffer-value )
            and buf_reportShift.obj-type = oldbh:buffer-field( "obj-type":U  ):buffer-value 
            and buf_reportShift.shift-date = date(oldbh:buffer-field( "shift-date":U  ):buffer-value )
            and buf_reportShift.shift-num  = int(oldbh:buffer-field( "shift-num":U  ):buffer-value ) 
            and buf_reportShift.report-type  = int(oldbh:buffer-field( "report-type":U  ):buffer-value ) no-error .
        if not avail buf_reportShift then 
        do:
            Msg = substitute("Отчет &1 не найден.", oldbh:buffer-field( "id":U  ):buffer-value).
            return error.
        end.
        mypar =
            "X-DATE-START = " + string(buf_reportShift.shift-date, "99/99/9999") + {&comma-char} +
            "X-SHIFT-START = " + string(buf_reportShift.shift-num) + {&comma-char} +
            "X-DATE-END = " + string(buf_reportShift.shift-date, "99/99/9999") + {&comma-char} +
            "X-SHIFT-END = " + string(buf_reportShift.shift-num) .
        
        run rep/r-closeShift.p
            ( input parparentproc
/*            ,input this-procedure:handle /*p-parent-handle*/   */
/*            ,input this-procedure:handle /*      p-log-handle*/*/
/*            ,input this-procedure:handle /*   p-cont-handle*/  */
/*            ,input this-procedure:handle /*p-call-handle*/     */
            ,input ? /*p-redbh*/
            ,input '' /*p-report-id*/
            ,input mypar
            ,INPUT buf_reportShift.obj-code
            ,INPUT buf_reportShift.obj-type
            ,INPUT "руб"
            ,INPUT 0
            ,INPUT yes
            ,INPUT yes
            ,input yes
            ,input yes
            ,input no
            ,INPUT yes
            ,input no
            ,input yes
            ,input yes
            ,input yes
            ,input yes
            ,input yes
            ,input yes
            ,input yes
            ,input no
            ,input yes
            ,output report-html
            ,output report-json
            ) .
            
            buf_reportShift.report-html = report-html .
            buf_reportShift.report-json = report-json .
            
        return.

    end method.

    /*------------------------------------------------------------------------------
     Purpose: выгружает состав сущности в контекст контейнера SAX-writer
     Notes:   обязательный метод
     Param:   insw = create sax-writer
    ------------------------------------------------------------------------------*/
    method override public void CrContentToSW (insw as handle):
        define buffer buf_reportShift for ub.reportShift .
        define variable v-dt-shift-start as datetime no-undo .
        define variable v-dt-shift-end   as datetime no-undo .
        define variable report-html      as longchar no-undo .
        define variable report-json      as longchar no-undo .
        define buffer buf_temp-ext-file-line for temp-ext-file-line .

        find first buf_reportShift no-lock where 
            buf_reportShift.obj-code  = int(oldbh:buffer-field( "obj-code":U  ):buffer-value )
            and buf_reportShift.obj-type = oldbh:buffer-field( "obj-type":U  ):buffer-value 
            and buf_reportShift.shift-date = date(oldbh:buffer-field( "shift-date":U  ):buffer-value )
            and buf_reportShift.shift-num  = int(oldbh:buffer-field( "shift-num":U  ):buffer-value ) 
            and buf_reportShift.report-type  = int(oldbh:buffer-field( "report-type":U  ):buffer-value ) no-error .

        sendOldRowid = rowid(buf_reportShift) .
        if search(buf_reportShift.report-html) <> ? then 
        do:
   
            binfile_read(input  0
                ,input  1
                ,input  1
                ,input  buf_reportShift.report-html
                ) .
            
            for each buf_temp-ext-file-line
                where buf_temp-ext-file-line.db-num   = 0
                and buf_temp-ext-file-line.from-db-num = 1
                and buf_temp-ext-file-line.file-num = 1
                on error undo, return error return-value
                :
                report-html = report-html + buf_temp-ext-file-line.line-text .
            end.
        end.
        if search(buf_reportShift.report-json) <> ? then 
        do:
            binfile_read(input  0
                ,input  1
                ,input  1
                ,input  buf_reportShift.report-json
                ) .
            
            for each buf_temp-ext-file-line
                where buf_temp-ext-file-line.db-num   = 0
                and buf_temp-ext-file-line.from-db-num = 1
                and buf_temp-ext-file-line.file-num = 1
                on error undo, return error return-value
                :
                report-json = report-json + buf_temp-ext-file-line.line-text .
            end.
        end.
                
        insw:start-element ("TH-report") .    
        insw:write-data-element (  "id":U,   string(buf_reportShift.id)    ).
        insw:write-data-element (  "generation":U,   iso-date (datetime (buf_reportShift.date, buf_reportShift.time_ * 1000)) ).
        insw:write-data-element (  "shift-date":U, iso-date(buf_reportShift.shift-date) ) .
        insw:write-data-element (  "shift-num":U,   string(buf_reportShift.shift-num)    ).
        insw:write-data-element (  "shift-number":U,   string(buf_reportShift.shift-name)    ).
        insw:write-data-element (  "type":U,   string(buf_reportShift.report-type)    ).
        insw:write-data-element (  "operator":U,  string(buf_reportShift.fio) ).
        insw:write-data-element (  "id-user":U,   entry(2,buf_reportShift.user-id,"-")  ).
        insw:write-data-element (  "report-html":U,  report-html ).
        insw:write-data-element (  "report-json":U,  report-json ).
        insw:end-element ("TH-report") .
        
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
