#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

void *thread_1(void *arg)
{
    printf("Nous sommes dans le thread.\n");
    /* Pour enlever le warning */
    (void) arg;
    pthread_exit(NULL);
}

int main()
{
  pthread_t thread1;
  printf("Avant la création du thread.\n");

  if (pthread_create(&thread1, NULL, thread_1, NULL)) {
    perror("pthread_create");
    return EXIT_FAILURE;
  }

  printf("Après la création du thread.\n");
  return EXIT_SUCCESS;
}
