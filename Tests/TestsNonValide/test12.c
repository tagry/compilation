void *thread_1(void *arg)
{
    pthread_exit(NULL);
}


int main(void)

{
    pthread_t thread1;
    pthread_create(&thread1, NULL, thread_1, NULL)
    return 0;
}
