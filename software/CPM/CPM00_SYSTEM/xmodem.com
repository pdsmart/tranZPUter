1��=��1 ���[!�"�*�|���+"�*�#"�>ͫ:�ͫ/ͫ �QY*�~ͫ�&�o��O~�W$^�#�F:���izͫKyͫ�~�/2�"�:�<�'�!8"��@1 �2�>�*��!>2��(W:�_�(/��&�2� �QY*��(w�&�o��O~�W$^�#¾:�����(��5K�(��8:�=�"�: �*�#"��Q*�#"�:�<�'ͩÏ<��x�ʏ �(�(�x�(�:�ͫ!�4~�
ړ��x! "��*�|��+"��D�\ �D��x� �W>x�*��������f!�4~�
���x\ �D<�ͣFILE CLOSE ERROR! May be corrupt.$:���! "���D�\ �D��� �*�#"�: ����2�*�|��>ͫ�~��TOK
Sent���>2��*�ê+}�̖>�K��4>	�J>�����U����* o�+}�̖>�K�Z��+}�̖� ��j���+}�̖6�x  �{�����������f!�5*�����*���>�Oê6�x  y���!  +|���� �¿y����)�x>��>�Ky�� �����������}�>��T]<	���_��W{�0O>�K�f:�<�-!+2��=�2���N��\ !	���� �����W���N�~��~#��X��>�K��>	�K�� �TABORT:��B:��ªÚ�Qͩ�TO�͢*�|����<<��ͦ
Empty file deleted$�TReceived�*���ͦ blocks$10 block errors$10 ACK errors$}  0@P`p��������2"RBrb��������$4dtDT��������6&vfVF��������HXhx(8��������ZJzj
:*���뛋��l|L\,<���ݭ���~n^N>.���Ͽ����������� 0 P@p`��������"2BRbr��������4$tdTD��������&6fvFV���陉��XHxh8(��������JZjz
*:���ͽ���|l\L<,���߯���n~N^.> !Bc����)Jk����1sR����9{Z����bC �Ǥ�jK(	�Ϭ�Sr0����[z8�����冧@a#�펯Hi
+�Է�qP3�ܿ�yX;����"`A����*hI����2Qp����:Yx����-No����%Fg����=^����5wV�˨�nO,�à�fG$����_~<��Wv4Lm/�銫De'�Ⴃ}\?�ػ�uT7�г�.lM����&dE����>]|����6Ut����^C$Sync fail$Lost blocks$Disk write fail$UART Tx fail$Undefined Port$No init from receiver$Z!g"�:�OE�x�(�2�ʎ�V�g��W with CRC����W with checksum���N��B�        �	   �C<  \ �D<�.�TFile open
Sen��Wing via�:�=�$=���Wexternal cod���Wdirect I/���WRDR/PU��2��WCO��ͣFile not found$\ �D<�w�TFile exists. Overwrite (Y/N)���	�Yª�<�TFile creat��D<���Wd
Recei���:��³�h�M�f+}�ª:����2�̀̐:�ëͦ fail. Write protect? Directory full?$�>3�K��	>2�!� P~#�
	+�D<��	�2�2�Ͳڿ
���G	�/�?	4> � �0	��	!\ >/#�_	��O	6 #�X	p#�_	!�:��_��_ N#F#^#V��	:��ʊ	!`"2�(�#^#V�"��M        :����TSend or receive (S/R)?���	�R�ҩ	2��� >
�D:� =�:� ���Ͳ��	��;ʷ
�/����!�#N#��
�G!
	�2��<2����!�	�0�<
!�=�<
!�=�<
!�=�u�̈́��G
�w#�>
��N������Q
�o2g
̈́�� �b
�oo�og�oO�o��o���!��\�!q�\��=2��<2�����0��u2�����1��u<2�����·
��T=========================
XMODEM 2.7 By M. Eberhard
=========================
Z80-MBC2 (CP/M 2.2 only)
patched ver. by J4F
=========================
Usage: XMODEM <filename> <option list>
^C aborts

Command line and XMODEM.CFG options:
 /R to receive, /S to send
 /C receive with checksums, otherwise CRC error checking
    (Receiver sets error checking mode when sending)
 /E if CP/M RDR returns with Z set when not ready

--More-��m�T /I<n> patches I/O routines with 8080 code for /X3:
   /I0 h0 h1 ...(up to h7) = initialization
   /I1 h0 h1 ...(up to h7) = Tx data (chr is in reg c)
   /I2 h0 h1 ...(up to h7) = Rx status (Z set if no chr)
   /I3 h0 h1 ...(up to h7) = Rx data (chr in reg a)
 /M console message
 /O pp h0 h1 ... hn sends bytes h1-hn to port pp
 /P ss dd qq rr tt defines direct I/O port:
   ss = status port
   dd = data port
   qq = 00/01 for active low/active high ready bits
   rr = Rx ready bit mask
   tt = Tx ready bit mask

--More-��mͣ /Q for Quiet; else + means good block, - means retry
 /X selects the transfer port:
   /X0 CP/M CON
   /X1 CP/M RDR/PUN (default)
   /X2 Direct I/O, defined by /P option
   /X3 8080 I/O code, patched with /I options
 /Zm for m MHz CPU. 0<m<7, default m=2

CP/M CON and RDR must not strip parity.
Values for /I, /O and /P are 2-digit hex.
$2�T/& unrecognize�� �TJun�:���9ͦ in XMODEM.CFG$ͦ in command line$:�!  	=�S"��s##w#y��h6�#####r��̈́���TBad valu�� Ͳ�͢ڛ����G͞�u��4�����:ڬ�A���0�?����ʲ� ʲ�	ʲ�:����O��D+�D���7�6�!�~�����7�5���
7?ɼ:�;H��$p����C EI	M;OIPXQ}R�S�X�Z�� XMODEM  CFG                                                                         