/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Описание полей используемых в разных типах cd-trans

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/03/08
Author: Bakhtadze Natalya
Creation date: 06/03/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


&if "{1}" = "ach" &then
&global-define achdate                    chk-date
&global-define achcardnum                 charkey_one
&global-define achstatus                  key#_one
&global-define acherrcode                 key#_two
&global-define acherrmess                 charkey_three
&global-define achtrknum                  key#_five
&global-define achcode                    charkey_two
&global-define achordervol                deckey_one
&global-define achtakevol                 deckey_two
&global-define achret                     logkey_one
&global-define achtranznum                key#_three
&global-define achtime                    key#_four
&global-define achprice                   deckey_three
&global-define achcheckid                 chk-id
&endif

&if "{1}" = "achexp" &then
&global-define achelastdate               chk-date
&global-define achecardnum                charkey_one
&global-define achecode                   charkey_two
&global-define acheexp                    deckey_one
&global-define achemonthexp               deckey_two
&global-define achedayexp                 deckey_three
&endif

&if "{1}" = "achdata" &then
&global-define achdcardnum                charkey_one
&global-define achdnum                    key#_one
&global-define achddate                   chk-date
&global-define achdshop                   obj-code
&global-define achdcashnum                pay-desk
&global-define achdcode                   charkey_two
&global-define achdtrnum                  key#_three
&global-define achdtrk                    key#_five
&global-define achdnozzle                 key#_four
&global-define achdvol                    deckey_one
&endif

&if "{1}" = "cfserial" &then
&global-define cfserial                  charkey_one
&global-define cfserial_doc-code         doc-code
&global-define cfserail_chk-id           chk-id
&global-define cfserial_date             chk-date
&global-define cfserial_time             chk-time
&global-define cfserial_obj-type         obj-type
&global-define cfserial_obj-code         obj-code
&global-define cfserial_pay-desk         pay-desk
&global-define cfserial_chk-num          chk-num
&endif

&if "{1}" = "cfregnum" &then
&global-define cfregnum                  charkey_one
&global-define cfregnum_doc-code         doc-code
&global-define cfregnum_chk-id           chk-id
&global-define cfregnum_date             chk-date
&global-define cfregnum_time             chk-time
&global-define cfregnum_obj-type         obj-type
&global-define cfregnum_obj-code         obj-code
&global-define cfregnum_pay-desk         pay-desk
&global-define cfregnum_chk-num          chk-num
&endif

&if "{1}" = "cfOwner" &then
&global-define cfowner                  charkey_one
&global-define cfowner_doc-code         doc-code
&global-define cfowner_chk-id           chk-id
&global-define cfowner_date             chk-date
&global-define cfowner_time             chk-time
&global-define cfowner_obj-type         obj-type
&global-define cfowner_obj-code         obj-code
&global-define cfowner_pay-desk         pay-desk
&global-define cfowner_chk-num          chk-num
&endif

&if "{1}" = "cfeklzserial" &then
&global-define cfeklzserial                  charkey_one
&global-define cfeklzserial_doc-code         doc-code
&global-define cfeklzserial_chk-id           chk-id
&global-define cfeklzserial_date             chk-date
&global-define cfeklzserial_time             chk-time
&global-define cfeklzserial_obj-type         obj-type
&global-define cfeklzserial_obj-code         obj-code
&global-define cfeklzserial_pay-desk         pay-desk
&global-define cfeklzserial_chk-num          chk-num
&endif

&if "{1}" = "cfzcount" &then
&global-define cfzcount                  key#_one
&global-define cfzcount_doc-code         doc-code
&global-define cfzcount_chk-id           chk-id
&global-define cfzcount_date             chk-date
&global-define cfzcount_time             chk-time
&global-define cfzcount_obj-type         obj-type
&global-define cfzcount_obj-code         obj-code
&global-define cfzcount_pay-desk         pay-desk
&global-define cfzcount_chk-num          chk-num
&endif

&if "{1}" = "cfdate" &then
&global-define cfdate                  charkey_one
&global-define cfdate_doc-code         doc-code
&global-define cfdate_chk-id           chk-id
&global-define cfdate_date             chk-date
&global-define cfdate_time             chk-time
&global-define cfdate_obj-type         obj-type
&global-define cfdate_obj-code         obj-code
&global-define cfdate_pay-desk         pay-desk
&global-define cfdate_chk-num          chk-num
&endif


&if "{1}" = "cfxcount" &then
&global-define cfxcount                  key#_one
&global-define cfxcount_doc-code         doc-code
&global-define cfxcount_chk-id           chk-id
&global-define cfxcount_date             chk-date
&global-define cfxcount_time             chk-time
&global-define cfxcount_obj-type         obj-type
&global-define cfxcount_obj-code         obj-code
&global-define cfxcount_pay-desk         pay-desk
&global-define cfxcount_chk-num          chk-num
&endif


&if "{1}" = "cfejcount" &then
&global-define cfejcount                  key#_one
&global-define cfejcount_doc-code         doc-code
&global-define cfejcount_chk-id           chk-id
&global-define cfejcount_date             chk-date
&global-define cfejcount_time             chk-time
&global-define cfejcount_obj-type         obj-type
&global-define cfejcount_obj-code         obj-code
&global-define cfejcount_pay-desk         pay-desk
&global-define cfejcount_chk-num          chk-num
&endif

&if "{1}" = "cfcash" &then
&global-define cfcash                  deckey_one
&global-define cfcash_doc-code         doc-code
&global-define cfcash_chk-id           chk-id
&global-define cfcash_date             chk-date
&global-define cfcash_time             chk-time
&global-define cfcash_obj-type         obj-type
&global-define cfcash_obj-code         obj-code
&global-define cfcash_pay-desk         pay-desk
&global-define cfcash_chk-num          chk-num
&endif

&if "{1}" = "cfdoccount" &then
&global-define cfdoccount                  key#_one
&global-define cfdoccount_doc-code         doc-code
&global-define cfdoccount_chk-id           chk-id
&global-define cfdoccount_date             chk-date
&global-define cfdoccount_time             chk-time
&global-define cfdoccount_obj-type         obj-type
&global-define cfdoccount_obj-code         obj-code
&global-define cfdoccount_pay-desk         pay-desk
&global-define cfdoccount_chk-num          chk-num
&endif

&if "{1}" = "cfsalesaccum" &then
&global-define cfsalesaccum                  deckey_one
&global-define cfsalesaccum_doc-code         doc-code
&global-define cfsalesaccum_chk-id           chk-id
&global-define cfsalesaccum_date             chk-date
&global-define cfsalesaccum_time             chk-time
&global-define cfsalesaccum_obj-type         obj-type
&global-define cfsalesaccum_obj-code         obj-code
&global-define cfsalesaccum_pay-desk         pay-desk
&global-define cfsalesaccum_chk-num          chk-num
&endif

&if "{1}" = "cfretaccum" &then
&global-define cfretaccum                  deckey_one
&global-define cfretaccum_doc-code         doc-code
&global-define cfretaccum_chk-id           chk-id
&global-define cfretaccum_date             chk-date
&global-define cfretaccum_time             chk-time
&global-define cfretaccum_obj-type         obj-type
&global-define cfretaccum_obj-code         obj-code
&global-define cfretaccum_pay-desk         pay-desk
&global-define cfretaccum_chk-num          chk-num
&endif

&if "{1}" = "cfreg" &then
&global-define cfreg_cfrtype          charkey_one
&global-define cfreg_cframount        deckey_one
&global-define cfreg_cfrcount         key#_one
&global-define cfreg_doc-code         doc-code
&global-define cfreg_chk-id           chk-id
&global-define cfreg_date             chk-date
&global-define cfreg_time             chk-time
&global-define cfreg_obj-type         obj-type
&global-define cfreg_obj-code         obj-code
&global-define cfreg_pay-desk         pay-desk
&global-define cfreg_chk-num          chk-num
&endif






/* $Workfile$ e n d */