/*
codeunit 99944 "Barcode 3 of 9"
{

    trigger OnRun()
    begin
        SetDPI(48, 0, 0);
    end;

    var
        IncludeQuiet: Boolean;
        SpaceAlloc: Integer;
        Bcode: array [45] of Text[9];
        Code39x: array [128] of Text[2];
        "The Pic Width": Integer;
        "The Pic Height": Integer;
        "The Pic DPI": Integer;

    procedure SetDPI(DPI: Integer;Width: Integer;Height: Integer)
    begin
        "The Pic Width" := Width;
        "The Pic Height" := Height;
        "The Pic DPI" := DPI;

        BcodeTab();
        Code39xTab();
    end;

    procedure AddQuiet(Quiet: Boolean)
    begin
        IncludeQuiet := Quiet;
    end;

    procedure MkBarcode("Barcode Text": Text[250];var Pic: Record "2000000001";Extended: Boolean)
    var
        OStrm: OutStream;
        CH: Char;
        L: Integer;
        I: Integer;
        J: Integer;
        X: Integer;
        Y: Integer;
        BarcodeText: Text[1024];
        B: Integer;
        C: Integer;
        N: Integer;
        BC: Text[30];
        Standard39: Label '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. $/+%*';
        XPad: Integer;
        White: Char;
        Black: Char;
    begin
        White := 255; Black := 0;

        IF Extended THEN
          BarcodeText := Code39Unextend("Barcode Text")
        ELSE
          BarcodeText := UPPERCASE("Barcode Text");


        C := STRLEN(BarcodeText);
        BarcodeText := '*' + CONVERTSTR(BarcodeText, '*', '=') + '*';

        N := 3;

        X := (C + 2)*(3 * N  + 6) + (C + 1) * 1;
        Y := ROUND(X * 0.15, 1, '>');

        IF IncludeQuiet THEN X += 20;

        IF ("The Pic Width" <> 0) AND ("The Pic DPI" <> 0) THEN BEGIN
          XPad := ROUND("The Pic Width" / 2540 * "The Pic DPI", 1, '>') - X;
          IF XPad < 0 THEN XPad := 0;
        END ELSE
          XPad := 0;

        IF SpaceAlloc < (XPad+X) * Y THEN
        BEGIN
          // Allocate space.
          SpaceAlloc := (XPad+X) * Y;
          Pic."BLOB Reference".CREATEOUTSTREAM(OStrm);
          FOR I := 1 TO ROUND((XPad+X) * Y * 3 / 1024, 1, '<') DO
            OStrm.WRITETEXT(PADSTR('', 1023, ' ')); // Plus a NUL
        END;

        Pic.ID := 1000000000;
        Pic."BLOB Reference".CREATEOUTSTREAM(OStrm);
        WriteBMHeader(OStrm, (XPad+X), Y, "The Pic Width", "The Pic Height", "The Pic DPI");

        // ImageX := (xpad+X); ImageY := Y; // Save size for later.

        FOR L := 1 TO Y DO BEGIN
          CH := White;
          IF IncludeQuiet THEN FOR I := 1 TO 30 DO OStrm.WRITE(CH, 1);

          FOR I := 1 TO C+2 DO BEGIN
            B := STRPOS(Standard39, FORMAT(BarcodeText[I]));
            IF B = 0 THEN B := 45; // Replace with 39 to change invalid to space.
            BC := Bcode[B];
            IF I <> C+2 THEN BC := BC + '0'; // Gap is a narrow.

            CH := Black; IF B = 45 THEN CH := 127;
            FOR J := 1 TO STRLEN(BC) DO BEGIN
              OStrm.WRITE(CH, 1); OStrm.WRITE(CH, 1); OStrm.WRITE(CH, 1);
              IF BC[J] = '1' THEN BEGIN
                OStrm.WRITE(CH, 1); OStrm.WRITE(CH, 1); OStrm.WRITE(CH, 1);
                OStrm.WRITE(CH, 1); OStrm.WRITE(CH, 1); OStrm.WRITE(CH, 1);
              END;
              CH := 255 - CH; // 255 here is black+white
            END;
          END;

          CH := White;
          IF IncludeQuiet THEN FOR I := 1 TO 30 DO OStrm.WRITE(CH, 1);
          IF XPad > 0 THEN FOR I := 1 TO XPad*3 DO OStrm.WRITE(CH, 1);
          J := (XPad+X) * 3;
          IF J <> ROUND(J, 4, '>') THEN
            FOR I := J+1 TO ROUND(J, 4, '>') DO BEGIN
              OStrm.WRITE(CH, 1);
            END;
        END;
    end;

    local procedure Code39Unextend(C39X: Text[1024]) C39: Text[1024]
    var
        I: Integer;
        Ch: Char;
    begin
        FOR I := 1 TO STRLEN(C39X) DO BEGIN
          Ch := C39X[I];
          IF (Ch = '$') OR (Ch = '%') OR (Ch = '+') OR (Ch = '/') THEN BEGIN
            IF (C39X[I+1] >= 'A') AND (C39X[I+1] <= 'Z') THEN
              C39 := C39 + Code39x[Ch]
            ELSE
              C39 := C39 + FORMAT(Ch);
          END ELSE IF Ch < 128 THEN
            C39 := C39 + Code39x[Ch]
          ELSE
            C39 := C39 + FORMAT(Ch);
        END;
    end;

    local procedure WriteBMHeader(Strm: OutStream;Cols: Integer;Rows: Integer;Width: Integer;Height: Integer;DPI: Integer)
    var
        CH: Char;
        ResX: Integer;
        ResY: Integer;
    begin
        IF DPI > 0 THEN BEGIN
          ResX := ROUND(39.370 * DPI, 1);
          ResY := ResX;
          IF Width > 0 THEN
            ResX := ROUND(Cols / Width * 100000, 1);
          IF Height > 0 THEN
            ResY := ROUND(Rows / Height * 100000, 1);
        END ELSE IF (Width > 0) AND (Height > 0) THEN BEGIN
          ResX := ROUND(Cols / Width * 100000, 1);
          ResY := ROUND(Rows / Height * 100000, 1);
        END;

        // BMP File Header
        CH := 'B' ; Strm.WRITE(CH, 1); // Magic.
        CH := 'M' ; Strm.WRITE(CH, 1);
        Strm.WRITE(54 + Rows * Cols * 3, 4); // BMP file size.
        Strm.WRITE(0, 4); // Reserved for everybody.
        Strm.WRITE(54, 4); // Offset of bitmap.

        // "Pix Mult" := ROUND(39.370 * 96 / "Pix Mult", 1);

        // DIB Header (24 bit)
        Strm.WRITE(40, 4); // Bytes in DIB Header
        Strm.WRITE(Cols, 4); // If not divisible by four padding is required.
        Strm.WRITE(Rows, 4); // -ve means scan is top to bottom (in theory).
        Strm.WRITE(1 + 65536 * 24, 4); // Planes and bpp.
        Strm.WRITE(0, 4); // Compression.
        Strm.WRITE(0, 4); // Raw bitmap size (0=default for uncompressed)
        Strm.WRITE(ResX, 4); // Pixels/metre Horizontal, dpm = 39.370 * dpi, screen = 96dpi (3780)
        Strm.WRITE(ResY, 4); // Pixels/metre Vertical
        Strm.WRITE(0, 4); // Colours in palette (0=default)
        Strm.WRITE(0, 4); // Important colours, ignored.

        // Bytes. BGR
    end;

    local procedure BcodeTab()
    begin
                  //  bsbsbsbsb, 0 = narrow, 1 = wide.
        Bcode[ 1] := '000110100'; // 0
        Bcode[ 2] := '100100001'; // 1
        Bcode[ 3] := '001100001'; // 2
        Bcode[ 4] := '101100000'; // 3
        Bcode[ 5] := '000110001'; // 4
        Bcode[ 6] := '100110000'; // 5
        Bcode[ 7] := '001110000'; // 6
        Bcode[ 8] := '000100101'; // 7
        Bcode[ 9] := '100100100'; // 8
        Bcode[10] := '001100100'; // 9
        Bcode[11] := '100001001'; // A
        Bcode[12] := '001001001'; // B
        Bcode[13] := '101001000'; // C
        Bcode[14] := '000011001'; // D
        Bcode[15] := '100011000'; // E
        Bcode[16] := '001011000'; // F
        Bcode[17] := '000001101'; // G
        Bcode[18] := '100001100'; // H
        Bcode[19] := '001001100'; // I
        Bcode[20] := '000011100'; // J
        Bcode[21] := '100000011'; // K
        Bcode[22] := '001000011'; // L
        Bcode[23] := '101000010'; // M
        Bcode[24] := '000010011'; // N
        Bcode[25] := '100010010'; // O
        Bcode[26] := '001010010'; // P
        Bcode[27] := '000000111'; // Q
        Bcode[28] := '100000110'; // R
        Bcode[29] := '001000110'; // S
        Bcode[30] := '000010110'; // T
        Bcode[31] := '110000001'; // U
        Bcode[32] := '011000001'; // V
        Bcode[33] := '111000000'; // W
        Bcode[34] := '010010001'; // X
        Bcode[35] := '110010000'; // Y
        Bcode[36] := '011010000'; // Z
        Bcode[37] := '010000101'; // -
        Bcode[38] := '110000100'; // .
        Bcode[39] := '011000100'; // Space
        Bcode[40] := '010101000'; // $
        Bcode[41] := '010100010'; // /
        Bcode[42] := '010001010'; // +
        Bcode[43] := '000101010'; // %
        Bcode[44] := '010010100'; // *
        Bcode[45] := '100010001'; // N/A
    end;

    local procedure Code39xTab()
    begin
        Code39x[128] := '%U'; // NUL
        Code39x[  1] := '$A'; // SOH
        Code39x[  2] := '$B'; // STX
        Code39x[  3] := '$C'; // ETX
        Code39x[  4] := '$D'; // EOT
        Code39x[  5] := '$E'; // ENQ
        Code39x[  6] := '$F'; // ACK
        Code39x[  7] := '$G'; // BEL
        Code39x[  8] := '$H'; // BS
        Code39x[  9] := '$I'; // HT
        Code39x[ 10] := '$J'; // LF
        Code39x[ 11] := '$K'; // VT
        Code39x[ 12] := '$L'; // FF
        Code39x[ 13] := '$M'; // CR
        Code39x[ 14] := '$N'; // SO
        Code39x[ 15] := '$O'; // SI
        Code39x[ 16] := '$P'; // DLE
        Code39x[ 17] := '$Q'; // DC1
        Code39x[ 18] := '$R'; // DC2
        Code39x[ 19] := '$S'; // DC3
        Code39x[ 20] := '$T'; // DC4
        Code39x[ 21] := '$U'; // NAK
        Code39x[ 22] := '$V'; // SYN
        Code39x[ 23] := '$W'; // ETB
        Code39x[ 24] := '$X'; // CAN
        Code39x[ 25] := '$Y'; // EM
        Code39x[ 26] := '$Z'; // SUB
        Code39x[ 27] := '%A'; // ESC
        Code39x[ 28] := '%B'; // FS
        Code39x[ 29] := '%C'; // GS
        Code39x[ 30] := '%D'; // RS
        Code39x[ 31] := '%E'; // US
        Code39x[ 32] := ' '; // SPACE
        Code39x[ 33] := '/A'; // !
        Code39x[ 34] := '/B'; // "
        Code39x[ 35] := '/C'; // #
        Code39x[ 36] := '/D'; // $ possibly as $
        Code39x[ 37] := '/E'; // % possibly as %
        Code39x[ 38] := '/F'; // &
        Code39x[ 39] := '/G'; // '
        Code39x[ 40] := '/H'; // (
        Code39x[ 41] := '/I'; // )
        Code39x[ 42] := '/J'; // *
        Code39x[ 43] := '/K'; // + possibly as +
        Code39x[ 44] := '/L'; // ,
        Code39x[ 45] := '-'; // -
        Code39x[ 46] := '.'; // .
        Code39x[ 47] := '/O'; // / possibly as /
        Code39x[ 48] := '0'; // 0
        Code39x[ 49] := '1'; // 1
        Code39x[ 50] := '2'; // 2
        Code39x[ 51] := '3'; // 3
        Code39x[ 52] := '4'; // 4
        Code39x[ 53] := '5'; // 5
        Code39x[ 54] := '6'; // 6
        Code39x[ 55] := '7'; // 7
        Code39x[ 56] := '8'; // 8
        Code39x[ 57] := '9'; // 9
        Code39x[ 58] := '/Z'; // :
        Code39x[ 59] := '%F'; // ;
        Code39x[ 60] := '%G'; // <
        Code39x[ 61] := '%H'; // =
        Code39x[ 62] := '%I'; // >
        Code39x[ 63] := '%J'; // ?
        Code39x[ 64] := '%V'; // @
        Code39x[ 65] := 'A'; // A
        Code39x[ 66] := 'B'; // B
        Code39x[ 67] := 'C'; // C
        Code39x[ 68] := 'D'; // D
        Code39x[ 69] := 'E'; // E
        Code39x[ 70] := 'F'; // F
        Code39x[ 71] := 'G'; // G
        Code39x[ 72] := 'H'; // H
        Code39x[ 73] := 'I'; // I
        Code39x[ 74] := 'J'; // J
        Code39x[ 75] := 'K'; // K
        Code39x[ 76] := 'L'; // L
        Code39x[ 77] := 'M'; // M
        Code39x[ 78] := 'N'; // N
        Code39x[ 79] := 'O'; // O
        Code39x[ 80] := 'P'; // P
        Code39x[ 81] := 'Q'; // Q
        Code39x[ 82] := 'R'; // R
        Code39x[ 83] := 'S'; // S
        Code39x[ 84] := 'T'; // T
        Code39x[ 85] := 'U'; // U
        Code39x[ 86] := 'V'; // V
        Code39x[ 87] := 'W'; // W
        Code39x[ 88] := 'X'; // X
        Code39x[ 89] := 'Y'; // Y
        Code39x[ 90] := 'Z'; // Z
        Code39x[ 91] := '%K'; // [
        Code39x[ 92] := '%L'; // \
        Code39x[ 93] := '%M'; // ]
        Code39x[ 94] := '%N'; // ^
        Code39x[ 95] := '%O'; // _
        Code39x[ 96] := '%W'; // `
        Code39x[ 97] := '+A'; // a
        Code39x[ 98] := '+B'; // b
        Code39x[ 99] := '+C'; // c
        Code39x[100] := '+D'; // d
        Code39x[101] := '+E'; // e
        Code39x[102] := '+F'; // f
        Code39x[103] := '+G'; // g
        Code39x[104] := '+H'; // h
        Code39x[105] := '+I'; // i
        Code39x[106] := '+J'; // j
        Code39x[107] := '+K'; // k
        Code39x[108] := '+L'; // l
        Code39x[109] := '+M'; // m
        Code39x[110] := '+N'; // n
        Code39x[111] := '+O'; // o
        Code39x[112] := '+P'; // p
        Code39x[113] := '+Q'; // q
        Code39x[114] := '+R'; // r
        Code39x[115] := '+S'; // s
        Code39x[116] := '+T'; // t
        Code39x[117] := '+U'; // u
        Code39x[118] := '+V'; // v
        Code39x[119] := '+W'; // w
        Code39x[120] := '+X'; // x
        Code39x[121] := '+Y'; // y
        Code39x[122] := '+Z'; // z
        Code39x[123] := '%P'; // {
        Code39x[124] := '%Q'; // |
        Code39x[125] := '%R'; // }
        Code39x[126] := '%S'; // ~
        Code39x[127] := '%T'; // DEL
    end;
}

*/