main : main.c
	gcc main.c -o main -lpthread
clean : 
	rm -rf main