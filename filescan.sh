#!/bin/bash

check_tools() {
    MISSING=""
    for tool in file strings; do
        command -v "$tool" >/dev/null 2>&1 || MISSING="$MISSING $tool"
    done
    for tool in exiftool binwalk pdfinfo; do
        command -v "$tool" >/dev/null 2>&1 || MISSING="$MISSING $tool"
    done
    [[ -n "$MISSING" ]] && echo "Missing:$MISSING (install for full features)"
}

TARGET="${1:-.}"

echo "File Scanner"
echo "============"
echo "Scanning: $(realpath "$TARGET")"
echo ""

stat --printf="Name: %n\nType: %F\nSize: %s bytes\nAccess: %a (%A)\nUID/GID: %u/%g\nCreated: %w\nModified: %y\nChanged: %z\nAccessed: %x\n" "$TARGET" 2>/dev/null

echo ""
echo "=== File Type Analysis ==="
ACTUAL=$(file -b "$TARGET")
echo "Detected: $ACTUAL"

EXT="${TARGET##*.}"
if [[ -n "$EXT" && ${#EXT} -lt 10 ]]; then
    MIME=$(file --mime-type -b "$TARGET" 2>/dev/null)
    case "$MIME" in
        image/png) EXPECTED="png" ;;
        image/jpeg) EXPECTED="jpg" ;;
        image/gif) EXPECTED="gif" ;;
        application/pdf) EXPECTED="pdf" ;;
        text/plain) EXPECTED="txt" ;;
        video/*) EXPECTED="video" ;;
        audio/*) EXPECTED="audio" ;;
        application/zip|application/x-zip) EXPECTED="zip" ;;
        application/x-executable) EXPECTED="exe" ;;
        *) EXPECTED="" ;;
    esac
    if [[ -n "$EXPECTED" && "${EXT,,}" != "${EXPECTED,,}" ]]; then
        echo "WARNING: Extension mismatch! .$EXT vs expected $EXPECTED"
    fi
fi

FILETYPE=$(file -b "$TARGET")
if echo "$FILETYPE" | grep -qE "ELF.*executable|Mach-O.*executable|PE32"; then
    echo ""
    echo "Binary: Compiled executable detected"
    echo "Architecture: $(echo "$FILETYPE" | grep -oE "(ELF|x86|ARM|aarch64|i[0-9]86|amd64).*" | head -1)"
fi

if [[ -f "$TARGET" ]]; then
    if command -v binwalk >/dev/null 2>&1; then
        echo ""
        echo "=== Embedded Files ==="
        EMBEDDED=$(binwalk -y filesystem "$TARGET" 2>/dev/null | tail -n +4 | head -10)
        if [[ -n "$EMBEDDED" ]]; then
            echo "$EMBEDDED" | sed 's/^/  /'
        else
            echo "  None found"
        fi
    fi

    echo ""
    echo "=== Strings (text) ==="
    strings "$TARGET" 2>/dev/null | grep -E "[[:print:]]{8,}" | head -20 | sed 's/^/  /'

    MIME=$(file --mime-type -b "$TARGET" 2>/dev/null)
    echo ""
    echo "MIME Type: $MIME"

    case "$MIME" in
        image/*)
            echo ""
            echo "=== Image Metadata ==="
            if command -v exiftool >/dev/null 2>&1; then
                exiftool "$TARGET" 2>/dev/null | grep -E "(Make|Model|Date|Software|GPS|Image Size|Camera|Exposure|Aperture|ISO)" | sed 's/^/  /'
            else
                strings "$TARGET" | grep -E "(Exif|EXIF|Camera|Photo|DCF|JFIF)" | head -5 | sed 's/^/  /'
            fi
            ;;
        application/pdf)
            echo ""
            echo "=== PDF Metadata ==="
            if command -v pdfinfo >/dev/null 2>&1; then
                pdfinfo "$TARGET" 2>/dev/null | sed 's/^/  /'
            fi
            ;;
        text/*|application/rtf|application/vnd.*|application/msword)
            echo ""
            echo "=== Document Metadata ==="
            strings "$TARGET" | grep -E "(Author|Creator|Producer|Title|Date):" | head -10 | sed 's/^/  /'
            ;;
    esac

    echo ""
    echo "=== Steganography Check ==="
    if command -v binwalk >/dev/null 2>&1; then
        STEG=$(binwalk "$TARGET" 2>/dev/null | tail -n +4 | head -15)
        if echo "$STEG" | grep -qE "JPEG|PNG|GIF|ZIP|RAR|Archive"; then
            echo "Hidden data signatures:"
            echo "$STEG" | sed 's/^/  /'
        else
            echo "  No hidden signatures found"
        fi
    else
        if strings "$TARGET" | grep -qE "Steghide|OpenStego|outguess|jsteg|F5|zsteg"; then
            echo "  Possible steganography tool signatures"
        else
            echo "  No steganography signatures detected"
        fi
    fi
fi

echo ""
check_tools
