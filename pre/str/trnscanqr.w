using ibs.th.str.ptrl.autotrn.*.
using ibs.th.str.*.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сканирование 2D кода. Автоматическое заполнение накладной.".
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
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define input  parameter parparentproc         as handle              no-undo .
define input  parameter p-doc-code            as character           no-undo .
define input  parameter p-mode                as character           no-undo .
define input  parameter p-handle              as handle              no-undo .
define variable iLang           as integer   no-undo.
define variable p-value-logical as logical no-undo.
define variable p-value-character  as character no-undo.
define variable p-value-date       as date no-undo.
define variable p-value-decimal    as decimal no-undo.
define variable p-value-integer    as integer no-undo.
define variable p-param-type       as character no-undo.
define variable v-tth as handle no-undo .
define variable par-type          as character no-undo .
define variable v-value-char      as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable qr-scan-time      as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define buffer t_doc        for ub.trn-doc .
define buffer bf_doc-line  for ub.doc-line.
define variable v-timedelay  as integer   no-undo.
define variable v-scan-str as character no-undo.
define stream str-err .
define stream in-stream.
FUNCTION BinaryXOR RETURNS INT64(INPUT intOperand1 AS INT64,
                                 INPUT intOperand2 AS INT64)
                                 forward .
FUNCTION ShiftRight RETURNS INT64(INPUT in_Operand_A AS INT64,
                                  INPUT in_Operand_B AS INTEGER)
                                  forward .
FUNCTION BinaryAND RETURNS INTEGER (INPUT in_Operand_A AS INT64,
                                    INPUT in_Operand_B AS INT64)
                                    forward .
FUNCTION intToHex RETURNS CHARACTER (i_iint AS INT64) forward .
FUNCTION crc32Table RETURNS INT64 EXTENT 256  () forward .
FUNCTION CRC32 RETURNS INT64 (INPUT mpData AS MEMPTR) forward .
FUNCTION BinaryXOR RETURNS INT64
(INPUT intOperand1 AS INT64,
 INPUT intOperand2 AS INT64):
    DEFINE VARIABLE iByteLoop  AS INTEGER NO-UNDO.
    DEFINE VARIABLE iXOResult  AS INT64 NO-UNDO.
    DEFINE VARIABLE lFirstBit  AS LOGICAL NO-UNDO.
    DEFINE VARIABLE lSecondBit AS LOGICAL NO-UNDO.
    iXOResult = 0.
    DO iByteLoop = 1 TO 64:
        ASSIGN
        lFirstBit  = LOGICAL(GET-BITS(intOperand1,iByteLoop  ,1))
        lSecondBit = LOGICAL(GET-BITS(intOperand2,iByteLoop , 1)).
        IF (lFirstBit  AND NOT lSecondBit) OR
           (lSecondBit AND NOT lFirstBit) THEN
            iXOResult = iXOResult + EXP(2, iByteLoop - 1).
    END.
    RETURN iXOResult.
END .
FUNCTION ShiftRight RETURNS INT64
(INPUT in_Operand_A AS INT64,
 INPUT in_Operand_B AS INTEGER):
   RETURN INT64( TRUNCATE( in_Operand_A / EXP(2,in_Operand_B), 0 ) ).
END .
FUNCTION BinaryAND RETURNS INTEGER
(INPUT in_Operand_A AS INT64,
 INPUT in_Operand_B AS INT64):
   DEFINE VARIABLE in_cbit     AS INTEGER     NO-UNDO.
   DEFINE VARIABLE in_result   AS INT64     NO-UNDO.
   DO in_cbit = 1 TO 64:
      IF LOGICAL( GET-BITS( in_Operand_A, in_cbit, 1 ) ) AND
         LOGICAL( GET-BITS( in_Operand_B, in_cbit, 1 ) )
      THEN
         PUT-BITS( in_result, in_cbit, 1 ) = 1.
  END.
  RETURN in_result.
END .
FUNCTION intToHex RETURNS CHARACTER
(i_iint AS INT64):
   DEF VAR chex  AS CHAR NO-UNDO.
   DEF VAR rbyte AS RAW  NO-UNDO.
   DO WHILE i_iint > 0:
      PUT-BYTE( rbyte, 1 ) = i_iint MODULO 256.
      chex = STRING( HEX-ENCODE( rbyte ) ) + chex.
      i_iint = TRUNCATE( i_iint / 256, 0 ).
   END.
   RETURN chex.
END .
FUNCTION crc32Table RETURNS INT64 EXTENT 256
():
    DEFINE VARIABLE crc32_tab       AS INT64     NO-UNDO EXTENT 256 INITIAL
        [0x00000000, 0x77073096, 0xEE0E612C, 0x990951BA, 0x076DC419, 0x706AF48F,
        0xE963A535, 0x9E6495A3, 0x0EDB8832, 0x79DCB8A4, 0xE0D5E91E, 0x97D2D988,
        0x09B64C2B, 0x7EB17CBD, 0xE7B82D07, 0x90BF1D91, 0x1DB71064, 0x6AB020F2,
        0xF3B97148, 0x84BE41DE, 0x1ADAD47D, 0x6DDDE4EB, 0xF4D4B551, 0x83D385C7,
        0x136C9856, 0x646BA8C0, 0xFD62F97A, 0x8A65C9EC, 0x14015C4F, 0x63066CD9,
        0xFA0F3D63, 0x8D080DF5, 0x3B6E20C8, 0x4C69105E, 0xD56041E4, 0xA2677172,
        0x3C03E4D1, 0x4B04D447, 0xD20D85FD, 0xA50AB56B, 0x35B5A8FA, 0x42B2986C,
        0xDBBBC9D6, 0xACBCF940, 0x32D86CE3, 0x45DF5C75, 0xDCD60DCF, 0xABD13D59,
        0x26D930AC, 0x51DE003A, 0xC8D75180, 0xBFD06116, 0x21B4F4B5, 0x56B3C423,
        0xCFBA9599, 0xB8BDA50F, 0x2802B89E, 0x5F058808, 0xC60CD9B2, 0xB10BE924,
        0x2F6F7C87, 0x58684C11, 0xC1611DAB, 0xB6662D3D, 0x76DC4190, 0x01DB7106,
        0x98D220BC, 0xEFD5102A, 0x71B18589, 0x06B6B51F, 0x9FBFE4A5, 0xE8B8D433,
        0x7807C9A2, 0x0F00F934, 0x9609A88E, 0xE10E9818, 0x7F6A0DBB, 0x086D3D2D,
        0x91646C97, 0xE6635C01, 0x6B6B51F4, 0x1C6C6162, 0x856530D8, 0xF262004E,
        0x6C0695ED, 0x1B01A57B, 0x8208F4C1, 0xF50FC457, 0x65B0D9C6, 0x12B7E950,
        0x8BBEB8EA, 0xFCB9887C, 0x62DD1DDF, 0x15DA2D49, 0x8CD37CF3, 0xFBD44C65,
        0x4DB26158, 0x3AB551CE, 0xA3BC0074, 0xD4BB30E2, 0x4ADFA541, 0x3DD895D7,
        0xA4D1C46D, 0xD3D6F4FB, 0x4369E96A, 0x346ED9FC, 0xAD678846, 0xDA60B8D0,
        0x44042D73, 0x33031DE5, 0xAA0A4C5F, 0xDD0D7CC9, 0x5005713C, 0x270241AA,
        0xBE0B1010, 0xC90C2086, 0x5768B525, 0x206F85B3, 0xB966D409, 0xCE61E49F,
        0x5EDEF90E, 0x29D9C998, 0xB0D09822, 0xC7D7A8B4, 0x59B33D17, 0x2EB40D81,
        0xB7BD5C3B, 0xC0BA6CAD, 0xEDB88320, 0x9ABFB3B6, 0x03B6E20C, 0x74B1D29A,
        0xEAD54739, 0x9DD277AF, 0x04DB2615, 0x73DC1683, 0xE3630B12, 0x94643B84,
        0x0D6D6A3E, 0x7A6A5AA8, 0xE40ECF0B, 0x9309FF9D, 0x0A00AE27, 0x7D079EB1,
        0xF00F9344, 0x8708A3D2, 0x1E01F268, 0x6906C2FE, 0xF762575D, 0x806567CB,
        0x196C3671, 0x6E6B06E7, 0xFED41B76, 0x89D32BE0, 0x10DA7A5A, 0x67DD4ACC,
        0xF9B9DF6F, 0x8EBEEFF9, 0x17B7BE43, 0x60B08ED5, 0xD6D6A3E8, 0xA1D1937E,
        0x38D8C2C4, 0x4FDFF252, 0xD1BB67F1, 0xA6BC5767, 0x3FB506DD, 0x48B2364B,
        0xD80D2BDA, 0xAF0A1B4C, 0x36034AF6, 0x41047A60, 0xDF60EFC3, 0xA867DF55,
        0x316E8EEF, 0x4669BE79, 0xCB61B38C, 0xBC66831A, 0x256FD2A0, 0x5268E236,
        0xCC0C7795, 0xBB0B4703, 0x220216B9, 0x5505262F, 0xC5BA3BBE, 0xB2BD0B28,
        0x2BB45A92, 0x5CB36A04, 0xC2D7FFA7, 0xB5D0CF31, 0x2CD99E8B, 0x5BDEAE1D,
        0x9B64C2B0, 0xEC63F226, 0x756AA39C, 0x026D930A, 0x9C0906A9, 0xEB0E363F,
        0x72076785, 0x05005713, 0x95BF4A82, 0xE2B87A14, 0x7BB12BAE, 0x0CB61B38,
        0x92D28E9B, 0xE5D5BE0D, 0x7CDCEFB7, 0x0BDBDF21, 0x86D3D2D4, 0xF1D4E242,
        0x68DDB3F8, 0x1FDA836E, 0x81BE16CD, 0xF6B9265B, 0x6FB077E1, 0x18B74777,
        0x88085AE6, 0xFF0F6A70, 0x66063BCA, 0x11010B5C, 0x8F659EFF, 0xF862AE69,
        0x616BFFD3, 0x166CCF45, 0xA00AE278, 0xD70DD2EE, 0x4E048354, 0x3903B3C2,
        0xA7672661, 0xD06016F7, 0x4969474D, 0x3E6E77DB, 0xAED16A4A, 0xD9D65ADC,
        0x40DF0B66, 0x37D83BF0, 0xA9BCAE53, 0xDEBB9EC5, 0x47B2CF7F, 0x30B5FFE9,
        0xBDBDF21C, 0xCABAC28A, 0x53B39330, 0x24B4A3A6, 0xBAD03605, 0xCDD70693,
        0x54DE5729, 0x23D967BF, 0xB3667A2E, 0xC4614AB8, 0x5D681B02, 0x2A6F2B94,
        0xB40BBE37, 0xC30C8EA1, 0x5A05DF1B, 0x2D02EF8D].
    RETURN crc32_tab.
END .
FUNCTION CRC32 RETURNS INT64
(INPUT mpData AS MEMPTR):
    DEFINE VARIABLE IN_BYtes_Size   AS INTEGER   NO-UNDO.
    DEFINE VARIABLE in_byte         AS INTEGER   NO-UNDO.
    DEFINE VARIABLE crc_value       AS INT64     NO-UNDO.
    DEFINE VARIABLE tmp             AS INT64     NO-UNDO.
    DEFINE VARIABLE crc32_tab       AS INT64     NO-UNDO EXTENT 256.
    DEFINE VARIABLE in_loop         AS INTEGER     NO-UNDO.
    crc32_tab = crc32Table().
    crc_value = 0xffffffff.
    In_Bytes_Size = GET-SIZE(mpData).
    DO in_loop = 1 TO In_Bytes_Size:
        tmp = BinaryXOR(crc_value, GET-BYTE(mpData,in_loop )).
        crc_value = BinaryXOR( ShiftRight(crc_value, 8), crc32_tab[BinaryAND(tmp,0x00ff) + 1 ] ).
    END.
    crc_value = BinaryXOR(crc_value, 0xffffffff).
    RETURN crc_value.
END .
define button b-exit auto-go
     label "&Отмена"
     size 10 by 1
     bgcolor 8 .
define variable v-sts as character format "X(256)":U init "ожидание сканирования"
     label "Статус"
     view-as fill-in
     size 76 by 1 no-undo.
DEFINE VARIABLE v-mark AS CHARACTER FORMAT "X(31000)":U
  LABEL "Марка"
  VIEW-AS FILL-IN
  SIZE 76 BY 1
  BGCOLOR 15 NO-UNDO.
define frame Dialog-Frame
     b-exit at row 1 col 1
     v-mark at row 2.3 col 5 no-label
     v-sts at row 3.5 col 7.5 colon-aligned
     space(2) skip(0.1)
    with view-as dialog-box keep-tab-order
         side-labels no-underline three-d  scrollable
         title "Сканирование 2D кода. Автоматическое заполнение накладной."
         default-button b-exit .
assign
       frame Dialog-Frame:SCROLLABLE       = false
       frame Dialog-Frame:HIDDEN           = true.
on window-close of frame Dialog-Frame
do:
  APPLY "END-ERROR":U TO SELF.
end.
on return of b-exit in frame Dialog-Frame
do:
  run save_update .
end.
on entry of v-sts in frame Dialog-Frame
do:
  run LoadKeyboardLayoutA (input "00000419", input 0, output iLang).
      run adm/shattri.p (
               input "get":U
               ,input  v-cntxt-obj-type
               ,input  v-cntxt-obj-code
               ,input  'marking':U
               ,input  'rus-key':U
               ,output p-value-character
               ,output p-value-date
               ,output p-value-decimal
               ,output p-value-integer
               ,output p-value-logical
               ,output p-param-type
               ,input-output table-handle v-tth
               ) no-error .
      IF p-value-logical = yes THEN  iLang = 68748313.
  run ActivateKeyboardLayout (input iLang, input 0).
end.
on any-printable of v-mark in frame Dialog-Frame
do:
  run proc-any-key.
end.
on return of v-mark in frame Dialog-Frame
do:
  run save_update .
end.
ON ENTRY OF v-mark IN FRAME Dialog-Frame
DO:
  run LoadKeyboardLayoutA (input "00000419", input 0, output iLang).
      run adm/shattri.p (
               input "get":U
               ,input  v-cntxt-obj-type
               ,input  v-cntxt-obj-code
               ,input  'marking':U
               ,input  'rus-key':U
               ,output p-value-character
               ,output p-value-date
               ,output p-value-decimal
               ,output p-value-integer
               ,output p-value-logical
               ,output p-param-type
               ,input-output table-handle v-tth
               ) no-error .
      IF p-value-logical = yes THEN  iLang = 68748313.
  run ActivateKeyboardLayout (input iLang, input 0).
END.
ON LEAVE OF v-mark IN FRAME Dialog-Frame
DO:
  assign frame Dialog-Frame v-mark .
END.
if valid-handle(active-window) and frame Dialog-Frame:PARENT eq ?
  then frame Dialog-Frame:PARENT = active-window.
MAIN-BLOCK:
do on error undo MAIN-BLOCK, leave MAIN-BLOCK
  :
  run LoadKeyboardLayoutA (input "00000419", input 0, output iLang).
      run adm/shattri.p (
               input "get":U
               ,input  v-cntxt-obj-type
               ,input  v-cntxt-obj-code
               ,input  'marking':U
               ,input  'rus-key':U
               ,output p-value-character
               ,output p-value-date
               ,output p-value-decimal
               ,output p-value-integer
               ,output p-value-logical
               ,output p-param-type
               ,input-output table-handle v-tth
               ) no-error .
      IF p-value-logical = yes THEN  iLang = 68748313.
  run ActivateKeyboardLayout (input iLang, input 0).
  run enable_UI.
  find first t_doc no-lock where t_doc.doc-code = p-doc-code no-error .
  run adm/shattri.p (
             input "get":U
            ,input  t_doc.obj-type
            ,input  t_doc.obj-code
            ,input  'petrol':U
            ,input  'qr-scan-time':U
            ,output v-value-char
            ,output v-value-date
            ,output v-value-decimal
            ,output qr-scan-time
            ,output v-value-logical
            ,output par-type
            ,input-output table-handle v-tth
            ) no-error .
  if error-status:error then do:
      if valid-handle(v-tth) then delete object v-tth.
      qr-scan-time = 5000 .
  end.
  apply "entry" to v-mark in frame Dialog-Frame.
  v-mark:READ-ONLY IN FRAME Dialog-Frame       = TRUE .
  disable v-sts with frame Dialog-Frame.
  wait-for go of frame Dialog-Frame.
end.
run disable_UI.
procedure ActivateKeyboardLayout external 'user32' :
  define input parameter P1 as long.
  define input parameter P2 as long.
end procedure.
procedure disable_UI :
  hide frame Dialog-Frame.
end procedure.
procedure dispmessage :
define input parameter p-str as character no-undo.
end procedure.
procedure enable_UI :
  display v-sts v-mark b-exit
      with frame Dialog-Frame.
  enable b-exit v-mark
      with frame Dialog-Frame.
  view frame Dialog-Frame.
end procedure.
procedure LoadKeyboardLayoutA external 'user32':
  define input  parameter P1 as char.
  define input  parameter P2 as long.
  define return parameter pret as long.
end procedure.
procedure save_update :
  define variable v-xmlfile as char no-undo .
  define variable v-ok as logical no-undo .
  define variable xmlhndlerObj as class xmlhndler no-undo .
  define variable v-tmp-int as int no-undo .
  define variable v-tmp-char as character no-undo .
  define variable v-tmp-char2 as character no-undo .
  define variable v-tmp-date as date no-undo .
  define variable v-gdsrec-list as char no-undo .
  define variable v-gd-cd as integer no-undo .
  define variable v-cli-code as character no-undo .
  define variable v-bad-symb as character no-undo .
  define variable v-json-str as character no-undo.
  define variable v-ix as integer no-undo.
  define variable v-crc as char no-undo.
  define variable ii as integer no-undo .
  define variable byte1 as character no-undo .
  define variable byte2 as character no-undo .
  define variable v-asc-symb as int64 no-undo .
  define variable mData as memptr no-undo .
  define variable tmpstr as character no-undo .
  define variable v-length as integer no-undo .
  define variable byte-size as integer no-undo .
  define variable infoSecsObj as class InfoSectionsTotal no-undo.
  define variable v-bool as logical no-undo.
  define variable v-gds-attr as character no-undo .
  define buffer buf_goods for ub.goods .
  define buffer buf_pl-gds for ub.pl-gds .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_doc-line-attr for ub.doc-line-attr .
  define buffer buf_auto-tank for ub.auto-tank .
  v-bad-symb = '!' + chr(4) + '@' + chr(4) + '#' + chr(4) + '$' + chr(4) + '%' + chr(4) + '^' + chr(4) + '&' + chr(4)
             + '*' + chr(4) + '(' + chr(4) + ')' + chr(4) + '-' + chr(4) + '_' + chr(4) + '=' + chr(4) + '+' + chr(4)
             + '.' + chr(4) + ',' + chr(4) + '/' + chr(4) + '|' + chr(4) + '\' + chr(4) + '?' + chr(4) + '"' + chr(4)
             + ';' + chr(4) + ':' + chr(4) + '[' + chr(4) + ']' + chr(4) + chr(123) + chr(4) + '}' + chr(4)
             + '`' + chr(4) + '№' + chr(4) + ' ' + chr(4) + "'" + chr(4) + "RUS" .
  if v-mark:screen-value in frame Dialog-Frame = ""
  then do:
    v-length = LENGTH(v-scan-str, 'raw').
    if v-length = 0
    then return .
    set-size(mData) = 0.
    set-size(mData) = v-length.
    PUT-STRING(mData, 1, v-length) = v-scan-str.
    byte-size = GET-SIZE(mData).
    DO ii = 1 TO byte-size:
      v-asc-symb = GET-BYTE(mData, ii).
      byte1 = intToHex(v-asc-symb) .
      if byte2 = "d0" and byte1 = "3f"
      then do :
        tmpstr = substring(tmpstr, 1, length(tmpstr) - 1) no-error .
        tmpstr = tmpstr + CHR(38) + CHR(36) no-error .
      end .
      else do :
        tmpstr = tmpstr + CHR(v-asc-symb) no-error .
      end .
      byte2 = intToHex(v-asc-symb) .
    END.
    set-size(mData) = 0.
    tmpstr = codepage-convert(tmpstr, "1251", "UTF-8") .
    tmpstr = replace(tmpstr, "&$", "И") .
    v-mark:screen-value in frame Dialog-Frame = tmpstr .
    v-scan-str = "".
  end.
  v-json-str = v-mark:screen-value .
  v-scan-str = "".
  if trim(v-json-str) = ""
  then do :
    v-mark:screen-value = "" .
    v-scan-str = "".
    v-mark = "".
    message "Ошибка сканирования! Попробуйте увеличить время на сканирование QR-кода в настройках по топливу." view-as alert-box .
    v-sts:screen-value in frame Dialog-Frame = "ожидание сканирования" .
    return .
  end .
  if v-json-str begins (CHR(123) + "@data@^")
  then do :
    v-mark:screen-value = "" .
    v-scan-str = "".
    v-mark = "".
    message "Ошибка сканирования!" skip "Убедитесь, что установлена русская раскладка клавиатуры." view-as alert-box .
    v-sts:screen-value in frame Dialog-Frame = "ожидание сканирования" .
    return .
  end .
  v-ix = index (v-json-str, ',"CRC":"').
  v-crc = substring (v-json-str, v-ix + 8, 8).
  v-json-str = substring (v-json-str, 9, v-ix - 9).
  v-json-str = codepage-convert(v-json-str, "UTF-8", "1251") .
  run checkcrc (input v-json-str, input v-crc, output v-ok).
  if not v-ok
  then do:
    v-mark:screen-value = "" .
    v-scan-str = "".
    v-mark = "".
    message "Контрольная сумма не соответствует содержанию штрих-кода. Повторно просканируйте код с ТТН. При возникновении проблемы обратитесь в тех. поддержку" view-as alert-box .
    v-sts:screen-value in frame Dialog-Frame = "ожидание сканирования" .
    return .
  end.
  assign v-mark = v-mark:screen-value .
  if trim(v-mark) = "" then return .
  run checkJson (input v-mark, output v-ok) .
  if not v-ok
  then do:
    v-mark:screen-value = "" .
    v-scan-str = "".
    v-mark = "".
    message "Некорректный формат штрих-кода. Повторно просканируйте код с ТТН. При возникновении проблемы обратитесь в тех. поддержку" view-as alert-box .
    v-sts:screen-value in frame Dialog-Frame = "ожидание сканирования" .
    undo, return.
  end.
  run parse2DCodeToXML (input v-mark, output v-xmlfile) no-error.
  if error-status:error
  then do:
    v-mark:screen-value = "" .
    v-scan-str = "".
    v-mark = "".
    v-sts:screen-value in frame Dialog-Frame = "ожидание сканирования" .
    undo, return.
  end.
  infoSecsObj = new ibs.th.str.InfoSectionsTotal().
  xmlhndlerObj = new xmlhndler().
  xmlhndlerObj:FillDataset(input search (v-xmlfile)) no-error.
  if error-status:error
  then do :
    v-mark:screen-value = "" .
    v-scan-str = "".
    v-mark = "".
    message xmlhndlerObj:ErrMsg view-as alert-box.
    v-sts:screen-value in frame Dialog-Frame = "ожидание сканирования" .
    undo, return error .
  end .
  v-ok = xmlhndlerObj:GetFirst("doc") no-error.
  if not v-ok
  then do :
    v-mark:screen-value = "" .
    v-scan-str = "".
    v-mark = "".
    message xmlhndlerObj:ErrMsg view-as alert-box.
    v-sts:screen-value in frame Dialog-Frame = "ожидание сканирования" .
    undo, return error .
  end .
  v-cli-code =  (xmlhndlerObj:vbf:buffer-field("contr-cd"):buffer-value) no-error.
  if error-status:error
  then do :
    v-mark:screen-value = "" .
    v-scan-str = "".
    v-mark = "".
    message error-status:get-message (1) view-as alert-box.
    v-sts:screen-value in frame Dialog-Frame = "ожидание сканирования" .
    undo, return error .
  end .
  else do:
    v-tmp-int = integer(v-cli-code) no-error .
    for first ub.clients-attr no-lock where ub.clients-attr.obj-type = 'орг':U
                                        and ub.clients-attr.attr-code = 'code-KSK':U
                                        and (ub.clients-attr.attr-value = v-cli-code
                                        or ub.clients-attr.attr-value = string(v-tmp-int))
                                        :
      v-tmp-int = ub.clients-attr.obj-code .
    end .
    if v-tmp-int = 0
    or v-tmp-int = ?
    then do :
      v-mark:screen-value = "" .
      v-scan-str = "".
      v-mark = "".
      message "Ошибка установки поставщика. Не найден поставщик с кодом " v-cli-code ". Для внесения в систему данных обратитесь к ответственному сотруднику регионального офиса" skip return-value view-as alert-box.
      v-sts:screen-value in frame Dialog-Frame = "ожидание сканирования" .
      undo, return error .
    end .
    find first ub.clients no-lock where ub.clients.obj-type = 'орг':U
                                    and ub.clients.obj-code = v-tmp-int
                                    no-error .
    if not available ub.clients
    then do :
      v-mark:screen-value = "" .
      v-scan-str = "".
      v-mark = "".
      message "Отсутствует поставщик с кодом " v-cli-code ". Для внесения в систему данных обратитесь к ответственному сотруднику регионального офиса" view-as alert-box.
      v-sts:screen-value in frame Dialog-Frame = "ожидание сканирования" .
      undo, return error .
    end .
    else do :
      if ub.clients.stts <> 0
      then do :
        v-mark:screen-value = "" .
        v-scan-str = "".
        v-mark = "".
        message "Поставщик с кодом " v-cli-code " неактивный (Удалён). Для внесения в систему данных обратитесь к ответственному сотруднику регионального офиса"  view-as alert-box.
        v-sts:screen-value in frame Dialog-Frame = "ожидание сканирования" .
        undo, return error .
      end .
      run set-cli-cust in p-handle (input 'орг':U, input v-tmp-int) no-error.
    end .
  end.
  v-tmp-char =  (xmlhndlerObj:vbf:buffer-field("doc-num"):buffer-value) no-error.
  if error-status:error
  then do :
    v-mark:screen-value = "" .
    v-scan-str = "".
    v-mark = "".
    message error-status:get-message (1) view-as alert-box.
    v-sts:screen-value in frame Dialog-Frame = "ожидание сканирования" .
    undo, return error .
  end .
  else do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t_doc.doc-code ,
                       input 'nids':U ,
                       input v-tmp-char ) no-error .
  end.
  v-tmp-char =  (xmlhndlerObj:vbf:buffer-field("doc-date"):buffer-value) no-error.
  if error-status:error
  then do :
    v-mark:screen-value = "" .
    v-scan-str = "".
    v-mark = "".
    message error-status:get-message (1) view-as alert-box.
    v-sts:screen-value in frame Dialog-Frame = "ожидание сканирования" .
    undo, return error .
  end .
  else do:
    if trim(v-tmp-char) = ""
    then do :
      v-mark:screen-value = "" .
      v-scan-str = "".
      v-mark = "".
      message "В накладной не указана дата документа. Для внесения в систему данных обратитесь к ответственному сотруднику регионального офиса"  view-as alert-box.
      v-sts:screen-value in frame Dialog-Frame = "ожидание сканирования" .
      undo, return error .
    end .
    v-tmp-date = date( entry(3, v-tmp-char, "-") + "/" + entry(2, v-tmp-char, "-") + "/" + entry(1, v-tmp-char, "-") ) no-error .
    if v-tmp-date = ?
    then do :
      v-mark:screen-value = "" .
      v-scan-str = "".
      v-mark = "".
      message "В накладной неверно указана дата документа. Для внесения в систему данных обратитесь к ответственному сотруднику регионального офиса"  view-as alert-box.
      v-sts:screen-value in frame Dialog-Frame = "ожидание сканирования" .
      undo, return error .
    end .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t_doc.doc-code ,
                       input 'dids':U ,
                       input string(v-tmp-date) ) no-error .
  end.
  v-ok = xmlhndlerObj:GetFirst("transp") no-error.
  if not v-ok
  then do :
    v-mark:screen-value = "" .
    v-scan-str = "".
    v-mark = "".
    message xmlhndlerObj:ErrMsg view-as alert-box.
    v-sts:screen-value in frame Dialog-Frame = "ожидание сканирования" .
    undo, return error .
  end .
  v-cli-code =  (xmlhndlerObj:vbf:buffer-field("nb-cd"):buffer-value) no-error.
  if error-status:error
  then do :
    v-mark:screen-value = "" .
    v-scan-str = "".
    v-mark = "".
    message error-status:get-message (1) view-as alert-box.
    v-sts:screen-value in frame Dialog-Frame = "ожидание сканирования" .
    undo, return error .
  end .
  else do:
    v-tmp-int = integer(v-cli-code) no-error .
    for first ub.clients-attr no-lock where ub.clients-attr.obj-type = 'орг':U
                                        and ub.clients-attr.attr-code = 'code-AIS':U
                                        and (ub.clients-attr.attr-value = v-cli-code
                                        or ub.clients-attr.attr-value = string(v-tmp-int))
                                        :
      v-tmp-int = ub.clients-attr.obj-code .
    end .
    find first ub.clients no-lock where ub.clients.obj-type = 'орг':U
                                    and ub.clients.obj-code = v-tmp-int
                                    no-error .
    if not available ub.clients
    then do :
      v-mark:screen-value = "" .
      v-scan-str = "".
      v-mark = "".
      message "Отсутствует нефтебаза с кодом " v-cli-code ". Для внесения в систему данных обратитесь к ответственному сотруднику регионального офиса"  view-as alert-box.
      v-sts:screen-value in frame Dialog-Frame = "ожидание сканирования" .
      undo, return error .
    end .
    else do :
      if ub.clients.stts <> 0
      then do :
        v-mark:screen-value = "" .
        v-scan-str = "".
        v-mark = "".
        message "Нефтебаза с кодом " v-cli-code " неактивна (Удалена). Для внесения в систему данных обратитесь к ответственному сотруднику регионального офиса"  view-as alert-box.
        v-sts:screen-value in frame Dialog-Frame = "ожидание сканирования" .
        undo, return error .
      end .
      v-tmp-char = 'орг':U + ";" + string(v-tmp-int) .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t_doc.doc-code ,
                       input 'ptbobj':U ,
                       input v-tmp-char ) no-error .
    end .
  end.
  define variable v-auto-num as character no-undo .
  define variable v-found-trans as logical no-undo .
  v-tmp-char =  (xmlhndlerObj:vbf:buffer-field("transp-num"):buffer-value) no-error.
  if error-status:error
  then do :
    v-mark:screen-value = "" .
    v-scan-str = "".
    v-mark = "".
    message error-status:get-message (1) view-as alert-box.
    v-sts:screen-value in frame Dialog-Frame = "ожидание сканирования" .
    undo, return error .
  end .
  else do:
    do ii = 1 to num-entries(v-bad-symb, chr(4)) :
      v-tmp-char = replace(v-tmp-char, entry(ii, v-bad-symb, chr(4)), "") .
    end .
    v-found-trans = no .
    for each ub.auto-tank no-lock where ub.auto-tank.status_ = 'тек':U :
      v-auto-num = ub.auto-tank.auto-num .
      do ii = 1 to num-entries(v-bad-symb, chr(4)) :
        v-auto-num = replace(v-auto-num, entry(ii, v-bad-symb, chr(4)), "") .
      end .
      if v-auto-num = v-tmp-char
      then do :
        v-found-trans = true .
        leave .
      end .
    end .
    if not v-found-trans
    then do :
      v-mark:screen-value = "" .
      v-scan-str = "".
      v-mark = "".
      message "Отсутствует автоцистерна с гос. номером " v-tmp-char ". Для внесения в систему данных обратитесь к ответственному сотруднику регионального офиса" view-as alert-box.
      v-sts:screen-value in frame Dialog-Frame = "ожидание сканирования" .
      undo, return error .
    end .
    else do :
      infoSecsObj:CarNum = ub.auto-tank.auto-num .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t_doc.doc-code ,
                       input 'car-num':U ,
                       input ub.auto-tank.auto-num ) no-error .
      v-tmp-char2 = ub.auto-tank.firm-type + ";" + string(ub.auto-tank.firm-code) .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t_doc.doc-code ,
                       input 'autoent':U ,
                       input v-tmp-char2 ) no-error .
    end .
  end.
  v-tmp-char =  (xmlhndlerObj:vbf:buffer-field("driv"):buffer-value) no-error.
  if error-status:error
  then do :
    v-mark:screen-value = "" .
    v-scan-str = "".
    v-mark = "".
    message error-status:get-message (1) view-as alert-box.
    v-sts:screen-value in frame Dialog-Frame = "ожидание сканирования" .
    undo, return error .
  end .
  else do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t_doc.doc-code ,
                       input 'fio-driver':U ,
                       input v-tmp-char ) no-error .
  end.
  v-tmp-char =  (xmlhndlerObj:vbf:buffer-field("pl-num"):buffer-value) no-error.
  if error-status:error
  then do :
    v-mark:screen-value = "" .
    v-scan-str = "".
    v-mark = "".
    message error-status:get-message (1) view-as alert-box.
    v-sts:screen-value in frame Dialog-Frame = "ожидание сканирования" .
    undo, return error .
  end .
  else do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t_doc.doc-code ,
                       input 'seals-condition':U ,
                       input v-tmp-char ) no-error .
  end.
  v-ok = xmlhndlerObj:GetFirst("scs") no-error.
  if not v-ok
  then do :
    v-mark:screen-value = "" .
    v-scan-str = "".
    v-mark = "".
    message xmlhndlerObj:ErrMsg view-as alert-box.
    v-sts:screen-value in frame Dialog-Frame = "ожидание сканирования" .
    undo, return error .
  end .
  rep_:
  repeat:
    if available ub.auto-tank
    then do :
      find first ub.auto-section no-lock where ub.auto-section.auto-num = ub.auto-tank.auto-num
                                           and ub.auto-section.section-num = xmlhndlerObj:vbf:buffer-field("sc-num"):buffer-value
                                           no-error .
      if not available ub.auto-section
      then do :
        v-mark:screen-value = "" .
        v-scan-str = "".
        v-mark = "".
        message "Для автоцистерны с номером " ub.auto-tank.auto-num " не найдена секция " xmlhndlerObj:vbf:buffer-field("sc-num"):buffer-value ". Для внесения в систему данных обратитесь к ответственному сотруднику регионального офиса" view-as alert-box title "Ошибка".
        if not xmlhndlerObj:GetNext()
          then leave rep_.
        next rep_.
      end .
    end .
    v-gd-cd = xmlhndlerObj:vbf:buffer-field("gd-cd"):buffer-value no-error.
    if error-status:error
    then do:
      v-mark:screen-value = "" .
      v-scan-str = "".
      v-mark = "".
      message error-status:get-message (1) view-as alert-box.
      v-sts:screen-value in frame Dialog-Frame = "ожидание сканирования" .
      if not xmlhndlerObj:GetNext()
        then leave rep_.
      next rep_.
    end.
    else do:
      v-tmp-int = v-gd-cd .
      v-tmp-char = "" .
      for each ub.goods-attr no-lock where ub.goods-attr.attr-code = 'gds-code-AIS':U
                                       and trim(ub.goods-attr.attr-value) > ""
                                       :
        v-gds-attr = replace(ub.goods-attr.attr-value, " ", "") .
        if lookup(string(v-gd-cd), v-gds-attr) > 0
        then do :
          v-tmp-char = v-tmp-char + string(ub.goods-attr.gds-code) + "," .
          v-tmp-int = ub.goods-attr.gds-code .
        end .
      end .
      v-tmp-char = trim(v-tmp-char, ",") .
      if num-entries(v-tmp-char) > 1
      then do :
        message "Коду топлива " string(v-gd-cd) " соответствуют несколько товаров TH." skip "Выберите  топливо по справочнику ТН,  соответствующее  топливу сливаемой секции АЦ по ТТН (секция №" xmlhndlerObj:vbf:buffer-field("sc-num"):buffer-value ")."
        view-as alert-box .
        run str\chs-gd-from-list.w (input v-tmp-char,
                                    output v-tmp-int) .
        if v-tmp-int = 0
        or v-tmp-int = ?
        then do :
          next rep_.
        end .
      end .
      find first ub.goods where ub.goods.gds-code = v-tmp-int no-lock no-error.
      if not available (ub.goods)
      then do:
        v-mark:screen-value = "" .
        v-scan-str = "".
        v-mark = "".
        message "Для секции ТТН № " xmlhndlerObj:vbf:buffer-field("sc-num"):buffer-value "отсутствует товар с кодом " v-gd-cd ". Для внесения в систему данных обратитесь к ответственному сотруднику регионального офиса" view-as alert-box title "Ошибка".
        if not xmlhndlerObj:GetNext()
          then leave rep_.
        next rep_.
      end.
      find first ub.pl-gds no-lock where ub.pl-gds.obj-type   = t_doc.obj-type
                                     and ub.pl-gds.obj-code   = t_doc.obj-code
                                     and ub.pl-gds.gds-code   = ub.goods.gds-code
                                     no-error .
      if not available (ub.pl-gds)
      then do:
        v-mark:screen-value = "" .
        v-scan-str = "".
        v-mark = "".
        message "Для товара с кодом " v-tmp-int " не удалось определить резервуар для приема НП" ". Для внесения в систему данных обратитесь к ответственному сотруднику регионального офиса" view-as alert-box title "Ошибка".
        if not xmlhndlerObj:GetNext()
          then leave rep_.
        next rep_.
      end.
      if lookup (string (recid (ub.goods)), v-gdsrec-list) = 0
      then do:
        v-gdsrec-list = string (v-gdsrec-list) + "," + string (recid (ub.goods)).
        infoSecsObj:Initialization(t_doc.doc-code, ub.goods.gds-code).
        infoSecsObj:GetInfoSectionProp().
      end.
      else do :
        infoSecsObj:Initialization(t_doc.doc-code, ub.goods.gds-code).
        infoSecsObj:NewSection().
      end .
      infoSecsObj:InfoSectionCurr:SectionName = xmlhndlerObj:vbf:buffer-field("sc-num"):buffer-value no-error.
      infoSecsObj:InfoSectionCurr:SetCarVol(infoSecsObj:InfoSectionCurr:SectionName) .
      infoSecsObj:InfoSectionCurr:DocVolume = xmlhndlerObj:vbf:buffer-field("vol"):buffer-value no-error.
      infoSecsObj:InfoSectionCurr:CliQnty = xmlhndlerObj:vbf:buffer-field("mass"):buffer-value no-error.
      infoSecsObj:InfoSectionCurr:DocDensity = xmlhndlerObj:vbf:buffer-field("dens"):buffer-value / 1000 no-error.
      infoSecsObj:InfoSectionCurr:DocQnty = infoSecsObj:InfoSectionCurr:CliQnty / infoSecsObj:InfoSectionCurr:DocDensity .
      infoSecsObj:InfoSectionCurr:TTNTemp = xmlhndlerObj:vbf:buffer-field("temp"):buffer-value no-error.
      v-tmp-int = xmlhndlerObj:vbf:buffer-field("gd-gr"):buffer-value no-error.
      if not error-status:error
      then do :
        case v-tmp-int:
          when 1 then infoSecsObj:InfoSectionCurr:GroupNP = "I" .
          when 2 then infoSecsObj:InfoSectionCurr:GroupNP = "II" .
          when 3 then infoSecsObj:InfoSectionCurr:GroupNP = "III" .
          when 4 then infoSecsObj:InfoSectionCurr:GroupNP = "IV" .
          otherwise infoSecsObj:InfoSectionCurr:GroupNP = "" .
        end case .
      end .
      v-tmp-int = xmlhndlerObj:vbf:buffer-field("fill-type"):buffer-value no-error.
      if not error-status:error
      then do :
        case v-tmp-int:
          when 0 then infoSecsObj:InfoSectionCurr:Pour = "Верхний налив" .
          when 1 then infoSecsObj:InfoSectionCurr:Pour = "Нижний налив" .
          otherwise infoSecsObj:InfoSectionCurr:Pour = "Верхний налив" .
        end case .
      end .
      infoSecsObj:InfoSectionCurr:DocDensST = xmlhndlerObj:vbf:buffer-field("dens-st"):buffer-value / 1000 no-error.
      infoSecsObj:InfoSectionCurr:AccShip = xmlhndlerObj:vbf:buffer-field("contr-err"):buffer-value no-error.
      infoSecsObj:InfoSectionCurr:PaspDens = xmlhndlerObj:vbf:buffer-field("dens-pas"):buffer-value / 1000 no-error.
      infoSecsObj:InfoSectionCurr:NumPassport = xmlhndlerObj:vbf:buffer-field("pasp"):buffer-value no-error.
      infoSecsObj:SaveDBNoCheck().
      if not xmlhndlerObj:GetNext()
        then leave rep_.
    end.
  end.
  v-gdsrec-list = left-trim (v-gdsrec-list, ",").
  v-mark:screen-value = "" .
  v-scan-str = "".
  v-mark = "".
  v-sts:screen-value in frame Dialog-Frame = "ожидание сканирования" .
  run cycle-add-cust in p-handle (input v-gdsrec-list) no-error.
  if error-status:error
    then message "Ошибка добавление товара." return-value view-as alert-box.
  v-sts:screen-value in frame Dialog-Frame  = "считано".
  for each buf_doc-line-attr exclusive-lock where buf_doc-line-attr.doc-code = t_doc.doc-code,
  first buf_goods no-lock where buf_goods.gds-code = buf_doc-line-attr.gds-code
  :
    if not can-find (first buf_doc-line no-lock where buf_doc-line.doc-code = buf_doc-line-attr.doc-code
                                                  and buf_doc-line.artic = buf_goods.artic
                                                  and buf_doc-line.prod-code = buf_goods.prod-code
                                                  and buf_doc-line.prod-type = buf_goods.prod-type)
    then do :
      delete buf_doc-line-attr .
    end .
  end .
  delete object infoSecsObj no-error .
  apply "choose" to b-exit in frame Dialog-Frame.
end procedure.
procedure parse2DCodeToXML :
  define input parameter p-2dcode as char no-undo.
  define output parameter p-xmlfile as char no-undo.
  define variable v-ok as logical no-undo .
  define variable v-json-str as character no-undo.
  define variable v-ix as integer no-undo.
  define variable v-crc as char no-undo.
  define variable cmd as char no-undo.
  v-json-str = p-2dcode.
  v-scan-str = "".
  v-ix = index (v-json-str, ',"CRC":"').
  v-crc = substring (v-json-str, v-ix + 8, 8).
  v-json-str = substring (v-json-str, 9, v-ix - 9).
  v-json-str = replace(v-json-str, '\', '\\') .
  v-json-str = replace(v-json-str, '/', '\/') .
  output to "qr2d.json" convert target 'UTF-8'.
  put unformatted v-json-str.
  output close.
  cmd = substitute ('&1 -file=&2 >&3',
                     search("exe/json2xml.exe"),
                     search("qr2d.json"),
                     "qr2d.xml"
                     ) .
  os-command silent value (cmd).
  file-info:file-name = search("qr2d.xml") .
  if file-info:file-size = 0
  then do :
    v-ok = false .
    v-sts = "oшибка при конвертации json в XML. Файл " + search("qr2d.xml") + " пустой (размер 0 байт)." .
    return error.
  end .
  p-xmlfile = search("qr2d.xml").
end.
procedure checkJson :
  define input parameter p-str as character no-undo .
  define output parameter p-ok as logical no-undo .
  define variable v-num-sec as integer no-undo .
  define variable v-tmp-str as character no-undo .
  define variable ii as integer no-undo .
  define variable v-num-teg as integer no-undo .
  p-ok = yes .
  if index(p-str, '"data"') = 0
  then do :
    p-ok = no .
    return .
  end .
  if index(p-str, '"CRC"') = 0
  then do :
    p-ok = no .
    return .
  end .
  if index(p-str, '"doc"') = 0
  then do :
    p-ok = no .
    return .
  end .
  if index(p-str, '"contr-cd"') = 0
  then do :
    p-ok = no .
    return .
  end .
  if index(p-str, '"doc-date"') = 0
  then do :
    p-ok = no .
    return .
  end .
  if index(p-str, '"doc-num"') = 0
  then do :
    p-ok = no .
    return .
  end .
  if index(p-str, '"transp"') = 0
  then do :
    p-ok = no .
    return .
  end .
  if index(p-str, '"nb-cd"') = 0
  then do :
    p-ok = no .
    return .
  end .
  if index(p-str, '"transp-num"') = 0
  then do :
    p-ok = no .
    return .
  end .
  if index(p-str, '"driv"') = 0
  then do :
    p-ok = no .
    return .
  end .
  if index(p-str, '"scs"') = 0
  then do :
    p-ok = no .
    return .
  end .
  if index(p-str, '"sc-num"') = 0
  then do :
    p-ok = no .
    return .
  end .
  if index(p-str, '"gd-cd"') = 0
  then do :
    p-ok = no .
    return .
  end .
  if index(p-str, '"gd-gr"') = 0
  then do :
    p-ok = no .
    return .
  end .
  if index(p-str, '"fill-type"') = 0
  then do :
    p-ok = no .
    return .
  end .
  if index(p-str, '"temp"') = 0
  then do :
    p-ok = no .
    return .
  end .
  if index(p-str, '"dens"') = 0
  then do :
    p-ok = no .
    return .
  end .
  if index(p-str, '"mass"') = 0
  then do :
    p-ok = no .
    return .
  end .
  if index(p-str, '"vol"') = 0
  then do :
    p-ok = no .
    return .
  end .
  if index(p-str, '"dens-st"') = 0
  then do :
    p-ok = no .
    return .
  end .
  if index(p-str, '"contr-err"') = 0
  then do :
    p-ok = no .
    return .
  end .
  if index(p-str, '"pasp"') = 0
  then do :
    p-ok = no .
    return .
  end .
  if index(p-str, '"dens-pas"') = 0
  then do :
    p-ok = no .
    return .
  end .
  v-tmp-str = p-str .
  v-tmp-str = substring(v-tmp-str, index(v-tmp-str, '"scs"') + 6) .
  v-tmp-str = replace(v-tmp-str, chr(123), "") .
  v-tmp-str = replace(v-tmp-str, chr(125), "") .
  v-tmp-str = replace(v-tmp-str, "[", "") .
  v-tmp-str = replace(v-tmp-str, "]", "") .
  v-num-sec = 0 .
  do ii = 1 to num-entries(v-tmp-str) :
    if entry(ii, v-tmp-str) begins '"sc-num"' then v-num-sec = v-num-sec + 1 .
  end.
  v-num-teg = 0 .
  do ii = 1 to num-entries(v-tmp-str) :
    if entry(ii, v-tmp-str) begins '"gd-cd"' then v-num-teg = v-num-teg + 1 .
  end.
  if v-num-teg <> v-num-sec
  then do :
    p-ok = no .
    return .
  end .
  v-num-teg = 0 .
  do ii = 1 to num-entries(v-tmp-str) :
    if entry(ii, v-tmp-str) begins '"gd-gr"' then v-num-teg = v-num-teg + 1 .
  end.
  if v-num-teg <> v-num-sec
  then do :
    p-ok = no .
    return .
  end .
  v-num-teg = 0 .
  do ii = 1 to num-entries(v-tmp-str) :
    if entry(ii, v-tmp-str) begins '"fill-type"' then v-num-teg = v-num-teg + 1 .
  end.
  if v-num-teg <> v-num-sec
  then do :
    p-ok = no .
    return .
  end .
  v-num-teg = 0 .
  do ii = 1 to num-entries(v-tmp-str) :
    if entry(ii, v-tmp-str) begins '"temp"' then v-num-teg = v-num-teg + 1 .
  end.
  if v-num-teg <> v-num-sec
  then do :
    p-ok = no .
    return .
  end .
  v-num-teg = 0 .
  do ii = 1 to num-entries(v-tmp-str) :
    if entry(ii, v-tmp-str) begins '"dens"' then v-num-teg = v-num-teg + 1 .
  end.
  if v-num-teg <> v-num-sec
  then do :
    p-ok = no .
    return .
  end .
  v-num-teg = 0 .
  do ii = 1 to num-entries(v-tmp-str) :
    if entry(ii, v-tmp-str) begins '"mass"' then v-num-teg = v-num-teg + 1 .
  end.
  if v-num-teg <> v-num-sec
  then do :
    p-ok = no .
    return .
  end .
  v-num-teg = 0 .
  do ii = 1 to num-entries(v-tmp-str) :
    if entry(ii, v-tmp-str) begins '"vol"' then v-num-teg = v-num-teg + 1 .
  end.
  if v-num-teg <> v-num-sec
  then do :
    p-ok = no .
    return .
  end .
  v-num-teg = 0 .
  do ii = 1 to num-entries(v-tmp-str) :
    if entry(ii, v-tmp-str) begins '"dens-st"' then v-num-teg = v-num-teg + 1 .
  end.
  if v-num-teg <> v-num-sec
  then do :
    p-ok = no .
    return .
  end .
  v-num-teg = 0 .
  do ii = 1 to num-entries(v-tmp-str) :
    if entry(ii, v-tmp-str) begins '"contr-err"' then v-num-teg = v-num-teg + 1 .
  end.
  if v-num-teg <> v-num-sec
  then do :
    p-ok = no .
    return .
  end .
  v-num-teg = 0 .
  do ii = 1 to num-entries(v-tmp-str) :
    if entry(ii, v-tmp-str) begins '"pasp"' then v-num-teg = v-num-teg + 1 .
  end.
  if v-num-teg <> v-num-sec
  then do :
    p-ok = no .
    return .
  end .
  v-num-teg = 0 .
  do ii = 1 to num-entries(v-tmp-str) :
    if entry(ii, v-tmp-str) begins '"dens-pas"' then v-num-teg = v-num-teg + 1 .
  end.
  if v-num-teg <> v-num-sec
  then do :
    p-ok = no .
    return .
  end .
end .
procedure checkcrc:
  define input parameter p-json-str as char no-undo.
  define input parameter p-crc32 as char no-undo.
  define output parameter p-ok as logical no-undo.
  define variable v-crc32   as character no-undo .
  define variable mpData    as memptr    no-undo .
  define variable inLength  as integer   no-undo .
  p-ok = false.
  inLength     = LENGTH(p-json-str, 'raw').
  set-size(mpData) = 0.
  set-size(mpData) = inLength.
  PUT-STRING(mpData,1,inLength) = p-json-str.
  v-crc32 =  intToHex(CRC32(INPUT mpData)) .
  set-size(mpData) = 0.
  if length(v-crc32) < 8
  then
    v-crc32 = fill("0", 8 - length(v-crc32)) + v-crc32 .
  if p-crc32 = v-crc32
  then do :
    p-ok = true.
  end .
end.
procedure proc-any-key :
  if v-scan-str = ""
  then
    v-timedelay = etime.
  else
  if etime - v-timedelay > qr-scan-time
  then
    v-scan-str = "".
  v-scan-str = v-scan-str + last-event:label.
end.
