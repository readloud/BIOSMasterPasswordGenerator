��~ �+�.��\�$ ��;�� � L�!P���p� ���q� ��p�Xù� ��*��rr�'���C�����2�&�� �� ð ����tAO����uAOJu��+΋�ù  ��������X ��Z�t%�؎�����X����&�� ��� ��/u<Qt� ��>Z�&� �����X�SP���p� �q� �ذ�p�X��[�P�	�!X�00$PSQR�б��$<	0�7����$<	0�7� ���	�!ZY[X����u���<ar<zw, Í�����+������� �L�!VWQ�6��>��  �t������@Y_^ÍZ2��=�!r��ع� ���?�!r�=� u��>�!r��:�s<	vQW� �>�_Yt���ù� ��*�V+����r7���:'t0��u����PF���6���������6��������8���XC��⿅�t�L�!^ð��� CMOSRest 4.7 ۲��

Restores CMOS from a CMOSSave file on hard disk or floppy.
Copyright: (c) 1991-2014 Roedy Green, Canadian Mind Products.
#101 - 2536 Wark Street, Victoria, BC Canada V8T 4G8
tel:(250) 361-9093   mailto:roedyg@mindprod.com   http://mindprod.com
Freeware to freely distribute and use for any purpose except military.

$���� Error ۲��
Insert the diskette you used for CMOSSave.
then try:
CMOSRest A:\CMOS.Sav
or if the file is on hard disk try:
CMOSRest C:\SAFE\CMOS.Sav
CMOSRest is a DOS utility, and thus can only use short 8.3 file names
Read CMOS.TXT to find how to use it properly.
$���� Error ۲��
Cannot find/read the disk file.
$���� Error ۲��
CMOS restore unsuccessful. CMOS is still corrupted at hex offset:value:expected 
$:$
$CMOS successfully restored
$                                                                                                                                                                                                    2