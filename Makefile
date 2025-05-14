main : main.c
	gcc main.c -o main -lpthread
clean : 
	rm -rf main
asm :
	gcc -S main.c -o main.asm -lpthread