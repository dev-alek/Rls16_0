 
 /*------------------------------------------------------------------------
    File        : ReportXsltUtil
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : VKharitonov
    Created     : Mon Aug 20 11:37:00 MSD 2012
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
using ibs.th.gbl.*.
block-level on error undo, throw.



CLASS ibs.th.gbl.ReportXsltUtil: 

def var v-temp-file         as char             no-undo.
def var v-main-template     as char             no-undo.
def var v-rep-gen           as class ReportXml  no-undo.
def var v-rep-num           as int              no-undo.
def var v-rep-section-open  as logical          no-undo.
def var v-cur-template      as char initial ""  no-undo.

def stream cfg-stream.

def temp-table tmp#xslt no-undo
field template-name as char
field data-prefix as char
.

def buffer buf_tmp#xslt for tmp#xslt.

constructor public ReportXsltUtil(temp-file as char):
    v-temp-file = temp-file.
    v-main-template = search("exe\xslt-excel-main-template.xml").
    v-rep-gen = new ReportXml(v-temp-file + ".xslt-data").
end.

method public ReportXml get-data-generator():
    return v-rep-gen.
end.

method public void set-current-template(template-file-name as char):
    v-cur-template = template-file-name.
end.

method char get-cur-tag-name():
    return "rep" + string(v-rep-num).
end.

method public void begin-report():
    end-report().
    v-rep-num = v-rep-num + 1.
    v-rep-gen:start-element(get-cur-tag-name()).
    v-rep-section-open = true.
end.

method public void end-report():
    if v-rep-section-open then
        do:
            v-rep-gen:end-element(get-cur-tag-name()).
            v-rep-section-open = false.
            
            if v-cur-template <> ""  then
                do:
                    create buf_tmp#xslt.
                    assign
                        buf_tmp#xslt.template-name = search(v-cur-template)
                        buf_tmp#xslt.data-prefix = "Workbook/" + get-cur-tag-name()
                        .
                    v-cur-template = "".
                end.
        end.
end.

method public void write-config():
    def var path as char no-undo.
    path = v-temp-file + ".xslt-cfg".
    output stream cfg-stream to value(path).
    
    put stream cfg-stream unformatted "init=excel,null" skip.
    put stream cfg-stream unformatted "main_template=" v-main-template skip.
        
    for each buf_tmp#xslt:
        put stream cfg-stream unformatted
            "merge_file="
            buf_tmp#xslt.template-name
            ","
            buf_tmp#xslt.data-prefix
            skip.
    end.
    
    put stream cfg-stream unformatted "merge_to=" v-temp-file ".xslt-merged" skip.
    put stream cfg-stream unformatted
        "transform_to="
        v-temp-file ".xslt-data"
        ","
        v-temp-file ".xslt-res"
        skip.
    
    output stream cfg-stream close.
end.

destructor public ReportXsltUtil():
    end-report().
       
    delete object v-rep-gen.
end.

END CLASS.