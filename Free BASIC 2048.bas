#define EXTCHAR Chr(255)

'--- Declaration of global variables ---
Dim Shared As Integer gGridSize = 4  'grid size (4 -> 4x4)
Dim Shared As Integer gGrid(gGridSize, gGridSize)
Dim Shared As Integer gScore
Dim Shared As Integer curX, curY
Dim Shared As Integer hasMoved, wasMerge  
' Don't touch these numbers, seriously
Dim Shared As Integer gOriginX, gOriginY
gOriginX = 75 'pixel X of top left of grid
gOriginY = 12 'pixel Y of top right of grida
Dim Shared As Integer gTextOriginX, gTextOriginY, gSquareSide
gTextOriginX = 11
gTextOriginY = 3
gSquareSide = 38 'width/height of block in pixels

'set up all the things!
Dim Shared As Integer gDebug = 0

'--- SUBroutines and FUNCtions ---
Sub addblock
    Dim As Integer emptyCells(gGridSize * gGridSize, 2)
    Dim As Integer emptyCellCount = 0
    Dim As Integer x, y, index, num
    
    For x = 0 To gGridSize - 1
        For y = 0 To gGridSize - 1
            If gGrid(x, y) = 0 Then
                emptyCells(emptyCellCount, 0) = x
                emptyCells(emptyCellCount, 1) = y
                emptyCellCount += 1
            End If
        Next y
    Next x
    
    If emptyCellCount > 0 Then
        index = Int(Rnd * emptyCellCount)
        num = Cint(Rnd + 1) * 2
        gGrid(emptyCells(index, 0), emptyCells(index, 1)) = num
    End If
End Sub

Function pad(num As Integer) As String
    Dim As String strNum = Ltrim(Str(num))
    
    Select Case Len(strNum)
    Case 1: Return "  " + strNum + " "
    Case 2: Return " " + strNum + " "
    Case 3: Return " " + strNum
    Case 4: Return strNum
    End Select
End Function

Sub drawNumber(num As Integer, xPos As Integer, yPos As Integer)
    Dim As Integer c, x, y
    Select Case num
    Case 0:    c = 16
    Case 2:    c = 2
    Case 4:    c = 3
    Case 8:    c = 4
    Case 16:   c = 5
    Case 32:   c = 6
    Case 64:   c = 7
    Case 128:  c = 8
    Case 256:  c = 9
    Case 512:  c = 10
    Case 1024: c = 11
    Case 2048: c = 12
    Case 4096: c = 13
    Case 8192: c = 13
    Case Else: c = 13
    End Select
    
    x = xPos *(gSquareSide + 2) + gOriginX + 1
    y = yPos *(gSquareSide + 2) + gOriginY + 1
    Line(x + 1, y + 1)-(x + gSquareSide - 1, y + gSquareSide - 1), c, BF
    
    If num > 0 Then
        Locate gTextOriginY + 1 +(yPos * 5), gTextOriginX +(xPos * 5) : Print "    "
        Locate gTextOriginY + 2 +(yPos * 5), gTextOriginX +(xPos * 5) : Print pad(num)
        Locate gTextOriginY + 3 +(yPos * 5), gTextOriginX +(xPos * 5)
    End If
End Sub

Function getAdjacentCell(x As Integer, y As Integer, d As String) As Integer
    If (d = "l" And x = 0) Or (d = "r" And x = gGridSize - 1) Or (d = "u" And y = 0) Or (d = "d" And y = gGridSize - 1) Then
        getAdjacentCell = -1
    Else
        Select Case d
        Case "l": getAdjacentCell = gGrid(x - 1, y)
        Case "r": getAdjacentCell = gGrid(x + 1, y)
        Case "u": getAdjacentCell = gGrid(x, y - 1)
        Case "d": getAdjacentCell = gGrid(x, y + 1)
        End Select
    End If
End Function

'Draws the outside grid(doesn't render tiles)
Sub initGraphicGrid
    Dim As Integer x, y, gridSide =(gSquareSide + 2) * gGridSize
    
    Line(gOriginX, gOriginY)-(gOriginX + gridSide, gOriginY + gridSide), 14, BF 'outer square, 3 thick
    Line(gOriginX, gOriginY)-(gOriginX + gridSide, gOriginY + gridSide), 1, B 'outer square, 3 thick
    Line(gOriginX - 1, gOriginY - 1)-(gOriginX + gridSide + 1, gOriginY + gridSide + 1), 1, B
    Line(gOriginX - 2, gOriginY - 2)-(gOriginX + gridSide + 2, gOriginY + gridSide + 2), 1, B
    
    For x = gOriginX + gSquareSide + 2 To gOriginX +(gSquareSide + 2) * gGridSize Step gSquareSide + 2  ' horizontal lines
        Line(x, gOriginY)-(x, gOriginY + gridSide), 1
    Next x
    
    For y = gOriginY + gSquareSide + 2 To gOriginY +(gSquareSide + 2) * gGridSize Step gSquareSide + 2 ' vertical lines
        Line(gOriginX, y)-(gOriginX + gridSide, y), 1
    Next y
End Sub

'Init the(data) grid with 0s
Sub initGrid
    Dim As Integer x, y
    For x = 0 To 3
        For y = 0 To 3
            gGrid(x, y) = 0
        Next y
    Next x
    
    addblock
    addblock
End Sub

Sub moveBlock(sourceX As Integer, sourceY As Integer, targetX As Integer, targetY As Integer, merge As Integer)
    If sourceX < 0 Or sourceX >= gGridSize Or sourceY < 0 Or sourceY >= gGridSize And gDebug = 1 Then
        Locate 0, 0 : Print "moveBlock: source coords out of bounds"
    End If
    
    If targetX < 0 Or targetX >= gGridSize Or targetY < 0 Or targetY >= gGridSize And gDebug = 1 Then
        Locate 0, 0 : Print "moveBlock: source coords out of bounds"
    End If
    
    Dim As Integer sourceSquareValue = gGrid(sourceX, sourceY)
    Dim As Integer targetSquareValue = gGrid(targetX, targetY)
    
    If merge = 1 Then
        If sourceSquareValue = targetSquareValue Then
            gGrid(sourceX, sourceY) = 0
            gGrid(targetX, targetY) = targetSquareValue * 2
            gScore += targetSquareValue * 2 ' Points!
        Elseif gDebug = 1 Then
            Locate 0, 0 : Print "moveBlock: Attempted to merge unequal sqs"
        End If
    Else
        If targetSquareValue = 0 Then
            gGrid(sourceX, sourceY) = 0
            gGrid(targetX, targetY) = sourceSquareValue
        Elseif gDebug = 1 Then
            Locate 0, 0 : Print "moveBlock: Attempted to move to non-empty block"
        End If
    End If
End Sub

Function pColor(r As Integer, g As Integer, b As Integer) As Integer
    Return (r + g * 256 + b * 65536)
End Function

Sub moveToObstacle(x As Integer, y As Integer, direcc As String)
    curX = x : curY = y
    
    Do While getAdjacentCell(curX, curY, direcc) = 0
        Select Case direcc
        Case "l": curX -= 1
        Case "r": curX += 1
        Case "u": curY -= 1
        Case "d": curY += 1
        End Select
    Loop
End Sub

Sub processBlock(x As Integer, y As Integer, direcc As String)
    Dim As Integer merge = 0, mergeDirX, mergeDirY
    If gGrid(x, y) <> 0 Then ' have block
        moveToObstacle(x, y, direcc) ' figure out where it can be moved to
        If getAdjacentCell(curX, curY, direcc) = gGrid(x, y) And wasMerge = 0 Then  ' obstacle can be merged with
            merge = 1
            wasMerge = 1
        Else
            wasMerge = 0
        End If
        
        If curX <> x Or curY <> y Or merge = 1 Then
            mergeDirX = 0
            mergeDirY = 0
            If merge = 1 Then
                Select Case direcc
                Case "l": mergeDirX = -1
                Case "r": mergeDirX = 1
                Case "u": mergeDirY = -1
                Case "d": mergeDirY = 1
                End Select
            End If
            
            moveBlock(x, y, curX + mergeDirX, curY + mergeDirY, merge) ' move to before obstacle or merge
            hasMoved = 1
        End If
    End If
End Sub

Sub renderGrid
    Dim As Integer x, y
    For x = 0 To gGridSize - 1
        For y = 0 To gGridSize - 1
            drawNumber(gGrid(x, y), x, y)
        Next y
    Next x
End Sub

Sub updateScore
    Locate 1, 10 : Print Using "Score: #####"; gScore
End Sub

Sub processMove(direcc As String) '' direcc can be 'l', 'r', 'u', or 'd'
    Dim As Integer x, y
    hasMoved = 0
    
    If direcc = "l" Then
        For y = 0 To gGridSize - 1
            wasMerge = 0
            For x = 0 To gGridSize - 1
                processBlock(x,y,direcc)
            Next x
        Next y
    Elseif direcc = "r" Then
        For y = 0 To gGridSize - 1
            wasMerge = 0
            For x = gGridSize - 1 To 0 Step -1
                processBlock(x,y,direcc)
            Next x
        Next y
    Elseif direcc = "u" Then
        For x = 0 To gGridSize - 1
            wasMerge = 0
            For y = 0 To gGridSize - 1
                processBlock(x,y,direcc)
            Next y
        Next x
    Elseif direcc = "d" Then
        For x = 0 To gGridSize - 1
            wasMerge = 0
            For y = gGridSize - 1 To 0 Step -1
                processBlock(x,y,direcc)
            Next y
        Next x
    End If
    
    If hasMoved = 1 Then addblock
    renderGrid
    updateScore
End Sub


'--- Main Program ---
Screen 8
Windowtitle "2048"
Palette 1, pColor(35, 33, 31)
Palette 2, pColor(46, 46, 51)
Palette 3, pColor(59, 56, 50)
Palette 4, pColor(61, 44, 30)
Palette 5, pColor(61, 37, 25)
Palette 6, pColor(62, 31, 24)
Palette 7, pColor(62, 24, 15)
Palette 8, pColor(59, 52, 29)
Palette 9, pColor(59, 51, 24)
Palette 10, pColor(59, 50, 20)
Palette 11, pColor(59, 49, 16)
Palette 12, pColor(59, 49, 12)
Palette 13, pColor(15, 15, 13)
Palette 14, pColor(23, 22, 20)

Randomize Timer
Cls
Do
    initGrid
    initGraphicGrid
    renderGrid
    updateScore
    
    gScore = 0
    
    Locate 23, 10 : Print "Move with arrow keys."
    Locate 24, 12 : Print "(R)estart, (Q)uit"
    
    Dim As String k
    Do
        Do
            k = Inkey
        Loop Until k <> ""
        
        Select Case k
        Case EXTCHAR + Chr(72) 'up
            processMove("u")
        Case EXTCHAR + Chr(80) 'down
            processMove("d")
        Case EXTCHAR + Chr(77) 'right
            processMove("r")
        Case EXTCHAR + Chr(75) 'left
            processMove("l")
        Case "q", "Q", Chr(27) 'escape
            End
        Case "r", "R"
            Exit Do
        End Select
    Loop
Loop
