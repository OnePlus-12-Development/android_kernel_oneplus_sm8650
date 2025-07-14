#ifndef __SLIM_H
#define __SLIM_H

#include <linux/proc_fs.h>
#include <linux/seq_file.h>

extern int scx_enable;

extern int cpuctrl_high_ratio;
extern int cpuctrl_low_ratio;
extern int partial_enable;
extern int slim_stats;
extern int misfit_ds;

extern int slim_walt_ctrl;
extern int slim_walt_dump;
extern int slim_walt_policy;
extern int slim_gov_debug;
extern int hmbirdcore_debug;
extern int sched_ravg_window_frame_per_sec;

extern atomic_t __scx_ops_enabled;
extern atomic_t non_ext_task;

extern noinline int tracing_mark_write(const char *buf);
int task_top_id(struct task_struct *p);
void stats_print(char *buf, int len);
extern spinlock_t scx_tasks_lock;

#define HMBIRD_CREATE_PROC_ENTRY(name, mode, parent, proc_ops) \
	do { \
		if (!proc_create(name, mode, parent, proc_ops)) { \
			pr_err("Error creating proc entry %s\n", name); \
			return -ENOMEM; \
		} \
	} while (0)

#define HMBIRD_CREATE_PROC_ENTRY_DATA(name, mode, parent, proc_ops, data) \
	do { \
		if (!proc_create_data(name, mode, parent, proc_ops, data)) { \
			pr_err("Error creating proc entry with data %s\n", name); \
			return -ENOMEM; \
		} \
	} while (0)

#define HMBIRD_PROC_OPS(name, open_func, write_func) \
	static const struct proc_ops name##_proc_ops = { \
		.proc_open = open_func, \
		.proc_write = write_func, \
		.proc_read = seq_read, \
		.proc_lseek = seq_lseek, \
		.proc_release = single_release, \
	}

#endif
