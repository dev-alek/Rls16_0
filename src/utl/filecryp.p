block-level on error undo, throw.
/*

$Revision: 15ea7233baa8, 1928, rls $
$Author: obrezanova $
$Date: Fri Jul 12 15:10:05 2019 +0300 $
$Workfile: filecryp.p $
$Archive: utl/filecryp.p $

шифрование файла

Автор: Белоусов Илья Александрович
Дата создания: 05/16/07
Author: Ilia Belousov
Creation date: 05/16/07

Input: p-in-file

Output: p-out-file

*/
define input parameter p-infile  as character no-undo.
define input parameter p-pasword as character no-undo.
define input parameter p-encrypt as logical   no-undo.
define input parameter p-outfile as character no-undo.

define variable vss-revision    as character no-undo init "$Revision: 15ea7233baa8, 1928, rls $":U .
define variable vss-author      as character no-undo init "$Author: obrezanova $":U .
define variable vss-date        as character no-undo init "$Date: Fri Jul 12 15:10:05 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: filecryp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/filecryp.p $":U .
define variable vss-description as character no-undo init "шифрование файла".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
&if "{1}" = "nodb"
&then
   { gbl/pencrypt.i defproc  }
   { gbl/pdecrypt.i defproc  }
&else
   { cmp/library.i  }
   
&endif
 
DEFINE STREAM st-in.
DEFINE STREAM st-out.


DEFINE VARIABLE v-in-string  AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-out-string AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-file-name  AS CHARACTER NO-UNDO .

DEFINE VARIABLE v-count      AS INTEGER   NO-UNDO .

DO
ON ERROR UNDO, RETURN ERROR
:
   v-file-name = SEARCH(p-infile).

   IF p-encrypt = ? THEN DO:
      RETURN ERROR "Не опредлено дейcтвие".
   END.

   IF p-infile = p-outfile THEN DO:
      RETURN ERROR "Нельзя выходным файлом указывать входной".
   END.

   INPUT  STREAM st-in  FROM VALUE(v-file-name) .
   OUTPUT STREAM st-out TO   VALUE(p-outfile) .

   SECURITY-POLICY:SYMMETRIC-ENCRYPTION-KEY = GENERATE-PBE-KEY(p-pasword).
   REPEAT:
      ASSIGN
         v-out-string = ""
         v-in-string  = ""
      .

      IMPORT STREAM st-in UNFORMATTED
         v-in-string
         .
      if p-encrypt THEN DO:
         { gbl/pencrypt.i v-in-string v-out-string }
      END.
      ELSE DO:
         { gbl/pdecrypt.i v-in-string v-out-string }
      END.

      PUT STREAM st-out UNFORMATTED
         v-out-string SKIP
         .
   END.
   INPUT  STREAM st-in  CLOSE.
   OUTPUT STREAM st-out CLOSE.
END.