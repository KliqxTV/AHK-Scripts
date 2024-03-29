﻿Jxon_Load(&src, args*) {
    static q := Chr(34)
    
    key := "", is_key := false
    stack := [ tree := [] ]
    is_arr := Map(tree, 1) ; ahk v2
    next := q "{[01234567890-tfn"
    pos := 0
    
    while ( (ch := SubStr(src, ++pos, 1)) != "" ) {
        if InStr(" `t`n`r", ch)
            continue
        if !InStr(next, ch, true) {
            testArr := StrSplit(SubStr(src, 1, pos), "`n")
            
            ln := testArr.Length
            col := pos - InStr(src, "`n",, -(StrLen(src)-pos+1))

            msg := Format("{}: line {} col {} (char {})"
            ,   (next == "")      ? ["Extra data", ch := SubStr(src, pos)][1]
              : (next == "'")     ? "Unterminated string starting at"
              : (next == "\")     ? "Invalid \escape"
              : (next == ":")     ? "Expecting ':' delimiter"
              : (next == q)       ? "Expecting object key enclosed in double quotes"
              : (next == q . "}") ? "Expecting object key enclosed in double quotes or object closing '}'"
              : (next == ",}")    ? "Expecting ',' delimiter or object closing '}'"
              : (next == ",]")    ? "Expecting ',' delimiter or array closing ']'"
              : [ "Expecting JSON value(string, number, [true, false, null], object or array)"
                , ch := SubStr(src, pos, (SubStr(src, pos)~="[\]\},\s]|$")-1) ][1]
            , ln, col, pos)

            throw Error(msg, -1, ch)
        }
        
        obj := stack[1]
        memType := Type(obj)
        is_array := (memType = "Array") ? 1 : 0
        
        if j := InStr("{[", ch) { ; start new object / map?
            val := (j = 1) ? Map() : Array()    ; ahk v2
            
            is_array ? obj.Push(val) : obj[key] := val
            stack.InsertAt(1,val)
            
            is_arr[val] := !(is_key := ch == "{")
            next := q (is_key ? "}" : "{[]0123456789-tfn")
        } else if InStr("}]", ch) {
            stack.RemoveAt(1)
            next := stack[1]==tree ? "" : is_arr[stack[1]] ? ",]" : ",}"
        } else if InStr(",:", ch) {
            is_key := (!is_array && ch == ",")
            next := is_key ? q : q "{[0123456789-tfn"
        } else { ; string | number | true | false | null
            if (ch == q) { ; string
                j := pos
                while j := InStr(src, q,, j+1) {
                    val := StrReplace(SubStr(src, pos+1, j-pos-1), "\\", "\u005C")
                    if (SubStr(val, -1) != "\")
                        break
                }
                if !j ? (pos--, next := "'") : 0
                    continue

                pos := j ; update pos

                val := StrReplace(val, "\/", "/")
                val := StrReplace(val, "\" . q, q)
                , val := StrReplace(val, "\b", "`b")
                , val := StrReplace(val, "\f", "`f")
                , val := StrReplace(val, "\n", "`n")
                , val := StrReplace(val, "\r", "`r")
                , val := StrReplace(val, "\t", "`t")

                j := 0
                while j := InStr(val, "\",, j+1) {
                    if (SubStr(val, j+1, 1) != "u") ? (pos -= StrLen(SubStr(val, j)), next := "\") : 0
                        continue 2

                    xxxx := Abs("0x" . SubStr(val, j+2, 4)) ; \uXXXX - JSON unicode escape sequence
                    if (xxxx < 0x100)
                        val := SubStr(val, 1, j-1) . Chr(xxxx) . SubStr(val, j+6)
                }
                
                if is_key {
                    key := val, next := ":"
                    continue
                }
            } else { ; number | true | false | null
                val := SubStr(src, pos, j := RegExMatch(src, "[\]\},\s]|$",, pos)-pos)
                
                if IsInteger(val)
                    val += 0
                else if IsFloat(val)
                    val += 0
                else if (val == "true" || val == "false")
                    val := (val == "true")
                else if (val == "null")
                    val := ""
                else if is_key {
                    pos--, next := "#"
                    continue
                }
                
                pos += j-1
            }
            
            is_array ? obj.Push(val) : obj[key] := val
            next := obj == tree ? "" : is_array ? ",]" : ",}"
        }
    }
    
    return tree[1]
}

Jxon_Dump(obj, indent:="", lvl:=1) {
    static q := Chr(34)
    
    if IsObject(obj) {
        memType := Type(obj) ; Type.Call(obj)
        is_array := (memType = "Array") ? 1 : 0
        
        if (memType ? (memType != "Object" And memType != "Map" And memType != "Array") : (ObjGetCapacity(obj) == ""))
            throw Error("Object type not supported.`r`n`r`nObj Type: " Type(obj), -1, Format("<Object at 0x{:p}>", ObjPtr(obj)))
        
        if IsInteger(indent)
        {
            if (indent < 0)
                throw Error("Indent parameter must be a postive integer.", -1, indent)
            spaces := indent, indent := ""
            
            Loop spaces ; ===> changed
                indent .= " "
        }
        indt := ""
        
        Loop indent ? lvl : 0
            indt .= indent

        lvl += 1, out := "" ; Make #Warn happy
        for k, v in obj {
            if IsObject(k) || (k == "")
                throw Error("Invalid object key.", -1, k ? Format("<Object at 0x{:p}>", ObjPtr(obj)) : "<blank>")
            
            if !is_array ;// key ; ObjGetCapacity([k], 1)
                out .= (ObjGetCapacity([k]) ? Jxon_Dump(k) : q k q) (indent ? ": " : ":") ; token + padding
            
            out .= Jxon_Dump(v, indent, lvl) ; value
                .  ( indent ? ",`n" . indt : "," ) ; token + indent
        }

        if (out != "") {
            out := Trim(out, ",`n" . indent)
            if (indent != "")
                out := "`n" . indt . out . "`n" . SubStr(indt, StrLen(indent)+1)
        }
        
        return is_array ? "[" . out . "]" : "{" . out . "}"
    } else { ; Number
        If (Type(obj) != "String")
            return obj
        Else {
            obj := StrReplace(obj,"\","\\")
            obj := StrReplace(obj,"`t","\t")
            obj := StrReplace(obj,"`r","\r")
            obj := StrReplace(obj,"`n","\n")
            obj := StrReplace(obj,"`b","\b")
            obj := StrReplace(obj,"`f","\f")
            obj := StrReplace(obj,"/","\/")
            obj := StrReplace(obj,q,"\" q)
            return q obj q
        }
    }
}
