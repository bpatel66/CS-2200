/*
 * student.c
 * Multithreaded OS Simulation for CS 2200
 *
 * This file contains the CPU scheduler for the simulation.
 */

#include <assert.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "os-sim.h"

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-parameter"

/** Function prototypes **/
extern void idle(unsigned int cpu_id);
extern void preempt(unsigned int cpu_id);
extern void yield(unsigned int cpu_id);
extern void terminate(unsigned int cpu_id);
extern void wake_up(pcb_t *process);


/*
 * current[] is an array of pointers to the currently running processes.
 * There is one array element corresponding to each CPU in the simulation.
 *
 * current[] should be updated by schedule() each time a process is scheduled
 * on a CPU.  Since the current[] array is accessed by multiple threads, you
 * will need to use a mutex to protect it.  current_mutex has been provided
 * for your use.
 */
static pcb_t **current;
static pthread_mutex_t current_mutex;
static unsigned int rr_selected;
static int quantum;
static unsigned int srtf_selected;
static unsigned int cpu_count;

/* ready queue implementation starts here */
static pcb_t* head;
static pthread_mutex_t ready_mutex_lock;
static pthread_cond_t not_idle;
/* add to the tail in ready queue*/
static void add_to_tail(pcb_t* process) {
    pcb_t* curr;
    pthread_mutex_lock(&ready_mutex_lock);
    /* do you need to set at pthread_cond to prevent a race condition? */
    if (head == NULL) {
        head = process;
    } else {
        curr = head;
        while (curr -> next != NULL) {
            curr = curr -> next;
        }
        curr -> next = process;
    }
    process -> next = NULL;
    pthread_cond_broadcast(&not_idle);
    pthread_mutex_unlock(&ready_mutex_lock);
}
/* pop head for FIFO */
static pcb_t* pop_head() {
    pcb_t* temp;
    pthread_mutex_lock(&ready_mutex_lock);
    if (head == NULL) {
        pthread_mutex_unlock(&ready_mutex_lock);
        return NULL;
    } else {
        temp = head;
        head = head -> next;
        temp -> next = NULL;
    }
    pthread_mutex_unlock(&ready_mutex_lock);
    return temp;

}
/* SRTF dequeue method */
static pcb_t* srtf_pop() {
    pcb_t* temp = NULL;
    pthread_mutex_lock(&ready_mutex_lock);
    if (head == NULL) {
        pthread_mutex_unlock(&ready_mutex_lock);
        return temp;
    } else {
        unsigned int srtf_process_id = 0;
        pcb_t* curr = head;
        unsigned int lowest_time_remaining = __UINT32_MAX__;

        while (curr != NULL) {
            if (curr -> time_remaining < lowest_time_remaining) {
                srtf_process_id = curr -> pid;
                lowest_time_remaining = curr -> time_remaining;
            }
            curr = curr -> next;
        }
        curr = head;
        pcb_t* prev = NULL;
        while (curr != NULL) {
            if (curr -> pid == srtf_process_id && curr -> time_remaining == lowest_time_remaining) {
                temp = curr;
                if (curr == head) {
                    head = head -> next;
                    pthread_mutex_unlock(&ready_mutex_lock);
                    return temp;
                } else {
                    prev -> next = curr -> next;
                    pthread_mutex_unlock(&ready_mutex_lock);
                    return temp;
                }
            }
            prev = curr;
            curr = curr -> next;
        }
        pthread_mutex_unlock(&ready_mutex_lock);
        return temp;
    }
}


/*
 * schedule() is your CPU scheduler.  It should perform the following tasks:
 *
 *   1. Select and remove a runnable process from your ready queue which
 *	you will have to implement with a linked list or something of the sort.
 *
 *   2. Set the process state to RUNNING
 *
 *   3. Call context_switch(), to tell the simulator which process to execute
 *      next on the CPU.  If no process is runnable, call context_switch()
 *      with a pointer to NULL to select the idle process.
 *	The current array (see above) is how you access the currently running process indexed by the cpu id.
 *	See above for full description.
 *	context_switch() is prototyped in os-sim.h. Look there for more information
 *	about it and its parameters.
 */
static void schedule(unsigned int cpu_id)
{
    /* FIX ME */
    pcb_t* proc_to_be_scheduled;
    if (srtf_selected != 1) {
         proc_to_be_scheduled = pop_head();
    } else {
        proc_to_be_scheduled = srtf_pop();
    }
    if (proc_to_be_scheduled != NULL) {
        proc_to_be_scheduled -> state = PROCESS_RUNNING;
    }
    pthread_mutex_lock(&current_mutex);
    current[cpu_id] = proc_to_be_scheduled;
    pthread_mutex_unlock(&current_mutex);
    context_switch(cpu_id, proc_to_be_scheduled, quantum);

}


/*
 * idle() is your idle process.  It is called by the simulator when the idle
 * process is scheduled.
 *
 * This function should block until a process is added to your ready queue.
 * It should then call schedule() to select the process to run on the CPU.
 */
extern void idle(unsigned int cpu_id)
{
    /* FIX ME */
    pthread_mutex_lock(&ready_mutex_lock);
    while (head == NULL) {
        pthread_cond_wait(&not_idle, &ready_mutex_lock);
    }
    pthread_mutex_unlock(&ready_mutex_lock);
    schedule(cpu_id);
    /*
     * REMOVE THE LINE BELOW AFTER IMPLEMENTING IDLE()
     *
     * idle() must block when the ready queue is empty, or else the CPU threads
     * will spin in a loop.  Until a ready queue is implemented, we'll put the
     * thread to sleep to keep it from consuming 100% of the CPU time.  Once
     * you implement a proper idle() function using a condition variable,
     * remove the call to mt_safe_usleep() below.
     */
}


/*
 * preempt() is the handler called by the simulator when a process is
 * preempted due to its timeslice expiring.
 *
 * This function should place the currently running process back in the
 * ready queue, and call schedule() to select a new runnable process.
 *
 * Remember to set the status of the process to the proper value.
 */
extern void preempt(unsigned int cpu_id)
{
    /* FIX ME */
    pcb_t* current_process;
    pthread_mutex_lock(&current_mutex);
    current_process = current[cpu_id];
    current_process -> state = PROCESS_READY;
    pthread_mutex_unlock(&current_mutex);
    add_to_tail(current_process);
    schedule(cpu_id);
}


/*
 * yield() is the handler called by the simulator when a process yields the
 * CPU to perform an I/O request.
 *
 * It should mark the process as WAITING, then call schedule() to select
 * a new process for the CPU.
 */
extern void yield(unsigned int cpu_id)
{
    /* FIX ME */
    pcb_t* process;
    pthread_mutex_lock(&current_mutex);
    process = current[cpu_id];
    process -> state = PROCESS_WAITING;
    pthread_mutex_unlock(&current_mutex);
    schedule(cpu_id);
}


/*
 * terminate() is the handler called by the simulator when a process completes.
 * It should mark the process as terminated, then call schedule() to select
 * a new process for the CPU.
 */
extern void terminate(unsigned int cpu_id)
{
    /* FIX ME */
    pcb_t* process;
    pthread_mutex_lock(&current_mutex);
    process = current[cpu_id];
    process -> state = PROCESS_TERMINATED;
    pthread_mutex_unlock(&current_mutex);
    schedule(cpu_id);
}


/*
 * wake_up() is the handler called by the simulator when a process's I/O
 * request completes.  It should perform the following tasks:
 *
 *   1. Mark the process as READY, and insert it into the ready queue.
 *
 *   2. If the scheduling algorithm is SRTF, wake_up() may need
 *      to preempt the CPU with the highest remaining time left to allow it to
 *      execute the process which just woke up.  However, if any CPU is
 *      currently running idle, or all of the CPUs are running processes
 *      with a lower remaining time left than the one which just woke up, wake_up()
 *      should not preempt any CPUs.
 *	To preempt a process, use force_preempt(). Look in os-sim.h for
 * 	its prototype and the parameters it takes in.
 */
extern void wake_up(pcb_t *process)
{
    /* FIX ME */
    process -> state = PROCESS_READY;
    add_to_tail(process);
    if (srtf_selected == 1) {
        pthread_mutex_lock(&current_mutex);
        unsigned int most_time_remaining = 0;
        int most_time_remaining_pid = -1;
        for (unsigned int i = 0; i < cpu_count; i++) {
            if (current[i] == NULL) {
                most_time_remaining_pid = -1;
                break;
            }
            if (current[i] -> time_remaining > most_time_remaining) {
                most_time_remaining = current[i] -> time_remaining;
                most_time_remaining_pid = (int) i;
            }
        }
        pthread_mutex_unlock(&current_mutex);
        if (most_time_remaining > process -> time_remaining && most_time_remaining_pid != -1) {
            unsigned int preempted_pid = (unsigned int) most_time_remaining_pid;
            force_preempt(preempted_pid);
        }
    }

}


/*
 * main() simply parses command line arguments, then calls start_simulator().
 * You will need to modify it to support the -r and -s command-line parameters.
 */
int main(int argc, char *argv[])
{
    /* Parse command-line arguments */
    if (argc < 2 || argc > 4)
    {
        fprintf(stderr, "CS 2200 Project 4 -- Multithreaded OS Simulator\n"
            "Usage: ./os-sim <# CPUs> [ -r <time slice> | -s ]\n"
            "    Default : FIFO Scheduler\n"
            "         -r : Round-Robin Scheduler\n"
            "         -s : Shortest Remaining Time First Scheduler\n\n");
        return -1;
    }
    /* FIX ME - Add support for -r and -s parameters*/
    cpu_count = strtoul(argv[1], NULL, 0);
    if (cpu_count == 0) {
        return -1;
    }
    rr_selected = 0;
    quantum = -1;
    srtf_selected = 0;
    if (argc > 2) {
        if (strcmp(argv[2], "-r") == 0) {
            rr_selected = 1;
        }
        if (argc > 3) {
             quantum = strtoul(argv[3], NULL, 0);
        }
        if (strcmp(argv[2], "-s") == 0) {
            srtf_selected = 1;
        }
    }
    /* Allocate the current[] array and its mutex */
    current = malloc(sizeof(pcb_t*) * cpu_count);
    assert(current != NULL);
    pthread_mutex_init(&current_mutex, NULL);
    pthread_mutex_init(&ready_mutex_lock, NULL);
    head = NULL;
    /* Start the simulator in the library */
    start_simulator(cpu_count);

    return 0;
}


#pragma GCC diagnostic pop
