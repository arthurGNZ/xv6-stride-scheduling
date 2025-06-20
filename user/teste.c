#include "kernel/types.h"
#include "user/user.h"

#define N 3

void waste_time() {
  printf("start\n");
  
  volatile unsigned long long i;
  for (i = 0; i < 1000000000ULL; ++i);
  
  printf("stop\n");
}

int main(int argc, char *argv[])
{
  int n, pid;
  int tickets_para_dar[] = {150, 100, 50};

  for(n = 0; n < N; n++) {
    pid = fork();
    if(pid == 0) {
      if (settickets(tickets_para_dar[n]) < 0) {
          printf("Erro: settickets() falhou para o PID %d\n", getpid());
      }
      waste_time();
      exit(0);
    }
  }

  for(n = 0; n < N; n++) {
    int finished_pid = wait(0);
    printf("Child pid = %d finished!\n", finished_pid);
  }

  exit(0);
}