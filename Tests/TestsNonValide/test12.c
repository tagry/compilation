void *thread_1(void *arg)
{
    pthread_exit();
}


int main()

{
    pthread_t thread1;
    pthread_create(&thread1, thread_1);
    return 0;
}
