// the lock server implementation

#include "lock_server.h"
#include <sstream>
#include <stdio.h>
#include <unistd.h>
#include <arpa/inet.h>

lock_server::lock_server():
  nacquire (0)
{
	pthread_mutex_init(&mutex, NULL);
	pthread_cond_init(&cond, NULL);
}

lock_protocol::status
lock_server::stat(int clt, lock_protocol::lockid_t lid, int &r)
{
  lock_protocol::status ret = lock_protocol::OK;
  printf("stat request from clt %d\n", clt);
  r = nacquire;
  return ret;
}

lock_protocol::status
lock_server::acquire(int clt, lock_protocol::lockid_t lid, int &r)
{
	lock_protocol::status ret = lock_protocol::OK;

	pthread_mutex_lock(&mutex);
	while(lockState[lid])
	{
		pthread_cond_wait(&cond, &mutex);
	}
	lockState[lid] = 1;
	std::cout << "locked lock No." << lid << std::endl;
	r = lock_protocol::OK;
	pthread_mutex_unlock(&mutex);

	return ret;
}

lock_protocol::status
lock_server::release(int clt, lock_protocol::lockid_t lid, int &r)
{
	lock_protocol::status ret = lock_protocol::OK;
	
	pthread_mutex_lock(&mutex);
	if(!lockState[lid])
	{
		r = lock_protocol::NOENT;
	}
	else
	{
		lockState[lid] = 0;
		std::cout << "unlocked lock No." << lid << std::endl;
		r = lock_protocol::OK;
		pthread_cond_signal(&cond);
	}
	pthread_mutex_unlock(&mutex);

	return ret;
}
