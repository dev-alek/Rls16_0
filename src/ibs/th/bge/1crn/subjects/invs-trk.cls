
/*

$Revision: 76575567272c, 2782, rls $
$Author: ASMorozov $
$Date: Чт апр 08 19:52:17 2021 +0300 $
$Workfile: invs-trk.cls $
$Archive: ibs/th/bge/1crn/subjects/invs-trk.cls $

Экспорт сообщения с накладаной в 1С ERPRN invs-trk

Автор: Елена Шкляр
Дата создания: 26/09/17
Author: Shklyar Elena
Creation date: 26/09/17

*/

using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
block-level on error undo, throw.

class ibs.th.bge.1crn.subjects.invs-trk implements iexpsubject:

  { cmp/str-glbl.i class }
  
  define buffer buf_icnt-doc  for ub.icnt-doc .
  define buffer buf_icnt-line for ub.icnt-line .
  
  define property Msg as character no-undo
    get.
    private set.

  define property DocCode as character no-undo
    get.
    set.
    
  define property InitSecTag as character no-undo init "invs-trk"
    get.
    private set.

  define property sendTableName  as character  no-undo init "icnt-doc"
  get.
   
  define property sendOldRowid as rowid  no-undo
  get.
  set.

  define property sendNewRowid as rowid  no-undo
  get.
  set.

  define variable sw as handle no-undo.
  
  method public void CrContentToSW (insw as handle):
    
    sw = insw .

    find first buf_icnt-doc no-lock where buf_icnt-doc.doc-code = DocCode no-error.
    if not available (buf_icnt-doc)
      then return.
          
    sendOldRowid = rowid(buf_icnt-doc).
    /*    sw:start-element ("invs-trk") .*/
    sw:start-element ("inv-trk") .
    sw:write-data-element ("doc-num", if buf_icnt-doc.doc-code = ? then "" else string(buf_icnt-doc.doc-code)).
    sw:write-data-element ("doc-code", if buf_icnt-doc.doc-code = ? then "" else string(buf_icnt-doc.doc-code)).
    sw:write-data-element ("date", if buf_icnt-doc.doc-date = ? then "" else ISO-DATE(buf_icnt-doc.doc-date)).
    sw:write-data-element ("shift-date", if buf_icnt-doc.shift-date = ? then "" else ISO-DATE (buf_icnt-doc.shift-date)).
    sw:write-data-element ("shift-num", if buf_icnt-doc.shift-num = ? then "0" else string(buf_icnt-doc.shift-num)).
    sw:write-data-element ("operator", if buf_icnt-doc.creid = ? then "" else pr-objname(buf_icnt-doc.creid)).
    sw:start-element ("trk-inds") .
    for each buf_icnt-line no-lock where buf_icnt-line.doc-code = buf_icnt-doc.doc-code:
      sw:start-element ("trk-ind") .
      sw:write-data-element ("gd-code"  , string-mth(buf_icnt-line.gds-code)).
      sw:write-data-element ("trk-num" , string-mth(buf_icnt-line.pump-code)).
      sw:write-data-element ("trk-pnum" , string-mth(buf_icnt-line.nozzle-code)).
      sw:write-data-element ("ind-el" , string-mth(buf_icnt-line.state-el-cnt)).
      sw:write-data-element ("ind-meh" , string-mth(buf_icnt-line.state-mh-cnt)).
      sw:write-data-element ("dif" , string-mth(buf_icnt-line.state-el-cnt - buf_icnt-line.state-mh-cnt)).
      sw:write-data-element ("ind-auto" , string-mth(if buf_icnt-line.meas-el-cnt = ? then 0 else buf_icnt-line.meas-el-cnt)).
      sw:end-element ("trk-ind")  .  
    end.
    sw:end-element ("trk-inds")  .  
    sw:END-ELEMENT ("inv-trk") .  
  end.  
  method private character string-mth (inValue as decimal):
    
    def var v-str as character no-undo.
    def var v-stt as decimal   no-undo.
     
    if inValue = ?  then v-str = "0".
    if inValue < 0 then 
    do:
      v-stt = inValue .
      inValue = ABSOLUTE(v-stt).
    end.
    if string (inValue) begins "."
      then v-str = "0" + string (inValue).
    else v-str = string (inValue).
    if v-stt <> 0 then v-str = "-" + v-str.
    return v-str.
    
  end.
  
    method private character pr-objname (inValue as character):
    
        define variable v-obj-name as character no-undo .

            find first ub.user-account NO-LOCK where ub.user-account.user-id = inValue no-error .
            if AVAILABLE (ub.user-account) then do:
                v-obj-name = ub.user-account.last-name + " " + (if ub.user-account.first-name <> "" then SUBSTRING (ub.user-account.first-name,1,1) + "." else "") + (if ub.user-account.second-name <> "" then SUBSTRING (ub.user-account.second-name,1,1) + "." else "").
            end.    
            
       RETURN v-obj-name.
    
    end.  

end class.