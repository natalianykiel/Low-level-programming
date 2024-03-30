;=============================================================================;
;                                                                             ;
; Plik           : arch.asm                                                   ;
; Format         : COM                                                        ;                                             ;
; Autorzy        : Hanna Mikołajczyk, Natalia Nykiel                          ;
;                                                                             ;
; Uwagi          : Program obliczajacy wzor: 3*a+b/c                          ;
;                                                                             ;
;=============================================================================;
.model tiny
.stack 24h
assume cs:code, ds:data
data segment                                                                  ; deklaracja danych
    tab         Db      01h, 02h, 00h, 10h, 12h, 33h                          ; deklaracja tablicy
                DB      15h, 09h, 11h, 08h, 0Ah, 00h                       
    DL_TAB      dw      13d                                                   ; zmienna przechowujaca dlugosc tablicy
    reszta      db      0                                                     ; zmienna potrzebna do wyswietlenia wyniku w systemie dziesietnym
    czyZmiana   db      0                                                     ; zmienna flagowa kontrolujaca zakonczenie sortowania
    spacja      db      '; $'
data ends

code segment
    start:
    mov ax,seg data                                                           ; zainicjowanie danych
    mov ds,ax    

    mov ax,0
    mov dx,0
    mov si,0
    mov cx,DL_TAB
    wyswietlanienieposortowanej:
        mov reszta,0                                                         
        mov dl,[si+tab]
        mov ax,dx
        aam
        mov reszta, al
        mov dl,ah
        add dl, 48
        mov ah,02h
        int 21h
        mov dl, reszta
        add dl, 48
        mov ah, 2
        int 21h
        mov dx,offset spacja
        mov ah,9
        int 21h
        inc si
    loop wyswietlanienieposortowanej
    mov dx,0
    mov si,0
    mov ax,0                                                                  ; wyzerowanie rejestru ax
    mov cx, DL_TAB                                                            ; ustawienie rejestru zliczajacego iteracje na ilosc elementow w tablicy   
    mov ch,0                                                                  ; wyzerowanie 'gornej polowy' rejestru (z jakiegos powodu ustawialo gorny rejestr na 16cos i sie program wysypywal)
    mov si,0                                                                  ; wyzerowanie rejestru za pomoca ktorego odwolujemy sie do konkretnego indeksu tablicy

    petla1:
        mov ax,0                                                             
        mov bx,0
        cmp si,12                                                             ; sprawdzenie, czy nie znajdujemy sie na koncu tablicy
        je przejscie                                                          ; jesli tak to przejscie do czesci kodu ktora sprawdza czy cala tablica jest posortowana, jesli nie to wykonuja sie dalsze instrukcje
        mov al,[si+tab]                                                       ; przeniesienie obecnego indeksu do ax
        mov bl,[si+1+tab]                                                     ; przeniesienie elementu z tablicy z kolejnego indeksu do bx
        cmp bl,al                                                             ; porownanie elementow
        jb petla2                                                             ; jesli pierwszy element jest wiekszy to przeniesienie do fragmentu kodu zamieniajacego elementy ze soba
        inc si                                                                ; zwiekszenie indeksu tablicy o 1
        dec cx                                                                ; zmniejszenie iteracji petli o 1
        cmp cx,0                                                              ; sprawdzenie, czy nie osiagnelismy limitu petli, jesli tak to wykonywane jest przejscie
        jne petla1                                                            ; jesli nie to wykonywana jest kolejna iteracja petli petla1

    przejscie:
        mov si,0                                                              ; zerowanie rejestrow w celu unikniecia bledow typu dopisanie do wartosci
        mov ax,0
        mov dx,0
        mov bx,0
        mov cx,0
        mov cx,13d                                                            ; ustawienie rejestru zliczajacego iteracje na rozmiar tablicy
        cmp czyZmiana,0h                                                      ; sprawdzenie, czy tablica nie jest juz posortowana
        mov czyZmiana,0h                                                      ; ustawienie zmiennej flagowej na 0
        jne petla1 
        mov dx,0Ah
        mov ah,2
        int 21H                                                               ; jesli tablica nie jest jeszcze posortowana, to sortowanie jest wykonywane ponownie
        jmp koniec                                                            ; w przeciwnym wypadku tablica jest wyswietlana
 
    petla2:                                                                   ; petla 2 jest odpowiedzialna za zamiane elementow nieposortowanych
        xchg ax,bx                                                           
        shl [si+tab],8                                                        ; zerowanie obecnego elementu tablicy
        mov [si+tab],al                                                       ; zapisanie 'posortowanej' wartosci do obecnego elementu tablicy
        shl [si+tab+1],8                                                      ; zerowanie kolejnego elemntu tablicy
        mov [si+tab+1],bl                                                     ; zapisanie 'posortowanej' wartosci do kolejnego elementu tablicy
        inc si                                                                ; zwiekszenie indeksu o 1
        dec cx                                                                ; zmniejszenie iteracji o 1
        mov czyZmiana,1                                                       ; ustawienie zmiennej flagowej na 1 (informacja, ze zmiana zostala dokonana - tablica nie koniecznie jest posortowana)
        jmp petla1                                                            ; skok na kolejna iteracje petli1

    koniec:
        
        mov dx,0
        mov reszta,0                                                         
        mov dl,[si+tab]
        mov ax,dx
        aam
        mov reszta, al
        mov dl,ah
        add dl, 48
        mov ah,02h
        int 21h
        mov dl, reszta
        add dl, 48
        mov ah, 2
        int 21h
        mov dx,offset spacja
        mov ah,9
        int 21h
        inc si
    loop koniec
    mov ah,4ch
    int 21h

code ends
end start
