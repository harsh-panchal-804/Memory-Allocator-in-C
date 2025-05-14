main : main.c
	gcc main.c -o main -lpthread
clean : 
	rm -rf main
asm :
	gcc main.c -o main.asm -lpthread